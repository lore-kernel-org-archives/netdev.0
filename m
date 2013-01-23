From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 06/12] bnx2x: Correct memory preparation and
 release
Date: Wed, 23 Jan 2013 15:21:48 +0200
Message-ID: <1358947314-3851-7-git-send-email-yuvalmin@broadcom.com>
References: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1312 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755279Ab3AWOXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 09:23:10 -0500
In-Reply-To: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Since commit 15192a8cf there have been a memory leak upon rmmod
of the bnx2x driver.

This corrects the memory leak and corrects the zeroing of internal
memories upon driver load.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |  2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 58 ++++++-------------------
 2 files changed, 16 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 0532e43..55ae8f9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1702,6 +1702,8 @@ struct bnx2x {
 
 	/* priority to cos mapping */
 	u8					prio_to_cos[8];
+
+	int fp_array_size;
 	u32 dump_preset_idx;
 };
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 58f491e..bcb2b64 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2308,49 +2308,15 @@ static void bnx2x_nic_load_afex_dcc(struct bnx2x *bp, int load_code)
 static void bnx2x_bz_fp(struct bnx2x *bp, int index)
 {
 	struct bnx2x_fastpath *fp = &bp->fp[index];
-	struct bnx2x_fp_stats *fp_stats = &bp->fp_stats[index];
 
 	int cos;
 	struct napi_struct orig_napi = fp->napi;
 	struct bnx2x_agg_info *orig_tpa_info = fp->tpa_info;
 	/* bzero bnx2x_fastpath contents */
-	if (bp->stats_init) {
-		memset(fp->tpa_info, 0, sizeof(*fp->tpa_info));
-		memset(fp, 0, sizeof(*fp));
-	} else {
-		/* Keep Queue statistics */
-		struct bnx2x_eth_q_stats *tmp_eth_q_stats;
-		struct bnx2x_eth_q_stats_old *tmp_eth_q_stats_old;
-
-		tmp_eth_q_stats = kzalloc(sizeof(struct bnx2x_eth_q_stats),
-					  GFP_KERNEL);
-		if (tmp_eth_q_stats)
-			memcpy(tmp_eth_q_stats, &fp_stats->eth_q_stats,
-			       sizeof(struct bnx2x_eth_q_stats));
-
-		tmp_eth_q_stats_old =
-			kzalloc(sizeof(struct bnx2x_eth_q_stats_old),
-				GFP_KERNEL);
-		if (tmp_eth_q_stats_old)
-			memcpy(tmp_eth_q_stats_old, &fp_stats->eth_q_stats_old,
-			       sizeof(struct bnx2x_eth_q_stats_old));
-
-		memset(fp->tpa_info, 0, sizeof(*fp->tpa_info));
-		memset(fp, 0, sizeof(*fp));
-
-		if (tmp_eth_q_stats) {
-			memcpy(&fp_stats->eth_q_stats, tmp_eth_q_stats,
-			       sizeof(struct bnx2x_eth_q_stats));
-			kfree(tmp_eth_q_stats);
-		}
-
-		if (tmp_eth_q_stats_old) {
-			memcpy(&fp_stats->eth_q_stats_old, tmp_eth_q_stats_old,
-			       sizeof(struct bnx2x_eth_q_stats_old));
-			kfree(tmp_eth_q_stats_old);
-		}
-
-	}
+	if (fp->tpa_info)
+		memset(fp->tpa_info, 0, ETH_MAX_AGGREGATION_QUEUES_E1H_E2 *
+		       sizeof(struct bnx2x_agg_info));
+	memset(fp, 0, sizeof(*fp));
 
 	/* Restore the NAPI object as it has been already initialized */
 	fp->napi = orig_napi;
@@ -4227,7 +4193,10 @@ int bnx2x_alloc_fp_mem(struct bnx2x *bp)
 
 void bnx2x_free_mem_bp(struct bnx2x *bp)
 {
-	kfree(bp->fp->tpa_info);
+	int i;
+
+	for (i = 0; i < bp->fp_array_size; i++)
+		kfree(bp->fp[i].tpa_info);
 	kfree(bp->fp);
 	kfree(bp->sp_objs);
 	kfree(bp->fp_stats);
@@ -4256,12 +4225,13 @@ int bnx2x_alloc_mem_bp(struct bnx2x *bp)
 
 	/* fp array: RSS plus CNIC related L2 queues */
 	fp_array_size = BNX2X_MAX_RSS_COUNT(bp) + CNIC_SUPPORT(bp);
-	BNX2X_DEV_INFO("fp_array_size %d", fp_array_size);
+	bp->fp_array_size = fp_array_size;
+	BNX2X_DEV_INFO("fp_array_size %d\n", bp->fp_array_size);
 
-	fp = kcalloc(fp_array_size, sizeof(*fp), GFP_KERNEL);
+	fp = kcalloc(bp->fp_array_size, sizeof(*fp), GFP_KERNEL);
 	if (!fp)
 		goto alloc_err;
-	for (i = 0; i < fp_array_size; i++) {
+	for (i = 0; i < bp->fp_array_size; i++) {
 		fp[i].tpa_info =
 			kcalloc(ETH_MAX_AGGREGATION_QUEUES_E1H_E2,
 				sizeof(struct bnx2x_agg_info), GFP_KERNEL);
@@ -4272,13 +4242,13 @@ int bnx2x_alloc_mem_bp(struct bnx2x *bp)
 	bp->fp = fp;
 
 	/* allocate sp objs */
-	bp->sp_objs = kcalloc(fp_array_size, sizeof(struct bnx2x_sp_objs),
+	bp->sp_objs = kcalloc(bp->fp_array_size, sizeof(struct bnx2x_sp_objs),
 			      GFP_KERNEL);
 	if (!bp->sp_objs)
 		goto alloc_err;
 
 	/* allocate fp_stats */
-	bp->fp_stats = kcalloc(fp_array_size, sizeof(struct bnx2x_fp_stats),
+	bp->fp_stats = kcalloc(bp->fp_array_size, sizeof(struct bnx2x_fp_stats),
 			       GFP_KERNEL);
 	if (!bp->fp_stats)
 		goto alloc_err;
-- 
1.8.1.227.g44fe835
