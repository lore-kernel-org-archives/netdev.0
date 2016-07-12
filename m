From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: [PATCH v3] Marvell phy: add fiber status check and configuration for
 some phys
Date: Tue, 12 Jul 2016 17:00:52 +0200
Message-ID: <75f458dd-6f6e-153d-eff1-d2b1112f268f@nexvision.fr>
References: <20160404132552.GH21828@lunn.ch> <570BFF50.6060909@gmail.com>
 <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
 <9dd03fd9-1241-fc7d-ead3-feb7e918d4c3@nexvision.fr>
 <20160602145636.GA15379@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 17.mo3.mail-out.ovh.net ([87.98.178.58]:54622 "EHLO
	17.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982AbcGLPIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 11:08:36 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id 2E2611020D85
	for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 17:01:53 +0200 (CEST)
In-Reply-To: <20160602145636.GA15379@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I'm back with another patch evrsion about Marvell phys with a fiber interface.
>From the previous release, I fixed some issues reported by yours and I added some functions around the fiber interface to get statistics, to configure the aneg, etc.
Yes, to implement that, copper and fiber side are closed, but the fiber link needs some custom registers or bit values. I'm based on some genphy functions to adapt to fiber link.

With that, the 88E1512 for example could have the same features for the copper and fiber links.
I'm interested by your feedback about this patch.

Thank you in advance.
Regards.
Charles-Antoine Couret

>From 4ca5935f8aa97c3ba02cb27e970e1bcf248aed18 Mon Sep 17 00:00:00 2001
From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Date: Fri, 1 Apr 2016 16:16:35 +0200
Subject: [PATCH] Marvell phy: add fiber status check for some components

Some Marvell's phys have two modes: fiber and copper. Currently, the driver
configures and checks only the copper mode registers
which could be the wrong link.

This commit add handlers to check fiber then copper status link
or to configure the fiber interface.

This patch is not tested with all Marvell's phys.
The new functions are enabled only for tested phys.
Some of them functions are based on genphy functions.

Signed-off-by: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
---
 drivers/net/phy/marvell.c | 323 +++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 307 insertions(+), 16 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index ec2c1ee..3cd8d94 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -138,6 +138,20 @@
 #define MII_88E1510_GEN_CTRL_REG_1_MODE_SGMII	0x1	/* SGMII to copper */
 #define MII_88E1510_GEN_CTRL_REG_1_RESET	0x8000	/* Soft reset */
 
+#define LPA_FIBER_1000HALF	0x40
+#define LPA_FIBER_1000FULL	0x20
+
+#define LPA_PAUSE_FIBER		0x180
+#define LPA_PAUSE_ASYM_FIBER	0x100
+
+#define ADVERTISE_FIBER_1000HALF	0x40
+#define ADVERTISE_FIBER_1000FULL	0x20
+
+#define ADVERTISE_PAUSE_FIBER		0x180
+#define ADVERTISE_PAUSE_ASYM_FIBER	0x100
+
+#define REGISTER_LINK_STATUS	0x400
+
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
 MODULE_LICENSE("GPL");
@@ -151,6 +165,7 @@ struct marvell_hw_stat {
 
 static struct marvell_hw_stat marvell_hw_stats[] = {
 	{ "phy_receive_errors", 0, 21, 16},
+	{ "phy_receive_errors_fiber", 1, 21, 16},
 	{ "phy_idle_errors", 0, 10, 8 },
 };
 
@@ -477,15 +492,122 @@ static int m88e1318_config_aneg(struct phy_device *phydev)
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
@@ -890,6 +1012,48 @@ static int m88e1145_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+/**
+ * fiber_lpa_to_ethtool_lpa_t
+ * @lpa: value of the MII_LPA register for fiber link
+ *
+ * A small helper function that translates MII_LPA
+ * bits to ethtool LP advertisement settings.
+ */
+static u32 fiber_lpa_to_ethtool_lpa_t(u32 lpa)
+{
+	u32 result = 0;
+
+	if (lpa & LPA_FIBER_1000HALF)
+		result |= ADVERTISED_1000baseT_Half;
+	if (lpa & LPA_FIBER_1000FULL)
+		result |= ADVERTISED_1000baseT_Full;
+
+	return result;
+}
+
+/**
+ * marvell_update_link - update link status in real time in @phydev
+ * @phydev: target phy_device struct
+ *
+ * Description: Update the value in phydev->link to reflect the
+ *   current link value.
+ */
+static int marvell_update_link(struct phy_device *phydev)
+{
+	int status;
+
+	status = phy_read(phydev, MII_M1011_PHY_STATUS);
+	if (status < 0)
+		return status;
+
+	if ((status & REGISTER_LINK_STATUS) == 0)
+		phydev->link = 0;
+	else
+		phydev->link = 1;
+
+	return 0;
+}
+
 /* marvell_read_status
  *
  * Generic status code does not detect Fiber correctly!
@@ -906,12 +1070,17 @@ static int marvell_read_status(struct phy_device *phydev)
 	int lpa;
 	int lpagb;
 	int status = 0;
+	int page, fiber;
 
-	/* Update the link, but return if there
+	/* Detect and update the link, but return if there
 	 * was an error */
-	err = genphy_update_link(phydev);
-	if (err)
-		return err;
+	page = phy_read(phydev, MII_MARVELL_PHY_PAGE);
+	if (page == MII_M1111_FIBER)
+		fiber = 1;
+	else
+		fiber = 0;
+
+	err = marvell_update_link(phydev);
 
 	if (AUTONEG_ENABLE == phydev->autoneg) {
 		status = phy_read(phydev, MII_M1011_PHY_STATUS);
@@ -930,9 +1099,6 @@ static int marvell_read_status(struct phy_device *phydev)
 		if (adv < 0)
 			return adv;
 
-		phydev->lp_advertising = mii_stat1000_to_ethtool_lpa_t(lpagb) |
-					 mii_lpa_to_ethtool_lpa_t(lpa);
-
 		lpa &= adv;
 
 		if (status & MII_M1011_PHY_STATUS_FULLDUPLEX)
@@ -957,9 +1123,30 @@ static int marvell_read_status(struct phy_device *phydev)
 			break;
 		}
 
-		if (phydev->duplex == DUPLEX_FULL) {
-			phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
-			phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
+		if (!fiber) {
+			phydev->lp_advertising = mii_stat1000_to_ethtool_lpa_t(lpagb) |
+					 mii_lpa_to_ethtool_lpa_t(lpa);
+
+			if (phydev->duplex == DUPLEX_FULL) {
+				phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
+				phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
+			}
+		} else {
+			/* The fiber link is only 1000M capable */
+			phydev->lp_advertising = fiber_lpa_to_ethtool_lpa_t(lpa);
+
+			if (phydev->duplex == DUPLEX_FULL) {
+				if (!(lpa & LPA_PAUSE_FIBER)) {
+					phydev->pause = 0;
+					phydev->asym_pause = 0;
+				} else if ((lpa & LPA_PAUSE_ASYM_FIBER)) {
+					phydev->pause = 1;
+					phydev->asym_pause = 1;
+				} else {
+					phydev->pause = 1;
+					phydev->asym_pause = 0;
+				}
+			}
 		}
 	} else {
 		int bmcr = phy_read(phydev, MII_BMCR);
@@ -986,6 +1173,105 @@ static int marvell_read_status(struct phy_device *phydev)
 	return 0;
 }
 
+/* marvell_read_fiber_status
+ *
+ * Some Marvell's phys have two modes: fiber and copper.
+ * Both need status checked.
+ * Description:
+ *   First, check the fiber link and status.
+ *   If the fiber link is down, check the copper link and status which
+ *   will be the default value if both link are down.
+ */
+static int marvell_read_fiber_status(struct phy_device *phydev)
+{
+	int err;
+
+	/* Check the fiber mode first */
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+	if (err < 0)
+		goto error;
+
+	err = marvell_read_status(phydev);
+	if (err < 0)
+		goto error;
+
+	if (phydev->link) {
+		phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+		return 0;
+	}
+
+	/* If fiber link is down, check and save copper mode state */
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	if (err < 0)
+		goto error;
+
+	return marvell_read_status(phydev);
+
+error:
+	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	return err;
+}
+
+/* marvell_suspend_fiber
+ *
+ * Some Marvell's phys have two modes: fiber and copper.
+ * Both need to be suspended
+ */
+static int marvell_suspend_fiber(struct phy_device *phydev)
+{
+	int err;
+
+	/* Suspend the fiber mode first */
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+	if (err < 0)
+		goto error;
+
+	err = genphy_suspend(phydev);
+	if (err < 0)
+		goto error;
+
+	/* Then, the copper link */
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	if (err < 0)
+		goto error;
+
+	return genphy_suspend(phydev);
+
+error:
+	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	return err;
+}
+
+/* marvell_resume_fiber
+ *
+ * Some Marvell's phys have two modes: fiber and copper.
+ * Both need to be resumed
+ */
+static int marvell_resume_fiber(struct phy_device *phydev)
+{
+	int err;
+
+	/* Resume the fiber mode first */
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+	if (err < 0)
+		goto error;
+
+	err = genphy_resume(phydev);
+	if (err < 0)
+		goto error;
+
+	/* Then, the copper link */
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	if (err < 0)
+		goto error;
+
+	return genphy_resume(phydev);
+
+error:
+	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	return err;
+}
+
 static int marvell_aneg_done(struct phy_device *phydev)
 {
 	int retval = phy_read(phydev, MII_M1011_PHY_STATUS);
@@ -1130,6 +1416,11 @@ static u64 marvell_get_stat(struct phy_device *phydev, int i)
 	int err, oldpage, val;
 	u64 ret;
 
+	if (!(phydev->supported & SUPPORTED_FIBRE)) {
+		if (strstr(marvell_hw_stats[i].string, "fiber"))
+			return 0;
+	}
+
 	oldpage = phy_read(phydev, MII_MARVELL_PHY_PAGE);
 	err = phy_write(phydev, MII_MARVELL_PHY_PAGE,
 			stat.page);
@@ -1361,17 +1652,17 @@ static struct phy_driver marvell_drivers[] = {
 		.phy_id = MARVELL_PHY_ID_88E1510,
 		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1510",
-		.features = PHY_GBIT_FEATURES,
+		.features = PHY_GBIT_FEATURES | SUPPORTED_FIBRE,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
 		.config_init = &m88e1510_config_init,
 		.config_aneg = &m88e1510_config_aneg,
-		.read_status = &marvell_read_status,
+		.read_status = &marvell_read_fiber_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.did_interrupt = &m88e1121_did_interrupt,
-		.resume = &genphy_resume,
-		.suspend = &genphy_suspend,
+		.resume = &marvell_resume_fiber,
+		.suspend = &marvell_suspend_fiber,
 		.get_sset_count = marvell_get_sset_count,
 		.get_strings = marvell_get_strings,
 		.get_stats = marvell_get_stats,
-- 
2.7.4
