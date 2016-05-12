From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH] phy: add support for a reset-gpio specification
Date: Thu, 12 May 2016 17:16:56 +0300
Message-ID: <57349058.6040708@ti.com>
References: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <57348A2A.8070806@ti.com> <57348D05.905@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <kernel@pengutronix.de>, "Andrew F . Davis" <afd@ti.com>,
	Sekhar Nori <nsekhar@ti.com>, Suman Anna <s-anna@ti.com>
To: Nishanth Menon <nm@ti.com>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:43155 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752083AbcELORI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 10:17:08 -0400
In-Reply-To: <57348D05.905@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/16 17:02, Roger Quadros wrote:
> Hi,
>=20
> On 12/05/16 16:50, Nishanth Menon wrote:
>> On 05/12/2016 05:00 AM, Uwe Kleine-K=C3=B6nig wrote:
>>> The framework only asserts (for now) that the reset gpio is not act=
ive.
>>>
>>> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.d=
e>
>>> ---
>>>  Documentation/devicetree/bindings/net/phy.txt | 3 +++
>>>  drivers/net/phy/phy_device.c                  | 8 ++++++++
>>>  2 files changed, 11 insertions(+)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Docume=
ntation/devicetree/bindings/net/phy.txt
>>> index bc1c3c8bf8fa..c00a9a894547 100644
>>> --- a/Documentation/devicetree/bindings/net/phy.txt
>>> +++ b/Documentation/devicetree/bindings/net/phy.txt
>>> @@ -35,6 +35,8 @@ Optional Properties:
>>>  - broken-turn-around: If set, indicates the PHY device does not co=
rrectly
>>>    release the turn around line low at the end of a MDIO transactio=
n.
>>> =20
>>> +- reset-gpios: Reference to a GPIO used to reset the phy.
>>> +
>>>  Example:
>>> =20
>>>  ethernet-phy@0 {
>>> @@ -42,4 +44,5 @@ ethernet-phy@0 {
>>>  	interrupt-parent =3D <40000>;
>>>  	interrupts =3D <35 1>;
>>>  	reg =3D <0>;
>>> +	reset-gpios =3D <&gpio1 17 GPIO_ACTIVE_LOW>;
>>>  };
>>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_dev=
ice.c
>>> index e551f3a89cfd..7d666ab47271 100644
>>> --- a/drivers/net/phy/phy_device.c
>>> +++ b/drivers/net/phy/phy_device.c
>>> @@ -34,6 +34,7 @@
>>>  #include <linux/io.h>
>>>  #include <linux/uaccess.h>
>>>  #include <linux/of.h>
>>> +#include <linux/gpio/consumer.h>
>>> =20
>>>  #include <asm/irq.h>
>>> =20
>>> @@ -1569,9 +1570,16 @@ static int phy_probe(struct device *dev)
>>>  	struct device_driver *drv =3D phydev->mdio.dev.driver;
>>>  	struct phy_driver *phydrv =3D to_phy_driver(drv);
>>>  	int err =3D 0;
>>> +	struct gpio_descs *reset_gpios;
>>> =20
>>>  	phydev->drv =3D phydrv;
>>> =20
>>> +	/* take phy out of reset */
>>> +	reset_gpios =3D devm_gpiod_get_array_optional(dev, "reset",
>>> +						    GPIOD_OUT_LOW);
>>> +	if (IS_ERR(reset_gpios))
>>> +		return PTR_ERR(reset_gpios);
>>> +
>>>  	/* Disable the interrupt if the PHY doesn't support it
>>>  	 * but the interrupt is still a valid one
>>>  	 */
>>>
>>
>> This looks like the right approach to me at least: I see that TI EVM=
s
>> will also benefit with this approach.
>>
>=20
> Agreed. Although on some of our boards we actually need a RESET pulse
> to get the PHY in a sane state. I can send a patch on top for that.
>=20

I think I replied too early. Will phy_probe() be called at all if the
PHY is not detected on the MDIO bus?
If not then this approach is not sufficient for some of the TI boards.
e.g. am57xx-idk.
I think the reset needs to be done at MDIO bus level before it enumerat=
es
the PHYs so that we know the PHY is in an enumerable state.

cheers,
-roger
