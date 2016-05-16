From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Mon, 16 May 2016 11:51:27 +0300
Message-ID: <57398A0F.8070708@ti.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de> <5735995B.8030802@ti.com>
 <b9bcc192-f97b-304e-77b2-894c4528ddb6@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <grant.likely@linaro.org>, <robh+dt@kernel.org>,
	<devicetree@vger.kernel.org>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <frowand.list@gmail.com>,
	<pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<linux-kernel@vger.kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([198.47.19.12]:52748 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194AbcEPIvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2016 04:51:55 -0400
In-Reply-To: <b9bcc192-f97b-304e-77b2-894c4528ddb6@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/05/16 22:36, Sergei Shtylyov wrote:
> Hello.
> 
> On 05/13/2016 12:07 PM, Roger Quadros wrote:
> 
> [...]
> 
>>>> +}
>>>> +EXPORT_SYMBOL(mdio_device_reset);
>>>> +
>>>>  /**
>>>>   * mdio_probe - probe an MDIO device
>>>>   * @dev: device to probe
>>>> @@ -117,9 +126,16 @@ static int mdio_probe(struct device *dev
>>>>      struct mdio_driver *mdiodrv = to_mdio_driver(drv);
>>>>      int err = 0;
>>>>
>>>> -    if (mdiodrv->probe)
>>>> +    if (mdiodrv->probe) {
>>>> +        /* Deassert the reset signal */
>>>> +        mdio_device_reset(mdiodev, 0);
>>>> +
>>>>          err = mdiodrv->probe(mdiodev);
>>>>
>>>> +        /* Assert the reset signal */
>>>> +        mdio_device_reset(mdiodev, 1);
>>>
>>> I wonder if it's safe to do this in general. What if ->probe does
>>> something with the phy that is lost by resetting but that is relied on
>>> later?
>>
>> mdio_probe is called for non PHY devices only, right?
> 
>    Yes, those also can have a reset signal.
> 
>> I'm a bit lost as to why we're de-asserting reset at multiple places. i.e.
>> mdio_probe(), phy_device_register(), phy_init_hw(), phy_probe(), of_mdiobus_register_phy().
> 
>> Isn't it simpler to just de-assert it once at the topmost level?
> 
>    I wasn't after simplicity here. The intent was to save some power putting the device at reset when it's not needed. Florian Fainelly (the phylib maintainer) actually wanted me to go even further with that and assert reset in phy_suspend() but it was too much for me.

Is using RESET for power saving a standard practice? Isn't there some register interface for power saving?
My concern here is that RESET does a number of things that might be undesired for normal operation.
e.g. PHY's will use bootstrap settings on RESET and we need to ensure that bootstrap pins are always in
the right setting before issuing a RESET.

What happens to the PHY link? Is it lost while PHY RESET is asserted?
Is this really desirable?


> 
>> i.e. of_mdiobus_register_device() f and of_mdiobus_register_phy()?
>>
>> Also, how about issuing a reset pulse instead of just de-asserting it.
> 
>    If it's already held at reset, my assumption is that it's enough time passed already.
> 
>> This would tackle the case where PHY is in invalid state with reset already
>> de-asserted.
> 
>     Good question. I haven't yet met such cases though.
> 
>> Another issue is that on some boards we have one reset line tied to
>> multiple PHYs.How do we prevent multiple resets being taking place when each of
>> the PHYs are registered?
> 
>    My patch just doesn't address this case -- it's about the individual resets only.
> 
>> Do we just specify the reset line only for one PHY in
>> the DT or can we have the reset gpio in the mdio_bus node for such case?
> 
>    I think there's mii_bus::reset() method for that case. Some Ethernet drivers even use it
> (mostly instead of the code being suggested here).
> 
