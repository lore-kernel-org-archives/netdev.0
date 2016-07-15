From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: [PATCH 1/4 v4] Marvell phy: check link status in case of fiber link.
Date: Fri, 15 Jul 2016 12:11:30 +0200
Message-ID: <9e170b8a-cfd7-42ef-0beb-29161d283b00@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 17.mo3.mail-out.ovh.net ([87.98.178.58]:36831 "EHLO
	17.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932284AbcGOKTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 06:19:04 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id C5F6F1030679
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 12:11:30 +0200 (CEST)
Received: from [192.168.1.29] (LFbn-1-1866-70.w90-73.abo.wanadoo.fr [90.73.165.70])
	(Authenticated sender: charles-antoine.couret@nexvision.fr)
	by player734.ha.ovh.net (Postfix) with ESMTPSA id 762B1280073
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 12:11:30 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

It's my 4rd patch set for this feature.
Thanks to comment my work. :)

>From 354c25b138f8da9a1f4f451698b3a9122f41717c Mon Sep 17 00:00:00 2001
From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Date: Fri, 15 Jul 2016 11:51:48 +0200
Subject: [PATCH 1/4] Marvell phy: check link status in case of fiber link.

For concerned phy, the fiber link is checked before the copper link.
According to datasheet, the link which is up is enabled.

If both links are down, copper link would be used.
To detect fiber link status, we used the real time status
because of troubles with the copper method.

Tested with Marvell 88E1512.

Signed-off-by: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
---
 drivers/net/phy/marvell.c | 152 ++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 141 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index ec2c1ee..97b9148 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -138,6 +138,21 @@
 #define MII_88E1510_GEN_CTRL_REG_1_MODE_SGMII	0x1	/* SGMII to copper */
 #define MII_88E1510_GEN_CTRL_REG_1_RESET	0x8000	/* Soft reset */
 
+#define LPA_FIBER_1000HALF	0x40
+#define LPA_FIBER_1000FULL	0x20
+
+#define LPA_PAUSE_FIBER	0x180
+#define LPA_PAUSE_ASYM_FIBER	0x100
+
+#define ADVERTISE_FIBER_1000HALF	0x40
+#define ADVERTISE_FIBER_1000FULL	0x20
+
+#define ADVERTISE_PAUSE_FIBER		0x180
+#define ADVERTISE_PAUSE_ASYM_FIBER	0x100
+
+#define REGISTER_LINK_STATUS	0x400
+#define NB_FIBER_STATS	1
+
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
 MODULE_LICENSE("GPL");
@@ -890,26 +905,79 @@ static int m88e1145_config_init(struct phy_device *phydev)
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
+static int marvell_update_link(struct phy_device *phydev, int fiber)
+{
+	int status;
+
+	/* Use the generic register for copper link, or specific
+	 * register for fiber case */
+	if (fiber) {
+		status = phy_read(phydev, MII_M1011_PHY_STATUS);
+		if (status < 0)
+			return status;
+
+		if ((status & REGISTER_LINK_STATUS) == 0)
+			phydev->link = 0;
+		else
+			phydev->link = 1;
+	} else {
+		return genphy_update_link(phydev);
+	}
+
+	return 0;
+}
+
 /* marvell_read_status
  *
- * Generic status code does not detect Fiber correctly!
  * Description:
  *   Check the link, then figure out the current state
  *   by comparing what we advertise with what the link partner
  *   advertises.  Start by checking the gigabit possibilities,
  *   then move on to 10/100.
  */
-static int marvell_read_status(struct phy_device *phydev)
+static int marvell_read_status_page(struct phy_device *phydev, int page)
 {
 	int adv;
 	int err;
 	int lpa;
 	int lpagb;
 	int status = 0;
+	int fiber;
 
-	/* Update the link, but return if there
+	/* Detect and update the link, but return if there
 	 * was an error */
-	err = genphy_update_link(phydev);
+	if (page == MII_M1111_FIBER)
+		fiber = 1;
+	else
+		fiber = 0;
+
+	err = marvell_update_link(phydev, fiber);
 	if (err)
 		return err;
 
@@ -930,9 +998,6 @@ static int marvell_read_status(struct phy_device *phydev)
 		if (adv < 0)
 			return adv;
 
-		phydev->lp_advertising = mii_stat1000_to_ethtool_lpa_t(lpagb) |
-					 mii_lpa_to_ethtool_lpa_t(lpa);
-
 		lpa &= adv;
 
 		if (status & MII_M1011_PHY_STATUS_FULLDUPLEX)
@@ -957,9 +1022,30 @@ static int marvell_read_status(struct phy_device *phydev)
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
@@ -986,6 +1072,50 @@ static int marvell_read_status(struct phy_device *phydev)
 	return 0;
 }
 
+/* marvell_read_status
+ *
+ * Some Marvell's phys have two modes: fiber and copper.
+ * Both need status checked.
+ * Description:
+ *   First, check the fiber link and status.
+ *   If the fiber link is down, check the copper link and status which
+ *   will be the default value if both link are down.
+ */
+static int marvell_read_status(struct phy_device *phydev)
+{
+	int err;
+
+	/* Check the fiber mode first */
+	if (phydev->supported & SUPPORTED_FIBRE) {
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
+		if (err < 0)
+			goto error;
+
+		err = marvell_read_status_page(phydev, MII_M1111_FIBER);
+		if (err < 0)
+			goto error;
+
+		/* If the fiber link is up, it is the selected and used link.
+		 * In this case, we need to stay in the fiber page.
+		 * Please to be careful about that, avoid to restore Copper page
+		 * in other functions which could break the behaviour
+		 * for some fiber phy like 88E1512.
+		 * */
+		if (phydev->link)
+			return 0;
+
+		/* If fiber link is down, check and save copper mode state */
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+		if (err < 0)
+			goto error;
+	}
+
+	return marvell_read_status_page(phydev, MII_M1111_COPPER);
+
+error:
+	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
+	return err;
+}
 static int marvell_aneg_done(struct phy_device *phydev)
 {
 	int retval = phy_read(phydev, MII_M1011_PHY_STATUS);
@@ -1361,7 +1491,7 @@ static struct phy_driver marvell_drivers[] = {
 		.phy_id = MARVELL_PHY_ID_88E1510,
 		.phy_id_mask = MARVELL_PHY_ID_MASK,
 		.name = "Marvell 88E1510",
-		.features = PHY_GBIT_FEATURES,
+		.features = PHY_GBIT_FEATURES | SUPPORTED_FIBRE,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
 		.config_init = &m88e1510_config_init,
-- 
2.7.4
