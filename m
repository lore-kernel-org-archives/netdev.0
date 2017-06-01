From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 5/5] net: phy: add Marvell Alaska X 88X3310 10Gigabit PHY
 support
Date: Thu, 1 Jun 2017 14:06:58 +0100
Message-ID: <20170601130658.GZ22219@n2100.armlinux.org.uk>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJc-000442-8H@rmk-PC.armlinux.org.uk>
 <20170601125150.GE9282@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:54920 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdFANHI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 09:07:08 -0400
Content-Disposition: inline
In-Reply-To: <20170601125150.GE9282@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 02:51:50PM +0200, Andrew Lunn wrote:
> > +static int mv3310_read_status(struct phy_device *phydev)
> > +{
> > +	u32 mmd_mask = phydev->c45_ids.devices_in_package;
> > +	int val;
> > +
> > +	/* The vendor devads do not report link status.  Avoid the PHYXS
> > +	 * instance as there are three, and its status depends on the MAC
> > +	 * being appropriately configured for the negotiated speed.
> > +	 */
> > +	mmd_mask &= ~(BIT(MDIO_MMD_VEND1) | BIT(MDIO_MMD_VEND2) |
> > +		      BIT(MDIO_MMD_PHYXS));
> > +
> > +	phydev->speed = SPEED_UNKNOWN;
> > +	phydev->duplex = DUPLEX_UNKNOWN;
> > +	phydev->lp_advertising = 0;
> > +	phydev->link = 0;
> > +	phydev->pause = 0;
> > +	phydev->asym_pause = 0;
> > +
> > +	val = phy_read_mmd(phydev, MDIO_MMD_PCS, MV_PCS_BASE_R + MDIO_STAT1);
> > +	if (val < 0)
> > +		return val;
> > +
> > +	if (val & MDIO_STAT1_LSTATUS)
> > +		return mv3310_read_10gbr_status(phydev);
> > +
> > +	val = genphy_c45_read_link(phydev, mmd_mask);
> > +	if (val < 0)
> > +		return val;
> > +
> > +	phydev->link = val > 0 ? 1 : 0;
> > +
> > +	val = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
> > +	if (val < 0)
> > +		return val;
> > +
> > +	if (val & MDIO_AN_STAT1_COMPLETE) {
> > +		val = genphy_c45_read_lpa(phydev);
> > +		if (val < 0)
> > +			return val;
> > +
> > +		/* Read the link partner's 1G advertisment */
> > +		val = phy_read_mmd(phydev, MDIO_MMD_AN, MV_AN_STAT1000);
> > +		if (val < 0)
> > +			return val;
> > +
> > +		phydev->lp_advertising |= mii_stat1000_to_ethtool_lpa_t(val);
> > +
> > +		if (phydev->autoneg == AUTONEG_ENABLE) {
> > +			val = phy_read_mmd(phydev, MDIO_MMD_AN, MV_AN_RESULT);
> > +			if (val < 0)
> > +				return val;
> > +
> > +			if (val & MV_AN_RESULT_SPD_10000)
> > +				phydev->speed = SPEED_10000;
> > +			else if (val & MV_AN_RESULT_SPD_1000)
> > +				phydev->speed = SPEED_1000;
> > +			else if (val & MV_AN_RESULT_SPD_100)
> > +				phydev->speed = SPEED_100;
> > +			else if (val & MV_AN_RESULT_SPD_10)
> > +				phydev->speed = SPEED_10;
> > +
> > +			phydev->duplex = DUPLEX_FULL;
> > +		}
> > +	}
> > +
> > +	if (phydev->autoneg != AUTONEG_ENABLE) {
> > +		val = genphy_c45_read_pma(phydev);
> > +		if (val < 0)
> > +			return val;
> > +	}
> > +
> > +	if ((phydev->interface == PHY_INTERFACE_MODE_SGMII ||
> > +	     phydev->interface == PHY_INTERFACE_MODE_10GKR) && phydev->link) {
> > +		/* The PHY automatically switches its serdes interface (and
> > +		 * active PHYXS instance) between Cisco SGMII and 10GBase-KR
> > +		 * modes according to the speed.  Florian suggests setting
> > +		 * phydev->interface to communicate this to the MAC. Only do
> > +		 * this if we are already in either SGMII or 10GBase-KR mode.
> > +		 */
> 
> Hi Russell
> 
> Just for my understanding. The MAC should check phydev->interface in
> its adjust_link function? Can we document this here please. I wounder
> if there is somewhere in the generic code we should also document
> this?

Yes, it would need to, since it would be unreliable to determine from
the link mode bits.

> > +static struct phy_driver mv3310_drivers[] = {
> > +	{
> > +		.phy_id		= 0x002b09aa,
> > +		.phy_id_mask	= 0xffffffff,
> 
> How about adding this ID to include/linux/marvell_phy.h? Or do you
> think this is not actually a Marvell ID, but some 3rd party which
> Marvell has licensed it from?

The vendor part is not the conventional Marvell ID.  The 3310 appears
to be two or three different vendors IP all glued together, some of
which is in a way which violates the clause 45 register definitions.
Eg, there's multiple instances of PHYXS at 4K offsets, but C45
indicates that these are "reserved" and the place for vendor specific
stuff is in the two vendor MMDs.  Same goes for some of the other
MMDs as well.  I'll call these "MMD sub-blocks".

Some MMD sub-blocks have a Marvell ID in them, but others do not.

The OUI for the ID listed above is apparently "FiberHome Digital
Technology Co.,Ltd." but you'll also find the ID "0141 0daa" in some
of the MMD sub-blocks which corresponds with Marvell.

We can't use the sub-blocks though, because as I say, that's rather
non-standard and against the Clause 45 spec.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
