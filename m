From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 11/18] tg3: Add coalesce parameters for msix vectors
Date: Tue, 1 Sep 2009 16:12:00 -0700
Message-ID: <1251867309.5944@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3685 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932133AbZIBEzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to tune the coalescing parameters for the other
msix vectors.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   57 ++++++++++++++++++++++++++++++++++++++++++++--------
 drivers/net/tg3.h |   10 ++++++++-
 2 files changed, 57 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ad0fc5d..8e9492b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6876,24 +6876,63 @@ static void tg3_set_bdinfo(struct tg3 *tp, u32 bdinfo_addr,
 static void __tg3_set_rx_mode(struct net_device *);
 static void __tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
 {
-	tw32(HOSTCC_RXCOL_TICKS, ec->rx_coalesce_usecs);
-	tw32(HOSTCC_TXCOL_TICKS, ec->tx_coalesce_usecs);
-	tw32(HOSTCC_RXMAX_FRAMES, ec->rx_max_coalesced_frames);
-	tw32(HOSTCC_TXMAX_FRAMES, ec->tx_max_coalesced_frames);
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
-		tw32(HOSTCC_RXCOAL_TICK_INT, ec->rx_coalesce_usecs_irq);
-		tw32(HOSTCC_TXCOAL_TICK_INT, ec->tx_coalesce_usecs_irq);
+	int i;
+
+	if (!(tp->tg3_flags2 & TG3_FLG2_USING_MSIX)) {
+		tw32(HOSTCC_TXCOL_TICKS, ec->tx_coalesce_usecs);
+		tw32(HOSTCC_TXMAX_FRAMES, ec->tx_max_coalesced_frames);
+		tw32(HOSTCC_TXCOAL_MAXF_INT, ec->tx_max_coalesced_frames_irq);
+
+		tw32(HOSTCC_RXCOL_TICKS, ec->rx_coalesce_usecs);
+		tw32(HOSTCC_RXMAX_FRAMES, ec->rx_max_coalesced_frames);
+		tw32(HOSTCC_RXCOAL_MAXF_INT, ec->rx_max_coalesced_frames_irq);
+	} else {
+		tw32(HOSTCC_TXCOL_TICKS, 0);
+		tw32(HOSTCC_TXMAX_FRAMES, 0);
+		tw32(HOSTCC_TXCOAL_MAXF_INT, 0);
+
+		tw32(HOSTCC_RXCOL_TICKS, 0);
+		tw32(HOSTCC_RXMAX_FRAMES, 0);
+		tw32(HOSTCC_RXCOAL_MAXF_INT, 0);
 	}
-	tw32(HOSTCC_RXCOAL_MAXF_INT, ec->rx_max_coalesced_frames_irq);
-	tw32(HOSTCC_TXCOAL_MAXF_INT, ec->tx_max_coalesced_frames_irq);
+
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
 		u32 val = ec->stats_block_coalesce_usecs;
 
+		tw32(HOSTCC_RXCOAL_TICK_INT, ec->rx_coalesce_usecs_irq);
+		tw32(HOSTCC_TXCOAL_TICK_INT, ec->tx_coalesce_usecs_irq);
+
 		if (!netif_carrier_ok(tp->dev))
 			val = 0;
 
 		tw32(HOSTCC_STAT_COAL_TICKS, val);
 	}
+
+	for (i = 0; i < tp->irq_cnt - 1; i++) {
+		u32 reg;
+
+		reg = HOSTCC_RXCOL_TICKS_VEC1 + i * 0x18;
+		tw32(reg, ec->rx_coalesce_usecs);
+		reg = HOSTCC_TXCOL_TICKS_VEC1 + i * 0x18;
+		tw32(reg, ec->tx_coalesce_usecs);
+		reg = HOSTCC_RXMAX_FRAMES_VEC1 + i * 0x18;
+		tw32(reg, ec->rx_max_coalesced_frames);
+		reg = HOSTCC_TXMAX_FRAMES_VEC1 + i * 0x18;
+		tw32(reg, ec->tx_max_coalesced_frames);
+		reg = HOSTCC_RXCOAL_MAXF_INT_VEC1 + i * 0x18;
+		tw32(reg, ec->rx_max_coalesced_frames_irq);
+		reg = HOSTCC_TXCOAL_MAXF_INT_VEC1 + i * 0x18;
+		tw32(reg, ec->tx_max_coalesced_frames_irq);
+	}
+
+	for (; i < tp->irq_max - 1; i++) {
+		tw32(HOSTCC_RXCOL_TICKS_VEC1 + i * 0x18, 0);
+		tw32(HOSTCC_TXCOL_TICKS_VEC1 + i * 0x18, 0);
+		tw32(HOSTCC_RXMAX_FRAMES_VEC1 + i * 0x18, 0);
+		tw32(HOSTCC_TXMAX_FRAMES_VEC1 + i * 0x18, 0);
+		tw32(HOSTCC_RXCOAL_MAXF_INT_VEC1 + i * 0x18, 0);
+		tw32(HOSTCC_TXCOAL_MAXF_INT_VEC1 + i * 0x18, 0);
+	}
 }
 
 /* tp->lock is held. */
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d1c7add..978b6d9 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1119,7 +1119,15 @@
 #define HOSTCC_SND_CON_IDX_14		0x00003cf8
 #define HOSTCC_SND_CON_IDX_15		0x00003cfc
 #define HOSTCC_STATBLCK_RING1		0x00003d00
-/* 0x3d04 --> 0x4000 unused */
+/* 0x3d00 --> 0x3d80 unused */
+
+#define HOSTCC_RXCOL_TICKS_VEC1		0x00003d80
+#define HOSTCC_TXCOL_TICKS_VEC1		0x00003d84
+#define HOSTCC_RXMAX_FRAMES_VEC1	0x00003d88
+#define HOSTCC_TXMAX_FRAMES_VEC1	0x00003d8c
+#define HOSTCC_RXCOAL_MAXF_INT_VEC1	0x00003d90
+#define HOSTCC_TXCOAL_MAXF_INT_VEC1	0x00003d94
+/* 0x3d98 --> 0x4000 unused */
 
 /* Memory arbiter control registers */
 #define MEMARB_MODE			0x00004000
-- 
1.6.3.3


