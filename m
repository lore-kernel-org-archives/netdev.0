From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/6] cnic: Unify kcq allocation for all
 devices.
Date: Thu, 24 Jun 2010 17:58:39 -0700
Message-ID: <1277427522-17306-3-git-send-email-mchan@broadcom.com>
References: <1277427522-17306-1-git-send-email-mchan@broadcom.com>
 <1277427522-17306-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3197 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754023Ab0FYA4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 20:56:19 -0400
In-Reply-To: <1277427522-17306-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By creating a common data stucture kcq_info for all devices, the kcq
(kernel completion queue) for all devices can be allocated by common
code.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |  143 +++++++++++++++++++++++++++++++--------------------
 drivers/net/cnic.h |   19 ++++---
 2 files changed, 98 insertions(+), 64 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index bd92a24..948b25b 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -804,7 +804,7 @@ static void cnic_free_resc(struct cnic_dev *dev)
 	cnic_free_dma(dev, &cp->conn_buf_info);
 	cnic_free_dma(dev, &cp->kwq_info);
 	cnic_free_dma(dev, &cp->kwq_16_data_info);
-	cnic_free_dma(dev, &cp->kcq_info);
+	cnic_free_dma(dev, &cp->kcq1.dma);
 	kfree(cp->iscsi_tbl);
 	cp->iscsi_tbl = NULL;
 	kfree(cp->ctx_tbl);
@@ -863,6 +863,37 @@ static int cnic_alloc_context(struct cnic_dev *dev)
 	return 0;
 }
 
+static int cnic_alloc_kcq(struct cnic_dev *dev, struct kcq_info *info)
+{
+	int err, i, is_bnx2 = 0;
+	struct kcqe **kcq;
+
+	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags))
+		is_bnx2 = 1;
+
+	err = cnic_alloc_dma(dev, &info->dma, KCQ_PAGE_CNT, is_bnx2);
+	if (err)
+		return err;
+
+	kcq = (struct kcqe **) info->dma.pg_arr;
+	info->kcq = kcq;
+
+	if (is_bnx2)
+		return 0;
+
+	for (i = 0; i < KCQ_PAGE_CNT; i++) {
+		struct bnx2x_bd_chain_next *next =
+			(struct bnx2x_bd_chain_next *) &kcq[i][MAX_KCQE_CNT];
+		int j = i + 1;
+
+		if (j >= KCQ_PAGE_CNT)
+			j = 0;
+		next->addr_hi = (u64) info->dma.pg_map_arr[j] >> 32;
+		next->addr_lo = info->dma.pg_map_arr[j] & 0xffffffff;
+	}
+	return 0;
+}
+
 static int cnic_alloc_l2_rings(struct cnic_dev *dev, int pages)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -954,10 +985,9 @@ static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
 		goto error;
 	cp->kwq = (struct kwqe **) cp->kwq_info.pg_arr;
 
-	ret = cnic_alloc_dma(dev, &cp->kcq_info, KCQ_PAGE_CNT, 1);
+	ret = cnic_alloc_kcq(dev, &cp->kcq1);
 	if (ret)
 		goto error;
-	cp->kcq = (struct kcqe **) cp->kcq_info.pg_arr;
 
 	ret = cnic_alloc_context(dev);
 	if (ret)
@@ -1076,22 +1106,9 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 			j++;
 	}
 
-	ret = cnic_alloc_dma(dev, &cp->kcq_info, KCQ_PAGE_CNT, 0);
+	ret = cnic_alloc_kcq(dev, &cp->kcq1);
 	if (ret)
 		goto error;
-	cp->kcq = (struct kcqe **) cp->kcq_info.pg_arr;
-
-	for (i = 0; i < KCQ_PAGE_CNT; i++) {
-		struct bnx2x_bd_chain_next *next =
-			(struct bnx2x_bd_chain_next *)
-			&cp->kcq[i][MAX_KCQE_CNT];
-		int j = i + 1;
-
-		if (j >= KCQ_PAGE_CNT)
-			j = 0;
-		next->addr_hi = (u64) cp->kcq_info.pg_map_arr[j] >> 32;
-		next->addr_lo = cp->kcq_info.pg_map_arr[j] & 0xffffffff;
-	}
 
 	pages = PAGE_ALIGN(BNX2X_ISCSI_NUM_CONNECTIONS *
 			   BNX2X_ISCSI_CONN_BUF_SIZE) / PAGE_SIZE;
@@ -2135,7 +2152,7 @@ static int cnic_get_kcqes(struct cnic_dev *dev, u16 hw_prod, u16 *sw_prod)
 	ri &= MAX_KCQ_IDX;
 
 	while ((i != hw_prod) && (kcqe_cnt < MAX_COMPLETED_KCQE)) {
-		kcqe = &cp->kcq[KCQ_PG(ri)][KCQ_IDX(ri)];
+		kcqe = &cp->kcq1.kcq[KCQ_PG(ri)][KCQ_IDX(ri)];
 		cp->completed_kcq[kcqe_cnt++] = kcqe;
 		i = cp->next_idx(i);
 		ri = i & MAX_KCQ_IDX;
@@ -2219,7 +2236,7 @@ static int cnic_service_bnx2(void *data, void *status_blk)
 	cp->kwq_con_idx = *cp->kwq_con_idx_ptr;
 
 	hw_prod = sblk->status_completion_producer_index;
-	sw_prod = cp->kcq_prod_idx;
+	sw_prod = cp->kcq1.sw_prod_idx;
 	while (sw_prod != hw_prod) {
 		kcqe_cnt = cnic_get_kcqes(dev, hw_prod, &sw_prod);
 		if (kcqe_cnt == 0)
@@ -2238,9 +2255,9 @@ static int cnic_service_bnx2(void *data, void *status_blk)
 	}
 
 done:
-	CNIC_WR16(dev, cp->kcq_io_addr, sw_prod);
+	CNIC_WR16(dev, cp->kcq1.io_addr, sw_prod);
 
-	cp->kcq_prod_idx = sw_prod;
+	cp->kcq1.sw_prod_idx = sw_prod;
 
 	cnic_chk_pkt_rings(cp);
 	return status_idx;
@@ -2258,7 +2275,7 @@ static void cnic_service_bnx2_msix(unsigned long data)
 	cp->kwq_con_idx = status_blk->status_cmd_consumer_index;
 
 	hw_prod = status_blk->status_completion_producer_index;
-	sw_prod = cp->kcq_prod_idx;
+	sw_prod = cp->kcq1.sw_prod_idx;
 	while (sw_prod != hw_prod) {
 		kcqe_cnt = cnic_get_kcqes(dev, hw_prod, &sw_prod);
 		if (kcqe_cnt == 0)
@@ -2277,8 +2294,8 @@ static void cnic_service_bnx2_msix(unsigned long data)
 	}
 
 done:
-	CNIC_WR16(dev, cp->kcq_io_addr, sw_prod);
-	cp->kcq_prod_idx = sw_prod;
+	CNIC_WR16(dev, cp->kcq1.io_addr, sw_prod);
+	cp->kcq1.sw_prod_idx = sw_prod;
 
 	cnic_chk_pkt_rings(cp);
 
@@ -2290,11 +2307,11 @@ done:
 static void cnic_doirq(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	u16 prod = cp->kcq_prod_idx & MAX_KCQ_IDX;
+	u16 prod = cp->kcq1.sw_prod_idx & MAX_KCQ_IDX;
 
 	if (likely(test_bit(CNIC_F_CNIC_UP, &dev->flags))) {
 		prefetch(cp->status_blk.gen);
-		prefetch(&cp->kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
+		prefetch(&cp->kcq1.kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
 
 		tasklet_schedule(&cp->cnic_irq_task);
 	}
@@ -2354,7 +2371,7 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 
 	hw_prod = sblk->index_values[HC_INDEX_C_ISCSI_EQ_CONS];
 	hw_prod = cp->hw_idx(hw_prod);
-	sw_prod = cp->kcq_prod_idx;
+	sw_prod = cp->kcq1.sw_prod_idx;
 	while (sw_prod != hw_prod) {
 		kcqe_cnt = cnic_get_kcqes(dev, hw_prod, &sw_prod);
 		if (kcqe_cnt == 0)
@@ -2373,11 +2390,11 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 	}
 
 done:
-	CNIC_WR16(dev, cp->kcq_io_addr, sw_prod + MAX_KCQ_IDX);
+	CNIC_WR16(dev, cp->kcq1.io_addr, sw_prod + MAX_KCQ_IDX);
 	cnic_ack_bnx2x_int(dev, cp->status_blk_num, CSTORM_ID,
 			   status_idx, IGU_INT_ENABLE, 1);
 
-	cp->kcq_prod_idx = sw_prod;
+	cp->kcq1.sw_prod_idx = sw_prod;
 }
 
 static int cnic_service_bnx2x(void *data, void *status_blk)
@@ -3711,7 +3728,7 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 	struct cnic_local *cp = dev->cnic_priv;
 	struct cnic_eth_dev *ethdev = cp->ethdev;
 	struct status_block *sblk = cp->status_blk.gen;
-	u32 val;
+	u32 val, kcq_cid_addr, kwq_cid_addr;
 	int err;
 
 	cnic_set_bnx2_mac(dev);
@@ -3736,7 +3753,7 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 	cnic_init_context(dev, KWQ_CID);
 	cnic_init_context(dev, KCQ_CID);
 
-	cp->kwq_cid_addr = GET_CID_ADDR(KWQ_CID);
+	kwq_cid_addr = GET_CID_ADDR(KWQ_CID);
 	cp->kwq_io_addr = MB_GET_CID_ADDR(KWQ_CID) + L5_KRNLQ_HOST_QIDX;
 
 	cp->max_kwq_idx = MAX_KWQ_IDX;
@@ -3752,50 +3769,58 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 	/* Initialize the kernel work queue context. */
 	val = KRNLQ_TYPE_TYPE_KRNLQ | KRNLQ_SIZE_TYPE_SIZE |
 	      (BCM_PAGE_BITS - 8) | KRNLQ_FLAGS_QE_SELF_SEQ;
-	cnic_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_TYPE, val);
+	cnic_ctx_wr(dev, kwq_cid_addr, L5_KRNLQ_TYPE, val);
 
 	val = (BCM_PAGE_SIZE / sizeof(struct kwqe) - 1) << 16;
-	cnic_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_QE_SELF_SEQ_MAX, val);
+	cnic_ctx_wr(dev, kwq_cid_addr, L5_KRNLQ_QE_SELF_SEQ_MAX, val);
 
 	val = ((BCM_PAGE_SIZE / sizeof(struct kwqe)) << 16) | KWQ_PAGE_CNT;
-	cnic_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_PGTBL_NPAGES, val);
+	cnic_ctx_wr(dev, kwq_cid_addr, L5_KRNLQ_PGTBL_NPAGES, val);
 
 	val = (u32) ((u64) cp->kwq_info.pgtbl_map >> 32);
-	cnic_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_PGTBL_HADDR_HI, val);
+	cnic_ctx_wr(dev, kwq_cid_addr, L5_KRNLQ_PGTBL_HADDR_HI, val);
 
 	val = (u32) cp->kwq_info.pgtbl_map;
-	cnic_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_PGTBL_HADDR_LO, val);
+	cnic_ctx_wr(dev, kwq_cid_addr, L5_KRNLQ_PGTBL_HADDR_LO, val);
+
+	kcq_cid_addr = GET_CID_ADDR(KCQ_CID);
+	cp->kcq1.io_addr = MB_GET_CID_ADDR(KCQ_CID) + L5_KRNLQ_HOST_QIDX;
 
-	cp->kcq_cid_addr = GET_CID_ADDR(KCQ_CID);
-	cp->kcq_io_addr = MB_GET_CID_ADDR(KCQ_CID) + L5_KRNLQ_HOST_QIDX;
+	cp->kcq1.sw_prod_idx = 0;
+	cp->kcq1.hw_prod_idx_ptr =
+		(u16 *) &sblk->status_completion_producer_index;
 
-	cp->kcq_prod_idx = 0;
+	cp->kcq1.status_idx_ptr = (u16 *) &sblk->status_idx;
 
 	/* Initialize the kernel complete queue context. */
 	val = KRNLQ_TYPE_TYPE_KRNLQ | KRNLQ_SIZE_TYPE_SIZE |
 	      (BCM_PAGE_BITS - 8) | KRNLQ_FLAGS_QE_SELF_SEQ;
-	cnic_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_TYPE, val);
+	cnic_ctx_wr(dev, kcq_cid_addr, L5_KRNLQ_TYPE, val);
 
 	val = (BCM_PAGE_SIZE / sizeof(struct kcqe) - 1) << 16;
-	cnic_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_QE_SELF_SEQ_MAX, val);
+	cnic_ctx_wr(dev, kcq_cid_addr, L5_KRNLQ_QE_SELF_SEQ_MAX, val);
 
 	val = ((BCM_PAGE_SIZE / sizeof(struct kcqe)) << 16) | KCQ_PAGE_CNT;
-	cnic_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_PGTBL_NPAGES, val);
+	cnic_ctx_wr(dev, kcq_cid_addr, L5_KRNLQ_PGTBL_NPAGES, val);
 
-	val = (u32) ((u64) cp->kcq_info.pgtbl_map >> 32);
-	cnic_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_PGTBL_HADDR_HI, val);
+	val = (u32) ((u64) cp->kcq1.dma.pgtbl_map >> 32);
+	cnic_ctx_wr(dev, kcq_cid_addr, L5_KRNLQ_PGTBL_HADDR_HI, val);
 
-	val = (u32) cp->kcq_info.pgtbl_map;
-	cnic_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_PGTBL_HADDR_LO, val);
+	val = (u32) cp->kcq1.dma.pgtbl_map;
+	cnic_ctx_wr(dev, kcq_cid_addr, L5_KRNLQ_PGTBL_HADDR_LO, val);
 
 	cp->int_num = 0;
 	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
+		struct status_block_msix *msblk = cp->status_blk.bnx2;
 		u32 sb_id = cp->status_blk_num;
 		u32 sb = BNX2_L2CTX_L5_STATUSB_NUM(sb_id);
 
+		cp->kcq1.hw_prod_idx_ptr =
+			(u16 *) &msblk->status_completion_producer_index;
+		cp->kcq1.status_idx_ptr = (u16 *) &msblk->status_idx;
 		cp->int_num = sb_id << BNX2_PCICFG_INT_ACK_CMD_INT_NUM_SHIFT;
-		cnic_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_HOST_QIDX, sb);
-		cnic_ctx_wr(dev, cp->kcq_cid_addr, L5_KRNLQ_HOST_QIDX, sb);
+		cnic_ctx_wr(dev, kwq_cid_addr, L5_KRNLQ_HOST_QIDX, sb);
+		cnic_ctx_wr(dev, kcq_cid_addr, L5_KRNLQ_HOST_QIDX, sb);
 	}
 
 	/* Enable Commnad Scheduler notification when we write to the
@@ -4132,28 +4157,34 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	if (ret)
 		return -ENOMEM;
 
-	cp->kcq_io_addr = BAR_CSTRORM_INTMEM +
+	cp->kcq1.io_addr = BAR_CSTRORM_INTMEM +
 			  CSTORM_ISCSI_EQ_PROD_OFFSET(func, 0);
-	cp->kcq_prod_idx = 0;
+	cp->kcq1.sw_prod_idx = 0;
+
+	cp->kcq1.hw_prod_idx_ptr =
+		&cp->status_blk.bnx2x->c_status_block.index_values[
+			HC_INDEX_C_ISCSI_EQ_CONS];
+	cp->kcq1.status_idx_ptr =
+		&cp->status_blk.bnx2x->c_status_block.status_block_index;
 
 	cnic_get_bnx2x_iscsi_info(dev);
 
 	/* Only 1 EQ */
-	CNIC_WR16(dev, cp->kcq_io_addr, MAX_KCQ_IDX);
+	CNIC_WR16(dev, cp->kcq1.io_addr, MAX_KCQ_IDX);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
 		CSTORM_ISCSI_EQ_CONS_OFFSET(func, 0), 0);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
 		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_OFFSET(func, 0),
-		cp->kcq_info.pg_map_arr[1] & 0xffffffff);
+		cp->kcq1.dma.pg_map_arr[1] & 0xffffffff);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
 		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_OFFSET(func, 0) + 4,
-		(u64) cp->kcq_info.pg_map_arr[1] >> 32);
+		(u64) cp->kcq1.dma.pg_map_arr[1] >> 32);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
 		CSTORM_ISCSI_EQ_NEXT_EQE_ADDR_OFFSET(func, 0),
-		cp->kcq_info.pg_map_arr[0] & 0xffffffff);
+		cp->kcq1.dma.pg_map_arr[0] & 0xffffffff);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
 		CSTORM_ISCSI_EQ_NEXT_EQE_ADDR_OFFSET(func, 0) + 4,
-		(u64) cp->kcq_info.pg_map_arr[0] >> 32);
+		(u64) cp->kcq1.dma.pg_map_arr[0] >> 32);
 	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
 		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_VALID_OFFSET(func, 0), 1);
 	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
@@ -4381,7 +4412,7 @@ static void cnic_stop_bnx2x_hw(struct cnic_dev *dev)
 		  0);
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
 		CSTORM_ISCSI_EQ_CONS_OFFSET(cp->func, 0), 0);
-	CNIC_WR16(dev, cp->kcq_io_addr, 0);
+	CNIC_WR16(dev, cp->kcq1.io_addr, 0);
 	cnic_free_resc(dev);
 }
 
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index b7e2f7f..275c361 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -169,6 +169,16 @@ struct cnic_context {
 	} proto;
 };
 
+struct kcq_info {
+	struct cnic_dma	dma;
+	struct kcqe	**kcq;
+
+	u16		*hw_prod_idx_ptr;
+	u16		sw_prod_idx;
+	u16		*status_idx_ptr;
+	u32		io_addr;
+};
+
 struct cnic_local {
 
 	spinlock_t cnic_ulp_lock;
@@ -202,9 +212,6 @@ struct cnic_local {
 	u16		rx_cons;
 	u16		tx_cons;
 
-	u32 kwq_cid_addr;
-	u32 kcq_cid_addr;
-
 	struct cnic_dma		kwq_info;
 	struct kwqe		**kwq;
 
@@ -218,11 +225,7 @@ struct cnic_local {
 	u16		*kwq_con_idx_ptr;
 	u16		kwq_con_idx;
 
-	struct cnic_dma	kcq_info;
-	struct kcqe	**kcq;
-
-	u16		kcq_prod_idx;
-	u32		kcq_io_addr;
+	struct kcq_info	kcq1;
 
 	union {
 		void				*gen;
-- 
1.6.4.GIT


