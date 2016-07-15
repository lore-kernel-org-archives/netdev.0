From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: [PATCH 3/4] Marvell phy: add configuration of autonegociation for
 fiber link.
Date: Fri, 15 Jul 2016 12:12:39 +0200
Message-ID: <5dcd193f-b060-8b85-a1d9-8f6031b991d1@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 18.mo3.mail-out.ovh.net ([87.98.172.162]:33776 "EHLO
	18.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbcGOKTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 06:19:00 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id 680091030662
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 12:12:39 +0200 (CEST)
Received: from [192.168.1.29] (LFbn-1-1866-70.w90-73.abo.wanadoo.fr [90.73.165.70])
	(Authenticated sender: charles-antoine.couret@nexvision.fr)
	by player734.ha.ovh.net (Postfix) with ESMTPSA id 5829528001B
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 12:12:39 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 5be52efa3f1c034c21f80850b651193d1f51a313 Mon Sep 17 00:00:00 2001
From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Date: Fri, 15 Jul 2016 11:57:25 +0200
Subject: [PATCH 3/4] Marvell phy: add configuration of autonegociation for
 fiber link.

Signed-off-by: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
---
 drivers/net/phy/marvell.c | 111 +++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 109 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 13a93d8..e05209b 100644
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
