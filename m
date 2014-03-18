From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 2/3] cnic,bnx2i,bnx2fc: Fix inconsistent use of page size
Date: Mon, 17 Mar 2014 19:19:07 -0800
Message-ID: <1395112748-21965-3-git-send-email-mchan@broadcom.com>
References: <1395112748-21965-1-git-send-email-mchan@broadcom.com>
 <1395112748-21965-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <eddie.wai@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:61939 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471AbaCRCAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 22:00:10 -0400
In-Reply-To: <1395112748-21965-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnx2/bnx2x rings are made up of linked pages.  However there is an
upper limit on the page size as some the page size settings are 16-bit
in the hardware/firmware interface.  In the current code, some parts
use BNX2_PAGE_SIZE which has a 16K upper limit and some parts use
PAGE_SIZE.  On archs with >= 64K PAGE_SIZE, it generates some compile
warnings.  Define a new CNIC_PAGE_SZIE which has an upper limit of
16K and use it consistently in all relevant parts.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c    |  104 +++++++++++++++---------------
 drivers/net/ethernet/broadcom/cnic_if.h |   10 +++
 drivers/scsi/bnx2fc/bnx2fc_io.c         |   16 +++---
 drivers/scsi/bnx2fc/bnx2fc_tgt.c        |   38 ++++++-----
 drivers/scsi/bnx2i/bnx2i_hwi.c          |   52 ++++++++--------
 drivers/scsi/bnx2i/bnx2i_iscsi.c        |   23 ++++---
 6 files changed, 129 insertions(+), 114 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 2cb2482..ea37ea2 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -726,7 +726,7 @@ static void cnic_free_dma(struct cnic_dev *dev, struct cnic_dma *dma)
 
 	for (i = 0; i < dma->num_pages; i++) {
 		if (dma->pg_arr[i]) {
-			dma_free_coherent(&dev->pcidev->dev, BNX2_PAGE_SIZE,
+			dma_free_coherent(&dev->pcidev->dev, CNIC_PAGE_SIZE,
 					  dma->pg_arr[i], dma->pg_map_arr[i]);
 			dma->pg_arr[i] = NULL;
 		}
@@ -785,7 +785,7 @@ static int cnic_alloc_dma(struct cnic_dev *dev, struct cnic_dma *dma,
 
 	for (i = 0; i < pages; i++) {
 		dma->pg_arr[i] = dma_alloc_coherent(&dev->pcidev->dev,
-						    BNX2_PAGE_SIZE,
+						    CNIC_PAGE_SIZE,
 						    &dma->pg_map_arr[i],
 						    GFP_ATOMIC);
 		if (dma->pg_arr[i] == NULL)
@@ -794,8 +794,8 @@ static int cnic_alloc_dma(struct cnic_dev *dev, struct cnic_dma *dma,
 	if (!use_pg_tbl)
 		return 0;
 
-	dma->pgtbl_size = ((pages * 8) + BNX2_PAGE_SIZE - 1) &
-			  ~(BNX2_PAGE_SIZE - 1);
+	dma->pgtbl_size = ((pages * 8) + CNIC_PAGE_SIZE - 1) &
+			  ~(CNIC_PAGE_SIZE - 1);
 	dma->pgtbl = dma_alloc_coherent(&dev->pcidev->dev, dma->pgtbl_size,
 					&dma->pgtbl_map, GFP_ATOMIC);
 	if (dma->pgtbl == NULL)
@@ -900,8 +900,8 @@ static int cnic_alloc_context(struct cnic_dev *dev)
 	if (BNX2_CHIP(cp) == BNX2_CHIP_5709) {
 		int i, k, arr_size;
 
-		cp->ctx_blk_size = BNX2_PAGE_SIZE;
-		cp->cids_per_blk = BNX2_PAGE_SIZE / 128;
+		cp->ctx_blk_size = CNIC_PAGE_SIZE;
+		cp->cids_per_blk = CNIC_PAGE_SIZE / 128;
 		arr_size = BNX2_MAX_CID / cp->cids_per_blk *
 			   sizeof(struct cnic_ctx);
 		cp->ctx_arr = kzalloc(arr_size, GFP_KERNEL);
@@ -933,7 +933,7 @@ static int cnic_alloc_context(struct cnic_dev *dev)
 		for (i = 0; i < cp->ctx_blks; i++) {
 			cp->ctx_arr[i].ctx =
 				dma_alloc_coherent(&dev->pcidev->dev,
-						   BNX2_PAGE_SIZE,
+						   CNIC_PAGE_SIZE,
 						   &cp->ctx_arr[i].mapping,
 						   GFP_KERNEL);
 			if (cp->ctx_arr[i].ctx == NULL)
@@ -1013,7 +1013,7 @@ static int __cnic_alloc_uio_rings(struct cnic_uio_dev *udev, int pages)
 	if (udev->l2_ring)
 		return 0;
 
-	udev->l2_ring_size = pages * BNX2_PAGE_SIZE;
+	udev->l2_ring_size = pages * CNIC_PAGE_SIZE;
 	udev->l2_ring = dma_alloc_coherent(&udev->pdev->dev, udev->l2_ring_size,
 					   &udev->l2_ring_map,
 					   GFP_KERNEL | __GFP_COMP);
@@ -1021,7 +1021,7 @@ static int __cnic_alloc_uio_rings(struct cnic_uio_dev *udev, int pages)
 		return -ENOMEM;
 
 	udev->l2_buf_size = (cp->l2_rx_ring_size + 1) * cp->l2_single_buf_size;
-	udev->l2_buf_size = PAGE_ALIGN(udev->l2_buf_size);
+	udev->l2_buf_size = CNIC_PAGE_ALIGN(udev->l2_buf_size);
 	udev->l2_buf = dma_alloc_coherent(&udev->pdev->dev, udev->l2_buf_size,
 					  &udev->l2_buf_map,
 					  GFP_KERNEL | __GFP_COMP);
@@ -1102,7 +1102,7 @@ static int cnic_init_uio(struct cnic_dev *dev)
 		uinfo->mem[0].size = MB_GET_CID_ADDR(TX_TSS_CID +
 						     TX_MAX_TSS_RINGS + 1);
 		uinfo->mem[1].addr = (unsigned long) cp->status_blk.gen &
-					PAGE_MASK;
+					CNIC_PAGE_MASK;
 		if (cp->ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX)
 			uinfo->mem[1].size = BNX2_SBLK_MSIX_ALIGN_SIZE * 9;
 		else
@@ -1113,7 +1113,7 @@ static int cnic_init_uio(struct cnic_dev *dev)
 		uinfo->mem[0].size = pci_resource_len(dev->pcidev, 0);
 
 		uinfo->mem[1].addr = (unsigned long) cp->bnx2x_def_status_blk &
-			PAGE_MASK;
+			CNIC_PAGE_MASK;
 		uinfo->mem[1].size = sizeof(*cp->bnx2x_def_status_blk);
 
 		uinfo->name = "bnx2x_cnic";
@@ -1267,14 +1267,14 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	for (i = MAX_ISCSI_TBL_SZ; i < cp->max_cid_space; i++)
 		cp->ctx_tbl[i].ulp_proto_id = CNIC_ULP_FCOE;
 
-	pages = PAGE_ALIGN(cp->max_cid_space * CNIC_KWQ16_DATA_SIZE) /
-		PAGE_SIZE;
+	pages = CNIC_PAGE_ALIGN(cp->max_cid_space * CNIC_KWQ16_DATA_SIZE) /
+		CNIC_PAGE_SIZE;
 
 	ret = cnic_alloc_dma(dev, kwq_16_dma, pages, 0);
 	if (ret)
 		return -ENOMEM;
 
-	n = PAGE_SIZE / CNIC_KWQ16_DATA_SIZE;
+	n = CNIC_PAGE_SIZE / CNIC_KWQ16_DATA_SIZE;
 	for (i = 0, j = 0; i < cp->max_cid_space; i++) {
 		long off = CNIC_KWQ16_DATA_SIZE * (i % n);
 
@@ -1296,7 +1296,7 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 			goto error;
 	}
 
-	pages = PAGE_ALIGN(BNX2X_ISCSI_GLB_BUF_SIZE) / PAGE_SIZE;
+	pages = CNIC_PAGE_ALIGN(BNX2X_ISCSI_GLB_BUF_SIZE) / CNIC_PAGE_SIZE;
 	ret = cnic_alloc_dma(dev, &cp->gbl_buf_info, pages, 0);
 	if (ret)
 		goto error;
@@ -1466,8 +1466,8 @@ static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 	cp->r2tq_size = cp->num_iscsi_tasks * BNX2X_ISCSI_MAX_PENDING_R2TS *
 			BNX2X_ISCSI_R2TQE_SIZE;
 	cp->hq_size = cp->num_ccells * BNX2X_ISCSI_HQ_BD_SIZE;
-	pages = PAGE_ALIGN(cp->hq_size) / PAGE_SIZE;
-	hq_bds = pages * (PAGE_SIZE / BNX2X_ISCSI_HQ_BD_SIZE);
+	pages = CNIC_PAGE_ALIGN(cp->hq_size) / CNIC_PAGE_SIZE;
+	hq_bds = pages * (CNIC_PAGE_SIZE / BNX2X_ISCSI_HQ_BD_SIZE);
 	cp->num_cqs = req1->num_cqs;
 
 	if (!dev->max_iscsi_conn)
@@ -1477,9 +1477,9 @@ static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 	CNIC_WR16(dev, BAR_TSTRORM_INTMEM + TSTORM_ISCSI_RQ_SIZE_OFFSET(pfid),
 		  req1->rq_num_wqes);
 	CNIC_WR16(dev, BAR_TSTRORM_INTMEM + TSTORM_ISCSI_PAGE_SIZE_OFFSET(pfid),
-		  PAGE_SIZE);
+		  CNIC_PAGE_SIZE);
 	CNIC_WR8(dev, BAR_TSTRORM_INTMEM +
-		 TSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), PAGE_SHIFT);
+		 TSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), CNIC_PAGE_BITS);
 	CNIC_WR16(dev, BAR_TSTRORM_INTMEM +
 		  TSTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfid),
 		  req1->num_tasks_per_conn);
@@ -1489,9 +1489,9 @@ static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 		  USTORM_ISCSI_RQ_BUFFER_SIZE_OFFSET(pfid),
 		  req1->rq_buffer_size);
 	CNIC_WR16(dev, BAR_USTRORM_INTMEM + USTORM_ISCSI_PAGE_SIZE_OFFSET(pfid),
-		  PAGE_SIZE);
+		  CNIC_PAGE_SIZE);
 	CNIC_WR8(dev, BAR_USTRORM_INTMEM +
-		 USTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), PAGE_SHIFT);
+		 USTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), CNIC_PAGE_BITS);
 	CNIC_WR16(dev, BAR_USTRORM_INTMEM +
 		  USTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfid),
 		  req1->num_tasks_per_conn);
@@ -1504,9 +1504,9 @@ static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 
 	/* init Xstorm RAM */
 	CNIC_WR16(dev, BAR_XSTRORM_INTMEM + XSTORM_ISCSI_PAGE_SIZE_OFFSET(pfid),
-		  PAGE_SIZE);
+		  CNIC_PAGE_SIZE);
 	CNIC_WR8(dev, BAR_XSTRORM_INTMEM +
-		 XSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), PAGE_SHIFT);
+		 XSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), CNIC_PAGE_BITS);
 	CNIC_WR16(dev, BAR_XSTRORM_INTMEM +
 		  XSTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfid),
 		  req1->num_tasks_per_conn);
@@ -1519,9 +1519,9 @@ static int cnic_bnx2x_iscsi_init1(struct cnic_dev *dev, struct kwqe *kwqe)
 
 	/* init Cstorm RAM */
 	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_ISCSI_PAGE_SIZE_OFFSET(pfid),
-		  PAGE_SIZE);
+		  CNIC_PAGE_SIZE);
 	CNIC_WR8(dev, BAR_CSTRORM_INTMEM +
-		 CSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), PAGE_SHIFT);
+		 CSTORM_ISCSI_PAGE_SIZE_LOG_OFFSET(pfid), CNIC_PAGE_BITS);
 	CNIC_WR16(dev, BAR_CSTRORM_INTMEM +
 		  CSTORM_ISCSI_NUM_OF_TASKS_OFFSET(pfid),
 		  req1->num_tasks_per_conn);
@@ -1623,18 +1623,18 @@ static int cnic_alloc_bnx2x_conn_resc(struct cnic_dev *dev, u32 l5_cid)
 	}
 
 	ctx->cid = cid;
-	pages = PAGE_ALIGN(cp->task_array_size) / PAGE_SIZE;
+	pages = CNIC_PAGE_ALIGN(cp->task_array_size) / CNIC_PAGE_SIZE;
 
 	ret = cnic_alloc_dma(dev, &iscsi->task_array_info, pages, 1);
 	if (ret)
 		goto error;
 
-	pages = PAGE_ALIGN(cp->r2tq_size) / PAGE_SIZE;
+	pages = CNIC_PAGE_ALIGN(cp->r2tq_size) / CNIC_PAGE_SIZE;
 	ret = cnic_alloc_dma(dev, &iscsi->r2tq_info, pages, 1);
 	if (ret)
 		goto error;
 
-	pages = PAGE_ALIGN(cp->hq_size) / PAGE_SIZE;
+	pages = CNIC_PAGE_ALIGN(cp->hq_size) / CNIC_PAGE_SIZE;
 	ret = cnic_alloc_dma(dev, &iscsi->hq_info, pages, 1);
 	if (ret)
 		goto error;
@@ -1760,7 +1760,7 @@ static int cnic_setup_bnx2x_ctx(struct cnic_dev *dev, struct kwqe *wqes[],
 	ictx->tstorm_st_context.iscsi.hdr_bytes_2_fetch = ISCSI_HEADER_SIZE;
 	/* TSTORM requires the base address of RQ DB & not PTE */
 	ictx->tstorm_st_context.iscsi.rq_db_phy_addr.lo =
-		req2->rq_page_table_addr_lo & PAGE_MASK;
+		req2->rq_page_table_addr_lo & CNIC_PAGE_MASK;
 	ictx->tstorm_st_context.iscsi.rq_db_phy_addr.hi =
 		req2->rq_page_table_addr_hi;
 	ictx->tstorm_st_context.iscsi.iscsi_conn_id = req1->iscsi_conn_id;
@@ -1842,7 +1842,7 @@ static int cnic_setup_bnx2x_ctx(struct cnic_dev *dev, struct kwqe *wqes[],
 	/* CSTORM and USTORM initialization is different, CSTORM requires
 	 * CQ DB base & not PTE addr */
 	ictx->cstorm_st_context.cq_db_base.lo =
-		req1->cq_page_table_addr_lo & PAGE_MASK;
+		req1->cq_page_table_addr_lo & CNIC_PAGE_MASK;
 	ictx->cstorm_st_context.cq_db_base.hi = req1->cq_page_table_addr_hi;
 	ictx->cstorm_st_context.iscsi_conn_id = req1->iscsi_conn_id;
 	ictx->cstorm_st_context.cq_proc_en_bit_map = (1 << cp->num_cqs) - 1;
@@ -2911,7 +2911,7 @@ static int cnic_l2_completion(struct cnic_local *cp)
 	u16 hw_cons, sw_cons;
 	struct cnic_uio_dev *udev = cp->udev;
 	union eth_rx_cqe *cqe, *cqe_ring = (union eth_rx_cqe *)
-					(udev->l2_ring + (2 * BNX2_PAGE_SIZE));
+					(udev->l2_ring + (2 * CNIC_PAGE_SIZE));
 	u32 cmd;
 	int comp = 0;
 
@@ -4385,7 +4385,7 @@ static int cnic_setup_5709_context(struct cnic_dev *dev, int valid)
 		u32 idx = cp->ctx_arr[i].cid / cp->cids_per_blk;
 		u32 val;
 
-		memset(cp->ctx_arr[i].ctx, 0, BNX2_PAGE_SIZE);
+		memset(cp->ctx_arr[i].ctx, 0, CNIC_PAGE_SIZE);
 
 		CNIC_WR(dev, BNX2_CTX_HOST_PAGE_TBL_DATA0,
 			(cp->ctx_arr[i].mapping & 0xffffffff) | valid_bit);
@@ -4629,7 +4629,7 @@ static void cnic_init_bnx2_rx_ring(struct cnic_dev *dev)
 		val = BNX2_L2CTX_L2_STATUSB_NUM(sb_id);
 	cnic_ctx_wr(dev, cid_addr, BNX2_L2CTX_HOST_BDIDX, val);
 
-	rxbd = udev->l2_ring + BNX2_PAGE_SIZE;
+	rxbd = udev->l2_ring + CNIC_PAGE_SIZE;
 	for (i = 0; i < BNX2_MAX_RX_DESC_CNT; i++, rxbd++) {
 		dma_addr_t buf_map;
 		int n = (i % cp->l2_rx_ring_size) + 1;
@@ -4640,11 +4640,11 @@ static void cnic_init_bnx2_rx_ring(struct cnic_dev *dev)
 		rxbd->rx_bd_haddr_hi = (u64) buf_map >> 32;
 		rxbd->rx_bd_haddr_lo = (u64) buf_map & 0xffffffff;
 	}
-	val = (u64) (ring_map + BNX2_PAGE_SIZE) >> 32;
+	val = (u64) (ring_map + CNIC_PAGE_SIZE) >> 32;
 	cnic_ctx_wr(dev, cid_addr, BNX2_L2CTX_NX_BDHADDR_HI, val);
 	rxbd->rx_bd_haddr_hi = val;
 
-	val = (u64) (ring_map + BNX2_PAGE_SIZE) & 0xffffffff;
+	val = (u64) (ring_map + CNIC_PAGE_SIZE) & 0xffffffff;
 	cnic_ctx_wr(dev, cid_addr, BNX2_L2CTX_NX_BDHADDR_LO, val);
 	rxbd->rx_bd_haddr_lo = val;
 
@@ -4710,10 +4710,10 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 
 	val = CNIC_RD(dev, BNX2_MQ_CONFIG);
 	val &= ~BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE;
-	if (BNX2_PAGE_BITS > 12)
+	if (CNIC_PAGE_BITS > 12)
 		val |= (12 - 8)  << 4;
 	else
-		val |= (BNX2_PAGE_BITS - 8)  << 4;
+		val |= (CNIC_PAGE_BITS - 8)  << 4;
 
 	CNIC_WR(dev, BNX2_MQ_CONFIG, val);
 
@@ -4743,13 +4743,13 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 
 	/* Initialize the kernel work queue context. */
 	val = KRNLQ_TYPE_TYPE_KRNLQ | KRNLQ_SIZE_TYPE_SIZE |
-	      (BNX2_PAGE_BITS - 8) | KRNLQ_FLAGS_QE_SELF_SEQ;
+	      (CNIC_PAGE_BITS - 8) | KRNLQ_FLAGS_QE_SELF_SEQ;
 	cnic_ctx_wr(dev, kwq_cid_addr, L5_KRNLQ_TYPE, val);
 
-	val = (BNX2_PAGE_SIZE / sizeof(struct kwqe) - 1) << 16;
+	val = (CNIC_PAGE_SIZE / sizeof(struct kwqe) - 1) << 16;
 	cnic_ctx_wr(dev, kwq_cid_addr, L5_KRNLQ_QE_SELF_SEQ_MAX, val);
 
-	val = ((BNX2_PAGE_SIZE / sizeof(struct kwqe)) << 16) | KWQ_PAGE_CNT;
+	val = ((CNIC_PAGE_SIZE / sizeof(struct kwqe)) << 16) | KWQ_PAGE_CNT;
 	cnic_ctx_wr(dev, kwq_cid_addr, L5_KRNLQ_PGTBL_NPAGES, val);
 
 	val = (u32) ((u64) cp->kwq_info.pgtbl_map >> 32);
@@ -4769,13 +4769,13 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 
 	/* Initialize the kernel complete queue context. */
 	val = KRNLQ_TYPE_TYPE_KRNLQ | KRNLQ_SIZE_TYPE_SIZE |
-	      (BNX2_PAGE_BITS - 8) | KRNLQ_FLAGS_QE_SELF_SEQ;
+	      (CNIC_PAGE_BITS - 8) | KRNLQ_FLAGS_QE_SELF_SEQ;
 	cnic_ctx_wr(dev, kcq_cid_addr, L5_KRNLQ_TYPE, val);
 
-	val = (BNX2_PAGE_SIZE / sizeof(struct kcqe) - 1) << 16;
+	val = (CNIC_PAGE_SIZE / sizeof(struct kcqe) - 1) << 16;
 	cnic_ctx_wr(dev, kcq_cid_addr, L5_KRNLQ_QE_SELF_SEQ_MAX, val);
 
-	val = ((BNX2_PAGE_SIZE / sizeof(struct kcqe)) << 16) | KCQ_PAGE_CNT;
+	val = ((CNIC_PAGE_SIZE / sizeof(struct kcqe)) << 16) | KCQ_PAGE_CNT;
 	cnic_ctx_wr(dev, kcq_cid_addr, L5_KRNLQ_PGTBL_NPAGES, val);
 
 	val = (u32) ((u64) cp->kcq1.dma.pgtbl_map >> 32);
@@ -4919,7 +4919,7 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev,
 	u32 cli = cp->ethdev->iscsi_l2_client_id;
 	u32 val;
 
-	memset(txbd, 0, BNX2_PAGE_SIZE);
+	memset(txbd, 0, CNIC_PAGE_SIZE);
 
 	buf_map = udev->l2_buf_map;
 	for (i = 0; i < BNX2_MAX_TX_DESC_CNT; i += 3, txbd += 3) {
@@ -4979,9 +4979,9 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 	struct bnx2x *bp = netdev_priv(dev->netdev);
 	struct cnic_uio_dev *udev = cp->udev;
 	struct eth_rx_bd *rxbd = (struct eth_rx_bd *) (udev->l2_ring +
-				BNX2_PAGE_SIZE);
+				CNIC_PAGE_SIZE);
 	struct eth_rx_cqe_next_page *rxcqe = (struct eth_rx_cqe_next_page *)
-				(udev->l2_ring + (2 * BNX2_PAGE_SIZE));
+				(udev->l2_ring + (2 * CNIC_PAGE_SIZE));
 	struct host_sp_status_block *sb = cp->bnx2x_def_status_blk;
 	int i;
 	u32 cli = cp->ethdev->iscsi_l2_client_id;
@@ -5005,20 +5005,20 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 		rxbd->addr_lo = cpu_to_le32(buf_map & 0xffffffff);
 	}
 
-	val = (u64) (ring_map + BNX2_PAGE_SIZE) >> 32;
+	val = (u64) (ring_map + CNIC_PAGE_SIZE) >> 32;
 	rxbd->addr_hi = cpu_to_le32(val);
 	data->rx.bd_page_base.hi = cpu_to_le32(val);
 
-	val = (u64) (ring_map + BNX2_PAGE_SIZE) & 0xffffffff;
+	val = (u64) (ring_map + CNIC_PAGE_SIZE) & 0xffffffff;
 	rxbd->addr_lo = cpu_to_le32(val);
 	data->rx.bd_page_base.lo = cpu_to_le32(val);
 
 	rxcqe += BNX2X_MAX_RCQ_DESC_CNT;
-	val = (u64) (ring_map + (2 * BNX2_PAGE_SIZE)) >> 32;
+	val = (u64) (ring_map + (2 * CNIC_PAGE_SIZE)) >> 32;
 	rxcqe->addr_hi = cpu_to_le32(val);
 	data->rx.cqe_page_base.hi = cpu_to_le32(val);
 
-	val = (u64) (ring_map + (2 * BNX2_PAGE_SIZE)) & 0xffffffff;
+	val = (u64) (ring_map + (2 * CNIC_PAGE_SIZE)) & 0xffffffff;
 	rxcqe->addr_lo = cpu_to_le32(val);
 	data->rx.cqe_page_base.lo = cpu_to_le32(val);
 
@@ -5266,8 +5266,8 @@ static void cnic_shutdown_rings(struct cnic_dev *dev)
 		msleep(10);
 	}
 	clear_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags);
-	rx_ring = udev->l2_ring + BNX2_PAGE_SIZE;
-	memset(rx_ring, 0, BNX2_PAGE_SIZE);
+	rx_ring = udev->l2_ring + CNIC_PAGE_SIZE;
+	memset(rx_ring, 0, CNIC_PAGE_SIZE);
 }
 
 static int cnic_register_netdev(struct cnic_dev *dev)
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 8cf6b19..40bb563 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -24,6 +24,16 @@
 #define MAX_CNIC_ULP_TYPE_EXT	3
 #define MAX_CNIC_ULP_TYPE	4
 
+/* Use CPU native page size up to 16K for cnic ring sizes.  */
+#if (PAGE_SHIFT > 14)
+#define CNIC_PAGE_BITS	14
+#else
+#define CNIC_PAGE_BITS	PAGE_SHIFT
+#endif
+#define CNIC_PAGE_SIZE	(1 << (CNIC_PAGE_BITS))
+#define CNIC_PAGE_ALIGN(addr) ALIGN(addr, CNIC_PAGE_SIZE)
+#define CNIC_PAGE_MASK	(~((CNIC_PAGE_SIZE) - 1))
+
 struct kwqe {
 	u32 kwqe_op_flag;
 
diff --git a/drivers/scsi/bnx2fc/bnx2fc_io.c b/drivers/scsi/bnx2fc/bnx2fc_io.c
index ed88089..e9279a8 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_io.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_io.c
@@ -594,13 +594,13 @@ static void bnx2fc_free_mp_resc(struct bnx2fc_cmd *io_req)
 		mp_req->mp_resp_bd = NULL;
 	}
 	if (mp_req->req_buf) {
-		dma_free_coherent(&hba->pcidev->dev, PAGE_SIZE,
+		dma_free_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 				     mp_req->req_buf,
 				     mp_req->req_buf_dma);
 		mp_req->req_buf = NULL;
 	}
 	if (mp_req->resp_buf) {
-		dma_free_coherent(&hba->pcidev->dev, PAGE_SIZE,
+		dma_free_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 				     mp_req->resp_buf,
 				     mp_req->resp_buf_dma);
 		mp_req->resp_buf = NULL;
@@ -622,7 +622,7 @@ int bnx2fc_init_mp_req(struct bnx2fc_cmd *io_req)
 
 	mp_req->req_len = sizeof(struct fcp_cmnd);
 	io_req->data_xfer_len = mp_req->req_len;
-	mp_req->req_buf = dma_alloc_coherent(&hba->pcidev->dev, PAGE_SIZE,
+	mp_req->req_buf = dma_alloc_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 					     &mp_req->req_buf_dma,
 					     GFP_ATOMIC);
 	if (!mp_req->req_buf) {
@@ -631,7 +631,7 @@ int bnx2fc_init_mp_req(struct bnx2fc_cmd *io_req)
 		return FAILED;
 	}
 
-	mp_req->resp_buf = dma_alloc_coherent(&hba->pcidev->dev, PAGE_SIZE,
+	mp_req->resp_buf = dma_alloc_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 					      &mp_req->resp_buf_dma,
 					      GFP_ATOMIC);
 	if (!mp_req->resp_buf) {
@@ -639,8 +639,8 @@ int bnx2fc_init_mp_req(struct bnx2fc_cmd *io_req)
 		bnx2fc_free_mp_resc(io_req);
 		return FAILED;
 	}
-	memset(mp_req->req_buf, 0, PAGE_SIZE);
-	memset(mp_req->resp_buf, 0, PAGE_SIZE);
+	memset(mp_req->req_buf, 0, CNIC_PAGE_SIZE);
+	memset(mp_req->resp_buf, 0, CNIC_PAGE_SIZE);
 
 	/* Allocate and map mp_req_bd and mp_resp_bd */
 	sz = sizeof(struct fcoe_bd_ctx);
@@ -665,7 +665,7 @@ int bnx2fc_init_mp_req(struct bnx2fc_cmd *io_req)
 	mp_req_bd = mp_req->mp_req_bd;
 	mp_req_bd->buf_addr_lo = (u32)addr & 0xffffffff;
 	mp_req_bd->buf_addr_hi = (u32)((u64)addr >> 32);
-	mp_req_bd->buf_len = PAGE_SIZE;
+	mp_req_bd->buf_len = CNIC_PAGE_SIZE;
 	mp_req_bd->flags = 0;
 
 	/*
@@ -677,7 +677,7 @@ int bnx2fc_init_mp_req(struct bnx2fc_cmd *io_req)
 	addr = mp_req->resp_buf_dma;
 	mp_resp_bd->buf_addr_lo = (u32)addr & 0xffffffff;
 	mp_resp_bd->buf_addr_hi = (u32)((u64)addr >> 32);
-	mp_resp_bd->buf_len = PAGE_SIZE;
+	mp_resp_bd->buf_len = CNIC_PAGE_SIZE;
 	mp_resp_bd->flags = 0;
 
 	return SUCCESS;
diff --git a/drivers/scsi/bnx2fc/bnx2fc_tgt.c b/drivers/scsi/bnx2fc/bnx2fc_tgt.c
index 4d93177..d9bae56 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_tgt.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_tgt.c
@@ -673,7 +673,8 @@ static int bnx2fc_alloc_session_resc(struct bnx2fc_hba *hba,
 
 	/* Allocate and map SQ */
 	tgt->sq_mem_size = tgt->max_sqes * BNX2FC_SQ_WQE_SIZE;
-	tgt->sq_mem_size = (tgt->sq_mem_size + (PAGE_SIZE - 1)) & PAGE_MASK;
+	tgt->sq_mem_size = (tgt->sq_mem_size + (CNIC_PAGE_SIZE - 1)) &
+			   CNIC_PAGE_MASK;
 
 	tgt->sq = dma_alloc_coherent(&hba->pcidev->dev, tgt->sq_mem_size,
 				     &tgt->sq_dma, GFP_KERNEL);
@@ -686,7 +687,8 @@ static int bnx2fc_alloc_session_resc(struct bnx2fc_hba *hba,
 
 	/* Allocate and map CQ */
 	tgt->cq_mem_size = tgt->max_cqes * BNX2FC_CQ_WQE_SIZE;
-	tgt->cq_mem_size = (tgt->cq_mem_size + (PAGE_SIZE - 1)) & PAGE_MASK;
+	tgt->cq_mem_size = (tgt->cq_mem_size + (CNIC_PAGE_SIZE - 1)) &
+			   CNIC_PAGE_MASK;
 
 	tgt->cq = dma_alloc_coherent(&hba->pcidev->dev, tgt->cq_mem_size,
 				     &tgt->cq_dma, GFP_KERNEL);
@@ -699,7 +701,8 @@ static int bnx2fc_alloc_session_resc(struct bnx2fc_hba *hba,
 
 	/* Allocate and map RQ and RQ PBL */
 	tgt->rq_mem_size = tgt->max_rqes * BNX2FC_RQ_WQE_SIZE;
-	tgt->rq_mem_size = (tgt->rq_mem_size + (PAGE_SIZE - 1)) & PAGE_MASK;
+	tgt->rq_mem_size = (tgt->rq_mem_size + (CNIC_PAGE_SIZE - 1)) &
+			   CNIC_PAGE_MASK;
 
 	tgt->rq = dma_alloc_coherent(&hba->pcidev->dev, tgt->rq_mem_size,
 					&tgt->rq_dma, GFP_KERNEL);
@@ -710,8 +713,9 @@ static int bnx2fc_alloc_session_resc(struct bnx2fc_hba *hba,
 	}
 	memset(tgt->rq, 0, tgt->rq_mem_size);
 
-	tgt->rq_pbl_size = (tgt->rq_mem_size / PAGE_SIZE) * sizeof(void *);
-	tgt->rq_pbl_size = (tgt->rq_pbl_size + (PAGE_SIZE - 1)) & PAGE_MASK;
+	tgt->rq_pbl_size = (tgt->rq_mem_size / CNIC_PAGE_SIZE) * sizeof(void *);
+	tgt->rq_pbl_size = (tgt->rq_pbl_size + (CNIC_PAGE_SIZE - 1)) &
+			   CNIC_PAGE_MASK;
 
 	tgt->rq_pbl = dma_alloc_coherent(&hba->pcidev->dev, tgt->rq_pbl_size,
 					 &tgt->rq_pbl_dma, GFP_KERNEL);
@@ -722,7 +726,7 @@ static int bnx2fc_alloc_session_resc(struct bnx2fc_hba *hba,
 	}
 
 	memset(tgt->rq_pbl, 0, tgt->rq_pbl_size);
-	num_pages = tgt->rq_mem_size / PAGE_SIZE;
+	num_pages = tgt->rq_mem_size / CNIC_PAGE_SIZE;
 	page = tgt->rq_dma;
 	pbl = (u32 *)tgt->rq_pbl;
 
@@ -731,13 +735,13 @@ static int bnx2fc_alloc_session_resc(struct bnx2fc_hba *hba,
 		pbl++;
 		*pbl = (u32)((u64)page >> 32);
 		pbl++;
-		page += PAGE_SIZE;
+		page += CNIC_PAGE_SIZE;
 	}
 
 	/* Allocate and map XFERQ */
 	tgt->xferq_mem_size = tgt->max_sqes * BNX2FC_XFERQ_WQE_SIZE;
-	tgt->xferq_mem_size = (tgt->xferq_mem_size + (PAGE_SIZE - 1)) &
-			       PAGE_MASK;
+	tgt->xferq_mem_size = (tgt->xferq_mem_size + (CNIC_PAGE_SIZE - 1)) &
+			       CNIC_PAGE_MASK;
 
 	tgt->xferq = dma_alloc_coherent(&hba->pcidev->dev, tgt->xferq_mem_size,
 					&tgt->xferq_dma, GFP_KERNEL);
@@ -750,8 +754,8 @@ static int bnx2fc_alloc_session_resc(struct bnx2fc_hba *hba,
 
 	/* Allocate and map CONFQ & CONFQ PBL */
 	tgt->confq_mem_size = tgt->max_sqes * BNX2FC_CONFQ_WQE_SIZE;
-	tgt->confq_mem_size = (tgt->confq_mem_size + (PAGE_SIZE - 1)) &
-			       PAGE_MASK;
+	tgt->confq_mem_size = (tgt->confq_mem_size + (CNIC_PAGE_SIZE - 1)) &
+			       CNIC_PAGE_MASK;
 
 	tgt->confq = dma_alloc_coherent(&hba->pcidev->dev, tgt->confq_mem_size,
 					&tgt->confq_dma, GFP_KERNEL);
@@ -763,9 +767,9 @@ static int bnx2fc_alloc_session_resc(struct bnx2fc_hba *hba,
 	memset(tgt->confq, 0, tgt->confq_mem_size);
 
 	tgt->confq_pbl_size =
-		(tgt->confq_mem_size / PAGE_SIZE) * sizeof(void *);
+		(tgt->confq_mem_size / CNIC_PAGE_SIZE) * sizeof(void *);
 	tgt->confq_pbl_size =
-		(tgt->confq_pbl_size + (PAGE_SIZE - 1)) & PAGE_MASK;
+		(tgt->confq_pbl_size + (CNIC_PAGE_SIZE - 1)) & CNIC_PAGE_MASK;
 
 	tgt->confq_pbl = dma_alloc_coherent(&hba->pcidev->dev,
 					    tgt->confq_pbl_size,
@@ -777,7 +781,7 @@ static int bnx2fc_alloc_session_resc(struct bnx2fc_hba *hba,
 	}
 
 	memset(tgt->confq_pbl, 0, tgt->confq_pbl_size);
-	num_pages = tgt->confq_mem_size / PAGE_SIZE;
+	num_pages = tgt->confq_mem_size / CNIC_PAGE_SIZE;
 	page = tgt->confq_dma;
 	pbl = (u32 *)tgt->confq_pbl;
 
@@ -786,7 +790,7 @@ static int bnx2fc_alloc_session_resc(struct bnx2fc_hba *hba,
 		pbl++;
 		*pbl = (u32)((u64)page >> 32);
 		pbl++;
-		page += PAGE_SIZE;
+		page += CNIC_PAGE_SIZE;
 	}
 
 	/* Allocate and map ConnDB */
@@ -805,8 +809,8 @@ static int bnx2fc_alloc_session_resc(struct bnx2fc_hba *hba,
 
 	/* Allocate and map LCQ */
 	tgt->lcq_mem_size = (tgt->max_sqes + 8) * BNX2FC_SQ_WQE_SIZE;
-	tgt->lcq_mem_size = (tgt->lcq_mem_size + (PAGE_SIZE - 1)) &
-			     PAGE_MASK;
+	tgt->lcq_mem_size = (tgt->lcq_mem_size + (CNIC_PAGE_SIZE - 1)) &
+			     CNIC_PAGE_MASK;
 
 	tgt->lcq = dma_alloc_coherent(&hba->pcidev->dev, tgt->lcq_mem_size,
 				      &tgt->lcq_dma, GFP_KERNEL);
diff --git a/drivers/scsi/bnx2i/bnx2i_hwi.c b/drivers/scsi/bnx2i/bnx2i_hwi.c
index e4cf23d..b87a193 100644
--- a/drivers/scsi/bnx2i/bnx2i_hwi.c
+++ b/drivers/scsi/bnx2i/bnx2i_hwi.c
@@ -61,7 +61,7 @@ static void bnx2i_adjust_qp_size(struct bnx2i_hba *hba)
 	 * yield integral num of page buffers
 	 */
 	/* adjust SQ */
-	num_elements_per_pg = PAGE_SIZE / BNX2I_SQ_WQE_SIZE;
+	num_elements_per_pg = CNIC_PAGE_SIZE / BNX2I_SQ_WQE_SIZE;
 	if (hba->max_sqes < num_elements_per_pg)
 		hba->max_sqes = num_elements_per_pg;
 	else if (hba->max_sqes % num_elements_per_pg)
@@ -69,7 +69,7 @@ static void bnx2i_adjust_qp_size(struct bnx2i_hba *hba)
 				 ~(num_elements_per_pg - 1);
 
 	/* adjust CQ */
-	num_elements_per_pg = PAGE_SIZE / BNX2I_CQE_SIZE;
+	num_elements_per_pg = CNIC_PAGE_SIZE / BNX2I_CQE_SIZE;
 	if (hba->max_cqes < num_elements_per_pg)
 		hba->max_cqes = num_elements_per_pg;
 	else if (hba->max_cqes % num_elements_per_pg)
@@ -77,7 +77,7 @@ static void bnx2i_adjust_qp_size(struct bnx2i_hba *hba)
 				 ~(num_elements_per_pg - 1);
 
 	/* adjust RQ */
-	num_elements_per_pg = PAGE_SIZE / BNX2I_RQ_WQE_SIZE;
+	num_elements_per_pg = CNIC_PAGE_SIZE / BNX2I_RQ_WQE_SIZE;
 	if (hba->max_rqes < num_elements_per_pg)
 		hba->max_rqes = num_elements_per_pg;
 	else if (hba->max_rqes % num_elements_per_pg)
@@ -959,7 +959,7 @@ static void setup_qp_page_tables(struct bnx2i_endpoint *ep)
 
 	/* SQ page table */
 	memset(ep->qp.sq_pgtbl_virt, 0, ep->qp.sq_pgtbl_size);
-	num_pages = ep->qp.sq_mem_size / PAGE_SIZE;
+	num_pages = ep->qp.sq_mem_size / CNIC_PAGE_SIZE;
 	page = ep->qp.sq_phys;
 
 	if (cnic_dev_10g)
@@ -973,7 +973,7 @@ static void setup_qp_page_tables(struct bnx2i_endpoint *ep)
 			ptbl++;
 			*ptbl = (u32) ((u64) page >> 32);
 			ptbl++;
-			page += PAGE_SIZE;
+			page += CNIC_PAGE_SIZE;
 		} else {
 			/* PTE is written in big endian format for
 			 * 5706/5708/5709 devices */
@@ -981,13 +981,13 @@ static void setup_qp_page_tables(struct bnx2i_endpoint *ep)
 			ptbl++;
 			*ptbl = (u32) page;
 			ptbl++;
-			page += PAGE_SIZE;
+			page += CNIC_PAGE_SIZE;
 		}
 	}
 
 	/* RQ page table */
 	memset(ep->qp.rq_pgtbl_virt, 0, ep->qp.rq_pgtbl_size);
-	num_pages = ep->qp.rq_mem_size / PAGE_SIZE;
+	num_pages = ep->qp.rq_mem_size / CNIC_PAGE_SIZE;
 	page = ep->qp.rq_phys;
 
 	if (cnic_dev_10g)
@@ -1001,7 +1001,7 @@ static void setup_qp_page_tables(struct bnx2i_endpoint *ep)
 			ptbl++;
 			*ptbl = (u32) ((u64) page >> 32);
 			ptbl++;
-			page += PAGE_SIZE;
+			page += CNIC_PAGE_SIZE;
 		} else {
 			/* PTE is written in big endian format for
 			 * 5706/5708/5709 devices */
@@ -1009,13 +1009,13 @@ static void setup_qp_page_tables(struct bnx2i_endpoint *ep)
 			ptbl++;
 			*ptbl = (u32) page;
 			ptbl++;
-			page += PAGE_SIZE;
+			page += CNIC_PAGE_SIZE;
 		}
 	}
 
 	/* CQ page table */
 	memset(ep->qp.cq_pgtbl_virt, 0, ep->qp.cq_pgtbl_size);
-	num_pages = ep->qp.cq_mem_size / PAGE_SIZE;
+	num_pages = ep->qp.cq_mem_size / CNIC_PAGE_SIZE;
 	page = ep->qp.cq_phys;
 
 	if (cnic_dev_10g)
@@ -1029,7 +1029,7 @@ static void setup_qp_page_tables(struct bnx2i_endpoint *ep)
 			ptbl++;
 			*ptbl = (u32) ((u64) page >> 32);
 			ptbl++;
-			page += PAGE_SIZE;
+			page += CNIC_PAGE_SIZE;
 		} else {
 			/* PTE is written in big endian format for
 			 * 5706/5708/5709 devices */
@@ -1037,7 +1037,7 @@ static void setup_qp_page_tables(struct bnx2i_endpoint *ep)
 			ptbl++;
 			*ptbl = (u32) page;
 			ptbl++;
-			page += PAGE_SIZE;
+			page += CNIC_PAGE_SIZE;
 		}
 	}
 }
@@ -1064,11 +1064,11 @@ int bnx2i_alloc_qp_resc(struct bnx2i_hba *hba, struct bnx2i_endpoint *ep)
 	/* Allocate page table memory for SQ which is page aligned */
 	ep->qp.sq_mem_size = hba->max_sqes * BNX2I_SQ_WQE_SIZE;
 	ep->qp.sq_mem_size =
-		(ep->qp.sq_mem_size + (PAGE_SIZE - 1)) & PAGE_MASK;
+		(ep->qp.sq_mem_size + (CNIC_PAGE_SIZE - 1)) & CNIC_PAGE_MASK;
 	ep->qp.sq_pgtbl_size =
-		(ep->qp.sq_mem_size / PAGE_SIZE) * sizeof(void *);
+		(ep->qp.sq_mem_size / CNIC_PAGE_SIZE) * sizeof(void *);
 	ep->qp.sq_pgtbl_size =
-		(ep->qp.sq_pgtbl_size + (PAGE_SIZE - 1)) & PAGE_MASK;
+		(ep->qp.sq_pgtbl_size + (CNIC_PAGE_SIZE - 1)) & CNIC_PAGE_MASK;
 
 	ep->qp.sq_pgtbl_virt =
 		dma_alloc_coherent(&hba->pcidev->dev, ep->qp.sq_pgtbl_size,
@@ -1101,11 +1101,11 @@ int bnx2i_alloc_qp_resc(struct bnx2i_hba *hba, struct bnx2i_endpoint *ep)
 	/* Allocate page table memory for CQ which is page aligned */
 	ep->qp.cq_mem_size = hba->max_cqes * BNX2I_CQE_SIZE;
 	ep->qp.cq_mem_size =
-		(ep->qp.cq_mem_size + (PAGE_SIZE - 1)) & PAGE_MASK;
+		(ep->qp.cq_mem_size + (CNIC_PAGE_SIZE - 1)) & CNIC_PAGE_MASK;
 	ep->qp.cq_pgtbl_size =
-		(ep->qp.cq_mem_size / PAGE_SIZE) * sizeof(void *);
+		(ep->qp.cq_mem_size / CNIC_PAGE_SIZE) * sizeof(void *);
 	ep->qp.cq_pgtbl_size =
-		(ep->qp.cq_pgtbl_size + (PAGE_SIZE - 1)) & PAGE_MASK;
+		(ep->qp.cq_pgtbl_size + (CNIC_PAGE_SIZE - 1)) & CNIC_PAGE_MASK;
 
 	ep->qp.cq_pgtbl_virt =
 		dma_alloc_coherent(&hba->pcidev->dev, ep->qp.cq_pgtbl_size,
@@ -1144,11 +1144,11 @@ int bnx2i_alloc_qp_resc(struct bnx2i_hba *hba, struct bnx2i_endpoint *ep)
 	/* Allocate page table memory for RQ which is page aligned */
 	ep->qp.rq_mem_size = hba->max_rqes * BNX2I_RQ_WQE_SIZE;
 	ep->qp.rq_mem_size =
-		(ep->qp.rq_mem_size + (PAGE_SIZE - 1)) & PAGE_MASK;
+		(ep->qp.rq_mem_size + (CNIC_PAGE_SIZE - 1)) & CNIC_PAGE_MASK;
 	ep->qp.rq_pgtbl_size =
-		(ep->qp.rq_mem_size / PAGE_SIZE) * sizeof(void *);
+		(ep->qp.rq_mem_size / CNIC_PAGE_SIZE) * sizeof(void *);
 	ep->qp.rq_pgtbl_size =
-		(ep->qp.rq_pgtbl_size + (PAGE_SIZE - 1)) & PAGE_MASK;
+		(ep->qp.rq_pgtbl_size + (CNIC_PAGE_SIZE - 1)) & CNIC_PAGE_MASK;
 
 	ep->qp.rq_pgtbl_virt =
 		dma_alloc_coherent(&hba->pcidev->dev, ep->qp.rq_pgtbl_size,
@@ -1270,7 +1270,7 @@ int bnx2i_send_fw_iscsi_init_msg(struct bnx2i_hba *hba)
 	bnx2i_adjust_qp_size(hba);
 
 	iscsi_init.flags =
-		ISCSI_PAGE_SIZE_4K << ISCSI_KWQE_INIT1_PAGE_SIZE_SHIFT;
+		(CNIC_PAGE_BITS - 8) << ISCSI_KWQE_INIT1_PAGE_SIZE_SHIFT;
 	if (en_tcp_dack)
 		iscsi_init.flags |= ISCSI_KWQE_INIT1_DELAYED_ACK_ENABLE;
 	iscsi_init.reserved0 = 0;
@@ -1288,15 +1288,15 @@ int bnx2i_send_fw_iscsi_init_msg(struct bnx2i_hba *hba)
 			((hba->num_ccell & 0xFFFF) | (hba->max_sqes << 16));
 	iscsi_init.num_ccells_per_conn = hba->num_ccell;
 	iscsi_init.num_tasks_per_conn = hba->max_sqes;
-	iscsi_init.sq_wqes_per_page = PAGE_SIZE / BNX2I_SQ_WQE_SIZE;
+	iscsi_init.sq_wqes_per_page = CNIC_PAGE_SIZE / BNX2I_SQ_WQE_SIZE;
 	iscsi_init.sq_num_wqes = hba->max_sqes;
 	iscsi_init.cq_log_wqes_per_page =
-		(u8) bnx2i_power_of2(PAGE_SIZE / BNX2I_CQE_SIZE);
+		(u8) bnx2i_power_of2(CNIC_PAGE_SIZE / BNX2I_CQE_SIZE);
 	iscsi_init.cq_num_wqes = hba->max_cqes;
 	iscsi_init.cq_num_pages = (hba->max_cqes * BNX2I_CQE_SIZE +
-				   (PAGE_SIZE - 1)) / PAGE_SIZE;
+				   (CNIC_PAGE_SIZE - 1)) / CNIC_PAGE_SIZE;
 	iscsi_init.sq_num_pages = (hba->max_sqes * BNX2I_SQ_WQE_SIZE +
-				   (PAGE_SIZE - 1)) / PAGE_SIZE;
+				   (CNIC_PAGE_SIZE - 1)) / CNIC_PAGE_SIZE;
 	iscsi_init.rq_buffer_size = BNX2I_RQ_WQE_SIZE;
 	iscsi_init.rq_num_wqes = hba->max_rqes;
 
diff --git a/drivers/scsi/bnx2i/bnx2i_iscsi.c b/drivers/scsi/bnx2i/bnx2i_iscsi.c
index 854dad7..c8b0aff 100644
--- a/drivers/scsi/bnx2i/bnx2i_iscsi.c
+++ b/drivers/scsi/bnx2i/bnx2i_iscsi.c
@@ -525,7 +525,7 @@ static int bnx2i_setup_mp_bdt(struct bnx2i_hba *hba)
 	struct iscsi_bd *mp_bdt;
 	u64 addr;
 
-	hba->mp_bd_tbl = dma_alloc_coherent(&hba->pcidev->dev, PAGE_SIZE,
+	hba->mp_bd_tbl = dma_alloc_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 					    &hba->mp_bd_dma, GFP_KERNEL);
 	if (!hba->mp_bd_tbl) {
 		printk(KERN_ERR "unable to allocate Middle Path BDT\n");
@@ -533,11 +533,12 @@ static int bnx2i_setup_mp_bdt(struct bnx2i_hba *hba)
 		goto out;
 	}
 
-	hba->dummy_buffer = dma_alloc_coherent(&hba->pcidev->dev, PAGE_SIZE,
+	hba->dummy_buffer = dma_alloc_coherent(&hba->pcidev->dev,
+					       CNIC_PAGE_SIZE,
 					       &hba->dummy_buf_dma, GFP_KERNEL);
 	if (!hba->dummy_buffer) {
 		printk(KERN_ERR "unable to alloc Middle Path Dummy Buffer\n");
-		dma_free_coherent(&hba->pcidev->dev, PAGE_SIZE,
+		dma_free_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 				  hba->mp_bd_tbl, hba->mp_bd_dma);
 		hba->mp_bd_tbl = NULL;
 		rc = -1;
@@ -548,7 +549,7 @@ static int bnx2i_setup_mp_bdt(struct bnx2i_hba *hba)
 	addr = (unsigned long) hba->dummy_buf_dma;
 	mp_bdt->buffer_addr_lo = addr & 0xffffffff;
 	mp_bdt->buffer_addr_hi = addr >> 32;
-	mp_bdt->buffer_length = PAGE_SIZE;
+	mp_bdt->buffer_length = CNIC_PAGE_SIZE;
 	mp_bdt->flags = ISCSI_BD_LAST_IN_BD_CHAIN |
 			ISCSI_BD_FIRST_IN_BD_CHAIN;
 out:
@@ -565,12 +566,12 @@ out:
 static void bnx2i_free_mp_bdt(struct bnx2i_hba *hba)
 {
 	if (hba->mp_bd_tbl) {
-		dma_free_coherent(&hba->pcidev->dev, PAGE_SIZE,
+		dma_free_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 				  hba->mp_bd_tbl, hba->mp_bd_dma);
 		hba->mp_bd_tbl = NULL;
 	}
 	if (hba->dummy_buffer) {
-		dma_free_coherent(&hba->pcidev->dev, PAGE_SIZE,
+		dma_free_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 				  hba->dummy_buffer, hba->dummy_buf_dma);
 		hba->dummy_buffer = NULL;
 	}
@@ -934,14 +935,14 @@ static void bnx2i_conn_free_login_resources(struct bnx2i_hba *hba,
 					    struct bnx2i_conn *bnx2i_conn)
 {
 	if (bnx2i_conn->gen_pdu.resp_bd_tbl) {
-		dma_free_coherent(&hba->pcidev->dev, PAGE_SIZE,
+		dma_free_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 				  bnx2i_conn->gen_pdu.resp_bd_tbl,
 				  bnx2i_conn->gen_pdu.resp_bd_dma);
 		bnx2i_conn->gen_pdu.resp_bd_tbl = NULL;
 	}
 
 	if (bnx2i_conn->gen_pdu.req_bd_tbl) {
-		dma_free_coherent(&hba->pcidev->dev, PAGE_SIZE,
+		dma_free_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 				  bnx2i_conn->gen_pdu.req_bd_tbl,
 				  bnx2i_conn->gen_pdu.req_bd_dma);
 		bnx2i_conn->gen_pdu.req_bd_tbl = NULL;
@@ -998,13 +999,13 @@ static int bnx2i_conn_alloc_login_resources(struct bnx2i_hba *hba,
 	bnx2i_conn->gen_pdu.resp_wr_ptr = bnx2i_conn->gen_pdu.resp_buf;
 
 	bnx2i_conn->gen_pdu.req_bd_tbl =
-		dma_alloc_coherent(&hba->pcidev->dev, PAGE_SIZE,
+		dma_alloc_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 				   &bnx2i_conn->gen_pdu.req_bd_dma, GFP_KERNEL);
 	if (bnx2i_conn->gen_pdu.req_bd_tbl == NULL)
 		goto login_req_bd_tbl_failure;
 
 	bnx2i_conn->gen_pdu.resp_bd_tbl =
-		dma_alloc_coherent(&hba->pcidev->dev, PAGE_SIZE,
+		dma_alloc_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 				   &bnx2i_conn->gen_pdu.resp_bd_dma,
 				   GFP_KERNEL);
 	if (bnx2i_conn->gen_pdu.resp_bd_tbl == NULL)
@@ -1013,7 +1014,7 @@ static int bnx2i_conn_alloc_login_resources(struct bnx2i_hba *hba,
 	return 0;
 
 login_resp_bd_tbl_failure:
-	dma_free_coherent(&hba->pcidev->dev, PAGE_SIZE,
+	dma_free_coherent(&hba->pcidev->dev, CNIC_PAGE_SIZE,
 			  bnx2i_conn->gen_pdu.req_bd_tbl,
 			  bnx2i_conn->gen_pdu.req_bd_dma);
 	bnx2i_conn->gen_pdu.req_bd_tbl = NULL;
-- 
1.7.1
