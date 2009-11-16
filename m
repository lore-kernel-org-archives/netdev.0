From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Mon, 16 Nov 2009 18:05:58 +0200
Message-ID: <1258387558.30637.77.camel@lb-tlvb-vladz.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3383 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763AbZKPQFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 11:05:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put Tx and Rx DPC to be handled in the NAPI:
  - Saves status blocks.
  - Moves the Tx work from hardIRQ to NAPI.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   21 +--
 drivers/net/bnx2x_main.c |  367 +++++++++++++++++++---------------------------
 2 files changed, 157 insertions(+), 231 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 928942b..602ab86 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -259,9 +259,6 @@ struct bnx2x_eth_q_stats {
 struct bnx2x_fastpath {
 
 	struct napi_struct	napi;
-
-	u8			is_rx_queue;
-
 	struct host_status_block *status_blk;
 	dma_addr_t		status_blk_mapping;
 
@@ -970,8 +967,7 @@ struct bnx2x {
 #define BNX2X_STATE_ERROR		0xf000
 
 	int			multi_mode;
-	int			num_rx_queues;
-	int			num_tx_queues;
+	int			num_queues;
 
 	u32			rx_mode;
 #define BNX2X_RX_MODE_NONE		0
@@ -1074,20 +1070,15 @@ struct bnx2x {
 };
 
 
-#define BNX2X_MAX_QUEUES(bp)	(IS_E1HMF(bp) ? (MAX_CONTEXT/(2 * E1HVN_MAX)) \
-					      : (MAX_CONTEXT/2))
-#define BNX2X_NUM_QUEUES(bp)	(bp->num_rx_queues + bp->num_tx_queues)
-#define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 2)
+#define BNX2X_MAX_QUEUES(bp)	(IS_E1HMF(bp) ? (MAX_CONTEXT/E1HVN_MAX) \
+					      : MAX_CONTEXT)
+#define BNX2X_NUM_QUEUES(bp)	(bp->num_queues)
+#define is_multi(bp)		(BNX2X_NUM_QUEUES(bp) > 1)
 
-#define for_each_rx_queue(bp, var) \
-			for (var = 0; var < bp->num_rx_queues; var++)
-#define for_each_tx_queue(bp, var) \
-			for (var = bp->num_rx_queues; \
-			     var < BNX2X_NUM_QUEUES(bp); var++)
 #define for_each_queue(bp, var) \
 			for (var = 0; var < BNX2X_NUM_QUEUES(bp); var++)
 #define for_each_nondefault_queue(bp, var) \
-			for (var = 1; var < bp->num_rx_queues; var++)
+			for (var = 1; var < BNX2X_NUM_QUEUES(bp); var++)
 
 
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32);
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index e2cf686..bdecd42 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -57,7 +57,7 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
 
-#define DRV_MODULE_VERSION	"1.52.1-4"
+#define DRV_MODULE_VERSION	"1.52.1-5"
 #define DRV_MODULE_RELDATE	"2009/11/09"
 #define BNX2X_BC_VER		0x040200
 
@@ -91,15 +91,10 @@ module_param(multi_mode, int, 0);
 MODULE_PARM_DESC(multi_mode, " Multi queue mode "
 			     "(0 Disable; 1 Enable (default))");
 
-static int num_rx_queues;
-module_param(num_rx_queues, int, 0);
-MODULE_PARM_DESC(num_rx_queues, " Number of Rx queues for multi_mode=1"
-				" (default is half number of CPUs)");
-
-static int num_tx_queues;
-module_param(num_tx_queues, int, 0);
-MODULE_PARM_DESC(num_tx_queues, " Number of Tx queues for multi_mode=1"
-				" (default is half number of CPUs)");
+static int num_queues;
+module_param(num_queues, int, 0);
+MODULE_PARM_DESC(num_queues, " Number of queues for multi_mode=1"
+				" (default is as a number of CPUs)");
 
 static int disable_tpa;
 module_param(disable_tpa, int, 0);
@@ -558,7 +553,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 		  bp->def_att_idx, bp->attn_state, bp->spq_prod_idx);
 
 	/* Rx */
-	for_each_rx_queue(bp, i) {
+	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		BNX2X_ERR("fp%d: rx_bd_prod(%x)  rx_bd_cons(%x)"
@@ -575,7 +570,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	}
 
 	/* Tx */
-	for_each_tx_queue(bp, i) {
+	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		BNX2X_ERR("fp%d: tx_pkt_prod(%x)  tx_pkt_cons(%x)"
@@ -590,7 +585,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 
 	/* Rings */
 	/* Rx */
-	for_each_rx_queue(bp, i) {
+	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		start = RX_BD(le16_to_cpu(*fp->rx_cons_sb) - 10);
@@ -624,7 +619,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	}
 
 	/* Tx */
-	for_each_tx_queue(bp, i) {
+	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		start = TX_BD(le16_to_cpu(*fp->tx_cons_sb) - 10);
@@ -792,21 +787,13 @@ static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
 	barrier();
 }
 
-static inline u16 bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
+static inline void bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
 {
 	struct host_status_block *fpsb = fp->status_blk;
-	u16 rc = 0;
 
 	barrier(); /* status block is written to by the chip */
-	if (fp->fp_c_idx != fpsb->c_status_block.status_block_index) {
-		fp->fp_c_idx = fpsb->c_status_block.status_block_index;
-		rc |= 1;
-	}
-	if (fp->fp_u_idx != fpsb->u_status_block.status_block_index) {
-		fp->fp_u_idx = fpsb->u_status_block.status_block_index;
-		rc |= 2;
-	}
-	return rc;
+	fp->fp_c_idx = fpsb->c_status_block.status_block_index;
+	fp->fp_u_idx = fpsb->u_status_block.status_block_index;
 }
 
 static u16 bnx2x_ack_int(struct bnx2x *bp)
@@ -846,6 +833,9 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	u16 bd_idx = TX_BD(tx_buf->first_bd), new_cons;
 	int nbd;
 
+	/* prefetch skb end pointer to speedup dev_kfree_skb() */
+	prefetch(&skb->end);
+
 	DP(BNX2X_MSG_OFF, "pkt_idx %d  buff @(%p)->skb %p\n",
 	   idx, tx_buf, skb);
 
@@ -890,7 +880,7 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 	/* release skb */
 	WARN_ON(!skb);
-	dev_kfree_skb_any(skb);
+	dev_kfree_skb(skb);
 	tx_buf->first_bd = 0;
 	tx_buf->skb = NULL;
 
@@ -920,19 +910,28 @@ static inline u16 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
 	return (s16)(fp->bp->tx_ring_size) - used;
 }
 
-static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
+static inline int bnx2x_has_tx_work(struct bnx2x_fastpath *fp)
+{
+	u16 hw_cons;
+
+	/* Tell compiler that status block fields can change */
+	barrier();
+	hw_cons = le16_to_cpu(*fp->tx_cons_sb);
+	return hw_cons != fp->tx_pkt_cons;
+}
+
+static int bnx2x_tx_int(struct bnx2x_fastpath *fp)
 {
 	struct bnx2x *bp = fp->bp;
 	struct netdev_queue *txq;
 	u16 hw_cons, sw_cons, bd_cons = fp->tx_bd_cons;
-	int done = 0;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
-		return;
+		return -1;
 #endif
 
-	txq = netdev_get_tx_queue(bp->dev, fp->index - bp->num_rx_queues);
+	txq = netdev_get_tx_queue(bp->dev, fp->index);
 	hw_cons = le16_to_cpu(*fp->tx_cons_sb);
 	sw_cons = fp->tx_pkt_cons;
 
@@ -953,7 +952,6 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
 */
 		bd_cons = bnx2x_free_tx_pkt(bp, fp, pkt_cons);
 		sw_cons++;
-		done++;
 	}
 
 	fp->tx_pkt_cons = sw_cons;
@@ -975,6 +973,7 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
 		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
 			netif_tx_wake_queue(txq);
 	}
+	return 0;
 }
 
 #ifdef BCM_CNIC
@@ -1561,6 +1560,8 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		} else {
 			rx_buf = &fp->rx_buf_ring[bd_cons];
 			skb = rx_buf->skb;
+			prefetch(skb);
+			prefetch((u8 *)skb + 256);
 			len = le16_to_cpu(cqe->fast_path_cqe.pkt_len);
 			pad = cqe->fast_path_cqe.placement_offset;
 
@@ -1742,27 +1743,13 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	if (unlikely(bp->panic))
 		return IRQ_HANDLED;
 #endif
-	/* Handle Rx or Tx according to MSI-X vector */
-	if (fp->is_rx_queue) {
-		prefetch(fp->rx_cons_sb);
-		prefetch(&fp->status_blk->u_status_block.status_block_index);
-
-		napi_schedule(&bnx2x_fp(bp, fp->index, napi));
-
-	} else {
-		prefetch(fp->tx_cons_sb);
-		prefetch(&fp->status_blk->c_status_block.status_block_index);
-
-		bnx2x_update_fpsb_idx(fp);
-		rmb();
-		bnx2x_tx_int(fp);
 
-		/* Re-enable interrupts */
-		bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
-			     le16_to_cpu(fp->fp_u_idx), IGU_INT_NOP, 1);
-		bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
-			     le16_to_cpu(fp->fp_c_idx), IGU_INT_ENABLE, 1);
-	}
+	/* Handle Rx and Tx according to MSI-X vector */
+	prefetch(fp->rx_cons_sb);
+	prefetch(fp->tx_cons_sb);
+	prefetch(&fp->status_blk->u_status_block.status_block_index);
+	prefetch(&fp->status_blk->c_status_block.status_block_index);
+	napi_schedule(&bnx2x_fp(bp, fp->index, napi));
 
 	return IRQ_HANDLED;
 }
@@ -1797,31 +1784,14 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 
 		mask = 0x2 << fp->sb_id;
 		if (status & mask) {
-			/* Handle Rx or Tx according to SB id */
-			if (fp->is_rx_queue) {
-				prefetch(fp->rx_cons_sb);
-				prefetch(&fp->status_blk->u_status_block.
-							status_block_index);
-
-				napi_schedule(&bnx2x_fp(bp, fp->index, napi));
-
-			} else {
-				prefetch(fp->tx_cons_sb);
-				prefetch(&fp->status_blk->c_status_block.
-							status_block_index);
-
-				bnx2x_update_fpsb_idx(fp);
-				rmb();
-				bnx2x_tx_int(fp);
-
-				/* Re-enable interrupts */
-				bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
-					     le16_to_cpu(fp->fp_u_idx),
-					     IGU_INT_NOP, 1);
-				bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
-					     le16_to_cpu(fp->fp_c_idx),
-					     IGU_INT_ENABLE, 1);
-			}
+			/* Handle Rx and Tx according to SB id */
+			prefetch(fp->rx_cons_sb);
+			prefetch(&fp->status_blk->u_status_block.
+						status_block_index);
+			prefetch(fp->tx_cons_sb);
+			prefetch(&fp->status_blk->c_status_block.
+						status_block_index);
+			napi_schedule(&bnx2x_fp(bp, fp->index, napi));
 			status &= ~mask;
 		}
 	}
@@ -4027,7 +3997,7 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 	estats->no_buff_discard_hi = 0;
 	estats->no_buff_discard_lo = 0;
 
-	for_each_rx_queue(bp, i) {
+	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		int cl_id = fp->cl_id;
 		struct tstorm_per_client_stats *tclient =
@@ -4244,7 +4214,7 @@ static void bnx2x_net_stats_update(struct bnx2x *bp)
 	nstats->tx_bytes = bnx2x_hilo(&estats->total_bytes_transmitted_hi);
 
 	nstats->rx_dropped = estats->mac_discard;
-	for_each_rx_queue(bp, i)
+	for_each_queue(bp, i)
 		nstats->rx_dropped +=
 			le32_to_cpu(bp->fp[i].old_tclient.checksum_discard);
 
@@ -4298,7 +4268,7 @@ static void bnx2x_drv_stats_update(struct bnx2x *bp)
 	estats->rx_err_discard_pkt = 0;
 	estats->rx_skb_alloc_failed = 0;
 	estats->hw_csum_err = 0;
-	for_each_rx_queue(bp, i) {
+	for_each_queue(bp, i) {
 		struct bnx2x_eth_q_stats *qstats = &bp->fp[i].eth_q_stats;
 
 		estats->driver_xoff += qstats->driver_xoff;
@@ -4329,7 +4299,7 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 
 	if (bp->msglevel & NETIF_MSG_TIMER) {
 		struct bnx2x_fastpath *fp0_rx = bp->fp;
-		struct bnx2x_fastpath *fp0_tx = &(bp->fp[bp->num_rx_queues]);
+		struct bnx2x_fastpath *fp0_tx = bp->fp;
 		struct tstorm_per_client_stats *old_tclient =
 							&bp->fp->old_tclient;
 		struct bnx2x_eth_q_stats *qstats = &bp->fp->eth_q_stats;
@@ -4984,7 +4954,7 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 
 	if (bp->flags & TPA_ENABLE_FLAG) {
 
-		for_each_rx_queue(bp, j) {
+		for_each_queue(bp, j) {
 			struct bnx2x_fastpath *fp = &bp->fp[j];
 
 			for (i = 0; i < max_agg_queues; i++) {
@@ -5007,16 +4977,13 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 		}
 	}
 
-	for_each_rx_queue(bp, j) {
+	for_each_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		fp->rx_bd_cons = 0;
 		fp->rx_cons_sb = BNX2X_RX_SB_INDEX;
 		fp->rx_bd_cons_sb = BNX2X_RX_SB_BD_INDEX;
 
-		/* Mark queue as Rx */
-		fp->is_rx_queue = 1;
-
 		/* "next page" elements initialization */
 		/* SGE ring */
 		for (i = 1; i <= NUM_RX_SGE_PAGES; i++) {
@@ -5122,7 +5089,7 @@ static void bnx2x_init_tx_ring(struct bnx2x *bp)
 {
 	int i, j;
 
-	for_each_tx_queue(bp, j) {
+	for_each_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		for (i = 1; i <= NUM_TX_RINGS; i++) {
@@ -5148,10 +5115,6 @@ static void bnx2x_init_tx_ring(struct bnx2x *bp)
 		fp->tx_cons_sb = BNX2X_TX_SB_INDEX;
 		fp->tx_pkt = 0;
 	}
-
-	/* clean tx statistics */
-	for_each_rx_queue(bp, i)
-		bnx2x_fp(bp, i, tx_pkt) = 0;
 }
 
 static void bnx2x_init_sp_ring(struct bnx2x *bp)
@@ -5180,7 +5143,8 @@ static void bnx2x_init_context(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_rx_queue(bp, i) {
+	/* Rx */
+	for_each_queue(bp, i) {
 		struct eth_context *context = bnx2x_sp(bp, context[i].eth);
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		u8 cl_id = fp->cl_id;
@@ -5232,10 +5196,11 @@ static void bnx2x_init_context(struct bnx2x *bp)
 					       ETH_CONNECTION_TYPE);
 	}
 
-	for_each_tx_queue(bp, i) {
+	/* Tx */
+	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		struct eth_context *context =
-			bnx2x_sp(bp, context[i - bp->num_rx_queues].eth);
+			bnx2x_sp(bp, context[i].eth);
 
 		context->cstorm_st_context.sb_index_number =
 						C_SB_ETH_TX_CQ_INDEX;
@@ -5263,7 +5228,7 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
 	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
 		REG_WR8(bp, BAR_TSTRORM_INTMEM +
 			TSTORM_INDIRECTION_TABLE_OFFSET(func) + i,
-			bp->fp->cl_id + (i % bp->num_rx_queues));
+			bp->fp->cl_id + (i % bp->num_queues));
 }
 
 static void bnx2x_set_client_config(struct bnx2x *bp)
@@ -5507,7 +5472,7 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 		min((u32)(min((u32)8, (u32)MAX_SKB_FRAGS) *
 			  SGE_PAGE_SIZE * PAGES_PER_SGE),
 		    (u32)0xffff);
-	for_each_rx_queue(bp, i) {
+	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		REG_WR(bp, BAR_USTRORM_INTMEM +
@@ -5542,7 +5507,7 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 		rx_pause.cqe_thr_high = 350;
 		rx_pause.sge_thr_high = 0;
 
-		for_each_rx_queue(bp, i) {
+		for_each_queue(bp, i) {
 			struct bnx2x_fastpath *fp = &bp->fp[i];
 
 			if (!fp->disable_tpa) {
@@ -5637,9 +5602,6 @@ static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 #else
 		fp->sb_id = fp->cl_id;
 #endif
-		/* Suitable Rx and Tx SBs are served by the same client */
-		if (i >= bp->num_rx_queues)
-			fp->cl_id -= bp->num_rx_queues;
 		DP(NETIF_MSG_IFUP,
 		   "queue[%d]:  bnx2x_init_sb(%p,%p)  cl_id %d  sb %d\n",
 		   i, bp, fp->status_blk, fp->cl_id, fp->sb_id);
@@ -6749,7 +6711,7 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 			       sizeof(struct host_status_block));
 	}
 	/* Rx */
-	for_each_rx_queue(bp, i) {
+	for_each_queue(bp, i) {
 
 		/* fastpath rx rings: rx_buf rx_desc rx_comp */
 		BNX2X_FREE(bnx2x_fp(bp, i, rx_buf_ring));
@@ -6769,7 +6731,7 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 			       BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
 	}
 	/* Tx */
-	for_each_tx_queue(bp, i) {
+	for_each_queue(bp, i) {
 
 		/* fastpath tx rings: tx_buf tx_desc */
 		BNX2X_FREE(bnx2x_fp(bp, i, tx_buf_ring));
@@ -6831,7 +6793,7 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 				sizeof(struct host_status_block));
 	}
 	/* Rx */
-	for_each_rx_queue(bp, i) {
+	for_each_queue(bp, i) {
 
 		/* fastpath rx rings: rx_buf rx_desc rx_comp */
 		BNX2X_ALLOC(bnx2x_fp(bp, i, rx_buf_ring),
@@ -6853,7 +6815,7 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 				BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
 	}
 	/* Tx */
-	for_each_tx_queue(bp, i) {
+	for_each_queue(bp, i) {
 
 		/* fastpath tx rings: tx_buf tx_desc */
 		BNX2X_ALLOC(bnx2x_fp(bp, i, tx_buf_ring),
@@ -6909,7 +6871,7 @@ static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_tx_queue(bp, i) {
+	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		u16 bd_cons = fp->tx_bd_cons;
@@ -6927,7 +6889,7 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 {
 	int i, j;
 
-	for_each_rx_queue(bp, j) {
+	for_each_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
 		for (i = 0; i < NUM_RX_BD; i++) {
@@ -7042,12 +7004,8 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 #endif
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
-
-		if (i < bp->num_rx_queues)
-			sprintf(fp->name, "%s-rx-%d", bp->dev->name, i);
-		else
-			sprintf(fp->name, "%s-tx-%d",
-				bp->dev->name, i - bp->num_rx_queues);
+		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
+			 bp->dev->name, i);
 
 		rc = request_irq(bp->msix_table[i + offset].vector,
 				 bnx2x_msix_fp_int, 0, fp->name, fp);
@@ -7106,7 +7064,7 @@ static void bnx2x_napi_enable(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_rx_queue(bp, i)
+	for_each_queue(bp, i)
 		napi_enable(&bnx2x_fp(bp, i, napi));
 }
 
@@ -7114,7 +7072,7 @@ static void bnx2x_napi_disable(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_rx_queue(bp, i)
+	for_each_queue(bp, i)
 		napi_disable(&bnx2x_fp(bp, i, napi));
 }
 
@@ -7410,88 +7368,60 @@ static int bnx2x_setup_multi(struct bnx2x *bp, int index)
 
 static int bnx2x_poll(struct napi_struct *napi, int budget);
 
-static void bnx2x_set_int_mode_msix(struct bnx2x *bp, int *num_rx_queues_out,
-				    int *num_tx_queues_out)
+static void bnx2x_set_num_queues_msix(struct bnx2x *bp)
 {
-	int _num_rx_queues = 0, _num_tx_queues = 0;
 
 	switch (bp->multi_mode) {
 	case ETH_RSS_MODE_DISABLED:
-		_num_rx_queues = 1;
-		_num_tx_queues = 1;
+		bp->num_queues = 1;
 		break;
 
 	case ETH_RSS_MODE_REGULAR:
-		if (num_rx_queues)
-			_num_rx_queues = min_t(u32, num_rx_queues,
-					       BNX2X_MAX_QUEUES(bp));
-		else
-			_num_rx_queues = min_t(u32, num_online_cpus(),
-					       BNX2X_MAX_QUEUES(bp));
-
-		if (num_tx_queues)
-			_num_tx_queues = min_t(u32, num_tx_queues,
-					       BNX2X_MAX_QUEUES(bp));
+		if (num_queues)
+			bp->num_queues = min_t(u32, num_queues,
+						  BNX2X_MAX_QUEUES(bp));
 		else
-			_num_tx_queues = min_t(u32, num_online_cpus(),
-					       BNX2X_MAX_QUEUES(bp));
-
-		/* There must be not more Tx queues than Rx queues */
-		if (_num_tx_queues > _num_rx_queues) {
-			BNX2X_ERR("number of tx queues (%d) > "
-				  "number of rx queues (%d)"
-				  "  defaulting to %d\n",
-				  _num_tx_queues, _num_rx_queues,
-				  _num_rx_queues);
-			_num_tx_queues = _num_rx_queues;
-		}
+			bp->num_queues = min_t(u32, num_online_cpus(),
+						  BNX2X_MAX_QUEUES(bp));
 		break;
 
 
 	default:
-		_num_rx_queues = 1;
-		_num_tx_queues = 1;
+		bp->num_queues = 1;
 		break;
 	}
-
-	*num_rx_queues_out = _num_rx_queues;
-	*num_tx_queues_out = _num_tx_queues;
 }
 
-static int bnx2x_set_int_mode(struct bnx2x *bp)
+static int bnx2x_set_num_queues(struct bnx2x *bp)
 {
 	int rc = 0;
 
 	switch (int_mode) {
 	case INT_MODE_INTx:
 	case INT_MODE_MSI:
-		bp->num_rx_queues = 1;
-		bp->num_tx_queues = 1;
+		bp->num_queues = 1;
 		DP(NETIF_MSG_IFUP, "set number of queues to 1\n");
 		break;
 
 	case INT_MODE_MSIX:
 	default:
-		/* Set interrupt mode according to bp->multi_mode value */
-		bnx2x_set_int_mode_msix(bp, &bp->num_rx_queues,
-					&bp->num_tx_queues);
+		/* Set number of queues according to bp->multi_mode value */
+		bnx2x_set_num_queues_msix(bp);
 
-		DP(NETIF_MSG_IFUP, "set number of queues to: rx %d tx %d\n",
-		   bp->num_rx_queues, bp->num_tx_queues);
+		DP(NETIF_MSG_IFUP, "set number of queues to %d\n",
+		   bp->num_queues);
 
 		/* if we can't use MSI-X we only need one fp,
 		 * so try to enable MSI-X with the requested number of fp's
 		 * and fallback to MSI or legacy INTx with one fp
 		 */
 		rc = bnx2x_enable_msix(bp);
-		if (rc) {
+		if (rc)
 			/* failed to enable MSI-X */
-			bp->num_rx_queues = 1;
-			bp->num_tx_queues = 1;
-		}
+			bp->num_queues = 1;
 		break;
 	}
-	bp->dev->real_num_tx_queues = bp->num_tx_queues;
+	bp->dev->real_num_tx_queues = bp->num_queues;
 	return rc;
 }
 
@@ -7513,16 +7443,16 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
 
-	rc = bnx2x_set_int_mode(bp);
+	rc = bnx2x_set_num_queues(bp);
 
 	if (bnx2x_alloc_mem(bp))
 		return -ENOMEM;
 
-	for_each_rx_queue(bp, i)
+	for_each_queue(bp, i)
 		bnx2x_fp(bp, i, disable_tpa) =
 					((bp->flags & TPA_ENABLE_FLAG) == 0);
 
-	for_each_rx_queue(bp, i)
+	for_each_queue(bp, i)
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
 			       bnx2x_poll, 128);
 
@@ -7536,7 +7466,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 	} else {
 		/* Fall to INTx if failed to enable MSI-X due to lack of
-		   memory (in bnx2x_set_int_mode()) */
+		   memory (in bnx2x_set_num_queues()) */
 		if ((rc != -ENOMEM) && (int_mode != INT_MODE_INTx))
 			bnx2x_enable_msi(bp);
 		bnx2x_ack_int(bp);
@@ -7730,14 +7660,14 @@ load_error3:
 	bp->port.pmf = 0;
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
-	for_each_rx_queue(bp, i)
+	for_each_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
 load_error2:
 	/* Release IRQs */
 	bnx2x_free_irq(bp);
 load_error1:
 	bnx2x_napi_disable(bp);
-	for_each_rx_queue(bp, i)
+	for_each_queue(bp, i)
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 	bnx2x_free_mem(bp);
 
@@ -7928,7 +7858,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	bnx2x_free_irq(bp);
 
 	/* Wait until tx fastpath tasks complete */
-	for_each_tx_queue(bp, i) {
+	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		cnt = 1000;
@@ -8071,9 +8001,9 @@ unload_error:
 
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
-	for_each_rx_queue(bp, i)
+	for_each_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
-	for_each_rx_queue(bp, i)
+	for_each_queue(bp, i)
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 	bnx2x_free_mem(bp);
 
@@ -10269,7 +10199,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	struct sk_buff *skb;
 	unsigned char *packet;
 	struct bnx2x_fastpath *fp_rx = &bp->fp[0];
-	struct bnx2x_fastpath *fp_tx = &bp->fp[bp->num_rx_queues];
+	struct bnx2x_fastpath *fp_tx = &bp->fp[0];
 	u16 tx_start_idx, tx_idx;
 	u16 rx_start_idx, rx_idx;
 	u16 pkt_prod, bd_prod;
@@ -10346,7 +10276,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 
 	fp_tx->tx_db.data.prod += 2;
 	barrier();
-	DOORBELL(bp, fp_tx->index - bp->num_rx_queues, fp_tx->tx_db.raw);
+	DOORBELL(bp, fp_tx->index, fp_tx->tx_db.raw);
 
 	mmiowb();
 
@@ -10725,7 +10655,7 @@ static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 	switch(stringset) {
 	case ETH_SS_STATS:
 		if (is_multi(bp)) {
-			num_stats = BNX2X_NUM_Q_STATS * bp->num_rx_queues;
+			num_stats = BNX2X_NUM_Q_STATS * bp->num_queues;
 			if (!IS_E1HMF_MODE_STAT(bp))
 				num_stats += BNX2X_NUM_STATS;
 		} else {
@@ -10756,7 +10686,7 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 	case ETH_SS_STATS:
 		if (is_multi(bp)) {
 			k = 0;
-			for_each_rx_queue(bp, i) {
+			for_each_queue(bp, i) {
 				for (j = 0; j < BNX2X_NUM_Q_STATS; j++)
 					sprintf(buf + (k + j)*ETH_GSTRING_LEN,
 						bnx2x_q_stats_arr[j].string, i);
@@ -10793,7 +10723,7 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 
 	if (is_multi(bp)) {
 		k = 0;
-		for_each_rx_queue(bp, i) {
+		for_each_queue(bp, i) {
 			hw_stats = (u32 *)&bp->fp[i].eth_q_stats;
 			for (j = 0; j < BNX2X_NUM_Q_STATS; j++) {
 				if (bnx2x_q_stats_arr[j].size == 0) {
@@ -10989,54 +10919,60 @@ static inline int bnx2x_has_rx_work(struct bnx2x_fastpath *fp)
 
 static int bnx2x_poll(struct napi_struct *napi, int budget)
 {
+	int work_done = 0;
 	struct bnx2x_fastpath *fp = container_of(napi, struct bnx2x_fastpath,
 						 napi);
 	struct bnx2x *bp = fp->bp;
-	int work_done = 0;
 
+	while (1) {
 #ifdef BNX2X_STOP_ON_ERROR
-	if (unlikely(bp->panic))
-		goto poll_panic;
+		if (unlikely(bp->panic)) {
+			napi_complete(napi);
+			return 0;
+		}
 #endif
 
-	prefetch(fp->rx_buf_ring[RX_BD(fp->rx_bd_cons)].skb);
-	prefetch((char *)(fp->rx_buf_ring[RX_BD(fp->rx_bd_cons)].skb) + 256);
-
-	bnx2x_update_fpsb_idx(fp);
-
-	if (bnx2x_has_rx_work(fp)) {
-		work_done = bnx2x_rx_int(fp, budget);
+		if (bnx2x_has_tx_work(fp))
+			bnx2x_tx_int(fp);
 
-		/* must not complete if we consumed full budget */
-		if (work_done >= budget)
-			goto poll_again;
-	}
+		if (bnx2x_has_rx_work(fp)) {
+			work_done += bnx2x_rx_int(fp, budget - work_done);
 
-	/* bnx2x_has_rx_work() reads the status block, thus we need to
-	 * ensure that status block indices have been actually read
-	 * (bnx2x_update_fpsb_idx) prior to this check (bnx2x_has_rx_work)
-	 * so that we won't write the "newer" value of the status block to IGU
-	 * (if there was a DMA right after bnx2x_has_rx_work and
-	 * if there is no rmb, the memory reading (bnx2x_update_fpsb_idx)
-	 * may be postponed to right before bnx2x_ack_sb). In this case
-	 * there will never be another interrupt until there is another update
-	 * of the status block, while there is still unhandled work.
-	 */
-	rmb();
+			/* must not complete if we consumed full budget */
+			if (work_done >= budget)
+				break;
+		}
 
-	if (!bnx2x_has_rx_work(fp)) {
-#ifdef BNX2X_STOP_ON_ERROR
-poll_panic:
-#endif
-		napi_complete(napi);
+		/* Fall out from the NAPI loop if needed */
+		if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
+			bnx2x_update_fpsb_idx(fp);
+		/* bnx2x_has_rx_work() reads the status block, thus we need
+		 * to ensure that status block indices have been actually read
+		 * (bnx2x_update_fpsb_idx) prior to this check
+		 * (bnx2x_has_rx_work) so that we won't write the "newer"
+		 * value of the status block to IGU (if there was a DMA right
+		 * after bnx2x_has_rx_work and if there is no rmb, the memory
+		 * reading (bnx2x_update_fpsb_idx) may be postponed to right
+		 * before bnx2x_ack_sb). In this case there will never be
+		 * another interrupt until there is another update of the
+		 * status block, while there is still unhandled work.
+		 */
+			rmb();
 
-		bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
-			     le16_to_cpu(fp->fp_u_idx), IGU_INT_NOP, 1);
-		bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
-			     le16_to_cpu(fp->fp_c_idx), IGU_INT_ENABLE, 1);
+			if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
+				napi_complete(napi);
+				/* Re-enable interrupts */
+				bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
+					     le16_to_cpu(fp->fp_c_idx),
+					     IGU_INT_NOP, 1);
+				bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
+					     le16_to_cpu(fp->fp_u_idx),
+					     IGU_INT_ENABLE, 1);
+				break;
+			}
+		}
 	}
 
-poll_again:
 	return work_done;
 }
 
@@ -11221,7 +11157,7 @@ exit_lbl:
 static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	struct bnx2x_fastpath *fp, *fp_stat;
+	struct bnx2x_fastpath *fp;
 	struct netdev_queue *txq;
 	struct sw_tx_bd *tx_buf;
 	struct eth_tx_start_bd *tx_start_bd;
@@ -11243,11 +11179,10 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	fp_index = skb_get_queue_mapping(skb);
 	txq = netdev_get_tx_queue(dev, fp_index);
 
-	fp = &bp->fp[fp_index + bp->num_rx_queues];
-	fp_stat = &bp->fp[fp_index];
+	fp = &bp->fp[fp_index];
 
 	if (unlikely(bnx2x_tx_avail(fp) < (skb_shinfo(skb)->nr_frags + 3))) {
-		fp_stat->eth_q_stats.driver_xoff++;
+		fp->eth_q_stats.driver_xoff++;
 		netif_tx_stop_queue(txq);
 		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
 		return NETDEV_TX_BUSY;
@@ -11473,7 +11408,7 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	fp->tx_db.data.prod += nbd;
 	barrier();
-	DOORBELL(bp, fp->index - bp->num_rx_queues, fp->tx_db.raw);
+	DOORBELL(bp, fp->index, fp->tx_db.raw);
 
 	mmiowb();
 
@@ -11484,11 +11419,11 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* We want bnx2x_tx_int to "see" the updated tx_bd_prod
 		   if we put Tx into XOFF state. */
 		smp_mb();
-		fp_stat->eth_q_stats.driver_xoff++;
+		fp->eth_q_stats.driver_xoff++;
 		if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
 			netif_tx_wake_queue(txq);
 	}
-	fp_stat->tx_pkt++;
+	fp->tx_pkt++;
 
 	return NETDEV_TX_OK;
 }
@@ -12376,9 +12311,9 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
-	for_each_rx_queue(bp, i)
+	for_each_queue(bp, i)
 		bnx2x_free_rx_sge_range(bp, bp->fp + i, NUM_RX_SGE);
-	for_each_rx_queue(bp, i)
+	for_each_queue(bp, i)
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 	bnx2x_free_mem(bp);
 
-- 
1.6.3.3




