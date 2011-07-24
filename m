From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 3/6] bnx2x: count statistic ramrods on EQ to prevent MC
 assert
Date: Sun, 24 Jul 2011 16:54:17 +0300
Message-ID: <1311515657.23243.5.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4917 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592Ab1GXOKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2011 10:10:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>

This patch includes:
 - Counting statistics ramrods as EQ ramrods the way they should be. This
   accounting is meant to prevent MC asserts in case of software bugs.
 - Fixes in debug facilities which were added while working on one of such
   bugs.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   63 ++++++++++++++++++++-------------------
 1 files changed, 32 insertions(+), 31 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 48490da..9c146f7 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1671,11 +1671,12 @@ void bnx2x_sp_event(struct bnx2x_fastpath *fp, union eth_rx_cqe *rr_cqe)
 
 	switch (command) {
 	case (RAMROD_CMD_ID_ETH_CLIENT_UPDATE):
-		DP(NETIF_MSG_IFUP, "got UPDATE ramrod. CID %d\n", cid);
+		DP(BNX2X_MSG_SP, "got UPDATE ramrod. CID %d\n", cid);
 		drv_cmd = BNX2X_Q_CMD_UPDATE;
 		break;
+
 	case (RAMROD_CMD_ID_ETH_CLIENT_SETUP):
-		DP(NETIF_MSG_IFUP, "got MULTI[%d] setup ramrod\n", cid);
+		DP(BNX2X_MSG_SP, "got MULTI[%d] setup ramrod\n", cid);
 		drv_cmd = BNX2X_Q_CMD_SETUP;
 		break;
 
@@ -1685,17 +1686,17 @@ void bnx2x_sp_event(struct bnx2x_fastpath *fp, union eth_rx_cqe *rr_cqe)
 		break;
 
 	case (RAMROD_CMD_ID_ETH_HALT):
-		DP(NETIF_MSG_IFDOWN, "got MULTI[%d] halt ramrod\n", cid);
+		DP(BNX2X_MSG_SP, "got MULTI[%d] halt ramrod\n", cid);
 		drv_cmd = BNX2X_Q_CMD_HALT;
 		break;
 
 	case (RAMROD_CMD_ID_ETH_TERMINATE):
-		DP(NETIF_MSG_IFDOWN, "got MULTI[%d] teminate ramrod\n", cid);
+		DP(BNX2X_MSG_SP, "got MULTI[%d] teminate ramrod\n", cid);
 		drv_cmd = BNX2X_Q_CMD_TERMINATE;
 		break;
 
 	case (RAMROD_CMD_ID_ETH_EMPTY):
-		DP(NETIF_MSG_IFDOWN, "got MULTI[%d] empty ramrod\n", cid);
+		DP(BNX2X_MSG_SP, "got MULTI[%d] empty ramrod\n", cid);
 		drv_cmd = BNX2X_Q_CMD_EMPTY;
 		break;
 
@@ -1725,6 +1726,8 @@ void bnx2x_sp_event(struct bnx2x_fastpath *fp, union eth_rx_cqe *rr_cqe)
 	/* push the change in bp->spq_left and towards the memory */
 	smp_mb__after_atomic_inc();
 
+	DP(BNX2X_MSG_SP, "bp->cq_spq_left %x\n", atomic_read(&bp->cq_spq_left));
+
 	return;
 }
 
@@ -3089,26 +3092,23 @@ int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 	spe->data.update_data_addr.hi = cpu_to_le32(data_hi);
 	spe->data.update_data_addr.lo = cpu_to_le32(data_lo);
 
-	/* stats ramrod has it's own slot on the spq */
-	if (command != RAMROD_CMD_ID_COMMON_STAT_QUERY) {
-		/*
-		 * It's ok if the actual decrement is issued towards the memory
-		 * somewhere between the spin_lock and spin_unlock. Thus no
-		 * more explict memory barrier is needed.
-		 */
-		if (common)
-			atomic_dec(&bp->eq_spq_left);
-		else
-			atomic_dec(&bp->cq_spq_left);
-	}
+	/*
+	 * It's ok if the actual decrement is issued towards the memory
+	 * somewhere between the spin_lock and spin_unlock. Thus no
+	 * more explict memory barrier is needed.
+	 */
+	if (common)
+		atomic_dec(&bp->eq_spq_left);
+	else
+		atomic_dec(&bp->cq_spq_left);
 
 
 	DP(BNX2X_MSG_SP/*NETIF_MSG_TIMER*/,
-	   "SPQE[%x] (%x:%x)  command %d  hw_cid %x  data (%x:%x) "
-	   "type(0x%x) left (ETH, COMMON) (%x,%x)\n",
+	   "SPQE[%x] (%x:%x)  (cmd, common?) (%d,%d)  hw_cid %x  data (%x:%x) "
+	   "type(0x%x) left (CQ, EQ) (%x,%x)\n",
 	   bp->spq_prod_idx, (u32)U64_HI(bp->spq_mapping),
 	   (u32)(U64_LO(bp->spq_mapping) +
-	   (void *)bp->spq_prod_bd - (void *)bp->spq), command,
+	   (void *)bp->spq_prod_bd - (void *)bp->spq), command, common,
 	   HW_CID(bp, cid), data_hi, data_lo, type,
 	   atomic_read(&bp->cq_spq_left), atomic_read(&bp->eq_spq_left));
 
@@ -3465,6 +3465,7 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 		} else if (attn & BNX2X_MC_ASSERT_BITS) {
 
 			BNX2X_ERR("MC assert!\n");
+			bnx2x_mc_assert(bp);
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_10, 0);
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_9, 0);
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_8, 0);
@@ -4424,7 +4425,7 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 	sw_cons = bp->eq_cons;
 	sw_prod = bp->eq_prod;
 
-	DP(BNX2X_MSG_SP, "EQ:  hw_cons %u  sw_cons %u bp->cq_spq_left %u\n",
+	DP(BNX2X_MSG_SP, "EQ:  hw_cons %u  sw_cons %u bp->eq_spq_left %x\n",
 			hw_cons, sw_cons, atomic_read(&bp->eq_spq_left));
 
 	for (; sw_cons != hw_cons;
@@ -4443,7 +4444,7 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 			DP(NETIF_MSG_TIMER, "got statistics comp event %d\n",
 			   bp->stats_comp++);
 			/* nothing to do with stats comp */
-			continue;
+			goto next_spqe;
 
 		case EVENT_RING_OPCODE_CFC_DEL:
 			/* handle according to cid range */
@@ -4451,7 +4452,7 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 			 * we may want to verify here that the bp state is
 			 * HALTING
 			 */
-			DP(NETIF_MSG_IFDOWN,
+			DP(BNX2X_MSG_SP,
 			   "got delete ramrod for MULTI[%d]\n", cid);
 #ifdef BCM_CNIC
 			if (!bnx2x_cnic_handle_cfc_del(bp, cid, elem))
@@ -4467,7 +4468,7 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 			goto next_spqe;
 
 		case EVENT_RING_OPCODE_STOP_TRAFFIC:
-			DP(NETIF_MSG_IFUP, "got STOP TRAFFIC\n");
+			DP(BNX2X_MSG_SP, "got STOP TRAFFIC\n");
 			if (f_obj->complete_cmd(bp, f_obj,
 						BNX2X_F_CMD_TX_STOP))
 				break;
@@ -4475,21 +4476,21 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 			goto next_spqe;
 
 		case EVENT_RING_OPCODE_START_TRAFFIC:
-			DP(NETIF_MSG_IFUP, "got START TRAFFIC\n");
+			DP(BNX2X_MSG_SP, "got START TRAFFIC\n");
 			if (f_obj->complete_cmd(bp, f_obj,
 						BNX2X_F_CMD_TX_START))
 				break;
 			bnx2x_dcbx_set_params(bp, BNX2X_DCBX_STATE_TX_RELEASED);
 			goto next_spqe;
 		case EVENT_RING_OPCODE_FUNCTION_START:
-			DP(NETIF_MSG_IFUP, "got FUNC_START ramrod\n");
+			DP(BNX2X_MSG_SP, "got FUNC_START ramrod\n");
 			if (f_obj->complete_cmd(bp, f_obj, BNX2X_F_CMD_START))
 				break;
 
 			goto next_spqe;
 
 		case EVENT_RING_OPCODE_FUNCTION_STOP:
-			DP(NETIF_MSG_IFDOWN, "got FUNC_STOP ramrod\n");
+			DP(BNX2X_MSG_SP, "got FUNC_STOP ramrod\n");
 			if (f_obj->complete_cmd(bp, f_obj, BNX2X_F_CMD_STOP))
 				break;
 
@@ -4503,7 +4504,7 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 		      BNX2X_STATE_OPENING_WAIT4_PORT):
 			cid = elem->message.data.eth_event.echo &
 				BNX2X_SWCID_MASK;
-			DP(NETIF_MSG_IFUP, "got RSS_UPDATE ramrod. CID %d\n",
+			DP(BNX2X_MSG_SP, "got RSS_UPDATE ramrod. CID %d\n",
 			   cid);
 			rss_raw->clear_pending(rss_raw);
 			break;
@@ -4518,7 +4519,7 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 		      BNX2X_STATE_DIAG):
 		case (EVENT_RING_OPCODE_CLASSIFICATION_RULES |
 		      BNX2X_STATE_CLOSING_WAIT4_HALT):
-			DP(NETIF_MSG_IFUP, "got (un)set mac ramrod\n");
+			DP(BNX2X_MSG_SP, "got (un)set mac ramrod\n");
 			bnx2x_handle_classification_eqe(bp, elem);
 			break;
 
@@ -4528,7 +4529,7 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 		      BNX2X_STATE_DIAG):
 		case (EVENT_RING_OPCODE_MULTICAST_RULES |
 		      BNX2X_STATE_CLOSING_WAIT4_HALT):
-			DP(NETIF_MSG_IFUP, "got mcast ramrod\n");
+			DP(BNX2X_MSG_SP, "got mcast ramrod\n");
 			bnx2x_handle_mcast_eqe(bp);
 			break;
 
@@ -4538,7 +4539,7 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 		      BNX2X_STATE_DIAG):
 		case (EVENT_RING_OPCODE_FILTERS_RULES |
 		      BNX2X_STATE_CLOSING_WAIT4_HALT):
-			DP(NETIF_MSG_IFUP, "got rx_mode ramrod\n");
+			DP(BNX2X_MSG_SP, "got rx_mode ramrod\n");
 			bnx2x_handle_rx_mode_eqe(bp);
 			break;
 		default:
-- 
1.7.2.2




