From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next] net: bcmgenet: core changes for supporting multiple Rx queues
Date: Mon,  9 Mar 2015 13:40:00 -0700 (PDT)
Message-ID: <20150309204001.215FB2214B7@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:33530 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407AbbCIUkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 16:40:03 -0400
Received: by iecrp18 with SMTP id rp18so7243147iec.0
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 13:40:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Add struct bcmgenet_rx_ring to hold all necessary information
   for a single Rx queue.
2. Add bcmgenet_init_rx_queues() to initialize all Rx queues.
3. Modify bcmgenet_init_rx_ring() to initialize a single Rx queue.
4. Modify Rx interrupt path code to use per-queue data.
5. Modify bcmgenet_rx_refill() to use RxCB->bd_addr.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 156 +++++++++++++++++--------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  16 ++-
 2 files changed, 119 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 83c0cb3..275be56 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1363,16 +1363,7 @@ static int bcmgenet_rx_refill(struct bcmgenet_priv *priv, struct enet_cb *cb)
 	}
 
 	dma_unmap_addr_set(cb, dma_addr, mapping);
-	/* assign packet, prepare descriptor, and advance pointer */
-
-	dmadesc_set_addr(priv, priv->rx_bd_assign_ptr, mapping);
-
-	/* turn on the newly assigned BD for DMA to use */
-	priv->rx_bd_assign_index++;
-	priv->rx_bd_assign_index &= (priv->num_rx_bds - 1);
-
-	priv->rx_bd_assign_ptr = priv->rx_bds +
-		(priv->rx_bd_assign_index * DMA_DESC_SIZE);
+	dmadesc_set_addr(priv, cb->bd_addr, mapping);
 
 	return 0;
 }
@@ -1381,8 +1372,10 @@ static int bcmgenet_rx_refill(struct bcmgenet_priv *priv, struct enet_cb *cb)
  * this could be called from bottom half, or from NAPI polling method.
  */
 static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
+				     unsigned int index,
 				     unsigned int budget)
 {
+	struct bcmgenet_rx_ring *ring = &priv->rx_rings[index];
 	struct net_device *dev = priv->dev;
 	struct enet_cb *cb;
 	struct sk_buff *skb;
@@ -1393,21 +1386,21 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 	unsigned int p_index;
 	unsigned int chksum_ok = 0;
 
-	p_index = bcmgenet_rdma_ring_readl(priv, DESC_INDEX, RDMA_PROD_INDEX);
+	p_index = bcmgenet_rdma_ring_readl(priv, index, RDMA_PROD_INDEX);
 	p_index &= DMA_P_INDEX_MASK;
 
-	if (p_index < priv->rx_c_index)
-		rxpkttoprocess = (DMA_C_INDEX_MASK + 1) -
-			priv->rx_c_index + p_index;
+	if (likely(p_index >= ring->c_index))
+		rxpkttoprocess = p_index - ring->c_index;
 	else
-		rxpkttoprocess = p_index - priv->rx_c_index;
+		rxpkttoprocess = (DMA_C_INDEX_MASK + 1) - ring->c_index +
+				 p_index;
 
 	netif_dbg(priv, rx_status, dev,
 		  "RDMA: rxpkttoprocess=%d\n", rxpkttoprocess);
 
 	while ((rxpktprocessed < rxpkttoprocess) &&
 	       (rxpktprocessed < budget)) {
-		cb = &priv->rx_cbs[priv->rx_read_ptr];
+		cb = &priv->rx_cbs[ring->read_ptr];
 		skb = cb->skb;
 
 		/* We do not have a backing SKB, so we do not have a
@@ -1430,10 +1423,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 
 		if (!priv->desc_64b_en) {
 			dma_length_status =
-				dmadesc_get_length_status(priv,
-							  priv->rx_bds +
-							  (priv->rx_read_ptr *
-							   DMA_DESC_SIZE));
+				dmadesc_get_length_status(priv, cb->bd_addr);
 		} else {
 			struct status_64 *status;
 
@@ -1449,8 +1439,8 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
 
 		netif_dbg(priv, rx_status, dev,
 			  "%s:p_ind=%d c_ind=%d read_ptr=%d len_stat=0x%08x\n",
-			  __func__, p_index, priv->rx_c_index,
-			  priv->rx_read_ptr, dma_length_status);
+			  __func__, p_index, ring->c_index,
+			  ring->read_ptr, dma_length_status);
 
 		if (unlikely(!(dma_flag & DMA_EOP) || !(dma_flag & DMA_SOP))) {
 			netif_err(priv, rx_status, dev,
@@ -1528,25 +1518,31 @@ refill:
 		}
 
 		rxpktprocessed++;
-		priv->rx_read_ptr++;
-		priv->rx_read_ptr &= (priv->num_rx_bds - 1);
+		if (likely(ring->read_ptr < ring->end_ptr))
+			ring->read_ptr++;
+		else
+			ring->read_ptr = ring->cb_ptr;
+
+		ring->c_index = (ring->c_index + 1) & DMA_C_INDEX_MASK;
+		bcmgenet_rdma_ring_writel(priv, index, ring->c_index, RDMA_CONS_INDEX);
 	}
 
 	return rxpktprocessed;
 }
 
 /* Assign skb to RX DMA descriptor. */
-static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv)
+static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv,
+				     struct bcmgenet_rx_ring *ring)
 {
 	struct enet_cb *cb;
 	int ret = 0;
 	int i;
 
-	netif_dbg(priv, hw, priv->dev, "%s:\n", __func__);
+	netif_dbg(priv, hw, priv->dev, "%s\n", __func__);
 
 	/* loop here for each buffer needing assign */
-	for (i = 0; i < priv->num_rx_bds; i++) {
-		cb = &priv->rx_cbs[priv->rx_bd_assign_index];
+	for (i = 0; i < ring->size; i++) {
+		cb = ring->cbs + i;
 		if (cb->skb)
 			continue;
 
@@ -1778,20 +1774,24 @@ static void bcmgenet_fini_tx_ring(struct bcmgenet_priv *priv,
 
 /* Initialize a RDMA ring */
 static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
-				 unsigned int index, unsigned int size)
+				 unsigned int index, unsigned int size,
+				 unsigned int start_ptr, unsigned int end_ptr)
 {
+	struct bcmgenet_rx_ring *ring = &priv->rx_rings[index];
 	u32 words_per_bd = WORDS_PER_BD(priv);
 	int ret;
 
-	priv->rx_bd_assign_ptr = priv->rx_bds;
-	priv->rx_bd_assign_index = 0;
-	priv->rx_c_index = 0;
-	priv->rx_read_ptr = 0;
+	ring->index = index;
+	ring->cbs = priv->rx_cbs + start_ptr;
+	ring->size = size;
+	ring->c_index = 0;
+	ring->read_ptr = start_ptr;
+	ring->cb_ptr = start_ptr;
+	ring->end_ptr = end_ptr - 1;
 
-	ret = bcmgenet_alloc_rx_buffers(priv);
-	if (ret) {
+	ret = bcmgenet_alloc_rx_buffers(priv, ring);
+	if (ret)
 		return ret;
-	}
 
 	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_PROD_INDEX);
 	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_CONS_INDEX);
@@ -1805,10 +1805,13 @@ static int bcmgenet_init_rx_ring(struct bcmgenet_priv *priv,
 				   DMA_FC_THRESH_HI, RDMA_XON_XOFF_THRESH);
 
 	/* Set start and end address, read and write pointers */
-	bcmgenet_rdma_ring_writel(priv, index, 0, DMA_START_ADDR);
-	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_READ_PTR);
-	bcmgenet_rdma_ring_writel(priv, index, 0, RDMA_WRITE_PTR);
-	bcmgenet_rdma_ring_writel(priv, index, words_per_bd * size - 1,
+	bcmgenet_rdma_ring_writel(priv, index, start_ptr * words_per_bd,
+				  DMA_START_ADDR);
+	bcmgenet_rdma_ring_writel(priv, index, start_ptr * words_per_bd,
+				  RDMA_READ_PTR);
+	bcmgenet_rdma_ring_writel(priv, index, start_ptr * words_per_bd,
+				  RDMA_WRITE_PTR);
+	bcmgenet_rdma_ring_writel(priv, index, end_ptr * words_per_bd - 1,
 				  DMA_END_ADDR);
 
 	return ret;
@@ -1883,6 +1886,66 @@ static void bcmgenet_init_tx_queues(struct net_device *dev)
 	bcmgenet_tdma_writel(priv, dma_ctrl, DMA_CTRL);
 }
 
+/* Initialize Rx queues
+ *
+ * Queues 0-15 are priority queues. Hardware Filtering Block (HFB) can be
+ * used to direct traffic to these queues.
+ *
+ * Queue 16 is the default Rx queue with GENET_Q16_RX_BD_CNT descriptors.
+ */
+static int bcmgenet_init_rx_queues(struct net_device *dev)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	u32 i;
+	u32 dma_enable;
+	u32 dma_ctrl;
+	u32 ring_cfg;
+	int ret;
+
+	dma_ctrl = bcmgenet_rdma_readl(priv, DMA_CTRL);
+	dma_enable = dma_ctrl & DMA_EN;
+	dma_ctrl &= ~DMA_EN;
+	bcmgenet_rdma_writel(priv, dma_ctrl, DMA_CTRL);
+
+	dma_ctrl = 0;
+	ring_cfg = 0;
+
+	/* Initialize Rx priority queues */
+	for (i = 0; i < priv->hw_params->rx_queues; i++) {
+		ret = bcmgenet_init_rx_ring(priv, i,
+					    priv->hw_params->rx_bds_per_q,
+					    i * priv->hw_params->rx_bds_per_q,
+					    (i + 1) *
+					    priv->hw_params->rx_bds_per_q);
+		if (ret)
+			return ret;
+
+		ring_cfg |= (1 << i);
+		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));
+	}
+
+	/* Initialize Rx default queue 16 */
+	ret = bcmgenet_init_rx_ring(priv, DESC_INDEX, GENET_Q16_RX_BD_CNT,
+				    priv->hw_params->rx_queues *
+				    priv->hw_params->rx_bds_per_q,
+				    TOTAL_DESC);
+	if (ret)
+		return ret;
+
+	ring_cfg |= (1 << DESC_INDEX);
+	dma_ctrl |= (1 << (DESC_INDEX + DMA_RING_BUF_EN_SHIFT));
+
+	/* Enable rings */
+	bcmgenet_rdma_writel(priv, ring_cfg, DMA_RING_CFG);
+
+	/* Configure ring as descriptor ring and re-enable DMA if enabled */
+	if (dma_enable)
+		dma_ctrl |= DMA_EN;
+	bcmgenet_rdma_writel(priv, dma_ctrl, DMA_CTRL);
+
+	return 0;
+}
+
 static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
 {
 	int ret = 0;
@@ -1990,10 +2053,10 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 		cb->bd_addr = priv->rx_bds + i * DMA_DESC_SIZE;
 	}
 
-	/* Initialize Rx default queue 16 */
-	ret = bcmgenet_init_rx_ring(priv, DESC_INDEX, TOTAL_DESC);
+	/* Initialize Rx queues */
+	ret = bcmgenet_init_rx_queues(priv->dev);
 	if (ret) {
-		netdev_err(priv->dev, "failed to initialize RX ring\n");
+		netdev_err(priv->dev, "failed to initialize Rx queues\n");
 		bcmgenet_free_rx_buffers(priv);
 		kfree(priv->rx_cbs);
 		return ret;
@@ -2030,13 +2093,8 @@ static int bcmgenet_poll(struct napi_struct *napi, int budget)
 			struct bcmgenet_priv, napi);
 	unsigned int work_done;
 
-	work_done = bcmgenet_desc_rx(priv, budget);
+	work_done = bcmgenet_desc_rx(priv, DESC_INDEX, budget);
 
-	/* Advancing our consumer index*/
-	priv->rx_c_index += work_done;
-	priv->rx_c_index &= DMA_C_INDEX_MASK;
-	bcmgenet_rdma_ring_writel(priv, DESC_INDEX,
-				  priv->rx_c_index, RDMA_CONS_INDEX);
 	if (work_done < budget) {
 		napi_complete(napi);
 		bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE,
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 5684e85..17443db 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -540,6 +540,16 @@ struct bcmgenet_tx_ring {
 	struct bcmgenet_priv *priv;
 };
 
+struct bcmgenet_rx_ring {
+	unsigned int	index;		/* Rx ring index */
+	struct enet_cb	*cbs;		/* Rx ring buffer control block */
+	unsigned int	size;		/* Rx ring size */
+	unsigned int	c_index;	/* Rx last consumer index */
+	unsigned int	read_ptr;	/* Rx ring read pointer */
+	unsigned int	cb_ptr;		/* Rx ring initial CB ptr */
+	unsigned int	end_ptr;	/* Rx ring end CB ptr */
+};
+
 /* device context */
 struct bcmgenet_priv {
 	void __iomem *base;
@@ -560,13 +570,11 @@ struct bcmgenet_priv {
 
 	/* receive variables */
 	void __iomem *rx_bds;
-	void __iomem *rx_bd_assign_ptr;
-	int rx_bd_assign_index;
 	struct enet_cb *rx_cbs;
 	unsigned int num_rx_bds;
 	unsigned int rx_buf_len;
-	unsigned int rx_read_ptr;
-	unsigned int rx_c_index;
+
+	struct bcmgenet_rx_ring rx_rings[DESC_INDEX + 1];
 
 	/* other misc variables */
 	struct bcmgenet_hw_params *hw_params;
-- 
2.2.0.rc0.207.ga3a616c
