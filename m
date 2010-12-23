From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 8/9] cnic: Add kcq2 support on 57712
Date: Thu, 23 Dec 2010 09:43:03 -0800
Message-ID: <1293126184-13097-9-git-send-email-mchan@broadcom.com>
References: <1293126184-13097-1-git-send-email-mchan@broadcom.com>
 <1293126184-13097-2-git-send-email-mchan@broadcom.com>
 <1293126184-13097-3-git-send-email-mchan@broadcom.com>
 <1293126184-13097-4-git-send-email-mchan@broadcom.com>
 <1293126184-13097-5-git-send-email-mchan@broadcom.com>
 <1293126184-13097-6-git-send-email-mchan@broadcom.com>
 <1293126184-13097-7-git-send-email-mchan@broadcom.com>
 <1293126184-13097-8-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4511 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428Ab0LWSir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 13:38:47 -0500
In-Reply-To: <1293126184-13097-8-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kcq2 (2nd kernel work queue) is used by FCoE on 57712 devices.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   76 +++++++++++++++++++++++++++++++++++++--------------
 drivers/net/cnic.h |    1 +
 2 files changed, 56 insertions(+), 21 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 36c1578..6ce7398 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -843,6 +843,7 @@ static void cnic_free_resc(struct cnic_dev *dev)
 	cnic_free_dma(dev, &cp->conn_buf_info);
 	cnic_free_dma(dev, &cp->kwq_info);
 	cnic_free_dma(dev, &cp->kwq_16_data_info);
+	cnic_free_dma(dev, &cp->kcq2.dma);
 	cnic_free_dma(dev, &cp->kcq1.dma);
 	kfree(cp->iscsi_tbl);
 	cp->iscsi_tbl = NULL;
@@ -1183,6 +1184,12 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	if (ret)
 		goto error;
 
+	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
+		ret = cnic_alloc_kcq(dev, &cp->kcq2);
+		if (ret)
+			goto error;
+	}
+
 	pages = PAGE_ALIGN(BNX2X_ISCSI_NUM_CONNECTIONS *
 			   BNX2X_ISCSI_CONN_BUF_SIZE) / PAGE_SIZE;
 	ret = cnic_alloc_dma(dev, &cp->conn_buf_info, pages, 1);
@@ -2493,12 +2500,19 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 	status_idx = cnic_service_bnx2x_kcq(dev, &cp->kcq1);
 
 	CNIC_WR16(dev, cp->kcq1.io_addr, cp->kcq1.sw_prod_idx + MAX_KCQ_IDX);
-	if (BNX2X_CHIP_IS_E2(cp->chip_id))
+
+	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
+		status_idx = cnic_service_bnx2x_kcq(dev, &cp->kcq2);
+
+		CNIC_WR16(dev, cp->kcq2.io_addr, cp->kcq2.sw_prod_idx +
+			  MAX_KCQ_IDX);
+
 		cnic_ack_igu_sb(dev, cp->bnx2x_igu_sb_id, IGU_SEG_ACCESS_DEF,
 				status_idx, IGU_INT_ENABLE, 1);
-	else
+	} else {
 		cnic_ack_bnx2x_int(dev, cp->bnx2x_igu_sb_id, USTORM_ID,
 				   status_idx, IGU_INT_ENABLE, 1);
+	}
 }
 
 static int cnic_service_bnx2x(void *data, void *status_blk)
@@ -4381,6 +4395,44 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 		dev->max_iscsi_conn = 0;
 }
 
+static void cnic_init_bnx2x_kcq(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	u32 pfid = cp->pfid;
+
+	cp->kcq1.io_addr = BAR_CSTRORM_INTMEM +
+			   CSTORM_ISCSI_EQ_PROD_OFFSET(pfid, 0);
+	cp->kcq1.sw_prod_idx = 0;
+
+	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
+		struct host_hc_status_block_e2 *sb = cp->status_blk.gen;
+
+		cp->kcq1.hw_prod_idx_ptr =
+			&sb->sb.index_values[HC_INDEX_ISCSI_EQ_CONS];
+		cp->kcq1.status_idx_ptr =
+			&sb->sb.running_index[SM_RX_ID];
+	} else {
+		struct host_hc_status_block_e1x *sb = cp->status_blk.gen;
+
+		cp->kcq1.hw_prod_idx_ptr =
+			&sb->sb.index_values[HC_INDEX_ISCSI_EQ_CONS];
+		cp->kcq1.status_idx_ptr =
+			&sb->sb.running_index[SM_RX_ID];
+	}
+
+	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
+		struct host_hc_status_block_e2 *sb = cp->status_blk.gen;
+
+		cp->kcq2.io_addr = BAR_USTRORM_INTMEM +
+					USTORM_FCOE_EQ_PROD_OFFSET(pfid);
+		cp->kcq2.sw_prod_idx = 0;
+		cp->kcq2.hw_prod_idx_ptr =
+			&sb->sb.index_values[HC_INDEX_FCOE_EQ_CONS];
+		cp->kcq2.status_idx_ptr =
+			&sb->sb.running_index[SM_RX_ID];
+	}
+}
+
 static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -4413,25 +4465,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 
 	cp->bnx2x_igu_sb_id = ethdev->irq_arr[0].status_blk_num2;
 
-	cp->kcq1.io_addr = BAR_CSTRORM_INTMEM +
-			  CSTORM_ISCSI_EQ_PROD_OFFSET(pfid, 0);
-	cp->kcq1.sw_prod_idx = 0;
-
-	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
-		struct host_hc_status_block_e2 *sb = cp->status_blk.gen;
-
-		cp->kcq1.hw_prod_idx_ptr =
-			&sb->sb.index_values[HC_INDEX_ISCSI_EQ_CONS];
-		cp->kcq1.status_idx_ptr =
-			&sb->sb.running_index[SM_RX_ID];
-	} else {
-		struct host_hc_status_block_e1x *sb = cp->status_blk.gen;
-
-		cp->kcq1.hw_prod_idx_ptr =
-			&sb->sb.index_values[HC_INDEX_ISCSI_EQ_CONS];
-		cp->kcq1.status_idx_ptr =
-			&sb->sb.running_index[SM_RX_ID];
-	}
+	cnic_init_bnx2x_kcq(dev);
 
 	cnic_get_bnx2x_iscsi_info(dev);
 
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index fb3b753..e46b4c1 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -258,6 +258,7 @@ struct cnic_local {
 	u16		kwq_con_idx;
 
 	struct kcq_info	kcq1;
+	struct kcq_info	kcq2;
 
 	union {
 		void				*gen;
-- 
1.6.4.GIT


