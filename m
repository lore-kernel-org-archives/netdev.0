From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/7 net-next v2] tg3: Separate coalescing setup for rx
 and tx
Date: Fri, 28 Sep 2012 10:12:39 -0700
Message-ID: <1348852363-8582-3-git-send-email-mchan@broadcom.com>
References: <1348852363-8582-1-git-send-email-mchan@broadcom.com>
 <1348852363-8582-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3442 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758343Ab2I2Blp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 21:41:45 -0400
In-Reply-To: <1348852363-8582-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since the number of rings can be different.

Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   74 +++++++++++++++++++++--------------
 1 files changed, 45 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 330356b..ddf260c 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8331,9 +8331,10 @@ static void tg3_set_bdinfo(struct tg3 *tp, u32 bdinfo_addr,
 			      nic_addr);
 }
 
-static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
+
+static void tg3_coal_tx_init(struct tg3 *tp, struct ethtool_coalesce *ec)
 {
-	int i;
+	int i = 0;
 
 	if (!tg3_flag(tp, ENABLE_TSS)) {
 		tw32(HOSTCC_TXCOL_TICKS, ec->tx_coalesce_usecs);
@@ -8343,31 +8344,43 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 		tw32(HOSTCC_TXCOL_TICKS, 0);
 		tw32(HOSTCC_TXMAX_FRAMES, 0);
 		tw32(HOSTCC_TXCOAL_MAXF_INT, 0);
+
+		for (; i < tp->txq_cnt; i++) {
+			u32 reg;
+
+			reg = HOSTCC_TXCOL_TICKS_VEC1 + i * 0x18;
+			tw32(reg, ec->tx_coalesce_usecs);
+			reg = HOSTCC_TXMAX_FRAMES_VEC1 + i * 0x18;
+			tw32(reg, ec->tx_max_coalesced_frames);
+			reg = HOSTCC_TXCOAL_MAXF_INT_VEC1 + i * 0x18;
+			tw32(reg, ec->tx_max_coalesced_frames_irq);
+		}
+	}
+
+	for (; i < tp->irq_max - 1; i++) {
+		tw32(HOSTCC_TXCOL_TICKS_VEC1 + i * 0x18, 0);
+		tw32(HOSTCC_TXMAX_FRAMES_VEC1 + i * 0x18, 0);
+		tw32(HOSTCC_TXCOAL_MAXF_INT_VEC1 + i * 0x18, 0);
 	}
+}
+
+static void tg3_coal_rx_init(struct tg3 *tp, struct ethtool_coalesce *ec)
+{
+	int i = 0;
+	u32 limit = tp->rxq_cnt;
 
 	if (!tg3_flag(tp, ENABLE_RSS)) {
 		tw32(HOSTCC_RXCOL_TICKS, ec->rx_coalesce_usecs);
 		tw32(HOSTCC_RXMAX_FRAMES, ec->rx_max_coalesced_frames);
 		tw32(HOSTCC_RXCOAL_MAXF_INT, ec->rx_max_coalesced_frames_irq);
+		limit--;
 	} else {
 		tw32(HOSTCC_RXCOL_TICKS, 0);
 		tw32(HOSTCC_RXMAX_FRAMES, 0);
 		tw32(HOSTCC_RXCOAL_MAXF_INT, 0);
 	}
 
-	if (!tg3_flag(tp, 5705_PLUS)) {
-		u32 val = ec->stats_block_coalesce_usecs;
-
-		tw32(HOSTCC_RXCOAL_TICK_INT, ec->rx_coalesce_usecs_irq);
-		tw32(HOSTCC_TXCOAL_TICK_INT, ec->tx_coalesce_usecs_irq);
-
-		if (!netif_carrier_ok(tp->dev))
-			val = 0;
-
-		tw32(HOSTCC_STAT_COAL_TICKS, val);
-	}
-
-	for (i = 0; i < tp->irq_cnt - 1; i++) {
+	for (; i < limit; i++) {
 		u32 reg;
 
 		reg = HOSTCC_RXCOL_TICKS_VEC1 + i * 0x18;
@@ -8376,27 +8389,30 @@ static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 		tw32(reg, ec->rx_max_coalesced_frames);
 		reg = HOSTCC_RXCOAL_MAXF_INT_VEC1 + i * 0x18;
 		tw32(reg, ec->rx_max_coalesced_frames_irq);
-
-		if (tg3_flag(tp, ENABLE_TSS)) {
-			reg = HOSTCC_TXCOL_TICKS_VEC1 + i * 0x18;
-			tw32(reg, ec->tx_coalesce_usecs);
-			reg = HOSTCC_TXMAX_FRAMES_VEC1 + i * 0x18;
-			tw32(reg, ec->tx_max_coalesced_frames);
-			reg = HOSTCC_TXCOAL_MAXF_INT_VEC1 + i * 0x18;
-			tw32(reg, ec->tx_max_coalesced_frames_irq);
-		}
 	}
 
 	for (; i < tp->irq_max - 1; i++) {
 		tw32(HOSTCC_RXCOL_TICKS_VEC1 + i * 0x18, 0);
 		tw32(HOSTCC_RXMAX_FRAMES_VEC1 + i * 0x18, 0);
 		tw32(HOSTCC_RXCOAL_MAXF_INT_VEC1 + i * 0x18, 0);
+	}
+}
 
-		if (tg3_flag(tp, ENABLE_TSS)) {
-			tw32(HOSTCC_TXCOL_TICKS_VEC1 + i * 0x18, 0);
-			tw32(HOSTCC_TXMAX_FRAMES_VEC1 + i * 0x18, 0);
-			tw32(HOSTCC_TXCOAL_MAXF_INT_VEC1 + i * 0x18, 0);
-		}
+static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
+{
+	tg3_coal_tx_init(tp, ec);
+	tg3_coal_rx_init(tp, ec);
+
+	if (!tg3_flag(tp, 5705_PLUS)) {
+		u32 val = ec->stats_block_coalesce_usecs;
+
+		tw32(HOSTCC_RXCOAL_TICK_INT, ec->rx_coalesce_usecs_irq);
+		tw32(HOSTCC_TXCOAL_TICK_INT, ec->tx_coalesce_usecs_irq);
+
+		if (!netif_carrier_ok(tp->dev))
+			val = 0;
+
+		tw32(HOSTCC_STAT_COAL_TICKS, val);
 	}
 }
 
-- 
1.7.1
