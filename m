From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [RFC PATCH v2 2/4] net: ethernet: xilinx: Add gmii2rgmii
 converter support
Date: Mon, 4 Jul 2016 11:54:02 +0200
Message-ID: <577A323A.4080207@atmel.com>
References: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
 <1467623084-15471-3-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	<robh+dt@kernel.org>, <mark.rutland@arm.com>,
	<michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
	<punnaia@xilinx.com>, <f.fainelli@gmail.com>, <andrew@lunn.ch>,
	<anirudh@xilinx.com>, <harinik@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467623084-15471-3-git-send-email-appanad@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 04/07/2016 11:04, Kedareswara rao Appana a =E9crit :
> This patch adds support for gmii2rgmii converter.
>=20
> The GMII to RGMII IP core provides the Reduced Gigabit Media
> Independent Interface (RGMII) between Ethernet physical media
> Devices and the Gigabit Ethernet controller. This core can
> Switch dynamically between the three different speed modes of
> Operation by configuring the converter register through mdio write.
>=20
> MDIO interface is used to set operating speed of Ethernet MAC.
>=20
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> ---
> Changes for v2:
> --> Passed struct xphy pointer directly to the fix_mac_speed
> API as suggested by the Florian.
> --> Added checks for the phy-node fail case as suggested
> by the Florian.
>=20
>  drivers/net/ethernet/xilinx/Kconfig             |  8 +++
>  drivers/net/ethernet/xilinx/Makefile            |  1 +
>  drivers/net/ethernet/xilinx/xilinx_gmii2rgmii.c | 79 +++++++++++++++=
++++++++++
>  include/linux/xilinx_gmii2rgmii.h               | 24 ++++++++
>  4 files changed, 112 insertions(+)
>  create mode 100644 drivers/net/ethernet/xilinx/xilinx_gmii2rgmii.c
>  create mode 100644 include/linux/xilinx_gmii2rgmii.h
>=20
> diff --git a/drivers/net/ethernet/xilinx/Kconfig b/drivers/net/ethern=
et/xilinx/Kconfig
> index 4f5c024..4b65174 100644
> --- a/drivers/net/ethernet/xilinx/Kconfig
> +++ b/drivers/net/ethernet/xilinx/Kconfig
> @@ -39,4 +39,12 @@ config XILINX_LL_TEMAC
>  	  This driver supports the Xilinx 10/100/1000 LocalLink TEMAC
>  	  core used in Xilinx Spartan and Virtex FPGAs
> =20
> +config XILINX_GMII2RGMII
> +	tristate "Xilinx GMII2RGMII converter driver"
> +	default y
> +	---help---
> +	  This driver support xilinx GMII to RGMII IP core it provides
> +	  the Reduced Gigabit Media Independent Interface(RGMII) between
> +	  Ethernet physical media devices and the Gigabit Ethernet controll=
er.
> +
>  endif # NET_VENDOR_XILINX
> diff --git a/drivers/net/ethernet/xilinx/Makefile b/drivers/net/ether=
net/xilinx/Makefile
> index 214205e..bca0da0 100644
> --- a/drivers/net/ethernet/xilinx/Makefile
> +++ b/drivers/net/ethernet/xilinx/Makefile
> @@ -7,3 +7,4 @@ obj-$(CONFIG_XILINX_LL_TEMAC) +=3D ll_temac.o
>  obj-$(CONFIG_XILINX_EMACLITE) +=3D xilinx_emaclite.o
>  xilinx_emac-objs :=3D xilinx_axienet_main.o xilinx_axienet_mdio.o
>  obj-$(CONFIG_XILINX_AXI_EMAC) +=3D xilinx_emac.o
> +obj-$(CONFIG_XILINX_GMII2RGMII) +=3D xilinx_gmii2rgmii.o
> diff --git a/drivers/net/ethernet/xilinx/xilinx_gmii2rgmii.c b/driver=
s/net/ethernet/xilinx/xilinx_gmii2rgmii.c
> new file mode 100644
> index 0000000..de3bd89
> --- /dev/null
> +++ b/drivers/net/ethernet/xilinx/xilinx_gmii2rgmii.c
> @@ -0,0 +1,79 @@
> +/* Xilinx GMII2RGMII Converter driver
> + *
> + * Copyright (C) 2016 Xilinx, Inc.
> + *
> + * Author: Kedareswara rao Appana <appanad@xilinx.com>
> + *
> + * Description:
> + * This driver is developed for Xilinx GMII2RGMII Converter
> + *
> + * This program is free software: you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License as published=
 by
> + * the Free Software Foundation, either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/netdevice.h>
> +#include <linux/mii.h>
> +#include <linux/of_platform.h>
> +#include <linux/of_address.h>
> +#include <linux/of_mdio.h>
> +#include <linux/xilinx_gmii2rgmii.h>
> +
> +static void xgmii2rgmii_fix_mac_speed(struct gmii2rgmii *xphy,
> +				      unsigned int speed)
> +{
> +	struct phy_device *gmii2rgmii_phydev =3D xphy->gmii2rgmii_phy_dev;
> +	u16 gmii2rgmii_reg =3D 0;
> +
> +	switch (speed) {
> +	case 1000:
> +		gmii2rgmii_reg |=3D XILINX_GMII2RGMII_SPEED1000;
> +		break;
> +	case 100:
> +		gmii2rgmii_reg |=3D XILINX_GMII2RGMII_SPEED100;
> +		break;
> +	default:
> +		return;
> +	}
> +
> +	xphy->mdio_write(xphy->mii_bus, gmii2rgmii_phydev->mdio.addr,
> +			 XILINX_GMII2RGMII_REG_NUM,
> +			 gmii2rgmii_reg);
> +}
> +
> +int gmii2rgmii_phyprobe(struct gmii2rgmii *xphy)
> +{
> +	struct device_node *phy_node;
> +	struct phy_device *phydev;
> +	struct device_node *np =3D (struct device_node *)xphy->platform_dat=
a;
> +
> +	phy_node =3D of_parse_phandle(np, "gmii2rgmii-phy-handle", 0);
> +	if (phy_node) {
> +		phydev =3D of_phy_attach(xphy->dev, phy_node, 0, 0);
> +		if (!phydev) {
> +			netdev_err(xphy->dev,
> +				   "%s: no gmii to rgmii converter found\n",
> +				   xphy->dev->name);
> +			return -1;
> +		}
> +		xphy->gmii2rgmii_phy_dev =3D phydev;
> +		xphy->fix_mac_speed =3D xgmii2rgmii_fix_mac_speed;
> +	} else {
> +		xphy->gmii2rgmii_phy_dev =3D 0;
> +		xphy->fix_mac_speed =3D 0;
> +	}
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(gmii2rgmii_phyprobe);
> +
> +MODULE_DESCRIPTION("Xilinx GMII2RGMII converter driver");
> +MODULE_LICENSE("GPL");
> diff --git a/include/linux/xilinx_gmii2rgmii.h b/include/linux/xilinx=
_gmii2rgmii.h
> new file mode 100644
> index 0000000..b328ee7
> --- /dev/null
> +++ b/include/linux/xilinx_gmii2rgmii.h
> @@ -0,0 +1,24 @@


Here, header of the file seems needed.

> +#ifndef _GMII2RGMII_H
> +#define _GMII2RGMII_H
> +
> +#include <linux/of.h>
> +#include <linux/phy.h>
> +#include <linux/mii.h>
> +
> +#define XILINX_GMII2RGMII_FULLDPLX		BMCR_FULLDPLX
> +#define XILINX_GMII2RGMII_SPEED1000		BMCR_SPEED1000
> +#define XILINX_GMII2RGMII_SPEED100		BMCR_SPEED100
> +#define XILINX_GMII2RGMII_REG_NUM			0x10
> +
> +struct gmii2rgmii {
> +	struct net_device	*dev;
> +	struct mii_bus		*mii_bus;
> +	struct phy_device	*gmii2rgmii_phy_dev;
> +	void			*platform_data;
> +	int (*mdio_write)(struct mii_bus *bus, int mii_id, int reg,
> +			  u16 val);
> +	void (*fix_mac_speed)(struct gmii2rgmii *xphy, unsigned int speed);
> +};
> +
> +extern int gmii2rgmii_phyprobe(struct gmii2rgmii *xphy);
> +#endif

I see a compilation issue here:

You should provide a way to have this function even if the
NET_VENDOR_XILINX config option is not selected (test to compile with
the sama5_defconfig and you'll see).

What about making this function void in case of !XILINX?

(so, NACK for the series as it is).
Bye,
--=20
Nicolas Ferre
