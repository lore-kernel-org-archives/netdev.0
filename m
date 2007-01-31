From: Divy Le Ray <None@chelsio.com>
Subject: [PATCH 3/10] cxgb3 - remove SW Tx credits coalescing
Date: Tue, 30 Jan 2007 19:43:56 -0800
Message-ID: <20070131034356.8596.84856.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932622AbXAaDo0@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Remove tx credit coalescing done in SW.
The HW is caring care of it already.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |   75 +++++++++--------------------------------------
 1 files changed, 14 insertions(+), 61 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index ccea06a..8b3c824 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1550,33 +1550,6 @@ static inline int rx_offload(struct t3cd
 }
 
 /**
- *	update_tx_completed - update the number of processed Tx descriptors
- *	@qs: the queue set to update
- *	@idx: which Tx queue within the set to update
- *	@credits: number of new processed descriptors
- *	@tx_completed: accumulates credits for the queues
- *
- *	Updates the number of completed Tx descriptors for a queue set's Tx
- *	queue.  On UP systems we updated the information immediately but on
- *	MP we accumulate the credits locally and update the Tx queue when we
- *	reach a threshold to avoid cache-line bouncing.
- */
-static inline void update_tx_completed(struct sge_qset *qs, int idx,
-				       unsigned int credits,
-				       unsigned int tx_completed[])
-{
-#ifdef CONFIG_SMP
-	tx_completed[idx] += credits;
-	if (tx_completed[idx] > 32) {
-		qs->txq[idx].processed += tx_completed[idx];
-		tx_completed[idx] = 0;
-	}
-#else
-	qs->txq[idx].processed += credits;
-#endif
-}
-
-/**
  *	restart_tx - check whether to restart suspended Tx queues
  *	@qs: the queue set to resume
  *
@@ -1656,13 +1629,12 @@ static void rx_eth(struct adapter *adap,
  *	handle_rsp_cntrl_info - handles control information in a response
  *	@qs: the queue set corresponding to the response
  *	@flags: the response control flags
- *	@tx_completed: accumulates completion credits for the Tx queues
  *
  *	Handles the control information of an SGE response, such as GTS
  *	indications and completion credits for the queue set's Tx queues.
+ *	HW coalesces credits, we don't do any extra SW coalescing.
  */
-static inline void handle_rsp_cntrl_info(struct sge_qset *qs, u32 flags,
-					 unsigned int tx_completed[])
+static inline void handle_rsp_cntrl_info(struct sge_qset *qs, u32 flags)
 {
 	unsigned int credits;
 
@@ -1671,37 +1643,21 @@ static inline void handle_rsp_cntrl_info
 		clear_bit(TXQ_RUNNING, &qs->txq[TXQ_ETH].flags);
 #endif
 
-	/* ETH credits are already coalesced, return them immediately. */
 	credits = G_RSPD_TXQ0_CR(flags);
 	if (credits)
 		qs->txq[TXQ_ETH].processed += credits;
 
+	credits = G_RSPD_TXQ2_CR(flags);
+	if (credits)
+		qs->txq[TXQ_CTRL].processed += credits;
+
 # if USE_GTS
 	if (flags & F_RSPD_TXQ1_GTS)
 		clear_bit(TXQ_RUNNING, &qs->txq[TXQ_OFLD].flags);
 # endif
-	update_tx_completed(qs, TXQ_OFLD, G_RSPD_TXQ1_CR(flags), tx_completed);
-	update_tx_completed(qs, TXQ_CTRL, G_RSPD_TXQ2_CR(flags), tx_completed);
-}
-
-/**
- *	flush_tx_completed - returns accumulated Tx completions to Tx queues
- *	@qs: the queue set to update
- *	@tx_completed: pending completion credits to return to Tx queues
- *
- *	Updates the number of completed Tx descriptors for a queue set's Tx
- *	queues with the credits pending in @tx_completed.  This does something
- *	only on MP systems as on UP systems we return the credits immediately.
- */
-static inline void flush_tx_completed(struct sge_qset *qs,
-				      unsigned int tx_completed[])
-{
-#if defined(CONFIG_SMP)
-	if (tx_completed[TXQ_OFLD])
-		qs->txq[TXQ_OFLD].processed += tx_completed[TXQ_OFLD];
-	if (tx_completed[TXQ_CTRL])
-		qs->txq[TXQ_CTRL].processed += tx_completed[TXQ_CTRL];
-#endif
+	credits = G_RSPD_TXQ1_CR(flags);
+	if (credits)
+		qs->txq[TXQ_OFLD].processed += credits;
 }
 
 /**
@@ -1784,7 +1740,7 @@ static int process_responses(struct adap
 	struct sge_rspq *q = &qs->rspq;
 	struct rsp_desc *r = &q->desc[q->cidx];
 	int budget_left = budget;
-	unsigned int sleeping = 0, tx_completed[3] = { 0, 0, 0 };
+	unsigned int sleeping = 0;
 	struct sk_buff *offload_skbs[RX_BUNDLE_SIZE];
 	int ngathered = 0;
 
@@ -1837,7 +1793,7 @@ static int process_responses(struct adap
 
 		if (flags & RSPD_CTRL_MASK) {
 			sleeping |= flags & RSPD_GTS_MASK;
-			handle_rsp_cntrl_info(qs, flags, tx_completed);
+			handle_rsp_cntrl_info(qs, flags);
 		}
 
 		r++;
@@ -1868,7 +1824,6 @@ static int process_responses(struct adap
 		--budget_left;
 	}
 
-	flush_tx_completed(qs, tx_completed);
 	deliver_partial_bundle(&adap->tdev, q, offload_skbs, ngathered);
 	if (sleeping)
 		check_ring_db(adap, qs, sleeping);
@@ -1953,7 +1908,7 @@ static int process_pure_responses(struct
 				  struct rsp_desc *r)
 {
 	struct sge_rspq *q = &qs->rspq;
-	unsigned int sleeping = 0, tx_completed[3] = { 0, 0, 0 };
+	unsigned int sleeping = 0;
 
 	do {
 		u32 flags = ntohl(r->flags);
@@ -1968,7 +1923,7 @@ static int process_pure_responses(struct
 
 		if (flags & RSPD_CTRL_MASK) {
 			sleeping |= flags & RSPD_GTS_MASK;
-			handle_rsp_cntrl_info(qs, flags, tx_completed);
+			handle_rsp_cntrl_info(qs, flags);
 		}
 
 		q->pure_rsps++;
@@ -1978,8 +1933,6 @@ static int process_pure_responses(struct
 		}
 	} while (is_new_response(r, q) && is_pure_response(r));
 
-	flush_tx_completed(qs, tx_completed);
-
 	if (sleeping)
 		check_ring_db(adap, qs, sleeping);
 
@@ -2630,7 +2583,7 @@ void t3_sge_init(struct adapter *adap, s
 		     V_LORCQDRBTHRSH(512));
 	t3_write_reg(adap, A_SG_TIMER_TICK, core_ticks_per_usec(adap) / 10);
 	t3_write_reg(adap, A_SG_CMDQ_CREDIT_TH, V_THRESHOLD(32) |
-		     V_TIMEOUT(100 * core_ticks_per_usec(adap)));
+		     V_TIMEOUT(200 * core_ticks_per_usec(adap)));
 	t3_write_reg(adap, A_SG_HI_DRB_HI_THRSH, 1000);
 	t3_write_reg(adap, A_SG_HI_DRB_LO_THRSH, 256);
 	t3_write_reg(adap, A_SG_LO_DRB_HI_THRSH, 1000);
