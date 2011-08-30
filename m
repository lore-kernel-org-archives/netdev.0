From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 6/7] bnx2x: move fp->disable_tpa to ->flags
Date: Tue, 30 Aug 2011 16:30:45 +0200
Message-ID: <1314714646-3642-7-git-send-email-mschmidt@redhat.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Cc: vladz@broadcom.com, dmitry@broadcom.com, eilong@broadcom.com,
	Michal Schmidt <mschmidt@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62693 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754535Ab1H3ObU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 10:31:20 -0400
In-Reply-To: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Store the boolean fp->disable_tpa in a more general 'flags' field.
Later more flags will be added.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   31 ++++++++++------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 +-
 4 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index c0d2d9c..02fa7a7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -477,6 +477,8 @@ struct bnx2x_fastpath {
 	u8			cl_qzone_id;
 	u8			fw_sb_id;	/* status block number in FW */
 	u8			igu_sb_id;	/* status block number in HW */
+	u8			flags;
+#define FP_TPA			(1 << 0)	/* TPA enabled */
 
 	u16			rx_bd_prod;
 	u16			rx_bd_cons;
@@ -491,7 +493,6 @@ struct bnx2x_fastpath {
 
 	/* TPA related */
 	struct bnx2x_agg_info	tpa_info[ETH_MAX_AGGREGATION_QUEUES_E1H_E2];
-	u8			disable_tpa;
 #ifdef BNX2X_STOP_ON_ERROR
 	u64			tpa_queue_used;
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index fe5be0c..d45aaa5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -60,15 +60,12 @@ static inline void bnx2x_bz_fp(struct bnx2x *bp, int index)
 
 	/*
 	 * set the tpa flag for each queue. The tpa flag determines the queue
-	 * minimal size so it must be set prior to queue memory allocation
+	 * minimal size so it must be set prior to queue memory allocation.
+	 *
+	 * We don't want TPA on an FCoE L2 ring.
 	 */
-	fp->disable_tpa = ((bp->flags & TPA_ENABLE_FLAG) == 0);
-
-#ifdef BCM_CNIC
-	/* We don't want TPA on an FCoE L2 ring */
-	if (IS_FCOE_FP(fp))
-		fp->disable_tpa = 1;
-#endif
+	if ((bp->flags & TPA_ENABLE_FLAG) && !IS_FCOE_FP(fp))
+		fp->flags = FP_TPA;
 }
 
 /**
@@ -634,9 +631,9 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		if (!CQE_TYPE_FAST(cqe_fp_type)) {
 #ifdef BNX2X_STOP_ON_ERROR
 			/* sanity check */
-			if (fp->disable_tpa)
+			if (!(fp->flags & FP_TPA))
 				BNX2X_ERR("START/STOP packet while "
-					  "disable_tpa type %x\n",
+					  "TPA disabled, type %x\n",
 					  CQE_TYPE(cqe_fp_type));
 #endif
 
@@ -993,7 +990,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 		DP(NETIF_MSG_IFUP,
 		   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, fp->rx_buf_size);
 
-		if (!fp->disable_tpa) {
+		if (fp->flags & FP_TPA) {
 			/* Fill the per-aggregtion pool */
 			for (i = 0; i < max_agg_queues; i++) {
 				struct bnx2x_agg_info *tpa_info =
@@ -1009,7 +1006,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 						  "disabling TPA on this "
 						  "queue!\n", j);
 					bnx2x_free_tpa_pool(bp, fp, i);
-					fp->disable_tpa = 1;
+					fp->flags &= ~FP_TPA;
 					break;
 				}
 				dma_unmap_addr_set(first_buf, mapping, 0);
@@ -1036,7 +1033,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 								ring_prod);
 					bnx2x_free_tpa_pool(bp, fp,
 							    max_agg_queues);
-					fp->disable_tpa = 1;
+					fp->flags &= ~FP_TPA;
 					ring_prod = 0;
 					break;
 				}
@@ -1130,7 +1127,7 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 
 		bnx2x_free_rx_bds(fp);
 
-		if (!fp->disable_tpa)
+		if (fp->flags & FP_TPA)
 			bnx2x_free_tpa_pool(bp, fp, CHIP_IS_E1(bp) ?
 					    ETH_MAX_AGGREGATION_QUEUES_E1 :
 					    ETH_MAX_AGGREGATION_QUEUES_E1H_E2);
@@ -1724,7 +1721,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/*
 	 * Zero fastpath structures preserving invariants like napi, which are
 	 * allocated only once, fp index, max_cos, bp pointer.
-	 * Also set fp->disable_tpa.
+	 * Also set fp->flags.
 	 */
 	for_each_queue(bp, i)
 		bnx2x_bz_fp(bp, i);
@@ -3182,8 +3179,8 @@ alloc_mem_err:
 	 * In these cases we disable the queue
 	 * Min size is different for OOO, TPA and non-TPA queues
 	 */
-	if (ring_size < (fp->disable_tpa ?
-				MIN_RX_SIZE_NONTPA : MIN_RX_SIZE_TPA)) {
+	if (ring_size < ((fp->flags & FP_TPA) ? MIN_RX_SIZE_TPA :
+						MIN_RX_SIZE_NONTPA)) {
 			/* release memory allocated for this queue */
 			bnx2x_free_fp_mem_at(bp, index);
 			return -ENOMEM;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 54d50b7..14b3658 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1013,7 +1013,7 @@ static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
 {
 	int i;
 
-	if (fp->disable_tpa)
+	if (!(fp->flags & FP_TPA))
 		return;
 
 	for (i = 0; i < last; i++)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 617a072..7bc6944 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2709,7 +2709,7 @@ static unsigned long bnx2x_get_q_flags(struct bnx2x *bp,
 	if (IS_FCOE_FP(fp))
 		__set_bit(BNX2X_Q_FLG_FCOE, &flags);
 
-	if (!fp->disable_tpa) {
+	if (fp->flags & FP_TPA) {
 		__set_bit(BNX2X_Q_FLG_TPA, &flags);
 		__set_bit(BNX2X_Q_FLG_TPA_IPV6, &flags);
 	}
@@ -2750,7 +2750,7 @@ static void bnx2x_pf_rx_q_prep(struct bnx2x *bp,
 	u16 sge_sz = 0;
 	u16 tpa_agg_size = 0;
 
-	if (!fp->disable_tpa) {
+	if (fp->flags & FP_TPA) {
 		pause->sge_th_hi = 250;
 		pause->sge_th_lo = 150;
 		tpa_agg_size = min_t(u32,
-- 
1.7.6
