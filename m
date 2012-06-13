From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 5/12] bnx2x: Make the transmission queues
 adjacent
Date: Wed, 13 Jun 2012 15:44:17 +0300
Message-ID: <1339591464-10554-6-git-send-email-meravs@broadcom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1465 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752221Ab2FMJte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 05:49:34 -0400
In-Reply-To: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current scheme the transmission queues of traffic-class 0 were 0-15, the
transmission queues of traffic-class 1 were 16-31 and so on. If the number of
RSS queues was smaller than 16, there were gaps in transmission queues
numbering, as well as in CIDs numbering. This is both a waste (especially when
16 is increased to 64), and may causes problems with flushing queues when
reducing the number of RSS queues (using ethtool -L). The new scheme eliminates
the gaps.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |   66 +++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  105 +++++++++++++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |   14 +--
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   42 ++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |    4 +-
 6 files changed, 139 insertions(+), 94 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index feec032..36ebc3d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -276,29 +276,32 @@ enum {
 #define FIRST_TX_ONLY_COS_INDEX		1
 #define FIRST_TX_COS_INDEX		0
 
-/* defines for decodeing the fastpath index and the cos index out of the
- * transmission queue index
- */
 #define MAX_TXQS_PER_COS	FP_SB_MAX_E1x
 
-#define TXQ_TO_FP(txq_index)	((txq_index) % MAX_TXQS_PER_COS)
-#define TXQ_TO_COS(txq_index)	((txq_index) / MAX_TXQS_PER_COS)
-
 /* rules for calculating the cids of tx-only connections */
-#define CID_TO_FP(cid)		((cid) % MAX_TXQS_PER_COS)
-#define CID_COS_TO_TX_ONLY_CID(cid, cos)	(cid + cos * MAX_TXQS_PER_COS)
+#define CID_TO_FP(cid, bp)		((cid) % BNX2X_NUM_NON_CNIC_QUEUES(bp))
+#define CID_COS_TO_TX_ONLY_CID(cid, cos, bp) \
+				(cid + cos * BNX2X_NUM_NON_CNIC_QUEUES(bp))
 
 /* fp index inside class of service range */
-#define FP_COS_TO_TXQ(fp, cos)    ((fp)->index + cos * MAX_TXQS_PER_COS)
-
-/*
- * 0..15 eth cos0
- * 16..31 eth cos1 if applicable
- * 32..47 eth cos2 If applicable
- * fcoe queue follows eth queues (16, 32, 48 depending on cos)
+#define FP_COS_TO_TXQ(fp, cos, bp) \
+			((fp)->index + cos * BNX2X_NUM_NON_CNIC_QUEUES(bp))
+
+/* Indexes for transmission queues array:
+ * txdata for RSS i CoS j is at location i + (j * num of RSS)
+ * txdata for FCoE (if exist) is at location max cos * num of RSS
+ * txdata for FWD (if exist) is one location after FCoE
+ * txdata for OOO (if exist) is one location after FWD
  */
-#define MAX_ETH_TXQ_IDX(bp)	(MAX_TXQS_PER_COS * (bp)->max_cos)
-#define FCOE_TXQ_IDX(bp)	(MAX_ETH_TXQ_IDX(bp))
+enum {
+	FCOE_TXQ_IDX_OFFSET,
+	FWD_TXQ_IDX_OFFSET,
+	OOO_TXQ_IDX_OFFSET,
+};
+#define MAX_ETH_TXQ_IDX(bp)	(BNX2X_NUM_NON_CNIC_QUEUES(bp) * (bp)->max_cos)
+#ifdef BCM_CNIC
+#define FCOE_TXQ_IDX(bp)	(MAX_ETH_TXQ_IDX(bp) + FCOE_TXQ_IDX_OFFSET)
+#endif
 
 /* fast path */
 /*
@@ -481,6 +484,8 @@ struct bnx2x_fp_txdata {
 	__le16			*tx_cons_sb;
 
 	int			txq_index;
+	struct bnx2x_fastpath	*parent_fp;
+	int			tx_ring_size;
 };
 
 enum bnx2x_tpa_mode_t {
@@ -507,7 +512,7 @@ struct bnx2x_fastpath {
 	enum bnx2x_tpa_mode_t	mode;
 
 	u8			max_cos; /* actual number of active tx coses */
-	struct bnx2x_fp_txdata	txdata[BNX2X_MULTI_TX_COS];
+	struct bnx2x_fp_txdata	*txdata_ptr[BNX2X_MULTI_TX_COS];
 
 	struct sw_rx_bd		*rx_buf_ring;	/* BDs mappings ring */
 	struct sw_rx_page	*rx_page_ring;	/* SGE pages mappings ring */
@@ -579,19 +584,22 @@ struct bnx2x_fastpath {
 /* Use 2500 as a mini-jumbo MTU for FCoE */
 #define BNX2X_FCOE_MINI_JUMBO_MTU	2500
 
-/* FCoE L2 `fastpath' entry is right after the eth entries */
-#define FCOE_IDX			BNX2X_NUM_ETH_QUEUES(bp)
-#define bnx2x_fcoe_fp(bp)		(&bp->fp[FCOE_IDX])
-#define bnx2x_fcoe(bp, var)		(bnx2x_fcoe_fp(bp)->var)
-#define bnx2x_fcoe_tx(bp, var)		(bnx2x_fcoe_fp(bp)-> \
-						txdata[FIRST_TX_COS_INDEX].var)
+#define	FCOE_IDX_OFFSET		0
+
+#define FCOE_IDX(bp)		(BNX2X_NUM_NON_CNIC_QUEUES(bp) + \
+				 FCOE_IDX_OFFSET)
+#define bnx2x_fcoe_fp(bp)	(&bp->fp[FCOE_IDX(bp)])
+#define bnx2x_fcoe(bp, var)	(bnx2x_fcoe_fp(bp)->var)
+#define bnx2x_fcoe_tx(bp, var)	(bnx2x_fcoe_fp(bp)-> \
+						txdata_ptr[FIRST_TX_COS_INDEX] \
+						->var)
 
 
 #define IS_ETH_FP(fp)			(fp->index < \
 					 BNX2X_NUM_ETH_QUEUES(fp->bp))
 #ifdef BCM_CNIC
-#define IS_FCOE_FP(fp)			(fp->index == FCOE_IDX)
-#define IS_FCOE_IDX(idx)		((idx) == FCOE_IDX)
+#define IS_FCOE_FP(fp)			(fp->index == FCOE_IDX(fp->bp))
+#define IS_FCOE_IDX(idx)		((idx) == FCOE_IDX(bp))
 #else
 #define IS_FCOE_FP(fp)		false
 #define IS_FCOE_IDX(idx)	false
@@ -1202,6 +1210,8 @@ struct bnx2x {
 	 * are grouped together in the beginning of the structure
 	 */
 	struct bnx2x_fastpath	*fp;
+	struct bnx2x_fp_txdata	*bnx2x_txq;
+	int			bnx2x_txq_size;
 	void __iomem		*regview;
 	void __iomem		*doorbells;
 	u16			db_size;
@@ -1404,6 +1414,7 @@ struct bnx2x {
 	u8			igu_dsb_id;
 	u8			igu_base_sb;
 	u8			igu_sb_cnt;
+
 	dma_addr_t		def_status_blk_mapping;
 
 	struct bnx2x_slowpath	*slowpath;
@@ -1458,7 +1469,6 @@ struct bnx2x {
 					NON_ETH_CONTEXT_USE + CNIC_PRESENT)
 #define L2_ILT_LINES(bp)	(DIV_ROUND_UP(BNX2X_L2_CID_COUNT(bp),\
 					ILT_PAGE_CIDS))
-#define BNX2X_DB_SIZE(bp)	(BNX2X_L2_CID_COUNT(bp) * (1 << BNX2X_DB_SHIFT))
 
 	int			qm_cid_count;
 
@@ -1617,6 +1627,8 @@ struct bnx2x {
 extern int num_queues;
 #define BNX2X_NUM_QUEUES(bp)	(bp->num_queues)
 #define BNX2X_NUM_ETH_QUEUES(bp) (BNX2X_NUM_QUEUES(bp) - NON_ETH_CONTEXT_USE)
+#define BNX2X_NUM_NON_CNIC_QUEUES(bp)	(BNX2X_NUM_QUEUES(bp) - \
+					 NON_ETH_CONTEXT_USE)
 #define BNX2X_NUM_RX_QUEUES(bp)	BNX2X_NUM_QUEUES(bp)
 
 #define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 1)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 5648078..33132b1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -40,12 +40,15 @@
  * Makes sure the contents of the bp->fp[to].napi is kept
  * intact. This is done by first copying the napi struct from
  * the target to the source, and then mem copying the entire
- * source onto the target
+ * source onto the target. Update txdata pointers and related
+ * content.
  */
 static inline void bnx2x_move_fp(struct bnx2x *bp, int from, int to)
 {
 	struct bnx2x_fastpath *from_fp = &bp->fp[from];
 	struct bnx2x_fastpath *to_fp = &bp->fp[to];
+	int old_max_eth_txqs, new_max_eth_txqs;
+	int old_txdata_index = 0, new_txdata_index = 0;
 
 	/* Copy the NAPI object as it has been already initialized */
 	from_fp->napi = to_fp->napi;
@@ -53,6 +56,24 @@ static inline void bnx2x_move_fp(struct bnx2x *bp, int from, int to)
 	/* Move bnx2x_fastpath contents */
 	memcpy(to_fp, from_fp, sizeof(*to_fp));
 	to_fp->index = to;
+
+	/* Update txdata pointers in fp and move txdata content accordingly:
+	 * Each fp consumes 'max_cos' txdata structures, so the index should be
+	 * decremented by max_cos x delta.
+	 */
+
+	old_max_eth_txqs = BNX2X_NUM_ETH_QUEUES(bp) * (bp)->max_cos;
+	new_max_eth_txqs = (BNX2X_NUM_ETH_QUEUES(bp) - from + to) *
+				(bp)->max_cos;
+	if (from == FCOE_IDX(bp)) {
+		old_txdata_index = old_max_eth_txqs + FCOE_TXQ_IDX_OFFSET;
+		new_txdata_index = new_max_eth_txqs + FCOE_TXQ_IDX_OFFSET;
+	}
+
+	memcpy(&bp->bnx2x_txq[old_txdata_index],
+	       &bp->bnx2x_txq[new_txdata_index],
+	       sizeof(struct bnx2x_fp_txdata));
+	to_fp->txdata_ptr[0] = &bp->bnx2x_txq[new_txdata_index];
 }
 
 int load_count[2][3] = { {0} }; /* per-path: 0-common, 1-port0, 2-port1 */
@@ -873,7 +894,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	prefetch(fp->rx_cons_sb);
 
 	for_each_cos_in_tx_queue(fp, cos)
-		prefetch(fp->txdata[cos].tx_cons_sb);
+		prefetch(fp->txdata_ptr[cos]->tx_cons_sb);
 
 	prefetch(&fp->sb_running_index[SM_RX_ID]);
 	napi_schedule(&bnx2x_fp(bp, fp->index, napi));
@@ -1190,7 +1211,7 @@ static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 	for_each_tx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		for_each_cos_in_tx_queue(fp, cos) {
-			struct bnx2x_fp_txdata *txdata = &fp->txdata[cos];
+			struct bnx2x_fp_txdata *txdata = fp->txdata_ptr[cos];
 			unsigned pkts_compl = 0, bytes_compl = 0;
 
 			u16 sw_prod = txdata->tx_pkt_prod;
@@ -1202,7 +1223,8 @@ static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 				sw_cons++;
 			}
 			netdev_tx_reset_queue(
-			    netdev_get_tx_queue(bp->dev, txdata->txq_index));
+				netdev_get_tx_queue(bp->dev,
+						    txdata->txq_index));
 		}
 	}
 }
@@ -1564,6 +1586,8 @@ void bnx2x_set_num_queues(struct bnx2x *bp)
 #endif
 	/* Add special queues */
 	bp->num_queues += NON_ETH_CONTEXT_USE;
+
+	BNX2X_DEV_INFO("set number of queues to %d\n", bp->num_queues);
 }
 
 /**
@@ -1592,8 +1616,8 @@ static int bnx2x_set_real_num_queues(struct bnx2x *bp)
 {
 	int rc, tx, rx;
 
-	tx = MAX_TXQS_PER_COS * bp->max_cos;
-	rx = BNX2X_NUM_ETH_QUEUES(bp);
+	tx = BNX2X_NUM_ETH_QUEUES(bp) * bp->max_cos;
+	rx = BNX2X_NUM_QUEUES(bp) - NON_ETH_CONTEXT_USE;
 
 /* account for fcoe queue */
 #ifdef BCM_CNIC
@@ -1838,6 +1862,7 @@ bool bnx2x_test_firmware_version(struct bnx2x *bp, bool is_err)
 static void bnx2x_bz_fp(struct bnx2x *bp, int index)
 {
 	struct bnx2x_fastpath *fp = &bp->fp[index];
+	int cos;
 	struct napi_struct orig_napi = fp->napi;
 	/* bzero bnx2x_fastpath contents */
 	if (bp->stats_init)
@@ -1887,6 +1912,16 @@ static void bnx2x_bz_fp(struct bnx2x *bp, int index)
 		/* Special queues support only one CoS */
 		fp->max_cos = 1;
 
+	/* Init txdata pointers */
+#ifdef BCM_CNIC
+	if (IS_FCOE_FP(fp))
+		fp->txdata_ptr[0] = &bp->bnx2x_txq[FCOE_TXQ_IDX(bp)];
+#endif
+	if (IS_ETH_FP(fp))
+		for_each_cos_in_tx_queue(fp, cos)
+			fp->txdata_ptr[cos] = &bp->bnx2x_txq[cos *
+				BNX2X_NUM_ETH_QUEUES(bp) + index];
+
 	/*
 	 * set the tpa flag for each queue. The tpa flag determines the queue
 	 * minimal size so it must be set prior to queue memory allocation
@@ -1936,11 +1971,13 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/*
 	 * Zero fastpath structures preserving invariants like napi, which are
 	 * allocated only once, fp index, max_cos, bp pointer.
-	 * Also set fp->disable_tpa.
+	 * Also set fp->disable_tpa and txdata_ptr.
 	 */
 	DP(NETIF_MSG_IFUP, "num queues: %d", bp->num_queues);
 	for_each_queue(bp, i)
 		bnx2x_bz_fp(bp, i);
+	memset(bp->bnx2x_txq, 0, bp->bnx2x_txq_size *
+	       sizeof(struct bnx2x_fp_txdata));
 
 
 	/* Set the receive queues buffer size */
@@ -2287,6 +2324,7 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 	/* Stop Tx */
 	bnx2x_tx_disable(bp);
+	netdev_reset_tc(bp->dev);
 
 #ifdef BCM_CNIC
 	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
@@ -2445,8 +2483,8 @@ int bnx2x_poll(struct napi_struct *napi, int budget)
 #endif
 
 		for_each_cos_in_tx_queue(fp, cos)
-			if (bnx2x_tx_queue_has_work(&fp->txdata[cos]))
-				bnx2x_tx_int(bp, &fp->txdata[cos]);
+			if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))
+				bnx2x_tx_int(bp, fp->txdata_ptr[cos]);
 
 
 		if (bnx2x_has_rx_work(fp)) {
@@ -2825,7 +2863,6 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
-	struct bnx2x_fastpath *fp;
 	struct netdev_queue *txq;
 	struct bnx2x_fp_txdata *txdata;
 	struct sw_tx_bd *tx_buf;
@@ -2835,7 +2872,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct eth_tx_parse_bd_e2 *pbd_e2 = NULL;
 	u32 pbd_e2_parsing_data = 0;
 	u16 pkt_prod, bd_prod;
-	int nbd, txq_index, fp_index, txdata_index;
+	int nbd, txq_index;
 	dma_addr_t mapping;
 	u32 xmit_type = bnx2x_xmit_type(bp, skb);
 	int i;
@@ -2854,31 +2891,12 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	BUG_ON(txq_index >= MAX_ETH_TXQ_IDX(bp) + FCOE_PRESENT);
 
-	/* decode the fastpath index and the cos index from the txq */
-	fp_index = TXQ_TO_FP(txq_index);
-	txdata_index = TXQ_TO_COS(txq_index);
-
-#ifdef BCM_CNIC
-	/*
-	 * Override the above for the FCoE queue:
-	 *   - FCoE fp entry is right after the ETH entries.
-	 *   - FCoE L2 queue uses bp->txdata[0] only.
-	 */
-	if (unlikely(!NO_FCOE(bp) && (txq_index ==
-				      bnx2x_fcoe_tx(bp, txq_index)))) {
-		fp_index = FCOE_IDX;
-		txdata_index = 0;
-	}
-#endif
+	txdata = &bp->bnx2x_txq[txq_index];
 
 	/* enable this debug print to view the transmission queue being used
 	DP(NETIF_MSG_TX_QUEUED, "indices: txq %d, fp %d, txdata %d\n",
 	   txq_index, fp_index, txdata_index); */
 
-	/* locate the fastpath and the txdata */
-	fp = &bp->fp[fp_index];
-	txdata = &fp->txdata[txdata_index];
-
 	/* enable this debug print to view the tranmission details
 	DP(NETIF_MSG_TX_QUEUED,
 	   "transmitting packet cid %d fp index %d txdata_index %d tx_data ptr %p fp pointer %p\n",
@@ -2886,7 +2904,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(bnx2x_tx_avail(bp, txdata) <
 		     (skb_shinfo(skb)->nr_frags + 3))) {
-		fp->eth_q_stats.driver_xoff++;
+		txdata->parent_fp->eth_q_stats.driver_xoff++;
 		netif_tx_stop_queue(txq);
 		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
 		return NETDEV_TX_BUSY;
@@ -3168,7 +3186,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * fp->bd_tx_cons */
 		smp_mb();
 
-		fp->eth_q_stats.driver_xoff++;
+		txdata->parent_fp->eth_q_stats.driver_xoff++;
 		if (bnx2x_tx_avail(bp, txdata) >= MAX_SKB_FRAGS + 3)
 			netif_tx_wake_queue(txq);
 	}
@@ -3234,7 +3252,7 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 	/* configure traffic class to transmission queue mapping */
 	for (cos = 0; cos < bp->max_cos; cos++) {
 		count = BNX2X_NUM_ETH_QUEUES(bp);
-		offset = cos * MAX_TXQS_PER_COS;
+		offset = cos * BNX2X_NUM_NON_CNIC_QUEUES(bp);
 		netdev_set_tc_queue(dev, cos, count, offset);
 		DP(BNX2X_MSG_SP | NETIF_MSG_IFUP,
 		   "mapping tc %d to offset %d count %d\n",
@@ -3333,7 +3351,7 @@ static void bnx2x_free_fp_mem_at(struct bnx2x *bp, int fp_index)
 	if (!skip_tx_queue(bp, fp_index)) {
 		/* fastpath tx rings: tx_buf tx_desc */
 		for_each_cos_in_tx_queue(fp, cos) {
-			struct bnx2x_fp_txdata *txdata = &fp->txdata[cos];
+			struct bnx2x_fp_txdata *txdata = fp->txdata_ptr[cos];
 
 			DP(NETIF_MSG_IFDOWN,
 			   "freeing tx memory of fp %d cos %d cid %d\n",
@@ -3490,7 +3508,7 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 	if (!skip_tx_queue(bp, index)) {
 		/* fastpath tx rings: tx_buf tx_desc */
 		for_each_cos_in_tx_queue(fp, cos) {
-			struct bnx2x_fp_txdata *txdata = &fp->txdata[cos];
+			struct bnx2x_fp_txdata *txdata = fp->txdata_ptr[cos];
 
 			DP(NETIF_MSG_IFUP,
 			   "allocating tx memory of fp %d cos %d\n",
@@ -3573,7 +3591,7 @@ int bnx2x_alloc_fp_mem(struct bnx2x *bp)
 #ifdef BCM_CNIC
 	if (!NO_FCOE(bp))
 		/* FCoE */
-		if (bnx2x_alloc_fp_mem_at(bp, FCOE_IDX))
+		if (bnx2x_alloc_fp_mem_at(bp, FCOE_IDX(bp)))
 			/* we will fail load process instead of mark
 			 * NO_FCOE_FLAG
 			 */
@@ -3598,7 +3616,7 @@ int bnx2x_alloc_fp_mem(struct bnx2x *bp)
 		 */
 
 		/* move FCoE fp even NO_FCOE_FLAG is on */
-		bnx2x_move_fp(bp, FCOE_IDX, FCOE_IDX - delta);
+		bnx2x_move_fp(bp, FCOE_IDX(bp), FCOE_IDX(bp) - delta);
 #endif
 		bp->num_queues -= delta;
 		BNX2X_ERR("Adjusted num of queues from %d to %d\n",
@@ -3611,6 +3629,7 @@ int bnx2x_alloc_fp_mem(struct bnx2x *bp)
 void bnx2x_free_mem_bp(struct bnx2x *bp)
 {
 	kfree(bp->fp);
+	kfree(bp->bnx2x_txq);
 	kfree(bp->msix_table);
 	kfree(bp->ilt);
 }
@@ -3635,6 +3654,16 @@ int __devinit bnx2x_alloc_mem_bp(struct bnx2x *bp)
 		goto alloc_err;
 	bp->fp = fp;
 
+	/* Allocate memory for the transmission queues array */
+	bp->bnx2x_txq_size = BNX2X_MAX_RSS_COUNT(bp) * BNX2X_MULTI_TX_COS;
+#ifdef BCM_CNIC
+	bp->bnx2x_txq_size++;
+#endif
+	bp->bnx2x_txq = kcalloc(bp->bnx2x_txq_size,
+				sizeof(struct bnx2x_fp_txdata), GFP_KERNEL);
+	if (!bp->bnx2x_txq)
+		goto alloc_err;
+
 	/* msix table */
 	tbl = kcalloc(msix_table_size, sizeof(*tbl), GFP_KERNEL);
 	if (!tbl)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index bb47984..112ffcc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -728,7 +728,7 @@ static inline bool bnx2x_has_tx_work(struct bnx2x_fastpath *fp)
 {
 	u8 cos;
 	for_each_cos_in_tx_queue(fp, cos)
-		if (bnx2x_tx_queue_has_work(&fp->txdata[cos]))
+		if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))
 			return true;
 	return false;
 }
@@ -1066,12 +1066,14 @@ static inline u32 bnx2x_rx_ustorm_prods_offset(struct bnx2x_fastpath *fp)
 }
 
 static inline void bnx2x_init_txdata(struct bnx2x *bp,
-	struct bnx2x_fp_txdata *txdata, u32 cid, int txq_index,
-	__le16 *tx_cons_sb)
+				     struct bnx2x_fp_txdata *txdata, u32 cid,
+				     int txq_index, __le16 *tx_cons_sb,
+				     struct bnx2x_fastpath *fp)
 {
 	txdata->cid = cid;
 	txdata->txq_index = txq_index;
 	txdata->tx_cons_sb = tx_cons_sb;
+	txdata->parent_fp = fp;
 
 	DP(NETIF_MSG_IFUP, "created tx data cid %d, txq %d\n",
 	   txdata->cid, txdata->txq_index);
@@ -1114,9 +1116,9 @@ static inline void bnx2x_init_fcoe_fp(struct bnx2x *bp)
 	bnx2x_fcoe(bp, fw_sb_id) = DEF_SB_ID;
 	bnx2x_fcoe(bp, igu_sb_id) = bp->igu_dsb_id;
 	bnx2x_fcoe(bp, rx_cons_sb) = BNX2X_FCOE_L2_RX_INDEX;
-
-	bnx2x_init_txdata(bp, &bnx2x_fcoe(bp, txdata[0]),
-			  fp->cid, FCOE_TXQ_IDX(bp), BNX2X_FCOE_L2_TX_INDEX);
+	bnx2x_init_txdata(bp, bnx2x_fcoe(bp, txdata_ptr[0]),
+			  fp->cid, FCOE_TXQ_IDX(bp), BNX2X_FCOE_L2_TX_INDEX,
+			  fp);
 
 	DP(NETIF_MSG_IFUP, "created fcoe tx data (fp index %d)\n", fp->index);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 7378b1d..037eee6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1959,7 +1959,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
 	unsigned char *packet;
 	struct bnx2x_fastpath *fp_rx = &bp->fp[0];
 	struct bnx2x_fastpath *fp_tx = &bp->fp[0];
-	struct bnx2x_fp_txdata *txdata = &fp_tx->txdata[0];
+	struct bnx2x_fp_txdata *txdata = fp_tx->txdata_ptr[0];
 	u16 tx_start_idx, tx_idx;
 	u16 rx_start_idx, rx_idx;
 	u16 pkt_prod, bd_prod;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 16e009f..f80059e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -758,7 +758,7 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 		/* Tx */
 		for_each_cos_in_tx_queue(fp, cos)
 		{
-			txdata = fp->txdata[cos];
+			txdata = *fp->txdata_ptr[cos];
 			BNX2X_ERR("fp%d: tx_pkt_prod(0x%x)  tx_pkt_cons(0x%x)  tx_bd_prod(0x%x)  tx_bd_cons(0x%x)  *tx_cons_sb(0x%x)\n",
 				  i, txdata.tx_pkt_prod,
 				  txdata.tx_pkt_cons, txdata.tx_bd_prod,
@@ -876,7 +876,7 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 	for_each_tx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		for_each_cos_in_tx_queue(fp, cos) {
-			struct bnx2x_fp_txdata *txdata = &fp->txdata[cos];
+			struct bnx2x_fp_txdata *txdata = fp->txdata_ptr[cos];
 
 			start = TX_BD(le16_to_cpu(*txdata->tx_cons_sb) - 10);
 			end = TX_BD(le16_to_cpu(*txdata->tx_cons_sb) + 245);
@@ -1710,7 +1710,7 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 			/* Handle Rx or Tx according to SB id */
 			prefetch(fp->rx_cons_sb);
 			for_each_cos_in_tx_queue(fp, cos)
-				prefetch(fp->txdata[cos].tx_cons_sb);
+				prefetch(fp->txdata_ptr[cos]->tx_cons_sb);
 			prefetch(&fp->sb_running_index[SM_RX_ID]);
 			napi_schedule(&bnx2x_fp(bp, fp->index, napi));
 			status &= ~mask;
@@ -2921,7 +2921,7 @@ static void bnx2x_pf_tx_q_prep(struct bnx2x *bp,
 	struct bnx2x_fastpath *fp, struct bnx2x_txq_setup_params *txq_init,
 	u8 cos)
 {
-	txq_init->dscr_map = fp->txdata[cos].tx_desc_mapping;
+	txq_init->dscr_map = fp->txdata_ptr[cos]->tx_desc_mapping;
 	txq_init->sb_cq_index = HC_INDEX_ETH_FIRST_TX_CQ_CONS + cos;
 	txq_init->traffic_type = LLFC_TRAFFIC_TYPE_NW;
 	txq_init->fw_sb_id = fp->fw_sb_id;
@@ -3068,11 +3068,11 @@ static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
 	/* insert FCoE stats from ramrod response */
 	if (!NO_FCOE(bp)) {
 		struct tstorm_per_queue_stats *fcoe_q_tstorm_stats =
-			&bp->fw_stats_data->queue_stats[FCOE_IDX].
+			&bp->fw_stats_data->queue_stats[FCOE_IDX(bp)].
 			tstorm_queue_statistics;
 
 		struct xstorm_per_queue_stats *fcoe_q_xstorm_stats =
-			&bp->fw_stats_data->queue_stats[FCOE_IDX].
+			&bp->fw_stats_data->queue_stats[FCOE_IDX(bp)].
 			xstorm_queue_statistics;
 
 		struct fcoe_statistics_params *fw_fcoe_stat =
@@ -4741,7 +4741,7 @@ static void bnx2x_after_function_update(struct bnx2x *bp)
 
 #ifdef BCM_CNIC
 	if (!NO_FCOE(bp)) {
-		fp = &bp->fp[FCOE_IDX];
+		fp = &bp->fp[FCOE_IDX(bp)];
 		queue_params.q_obj = &fp->q_obj;
 
 		/* clear pending completion bit */
@@ -4778,7 +4778,7 @@ static struct bnx2x_queue_sp_obj *bnx2x_cid_to_q_obj(
 		return &bnx2x_fcoe(bp, q_obj);
 	else
 #endif
-		return &bnx2x_fp(bp, CID_TO_FP(cid), q_obj);
+		return &bnx2x_fp(bp, CID_TO_FP(cid, bp), q_obj);
 }
 
 static void bnx2x_eq_int(struct bnx2x *bp)
@@ -5660,11 +5660,11 @@ static void bnx2x_init_eth_fp(struct bnx2x *bp, int fp_idx)
 
 	/* init tx data */
 	for_each_cos_in_tx_queue(fp, cos) {
-		bnx2x_init_txdata(bp, &fp->txdata[cos],
-				  CID_COS_TO_TX_ONLY_CID(fp->cid, cos),
-				  FP_COS_TO_TXQ(fp, cos),
-				  BNX2X_TX_SB_INDEX_BASE + cos);
-		cids[cos] = fp->txdata[cos].cid;
+		bnx2x_init_txdata(bp, fp->txdata_ptr[cos],
+				  CID_COS_TO_TX_ONLY_CID(fp->cid, cos, bp),
+				  FP_COS_TO_TXQ(fp, cos, bp),
+				  BNX2X_TX_SB_INDEX_BASE + cos, fp);
+		cids[cos] = fp->txdata_ptr[cos]->cid;
 	}
 
 	bnx2x_init_queue_obj(bp, &fp->q_obj, fp->cl_id, cids, fp->max_cos,
@@ -5719,7 +5719,7 @@ static void bnx2x_init_tx_rings(struct bnx2x *bp)
 
 	for_each_tx_queue(bp, i)
 		for_each_cos_in_tx_queue(&bp->fp[i], cos)
-			bnx2x_init_tx_ring_one(&bp->fp[i].txdata[cos]);
+			bnx2x_init_tx_ring_one(bp->fp[i].txdata_ptr[cos]);
 }
 
 void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
@@ -7807,8 +7807,8 @@ static void bnx2x_pf_q_prep_init(struct bnx2x *bp,
 
 	/* set the context pointers queue object */
 	for (cos = FIRST_TX_COS_INDEX; cos < init_params->max_cos; cos++) {
-		cxt_index = fp->txdata[cos].cid / ILT_PAGE_CIDS;
-		cxt_offset = fp->txdata[cos].cid - (cxt_index *
+		cxt_index = fp->txdata_ptr[cos]->cid / ILT_PAGE_CIDS;
+		cxt_offset = fp->txdata_ptr[cos]->cid - (cxt_index *
 				ILT_PAGE_CIDS);
 		init_params->cxts[cos] =
 			&bp->context[cxt_index].vcxt[cxt_offset].eth;
@@ -7961,7 +7961,7 @@ static int bnx2x_stop_queue(struct bnx2x *bp, int index)
 	     tx_index++){
 
 		/* ascertain this is a normal queue*/
-		txdata = &fp->txdata[tx_index];
+		txdata = fp->txdata_ptr[tx_index];
 
 		DP(NETIF_MSG_IFDOWN, "stopping tx-only queue %d\n",
 							txdata->txq_index);
@@ -8328,7 +8328,7 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		for_each_cos_in_tx_queue(fp, cos)
-			rc = bnx2x_clean_tx_queue(bp, &fp->txdata[cos]);
+			rc = bnx2x_clean_tx_queue(bp, fp->txdata_ptr[cos]);
 #ifdef BNX2X_STOP_ON_ERROR
 		if (rc)
 			return;
@@ -11769,7 +11769,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	struct bnx2x *bp;
 	int pcie_width, pcie_speed;
 	int rc, max_non_def_sbs;
-	int rx_count, tx_count, rss_count;
+	int rx_count, tx_count, rss_count, doorbell_size;
 	/*
 	 * An estimated maximum supported CoS number according to the chip
 	 * version.
@@ -11863,8 +11863,10 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	 * Map doorbels here as we need the real value of bp->max_cos which
 	 * is initialized in bnx2x_init_bp().
 	 */
+	doorbell_size = (rss_count * max_cos_est + NON_ETH_CONTEXT_USE +
+			 CNIC_PRESENT) * (1 << BNX2X_DB_SHIFT);
 	bp->doorbells = ioremap_nocache(pci_resource_start(pdev, 2),
-					min_t(u64, BNX2X_DB_SIZE(bp),
+					min_t(u64, doorbell_size,
 					      pci_resource_len(pdev, 2)));
 	if (!bp->doorbells) {
 		dev_err(&bp->pdev->dev,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 0e8bdcb..776b521 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1432,7 +1432,7 @@ static void bnx2x_prep_fw_stats_req(struct bnx2x *bp)
 					query[first_queue_query_index + i];
 
 		cur_query_entry->kind = STATS_TYPE_QUEUE;
-		cur_query_entry->index = bnx2x_stats_id(&bp->fp[FCOE_IDX]);
+		cur_query_entry->index = bnx2x_stats_id(&bp->fp[FCOE_IDX(bp)]);
 		cur_query_entry->funcID = cpu_to_le16(BP_FUNC(bp));
 		cur_query_entry->address.hi =
 			cpu_to_le32(U64_HI(cur_data_offset));
@@ -1573,7 +1573,7 @@ void bnx2x_afex_collect_stats(struct bnx2x *bp, void *void_afex_stats,
 	struct afex_stats *afex_stats = (struct afex_stats *)void_afex_stats;
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
 	struct per_queue_stats *fcoe_q_stats =
-		&bp->fw_stats_data->queue_stats[FCOE_IDX];
+		&bp->fw_stats_data->queue_stats[FCOE_IDX(bp)];
 
 	struct tstorm_per_queue_stats *fcoe_q_tstorm_stats =
 		&fcoe_q_stats->tstorm_queue_statistics;
-- 
1.7.10
