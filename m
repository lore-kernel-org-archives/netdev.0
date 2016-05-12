From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] phy: add support for a reset-gpio specification
Date: Thu, 12 May 2016 17:25:09 +0300
Message-ID: <13f35b16-1628-2835-1ff2-149b5e4c5d7e@cogentembedded.com>
References: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <57348A2A.8070806@ti.com> <57348D05.905@ti.com> <57349058.6040708@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de, "Andrew F . Davis" <afd@ti.com>,
	Sekhar Nori <nsekhar@ti.com>, Suman Anna <s-anna@ti.com>
To: Roger Quadros <rogerq@ti.com>, Nishanth Menon <nm@ti.com>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:35690 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbcELOZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 10:25:13 -0400
Received: by mail-lb0-f178.google.com with SMTP id ww9so3582755lbc.2
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 07:25:12 -0700 (PDT)
In-Reply-To: <57349058.6040708@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/2016 5:16 PM, Roger Quadros wrote:

>>>> The framework only asserts (for now) that the reset gpio is not ac=
tive.
>>>>
>>>> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.=
de>
>>>> ---
>>>>  Documentation/devicetree/bindings/net/phy.txt | 3 +++
>>>>  drivers/net/phy/phy_device.c                  | 8 ++++++++
>>>>  2 files changed, 11 insertions(+)
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Docum=
entation/devicetree/bindings/net/phy.txt
>>>> index bc1c3c8bf8fa..c00a9a894547 100644
>>>> --- a/Documentation/devicetree/bindings/net/phy.txt
>>>> +++ b/Documentation/devicetree/bindings/net/phy.txt
>>>> @@ -35,6 +35,8 @@ Optional Properties:
>>>>  - broken-turn-around: If set, indicates the PHY device does not c=
orrectly
>>>>    release the turn around line low at the end of a MDIO transacti=
on.
>>>>
>>>> +- reset-gpios: Reference to a GPIO used to reset the phy.
>>>> +
>>>>  Example:
>>>>
>>>>  ethernet-phy@0 {
>>>> @@ -42,4 +44,5 @@ ethernet-phy@0 {
>>>>  	interrupt-parent =3D <40000>;
>>>>  	interrupts =3D <35 1>;
>>>>  	reg =3D <0>;
>>>> +	reset-gpios =3D <&gpio1 17 GPIO_ACTIVE_LOW>;
>>>>  };
>>>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_de=
vice.c
>>>> index e551f3a89cfd..7d666ab47271 100644
>>>> --- a/drivers/net/phy/phy_device.c
>>>> +++ b/drivers/net/phy/phy_device.c
>>>> @@ -34,6 +34,7 @@
>>>>  #include <linux/io.h>
>>>>  #include <linux/uaccess.h>
>>>>  #include <linux/of.h>
>>>> +#include <linux/gpio/consumer.h>
>>>>
>>>>  #include <asm/irq.h>
>>>>
>>>> @@ -1569,9 +1570,16 @@ static int phy_probe(struct device *dev)
>>>>  	struct device_driver *drv =3D phydev->mdio.dev.driver;
>>>>  	struct phy_driver *phydrv =3D to_phy_driver(drv);
>>>>  	int err =3D 0;
>>>> +	struct gpio_descs *reset_gpios;
>>>>
>>>>  	phydev->drv =3D phydrv;
>>>>
>>>> +	/* take phy out of reset */
>>>> +	reset_gpios =3D devm_gpiod_get_array_optional(dev, "reset",
>>>> +						    GPIOD_OUT_LOW);
>>>> +	if (IS_ERR(reset_gpios))
>>>> +		return PTR_ERR(reset_gpios);
>>>> +
>>>>  	/* Disable the interrupt if the PHY doesn't support it
>>>>  	 * but the interrupt is still a valid one
>>>>  	 */
>>>
>>> This looks like the right approach to me at least: I see that TI EV=
Ms
>>> will also benefit with this approach.
>>
>> Agreed. Although on some of our boards we actually need a RESET puls=
e
>> to get the PHY in a sane state. I can send a patch on top for that.
>
> I think I replied too early. Will phy_probe() be called at all if the
> PHY is not detected on the MDIO bus?

    No. What Uwe haven't said is that the PHY ID needs to be specified =
in the=20
device tree for his patch to actually work. ;-)

> If not then this approach is not sufficient for some of the TI boards=
=2E
> e.g. am57xx-idk.
> I think the reset needs to be done at MDIO bus level before it enumer=
ates
> the PHYs so that we know the PHY is in an enumerable state.

    Have you seen my patch, [1]?

[1] http://patchwork.ozlabs.org/patch/616495/

> cheers,
> -roger

MBR, Seregi
