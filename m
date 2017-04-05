From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 2/4 v2 net-next] net: stmmac: adding multiple buffers for RX
Date: Wed,  5 Apr 2017 17:43:02 +0100
Message-ID: <4249aacde3ed33071c3c7af0e93eb0ac06806441.1491409859.git.jpinto@synopsys.com>
References: <cover.1491409859.git.jpinto@synopsys.com>
Cc: netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net, clabbe.montjoie@gmail.com, treding@nvidia.com,
        niklas.cassel@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:43710 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755812AbdDEQna (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 12:43:30 -0400
In-Reply-To: <cover.1491409859.git.jpinto@synopsys.com>
In-Reply-To: <cover.1491409859.git.jpinto@synopsys.com>
References: <cover.1491409859.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the structure stmmac_rx_queue which contains
rx queues specific data (previously in stmmac_priv).

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- %d replaced by %u when printing unsigned
- err_init_rx_buffers treatment fixed

 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |   7 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  26 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 454 ++++++++++++++--------
 3 files changed, 303 insertions(+), 184 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 01a8c02..8db5a80 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -136,15 +136,16 @@ static void stmmac_init_dma_chain(void *des, dma_addr_t phy_addr,
 
 static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
 {
-	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
+	struct stmmac_rx_queue *rx_q = (struct stmmac_rx_queue *)priv_ptr;
+	struct stmmac_priv *priv = rx_q->priv_data;
 
 	if (priv->hwts_rx_en && !priv->extend_desc)
 		/* NOTE: Device will overwrite des3 with timestamp value if
 		 * 1588-2002 time stamping is enabled, hence reinitialize it
 		 * to keep explicit chaining in the descriptor.
 		 */
-		p->des3 = cpu_to_le32((unsigned int)(priv->dma_rx_phy +
-				      (((priv->dirty_rx) + 1) %
+		p->des3 = cpu_to_le32((unsigned int)(rx_q->dma_rx_phy +
+				      (((rx_q->dirty_rx) + 1) %
 				       DMA_RX_SIZE) *
 				      sizeof(struct dma_desc)));
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index cd8fb61..c7ad9e4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -46,6 +46,20 @@ struct stmmac_tx_info {
 	bool is_jumbo;
 };
 
+struct stmmac_rx_queue {
+	u32 queue_index;
+	struct stmmac_priv *priv_data;
+	struct dma_extended_desc *dma_erx;
+	struct dma_desc *dma_rx ____cacheline_aligned_in_smp;
+	struct sk_buff **rx_skbuff;
+	dma_addr_t *rx_skbuff_dma;
+	unsigned int cur_rx;
+	unsigned int dirty_rx;
+	u32 rx_zeroc_thresh;
+	dma_addr_t dma_rx_phy;
+	u32 rx_tail_addr;
+};
+
 struct stmmac_priv {
 	/* Frequently used values are kept adjacent for cache effect */
 	struct dma_extended_desc *dma_etx ____cacheline_aligned_in_smp;
@@ -64,18 +78,10 @@ struct stmmac_priv {
 	struct timer_list txtimer;
 	bool tso;
 
-	struct dma_desc *dma_rx	____cacheline_aligned_in_smp;
-	struct dma_extended_desc *dma_erx;
-	struct sk_buff **rx_skbuff;
-	unsigned int cur_rx;
-	unsigned int dirty_rx;
 	unsigned int dma_buf_sz;
 	unsigned int rx_copybreak;
-	unsigned int rx_zeroc_thresh;
 	u32 rx_riwt;
 	int hwts_rx_en;
-	dma_addr_t *rx_skbuff_dma;
-	dma_addr_t dma_rx_phy;
 
 	struct napi_struct napi ____cacheline_aligned_in_smp;
 
@@ -85,6 +91,9 @@ struct stmmac_priv {
 	struct mac_device_info *hw;
 	spinlock_t lock;
 
+	/* RX Queue */
+	struct stmmac_rx_queue rx_queue[MTL_MAX_RX_QUEUES];
+
 	int oldlink;
 	int speed;
 	int oldduplex;
@@ -119,7 +128,6 @@ struct stmmac_priv {
 	spinlock_t ptp_lock;
 	void __iomem *mmcaddr;
 	void __iomem *ptpaddr;
-	u32 rx_tail_addr;
 	u32 tx_tail_addr;
 	u32 mss;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ff839e1..5892796 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -197,14 +197,20 @@ static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 	return avail;
 }
 
-static inline u32 stmmac_rx_dirty(struct stmmac_priv *priv)
+/**
+ * stmmac_rx_dirty - Get RX queue dirty
+ * @priv: driver private structure
+ * @queue: RX queue index
+ */
+static inline u32 stmmac_rx_dirty(struct stmmac_priv *priv, u32 queue)
 {
+	struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
 	u32 dirty;
 
-	if (priv->dirty_rx <= priv->cur_rx)
-		dirty = priv->cur_rx - priv->dirty_rx;
+	if (rx_q->dirty_rx <= rx_q->cur_rx)
+		dirty = rx_q->cur_rx - rx_q->dirty_rx;
 	else
-		dirty = DMA_RX_SIZE - priv->dirty_rx + priv->cur_rx;
+		dirty = DMA_RX_SIZE - rx_q->dirty_rx + rx_q->cur_rx;
 
 	return dirty;
 }
@@ -891,15 +897,24 @@ static int stmmac_init_phy(struct net_device *dev)
 
 static void stmmac_display_rx_rings(struct stmmac_priv *priv)
 {
+	u32 rx_cnt = priv->plat->rx_queues_to_use;
 	void *head_rx;
+	u32 queue;
 
-	if (priv->extend_desc)
-		head_rx = (void *)priv->dma_erx;
-	else
-		head_rx = (void *)priv->dma_rx;
+	/* Display RX rings */
+	for (queue = 0; queue < rx_cnt; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
 
-	/* Display RX ring */
-	priv->hw->desc->display_ring(head_rx, DMA_RX_SIZE, true);
+		pr_info("\tRX Queue %u rings\n", queue);
+
+		if (priv->extend_desc)
+			head_rx = (void *)rx_q->dma_erx;
+		else
+			head_rx = (void *)rx_q->dma_rx;
+
+		/* Display RX ring */
+		priv->hw->desc->display_ring(head_rx, DMA_RX_SIZE, true);
+	}
 }
 
 static void stmmac_display_tx_rings(struct stmmac_priv *priv)
@@ -943,21 +958,23 @@ static int stmmac_set_bfsize(int mtu, int bufsize)
 /**
  * stmmac_clear_rx_descriptors - clear RX descriptors
  * @priv: driver private structure
+ * @queue: RX queue index
  * Description: this function is called to clear the RX descriptors
  * in case of both basic and extended descriptors are used.
  */
-static void stmmac_clear_rx_descriptors(struct stmmac_priv *priv)
+static void stmmac_clear_rx_descriptors(struct stmmac_priv *priv, u32 queue)
 {
+	struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
 	int i;
 
 	/* Clear the RX descriptors */
 	for (i = 0; i < DMA_RX_SIZE; i++)
 		if (priv->extend_desc)
-			priv->hw->desc->init_rx_desc(&priv->dma_erx[i].basic,
+			priv->hw->desc->init_rx_desc(&rx_q->dma_erx[i].basic,
 						     priv->use_riwt, priv->mode,
 						     (i == DMA_RX_SIZE - 1));
 		else
-			priv->hw->desc->init_rx_desc(&priv->dma_rx[i],
+			priv->hw->desc->init_rx_desc(&rx_q->dma_rx[i],
 						     priv->use_riwt, priv->mode,
 						     (i == DMA_RX_SIZE - 1));
 }
@@ -992,8 +1009,12 @@ static void stmmac_clear_tx_descriptors(struct stmmac_priv *priv)
  */
 static void stmmac_clear_descriptors(struct stmmac_priv *priv)
 {
+	u32 rx_queue_cnt = priv->plat->rx_queues_to_use;
+	u32 queue;
+
 	/* Clear the RX descriptors */
-	stmmac_clear_rx_descriptors(priv);
+	for (queue = 0; queue < rx_queue_cnt; queue++)
+		stmmac_clear_rx_descriptors(priv, queue);
 
 	/* Clear the TX descriptors */
 	stmmac_clear_tx_descriptors(priv);
@@ -1004,13 +1025,15 @@ static void stmmac_clear_descriptors(struct stmmac_priv *priv)
  * @priv: driver private structure
  * @p: descriptor pointer
  * @i: descriptor index
- * @flags: gfp flag.
+ * @flags: gfp flag
+ * @queue: RX queue index
  * Description: this function is called to allocate a receive buffer, perform
  * the DMA mapping and init the descriptor.
  */
 static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
-				  int i, gfp_t flags)
+				  int i, gfp_t flags, u32 queue)
 {
+	struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
 	struct sk_buff *skb;
 
 	skb = __netdev_alloc_skb_ip_align(priv->dev, priv->dma_buf_sz, flags);
@@ -1019,20 +1042,20 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 			   "%s: Rx init fails; skb is NULL\n", __func__);
 		return -ENOMEM;
 	}
-	priv->rx_skbuff[i] = skb;
-	priv->rx_skbuff_dma[i] = dma_map_single(priv->device, skb->data,
+	rx_q->rx_skbuff[i] = skb;
+	rx_q->rx_skbuff_dma[i] = dma_map_single(priv->device, skb->data,
 						priv->dma_buf_sz,
 						DMA_FROM_DEVICE);
-	if (dma_mapping_error(priv->device, priv->rx_skbuff_dma[i])) {
+	if (dma_mapping_error(priv->device, rx_q->rx_skbuff_dma[i])) {
 		netdev_err(priv->dev, "%s: DMA mapping error\n", __func__);
 		dev_kfree_skb_any(skb);
 		return -EINVAL;
 	}
 
 	if (priv->synopsys_id >= DWMAC_CORE_4_00)
-		p->des0 = cpu_to_le32(priv->rx_skbuff_dma[i]);
+		p->des0 = cpu_to_le32(rx_q->rx_skbuff_dma[i]);
 	else
-		p->des2 = cpu_to_le32(priv->rx_skbuff_dma[i]);
+		p->des2 = cpu_to_le32(rx_q->rx_skbuff_dma[i]);
 
 	if ((priv->hw->mode->init_desc3) &&
 	    (priv->dma_buf_sz == BUF_SIZE_16KiB))
@@ -1044,16 +1067,19 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 /**
  * stmmac_free_rx_buffer - free RX dma buffers
  * @priv: private structure
+ * @queue: RX queue index
  * @i: buffer index.
  */
-static void stmmac_free_rx_buffer(struct stmmac_priv *priv, int i)
+static void stmmac_free_rx_buffer(struct stmmac_priv *priv, u32 queue, int i)
 {
-	if (priv->rx_skbuff[i]) {
-		dma_unmap_single(priv->device, priv->rx_skbuff_dma[i],
+	struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+	if (rx_q->rx_skbuff[i]) {
+		dma_unmap_single(priv->device, rx_q->rx_skbuff_dma[i],
 				 priv->dma_buf_sz, DMA_FROM_DEVICE);
-		dev_kfree_skb_any(priv->rx_skbuff[i]);
+		dev_kfree_skb_any(rx_q->rx_skbuff[i]);
 	}
-	priv->rx_skbuff[i] = NULL;
+	rx_q->rx_skbuff[i] = NULL;
 }
 
 /**
@@ -1094,10 +1120,12 @@ static void stmmac_free_tx_buffer(struct stmmac_priv *priv, int i)
  */
 static int init_dma_rx_desc_rings(struct net_device *dev, gfp_t flags)
 {
-	int i;
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 rx_count = priv->plat->rx_queues_to_use;
 	unsigned int bfsize = 0;
 	int ret = -ENOMEM;
+	u32 queue;
+	int i;
 
 	if (priv->hw->mode->set_16kib_bfsize)
 		bfsize = priv->hw->mode->set_16kib_bfsize(dev->mtu);
@@ -1107,45 +1135,66 @@ static int init_dma_rx_desc_rings(struct net_device *dev, gfp_t flags)
 
 	priv->dma_buf_sz = bfsize;
 
-	netif_dbg(priv, probe, priv->dev,
-		  "(%s) dma_rx_phy=0x%08x\n", __func__, (u32)priv->dma_rx_phy);
-
+	/* RX INITIALIZATION */
 	netif_dbg(priv, probe, priv->dev,
 		  "SKB addresses:\nskb\t\tskb data\tdma data\n");
 
-	for (i = 0; i < DMA_RX_SIZE; i++) {
-		struct dma_desc *p;
-		if (priv->extend_desc)
-			p = &((priv->dma_erx + i)->basic);
-		else
-			p = priv->dma_rx + i;
+	for (queue = 0; queue < rx_count; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
 
-		ret = stmmac_init_rx_buffers(priv, p, i, flags);
-		if (ret)
-			goto err_init_rx_buffers;
+		netif_dbg(priv, probe, priv->dev,
+			  "(%s) dma_rx_phy=0x%08x\n", __func__,
+			  (u32)rx_q->dma_rx_phy);
 
-		netif_dbg(priv, probe, priv->dev, "[%p]\t[%p]\t[%x]\n",
-			  priv->rx_skbuff[i], priv->rx_skbuff[i]->data,
-			  (unsigned int)priv->rx_skbuff_dma[i]);
-	}
-	priv->cur_rx = 0;
-	priv->dirty_rx = (unsigned int)(i - DMA_RX_SIZE);
-	buf_sz = bfsize;
+		for (i = 0; i < DMA_RX_SIZE; i++) {
+			struct dma_desc *p;
 
-	/* Setup the chained descriptor addresses */
-	if (priv->mode == STMMAC_CHAIN_MODE) {
-		if (priv->extend_desc)
-			priv->hw->mode->init(priv->dma_erx, priv->dma_rx_phy,
-					     DMA_RX_SIZE, 1);
-		else
-			priv->hw->mode->init(priv->dma_rx, priv->dma_rx_phy,
-					     DMA_RX_SIZE, 0);
+			if (priv->extend_desc)
+				p = &((rx_q->dma_erx + i)->basic);
+			else
+				p = rx_q->dma_rx + i;
+
+			ret = stmmac_init_rx_buffers(priv, p, i, flags,
+						     queue);
+			if (ret)
+				goto err_init_rx_buffers;
+
+			netif_dbg(priv, probe, priv->dev, "[%p]\t[%p]\t[%x]\n",
+				  rx_q->rx_skbuff[i], rx_q->rx_skbuff[i]->data,
+				  (unsigned int)rx_q->rx_skbuff_dma[i]);
+		}
+
+		rx_q->cur_rx = 0;
+		rx_q->dirty_rx = (unsigned int)(i - DMA_RX_SIZE);
+
+		stmmac_clear_rx_descriptors(priv, queue);
+
+		/* Setup the chained descriptor addresses */
+		if (priv->mode == STMMAC_CHAIN_MODE) {
+			if (priv->extend_desc)
+				priv->hw->mode->init(rx_q->dma_erx,
+						     rx_q->dma_rx_phy,
+						     DMA_RX_SIZE, 1);
+			else
+				priv->hw->mode->init(rx_q->dma_rx,
+						     rx_q->dma_rx_phy,
+						     DMA_RX_SIZE, 0);
+		}
 	}
 
+	buf_sz = bfsize;
+
 	return 0;
+
 err_init_rx_buffers:
-	while (--i >= 0)
-		stmmac_free_rx_buffer(priv, i);
+	while (queue >= 0) {
+		while (--i >= 0)
+			stmmac_free_rx_buffer(priv, queue, i);
+
+		i = DMA_RX_SIZE;
+		queue--;
+	}
+
 	return ret;
 }
 
@@ -1234,13 +1283,14 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 /**
  * dma_free_rx_skbufs - free RX dma buffers
  * @priv: private structure
+ * @queue: RX queue index
  */
-static void dma_free_rx_skbufs(struct stmmac_priv *priv)
+static void dma_free_rx_skbufs(struct stmmac_priv *priv, u32 queue)
 {
 	int i;
 
 	for (i = 0; i < DMA_RX_SIZE; i++)
-		stmmac_free_rx_buffer(priv, i);
+		stmmac_free_rx_buffer(priv, queue, i);
 }
 
 /**
@@ -1256,6 +1306,37 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 }
 
 /**
+ * free_dma_rx_desc_resources - free RX dma desc resources
+ * @priv: private structure
+ */
+static void free_dma_rx_desc_resources(struct stmmac_priv *priv)
+{
+	u32 rx_count = priv->plat->rx_queues_to_use;
+	u32 queue;
+
+	/* Free RX queue resources */
+	for (queue = 0; queue < rx_count; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		/* Release the DMA RX socket buffers */
+		dma_free_rx_skbufs(priv, queue);
+
+		/* Free DMA regions of consistent memory previously allocated */
+		if (!priv->extend_desc)
+			dma_free_coherent(priv->device,
+					  DMA_RX_SIZE * sizeof(struct dma_desc),
+					  rx_q->dma_rx, rx_q->dma_rx_phy);
+		else
+			dma_free_coherent(priv->device, DMA_RX_SIZE *
+					  sizeof(struct dma_extended_desc),
+					  rx_q->dma_erx, rx_q->dma_rx_phy);
+
+		kfree(rx_q->rx_skbuff_dma);
+		kfree(rx_q->rx_skbuff);
+	}
+}
+
+/**
  * alloc_dma_rx_desc_resources - alloc RX resources.
  * @priv: private structure
  * Description: according to which descriptor can be used (extend or basic)
@@ -1265,42 +1346,56 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
  */
 static int alloc_dma_rx_desc_resources(struct stmmac_priv *priv)
 {
+	u32 rx_count = priv->plat->rx_queues_to_use;
 	int ret = -ENOMEM;
+	u32 queue;
 
-	priv->rx_skbuff_dma = kmalloc_array(DMA_RX_SIZE, sizeof(dma_addr_t),
-					    GFP_KERNEL);
-	if (!priv->rx_skbuff_dma)
-		return -ENOMEM;
+	/* RX queues buffers and DMA */
+	for (queue = 0; queue < rx_count; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
 
-	priv->rx_skbuff = kmalloc_array(DMA_RX_SIZE, sizeof(struct sk_buff *),
-					GFP_KERNEL);
-	if (!priv->rx_skbuff)
-		goto err_rx_skbuff;
+		rx_q->queue_index = queue;
+		rx_q->priv_data = priv;
 
-	if (priv->extend_desc) {
-		priv->dma_erx = dma_zalloc_coherent(priv->device, DMA_RX_SIZE *
-						    sizeof(struct
-							   dma_extended_desc),
-						    &priv->dma_rx_phy,
+		rx_q->rx_skbuff_dma = kmalloc_array(DMA_RX_SIZE,
+						    sizeof(dma_addr_t),
 						    GFP_KERNEL);
-		if (!priv->dma_erx)
-			goto err_dma;
+		if (!rx_q->rx_skbuff_dma)
+			return -ENOMEM;
 
-	} else {
-		priv->dma_rx = dma_zalloc_coherent(priv->device, DMA_RX_SIZE *
-						   sizeof(struct dma_desc),
-						   &priv->dma_rx_phy,
-						   GFP_KERNEL);
-		if (!priv->dma_rx)
+		rx_q->rx_skbuff = kmalloc_array(DMA_RX_SIZE,
+						sizeof(struct sk_buff *),
+						GFP_KERNEL);
+		if (!rx_q->rx_skbuff)
 			goto err_dma;
+
+		if (priv->extend_desc) {
+			rx_q->dma_erx = dma_zalloc_coherent(priv->device,
+							    DMA_RX_SIZE *
+							    sizeof(struct
+							    dma_extended_desc),
+							    &rx_q->dma_rx_phy,
+							    GFP_KERNEL);
+			if (!rx_q->dma_erx)
+				goto err_dma;
+
+		} else {
+			rx_q->dma_rx = dma_zalloc_coherent(priv->device,
+							   DMA_RX_SIZE *
+							   sizeof(struct
+							   dma_desc),
+							   &rx_q->dma_rx_phy,
+							   GFP_KERNEL);
+			if (!rx_q->dma_rx)
+				goto err_dma;
+		}
 	}
 
 	return 0;
 
 err_dma:
-	kfree(priv->rx_skbuff);
-err_rx_skbuff:
-	kfree(priv->rx_skbuff_dma);
+	free_dma_rx_desc_resources(priv);
+
 	return ret;
 }
 
@@ -1333,23 +1428,15 @@ static int alloc_dma_tx_desc_resources(struct stmmac_priv *priv)
 							   dma_extended_desc),
 						    &priv->dma_tx_phy,
 						    GFP_KERNEL);
-		if (!priv->dma_etx) {
-			dma_free_coherent(priv->device, DMA_RX_SIZE *
-					  sizeof(struct dma_extended_desc),
-					  priv->dma_erx, priv->dma_rx_phy);
+		if (!priv->dma_etx)
 			goto err_dma;
-		}
 	} else {
 		priv->dma_tx = dma_zalloc_coherent(priv->device, DMA_TX_SIZE *
 						   sizeof(struct dma_desc),
 						   &priv->dma_tx_phy,
 						   GFP_KERNEL);
-		if (!priv->dma_tx) {
-			dma_free_coherent(priv->device, DMA_RX_SIZE *
-					  sizeof(struct dma_desc),
-					  priv->dma_rx, priv->dma_rx_phy);
+		if (!priv->dma_tx)
 			goto err_dma;
-		}
 	}
 
 	return 0;
@@ -1371,6 +1458,7 @@ static int alloc_dma_tx_desc_resources(struct stmmac_priv *priv)
  */
 static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 {
+	/* RX Allocation */
 	int ret = alloc_dma_rx_desc_resources(priv);
 
 	if (ret)
@@ -1382,29 +1470,6 @@ static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 }
 
 /**
- * free_dma_rx_desc_resources - free RX dma desc resources
- * @priv: private structure
- */
-static void free_dma_rx_desc_resources(struct stmmac_priv *priv)
-{
-	/* Release the DMA RX socket buffers */
-	dma_free_rx_skbufs(priv);
-
-	/* Free DMA regions of consistent memory previously allocated */
-	if (!priv->extend_desc)
-		dma_free_coherent(priv->device,
-				  DMA_RX_SIZE * sizeof(struct dma_desc),
-				  priv->dma_rx, priv->dma_rx_phy);
-	else
-		dma_free_coherent(priv->device, DMA_RX_SIZE *
-				  sizeof(struct dma_extended_desc),
-				  priv->dma_erx, priv->dma_rx_phy);
-
-	kfree(priv->rx_skbuff_dma);
-	kfree(priv->rx_skbuff);
-}
-
-/**
  * free_dma_tx_desc_resources - free TX dma desc resources
  * @priv: private structure
  */
@@ -1914,6 +1979,7 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 {
 	u32 rx_channels_count = priv->plat->rx_queues_to_use;
 	u32 tx_channels_count = priv->plat->tx_queues_to_use;
+	struct stmmac_rx_queue *rx_q;
 	u32 dummy_dma_rx_phy = 0;
 	u32 dummy_dma_tx_phy = 0;
 	u32 chan = 0;
@@ -1941,14 +2007,16 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 
 		/* DMA RX Channel Configuration */
 		for (chan = 0; chan < rx_channels_count; chan++) {
+			rx_q = &priv->rx_queue[chan];
+
 			priv->hw->dma->init_rx_chan(priv->ioaddr,
 						    priv->plat->dma_cfg,
-						    priv->dma_rx_phy, chan);
+						    rx_q->dma_rx_phy, chan);
 
-			priv->rx_tail_addr = priv->dma_rx_phy +
+			rx_q->rx_tail_addr = rx_q->dma_rx_phy +
 				    (DMA_RX_SIZE * sizeof(struct dma_desc));
 			priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
-						       priv->rx_tail_addr,
+						       rx_q->rx_tail_addr,
 						       chan);
 		}
 
@@ -1969,8 +2037,9 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 						       chan);
 		}
 	} else {
+		rx_q = &priv->rx_queue[chan];
 		priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
-				    priv->dma_tx_phy, priv->dma_rx_phy, atds);
+				    priv->dma_tx_phy, rx_q->dma_rx_phy, atds);
 	}
 
 	if (priv->plat->axi && priv->hw->dma->axi)
@@ -2942,9 +3011,9 @@ static void stmmac_rx_vlan(struct net_device *dev, struct sk_buff *skb)
 }
 
 
-static inline int stmmac_rx_threshold_count(struct stmmac_priv *priv)
+static inline int stmmac_rx_threshold_count(struct stmmac_rx_queue *rx_q)
 {
-	if (priv->rx_zeroc_thresh < STMMAC_RX_THRESH)
+	if (rx_q->rx_zeroc_thresh < STMMAC_RX_THRESH)
 		return 0;
 
 	return 1;
@@ -2953,30 +3022,33 @@ static inline int stmmac_rx_threshold_count(struct stmmac_priv *priv)
 /**
  * stmmac_rx_refill - refill used skb preallocated buffers
  * @priv: driver private structure
+ * @queue: RX queue index
  * Description : this is to reallocate the skb for the reception process
  * that is based on zero-copy.
  */
-static inline void stmmac_rx_refill(struct stmmac_priv *priv)
+static inline void stmmac_rx_refill(struct stmmac_priv *priv, u32 queue)
 {
+	struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+	int dirty = stmmac_rx_dirty(priv, queue);
+	unsigned int entry = rx_q->dirty_rx;
+
 	int bfsize = priv->dma_buf_sz;
-	unsigned int entry = priv->dirty_rx;
-	int dirty = stmmac_rx_dirty(priv);
 
 	while (dirty-- > 0) {
 		struct dma_desc *p;
 
 		if (priv->extend_desc)
-			p = (struct dma_desc *)(priv->dma_erx + entry);
+			p = (struct dma_desc *)(rx_q->dma_erx + entry);
 		else
-			p = priv->dma_rx + entry;
+			p = rx_q->dma_rx + entry;
 
-		if (likely(priv->rx_skbuff[entry] == NULL)) {
+		if (likely(!rx_q->rx_skbuff[entry])) {
 			struct sk_buff *skb;
 
 			skb = netdev_alloc_skb_ip_align(priv->dev, bfsize);
 			if (unlikely(!skb)) {
 				/* so for a while no zero-copy! */
-				priv->rx_zeroc_thresh = STMMAC_RX_THRESH;
+				rx_q->rx_zeroc_thresh = STMMAC_RX_THRESH;
 				if (unlikely(net_ratelimit()))
 					dev_err(priv->device,
 						"fail to alloc skb entry %d\n",
@@ -2984,28 +3056,28 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 				break;
 			}
 
-			priv->rx_skbuff[entry] = skb;
-			priv->rx_skbuff_dma[entry] =
+			rx_q->rx_skbuff[entry] = skb;
+			rx_q->rx_skbuff_dma[entry] =
 			    dma_map_single(priv->device, skb->data, bfsize,
 					   DMA_FROM_DEVICE);
 			if (dma_mapping_error(priv->device,
-					      priv->rx_skbuff_dma[entry])) {
+					      rx_q->rx_skbuff_dma[entry])) {
 				netdev_err(priv->dev, "Rx DMA map failed\n");
 				dev_kfree_skb(skb);
 				break;
 			}
 
 			if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00)) {
-				p->des0 = cpu_to_le32(priv->rx_skbuff_dma[entry]);
+				p->des0 = cpu_to_le32(rx_q->rx_skbuff_dma[entry]);
 				p->des1 = 0;
 			} else {
-				p->des2 = cpu_to_le32(priv->rx_skbuff_dma[entry]);
+				p->des2 = cpu_to_le32(rx_q->rx_skbuff_dma[entry]);
 			}
 			if (priv->hw->mode->refill_desc3)
-				priv->hw->mode->refill_desc3(priv, p);
+				priv->hw->mode->refill_desc3(rx_q, p);
 
-			if (priv->rx_zeroc_thresh > 0)
-				priv->rx_zeroc_thresh--;
+			if (rx_q->rx_zeroc_thresh > 0)
+				rx_q->rx_zeroc_thresh--;
 
 			netif_dbg(priv, rx_status, priv->dev,
 				  "refill entry #%d\n", entry);
@@ -3021,31 +3093,33 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 
 		entry = STMMAC_GET_ENTRY(entry, DMA_RX_SIZE);
 	}
-	priv->dirty_rx = entry;
+	rx_q->dirty_rx = entry;
 }
 
 /**
  * stmmac_rx - manage the receive process
  * @priv: driver private structure
- * @limit: napi bugget.
+ * @limit: napi bugget
+ * @queue: RX queue index.
  * Description :  this the function called by the napi poll method.
  * It gets all the frames inside the ring.
  */
-static int stmmac_rx(struct stmmac_priv *priv, int limit)
+static int stmmac_rx(struct stmmac_priv *priv, int limit, u32 queue)
 {
-	unsigned int entry = priv->cur_rx;
+	struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+	unsigned int entry = rx_q->cur_rx;
+	int coe = priv->hw->rx_csum;
 	unsigned int next_entry;
 	unsigned int count = 0;
-	int coe = priv->hw->rx_csum;
 
 	if (netif_msg_rx_status(priv)) {
 		void *rx_head;
 
 		netdev_dbg(priv->dev, "%s: descriptor ring:\n", __func__);
 		if (priv->extend_desc)
-			rx_head = (void *)priv->dma_erx;
+			rx_head = (void *)rx_q->dma_erx;
 		else
-			rx_head = (void *)priv->dma_rx;
+			rx_head = (void *)rx_q->dma_rx;
 
 		priv->hw->desc->display_ring(rx_head, DMA_RX_SIZE, true);
 	}
@@ -3055,9 +3129,9 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		struct dma_desc *np;
 
 		if (priv->extend_desc)
-			p = (struct dma_desc *)(priv->dma_erx + entry);
+			p = (struct dma_desc *)(rx_q->dma_erx + entry);
 		else
-			p = priv->dma_rx + entry;
+			p = rx_q->dma_rx + entry;
 
 		/* read the status of the incoming frame */
 		status = priv->hw->desc->rx_status(&priv->dev->stats,
@@ -3068,20 +3142,20 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
 		count++;
 
-		priv->cur_rx = STMMAC_GET_ENTRY(priv->cur_rx, DMA_RX_SIZE);
-		next_entry = priv->cur_rx;
+		rx_q->cur_rx = STMMAC_GET_ENTRY(rx_q->cur_rx, DMA_RX_SIZE);
+		next_entry = rx_q->cur_rx;
 
 		if (priv->extend_desc)
-			np = (struct dma_desc *)(priv->dma_erx + next_entry);
+			np = (struct dma_desc *)(rx_q->dma_erx + next_entry);
 		else
-			np = priv->dma_rx + next_entry;
+			np = rx_q->dma_rx + next_entry;
 
 		prefetch(np);
 
 		if ((priv->extend_desc) && (priv->hw->desc->rx_extended_status))
 			priv->hw->desc->rx_extended_status(&priv->dev->stats,
 							   &priv->xstats,
-							   priv->dma_erx +
+							   rx_q->dma_erx +
 							   entry);
 		if (unlikely(status == discard_frame)) {
 			priv->dev->stats.rx_errors++;
@@ -3091,9 +3165,9 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 				 * them in stmmac_rx_refill() function so that
 				 * device can reuse it.
 				 */
-				priv->rx_skbuff[entry] = NULL;
+				rx_q->rx_skbuff[entry] = NULL;
 				dma_unmap_single(priv->device,
-						 priv->rx_skbuff_dma[entry],
+						 rx_q->rx_skbuff_dma[entry],
 						 priv->dma_buf_sz,
 						 DMA_FROM_DEVICE);
 			}
@@ -3141,7 +3215,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 			 */
 			if (unlikely(!priv->plat->has_gmac4 &&
 				     ((frame_len < priv->rx_copybreak) ||
-				     stmmac_rx_threshold_count(priv)))) {
+				     stmmac_rx_threshold_count(rx_q)))) {
 				skb = netdev_alloc_skb_ip_align(priv->dev,
 								frame_len);
 				if (unlikely(!skb)) {
@@ -3153,21 +3227,21 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 				}
 
 				dma_sync_single_for_cpu(priv->device,
-							priv->rx_skbuff_dma
+							rx_q->rx_skbuff_dma
 							[entry], frame_len,
 							DMA_FROM_DEVICE);
 				skb_copy_to_linear_data(skb,
-							priv->
+							rx_q->
 							rx_skbuff[entry]->data,
 							frame_len);
 
 				skb_put(skb, frame_len);
 				dma_sync_single_for_device(priv->device,
-							   priv->rx_skbuff_dma
+							   rx_q->rx_skbuff_dma
 							   [entry], frame_len,
 							   DMA_FROM_DEVICE);
 			} else {
-				skb = priv->rx_skbuff[entry];
+				skb = rx_q->rx_skbuff[entry];
 				if (unlikely(!skb)) {
 					netdev_err(priv->dev,
 						   "%s: Inconsistent Rx chain\n",
@@ -3176,12 +3250,12 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 					break;
 				}
 				prefetch(skb->data - NET_IP_ALIGN);
-				priv->rx_skbuff[entry] = NULL;
-				priv->rx_zeroc_thresh++;
+				rx_q->rx_skbuff[entry] = NULL;
+				rx_q->rx_zeroc_thresh++;
 
 				skb_put(skb, frame_len);
 				dma_unmap_single(priv->device,
-						 priv->rx_skbuff_dma[entry],
+						 rx_q->rx_skbuff_dma[entry],
 						 priv->dma_buf_sz,
 						 DMA_FROM_DEVICE);
 			}
@@ -3211,7 +3285,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		entry = next_entry;
 	}
 
-	stmmac_rx_refill(priv);
+	stmmac_rx_refill(priv, queue);
 
 	priv->xstats.rx_pkt_n += count;
 
@@ -3229,13 +3303,14 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 static int stmmac_poll(struct napi_struct *napi, int budget)
 {
 	struct stmmac_priv *priv = container_of(napi, struct stmmac_priv, napi);
-	int work_done = 0;
 	u32 chan = STMMAC_CHAN0;
+	int work_done = 0;
+	u32 queue = chan;
 
 	priv->xstats.napi_poll++;
 	stmmac_tx_clean(priv);
 
-	work_done = stmmac_rx(priv, budget);
+	work_done = stmmac_rx(priv, budget, queue);
 	if (work_done < budget) {
 		napi_complete_done(napi, work_done);
 		stmmac_enable_dma_irq(priv, chan);
@@ -3396,6 +3471,9 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 
 		if (priv->synopsys_id >= DWMAC_CORE_4_00) {
 			for (queue = 0; queue < queues_count; queue++) {
+				struct stmmac_rx_queue *rx_q =
+				&priv->rx_queue[queue];
+
 				status |=
 				priv->hw->mac->host_mtl_irq_status(priv->hw,
 								   queue);
@@ -3403,7 +3481,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 				if (status & CORE_IRQ_MTL_RX_OVERFLOW &&
 				    priv->hw->dma->set_rx_tail_ptr)
 					priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
-								priv->rx_tail_addr,
+								rx_q->rx_tail_addr,
 								queue);
 			}
 		}
@@ -3503,15 +3581,29 @@ static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
 {
 	struct net_device *dev = seq->private;
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 rx_count = priv->plat->rx_queues_to_use;
+	u32 queue;
+
+	for (queue = 0; queue < rx_count; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		seq_printf(seq, "RX Queue %d:\n", queue);
+
+		if (priv->extend_desc) {
+			seq_printf(seq, "Extended descriptor ring:\n");
+			sysfs_display_ring((void *)rx_q->dma_erx,
+					   DMA_RX_SIZE, 1, seq);
+		} else {
+			seq_printf(seq, "Descriptor ring:\n");
+			sysfs_display_ring((void *)rx_q->dma_rx,
+					   DMA_RX_SIZE, 0, seq);
+		}
+	}
 
 	if (priv->extend_desc) {
-		seq_printf(seq, "Extended RX descriptor ring:\n");
-		sysfs_display_ring((void *)priv->dma_erx, DMA_RX_SIZE, 1, seq);
 		seq_printf(seq, "Extended TX descriptor ring:\n");
 		sysfs_display_ring((void *)priv->dma_etx, DMA_TX_SIZE, 1, seq);
 	} else {
-		seq_printf(seq, "RX descriptor ring:\n");
-		sysfs_display_ring((void *)priv->dma_rx, DMA_RX_SIZE, 0, seq);
 		seq_printf(seq, "TX descriptor ring:\n");
 		sysfs_display_ring((void *)priv->dma_tx, DMA_TX_SIZE, 0, seq);
 	}
@@ -4026,6 +4118,26 @@ int stmmac_suspend(struct device *dev)
 EXPORT_SYMBOL_GPL(stmmac_suspend);
 
 /**
+ * stmmac_reset_queues_param - reset queue parameters
+ * @dev: device pointer
+ */
+static void stmmac_reset_queues_param(struct stmmac_priv *priv)
+{
+	u32 rx_cnt = priv->plat->rx_queues_to_use;
+	u32 queue;
+
+	for (queue = 0; queue < rx_cnt; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		rx_q->cur_rx = 0;
+		rx_q->dirty_rx = 0;
+	}
+
+	priv->dirty_tx = 0;
+	priv->cur_tx = 0;
+}
+
+/**
  * stmmac_resume - resume callback
  * @dev: device pointer
  * Description: when resume this function is invoked to setup the DMA and CORE
@@ -4065,10 +4177,8 @@ int stmmac_resume(struct device *dev)
 
 	spin_lock_irqsave(&priv->lock, flags);
 
-	priv->cur_rx = 0;
-	priv->dirty_rx = 0;
-	priv->dirty_tx = 0;
-	priv->cur_tx = 0;
+	stmmac_reset_queues_param(priv);
+
 	/* reset private mss value to force mss context settings at
 	 * next tso xmit (only used for gmac4).
 	 */
-- 
2.9.3
