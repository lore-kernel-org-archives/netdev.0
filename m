From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 2/3] bnx2x: merge fp->disable_tpa with fp->mode
Date: Tue, 28 Apr 2015 11:34:22 +0200
Message-ID: <1430213663-5657-3-git-send-email-mschmidt@redhat.com>
References: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932786AbbD1Jec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 05:34:32 -0400
In-Reply-To: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is simpler to have the TPA mode as one three-state variable.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 26 ++++++++++++------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c |  2 +-
 5 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 355d5fea5b..2a41604cdd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -521,6 +521,7 @@ struct bnx2x_fp_txdata {
 };
 
 enum bnx2x_tpa_mode_t {
+	TPA_MODE_DISABLED,
 	TPA_MODE_LRO,
 	TPA_MODE_GRO
 };
@@ -589,7 +590,6 @@ struct bnx2x_fastpath {
 
 	/* TPA related */
 	struct bnx2x_agg_info	*tpa_info;
-	u8			disable_tpa;
 #ifdef BNX2X_STOP_ON_ERROR
 	u64			tpa_queue_used;
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index dcdbd00d02..84612b082b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -947,10 +947,10 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			u16 frag_size, pages;
 #ifdef BNX2X_STOP_ON_ERROR
 			/* sanity check */
-			if (fp->disable_tpa &&
+			if (fp->mode == TPA_MODE_DISABLED &&
 			    (CQE_TYPE_START(cqe_fp_type) ||
 			     CQE_TYPE_STOP(cqe_fp_type)))
-				BNX2X_ERR("START/STOP packet while disable_tpa type %x\n",
+				BNX2X_ERR("START/STOP packet while TPA disabled, type %x\n",
 					  CQE_TYPE(cqe_fp_type));
 #endif
 
@@ -1396,7 +1396,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 		DP(NETIF_MSG_IFUP,
 		   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, fp->rx_buf_size);
 
-		if (!fp->disable_tpa) {
+		if (fp->mode != TPA_MODE_DISABLED) {
 			/* Fill the per-aggregation pool */
 			for (i = 0; i < MAX_AGG_QS(bp); i++) {
 				struct bnx2x_agg_info *tpa_info =
@@ -1410,7 +1410,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 					BNX2X_ERR("Failed to allocate TPA skb pool for queue[%d] - disabling TPA on this queue!\n",
 						  j);
 					bnx2x_free_tpa_pool(bp, fp, i);
-					fp->disable_tpa = 1;
+					fp->mode = TPA_MODE_DISABLED;
 					break;
 				}
 				dma_unmap_addr_set(first_buf, mapping, 0);
@@ -1438,7 +1438,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 								ring_prod);
 					bnx2x_free_tpa_pool(bp, fp,
 							    MAX_AGG_QS(bp));
-					fp->disable_tpa = 1;
+					fp->mode = TPA_MODE_DISABLED;
 					ring_prod = 0;
 					break;
 				}
@@ -1560,7 +1560,7 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 
 		bnx2x_free_rx_bds(fp);
 
-		if (!fp->disable_tpa)
+		if (fp->mode != TPA_MODE_DISABLED)
 			bnx2x_free_tpa_pool(bp, fp, MAX_AGG_QS(bp));
 	}
 }
@@ -2477,19 +2477,19 @@ static void bnx2x_bz_fp(struct bnx2x *bp, int index)
 	/* set the tpa flag for each queue. The tpa flag determines the queue
 	 * minimal size so it must be set prior to queue memory allocation
 	 */
-	fp->disable_tpa = !(bp->flags & TPA_ENABLE_FLAG ||
-				  (bp->flags & GRO_ENABLE_FLAG &&
-				   bnx2x_mtu_allows_gro(bp->dev->mtu)));
 	if (bp->flags & TPA_ENABLE_FLAG)
 		fp->mode = TPA_MODE_LRO;
-	else if (bp->flags & GRO_ENABLE_FLAG)
+	else if (bp->flags & GRO_ENABLE_FLAG &&
+		 bnx2x_mtu_allows_gro(bp->dev->mtu))
 		fp->mode = TPA_MODE_GRO;
+	else
+		fp->mode = TPA_MODE_DISABLED;
 
 	/* We don't want TPA if it's disabled in bp
 	 * or if this is an FCoE L2 ring.
 	 */
 	if (bp->disable_tpa || IS_FCOE_FP(fp))
-		fp->disable_tpa = 1;
+		fp->mode = TPA_MODE_DISABLED;
 }
 
 int bnx2x_load_cnic(struct bnx2x *bp)
@@ -2610,7 +2610,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/*
 	 * Zero fastpath structures preserving invariants like napi, which are
 	 * allocated only once, fp index, max_cos, bp pointer.
-	 * Also set fp->disable_tpa and txdata_ptr.
+	 * Also set fp->mode and txdata_ptr.
 	 */
 	DP(NETIF_MSG_IFUP, "num queues: %d", bp->num_queues);
 	for_each_queue(bp, i)
@@ -4545,7 +4545,7 @@ alloc_mem_err:
 	 * In these cases we disable the queue
 	 * Min size is different for OOO, TPA and non-TPA queues
 	 */
-	if (ring_size < (fp->disable_tpa ?
+	if (ring_size < (fp->mode == TPA_MODE_DISABLED ?
 				MIN_RX_SIZE_NONTPA : MIN_RX_SIZE_TPA)) {
 			/* release memory allocated for this queue */
 			bnx2x_free_fp_mem_at(bp, index);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index adcacda7af..d7a71758e8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -969,7 +969,7 @@ static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
 {
 	int i;
 
-	if (fp->disable_tpa)
+	if (fp->mode == TPA_MODE_DISABLED)
 		return;
 
 	for (i = 0; i < last; i++)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2d067c937b..64ea5adf72 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3128,7 +3128,7 @@ static unsigned long bnx2x_get_q_flags(struct bnx2x *bp,
 		__set_bit(BNX2X_Q_FLG_FORCE_DEFAULT_PRI, &flags);
 	}
 
-	if (!fp->disable_tpa) {
+	if (fp->mode != TPA_MODE_DISABLED) {
 		__set_bit(BNX2X_Q_FLG_TPA, &flags);
 		__set_bit(BNX2X_Q_FLG_TPA_IPV6, &flags);
 		if (fp->mode == TPA_MODE_GRO)
@@ -3176,7 +3176,7 @@ static void bnx2x_pf_rx_q_prep(struct bnx2x *bp,
 	u16 sge_sz = 0;
 	u16 tpa_agg_size = 0;
 
-	if (!fp->disable_tpa) {
+	if (fp->mode != TPA_MODE_DISABLED) {
 		pause->sge_th_lo = SGE_TH_LO(bp);
 		pause->sge_th_hi = SGE_TH_HI(bp);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 15b2d16475..06b8c0d8fd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -594,7 +594,7 @@ int bnx2x_vfpf_setup_q(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	bnx2x_vfpf_prep(bp, &req->first_tlv, CHANNEL_TLV_SETUP_Q, sizeof(*req));
 
 	/* select tpa mode to request */
-	if (!fp->disable_tpa) {
+	if (fp->mode != TPA_MODE_DISABLED) {
 		flags |= VFPF_QUEUE_FLG_TPA;
 		flags |= VFPF_QUEUE_FLG_TPA_IPV6;
 		if (fp->mode == TPA_MODE_GRO)
-- 
2.1.0
