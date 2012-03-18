From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 8/9] bnx2x: consistent statistics for old FW
Date: Sun, 18 Mar 2012 16:33:44 -0400
Message-ID: <1332102825-7838-9-git-send-email-yuvalmin@broadcom.com>
References: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4961 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755207Ab2CRNsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 09:48:33 -0400
In-Reply-To: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously applied patch making the bnx2x statistics consistent
did not apply to old FWs. This remedies it, extending the consistent
behaviour to all drivers.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |   39 ++------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h |    7 +---
 3 files changed, 6 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 562cec3..e37161f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1482,6 +1482,7 @@ struct bnx2x {
 
 	u16			stats_counter;
 	struct bnx2x_eth_stats	eth_stats;
+	struct host_func_stats		func_stats;
 	struct bnx2x_eth_stats_old	eth_stats_old;
 	struct bnx2x_net_stats_old	net_stats_old;
 	struct bnx2x_fw_port_stats_old	fw_stats_old;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 4516e6a..2e33328 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -128,6 +128,8 @@ static void bnx2x_hw_stats_post(struct bnx2x *bp)
 
 	} else if (bp->func_stx) {
 		*stats_comp = 0;
+		memcpy(bnx2x_sp(bp, func_stats), &bp->func_stats,
+		       sizeof(bp->func_stats));
 		bnx2x_post_dmae(bp, dmae, INIT_DMAE_C(bp));
 	}
 }
@@ -814,7 +816,7 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 				&bp->fw_stats_data->port.tstorm_port_statistics;
 	struct tstorm_per_pf_stats *tfunc =
 				&bp->fw_stats_data->pf.tstorm_pf_statistics;
-	struct host_func_stats *fstats = bnx2x_sp(bp, func_stats);
+	struct host_func_stats *fstats = &bp->func_stats;
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
 	struct bnx2x_eth_stats_old *estats_old = &bp->eth_stats_old;
 	struct stats_counter *counters = &bp->fw_stats_data->storm_counters;
@@ -1319,36 +1321,6 @@ static void bnx2x_port_stats_base_init(struct bnx2x *bp)
 	bnx2x_stats_comp(bp);
 }
 
-static void bnx2x_func_stats_base_update(struct bnx2x *bp)
-{
-	struct dmae_command *dmae = &bp->stats_dmae;
-	u32 *stats_comp = bnx2x_sp(bp, stats_comp);
-
-	/* sanity */
-	if (!bp->func_stx) {
-		BNX2X_ERR("BUG!\n");
-		return;
-	}
-
-	bp->executer_idx = 0;
-	memset(dmae, 0, sizeof(struct dmae_command));
-
-	dmae->opcode = bnx2x_dmae_opcode(bp, DMAE_SRC_GRC, DMAE_DST_PCI,
-					 true, DMAE_COMP_PCI);
-	dmae->src_addr_lo = bp->func_stx >> 2;
-	dmae->src_addr_hi = 0;
-	dmae->dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, func_stats));
-	dmae->dst_addr_hi = U64_HI(bnx2x_sp_mapping(bp, func_stats));
-	dmae->len = sizeof(struct host_func_stats) >> 2;
-	dmae->comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, stats_comp));
-	dmae->comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, stats_comp));
-	dmae->comp_val = DMAE_COMP_VAL;
-
-	*stats_comp = 0;
-	bnx2x_hw_stats_post(bp);
-	bnx2x_stats_comp(bp);
-}
-
 /**
  * This function will prepare the statistics ramrod data the way
  * we will only have to increment the statistics counter and
@@ -1540,6 +1512,7 @@ void bnx2x_stats_init(struct bnx2x *bp)
 		memset(&bp->fw_stats_old, 0, sizeof(bp->fw_stats_old));
 		memset(&bp->eth_stats_old, 0, sizeof(bp->eth_stats_old));
 		memset(&bp->eth_stats, 0, sizeof(bp->eth_stats));
+		memset(&bp->func_stats, 0, sizeof(bp->func_stats));
 
 		/* Clean SP from previous statistics */
 		if (bp->func_stx) {
@@ -1556,10 +1529,6 @@ void bnx2x_stats_init(struct bnx2x *bp)
 	if (bp->port.pmf && bp->port.port_stx)
 		bnx2x_port_stats_base_init(bp);
 
-	/* On a non-init, retrieve previous statistics from SP */
-	if (!bp->stats_init && bp->func_stx)
-		bnx2x_func_stats_base_update(bp);
-
 	/* mark the end of statistics initializiation */
 	bp->stats_init = false;
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index 39ffd6d..2b46e1e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -421,12 +421,7 @@ struct bnx2x_fw_port_stats_old {
 	do { \
 		diff = le32_to_cpu(uclient->s) - le32_to_cpu(old_uclient->s); \
 		old_uclient->s = uclient->s; \
-	} while (0)
-
-#define UPDATE_EXTEND_E_USTAT(s, t) \
-	do { \
-		UPDATE_EXTEND_USTAT(s, t); \
-		ADD_EXTEND_64(estats->t##_hi, estats->t##_lo, diff); \
+		ADD_EXTEND_64(qstats->t##_hi, qstats->t##_lo, diff); \
 	} while (0)
 
 #define UPDATE_EXTEND_E_USTAT(s, t) \
-- 
1.7.9.rc2
