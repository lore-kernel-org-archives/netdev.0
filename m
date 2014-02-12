From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net-next 1/9] bnx2x: [Debug] change verbosity of some prints
Date: Wed, 12 Feb 2014 18:19:49 +0200
Message-ID: <1392221997-25525-2-git-send-email-yuvalmin@broadcom.com>
References: <1392221997-25525-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:19877 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbaBLQUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 11:20:08 -0500
In-Reply-To: <1392221997-25525-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some debug prints (mostly iov/statistics related) which clobber
system logs whenever their verbosity level is set for an interface.
This patch puts harsher verbosity requirements for such debug prints to be
printed.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       | 17 +++++++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 17 +++++++++--------
 3 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 391f29e..ae91e8f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -75,13 +75,22 @@ enum bnx2x_int_mode {
 #define BNX2X_MSG_DCB			0x8000000
 
 /* regular debug print */
+#define DP_INNER(fmt, ...)					\
+	pr_notice("[%s:%d(%s)]" fmt,				\
+		  __func__, __LINE__,				\
+		  bp->dev ? (bp->dev->name) : "?",		\
+		  ##__VA_ARGS__);
+
 #define DP(__mask, fmt, ...)					\
 do {								\
 	if (unlikely(bp->msg_enable & (__mask)))		\
-		pr_notice("[%s:%d(%s)]" fmt,			\
-			  __func__, __LINE__,			\
-			  bp->dev ? (bp->dev->name) : "?",	\
-			  ##__VA_ARGS__);			\
+		DP_INNER(fmt, ##__VA_ARGS__);			\
+} while (0)
+
+#define DP_AND(__mask, fmt, ...)				\
+do {								\
+	if (unlikely((bp->msg_enable & (__mask)) == __mask))	\
+		DP_INNER(fmt, ##__VA_ARGS__);			\
 } while (0)
 
 #define DP_CONT(__mask, fmt, ...)				\
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e118a3e..72ff5d2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -5221,9 +5221,9 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 			continue;
 
 		case EVENT_RING_OPCODE_STAT_QUERY:
-			DP(BNX2X_MSG_SP | BNX2X_MSG_STATS,
-			   "got statistics comp event %d\n",
-			   bp->stats_comp++);
+			DP_AND((BNX2X_MSG_SP | BNX2X_MSG_STATS),
+			       "got statistics comp event %d\n",
+			       bp->stats_comp++);
 			/* nothing to do with stats comp */
 			goto next_spqe;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index aec5ef2..04805b6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2527,10 +2527,10 @@ void bnx2x_iov_adjust_stats_req(struct bnx2x *bp)
 	first_queue_query_index = BNX2X_FIRST_QUEUE_QUERY_IDX -
 		(is_fcoe ? 0 : 1);
 
-	DP(BNX2X_MSG_IOV,
-	   "BNX2X_NUM_ETH_QUEUES %d, is_fcoe %d, first_queue_query_index %d => determined the last non virtual statistics query index is %d. Will add queries on top of that\n",
-	   BNX2X_NUM_ETH_QUEUES(bp), is_fcoe, first_queue_query_index,
-	   first_queue_query_index + num_queues_req);
+	DP_AND((BNX2X_MSG_IOV | BNX2X_MSG_STATS),
+	       "BNX2X_NUM_ETH_QUEUES %d, is_fcoe %d, first_queue_query_index %d => determined the last non virtual statistics query index is %d. Will add queries on top of that\n",
+	       BNX2X_NUM_ETH_QUEUES(bp), is_fcoe, first_queue_query_index,
+	       first_queue_query_index + num_queues_req);
 
 	cur_data_offset = bp->fw_stats_data_mapping +
 		offsetof(struct bnx2x_fw_stats_data, queue_stats) +
@@ -2544,9 +2544,9 @@ void bnx2x_iov_adjust_stats_req(struct bnx2x *bp)
 		struct bnx2x_virtf *vf = BP_VF(bp, i);
 
 		if (vf->state != VF_ENABLED) {
-			DP(BNX2X_MSG_IOV,
-			   "vf %d not enabled so no stats for it\n",
-			   vf->abs_vfid);
+			DP_AND((BNX2X_MSG_IOV | BNX2X_MSG_STATS),
+			       "vf %d not enabled so no stats for it\n",
+			       vf->abs_vfid);
 			continue;
 		}
 
@@ -2597,7 +2597,8 @@ void bnx2x_iov_sp_task(struct bnx2x *bp)
 	/* Iterate over all VFs and invoke state transition for VFs with
 	 * 'in-progress' slow-path operations
 	 */
-	DP(BNX2X_MSG_IOV, "searching for pending vf operations\n");
+	DP_AND((BNX2X_MSG_IOV | BNX2X_MSG_SP),
+	       "searching for pending vf operations\n");
 	for_each_vf(bp, i) {
 		struct bnx2x_virtf *vf = BP_VF(bp, i);
 
-- 
1.8.1.227.g44fe835
