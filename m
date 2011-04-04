From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/8] bnx2: convert to set_phys_id
Date: Mon, 04 Apr 2011 14:06:36 -0700
Message-ID: <20110404210805.389777981@linuxplumber.net>
References: <20110404210634.840793593@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43877 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754631Ab1DDWSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 18:18:16 -0400
Content-Disposition: inline; filename=bnx2-set-phys.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this case, need to add element to device private to hold
original led state.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/bnx2.c |   58 +++++++++++++++++++++++++----------------------------
 drivers/net/bnx2.h |    1 
 2 files changed, 29 insertions(+), 30 deletions(-)

--- a/drivers/net/bnx2.c	2011-04-04 12:00:28.358308398 -0700
+++ b/drivers/net/bnx2.c	2011-04-04 12:05:33.909298263 -0700
@@ -7495,41 +7495,39 @@ bnx2_get_ethtool_stats(struct net_device
 }
 
 static int
-bnx2_phys_id(struct net_device *dev, u32 data)
+bnx2_set_phys_id(struct net_device *dev, enum ethtool_phys_id_state state)
 {
 	struct bnx2 *bp = netdev_priv(dev);
-	int i;
-	u32 save;
 
-	bnx2_set_power_state(bp, PCI_D0);
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		bnx2_set_power_state(bp, PCI_D0);
 
-	if (data == 0)
-		data = 2;
+		bp->leds_save = REG_RD(bp, BNX2_MISC_CFG);
+		REG_WR(bp, BNX2_MISC_CFG, BNX2_MISC_CFG_LEDMODE_MAC);
+		return -EINVAL;
 
-	save = REG_RD(bp, BNX2_MISC_CFG);
-	REG_WR(bp, BNX2_MISC_CFG, BNX2_MISC_CFG_LEDMODE_MAC);
-
-	for (i = 0; i < (data * 2); i++) {
-		if ((i % 2) == 0) {
-			REG_WR(bp, BNX2_EMAC_LED, BNX2_EMAC_LED_OVERRIDE);
-		}
-		else {
-			REG_WR(bp, BNX2_EMAC_LED, BNX2_EMAC_LED_OVERRIDE |
-				BNX2_EMAC_LED_1000MB_OVERRIDE |
-				BNX2_EMAC_LED_100MB_OVERRIDE |
-				BNX2_EMAC_LED_10MB_OVERRIDE |
-				BNX2_EMAC_LED_TRAFFIC_OVERRIDE |
-				BNX2_EMAC_LED_TRAFFIC);
-		}
-		msleep_interruptible(500);
-		if (signal_pending(current))
-			break;
+	case ETHTOOL_ID_ON:
+		REG_WR(bp, BNX2_EMAC_LED, BNX2_EMAC_LED_OVERRIDE |
+		       BNX2_EMAC_LED_1000MB_OVERRIDE |
+		       BNX2_EMAC_LED_100MB_OVERRIDE |
+		       BNX2_EMAC_LED_10MB_OVERRIDE |
+		       BNX2_EMAC_LED_TRAFFIC_OVERRIDE |
+		       BNX2_EMAC_LED_TRAFFIC);
+		break;
+
+	case ETHTOOL_ID_OFF:
+		REG_WR(bp, BNX2_EMAC_LED, BNX2_EMAC_LED_OVERRIDE);
+		break;
+
+	case ETHTOOL_ID_INACTIVE:
+		REG_WR(bp, BNX2_EMAC_LED, 0);
+		REG_WR(bp, BNX2_MISC_CFG, bp->leds_save);
+
+		if (!netif_running(dev))
+			bnx2_set_power_state(bp, PCI_D3hot);
+		break;
 	}
-	REG_WR(bp, BNX2_EMAC_LED, 0);
-	REG_WR(bp, BNX2_MISC_CFG, save);
-
-	if (!netif_running(dev))
-		bnx2_set_power_state(bp, PCI_D3hot);
 
 	return 0;
 }
@@ -7602,7 +7600,7 @@ static const struct ethtool_ops bnx2_eth
 	.set_tso		= bnx2_set_tso,
 	.self_test		= bnx2_self_test,
 	.get_strings		= bnx2_get_strings,
-	.phys_id		= bnx2_phys_id,
+	.set_phys_id		= bnx2_set_phys_id,
 	.get_ethtool_stats	= bnx2_get_ethtool_stats,
 	.get_sset_count		= bnx2_get_sset_count,
 	.set_flags		= bnx2_set_flags,
--- a/drivers/net/bnx2.h	2011-04-04 12:03:55.332429815 -0700
+++ b/drivers/net/bnx2.h	2011-04-04 12:04:59.388992279 -0700
@@ -6922,6 +6922,7 @@ struct bnx2 {
 	u8			num_tx_rings;
 	u8			num_rx_rings;
 
+	u32 			leds_save;
 	u32			idle_chk_status_idx;
 
 #ifdef BCM_CNIC


