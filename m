From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] phy: add support for a reset-gpio specification
Date: Fri, 13 May 2016 08:26:31 +0200
Message-ID: <20160513062631.GA28415@pengutronix.de>
References: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <4363f9c0-d447-5fc1-3ac9-382a172a7087@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>, kernel@pengutronix.de,
	"Andrew F . Davis" <afd@ti.com>, Nishanth Menon <nm@ti.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:51366 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751194AbcEMG0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 02:26:35 -0400
Content-Disposition: inline
In-Reply-To: <4363f9c0-d447-5fc1-3ac9-382a172a7087@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sergei,

On Fri, May 13, 2016 at 12:41:47AM +0300, Sergei Shtylyov wrote:
> On 05/12/2016 01:00 PM, Uwe Kleine-K=F6nig wrote:
>=20
> >The framework only asserts (for now) that the reset gpio is not acti=
ve.
> >
> >Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> >---
> > Documentation/devicetree/bindings/net/phy.txt | 3 +++
> > drivers/net/phy/phy_device.c                  | 8 ++++++++
> > 2 files changed, 11 insertions(+)
> >
> >diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documen=
tation/devicetree/bindings/net/phy.txt
> >index bc1c3c8bf8fa..c00a9a894547 100644
> >--- a/Documentation/devicetree/bindings/net/phy.txt
> >+++ b/Documentation/devicetree/bindings/net/phy.txt
> >@@ -35,6 +35,8 @@ Optional Properties:
> > - broken-turn-around: If set, indicates the PHY device does not cor=
rectly
> >   release the turn around line low at the end of a MDIO transaction=
=2E
> >
> >+- reset-gpios: Reference to a GPIO used to reset the phy.
> >+
> > Example:
> >
> > ethernet-phy@0 {
> >@@ -42,4 +44,5 @@ ethernet-phy@0 {
> > 	interrupt-parent =3D <40000>;
> > 	interrupts =3D <35 1>;
> > 	reg =3D <0>;
> >+	reset-gpios =3D <&gpio1 17 GPIO_ACTIVE_LOW>;
> >  };
>=20
>    OK, the example has PHY ID specified in the "compatible" prop. It'=
s a
> vital detail, you should mention it somewhere...

Something like that in the commit log:

	Note that reset is only deasserted when the PHY ID is already
	determined. If your phy doesn't support reading the PHY ID while
	reset is asserted it's recommended to specify it in the
	compatible string. Otherwise the device might fail to probe.

> >diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devi=
ce.c
> >index e551f3a89cfd..7d666ab47271 100644
> >--- a/drivers/net/phy/phy_device.c
> >+++ b/drivers/net/phy/phy_device.c
> [...]
> >@@ -1569,9 +1570,16 @@ static int phy_probe(struct device *dev)
> > 	struct device_driver *drv =3D phydev->mdio.dev.driver;
> > 	struct phy_driver *phydrv =3D to_phy_driver(drv);
> > 	int err =3D 0;
> >+	struct gpio_descs *reset_gpios;
> >
> > 	phydev->drv =3D phydrv;
> >
> >+	/* take phy out of reset */
> >+	reset_gpios =3D devm_gpiod_get_array_optional(dev, "reset",
> >+						    GPIOD_OUT_LOW);
> >+	if (IS_ERR(reset_gpios))
> >+		return PTR_ERR(reset_gpios);
> >+
>=20
>    It would have been logical to assert back the reset GPIO in phy_re=
move(),

Not necessarily. If you want to save some energy it might make sense. I=
f
you only focus on making the device work, ensuring that reset is not
applied is enough.

> no? Also, you'd need to store the GPIO permanently somewhere...

I need to store it, iff I want to do something with the reset line
later. Currently that's not the case.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
