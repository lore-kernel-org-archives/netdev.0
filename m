From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 03/14] tg3: Update ethtool set_settings error checks
Date: Wed, 25 Feb 2009 16:23:01 -0800
Message-ID: <1235616369.16001@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1837 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753545AbZBZCqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool interface has acquired some new enumerations since the
tg3 driver's tg3_set_settings() error checking code was written.  The
error checking code is no longer complete.  This patch rewrites the
error checking so that it is future-proofed.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   68 +++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 50 insertions(+), 18 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 774a01a..0ea61f7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8552,7 +8552,7 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->duplex = tp->link_config.active_duplex;
 	}
 	cmd->phy_address = PHY_ADDR;
-	cmd->transceiver = 0;
+	cmd->transceiver = XCVR_INTERNAL;
 	cmd->autoneg = tp->link_config.autoneg;
 	cmd->maxtxpkt = 0;
 	cmd->maxrxpkt = 0;
@@ -8569,26 +8569,58 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return phy_ethtool_sset(tp->mdio_bus->phy_map[PHY_ADDR], cmd);
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) {
-		/* These are the only valid advertisement bits allowed.  */
-		if (cmd->autoneg == AUTONEG_ENABLE &&
-		    (cmd->advertising & ~(ADVERTISED_1000baseT_Half |
-					  ADVERTISED_1000baseT_Full |
-					  ADVERTISED_Autoneg |
-					  ADVERTISED_FIBRE)))
-			return -EINVAL;
-		/* Fiber can only do SPEED_1000.  */
-		else if ((cmd->autoneg != AUTONEG_ENABLE) &&
-			 (cmd->speed != SPEED_1000))
-			return -EINVAL;
-	/* Copper cannot force SPEED_1000.  */
-	} else if ((cmd->autoneg != AUTONEG_ENABLE) &&
-		   (cmd->speed == SPEED_1000))
+	if (cmd->autoneg != AUTONEG_ENABLE &&
+	    cmd->autoneg != AUTONEG_DISABLE)
 		return -EINVAL;
-	else if ((cmd->speed == SPEED_1000) &&
-		 (tp->tg3_flags & TG3_FLAG_10_100_ONLY))
+
+	if (cmd->autoneg == AUTONEG_DISABLE &&
+	    cmd->duplex != DUPLEX_FULL &&
+	    cmd->duplex != DUPLEX_HALF)
 		return -EINVAL;
 
+	if (cmd->autoneg == AUTONEG_ENABLE) {
+		u32 mask = ADVERTISED_Autoneg |
+			   ADVERTISED_Pause |
+			   ADVERTISED_Asym_Pause;
+
+		if (!(tp->tg3_flags2 & TG3_FLAG_10_100_ONLY))
+			mask |= ADVERTISED_1000baseT_Half |
+				ADVERTISED_1000baseT_Full;
+
+		if (!(tp->tg3_flags2 & TG3_FLG2_ANY_SERDES))
+			mask |= ADVERTISED_100baseT_Half |
+				ADVERTISED_100baseT_Full |
+				ADVERTISED_10baseT_Half |
+				ADVERTISED_10baseT_Full |
+				ADVERTISED_TP;
+		else
+			mask |= ADVERTISED_FIBRE;
+
+		if (cmd->advertising & ~mask)
+			return -EINVAL;
+
+		mask &= (ADVERTISED_1000baseT_Half |
+			 ADVERTISED_1000baseT_Full |
+			 ADVERTISED_100baseT_Half |
+			 ADVERTISED_100baseT_Full |
+			 ADVERTISED_10baseT_Half |
+			 ADVERTISED_10baseT_Full);
+
+		cmd->advertising &= mask;
+	} else {
+		if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) {
+			if (cmd->speed != SPEED_1000)
+				return -EINVAL;
+
+			if (cmd->duplex != DUPLEX_FULL)
+				return -EINVAL;
+		} else {
+			if (cmd->speed != SPEED_100 &&
+			    cmd->speed != SPEED_10)
+				return -EINVAL;
+		}
+	}
+
 	tg3_full_lock(tp, 0);
 
 	tp->link_config.autoneg = cmd->autoneg;
-- 
1.6.0.6


