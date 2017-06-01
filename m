From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/5] net: phy: add 802.3 clause 45 support to phylib
Date: Thu, 1 Jun 2017 10:15:28 -0700
Message-ID: <34431c1b-025f-55e5-9f31-34e14493541b@gmail.com>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJH-00043Y-Gl@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33925 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdFARPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 13:15:32 -0400
Received: by mail-qk0-f195.google.com with SMTP id d14so3334961qkb.1
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 10:15:32 -0700 (PDT)
In-Reply-To: <E1dGNJH-00043Y-Gl@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2017 03:26 AM, Russell King wrote:
> Add generic helpers for 802.3 clause 45 PHYs for >= 10Gbps support.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> ---

> +	ctrl1 &= ~MDIO_CTRL1_SPEEDSEL;
> +	/* PMA/PMD type selection is 1.7.5:0 not 1.7.3:0.  See 45.2.1.6.1. */
> +	ctrl2 &= ~(MDIO_PMA_CTRL2_TYPE | 0x30);

You could add a define for this 0x30 to indicate that you are masking
off the reserved bits (there are more entries that are reserved
actually, but that would do for now).

With that:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> +
> +	switch (phydev->speed) {
> +	case SPEED_10:
> +		ctrl2 |= MDIO_PMA_CTRL2_10BT;
> +		break;
> +	case SPEED_100:
> +		ctrl1 |= MDIO_PMA_CTRL1_SPEED100;
> +		ctrl2 |= MDIO_PMA_CTRL2_100BTX;
> +		break;
> +	case SPEED_1000:
> +		ctrl1 |= MDIO_PMA_CTRL1_SPEED1000;
> +		/* Assume 1000base-T */
> +		ctrl2 |= MDIO_PMA_CTRL2_1000BT;
> +		break;
> +	case SPEED_10000:
> +		ctrl1 |= MDIO_CTRL1_SPEED10G;
> +		/* Assume 10Gbase-T */
> +		ctrl2 |= MDIO_PMA_CTRL2_10GBT;
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	ret = phy_write_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_CTRL1, ctrl1);
> +	if (ret < 0)
> +		return ret;
> +
> +	return phy_write_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_CTRL2, ctrl2);
> +}
> +EXPORT_SYMBOL_GPL(genphy_c45_pma_setup_forced);
> +
> +/**
> + * genphy_c45_an_disable_aneg - disable auto-negotiation
> + * @phydev: target phy_device struct
> + *
> + * Disable auto-negotiation in the Clause 45 PHY. The link parameters
> + * parameters are controlled through the PMA/PMD MMD registers.
> + *
> + * Returns zero on success, negative errno code on failure.
> + */
> +int genphy_c45_an_disable_aneg(struct phy_device *phydev)
> +{
> +	int val;
> +
> +	val = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_CTRL1);
> +	if (val < 0)
> +		return val;
> +
> +	val &= ~(MDIO_AN_CTRL1_ENABLE | MDIO_AN_CTRL1_RESTART);
> +
> +	return phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_CTRL1, val);
> +}
> +EXPORT_SYMBOL_GPL(genphy_c45_an_disable_aneg);
> +
> +/**
> + * genphy_c45_restart_aneg - Enable and restart auto-negotiation
> + * @phydev: target phy_device struct
> + *
> + * This assumes that the auto-negotiation MMD is present.
> + *
> + * Enable and restart auto-negotiation.
> + */
> +int genphy_c45_restart_aneg(struct phy_device *phydev)
> +{
> +	int val;
> +
> +	val = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_CTRL1);
> +	if (val < 0)
> +		return val;
> +
> +	val |= MDIO_AN_CTRL1_ENABLE | MDIO_AN_CTRL1_RESTART;
> +
> +	return phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_CTRL1, val);
> +}
> +EXPORT_SYMBOL_GPL(genphy_c45_restart_aneg);
> +
> +/**
> + * genphy_c45_aneg_done - return auto-negotiation complete status
> + * @phydev: target phy_device struct
> + *
> + * This assumes that the auto-negotiation MMD is present.
> + *
> + * Reads the status register from the auto-negotiation MMD, returning:
> + * - positive if auto-negotiation is complete
> + * - negative errno code on error
> + * - zero otherwise
> + */
> +int genphy_c45_aneg_done(struct phy_device *phydev)
> +{
> +	int val = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
> +
> +	return val < 0 ? val : val & MDIO_AN_STAT1_COMPLETE ? 1 : 0;
> +}
> +EXPORT_SYMBOL_GPL(genphy_c45_aneg_done);
> +
> +/**
> + * genphy_c45_read_link - read the overall link status from the MMDs
> + * @phydev: target phy_device struct
> + * @mmd_mask: MMDs to read status from
> + *
> + * Read the link status from the specified MMDs, and if they all indicate
> + * that the link is up, return positive.  If an error is encountered,
> + * a negative errno will be returned, otherwise zero.
> + */
> +int genphy_c45_read_link(struct phy_device *phydev, u32 mmd_mask)
> +{
> +	int val, devad;
> +	bool link = true;
> +
> +	while (mmd_mask) {
> +		devad = __ffs(mmd_mask);
> +		mmd_mask &= ~BIT(devad);
> +
> +		/* The link state is latched low so that momentary link
> +		 * drops can be detected.  Do not double-read the status
> +		 * register if the link is down.
> +		 */
> +		val = phy_read_mmd(phydev, devad, MDIO_STAT1);
> +		if (val < 0)
> +			return val;
> +
> +		if (!(val & MDIO_STAT1_LSTATUS))
> +			link = false;
> +	}
> +
> +	return link;
> +}
> +EXPORT_SYMBOL_GPL(genphy_c45_read_link);
> +
> +/**
> + * genphy_c45_read_lpa - read the link partner advertisment and pause
> + * @phydev: target phy_device struct
> + *
> + * Read the Clause 45 defined base (7.19) and 10G (7.33) status registers,
> + * filling in the link partner advertisment, pause and asym_pause members
> + * in @phydev.  This assumes that the auto-negotiation MMD is present, and
> + * the backplane bit (7.48.0) is clear.  Clause 45 PHY drivers are expected
> + * to fill in the remainder of the link partner advert from vendor registers.
> + */
> +int genphy_c45_read_lpa(struct phy_device *phydev)
> +{
> +	int val;
> +
> +	/* Read the link partner's base page advertisment */
> +	val = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_LPA);
> +	if (val < 0)
> +		return val;
> +
> +	phydev->lp_advertising = mii_lpa_to_ethtool_lpa_t(val);
> +	phydev->pause = val & LPA_PAUSE_CAP ? 1 : 0;
> +	phydev->asym_pause = val & LPA_PAUSE_ASYM ? 1 : 0;
> +
> +	/* Read the link partner's 10G advertisment */
> +	val = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_10GBT_STAT);
> +	if (val < 0)
> +		return val;
> +
> +	if (val & MDIO_AN_10GBT_STAT_LP10G)
> +		phydev->lp_advertising |= ADVERTISED_10000baseT_Full;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(genphy_c45_read_lpa);
> +
> +/**
> + * genphy_c45_read_pma - read link speed etc from PMA
> + * @phydev: target phy_device struct
> + */
> +int genphy_c45_read_pma(struct phy_device *phydev)
> +{
> +	int val;
> +
> +	val = phy_read_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_CTRL1);
> +	if (val < 0)
> +		return val;
> +
> +	switch (val & MDIO_CTRL1_SPEEDSEL) {
> +	case 0:
> +		phydev->speed = SPEED_10;
> +		break;
> +	case MDIO_PMA_CTRL1_SPEED100:
> +		phydev->speed = SPEED_100;
> +		break;
> +	case MDIO_PMA_CTRL1_SPEED1000:
> +		phydev->speed = SPEED_1000;
> +		break;
> +	case MDIO_CTRL1_SPEED10G:
> +		phydev->speed = SPEED_10000;
> +		break;
> +	default:
> +		phydev->speed = SPEED_UNKNOWN;
> +		break;
> +	}
> +
> +	phydev->duplex = DUPLEX_FULL;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(genphy_c45_read_pma);
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 1219eeab69d1..040575dba98c 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -1483,27 +1483,19 @@ EXPORT_SYMBOL(genphy_read_status);
>  
>  static int gen10g_read_status(struct phy_device *phydev)
>  {
> -	int devad, reg;
>  	u32 mmd_mask = phydev->c45_ids.devices_in_package;
> -
> -	phydev->link = 1;
> +	int ret;
>  
>  	/* For now just lie and say it's 10G all the time */
>  	phydev->speed = SPEED_10000;
>  	phydev->duplex = DUPLEX_FULL;
>  
> -	for (devad = 0; mmd_mask; devad++, mmd_mask = mmd_mask >> 1) {
> -		if (!(mmd_mask & 1))
> -			continue;
> +	/* Avoid reading the vendor MMDs */
> +	mmd_mask &= ~(BIT(MDIO_MMD_VEND1) | BIT(MDIO_MMD_VEND2));
>  
> -		/* Read twice because link state is latched and a
> -		 * read moves the current state into the register
> -		 */
> -		phy_read_mmd(phydev, devad, MDIO_STAT1);
> -		reg = phy_read_mmd(phydev, devad, MDIO_STAT1);
> -		if (reg < 0 || !(reg & MDIO_STAT1_LSTATUS))
> -			phydev->link = 0;
> -	}
> +	ret = genphy_c45_read_link(phydev, mmd_mask);
> +
> +	phydev->link = ret > 0 ? 1 : 0;
>  
>  	return 0;
>  }
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index e76e4adbc7c7..735ff1f98db3 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -816,6 +816,8 @@ static inline const char *phydev_name(const struct phy_device *phydev)
>  void phy_attached_print(struct phy_device *phydev, const char *fmt, ...)
>  	__printf(2, 3);
>  void phy_attached_info(struct phy_device *phydev);
> +
> +/* Clause 22 PHY */
>  int genphy_config_init(struct phy_device *phydev);
>  int genphy_setup_forced(struct phy_device *phydev);
>  int genphy_restart_aneg(struct phy_device *phydev);
> @@ -830,6 +832,16 @@ static inline int genphy_no_soft_reset(struct phy_device *phydev)
>  {
>  	return 0;
>  }
> +
> +/* Clause 45 PHY */
> +int genphy_c45_restart_aneg(struct phy_device *phydev);
> +int genphy_c45_aneg_done(struct phy_device *phydev);
> +int genphy_c45_read_link(struct phy_device *phydev, u32 mmd_mask);
> +int genphy_c45_read_lpa(struct phy_device *phydev);
> +int genphy_c45_read_pma(struct phy_device *phydev);
> +int genphy_c45_pma_setup_forced(struct phy_device *phydev);
> +int genphy_c45_an_disable_aneg(struct phy_device *phydev);
> +
>  void phy_driver_unregister(struct phy_driver *drv);
>  void phy_drivers_unregister(struct phy_driver *drv, int n);
>  int phy_driver_register(struct phy_driver *new_driver, struct module *owner);
> 


-- 
Florian
