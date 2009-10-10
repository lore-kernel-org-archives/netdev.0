From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 7/7] cnic: Add main functions to support bnx2x devices.
Date: Sat, 10 Oct 2009 16:46:59 -0700
Message-ID: <1255218419-17320-7-git-send-email-mchan@broadcom.com>
References: <1255218419-17320-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michaelc@cs.wisc.edu,
	shmulikr@broadcom.com, eilong@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2231 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758147AbZJJXjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2009 19:39:11 -0400
In-Reply-To: <1255218419-17320-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add iSCSI support for bnx2x devices.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Shmulik Ravid - Rabinovitz <shmulikr@broadcom.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/cnic.c | 1742 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 1742 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 1fd1058..6e7af7b 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -64,6 +64,7 @@ static DEFINE_MUTEX(cnic_lock);
 static struct cnic_ulp_ops *cnic_ulp_tbl[MAX_CNIC_ULP_TYPE];
 
 static int cnic_service_bnx2(void *, void *);
+static int cnic_service_bnx2x(void *, void *);
 static int cnic_ctl(void *, struct cnic_ctl_info *);
 
 static struct cnic_ops cnic_bnx2_ops = {
@@ -72,6 +73,12 @@ static struct cnic_ops cnic_bnx2_ops = {
 	.cnic_ctl	= cnic_ctl,
 };
 
+static struct cnic_ops cnic_bnx2x_ops = {
+	.cnic_owner	= THIS_MODULE,
+	.cnic_handler	= cnic_service_bnx2x,
+	.cnic_ctl	= cnic_ctl,
+};
+
 static void cnic_shutdown_rings(struct cnic_dev *);
 static void cnic_init_rings(struct cnic_dev *);
 static int cnic_cm_set_pg(struct cnic_sock *);
@@ -172,6 +179,36 @@ static void cnic_ctx_wr(struct cnic_dev *dev, u32 cid_addr, u32 off, u32 val)
 	ethdev->drv_ctl(dev->netdev, &info);
 }
 
+static void cnic_ctx_tbl_wr(struct cnic_dev *dev, u32 off, dma_addr_t addr)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_eth_dev *ethdev = cp->ethdev;
+	struct drv_ctl_info info;
+	struct drv_ctl_io *io = &info.data.io;
+
+	info.cmd = DRV_CTL_CTXTBL_WR_CMD;
+	io->offset = off;
+	io->dma_addr = addr;
+	ethdev->drv_ctl(dev->netdev, &info);
+}
+
+static void cnic_ring_ctl(struct cnic_dev *dev, u32 cid, u32 cl_id, int start)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_eth_dev *ethdev = cp->ethdev;
+	struct drv_ctl_info info;
+	struct drv_ctl_l2_ring *ring = &info.data.ring;
+
+	if (start)
+		info.cmd = DRV_CTL_START_L2_CMD;
+	else
+		info.cmd = DRV_CTL_STOP_L2_CMD;
+
+	ring->cid = cid;
+	ring->client_id = cl_id;
+	ethdev->drv_ctl(dev->netdev, &info);
+}
+
 static void cnic_reg_wr_ind(struct cnic_dev *dev, u32 off, u32 val)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -214,6 +251,19 @@ static void cnic_kwq_completion(struct cnic_dev *dev, u32 count)
 	ethdev->drv_ctl(dev->netdev, &info);
 }
 
+static int cnic_get_l5_cid(struct cnic_local *cp, u32 cid, u32 *l5_cid)
+{
+	u32 i;
+
+	for (i = 0; i < MAX_ISCSI_TBL_SZ; i++) {
+		if (cp->ctx_tbl[i].cid == cid) {
+			*l5_cid = i;
+			return 0;
+		}
+	}
+	return -EINVAL;
+}
+
 static int cnic_send_nlmsg(struct cnic_local *cp, u32 type,
 			   struct cnic_sock *csk)
 {
@@ -645,6 +695,20 @@ static void cnic_setup_page_tbl(struct cnic_dev *dev, struct cnic_dma *dma)
 	}
 }
 
+static void cnic_setup_page_tbl_le(struct cnic_dev *dev, struct cnic_dma *dma)
+{
+	int i;
+	u32 *page_table = dma->pgtbl;
+
+	for (i = 0; i < dma->num_pages; i++) {
+		/* Each entry needs to be in little endian format. */
+		*page_table = dma->pg_map_arr[i] & 0xffffffff;
+		page_table++;
+		*page_table = (u32) ((u64) dma->pg_map_arr[i] >> 32);
+		page_table++;
+	}
+}
+
 static int cnic_alloc_dma(struct cnic_dev *dev, struct cnic_dma *dma,
 			  int pages, int use_pg_tbl)
 {
@@ -735,6 +799,7 @@ static void cnic_free_resc(struct cnic_dev *dev)
 	cnic_free_dma(dev, &cp->gbl_buf_info);
 	cnic_free_dma(dev, &cp->conn_buf_info);
 	cnic_free_dma(dev, &cp->kwq_info);
+	cnic_free_dma(dev, &cp->kwq_16_data_info);
 	cnic_free_dma(dev, &cp->kcq_info);
 	kfree(cp->iscsi_tbl);
 	cp->iscsi_tbl = NULL;
@@ -834,6 +899,12 @@ static int cnic_alloc_uio(struct cnic_dev *dev) {
 			uinfo->mem[1].size = BNX2_SBLK_MSIX_ALIGN_SIZE;
 
 		uinfo->name = "bnx2_cnic";
+	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
+		uinfo->mem[1].addr = (unsigned long) cp->bnx2x_def_status_blk &
+			PAGE_MASK;
+		uinfo->mem[1].size = sizeof(struct host_def_status_block);
+
+		uinfo->name = "bnx2x_cnic";
 	}
 
 	uinfo->mem[1].memtype = UIO_MEM_LOGICAL;
@@ -898,6 +969,151 @@ error:
 	return ret;
 }
 
+static int cnic_alloc_bnx2x_context(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_eth_dev *ethdev = cp->ethdev;
+	int ctx_blk_size = cp->ethdev->ctx_blk_size;
+	int total_mem, blks, i, cid_space;
+
+	if (BNX2X_ISCSI_START_CID < ethdev->starting_cid)
+		return -EINVAL;
+
+	cid_space = MAX_ISCSI_TBL_SZ +
+		    (BNX2X_ISCSI_START_CID - ethdev->starting_cid);
+
+	total_mem = BNX2X_CONTEXT_MEM_SIZE * cid_space;
+	blks = total_mem / ctx_blk_size;
+	if (total_mem % ctx_blk_size)
+		blks++;
+
+	if (blks > cp->ethdev->ctx_tbl_len)
+		return -ENOMEM;
+
+	cp->ctx_arr = kzalloc(blks * sizeof(struct cnic_ctx), GFP_KERNEL);
+	if (cp->ctx_arr == NULL)
+		return -ENOMEM;
+
+	cp->ctx_blks = blks;
+	cp->ctx_blk_size = ctx_blk_size;
+	if (BNX2X_CHIP_IS_E1H(cp->chip_id))
+		cp->ctx_align = 0;
+	else
+		cp->ctx_align = ctx_blk_size;
+
+	cp->cids_per_blk = ctx_blk_size / BNX2X_CONTEXT_MEM_SIZE;
+
+	for (i = 0; i < blks; i++) {
+		cp->ctx_arr[i].ctx =
+			pci_alloc_consistent(dev->pcidev, cp->ctx_blk_size,
+					     &cp->ctx_arr[i].mapping);
+		if (cp->ctx_arr[i].ctx == NULL)
+			return -ENOMEM;
+
+		if (cp->ctx_align && cp->ctx_blk_size == ctx_blk_size) {
+			if (cp->ctx_arr[i].mapping & (cp->ctx_align - 1)) {
+				cnic_free_context(dev);
+				cp->ctx_blk_size += cp->ctx_align;
+				i = -1;
+				continue;
+			}
+		}
+	}
+	return 0;
+}
+
+static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int i, j, n, ret, pages;
+	struct cnic_dma *kwq_16_dma = &cp->kwq_16_data_info;
+
+	cp->iscsi_tbl = kzalloc(sizeof(struct cnic_iscsi) * MAX_ISCSI_TBL_SZ,
+				GFP_KERNEL);
+	if (!cp->iscsi_tbl)
+		goto error;
+
+	cp->ctx_tbl = kzalloc(sizeof(struct cnic_context) *
+				  MAX_CNIC_L5_CONTEXT, GFP_KERNEL);
+	if (!cp->ctx_tbl)
+		goto error;
+
+	for (i = 0; i < MAX_ISCSI_TBL_SZ; i++) {
+		cp->ctx_tbl[i].proto.iscsi = &cp->iscsi_tbl[i];
+		cp->ctx_tbl[i].ulp_proto_id = CNIC_ULP_ISCSI;
+	}
+
+	pages = PAGE_ALIGN(MAX_CNIC_L5_CONTEXT * CNIC_KWQ16_DATA_SIZE) /
+		PAGE_SIZE;
+
+	ret = cnic_alloc_dma(dev, kwq_16_dma, pages, 0);
+	if (ret)
+		return -ENOMEM;
+
+	n = PAGE_SIZE / CNIC_KWQ16_DATA_SIZE;
+	for (i = 0, j = 0; i < MAX_ISCSI_TBL_SZ; i++) {
+		long off = CNIC_KWQ16_DATA_SIZE * (i % n);
+
+		cp->ctx_tbl[i].kwqe_data = kwq_16_dma->pg_arr[j] + off;
+		cp->ctx_tbl[i].kwqe_data_mapping = kwq_16_dma->pg_map_arr[j] +
+						   off;
+
+		if ((i % n) == (n - 1))
+			j++;
+	}
+
+	ret = cnic_alloc_dma(dev, &cp->kcq_info, KCQ_PAGE_CNT, 0);
+	if (ret)
+		goto error;
+	cp->kcq = (struct kcqe **) cp->kcq_info.pg_arr;
+
+	for (i = 0; i < KCQ_PAGE_CNT; i++) {
+		struct bnx2x_bd_chain_next *next =
+			(struct bnx2x_bd_chain_next *)
+			&cp->kcq[i][MAX_KCQE_CNT];
+		int j = i + 1;
+
+		if (j >= KCQ_PAGE_CNT)
+			j = 0;
+		next->addr_hi = (u64) cp->kcq_info.pg_map_arr[j] >> 32;
+		next->addr_lo = cp->kcq_info.pg_map_arr[j] & 0xffffffff;
+	}
+
+	pages = PAGE_ALIGN(BNX2X_ISCSI_NUM_CONNECTIONS *
+			   BNX2X_ISCSI_CONN_BUF_SIZE) / PAGE_SIZE;
+	ret = cnic_alloc_dma(dev, &cp->conn_buf_info, pages, 1);
+	if (ret)
+		goto error;
+
+	pages = PAGE_ALIGN(BNX2X_ISCSI_GLB_BUF_SIZE) / PAGE_SIZE;
+	ret = cnic_alloc_dma(dev, &cp->gbl_buf_info, pages, 0);
+	if (ret)
+		goto error;
+
+	ret = cnic_alloc_bnx2x_context(dev);
+	if (ret)
+		goto error;
+
+	cp->bnx2x_status_blk = cp->status_blk;
+	cp->bnx2x_def_status_blk = cp->ethdev->irq_arr[1].status_blk;
+
+	cp->l2_rx_ring_size = 15;
+
+	ret = cnic_alloc_l2_rings(dev, 4);
+	if (ret)
+		goto error;
+
+	ret = cnic_alloc_uio(dev);
+	if (ret)
+		goto error;
+
+	return 0;
+
+error:
+	cnic_free_resc(dev);
+	return -ENOMEM;
+}
+
 static inline u32 cnic_kwq_avail(struct cnic_local *cp)
 {
 	return cp->max_kwq_idx -
@@ -939,6 +1155,880 @@ static int cnic_submit_bnx2_kwqes(struct cnic_dev *dev, struct kwqe *wqes[],
 	return 0;
 }
 
+static void *cnic_get_kwqe_16_data(struct cnic_local *cp, u32 l5_cid,
+				   union l5cm_specific_data *l5_data)
+{
+	struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
+	dma_addr_t map;
+
+	map = ctx->kwqe_data_mapping;
+	l5_data->phy_address.lo = (u64) map & 0xffffffff;
+	l5_data->phy_address.hi = (u64) map >> 32;
+	return ctx->kwqe_data;
+}
+
+static int cnic_submit_kwqe_16(struct cnic_dev *dev, u32 cmd, u32 cid,
+				u32 type, union l5cm_specific_data *l5_data)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct l5cm_spe kwqe;
+	struct kwqe_16 *kwq[1];
+	int ret;
+
+	kwqe.hdr.conn_and_cmd_data =
+		cpu_to_le32(((cmd << SPE_HDR_CMD_ID_SHIFT) |
+			     BNX2X_HW_CID(cid, cp->func)));
+	kwqe.hdr.type = cpu_to_le16(type);
+	kwqe.hdr.reserved = 0;
+	kwqe.data.phy_address.lo = cpu_to_le32(l5_data->phy_address.lo);
+	kwqe.data.phy_address.hi = cpu_to_le32(l5_data->phy_address.hi);
+
+	kwq[0] = (struct kwqe_16 *) &kwqe;
+
+	spin_lock_bh(&cp->cnic_ulp_lock);
+	ret = cp->ethdev->drv_submit_kwqes_16(dev->netdev, kwq, 1);
+	spin_unlock_bh(&cp->cnic_ulp_lock);
+
+	if (ret == 1)
+		return 0;
+
+	return -EBUSY;
+}
+
+static void cnic_reply_bnx2x_kcqes(struct cnic_dev *dev, int ulp_type,
+				   struct kcqe *cqes[], u32 num_cqes)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_ulp_ops *ulp_ops;
+
+	rcu_read_lock();
+	ulp_ops = rcu_dereference(cp->ulp_ops[ulp_type]);
+	if (likely(ulp_ops)) {
+		ulp_ops->indicate_kcqes(cp->ulp_handle[ulp_type],
+					  cqes, num_cqes);
+	}
+	rcu_read_unlock();
+}
+
+static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct iscsi_kwqe_init1 *req1 = (struct iscsi_kwqe_init1 *) kwqe;
+	int func = cp->func, pages;
+	int hq_bds;
+
+	cp->num_iscsi_tasks = req1->num_tasks_per_conn;
+	cp->num_ccells = req1->num_ccells_per_conn;
+	cp->task_array_size = BNX2X_ISCSI_TASK_CONTEXT_SIZE *
+			      cp->num_iscsi_tasks;
+	cp->r2tq_size = cp->num_iscsi_tasks * BNX2X_ISCSI_MAX_PENDING_R2TS *
+			BNX2X_ISCSI_R2TQE_SIZE;
+	cp->hq_size = cp->num_ccells * BNX2X_ISCSI_HQ_BD_SIZE;
+	pages = PAGE_ALIGN(cp->hq_size) / PAGE_SIZE;
+	hq_bds = pages * (PAGE_SIZE / BNX2X_ISCSI_HQ_BD_SIZE);
+	cp->num_cqs = req1->num_cqs;
+
+	if (!dev->max_iscsi_conn)
+		return 0;
+
+	/* init Tstorm RAM */
+	CNIC_WR16(dev, BAR_TSTRORM_INTMEM + TSTORM_ISCSI_RQ_SIZE_OFFSET(func),
+		  req1->rq_num_wqes);
+	CNIC_WR16(dev, BAR_TSTRORM_INTMEM + TSTORM_ISCSI_PAGE_SIZE_OFFSET(func),
+		  PAGE_SIZE);
+	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
+		 TSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(func), PAGE_SHIFT);
+	CNIC_WR16(dev, BAR_TSTRORM_INTMEM +
+		  TSTORM_ISCSI_NUM_OF_TASKS_OFFSET(func),
+		  req1->num_tasks_per_conn);
+
+	/* init Ustorm RAM */
+	CNIC_WR16(dev, BAR_USTRORM_INTMEM +
+		  USTORM_ISCSI_RQ_BUFFER_SIZE_OFFSET(func),
+		  req1->rq_buffer_size);
+	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_PAGE_SIZE_OFFSET(func),
+		  PAGE_SIZE);
+	CNIC_WR8(dev, BAR_USTRORM_INTMEM +
+		 USTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(func), PAGE_SHIFT);
+	CNIC_WR16(dev, BAR_USTRORM_INTMEM +
+		  USTORM_ISCSI_NUM_OF_TASKS_OFFSET(func),
+		  req1->num_tasks_per_conn);
+	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_RQ_SIZE_OFFSET(func),
+		  req1->rq_num_wqes);
+	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_CQ_SIZE_OFFSET(func),
+		  req1->cq_num_wqes);
+	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_R2TQ_SIZE_OFFSET(func),
+		  cp->num_iscsi_tasks * BNX2X_ISCSI_MAX_PENDING_R2TS);
+
+	/* init Xstorm RAM */
+	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_PAGE_SIZE_OFFSET(func),
+		  PAGE_SIZE);
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(func), PAGE_SHIFT);
+	CNIC_WR16(dev, BAR_XSTRORM_INTMEM +
+		  XSTORM_ISCSI_NUM_OF_TASKS_OFFSET(func),
+		  req1->num_tasks_per_conn);
+	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_HQ_SIZE_OFFSET(func),
+		  hq_bds);
+	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_SQ_SIZE_OFFSET(func),
+		  req1->num_tasks_per_conn);
+	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_R2TQ_SIZE_OFFSET(func),
+		  cp->num_iscsi_tasks * BNX2X_ISCSI_MAX_PENDING_R2TS);
+
+	/* init Cstorm RAM */
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_ISCSI_PAGE_SIZE_OFFSET(func),
+		  PAGE_SIZE);
+	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
+		 CSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(func), PAGE_SHIFT);
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
+		  CSTORM_ISCSI_NUM_OF_TASKS_OFFSET(func),
+		  req1->num_tasks_per_conn);
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_ISCSI_CQ_SIZE_OFFSET(func),
+		  req1->cq_num_wqes);
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_ISCSI_HQ_SIZE_OFFSET(func),
+		  hq_bds);
+
+	return 0;
+}
+
+static int cnic_bnx2x_iscsi_init2(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct iscsi_kwqe_init2 *req2 = (struct iscsi_kwqe_init2 *) kwqe;
+	struct cnic_local *cp = dev->cnic_priv;
+	int func = cp->func;
+	struct iscsi_kcqe kcqe;
+	struct kcqe *cqes[1];
+
+	memset(&kcqe, 0, sizeof(kcqe));
+	if (!dev->max_iscsi_conn) {
+		kcqe.completion_status =
+			ISCSI_KCQE_COMPLETION_STATUS_ISCSI_NOT_SUPPORTED;
+		goto done;
+	}
+
+	CNIC_WR(dev, BAR_TSTRORM_INTMEM +
+		TSTORM_ISCSI_ERROR_BITMAP_OFFSET(func), req2->error_bit_map[0]);
+	CNIC_WR(dev, BAR_TSTRORM_INTMEM +
+		TSTORM_ISCSI_ERROR_BITMAP_OFFSET(func) + 4,
+		req2->error_bit_map[1]);
+
+	CNIC_WR16(dev, BAR_USTRORM_INTMEM +
+		  USTORM_ISCSI_CQ_SQN_SIZE_OFFSET(func), req2->max_cq_sqn);
+	CNIC_WR(dev, BAR_USTRORM_INTMEM +
+		USTORM_ISCSI_ERROR_BITMAP_OFFSET(func), req2->error_bit_map[0]);
+	CNIC_WR(dev, BAR_USTRORM_INTMEM +
+		USTORM_ISCSI_ERROR_BITMAP_OFFSET(func) + 4,
+		req2->error_bit_map[1]);
+
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
+		  CSTORM_ISCSI_CQ_SQN_SIZE_OFFSET(func), req2->max_cq_sqn);
+
+	kcqe.completion_status = ISCSI_KCQE_COMPLETION_STATUS_SUCCESS;
+
+done:
+	kcqe.op_code = ISCSI_KCQE_OPCODE_INIT;
+	cqes[0] = (struct kcqe *) &kcqe;
+	cnic_reply_bnx2x_kcqes(dev, CNIC_ULP_ISCSI, cqes, 1);
+
+	return 0;
+}
+
+static void cnic_free_bnx2x_conn_resc(struct cnic_dev *dev, u32 l5_cid)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
+
+	if (ctx->ulp_proto_id == CNIC_ULP_ISCSI) {
+		struct cnic_iscsi *iscsi = ctx->proto.iscsi;
+
+		cnic_free_dma(dev, &iscsi->hq_info);
+		cnic_free_dma(dev, &iscsi->r2tq_info);
+		cnic_free_dma(dev, &iscsi->task_array_info);
+	}
+	cnic_free_id(&cp->cid_tbl, ctx->cid);
+	ctx->cid = 0;
+}
+
+static int cnic_alloc_bnx2x_conn_resc(struct cnic_dev *dev, u32 l5_cid)
+{
+	u32 cid;
+	int ret, pages;
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
+	struct cnic_iscsi *iscsi = ctx->proto.iscsi;
+
+	cid = cnic_alloc_new_id(&cp->cid_tbl);
+	if (cid == -1) {
+		ret = -ENOMEM;
+		goto error;
+	}
+
+	ctx->cid = cid;
+	pages = PAGE_ALIGN(cp->task_array_size) / PAGE_SIZE;
+
+	ret = cnic_alloc_dma(dev, &iscsi->task_array_info, pages, 1);
+	if (ret)
+		goto error;
+
+	pages = PAGE_ALIGN(cp->r2tq_size) / PAGE_SIZE;
+	ret = cnic_alloc_dma(dev, &iscsi->r2tq_info, pages, 1);
+	if (ret)
+		goto error;
+
+	pages = PAGE_ALIGN(cp->hq_size) / PAGE_SIZE;
+	ret = cnic_alloc_dma(dev, &iscsi->hq_info, pages, 1);
+	if (ret)
+		goto error;
+
+	return 0;
+
+error:
+	cnic_free_bnx2x_conn_resc(dev, l5_cid);
+	return ret;
+}
+
+static void *cnic_get_bnx2x_ctx(struct cnic_dev *dev, u32 cid, int init,
+				struct regpair *ctx_addr)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_eth_dev *ethdev = cp->ethdev;
+	int blk = (cid - ethdev->starting_cid) / cp->cids_per_blk;
+	int off = (cid - ethdev->starting_cid) % cp->cids_per_blk;
+	unsigned long align_off = 0;
+	dma_addr_t ctx_map;
+	void *ctx;
+
+	if (cp->ctx_align) {
+		unsigned long mask = cp->ctx_align - 1;
+
+		if (cp->ctx_arr[blk].mapping & mask)
+			align_off = cp->ctx_align -
+				    (cp->ctx_arr[blk].mapping & mask);
+	}
+	ctx_map = cp->ctx_arr[blk].mapping + align_off +
+		(off * BNX2X_CONTEXT_MEM_SIZE);
+	ctx = cp->ctx_arr[blk].ctx + align_off +
+	      (off * BNX2X_CONTEXT_MEM_SIZE);
+	if (init)
+		memset(ctx, 0, BNX2X_CONTEXT_MEM_SIZE);
+
+	ctx_addr->lo = ctx_map & 0xffffffff;
+	ctx_addr->hi = (u64) ctx_map >> 32;
+	return ctx;
+}
+
+static int cnic_setup_bnx2x_ctx(struct cnic_dev *dev, struct kwqe *wqes[],
+				u32 num)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct iscsi_kwqe_conn_offload1 *req1 =
+			(struct iscsi_kwqe_conn_offload1 *) wqes[0];
+	struct iscsi_kwqe_conn_offload2 *req2 =
+			(struct iscsi_kwqe_conn_offload2 *) wqes[1];
+	struct iscsi_kwqe_conn_offload3 *req3;
+	struct cnic_context *ctx = &cp->ctx_tbl[req1->iscsi_conn_id];
+	struct cnic_iscsi *iscsi = ctx->proto.iscsi;
+	u32 cid = ctx->cid;
+	u32 hw_cid = BNX2X_HW_CID(cid, cp->func);
+	struct iscsi_context *ictx;
+	struct regpair context_addr;
+	int i, j, n = 2, n_max;
+
+	ctx->ctx_flags = 0;
+	if (!req2->num_additional_wqes)
+		return -EINVAL;
+
+	n_max = req2->num_additional_wqes + 2;
+
+	ictx = cnic_get_bnx2x_ctx(dev, cid, 1, &context_addr);
+	if (ictx == NULL)
+		return -ENOMEM;
+
+	req3 = (struct iscsi_kwqe_conn_offload3 *) wqes[n++];
+
+	ictx->xstorm_ag_context.hq_prod = 1;
+
+	ictx->xstorm_st_context.iscsi.first_burst_length =
+		ISCSI_DEF_FIRST_BURST_LEN;
+	ictx->xstorm_st_context.iscsi.max_send_pdu_length =
+		ISCSI_DEF_MAX_RECV_SEG_LEN;
+	ictx->xstorm_st_context.iscsi.sq_pbl_base.lo =
+		req1->sq_page_table_addr_lo;
+	ictx->xstorm_st_context.iscsi.sq_pbl_base.hi =
+		req1->sq_page_table_addr_hi;
+	ictx->xstorm_st_context.iscsi.sq_curr_pbe.lo = req2->sq_first_pte.hi;
+	ictx->xstorm_st_context.iscsi.sq_curr_pbe.hi = req2->sq_first_pte.lo;
+	ictx->xstorm_st_context.iscsi.hq_pbl_base.lo =
+		iscsi->hq_info.pgtbl_map & 0xffffffff;
+	ictx->xstorm_st_context.iscsi.hq_pbl_base.hi =
+		(u64) iscsi->hq_info.pgtbl_map >> 32;
+	ictx->xstorm_st_context.iscsi.hq_curr_pbe_base.lo =
+		iscsi->hq_info.pgtbl[0];
+	ictx->xstorm_st_context.iscsi.hq_curr_pbe_base.hi =
+		iscsi->hq_info.pgtbl[1];
+	ictx->xstorm_st_context.iscsi.r2tq_pbl_base.lo =
+		iscsi->r2tq_info.pgtbl_map & 0xffffffff;
+	ictx->xstorm_st_context.iscsi.r2tq_pbl_base.hi =
+		(u64) iscsi->r2tq_info.pgtbl_map >> 32;
+	ictx->xstorm_st_context.iscsi.r2tq_curr_pbe_base.lo =
+		iscsi->r2tq_info.pgtbl[0];
+	ictx->xstorm_st_context.iscsi.r2tq_curr_pbe_base.hi =
+		iscsi->r2tq_info.pgtbl[1];
+	ictx->xstorm_st_context.iscsi.task_pbl_base.lo =
+		iscsi->task_array_info.pgtbl_map & 0xffffffff;
+	ictx->xstorm_st_context.iscsi.task_pbl_base.hi =
+		(u64) iscsi->task_array_info.pgtbl_map >> 32;
+	ictx->xstorm_st_context.iscsi.task_pbl_cache_idx =
+		BNX2X_ISCSI_PBL_NOT_CACHED;
+	ictx->xstorm_st_context.iscsi.flags.flags |=
+		XSTORM_ISCSI_CONTEXT_FLAGS_B_IMMEDIATE_DATA;
+	ictx->xstorm_st_context.iscsi.flags.flags |=
+		XSTORM_ISCSI_CONTEXT_FLAGS_B_INITIAL_R2T;
+
+	ictx->tstorm_st_context.iscsi.hdr_bytes_2_fetch = ISCSI_HEADER_SIZE;
+	/* TSTORM requires the base address of RQ DB & not PTE */
+	ictx->tstorm_st_context.iscsi.rq_db_phy_addr.lo =
+		req2->rq_page_table_addr_lo & PAGE_MASK;
+	ictx->tstorm_st_context.iscsi.rq_db_phy_addr.hi =
+		req2->rq_page_table_addr_hi;
+	ictx->tstorm_st_context.iscsi.iscsi_conn_id = req1->iscsi_conn_id;
+	ictx->tstorm_st_context.tcp.cwnd = 0x5A8;
+	ictx->tstorm_st_context.tcp.flags2 |=
+		TSTORM_TCP_ST_CONTEXT_SECTION_DA_EN;
+
+	ictx->timers_context.flags |= ISCSI_TIMERS_BLOCK_CONTEXT_CONN_VALID_FLG;
+
+	ictx->ustorm_st_context.ring.rq.pbl_base.lo =
+		req2->rq_page_table_addr_lo & 0xffffffff;
+	ictx->ustorm_st_context.ring.rq.pbl_base.hi =
+		(u64) req2->rq_page_table_addr_hi >> 32;
+	ictx->ustorm_st_context.ring.rq.curr_pbe.lo = req3->qp_first_pte[0].hi;
+	ictx->ustorm_st_context.ring.rq.curr_pbe.hi = req3->qp_first_pte[0].lo;
+	ictx->ustorm_st_context.ring.r2tq.pbl_base.lo =
+		iscsi->r2tq_info.pgtbl_map & 0xffffffff;
+	ictx->ustorm_st_context.ring.r2tq.pbl_base.hi =
+		(u64) iscsi->r2tq_info.pgtbl_map >> 32;
+	ictx->ustorm_st_context.ring.r2tq.curr_pbe.lo =
+		iscsi->r2tq_info.pgtbl[0];
+	ictx->ustorm_st_context.ring.r2tq.curr_pbe.hi =
+		iscsi->r2tq_info.pgtbl[1];
+	ictx->ustorm_st_context.ring.cq_pbl_base.lo =
+		req1->cq_page_table_addr_lo;
+	ictx->ustorm_st_context.ring.cq_pbl_base.hi =
+		req1->cq_page_table_addr_hi;
+	ictx->ustorm_st_context.ring.cq[0].cq_sn = ISCSI_INITIAL_SN;
+	ictx->ustorm_st_context.ring.cq[0].curr_pbe.lo = req2->cq_first_pte.hi;
+	ictx->ustorm_st_context.ring.cq[0].curr_pbe.hi = req2->cq_first_pte.lo;
+	ictx->ustorm_st_context.task_pbe_cache_index =
+		BNX2X_ISCSI_PBL_NOT_CACHED;
+	ictx->ustorm_st_context.task_pdu_cache_index =
+		BNX2X_ISCSI_PDU_HEADER_NOT_CACHED;
+
+	for (i = 1, j = 1; i < cp->num_cqs; i++, j++) {
+		if (j == 3) {
+			if (n >= n_max)
+				break;
+			req3 = (struct iscsi_kwqe_conn_offload3 *) wqes[n++];
+			j = 0;
+		}
+		ictx->ustorm_st_context.ring.cq[i].cq_sn = ISCSI_INITIAL_SN;
+		ictx->ustorm_st_context.ring.cq[i].curr_pbe.lo =
+			req3->qp_first_pte[j].hi;
+		ictx->ustorm_st_context.ring.cq[i].curr_pbe.hi =
+			req3->qp_first_pte[j].lo;
+	}
+
+	ictx->ustorm_st_context.task_pbl_base.lo =
+		iscsi->task_array_info.pgtbl_map & 0xffffffff;
+	ictx->ustorm_st_context.task_pbl_base.hi =
+		(u64) iscsi->task_array_info.pgtbl_map >> 32;
+	ictx->ustorm_st_context.tce_phy_addr.lo =
+		iscsi->task_array_info.pgtbl[0];
+	ictx->ustorm_st_context.tce_phy_addr.hi =
+		iscsi->task_array_info.pgtbl[1];
+	ictx->ustorm_st_context.iscsi_conn_id = req1->iscsi_conn_id;
+	ictx->ustorm_st_context.num_cqs = cp->num_cqs;
+	ictx->ustorm_st_context.negotiated_rx |= ISCSI_DEF_MAX_RECV_SEG_LEN;
+	ictx->ustorm_st_context.negotiated_rx_and_flags |=
+		ISCSI_DEF_MAX_BURST_LEN;
+	ictx->ustorm_st_context.negotiated_rx |=
+		ISCSI_DEFAULT_MAX_OUTSTANDING_R2T <<
+		USTORM_ISCSI_ST_CONTEXT_MAX_OUTSTANDING_R2TS_SHIFT;
+
+	ictx->cstorm_st_context.hq_pbl_base.lo =
+		iscsi->hq_info.pgtbl_map & 0xffffffff;
+	ictx->cstorm_st_context.hq_pbl_base.hi =
+		(u64) iscsi->hq_info.pgtbl_map >> 32;
+	ictx->cstorm_st_context.hq_curr_pbe.lo = iscsi->hq_info.pgtbl[0];
+	ictx->cstorm_st_context.hq_curr_pbe.hi = iscsi->hq_info.pgtbl[1];
+	ictx->cstorm_st_context.task_pbl_base.lo =
+		iscsi->task_array_info.pgtbl_map & 0xffffffff;
+	ictx->cstorm_st_context.task_pbl_base.hi =
+		(u64) iscsi->task_array_info.pgtbl_map >> 32;
+	/* CSTORM and USTORM initialization is different, CSTORM requires
+	 * CQ DB base & not PTE addr */
+	ictx->cstorm_st_context.cq_db_base.lo =
+		req1->cq_page_table_addr_lo & PAGE_MASK;
+	ictx->cstorm_st_context.cq_db_base.hi = req1->cq_page_table_addr_hi;
+	ictx->cstorm_st_context.iscsi_conn_id = req1->iscsi_conn_id;
+	ictx->cstorm_st_context.cq_proc_en_bit_map = (1 << cp->num_cqs) - 1;
+	for (i = 0; i < cp->num_cqs; i++) {
+		ictx->cstorm_st_context.cq_c_prod_sqn_arr.sqn[i] =
+			ISCSI_INITIAL_SN;
+		ictx->cstorm_st_context.cq_c_sqn_2_notify_arr.sqn[i] =
+			ISCSI_INITIAL_SN;
+	}
+
+	ictx->xstorm_ag_context.cdu_reserved =
+		CDU_RSRVD_VALUE_TYPE_A(hw_cid, CDU_REGION_NUMBER_XCM_AG,
+				       ISCSI_CONNECTION_TYPE);
+	ictx->ustorm_ag_context.cdu_usage =
+		CDU_RSRVD_VALUE_TYPE_A(hw_cid, CDU_REGION_NUMBER_UCM_AG,
+				       ISCSI_CONNECTION_TYPE);
+	return 0;
+
+}
+
+static int cnic_bnx2x_iscsi_ofld1(struct cnic_dev *dev, struct kwqe *wqes[],
+				   u32 num, int *work)
+{
+	struct iscsi_kwqe_conn_offload1 *req1;
+	struct iscsi_kwqe_conn_offload2 *req2;
+	struct cnic_local *cp = dev->cnic_priv;
+	struct iscsi_kcqe kcqe;
+	struct kcqe *cqes[1];
+	u32 l5_cid;
+	int ret;
+
+	if (num < 2) {
+		*work = num;
+		return -EINVAL;
+	}
+
+	req1 = (struct iscsi_kwqe_conn_offload1 *) wqes[0];
+	req2 = (struct iscsi_kwqe_conn_offload2 *) wqes[1];
+	if ((num - 2) < req2->num_additional_wqes) {
+		*work = num;
+		return -EINVAL;
+	}
+	*work = 2 + req2->num_additional_wqes;;
+
+	l5_cid = req1->iscsi_conn_id;
+	if (l5_cid >= MAX_ISCSI_TBL_SZ)
+		return -EINVAL;
+
+	memset(&kcqe, 0, sizeof(kcqe));
+	kcqe.op_code = ISCSI_KCQE_OPCODE_OFFLOAD_CONN;
+	kcqe.iscsi_conn_id = l5_cid;
+	kcqe.completion_status = ISCSI_KCQE_COMPLETION_STATUS_CTX_ALLOC_FAILURE;
+
+	if (atomic_inc_return(&cp->iscsi_conn) > dev->max_iscsi_conn) {
+		atomic_dec(&cp->iscsi_conn);
+		ret = 0;
+		goto done;
+	}
+	ret = cnic_alloc_bnx2x_conn_resc(dev, l5_cid);
+	if (ret) {
+		atomic_dec(&cp->iscsi_conn);
+		ret = 0;
+		goto done;
+	}
+	ret = cnic_setup_bnx2x_ctx(dev, wqes, num);
+	if (ret < 0) {
+		cnic_free_bnx2x_conn_resc(dev, l5_cid);
+		atomic_dec(&cp->iscsi_conn);
+		goto done;
+	}
+
+	kcqe.completion_status = ISCSI_KCQE_COMPLETION_STATUS_SUCCESS;
+	kcqe.iscsi_conn_context_id = BNX2X_HW_CID(cp->ctx_tbl[l5_cid].cid,
+						  cp->func);
+
+done:
+	cqes[0] = (struct kcqe *) &kcqe;
+	cnic_reply_bnx2x_kcqes(dev, CNIC_ULP_ISCSI, cqes, 1);
+	return ret;
+}
+
+
+static int cnic_bnx2x_iscsi_update(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct iscsi_kwqe_conn_update *req =
+		(struct iscsi_kwqe_conn_update *) kwqe;
+	void *data;
+	union l5cm_specific_data l5_data;
+	u32 l5_cid, cid = BNX2X_SW_CID(req->context_id);
+	int ret;
+
+	if (cnic_get_l5_cid(cp, cid, &l5_cid) != 0)
+		return -EINVAL;
+
+	data = cnic_get_kwqe_16_data(cp, l5_cid, &l5_data);
+	if (!data)
+		return -ENOMEM;
+
+	memcpy(data, kwqe, sizeof(struct kwqe));
+
+	ret = cnic_submit_kwqe_16(dev, ISCSI_RAMROD_CMD_ID_UPDATE_CONN,
+			req->context_id, ISCSI_CONNECTION_TYPE, &l5_data);
+	return ret;
+}
+
+static int cnic_bnx2x_iscsi_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct iscsi_kwqe_conn_destroy *req =
+		(struct iscsi_kwqe_conn_destroy *) kwqe;
+	union l5cm_specific_data l5_data;
+	u32 l5_cid = req->reserved0;
+	struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
+	int ret = 0;
+	struct iscsi_kcqe kcqe;
+	struct kcqe *cqes[1];
+
+	if (!(ctx->ctx_flags & CTX_FL_OFFLD_START))
+		goto skip_cfc_delete;
+
+	while (!time_after(jiffies, ctx->timestamp + (2 * HZ)))
+		msleep(250);
+
+	init_waitqueue_head(&ctx->waitq);
+	ctx->wait_cond = 0;
+	memset(&l5_data, 0, sizeof(l5_data));
+	ret = cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_CFC_DEL,
+				  req->context_id,
+				  ETH_CONNECTION_TYPE |
+				  (1 << SPE_HDR_COMMON_RAMROD_SHIFT),
+				  &l5_data);
+	if (ret == 0)
+		wait_event(ctx->waitq, ctx->wait_cond);
+
+skip_cfc_delete:
+	cnic_free_bnx2x_conn_resc(dev, l5_cid);
+
+	atomic_dec(&cp->iscsi_conn);
+
+	memset(&kcqe, 0, sizeof(kcqe));
+	kcqe.op_code = ISCSI_KCQE_OPCODE_DESTROY_CONN;
+	kcqe.iscsi_conn_id = l5_cid;
+	kcqe.completion_status = ISCSI_KCQE_COMPLETION_STATUS_SUCCESS;
+	kcqe.iscsi_conn_context_id = req->context_id;
+
+	cqes[0] = (struct kcqe *) &kcqe;
+	cnic_reply_bnx2x_kcqes(dev, CNIC_ULP_ISCSI, cqes, 1);
+
+	return ret;
+}
+
+static void cnic_init_storm_conn_bufs(struct cnic_dev *dev,
+				      struct l4_kwq_connect_req1 *kwqe1,
+				      struct l4_kwq_connect_req3 *kwqe3,
+				      struct l5cm_active_conn_buffer *conn_buf)
+{
+	struct l5cm_conn_addr_params *conn_addr = &conn_buf->conn_addr_buf;
+	struct l5cm_xstorm_conn_buffer *xstorm_buf =
+		&conn_buf->xstorm_conn_buffer;
+	struct l5cm_tstorm_conn_buffer *tstorm_buf =
+		&conn_buf->tstorm_conn_buffer;
+	struct regpair context_addr;
+	u32 cid = BNX2X_SW_CID(kwqe1->cid);
+	struct in6_addr src_ip, dst_ip;
+	int i;
+	u32 *addrp;
+
+	addrp = (u32 *) &conn_addr->local_ip_addr;
+	for (i = 0; i < 4; i++, addrp++)
+		src_ip.in6_u.u6_addr32[i] = cpu_to_be32(*addrp);
+
+	addrp = (u32 *) &conn_addr->remote_ip_addr;
+	for (i = 0; i < 4; i++, addrp++)
+		dst_ip.in6_u.u6_addr32[i] = cpu_to_be32(*addrp);
+
+	cnic_get_bnx2x_ctx(dev, cid, 0, &context_addr);
+
+	xstorm_buf->context_addr.hi = context_addr.hi;
+	xstorm_buf->context_addr.lo = context_addr.lo;
+	xstorm_buf->mss = 0xffff;
+	xstorm_buf->rcv_buf = kwqe3->rcv_buf;
+	if (kwqe1->tcp_flags & L4_KWQ_CONNECT_REQ1_NAGLE_ENABLE)
+		xstorm_buf->params |= L5CM_XSTORM_CONN_BUFFER_NAGLE_ENABLE;
+	xstorm_buf->pseudo_header_checksum =
+		swab16(~csum_ipv6_magic(&src_ip, &dst_ip, 0, IPPROTO_TCP, 0));
+
+	if (!(kwqe1->tcp_flags & L4_KWQ_CONNECT_REQ1_NO_DELAY_ACK))
+		tstorm_buf->params |=
+			L5CM_TSTORM_CONN_BUFFER_DELAYED_ACK_ENABLE;
+	if (kwqe3->ka_timeout) {
+		tstorm_buf->ka_enable = 1;
+		tstorm_buf->ka_timeout = kwqe3->ka_timeout;
+		tstorm_buf->ka_interval = kwqe3->ka_interval;
+		tstorm_buf->ka_max_probe_count = kwqe3->ka_max_probe_count;
+	}
+	tstorm_buf->rcv_buf = kwqe3->rcv_buf;
+	tstorm_buf->snd_buf = kwqe3->snd_buf;
+	tstorm_buf->max_rt_time = 0xffffffff;
+}
+
+static void cnic_init_bnx2x_mac(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int func = CNIC_FUNC(cp);
+	u8 *mac = dev->mac_addr;
+
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR0_OFFSET(func), mac[0]);
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR1_OFFSET(func), mac[1]);
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR2_OFFSET(func), mac[2]);
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR3_OFFSET(func), mac[3]);
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR4_OFFSET(func), mac[4]);
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_LOCAL_MAC_ADDR5_OFFSET(func), mac[5]);
+
+	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
+		 TSTORM_ISCSI_TCP_VARS_LSB_LOCAL_MAC_ADDR_OFFSET(func), mac[5]);
+	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
+		 TSTORM_ISCSI_TCP_VARS_LSB_LOCAL_MAC_ADDR_OFFSET(func) + 1,
+		 mac[4]);
+	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
+		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(func), mac[3]);
+	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
+		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(func) + 1,
+		 mac[2]);
+	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
+		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(func) + 2,
+		 mac[1]);
+	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
+		 TSTORM_ISCSI_TCP_VARS_MSB_LOCAL_MAC_ADDR_OFFSET(func) + 3,
+		 mac[0]);
+}
+
+static void cnic_bnx2x_set_tcp_timestamp(struct cnic_dev *dev, int tcp_ts)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	u8 xstorm_flags = XSTORM_L5CM_TCP_FLAGS_WND_SCL_EN;
+	u16 tstorm_flags = 0;
+
+	if (tcp_ts) {
+		xstorm_flags |= XSTORM_L5CM_TCP_FLAGS_TS_ENABLED;
+		tstorm_flags |= TSTORM_L5CM_TCP_FLAGS_TS_ENABLED;
+	}
+
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->func), xstorm_flags);
+
+	CNIC_WR16(dev, BAR_TSTRORM_INTMEM +
+		  TSTORM_ISCSI_TCP_VARS_FLAGS_OFFSET(cp->func), tstorm_flags);
+}
+
+static int cnic_bnx2x_connect(struct cnic_dev *dev, struct kwqe *wqes[],
+			      u32 num, int *work)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct l4_kwq_connect_req1 *kwqe1 =
+		(struct l4_kwq_connect_req1 *) wqes[0];
+	struct l4_kwq_connect_req3 *kwqe3;
+	struct l5cm_active_conn_buffer *conn_buf;
+	struct l5cm_conn_addr_params *conn_addr;
+	union l5cm_specific_data l5_data;
+	u32 l5_cid = kwqe1->pg_cid;
+	struct cnic_sock *csk = &cp->csk_tbl[l5_cid];
+	struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
+	int ret;
+
+	if (num < 2) {
+		*work = num;
+		return -EINVAL;
+	}
+
+	if (kwqe1->conn_flags & L4_KWQ_CONNECT_REQ1_IP_V6)
+		*work = 3;
+	else
+		*work = 2;
+
+	if (num < *work) {
+		*work = num;
+		return -EINVAL;
+	}
+
+	if (sizeof(*conn_buf) > CNIC_KWQ16_DATA_SIZE) {
+		printk(KERN_ERR PFX "%s: conn_buf size too big\n",
+			       dev->netdev->name);
+		return -ENOMEM;
+	}
+	conn_buf = cnic_get_kwqe_16_data(cp, l5_cid, &l5_data);
+	if (!conn_buf)
+		return -ENOMEM;
+
+	memset(conn_buf, 0, sizeof(*conn_buf));
+
+	conn_addr = &conn_buf->conn_addr_buf;
+	conn_addr->remote_addr_0 = csk->ha[0];
+	conn_addr->remote_addr_1 = csk->ha[1];
+	conn_addr->remote_addr_2 = csk->ha[2];
+	conn_addr->remote_addr_3 = csk->ha[3];
+	conn_addr->remote_addr_4 = csk->ha[4];
+	conn_addr->remote_addr_5 = csk->ha[5];
+
+	if (kwqe1->conn_flags & L4_KWQ_CONNECT_REQ1_IP_V6) {
+		struct l4_kwq_connect_req2 *kwqe2 =
+			(struct l4_kwq_connect_req2 *) wqes[1];
+
+		conn_addr->local_ip_addr.ip_addr_hi_hi = kwqe2->src_ip_v6_4;
+		conn_addr->local_ip_addr.ip_addr_hi_lo = kwqe2->src_ip_v6_3;
+		conn_addr->local_ip_addr.ip_addr_lo_hi = kwqe2->src_ip_v6_2;
+
+		conn_addr->remote_ip_addr.ip_addr_hi_hi = kwqe2->dst_ip_v6_4;
+		conn_addr->remote_ip_addr.ip_addr_hi_lo = kwqe2->dst_ip_v6_3;
+		conn_addr->remote_ip_addr.ip_addr_lo_hi = kwqe2->dst_ip_v6_2;
+		conn_addr->params |= L5CM_CONN_ADDR_PARAMS_IP_VERSION;
+	}
+	kwqe3 = (struct l4_kwq_connect_req3 *) wqes[*work - 1];
+
+	conn_addr->local_ip_addr.ip_addr_lo_lo = kwqe1->src_ip;
+	conn_addr->remote_ip_addr.ip_addr_lo_lo = kwqe1->dst_ip;
+	conn_addr->local_tcp_port = kwqe1->src_port;
+	conn_addr->remote_tcp_port = kwqe1->dst_port;
+
+	conn_addr->pmtu = kwqe3->pmtu;
+	cnic_init_storm_conn_bufs(dev, kwqe1, kwqe3, conn_buf);
+
+	CNIC_WR16(dev, BAR_XSTRORM_INTMEM +
+		  XSTORM_ISCSI_LOCAL_VLAN_OFFSET(cp->func), csk->vlan_id);
+
+	cnic_bnx2x_set_tcp_timestamp(dev,
+		kwqe1->tcp_flags & L4_KWQ_CONNECT_REQ1_TIME_STAMP);
+
+	ret = cnic_submit_kwqe_16(dev, L5CM_RAMROD_CMD_ID_TCP_CONNECT,
+			kwqe1->cid, ISCSI_CONNECTION_TYPE, &l5_data);
+	if (!ret)
+		ctx->ctx_flags |= CTX_FL_OFFLD_START;
+
+	return ret;
+}
+
+static int cnic_bnx2x_close(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct l4_kwq_close_req *req = (struct l4_kwq_close_req *) kwqe;
+	union l5cm_specific_data l5_data;
+	int ret;
+
+	memset(&l5_data, 0, sizeof(l5_data));
+	ret = cnic_submit_kwqe_16(dev, L5CM_RAMROD_CMD_ID_CLOSE,
+			req->cid, ISCSI_CONNECTION_TYPE, &l5_data);
+	return ret;
+}
+
+static int cnic_bnx2x_reset(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct l4_kwq_reset_req *req = (struct l4_kwq_reset_req *) kwqe;
+	union l5cm_specific_data l5_data;
+	int ret;
+
+	memset(&l5_data, 0, sizeof(l5_data));
+	ret = cnic_submit_kwqe_16(dev, L5CM_RAMROD_CMD_ID_ABORT,
+			req->cid, ISCSI_CONNECTION_TYPE, &l5_data);
+	return ret;
+}
+static int cnic_bnx2x_offload_pg(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct l4_kwq_offload_pg *req = (struct l4_kwq_offload_pg *) kwqe;
+	struct l4_kcq kcqe;
+	struct kcqe *cqes[1];
+
+	memset(&kcqe, 0, sizeof(kcqe));
+	kcqe.pg_host_opaque = req->host_opaque;
+	kcqe.pg_cid = req->host_opaque;
+	kcqe.op_code = L4_KCQE_OPCODE_VALUE_OFFLOAD_PG;
+	cqes[0] = (struct kcqe *) &kcqe;
+	cnic_reply_bnx2x_kcqes(dev, CNIC_ULP_L4, cqes, 1);
+	return 0;
+}
+
+static int cnic_bnx2x_update_pg(struct cnic_dev *dev, struct kwqe *kwqe)
+{
+	struct l4_kwq_update_pg *req = (struct l4_kwq_update_pg *) kwqe;
+	struct l4_kcq kcqe;
+	struct kcqe *cqes[1];
+
+	memset(&kcqe, 0, sizeof(kcqe));
+	kcqe.pg_host_opaque = req->pg_host_opaque;
+	kcqe.pg_cid = req->pg_cid;
+	kcqe.op_code = L4_KCQE_OPCODE_VALUE_UPDATE_PG;
+	cqes[0] = (struct kcqe *) &kcqe;
+	cnic_reply_bnx2x_kcqes(dev, CNIC_ULP_L4, cqes, 1);
+	return 0;
+}
+
+static int cnic_submit_bnx2x_kwqes(struct cnic_dev *dev, struct kwqe *wqes[],
+				   u32 num_wqes)
+{
+	int i, work, ret;
+	u32 opcode;
+	struct kwqe *kwqe;
+
+	if (!test_bit(CNIC_F_CNIC_UP, &dev->flags))
+		return -EAGAIN;		/* bnx2 is down */
+
+	for (i = 0; i < num_wqes; ) {
+		kwqe = wqes[i];
+		opcode = KWQE_OPCODE(kwqe->kwqe_op_flag);
+		work = 1;
+
+		switch (opcode) {
+		case ISCSI_KWQE_OPCODE_INIT1:
+			ret = cnic_bnx2x_iscsi_init1(dev, kwqe);
+			break;
+		case ISCSI_KWQE_OPCODE_INIT2:
+			ret = cnic_bnx2x_iscsi_init2(dev, kwqe);
+			break;
+		case ISCSI_KWQE_OPCODE_OFFLOAD_CONN1:
+			ret = cnic_bnx2x_iscsi_ofld1(dev, &wqes[i],
+						     num_wqes - i, &work);
+			break;
+		case ISCSI_KWQE_OPCODE_UPDATE_CONN:
+			ret = cnic_bnx2x_iscsi_update(dev, kwqe);
+			break;
+		case ISCSI_KWQE_OPCODE_DESTROY_CONN:
+			ret = cnic_bnx2x_iscsi_destroy(dev, kwqe);
+			break;
+		case L4_KWQE_OPCODE_VALUE_CONNECT1:
+			ret = cnic_bnx2x_connect(dev, &wqes[i], num_wqes - i,
+						 &work);
+			break;
+		case L4_KWQE_OPCODE_VALUE_CLOSE:
+			ret = cnic_bnx2x_close(dev, kwqe);
+			break;
+		case L4_KWQE_OPCODE_VALUE_RESET:
+			ret = cnic_bnx2x_reset(dev, kwqe);
+			break;
+		case L4_KWQE_OPCODE_VALUE_OFFLOAD_PG:
+			ret = cnic_bnx2x_offload_pg(dev, kwqe);
+			break;
+		case L4_KWQE_OPCODE_VALUE_UPDATE_PG:
+			ret = cnic_bnx2x_update_pg(dev, kwqe);
+			break;
+		case L4_KWQE_OPCODE_VALUE_UPLOAD_PG:
+			ret = 0;
+			break;
+		default:
+			ret = 0;
+			printk(KERN_ERR PFX "%s: Unknown type of KWQE(0x%x)\n",
+			       dev->netdev->name, opcode);
+			break;
+		}
+		if (ret < 0)
+			printk(KERN_ERR PFX "%s: KWQE(0x%x) failed\n",
+			       dev->netdev->name, opcode);
+		i += work;
+	}
+	return 0;
+}
+
 static void service_kcqes(struct cnic_dev *dev, int num_cqes)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -1005,6 +2095,22 @@ static u16 cnic_bnx2_hw_idx(u16 idx)
 	return idx;
 }
 
+static u16 cnic_bnx2x_next_idx(u16 idx)
+{
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
 static int cnic_get_kcqes(struct cnic_dev *dev, u16 hw_prod, u16 *sw_prod)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -1038,6 +2144,7 @@ static void cnic_chk_pkt_rings(struct cnic_local *cp)
 	if (cp->tx_cons != tx_cons || cp->rx_cons != rx_cons) {
 		cp->tx_cons = tx_cons;
 		cp->rx_cons = rx_cons;
+
 		uio_event_notify(cp->cnic_uinfo);
 	}
 }
@@ -1143,6 +2250,91 @@ static irqreturn_t cnic_irq(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
+static inline void cnic_ack_bnx2x_int(struct cnic_dev *dev, u8 id, u8 storm,
+				      u16 index, u8 op, u8 update)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	u32 hc_addr = (HC_REG_COMMAND_REG + CNIC_PORT(cp) * 32 +
+		       COMMAND_REG_INT_ACK);
+	struct igu_ack_register igu_ack;
+
+	igu_ack.status_block_index = index;
+	igu_ack.sb_id_and_flags =
+			((id << IGU_ACK_REGISTER_STATUS_BLOCK_ID_SHIFT) |
+			 (storm << IGU_ACK_REGISTER_STORM_ID_SHIFT) |
+			 (update << IGU_ACK_REGISTER_UPDATE_INDEX_SHIFT) |
+			 (op << IGU_ACK_REGISTER_INTERRUPT_MODE_SHIFT));
+
+	CNIC_WR(dev, hc_addr, (*(u32 *)&igu_ack));
+}
+
+static void cnic_ack_bnx2x_msix(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+
+	cnic_ack_bnx2x_int(dev, cp->status_blk_num, CSTORM_ID, 0,
+			   IGU_INT_DISABLE, 0);
+}
+
+static void cnic_service_bnx2x_bh(unsigned long data)
+{
+	struct cnic_dev *dev = (struct cnic_dev *) data;
+	struct cnic_local *cp = dev->cnic_priv;
+	u16 hw_prod, sw_prod;
+	struct cstorm_status_block_c *sblk =
+		&cp->bnx2x_status_blk->c_status_block;
+	u32 status_idx = sblk->status_block_index;
+	int kcqe_cnt;
+
+	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags)))
+		return;
+
+	hw_prod = sblk->index_values[HC_INDEX_C_ISCSI_EQ_CONS];
+	hw_prod = cp->hw_idx(hw_prod);
+	sw_prod = cp->kcq_prod_idx;
+	while (sw_prod != hw_prod) {
+		kcqe_cnt = cnic_get_kcqes(dev, hw_prod, &sw_prod);
+		if (kcqe_cnt == 0)
+			goto done;
+
+		service_kcqes(dev, kcqe_cnt);
+
+		/* Tell compiler that sblk fields can change. */
+		barrier();
+		if (status_idx == sblk->status_block_index)
+			break;
+
+		status_idx = sblk->status_block_index;
+		hw_prod = sblk->index_values[HC_INDEX_C_ISCSI_EQ_CONS];
+		hw_prod = cp->hw_idx(hw_prod);
+	}
+
+done:
+	CNIC_WR16(dev, cp->kcq_io_addr, sw_prod + MAX_KCQ_IDX);
+	cnic_ack_bnx2x_int(dev, cp->status_blk_num, CSTORM_ID,
+			   status_idx, IGU_INT_ENABLE, 1);
+
+	cp->kcq_prod_idx = sw_prod;
+	return;
+}
+
+static int cnic_service_bnx2x(void *data, void *status_blk)
+{
+	struct cnic_dev *dev = data;
+	struct cnic_local *cp = dev->cnic_priv;
+	u16 prod = cp->kcq_prod_idx & MAX_KCQ_IDX;
+
+	prefetch(cp->status_blk);
+	prefetch(&cp->kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
+
+	if (likely(test_bit(CNIC_F_CNIC_UP, &dev->flags)))
+		tasklet_schedule(&cp->cnic_irq_task);
+
+	cnic_chk_pkt_rings(cp);
+
+	return 0;
+}
+
 static void cnic_ulp_stop(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -1215,6 +2407,19 @@ static int cnic_ctl(void *data, struct cnic_ctl_info *info)
 
 		cnic_put(dev);
 		break;
+	case CNIC_CTL_COMPLETION_CMD: {
+		u32 cid = BNX2X_SW_CID(info->data.comp.cid);
+		u32 l5_cid;
+		struct cnic_local *cp = dev->cnic_priv;
+
+		if (cnic_get_l5_cid(cp, cid, &l5_cid) == 0) {
+			struct cnic_context *ctx = &cp->ctx_tbl[l5_cid];
+
+			ctx->wait_cond = 1;
+			wake_up(&ctx->waitq);
+		}
+		break;
+	}
 	default:
 		return -EINVAL;
 	}
@@ -1890,6 +3095,8 @@ static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
 		/* fall through */
 	case L4_KCQE_OPCODE_VALUE_CLOSE_COMP:
 	case L4_KCQE_OPCODE_VALUE_RESET_COMP:
+	case L5CM_RAMROD_CMD_ID_SEARCHER_DELETE:
+	case L5CM_RAMROD_CMD_ID_TERMINATE_OFFLOAD:
 		cp->close_conn(csk, opcode);
 		break;
 
@@ -1975,6 +3182,76 @@ static int cnic_cm_init_bnx2_hw(struct cnic_dev *dev)
 	return 0;
 }
 
+static void cnic_close_bnx2x_conn(struct cnic_sock *csk, u32 opcode)
+{
+	struct cnic_dev *dev = csk->dev;
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_context *ctx = &cp->ctx_tbl[csk->l5_cid];
+	union l5cm_specific_data l5_data;
+	u32 cmd = 0;
+	int close_complete = 0;
+
+	switch (opcode) {
+	case L4_KCQE_OPCODE_VALUE_RESET_RECEIVED:
+	case L4_KCQE_OPCODE_VALUE_CLOSE_COMP:
+	case L4_KCQE_OPCODE_VALUE_RESET_COMP:
+		if (cnic_ready_to_close(csk, opcode))
+			cmd = L5CM_RAMROD_CMD_ID_SEARCHER_DELETE;
+		break;
+	case L5CM_RAMROD_CMD_ID_SEARCHER_DELETE:
+		cmd = L5CM_RAMROD_CMD_ID_TERMINATE_OFFLOAD;
+		break;
+	case L5CM_RAMROD_CMD_ID_TERMINATE_OFFLOAD:
+		close_complete = 1;
+		break;
+	}
+	if (cmd) {
+		memset(&l5_data, 0, sizeof(l5_data));
+
+		cnic_submit_kwqe_16(dev, cmd, csk->cid, ISCSI_CONNECTION_TYPE,
+				    &l5_data);
+	} else if (close_complete) {
+		ctx->timestamp = jiffies;
+		cnic_close_conn(csk);
+		cnic_cm_upcall(cp, csk, csk->state);
+	}
+}
+
+static void cnic_cm_stop_bnx2x_hw(struct cnic_dev *dev)
+{
+}
+
+static int cnic_cm_init_bnx2x_hw(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int func = CNIC_FUNC(cp);
+
+	cnic_init_bnx2x_mac(dev);
+	cnic_bnx2x_set_tcp_timestamp(dev, 1);
+
+	CNIC_WR16(dev, BAR_XSTRORM_INTMEM +
+		  XSTORM_ISCSI_LOCAL_VLAN_OFFSET(func), 0);
+
+	CNIC_WR(dev, BAR_XSTRORM_INTMEM +
+		XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_ENABLED_OFFSET(func), 1);
+	CNIC_WR(dev, BAR_XSTRORM_INTMEM +
+		XSTORM_TCP_GLOBAL_DEL_ACK_COUNTER_MAX_COUNT_OFFSET(func),
+		DEF_MAX_DA_COUNT);
+
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_TCP_VARS_TTL_OFFSET(func), DEF_TTL);
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_TCP_VARS_TOS_OFFSET(func), DEF_TOS);
+	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
+		 XSTORM_ISCSI_TCP_VARS_ADV_WND_SCL_OFFSET(func), 2);
+	CNIC_WR(dev, BAR_XSTRORM_INTMEM +
+		XSTORM_TCP_TX_SWS_TIMER_VAL_OFFSET(func), DEF_SWS_TIMER);
+
+	CNIC_WR(dev, BAR_TSTRORM_INTMEM + TSTORM_TCP_MAX_CWND_OFFSET(func),
+		DEF_MAX_CWND);
+	return 0;
+}
+
 static int cnic_cm_open(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -2482,11 +3759,402 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 	return 0;
 }
 
+static void cnic_setup_bnx2x_context(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_eth_dev *ethdev = cp->ethdev;
+	u32 start_offset = ethdev->ctx_tbl_offset;
+	int i;
+
+	for (i = 0; i < cp->ctx_blks; i++) {
+		struct cnic_ctx *ctx = &cp->ctx_arr[i];
+		dma_addr_t map = ctx->mapping;
+
+		if (cp->ctx_align) {
+			unsigned long mask = cp->ctx_align - 1;
+
+			map = (map + mask) & ~mask;
+		}
+
+		cnic_ctx_tbl_wr(dev, start_offset + i, map);
+	}
+}
+
+static int cnic_init_bnx2x_irq(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_eth_dev *ethdev = cp->ethdev;
+	int err = 0;
+
+	tasklet_init(&cp->cnic_irq_task, &cnic_service_bnx2x_bh,
+		     (unsigned long) dev);
+	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
+		err = request_irq(ethdev->irq_arr[0].vector, cnic_irq, 0,
+				  "cnic", dev);
+		if (err)
+			tasklet_disable(&cp->cnic_irq_task);
+	}
+	return err;
+}
+
+static void cnic_enable_bnx2x_int(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	u8 sb_id = cp->status_blk_num;
+	int port = CNIC_PORT(cp);
+
+	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
+		 CSTORM_SB_HC_TIMEOUT_C_OFFSET(port, sb_id,
+					       HC_INDEX_C_ISCSI_EQ_CONS),
+		 64 / 12);
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
+		  CSTORM_SB_HC_DISABLE_C_OFFSET(port, sb_id,
+						HC_INDEX_C_ISCSI_EQ_CONS), 0);
+}
+
+static void cnic_disable_bnx2x_int_sync(struct cnic_dev *dev)
+{
+}
+
+static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	union eth_tx_bd_types *txbd = (union eth_tx_bd_types *) cp->l2_ring;
+	struct eth_context *context;
+	struct regpair context_addr;
+	dma_addr_t buf_map;
+	int func = CNIC_FUNC(cp);
+	int port = CNIC_PORT(cp);
+	int i;
+	int cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
+	u32 val;
+
+	memset(txbd, 0, BCM_PAGE_SIZE);
+
+	buf_map = cp->l2_buf_map;
+	for (i = 0; i < MAX_TX_DESC_CNT; i += 3, txbd += 3) {
+		struct eth_tx_start_bd *start_bd = &txbd->start_bd;
+		struct eth_tx_bd *reg_bd = &((txbd + 2)->reg_bd);
+
+		start_bd->addr_hi = cpu_to_le32((u64) buf_map >> 32);
+		start_bd->addr_lo = cpu_to_le32(buf_map & 0xffffffff);
+		reg_bd->addr_hi = start_bd->addr_hi;
+		reg_bd->addr_lo = start_bd->addr_lo + 0x10;
+		start_bd->nbytes = cpu_to_le16(0x10);
+		start_bd->nbd = cpu_to_le16(3);
+		start_bd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
+		start_bd->general_data = (UNICAST_ADDRESS <<
+			ETH_TX_START_BD_ETH_ADDR_TYPE_SHIFT);
+		start_bd->general_data |= (1 << ETH_TX_START_BD_HDR_NBDS_SHIFT);
+
+	}
+	context = cnic_get_bnx2x_ctx(dev, BNX2X_ISCSI_L2_CID, 1, &context_addr);
+
+	val = (u64) cp->l2_ring_map >> 32;
+	txbd->next_bd.addr_hi = cpu_to_le32(val);
+
+	context->xstorm_st_context.tx_bd_page_base_hi = val;
+
+	val = (u64) cp->l2_ring_map & 0xffffffff;
+	txbd->next_bd.addr_lo = cpu_to_le32(val);
+
+	context->xstorm_st_context.tx_bd_page_base_lo = val;
+
+	context->cstorm_st_context.sb_index_number =
+		HC_INDEX_DEF_C_ETH_ISCSI_CQ_CONS;
+	context->cstorm_st_context.status_block_id = BNX2X_DEF_SB_ID;
+
+	context->xstorm_st_context.statistics_data = (cli |
+				XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE);
+
+	context->xstorm_ag_context.cdu_reserved =
+		CDU_RSRVD_VALUE_TYPE_A(BNX2X_HW_CID(BNX2X_ISCSI_L2_CID, func),
+					CDU_REGION_NUMBER_XCM_AG,
+					ETH_CONNECTION_TYPE);
+
+	/* reset xstorm per client statistics */
+	val = BAR_XSTRORM_INTMEM +
+	      XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
+	for (i = 0; i < sizeof(struct xstorm_per_client_stats) / 4; i++)
+		CNIC_WR(dev, val + i * 4, 0);
+
+	cp->tx_cons_ptr =
+		&cp->bnx2x_def_status_blk->c_def_status_block.index_values[
+			HC_INDEX_DEF_C_ETH_ISCSI_CQ_CONS];
+}
+
+static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct eth_rx_bd *rxbd = (struct eth_rx_bd *) (cp->l2_ring +
+				BCM_PAGE_SIZE);
+	struct eth_rx_cqe_next_page *rxcqe = (struct eth_rx_cqe_next_page *)
+				(cp->l2_ring + (2 * BCM_PAGE_SIZE));
+	struct eth_context *context;
+	struct regpair context_addr;
+	int i;
+	int port = CNIC_PORT(cp);
+	int func = CNIC_FUNC(cp);
+	int cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
+	u32 val;
+	struct tstorm_eth_client_config tstorm_client = {0};
+
+	for (i = 0; i < BNX2X_MAX_RX_DESC_CNT; i++, rxbd++) {
+		dma_addr_t buf_map;
+		int n = (i % cp->l2_rx_ring_size) + 1;
+
+		buf_map = cp->l2_buf_map + (n * cp->l2_single_buf_size);
+		rxbd->addr_hi = cpu_to_le32((u64) buf_map >> 32);
+		rxbd->addr_lo = cpu_to_le32(buf_map & 0xffffffff);
+	}
+	context = cnic_get_bnx2x_ctx(dev, BNX2X_ISCSI_L2_CID, 0, &context_addr);
+
+	val = (u64) (cp->l2_ring_map + BCM_PAGE_SIZE) >> 32;
+	rxbd->addr_hi = cpu_to_le32(val);
+
+	context->ustorm_st_context.common.bd_page_base_hi = val;
+
+	val = (u64) (cp->l2_ring_map + BCM_PAGE_SIZE) & 0xffffffff;
+	rxbd->addr_lo = cpu_to_le32(val);
+
+	context->ustorm_st_context.common.bd_page_base_lo = val;
+
+	context->ustorm_st_context.common.sb_index_numbers =
+						BNX2X_ISCSI_RX_SB_INDEX_NUM;
+	context->ustorm_st_context.common.clientId = cli;
+	context->ustorm_st_context.common.status_block_id = BNX2X_DEF_SB_ID;
+	context->ustorm_st_context.common.flags =
+		USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_STATISTICS;
+	context->ustorm_st_context.common.statistics_counter_id = cli;
+	context->ustorm_st_context.common.mc_alignment_log_size = 0;
+	context->ustorm_st_context.common.bd_buff_size =
+						cp->l2_single_buf_size;
+
+	context->ustorm_ag_context.cdu_usage =
+		CDU_RSRVD_VALUE_TYPE_A(BNX2X_HW_CID(BNX2X_ISCSI_L2_CID, func),
+					CDU_REGION_NUMBER_UCM_AG,
+					ETH_CONNECTION_TYPE);
+
+	rxcqe += BNX2X_MAX_RCQ_DESC_CNT;
+	val = (u64) (cp->l2_ring_map + (2 * BCM_PAGE_SIZE)) >> 32;
+	rxcqe->addr_hi = cpu_to_le32(val);
+
+	CNIC_WR(dev, BAR_USTRORM_INTMEM +
+		USTORM_CQE_PAGE_BASE_OFFSET(port, cli) + 4, val);
+
+	CNIC_WR(dev, BAR_USTRORM_INTMEM +
+		USTORM_CQE_PAGE_NEXT_OFFSET(port, cli) + 4, val);
+
+	val = (u64) (cp->l2_ring_map + (2 * BCM_PAGE_SIZE)) & 0xffffffff;
+	rxcqe->addr_lo = cpu_to_le32(val);
+
+	CNIC_WR(dev, BAR_USTRORM_INTMEM +
+		USTORM_CQE_PAGE_BASE_OFFSET(port, cli), val);
+
+	CNIC_WR(dev, BAR_USTRORM_INTMEM +
+		USTORM_CQE_PAGE_NEXT_OFFSET(port, cli), val);
+
+	/* client tstorm info */
+	tstorm_client.mtu = cp->l2_single_buf_size - 14;
+	tstorm_client.config_flags =
+			(TSTORM_ETH_CLIENT_CONFIG_E1HOV_REM_ENABLE |
+			TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE);
+	tstorm_client.statistics_counter_id = cli;
+
+	CNIC_WR(dev, BAR_TSTRORM_INTMEM +
+		   TSTORM_CLIENT_CONFIG_OFFSET(port, cli),
+		   ((u32 *)&tstorm_client)[0]);
+	CNIC_WR(dev, BAR_TSTRORM_INTMEM +
+		   TSTORM_CLIENT_CONFIG_OFFSET(port, cli) + 4,
+		   ((u32 *)&tstorm_client)[1]);
+
+	/* reset tstorm per client statistics */
+	val = BAR_TSTRORM_INTMEM +
+	      TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
+	for (i = 0; i < sizeof(struct tstorm_per_client_stats) / 4; i++)
+		CNIC_WR(dev, val + i * 4, 0);
+
+	/* reset ustorm per client statistics */
+	val = BAR_USTRORM_INTMEM +
+	      USTORM_PER_COUNTER_ID_STATS_OFFSET(port, cli);
+	for (i = 0; i < sizeof(struct ustorm_per_client_stats) / 4; i++)
+		CNIC_WR(dev, val + i * 4, 0);
+
+	cp->rx_cons_ptr =
+		&cp->bnx2x_def_status_blk->u_def_status_block.index_values[
+			HC_INDEX_DEF_U_ETH_ISCSI_RX_CQ_CONS];
+}
+
+static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	u32 base, addr, val;
+	int port = CNIC_PORT(cp);
+
+	dev->max_iscsi_conn = 0;
+	base = CNIC_RD(dev, MISC_REG_SHARED_MEM_ADDR);
+	if (base < 0xa0000 || base >= 0xc0000)
+		return;
+
+	val = BNX2X_SHMEM_ADDR(base,
+		dev_info.port_hw_config[port].iscsi_mac_upper);
+
+	dev->mac_addr[0] = (u8) (val >> 8);
+	dev->mac_addr[1] = (u8) val;
+
+	val = BNX2X_SHMEM_ADDR(base,
+		dev_info.port_hw_config[port].iscsi_mac_lower);
+
+	dev->mac_addr[2] = (u8) (val >> 24);
+	dev->mac_addr[3] = (u8) (val >> 16);
+	dev->mac_addr[4] = (u8) (val >> 8);
+	dev->mac_addr[5] = (u8) val;
+
+	addr = BNX2X_SHMEM_ADDR(base, validity_map[port]);
+	val = CNIC_RD(dev, addr);
+
+	if (!(val & SHR_MEM_VALIDITY_LIC_NO_KEY_IN_EFFECT)) {
+		u16 val16;
+
+		addr = BNX2X_SHMEM_ADDR(base,
+				drv_lic_key[port].max_iscsi_init_conn);
+		val16 = CNIC_RD16(dev, addr);
+
+		if (val16)
+			val16 ^= 0x1e1e;
+		dev->max_iscsi_conn = val16;
+	}
+	if (BNX2X_CHIP_IS_E1H(cp->chip_id)) {
+		int func = CNIC_FUNC(cp);
+
+		addr = BNX2X_SHMEM_ADDR(base,
+				mf_cfg.func_mf_config[func].e1hov_tag);
+		val = CNIC_RD(dev, addr);
+		val &= FUNC_MF_CFG_E1HOV_TAG_MASK;
+		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
+			addr = BNX2X_SHMEM_ADDR(base,
+				mf_cfg.func_mf_config[func].config);
+			val = CNIC_RD(dev, addr);
+			val &= FUNC_MF_CFG_PROTOCOL_MASK;
+			if (val != FUNC_MF_CFG_PROTOCOL_ISCSI)
+				dev->max_iscsi_conn = 0;
+		}
+	}
+}
+
+static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int func = CNIC_FUNC(cp), ret, i;
+	int port = CNIC_PORT(cp);
+	u16 eq_idx;
+	u8 sb_id = cp->status_blk_num;
+
+	ret = cnic_init_id_tbl(&cp->cid_tbl, MAX_ISCSI_TBL_SZ,
+			       BNX2X_ISCSI_START_CID);
+
+	if (ret)
+		return -ENOMEM;
+
+	cp->kcq_io_addr = BAR_CSTRORM_INTMEM +
+			  CSTORM_ISCSI_EQ_PROD_OFFSET(func, 0);
+	cp->kcq_prod_idx = 0;
+
+	cnic_get_bnx2x_iscsi_info(dev);
+
+	/* Only 1 EQ */
+	CNIC_WR16(dev, cp->kcq_io_addr, MAX_KCQ_IDX);
+	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
+		CSTORM_ISCSI_EQ_CONS_OFFSET(func, 0), 0);
+	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
+		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_OFFSET(func, 0),
+		cp->kcq_info.pg_map_arr[1] & 0xffffffff);
+	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
+		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_OFFSET(func, 0) + 4,
+		(u64) cp->kcq_info.pg_map_arr[1] >> 32);
+	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
+		CSTORM_ISCSI_EQ_NEXT_EQE_ADDR_OFFSET(func, 0),
+		cp->kcq_info.pg_map_arr[0] & 0xffffffff);
+	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
+		CSTORM_ISCSI_EQ_NEXT_EQE_ADDR_OFFSET(func, 0) + 4,
+		(u64) cp->kcq_info.pg_map_arr[0] >> 32);
+	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
+		CSTORM_ISCSI_EQ_NEXT_PAGE_ADDR_VALID_OFFSET(func, 0), 1);
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
+		CSTORM_ISCSI_EQ_SB_NUM_OFFSET(func, 0), cp->status_blk_num);
+	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
+		CSTORM_ISCSI_EQ_SB_INDEX_OFFSET(func, 0),
+		HC_INDEX_C_ISCSI_EQ_CONS);
+
+	for (i = 0; i < cp->conn_buf_info.num_pages; i++) {
+		CNIC_WR(dev, BAR_TSTRORM_INTMEM +
+			TSTORM_ISCSI_CONN_BUF_PBL_OFFSET(func, i),
+			cp->conn_buf_info.pgtbl[2 * i]);
+		CNIC_WR(dev, BAR_TSTRORM_INTMEM +
+			TSTORM_ISCSI_CONN_BUF_PBL_OFFSET(func, i) + 4,
+			cp->conn_buf_info.pgtbl[(2 * i) + 1]);
+	}
+
+	CNIC_WR(dev, BAR_USTRORM_INTMEM +
+		USTORM_ISCSI_GLOBAL_BUF_PHYS_ADDR_OFFSET(func),
+		cp->gbl_buf_info.pg_map_arr[0] & 0xffffffff);
+	CNIC_WR(dev, BAR_USTRORM_INTMEM +
+		USTORM_ISCSI_GLOBAL_BUF_PHYS_ADDR_OFFSET(func) + 4,
+		(u64) cp->gbl_buf_info.pg_map_arr[0] >> 32);
+
+	cnic_setup_bnx2x_context(dev);
+
+	eq_idx = CNIC_RD16(dev, BAR_CSTRORM_INTMEM +
+			   CSTORM_SB_HOST_STATUS_BLOCK_C_OFFSET(port, sb_id) +
+			   offsetof(struct cstorm_status_block_c,
+				    index_values[HC_INDEX_C_ISCSI_EQ_CONS]));
+	if (eq_idx != 0) {
+		printk(KERN_ERR PFX "%s: EQ cons index %x != 0\n",
+		       dev->netdev->name, eq_idx);
+		return -EBUSY;
+	}
+	ret = cnic_init_bnx2x_irq(dev);
+	if (ret)
+		return ret;
+
+	cnic_init_bnx2x_tx_ring(dev);
+	cnic_init_bnx2x_rx_ring(dev);
+
+	return 0;
+}
+
 static void cnic_init_rings(struct cnic_dev *dev)
 {
 	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
 		cnic_init_bnx2_tx_ring(dev);
 		cnic_init_bnx2_rx_ring(dev);
+	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
+		struct cnic_local *cp = dev->cnic_priv;
+		struct cnic_eth_dev *ethdev = cp->ethdev;
+		u32 cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
+		union l5cm_specific_data l5_data;
+		struct ustorm_eth_rx_producers rx_prods = {0};
+		void __iomem *doorbell;
+		int i;
+
+		rx_prods.bd_prod = 0;
+		rx_prods.cqe_prod = BNX2X_MAX_RCQ_DESC_CNT;
+		barrier();
+
+		doorbell = ethdev->io_base2 + BAR_USTRORM_INTMEM +
+			USTORM_RX_PRODS_OFFSET(CNIC_PORT(cp), cli);
+
+		for (i = 0; i < sizeof(struct ustorm_eth_rx_producers) / 4; i++)
+			writel(((u32 *) &rx_prods)[i], doorbell + i * 4);
+
+		cnic_init_bnx2x_tx_ring(dev);
+		cnic_init_bnx2x_rx_ring(dev);
+
+		l5_data.phy_address.lo = cli;
+		l5_data.phy_address.hi = 0;
+		cnic_submit_kwqe_16(dev, RAMROD_CMD_ID_ETH_CLIENT_SETUP,
+			BNX2X_ISCSI_L2_CID, ETH_CONNECTION_TYPE, &l5_data);
+		cnic_ring_ctl(dev, BNX2X_ISCSI_L2_CID, cli, 1);
 	}
 }
 
@@ -2494,6 +4162,11 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 {
 	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
 		cnic_shutdown_bnx2_rx_ring(dev);
+	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
+		struct cnic_local *cp = dev->cnic_priv;
+		u32 cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
+
+		cnic_ring_ctl(dev, BNX2X_ISCSI_L2_CID, cli, 0);
 	}
 }
 
@@ -2587,6 +4260,22 @@ static void cnic_stop_bnx2_hw(struct cnic_dev *dev)
 	cnic_free_resc(dev);
 }
 
+
+static void cnic_stop_bnx2x_hw(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	u8 sb_id = cp->status_blk_num;
+	int port = CNIC_PORT(cp);
+
+	cnic_free_irq(dev);
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
+		  CSTORM_SB_HOST_STATUS_BLOCK_C_OFFSET(port, sb_id) +
+		  offsetof(struct cstorm_status_block_c,
+			   index_values[HC_INDEX_C_ISCSI_EQ_CONS]),
+		  0);
+	cnic_free_resc(dev);
+}
+
 static void cnic_stop_hw(struct cnic_dev *dev)
 {
 	if (test_bit(CNIC_F_CNIC_UP, &dev->flags)) {
@@ -2718,6 +4407,57 @@ cnic_err:
 	return NULL;
 }
 
+static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
+{
+	struct pci_dev *pdev;
+	struct cnic_dev *cdev;
+	struct cnic_local *cp;
+	struct cnic_eth_dev *ethdev = NULL;
+	struct cnic_eth_dev *(*probe)(struct net_device *) = NULL;
+
+	probe = symbol_get(bnx2x_cnic_probe);
+	if (probe) {
+		ethdev = (*probe)(dev);
+		symbol_put(bnx2x_cnic_probe);
+	}
+	if (!ethdev)
+		return NULL;
+
+	pdev = ethdev->pdev;
+	if (!pdev)
+		return NULL;
+
+	dev_hold(dev);
+	cdev = cnic_alloc_dev(dev, pdev);
+	if (cdev == NULL) {
+		dev_put(dev);
+		return NULL;
+	}
+
+	set_bit(CNIC_F_BNX2X_CLASS, &cdev->flags);
+	cdev->submit_kwqes = cnic_submit_bnx2x_kwqes;
+
+	cp = cdev->cnic_priv;
+	cp->ethdev = ethdev;
+	cdev->pcidev = pdev;
+
+	cp->cnic_ops = &cnic_bnx2x_ops;
+	cp->start_hw = cnic_start_bnx2x_hw;
+	cp->stop_hw = cnic_stop_bnx2x_hw;
+	cp->setup_pgtbl = cnic_setup_page_tbl_le;
+	cp->alloc_resc = cnic_alloc_bnx2x_resc;
+	cp->free_resc = cnic_free_resc;
+	cp->start_cm = cnic_cm_init_bnx2x_hw;
+	cp->stop_cm = cnic_cm_stop_bnx2x_hw;
+	cp->enable_int = cnic_enable_bnx2x_int;
+	cp->disable_int_sync = cnic_disable_bnx2x_int_sync;
+	cp->ack_int = cnic_ack_bnx2x_msix;
+	cp->close_conn = cnic_close_bnx2x_conn;
+	cp->next_idx = cnic_bnx2x_next_idx;
+	cp->hw_idx = cnic_bnx2x_hw_idx;
+	return cdev;
+}
+
 static struct cnic_dev *is_cnic_dev(struct net_device *dev)
 {
 	struct ethtool_drvinfo drvinfo;
@@ -2729,6 +4469,8 @@ static struct cnic_dev *is_cnic_dev(struct net_device *dev)
 
 		if (!strcmp(drvinfo.driver, "bnx2"))
 			cdev = init_bnx2_cnic(dev);
+		if (!strcmp(drvinfo.driver, "bnx2x"))
+			cdev = init_bnx2x_cnic(dev);
 		if (cdev) {
 			write_lock(&cnic_dev_lock);
 			list_add(&cdev->list, &cnic_dev_list);
-- 
1.6.4.GIT


