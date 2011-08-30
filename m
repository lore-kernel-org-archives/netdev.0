From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 2/7] bnx2x: remove the 'leading' arguments
Date: Tue, 30 Aug 2011 16:30:41 +0200
Message-ID: <1314714646-3642-3-git-send-email-mschmidt@redhat.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Cc: vladz@broadcom.com, dmitry@broadcom.com, eilong@broadcom.com,
	Michal Schmidt <mschmidt@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31636 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754421Ab1H3ObJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 10:31:09 -0400
In-Reply-To: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whether a queue is leading can be deduced from its index.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    4 +---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   21 +++++++++------------
 4 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 735e491..c0d2d9c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -531,6 +531,7 @@ struct bnx2x_fastpath {
 
 #define IS_ETH_FP(fp)			(fp->index < \
 					 BNX2X_NUM_ETH_QUEUES(fp->bp))
+#define IS_LEADING_FP(fp)		((fp)->index == 0)
 #ifdef BCM_CNIC
 #define IS_FCOE_FP(fp)			(fp->index == FCOE_IDX)
 #define IS_FCOE_IDX(idx)		((idx) == FCOE_IDX)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 5c3eb17..448e301 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1881,7 +1881,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 #endif
 
 	for_each_nondefault_queue(bp, i) {
-		rc = bnx2x_setup_queue(bp, &bp->fp[i], 0);
+		rc = bnx2x_setup_queue(bp, &bp->fp[i]);
 		if (rc)
 			LOAD_ERROR_EXIT(bp, load_error4);
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 5b1f9b5..54d50b7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -109,11 +109,9 @@ void bnx2x__init_func_obj(struct bnx2x *bp);
  *
  * @bp:		driver handle
  * @fp:		pointer to the fastpath structure
- * @leading:	boolean
  *
  */
-int bnx2x_setup_queue(struct bnx2x *bp, struct bnx2x_fastpath *fp,
-		       bool leading);
+int bnx2x_setup_queue(struct bnx2x *bp, struct bnx2x_fastpath *fp);
 
 /**
  * bnx2x_setup_leading - bring up a leading eth queue.
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e7b584b..64314f7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2697,9 +2697,8 @@ static inline unsigned long bnx2x_get_common_flags(struct bnx2x *bp,
 	return flags;
 }
 
-static inline unsigned long bnx2x_get_q_flags(struct bnx2x *bp,
-					      struct bnx2x_fastpath *fp,
-					      bool leading)
+static unsigned long bnx2x_get_q_flags(struct bnx2x *bp,
+				       struct bnx2x_fastpath *fp)
 {
 	unsigned long flags = 0;
 
@@ -2715,7 +2714,7 @@ static inline unsigned long bnx2x_get_q_flags(struct bnx2x *bp,
 		__set_bit(BNX2X_Q_FLG_TPA_IPV6, &flags);
 	}
 
-	if (leading) {
+	if (IS_LEADING_FP(fp)) {
 		__set_bit(BNX2X_Q_FLG_LEADING_RSS, &flags);
 		__set_bit(BNX2X_Q_FLG_MCAST, &flags);
 	}
@@ -6966,7 +6965,7 @@ int bnx2x_set_eth_mac(struct bnx2x *bp, bool set)
 
 int bnx2x_setup_leading(struct bnx2x *bp)
 {
-	return bnx2x_setup_queue(bp, &bp->fp[0], 1);
+	return bnx2x_setup_queue(bp, &bp->fp[0]);
 }
 
 /**
@@ -7177,10 +7176,10 @@ static inline void bnx2x_pf_q_prep_init(struct bnx2x *bp,
 			&bp->context.vcxt[fp->txdata[cos].cid].eth;
 }
 
-int bnx2x_setup_tx_only(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+static int bnx2x_setup_tx_only(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			struct bnx2x_queue_state_params *q_params,
 			struct bnx2x_queue_setup_tx_only_params *tx_only_params,
-			int tx_index, bool leading)
+			int tx_index)
 {
 	memset(tx_only_params, 0, sizeof(*tx_only_params));
 
@@ -7216,14 +7215,12 @@ int bnx2x_setup_tx_only(struct bnx2x *bp, struct bnx2x_fastpath *fp,
  *
  * @bp:		driver handle
  * @fp:		pointer to fastpath
- * @leading:	is leading
  *
  * This function performs 2 steps in a Queue state machine
  *      actually: 1) RESET->INIT 2) INIT->SETUP
  */
 
-int bnx2x_setup_queue(struct bnx2x *bp, struct bnx2x_fastpath *fp,
-		       bool leading)
+int bnx2x_setup_queue(struct bnx2x *bp, struct bnx2x_fastpath *fp)
 {
 	struct bnx2x_queue_state_params q_params = {0};
 	struct bnx2x_queue_setup_params *setup_params =
@@ -7264,7 +7261,7 @@ int bnx2x_setup_queue(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	memset(setup_params, 0, sizeof(*setup_params));
 
 	/* Set QUEUE flags */
-	setup_params->flags = bnx2x_get_q_flags(bp, fp, leading);
+	setup_params->flags = bnx2x_get_q_flags(bp, fp);
 
 	/* Set general SETUP parameters */
 	bnx2x_pf_q_prep_general(bp, fp, &setup_params->gen_params,
@@ -7293,7 +7290,7 @@ int bnx2x_setup_queue(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		/* prepare and send tx-only ramrod*/
 		rc = bnx2x_setup_tx_only(bp, fp, &q_params,
-					  tx_only_params, tx_index, leading);
+					  tx_only_params, tx_index);
 		if (rc) {
 			BNX2X_ERR("Queue(%d.%d) TX_ONLY_SETUP failed\n",
 				  fp->index, tx_index);
-- 
1.7.6
