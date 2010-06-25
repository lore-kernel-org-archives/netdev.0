From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/6] cnic: Restructure kcq processing.
Date: Thu, 24 Jun 2010 17:58:40 -0700
Message-ID: <1277427522-17306-4-git-send-email-mchan@broadcom.com>
References: <1277427522-17306-1-git-send-email-mchan@broadcom.com>
 <1277427522-17306-2-git-send-email-mchan@broadcom.com>
 <1277427522-17306-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1420 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106Ab0FYA4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 20:56:19 -0400
In-Reply-To: <1277427522-17306-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By doing more work in the common function cnic_get_kcqes(), and
making full use of the kcq_info structure.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   76 +++++++++++++++-------------------------------------
 1 files changed, 22 insertions(+), 54 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 948b25b..8c41fe0 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2141,18 +2141,20 @@ static u16 cnic_bnx2x_hw_idx(u16 idx)
 	return idx;
 }
 
-static int cnic_get_kcqes(struct cnic_dev *dev, u16 hw_prod, u16 *sw_prod)
+static int cnic_get_kcqes(struct cnic_dev *dev, struct kcq_info *info)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	u16 i, ri, last;
+	u16 i, ri, hw_prod, last;
 	struct kcqe *kcqe;
 	int kcqe_cnt = 0, last_cnt = 0;
 
-	i = ri = last = *sw_prod;
+	i = ri = last = info->sw_prod_idx;
 	ri &= MAX_KCQ_IDX;
+	hw_prod = *info->hw_prod_idx_ptr;
+	hw_prod = cp->hw_idx(hw_prod);
 
 	while ((i != hw_prod) && (kcqe_cnt < MAX_COMPLETED_KCQE)) {
-		kcqe = &cp->kcq1.kcq[KCQ_PG(ri)][KCQ_IDX(ri)];
+		kcqe = &info->kcq[KCQ_PG(ri)][KCQ_IDX(ri)];
 		cp->completed_kcq[kcqe_cnt++] = kcqe;
 		i = cp->next_idx(i);
 		ri = i & MAX_KCQ_IDX;
@@ -2162,7 +2164,7 @@ static int cnic_get_kcqes(struct cnic_dev *dev, u16 hw_prod, u16 *sw_prod)
 		}
 	}
 
-	*sw_prod = last;
+	info->sw_prod_idx = last;
 	return last_cnt;
 }
 
@@ -2224,10 +2226,8 @@ static void cnic_chk_pkt_rings(struct cnic_local *cp)
 static int cnic_service_bnx2(void *data, void *status_blk)
 {
 	struct cnic_dev *dev = data;
-	struct status_block *sblk = status_blk;
 	struct cnic_local *cp = dev->cnic_priv;
-	u32 status_idx = sblk->status_idx;
-	u16 hw_prod, sw_prod;
+	u32 status_idx = *cp->kcq1.status_idx_ptr;
 	int kcqe_cnt;
 
 	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags)))
@@ -2235,29 +2235,20 @@ static int cnic_service_bnx2(void *data, void *status_blk)
 
 	cp->kwq_con_idx = *cp->kwq_con_idx_ptr;
 
-	hw_prod = sblk->status_completion_producer_index;
-	sw_prod = cp->kcq1.sw_prod_idx;
-	while (sw_prod != hw_prod) {
-		kcqe_cnt = cnic_get_kcqes(dev, hw_prod, &sw_prod);
-		if (kcqe_cnt == 0)
-			goto done;
+	while ((kcqe_cnt = cnic_get_kcqes(dev, &cp->kcq1))) {
 
 		service_kcqes(dev, kcqe_cnt);
 
 		/* Tell compiler that status_blk fields can change. */
 		barrier();
-		if (status_idx != sblk->status_idx) {
-			status_idx = sblk->status_idx;
+		if (status_idx != *cp->kcq1.status_idx_ptr) {
+			status_idx = *cp->kcq1.status_idx_ptr;
 			cp->kwq_con_idx = *cp->kwq_con_idx_ptr;
-			hw_prod = sblk->status_completion_producer_index;
 		} else
 			break;
 	}
 
-done:
-	CNIC_WR16(dev, cp->kcq1.io_addr, sw_prod);
-
-	cp->kcq1.sw_prod_idx = sw_prod;
+	CNIC_WR16(dev, cp->kcq1.io_addr, cp->kcq1.sw_prod_idx);
 
 	cnic_chk_pkt_rings(cp);
 	return status_idx;
@@ -2268,34 +2259,25 @@ static void cnic_service_bnx2_msix(unsigned long data)
 	struct cnic_dev *dev = (struct cnic_dev *) data;
 	struct cnic_local *cp = dev->cnic_priv;
 	struct status_block_msix *status_blk = cp->status_blk.bnx2;
-	u32 status_idx = status_blk->status_idx;
-	u16 hw_prod, sw_prod;
+	u32 status_idx = *cp->kcq1.status_idx_ptr;
 	int kcqe_cnt;
 
 	cp->kwq_con_idx = status_blk->status_cmd_consumer_index;
 
-	hw_prod = status_blk->status_completion_producer_index;
-	sw_prod = cp->kcq1.sw_prod_idx;
-	while (sw_prod != hw_prod) {
-		kcqe_cnt = cnic_get_kcqes(dev, hw_prod, &sw_prod);
-		if (kcqe_cnt == 0)
-			goto done;
+	while ((kcqe_cnt = cnic_get_kcqes(dev, &cp->kcq1))) {
 
 		service_kcqes(dev, kcqe_cnt);
 
 		/* Tell compiler that status_blk fields can change. */
 		barrier();
-		if (status_idx != status_blk->status_idx) {
-			status_idx = status_blk->status_idx;
+		if (status_idx != *cp->kcq1.status_idx_ptr) {
+			status_idx = *cp->kcq1.status_idx_ptr;
 			cp->kwq_con_idx = status_blk->status_cmd_consumer_index;
-			hw_prod = status_blk->status_completion_producer_index;
 		} else
 			break;
 	}
 
-done:
-	CNIC_WR16(dev, cp->kcq1.io_addr, sw_prod);
-	cp->kcq1.sw_prod_idx = sw_prod;
+	CNIC_WR16(dev, cp->kcq1.io_addr, cp->kcq1.sw_prod_idx);
 
 	cnic_chk_pkt_rings(cp);
 
@@ -2360,41 +2342,27 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 {
 	struct cnic_dev *dev = (struct cnic_dev *) data;
 	struct cnic_local *cp = dev->cnic_priv;
-	u16 hw_prod, sw_prod;
-	struct cstorm_status_block_c *sblk =
-		&cp->status_blk.bnx2x->c_status_block;
-	u32 status_idx = sblk->status_block_index;
+	u32 status_idx = *cp->kcq1.status_idx_ptr;
 	int kcqe_cnt;
 
 	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags)))
 		return;
 
-	hw_prod = sblk->index_values[HC_INDEX_C_ISCSI_EQ_CONS];
-	hw_prod = cp->hw_idx(hw_prod);
-	sw_prod = cp->kcq1.sw_prod_idx;
-	while (sw_prod != hw_prod) {
-		kcqe_cnt = cnic_get_kcqes(dev, hw_prod, &sw_prod);
-		if (kcqe_cnt == 0)
-			goto done;
+	while ((kcqe_cnt = cnic_get_kcqes(dev, &cp->kcq1))) {
 
 		service_kcqes(dev, kcqe_cnt);
 
 		/* Tell compiler that sblk fields can change. */
 		barrier();
-		if (status_idx == sblk->status_block_index)
+		if (status_idx == *cp->kcq1.status_idx_ptr)
 			break;
 
-		status_idx = sblk->status_block_index;
-		hw_prod = sblk->index_values[HC_INDEX_C_ISCSI_EQ_CONS];
-		hw_prod = cp->hw_idx(hw_prod);
+		status_idx = *cp->kcq1.status_idx_ptr;
 	}
 
-done:
-	CNIC_WR16(dev, cp->kcq1.io_addr, sw_prod + MAX_KCQ_IDX);
+	CNIC_WR16(dev, cp->kcq1.io_addr, cp->kcq1.sw_prod_idx + MAX_KCQ_IDX);
 	cnic_ack_bnx2x_int(dev, cp->status_blk_num, CSTORM_ID,
 			   status_idx, IGU_INT_ENABLE, 1);
-
-	cp->kcq1.sw_prod_idx = sw_prod;
 }
 
 static int cnic_service_bnx2x(void *data, void *status_blk)
-- 
1.6.4.GIT


