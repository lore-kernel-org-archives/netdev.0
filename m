From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 5/5] net: phy: add Marvell Alaska X 88X3310 10Gigabit PHY
 support
Date: Thu, 1 Jun 2017 10:28:04 -0700
Message-ID: <ddf5b409-43fb-5045-ebfc-9a20d1ca1aec@gmail.com>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJc-000442-8H@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35836 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdFAR2H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 13:28:07 -0400
Received: by mail-qt0-f195.google.com with SMTP id r58so6519622qtb.2
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 10:28:06 -0700 (PDT)
In-Reply-To: <E1dGNJc-000442-8H@rmk-PC.armlinux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2017 03:26 AM, Russell King wrote:
> Add phylib support for the Marvell Alaska X 10 Gigabit PHY (MV88X3310).
> This phy is able to operate at 10G, 1G, 100M and 10M speeds, and only
> supports Clause 45 accesses.
> 
> The PHY appears (based on the vendor IDs) to be two different vendors
> IP, with each devad containing several instances.
> 
> This PHY driver has only been tested with the RJ45 copper port, fiber
> port and a Marvell Armada 8040-based ethernet interface.
> 
> It should be noted that to use the full range of speeds, MAC drivers
> need to also reconfigure the link mode as per phydev->interface, since
> the PHY automatically changes its interface mode depending on the
> negotiated speed.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> ---

>  MARVELL MVNETA ETHERNET DRIVER
>  M:	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
>  L:	netdev@vger.kernel.org
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index 19eddf758c88..905990fece28 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -55,7 +55,7 @@ obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
>  obj-$(CONFIG_INTEL_XWAY_PHY)	+= intel-xway.o
>  obj-$(CONFIG_LSI_ET1011C_PHY)	+= et1011c.o
>  obj-$(CONFIG_LXT_PHY)		+= lxt.o
> -obj-$(CONFIG_MARVELL_PHY)	+= marvell.o
> +obj-$(CONFIG_MARVELL_PHY)	+= marvell.o marvell10g.o

Could we introduce a CONFIG_MARVELL_10G_PHY symbol?


> +enum {
> +	MV_PCS_BASE_T		= 0x0000,
> +	MV_PCS_BASE_R		= 0x1000,
> +	MV_PCS_1000BASEX	= 0x2000,
> +
> +	/* These registers appear at 0x800X and 0xa00X - the 0xa00X control
> +	 * registers appear to set themselves to the 0x800X when AN is
> +	 * restarted, but status registers appear readable from either.
> +	 */
> +	MV_AN_CTRL1000		= 0x8000, /* 1000base-T control register */
> +	MV_AN_STAT1000		= 0x8001, /* 1000base-T status register */
> +
> +	/* This register appears to reflect the copper status */
> +	MV_AN_RESULT		= 0xa016,
> +	MV_AN_RESULT_SPD_10	= BIT(12),
> +	MV_AN_RESULT_SPD_100	= BIT(13),
> +	MV_AN_RESULT_SPD_1000	= BIT(14),
> +	MV_AN_RESULT_SPD_10000	= BIT(15),
> +};

Personal preference is not to use enums but jut plain #define, but
whatever works, really.


> +
> +static int mv3310_soft_reset(struct phy_device *phydev)
> +{
> +	return 0;
> +}

You could use genphy_no_soft_reset(), although genphy sort of implies
C22 now, or we could export genphy10g_soft_reset() which also does nothing.


> +	/* Ethtool does not support the WAN mode bits */
> +	if (val & (MDIO_PMA_STAT2_10GBSR | MDIO_PMA_STAT2_10GBLR |
> +		   MDIO_PMA_STAT2_10GBER | MDIO_PMA_STAT2_10GBLX4 |
> +		   MDIO_PMA_STAT2_10GBSW | MDIO_PMA_STAT2_10GBLW |
> +		   MDIO_PMA_STAT2_10GBEW))
> +		__set_bit(ETHTOOL_LINK_MODE_FIBRE_BIT, supported);
> +	if (val & MDIO_PMA_STAT2_10GBSR)
> +		__set_bit(ETHTOOL_LINK_MODE_10000baseSR_Full_BIT, supported);
> +	if (val & MDIO_PMA_STAT2_10GBLR)
> +		__set_bit(ETHTOOL_LINK_MODE_10000baseLR_Full_BIT, supported);
> +	if (val & MDIO_PMA_STAT2_10GBER)
> +		__set_bit(ETHTOOL_LINK_MODE_10000baseER_Full_BIT, supported);
> +
> +	if (val & MDIO_PMA_STAT2_EXTABLE) {
> +		val = phy_read_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_PMA_EXTABLE);
> +		if (val < 0)
> +			return val;
> +
> +		if (val & (MDIO_PMA_EXTABLE_10GBT | MDIO_PMA_EXTABLE_1000BT |
> +			   MDIO_PMA_EXTABLE_100BTX | MDIO_PMA_EXTABLE_10BT))
> +			__set_bit(ETHTOOL_LINK_MODE_TP_BIT, supported);
> +		if (val & MDIO_PMA_EXTABLE_10GBLRM)
> +			__set_bit(ETHTOOL_LINK_MODE_FIBRE_BIT, supported);
> +		if (val & (MDIO_PMA_EXTABLE_10GBKX4 | MDIO_PMA_EXTABLE_10GBKR |
> +			   MDIO_PMA_EXTABLE_1000BKX))
> +			__set_bit(ETHTOOL_LINK_MODE_Backplane_BIT, supported);
> +		if (val & MDIO_PMA_EXTABLE_10GBLRM)
> +			__set_bit(ETHTOOL_LINK_MODE_10000baseLRM_Full_BIT,
> +				  supported);
> +		if (val & MDIO_PMA_EXTABLE_10GBT)
> +			__set_bit(ETHTOOL_LINK_MODE_10000baseT_Full_BIT,
> +				  supported);
> +		if (val & MDIO_PMA_EXTABLE_10GBKX4)
> +			__set_bit(ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT,
> +				  supported);
> +		if (val & MDIO_PMA_EXTABLE_10GBKR)
> +			__set_bit(ETHTOOL_LINK_MODE_10000baseKR_Full_BIT,
> +				  supported);
> +		if (val & MDIO_PMA_EXTABLE_1000BT)
> +			__set_bit(ETHTOOL_LINK_MODE_1000baseT_Full_BIT,
> +				  supported);
> +		if (val & MDIO_PMA_EXTABLE_1000BKX)
> +			__set_bit(ETHTOOL_LINK_MODE_1000baseKX_Full_BIT,
> +				  supported);
> +		if (val & MDIO_PMA_EXTABLE_100BTX)
> +			__set_bit(ETHTOOL_LINK_MODE_100baseT_Full_BIT,
> +				  supported);
> +		if (val & MDIO_PMA_EXTABLE_10BT)
> +			__set_bit(ETHTOOL_LINK_MODE_10baseT_Full_BIT,
> +				  supported);
> +	}
> +
> +	if (!ethtool_convert_link_mode_to_legacy_u32(&mask, supported))
> +		dev_warn(&phydev->mdio.dev,
> +			 "PHY supports (%*pb) more modes than phylib supports, some modes not supported.\n",
> +			 __ETHTOOL_LINK_MODE_MASK_NBITS, supported);
> +
> +	phydev->supported &= mask;
> +	phydev->advertising &= phydev->supported;

Is not this a candidate for being moved into drivers/net/phy/phy-10g.c?
Past the phy interface mode check, the rest does not appear to be
particularly Marvell specific here.

Other than that, and making it a separate Kconfig option, this looks great!
-- 
Florian
