From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 01/11] net: phy: Add rockchip phy driver support
Date: Fri, 23 Jun 2017 09:18:24 -0700
Message-ID: <52e9b0d3-0db4-cc03-91a6-774d16115f0f@gmail.com>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
 <1498192929-7519-2-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: andrew@lunn.ch, peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Wu <david.wu@rock-chips.com>, davem@davemloft.net,
        heiko@sntech.de, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498192929-7519-2-git-send-email-david.wu@rock-chips.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/22/2017 09:41 PM, David Wu wrote:
> Support internal ephy currently.
> 
> Signed-off-by: David Wu <david.wu@rock-chips.com>
> ---
>  drivers/net/phy/Kconfig    |  4 ++
>  drivers/net/phy/Makefile   |  1 +
>  drivers/net/phy/rockchip.c | 94 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 99 insertions(+)
>  create mode 100644 drivers/net/phy/rockchip.c
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index c360dd6..86010d4 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -350,6 +350,10 @@ config XILINX_GMII2RGMII
>           the Reduced Gigabit Media Independent Interface(RGMII) between
>           Ethernet physical media devices and the Gigabit Ethernet controller.
>  
> +config ROCKCHIP_MAC_PHY
> +	tristate "Drivers for ROCKCHIP MAC PHY"
> +	---help---
> +	  Currently supports the mac internal ephy.
>  endif # PHYLIB
>  
>  config MICREL_KS8995MA
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index e36db9a..6d96779 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -69,3 +69,4 @@ obj-$(CONFIG_STE10XP)		+= ste10Xp.o
>  obj-$(CONFIG_TERANETICS_PHY)	+= teranetics.o
>  obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
>  obj-$(CONFIG_XILINX_GMII2RGMII) += xilinx_gmii2rgmii.o
> +obj-$(CONFIG_ROCKCHIP_MAC_PHY)	+= rockchip.o
> diff --git a/drivers/net/phy/rockchip.c b/drivers/net/phy/rockchip.c
> new file mode 100644
> index 0000000..69e96ec
> --- /dev/null
> +++ b/drivers/net/phy/rockchip.c
> @@ -0,0 +1,94 @@
> +/**
> + * Rockchip mac phy driver

MAC and PHY, capitalized.

> + *
> + * Copyright (c) 2017, Fuzhou Rockchip Electronics Co., Ltd
> + *
> + * David Wu<david.wu@rock-chips.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + */
> +
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/mii.h>
> +#include <linux/ethtool.h>
> +#include <linux/phy.h>
> +#include <linux/netdevice.h>
> +
> +static int internal_config_init(struct phy_device *phydev)
> +{
> +	int val;
> +	u32 features;
> +
> +	/*enable auto mdix*/
> +	phy_write(phydev, 0x11, 0x0080);

That is probably the only meaningful change needed by this driver, and
even that is not quite correct because auto MDI-X can be changed from
user-space through ethtool, see
drivers/net/phy/marvell.c::marvell_config_aneg()

> +
> +	features = (SUPPORTED_TP | SUPPORTED_MII
> +			| SUPPORTED_AUI | SUPPORTED_FIBRE |
> +			SUPPORTED_BNC);

This is not necessary, using driver::features set to PHY_GBIT_FEATURES

> +
> +	/* Do we support autonegotiation? */
> +	val = phy_read(phydev, MII_BMSR);
> +	if (val < 0)
> +		return val;
> +
> +	if (val & BMSR_ANEGCAPABLE)
> +		features |= SUPPORTED_Autoneg;

If we have disabled auto-negotiation prior to probing this driver, and
somehow the PHY is not reset, then you are falsely not advertising
support for auto-negotiation just because it *currently is* disabled.

> +
> +	if (val & BMSR_100FULL)
> +		features |= SUPPORTED_100baseT_Full;
> +	if (val & BMSR_100HALF)
> +		features |= SUPPORTED_100baseT_Half;
> +	if (val & BMSR_10FULL)
> +		features |= SUPPORTED_10baseT_Full;
> +	if (val & BMSR_10HALF)
> +		features |= SUPPORTED_10baseT_Half;
> +
> +	if (val & BMSR_ESTATEN) {
> +		val = phy_read(phydev, MII_ESTATUS);
> +		if (val < 0)
> +			return val;
> +
> +		if (val & ESTATUS_1000_TFULL)
> +			features |= SUPPORTED_1000baseT_Full;
> +		if (val & ESTATUS_1000_THALF)
> +			features |= SUPPORTED_1000baseT_Half;
> +	}
> +
> +	phydev->supported = features;
> +	phydev->advertising = features;
> +
> +	return 0;
> +}
> +
> +static struct phy_driver rockchip_phy_driver[] = {
> +{
> +	.phy_id 	= 0x1234d400,
> +	.phy_id_mask	= 0xffffffff,

Last 4 digits are supposed to hold the revision, do you really need to
have such a strict mask here?

> +	.name		= "rockchip internal ephy",
> +	.features	= 0,

features shoul dbe set to what you support: PHY_GBIT_FEAUTERS

> +	.config_init	= internal_config_init,
> +	.config_aneg	= genphy_config_aneg,
> +	.read_status	= genphy_read_status,
> +	.suspend	= genphy_suspend,
> +	.resume 	= genphy_resume,
> +},
> +};
> +
> +module_phy_driver(rockchip_phy_driver);
> +
> +static struct mdio_device_id __maybe_unused rockchip_phy_tbl[] = {
> +	{ 0x1234d400, 0xffffffff },
> +	{ }
> +};
> +
> +MODULE_DEVICE_TABLE(mdio, rockchip_phy_tbl);
> +
> +MODULE_AUTHOR("David Wu<david.wu@rock-chips.com>");
> +MODULE_DESCRIPTION("Rockchip mac phy driver");
> +MODULE_LICENSE("GPL v2");
> 


-- 
Florian
