From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next 1/3] net: stmmac: enable multiple buffers
Date: Thu, 16 Mar 2017 10:56:55 +0000
Message-ID: <1eb1ee4c84f61ff8dbc3f398f2e3f9b0bea3ee30.1489661229.git.jpinto@synopsys.com>
References: <cover.1489661229.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:49764 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751382AbdCPK54 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 06:57:56 -0400
In-Reply-To: <cover.1489661229.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489661229.git.jpinto@synopsys.com>
References: <cover.1489661229.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates 2 new structures (stmmac_tx_queue and stmmac_rx_queue)
in include/linux/stmmac.h, enabling that each RX and TX queue has its
own buffers and data.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |   45 +-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |   46 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   49 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 1306 ++++++++++++++-------
 4 files changed, 973 insertions(+), 473 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
index 01a8c02..37881f8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -26,12 +26,15 @@
 
 static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 {
-	struct stmmac_priv *priv = (struct stmmac_priv *)p;
-	unsigned int entry = priv->cur_tx;
-	struct dma_desc *desc = priv->dma_tx + entry;
+	struct stmmac_tx_queue *tx_q = (struct stmmac_tx_queue *)p;
 	unsigned int nopaged_len = skb_headlen(skb);
+	struct stmmac_priv *priv = tx_q->priv_data;
+	unsigned int entry = tx_q->cur_tx;
 	unsigned int bmax, des2;
 	unsigned int i = 1, len;
+	struct dma_desc *desc;
+
+	desc = tx_q->dma_tx + entry;
 
 	if (priv->plat->enh_desc)
 		bmax = BUF_SIZE_8KiB;
@@ -45,16 +48,16 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 	desc->des2 = cpu_to_le32(des2);
 	if (dma_mapping_error(priv->device, des2))
 		return -1;
-	priv->tx_skbuff_dma[entry].buf = des2;
-	priv->tx_skbuff_dma[entry].len = bmax;
+	tx_q->tx_skbuff_dma[entry].buf = des2;
+	tx_q->tx_skbuff_dma[entry].len = bmax;
 	/* do not close the descriptor and do not set own bit */
 	priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum, STMMAC_CHAIN_MODE,
 					0, false);
 
 	while (len != 0) {
-		priv->tx_skbuff[entry] = NULL;
+		tx_q->tx_skbuff[entry] = NULL;
 		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
-		desc = priv->dma_tx + entry;
+		desc = tx_q->dma_tx + entry;
 
 		if (len > bmax) {
 			des2 = dma_map_single(priv->device,
@@ -63,8 +66,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			desc->des2 = cpu_to_le32(des2);
 			if (dma_mapping_error(priv->device, des2))
 				return -1;
-			priv->tx_skbuff_dma[entry].buf = des2;
-			priv->tx_skbuff_dma[entry].len = bmax;
+			tx_q->tx_skbuff_dma[entry].buf = des2;
+			tx_q->tx_skbuff_dma[entry].len = bmax;
 			priv->hw->desc->prepare_tx_desc(desc, 0, bmax, csum,
 							STMMAC_CHAIN_MODE, 1,
 							false);
@@ -77,8 +80,8 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 			desc->des2 = cpu_to_le32(des2);
 			if (dma_mapping_error(priv->device, des2))
 				return -1;
-			priv->tx_skbuff_dma[entry].buf = des2;
-			priv->tx_skbuff_dma[entry].len = len;
+			tx_q->tx_skbuff_dma[entry].buf = des2;
+			tx_q->tx_skbuff_dma[entry].len = len;
 			/* last descriptor can be set now */
 			priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
 							STMMAC_CHAIN_MODE, 1,
@@ -87,7 +90,7 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		}
 	}
 
-	priv->cur_tx = entry;
+	tx_q->cur_tx = entry;
 
 	return entry;
 }
@@ -136,32 +139,34 @@ static void stmmac_init_dma_chain(void *des, dma_addr_t phy_addr,
 
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
 
 static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 {
-	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
-	unsigned int entry = priv->dirty_tx;
+	struct stmmac_tx_queue *tx_q = (struct stmmac_tx_queue *)priv_ptr;
+	struct stmmac_priv *priv = tx_q->priv_data;
+	unsigned int entry = tx_q->dirty_tx;
 
-	if (priv->tx_skbuff_dma[entry].last_segment && !priv->extend_desc &&
+	if (tx_q->tx_skbuff_dma[entry].last_segment && !priv->extend_desc &&
 	    priv->hwts_tx_en)
 		/* NOTE: Device will overwrite des3 with timestamp value if
 		 * 1588-2002 time stamping is enabled, hence reinitialize it
 		 * to keep explicit chaining in the descriptor.
 		 */
-		p->des3 = cpu_to_le32((unsigned int)((priv->dma_tx_phy +
-				      ((priv->dirty_tx + 1) % DMA_TX_SIZE))
+		p->des3 = cpu_to_le32((unsigned int)((tx_q->dma_tx_phy +
+				      ((tx_q->dirty_tx + 1) % DMA_TX_SIZE))
 				      * sizeof(struct dma_desc)));
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
index 452f256..31213e6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -26,16 +26,17 @@
 
 static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 {
-	struct stmmac_priv *priv = (struct stmmac_priv *)p;
-	unsigned int entry = priv->cur_tx;
-	struct dma_desc *desc;
+	struct stmmac_tx_queue *tx_q = (struct stmmac_tx_queue *)p;
 	unsigned int nopaged_len = skb_headlen(skb);
+	struct stmmac_priv *priv = tx_q->priv_data;
+	unsigned int entry = tx_q->cur_tx;
 	unsigned int bmax, len, des2;
+	struct dma_desc *desc;
 
 	if (priv->extend_desc)
-		desc = (struct dma_desc *)(priv->dma_etx + entry);
+		desc = (struct dma_desc *)(tx_q->dma_etx + entry);
 	else
-		desc = priv->dma_tx + entry;
+		desc = tx_q->dma_tx + entry;
 
 	if (priv->plat->enh_desc)
 		bmax = BUF_SIZE_8KiB;
@@ -52,29 +53,29 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		if (dma_mapping_error(priv->device, des2))
 			return -1;
 
-		priv->tx_skbuff_dma[entry].buf = des2;
-		priv->tx_skbuff_dma[entry].len = bmax;
-		priv->tx_skbuff_dma[entry].is_jumbo = true;
+		tx_q->tx_skbuff_dma[entry].buf = des2;
+		tx_q->tx_skbuff_dma[entry].len = bmax;
+		tx_q->tx_skbuff_dma[entry].is_jumbo = true;
 
 		desc->des3 = cpu_to_le32(des2 + BUF_SIZE_4KiB);
 		priv->hw->desc->prepare_tx_desc(desc, 1, bmax, csum,
 						STMMAC_RING_MODE, 0, false);
-		priv->tx_skbuff[entry] = NULL;
+		tx_q->tx_skbuff[entry] = NULL;
 		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
 
 		if (priv->extend_desc)
-			desc = (struct dma_desc *)(priv->dma_etx + entry);
+			desc = (struct dma_desc *)(tx_q->dma_etx + entry);
 		else
-			desc = priv->dma_tx + entry;
+			desc = tx_q->dma_tx + entry;
 
 		des2 = dma_map_single(priv->device, skb->data + bmax, len,
 				      DMA_TO_DEVICE);
 		desc->des2 = cpu_to_le32(des2);
 		if (dma_mapping_error(priv->device, des2))
 			return -1;
-		priv->tx_skbuff_dma[entry].buf = des2;
-		priv->tx_skbuff_dma[entry].len = len;
-		priv->tx_skbuff_dma[entry].is_jumbo = true;
+		tx_q->tx_skbuff_dma[entry].buf = des2;
+		tx_q->tx_skbuff_dma[entry].len = len;
+		tx_q->tx_skbuff_dma[entry].is_jumbo = true;
 
 		desc->des3 = cpu_to_le32(des2 + BUF_SIZE_4KiB);
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum,
@@ -85,15 +86,15 @@ static int stmmac_jumbo_frm(void *p, struct sk_buff *skb, int csum)
 		desc->des2 = cpu_to_le32(des2);
 		if (dma_mapping_error(priv->device, des2))
 			return -1;
-		priv->tx_skbuff_dma[entry].buf = des2;
-		priv->tx_skbuff_dma[entry].len = nopaged_len;
-		priv->tx_skbuff_dma[entry].is_jumbo = true;
+		tx_q->tx_skbuff_dma[entry].buf = des2;
+		tx_q->tx_skbuff_dma[entry].len = nopaged_len;
+		tx_q->tx_skbuff_dma[entry].is_jumbo = true;
 		desc->des3 = cpu_to_le32(des2 + BUF_SIZE_4KiB);
 		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len, csum,
 						STMMAC_RING_MODE, 0, true);
 	}
 
-	priv->cur_tx = entry;
+	tx_q->cur_tx = entry;
 
 	return entry;
 }
@@ -125,12 +126,13 @@ static void stmmac_init_desc3(struct dma_desc *p)
 
 static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 {
-	struct stmmac_priv *priv = (struct stmmac_priv *)priv_ptr;
-	unsigned int entry = priv->dirty_tx;
+	struct stmmac_tx_queue *tx_q = (struct stmmac_tx_queue *)priv_ptr;
+	struct stmmac_priv *priv = tx_q->priv_data;
+	unsigned int entry = tx_q->dirty_tx;
 
 	/* des3 is only used for jumbo frames tx or time stamping */
-	if (unlikely(priv->tx_skbuff_dma[entry].is_jumbo ||
-		     (priv->tx_skbuff_dma[entry].last_segment &&
+	if (unlikely(tx_q->tx_skbuff_dma[entry].is_jumbo ||
+		     (tx_q->tx_skbuff_dma[entry].last_segment &&
 		      !priv->extend_desc && priv->hwts_tx_en)))
 		p->des3 = 0;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index cd8fb61..6ec671c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -46,6 +46,35 @@ struct stmmac_tx_info {
 	bool is_jumbo;
 };
 
+/* Frequently used values are kept adjacent for cache effect */
+struct stmmac_tx_queue {
+	u32 queue_index;
+	struct stmmac_priv *priv_data;
+	struct dma_extended_desc *dma_etx ____cacheline_aligned_in_smp;
+	struct dma_desc *dma_tx;
+	struct sk_buff **tx_skbuff;
+	struct stmmac_tx_info *tx_skbuff_dma;
+	unsigned int cur_tx;
+	unsigned int dirty_tx;
+	dma_addr_t dma_tx_phy;
+	u32 tx_tail_addr;
+};
+
+struct stmmac_rx_queue {
+	u32 queue_index;
+	struct stmmac_priv *priv_data;
+	struct dma_extended_desc *dma_erx;
+	struct dma_desc *dma_rx ____cacheline_aligned_in_smp;
+	struct sk_buff **rx_skbuff;
+	dma_addr_t *rx_skbuff_dma;
+	struct napi_struct napi ____cacheline_aligned_in_smp;
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
@@ -56,28 +85,22 @@ struct stmmac_priv {
 	u32 tx_count_frames;
 	u32 tx_coal_frames;
 	u32 tx_coal_timer;
-	struct stmmac_tx_info *tx_skbuff_dma;
-	dma_addr_t dma_tx_phy;
 	int tx_coalesce;
 	int hwts_tx_en;
 	bool tx_path_in_lpi_mode;
 	struct timer_list txtimer;
 	bool tso;
 
-	struct dma_desc *dma_rx	____cacheline_aligned_in_smp;
-	struct dma_extended_desc *dma_erx;
-	struct sk_buff **rx_skbuff;
-	unsigned int cur_rx;
-	unsigned int dirty_rx;
+	/* TX Queue */
+	struct stmmac_tx_queue *tx_queue;
+
+	/* RX Queue */
+	struct stmmac_rx_queue *rx_queue;
+
 	unsigned int dma_buf_sz;
 	unsigned int rx_copybreak;
-	unsigned int rx_zeroc_thresh;
 	u32 rx_riwt;
 	int hwts_rx_en;
-	dma_addr_t *rx_skbuff_dma;
-	dma_addr_t dma_rx_phy;
-
-	struct napi_struct napi ____cacheline_aligned_in_smp;
 
 	void __iomem *ioaddr;
 	struct net_device *dev;
@@ -119,8 +142,6 @@ struct stmmac_priv {
 	spinlock_t ptp_lock;
 	void __iomem *mmcaddr;
 	void __iomem *ptpaddr;
-	u32 rx_tail_addr;
-	u32 tx_tail_addr;
 	u32 mss;
 
 #ifdef CONFIG_DEBUG_FS
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d3a2151..a389dfb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -185,26 +185,38 @@ static void print_pkt(unsigned char *buf, int len)
 	print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, buf, len);
 }
 
-static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
+/**
+ * stmmac_tx_avail - Get tx queue availability
+ * @priv: driver private structure
+ * @queue: TX queue index
+ */
+static inline u32 stmmac_tx_avail(struct stmmac_priv *priv, u32 queue)
 {
+	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
 	u32 avail;
 
-	if (priv->dirty_tx > priv->cur_tx)
-		avail = priv->dirty_tx - priv->cur_tx - 1;
+	if (tx_q->dirty_tx > tx_q->cur_tx)
+		avail = tx_q->dirty_tx - tx_q->cur_tx - 1;
 	else
-		avail = DMA_TX_SIZE - priv->cur_tx + priv->dirty_tx - 1;
+		avail = DMA_TX_SIZE - tx_q->cur_tx + tx_q->dirty_tx - 1;
 
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
@@ -232,9 +244,19 @@ static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
  */
 static void stmmac_enable_eee_mode(struct stmmac_priv *priv)
 {
+	u32 tx_cnt = priv->plat->tx_queues_to_use;
+	u32 queue;
+
+	/* check if all TX queues have the work finished */
+	for (queue = 0; queue < tx_cnt; queue++) {
+		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
+
+		if (tx_q->dirty_tx != tx_q->cur_tx)
+			return; /* still unfinished work */
+	}
+
 	/* Check and enter in LPI mode */
-	if ((priv->dirty_tx == priv->cur_tx) &&
-	    (priv->tx_path_in_lpi_mode == false))
+	if (!priv->tx_path_in_lpi_mode)
 		priv->hw->mac->set_eee_mode(priv->hw,
 					    priv->plat->en_tx_lpi_clockgating);
 }
@@ -891,20 +913,40 @@ static int stmmac_init_phy(struct net_device *dev)
 
 static void stmmac_display_rings(struct stmmac_priv *priv)
 {
+	u32 rx_cnt = priv->plat->rx_queues_to_use;
+	u32 tx_cnt = priv->plat->tx_queues_to_use;
 	void *head_rx, *head_tx;
+	u32 queue;
 
-	if (priv->extend_desc) {
-		head_rx = (void *)priv->dma_erx;
-		head_tx = (void *)priv->dma_etx;
-	} else {
-		head_rx = (void *)priv->dma_rx;
-		head_tx = (void *)priv->dma_tx;
+	/* Display RX rings */
+	for (queue = 0; queue < rx_cnt; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		pr_info("\tRX Queue %d rings\n", queue);
+
+		if (priv->extend_desc)
+			head_rx = (void *)rx_q->dma_erx;
+		else
+			head_rx = (void *)rx_q->dma_rx;
+
+		/* Display Rx ring */
+		priv->hw->desc->display_ring(head_rx, DMA_RX_SIZE, true);
 	}
 
-	/* Display Rx ring */
-	priv->hw->desc->display_ring(head_rx, DMA_RX_SIZE, true);
-	/* Display Tx ring */
-	priv->hw->desc->display_ring(head_tx, DMA_TX_SIZE, false);
+	/* Display TX rings */
+	for (queue = 0; queue < tx_cnt; queue++) {
+		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
+
+		pr_info("\tTX Queue %d rings\n", queue);
+
+		if (priv->extend_desc)
+			head_tx = (void *)tx_q->dma_etx;
+		else
+			head_tx = (void *)tx_q->dma_tx;
+
+		/* Display Tx ring */
+		priv->hw->desc->display_ring(head_tx, DMA_TX_SIZE, false);
+	}
 }
 
 static int stmmac_set_bfsize(int mtu, int bufsize)
@@ -924,48 +966,86 @@ static int stmmac_set_bfsize(int mtu, int bufsize)
 }
 
 /**
- * stmmac_clear_descriptors - clear descriptors
+ * stmmac_clear_rx_descriptors - clear the descriptors of a RX queue
  * @priv: driver private structure
- * Description: this function is called to clear the tx and rx descriptors
+ * @queue: RX queue index
+ * Description: this function is called to clear the RX descriptors
  * in case of both basic and extended descriptors are used.
  */
-static void stmmac_clear_descriptors(struct stmmac_priv *priv)
+static void stmmac_clear_rx_descriptors(struct stmmac_priv *priv, u32 queue)
 {
-	int i;
+	struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+	u32 i = 0;
 
-	/* Clear the Rx/Tx descriptors */
+	/* Clear the RX descriptors */
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
+}
+
+/**
+ * stmmac_clear_tx_descriptors - clear the descriptors of a TX queue
+ * @priv: driver private structure
+ * @queue: TX queue index
+ * Description: this function is called to clear the TX descriptors
+ * in case of both basic and extended descriptors are used.
+ */
+static void stmmac_clear_tx_descriptors(struct stmmac_priv *priv, u32 queue)
+{
+	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
+	u32 i = 0;
+
+	/* Clear the TX descriptors */
 	for (i = 0; i < DMA_TX_SIZE; i++)
 		if (priv->extend_desc)
-			priv->hw->desc->init_tx_desc(&priv->dma_etx[i].basic,
+			priv->hw->desc->init_tx_desc(&tx_q->dma_etx[i].basic,
 						     priv->mode,
 						     (i == DMA_TX_SIZE - 1));
 		else
-			priv->hw->desc->init_tx_desc(&priv->dma_tx[i],
+			priv->hw->desc->init_tx_desc(&tx_q->dma_tx[i],
 						     priv->mode,
 						     (i == DMA_TX_SIZE - 1));
 }
 
 /**
+ * stmmac_clear_descriptors - clear descriptors
+ * @priv: driver private structure
+ * Description: this function is called to clear the tx and rx descriptors
+ * in case of both basic and extended descriptors are used.
+ */
+static void stmmac_clear_descriptors(struct stmmac_priv *priv)
+{
+	u32 rx_queue_cnt = priv->plat->rx_queues_to_use;
+	u32 tx_queue_cnt = priv->plat->tx_queues_to_use;
+	u32 queue;
+
+	for (queue = 0; queue < rx_queue_cnt; queue++)
+		stmmac_clear_rx_descriptors(priv, queue);
+
+	for (queue = 0; queue < tx_queue_cnt; queue++)
+		stmmac_clear_tx_descriptors(priv, queue);
+}
+
+/**
  * stmmac_init_rx_buffers - init the RX descriptor buffer.
  * @priv: driver private structure
  * @p: descriptor pointer
  * @i: descriptor index
  * @flags: gfp flag.
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
@@ -974,20 +1054,20 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
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
@@ -996,30 +1076,136 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 	return 0;
 }
 
-static void stmmac_free_rx_buffers(struct stmmac_priv *priv, int i)
+/**
+ * stmmac_free_rx_buffers - free RX buffers.
+ * @priv: driver private structure
+ * @queue: RX queue index
+ * @i: buffer index
+ */
+static void stmmac_free_rx_buffers(struct stmmac_priv *priv, u32 queue, int i)
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
- * init_dma_desc_rings - init the RX/TX descriptor rings
+ * stmmac_free_tx_buffers - free RX buffers.
+ * @priv: driver private structure
+ * @queue: RX queue index
+ * @i: buffer index
+ */
+static void stmmac_free_tx_buffers(struct stmmac_priv *priv, u32 queue, u32 i)
+{
+	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
+
+	if (tx_q->tx_skbuff_dma[i].buf) {
+		if (tx_q->tx_skbuff_dma[i].map_as_page)
+			dma_unmap_page(priv->device,
+				       tx_q->tx_skbuff_dma[i].buf,
+				       tx_q->tx_skbuff_dma[i].len,
+				       DMA_TO_DEVICE);
+		else
+			dma_unmap_single(priv->device,
+					 tx_q->tx_skbuff_dma[i].buf,
+					 tx_q->tx_skbuff_dma[i].len,
+					 DMA_TO_DEVICE);
+	}
+
+	if (tx_q->tx_skbuff[i]) {
+		dev_kfree_skb_any(tx_q->tx_skbuff[i]);
+		tx_q->tx_skbuff[i] = NULL;
+		tx_q->tx_skbuff_dma[i].buf = 0;
+		tx_q->tx_skbuff_dma[i].map_as_page = false;
+	}
+}
+
+/**
+ * init_tx_dma_desc_rings - init the TX descriptor rings
+ * @dev: net device structure
+ * Description: this function initializes the DMA TX descriptors
+ * and allocates the socket buffers. It suppors the chained and ring
+ * modes.
+ */
+static int init_tx_dma_desc_rings(struct net_device *dev)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 tx_queue_cnt = priv->plat->tx_queues_to_use;
+	u32 queue;
+	int i = 0;
+
+	for (queue = 0; queue < tx_queue_cnt; queue++) {
+		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
+
+		netif_dbg(priv, probe, priv->dev,
+			  "(%s) dma_tx_phy=0x%08x\n", __func__,
+			  (u32)tx_q->dma_tx_phy);
+
+		/* Setup the chained descriptor addresses */
+		if (priv->mode == STMMAC_CHAIN_MODE) {
+			if (priv->extend_desc)
+				priv->hw->mode->init(tx_q->dma_etx,
+						     tx_q->dma_tx_phy,
+						     DMA_TX_SIZE, 1);
+			else
+				priv->hw->mode->init(tx_q->dma_tx,
+						     tx_q->dma_tx_phy,
+						     DMA_TX_SIZE, 0);
+		}
+
+		for (i = 0; i < DMA_TX_SIZE; i++) {
+			struct dma_desc *p;
+
+			if (priv->extend_desc)
+				p = &((tx_q->dma_etx + i)->basic);
+			else
+				p = tx_q->dma_tx + i;
+
+			if (priv->synopsys_id >= DWMAC_CORE_4_00) {
+				p->des0 = 0;
+				p->des1 = 0;
+				p->des2 = 0;
+				p->des3 = 0;
+			} else {
+				p->des2 = 0;
+			}
+
+			tx_q->tx_skbuff_dma[i].buf = 0;
+			tx_q->tx_skbuff_dma[i].map_as_page = false;
+			tx_q->tx_skbuff_dma[i].len = 0;
+			tx_q->tx_skbuff_dma[i].last_segment = false;
+			tx_q->tx_skbuff[i] = NULL;
+		}
+
+		tx_q->dirty_tx = 0;
+		tx_q->cur_tx = 0;
+		netdev_tx_reset_queue(netdev_get_tx_queue(priv->dev, queue));
+	}
+
+	return 0;
+}
+
+/**
+ * init_rx_dma_desc_rings - init the RX descriptor rings
  * @dev: net device structure
  * @flags: gfp flag.
- * Description: this function initializes the DMA RX/TX descriptors
- * and allocates the socket buffers. It supports the chained and ring
+ * Description: this function initializes the DMA RX descriptors
+ * and allocates the socket buffers. It suppors the chained and ring
  * modes.
  */
-static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
+static int init_rx_dma_desc_rings(struct net_device *dev, gfp_t flags)
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
@@ -1029,235 +1215,350 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 
 	priv->dma_buf_sz = bfsize;
 
-	netif_dbg(priv, probe, priv->dev,
-		  "(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n",
-		  __func__, (u32)priv->dma_rx_phy, (u32)priv->dma_tx_phy);
-
 	/* RX INITIALIZATION */
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
-		if (priv->extend_desc) {
-			priv->hw->mode->init(priv->dma_erx, priv->dma_rx_phy,
-					     DMA_RX_SIZE, 1);
-			priv->hw->mode->init(priv->dma_etx, priv->dma_tx_phy,
-					     DMA_TX_SIZE, 1);
-		} else {
-			priv->hw->mode->init(priv->dma_rx, priv->dma_rx_phy,
-					     DMA_RX_SIZE, 0);
-			priv->hw->mode->init(priv->dma_tx, priv->dma_tx_phy,
-					     DMA_TX_SIZE, 0);
+			if (priv->extend_desc)
+				p = &((rx_q->dma_erx + i)->basic);
+			else
+				p = rx_q->dma_rx + i;
+
+			ret = stmmac_init_rx_buffers(priv, p, i, flags, queue);
+			if (ret)
+				goto err_init_rx_buffers;
+
+			netif_dbg(priv, probe, priv->dev, "[%p]\t[%p]\t[%x]\n",
+				  rx_q->rx_skbuff[i],
+				  rx_q->rx_skbuff[i]->data,
+				  (unsigned int)rx_q->rx_skbuff_dma[i]);
 		}
-	}
 
-	/* TX INITIALIZATION */
-	for (i = 0; i < DMA_TX_SIZE; i++) {
-		struct dma_desc *p;
-		if (priv->extend_desc)
-			p = &((priv->dma_etx + i)->basic);
-		else
-			p = priv->dma_tx + i;
+		rx_q->cur_rx = 0;
+		rx_q->dirty_rx = (unsigned int)(i - DMA_RX_SIZE);
 
-		if (priv->synopsys_id >= DWMAC_CORE_4_00) {
-			p->des0 = 0;
-			p->des1 = 0;
-			p->des2 = 0;
-			p->des3 = 0;
-		} else {
-			p->des2 = 0;
+		stmmac_clear_rx_descriptors(priv, queue);
+
+		if (priv->mode == STMMAC_CHAIN_MODE) {
+			if (priv->extend_desc)
+				priv->hw->mode->init(rx_q->dma_erx,
+						     rx_q->dma_rx_phy,
+						     DMA_RX_SIZE, 1);
+			else
+				priv->hw->mode->init(rx_q->dma_rx,
+						     rx_q->dma_rx_phy,
+						     DMA_RX_SIZE, 0);
 		}
+	}
 
-		priv->tx_skbuff_dma[i].buf = 0;
-		priv->tx_skbuff_dma[i].map_as_page = false;
-		priv->tx_skbuff_dma[i].len = 0;
-		priv->tx_skbuff_dma[i].last_segment = false;
-		priv->tx_skbuff[i] = NULL;
+	buf_sz = bfsize;
+
+	return 0;
+
+err_init_rx_buffers:
+	while (queue-- >= 0) {
+		while (--i >= 0)
+			stmmac_free_rx_buffers(priv, queue, i);
+
+		i = DMA_RX_SIZE;
 	}
 
-	priv->dirty_tx = 0;
-	priv->cur_tx = 0;
-	netdev_reset_queue(priv->dev);
+	return ret;
+}
 
-	stmmac_clear_descriptors(priv);
+/**
+ * init_dma_desc_rings - init the RX/TX descriptor rings
+ * @dev: net device structure
+ * @flags: gfp flag.
+ * Description: this function initializes the DMA RX/TX descriptors
+ * and allocates the socket buffers. It suppors the chained and ring
+ * modes.
+ */
+static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+	int ret = init_rx_dma_desc_rings(dev, flags);
+
+	if (ret)
+		return ret;
+
+	ret = init_tx_dma_desc_rings(dev);
 
 	if (netif_msg_hw(priv))
 		stmmac_display_rings(priv);
 
-	return 0;
-err_init_rx_buffers:
-	while (--i >= 0)
-		stmmac_free_rx_buffers(priv, i);
 	return ret;
 }
 
-static void dma_free_rx_skbufs(struct stmmac_priv *priv)
+static void dma_free_rx_skbufs(struct stmmac_priv *priv, u32 queue)
 {
 	int i;
 
 	for (i = 0; i < DMA_RX_SIZE; i++)
-		stmmac_free_rx_buffers(priv, i);
+		stmmac_free_rx_buffers(priv, queue, i);
 }
 
-static void dma_free_tx_skbufs(struct stmmac_priv *priv)
+static void dma_free_tx_skbufs(struct stmmac_priv *priv, u32 queue)
 {
 	int i;
 
-	for (i = 0; i < DMA_TX_SIZE; i++) {
-		if (priv->tx_skbuff_dma[i].buf) {
-			if (priv->tx_skbuff_dma[i].map_as_page)
-				dma_unmap_page(priv->device,
-					       priv->tx_skbuff_dma[i].buf,
-					       priv->tx_skbuff_dma[i].len,
-					       DMA_TO_DEVICE);
-			else
-				dma_unmap_single(priv->device,
-						 priv->tx_skbuff_dma[i].buf,
-						 priv->tx_skbuff_dma[i].len,
-						 DMA_TO_DEVICE);
-		}
+	for (i = 0; i < DMA_TX_SIZE; i++)
+		stmmac_free_tx_buffers(priv, queue, i);
+}
+
+/**
+ * free_rx_dma_desc_resources - free RX DMA resources
+ * @priv: driver private structure
+ */
+static void free_rx_dma_desc_resources(struct stmmac_priv *priv)
+{
+	u32 rx_count = priv->plat->rx_queues_to_use;
+	u32 queue = 0;
+
+	if (!priv->rx_queue)
+		return;
+
+	/* Free RX queue resources */
+	for (queue = 0; queue < rx_count; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		if (!rx_q)
+			break;
+
+		/* Release the DMA RX socket buffers */
+		dma_free_rx_skbufs(priv, queue);
+
+		kfree(rx_q->rx_skbuff);
+
+		kfree(rx_q->rx_skbuff_dma);
+
+		if (!priv->extend_desc)
+			dma_free_coherent(priv->device,
+					  DMA_RX_SIZE * sizeof(struct dma_desc),
+					  rx_q->dma_rx,
+					  rx_q->dma_rx_phy);
+		else
+			dma_free_coherent(priv->device, DMA_RX_SIZE *
+					  sizeof(struct dma_extended_desc),
+					  rx_q->dma_erx,
+					  rx_q->dma_rx_phy);
+	}
+
+	kfree(priv->rx_queue);
+}
+
+/**
+ * free_tx_dma_desc_resources - free TX DMA resources
+ * @priv: driver private structure
+ */
+static void free_tx_dma_desc_resources(struct stmmac_priv *priv)
+{
+	u32 tx_count = priv->plat->tx_queues_to_use;
+	u32 queue = 0;
+
+	if (!priv->tx_queue)
+		return;
+
+	/* Free TX queue resources */
+	for (queue = 0; queue < tx_count; queue++) {
+		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
+
+		if (!tx_q)
+			break;
+
+		/* Release the DMA TX socket buffers */
+		dma_free_tx_skbufs(priv, queue);
+
+		kfree(tx_q->tx_skbuff);
+
+		kfree(tx_q->tx_skbuff_dma);
+
+		if (!priv->extend_desc)
+			dma_free_coherent(priv->device,
+					  DMA_TX_SIZE * sizeof(struct dma_desc),
+					  tx_q->dma_tx,
+					  tx_q->dma_tx_phy);
+		else
+			dma_free_coherent(priv->device, DMA_TX_SIZE *
+					  sizeof(struct dma_extended_desc),
+					  tx_q->dma_etx,
+					  tx_q->dma_tx_phy);
+	}
+
+	kfree(priv->tx_queue);
+}
 
-		if (priv->tx_skbuff[i]) {
-			dev_kfree_skb_any(priv->tx_skbuff[i]);
-			priv->tx_skbuff[i] = NULL;
-			priv->tx_skbuff_dma[i].buf = 0;
-			priv->tx_skbuff_dma[i].map_as_page = false;
+/**
+ * free_dma_desc_resources - free All DMA resources
+ * @priv: driver private structure
+ */
+static void free_dma_desc_resources(struct stmmac_priv *priv)
+{
+	free_rx_dma_desc_resources(priv);
+	free_tx_dma_desc_resources(priv);
+}
+
+/**
+ * alloc_rx_dma_desc_resources - alloc RX resources.
+ * @priv: private structure
+ * Description: according to which descriptor can be used (extend or basic)
+ * this function allocates the resources for RX paths. It pre-allocates the
+ * RX socket buffer in order to allow zero-copy mechanism.
+ */
+static int alloc_rx_dma_desc_resources(struct stmmac_priv *priv)
+{
+	u32 rx_count = priv->plat->rx_queues_to_use;
+	int ret = -ENOMEM;
+	u32 queue = 0;
+
+	/* Allocate RX queues array */
+	priv->rx_queue = kmalloc_array(rx_count,
+				       sizeof(struct stmmac_rx_queue),
+				       GFP_KERNEL);
+	if (!priv->rx_queue) {
+		kfree(priv->rx_queue);
+		return -ENOMEM;
+	}
+
+	/* RX queues buffers and DMA */
+	for (queue = 0; queue < rx_count; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		rx_q->queue_index = queue;
+		rx_q->priv_data = priv;
+
+		rx_q->rx_skbuff_dma = kmalloc_array(DMA_RX_SIZE,
+							sizeof(dma_addr_t),
+							GFP_KERNEL);
+		if (!rx_q->rx_skbuff_dma)
+			goto err_dma_buffers;
+
+		rx_q->rx_skbuff = kmalloc_array(DMA_RX_SIZE,
+						    sizeof(struct sk_buff *),
+						    GFP_KERNEL);
+		if (!rx_q->rx_skbuff)
+			goto err_dma_buffers;
+
+		if (priv->extend_desc) {
+			rx_q->dma_erx =	dma_zalloc_coherent(priv->device,
+			(DMA_RX_SIZE * sizeof(struct dma_extended_desc)),
+			&rx_q->dma_rx_phy, GFP_KERNEL);
+
+			if (!rx_q->dma_erx)
+				goto err_dma_buffers;
+		} else {
+			rx_q->dma_rx = dma_zalloc_coherent(priv->device,
+			(DMA_RX_SIZE * sizeof(struct dma_desc)),
+			&rx_q->dma_rx_phy, GFP_KERNEL);
+
+			if (!rx_q->dma_rx)
+				goto err_dma_buffers;
 		}
 	}
+
+	return 0;
+
+err_dma_buffers:
+	free_rx_dma_desc_resources(priv);
+
+	return ret;
 }
 
 /**
- * alloc_dma_desc_resources - alloc TX/RX resources.
+ * alloc_tx_dma_desc_resources - alloc TX resources.
  * @priv: private structure
  * Description: according to which descriptor can be used (extend or basic)
- * this function allocates the resources for TX and RX paths. In case of
- * reception, for example, it pre-allocated the RX socket buffer in order to
- * allow zero-copy mechanism.
+ * this function allocates the resources for TX paths.
  */
-static int alloc_dma_desc_resources(struct stmmac_priv *priv)
+static int alloc_tx_dma_desc_resources(struct stmmac_priv *priv)
 {
+	u32 tx_count = priv->plat->tx_queues_to_use;
 	int ret = -ENOMEM;
+	u32 queue = 0;
 
-	priv->rx_skbuff_dma = kmalloc_array(DMA_RX_SIZE, sizeof(dma_addr_t),
-					    GFP_KERNEL);
-	if (!priv->rx_skbuff_dma)
+	/* Allocate TX queues array */
+	priv->tx_queue = kmalloc_array(tx_count,
+				       sizeof(struct stmmac_tx_queue),
+				       GFP_KERNEL);
+	if (!priv->tx_queue)
 		return -ENOMEM;
 
-	priv->rx_skbuff = kmalloc_array(DMA_RX_SIZE, sizeof(struct sk_buff *),
-					GFP_KERNEL);
-	if (!priv->rx_skbuff)
-		goto err_rx_skbuff;
-
-	priv->tx_skbuff_dma = kmalloc_array(DMA_TX_SIZE,
-					    sizeof(*priv->tx_skbuff_dma),
-					    GFP_KERNEL);
-	if (!priv->tx_skbuff_dma)
-		goto err_tx_skbuff_dma;
-
-	priv->tx_skbuff = kmalloc_array(DMA_TX_SIZE, sizeof(struct sk_buff *),
-					GFP_KERNEL);
-	if (!priv->tx_skbuff)
-		goto err_tx_skbuff;
-
-	if (priv->extend_desc) {
-		priv->dma_erx = dma_zalloc_coherent(priv->device, DMA_RX_SIZE *
-						    sizeof(struct
-							   dma_extended_desc),
-						    &priv->dma_rx_phy,
-						    GFP_KERNEL);
-		if (!priv->dma_erx)
-			goto err_dma;
+	/* TX queues buffers and DMA */
+	for (queue = 0; queue < tx_count; queue++) {
+		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
+
+		tx_q->queue_index = queue;
+		tx_q->priv_data = priv;
 
-		priv->dma_etx = dma_zalloc_coherent(priv->device, DMA_TX_SIZE *
-						    sizeof(struct
-							   dma_extended_desc),
-						    &priv->dma_tx_phy,
+		tx_q->tx_skbuff_dma = kmalloc_array(DMA_TX_SIZE,
+					  sizeof(struct stmmac_tx_info),
+					  GFP_KERNEL);
+
+		if (!tx_q->tx_skbuff_dma)
+			goto err_dma_buffers;
+
+		tx_q->tx_skbuff = kmalloc_array(DMA_TX_SIZE,
+						    sizeof(struct sk_buff *),
 						    GFP_KERNEL);
-		if (!priv->dma_etx) {
-			dma_free_coherent(priv->device, DMA_RX_SIZE *
-					  sizeof(struct dma_extended_desc),
-					  priv->dma_erx, priv->dma_rx_phy);
-			goto err_dma;
-		}
-	} else {
-		priv->dma_rx = dma_zalloc_coherent(priv->device, DMA_RX_SIZE *
-						   sizeof(struct dma_desc),
-						   &priv->dma_rx_phy,
-						   GFP_KERNEL);
-		if (!priv->dma_rx)
-			goto err_dma;
-
-		priv->dma_tx = dma_zalloc_coherent(priv->device, DMA_TX_SIZE *
-						   sizeof(struct dma_desc),
-						   &priv->dma_tx_phy,
-						   GFP_KERNEL);
-		if (!priv->dma_tx) {
-			dma_free_coherent(priv->device, DMA_RX_SIZE *
-					  sizeof(struct dma_desc),
-					  priv->dma_rx, priv->dma_rx_phy);
-			goto err_dma;
+		if (!tx_q->tx_skbuff)
+			goto err_dma_buffers;
+
+		if (priv->extend_desc) {
+			tx_q->dma_etx =
+			dma_zalloc_coherent(priv->device,
+			(DMA_TX_SIZE * sizeof(struct dma_extended_desc)),
+			&tx_q->dma_tx_phy, GFP_KERNEL);
+
+			if (!tx_q->dma_etx)
+				goto err_dma_buffers;
+		} else {
+			tx_q->dma_tx =
+			dma_zalloc_coherent(priv->device,
+			(DMA_TX_SIZE * sizeof(struct dma_desc)),
+			&tx_q->dma_tx_phy, GFP_KERNEL);
+
+			if (!tx_q->dma_tx)
+				goto err_dma_buffers;
 		}
 	}
 
 	return 0;
 
-err_dma:
-	kfree(priv->tx_skbuff);
-err_tx_skbuff:
-	kfree(priv->tx_skbuff_dma);
-err_tx_skbuff_dma:
-	kfree(priv->rx_skbuff);
-err_rx_skbuff:
-	kfree(priv->rx_skbuff_dma);
+err_dma_buffers:
+	free_tx_dma_desc_resources(priv);
+
 	return ret;
 }
 
-static void free_dma_desc_resources(struct stmmac_priv *priv)
+/**
+ * alloc_dma_desc_resources - alloc TX/RX resources.
+ * @priv: private structure
+ * Description: according to which descriptor can be used (extend or basic)
+ * this function allocates the resources for TX and RX paths. In case of
+ * reception, for example, it pre-allocated the RX socket buffer in order to
+ * allow zero-copy mechanism.
+ */
+static int alloc_dma_desc_resources(struct stmmac_priv *priv)
 {
-	/* Release the DMA TX/RX socket buffers */
-	dma_free_rx_skbufs(priv);
-	dma_free_tx_skbufs(priv);
-
-	/* Free DMA regions of consistent memory previously allocated */
-	if (!priv->extend_desc) {
-		dma_free_coherent(priv->device,
-				  DMA_TX_SIZE * sizeof(struct dma_desc),
-				  priv->dma_tx, priv->dma_tx_phy);
-		dma_free_coherent(priv->device,
-				  DMA_RX_SIZE * sizeof(struct dma_desc),
-				  priv->dma_rx, priv->dma_rx_phy);
-	} else {
-		dma_free_coherent(priv->device, DMA_TX_SIZE *
-				  sizeof(struct dma_extended_desc),
-				  priv->dma_etx, priv->dma_tx_phy);
-		dma_free_coherent(priv->device, DMA_RX_SIZE *
-				  sizeof(struct dma_extended_desc),
-				  priv->dma_erx, priv->dma_rx_phy);
-	}
-	kfree(priv->rx_skbuff_dma);
-	kfree(priv->rx_skbuff);
-	kfree(priv->tx_skbuff_dma);
-	kfree(priv->tx_skbuff);
+	int ret = 0;
+
+	ret = alloc_tx_dma_desc_resources(priv);
+	if (ret)
+		return ret;
+
+	ret = alloc_rx_dma_desc_resources(priv);
+
+	return ret;
 }
 
 /**
@@ -1421,26 +1722,28 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 /**
  * stmmac_tx_clean - to manage the transmission completion
  * @priv: driver private structure
+ * @queue: TX queue index
  * Description: it reclaims the transmit resources after transmission completes.
  */
-static void stmmac_tx_clean(struct stmmac_priv *priv)
+static void stmmac_tx_clean(struct stmmac_priv *priv, u32 queue)
 {
+	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
 	unsigned int bytes_compl = 0, pkts_compl = 0;
-	unsigned int entry = priv->dirty_tx;
+	unsigned int entry = tx_q->dirty_tx;
 
 	netif_tx_lock(priv->dev);
 
 	priv->xstats.tx_clean++;
 
-	while (entry != priv->cur_tx) {
-		struct sk_buff *skb = priv->tx_skbuff[entry];
+	while (entry != tx_q->cur_tx) {
+		struct sk_buff *skb = tx_q->tx_skbuff[entry];
 		struct dma_desc *p;
 		int status;
 
 		if (priv->extend_desc)
-			p = (struct dma_desc *)(priv->dma_etx + entry);
+			p = (struct dma_desc *)(tx_q->dma_etx + entry);
 		else
-			p = priv->dma_tx + entry;
+			p = tx_q->dma_tx + entry;
 
 		status = priv->hw->desc->tx_status(&priv->dev->stats,
 						      &priv->xstats, p,
@@ -1461,48 +1764,50 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			stmmac_get_tx_hwtstamp(priv, p, skb);
 		}
 
-		if (likely(priv->tx_skbuff_dma[entry].buf)) {
-			if (priv->tx_skbuff_dma[entry].map_as_page)
+		if (likely(tx_q->tx_skbuff_dma[entry].buf)) {
+			if (tx_q->tx_skbuff_dma[entry].map_as_page)
 				dma_unmap_page(priv->device,
-					       priv->tx_skbuff_dma[entry].buf,
-					       priv->tx_skbuff_dma[entry].len,
+					       tx_q->tx_skbuff_dma[entry].buf,
+					       tx_q->tx_skbuff_dma[entry].len,
 					       DMA_TO_DEVICE);
 			else
 				dma_unmap_single(priv->device,
-						 priv->tx_skbuff_dma[entry].buf,
-						 priv->tx_skbuff_dma[entry].len,
+						 tx_q->tx_skbuff_dma[entry].buf,
+						 tx_q->tx_skbuff_dma[entry].len,
 						 DMA_TO_DEVICE);
-			priv->tx_skbuff_dma[entry].buf = 0;
-			priv->tx_skbuff_dma[entry].len = 0;
-			priv->tx_skbuff_dma[entry].map_as_page = false;
+			tx_q->tx_skbuff_dma[entry].buf = 0;
+			tx_q->tx_skbuff_dma[entry].len = 0;
+			tx_q->tx_skbuff_dma[entry].map_as_page = false;
 		}
 
 		if (priv->hw->mode->clean_desc3)
-			priv->hw->mode->clean_desc3(priv, p);
+			priv->hw->mode->clean_desc3(tx_q, p);
 
-		priv->tx_skbuff_dma[entry].last_segment = false;
-		priv->tx_skbuff_dma[entry].is_jumbo = false;
+		tx_q->tx_skbuff_dma[entry].last_segment = false;
+		tx_q->tx_skbuff_dma[entry].is_jumbo = false;
 
 		if (likely(skb != NULL)) {
 			pkts_compl++;
 			bytes_compl += skb->len;
 			dev_consume_skb_any(skb);
-			priv->tx_skbuff[entry] = NULL;
+			tx_q->tx_skbuff[entry] = NULL;
 		}
 
 		priv->hw->desc->release_tx_desc(p, priv->mode);
 
 		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
 	}
-	priv->dirty_tx = entry;
+	tx_q->dirty_tx = entry;
 
-	netdev_completed_queue(priv->dev, pkts_compl, bytes_compl);
+	netdev_tx_completed_queue(netdev_get_tx_queue(priv->dev, queue),
+				  pkts_compl, bytes_compl);
 
-	if (unlikely(netif_queue_stopped(priv->dev) &&
-	    stmmac_tx_avail(priv) > STMMAC_TX_THRESH)) {
+	if (unlikely(netif_tx_queue_stopped(netdev_get_tx_queue(priv->dev,
+							       queue))) &&
+	    stmmac_tx_avail(priv, queue) > STMMAC_TX_THRESH) {
 		netif_dbg(priv, tx_done, priv->dev,
 			  "%s: restart transmit\n", __func__);
-		netif_wake_queue(priv->dev);
+		netif_tx_wake_queue(netdev_get_tx_queue(priv->dev, queue));
 	}
 
 	if ((priv->eee_enabled) && (!priv->tx_path_in_lpi_mode)) {
@@ -1525,33 +1830,36 @@ static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv, u32 chan)
 /**
  * stmmac_tx_err - to manage the tx error
  * @priv: driver private structure
- * @chan: channel index
+ * @queue: queue index
  * Description: it cleans the descriptors and restarts the transmission
  * in case of transmission errors.
  */
-static void stmmac_tx_err(struct stmmac_priv *priv, u32 chan)
+static void stmmac_tx_err(struct stmmac_priv *priv, u32 queue)
 {
+	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
+	u32 chan = queue;
 	int i;
-	netif_stop_queue(priv->dev);
+
+	netif_tx_stop_queue(netdev_get_tx_queue(priv->dev, queue));
 
 	stmmac_stop_tx_dma(priv, chan);
-	dma_free_tx_skbufs(priv);
+	dma_free_tx_skbufs(priv, queue);
 	for (i = 0; i < DMA_TX_SIZE; i++)
 		if (priv->extend_desc)
-			priv->hw->desc->init_tx_desc(&priv->dma_etx[i].basic,
+			priv->hw->desc->init_tx_desc(&tx_q->dma_etx[i].basic,
 						     priv->mode,
 						     (i == DMA_TX_SIZE - 1));
 		else
-			priv->hw->desc->init_tx_desc(&priv->dma_tx[i],
+			priv->hw->desc->init_tx_desc(&tx_q->dma_tx[i],
 						     priv->mode,
 						     (i == DMA_TX_SIZE - 1));
-	priv->dirty_tx = 0;
-	priv->cur_tx = 0;
-	netdev_reset_queue(priv->dev);
+	tx_q->dirty_tx = 0;
+	tx_q->cur_tx = 0;
+	netdev_tx_reset_queue(netdev_get_tx_queue(priv->dev, queue));
 	stmmac_start_tx_dma(priv, chan);
 
 	priv->dev->stats.tx_errors++;
-	netif_wake_queue(priv->dev);
+	netif_tx_wake_queue(netdev_get_tx_queue(priv->dev, queue));
 }
 
 /**
@@ -1596,12 +1904,14 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 	u32 chan;
 
 	for (chan = 0; chan < tx_channel_count; chan++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[chan];
+
 		status = priv->hw->dma->dma_interrupt(priv->ioaddr,
 						      &priv->xstats, chan);
 		if (likely((status & handle_rx)) || (status & handle_tx)) {
-			if (likely(napi_schedule_prep(&priv->napi))) {
+			if (likely(napi_schedule_prep(&rx_q->napi))) {
 				stmmac_disable_dma_irq(priv, chan);
-				__napi_schedule(&priv->napi);
+				__napi_schedule(&rx_q->napi);
 			}
 		}
 
@@ -1734,6 +2044,8 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 {
 	u32 rx_channels_count = priv->plat->rx_queues_to_use;
 	u32 tx_channels_count = priv->plat->tx_queues_to_use;
+	struct stmmac_rx_queue *rx_q;
+	struct stmmac_tx_queue *tx_q;
 	u32 dummy_dma_rx_phy = 0;
 	u32 dummy_dma_tx_phy = 0;
 	u32 chan = 0;
@@ -1761,36 +2073,43 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 
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
 
 		/* DMA TX Channel Configuration */
 		for (chan = 0; chan < tx_channels_count; chan++) {
+			tx_q = &priv->tx_queue[chan];
+
 			priv->hw->dma->init_chan(priv->ioaddr,
-							priv->plat->dma_cfg,
-							chan);
+						 priv->plat->dma_cfg,
+						 chan);
 
 			priv->hw->dma->init_tx_chan(priv->ioaddr,
 						    priv->plat->dma_cfg,
-						    priv->dma_tx_phy, chan);
+						    tx_q->dma_tx_phy, chan);
 
-			priv->tx_tail_addr = priv->dma_tx_phy +
+			tx_q->tx_tail_addr = tx_q->dma_tx_phy +
 				    (DMA_TX_SIZE * sizeof(struct dma_desc));
 			priv->hw->dma->set_tx_tail_ptr(priv->ioaddr,
-						       priv->tx_tail_addr,
+						       tx_q->tx_tail_addr,
 						       chan);
 		}
 	} else {
+		rx_q = &priv->rx_queue[chan];
+		tx_q = &priv->tx_queue[chan];
+
 		priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
-				    priv->dma_tx_phy, priv->dma_rx_phy, atds);
+				    tx_q->dma_tx_phy, rx_q->dma_rx_phy, atds);
 	}
 
 	if (priv->plat->axi && priv->hw->dma->axi)
@@ -1808,8 +2127,70 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 static void stmmac_tx_timer(unsigned long data)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *)data;
+	u32 tx_queues_count = priv->plat->tx_queues_to_use;
+	u32 queue;
+
+	/* let's scan all the tx queues */
+	for (queue = 0; queue < tx_queues_count; queue++)
+		stmmac_tx_clean(priv, queue);
+}
+
+/**
+ * stmmac_stop_all_queues - Stop all queues
+ * @priv: driver private structure
+ */
+static void stmmac_stop_all_queues(struct stmmac_priv *priv)
+{
+	u32 tx_queues_cnt = priv->plat->tx_queues_to_use;
+	u32 queue;
+
+	for (queue = 0; queue < tx_queues_cnt; queue++)
+		netif_tx_stop_queue(netdev_get_tx_queue(priv->dev, queue));
+}
+
+/**
+ * stmmac_start_all_queues - Start all queues
+ * @priv: driver private structure
+ */
+static void stmmac_start_all_queues(struct stmmac_priv *priv)
+{
+	u32 tx_queues_cnt = priv->plat->tx_queues_to_use;
+	u32 queue;
 
-	stmmac_tx_clean(priv);
+	for (queue = 0; queue < tx_queues_cnt; queue++)
+		netif_tx_start_queue(netdev_get_tx_queue(priv->dev, queue));
+}
+
+/**
+ * stmmac_disable_all_queues - Disable all queues
+ * @priv: driver private structure
+ */
+static void stmmac_disable_all_queues(struct stmmac_priv *priv)
+{
+	u32 rx_queues_cnt = priv->plat->rx_queues_to_use;
+	u32 queue;
+
+	for (queue = 0; queue < rx_queues_cnt; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		napi_disable(&rx_q->napi);
+	}
+}
+
+/**
+ * stmmac_enable_all_queues - Enable all queues
+ * @priv: driver private structure
+ */
+static void stmmac_enable_all_queues(struct stmmac_priv *priv)
+{
+	u32 rx_queues_cnt = priv->plat->rx_queues_to_use;
+	u32 queue;
+
+	for (queue = 0; queue < rx_queues_cnt; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		napi_enable(&rx_q->napi);
+	}
 }
 
 /**
@@ -2098,23 +2479,8 @@ static int stmmac_open(struct net_device *dev)
 	memset(&priv->xstats, 0, sizeof(struct stmmac_extra_stats));
 	priv->xstats.threshold = tc;
 
-	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
 	priv->rx_copybreak = STMMAC_RX_COPYBREAK;
 
-	ret = alloc_dma_desc_resources(priv);
-	if (ret < 0) {
-		netdev_err(priv->dev, "%s: DMA descriptors allocation failed\n",
-			   __func__);
-		goto dma_desc_error;
-	}
-
-	ret = init_dma_desc_rings(dev, GFP_KERNEL);
-	if (ret < 0) {
-		netdev_err(priv->dev, "%s: DMA descriptors initialization failed\n",
-			   __func__);
-		goto init_error;
-	}
-
 	ret = stmmac_hw_setup(dev, true);
 	if (ret < 0) {
 		netdev_err(priv->dev, "%s: Hw setup failed\n", __func__);
@@ -2160,8 +2526,8 @@ static int stmmac_open(struct net_device *dev)
 		}
 	}
 
-	napi_enable(&priv->napi);
-	netif_start_queue(dev);
+	stmmac_enable_all_queues(priv);
+	stmmac_start_all_queues(priv);
 
 	return 0;
 
@@ -2178,7 +2544,7 @@ static int stmmac_open(struct net_device *dev)
 	stmmac_hw_teardown(dev);
 init_error:
 	free_dma_desc_resources(priv);
-dma_desc_error:
+
 	if (dev->phydev)
 		phy_disconnect(dev->phydev);
 
@@ -2204,9 +2570,9 @@ static int stmmac_release(struct net_device *dev)
 		phy_disconnect(dev->phydev);
 	}
 
-	netif_stop_queue(dev);
+	stmmac_stop_all_queues(priv);
 
-	napi_disable(&priv->napi);
+	stmmac_disable_all_queues(priv);
 
 	del_timer_sync(&priv->txtimer);
 
@@ -2243,22 +2609,24 @@ static int stmmac_release(struct net_device *dev)
  *  @des: buffer start address
  *  @total_len: total length to fill in descriptors
  *  @last_segmant: condition for the last descriptor
+ *  @queue: TX queue index
  *  Description:
  *  This function fills descriptor and request new descriptors according to
  *  buffer length to fill
  */
 static void stmmac_tso_allocator(struct stmmac_priv *priv, unsigned int des,
-				 int total_len, bool last_segment)
+				 int total_len, bool last_segment, u32 queue)
 {
+	struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
 	struct dma_desc *desc;
-	int tmp_len;
 	u32 buff_size;
+	int tmp_len;
 
 	tmp_len = total_len;
 
 	while (tmp_len > 0) {
-		priv->cur_tx = STMMAC_GET_ENTRY(priv->cur_tx, DMA_TX_SIZE);
-		desc = priv->dma_tx + priv->cur_tx;
+		tx_q->cur_tx = STMMAC_GET_ENTRY(tx_q->cur_tx, DMA_TX_SIZE);
+		desc = tx_q->dma_tx + tx_q->cur_tx;
 
 		desc->des0 = cpu_to_le32(des + (total_len - tmp_len));
 		buff_size = tmp_len >= TSO_MAX_BUFF_SIZE ?
@@ -2302,23 +2670,27 @@ static void stmmac_tso_allocator(struct stmmac_priv *priv, unsigned int des,
  */
 static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	u32 pay_len, mss;
-	int tmp_pay_len = 0;
+	struct dma_desc *desc, *first, *mss_desc = NULL;
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 queue = skb_get_queue_mapping(skb);
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	unsigned int first_entry, des;
-	struct dma_desc *desc, *first, *mss_desc = NULL;
+	struct stmmac_tx_queue *tx_q;
+	int tmp_pay_len = 0;
+	u32 pay_len, mss;
 	u8 proto_hdr_len;
 	int i;
 
+	tx_q = &priv->tx_queue[queue];
+
 	/* Compute header lengths */
 	proto_hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 
 	/* Desc availability based on threshold should be enough safe */
-	if (unlikely(stmmac_tx_avail(priv) <
+	if (unlikely(stmmac_tx_avail(priv, queue) <
 		(((skb->len - proto_hdr_len) / TSO_MAX_BUFF_SIZE + 1)))) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
+		if (!netif_tx_queue_stopped(netdev_get_tx_queue(dev, queue))) {
+			netif_tx_stop_queue(netdev_get_tx_queue(dev, queue));
 			/* This is a hard error, log it. */
 			netdev_err(priv->dev,
 				   "%s: Tx Ring full when queue awake\n",
@@ -2333,10 +2705,10 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* set new MSS value if needed */
 	if (mss != priv->mss) {
-		mss_desc = priv->dma_tx + priv->cur_tx;
+		mss_desc = tx_q->dma_tx + tx_q->cur_tx;
 		priv->hw->desc->set_mss(mss_desc, mss);
 		priv->mss = mss;
-		priv->cur_tx = STMMAC_GET_ENTRY(priv->cur_tx, DMA_TX_SIZE);
+		tx_q->cur_tx = STMMAC_GET_ENTRY(tx_q->cur_tx, DMA_TX_SIZE);
 	}
 
 	if (netif_msg_tx_queued(priv)) {
@@ -2346,9 +2718,9 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb->data_len);
 	}
 
-	first_entry = priv->cur_tx;
+	first_entry = tx_q->cur_tx;
 
-	desc = priv->dma_tx + first_entry;
+	desc = tx_q->dma_tx + first_entry;
 	first = desc;
 
 	/* first descriptor: fill Headers on Buf1 */
@@ -2357,9 +2729,9 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (dma_mapping_error(priv->device, des))
 		goto dma_map_err;
 
-	priv->tx_skbuff_dma[first_entry].buf = des;
-	priv->tx_skbuff_dma[first_entry].len = skb_headlen(skb);
-	priv->tx_skbuff[first_entry] = skb;
+	tx_q->tx_skbuff_dma[first_entry].buf = des;
+	tx_q->tx_skbuff_dma[first_entry].len = skb_headlen(skb);
+	tx_q->tx_skbuff[first_entry] = skb;
 
 	first->des0 = cpu_to_le32(des);
 
@@ -2370,7 +2742,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* If needed take extra descriptors to fill the remaining payload */
 	tmp_pay_len = pay_len - TSO_MAX_BUFF_SIZE;
 
-	stmmac_tso_allocator(priv, des, tmp_pay_len, (nfrags == 0));
+	stmmac_tso_allocator(priv, des, tmp_pay_len, (nfrags == 0), queue);
 
 	/* Prepare fragments */
 	for (i = 0; i < nfrags; i++) {
@@ -2383,22 +2755,22 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto dma_map_err;
 
 		stmmac_tso_allocator(priv, des, skb_frag_size(frag),
-				     (i == nfrags - 1));
+				     (i == nfrags - 1), queue);
 
-		priv->tx_skbuff_dma[priv->cur_tx].buf = des;
-		priv->tx_skbuff_dma[priv->cur_tx].len = skb_frag_size(frag);
-		priv->tx_skbuff[priv->cur_tx] = NULL;
-		priv->tx_skbuff_dma[priv->cur_tx].map_as_page = true;
+		tx_q->tx_skbuff_dma[tx_q->cur_tx].buf = des;
+		tx_q->tx_skbuff_dma[tx_q->cur_tx].len = skb_frag_size(frag);
+		tx_q->tx_skbuff[tx_q->cur_tx] = NULL;
+		tx_q->tx_skbuff_dma[tx_q->cur_tx].map_as_page = true;
 	}
 
-	priv->tx_skbuff_dma[priv->cur_tx].last_segment = true;
+	tx_q->tx_skbuff_dma[tx_q->cur_tx].last_segment = true;
 
-	priv->cur_tx = STMMAC_GET_ENTRY(priv->cur_tx, DMA_TX_SIZE);
+	tx_q->cur_tx = STMMAC_GET_ENTRY(tx_q->cur_tx, DMA_TX_SIZE);
 
-	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
+	if (unlikely(stmmac_tx_avail(priv, queue) <= (MAX_SKB_FRAGS + 1))) {
 		netif_dbg(priv, hw, priv->dev, "%s: stop transmitted packets\n",
 			  __func__);
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(netdev_get_tx_queue(dev, queue));
 	}
 
 	dev->stats.tx_bytes += skb->len;
@@ -2430,7 +2802,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv->hw->desc->prepare_tso_tx_desc(first, 1,
 			proto_hdr_len,
 			pay_len,
-			1, priv->tx_skbuff_dma[first_entry].last_segment,
+			1, tx_q->tx_skbuff_dma[first_entry].last_segment,
 			tcp_hdrlen(skb) / 4, (skb->len - proto_hdr_len));
 
 	/* If context desc is used to change MSS */
@@ -2445,20 +2817,20 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (netif_msg_pktdata(priv)) {
 		pr_info("%s: curr=%d dirty=%d f=%d, e=%d, f_p=%p, nfrags %d\n",
-			__func__, priv->cur_tx, priv->dirty_tx, first_entry,
-			priv->cur_tx, first, nfrags);
+			__func__, tx_q->cur_tx, tx_q->dirty_tx, first_entry,
+			tx_q->cur_tx, first, nfrags);
 
-		priv->hw->desc->display_ring((void *)priv->dma_tx, DMA_TX_SIZE,
+		priv->hw->desc->display_ring((void *)tx_q->dma_tx, DMA_TX_SIZE,
 					     0);
 
 		pr_info(">>> frame to be transmitted: ");
 		print_pkt(skb->data, skb_headlen(skb));
 	}
 
-	netdev_sent_queue(dev, skb->len);
+	netdev_tx_sent_queue(netdev_get_tx_queue(dev, queue), skb->len);
 
-	priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
-				       STMMAC_CHAN0);
+	priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, tx_q->tx_tail_addr,
+				       queue);
 
 	return NETDEV_TX_OK;
 
@@ -2482,21 +2854,25 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	unsigned int nopaged_len = skb_headlen(skb);
 	int i, csum_insertion = 0, is_jumbo = 0;
+	u32 queue = skb_get_queue_mapping(skb);
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	unsigned int entry, first_entry;
 	struct dma_desc *desc, *first;
+	struct stmmac_tx_queue *tx_q;
 	unsigned int enh_desc;
 	unsigned int des;
 
+	tx_q = &priv->tx_queue[queue];
+
 	/* Manage oversized TCP frames for GMAC4 device */
 	if (skb_is_gso(skb) && priv->tso) {
 		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 			return stmmac_tso_xmit(skb, dev);
 	}
 
-	if (unlikely(stmmac_tx_avail(priv) < nfrags + 1)) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
+	if (unlikely(stmmac_tx_avail(priv, queue) < nfrags + 1)) {
+		if (!netif_tx_queue_stopped(netdev_get_tx_queue(dev, queue))) {
+			netif_tx_stop_queue(netdev_get_tx_queue(dev, queue));
 			/* This is a hard error, log it. */
 			netdev_err(priv->dev,
 				   "%s: Tx Ring full when queue awake\n",
@@ -2508,19 +2884,19 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (priv->tx_path_in_lpi_mode)
 		stmmac_disable_eee_mode(priv);
 
-	entry = priv->cur_tx;
+	entry = tx_q->cur_tx;
 	first_entry = entry;
 
 	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
 
 	if (likely(priv->extend_desc))
-		desc = (struct dma_desc *)(priv->dma_etx + entry);
+		desc = (struct dma_desc *)(tx_q->dma_etx + entry);
 	else
-		desc = priv->dma_tx + entry;
+		desc = tx_q->dma_tx + entry;
 
 	first = desc;
 
-	priv->tx_skbuff[first_entry] = skb;
+	tx_q->tx_skbuff[first_entry] = skb;
 
 	enh_desc = priv->plat->enh_desc;
 	/* To program the descriptors according to the size of the frame */
@@ -2529,7 +2905,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(is_jumbo) && likely(priv->synopsys_id <
 					 DWMAC_CORE_4_00)) {
-		entry = priv->hw->mode->jumbo_frm(priv, skb, csum_insertion);
+		entry = priv->hw->mode->jumbo_frm(tx_q, skb, csum_insertion);
 		if (unlikely(entry < 0))
 			goto dma_map_err;
 	}
@@ -2542,26 +2918,26 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
 
 		if (likely(priv->extend_desc))
-			desc = (struct dma_desc *)(priv->dma_etx + entry);
+			desc = (struct dma_desc *)(tx_q->dma_etx + entry);
 		else
-			desc = priv->dma_tx + entry;
+			desc = tx_q->dma_tx + entry;
 
 		des = skb_frag_dma_map(priv->device, frag, 0, len,
 				       DMA_TO_DEVICE);
 		if (dma_mapping_error(priv->device, des))
 			goto dma_map_err; /* should reuse desc w/o issues */
 
-		priv->tx_skbuff[entry] = NULL;
+		tx_q->tx_skbuff[entry] = NULL;
 
-		priv->tx_skbuff_dma[entry].buf = des;
+		tx_q->tx_skbuff_dma[entry].buf = des;
 		if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00))
 			desc->des0 = cpu_to_le32(des);
 		else
 			desc->des2 = cpu_to_le32(des);
 
-		priv->tx_skbuff_dma[entry].map_as_page = true;
-		priv->tx_skbuff_dma[entry].len = len;
-		priv->tx_skbuff_dma[entry].last_segment = last_segment;
+		tx_q->tx_skbuff_dma[entry].map_as_page = true;
+		tx_q->tx_skbuff_dma[entry].len = len;
+		tx_q->tx_skbuff_dma[entry].last_segment = last_segment;
 
 		/* Prepare the descriptor and set the own bit too */
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion,
@@ -2570,20 +2946,20 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
 
-	priv->cur_tx = entry;
+	tx_q->cur_tx = entry;
 
 	if (netif_msg_pktdata(priv)) {
 		void *tx_head;
 
 		netdev_dbg(priv->dev,
 			   "%s: curr=%d dirty=%d f=%d, e=%d, first=%p, nfrags=%d",
-			   __func__, priv->cur_tx, priv->dirty_tx, first_entry,
+			   __func__, tx_q->cur_tx, tx_q->dirty_tx, first_entry,
 			   entry, first, nfrags);
 
 		if (priv->extend_desc)
-			tx_head = (void *)priv->dma_etx;
+			tx_head = (void *)tx_q->dma_etx;
 		else
-			tx_head = (void *)priv->dma_tx;
+			tx_head = (void *)tx_q->dma_tx;
 
 		priv->hw->desc->display_ring(tx_head, DMA_TX_SIZE, false);
 
@@ -2591,10 +2967,10 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		print_pkt(skb->data, skb->len);
 	}
 
-	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
+	if (unlikely(stmmac_tx_avail(priv, queue) <= (MAX_SKB_FRAGS + 1))) {
 		netif_dbg(priv, hw, priv->dev, "%s: stop transmitted packets\n",
 			  __func__);
-		netif_stop_queue(dev);
+		netif_tx_stop_queue(netdev_get_tx_queue(dev, queue));
 	}
 
 	dev->stats.tx_bytes += skb->len;
@@ -2629,14 +3005,14 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (dma_mapping_error(priv->device, des))
 			goto dma_map_err;
 
-		priv->tx_skbuff_dma[first_entry].buf = des;
+		tx_q->tx_skbuff_dma[first_entry].buf = des;
 		if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00))
 			first->des0 = cpu_to_le32(des);
 		else
 			first->des2 = cpu_to_le32(des);
 
-		priv->tx_skbuff_dma[first_entry].len = nopaged_len;
-		priv->tx_skbuff_dma[first_entry].last_segment = last_segment;
+		tx_q->tx_skbuff_dma[first_entry].len = nopaged_len;
+		tx_q->tx_skbuff_dma[first_entry].last_segment = last_segment;
 
 		if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
 			     priv->hwts_tx_en)) {
@@ -2657,13 +3033,13 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		dma_wmb();
 	}
 
-	netdev_sent_queue(dev, skb->len);
+	netdev_tx_sent_queue(netdev_get_tx_queue(dev, queue), skb->len);
 
 	if (priv->synopsys_id < DWMAC_CORE_4_00)
 		priv->hw->dma->enable_dma_transmission(priv->ioaddr);
 	else
-		priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
-					       STMMAC_CHAN0);
+		priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, tx_q->tx_tail_addr,
+					       queue);
 
 	return NETDEV_TX_OK;
 
@@ -2691,9 +3067,9 @@ static void stmmac_rx_vlan(struct net_device *dev, struct sk_buff *skb)
 }
 
 
-static inline int stmmac_rx_threshold_count(struct stmmac_priv *priv)
+static inline int stmmac_rx_threshold_count(struct stmmac_rx_queue *rx_q)
 {
-	if (priv->rx_zeroc_thresh < STMMAC_RX_THRESH)
+	if (rx_q->rx_zeroc_thresh < STMMAC_RX_THRESH)
 		return 0;
 
 	return 1;
@@ -2702,30 +3078,32 @@ static inline int stmmac_rx_threshold_count(struct stmmac_priv *priv)
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
+		if (!rx_q->rx_skbuff[entry]) {
 			struct sk_buff *skb;
 
 			skb = netdev_alloc_skb_ip_align(priv->dev, bfsize);
 			if (unlikely(!skb)) {
 				/* so for a while no zero-copy! */
-				priv->rx_zeroc_thresh = STMMAC_RX_THRESH;
+				rx_q->rx_zeroc_thresh = STMMAC_RX_THRESH;
 				if (unlikely(net_ratelimit()))
 					dev_err(priv->device,
 						"fail to alloc skb entry %d\n",
@@ -2733,28 +3111,28 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
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
@@ -2770,7 +3148,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 
 		entry = STMMAC_GET_ENTRY(entry, DMA_RX_SIZE);
 	}
-	priv->dirty_rx = entry;
+	rx_q->dirty_rx = entry;
 }
 
 /**
@@ -2780,21 +3158,22 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
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
@@ -2804,9 +3183,9 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		struct dma_desc *np;
 
 		if (priv->extend_desc)
-			p = (struct dma_desc *)(priv->dma_erx + entry);
+			p = (struct dma_desc *)(rx_q->dma_erx + entry);
 		else
-			p = priv->dma_rx + entry;
+			p = rx_q->dma_rx + entry;
 
 		/* read the status of the incoming frame */
 		status = priv->hw->desc->rx_status(&priv->dev->stats,
@@ -2817,20 +3196,20 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 
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
@@ -2840,9 +3219,9 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
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
@@ -2890,7 +3269,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 			 */
 			if (unlikely(!priv->plat->has_gmac4 &&
 				     ((frame_len < priv->rx_copybreak) ||
-				     stmmac_rx_threshold_count(priv)))) {
+				     stmmac_rx_threshold_count(rx_q)))) {
 				skb = netdev_alloc_skb_ip_align(priv->dev,
 								frame_len);
 				if (unlikely(!skb)) {
@@ -2902,21 +3281,21 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
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
@@ -2925,12 +3304,12 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
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
@@ -2952,7 +3331,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 			else
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-			napi_gro_receive(&priv->napi, skb);
+			napi_gro_receive(&rx_q->napi, skb);
 
 			priv->dev->stats.rx_packets++;
 			priv->dev->stats.rx_bytes += frame_len;
@@ -2960,7 +3339,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		entry = next_entry;
 	}
 
-	stmmac_rx_refill(priv);
+	stmmac_rx_refill(priv, queue);
 
 	priv->xstats.rx_pkt_n += count;
 
@@ -2977,14 +3356,22 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
  */
 static int stmmac_poll(struct napi_struct *napi, int budget)
 {
-	struct stmmac_priv *priv = container_of(napi, struct stmmac_priv, napi);
-	int work_done = 0;
-	u32 chan = STMMAC_CHAN0;
+	struct stmmac_rx_queue *rx_q =
+		container_of(napi, struct stmmac_rx_queue, napi);
+	struct stmmac_priv *priv = rx_q->priv_data;
+	u32 tx_count = priv->dma_cap.number_tx_queues;
+	u32 chan = rx_q->queue_index;
+	u32 work_done = 0;
+	u32 queue = 0;
 
 	priv->xstats.napi_poll++;
-	stmmac_tx_clean(priv);
+	/* check all the queues */
+	for (queue = 0; queue < tx_count; queue++)
+		stmmac_tx_clean(priv, queue);
+
+	/* Process RX packets from this queue */
+	work_done = stmmac_rx(priv, budget, rx_q->queue_index);
 
-	work_done = stmmac_rx(priv, budget);
 	if (work_done < budget) {
 		napi_complete_done(napi, work_done);
 		stmmac_enable_dma_irq(priv, chan);
@@ -3003,10 +3390,12 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 static void stmmac_tx_timeout(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	u32 chan = STMMAC_CHAN0;
+	u32 tx_count = priv->plat->tx_queues_to_use;
+	u32 chan;
 
 	/* Clear Tx resources and restart transmitting again */
-	stmmac_tx_err(priv, chan);
+	for (chan = 0; chan < tx_count; chan++)
+		stmmac_tx_err(priv, chan);
 }
 
 /**
@@ -3145,6 +3534,9 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 
 		if (priv->synopsys_id >= DWMAC_CORE_4_00) {
 			for (queue = 0; queue < queues_count; queue++) {
+				struct stmmac_rx_queue *rx_q =
+				&priv->rx_queue[queue];
+
 				status |=
 				priv->hw->mac->host_mtl_irq_status(priv->hw,
 								   queue);
@@ -3152,7 +3544,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 				if (status & CORE_IRQ_MTL_RX_OVERFLOW &&
 				    priv->hw->dma->set_rx_tail_ptr)
 					priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
-								priv->rx_tail_addr,
+								rx_q->rx_tail_addr,
 								queue);
 			}
 		}
@@ -3252,17 +3644,40 @@ static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
 {
 	struct net_device *dev = seq->private;
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 rx_count = priv->plat->rx_queues_to_use;
+	u32 tx_count = priv->plat->tx_queues_to_use;
+	u32 queue;
 
-	if (priv->extend_desc) {
-		seq_printf(seq, "Extended RX descriptor ring:\n");
-		sysfs_display_ring((void *)priv->dma_erx, DMA_RX_SIZE, 1, seq);
-		seq_printf(seq, "Extended TX descriptor ring:\n");
-		sysfs_display_ring((void *)priv->dma_etx, DMA_TX_SIZE, 1, seq);
-	} else {
-		seq_printf(seq, "RX descriptor ring:\n");
-		sysfs_display_ring((void *)priv->dma_rx, DMA_RX_SIZE, 0, seq);
-		seq_printf(seq, "TX descriptor ring:\n");
-		sysfs_display_ring((void *)priv->dma_tx, DMA_TX_SIZE, 0, seq);
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
+
+	for (queue = 0; queue < tx_count; queue++) {
+		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
+
+		seq_printf(seq, "TX Queue %d:\n", queue);
+
+		if (priv->extend_desc) {
+			seq_printf(seq, "Extended descriptor ring:\n");
+			sysfs_display_ring((void *)tx_q->dma_etx,
+					   DMA_TX_SIZE, 1, seq);
+		} else {
+			seq_printf(seq, "Descriptor ring:\n");
+			sysfs_display_ring((void *)tx_q->dma_tx,
+					   DMA_TX_SIZE, 0, seq);
+		}
 	}
 
 	return 0;
@@ -3545,11 +3960,14 @@ int stmmac_dvr_probe(struct device *device,
 		     struct plat_stmmacenet_data *plat_dat,
 		     struct stmmac_resources *res)
 {
-	int ret = 0;
 	struct net_device *ndev = NULL;
 	struct stmmac_priv *priv;
+	int ret = 0;
+	u32 queue;
 
-	ndev = alloc_etherdev(sizeof(struct stmmac_priv));
+	ndev = alloc_etherdev_mqs(sizeof(struct stmmac_priv),
+				  MTL_MAX_TX_QUEUES,
+				  MTL_MAX_RX_QUEUES);
 	if (!ndev)
 		return -ENOMEM;
 
@@ -3591,6 +4009,12 @@ int stmmac_dvr_probe(struct device *device,
 	if (ret)
 		goto error_hw_init;
 
+	/* Configure real RX and TX queues */
+	ndev->real_num_rx_queues = priv->plat->rx_queues_to_use;
+	ndev->real_num_tx_queues = priv->plat->tx_queues_to_use;
+
+	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
+
 	ndev->netdev_ops = &stmmac_netdev_ops;
 
 	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
@@ -3640,7 +4064,26 @@ int stmmac_dvr_probe(struct device *device,
 			 "Enable RX Mitigation via HW Watchdog Timer\n");
 	}
 
-	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
+	ret = alloc_dma_desc_resources(priv);
+	if (ret < 0) {
+		netdev_err(priv->dev, "%s: DMA descriptors allocation failed\n",
+			   __func__);
+		goto init_dma_error;
+	}
+
+	ret = init_dma_desc_rings(priv->dev, GFP_KERNEL);
+	if (ret < 0) {
+		netdev_err(priv->dev, "%s: DMA descriptors initialization failed\n",
+			   __func__);
+		goto init_dma_error;
+	}
+
+	for (queue = 0; queue < priv->plat->rx_queues_to_use; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		netif_napi_add(ndev, &rx_q->napi, stmmac_poll,
+			       (64 * priv->plat->rx_queues_to_use));
+	}
 
 	spin_lock_init(&priv->lock);
 
@@ -3685,7 +4128,13 @@ int stmmac_dvr_probe(struct device *device,
 	    priv->hw->pcs != STMMAC_PCS_RTBI)
 		stmmac_mdio_unregister(ndev);
 error_mdio_register:
-	netif_napi_del(&priv->napi);
+	for (queue = 0; queue < priv->plat->rx_queues_to_use; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		netif_napi_del(&rx_q->napi);
+	}
+init_dma_error:
+	free_dma_desc_resources(priv);
 error_hw_init:
 	free_netdev(ndev);
 
@@ -3747,9 +4196,9 @@ int stmmac_suspend(struct device *dev)
 	spin_lock_irqsave(&priv->lock, flags);
 
 	netif_device_detach(ndev);
-	netif_stop_queue(ndev);
+	stmmac_stop_all_queues(priv);
 
-	napi_disable(&priv->napi);
+	stmmac_disable_all_queues(priv);
 
 	/* Stop TX/RX DMA */
 	stmmac_stop_all_dma(priv);
@@ -3775,6 +4224,31 @@ int stmmac_suspend(struct device *dev)
 EXPORT_SYMBOL_GPL(stmmac_suspend);
 
 /**
+ * stmmac_reset_queues_param - reset queue parameters
+ * @dev: device pointer
+ */
+static void stmmac_reset_queues_param(struct stmmac_priv *priv)
+{
+	u32 rx_cnt = priv->plat->rx_queues_to_use;
+	u32 tx_cnt = priv->plat->tx_queues_to_use;
+	u32 queue;
+
+	for (queue = 0; queue < rx_cnt; queue++) {
+		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
+
+		rx_q->cur_rx = 0;
+		rx_q->dirty_rx = 0;
+	}
+
+	for (queue = 0; queue < tx_cnt; queue++) {
+		struct stmmac_tx_queue *tx_q = &priv->tx_queue[queue];
+
+		tx_q->cur_tx = 0;
+		tx_q->dirty_tx = 0;
+	}
+}
+
+/**
  * stmmac_resume - resume callback
  * @dev: device pointer
  * Description: when resume this function is invoked to setup the DMA and CORE
@@ -3814,10 +4288,8 @@ int stmmac_resume(struct device *dev)
 
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
@@ -3829,9 +4301,9 @@ int stmmac_resume(struct device *dev)
 	stmmac_init_tx_coalesce(priv);
 	stmmac_set_rx_mode(ndev);
 
-	napi_enable(&priv->napi);
+	stmmac_enable_all_queues(priv);
 
-	netif_start_queue(ndev);
+	stmmac_start_all_queues(priv);
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
-- 
2.9.3
