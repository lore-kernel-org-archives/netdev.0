From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: [PATCH v6 3/4] Marvell phy: add configuration of autonegociation for fiber link.
Date: Tue, 19 Jul 2016 11:13:12 +0200
Message-ID: <1468919593-27602-4-git-send-email-charles-antoine.couret@nexvision.fr>
References: <1468919593-27602-1-git-send-email-charles-antoine.couret@nexvision.fr>
Cc: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 6.mo3.mail-out.ovh.net ([188.165.43.173]:39997 "EHLO
	6.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbcGSJOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 05:14:52 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id 4204110205B6
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:14:50 +0200 (CEST)
In-Reply-To: <1468919593-27602-1-git-send-email-charles-antoine.couret@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be correctly initilized, the fiber interface needs
to be configured via autonegociation registers which use
some customs options or registers.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
---
 drivers/net/phy/marvell.c | 111 +++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 109 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 0dde7ca..fb4d402 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -493,15 +493,122 @@ static int m88e1318_config_aneg(struct phy_device *phydev)
 	return m88e1121_config_aneg(phydev);
 }
 
+/**
+ * ethtool_adv_to_fiber_adv_t
+ * @ethadv: the ethtool advertisement settings
+ *
+ * A small helper function that translates ethtool advertisement
+ * settings to phy autonegotiation advertisements for the
+ * MII_ADV register for fiber link.
+ */
+static inline u32 ethtool_adv_to_fiber_adv_t(u32 ethadv)
+{
+	u32 result = 0;
+
+	if (ethadv & ADVERTISED_1000baseT_Half)
+		result |= ADVERTISE_FIBER_1000HALF;
+	if (ethadv & ADVERTISED_1000baseT_Full)
+		result |= ADVERTISE_FIBER_1000FULL;
+
+	if ((ethadv & ADVERTISE_PAUSE_ASYM) && (ethadv & ADVERTISE_PAUSE_CAP))
+		result |= LPA_PAUSE_ASYM_FIBER;
+	else if (ethadv & ADVERTISE_PAUSE_CAP)
+		result |= (ADVERTISE_PAUSE_FIBER
+			   & (~ADVERTISE_PAUSE_ASYM_FIBER));
+
+	return result;
+}
+
+/**
+ * marvell_config_aneg_fiber - restart auto-negotiation or write BMCR
+ * @phydev: target phy_device struct
+ *
+ * Description: If auto-negotiation is enabled, we configure the
+ *   advertising, and then restart auto-negotiation.  If it is not
+ *   enabled, then we write the BMCR. Adapted for fiber link in
+ *   some Marvell's devices.
+ */
+static int marvell_config_aneg_fiber(struct phy_device *phydev)
+{
+	int changed = 0;
+	int err;
+	int adv, oldadv;
+	u32 advertise;
+
+	if (phydev->autoneg != AUTONEG_ENABLE)
+		return genphy_setup_forced(phydev);
+
+	/* Only allow advertising what this PHY supports */
+	phydev->advertising &= phydev->supported;
+	advertise = phydev->advertising;
+
+	/* Setup fiber advertisement */
+	adv = phy_read(phydev, MII_ADVERTISE);
+	if (adv < 0)
+		return adv;
+
+	oldadv = adv;
+	adv &= ~(ADVERTISE_FIBER_1000HALF | ADVERTISE_FIBER_1000FULL
+		| LPA_PAUSE_FIBER);
+	adv |= ethtool_adv_to_fiber_adv_t(advertise);
+
+	if (adv != oldadv) {
+		err = phy_write(phydev, MII_ADVERTISE, adv);
+		if (err < 0)
+			return err;
+
+		changed = 1;
+	}
+
+	if (changed == 0) {
+		/* Advertisement hasn't changed, but maybe aneg was never on to
+		 * begin with?  Or maybe phy was isolated?
+		 */
+		int ctl = phy_read(phydev, MII_BMCR);
+
+		if (ctl < 0)
+			return ctl;
+
+		if (!(ctl & BMCR_ANENABLE) || (ctl & BMCR_ISOLATE))
+			changed = 1; /* do restart aneg */
+	}
+
+	/* Only restart aneg if we are advertising something different
+	 * than we were before.
+	 */
+	if (changed > 0)
+		changed = genphy_restart_aneg(phydev);
+
+	return changed;
+}
+
 static int m88e1510_config_aneg(struct phy_device *phydev)
 {
 	int err;
 
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	if (err < 0)
+		goto error;
+
+	/* Configure the copper link first */
 	err = m88e1318_config_aneg(phydev);
 	if (err < 0)
-		return err;
+		goto error;
 
-	return 0;
+	/* Then the fiber link */
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+	if (err < 0)
+		goto error;
+
+	err = marvell_config_aneg_fiber(phydev);
+	if (err < 0)
+		goto error;
+
+	return phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+
+error:
+	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	return err;
 }
 
 static int marvell_config_init(struct phy_device *phydev)
-- 
2.7.4
