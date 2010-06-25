From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 5/6] cnic: Further unify kcq handling code.
Date: Thu, 24 Jun 2010 17:58:41 -0700
Message-ID: <1277427522-17306-5-git-send-email-mchan@broadcom.com>
References: <1277427522-17306-1-git-send-email-mchan@broadcom.com>
 <1277427522-17306-2-git-send-email-mchan@broadcom.com>
 <1277427522-17306-3-git-send-email-mchan@broadcom.com>
 <1277427522-17306-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1422 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754103Ab0FYA4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 20:56:19 -0400
In-Reply-To: <1277427522-17306-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This eliminates some of the duplicate code for the various devices
that require the same basic kcq handling.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   71 +++++++++++++++++++++++++---------------------------
 1 files changed, 34 insertions(+), 37 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 8c41fe0..c0cc0d8 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2223,16 +2223,12 @@ static void cnic_chk_pkt_rings(struct cnic_local *cp)
 		clear_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags);
 }
 
-static int cnic_service_bnx2(void *data, void *status_blk)
+static u32 cnic_service_bnx2_queues(struct cnic_dev *dev)
 {
-	struct cnic_dev *dev = data;
 	struct cnic_local *cp = dev->cnic_priv;
-	u32 status_idx = *cp->kcq1.status_idx_ptr;
+	u32 status_idx = (u16) *cp->kcq1.status_idx_ptr;
 	int kcqe_cnt;
 
-	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags)))
-		return status_idx;
-
 	cp->kwq_con_idx = *cp->kwq_con_idx_ptr;
 
 	while ((kcqe_cnt = cnic_get_kcqes(dev, &cp->kcq1))) {
@@ -2242,7 +2238,7 @@ static int cnic_service_bnx2(void *data, void *status_blk)
 		/* Tell compiler that status_blk fields can change. */
 		barrier();
 		if (status_idx != *cp->kcq1.status_idx_ptr) {
-			status_idx = *cp->kcq1.status_idx_ptr;
+			status_idx = (u16) *cp->kcq1.status_idx_ptr;
 			cp->kwq_con_idx = *cp->kwq_con_idx_ptr;
 		} else
 			break;
@@ -2251,37 +2247,29 @@ static int cnic_service_bnx2(void *data, void *status_blk)
 	CNIC_WR16(dev, cp->kcq1.io_addr, cp->kcq1.sw_prod_idx);
 
 	cnic_chk_pkt_rings(cp);
+
 	return status_idx;
 }
 
-static void cnic_service_bnx2_msix(unsigned long data)
+static int cnic_service_bnx2(void *data, void *status_blk)
 {
-	struct cnic_dev *dev = (struct cnic_dev *) data;
+	struct cnic_dev *dev = data;
 	struct cnic_local *cp = dev->cnic_priv;
-	struct status_block_msix *status_blk = cp->status_blk.bnx2;
 	u32 status_idx = *cp->kcq1.status_idx_ptr;
-	int kcqe_cnt;
-
-	cp->kwq_con_idx = status_blk->status_cmd_consumer_index;
 
-	while ((kcqe_cnt = cnic_get_kcqes(dev, &cp->kcq1))) {
-
-		service_kcqes(dev, kcqe_cnt);
+	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags)))
+		return status_idx;
 
-		/* Tell compiler that status_blk fields can change. */
-		barrier();
-		if (status_idx != *cp->kcq1.status_idx_ptr) {
-			status_idx = *cp->kcq1.status_idx_ptr;
-			cp->kwq_con_idx = status_blk->status_cmd_consumer_index;
-		} else
-			break;
-	}
+	return cnic_service_bnx2_queues(dev);
+}
 
-	CNIC_WR16(dev, cp->kcq1.io_addr, cp->kcq1.sw_prod_idx);
+static void cnic_service_bnx2_msix(unsigned long data)
+{
+	struct cnic_dev *dev = (struct cnic_dev *) data;
+	struct cnic_local *cp = dev->cnic_priv;
 
-	cnic_chk_pkt_rings(cp);
+	cp->last_status_idx = cnic_service_bnx2_queues(dev);
 
-	cp->last_status_idx = status_idx;
 	CNIC_WR(dev, BNX2_PCICFG_INT_ACK_CMD, cp->int_num |
 		BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID | cp->last_status_idx);
 }
@@ -2338,27 +2326,35 @@ static void cnic_ack_bnx2x_msix(struct cnic_dev *dev)
 			   IGU_INT_DISABLE, 0);
 }
 
-static void cnic_service_bnx2x_bh(unsigned long data)
+static u32 cnic_service_bnx2x_kcq(struct cnic_dev *dev, struct kcq_info *info)
 {
-	struct cnic_dev *dev = (struct cnic_dev *) data;
-	struct cnic_local *cp = dev->cnic_priv;
-	u32 status_idx = *cp->kcq1.status_idx_ptr;
+	u32 last_status = *info->status_idx_ptr;
 	int kcqe_cnt;
 
-	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags)))
-		return;
-
-	while ((kcqe_cnt = cnic_get_kcqes(dev, &cp->kcq1))) {
+	while ((kcqe_cnt = cnic_get_kcqes(dev, info))) {
 
 		service_kcqes(dev, kcqe_cnt);
 
 		/* Tell compiler that sblk fields can change. */
 		barrier();
-		if (status_idx == *cp->kcq1.status_idx_ptr)
+		if (last_status == *info->status_idx_ptr)
 			break;
 
-		status_idx = *cp->kcq1.status_idx_ptr;
+		last_status = *info->status_idx_ptr;
 	}
+	return last_status;
+}
+
+static void cnic_service_bnx2x_bh(unsigned long data)
+{
+	struct cnic_dev *dev = (struct cnic_dev *) data;
+	struct cnic_local *cp = dev->cnic_priv;
+	u32 status_idx;
+
+	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags)))
+		return;
+
+	status_idx = cnic_service_bnx2x_kcq(dev, &cp->kcq1);
 
 	CNIC_WR16(dev, cp->kcq1.io_addr, cp->kcq1.sw_prod_idx + MAX_KCQ_IDX);
 	cnic_ack_bnx2x_int(dev, cp->status_blk_num, CSTORM_ID,
@@ -3786,6 +3782,7 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 		cp->kcq1.hw_prod_idx_ptr =
 			(u16 *) &msblk->status_completion_producer_index;
 		cp->kcq1.status_idx_ptr = (u16 *) &msblk->status_idx;
+		cp->kwq_con_idx_ptr = (u16 *) &msblk->status_cmd_consumer_index;
 		cp->int_num = sb_id << BNX2_PCICFG_INT_ACK_CMD_INT_NUM_SHIFT;
 		cnic_ctx_wr(dev, kwq_cid_addr, L5_KRNLQ_HOST_QIDX, sb);
 		cnic_ctx_wr(dev, kcq_cid_addr, L5_KRNLQ_HOST_QIDX, sb);
-- 
1.6.4.GIT


