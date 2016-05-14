From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Sun, 15 May 2016 00:14:29 +0300
Message-ID: <8bfe965e-aae3-e7a7-ad49-c19ca72e623c@cogentembedded.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de>
 <f1fae99f-2464-8a42-deb8-c27cccf8df12@cogentembedded.com>
 <31707c49-1f61-8ab8-eb87-5ce4e235db7b@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	frowand.list@gmail.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux-kernel@vger.kernel.org,
	Linus Walleij <linus.walleij@linaro.org>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36104 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938AbcENVOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 17:14:34 -0400
Received: by mail-lb0-f175.google.com with SMTP id h1so38013698lbj.3
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 14:14:33 -0700 (PDT)
In-Reply-To: <31707c49-1f61-8ab8-eb87-5ce4e235db7b@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/13/2016 10:18 PM, Sergei Shtylyov wrote:

>>> [we already talked about this patch in #armlinux, I'm now just
>>> forwarding my comments on the list. Background was that I sent an easier
>>> and less complete patch with the same idea. See
>>> http://patchwork.ozlabs.org/patch/621418/]
>>>
>>> [added Linus Walleij to Cc, there is a question for you/him below]
>>>
>>> On Fri, Apr 29, 2016 at 01:12:54AM +0300, Sergei Shtylyov wrote:
>>>> --- net-next.orig/Documentation/devicetree/bindings/net/phy.txt
>>>> +++ net-next/Documentation/devicetree/bindings/net/phy.txt
>>>> @@ -35,6 +35,8 @@ Optional Properties:
>>>>  - broken-turn-around: If set, indicates the PHY device does not correctly
>>>>    release the turn around line low at the end of a MDIO transaction.
>>>>
>>>> +- reset-gpios: The GPIO phandle and specifier for the PHY reset signal.
>>>> +
>>>>  Example:
>>>>
>>>>  ethernet-phy@0 {
>>>
>>> This is great.
>>>
>>>> Index: net-next/drivers/net/phy/at803x.c
>>>> ===================================================================
>>>> --- net-next.orig/drivers/net/phy/at803x.c
>>>> +++ net-next/drivers/net/phy/at803x.c
>>>> @@ -65,7 +65,6 @@ MODULE_LICENSE("GPL");
>>>> [...]
>>>
>>> My patch breaks this driver. I wasn't aware of it.
>>
>>    I tried to be as careful as I could but still it looks that I didn't
>> succeed at that too...
>
>    Hm, I'm starting to forget the vital details about my patch...
>
>> [...]
>>>> Index: net-next/drivers/net/phy/mdio_device.c
>>>> ===================================================================
>>>> --- net-next.orig/drivers/net/phy/mdio_device.c
>>>> +++ net-next/drivers/net/phy/mdio_device.c
>> [...]
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
>>    Well, I thought that config_init() method is designed for that but indeed
>> the LXT driver writes to BMCR in its probe() method and hence is broken.
>> Thank you for noticing...
>
>    It's broken even without my patch. The phylib will cause a PHY soft reset

    Only iff the config_init() method exists in the PHY driver...

> when attaching to the PHY device, so all BMCR programming dpone in the probe()
> method will be lost. My patch does make sense as is.

    No, actually it doesn't. :-(

> Looks like I should alsolook into fixing lxt.c.

    It took me to actually do a patch to understand my fault. Sigh... :-/

> Florian, what do you think?

    Florian, is phy_init_hw() logic correct?

MBR, Sergei
