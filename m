From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 01/11] net: phy: Add rockchip phy driver support
Date: Thu, 27 Jul 2017 09:51:31 -0700
Message-ID: <807c43ee-8421-c0b3-8aea-6091bef07a4c@gmail.com>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
 <1501160156-30328-2-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Wu <david.wu@rock-chips.com>, davem@davemloft.net,
        heiko@sntech.de, andrew@lunn.ch, robh+dt@kernel.org,
        mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
        olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501160156-30328-2-git-send-email-david.wu@rock-chips.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/27/2017 05:55 AM, David Wu wrote:
> Support internal ephy currently.
> 
> Signed-off-by: David Wu <david.wu@rock-chips.com>
> ---
> changes in v2:
>  - Alphabetic order for Kconfig and Makefile.
>  - Add analog register init.
>  - Disable auto-mdix for workround.
>  - Rename config
> 
>  drivers/net/phy/Kconfig    |   5 ++
>  drivers/net/phy/Makefile   |   1 +
>  drivers/net/phy/rockchip.c | 128 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 134 insertions(+)
>  create mode 100644 drivers/net/phy/rockchip.c
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 2dda720..8dc6cd7 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -334,6 +334,11 @@ config REALTEK_PHY
>  	---help---
>  	  Supports the Realtek 821x PHY.
>  
> +config ROCKCHIP_PHY
> +        tristate "Drivers for ROCKCHIP PHYs"

"Driver for Rockchip Ethernet PHYs" would seem more appropriate, this is
just one driver for now.

> +        ---help---
> +          Currently supports the internal ephy.

EPHY is usually how an Ethernet PHY is abbreviated.

> +
>  config SMSC_PHY
>  	tristate "SMSC PHYs"
>  	---help---
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index 8e9b9f3..350520e 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -66,6 +66,7 @@ obj-$(CONFIG_MICROSEMI_PHY)	+= mscc.o
>  obj-$(CONFIG_NATIONAL_PHY)	+= national.o
>  obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
>  obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
> +obj-$(CONFIG_ROCKCHIP_PHY)	+= rockchip.o
>  obj-$(CONFIG_SMSC_PHY)		+= smsc.o
>  obj-$(CONFIG_STE10XP)		+= ste10Xp.o
>  obj-$(CONFIG_TERANETICS_PHY)	+= teranetics.o
> diff --git a/drivers/net/phy/rockchip.c b/drivers/net/phy/rockchip.c
> new file mode 100644
> index 0000000..3f74658
> --- /dev/null
> +++ b/drivers/net/phy/rockchip.c
> @@ -0,0 +1,128 @@
> +/**
> + * drivers/net/phy/rockchip.c
> + *
> + * Driver for ROCKCHIP PHY
> + *
> + * Copyright (c) 2017, Fuzhou Rockchip Electronics Co., Ltd
> + *
> + * David Wu<david.wu@rock-chips.com>

Missing space between your last name and your email address, there is
another typo like this in the MODULE_AUTHOR() macro.

> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/mii.h>
> +#include <linux/ethtool.h>
> +#include <linux/phy.h>
> +#include <linux/netdevice.h>
> +
> +#define MII_INTERNAL_CTRL_STATUS	17
> +#define SMI_ADDR_TSTCNTL		20
> +#define SMI_ADDR_TSTREAD1		21
> +#define SMI_ADDR_TSTREAD2		22
> +#define SMI_ADDR_TSTWRITE		23
> +
> +#define AUTOMDIX_EN			BIT(7)
> +#define TSTCNTL_RD			(BIT(15) | BIT(10))
> +#define TSTCNTL_WR          		(BIT(14) | BIT(10))
> +
> +#define WR_ADDR_A7CFG			0x18
> +
> +static void rockchip_init_tstmode(struct phy_device *phydev)
> +{
> +	/* Enable access to Analog and DSP register banks */
> +	phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0400);
> +	phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0000);
> +	phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0400);
> +}
> +
> +static void  rockchip_close_tstmode(struct phy_device *phydev)
> +{
> +	/* Back to basic register bank */
> +	phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0000);
> +}
> +
> +static void rockchip_internal_phy_analog_init(struct phy_device *phydev)
> +{
> +	rockchip_init_tstmode(phydev);

Technically MDIO writes can fail, but you are not propagating the return
value, so you could be stuck on a bad page/bank.

> +
> +	/*
> +	 * Adjust tx amplitude to make sginal better,
> +	 * the default value is 0x8.
> +	 */
> +	phy_write(phydev, SMI_ADDR_TSTWRITE, 0xB);
> +	phy_write(phydev, SMI_ADDR_TSTCNTL, TSTCNTL_WR | WR_ADDR_A7CFG);

Likewise.

> +
> +	rockchip_close_tstmode(phydev);

Same here.

> +}
> +
> +static int rockchip_internal_phy_config_init(struct phy_device *phydev)
> +{
> +	int val;
> +
> +	/*
> +	 * The auto MIDX has linked problem on some board,
> +	 * workround to disable auto MDIX.
> +	 */

If this a board-specific problem you may consider register a PHY fixup
for the affected boards, or introduce a specific property to illustrate
that MDI-X is broken.

> +	val = phy_read(phydev, MII_INTERNAL_CTRL_STATUS);
> +	val &= ~AUTOMDIX_EN;
> +	phy_write(phydev, MII_INTERNAL_CTRL_STATUS, val);

You also need to reject MDI configuration requests coming via
phy_ethtool_ksettings_set() which you should see in the
phyddrv::config_ane callback.

> +
> +	rockchip_internal_phy_analog_init(phydev);
> +
> +	return 0;
> +}
> +
> +static int rockchip_internal_phy_read_status(struct phy_device *phydev)
> +{
> +	int ret, old_speed;
> +
> +	old_speed = phydev->speed;
> +	ret = genphy_read_status(phydev);
> +	if (ret)
> +		return ret;
> +
> +	/*
> +	 * If mode switch happens from 10BT to 100BT, all DSP/AFE
> +	 * registers are set to default values. So any AFE/DSP
> +	 * registers have to be re-initialized in this case.
> +	 */
> +	if ((old_speed == SPEED_10) && (phydev->speed == SPEED_100))
> +		rockchip_internal_phy_analog_init(phydev);

link changes can be intercepted with a link_change_notify callback,
which would be more appropriate than doing this during read_status here.

> +
> +	return ret;
> +}
> +
> +static struct phy_driver rockchip_phy_driver[] = {
> +{
> +	.phy_id 	= 0x1234d400,
> +	.phy_id_mask	= 0xffff0000,

This mask is way too wide, the industry practice is to have the last 4
digits contain the PHY revision, so I would expect to see 0xffff_fff0
here as a mask.

> +	.name		= "rockchip internal ephy",

Rockchip internal EPHY?

> +	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
> +			  | SUPPORTED_Asym_Pause),
> +	.soft_reset 	= genphy_soft_reset,

Since this is a driver for an internal PHY you also need:

	.flags		= PHY_IS_INTERNAL

> +	.config_init	= rockchip_internal_phy_config_init,
> +	.config_aneg	= genphy_config_aneg,
> +	.read_status	= rockchip_internal_phy_read_status,
> +	.suspend	= genphy_suspend,
> +	.resume 	= genphy_resume,

You probably need your resume function to restore the AFE/DSP settings
that were done in rockchip_internal_phy_config_init()

> +},
> +};
> +
> +module_phy_driver(rockchip_phy_driver);
> +
> +static struct mdio_device_id __maybe_unused rockchip_phy_tbl[] = {
> +	{ 0x1234d400, 0xffff0000 },

Please also fix up the mask here.

> +	{ }
> +};
> +
> +MODULE_DEVICE_TABLE(mdio, rockchip_phy_tbl);
> +
> +MODULE_AUTHOR("David Wu<david.wu@rock-chips.com>");

Typo here (same as in the heading).

> +MODULE_DESCRIPTION("Rockchip phy driver");

"Rockchip Ethernet PHY driver" so make it clear what type of PHY it manages?

> +MODULE_LICENSE("GPL v2");
> 


-- 
Florian
