From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] phylib: fix forced mode misbehaviour for aneg off case
Date: Thu, 3 Jul 2008 21:16:14 +0400
Message-ID: <20080703171614.GA21126@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:21855 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753156AbYGCRQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 13:16:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With disabled autonegotiation and link absence, phylib will place phy
into the forcing mode, thus will start calling phy_force_reduction().
That means that for the drivers that are using phylib we can't actually
set fixed speed for the link.

For example:

# ethtool -s eth0 autoneg off speed 1000

Without link attached what will actually happen is:

Trying 100/FULL
Trying 100/HALF
Trying 10/FULL
Trying 10/HALF
Trying 10/HALF
Trying 10/HALF
...

This patch implements "software autonegotiation" that is equivalent to
the current behaviour, but enabled only when hardware autonegotiation
was enabled and failed afterwards. With aneg disabled, phylib will not
try other link setups, thus will pay attention to user's needs.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

(it took me four months to recall that I need to respin this patch. ;-)

Andy, I incorporated your comment regarding link_timeout zeroing:
http://www.mail-archive.com/netdev@vger.kernel.org/msg62458.html

 drivers/net/phy/phy.c   |   21 ++++++++++++++-------
 include/linux/ethtool.h |    4 ++++
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 45cc291..5295016 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -264,7 +264,8 @@ void phy_sanitize_settings(struct phy_device *phydev)
 	int idx;
 
 	/* Sanitize settings based on PHY capabilities */
-	if ((features & SUPPORTED_Autoneg) == 0)
+	if ((features & SUPPORTED_Autoneg) == 0 &&
+			phydev->autoneg != AUTONEG_SOFT)
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
@@ -435,7 +438,8 @@ int phy_start_aneg(struct phy_device *phydev)
 
 	mutex_lock(&phydev->lock);
 
-	if (AUTONEG_DISABLE == phydev->autoneg)
+	if (phydev->autoneg == AUTONEG_DISABLE ||
+			phydev->autoneg == AUTONEG_SOFT)
 		phy_sanitize_settings(phydev);
 
 	err = phydev->drv->config_aneg(phydev);
@@ -449,7 +453,10 @@ int phy_start_aneg(struct phy_device *phydev)
 			phydev->link_timeout = PHY_AN_TIMEOUT;
 		} else {
 			phydev->state = PHY_FORCING;
-			phydev->link_timeout = PHY_FORCE_TIMEOUT;
+			if (phydev->autoneg == AUTONEG_SOFT)
+				phydev->link_timeout = PHY_FORCE_TIMEOUT;
+			else
+				phydev->link_timeout = 0;
 		}
 	}
 
@@ -877,7 +884,7 @@ static void phy_state_machine(struct work_struct *work)
 				phydev->speed = settings[idx].speed;
 				phydev->duplex = settings[idx].duplex;
 
-				phydev->autoneg = AUTONEG_DISABLE;
+				phydev->autoneg = AUTONEG_SOFT;
 
 				pr_info("Trying %d/%s\n", phydev->speed,
 						DUPLEX_FULL ==
@@ -906,7 +913,7 @@ static void phy_state_machine(struct work_struct *work)
 			if (phydev->link) {
 				phydev->state = PHY_RUNNING;
 				netif_carrier_on(phydev->attached_dev);
-			} else {
+			} else if (phydev->autoneg == AUTONEG_SOFT) {
 				if (0 == phydev->link_timeout--) {
 					phy_force_reduction(phydev);
 					needs_aneg = 1;
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c8d2163..337c88e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -518,6 +518,10 @@ struct ethtool_ops {
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
1.5.5.4
