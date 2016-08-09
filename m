From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH v5 3/3] net: phy: Add gmiitorgmii converter support
Date: Tue, 9 Aug 2016 14:29:10 -0700
Message-ID: <8919e4fe-69c5-9b16-cc37-e423b757609c@gmail.com>
References: <1470735283-23611-1-git-send-email-appanad@xilinx.com>
 <1470735283-23611-4-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kedareswara rao Appana <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470735283-23611-4-git-send-email-appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/09/2016 02:34 AM, Kedareswara rao Appana wrote:
> This patch adds support for gmiitorgmii converter.
> 
> The GMII to RGMII IP core provides the Reduced Gigabit Media
> Independent Interface (RGMII) between Ethernet physical media
> Devices and the Gigabit Ethernet controller. This core can
> Switch dynamically between the three different speed modes of
> Operation by configuring the converter register through mdio write.
> 
> MDIO interface is used to set operating speed of Ethernet MAC.
> 
> This converter sits between the MAC and the external phy
> MAC <==> GMII2RGMII <==> RGMII_PHY

This looks good, just a few things, see below:

> 
> Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> ---
> Thanks a lot Andrew for your inputs.
> Changes for v5:
> --> Fixed return values in the probe as suggested by punnaiah.
> --> Added a mask for the converter speed as suggested by punnaiah.
> Changes for v4:
> --> Updated phydev speed for all 3 speeds as suggested by zhuyj.
> Changes for v3:
> --> Updated the driver as suggested by Andrew.
> Changes for v2:
> --> Passed struct xphy pointer directly to the fix_mac_speed
> API as suggested by the Florian.
> --> Added checks for the phy-node fail case as suggested
> by the Florian
> 
>  drivers/net/phy/Kconfig             |   8 +++
>  drivers/net/phy/Makefile            |   1 +
>  drivers/net/phy/xilinx_gmii2rgmii.c | 121 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 130 insertions(+)
>  create mode 100644 drivers/net/phy/xilinx_gmii2rgmii.c
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 1b534ea..c79f347 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -312,6 +312,14 @@ config MICROSEMI_PHY
>      ---help---
>        Currently supports the VSC8531 and VSC8541 PHYs
>  
> +config XILINX_GMII2RGMII
> +       tristate "Xilinx GMII2RGMII converter driver"
> +       default y

Don't force that, or at least make the default based on the potential
users/drivers here.

> +       ---help---
> +         This driver support xilinx GMII to RGMII IP core it provides
> +         the Reduced Gigabit Media Independent Interface(RGMII) between
> +         Ethernet physical media devices and the Gigabit Ethernet controller.
> +
>  endif # PHYLIB
>  
>  config MICREL_KS8995MA
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index a713bd4..73d65ce 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -50,3 +50,4 @@ obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
>  obj-$(CONFIG_INTEL_XWAY_PHY)	+= intel-xway.o
>  obj-$(CONFIG_MDIO_HISI_FEMAC)	+= mdio-hisi-femac.o
>  obj-$(CONFIG_MDIO_XGENE)	+= mdio-xgene.o
> +obj-$(CONFIG_XILINX_GMII2RGMII) += xilinx_gmii2rgmii.o
> diff --git a/drivers/net/phy/xilinx_gmii2rgmii.c b/drivers/net/phy/xilinx_gmii2rgmii.c
> new file mode 100644
> index 0000000..1456e27
> --- /dev/null
> +++ b/drivers/net/phy/xilinx_gmii2rgmii.c
> @@ -0,0 +1,121 @@
> +/* Xilinx GMII2RGMII Converter driver
> + *
> + * Copyright (C) 2016 Xilinx, Inc.
> + *
> + * Author: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> + *
> + * Description:
> + * This driver is developed for Xilinx GMII2RGMII Converter
> + *
> + * This program is free software: you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
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
> +#include <linux/mii.h>
> +#include <linux/mdio.h>
> +#include <linux/phy.h>
> +#include <linux/of_mdio.h>
> +
> +#define XILINX_GMII2RGMII_REG		0x10
> +#define XILINX_GMII2RGMII_SPEED_MASK	0x2040

BMCR_SPEED1000 | BMCR_SPEED100 would be clearer here.

> +
> +struct gmii2rgmii {
> +	struct phy_device *phy_dev;
> +	struct phy_driver *phy_drv;
> +	struct phy_driver conv_phy_drv;
> +	int addr;
> +};
> +
> +static int xgmiitorgmii_read_status(struct phy_device *phydev)
> +{
> +	struct gmii2rgmii *priv = (struct gmii2rgmii *)phydev->priv;

Casting is not required here, priv is void *.

> +	u16 val = 0;
> +
> +	priv->phy_drv->read_status(phydev);
> +
> +	val = mdiobus_read(phydev->mdio.bus, priv->addr, XILINX_GMII2RGMII_REG);
> +	val &= XILINX_GMII2RGMII_SPEED_MASK;
> +
> +	switch (phydev->speed) {
> +	case SPEED_1000:
> +		val |= BMCR_SPEED1000;

Is the fall through really intentional here? See genphy_setup_forced()
for instance.

> +	case SPEED_100:
> +		val |= BMCR_SPEED100;
> +	case SPEED_10:
> +		val |= BMCR_SPEED10;
> +	}
> +
> +	mdiobus_write(phydev->mdio.bus, priv->addr, XILINX_GMII2RGMII_REG, val);
> +
> +	return 0;
> +}
[snip]

> +static int __init xgmiitorgmii_init(void)
> +{
> +	return mdio_driver_register(&xgmiitorgmii_driver);
> +}
> +module_init(xgmiitorgmii_init);
> +
> +static void __exit xgmiitorgmii_cleanup(void)
> +{
> +	mdio_driver_unregister(&xgmiitorgmii_driver);
> +}
> +module_exit(xgmiitorgmii_cleanup);

mdio_module_driver() does eliminate a bit of this boilerplate code.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
