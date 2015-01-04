From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v3 4/4] net: bcmgenet: rename bcmgenet_hw_params->bds_cnt and GENET_DEFAULT_BD_CNT
Date: Sat,  3 Jan 2015 23:45:49 -0800 (PST)
Message-ID: <20150104074549.AE90322034C@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:64577 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbADHpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 02:45:51 -0500
Received: by mail-vc0-f202.google.com with SMTP id hy10so980727vcb.5
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2015 23:45:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcmgenet_hw_params->bds_cnt and GENET_DEFAULT_BD_CNT are used only in Tx init.
Rename them accordingly:
- bcmgenet_hw_params->bds_cnt => bcmgenet_hw_params->tx_bds_per_q
- GENET_DEFAULT_BD_CNT => GENET_Q16_TX_BD_CNT

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 29 +++++++++++++-------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  2 +-
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 134d3bf..f5116c2 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -54,8 +54,8 @@
 /* Default highest priority queue for multi queue support */
 #define GENET_Q0_PRIORITY	0
 
-#define GENET_DEFAULT_BD_CNT	\
-	(TOTAL_DESC - priv->hw_params->tx_queues * priv->hw_params->bds_cnt)
+#define GENET_Q16_TX_BD_CNT	\
+	(TOTAL_DESC - priv->hw_params->tx_queues * priv->hw_params->tx_bds_per_q)
 
 #define RX_BUF_LENGTH		2048
 #define SKB_ALIGNMENT		32
@@ -1781,7 +1781,7 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
  * with queue 0 being the highest priority queue.
  *
  * Queue 16 is the default Tx queue with
- * GENET_DEFAULT_BD_CNT = 256 - 4 * 32 = 128 descriptors.
+ * GENET_Q16_TX_BD_CNT = 256 - 4 * 32 = 128 descriptors.
  *
  * The transmit control block pool is then partitioned as follows:
  * - Tx queue 0 uses tx_cbs[0..31]
@@ -1810,9 +1810,9 @@ static void bcmgenet_init_tx_queues(struct net_device *dev)
 
 	/* Initialize Tx priority queues */
 	for (i = 0; i < priv->hw_params->tx_queues; i++) {
-		bcmgenet_init_tx_ring(priv, i, priv->hw_params->bds_cnt,
-				      i * priv->hw_params->bds_cnt,
-				      (i + 1) * priv->hw_params->bds_cnt);
+		bcmgenet_init_tx_ring(priv, i, priv->hw_params->tx_bds_per_q,
+				      i * priv->hw_params->tx_bds_per_q,
+				      (i + 1) * priv->hw_params->tx_bds_per_q);
 		ring_cfg |= (1 << i);
 		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));
 		dma_priority[DMA_PRIO_REG_INDEX(i)] |=
@@ -1820,9 +1820,9 @@ static void bcmgenet_init_tx_queues(struct net_device *dev)
 	}
 
 	/* Initialize Tx default queue 16 */
-	bcmgenet_init_tx_ring(priv, DESC_INDEX, GENET_DEFAULT_BD_CNT,
+	bcmgenet_init_tx_ring(priv, DESC_INDEX, GENET_Q16_TX_BD_CNT,
 			      priv->hw_params->tx_queues *
-			      priv->hw_params->bds_cnt,
+			      priv->hw_params->tx_bds_per_q,
 			      TOTAL_DESC);
 	ring_cfg |= (1 << DESC_INDEX);
 	dma_ctrl |= (1 << (DESC_INDEX + DMA_RING_BUF_EN_SHIFT));
@@ -2426,8 +2426,8 @@ static const struct net_device_ops bcmgenet_netdev_ops = {
 static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 	[GENET_V1] = {
 		.tx_queues = 0,
+		.tx_bds_per_q = 0,
 		.rx_queues = 0,
-		.bds_cnt = 0,
 		.bp_in_en_shift = 16,
 		.bp_in_mask = 0xffff,
 		.hfb_filter_cnt = 16,
@@ -2439,8 +2439,8 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 	},
 	[GENET_V2] = {
 		.tx_queues = 4,
+		.tx_bds_per_q = 32,
 		.rx_queues = 4,
-		.bds_cnt = 32,
 		.bp_in_en_shift = 16,
 		.bp_in_mask = 0xffff,
 		.hfb_filter_cnt = 16,
@@ -2455,8 +2455,8 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 	},
 	[GENET_V3] = {
 		.tx_queues = 4,
+		.tx_bds_per_q = 32,
 		.rx_queues = 4,
-		.bds_cnt = 32,
 		.bp_in_en_shift = 17,
 		.bp_in_mask = 0x1ffff,
 		.hfb_filter_cnt = 48,
@@ -2471,8 +2471,8 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 	},
 	[GENET_V4] = {
 		.tx_queues = 4,
+		.tx_bds_per_q = 32,
 		.rx_queues = 4,
-		.bds_cnt = 32,
 		.bp_in_en_shift = 17,
 		.bp_in_mask = 0x1ffff,
 		.hfb_filter_cnt = 48,
@@ -2572,14 +2572,15 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 #endif
 
 	pr_debug("Configuration for version: %d\n"
-		"TXq: %1d, RXq: %1d, BDs: %1d\n"
+		"TXq: %1d, TXqBDs: %1d, RXq: %1d\n"
 		"BP << en: %2d, BP msk: 0x%05x\n"
 		"HFB count: %2d, QTAQ msk: 0x%05x\n"
 		"TBUF: 0x%04x, HFB: 0x%04x, HFBreg: 0x%04x\n"
 		"RDMA: 0x%05x, TDMA: 0x%05x\n"
 		"Words/BD: %d\n",
 		priv->version,
-		params->tx_queues, params->rx_queues, params->bds_cnt,
+		params->tx_queues, params->tx_bds_per_q,
+		params->rx_queues,
 		params->bp_in_en_shift, params->bp_in_mask,
 		params->hfb_filter_cnt, params->qtag_mask,
 		params->tbuf_offset, params->hfb_offset,
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index b36ddec..3a8a90f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -503,8 +503,8 @@ enum bcmgenet_version {
  */
 struct bcmgenet_hw_params {
 	u8		tx_queues;
+	u8		tx_bds_per_q;
 	u8		rx_queues;
-	u8		bds_cnt;
 	u8		bp_in_en_shift;
 	u32		bp_in_mask;
 	u8		hfb_filter_cnt;
-- 
2.2.0.rc0.207.ga3a616c
