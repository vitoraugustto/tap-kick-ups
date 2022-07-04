local physics = require( "physics" )

physics.start()
physics.setGravity( 0, 80 )

local DECLARED_SCREEN_WIDTH = display.contentWidth
local DECLARED_SCREEN_WIDTH = display.contentHeight
local TOTAL_SCREEN_WIDT	= display.actualContentWidth
local TOTAL_SCREEN_HEIGHT = display.actualContentHeight
local CENTER_X	= display.contentCenterX
local CENTER_Y = display.contentCenterY
local UNUSED_WIDTH = display.actualContentWidth - display.contentWidth
local UNUSED_HEIGHT	= display.actualContentHeight - display.contentHeight
local LEFT = display.contentCenterX - display.actualContentWidth * 0.5
local TOP = display.contentCenterY - display.actualContentHeight * 0.5
local RIGHT = display.contentCenterX + display.actualContentWidth * 0.5
local BOTTOM = display.contentCenterY + display.actualContentHeight * 0.5

local leftWall  = display.newLine ( LEFT, TOP, LEFT, BOTTOM )
leftWall.name = 'leftWall'
local rightWall = display.newLine ( RIGHT, TOP, RIGHT, BOTTOM )
rightWall.name = 'rightWall'
local ceiling = display.newLine ( LEFT, TOP, RIGHT, TOP )
ceiling.name = 'ceiling'
local bottom = display.newLine ( LEFT, BOTTOM, RIGHT, BOTTOM )	
bottom.name = 'bottom'

local walls = { leftWall, rightWall, ceiling, bottom }

physics.addBody( leftWall, 'static', { density=1.0, friction=0.3, bounce=0.2 } )
physics.addBody( rightWall, 'static', { density=1.0, friction=0.3, bounce=0.2 } )
physics.addBody( ceiling, 'static', { density=1.0, friction=0.3, bounce=0.2 } )
physics.addBody( bottom, 'static', { density=1.0, friction=0.3, bounce=0.2 } )


local background = display.newImageRect( "src/assets/images/background.png", 360, 800 )
background.x = display.contentCenterX
background.y = display.contentCenterY

local platform = display.newImageRect( "src/assets/images/platform.png", 360, 60 )
platform.name = "platform"
platform.x = display.contentCenterX
platform.y = display.contentHeight + 100
physics.addBody( platform, "static" )

local ball = display.newImageRect( "src/assets/images/ball.png", 112, 112 )
ball.name = 'ball'
ball.x = display.contentCenterX
ball.y = display.contentCenterY
physics.addBody( ball, "dynamic", { radius=50, bounce=0.7 } )

local kickSounds = { 
  audio.loadSound( "src/assets/sounds/kick-ball1.wav" ), 
  audio.loadSound( "src/assets/sounds/kick-ball2.wav" ), 
  audio.loadSound( "src/assets/sounds/kick-ball3.wav" ) 
}

local tapCount = 0
local tapText = display.newText( tapCount, display.contentCenterX, 20, native.systemFont, 50 )
tapText:setFillColor( 0, 0, 0 )

local record = 0
local recordText = display.newText( 'Recorde:' .. ' ' .. record, display.contentCenterX, -50, native.systemFont, 30 )
recordText:setFillColor( 0, 0, 0 )

local maxKickSound = 8
local numberOfKicks = 0

local rotation = 0

local function pushBall( event )
  local impulseDirection = math.random( -10, 10 ) / 10
  if ( event.phase == 'began' ) then

    numberOfKicks = 0
    audio.setVolume( 1, { channel=kickSounds } )
    audio.play( kickSounds[math.random( 1, 3 )] )
    ball:applyLinearImpulse( impulseDirection , -4, ball.x, ball.y )

    tapCount = tapCount + 1
    tapText.text = tapCount

    if ( tapCount > record ) then
      record = tapCount
      recordText.text = 'Recorde:' .. ' ' .. record
    end
  end
end

local function onPlatformCollision( self, event )
  if ( event.other.name == 'platform' ) then
    if ( event.phase == "began" ) then
      numberOfKicks = numberOfKicks + 1
      if ( numberOfKicks < maxKickSound ) then
        audio.setVolume( 0.2, { channel=kickSounds } )
        audio.play( kickSounds[math.random( 1, 3 )] )
      end

      if ( numberOfKicks == maxKickSound ) then
        ball.x = 100
      end
      tapCount = 0
      tapText.text = tapCount
    end
  end
end

local function onWallCollision( self, event )
  if ( event.other.name == 'ball' ) then
    if ( event.phase == 'began' ) then
      print(ball.isAwake)

      if ( event.target.name == 'leftWall' ) then
        transition.to( ball, { rotation=360, time=10000 } )
      elseif ( event.target.name == 'rightWall' ) then
        transition.to( ball, { rotation=-360, time=10000 } )
      end
    end
  end
end

for i = 1, #walls do
  walls[i].collision = onWallCollision  
  walls[i]:addEventListener( "collision" )
end

ball.collision = onPlatformCollision
ball:addEventListener( "collision" )
ball:addEventListener( "touch", pushBall )


