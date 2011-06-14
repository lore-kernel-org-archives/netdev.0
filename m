From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 1/24] cnic: Move indexing function pointers to
 struct kcq_info
Date: Tue, 14 Jun 2011 14:32:38 +0300
Message-ID: <201106141432.38924.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2143 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756273Ab1FNLd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:33:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

The hardware indexing scheme for the FCoE kcq will change in the upcoming
firmware.  This patch will cope with the change easily.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
---
 drivers/net/cnic.c |   84 ++++++++++++++++++++++++++-------------------------
 drivers/net/cnic.h |    5 ++-
 2 files changed, 46 insertions(+), 43 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 363c7f3..07f1b13 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -900,24 +900,56 @@ static int cnic_alloc_context(struct cnic_dev *dev)
 	return 0;
 }
 
-static int cnic_alloc_kcq(struct cnic_dev *dev, struct kcq_info *info)
+static u16 cnic_bnx2_next_idx(u16 idx)
+{
+	return idx + 1;
+}
+
+static u16 cnic_bnx2_hw_idx(u16 idx)
+{
+	return idx;
+}
+
+static u16 cnic_bnx2x_next_idx(u16 idx)
 {
-	int err, i, is_bnx2 = 0;
+	idx++;
+	if ((idx & MAX_KCQE_CNT) == MAX_KCQE_CNT)
+		idx++;
+
+	return idx;
+}
+
+static u16 cnic_bnx2x_hw_idx(u16 idx)
+{
+	if ((idx & MAX_KCQE_CNT) == MAX_KCQE_CNT)
+		idx++;
+	return idx;
+}
+
+static int cnic_alloc_kcq(struct cnic_dev *dev, struct kcq_info *info,
+			  bool use_pg_tbl)
+{
+	int err, i, use_page_tbl = 0;
 	struct kcqe **kcq;
 
-	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags))
-		is_bnx2 = 1;
+	if (use_pg_tbl)
+		use_page_tbl = 1;
 
-	err = cnic_alloc_dma(dev, &info->dma, KCQ_PAGE_CNT, is_bnx2);
+	err = cnic_alloc_dma(dev, &info->dma, KCQ_PAGE_CNT, use_page_tbl);
 	if (err)
 		return err;
 
 	kcq = (struct kcqe **) info->dma.pg_arr;
 	info->kcq = kcq;
 
-	if (is_bnx2)
+	info->next_idx = cnic_bnx2_next_idx;
+	info->hw_idx = cnic_bnx2_hw_idx;
+	if (use_pg_tbl)
 		return 0;
 
+	info->next_idx = cnic_bnx2x_next_idx;
+	info->hw_idx = cnic_bnx2x_hw_idx;
+
 	for (i = 0; i < KCQ_PAGE_CNT; i++) {
 		struct bnx2x_bd_chain_next *next =
 			(struct bnx2x_bd_chain_next *) &kcq[i][MAX_KCQE_CNT];
@@ -1060,7 +1092,7 @@ static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
 		goto error;
 	cp->kwq = (struct kwqe **) cp->kwq_info.pg_arr;
 
-	ret = cnic_alloc_kcq(dev, &cp->kcq1);
+	ret = cnic_alloc_kcq(dev, &cp->kcq1, true);
 	if (ret)
 		goto error;
 
@@ -1196,12 +1228,12 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 			j++;
 	}
 
-	ret = cnic_alloc_kcq(dev, &cp->kcq1);
+	ret = cnic_alloc_kcq(dev, &cp->kcq1, false);
 	if (ret)
 		goto error;
 
 	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
-		ret = cnic_alloc_kcq(dev, &cp->kcq2);
+		ret = cnic_alloc_kcq(dev, &cp->kcq2, false);
 		if (ret)
 			goto error;
 	}
@@ -2652,32 +2684,6 @@ end:
 		cnic_spq_completion(dev, DRV_CTL_RET_L5_SPQ_CREDIT_CMD, comp);
 }
 
-static u16 cnic_bnx2_next_idx(u16 idx)
-{
-	return idx + 1;
-}
-
-static u16 cnic_bnx2_hw_idx(u16 idx)
-{
-	return idx;
-}
-
-static u16 cnic_bnx2x_next_idx(u16 idx)
-{
-	idx++;
-	if ((idx & MAX_KCQE_CNT) == MAX_KCQE_CNT)
-		idx++;
-
-	return idx;
-}
-
-static u16 cnic_bnx2x_hw_idx(u16 idx)
-{
-	if ((idx & MAX_KCQE_CNT) == MAX_KCQE_CNT)
-		idx++;
-	return idx;
-}
-
 static int cnic_get_kcqes(struct cnic_dev *dev, struct kcq_info *info)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -2688,12 +2694,12 @@ static int cnic_get_kcqes(struct cnic_dev *dev, struct kcq_info *info)
 	i = ri = last = info->sw_prod_idx;
 	ri &= MAX_KCQ_IDX;
 	hw_prod = *info->hw_prod_idx_ptr;
-	hw_prod = cp->hw_idx(hw_prod);
+	hw_prod = info->hw_idx(hw_prod);
 
 	while ((i != hw_prod) && (kcqe_cnt < MAX_COMPLETED_KCQE)) {
 		kcqe = &info->kcq[KCQ_PG(ri)][KCQ_IDX(ri)];
 		cp->completed_kcq[kcqe_cnt++] = kcqe;
-		i = cp->next_idx(i);
+		i = info->next_idx(i);
 		ri = i & MAX_KCQ_IDX;
 		if (likely(!(kcqe->kcqe_op_flag & KCQE_FLAGS_NEXT))) {
 			last_cnt = kcqe_cnt;
@@ -5227,8 +5233,6 @@ static struct cnic_dev *init_bnx2_cnic(struct net_device *dev)
 	cp->enable_int = cnic_enable_bnx2_int;
 	cp->disable_int_sync = cnic_disable_bnx2_int_sync;
 	cp->close_conn = cnic_close_bnx2_conn;
-	cp->next_idx = cnic_bnx2_next_idx;
-	cp->hw_idx = cnic_bnx2_hw_idx;
 	return cdev;
 
 cnic_err:
@@ -5294,8 +5298,6 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 	else
 		cp->ack_int = cnic_ack_bnx2x_msix;
 	cp->close_conn = cnic_close_bnx2x_conn;
-	cp->next_idx = cnic_bnx2x_next_idx;
-	cp->hw_idx = cnic_bnx2x_hw_idx;
 	return cdev;
 }
 
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 3367a6d3..eb11821 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -185,6 +185,9 @@ struct kcq_info {
 	u16		sw_prod_idx;
 	u16		*status_idx_ptr;
 	u32		io_addr;
+
+	u16		(*next_idx)(u16);
+	u16		(*hw_idx)(u16);
 };
 
 struct iro {
@@ -332,8 +335,6 @@ struct cnic_local {
 	void			(*disable_int_sync)(struct cnic_dev *);
 	void			(*ack_int)(struct cnic_dev *);
 	void			(*close_conn)(struct cnic_sock *, u32 opcode);
-	u16			(*next_idx)(u16);
-	u16			(*hw_idx)(u16);
 };
 
 struct bnx2x_bd_chain_next {
-- 
1.7.4.1


