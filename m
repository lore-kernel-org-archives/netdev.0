From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next v3 4/6] bnx2x: improve memory handling, low memory
 recovery flows
Date: Thu, 5 May 2011 12:50:33 +0300
Message-ID: <1304589033.17528.4.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3367 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753340Ab1EEKAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 06:00:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h         |    3 +-
 drivers/net/bnx2x/bnx2x_cmn.c     |  402 +++++++++++++++++++++++++++++-------
 drivers/net/bnx2x/bnx2x_cmn.h     |  128 ++++++++++---
 drivers/net/bnx2x/bnx2x_ethtool.c |    3 +-
 drivers/net/bnx2x/bnx2x_main.c    |  189 ++----------------
 5 files changed, 449 insertions(+), 276 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 9e87417..d57dab1 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -473,7 +473,8 @@ struct bnx2x_fastpath {
 #define NUM_RX_BD			(RX_DESC_CNT * NUM_RX_RINGS)
 #define MAX_RX_BD			(NUM_RX_BD - 1)
 #define MAX_RX_AVAIL			(MAX_RX_DESC_CNT * NUM_RX_RINGS - 2)
-#define MIN_RX_AVAIL			128
+#define MIN_RX_SIZE_TPA			72
+#define MIN_RX_SIZE_NONTPA		10
 #define INIT_JUMBO_RX_RING_SIZE		MAX_RX_AVAIL
 #define INIT_RX_RING_SIZE		MAX_RX_AVAIL
 #define NEXT_RX_IDX(x)		((((x) & RX_DESC_MASK) == \
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 8729061..b171b9b 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -27,6 +27,49 @@
 
 static int bnx2x_setup_irqs(struct bnx2x *bp);
 
+/**
+ * bnx2x_bz_fp - zero content of the fastpath structure.
+ *
+ * @bp:		driver handle
+ * @index:	fastpath index to be zeroed
+ *
+ * Makes sure the contents of the bp->fp[index].napi is kept
+ * intact.
+ */
+static inline void bnx2x_bz_fp(struct bnx2x *bp, int index)
+{
+	struct bnx2x_fastpath *fp = &bp->fp[index];
+	struct napi_struct orig_napi = fp->napi;
+	/* bzero bnx2x_fastpath contents */
+	memset(fp, 0, sizeof(*fp));
+
+	/* Restore the NAPI object as it has been already initialized */
+	fp->napi = orig_napi;
+}
+
+/**
+ * bnx2x_move_fp - move content of the fastpath structure.
+ *
+ * @bp:		driver handle
+ * @from:	source FP index
+ * @to:		destination FP index
+ *
+ * Makes sure the contents of the bp->fp[to].napi is kept
+ * intact.
+ */
+static inline void bnx2x_move_fp(struct bnx2x *bp, int from, int to)
+{
+	struct bnx2x_fastpath *from_fp = &bp->fp[from];
+	struct bnx2x_fastpath *to_fp = &bp->fp[to];
+	struct napi_struct orig_napi = to_fp->napi;
+	/* Move bnx2x_fastpath contents */
+	memcpy(to_fp, from_fp, sizeof(*to_fp));
+	to_fp->index = to;
+
+	/* Restore the NAPI object as it has been already initialized */
+	to_fp->napi = orig_napi;
+}
+
 /* free skb in the packet ring at pos idx
  * return idx of last bd freed
  */
@@ -801,55 +844,6 @@ void bnx2x_link_report(struct bnx2x *bp)
 	}
 }
 
-/* Returns the number of actually allocated BDs */
-static inline int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
-				      int rx_ring_size)
-{
-	struct bnx2x *bp = fp->bp;
-	u16 ring_prod, cqe_ring_prod;
-	int i;
-
-	fp->rx_comp_cons = 0;
-	cqe_ring_prod = ring_prod = 0;
-	for (i = 0; i < rx_ring_size; i++) {
-		if (bnx2x_alloc_rx_skb(bp, fp, ring_prod) < 0) {
-			BNX2X_ERR("was only able to allocate "
-				  "%d rx skbs on queue[%d]\n", i, fp->index);
-			fp->eth_q_stats.rx_skb_alloc_failed++;
-			break;
-		}
-		ring_prod = NEXT_RX_IDX(ring_prod);
-		cqe_ring_prod = NEXT_RCQ_IDX(cqe_ring_prod);
-		WARN_ON(ring_prod <= i);
-	}
-
-	fp->rx_bd_prod = ring_prod;
-	/* Limit the CQE producer by the CQE ring size */
-	fp->rx_comp_prod = min_t(u16, NUM_RCQ_RINGS*RCQ_DESC_CNT,
-			       cqe_ring_prod);
-	fp->rx_pkt = fp->rx_calls = 0;
-
-	return i;
-}
-
-static inline void bnx2x_alloc_rx_bd_ring(struct bnx2x_fastpath *fp)
-{
-	struct bnx2x *bp = fp->bp;
-	int rx_ring_size = bp->rx_ring_size ? bp->rx_ring_size :
-					      MAX_RX_AVAIL/bp->num_queues;
-
-	rx_ring_size = max_t(int, MIN_RX_AVAIL, rx_ring_size);
-
-	bnx2x_alloc_rx_bds(fp, rx_ring_size);
-
-	/* Warning!
-	 * this will generate an interrupt (to the TSTORM)
-	 * must only be done after chip is initialized
-	 */
-	bnx2x_update_rx_prod(bp, fp, fp->rx_bd_prod, fp->rx_comp_prod,
-			     fp->rx_sge_prod);
-}
-
 void bnx2x_init_rx_rings(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
@@ -858,6 +852,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 	u16 ring_prod;
 	int i, j;
 
+	/* Allocate TPA resources */
 	for_each_rx_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
@@ -865,6 +860,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 		   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, fp->rx_buf_size);
 
 		if (!fp->disable_tpa) {
+			/* Fill the per-aggregation pool */
 			for (i = 0; i < max_agg_queues; i++) {
 				fp->tpa_pool[i].skb =
 				   netdev_alloc_skb(bp->dev, fp->rx_buf_size);
@@ -919,13 +915,13 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 
 		fp->rx_bd_cons = 0;
 
-		bnx2x_set_next_page_rx_bd(fp);
-
-		/* CQ ring */
-		bnx2x_set_next_page_rx_cq(fp);
-
-		/* Allocate BDs and initialize BD ring */
-		bnx2x_alloc_rx_bd_ring(fp);
+		/* Activate BD ring */
+		/* Warning!
+		 * this will generate an interrupt (to the TSTORM)
+		 * must only be done after chip is initialized
+		 */
+		bnx2x_update_rx_prod(bp, fp, fp->rx_bd_prod, fp->rx_comp_prod,
+				     fp->rx_sge_prod);
 
 		if (j != 0)
 			continue;
@@ -959,27 +955,40 @@ static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 	}
 }
 
+static void bnx2x_free_rx_bds(struct bnx2x_fastpath *fp)
+{
+	struct bnx2x *bp = fp->bp;
+	int i;
+
+	/* ring wasn't allocated */
+	if (fp->rx_buf_ring == NULL)
+		return;
+
+	for (i = 0; i < NUM_RX_BD; i++) {
+		struct sw_rx_bd *rx_buf = &fp->rx_buf_ring[i];
+		struct sk_buff *skb = rx_buf->skb;
+
+		if (skb == NULL)
+			continue;
+
+		dma_unmap_single(&bp->pdev->dev,
+				 dma_unmap_addr(rx_buf, mapping),
+				 fp->rx_buf_size, DMA_FROM_DEVICE);
+
+		rx_buf->skb = NULL;
+		dev_kfree_skb(skb);
+	}
+}
+
 static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 {
-	int i, j;
+	int j;
 
 	for_each_rx_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
-		for (i = 0; i < NUM_RX_BD; i++) {
-			struct sw_rx_bd *rx_buf = &fp->rx_buf_ring[i];
-			struct sk_buff *skb = rx_buf->skb;
-
-			if (skb == NULL)
-				continue;
-
-			dma_unmap_single(&bp->pdev->dev,
-					 dma_unmap_addr(rx_buf, mapping),
-					 fp->rx_buf_size, DMA_FROM_DEVICE);
+		bnx2x_free_rx_bds(fp);
 
-			rx_buf->skb = NULL;
-			dev_kfree_skb(skb);
-		}
 		if (!fp->disable_tpa)
 			bnx2x_free_tpa_pool(bp, fp, CHIP_IS_E1(bp) ?
 					    ETH_MAX_AGGREGATION_QUEUES_E1 :
@@ -1348,26 +1357,37 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* must be called before memory allocation and HW init */
 	bnx2x_ilt_set_info(bp);
 
+	/* zero fastpath structures preserving invariants like napi which are
+	 * allocated only once
+	 */
+	for_each_queue(bp, i)
+		bnx2x_bz_fp(bp, i);
+
 	/* Set the receive queues buffer size */
 	bnx2x_set_rx_buf_size(bp);
 
+	for_each_queue(bp, i)
+		bnx2x_fp(bp, i, disable_tpa) =
+					((bp->flags & TPA_ENABLE_FLAG) == 0);
+
+#ifdef BCM_CNIC
+	/* We don't want TPA on FCoE L2 ring */
+	bnx2x_fcoe(bp, disable_tpa) = 1;
+#endif
+
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
 
+	/* As long as bnx2x_alloc_mem() may possibly update
+	 * bp->num_queues, bnx2x_set_real_num_queues() should always
+	 * come after it.
+	 */
 	rc = bnx2x_set_real_num_queues(bp);
 	if (rc) {
 		BNX2X_ERR("Unable to set real_num_queues\n");
 		goto load_error0;
 	}
 
-	for_each_queue(bp, i)
-		bnx2x_fp(bp, i, disable_tpa) =
-					((bp->flags & TPA_ENABLE_FLAG) == 0);
-
-#ifdef BCM_CNIC
-	/* We don't want TPA on FCoE L2 ring */
-	bnx2x_fcoe(bp, disable_tpa) = 1;
-#endif
 	bnx2x_napi_enable(bp);
 
 	/* Send LOAD_REQUEST command to MCP
@@ -2393,6 +2413,232 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
+static void bnx2x_free_fp_mem_at(struct bnx2x *bp, int fp_index)
+{
+	union host_hc_status_block *sb = &bnx2x_fp(bp, fp_index, status_blk);
+	struct bnx2x_fastpath *fp = &bp->fp[fp_index];
+
+	/* Common */
+#ifdef BCM_CNIC
+	if (IS_FCOE_IDX(fp_index)) {
+		memset(sb, 0, sizeof(union host_hc_status_block));
+		fp->status_blk_mapping = 0;
+
+	} else {
+#endif
+		/* status blocks */
+		if (CHIP_IS_E2(bp))
+			BNX2X_PCI_FREE(sb->e2_sb,
+				       bnx2x_fp(bp, fp_index,
+						status_blk_mapping),
+				       sizeof(struct host_hc_status_block_e2));
+		else
+			BNX2X_PCI_FREE(sb->e1x_sb,
+				       bnx2x_fp(bp, fp_index,
+						status_blk_mapping),
+				       sizeof(struct host_hc_status_block_e1x));
+#ifdef BCM_CNIC
+	}
+#endif
+	/* Rx */
+	if (!skip_rx_queue(bp, fp_index)) {
+		bnx2x_free_rx_bds(fp);
+
+		/* fastpath rx rings: rx_buf rx_desc rx_comp */
+		BNX2X_FREE(bnx2x_fp(bp, fp_index, rx_buf_ring));
+		BNX2X_PCI_FREE(bnx2x_fp(bp, fp_index, rx_desc_ring),
+			       bnx2x_fp(bp, fp_index, rx_desc_mapping),
+			       sizeof(struct eth_rx_bd) * NUM_RX_BD);
+
+		BNX2X_PCI_FREE(bnx2x_fp(bp, fp_index, rx_comp_ring),
+			       bnx2x_fp(bp, fp_index, rx_comp_mapping),
+			       sizeof(struct eth_fast_path_rx_cqe) *
+			       NUM_RCQ_BD);
+
+		/* SGE ring */
+		BNX2X_FREE(bnx2x_fp(bp, fp_index, rx_page_ring));
+		BNX2X_PCI_FREE(bnx2x_fp(bp, fp_index, rx_sge_ring),
+			       bnx2x_fp(bp, fp_index, rx_sge_mapping),
+			       BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
+	}
+
+	/* Tx */
+	if (!skip_tx_queue(bp, fp_index)) {
+		/* fastpath tx rings: tx_buf tx_desc */
+		BNX2X_FREE(bnx2x_fp(bp, fp_index, tx_buf_ring));
+		BNX2X_PCI_FREE(bnx2x_fp(bp, fp_index, tx_desc_ring),
+			       bnx2x_fp(bp, fp_index, tx_desc_mapping),
+			       sizeof(union eth_tx_bd_types) * NUM_TX_BD);
+	}
+	/* end of fastpath */
+}
+
+void bnx2x_free_fp_mem(struct bnx2x *bp)
+{
+	int i;
+	for_each_queue(bp, i)
+		bnx2x_free_fp_mem_at(bp, i);
+}
+
+static inline void set_sb_shortcuts(struct bnx2x *bp, int index)
+{
+	union host_hc_status_block status_blk = bnx2x_fp(bp, index, status_blk);
+	if (CHIP_IS_E2(bp)) {
+		bnx2x_fp(bp, index, sb_index_values) =
+			(__le16 *)status_blk.e2_sb->sb.index_values;
+		bnx2x_fp(bp, index, sb_running_index) =
+			(__le16 *)status_blk.e2_sb->sb.running_index;
+	} else {
+		bnx2x_fp(bp, index, sb_index_values) =
+			(__le16 *)status_blk.e1x_sb->sb.index_values;
+		bnx2x_fp(bp, index, sb_running_index) =
+			(__le16 *)status_blk.e1x_sb->sb.running_index;
+	}
+}
+
+static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
+{
+	union host_hc_status_block *sb;
+	struct bnx2x_fastpath *fp = &bp->fp[index];
+	int ring_size = 0;
+
+	/* if rx_ring_size specified - use it */
+	int rx_ring_size = bp->rx_ring_size ? bp->rx_ring_size :
+			   MAX_RX_AVAIL/bp->num_queues;
+
+	/* allocate at least number of buffers required by FW */
+	rx_ring_size = max_t(int, fp->disable_tpa ? MIN_RX_SIZE_NONTPA :
+						    MIN_RX_SIZE_TPA,
+				  rx_ring_size);
+
+	bnx2x_fp(bp, index, bp) = bp;
+	bnx2x_fp(bp, index, index) = index;
+
+	/* Common */
+	sb = &bnx2x_fp(bp, index, status_blk);
+#ifdef BCM_CNIC
+	if (!IS_FCOE_IDX(index)) {
+#endif
+		/* status blocks */
+		if (CHIP_IS_E2(bp))
+			BNX2X_PCI_ALLOC(sb->e2_sb,
+				&bnx2x_fp(bp, index, status_blk_mapping),
+				sizeof(struct host_hc_status_block_e2));
+		else
+			BNX2X_PCI_ALLOC(sb->e1x_sb,
+				&bnx2x_fp(bp, index, status_blk_mapping),
+			    sizeof(struct host_hc_status_block_e1x));
+#ifdef BCM_CNIC
+	}
+#endif
+	set_sb_shortcuts(bp, index);
+
+	/* Tx */
+	if (!skip_tx_queue(bp, index)) {
+		/* fastpath tx rings: tx_buf tx_desc */
+		BNX2X_ALLOC(bnx2x_fp(bp, index, tx_buf_ring),
+				sizeof(struct sw_tx_bd) * NUM_TX_BD);
+		BNX2X_PCI_ALLOC(bnx2x_fp(bp, index, tx_desc_ring),
+				&bnx2x_fp(bp, index, tx_desc_mapping),
+				sizeof(union eth_tx_bd_types) * NUM_TX_BD);
+	}
+
+	/* Rx */
+	if (!skip_rx_queue(bp, index)) {
+		/* fastpath rx rings: rx_buf rx_desc rx_comp */
+		BNX2X_ALLOC(bnx2x_fp(bp, index, rx_buf_ring),
+				sizeof(struct sw_rx_bd) * NUM_RX_BD);
+		BNX2X_PCI_ALLOC(bnx2x_fp(bp, index, rx_desc_ring),
+				&bnx2x_fp(bp, index, rx_desc_mapping),
+				sizeof(struct eth_rx_bd) * NUM_RX_BD);
+
+		BNX2X_PCI_ALLOC(bnx2x_fp(bp, index, rx_comp_ring),
+				&bnx2x_fp(bp, index, rx_comp_mapping),
+				sizeof(struct eth_fast_path_rx_cqe) *
+				NUM_RCQ_BD);
+
+		/* SGE ring */
+		BNX2X_ALLOC(bnx2x_fp(bp, index, rx_page_ring),
+				sizeof(struct sw_rx_page) * NUM_RX_SGE);
+		BNX2X_PCI_ALLOC(bnx2x_fp(bp, index, rx_sge_ring),
+				&bnx2x_fp(bp, index, rx_sge_mapping),
+				BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
+		/* RX BD ring */
+		bnx2x_set_next_page_rx_bd(fp);
+
+		/* CQ ring */
+		bnx2x_set_next_page_rx_cq(fp);
+
+		/* BDs */
+		ring_size = bnx2x_alloc_rx_bds(fp, rx_ring_size);
+		if (ring_size < rx_ring_size)
+			goto alloc_mem_err;
+	}
+
+	return 0;
+
+/* handles low memory cases */
+alloc_mem_err:
+	BNX2X_ERR("Unable to allocate full memory for queue %d (size %d)\n",
+						index, ring_size);
+	/* FW will drop all packets if queue is not big enough,
+	 * In these cases we disable the queue
+	 * Min size diferent for TPA and non-TPA queues
+	 */
+	if (ring_size < (fp->disable_tpa ?
+				MIN_RX_SIZE_TPA : MIN_RX_SIZE_NONTPA)) {
+			/* release memory allocated for this queue */
+			bnx2x_free_fp_mem_at(bp, index);
+			return -ENOMEM;
+	}
+	return 0;
+}
+
+int bnx2x_alloc_fp_mem(struct bnx2x *bp)
+{
+	int i;
+
+	/**
+	 * 1. Allocate FP for leading - fatal if error
+	 * 2. {CNIC} Allocate FCoE FP - fatal if error
+	 * 3. Allocate RSS - fix number of queues if error
+	 */
+
+	/* leading */
+	if (bnx2x_alloc_fp_mem_at(bp, 0))
+		return -ENOMEM;
+#ifdef BCM_CNIC
+	/* FCoE */
+	if (bnx2x_alloc_fp_mem_at(bp, FCOE_IDX))
+		return -ENOMEM;
+#endif
+	/* RSS */
+	for_each_nondefault_eth_queue(bp, i)
+		if (bnx2x_alloc_fp_mem_at(bp, i))
+			break;
+
+	/* handle memory failures */
+	if (i != BNX2X_NUM_ETH_QUEUES(bp)) {
+		int delta = BNX2X_NUM_ETH_QUEUES(bp) - i;
+
+		WARN_ON(delta < 0);
+#ifdef BCM_CNIC
+		/**
+		 * move non eth FPs next to last eth FP
+		 * must be done in that order
+		 * FCOE_IDX < FWD_IDX < OOO_IDX
+		 */
+
+		/* move FCoE fp */
+		bnx2x_move_fp(bp, FCOE_IDX, FCOE_IDX - delta);
+#endif
+		bp->num_queues -= delta;
+		BNX2X_ERR("Adjusted num of queues from %d to %d\n",
+			  bp->num_queues + delta, bp->num_queues);
+	}
+
+	return 0;
+}
 
 static int bnx2x_setup_irqs(struct bnx2x *bp)
 {
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 1cdab69..c86a97b 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -25,6 +25,39 @@
 
 extern int num_queues;
 
+/************************ Macros ********************************/
+#define BNX2X_PCI_FREE(x, y, size) \
+	do { \
+		if (x) { \
+			dma_free_coherent(&bp->pdev->dev, size, (void *)x, y); \
+			x = NULL; \
+			y = 0; \
+		} \
+	} while (0)
+
+#define BNX2X_FREE(x) \
+	do { \
+		if (x) { \
+			kfree((void *)x); \
+			x = NULL; \
+		} \
+	} while (0)
+
+#define BNX2X_PCI_ALLOC(x, y, size) \
+	do { \
+		x = dma_alloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL); \
+		if (x == NULL) \
+			goto alloc_mem_err; \
+		memset((void *)x, 0, size); \
+	} while (0)
+
+#define BNX2X_ALLOC(x, size) \
+	do { \
+		x = kzalloc(size, GFP_KERNEL); \
+		if (x == NULL) \
+			goto alloc_mem_err; \
+	} while (0)
+
 /*********************** Interfaces ****************************
  *  Functions that need to be implemented by each driver version
  */
@@ -377,6 +410,9 @@ int bnx2x_resume(struct pci_dev *pdev);
 /* Release IRQ vectors */
 void bnx2x_free_irq(struct bnx2x *bp);
 
+void bnx2x_free_fp_mem(struct bnx2x *bp);
+int bnx2x_alloc_fp_mem(struct bnx2x *bp);
+
 void bnx2x_init_rx_rings(struct bnx2x *bp);
 void bnx2x_free_skbs(struct bnx2x *bp);
 void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw);
@@ -883,6 +919,9 @@ static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
 {
 	int i;
 
+	if (fp->disable_tpa)
+		return;
+
 	for (i = 0; i < last; i++)
 		bnx2x_free_rx_sge(bp, fp, i);
 }
@@ -911,36 +950,39 @@ static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
 	}
 }
 
-
-static inline void bnx2x_init_tx_rings(struct bnx2x *bp)
+static inline void bnx2x_init_tx_ring_one(struct bnx2x_fastpath *fp)
 {
-	int i, j;
+	int i;
 
-	for_each_tx_queue(bp, j) {
-		struct bnx2x_fastpath *fp = &bp->fp[j];
+	for (i = 1; i <= NUM_TX_RINGS; i++) {
+		struct eth_tx_next_bd *tx_next_bd =
+			&fp->tx_desc_ring[TX_DESC_CNT * i - 1].next_bd;
 
-		for (i = 1; i <= NUM_TX_RINGS; i++) {
-			struct eth_tx_next_bd *tx_next_bd =
-				&fp->tx_desc_ring[TX_DESC_CNT * i - 1].next_bd;
+		tx_next_bd->addr_hi =
+			cpu_to_le32(U64_HI(fp->tx_desc_mapping +
+				    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
+		tx_next_bd->addr_lo =
+			cpu_to_le32(U64_LO(fp->tx_desc_mapping +
+				    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
+	}
 
-			tx_next_bd->addr_hi =
-				cpu_to_le32(U64_HI(fp->tx_desc_mapping +
-					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
-			tx_next_bd->addr_lo =
-				cpu_to_le32(U64_LO(fp->tx_desc_mapping +
-					    BCM_PAGE_SIZE*(i % NUM_TX_RINGS)));
-		}
+	SET_FLAG(fp->tx_db.data.header.header, DOORBELL_HDR_DB_TYPE, 1);
+	fp->tx_db.data.zero_fill1 = 0;
+	fp->tx_db.data.prod = 0;
 
-		SET_FLAG(fp->tx_db.data.header.header, DOORBELL_HDR_DB_TYPE, 1);
-		fp->tx_db.data.zero_fill1 = 0;
-		fp->tx_db.data.prod = 0;
+	fp->tx_pkt_prod = 0;
+	fp->tx_pkt_cons = 0;
+	fp->tx_bd_prod = 0;
+	fp->tx_bd_cons = 0;
+	fp->tx_pkt = 0;
+}
 
-		fp->tx_pkt_prod = 0;
-		fp->tx_pkt_cons = 0;
-		fp->tx_bd_prod = 0;
-		fp->tx_bd_cons = 0;
-		fp->tx_pkt = 0;
-	}
+static inline void bnx2x_init_tx_rings(struct bnx2x *bp)
+{
+	int i;
+
+	for_each_tx_queue(bp, i)
+		bnx2x_init_tx_ring_one(&bp->fp[i]);
 }
 
 static inline void bnx2x_set_next_page_rx_bd(struct bnx2x_fastpath *fp)
@@ -995,6 +1037,44 @@ static inline void bnx2x_set_next_page_rx_cq(struct bnx2x_fastpath *fp)
 	}
 }
 
+/* Returns the number of actually allocated BDs */
+static inline int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
+				      int rx_ring_size)
+{
+	struct bnx2x *bp = fp->bp;
+	u16 ring_prod, cqe_ring_prod;
+	int i;
+
+	fp->rx_comp_cons = 0;
+	cqe_ring_prod = ring_prod = 0;
+
+	/* This routine is called only during fo init so
+	 * fp->eth_q_stats.rx_skb_alloc_failed = 0
+	 */
+	for (i = 0; i < rx_ring_size; i++) {
+		if (bnx2x_alloc_rx_skb(bp, fp, ring_prod) < 0) {
+			fp->eth_q_stats.rx_skb_alloc_failed++;
+			continue;
+		}
+		ring_prod = NEXT_RX_IDX(ring_prod);
+		cqe_ring_prod = NEXT_RCQ_IDX(cqe_ring_prod);
+		WARN_ON(ring_prod <= (i - fp->eth_q_stats.rx_skb_alloc_failed));
+	}
+
+	if (fp->eth_q_stats.rx_skb_alloc_failed)
+		BNX2X_ERR("was only able to allocate "
+			  "%d rx skbs on queue[%d]\n",
+			  (i - fp->eth_q_stats.rx_skb_alloc_failed), fp->index);
+
+	fp->rx_bd_prod = ring_prod;
+	/* Limit the CQE producer by the CQE ring size */
+	fp->rx_comp_prod = min_t(u16, NUM_RCQ_RINGS*RCQ_DESC_CNT,
+			       cqe_ring_prod);
+	fp->rx_pkt = fp->rx_calls = 0;
+
+	return i - fp->eth_q_stats.rx_skb_alloc_failed;
+}
+
 #ifdef BCM_CNIC
 static inline void bnx2x_init_fcoe_fp(struct bnx2x *bp)
 {
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 4f42c31..7556fde 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1220,7 +1220,8 @@ static int bnx2x_set_ringparam(struct net_device *dev,
 	}
 
 	if ((ering->rx_pending > MAX_RX_AVAIL) ||
-	    (ering->rx_pending < MIN_RX_AVAIL) ||
+	    (ering->rx_pending < (bp->disable_tpa ? MIN_RX_SIZE_NONTPA :
+						    MIN_RX_SIZE_TPA)) ||
 	    (ering->tx_pending > MAX_TX_AVAIL) ||
 	    (ering->tx_pending <= MAX_SKB_FRAGS + 4))
 		return -EINVAL;
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 69be737..439b8e5 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -4450,7 +4450,7 @@ static void bnx2x_init_fp_sb(struct bnx2x *bp, int fp_idx)
 
 	fp->state = BNX2X_FP_STATE_CLOSED;
 
-	fp->index = fp->cid = fp_idx;
+	fp->cid = fp_idx;
 	fp->cl_id = BP_L_ID(bp) + fp_idx;
 	fp->fw_sb_id = bp->base_fw_ndsb + fp->cl_id + CNIC_CONTEXT_USE;
 	fp->igu_sb_id = bp->igu_base_sb + fp_idx + CNIC_CONTEXT_USE;
@@ -4562,9 +4562,11 @@ gunzip_nomem1:
 
 static void bnx2x_gunzip_end(struct bnx2x *bp)
 {
-	kfree(bp->strm->workspace);
-	kfree(bp->strm);
-	bp->strm = NULL;
+	if (bp->strm) {
+		kfree(bp->strm->workspace);
+		kfree(bp->strm);
+		bp->strm = NULL;
+	}
 
 	if (bp->gunzip_buf) {
 		dma_free_coherent(&bp->pdev->dev, FW_BUF_SIZE, bp->gunzip_buf,
@@ -5872,9 +5874,6 @@ int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 
 	bp->dmae_ready = 0;
 	spin_lock_init(&bp->dmae_lock);
-	rc = bnx2x_gunzip_init(bp);
-	if (rc)
-		return rc;
 
 	switch (load_code) {
 	case FW_MSG_CODE_DRV_LOAD_COMMON:
@@ -5918,80 +5917,10 @@ init_hw_err:
 
 void bnx2x_free_mem(struct bnx2x *bp)
 {
-
-#define BNX2X_PCI_FREE(x, y, size) \
-	do { \
-		if (x) { \
-			dma_free_coherent(&bp->pdev->dev, size, (void *)x, y); \
-			x = NULL; \
-			y = 0; \
-		} \
-	} while (0)
-
-#define BNX2X_FREE(x) \
-	do { \
-		if (x) { \
-			kfree((void *)x); \
-			x = NULL; \
-		} \
-	} while (0)
-
-	int i;
+	bnx2x_gunzip_end(bp);
 
 	/* fastpath */
-	/* Common */
-	for_each_queue(bp, i) {
-#ifdef BCM_CNIC
-		/* FCoE client uses default status block */
-		if (IS_FCOE_IDX(i)) {
-			union host_hc_status_block *sb =
-				&bnx2x_fp(bp, i, status_blk);
-			memset(sb, 0, sizeof(union host_hc_status_block));
-			bnx2x_fp(bp, i, status_blk_mapping) = 0;
-		} else {
-#endif
-		/* status blocks */
-		if (CHIP_IS_E2(bp))
-			BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk.e2_sb),
-				       bnx2x_fp(bp, i, status_blk_mapping),
-				       sizeof(struct host_hc_status_block_e2));
-		else
-			BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk.e1x_sb),
-				       bnx2x_fp(bp, i, status_blk_mapping),
-				       sizeof(struct host_hc_status_block_e1x));
-#ifdef BCM_CNIC
-		}
-#endif
-	}
-	/* Rx */
-	for_each_rx_queue(bp, i) {
-
-		/* fastpath rx rings: rx_buf rx_desc rx_comp */
-		BNX2X_FREE(bnx2x_fp(bp, i, rx_buf_ring));
-		BNX2X_PCI_FREE(bnx2x_fp(bp, i, rx_desc_ring),
-			       bnx2x_fp(bp, i, rx_desc_mapping),
-			       sizeof(struct eth_rx_bd) * NUM_RX_BD);
-
-		BNX2X_PCI_FREE(bnx2x_fp(bp, i, rx_comp_ring),
-			       bnx2x_fp(bp, i, rx_comp_mapping),
-			       sizeof(struct eth_fast_path_rx_cqe) *
-			       NUM_RCQ_BD);
-
-		/* SGE ring */
-		BNX2X_FREE(bnx2x_fp(bp, i, rx_page_ring));
-		BNX2X_PCI_FREE(bnx2x_fp(bp, i, rx_sge_ring),
-			       bnx2x_fp(bp, i, rx_sge_mapping),
-			       BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
-	}
-	/* Tx */
-	for_each_tx_queue(bp, i) {
-
-		/* fastpath tx rings: tx_buf tx_desc */
-		BNX2X_FREE(bnx2x_fp(bp, i, tx_buf_ring));
-		BNX2X_PCI_FREE(bnx2x_fp(bp, i, tx_desc_ring),
-			       bnx2x_fp(bp, i, tx_desc_mapping),
-			       sizeof(union eth_tx_bd_types) * NUM_TX_BD);
-	}
+	bnx2x_free_fp_mem(bp);
 	/* end of fastpath */
 
 	BNX2X_PCI_FREE(bp->def_status_blk, bp->def_status_blk_mapping,
@@ -6024,101 +5953,13 @@ void bnx2x_free_mem(struct bnx2x *bp)
 		       BCM_PAGE_SIZE * NUM_EQ_PAGES);
 
 	BNX2X_FREE(bp->rx_indir_table);
-
-#undef BNX2X_PCI_FREE
-#undef BNX2X_KFREE
 }
 
-static inline void set_sb_shortcuts(struct bnx2x *bp, int index)
-{
-	union host_hc_status_block status_blk = bnx2x_fp(bp, index, status_blk);
-	if (CHIP_IS_E2(bp)) {
-		bnx2x_fp(bp, index, sb_index_values) =
-			(__le16 *)status_blk.e2_sb->sb.index_values;
-		bnx2x_fp(bp, index, sb_running_index) =
-			(__le16 *)status_blk.e2_sb->sb.running_index;
-	} else {
-		bnx2x_fp(bp, index, sb_index_values) =
-			(__le16 *)status_blk.e1x_sb->sb.index_values;
-		bnx2x_fp(bp, index, sb_running_index) =
-			(__le16 *)status_blk.e1x_sb->sb.running_index;
-	}
-}
 
 int bnx2x_alloc_mem(struct bnx2x *bp)
 {
-#define BNX2X_PCI_ALLOC(x, y, size) \
-	do { \
-		x = dma_alloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL); \
-		if (x == NULL) \
-			goto alloc_mem_err; \
-		memset(x, 0, size); \
-	} while (0)
-
-#define BNX2X_ALLOC(x, size) \
-	do { \
-		x = kzalloc(size, GFP_KERNEL); \
-		if (x == NULL) \
-			goto alloc_mem_err; \
-	} while (0)
-
-	int i;
-
-	/* fastpath */
-	/* Common */
-	for_each_queue(bp, i) {
-		union host_hc_status_block *sb = &bnx2x_fp(bp, i, status_blk);
-		bnx2x_fp(bp, i, bp) = bp;
-		/* status blocks */
-#ifdef BCM_CNIC
-		if (!IS_FCOE_IDX(i)) {
-#endif
-			if (CHIP_IS_E2(bp))
-				BNX2X_PCI_ALLOC(sb->e2_sb,
-				    &bnx2x_fp(bp, i, status_blk_mapping),
-				    sizeof(struct host_hc_status_block_e2));
-			else
-				BNX2X_PCI_ALLOC(sb->e1x_sb,
-				    &bnx2x_fp(bp, i, status_blk_mapping),
-				    sizeof(struct host_hc_status_block_e1x));
-#ifdef BCM_CNIC
-		}
-#endif
-		set_sb_shortcuts(bp, i);
-	}
-	/* Rx */
-	for_each_queue(bp, i) {
-
-		/* fastpath rx rings: rx_buf rx_desc rx_comp */
-		BNX2X_ALLOC(bnx2x_fp(bp, i, rx_buf_ring),
-				sizeof(struct sw_rx_bd) * NUM_RX_BD);
-		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, rx_desc_ring),
-				&bnx2x_fp(bp, i, rx_desc_mapping),
-				sizeof(struct eth_rx_bd) * NUM_RX_BD);
-
-		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, rx_comp_ring),
-				&bnx2x_fp(bp, i, rx_comp_mapping),
-				sizeof(struct eth_fast_path_rx_cqe) *
-				NUM_RCQ_BD);
-
-		/* SGE ring */
-		BNX2X_ALLOC(bnx2x_fp(bp, i, rx_page_ring),
-				sizeof(struct sw_rx_page) * NUM_RX_SGE);
-		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, rx_sge_ring),
-				&bnx2x_fp(bp, i, rx_sge_mapping),
-				BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
-	}
-	/* Tx */
-	for_each_queue(bp, i) {
-
-		/* fastpath tx rings: tx_buf tx_desc */
-		BNX2X_ALLOC(bnx2x_fp(bp, i, tx_buf_ring),
-				sizeof(struct sw_tx_bd) * NUM_TX_BD);
-		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, tx_desc_ring),
-				&bnx2x_fp(bp, i, tx_desc_mapping),
-				sizeof(union eth_tx_bd_types) * NUM_TX_BD);
-	}
-	/* end of fastpath */
+	if (bnx2x_gunzip_init(bp))
+		return -ENOMEM;
 
 #ifdef BCM_CNIC
 	if (CHIP_IS_E2(bp))
@@ -6158,14 +5999,18 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 
 	BNX2X_ALLOC(bp->rx_indir_table, sizeof(bp->rx_indir_table[0]) *
 		    TSTORM_INDIRECTION_TABLE_SIZE);
+
+	/* fastpath */
+	/* need to be done at the end, since it's self adjusting to amount
+	 * of memory available for RSS queues
+	 */
+	if (bnx2x_alloc_fp_mem(bp))
+		goto alloc_mem_err;
 	return 0;
 
 alloc_mem_err:
 	bnx2x_free_mem(bp);
 	return -ENOMEM;
-
-#undef BNX2X_PCI_ALLOC
-#undef BNX2X_ALLOC
 }
 
 /*
-- 
1.7.2.2




