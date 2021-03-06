mocha = require 'mocha'
should = require 'should'

jsdom = require 'jsdom'

delete require.cache[ require.resolve '../' ]
connectors = require '../'

getHtml = (win)-> win.document.documentElement
getBody = (win)-> win.document.body
getDocument = (win)-> win.document
getWindow = (win)-> win

testParams = [
  [ 'HTMLHtmlElement', getHtml, [ '' ] ]
  [ 'HTMLBodyElement', getBody, [ '/body[1]' ] ]
  [ 'Document', getDocument, [] ]
  [ 'Window', getWindow, [] ]
]

for params in testParams
  do (params)->
    [ name, getTestedNode, expectedSplit ] = params

    describe "connector.#{name}", ->
      window = null

      testedConnector = null

      beforeEach ->
        window = new jsdom.JSDOM().window
        testedConnector = connectors(window, window.document)[name]
      afterEach ->
        window.close()

      describe ".by", ->
        it "should be #{name}'s constructor", ->
          testedConnector.by.should.be.exactly window[name]

      describe ".split", ->
        it "should throw when called with node from another document", ->
          anotherWindow = new jsdom.JSDOM().window
          should(-> testedConnector.split getTestedNode anotherWindow)
            .throw 'The supplied node is not contained by the root node.'

        it "should return proper xpath of #{name}", ->
          node = getTestedNode window
          actualSplit = testedConnector.split node
          actualSplit.should.be.eql expectedSplit

      describe ".create", ->
        it "should return the same node from which xpath was created", ->
          node = getTestedNode window
          splitted = testedConnector.split node
          created = testedConnector.create splitted
          (created is node).should.be.true

