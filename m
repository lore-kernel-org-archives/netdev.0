From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] phy: add support for a reset-gpio specification
Date: Fri, 13 May 2016 22:10:40 +0300
Message-ID: <658c33a1-3304-8b0c-abfd-9e2a8b556d29@cogentembedded.com>
References: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <4363f9c0-d447-5fc1-3ac9-382a172a7087@cogentembedded.com>
 <20160513062631.GA28415@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>, kernel@pengutronix.de,
	"Andrew F . Davis" <afd@ti.com>, Nishanth Menon <nm@ti.com>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:35086 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbcEMTKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 15:10:45 -0400
Received: by mail-lf0-f52.google.com with SMTP id j8so92585058lfd.2
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 12:10:44 -0700 (PDT)
In-Reply-To: <20160513062631.GA28415@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/13/2016 09:26 AM, Uwe Kleine-K=F6nig wrote:

>>> The framework only asserts (for now) that the reset gpio is not act=
ive.
>>>
>>> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>>> ---
>>> Documentation/devicetree/bindings/net/phy.txt | 3 +++
>>> drivers/net/phy/phy_device.c                  | 8 ++++++++
>>> 2 files changed, 11 insertions(+)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Docume=
ntation/devicetree/bindings/net/phy.txt
>>> index bc1c3c8bf8fa..c00a9a894547 100644
>>> --- a/Documentation/devicetree/bindings/net/phy.txt
>>> +++ b/Documentation/devicetree/bindings/net/phy.txt
>>> @@ -35,6 +35,8 @@ Optional Properties:
>>> - broken-turn-around: If set, indicates the PHY device does not cor=
rectly
>>>   release the turn around line low at the end of a MDIO transaction=
=2E
>>>
>>> +- reset-gpios: Reference to a GPIO used to reset the phy.
>>> +
>>> Example:
>>>
>>> ethernet-phy@0 {
>>> @@ -42,4 +44,5 @@ ethernet-phy@0 {
>>> 	interrupt-parent =3D <40000>;
>>> 	interrupts =3D <35 1>;
>>> 	reg =3D <0>;
>>> +	reset-gpios =3D <&gpio1 17 GPIO_ACTIVE_LOW>;
>>>  };
>>
>>    OK, the example has PHY ID specified in the "compatible" prop. It=
's a
>> vital detail, you should mention it somewhere...
>
> Something like that in the commit log:
>
> 	Note that reset is only deasserted when the PHY ID is already
> 	determined. If your phy doesn't support reading the PHY ID while
> 	reset is asserted it's recommended to specify it in the
> 	compatible string. Otherwise the device might fail to probe.

    Yes, that should do.

>>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_dev=
ice.c
>>> index e551f3a89cfd..7d666ab47271 100644
>>> --- a/drivers/net/phy/phy_device.c
>>> +++ b/drivers/net/phy/phy_device.c
>> [...]
>>> @@ -1569,9 +1570,16 @@ static int phy_probe(struct device *dev)
>>> 	struct device_driver *drv =3D phydev->mdio.dev.driver;
>>> 	struct phy_driver *phydrv =3D to_phy_driver(drv);
>>> 	int err =3D 0;
>>> +	struct gpio_descs *reset_gpios;
>>>
>>> 	phydev->drv =3D phydrv;
>>>
>>> +	/* take phy out of reset */
>>> +	reset_gpios =3D devm_gpiod_get_array_optional(dev, "reset",
>>> +						    GPIOD_OUT_LOW);
>>> +	if (IS_ERR(reset_gpios))
>>> +		return PTR_ERR(reset_gpios);
>>> +
>>
>>    It would have been logical to assert back the reset GPIO in phy_r=
emove(),

> Not necessarily. If you want to save some energy it might make sense.=
 If

    Yes, we'd like to do that. Florian (the phylib maintainer) even wan=
ted=20
asserting reset during the PM suspended state.

> you only focus on making the device work, ensuring that reset is not
> applied is enough.

>> no? Also, you'd need to store the GPIO permanently somewhere...
>
> I need to store it, iff I want to do something with the reset line
> later. Currently that's not the case.

    Oops, I seem to somewhat muddled up here. Of course, you need to st=
ore it=20
if you intend to de-assert it later.

> Best regards
> Uwe

MBR, Sergei
