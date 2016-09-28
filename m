From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: phy: Add Wake-on-LAN driver for
 Microsemi PHYs.
Date: Wed, 28 Sep 2016 10:37:07 -0700
Message-ID: <74356bf4-9567-f948-65c1-54fad381423d@gmail.com>
References: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1475064078-22310-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Allan.Nielsen@microsemi.com, andrew@lunn.ch
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34171 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932777AbcI1RhJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 13:37:09 -0400
Received: by mail-pf0-f195.google.com with SMTP id 21so2419338pfy.1
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 10:37:09 -0700 (PDT)
In-Reply-To: <1475064078-22310-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2016 05:01 AM, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Wake-on-LAN (WoL) is an Ethernet networking standard that allows
> a computer/device to be turned on or awakened by a network message.
> VSC8531 PHY can support this feature configure by driver set function.
> WoL status get by driver get function.
> 
> Tested on Beaglebone Black with VSC 8531 PHY.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> ---
>  drivers/net/phy/mscc.c | 132 +++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 132 insertions(+)
> 
> diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
> index d350deb..ca6ea23 100644
> --- a/drivers/net/phy/mscc.c
> +++ b/drivers/net/phy/mscc.c
> @@ -11,6 +11,7 @@
>  #include <linux/mdio.h>
>  #include <linux/mii.h>
>  #include <linux/phy.h>
> +#include <linux/netdevice.h>
>  
>  enum rgmii_rx_clock_delay {
>  	RGMII_RX_CLK_DELAY_0_2_NS = 0,
> @@ -35,6 +36,7 @@ enum rgmii_rx_clock_delay {
>  
>  #define MII_VSC85XX_INT_MASK		  25
>  #define MII_VSC85XX_INT_MASK_MASK	  0xa000
> +#define MII_VSC85XX_INT_MASK_WOL	  0x0040
>  #define MII_VSC85XX_INT_STATUS		  26
>  
>  #define MSCC_EXT_PAGE_ACCESS		  31
> @@ -46,6 +48,19 @@ enum rgmii_rx_clock_delay {
>  #define RGMII_RX_CLK_DELAY_MASK		  0x0070
>  #define RGMII_RX_CLK_DELAY_POS		  4
>  
> +#define MSCC_PHY_WOL_LOWER_MAC_ADDR	  21
> +#define MSCC_PHY_WOL_MID_MAC_ADDR	  22
> +#define MSCC_PHY_WOL_UPPER_MAC_ADDR	  23
> +#define MSCC_PHY_WOL_LOWER_PASSWD	  24
> +#define MSCC_PHY_WOL_MID_PASSWD		  25
> +#define MSCC_PHY_WOL_UPPER_PASSWD	  26
> +
> +#define MSCC_PHY_WOL_MAC_CONTROL	  27
> +#define EDGE_RATE_CNTL_POS		  5
> +#define EDGE_RATE_CNTL_MASK		  0x00E0
> +#define SECURE_ON_ENABLE		  0x8000
> +#define SECURE_ON_PASSWD_LEN_4		  0x4000
> +
>  /* Microsemi PHY ID's */
>  #define PHY_ID_VSC8531			  0x00070570
>  #define PHY_ID_VSC8541			  0x00070770
> @@ -58,6 +73,119 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
>  	return rc;
>  }
>  
> +static int vsc85xx_wol_set(struct phy_device *phydev,
> +			   struct ethtool_wolinfo *wol)
> +{
> +	int rc;
> +	u16 reg_val;
> +	struct ethtool_wolinfo *wol_conf = wol;
> +
> +	mutex_lock(&phydev->lock);

This mutex is used here because you are using an indirect page access,
right? This is not to protect against multiple calls of wol_set from
different executing threads?

> +	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
> +	if (rc != 0)
> +		goto out_unlock;
> +
> +	if (wol->wolopts & WAKE_MAGIC) {
> +		/* Store the device address for the magic packet */
> +		reg_val = phydev->attached_dev->dev_addr[4] << 8;
> +		reg_val |= phydev->attached_dev->dev_addr[5];
> +		phy_write(phydev, MSCC_PHY_WOL_LOWER_MAC_ADDR, reg_val);
> +		reg_val = phydev->attached_dev->dev_addr[2] << 8;
> +		reg_val |= phydev->attached_dev->dev_addr[3];
> +		phy_write(phydev, MSCC_PHY_WOL_MID_MAC_ADDR, reg_val);
> +		reg_val = phydev->attached_dev->dev_addr[0] << 8;
> +		reg_val |= phydev->attached_dev->dev_addr[1];
> +		phy_write(phydev, MSCC_PHY_WOL_UPPER_MAC_ADDR, reg_val);
> +	} else {
> +		phy_write(phydev, MSCC_PHY_WOL_LOWER_MAC_ADDR, 0);
> +		phy_write(phydev, MSCC_PHY_WOL_MID_MAC_ADDR, 0);
> +		phy_write(phydev, MSCC_PHY_WOL_UPPER_MAC_ADDR, 0);
> +	}
> +
> +	reg_val = phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
> +	if (wol_conf->wolopts & WAKE_MAGICSECURE)
> +		reg_val |= SECURE_ON_ENABLE;
> +	else
> +		reg_val &= ~SECURE_ON_ENABLE;
> +	phy_write(phydev, MSCC_PHY_WOL_MAC_CONTROL, reg_val);
> +
> +	if (wol_conf->wolopts & WAKE_MAGICSECURE) {
> +		reg_val = wol_conf->sopass[4] << 8;
> +		reg_val |= wol_conf->sopass[5];
> +		phy_write(phydev, MSCC_PHY_WOL_LOWER_PASSWD, reg_val);
> +		reg_val = wol_conf->sopass[2] << 8;
> +		reg_val |= wol_conf->sopass[3];
> +		phy_write(phydev, MSCC_PHY_WOL_MID_PASSWD, reg_val);
> +		reg_val = wol_conf->sopass[0] << 8;
> +		reg_val |= wol_conf->sopass[1];
> +		phy_write(phydev, MSCC_PHY_WOL_UPPER_PASSWD, reg_val);
> +	} else {
> +		phy_write(phydev, MSCC_PHY_WOL_LOWER_PASSWD, 0);
> +		phy_write(phydev, MSCC_PHY_WOL_MID_PASSWD, 0);
> +		phy_write(phydev, MSCC_PHY_WOL_UPPER_PASSWD, 0);
> +	}

How about making the code a little simpler in both cases with something
like this the following:

	u16 pwd = { };
	unsigned int i;

	if (wol_conf->wolopts & WAKE_MAGICECURE)
		for (i = 0; i < ARRAY_SIZE(pwd); i++)
			pwd[i] = wol_conf->so_pass[5 - (i * 2 + 1)] << 8|
				 wol_conf->so_pass[5 - i * 2 ]

	phy_write(phydev, MSCC_PHY_WOL_LOWER_PASSWD, pwd[0]);
	phy_write(phydev, MSCC_PHY_WOL_MID_PASSWD, pwd[1]);
	phy_write(phydev, MSCC_PHY_WOL_UPPER_PASSWD, pwd[2]);

> +
> +	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
> +	if (rc != 0)
> +		goto out_unlock;
> +
> +	if (wol->wolopts & WAKE_MAGIC) {

Don't you also need to check WAKE_MAGICSECURE here as well? Or is the
interrupt going to be generated only if there is no password defined?

> +		/* Enable the WOL interrupt */
> +		reg_val = phy_read(phydev, MII_VSC85XX_INT_MASK);
> +		reg_val |= MII_VSC85XX_INT_MASK_WOL;
> +		rc = phy_write(phydev, MII_VSC85XX_INT_MASK, reg_val);
> +		if (rc != 0)
> +			goto out_unlock;
> +	} else {
> +		/* Disable the WOL interrupt */
> +		reg_val = phy_read(phydev, MII_VSC85XX_INT_MASK);
> +		reg_val &= (~MII_VSC85XX_INT_MASK_WOL);
> +		rc = phy_write(phydev, MII_VSC85XX_INT_MASK, reg_val);
> +		if (rc != 0)
> +			goto out_unlock;
> +	}
> +	/* Clear WOL iterrupt status */
> +	reg_val = phy_read(phydev, MII_VSC85XX_INT_STATUS);
> +
> +out_unlock:
> +	mutex_unlock(&phydev->lock);
> +
> +	return rc;
> +}
> +
> +static void vsc85xx_wol_get(struct phy_device *phydev,
> +			    struct ethtool_wolinfo *wol)
> +{
> +	int rc;
> +	u16 reg_val;
> +	struct ethtool_wolinfo *wol_conf = wol;
> +
> +	mutex_lock(&phydev->lock);
> +	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
> +	if (rc != 0)
> +		goto out_unlock;
> +
> +	reg_val = phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
> +	if (reg_val & SECURE_ON_ENABLE)
> +		wol_conf->wolopts |= WAKE_MAGICSECURE;
> +	if (wol_conf->wolopts & WAKE_MAGICSECURE) {
> +		reg_val = phy_read(phydev, MSCC_PHY_WOL_LOWER_PASSWD);
> +		wol_conf->sopass[5] = reg_val & 0x00ff;
> +		wol_conf->sopass[4] = (reg_val & 0xff00) >> 8;
> +		reg_val = phy_read(phydev, MSCC_PHY_WOL_MID_PASSWD);
> +		wol_conf->sopass[3] = reg_val & 0x00ff;
> +		wol_conf->sopass[2] = (reg_val & 0xff00) >> 8;
> +		reg_val = phy_read(phydev, MSCC_PHY_WOL_UPPER_PASSWD);
> +		wol_conf->sopass[1] = reg_val & 0x00ff;
> +		wol_conf->sopass[0] = (reg_val & 0xff00) >> 8;
> +	}
> +
> +	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
> +
> +out_unlock:
> +	mutex_unlock(&phydev->lock);
> +}
> +
>  static int vsc85xx_mac_if_set(struct phy_device *phydev,
>  			      phy_interface_t interface)
>  {
> @@ -177,6 +305,8 @@ static struct phy_driver vsc85xx_driver[] = {
>  	.config_intr    = &vsc85xx_config_intr,
>  	.suspend	= &genphy_suspend,
>  	.resume		= &genphy_resume,
> +	.set_wol        = &vsc85xx_wol_set,
> +	.get_wol        = &vsc85xx_wol_get,
>  },
>  {
>  	.phy_id		= PHY_ID_VSC8541,
> @@ -193,6 +323,8 @@ static struct phy_driver vsc85xx_driver[] = {
>  	.config_intr    = &vsc85xx_config_intr,
>  	.suspend	= &genphy_suspend,
>  	.resume		= &genphy_resume,
> +	.set_wol        = &vsc85xx_wol_set,
> +	.get_wol        = &vsc85xx_wol_get,
>  }
>  
>  };
> 


-- 
Florian
