From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v3 2/4] net: bcmgenet: rework Tx queue init
Date: Sat,  3 Jan 2015 23:45:31 -0800 (PST)
Message-ID: <20150104074531.AA3F522034C@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:44266 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbbADHpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 02:45:33 -0500
Received: by mail-pa0-f73.google.com with SMTP id rd3so2484718pab.0
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2015 23:45:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Rename bcmgenet_init_multiq() to bcmgenet_init_tx_queues()
2. Move Tx default queue init inside bcmgenet_init_tx_queues()

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 81 +++++++++++---------------
 1 file changed, 35 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 6636182..bd06573 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1775,78 +1775,73 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
 	return ret;
 }
 
-/* init multi xmit queues, only available for GENET2+
- * the queue is partitioned as follows:
+/* Initialize Tx queues
  *
- * queue 0 - 3 is priority based, each one has 32 descriptors,
+ * Queues 0-3 are priority-based, each one has 32 descriptors,
  * with queue 0 being the highest priority queue.
  *
- * queue 16 is the default tx queue with GENET_DEFAULT_BD_CNT
- * descriptors: 256 - (number of tx queues * bds per queues) = 128
- * descriptors.
+ * Queue 16 is the default Tx queue with
+ * GENET_DEFAULT_BD_CNT = 256 - 4 * 32 = 128 descriptors.
  *
- * The transmit control block pool is then partitioned as following:
- * - tx_cbs[0...127] are for queue 16
- * - tx_ring_cbs[0] points to tx_cbs[128..159]
- * - tx_ring_cbs[1] points to tx_cbs[160..191]
- * - tx_ring_cbs[2] points to tx_cbs[192..223]
- * - tx_ring_cbs[3] points to tx_cbs[224..255]
+ * The transmit control block pool is then partitioned as follows:
+ * - Tx queue 0 uses tx_cbs[0..31]
+ * - Tx queue 1 uses tx_cbs[32..63]
+ * - Tx queue 2 uses tx_cbs[64..95]
+ * - Tx queue 3 uses tx_cbs[96..127]
+ * - Tx queue 16 uses tx_cbs[128..255]
  */
-static void bcmgenet_init_multiq(struct net_device *dev)
+static void bcmgenet_init_tx_queues(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
-	unsigned int i, dma_enable;
-	u32 reg, dma_ctrl, ring_cfg = 0;
+	u32 i, dma_enable;
+	u32 dma_ctrl, ring_cfg;
 	u32 dma_priority[3] = {0, 0, 0};
 
-	if (!netif_is_multiqueue(dev)) {
-		netdev_warn(dev, "called with non multi queue aware HW\n");
-		return;
-	}
-
 	dma_ctrl = bcmgenet_tdma_readl(priv, DMA_CTRL);
 	dma_enable = dma_ctrl & DMA_EN;
 	dma_ctrl &= ~DMA_EN;
 	bcmgenet_tdma_writel(priv, dma_ctrl, DMA_CTRL);
 
+	dma_ctrl = 0;
+	ring_cfg = 0;
+
 	/* Enable strict priority arbiter mode */
 	bcmgenet_tdma_writel(priv, DMA_ARBITER_SP, DMA_ARB_CTRL);
 
+	/* Initialize Tx priority queues */
 	for (i = 0; i < priv->hw_params->tx_queues; i++) {
-		/* first 64 tx_cbs are reserved for default tx queue
-		 * (ring 16)
-		 */
 		bcmgenet_init_tx_ring(priv, i, priv->hw_params->bds_cnt,
 				      i * priv->hw_params->bds_cnt,
 				      (i + 1) * priv->hw_params->bds_cnt);
-
-		/* Configure ring as descriptor ring and setup priority */
-		ring_cfg |= 1 << i;
-		dma_ctrl |= 1 << (i + DMA_RING_BUF_EN_SHIFT);
-
+		ring_cfg |= (1 << i);
+		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));
 		dma_priority[DMA_PRIO_REG_INDEX(i)] |=
 			((GENET_Q0_PRIORITY + i) << DMA_PRIO_REG_SHIFT(i));
 	}
 
-	/* Set ring 16 priority and program the hardware registers */
+	/* Initialize Tx default queue 16 */
+	bcmgenet_init_tx_ring(priv, DESC_INDEX, GENET_DEFAULT_BD_CNT,
+			      priv->hw_params->tx_queues *
+			      priv->hw_params->bds_cnt,
+			      TOTAL_DESC);
+	ring_cfg |= (1 << DESC_INDEX);
+	dma_ctrl |= (1 << (DESC_INDEX + DMA_RING_BUF_EN_SHIFT));
 	dma_priority[DMA_PRIO_REG_INDEX(DESC_INDEX)] |=
 		((GENET_Q0_PRIORITY + priv->hw_params->tx_queues) <<
 		 DMA_PRIO_REG_SHIFT(DESC_INDEX));
+
+	/* Set Tx queue priorities */
 	bcmgenet_tdma_writel(priv, dma_priority[0], DMA_PRIORITY_0);
 	bcmgenet_tdma_writel(priv, dma_priority[1], DMA_PRIORITY_1);
 	bcmgenet_tdma_writel(priv, dma_priority[2], DMA_PRIORITY_2);
 
-	/* Enable rings */
-	reg = bcmgenet_tdma_readl(priv, DMA_RING_CFG);
-	reg |= ring_cfg;
-	bcmgenet_tdma_writel(priv, reg, DMA_RING_CFG);
+	/* Enable Tx queues */
+	bcmgenet_tdma_writel(priv, ring_cfg, DMA_RING_CFG);
 
-	/* Configure ring as descriptor ring and re-enable DMA if enabled */
-	reg = bcmgenet_tdma_readl(priv, DMA_CTRL);
-	reg |= dma_ctrl;
+	/* Enable Tx DMA */
 	if (dma_enable)
-		reg |= DMA_EN;
-	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
+		dma_ctrl |= DMA_EN;
+	bcmgenet_tdma_writel(priv, dma_ctrl, DMA_CTRL);
 }
 
 static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
@@ -1949,14 +1944,8 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 		return -ENOMEM;
 	}
 
-	/* initialize multi xmit queue */
-	bcmgenet_init_multiq(priv->dev);
-
-	/* initialize special ring 16 */
-	bcmgenet_init_tx_ring(priv, DESC_INDEX, GENET_DEFAULT_BD_CNT,
-			      priv->hw_params->tx_queues *
-			      priv->hw_params->bds_cnt,
-			      TOTAL_DESC);
+	/* Initialize Tx queues */
+	bcmgenet_init_tx_queues(priv->dev);
 
 	return 0;
 }
-- 
2.2.0.rc0.207.ga3a616c
