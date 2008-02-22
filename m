From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH RFC] phylib: fix forced mode misbehaviour for aneg off case
Date: Fri, 22 Feb 2008 18:55:24 +0300
Message-ID: <20080222155524.GA6623@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:39490 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753421AbYBVPz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 10:55:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When user disabled autonegotiation via ethtool, and no link is detected,
phylib will place phy into forcing mode, and then will start calling
phy_force_reduction(). This will break user expectations. For example,
user asks for fixed speed 1000:

ethtool -s eth0 autoneg off speed 1000

Without link attached what will actually happen is:

Trying 100/FULL
Trying 100/HALF
Trying 10/FULL
Trying 10/HALF
...

This patch implements "software autonegotiation" that is equivalent to
current behaviour, but enabled only when hardware autonegotiation was
enabled and failed afterwards. With aneg disabled, phylib will not try
other link setups.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

This is of course post-2.6.25 material and highly RFC, as it changes
current behaviour. Please review carefully.

Thanks.

 drivers/net/phy/phy.c   |   19 ++++++++++++-------
 include/linux/ethtool.h |    4 ++++
 2 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 12fccb1..35ad91f 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -264,7 +264,8 @@ void phy_sanitize_settings(struct phy_device *phydev)
 	int idx;
 
 	/* Sanitize settings based on PHY capabilities */
-	if ((features & SUPPORTED_Autoneg) == 0)
+	if ((features & SUPPORTED_Autoneg) == 0 &&
+			AUTONEG_SOFT != phydev->autoneg)
 		phydev->autoneg = AUTONEG_DISABLE;
 
 	idx = phy_find_valid(phy_find_setting(phydev->speed, phydev->duplex),
@@ -297,13 +298,15 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 	cmd->advertising &= phydev->supported;
 
 	/* Verify the settings we care about. */
-	if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != AUTONEG_DISABLE)
+	if (cmd->autoneg != AUTONEG_ENABLE &&
+			cmd->autoneg != AUTONEG_DISABLE &&
+			cmd->autoneg != AUTONEG_SOFT)
 		return -EINVAL;
 
 	if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
 		return -EINVAL;
 
-	if (cmd->autoneg == AUTONEG_DISABLE
+	if ((cmd->autoneg == AUTONEG_DISABLE || cmd->autoneg == AUTONEG_SOFT)
 			&& ((cmd->speed != SPEED_1000
 					&& cmd->speed != SPEED_100
 					&& cmd->speed != SPEED_10)
@@ -433,7 +436,8 @@ int phy_start_aneg(struct phy_device *phydev)
 
 	mutex_lock(&phydev->lock);
 
-	if (AUTONEG_DISABLE == phydev->autoneg)
+	if (AUTONEG_DISABLE == phydev->autoneg ||
+			AUTONEG_SOFT == phydev->autoneg)
 		phy_sanitize_settings(phydev);
 
 	err = phydev->drv->config_aneg(phydev);
@@ -447,7 +451,8 @@ int phy_start_aneg(struct phy_device *phydev)
 			phydev->link_timeout = PHY_AN_TIMEOUT;
 		} else {
 			phydev->state = PHY_FORCING;
-			phydev->link_timeout = PHY_FORCE_TIMEOUT;
+			if (AUTONEG_SOFT == phydev->autoneg)
+				phydev->link_timeout = PHY_FORCE_TIMEOUT;
 		}
 	}
 
@@ -875,7 +880,7 @@ static void phy_state_machine(struct work_struct *work)
 				phydev->speed = settings[idx].speed;
 				phydev->duplex = settings[idx].duplex;
 
-				phydev->autoneg = AUTONEG_DISABLE;
+				phydev->autoneg = AUTONEG_SOFT;
 
 				pr_info("Trying %d/%s\n", phydev->speed,
 						DUPLEX_FULL ==
@@ -904,7 +909,7 @@ static void phy_state_machine(struct work_struct *work)
 			if (phydev->link) {
 				phydev->state = PHY_RUNNING;
 				netif_carrier_on(phydev->attached_dev);
-			} else {
+			} else if (AUTONEG_SOFT == phydev->autoneg) {
 				if (0 == phydev->link_timeout--) {
 					phy_force_reduction(phydev);
 					needs_aneg = 1;
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index fcbe8b6..446f78b 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -517,6 +517,10 @@ struct ethtool_ops {
  */
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
+/* "Software autonegotiation": will try several link variants in this
+ * order -- 1000/FULL, 1000/HALF, 100/FULL, 100/HALF, 10/FULL, 10/HALF.
+ */
+#define AUTONEG_SOFT		0x02
 
 /* Wake-On-Lan options. */
 #define WAKE_PHY		(1 << 0)
-- 
1.5.2.2
