From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 2/6] bnx2x: Fix VF statistics
Date: Wed, 27 Mar 2013 13:05:15 +0200
Message-ID: <1364382319-24952-3-git-send-email-yuvalmin@broadcom.com>
References: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2778 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753992Ab3C0MK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 08:10:26 -0400
In-Reply-To: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

After a VF performs load/unload its statistics become corrupt -
we now zero the statistics structures upon a VF device load.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  5 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 77 +++++++++++++----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h |  2 +-
 3 files changed, 47 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 10b0748..cf2a169 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -6040,9 +6040,10 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 	rmb();
 	bnx2x_init_rx_rings(bp);
 	bnx2x_init_tx_rings(bp);
-
-	if (IS_VF(bp))
+	if (IS_VF(bp)) {
+		bnx2x_memset_stats(bp);
 		return;
+	}
 
 	/* Initialize MOD_ABS interrupts */
 	bnx2x_init_mod_abs_int(bp, &bp->link_vars, bp->common.chip_id,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 4397f8b..2ca3d94 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1547,11 +1547,51 @@ static void bnx2x_prep_fw_stats_req(struct bnx2x *bp)
 	}
 }
 
+void bnx2x_memset_stats(struct bnx2x *bp)
+{
+	int i;
+
+	/* function stats */
+	for_each_queue(bp, i) {
+		struct bnx2x_fp_stats *fp_stats = &bp->fp_stats[i];
+
+		memset(&fp_stats->old_tclient, 0,
+		       sizeof(fp_stats->old_tclient));
+		memset(&fp_stats->old_uclient, 0,
+		       sizeof(fp_stats->old_uclient));
+		memset(&fp_stats->old_xclient, 0,
+		       sizeof(fp_stats->old_xclient));
+		if (bp->stats_init) {
+			memset(&fp_stats->eth_q_stats, 0,
+			       sizeof(fp_stats->eth_q_stats));
+			memset(&fp_stats->eth_q_stats_old, 0,
+			       sizeof(fp_stats->eth_q_stats_old));
+		}
+	}
+
+	memset(&bp->dev->stats, 0, sizeof(bp->dev->stats));
+
+	if (bp->stats_init) {
+		memset(&bp->net_stats_old, 0, sizeof(bp->net_stats_old));
+		memset(&bp->fw_stats_old, 0, sizeof(bp->fw_stats_old));
+		memset(&bp->eth_stats_old, 0, sizeof(bp->eth_stats_old));
+		memset(&bp->eth_stats, 0, sizeof(bp->eth_stats));
+		memset(&bp->func_stats, 0, sizeof(bp->func_stats));
+	}
+
+	bp->stats_state = STATS_STATE_DISABLED;
+
+	if (bp->port.pmf && bp->port.port_stx)
+		bnx2x_port_stats_base_init(bp);
+
+	/* mark the end of statistics initializiation */
+	bp->stats_init = false;
+}
+
 void bnx2x_stats_init(struct bnx2x *bp)
 {
 	int /*abs*/port = BP_PORT(bp);
 	int mb_idx = BP_FW_MB_IDX(bp);
-	int i;
 
 	bp->stats_pending = 0;
 	bp->executer_idx = 0;
@@ -1587,36 +1627,11 @@ void bnx2x_stats_init(struct bnx2x *bp)
 			    &(bp->port.old_nig_stats.egress_mac_pkt1_lo), 2);
 	}
 
-	/* function stats */
-	for_each_queue(bp, i) {
-		struct bnx2x_fp_stats *fp_stats = &bp->fp_stats[i];
-
-		memset(&fp_stats->old_tclient, 0,
-		       sizeof(fp_stats->old_tclient));
-		memset(&fp_stats->old_uclient, 0,
-		       sizeof(fp_stats->old_uclient));
-		memset(&fp_stats->old_xclient, 0,
-		       sizeof(fp_stats->old_xclient));
-		if (bp->stats_init) {
-			memset(&fp_stats->eth_q_stats, 0,
-			       sizeof(fp_stats->eth_q_stats));
-			memset(&fp_stats->eth_q_stats_old, 0,
-			       sizeof(fp_stats->eth_q_stats_old));
-		}
-	}
-
 	/* Prepare statistics ramrod data */
 	bnx2x_prep_fw_stats_req(bp);
 
-	memset(&bp->dev->stats, 0, sizeof(bp->dev->stats));
+	/* Clean SP from previous statistics */
 	if (bp->stats_init) {
-		memset(&bp->net_stats_old, 0, sizeof(bp->net_stats_old));
-		memset(&bp->fw_stats_old, 0, sizeof(bp->fw_stats_old));
-		memset(&bp->eth_stats_old, 0, sizeof(bp->eth_stats_old));
-		memset(&bp->eth_stats, 0, sizeof(bp->eth_stats));
-		memset(&bp->func_stats, 0, sizeof(bp->func_stats));
-
-		/* Clean SP from previous statistics */
 		if (bp->func_stx) {
 			memset(bnx2x_sp(bp, func_stats), 0,
 			       sizeof(struct host_func_stats));
@@ -1626,13 +1641,7 @@ void bnx2x_stats_init(struct bnx2x *bp)
 		}
 	}
 
-	bp->stats_state = STATS_STATE_DISABLED;
-
-	if (bp->port.pmf && bp->port.port_stx)
-		bnx2x_port_stats_base_init(bp);
-
-	/* mark the end of statistics initializiation */
-	bp->stats_init = false;
+	bnx2x_memset_stats(bp);
 }
 
 void bnx2x_save_statistics(struct bnx2x *bp)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index 198f6f1..d117f47 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -540,8 +540,8 @@ struct bnx2x_fw_port_stats_old {
 /* forward */
 struct bnx2x;
 
+void bnx2x_memset_stats(struct bnx2x *bp);
 void bnx2x_stats_init(struct bnx2x *bp);
-
 void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event);
 
 /**
-- 
1.8.1.227.g44fe835
