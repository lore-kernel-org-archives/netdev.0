From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 4/12] bnx2x: Allow more than 64 L2 CIDs
Date: Wed, 13 Jun 2012 15:44:16 +0300
Message-ID: <1339591464-10554-5-git-send-email-meravs@broadcom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2785 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752704Ab2FMJmo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 05:42:44 -0400
In-Reply-To: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With increased number of RSS queues, each multiplied by the number of traffic-
classes, we may have up to 64*3=192 CIDs. The current driver scheme with regard
to context allocation supports only 64 CIDs. The new scheme enables scatter-
gatehr list of pages for the context.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |   10 +++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   67 ++++++++++++++++------
 2 files changed, 57 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 568c3c7..feec032 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -993,8 +993,8 @@ union cdu_context {
 };
 
 /* CDU host DB constants */
-#define CDU_ILT_PAGE_SZ_HW	3
-#define CDU_ILT_PAGE_SZ		(8192 << CDU_ILT_PAGE_SZ_HW) /* 64K */
+#define CDU_ILT_PAGE_SZ_HW	2
+#define CDU_ILT_PAGE_SZ		(8192 << CDU_ILT_PAGE_SZ_HW) /* 32K */
 #define ILT_PAGE_CIDS		(CDU_ILT_PAGE_SZ / sizeof(union cdu_context))
 
 #ifdef BCM_CNIC
@@ -1435,7 +1435,11 @@ struct bnx2x {
 	dma_addr_t			fw_stats_data_mapping;
 	int				fw_stats_data_sz;
 
-	struct hw_context	context;
+	/* For max 196 cids (64*3 + non-eth), 32KB ILT page size and 1KB
+	 * context size we need 8 ILT entries.
+	 */
+#define ILT_MAX_L2_LINES	8
+	struct hw_context	context[ILT_MAX_L2_LINES];
 
 	struct bnx2x_ilt	*ilt;
 #define BP_ILT(bp)		((bp)->ilt)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 21930be..16e009f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7068,12 +7068,10 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	cdu_ilt_start = ilt->clients[ILT_CLIENT_CDU].start;
 
 	for (i = 0; i < L2_ILT_LINES(bp); i++) {
-		ilt->lines[cdu_ilt_start + i].page =
-			bp->context.vcxt + (ILT_PAGE_CIDS * i);
+		ilt->lines[cdu_ilt_start + i].page = bp->context[i].vcxt;
 		ilt->lines[cdu_ilt_start + i].page_mapping =
-			bp->context.cxt_mapping + (CDU_ILT_PAGE_SZ * i);
-		/* cdu ilt pages are allocated manually so there's no need to
-		set the size */
+			bp->context[i].cxt_mapping;
+		ilt->lines[cdu_ilt_start + i].size = bp->context[i].size;
 	}
 	bnx2x_ilt_init_op(bp, INITOP_SET);
 
@@ -7340,6 +7338,8 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 
 void bnx2x_free_mem(struct bnx2x *bp)
 {
+	int i;
+
 	/* fastpath */
 	bnx2x_free_fp_mem(bp);
 	/* end of fastpath */
@@ -7353,9 +7353,9 @@ void bnx2x_free_mem(struct bnx2x *bp)
 	BNX2X_PCI_FREE(bp->slowpath, bp->slowpath_mapping,
 		       sizeof(struct bnx2x_slowpath));
 
-	BNX2X_PCI_FREE(bp->context.vcxt, bp->context.cxt_mapping,
-		       bp->context.size);
-
+	for (i = 0; i < L2_ILT_LINES(bp); i++)
+		BNX2X_PCI_FREE(bp->context[i].vcxt, bp->context[i].cxt_mapping,
+			       bp->context[i].size);
 	bnx2x_ilt_mem_op(bp, ILT_MEMOP_FREE);
 
 	BNX2X_FREE(bp->ilt->lines);
@@ -7441,6 +7441,8 @@ alloc_mem_err:
 
 int bnx2x_alloc_mem(struct bnx2x *bp)
 {
+	int i, allocated, context_size;
+
 #ifdef BCM_CNIC
 	if (!CHIP_IS_E1x(bp))
 		/* size = the status block + ramrod buffers */
@@ -7470,11 +7472,29 @@ int bnx2x_alloc_mem(struct bnx2x *bp)
 	if (bnx2x_alloc_fw_stats_mem(bp))
 		goto alloc_mem_err;
 
-	bp->context.size = sizeof(union cdu_context) * BNX2X_L2_CID_COUNT(bp);
-
-	BNX2X_PCI_ALLOC(bp->context.vcxt, &bp->context.cxt_mapping,
-			bp->context.size);
+	/* Allocate memory for CDU context:
+	 * This memory is allocated separately and not in the generic ILT
+	 * functions because CDU differs in few aspects:
+	 * 1. There are multiple entities allocating memory for context -
+	 * 'regular' driver, CNIC and SRIOV driver. Each separately controls
+	 * its own ILT lines.
+	 * 2. Since CDU page-size is not a single 4KB page (which is the case
+	 * for the other ILT clients), to be efficient we want to support
+	 * allocation of sub-page-size in the last entry.
+	 * 3. Context pointers are used by the driver to pass to FW / update
+	 * the context (for the other ILT clients the pointers are used just to
+	 * free the memory during unload).
+	 */
+	context_size = sizeof(union cdu_context) * BNX2X_L2_CID_COUNT(bp);
 
+	for (i = 0, allocated = 0; allocated < context_size; i++) {
+		bp->context[i].size = min(CDU_ILT_PAGE_SZ,
+					  (context_size - allocated));
+		BNX2X_PCI_ALLOC(bp->context[i].vcxt,
+				&bp->context[i].cxt_mapping,
+				bp->context[i].size);
+		allocated += bp->context[i].size;
+	}
 	BNX2X_ALLOC(bp->ilt->lines, sizeof(struct ilt_line) * ILT_MAX_LINES);
 
 	if (bnx2x_ilt_mem_op(bp, ILT_MEMOP_ALLOC))
@@ -7748,6 +7768,8 @@ static void bnx2x_pf_q_prep_init(struct bnx2x *bp,
 {
 
 	u8 cos;
+	int cxt_index, cxt_offset;
+
 	/* FCoE Queue uses Default SB, thus has no HC capabilities */
 	if (!IS_FCOE_FP(fp)) {
 		__set_bit(BNX2X_Q_FLG_HC, &init_params->rx.flags);
@@ -7784,9 +7806,13 @@ static void bnx2x_pf_q_prep_init(struct bnx2x *bp,
 	    fp->index, init_params->max_cos);
 
 	/* set the context pointers queue object */
-	for (cos = FIRST_TX_COS_INDEX; cos < init_params->max_cos; cos++)
+	for (cos = FIRST_TX_COS_INDEX; cos < init_params->max_cos; cos++) {
+		cxt_index = fp->txdata[cos].cid / ILT_PAGE_CIDS;
+		cxt_offset = fp->txdata[cos].cid - (cxt_index *
+				ILT_PAGE_CIDS);
 		init_params->cxts[cos] =
-			&bp->context.vcxt[fp->txdata[cos].cid].eth;
+			&bp->context[cxt_index].vcxt[cxt_offset].eth;
+	}
 }
 
 int bnx2x_setup_tx_only(struct bnx2x *bp, struct bnx2x_fastpath *fp,
@@ -12202,6 +12228,7 @@ static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp)
 static void bnx2x_cnic_sp_post(struct bnx2x *bp, int count)
 {
 	struct eth_spe *spe;
+	int cxt_index, cxt_offset;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -12224,10 +12251,16 @@ static void bnx2x_cnic_sp_post(struct bnx2x *bp, int count)
 		 *  ramrod
 		 */
 		if (type == ETH_CONNECTION_TYPE) {
-			if (cmd == RAMROD_CMD_ID_ETH_CLIENT_SETUP)
-				bnx2x_set_ctx_validation(bp, &bp->context.
-					vcxt[BNX2X_ISCSI_ETH_CID].eth,
+			if (cmd == RAMROD_CMD_ID_ETH_CLIENT_SETUP) {
+				cxt_index = BNX2X_ISCSI_ETH_CID /
+					ILT_PAGE_CIDS;
+				cxt_offset = BNX2X_ISCSI_ETH_CID -
+					(cxt_index * ILT_PAGE_CIDS);
+				bnx2x_set_ctx_validation(bp,
+					&bp->context[cxt_index].
+							 vcxt[cxt_offset].eth,
 					BNX2X_ISCSI_ETH_CID);
+			}
 		}
 
 		/*
-- 
1.7.10
