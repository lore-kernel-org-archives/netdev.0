From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 5/5] net: phy: add Marvell Alaska X 88X3310 10Gigabit PHY
 support
Date: Thu, 1 Jun 2017 14:51:50 +0200
Message-ID: <20170601125150.GE9282@lunn.ch>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJc-000442-8H@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32792 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751078AbdFAMvw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 08:51:52 -0400
Content-Disposition: inline
In-Reply-To: <E1dGNJc-000442-8H@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int mv3310_read_status(struct phy_device *phydev)
> +{
> +	u32 mmd_mask = phydev->c45_ids.devices_in_package;
> +	int val;
> +
> +	/* The vendor devads do not report link status.  Avoid the PHYXS
> +	 * instance as there are three, and its status depends on the MAC
> +	 * being appropriately configured for the negotiated speed.
> +	 */
> +	mmd_mask &= ~(BIT(MDIO_MMD_VEND1) | BIT(MDIO_MMD_VEND2) |
> +		      BIT(MDIO_MMD_PHYXS));
> +
> +	phydev->speed = SPEED_UNKNOWN;
> +	phydev->duplex = DUPLEX_UNKNOWN;
> +	phydev->lp_advertising = 0;
> +	phydev->link = 0;
> +	phydev->pause = 0;
> +	phydev->asym_pause = 0;
> +
> +	val = phy_read_mmd(phydev, MDIO_MMD_PCS, MV_PCS_BASE_R + MDIO_STAT1);
> +	if (val < 0)
> +		return val;
> +
> +	if (val & MDIO_STAT1_LSTATUS)
> +		return mv3310_read_10gbr_status(phydev);
> +
> +	val = genphy_c45_read_link(phydev, mmd_mask);
> +	if (val < 0)
> +		return val;
> +
> +	phydev->link = val > 0 ? 1 : 0;
> +
> +	val = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
> +	if (val < 0)
> +		return val;
> +
> +	if (val & MDIO_AN_STAT1_COMPLETE) {
> +		val = genphy_c45_read_lpa(phydev);
> +		if (val < 0)
> +			return val;
> +
> +		/* Read the link partner's 1G advertisment */
> +		val = phy_read_mmd(phydev, MDIO_MMD_AN, MV_AN_STAT1000);
> +		if (val < 0)
> +			return val;
> +
> +		phydev->lp_advertising |= mii_stat1000_to_ethtool_lpa_t(val);
> +
> +		if (phydev->autoneg == AUTONEG_ENABLE) {
> +			val = phy_read_mmd(phydev, MDIO_MMD_AN, MV_AN_RESULT);
> +			if (val < 0)
> +				return val;
> +
> +			if (val & MV_AN_RESULT_SPD_10000)
> +				phydev->speed = SPEED_10000;
> +			else if (val & MV_AN_RESULT_SPD_1000)
> +				phydev->speed = SPEED_1000;
> +			else if (val & MV_AN_RESULT_SPD_100)
> +				phydev->speed = SPEED_100;
> +			else if (val & MV_AN_RESULT_SPD_10)
> +				phydev->speed = SPEED_10;
> +
> +			phydev->duplex = DUPLEX_FULL;
> +		}
> +	}
> +
> +	if (phydev->autoneg != AUTONEG_ENABLE) {
> +		val = genphy_c45_read_pma(phydev);
> +		if (val < 0)
> +			return val;
> +	}
> +
> +	if ((phydev->interface == PHY_INTERFACE_MODE_SGMII ||
> +	     phydev->interface == PHY_INTERFACE_MODE_10GKR) && phydev->link) {
> +		/* The PHY automatically switches its serdes interface (and
> +		 * active PHYXS instance) between Cisco SGMII and 10GBase-KR
> +		 * modes according to the speed.  Florian suggests setting
> +		 * phydev->interface to communicate this to the MAC. Only do
> +		 * this if we are already in either SGMII or 10GBase-KR mode.
> +		 */

Hi Russell

Just for my understanding. The MAC should check phydev->interface in
its adjust_link function? Can we document this here please. I wounder
if there is somewhere in the generic code we should also document
this?

> +static struct phy_driver mv3310_drivers[] = {
> +	{
> +		.phy_id		= 0x002b09aa,
> +		.phy_id_mask	= 0xffffffff,

How about adding this ID to include/linux/marvell_phy.h? Or do you
think this is not actually a Marvell ID, but some 3rd party which
Marvell has licensed it from?

	Andrew
