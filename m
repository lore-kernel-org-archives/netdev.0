From: Dan Murphy <dmurphy@ti.com>
Subject: Re: [PATCH] net: phy: DP83822 initial driver submission
Date: Tue, 3 Oct 2017 11:11:51 -0500
Message-ID: <4405649c-7e0a-3bfb-0c17-b8b799574757@ti.com>
References: <20171003155316.12312-1-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:16183 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751538AbdJCQMF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 12:12:05 -0400
In-Reply-To: <20171003155316.12312-1-dmurphy@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All

On 10/03/2017 10:53 AM, Dan Murphy wrote:
> Add support for the TI  DP83822 10/100Mbit ethernet phy.
> 
> The DP83822 provides flexibility to connect to a MAC through a
> standard MII, RMII or RGMII interface.
> 

I need to submit an additional patch to remove DP83822 from the DP83848.
The main difference in the driver is that this driver supports WoL and the DP83848
does not.

So please kindly review this code and I can submit v2 with the DP83848 change

Dan

> Datasheet:
> http://www.ti.com/product/DP83822I/datasheet
> 
> Signed-off-by: Dan Murphy <dmurphy@ti.com>
> ---
>  drivers/net/phy/Kconfig   |   5 +
>  drivers/net/phy/Makefile  |   1 +
>  drivers/net/phy/dp83822.c | 313 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 319 insertions(+)
>  create mode 100644 drivers/net/phy/dp83822.c
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index cd931cf..8e78a48 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -277,6 +277,11 @@ config DAVICOM_PHY
>  	---help---
>  	  Currently supports dm9161e and dm9131
>  
> +config DP83822_PHY
> +	tristate "Texas Instruments DP83822 PHY"
> +	---help---
> +	  Supports the DP83822 PHY.
> +
>  config DP83848_PHY
>  	tristate "Texas Instruments DP83848 PHY"
>  	---help---
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index 416df92..df3b82b 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -55,6 +55,7 @@ obj-$(CONFIG_CICADA_PHY)	+= cicada.o
>  obj-$(CONFIG_CORTINA_PHY)	+= cortina.o
>  obj-$(CONFIG_DAVICOM_PHY)	+= davicom.o
>  obj-$(CONFIG_DP83640_PHY)	+= dp83640.o
> +obj-$(CONFIG_DP83822_PHY)	+= dp83822.o
>  obj-$(CONFIG_DP83848_PHY)	+= dp83848.o
>  obj-$(CONFIG_DP83867_PHY)	+= dp83867.o
>  obj-$(CONFIG_FIXED_PHY)		+= fixed_phy.o
> diff --git a/drivers/net/phy/dp83822.c b/drivers/net/phy/dp83822.c
> new file mode 100644
> index 0000000..1d77515
> --- /dev/null
> +++ b/drivers/net/phy/dp83822.c
> @@ -0,0 +1,313 @@
> +/*
> + * Driver for the Texas Instruments DP83822 PHY
> + *
> + * Copyright (C) 2017 Texas Instruments Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/ethtool.h>
> +#include <linux/etherdevice.h>
> +#include <linux/kernel.h>
> +#include <linux/mii.h>
> +#include <linux/module.h>
> +#include <linux/of.h>
> +#include <linux/phy.h>
> +#include <linux/netdevice.h>
> +
> +#define DP83822_PHY_ID	        0x2000a240
> +#define DP83822_DEVADDR		0x1f
> +
> +#define MII_DP83822_MISR1	0x12
> +#define MII_DP83822_MISR2	0x13
> +#define MII_DP83822_RESET_CTRL	0x1f
> +
> +#define DP83822_HW_RESET	BIT(15)
> +#define DP83822_SW_RESET	BIT(14)
> +
> +/* MISR1 bits */
> +#define DP83822_RX_ERR_HF_INT_EN	BIT(0)
> +#define DP83822_FALSE_CARRIER_HF_INT_EN	BIT(1)
> +#define DP83822_ANEG_COMPLETE_INT_EN	BIT(2)
> +#define DP83822_DUP_MODE_CHANGE_INT_EN	BIT(3)
> +#define DP83822_SPEED_CHANGED_INT_EN	BIT(4)
> +#define DP83822_LINK_STAT_INT_EN	BIT(5)
> +#define DP83822_ENERGY_DET_INT_EN	BIT(6)
> +#define DP83822_LINK_QUAL_INT_EN	BIT(7)
> +
> +/* MISR2 bits */
> +#define DP83822_JABBER_DET_INT_EN	BIT(0)
> +#define DP83822_WOL_PKT_INT_EN		BIT(1)
> +#define DP83822_SLEEP_MODE_INT_EN	BIT(2)
> +#define DP83822_MDI_XOVER_INT_EN	BIT(3)
> +#define DP83822_LB_FIFO_INT_EN		BIT(4)
> +#define DP83822_PAGE_RX_INT_EN		BIT(5)
> +#define DP83822_ANEG_ERR_INT_EN		BIT(6)
> +#define DP83822_EEE_ERROR_CHANGE_INT_EN	BIT(7)
> +
> +/* INT_STAT1 bits */
> +#define DP83822_WOL_INT_EN	BIT(4)
> +#define DP83822_WOL_INT_STAT	BIT(12)
> +
> +#define MII_DP83822_RXSOP1	0x04A5
> +#define	MII_DP83822_RXSOP2	0x04A6
> +#define	MII_DP83822_RXSOP3	0x04A7
> +
> +/* WoL Registers */
> +#define	MII_DP83822_WOL_CFG	0x04A0
> +#define	MII_DP83822_WOL_STAT	0x04A1
> +#define	MII_DP83822_WOL_DA1	0x04A2
> +#define	MII_DP83822_WOL_DA2	0x04A3
> +#define	MII_DP83822_WOL_DA3	0x04A4
> +
> +/* WoL bits */
> +#define DP83822_WOL_MAGIC_EN	BIT(1)
> +#define DP83822_WOL_SECURE_ON	BIT(5)
> +#define DP83822_WOL_EN		BIT(7)
> +#define DP83822_WOL_INDICATION_SEL BIT(8)
> +#define DP83822_WOL_CLR_INDICATION BIT(11)
> +
> +static int dp83822_ack_interrupt(struct phy_device *phydev)
> +{
> +	int err = phy_read(phydev, MII_DP83822_MISR1);
> +
> +	if (err < 0)
> +		return err;
> +
> +	err = phy_read(phydev, MII_DP83822_MISR2);
> +	if (err < 0)
> +		return err;
> +
> +	return 0;
> +}
> +
> +static int dp83822_set_wol(struct phy_device *phydev,
> +			   struct ethtool_wolinfo *wol)
> +{
> +	struct net_device *ndev = phydev->attached_dev;
> +	u16 value;
> +	const u8 *mac;
> +
> +	if (wol->wolopts & (WAKE_MAGIC | WAKE_MAGICSECURE)) {
> +		mac = (const u8 *)ndev->dev_addr;
> +
> +		if (!is_valid_ether_addr(mac))
> +			return -EFAULT;
> +
> +		/* MAC addresses start with byte 5, but stored in mac[0].
> +		 * 822 PHYs store bytes 4|5, 2|3, 0|1
> +		 */
> +		phy_write_mmd(phydev, DP83822_DEVADDR,
> +			      MII_DP83822_WOL_DA1, (mac[1] << 8) | mac[0]);
> +		phy_write_mmd(phydev, DP83822_DEVADDR,
> +			      MII_DP83822_WOL_DA2, (mac[3] << 8) | mac[2]);
> +		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_DA3,
> +			      (mac[5] << 8) | mac[4]);
> +
> +		value = phy_read_mmd(phydev, DP83822_DEVADDR,
> +				     MII_DP83822_WOL_CFG);
> +		if (wol->wolopts & WAKE_MAGIC)
> +			value |= DP83822_WOL_MAGIC_EN;
> +		else
> +			value &= ~DP83822_WOL_MAGIC_EN;
> +
> +		if (wol->wolopts & WAKE_MAGICSECURE) {
> +			value |= DP83822_WOL_SECURE_ON;
> +			phy_write_mmd(phydev, DP83822_DEVADDR,
> +				      MII_DP83822_RXSOP1,
> +				      (wol->sopass[1] << 8) | wol->sopass[0]);
> +			phy_write_mmd(phydev, DP83822_DEVADDR,
> +				      MII_DP83822_RXSOP2,
> +				      (wol->sopass[3] << 8) | wol->sopass[2]);
> +			phy_write_mmd(phydev, DP83822_DEVADDR,
> +				      MII_DP83822_RXSOP3,
> +				      (wol->sopass[5] << 8) | wol->sopass[4]);
> +		} else {
> +			value &= ~DP83822_WOL_SECURE_ON;
> +		}
> +
> +		value |= (DP83822_WOL_EN | DP83822_WOL_CLR_INDICATION |
> +			  DP83822_WOL_CLR_INDICATION);
> +		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
> +			      value);
> +	} else {
> +		value =
> +		    phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
> +		value &= (~DP83822_WOL_EN);
> +		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
> +			      value);
> +	}
> +
> +	return 0;
> +}
> +
> +static void dp83822_get_wol(struct phy_device *phydev,
> +			    struct ethtool_wolinfo *wol)
> +{
> +	int value;
> +
> +	wol->supported = (WAKE_MAGIC | WAKE_MAGICSECURE);
> +	wol->wolopts = 0;
> +
> +	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
> +	if (value & DP83822_WOL_MAGIC_EN)
> +		wol->wolopts |= WAKE_MAGIC;
> +
> +	if (value & DP83822_WOL_SECURE_ON)
> +		wol->wolopts |= WAKE_MAGICSECURE;
> +
> +	if (~value & DP83822_WOL_CLR_INDICATION)
> +		wol->wolopts = 0;
> +
> +	wol->sopass[0] = (phy_read_mmd(phydev,
> +				       DP83822_DEVADDR,
> +				       MII_DP83822_RXSOP1) & 0xFF);
> +	wol->sopass[1] =
> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP1) >> 8);
> +	wol->sopass[2] =
> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP2) & 0xFF);
> +	wol->sopass[3] =
> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP2) >> 8);
> +	wol->sopass[4] =
> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP3) & 0xFF);
> +	wol->sopass[5] =
> +	    (phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_RXSOP3) >> 8);
> +}
> +
> +static int dp83822_config_intr(struct phy_device *phydev)
> +{
> +	int misr_status;
> +	int err;
> +
> +	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
> +		misr_status = phy_read(phydev, MII_DP83822_MISR1);
> +		if (misr_status < 0)
> +			return misr_status;
> +
> +		misr_status |= (DP83822_RX_ERR_HF_INT_EN |
> +				DP83822_FALSE_CARRIER_HF_INT_EN |
> +				DP83822_ANEG_COMPLETE_INT_EN |
> +				DP83822_DUP_MODE_CHANGE_INT_EN |
> +				DP83822_SPEED_CHANGED_INT_EN |
> +				DP83822_LINK_STAT_INT_EN |
> +				DP83822_ENERGY_DET_INT_EN |
> +				DP83822_LINK_QUAL_INT_EN);
> +
> +		err = phy_write(phydev, MII_DP83822_MISR1, misr_status);
> +		if (err < 0)
> +			return err;
> +
> +		misr_status = phy_read(phydev, MII_DP83822_MISR2);
> +		if (misr_status < 0)
> +			return misr_status;
> +
> +		misr_status |= (DP83822_JABBER_DET_INT_EN |
> +				DP83822_WOL_PKT_INT_EN |
> +				DP83822_SLEEP_MODE_INT_EN |
> +				DP83822_MDI_XOVER_INT_EN |
> +				DP83822_LB_FIFO_INT_EN |
> +				DP83822_PAGE_RX_INT_EN |
> +				DP83822_ANEG_ERR_INT_EN |
> +				DP83822_EEE_ERROR_CHANGE_INT_EN);
> +
> +		err = phy_write(phydev, MII_DP83822_MISR2, misr_status);
> +	} else {
> +		err = phy_write(phydev, MII_DP83822_MISR1, 0);
> +		if (err < 0)
> +			return err;
> +
> +		err = phy_write(phydev, MII_DP83822_MISR1, 0);
> +	}
> +
> +	return err;
> +}
> +
> +static int dp83822_phy_reset(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	err = phy_write(phydev, MII_DP83822_RESET_CTRL, DP83822_HW_RESET);
> +	if (err < 0)
> +		return err;
> +
> +	return 0;
> +}
> +
> +static int dp83822_suspend(struct phy_device *phydev)
> +{
> +	int value;
> +
> +	mutex_lock(&phydev->lock);
> +
> +	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
> +	if (~value & DP83822_WOL_EN) {
> +		value = phy_read(phydev, MII_BMCR);
> +		phy_write(phydev, MII_BMCR, value | BMCR_PDOWN);
> +	}
> +
> +	mutex_unlock(&phydev->lock);
> +
> +	return 0;
> +}
> +
> +static int dp83822_resume(struct phy_device *phydev)
> +{
> +	int value;
> +
> +	mutex_lock(&phydev->lock);
> +
> +	value = phy_read(phydev, MII_BMCR);
> +	phy_write(phydev, MII_BMCR, value & ~BMCR_PDOWN);
> +
> +	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
> +
> +	phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG, value |
> +		      DP83822_WOL_CLR_INDICATION);
> +
> +	mutex_unlock(&phydev->lock);
> +
> +	return 0;
> +}
> +
> +static struct phy_driver dp83822_driver[] = {
> +	{
> +	 .phy_id = DP83822_PHY_ID,
> +	 .phy_id_mask = 0xfffffff0,
> +	 .name = "TI DP83822",
> +	 .features = PHY_BASIC_FEATURES,
> +	 .flags = PHY_HAS_INTERRUPT,
> +
> +	 .config_init = genphy_config_init,
> +	 .soft_reset = dp83822_phy_reset,
> +
> +	 .get_wol = dp83822_get_wol,
> +	 .set_wol = dp83822_set_wol,
> +
> +	 /* IRQ related */
> +	 .ack_interrupt = dp83822_ack_interrupt,
> +	 .config_intr = dp83822_config_intr,
> +
> +	 .config_aneg = genphy_config_aneg,
> +	 .read_status = genphy_read_status,
> +	 .suspend = dp83822_suspend,
> +	 .resume = dp83822_resume,
> +	 },
> +};
> +module_phy_driver(dp83822_driver);
> +
> +static struct mdio_device_id __maybe_unused dp83822_tbl[] = {
> +	{ DP83822_PHY_ID, 0xfffffff0 },
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(mdio, dp83822_tbl);
> +
> +MODULE_DESCRIPTION("Texas Instruments DP83822 PHY driver");
> +MODULE_AUTHOR("Dan Murphy <dmurphy@ti.com");
> +MODULE_LICENSE("GPL");
> 


-- 
------------------
Dan Murphy
