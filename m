From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv6 net-next 11/31] iw_cxgb4: use the BAR2/WC path for kernel QPs and T5 devices
Date: Wed, 12 Mar 2014 21:20:26 +0530
Message-ID: <1394639446-6504-12-git-send-email-hariprasad@chelsio.com>
References: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16882 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755320AbaCLP7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 11:59:30 -0400
In-Reply-To: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/device.c   | 41 +++++++++++++++++-----
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |  2 ++
 drivers/infiniband/hw/cxgb4/qp.c       | 59 +++++++++++++++++++++-----------
 drivers/infiniband/hw/cxgb4/t4.h       | 62 +++++++++++++++++++++++++++++++---
 4 files changed, 132 insertions(+), 32 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index f485849..2cf2a06 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -685,7 +685,10 @@ static void c4iw_dealloc(struct uld_ctx *ctx)
 	idr_destroy(&ctx->dev->hwtid_idr);
 	idr_destroy(&ctx->dev->stid_idr);
 	idr_destroy(&ctx->dev->atid_idr);
-	iounmap(ctx->dev->rdev.oc_mw_kva);
+	if (ctx->dev->rdev.bar2_kva)
+		iounmap(ctx->dev->rdev.bar2_kva);
+	if (ctx->dev->rdev.oc_mw_kva)
+		iounmap(ctx->dev->rdev.oc_mw_kva);
 	ib_dealloc_device(&ctx->dev->ibdev);
 	ctx->dev = NULL;
 }
@@ -725,11 +728,31 @@ static struct c4iw_dev *c4iw_alloc(const struct cxgb4_lld_info *infop)
 	}
 	devp->rdev.lldi = *infop;
 
-	devp->rdev.oc_mw_pa = pci_resource_start(devp->rdev.lldi.pdev, 2) +
-		(pci_resource_len(devp->rdev.lldi.pdev, 2) -
-		 roundup_pow_of_two(devp->rdev.lldi.vr->ocq.size));
-	devp->rdev.oc_mw_kva = ioremap_wc(devp->rdev.oc_mw_pa,
-					       devp->rdev.lldi.vr->ocq.size);
+	/*
+	 * For T5 devices, we map all of BAR2 with WC.
+	 * For T4 devices with onchip qp mem, we map only that part
+	 * of BAR2 with WC.
+	 */
+	devp->rdev.bar2_pa = pci_resource_start(devp->rdev.lldi.pdev, 2);
+	if (is_t5(devp->rdev.lldi.adapter_type)) {
+		devp->rdev.bar2_kva = ioremap_wc(devp->rdev.bar2_pa,
+			pci_resource_len(devp->rdev.lldi.pdev, 2));
+		if (!devp->rdev.bar2_kva) {
+			pr_err(MOD "Unable to ioremap BAR2\n");
+			return ERR_PTR(-EINVAL);
+		}
+	} else if (ocqp_supported(infop)) {
+		devp->rdev.oc_mw_pa =
+			pci_resource_start(devp->rdev.lldi.pdev, 2) +
+			pci_resource_len(devp->rdev.lldi.pdev, 2) -
+			roundup_pow_of_two(devp->rdev.lldi.vr->ocq.size);
+		devp->rdev.oc_mw_kva = ioremap_wc(devp->rdev.oc_mw_pa,
+			devp->rdev.lldi.vr->ocq.size);
+		if (!devp->rdev.oc_mw_kva) {
+			pr_err(MOD "Unable to ioremap onchip mem\n");
+			return ERR_PTR(-EINVAL);
+		}
+	}
 
 	PDBG(KERN_INFO MOD "ocq memory: "
 	       "hw_start 0x%x size %u mw_pa 0x%lx mw_kva %p\n",
@@ -1004,9 +1027,11 @@ static int enable_qp_db(int id, void *p, void *data)
 static void resume_rc_qp(struct c4iw_qp *qp)
 {
 	spin_lock(&qp->lock);
-	t4_ring_sq_db(&qp->wq, qp->wq.sq.wq_pidx_inc);
+	t4_ring_sq_db(&qp->wq, qp->wq.sq.wq_pidx_inc,
+		      is_t5(qp->rhp->rdev.lldi.adapter_type), NULL);
 	qp->wq.sq.wq_pidx_inc = 0;
-	t4_ring_rq_db(&qp->wq, qp->wq.rq.wq_pidx_inc);
+	t4_ring_rq_db(&qp->wq, qp->wq.rq.wq_pidx_inc,
+		      is_t5(qp->rhp->rdev.lldi.adapter_type), NULL);
 	qp->wq.rq.wq_pidx_inc = 0;
 	spin_unlock(&qp->lock);
 }
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index e9ecbfa..c05c875 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -149,6 +149,8 @@ struct c4iw_rdev {
 	struct gen_pool *ocqp_pool;
 	u32 flags;
 	struct cxgb4_lld_info lldi;
+	unsigned long bar2_pa;
+	void __iomem *bar2_kva;
 	unsigned long oc_mw_pa;
 	void __iomem *oc_mw_kva;
 	struct c4iw_stats stats;
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 2b0d994..7aee163 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -46,6 +46,10 @@ static int max_fr_immd = T4_MAX_FR_IMMD;
 module_param(max_fr_immd, int, 0644);
 MODULE_PARM_DESC(max_fr_immd, "fastreg threshold for using DSGL instead of immedate");
 
+int t5_en_wc = 1;
+module_param(t5_en_wc, int, 0644);
+MODULE_PARM_DESC(t5_en_wc, "Use BAR2/WC path for kernel users (default 1)");
+
 static void set_state(struct c4iw_qp *qhp, enum c4iw_qp_state state)
 {
 	unsigned long flag;
@@ -200,13 +204,23 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 
 	wq->db = rdev->lldi.db_reg;
 	wq->gts = rdev->lldi.gts_reg;
-	if (user) {
-		wq->sq.udb = (u64)pci_resource_start(rdev->lldi.pdev, 2) +
-					(wq->sq.qid << rdev->qpshift);
-		wq->sq.udb &= PAGE_MASK;
-		wq->rq.udb = (u64)pci_resource_start(rdev->lldi.pdev, 2) +
-					(wq->rq.qid << rdev->qpshift);
-		wq->rq.udb &= PAGE_MASK;
+	if (user || is_t5(rdev->lldi.adapter_type)) {
+		u32 off;
+
+		off = (wq->sq.qid << rdev->qpshift) & PAGE_MASK;
+		if (user) {
+			wq->sq.udb = (u64 __iomem *)(rdev->bar2_pa + off);
+		} else {
+			off += 128 * (wq->sq.qid & rdev->qpmask) + 8;
+			wq->sq.udb = (u64 __iomem *)(rdev->bar2_kva + off);
+		}
+		off = (wq->rq.qid << rdev->qpshift) & PAGE_MASK;
+		if (user) {
+			wq->rq.udb = (u64 __iomem *)(rdev->bar2_pa + off);
+		} else {
+			off += 128 * (wq->rq.qid & rdev->qpmask) + 8;
+			wq->rq.udb = (u64 __iomem *)(rdev->bar2_kva + off);
+		}
 	}
 	wq->rdev = rdev;
 	wq->rq.msn = 1;
@@ -289,7 +303,8 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 
 	PDBG("%s sqid 0x%x rqid 0x%x kdb 0x%p squdb 0x%llx rqudb 0x%llx\n",
 	     __func__, wq->sq.qid, wq->rq.qid, wq->db,
-	     (unsigned long long)wq->sq.udb, (unsigned long long)wq->rq.udb);
+	     (__force unsigned long long)wq->sq.udb,
+	     (__force unsigned long long)wq->rq.udb);
 
 	return 0;
 free_dma:
@@ -638,9 +653,10 @@ static int ring_kernel_sq_db(struct c4iw_qp *qhp, u16 inc)
 
 	spin_lock_irqsave(&qhp->rhp->lock, flags);
 	spin_lock(&qhp->lock);
-	if (qhp->rhp->db_state == NORMAL) {
-		t4_ring_sq_db(&qhp->wq, inc);
-	} else {
+	if (qhp->rhp->db_state == NORMAL)
+		t4_ring_sq_db(&qhp->wq, inc,
+			      is_t5(qhp->rhp->rdev.lldi.adapter_type), NULL);
+	else {
 		add_to_fc_list(&qhp->rhp->db_fc_list, &qhp->db_fc_entry);
 		qhp->wq.sq.wq_pidx_inc += inc;
 	}
@@ -655,9 +671,10 @@ static int ring_kernel_rq_db(struct c4iw_qp *qhp, u16 inc)
 
 	spin_lock_irqsave(&qhp->rhp->lock, flags);
 	spin_lock(&qhp->lock);
-	if (qhp->rhp->db_state == NORMAL) {
-		t4_ring_rq_db(&qhp->wq, inc);
-	} else {
+	if (qhp->rhp->db_state == NORMAL)
+		t4_ring_rq_db(&qhp->wq, inc,
+			      is_t5(qhp->rhp->rdev.lldi.adapter_type), NULL);
+	else {
 		add_to_fc_list(&qhp->rhp->db_fc_list, &qhp->db_fc_entry);
 		qhp->wq.rq.wq_pidx_inc += inc;
 	}
@@ -674,7 +691,7 @@ int c4iw_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 	enum fw_wr_opcodes fw_opcode = 0;
 	enum fw_ri_wr_flags fw_flags;
 	struct c4iw_qp *qhp;
-	union t4_wr *wqe;
+	union t4_wr *wqe = NULL;
 	u32 num_wrs;
 	struct t4_swsqe *swsqe;
 	unsigned long flag;
@@ -779,7 +796,8 @@ int c4iw_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		idx += DIV_ROUND_UP(len16*16, T4_EQ_ENTRY_SIZE);
 	}
 	if (!qhp->rhp->rdev.status_page->db_off) {
-		t4_ring_sq_db(&qhp->wq, idx);
+		t4_ring_sq_db(&qhp->wq, idx,
+			      is_t5(qhp->rhp->rdev.lldi.adapter_type), wqe);
 		spin_unlock_irqrestore(&qhp->lock, flag);
 	} else {
 		spin_unlock_irqrestore(&qhp->lock, flag);
@@ -793,7 +811,7 @@ int c4iw_post_receive(struct ib_qp *ibqp, struct ib_recv_wr *wr,
 {
 	int err = 0;
 	struct c4iw_qp *qhp;
-	union t4_recv_wr *wqe;
+	union t4_recv_wr *wqe = NULL;
 	u32 num_wrs;
 	u8 len16 = 0;
 	unsigned long flag;
@@ -845,7 +863,8 @@ int c4iw_post_receive(struct ib_qp *ibqp, struct ib_recv_wr *wr,
 		num_wrs--;
 	}
 	if (!qhp->rhp->rdev.status_page->db_off) {
-		t4_ring_rq_db(&qhp->wq, idx);
+		t4_ring_rq_db(&qhp->wq, idx,
+			      is_t5(qhp->rhp->rdev.lldi.adapter_type), wqe);
 		spin_unlock_irqrestore(&qhp->lock, flag);
 	} else {
 		spin_unlock_irqrestore(&qhp->lock, flag);
@@ -1663,11 +1682,11 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 		mm2->len = PAGE_ALIGN(qhp->wq.rq.memsize);
 		insert_mmap(ucontext, mm2);
 		mm3->key = uresp.sq_db_gts_key;
-		mm3->addr = qhp->wq.sq.udb;
+		mm3->addr = (__force u64)qhp->wq.sq.udb;
 		mm3->len = PAGE_SIZE;
 		insert_mmap(ucontext, mm3);
 		mm4->key = uresp.rq_db_gts_key;
-		mm4->addr = qhp->wq.rq.udb;
+		mm4->addr = (__force u64)qhp->wq.rq.udb;
 		mm4->len = PAGE_SIZE;
 		insert_mmap(ucontext, mm4);
 		if (mm5) {
diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index eeca8b1..edab0e9 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -292,7 +292,7 @@ struct t4_sq {
 	unsigned long phys_addr;
 	struct t4_swsqe *sw_sq;
 	struct t4_swsqe *oldest_read;
-	u64 udb;
+	u64 __iomem *udb;
 	size_t memsize;
 	u32 qid;
 	u16 in_use;
@@ -314,7 +314,7 @@ struct t4_rq {
 	dma_addr_t dma_addr;
 	DEFINE_DMA_UNMAP_ADDR(mapping);
 	struct t4_swrqe *sw_rq;
-	u64 udb;
+	u64 __iomem *udb;
 	size_t memsize;
 	u32 qid;
 	u32 msn;
@@ -435,15 +435,69 @@ static inline u16 t4_sq_wq_size(struct t4_wq *wq)
 		return wq->sq.size * T4_SQ_NUM_SLOTS;
 }
 
-static inline void t4_ring_sq_db(struct t4_wq *wq, u16 inc)
+/* This function copies 64 byte coalesced work request to
+ * memory mapped BAR2 space. For coalesced WR SGE fetches
+ * data from the FIFO instead of from Host.
+ */
+static inline void pio_copy(u64 __iomem *dst, u64 *src)
+{
+	int count = 8;
+
+	while (count) {
+		writeq(*src, dst);
+		src++;
+		dst++;
+		count--;
+	}
+}
+extern int t5_en_wc;
+
+static inline void wc_wmb(void)
+{
+#if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
+	asm volatile("sfence" : : : "memory");
+#else
+	wmb()
+#endif
+}
+
+static inline void t4_ring_sq_db(struct t4_wq *wq, u16 inc, u8 t5,
+				 union t4_wr *wqe)
 {
 	wmb();
+	if (t5) {
+		if (t5_en_wc && inc == 1 && wqe) {
+			PDBG("%s: WC wq->sq.pidx = %d\n",
+			     __func__, wq->sq.pidx);
+			pio_copy(wq->sq.udb + 7, (void *)wqe);
+			wc_wmb();
+		} else {
+			PDBG("%s: DB wq->sq.pidx = %d\n",
+			     __func__, wq->sq.pidx);
+			writel(PIDX_T5(inc), wq->sq.udb);
+		}
+		return;
+	}
 	writel(QID(wq->sq.qid) | PIDX(inc), wq->db);
 }
 
-static inline void t4_ring_rq_db(struct t4_wq *wq, u16 inc)
+static inline void t4_ring_rq_db(struct t4_wq *wq, u16 inc, u8 t5,
+				 union t4_recv_wr *wqe)
 {
 	wmb();
+	if (t5) {
+		if (t5_en_wc && inc == 1 && wqe) {
+			PDBG("%s: WC wq->rq.pidx = %d\n",
+			     __func__, wq->rq.pidx);
+			pio_copy(wq->rq.udb + 7, (void *)wqe);
+			wc_wmb();
+		} else {
+			PDBG("%s: DB wq->rq.pidx = %d\n",
+			     __func__, wq->rq.pidx);
+			writel(PIDX_T5(inc), wq->rq.udb);
+		}
+		return;
+	}
 	writel(QID(wq->rq.qid) | PIDX(inc), wq->db);
 }
 
-- 
1.8.4
