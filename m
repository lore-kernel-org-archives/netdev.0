From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] net/macb: add support for resetting PHY using GPIO
Date: Fri, 11 Dec 2015 11:21:30 +0100
Message-ID: <20151211102130.GA11966@pengutronix.de>
References: <1449683383-5022-1-git-send-email-gregory.clement@free-electrons.com>
 <20151210073756.GA11966@pengutronix.de>
 <871tau8hpj.fsf@free-electrons.com>
 <20151211084630.GW11966@pengutronix.de>
 <87wpsl727t.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:50343 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751319AbbLKKVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 05:21:40 -0500
Content-Disposition: inline
In-Reply-To: <87wpsl727t.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 11, 2015 at 10:40:22AM +0100, Gregory CLEMENT wrote:
> Hi Sascha,
> =20
>  On ven., d=E9c. 11 2015, Sascha Hauer <s.hauer@pengutronix.de> wrote=
:
>=20
> > On Thu, Dec 10, 2015 at 04:08:08PM +0100, Gregory CLEMENT wrote:
> >> Hi Sascha,
> >> =20
> >>  On jeu., d=E9c. 10 2015, Sascha Hauer <s.hauer@pengutronix.de> wr=
ote:
> >>=20
> >> > Hi Gregory,
> >> >
> >> > On Wed, Dec 09, 2015 at 06:49:43PM +0100, Gregory CLEMENT wrote:
> >> >> With device tree it is no more possible to reset the PHY at boa=
rd
> >> >> level. Furthermore, doing in the driver allow to power down the=
 PHY when
> >> >> the network interface is no more used.
> >> >>=20
> >> >> The patch introduces a new optional property "phy-reset-gpio" i=
nspired
> >> >> from the one use for the FEC.
> >> >
> >> > I don't think it's a good idea to further extend the usage of th=
is
> >> > binding. The driver should use the phy-handle property and
> >> > of_phy_connect() which gives you a proper device node for the ph=
y. Then
> >> > the phy device node should get the reset gpio. I know it's more =
work,
> >>=20
> >> So you suggest to pass from this binding:
> >> macb1: ethernet@fc028000 {
> >> 	phy-mode =3D "rmii";
> >> 	status =3D "okay";
> >> 	#address-cells =3D <1>;
> >> 	#size-cells =3D <0>;
> >> 	status =3D "okay";
> >> 	phy-reset-gpio =3D <&pioE 6 GPIO_ACTIVE_HIGH>;
> >>=20
> >> 	ethernet-phy@1 {
> >> 		reg =3D <0x1>;
> >> 		interrupt-parent =3D <&pioB>;
> >> 		interrupts =3D <31 IRQ_TYPE_EDGE_FALLING>;
> >>=20
> >> 	};
> >> };
> >>=20
> >> to this binding
> >> macb1: ethernet@fc028000 {
> >> 	phy-mode =3D "rmii";
> >> 	status =3D "okay";
> >> 	#address-cells =3D <1>;
> >> 	#size-cells =3D <0>;
> >> 	status =3D "okay";
> >>=20
> >> 	ethernet-phy@1 {
> >> 		reg =3D <0x1>;
> >> 		interrupt-parent =3D <&pioB>;
> >> 		interrupts =3D <31 IRQ_TYPE_EDGE_FALLING>;
> >>                 phy-reset-gpio =3D <&pioE 6 GPIO_ACTIVE_HIGH>;
> >> 	};
> >> };
> >
> > s/phy-reset-gpio/reset-gpios/, but yes.
>=20
> So I took this way. But I had several issues. The first one was that =
to
> be able to create a phy device it must first be detected by
> get_phy_device from of_mdiobus_register_phy.  But in order to be
> detected it must answer during the scan of the mii bus. That means we
> can't bind the gpio to the device in order to use it because when we
> need to manage the reset gpio the device is not yet created.
>=20
> So I see 2 options:
>=20
> - leaving the phy-reset-gpios property in the ethernet node. Thanks t=
o
>   this we can use the gpiod functions, and it is still possible to us=
e
>   manage the power management.
>=20
> - using a reset-gpios property inside the phy node. But then the only
>   solution to get a reference on it, will be to use
>   of_get_named_gpio. All the gpiod functions need a reference to the
>   device that we won't have at this point. Also we will only be able =
to
>   power up the reset, but we won't have any reference to it latter.

Have you seen fwnode_get_named_gpiod()? This seems to be the right
function for the job.

I think we should get the binding right. The code can be changed easier
than the binding later.

Sascha

--=20
Pengutronix e.K.                           |                           =
  |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0  =
  |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-555=
5 |
