From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: leds: Add support for "link" trigger
Date: Mon, 30 Oct 2017 11:56:21 -0700
Message-ID: <9cae12ab-7069-cf53-2584-392f185699cf@gmail.com>
References: <65b5c84f-1222-bbc3-24f5-723e07bbb6ed@maciej.szmigiero.name>
 <74fd5477-9165-3372-f386-3f46948b79d6@gmail.com>
 <b373a431-9edb-967b-7dad-0fba40fa5a32@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
To: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b373a431-9edb-967b-7dad-0fba40fa5a32@maciej.szmigiero.name>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2017 11:46 AM, Maciej S. Szmigiero wrote:
> On 30.10.2017 19:36, Florian Fainelli wrote:
>> On 10/28/2017 08:27 AM, Maciej S. Szmigiero wrote:
>>> Currently, we create a LED trigger for any link speed known to a PHY.
>>> These triggers only fire when their exact link speed had been negotiated
>>> (they aren't cumulative, that is, they don't fire for "their or any higher"
>>> link speed).
>>>
>>> What we are missing, however, is a trigger which will fire on any link
>>> speed known to the PHY. Such trigger can then be used for implementing a
>>> poor man's substitute of the "link" LED on boards that lack it.
>>> Let's add it.
>>
>> The use case definitively makes sense, but the implementation a little less.
>>
>>>
>>> Signed-off-by: Maciej S. Szmigiero <mail@maciej.szmigiero.name>
>>> ---
>>>  drivers/net/phy/Kconfig            |  7 +++++--
>>>  drivers/net/phy/phy_led_triggers.c | 19 ++++++++++++++++---
>>>  2 files changed, 21 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
>>> index cd931cf9dcc2..3bcc2107ad77 100644
>>> --- a/drivers/net/phy/Kconfig
>>> +++ b/drivers/net/phy/Kconfig
>>> @@ -191,11 +191,14 @@ config LED_TRIGGER_PHY
>>>  	  Adds support for a set of LED trigger events per-PHY.  Link
>>>  	  state change will trigger the events, for consumption by an
>>>  	  LED class driver.  There are triggers for each link speed currently
>>> -	  supported by the phy, and are of the form:
>>> +	  supported by the PHY and also a one common "link" trigger as a
>>> +	  logical-or of all the link speed ones.
>>> +	  All these triggers are named according to the following pattern:
>>>  	      <mii bus id>:<phy>:<speed>
>>>  
>>>  	  Where speed is in the form:
>>> -		<Speed in megabits>Mbps or <Speed in gigabits>Gbps
>>> +		<Speed in megabits>Mbps OR <Speed in gigabits>Gbps OR link
>>> +		for any speed known to the PHY.
>>>  
>>>  
>>>  comment "MII PHY device drivers"
>>> diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
>>> index 94ca42e630bb..5b6f1876f514 100644
>>> --- a/drivers/net/phy/phy_led_triggers.c
>>> +++ b/drivers/net/phy/phy_led_triggers.c
>>> @@ -20,7 +20,8 @@ static struct phy_led_trigger *phy_speed_to_led_trigger(struct phy_device *phy,
>>>  {
>>>  	unsigned int i;
>>>  
>>> -	for (i = 0; i < phy->phy_num_led_triggers; i++) {
>>> +	/* the first (i = 0) trigger is for "any" speed */
>>> +	for (i = 1; i < phy->phy_num_led_triggers; i++) {
>>>  		if (phy->phy_led_triggers[i].speed == speed)
>>>  			return &phy->phy_led_triggers[i];
>>
>> This looks unnecessary, because existing LED triggers are all relative
>> to a particular speed, you need to coerce the existing code into
>> accepting SPEED_UNKNOWN as a hint to mean "link". Just implement "link"
>> as a different trigger that does not need the speed argument/lookup to
>> be happening and don't change how the indexing into the array of speed
>> triggers is done. Just have a separate "link" trigger that is stored
>> separately from that existing array.
> 
> This way of implementation (overloading SPEED_UNKNOWN) needed least
> modification to the driver, but if a purer way is preferred then ok.

Sure, that makes it simpler to implement, but it seems to me this would
be cleaner if the "link" trigger was handled separately, the next thing
that comes to mind is actually implementing an "activity" trigger, and
this one is likely also reasonably speed independent.

> 
>> Also, what happens if I set both "link" and a given "speed" and my RJ-45
>> connector only has two LEDs, and one of them is already used for "activity"?
> 
> One LED can have only one trigger attached AFAIK.

True, so we should be fine, thanks!
-- 
Florian
