From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/4] tg3: Remove SPEED_UNKNOWN checks
Date: Wed, 22 Feb 2012 14:35:19 -0800
Message-ID: <1329950121-18577-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3326 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834Ab2BVWgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 17:36:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tg3_phy_copper_begin() has code that configures the link
advertisements through the use of the link_config.speed and
link_config.duplex members.  The driver does not internally use these
members in this way, nor is it (currently) permitted via the ethtool
interface.  This patch removes the dead code.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   67 ++++++++++++-----------------------
 1 files changed, 23 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index c56523e..9d895c9 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3894,51 +3894,33 @@ done:
 
 static void tg3_phy_copper_begin(struct tg3 *tp)
 {
-	u32 new_adv;
-	int i;
-
-	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) {
-		new_adv = ADVERTISED_10baseT_Half |
-			  ADVERTISED_10baseT_Full;
-		if (tg3_flag(tp, WOL_SPEED_100MB))
-			new_adv |= ADVERTISED_100baseT_Half |
-				   ADVERTISED_100baseT_Full;
-
-		tg3_phy_autoneg_cfg(tp, new_adv,
-				    FLOW_CTRL_TX | FLOW_CTRL_RX);
-	} else if (tp->link_config.speed == SPEED_UNKNOWN) {
-		if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
-			tp->link_config.advertising &=
-				~(ADVERTISED_1000baseT_Half |
-				  ADVERTISED_1000baseT_Full);
-
-		tg3_phy_autoneg_cfg(tp, tp->link_config.advertising,
-				    tp->link_config.flowctrl);
-	} else {
-		/* Asking for a specific link mode. */
-		if (tp->link_config.speed == SPEED_1000) {
-			if (tp->link_config.duplex == DUPLEX_FULL)
-				new_adv = ADVERTISED_1000baseT_Full;
-			else
-				new_adv = ADVERTISED_1000baseT_Half;
-		} else if (tp->link_config.speed == SPEED_100) {
-			if (tp->link_config.duplex == DUPLEX_FULL)
-				new_adv = ADVERTISED_100baseT_Full;
-			else
-				new_adv = ADVERTISED_100baseT_Half;
+	if (tp->link_config.autoneg == AUTONEG_ENABLE ||
+	    (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)) {
+		u32 adv, fc;
+
+		if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) {
+			adv = ADVERTISED_10baseT_Half |
+			      ADVERTISED_10baseT_Full;
+			if (tg3_flag(tp, WOL_SPEED_100MB))
+				adv |= ADVERTISED_100baseT_Half |
+				       ADVERTISED_100baseT_Full;
+
+			fc = FLOW_CTRL_TX | FLOW_CTRL_RX;
 		} else {
-			if (tp->link_config.duplex == DUPLEX_FULL)
-				new_adv = ADVERTISED_10baseT_Full;
-			else
-				new_adv = ADVERTISED_10baseT_Half;
+			adv = tp->link_config.advertising;
+			if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
+				adv &= ~(ADVERTISED_1000baseT_Half |
+					 ADVERTISED_1000baseT_Full);
+
+			fc = tp->link_config.flowctrl;
 		}
 
-		tg3_phy_autoneg_cfg(tp, new_adv,
-				    tp->link_config.flowctrl);
-	}
+		tg3_phy_autoneg_cfg(tp, adv, fc);
 
-	if (tp->link_config.autoneg == AUTONEG_DISABLE &&
-	    tp->link_config.speed != SPEED_UNKNOWN) {
+		tg3_writephy(tp, MII_BMCR,
+			     BMCR_ANENABLE | BMCR_ANRESTART);
+	} else {
+		int i;
 		u32 bmcr, orig_bmcr;
 
 		tp->link_config.active_speed = tp->link_config.speed;
@@ -3980,9 +3962,6 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 			tg3_writephy(tp, MII_BMCR, bmcr);
 			udelay(40);
 		}
-	} else {
-		tg3_writephy(tp, MII_BMCR,
-			     BMCR_ANENABLE | BMCR_ANRESTART);
 	}
 }
 
-- 
1.7.3.4
