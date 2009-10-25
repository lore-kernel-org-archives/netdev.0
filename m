From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next] bnx2x: Do Tx handling in a separate tasklet.
Date: Sun, 25 Oct 2009 14:19:42 +0200
Message-ID: <1256473182.11634.4.camel@lb-tlvb-vladz.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	Netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4342 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753415AbZJYMTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Oct 2009 08:19:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the 'Tx interrupt work' of each Tx queue from the hardIRQ
context to the separate low-latency tasklet. Otherwise there is a possibility
of a software lockup situation in a Tx softIRQ as it handles freeing all skb's
'freed' in (hard)IRQ context.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    5 ++
 drivers/net/bnx2x_main.c |  160 +++++++++++++++++++++++++++++-----------------
 2 files changed, 105 insertions(+), 60 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index c3b32f7..b29680e 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -259,6 +259,11 @@ struct bnx2x_eth_q_stats {
 struct bnx2x_fastpath {
 
 	struct napi_struct	napi;
+/*
+ * Tx tasklet should not run for more than 1 tick. Then it
+ * should reschedule itself.
+ */
+	struct tasklet_struct	tx_int_task;
 
 	u8			is_rx_queue;
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 59b58d8..0e2c1cb 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -56,8 +56,8 @@
 #include "bnx2x_init_ops.h"
 #include "bnx2x_dump.h"
 
-#define DRV_MODULE_VERSION	"1.52.1-1"
-#define DRV_MODULE_RELDATE	"2009/10/13"
+#define DRV_MODULE_VERSION	"1.52.1-2"
+#define DRV_MODULE_RELDATE	"2009/10/25"
 #define BNX2X_BC_VER		0x040200
 
 #include <linux/firmware.h>
@@ -784,21 +784,13 @@ static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
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
@@ -838,6 +830,9 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	u16 bd_idx = TX_BD(tx_buf->first_bd), new_cons;
 	int nbd;
 
+	/* prefetch skb end pointer to speedup dev_kfree_skb() */
+	prefetch(&skb->end);
+
 	DP(BNX2X_MSG_OFF, "pkt_idx %d  buff @(%p)->skb %p\n",
 	   idx, tx_buf, skb);
 
@@ -882,7 +877,7 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 	/* release skb */
 	WARN_ON(!skb);
-	dev_kfree_skb_any(skb);
+	dev_kfree_skb(skb);
 	tx_buf->first_bd = 0;
 	tx_buf->skb = NULL;
 
@@ -912,12 +907,23 @@ static inline u16 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
 	return (s16)(fp->bp->tx_ring_size) - used;
 }
 
-static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
+static inline int bnx2x_has_tx_work(struct bnx2x_fastpath *fp, u16 sw_cons)
+{
+	u16 hw_cons;
+
+	/* Tell compiler that status block fields can change */
+	barrier();
+	hw_cons = le16_to_cpu(*fp->tx_cons_sb);
+	return hw_cons != sw_cons;
+}
+
+static void bnx2x_tx_int(unsigned long data)
 {
+	struct bnx2x_fastpath *fp = (struct bnx2x_fastpath *)data;
 	struct bnx2x *bp = fp->bp;
 	struct netdev_queue *txq;
 	u16 hw_cons, sw_cons, bd_cons = fp->tx_bd_cons;
-	int done = 0;
+	unsigned long start_time = jiffies;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -928,7 +934,8 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
 	hw_cons = le16_to_cpu(*fp->tx_cons_sb);
 	sw_cons = fp->tx_pkt_cons;
 
-	while (sw_cons != hw_cons) {
+	while ((sw_cons != hw_cons) &&
+	       (start_time == jiffies)) {
 		u16 pkt_cons;
 
 		pkt_cons = TX_BD(sw_cons);
@@ -945,7 +952,6 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
 */
 		bd_cons = bnx2x_free_tx_pkt(bp, fp, pkt_cons);
 		sw_cons++;
-		done++;
 	}
 
 	fp->tx_pkt_cons = sw_cons;
@@ -954,7 +960,8 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
 	/* TBD need a thresh? */
 	if (unlikely(netif_tx_queue_stopped(txq))) {
 
-		/* Need to make the tx_bd_cons update visible to start_xmit()
+		/*
+		 * Need to make the tx_bd_cons update visible to start_xmit()
 		 * before checking for netif_tx_queue_stopped().  Without the
 		 * memory barrier, there is a small possibility that
 		 * start_xmit() will miss it and cause the queue to be stopped
@@ -967,6 +974,32 @@ static void bnx2x_tx_int(struct bnx2x_fastpath *fp)
 		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
 			netif_tx_wake_queue(txq);
 	}
+
+	/*
+	 * If the loop was broken by the timeout or/and there is more
+	 * Tx work to do, reschedule the task, otherwise reenable interrupts.
+	 * Do not restart the task if interrupts are disabled.
+	 */
+	if (likely(atomic_read(&bp->intr_sem) == 0)) {
+		if (bnx2x_has_tx_work(fp, sw_cons))
+			tasklet_hi_schedule(&fp->tx_int_task);
+		else {
+			fp->fp_c_idx =
+			fp->status_blk->c_status_block.status_block_index;
+			/*
+			 * Ensure that IGU status block is actually read and
+			 * the read value is written to the memory before we
+			 * check the Tx work.
+			 */
+			rmb();
+			if (bnx2x_has_tx_work(fp, sw_cons))
+				tasklet_hi_schedule(&fp->tx_int_task);
+			else
+				bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
+					     le16_to_cpu(fp->fp_c_idx),
+					     IGU_INT_ENABLE, 1);
+		}
+	}
 }
 
 #ifdef BCM_CNIC
@@ -1734,6 +1767,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	if (unlikely(bp->panic))
 		return IRQ_HANDLED;
 #endif
+
 	/* Handle Rx or Tx according to MSI-X vector */
 	if (fp->is_rx_queue) {
 		prefetch(fp->rx_cons_sb);
@@ -1745,15 +1779,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 		prefetch(fp->tx_cons_sb);
 		prefetch(&fp->status_blk->c_status_block.status_block_index);
 
-		bnx2x_update_fpsb_idx(fp);
-		rmb();
-		bnx2x_tx_int(fp);
-
-		/* Re-enable interrupts */
-		bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
-			     le16_to_cpu(fp->fp_u_idx), IGU_INT_NOP, 1);
-		bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
-			     le16_to_cpu(fp->fp_c_idx), IGU_INT_ENABLE, 1);
+		tasklet_hi_schedule(&fp->tx_int_task);
 	}
 
 	return IRQ_HANDLED;
@@ -1802,17 +1828,7 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 				prefetch(&fp->status_blk->c_status_block.
 							status_block_index);
 
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
+				tasklet_hi_schedule(&fp->tx_int_task);
 			}
 			status &= ~mask;
 		}
@@ -4673,7 +4689,7 @@ static void bnx2x_timer(unsigned long data)
 		struct bnx2x_fastpath *fp = &bp->fp[0];
 		int rc;
 
-		bnx2x_tx_int(fp);
+		tasklet_hi_schedule(&fp->tx_int_task);
 		rc = bnx2x_rx_int(fp, 1000);
 	}
 
@@ -5117,6 +5133,8 @@ static void bnx2x_init_tx_ring(struct bnx2x *bp)
 	for_each_tx_queue(bp, j) {
 		struct bnx2x_fastpath *fp = &bp->fp[j];
 
+		tasklet_init(&fp->tx_int_task, bnx2x_tx_int, (unsigned long)fp);
+
 		for (i = 1; i <= NUM_TX_RINGS; i++) {
 			struct eth_tx_next_bd *tx_next_bd =
 				&fp->tx_desc_ring[TX_DESC_CNT * i - 1].next_bd;
@@ -7119,20 +7137,38 @@ static void bnx2x_netif_start(struct bnx2x *bp)
 
 	if (intr_sem) {
 		if (netif_running(bp->dev)) {
+			int i;
+
 			bnx2x_napi_enable(bp);
 			bnx2x_int_enable(bp);
 			if (bp->state == BNX2X_STATE_OPEN)
 				netif_tx_wake_all_queues(bp->dev);
+
+			/* Enable Tx tasklets */
+			for_each_tx_queue(bp, i)
+				tasklet_enable(&bp->fp[i].tx_int_task);
 		}
 	}
 }
 
 static void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 {
+	int i;
+
 	bnx2x_int_disable_sync(bp, disable_hw);
 	bnx2x_napi_disable(bp);
 	netif_tx_disable(bp->dev);
 	bp->dev->trans_start = jiffies;	/* prevent tx timeout */
+
+	/* Stop Tx tasklet */
+	for_each_tx_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		/* Stop */
+		tasklet_disable(&fp->tx_int_task);
+		/* Kill */
+		tasklet_kill(&fp->tx_int_task);
+	}
 }
 
 /*
@@ -7931,7 +7967,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		cnt = 1000;
 		while (bnx2x_has_tx_work_unload(fp)) {
 
-			bnx2x_tx_int(fp);
+			bnx2x_tx_int((unsigned long)fp);
 			if (!cnt) {
 				BNX2X_ERR("timeout waiting for queue[%d]\n",
 					  i);
@@ -11004,8 +11040,6 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 	prefetch(fp->rx_buf_ring[RX_BD(fp->rx_bd_cons)].skb);
 	prefetch((char *)(fp->rx_buf_ring[RX_BD(fp->rx_bd_cons)].skb) + 256);
 
-	bnx2x_update_fpsb_idx(fp);
-
 	if (bnx2x_has_rx_work(fp)) {
 		work_done = bnx2x_rx_int(fp, budget);
 
@@ -11014,28 +11048,34 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 			goto poll_again;
 	}
 
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
-
+	/* Fall out from the NAPI loop if needed */
 	if (!bnx2x_has_rx_work(fp)) {
 #ifdef BNX2X_STOP_ON_ERROR
 poll_panic:
 #endif
-		napi_complete(napi);
+		fp->fp_u_idx =
+			fp->status_blk->u_status_block.status_block_index;
+		/*
+		 * bnx2x_has_rx_work() reads the status block, thus we need
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
+		rmb();
 
-		bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
-			     le16_to_cpu(fp->fp_u_idx), IGU_INT_NOP, 1);
-		bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
-			     le16_to_cpu(fp->fp_c_idx), IGU_INT_ENABLE, 1);
+		if (!bnx2x_has_rx_work(fp)) {
+			napi_complete(napi);
+			/* Re-enable interrupts */
+			bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
+				     le16_to_cpu(fp->fp_u_idx),
+				     IGU_INT_ENABLE, 1);
+		}
 	}
 
 poll_again:
-- 
1.6.0.4




