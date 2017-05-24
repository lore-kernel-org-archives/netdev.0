From: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Subject: RE: [PATCH v2] drivers: phy: Add Cortina CS4340 driver
Date: Wed, 24 May 2017 13:52:41 +0000
Message-ID: <DB5PR04MB1240541B2CFB2C99ED519CDFEAFE0@DB5PR04MB1240.eurprd04.prod.outlook.com>
References: <1495617948-13435-1-git-send-email-bogdan.purcareata@nxp.com>
 <20170524125830.GB24341@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170524125830.GB24341@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, May 24, 2017 3:59 PM
> To: Bogdan Purcareata <bogdan.purcareata@nxp.com>
> Cc: f.fainelli@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH v2] drivers: phy: Add Cortina CS4340 driver
>=20
> On Wed, May 24, 2017 at 09:25:48AM +0000, Bogdan Purcareata wrote:
> > Add basic support for Cortina PHY drivers. Support only CS4340 for now.
> > The phys are not compatible with IEEE 802.3 clause 45 registers.
> Implement
> > proper read_status support, so that phy polling does not cause bus
> > register access errors.
> >
> > The driver should be described using the "ethernet-phy-id" device tree
> > compatible.
>=20
> Hi Bogdan
>=20
> Thanks for testing that ethernet-phy-id works.
>=20
> I suggest you write a
> Documentation/devicetree/binding/net/phy/cortina.txt giving an example
> device tree node.

Yes, I can do that. However, I don't see a "phy" folder under Documentation=
/devicetree/bindings/net/.
Should I change the location to Documentation/devicetree/bindings/net/corti=
na.txt instead?

> >
> > Signed-off-by: Bogdan Purcareata <bogdan.purcareata@nxp.com>
> > ---
> > v1 -> v2:
> > - Rename "mdio-cortina.c" to "cortina.c" since it's a phy driver.
> > - Test probing based on the "ethernet-phy-id" compatible. In the previo=
us
> >   version, getting the phy_id via get_phy_c45_ids() involved an
> additional
> >   hack. Drop that approach and document probing in the commit message.
> >
> >  drivers/net/phy/Kconfig   |  5 +++
> >  drivers/net/phy/Makefile  |  1 +
> >  drivers/net/phy/cortina.c | 90
> +++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 96 insertions(+)
> >  create mode 100644 drivers/net/phy/cortina.c
> >
> > diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> > index 22dea7f..ad09e2d 100644
> > --- a/drivers/net/phy/Kconfig
> > +++ b/drivers/net/phy/Kconfig
> > @@ -240,6 +240,11 @@ config CICADA_PHY
> >  	---help---
> >  	  Currently supports the cis8204
> >
> > +config CORTINA_PHY
> > +	tristate "Cortina quad-10G Ethernet PHY"
> > +	---help---
> > +	  Currently supports the CS4340 phy.
> > +
> >  config DAVICOM_PHY
> >  	tristate "Davicom PHYs"
> >  	---help---
> > diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> > index 79365be..0de3e20 100644
> > --- a/drivers/net/phy/Makefile
> > +++ b/drivers/net/phy/Makefile
> > @@ -47,6 +47,7 @@ obj-$(CONFIG_BCM_CYGNUS_PHY)	+=3D bcm-cygnus.o
> >  obj-$(CONFIG_BCM_NET_PHYLIB)	+=3D bcm-phy-lib.o
> >  obj-$(CONFIG_BROADCOM_PHY)	+=3D broadcom.o
> >  obj-$(CONFIG_CICADA_PHY)	+=3D cicada.o
> > +obj-$(CONFIG_CORTINA_PHY)	+=3D cortina.o
> >  obj-$(CONFIG_DAVICOM_PHY)	+=3D davicom.o
> >  obj-$(CONFIG_DP83640_PHY)	+=3D dp83640.o
> >  obj-$(CONFIG_DP83848_PHY)	+=3D dp83848.o
> > diff --git a/drivers/net/phy/cortina.c b/drivers/net/phy/cortina.c
> > new file mode 100644
> > index 0000000..6f054ed
> > --- /dev/null
> > +++ b/drivers/net/phy/cortina.c
> > @@ -0,0 +1,90 @@
> > +/*
> > + *    Based on code from Cortina Systems, Inc.
> > + *
> > + *    Copyright 2011 Cortina Systems, Inc.
> > + *    Copyright 2017 NXP
> > + *
> > + *    This program is free software; you can redistribute it and/or
> modify
> > + *    it under the terms of the GNU General Public License as publishe=
d
> by
> > + *    the Free Software Foundation; either version 2 of the License, o=
r
> > + *    (at your option) any later version.
> > + *
> > + *    This program is distributed in the hope that it will be useful,
> > + *    but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + *    GNU General Public License for more details.
> > + *
> > + */
> > +#include <linux/module.h>
> > +#include <linux/phy.h>
> > +
> > +#define PHY_ID_CS4340	0x13e51002
> > +
> > +#define CORTINA_GPIO_GPIO_INTS				0x16D
> > +
> > +static int cortina_read_x(struct phy_device *phydev, int off, u16
> regnum)
> > +{
> > +	return mdiobus_read(phydev->mdio.bus, phydev->mdio.addr + off,
> > +			    MII_ADDR_C45 | regnum);
> > +}
> > +
> > +static int cortina_read(struct phy_device *phydev, u16 regnum)
> > +{
> > +	return cortina_read_x(phydev, 0, regnum);
> > +}
> > +
> > +static int cortina_config_aneg(struct phy_device *phydev)
> > +{
> > +	phydev->supported =3D SUPPORTED_10000baseT_Full;
> > +	phydev->advertising =3D SUPPORTED_10000baseT_Full;
> > +
> > +	return 0;
> > +}
> > +
> > +static int cortina_read_status(struct phy_device *phydev)
> > +{
> > +	int gpio_int_status;
> > +	int ret =3D 0;
>=20
> I think there needs to be some explanation here. What exactly are you
> using to indicate link up? What does CORTINA_GPIO_GPIO_INTS mean?

I can only assume it's the location of an interrupt status register. The Co=
rtina PHYs go mostly undocumented, I've found an implementation in an old t=
hread [1], that also did the job of programming the Cortina PHY microcode. =
I understand that microcode programming is now part of the bootloader.

The register seems to provide the link status properly, and based on that t=
he phydev is initialized with the only (currently) supported configuration,=
 10Gbps full duplex.

I can change the register name to something more meaningful, though - e.g. =
CORTINA_LINK_STATUS.

> > +	gpio_int_status =3D cortina_read(phydev, CORTINA_GPIO_GPIO_INTS);
> > +	if (gpio_int_status < 0) {
> > +		ret =3D gpio_int_status;
> > +		goto err;
> > +	}
> > +
> > +	if (gpio_int_status & 0x8) {
> > +		phydev->speed =3D SPEED_10000;
> > +		phydev->duplex =3D DUPLEX_FULL;
> > +		phydev->link =3D 1;
> > +	} else {
> > +		phydev->link =3D 0;
> > +	}
> > +
> > +err:
> > +	return ret;
> > +}
> > +
> > +static int cortina_soft_reset(struct phy_device *phydev)
> > +{
> > +	return 0;
> > +}
> > +
> > +static struct phy_driver cortina_driver[] =3D {
> > +{
> > +	.phy_id         =3D PHY_ID_CS4340,
> > +	.phy_id_mask    =3D 0xffffffff,
> > +	.name           =3D "Cortina CS4340",
> > +	.config_aneg    =3D cortina_config_aneg,
> > +	.read_status    =3D cortina_read_status,
> > +	.soft_reset     =3D cortina_soft_reset,
> > +},
> > +};
>=20
> Having two } at the same indentation level seems odd. Please can you
> fix this.

I've purposely left them on the same indentation level in case more Cortina=
 PHY IDs will be added (similar to the situation in drivers/net/phy/aquanti=
a.c). If it does look odd, I can refactor it to use the proper indentation.

[1] https://www.linux-mips.org/archives/linux-mips/2012-05/msg00314.html

Thank you!
Bogdan
