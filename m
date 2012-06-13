From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 6/12] bnx2x: Move the CNIC L2 CIDs to be right
 after the RSS CIDs
Date: Wed, 13 Jun 2012 15:44:18 +0300
Message-ID: <1339591464-10554-7-git-send-email-meravs@broadcom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1464 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496Ab2FMJte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 05:49:34 -0400
In-Reply-To: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the CNIC-related L2 CIDs (for sending control FCoE / iSCSI packets)
were at fixed position, according to the maximal number of RSS queues multiplied
by the number of traffic-classes. This change makes the CIDs dynamic, as they
are defined to be right after the highest RSS CID. This decreases the memory
allocated for the context.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |   19 +++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |   15 ++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   47 +++++++++++++++-------
 4 files changed, 52 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 36ebc3d..68d0d2c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -248,13 +248,12 @@ enum {
 	BNX2X_MAX_CNIC_ETH_CL_ID_IDX,
 };
 
-#define BNX2X_CNIC_START_ETH_CID	48
-enum {
+#define BNX2X_CNIC_START_ETH_CID(bp)	(BNX2X_NUM_NON_CNIC_QUEUES(bp) *\
+					 (bp)->max_cos)
 	/* iSCSI L2 */
-	BNX2X_ISCSI_ETH_CID = BNX2X_CNIC_START_ETH_CID,
+#define	BNX2X_ISCSI_ETH_CID(bp)		(BNX2X_CNIC_START_ETH_CID(bp))
 	/* FCoE L2 */
-	BNX2X_FCOE_ETH_CID,
-};
+#define	BNX2X_FCOE_ETH_CID(bp)		(BNX2X_CNIC_START_ETH_CID(bp) + 1)
 
 /** Additional rings budgeting */
 #ifdef BCM_CNIC
@@ -276,8 +275,6 @@ enum {
 #define FIRST_TX_ONLY_COS_INDEX		1
 #define FIRST_TX_COS_INDEX		0
 
-#define MAX_TXQS_PER_COS	FP_SB_MAX_E1x
-
 /* rules for calculating the cids of tx-only connections */
 #define CID_TO_FP(cid, bp)		((cid) % BNX2X_NUM_NON_CNIC_QUEUES(bp))
 #define CID_COS_TO_TX_ONLY_CID(cid, cos, bp) \
@@ -1463,10 +1460,12 @@ struct bnx2x {
 
 /*
  * Maximum CID count that might be required by the bnx2x:
- * Max Tss * Max_Tx_Multi_Cos + CNIC L2 Clients (FCoE and iSCSI related)
+ * Max RSS * Max_Tx_Multi_Cos + FCoE + iSCSI
  */
-#define BNX2X_L2_CID_COUNT(bp)	(MAX_TXQS_PER_COS * BNX2X_MULTI_TX_COS +\
-					NON_ETH_CONTEXT_USE + CNIC_PRESENT)
+#define BNX2X_L2_CID_COUNT(bp)	(BNX2X_NUM_ETH_QUEUES(bp) * BNX2X_MULTI_TX_COS \
+				+ NON_ETH_CONTEXT_USE + CNIC_PRESENT)
+#define BNX2X_L2_MAX_CID(bp)	(BNX2X_MAX_RSS_COUNT(bp) * BNX2X_MULTI_TX_COS \
+				+ NON_ETH_CONTEXT_USE + CNIC_PRESENT)
 #define L2_ILT_LINES(bp)	(DIV_ROUND_UP(BNX2X_L2_CID_COUNT(bp),\
 					ILT_PAGE_CIDS))
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 33132b1..d76df33 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2220,6 +2220,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* re-read iscsi info */
 	bnx2x_get_iscsi_info(bp);
 	bnx2x_setup_cnic_irq_info(bp);
+	bnx2x_setup_cnic_info(bp);
 	if (bp->state == BNX2X_STATE_OPEN)
 		bnx2x_cnic_notify(bp, CNIC_CTL_START_CMD);
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 112ffcc..de79cdf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -244,6 +244,14 @@ int bnx2x_cnic_notify(struct bnx2x *bp, int cmd);
  * @bp:		driver handle
  */
 void bnx2x_setup_cnic_irq_info(struct bnx2x *bp);
+
+/**
+ * bnx2x_setup_cnic_info - provides cnic with updated info
+ *
+ * @bp:		driver handle
+ */
+void bnx2x_setup_cnic_info(struct bnx2x *bp);
+
 #endif
 
 /**
@@ -1107,12 +1115,7 @@ static inline void bnx2x_init_fcoe_fp(struct bnx2x *bp)
 	bnx2x_fcoe(bp, rx_queue) = BNX2X_NUM_ETH_QUEUES(bp);
 	bnx2x_fcoe(bp, cl_id) = bnx2x_cnic_eth_cl_id(bp,
 						     BNX2X_FCOE_ETH_CL_ID_IDX);
-	/** Current BNX2X_FCOE_ETH_CID deffinition implies not more than
-	 *  16 ETH clients per function when CNIC is enabled!
-	 *
-	 *  Fix it ASAP!!!
-	 */
-	bnx2x_fcoe(bp, cid) = BNX2X_FCOE_ETH_CID;
+	bnx2x_fcoe(bp, cid) = BNX2X_FCOE_ETH_CID(bp);
 	bnx2x_fcoe(bp, fw_sb_id) = DEF_SB_ID;
 	bnx2x_fcoe(bp, igu_sb_id) = bp->igu_dsb_id;
 	bnx2x_fcoe(bp, rx_cons_sb) = BNX2X_FCOE_L2_RX_INDEX;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f80059e..1895de5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -4628,7 +4628,7 @@ static void bnx2x_handle_classification_eqe(struct bnx2x *bp,
 	case BNX2X_FILTER_MAC_PENDING:
 		DP(BNX2X_MSG_SP, "Got SETUP_MAC completions\n");
 #ifdef BCM_CNIC
-		if (cid == BNX2X_ISCSI_ETH_CID)
+		if (cid == BNX2X_ISCSI_ETH_CID(bp))
 			vlan_mac_obj = &bp->iscsi_l2_mac_obj;
 		else
 #endif
@@ -4774,7 +4774,7 @@ static struct bnx2x_queue_sp_obj *bnx2x_cid_to_q_obj(
 {
 	DP(BNX2X_MSG_SP, "retrieving fp from cid %d\n", cid);
 #ifdef BCM_CNIC
-	if (cid == BNX2X_FCOE_ETH_CID)
+	if (cid == BNX2X_FCOE_ETH_CID(bp))
 		return &bnx2x_fcoe(bp, q_obj);
 	else
 #endif
@@ -11724,7 +11724,7 @@ void bnx2x__init_func_obj(struct bnx2x *bp)
 /* must be called after sriov-enable */
 static int bnx2x_set_qm_cid_count(struct bnx2x *bp)
 {
-	int cid_count = BNX2X_L2_CID_COUNT(bp);
+	int cid_count = BNX2X_L2_MAX_CID(bp);
 
 #ifdef BCM_CNIC
 	cid_count += CNIC_CID_MAX;
@@ -11829,9 +11829,9 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	/*
 	 * Maximum number of netdev Tx queues:
-	 *      Maximum TSS queues * Maximum supported number of CoS  + FCoE L2
+	 * Maximum TSS queues * Maximum supported number of CoS  + FCoE L2
 	 */
-	tx_count = MAX_TXQS_PER_COS * max_cos_est + FCOE_PRESENT;
+	tx_count = rss_count * max_cos_est + FCOE_PRESENT;
 
 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mqs(sizeof(*bp), tx_count, rx_count);
@@ -11863,11 +11863,15 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	 * Map doorbels here as we need the real value of bp->max_cos which
 	 * is initialized in bnx2x_init_bp().
 	 */
-	doorbell_size = (rss_count * max_cos_est + NON_ETH_CONTEXT_USE +
-			 CNIC_PRESENT) * (1 << BNX2X_DB_SHIFT);
+	doorbell_size = BNX2X_L2_MAX_CID(bp) * (1 << BNX2X_DB_SHIFT);
+	if (doorbell_size > pci_resource_len(pdev, 2)) {
+		dev_err(&bp->pdev->dev,
+			"Cannot map doorbells, bar size too small, aborting\n");
+		rc = -ENOMEM;
+		goto init_one_exit;
+	}
 	bp->doorbells = ioremap_nocache(pci_resource_start(pdev, 2),
-					min_t(u64, doorbell_size,
-					      pci_resource_len(pdev, 2)));
+					doorbell_size);
 	if (!bp->doorbells) {
 		dev_err(&bp->pdev->dev,
 			"Cannot map doorbell space, aborting\n");
@@ -12254,14 +12258,14 @@ static void bnx2x_cnic_sp_post(struct bnx2x *bp, int count)
 		 */
 		if (type == ETH_CONNECTION_TYPE) {
 			if (cmd == RAMROD_CMD_ID_ETH_CLIENT_SETUP) {
-				cxt_index = BNX2X_ISCSI_ETH_CID /
+				cxt_index = BNX2X_ISCSI_ETH_CID(bp) /
 					ILT_PAGE_CIDS;
-				cxt_offset = BNX2X_ISCSI_ETH_CID -
+				cxt_offset = BNX2X_ISCSI_ETH_CID(bp) -
 					(cxt_index * ILT_PAGE_CIDS);
 				bnx2x_set_ctx_validation(bp,
 					&bp->context[cxt_index].
 							 vcxt[cxt_offset].eth,
-					BNX2X_ISCSI_ETH_CID);
+					BNX2X_ISCSI_ETH_CID(bp));
 			}
 		}
 
@@ -12615,6 +12619,21 @@ void bnx2x_setup_cnic_irq_info(struct bnx2x *bp)
 	cp->num_irq = 2;
 }
 
+void bnx2x_setup_cnic_info(struct bnx2x *bp)
+{
+	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
+
+
+	cp->ctx_tbl_offset = FUNC_ILT_BASE(BP_FUNC(bp)) +
+			     bnx2x_cid_ilt_lines(bp);
+	cp->starting_cid = bnx2x_cid_ilt_lines(bp) * ILT_PAGE_CIDS;
+	cp->fcoe_init_cid = BNX2X_FCOE_ETH_CID(bp);
+	cp->iscsi_l2_cid = BNX2X_ISCSI_ETH_CID(bp);
+
+	if (NO_ISCSI_OOO(bp))
+		cp->drv_state |= CNIC_DRV_STATE_NO_ISCSI_OOO;
+}
+
 static int bnx2x_register_cnic(struct net_device *dev, struct cnic_ops *ops,
 			       void *data)
 {
@@ -12693,10 +12712,10 @@ struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
 	cp->drv_ctl = bnx2x_drv_ctl;
 	cp->drv_register_cnic = bnx2x_register_cnic;
 	cp->drv_unregister_cnic = bnx2x_unregister_cnic;
-	cp->fcoe_init_cid = BNX2X_FCOE_ETH_CID;
+	cp->fcoe_init_cid = BNX2X_FCOE_ETH_CID(bp);
 	cp->iscsi_l2_client_id =
 		bnx2x_cnic_eth_cl_id(bp, BNX2X_ISCSI_ETH_CL_ID_IDX);
-	cp->iscsi_l2_cid = BNX2X_ISCSI_ETH_CID;
+	cp->iscsi_l2_cid = BNX2X_ISCSI_ETH_CID(bp);
 
 	if (NO_ISCSI_OOO(bp))
 		cp->drv_state |= CNIC_DRV_STATE_NO_ISCSI_OOO;
-- 
1.7.10
