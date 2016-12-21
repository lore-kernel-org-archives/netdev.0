From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH for bnxt_re V4 12/21] RDMA/bnxt_re: Support memory registration verbs
Date: Wed, 21 Dec 2016 03:42:01 -0800
Message-ID: <1482320530-5344-13-git-send-email-selvin.xavier@broadcom.com>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f178.google.com ([209.85.210.178]:36539 "EHLO
        mail-wj0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755574AbcLULnf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 06:43:35 -0500
Received: by mail-wj0-f178.google.com with SMTP id tk12so201510069wjb.3
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 03:43:34 -0800 (PST)
In-Reply-To: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the kernel and user memory region registration
supported by the bnxt_re driver.
This includes the user MR, FRMR, FMR and DMA MR support.

v3: Moves bnxt_qplib_map_tc2cos to DCB patch as the functionality is used
    by DCB patch. Also, removed some unwanted macros.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxt_re/ib_verbs.c | 376 +++++++++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/ib_verbs.h |  44 ++++
 drivers/infiniband/hw/bnxt_re/main.c     |  11 +
 drivers/infiniband/hw/bnxt_re/qplib_sp.c | 289 ++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/qplib_sp.h |  41 ++++
 5 files changed, 761 insertions(+)

diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.c b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
index 4f14cd6..8af6436 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.c
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
@@ -639,6 +639,48 @@ int bnxt_re_query_ah(struct ib_ah *ib_ah, struct ib_ah_attr *ah_attr)
 	return 0;
 }
 
+static int __from_ib_access_flags(int iflags)
+{
+	int qflags = 0;
+
+	if (iflags & IB_ACCESS_LOCAL_WRITE)
+		qflags |= BNXT_QPLIB_ACCESS_LOCAL_WRITE;
+	if (iflags & IB_ACCESS_REMOTE_READ)
+		qflags |= BNXT_QPLIB_ACCESS_REMOTE_READ;
+	if (iflags & IB_ACCESS_REMOTE_WRITE)
+		qflags |= BNXT_QPLIB_ACCESS_REMOTE_WRITE;
+	if (iflags & IB_ACCESS_REMOTE_ATOMIC)
+		qflags |= BNXT_QPLIB_ACCESS_REMOTE_ATOMIC;
+	if (iflags & IB_ACCESS_MW_BIND)
+		qflags |= BNXT_QPLIB_ACCESS_MW_BIND;
+	if (iflags & IB_ZERO_BASED)
+		qflags |= BNXT_QPLIB_ACCESS_ZERO_BASED;
+	if (iflags & IB_ACCESS_ON_DEMAND)
+		qflags |= BNXT_QPLIB_ACCESS_ON_DEMAND;
+	return qflags;
+};
+
+static enum ib_access_flags __to_ib_access_flags(int qflags)
+{
+	enum ib_access_flags iflags = 0;
+
+	if (qflags & BNXT_QPLIB_ACCESS_LOCAL_WRITE)
+		iflags |= IB_ACCESS_LOCAL_WRITE;
+	if (qflags & BNXT_QPLIB_ACCESS_REMOTE_WRITE)
+		iflags |= IB_ACCESS_REMOTE_WRITE;
+	if (qflags & BNXT_QPLIB_ACCESS_REMOTE_READ)
+		iflags |= IB_ACCESS_REMOTE_READ;
+	if (qflags & BNXT_QPLIB_ACCESS_REMOTE_ATOMIC)
+		iflags |= IB_ACCESS_REMOTE_ATOMIC;
+	if (qflags & BNXT_QPLIB_ACCESS_MW_BIND)
+		iflags |= IB_ACCESS_MW_BIND;
+	if (qflags & BNXT_QPLIB_ACCESS_ZERO_BASED)
+		iflags |= IB_ZERO_BASED;
+	if (qflags & BNXT_QPLIB_ACCESS_ON_DEMAND)
+		iflags |= IB_ACCESS_ON_DEMAND;
+	return iflags;
+};
+
 /* Completion Queues */
 int bnxt_re_destroy_cq(struct ib_cq *ib_cq)
 {
@@ -785,6 +827,340 @@ int bnxt_re_req_notify_cq(struct ib_cq *ib_cq,
 	return 0;
 }
 
+/* Memory Regions */
+struct ib_mr *bnxt_re_get_dma_mr(struct ib_pd *ib_pd, int mr_access_flags)
+{
+	struct bnxt_re_pd *pd = container_of(ib_pd, struct bnxt_re_pd, ib_pd);
+	struct bnxt_re_dev *rdev = pd->rdev;
+	struct bnxt_re_mr *mr;
+	u64 pbl = 0;
+	int rc;
+
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
+	if (!mr)
+		return ERR_PTR(-ENOMEM);
+
+	mr->rdev = rdev;
+	mr->qplib_mr.pd = &pd->qplib_pd;
+	mr->qplib_mr.flags = __from_ib_access_flags(mr_access_flags);
+	mr->qplib_mr.type = CMDQ_ALLOCATE_MRW_MRW_FLAGS_PMR;
+
+	/* Allocate and register 0 as the address */
+	rc = bnxt_qplib_alloc_mrw(&rdev->qplib_res, &mr->qplib_mr);
+	if (rc)
+		goto fail;
+
+	mr->qplib_mr.hwq.level = PBL_LVL_MAX;
+	mr->qplib_mr.total_size = -1; /* Infinte length */
+	rc = bnxt_qplib_reg_mr(&rdev->qplib_res, &mr->qplib_mr, &pbl, 0, false);
+	if (rc)
+		goto fail_mr;
+
+	mr->ib_mr.lkey = mr->qplib_mr.lkey;
+	if (mr_access_flags & (IB_ACCESS_REMOTE_WRITE | IB_ACCESS_REMOTE_READ |
+			       IB_ACCESS_REMOTE_ATOMIC))
+		mr->ib_mr.rkey = mr->ib_mr.lkey;
+	atomic_inc(&rdev->mr_count);
+
+	return &mr->ib_mr;
+
+fail_mr:
+	bnxt_qplib_free_mrw(&rdev->qplib_res, &mr->qplib_mr);
+fail:
+	kfree(mr);
+	return ERR_PTR(rc);
+}
+
+int bnxt_re_dereg_mr(struct ib_mr *ib_mr)
+{
+	struct bnxt_re_mr *mr = container_of(ib_mr, struct bnxt_re_mr, ib_mr);
+	struct bnxt_re_dev *rdev = mr->rdev;
+	int rc = 0;
+
+	if (mr->npages && mr->pages) {
+		rc = bnxt_qplib_free_fast_reg_page_list(&rdev->qplib_res,
+							&mr->qplib_frpl);
+		kfree(mr->pages);
+		mr->npages = 0;
+		mr->pages = NULL;
+	}
+	rc = bnxt_qplib_free_mrw(&rdev->qplib_res, &mr->qplib_mr);
+
+	if (!IS_ERR(mr->ib_umem) && mr->ib_umem)
+		ib_umem_release(mr->ib_umem);
+
+	kfree(mr);
+	atomic_dec(&rdev->mr_count);
+	return rc;
+}
+
+static int bnxt_re_set_page(struct ib_mr *ib_mr, u64 addr)
+{
+	struct bnxt_re_mr *mr = container_of(ib_mr, struct bnxt_re_mr, ib_mr);
+
+	if (unlikely(mr->npages == mr->qplib_frpl.max_pg_ptrs))
+		return -ENOMEM;
+
+	mr->pages[mr->npages++] = addr;
+	return 0;
+}
+
+int bnxt_re_map_mr_sg(struct ib_mr *ib_mr, struct scatterlist *sg, int sg_nents,
+		      unsigned int *sg_offset)
+{
+	struct bnxt_re_mr *mr = container_of(ib_mr, struct bnxt_re_mr, ib_mr);
+
+	mr->npages = 0;
+	return ib_sg_to_pages(ib_mr, sg, sg_nents, sg_offset, bnxt_re_set_page);
+}
+
+struct ib_mr *bnxt_re_alloc_mr(struct ib_pd *ib_pd, enum ib_mr_type type,
+			       u32 max_num_sg)
+{
+	struct bnxt_re_pd *pd = container_of(ib_pd, struct bnxt_re_pd, ib_pd);
+	struct bnxt_re_dev *rdev = pd->rdev;
+	struct bnxt_re_mr *mr = NULL;
+	int rc;
+
+	if (type != IB_MR_TYPE_MEM_REG) {
+		dev_dbg(rdev_to_dev(rdev), "MR type 0x%x not supported", type);
+		return ERR_PTR(-EINVAL);
+	}
+	if (max_num_sg > MAX_PBL_LVL_1_PGS)
+		return ERR_PTR(-EINVAL);
+
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
+	if (!mr)
+		return ERR_PTR(-ENOMEM);
+
+	mr->rdev = rdev;
+	mr->qplib_mr.pd = &pd->qplib_pd;
+	mr->qplib_mr.flags = BNXT_QPLIB_FR_PMR;
+	mr->qplib_mr.type = CMDQ_ALLOCATE_MRW_MRW_FLAGS_PMR;
+
+	rc = bnxt_qplib_alloc_mrw(&rdev->qplib_res, &mr->qplib_mr);
+	if (rc)
+		goto fail;
+
+	mr->ib_mr.lkey = mr->qplib_mr.lkey;
+	mr->ib_mr.rkey = mr->ib_mr.lkey;
+
+	mr->pages = kcalloc(max_num_sg, sizeof(u64), GFP_KERNEL);
+	if (!mr->pages) {
+		rc = -ENOMEM;
+		goto fail;
+	}
+	rc = bnxt_qplib_alloc_fast_reg_page_list(&rdev->qplib_res,
+						 &mr->qplib_frpl, max_num_sg);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev),
+			"Failed to allocate HW FR page list");
+		goto fail_mr;
+	}
+
+	atomic_inc(&rdev->mr_count);
+	return &mr->ib_mr;
+
+fail_mr:
+	bnxt_qplib_free_mrw(&rdev->qplib_res, &mr->qplib_mr);
+fail:
+	kfree(mr->pages);
+	kfree(mr);
+	return ERR_PTR(rc);
+}
+
+/* Fast Memory Regions */
+struct ib_fmr *bnxt_re_alloc_fmr(struct ib_pd *ib_pd, int mr_access_flags,
+				 struct ib_fmr_attr *fmr_attr)
+{
+	struct bnxt_re_pd *pd = container_of(ib_pd, struct bnxt_re_pd, ib_pd);
+	struct bnxt_re_dev *rdev = pd->rdev;
+	struct bnxt_re_fmr *fmr;
+	int rc;
+
+	if (fmr_attr->max_pages > MAX_PBL_LVL_2_PGS ||
+	    fmr_attr->max_maps > rdev->dev_attr.max_map_per_fmr) {
+		dev_err(rdev_to_dev(rdev), "Allocate FMR exceeded Max limit");
+		return ERR_PTR(-ENOMEM);
+	}
+	fmr = kzalloc(sizeof(*fmr), GFP_KERNEL);
+	if (!fmr)
+		return ERR_PTR(-ENOMEM);
+
+	fmr->rdev = rdev;
+	fmr->qplib_fmr.pd = &pd->qplib_pd;
+	fmr->qplib_fmr.type = CMDQ_ALLOCATE_MRW_MRW_FLAGS_PMR;
+
+	rc = bnxt_qplib_alloc_mrw(&rdev->qplib_res, &fmr->qplib_fmr);
+	if (rc)
+		goto fail;
+
+	fmr->qplib_fmr.flags = __from_ib_access_flags(mr_access_flags);
+	fmr->ib_fmr.lkey = fmr->qplib_fmr.lkey;
+	fmr->ib_fmr.rkey = fmr->ib_fmr.lkey;
+
+	atomic_inc(&rdev->mr_count);
+	return &fmr->ib_fmr;
+fail:
+	kfree(fmr);
+	return ERR_PTR(rc);
+}
+
+int bnxt_re_map_phys_fmr(struct ib_fmr *ib_fmr, u64 *page_list, int list_len,
+			 u64 iova)
+{
+	struct bnxt_re_fmr *fmr = container_of(ib_fmr, struct bnxt_re_fmr,
+					     ib_fmr);
+	struct bnxt_re_dev *rdev = fmr->rdev;
+	int rc;
+
+	fmr->qplib_fmr.va = iova;
+	fmr->qplib_fmr.total_size = list_len * PAGE_SIZE;
+
+	rc = bnxt_qplib_reg_mr(&rdev->qplib_res, &fmr->qplib_fmr, page_list,
+			       list_len, true);
+	if (rc)
+		dev_err(rdev_to_dev(rdev), "Failed to map FMR for lkey = 0x%x!",
+			fmr->ib_fmr.lkey);
+	return rc;
+}
+
+int bnxt_re_unmap_fmr(struct list_head *fmr_list)
+{
+	struct bnxt_re_dev *rdev;
+	struct bnxt_re_fmr *fmr;
+	struct ib_fmr *ib_fmr;
+	int rc = 0;
+
+	/* Validate each FMRs inside the fmr_list */
+	list_for_each_entry(ib_fmr, fmr_list, list) {
+		fmr = container_of(ib_fmr, struct bnxt_re_fmr, ib_fmr);
+		rdev = fmr->rdev;
+
+		if (rdev) {
+			rc = bnxt_qplib_dereg_mrw(&rdev->qplib_res,
+						  &fmr->qplib_fmr, true);
+			if (rc)
+				break;
+		}
+	}
+	return rc;
+}
+
+int bnxt_re_dealloc_fmr(struct ib_fmr *ib_fmr)
+{
+	struct bnxt_re_fmr *fmr = container_of(ib_fmr, struct bnxt_re_fmr,
+					       ib_fmr);
+	struct bnxt_re_dev *rdev = fmr->rdev;
+	int rc;
+
+	rc = bnxt_qplib_free_mrw(&rdev->qplib_res, &fmr->qplib_fmr);
+	if (rc)
+		dev_err(rdev_to_dev(rdev), "Failed to free FMR");
+
+	kfree(fmr);
+	atomic_dec(&rdev->mr_count);
+	return rc;
+}
+
+/* uverbs */
+struct ib_mr *bnxt_re_reg_user_mr(struct ib_pd *ib_pd, u64 start, u64 length,
+				  u64 virt_addr, int mr_access_flags,
+				  struct ib_udata *udata)
+{
+	struct bnxt_re_pd *pd = container_of(ib_pd, struct bnxt_re_pd, ib_pd);
+	struct bnxt_re_dev *rdev = pd->rdev;
+	struct bnxt_re_mr *mr;
+	struct ib_umem *umem;
+	u64 *pbl_tbl, *pbl_tbl_orig;
+	int i, umem_pgs, pages, page_shift, rc;
+	struct scatterlist *sg;
+	int entry;
+
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
+	if (!mr)
+		return ERR_PTR(-ENOMEM);
+
+	mr->rdev = rdev;
+	mr->qplib_mr.pd = &pd->qplib_pd;
+	mr->qplib_mr.flags = __from_ib_access_flags(mr_access_flags);
+	mr->qplib_mr.type = CMDQ_ALLOCATE_MRW_MRW_FLAGS_MR;
+
+	umem = ib_umem_get(ib_pd->uobject->context, start, length,
+			   mr_access_flags, 0);
+	if (IS_ERR(umem)) {
+		dev_err(rdev_to_dev(rdev), "Failed to get umem");
+		rc = -EFAULT;
+		goto free_mr;
+	}
+	mr->ib_umem = umem;
+
+	rc = bnxt_qplib_alloc_mrw(&rdev->qplib_res, &mr->qplib_mr);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev), "Failed to allocate MR");
+		goto release_umem;
+	}
+	/* The fixed portion of the rkey is the same as the lkey */
+	mr->ib_mr.rkey = mr->qplib_mr.rkey;
+
+	mr->qplib_mr.va = virt_addr;
+	umem_pgs = ib_umem_page_count(umem);
+	if (!umem_pgs) {
+		dev_err(rdev_to_dev(rdev), "umem is invalid!");
+		rc = -EINVAL;
+		goto free_mrw;
+	}
+	mr->qplib_mr.total_size = length;
+
+	pbl_tbl = kcalloc(umem_pgs, sizeof(u64 *), GFP_KERNEL);
+	if (!pbl_tbl) {
+		rc = -EINVAL;
+		goto free_mrw;
+	}
+	pbl_tbl_orig = pbl_tbl;
+
+	page_shift = ilog2(umem->page_size);
+	if (umem->hugetlb) {
+		dev_err(rdev_to_dev(rdev), "umem hugetlb not supported!");
+		rc = -EFAULT;
+		goto fail;
+	}
+	if (umem->page_size != PAGE_SIZE) {
+		dev_err(rdev_to_dev(rdev), "umem page size unsupported!");
+		rc = -EFAULT;
+		goto fail;
+	}
+	/* Map umem buf ptrs to the PBL */
+	for_each_sg(umem->sg_head.sgl, sg, umem->nmap, entry) {
+		pages = sg_dma_len(sg) >> page_shift;
+		for (i = 0; i < pages; i++, pbl_tbl++)
+			*pbl_tbl = sg_dma_address(sg) + (i << page_shift);
+	}
+	rc = bnxt_qplib_reg_mr(&rdev->qplib_res, &mr->qplib_mr, pbl_tbl_orig,
+			       umem_pgs, false);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev), "Failed to register user MR");
+		goto fail;
+	}
+
+	kfree(pbl_tbl_orig);
+
+	mr->ib_mr.lkey = mr->qplib_mr.lkey;
+	mr->ib_mr.rkey = mr->qplib_mr.lkey;
+	atomic_inc(&rdev->mr_count);
+
+	return &mr->ib_mr;
+fail:
+	kfree(pbl_tbl_orig);
+free_mrw:
+	bnxt_qplib_free_mrw(&rdev->qplib_res, &mr->qplib_mr);
+release_umem:
+	ib_umem_release(umem);
+free_mr:
+	kfree(mr);
+	return ERR_PTR(rc);
+}
+
 struct ib_ucontext *bnxt_re_alloc_ucontext(struct ib_device *ibdev,
 					   struct ib_udata *udata)
 {
diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.h b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
index 14c9e02..ba9a4c9 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.h
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
@@ -70,6 +70,34 @@ struct bnxt_re_cq {
 	struct ib_umem		*umem;
 };
 
+struct bnxt_re_mr {
+	struct bnxt_re_dev	*rdev;
+	struct ib_mr		ib_mr;
+	struct ib_umem		*ib_umem;
+	struct bnxt_qplib_mrw	qplib_mr;
+	u32			npages;
+	u64			*pages;
+	struct bnxt_qplib_frpl	qplib_frpl;
+};
+
+struct bnxt_re_frpl {
+	struct bnxt_re_dev		*rdev;
+	struct bnxt_qplib_frpl		qplib_frpl;
+	u64				*page_list;
+};
+
+struct bnxt_re_fmr {
+	struct bnxt_re_dev	*rdev;
+	struct ib_fmr		ib_fmr;
+	struct bnxt_qplib_mrw	qplib_fmr;
+};
+
+struct bnxt_re_mw {
+	struct bnxt_re_dev	*rdev;
+	struct ib_mw		ib_mw;
+	struct bnxt_qplib_mrw	qplib_mw;
+};
+
 struct bnxt_re_ucontext {
 	struct bnxt_re_dev	*rdev;
 	struct ib_ucontext	ib_uctx;
@@ -119,6 +147,22 @@ struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
 				struct ib_udata *udata);
 int bnxt_re_destroy_cq(struct ib_cq *cq);
 int bnxt_re_req_notify_cq(struct ib_cq *cq, enum ib_cq_notify_flags flags);
+struct ib_mr *bnxt_re_get_dma_mr(struct ib_pd *pd, int mr_access_flags);
+
+int bnxt_re_map_mr_sg(struct ib_mr *ib_mr, struct scatterlist *sg, int sg_nents,
+		      unsigned int *sg_offset);
+struct ib_mr *bnxt_re_alloc_mr(struct ib_pd *ib_pd, enum ib_mr_type mr_type,
+			       u32 max_num_sg);
+int bnxt_re_dereg_mr(struct ib_mr *mr);
+struct ib_fmr *bnxt_re_alloc_fmr(struct ib_pd *pd, int mr_access_flags,
+				 struct ib_fmr_attr *fmr_attr);
+int bnxt_re_map_phys_fmr(struct ib_fmr *fmr, u64 *page_list, int list_len,
+			 u64 iova);
+int bnxt_re_unmap_fmr(struct list_head *fmr_list);
+int bnxt_re_dealloc_fmr(struct ib_fmr *fmr);
+struct ib_mr *bnxt_re_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
+				  u64 virt_addr, int mr_access_flags,
+				  struct ib_udata *udata);
 struct ib_ucontext *bnxt_re_alloc_ucontext(struct ib_device *ibdev,
 					   struct ib_udata *udata);
 int bnxt_re_dealloc_ucontext(struct ib_ucontext *context);
diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index 31dc3f1..70b07ac 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -459,6 +459,17 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 	ibdev->create_cq		= bnxt_re_create_cq;
 	ibdev->destroy_cq		= bnxt_re_destroy_cq;
 	ibdev->req_notify_cq		= bnxt_re_req_notify_cq;
+
+	ibdev->get_dma_mr		= bnxt_re_get_dma_mr;
+	ibdev->dereg_mr			= bnxt_re_dereg_mr;
+	ibdev->alloc_mr			= bnxt_re_alloc_mr;
+	ibdev->map_mr_sg		= bnxt_re_map_mr_sg;
+	ibdev->alloc_fmr		= bnxt_re_alloc_fmr;
+	ibdev->map_phys_fmr		= bnxt_re_map_phys_fmr;
+	ibdev->unmap_fmr		= bnxt_re_unmap_fmr;
+	ibdev->dealloc_fmr		= bnxt_re_dealloc_fmr;
+
+	ibdev->reg_user_mr		= bnxt_re_reg_user_mr;
 	ibdev->alloc_ucontext		= bnxt_re_alloc_ucontext;
 	ibdev->dealloc_ucontext		= bnxt_re_dealloc_ucontext;
 	ibdev->mmap			= bnxt_re_mmap;
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_sp.c b/drivers/infiniband/hw/bnxt_re/qplib_sp.c
index 2fb43c1..8a6f43f 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_sp.c
+++ b/drivers/infiniband/hw/bnxt_re/qplib_sp.c
@@ -510,3 +510,292 @@ int bnxt_qplib_destroy_ah(struct bnxt_qplib_res *res, struct bnxt_qplib_ah *ah)
 	}
 	return 0;
 }
+
+/* MRW */
+int bnxt_qplib_free_mrw(struct bnxt_qplib_res *res, struct bnxt_qplib_mrw *mrw)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_deallocate_key req;
+	struct creq_deallocate_key_resp *resp;
+	u16 cmd_flags = 0;
+
+	if (mrw->lkey == 0xFFFFFFFF) {
+		dev_info(&res->pdev->dev,
+			 "QPLIB: SP: Free a reserved lkey MRW");
+		return 0;
+	}
+
+	RCFW_CMD_PREP(req, DEALLOCATE_KEY, cmd_flags);
+
+	req.mrw_flags = mrw->type;
+
+	if ((mrw->type == CMDQ_ALLOCATE_MRW_MRW_FLAGS_MW_TYPE1)  ||
+	    (mrw->type == CMDQ_ALLOCATE_MRW_MRW_FLAGS_MW_TYPE2A) ||
+	    (mrw->type == CMDQ_ALLOCATE_MRW_MRW_FLAGS_MW_TYPE2B))
+		req.key = cpu_to_le32(mrw->rkey);
+	else
+		req.key = cpu_to_le32(mrw->lkey);
+
+	resp = (struct creq_deallocate_key_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 0);
+	if (!resp) {
+		dev_err(&res->pdev->dev, "QPLIB: SP: FREE_MR send failed");
+		return -EINVAL;
+	}
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&res->pdev->dev, "QPLIB: SP: FREE_MR timed out");
+		return -ETIMEDOUT;
+	}
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&res->pdev->dev, "QPLIB: SP: FREE_MR failed ");
+		dev_err(&res->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		return -EINVAL;
+	}
+	/* Free the qplib's MRW memory */
+	if (mrw->hwq.max_elements)
+		bnxt_qplib_free_hwq(res->pdev, &mrw->hwq);
+
+	return 0;
+}
+
+int bnxt_qplib_alloc_mrw(struct bnxt_qplib_res *res, struct bnxt_qplib_mrw *mrw)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_allocate_mrw req;
+	struct creq_allocate_mrw_resp *resp;
+	u16 cmd_flags = 0;
+	unsigned long tmp;
+
+	RCFW_CMD_PREP(req, ALLOCATE_MRW, cmd_flags);
+
+	req.pd_id = cpu_to_le32(mrw->pd->id);
+	req.mrw_flags = mrw->type;
+	if ((mrw->type == CMDQ_ALLOCATE_MRW_MRW_FLAGS_PMR &&
+	     mrw->flags & BNXT_QPLIB_FR_PMR) ||
+	    mrw->type == CMDQ_ALLOCATE_MRW_MRW_FLAGS_MW_TYPE2A ||
+	    mrw->type == CMDQ_ALLOCATE_MRW_MRW_FLAGS_MW_TYPE2B)
+		req.access = CMDQ_ALLOCATE_MRW_ACCESS_CONSUMER_OWNED_KEY;
+	tmp = (unsigned long)mrw;
+	req.mrw_handle = cpu_to_le64(tmp);
+
+	resp = (struct creq_allocate_mrw_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 0);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: ALLOC_MRW send failed");
+		return -EINVAL;
+	}
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: ALLOC_MRW timed out");
+		return -ETIMEDOUT;
+	}
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: ALLOC_MRW failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		return -EINVAL;
+	}
+	if ((mrw->type == CMDQ_ALLOCATE_MRW_MRW_FLAGS_MW_TYPE1)  ||
+	    (mrw->type == CMDQ_ALLOCATE_MRW_MRW_FLAGS_MW_TYPE2A) ||
+	    (mrw->type == CMDQ_ALLOCATE_MRW_MRW_FLAGS_MW_TYPE2B))
+		mrw->rkey = le32_to_cpu(resp->xid);
+	else
+		mrw->lkey = le32_to_cpu(resp->xid);
+	return 0;
+}
+
+int bnxt_qplib_dereg_mrw(struct bnxt_qplib_res *res, struct bnxt_qplib_mrw *mrw,
+			 bool block)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_deregister_mr req;
+	struct creq_deregister_mr_resp *resp;
+	u16 cmd_flags = 0;
+	int rc;
+
+	RCFW_CMD_PREP(req, DEREGISTER_MR, cmd_flags);
+
+	req.lkey = cpu_to_le32(mrw->lkey);
+	resp = (struct creq_deregister_mr_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, block);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: DEREG_MR send failed");
+		return -EINVAL;
+	}
+	if (block)
+		rc = bnxt_qplib_rcfw_block_for_resp(rcfw,
+						    le16_to_cpu(req.cookie));
+	else
+		rc = bnxt_qplib_rcfw_wait_for_resp(rcfw,
+						   le16_to_cpu(req.cookie));
+	if (!rc) {
+		/* Cmd timed out */
+		dev_err(&res->pdev->dev, "QPLIB: SP: DEREG_MR timed out");
+		return -ETIMEDOUT;
+	}
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: SP: DEREG_MR failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		return -EINVAL;
+	}
+
+	/* Free the qplib's MR memory */
+	if (mrw->hwq.max_elements) {
+		mrw->va = 0;
+		mrw->total_size = 0;
+		bnxt_qplib_free_hwq(res->pdev, &mrw->hwq);
+	}
+
+	return 0;
+}
+
+int bnxt_qplib_reg_mr(struct bnxt_qplib_res *res, struct bnxt_qplib_mrw *mr,
+		      u64 *pbl_tbl, int num_pbls, bool block)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_register_mr req;
+	struct creq_register_mr_resp *resp;
+	u16 cmd_flags = 0, level;
+	int pg_ptrs, pages, i, rc;
+	dma_addr_t **pbl_ptr;
+	u32 pg_size;
+
+	if (num_pbls) {
+		pg_ptrs = roundup_pow_of_two(num_pbls);
+		pages = pg_ptrs >> MAX_PBL_LVL_1_PGS_SHIFT;
+		if (!pages)
+			pages++;
+
+		if (pages > MAX_PBL_LVL_1_PGS) {
+			dev_err(&res->pdev->dev, "QPLIB: SP: Reg MR pages ");
+			dev_err(&res->pdev->dev,
+				"requested (0x%x) exceeded max (0x%x)",
+				pages, MAX_PBL_LVL_1_PGS);
+			return -ENOMEM;
+		}
+		/* Free the hwq if it already exist, must be a rereg */
+		if (mr->hwq.max_elements)
+			bnxt_qplib_free_hwq(res->pdev, &mr->hwq);
+
+		mr->hwq.max_elements = pages;
+		rc = bnxt_qplib_alloc_init_hwq(res->pdev, &mr->hwq, NULL, 0,
+					       &mr->hwq.max_elements,
+					       PAGE_SIZE, 0, PAGE_SIZE,
+					       HWQ_TYPE_CTX);
+		if (rc) {
+			dev_err(&res->pdev->dev,
+				"SP: Reg MR memory allocation failed");
+			return -ENOMEM;
+		}
+		/* Write to the hwq */
+		pbl_ptr = (dma_addr_t **)mr->hwq.pbl_ptr;
+		for (i = 0; i < num_pbls; i++)
+			pbl_ptr[PTR_PG(i)][PTR_IDX(i)] =
+				(pbl_tbl[i] & PAGE_MASK) | PTU_PTE_VALID;
+	}
+
+	RCFW_CMD_PREP(req, REGISTER_MR, cmd_flags);
+
+	/* Configure the request */
+	if (mr->hwq.level == PBL_LVL_MAX) {
+		level = 0;
+		req.pbl = 0;
+		pg_size = PAGE_SIZE;
+	} else {
+		level = mr->hwq.level + 1;
+		req.pbl = cpu_to_le64(mr->hwq.pbl[PBL_LVL_0].pg_map_arr[0]);
+		pg_size = mr->hwq.pbl[PBL_LVL_0].pg_size;
+	}
+	req.log2_pg_size_lvl = (level << CMDQ_REGISTER_MR_LVL_SFT) |
+			       ((ilog2(pg_size) <<
+				 CMDQ_REGISTER_MR_LOG2_PG_SIZE_SFT) &
+				CMDQ_REGISTER_MR_LOG2_PG_SIZE_MASK);
+	req.access = (mr->flags & 0xFFFF);
+	req.va = cpu_to_le64(mr->va);
+	req.key = cpu_to_le32(mr->lkey);
+	req.mr_size = cpu_to_le64(mr->total_size);
+
+	resp = (struct creq_register_mr_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, block);
+	if (!resp) {
+		dev_err(&res->pdev->dev, "SP: REG_MR send failed");
+		rc = -EINVAL;
+		goto fail;
+	}
+	if (block)
+		rc = bnxt_qplib_rcfw_block_for_resp(rcfw,
+						    le16_to_cpu(req.cookie));
+	else
+		rc = bnxt_qplib_rcfw_wait_for_resp(rcfw,
+						   le16_to_cpu(req.cookie));
+	if (!rc) {
+		/* Cmd timed out */
+		dev_err(&res->pdev->dev, "SP: REG_MR timed out");
+		rc = -ETIMEDOUT;
+		goto fail;
+	}
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&res->pdev->dev, "QPLIB: SP: REG_MR failed ");
+		dev_err(&res->pdev->dev,
+			"QPLIB: SP: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		rc = -EINVAL;
+		goto fail;
+	}
+	return 0;
+
+fail:
+	if (mr->hwq.max_elements)
+		bnxt_qplib_free_hwq(res->pdev, &mr->hwq);
+	return rc;
+}
+
+int bnxt_qplib_alloc_fast_reg_page_list(struct bnxt_qplib_res *res,
+					struct bnxt_qplib_frpl *frpl,
+					int max_pg_ptrs)
+{
+	int pg_ptrs, pages, rc;
+
+	/* Re-calculate the max to fit the HWQ allocation model */
+	pg_ptrs = roundup_pow_of_two(max_pg_ptrs);
+	pages = pg_ptrs >> MAX_PBL_LVL_1_PGS_SHIFT;
+	if (!pages)
+		pages++;
+
+	if (pages > MAX_PBL_LVL_1_PGS)
+		return -ENOMEM;
+
+	frpl->hwq.max_elements = pages;
+	rc = bnxt_qplib_alloc_init_hwq(res->pdev, &frpl->hwq, NULL, 0,
+				       &frpl->hwq.max_elements, PAGE_SIZE, 0,
+				       PAGE_SIZE, HWQ_TYPE_CTX);
+	if (!rc)
+		frpl->max_pg_ptrs = pg_ptrs;
+
+	return rc;
+}
+
+int bnxt_qplib_free_fast_reg_page_list(struct bnxt_qplib_res *res,
+				       struct bnxt_qplib_frpl *frpl)
+{
+	bnxt_qplib_free_hwq(res->pdev, &frpl->hwq);
+	return 0;
+}
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_sp.h b/drivers/infiniband/hw/bnxt_re/qplib_sp.h
index 26eac17..3358f6d 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_sp.h
+++ b/drivers/infiniband/hw/bnxt_re/qplib_sp.h
@@ -94,6 +94,34 @@ struct bnxt_qplib_ah {
 	u8				nw_type;
 };
 
+struct bnxt_qplib_mrw {
+	struct bnxt_qplib_pd		*pd;
+	int				type;
+	u32				flags;
+#define BNXT_QPLIB_FR_PMR		0x80000000
+	u32				lkey;
+	u32				rkey;
+#define BNXT_QPLIB_RSVD_LKEY		0xFFFFFFFF
+	u64				va;
+	u64				total_size;
+	u32				npages;
+	u64				mr_handle;
+	struct bnxt_qplib_hwq		hwq;
+};
+
+struct bnxt_qplib_frpl {
+	int				max_pg_ptrs;
+	struct bnxt_qplib_hwq		hwq;
+};
+
+#define BNXT_QPLIB_ACCESS_LOCAL_WRITE	BIT(0)
+#define BNXT_QPLIB_ACCESS_REMOTE_READ	BIT(1)
+#define BNXT_QPLIB_ACCESS_REMOTE_WRITE	BIT(2)
+#define BNXT_QPLIB_ACCESS_REMOTE_ATOMIC	BIT(3)
+#define BNXT_QPLIB_ACCESS_MW_BIND	BIT(4)
+#define BNXT_QPLIB_ACCESS_ZERO_BASED	BIT(5)
+#define BNXT_QPLIB_ACCESS_ON_DEMAND	BIT(6)
+
 int bnxt_qplib_get_sgid(struct bnxt_qplib_res *res,
 			struct bnxt_qplib_sgid_tbl *sgid_tbl, int index,
 			struct bnxt_qplib_gid *gid);
@@ -115,4 +143,17 @@ int bnxt_qplib_get_dev_attr(struct bnxt_qplib_rcfw *rcfw,
 			    struct bnxt_qplib_dev_attr *attr);
 int bnxt_qplib_create_ah(struct bnxt_qplib_res *res, struct bnxt_qplib_ah *ah);
 int bnxt_qplib_destroy_ah(struct bnxt_qplib_res *res, struct bnxt_qplib_ah *ah);
+int bnxt_qplib_alloc_mrw(struct bnxt_qplib_res *res,
+			 struct bnxt_qplib_mrw *mrw);
+int bnxt_qplib_dereg_mrw(struct bnxt_qplib_res *res, struct bnxt_qplib_mrw *mrw,
+			 bool block);
+int bnxt_qplib_reg_mr(struct bnxt_qplib_res *res, struct bnxt_qplib_mrw *mr,
+		      u64 *pbl_tbl, int num_pbls, bool block);
+int bnxt_qplib_free_mrw(struct bnxt_qplib_res *res, struct bnxt_qplib_mrw *mr);
+int bnxt_qplib_alloc_fast_reg_mr(struct bnxt_qplib_res *res,
+				 struct bnxt_qplib_mrw *mr, int max);
+int bnxt_qplib_alloc_fast_reg_page_list(struct bnxt_qplib_res *res,
+					struct bnxt_qplib_frpl *frpl, int max);
+int bnxt_qplib_free_fast_reg_page_list(struct bnxt_qplib_res *res,
+				       struct bnxt_qplib_frpl *frpl);
 #endif /* __BNXT_QPLIB_SP_H__*/
-- 
2.5.5
