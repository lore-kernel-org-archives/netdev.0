From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/1 RFC] net/phy: Add Lantiq PHY driver
Date: Wed, 18 May 2016 09:24:24 -0700
Message-ID: <573C9738.4040402@gmail.com>
References: <1463587403-26809-1-git-send-email-alexander.stein@systec-electronic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch, john@phrozen.org
To: Alexander Stein <alexander.stein@systec-electronic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33640 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbcERQY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 12:24:29 -0400
In-Reply-To: <1463587403-26809-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC'ing Andrew, John,

On 05/18/2016 09:03 AM, Alexander Stein wrote:
> This currently only supports PEF7071 and allows to specify max-speed and
> is able to read the LED configuration from device-tree.
> 
> Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
> ---
> The main purpose for now is to set a LED configuration from device tree and
> to limit the maximum speed. The latter one in my case hardware limited.
> As MAC and it's link partner support 1000MBit/s they would try to use that
> but will eventually fail due to magnetics only supporting 100MBit/s. So
> limit the maximum link speed supported directly from the start.

The 'max-speed' parsing that you do in the driver should not be needed,
PHYLIB takes care of that already see
drivers/net/phy/phy_device.c::of_set_phy_supported

For LEDs, we had a patch series floating around adding LED triggers [1],
and it seems to me like the LEDs class subsystem would be a good fit for
controlling PHY LEDs, possibly with the help of PHYLIB when it comes to
doing the low-level work of registering LEDs and their names with the
LEDS subsystem.

[1]: http://lists.openwall.net/netdev/2016/03/23/61

> 
> As this is a RFC I skipped the device tree binding doc.

Too bad, that's probably what needs to be discussed here, because the
driver looks pretty reasonable otherwise.

> 
>  drivers/net/phy/Kconfig  |   5 ++
>  drivers/net/phy/Makefile |   1 +
>  drivers/net/phy/lantiq.c | 167 +++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 173 insertions(+)
>  create mode 100644 drivers/net/phy/lantiq.c
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 3e28f7a..c004885 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -119,6 +119,11 @@ config STE10XP
>  	---help---
>  	  This is the driver for the STe100p and STe101p PHYs.
>  
> +config LANTIQ_PHY
> +	tristate "Driver for Lantiq PHYs"
> +	---help---
> +	  Supports the PEF7071 PHYs.
> +
>  config LSI_ET1011C_PHY
>  	tristate "Driver for LSI ET1011C PHY"
>  	---help---
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index 8ad4ac6..e886549 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -38,3 +38,4 @@ obj-$(CONFIG_MDIO_SUN4I)	+= mdio-sun4i.o
>  obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
>  obj-$(CONFIG_AMD_XGBE_PHY)	+= amd-xgbe-phy.o
>  obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
> +obj-$(CONFIG_LANTIQ_PHY)	+= lantiq.o
> diff --git a/drivers/net/phy/lantiq.c b/drivers/net/phy/lantiq.c
> new file mode 100644
> index 0000000..876a7d1
> --- /dev/null
> +++ b/drivers/net/phy/lantiq.c
> @@ -0,0 +1,167 @@
> +/*
> + * Driver for Lantiq PHYs
> + *
> + * Author: Alexander Stein <alexander.stein@systec-electronic.com>
> + *
> + * Copyright (c) 2015-2016 SYS TEC electronic GmbH
> + *
> + * This program is free software; you can redistribute  it and/or modify it
> + * under  the terms of  the GNU General  Public License as published by the
> + * Free Software Foundation;  either version 2 of the  License, or (at your
> + * option) any later version.
> + *
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/phy.h>
> +#include <linux/of.h>
> +
> +#define PHY_ID_PEF7071	0xd565a401
> +
> +#define MII_LANTIQ_MMD_CTRL_REG		0x0d
> +#define MII_LANTIQ_MMD_REGDATA_REG	0x0e
> +#define OP_DATA				1
> +
> +struct lantiqphy_led_ctrl {
> +	const char *property;
> +	u32 regnum;
> +};
> +
> +static int lantiq_extended_write(struct phy_device *phydev,
> +				 u8 mode, u32 dev_addr, u32 regnum, u16 val)
> +{
> +	phy_write(phydev, MII_LANTIQ_MMD_CTRL_REG, dev_addr);
> +	phy_write(phydev, MII_LANTIQ_MMD_REGDATA_REG, regnum);
> +	phy_write(phydev, MII_LANTIQ_MMD_CTRL_REG, (mode << 14) | dev_addr);
> +	return phy_write(phydev, MII_LANTIQ_MMD_REGDATA_REG, val);
> +}
> +
> +static int lantiq_of_load_led_config(struct phy_device *phydev,
> +				     struct device_node *of_node,
> +				     const struct lantiqphy_led_ctrl *leds,
> +				     u8 entries)
> +{
> +	u16 val;
> +	int i;
> +	int ret = 0;
> +
> +	for (i = 0; i < entries; i++) {
> +		if (!of_property_read_u16(of_node, leds[i].property, &val)) {
> +			ret = lantiq_extended_write(phydev, OP_DATA, 0x1f,
> +						    leds[i].regnum, val);
> +			if (ret) {
> +				dev_err(&phydev->dev, "Error writing register 0x1f.%04x (%d)\n",
> +					leds[i].regnum, ret);
> +				break;
> +			}
> +		}
> +	}
> +
> +	return ret;
> +}
> +
> +static const struct lantiqphy_led_ctrl leds[] = {
> +	{
> +		.property = "led0h",
> +		.regnum = 0x01e2,
> +	},
> +	{
> +		.property = "led0l",
> +		.regnum = 0x01e3,
> +	},
> +	{
> +		.property = "led1h",
> +		.regnum = 0x01e4,
> +	},
> +	{
> +		.property = "led1l",
> +		.regnum = 0x01e5,
> +	},
> +	{
> +		.property = "led2h",
> +		.regnum = 0x01e6,
> +	},
> +	{
> +		.property = "led2l",
> +		.regnum = 0x01e7,
> +	},
> +};
> +
> +static int lantiqphy_config_init(struct phy_device *phydev)
> +{
> +	struct device *dev = &phydev->dev;
> +	struct device_node *of_node = dev->of_node;
> +	u32 max_speed;
> +
> +	if (!of_node && dev->parent->of_node)
> +		of_node = dev->parent->of_node;
> +
> +	if (of_node) {
> +		lantiq_of_load_led_config(phydev, of_node, leds,
> +					  ARRAY_SIZE(leds));
> +
> +		if (!of_property_read_u32(of_node, "max-speed",
> +					  &max_speed)) {
> +			/* The default values for phydev->supported are
> +			 * provided by the PHY driver "features" member,
> +			 * we want to reset to sane defaults fist before
> +			 * supporting higher speeds.
> +			 */
> +			phydev->supported &= PHY_DEFAULT_FEATURES;
> +
> +			switch (max_speed) {
> +			default:
> +				break;
> +
> +			case SPEED_1000:
> +				phydev->supported |= PHY_1000BT_FEATURES;
> +			case SPEED_100:
> +				phydev->supported |= PHY_100BT_FEATURES;
> +			case SPEED_10:
> +				phydev->supported |= PHY_10BT_FEATURES;
> +			}
> +		}
> +	}
> +	return 0;
> +}
> +
> +static struct phy_driver lantiqphy_driver[] = {
> +{
> +	.phy_id		= PHY_ID_PEF7071,
> +	.phy_id_mask	= 0x00fffffe,
> +	.name		= "Lantiq PEF7071",
> +	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
> +	.flags		= PHY_HAS_MAGICANEG,
> +	.config_init	= lantiqphy_config_init,
> +	.config_aneg	= genphy_config_aneg,
> +	.read_status	= genphy_read_status,
> +	.suspend	= genphy_suspend,
> +	.resume		= genphy_resume,
> +	.driver		= { .owner = THIS_MODULE,},
> +} };
> +
> +static int __init lantiqphy_init(void)
> +{
> +	return phy_drivers_register(lantiqphy_driver,
> +				    ARRAY_SIZE(lantiqphy_driver));
> +}
> +
> +static void __exit lantiqphy_exit(void)
> +{
> +	phy_drivers_unregister(lantiqphy_driver,
> +			       ARRAY_SIZE(lantiqphy_driver));
> +}
> +
> +module_init(lantiqphy_init);
> +module_exit(lantiqphy_exit);
> +
> +MODULE_DESCRIPTION("Lantiq PHY driver");
> +MODULE_AUTHOR("Alexander Stein <alexander.stein@systec-electronic.com>");
> +MODULE_LICENSE("GPL");
> +
> +static struct mdio_device_id __maybe_unused lantiq_tbl[] = {
> +	{ PHY_ID_PEF7071, 0x00fffffe },
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(mdio, lantiq_tbl);
> 


-- 
Florian
