From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH for bnxt_re V4 06/21] RDMA/bnxt_re: Support for PD, ucontext and mmap verbs
Date: Wed, 21 Dec 2016 03:41:55 -0800
Message-ID: <1482320530-5344-7-git-send-email-selvin.xavier@broadcom.com>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f182.google.com ([209.85.210.182]:33565 "EHLO
        mail-wj0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757257AbcLULnE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 06:43:04 -0500
Received: by mail-wj0-f182.google.com with SMTP id xy5so199957352wjc.0
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 03:43:01 -0800 (PST)
In-Reply-To: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch includes the uverbs ABI header file to enable user verbs.
Also, adds support for the Protection Domain, User Context and mmap
verbs.

v2: Moved the bnxt_re_uverbs_abi.h file to include/uapi/rdma folder.
    Also, Fixed one sparse warning.
v3: Fixes some cross compile and sparse warnings. Changes the
    bnxt_re_uverbs_abi.h file name to bnxtre-abi.h. Aligns the data
    structure to 64 bit and eliminates __packed qualifier from
    bnxtre-abi.h
v3  Changes the bnxtre_abi.h file name to bnxt_re-abi.h to follow
    modulename-abi.h format. Also, modifies the include file name.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxt_re/ib_verbs.c  | 218 ++++++++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/ib_verbs.h  |  23 ++++
 drivers/infiniband/hw/bnxt_re/main.c      |   7 +
 drivers/infiniband/hw/bnxt_re/qplib_res.c |  28 ++++
 drivers/infiniband/hw/bnxt_re/qplib_res.h |   6 +
 drivers/infiniband/hw/bnxt_re/qplib_sp.h  |   4 +
 include/uapi/rdma/bnxt_re-abi.h           |  59 ++++++++
 7 files changed, 345 insertions(+)
 create mode 100644 include/uapi/rdma/bnxt_re-abi.h

diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.c b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
index c01fa40..fed80ed 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.c
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
@@ -35,3 +35,221 @@
  *
  * Description: IB Verbs interpreter
  */
+
+#include <linux/interrupt.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_user_verbs.h>
+#include <rdma/ib_umem.h>
+#include <rdma/ib_addr.h>
+#include <rdma/ib_mad.h>
+#include <rdma/ib_cache.h>
+
+#include "bnxt_ulp.h"
+
+#include "roce_hsi.h"
+#include "qplib_res.h"
+#include "qplib_sp.h"
+#include "qplib_fp.h"
+#include "qplib_rcfw.h"
+
+#include "bnxt_re.h"
+#include "ib_verbs.h"
+#include <rdma/bnxt_re-abi.h>
+
+/* Protection Domains */
+int bnxt_re_dealloc_pd(struct ib_pd *ib_pd)
+{
+	struct bnxt_re_pd *pd = container_of(ib_pd, struct bnxt_re_pd, ib_pd);
+	struct bnxt_re_dev *rdev = pd->rdev;
+	int rc;
+
+	if (ib_pd->uobject && pd->dpi.dbr) {
+		struct ib_ucontext *ib_uctx = ib_pd->uobject->context;
+		struct bnxt_re_ucontext *ucntx;
+
+		/* Free DPI only if this is the first PD allocated by the
+		 * application and mark the context dpi as NULL
+		 */
+		ucntx = container_of(ib_uctx, struct bnxt_re_ucontext, ib_uctx);
+
+		rc = bnxt_qplib_dealloc_dpi(&rdev->qplib_res,
+					    &rdev->qplib_res.dpi_tbl,
+					    &pd->dpi);
+		if (rc)
+			dev_err(rdev_to_dev(rdev), "Failed to deallocate HW DPI");
+			/* Don't fail, continue*/
+		ucntx->dpi = NULL;
+	}
+
+	rc = bnxt_qplib_dealloc_pd(&rdev->qplib_res,
+				   &rdev->qplib_res.pd_tbl,
+				   &pd->qplib_pd);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev), "Failed to deallocate HW PD");
+		return rc;
+	}
+
+	kfree(pd);
+	return 0;
+}
+
+struct ib_pd *bnxt_re_alloc_pd(struct ib_device *ibdev,
+			       struct ib_ucontext *ucontext,
+			       struct ib_udata *udata)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
+	struct bnxt_re_ucontext *ucntx = container_of(ucontext,
+						      struct bnxt_re_ucontext,
+						      ib_uctx);
+	struct bnxt_re_pd *pd;
+	int rc;
+
+	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
+	if (!pd)
+		return ERR_PTR(-ENOMEM);
+
+	pd->rdev = rdev;
+	if (bnxt_qplib_alloc_pd(&rdev->qplib_res.pd_tbl, &pd->qplib_pd)) {
+		dev_err(rdev_to_dev(rdev), "Failed to allocate HW PD");
+		rc = -ENOMEM;
+		goto fail;
+	}
+
+	if (udata) {
+		struct bnxt_re_pd_resp resp;
+
+		if (!ucntx->dpi) {
+			/* Allocate DPI in alloc_pd to avoid failing of
+			 * ibv_devinfo and family of application when DPIs
+			 * are depleted.
+			 */
+			if (bnxt_qplib_alloc_dpi(&rdev->qplib_res.dpi_tbl,
+						 &pd->dpi, ucntx)) {
+				rc = -ENOMEM;
+				goto dbfail;
+			}
+			ucntx->dpi = &pd->dpi;
+		}
+
+		resp.pdid = pd->qplib_pd.id;
+		/* Still allow mapping this DBR to the new user PD. */
+		resp.dpi = ucntx->dpi->dpi;
+		resp.dbr = (u64)ucntx->dpi->umdbr;
+
+		rc = ib_copy_to_udata(udata, &resp, sizeof(resp));
+		if (rc) {
+			dev_err(rdev_to_dev(rdev),
+				"Failed to copy user response\n");
+			goto dbfail;
+		}
+	}
+
+	return &pd->ib_pd;
+dbfail:
+	(void)bnxt_qplib_dealloc_pd(&rdev->qplib_res, &rdev->qplib_res.pd_tbl,
+				    &pd->qplib_pd);
+fail:
+	kfree(pd);
+	return ERR_PTR(rc);
+}
+
+struct ib_ucontext *bnxt_re_alloc_ucontext(struct ib_device *ibdev,
+					   struct ib_udata *udata)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
+	struct bnxt_re_uctx_resp resp;
+	struct bnxt_re_ucontext *uctx;
+	struct bnxt_qplib_dev_attr *dev_attr = &rdev->dev_attr;
+	int rc;
+
+	dev_dbg(rdev_to_dev(rdev), "ABI version requested %d",
+		ibdev->uverbs_abi_ver);
+
+	if (ibdev->uverbs_abi_ver != BNXT_RE_ABI_VERSION) {
+		dev_dbg(rdev_to_dev(rdev), " is different from the device %d ",
+			BNXT_RE_ABI_VERSION);
+		return ERR_PTR(-EPERM);
+	}
+
+	uctx = kzalloc(sizeof(*uctx), GFP_KERNEL);
+	if (!uctx)
+		return ERR_PTR(-ENOMEM);
+
+	uctx->rdev = rdev;
+
+	uctx->shpg = (void *)__get_free_page(GFP_KERNEL);
+	if (!uctx->shpg) {
+		rc = -ENOMEM;
+		goto fail;
+	}
+	spin_lock_init(&uctx->sh_lock);
+
+	resp.dev_id = rdev->en_dev->pdev->devfn; /*Temp, Use idr_alloc instead*/
+	resp.max_qp = rdev->qplib_ctx.qpc_count;
+	resp.pg_size = PAGE_SIZE;
+	resp.cqe_sz = sizeof(struct cq_base);
+	resp.max_cqd = dev_attr->max_cq_wqes;
+	resp.rsvd    = 0;
+
+	rc = ib_copy_to_udata(udata, &resp, sizeof(resp));
+	if (rc) {
+		dev_err(rdev_to_dev(rdev), "Failed to copy user context");
+		rc = -EFAULT;
+		goto cfail;
+	}
+
+	return &uctx->ib_uctx;
+cfail:
+	free_page((unsigned long)uctx->shpg);
+	uctx->shpg = NULL;
+fail:
+	kfree(uctx);
+	return ERR_PTR(rc);
+}
+
+int bnxt_re_dealloc_ucontext(struct ib_ucontext *ib_uctx)
+{
+	struct bnxt_re_ucontext *uctx = container_of(ib_uctx,
+						   struct bnxt_re_ucontext,
+						   ib_uctx);
+	if (uctx->shpg)
+		free_page((unsigned long)uctx->shpg);
+	kfree(uctx);
+	return 0;
+}
+
+/* Helper function to mmap the virtual memory from user app */
+int bnxt_re_mmap(struct ib_ucontext *ib_uctx, struct vm_area_struct *vma)
+{
+	struct bnxt_re_ucontext *uctx = container_of(ib_uctx,
+						   struct bnxt_re_ucontext,
+						   ib_uctx);
+	struct bnxt_re_dev *rdev = uctx->rdev;
+	u64 pfn;
+
+	if (vma->vm_end - vma->vm_start != PAGE_SIZE)
+		return -EINVAL;
+
+	if (vma->vm_pgoff) {
+		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+		if (io_remap_pfn_range(vma, vma->vm_start, vma->vm_pgoff,
+				       PAGE_SIZE, vma->vm_page_prot)) {
+			dev_err(rdev_to_dev(rdev), "Failed to map DPI");
+			return -EAGAIN;
+		}
+	} else {
+		pfn = virt_to_phys(uctx->shpg) >> PAGE_SHIFT;
+		if (remap_pfn_range(vma, vma->vm_start,
+				    pfn, PAGE_SIZE, vma->vm_page_prot)) {
+			dev_err(rdev_to_dev(rdev),
+				"Failed to map shared page");
+			return -EAGAIN;
+		}
+	}
+
+	return 0;
+}
diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.h b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
index 9162774..a133d81 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.h
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
@@ -39,4 +39,27 @@
 #ifndef __BNXT_RE_IB_VERBS_H__
 #define __BNXT_RE_IB_VERBS_H__
 
+struct bnxt_re_pd {
+	struct bnxt_re_dev	*rdev;
+	struct ib_pd		ib_pd;
+	struct bnxt_qplib_pd	qplib_pd;
+	struct bnxt_qplib_dpi	dpi;
+};
+
+struct bnxt_re_ucontext {
+	struct bnxt_re_dev	*rdev;
+	struct ib_ucontext	ib_uctx;
+	struct bnxt_qplib_dpi	*dpi;
+	void			*shpg;
+	spinlock_t		sh_lock;	/* protect shpg */
+};
+
+struct ib_pd *bnxt_re_alloc_pd(struct ib_device *ibdev,
+			       struct ib_ucontext *context,
+			       struct ib_udata *udata);
+int bnxt_re_dealloc_pd(struct ib_pd *pd);
+struct ib_ucontext *bnxt_re_alloc_ucontext(struct ib_device *ibdev,
+					   struct ib_udata *udata);
+int bnxt_re_dealloc_ucontext(struct ib_ucontext *context);
+int bnxt_re_mmap(struct ib_ucontext *context, struct vm_area_struct *vma);
 #endif /* __BNXT_RE_IB_VERBS_H__ */
diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index bef654e..6f07657 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -59,6 +59,7 @@
 #include "qplib_fp.h"
 #include "qplib_rcfw.h"
 #include "bnxt_re.h"
+#include "ib_verbs.h"
 #include "bnxt.h"
 static char version[] =
 		BNXT_RE_DESC " v" ROCE_DRV_MODULE_VERSION "\n";
@@ -435,6 +436,12 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 
 	ibdev->num_comp_vectors	= 1;
 	ibdev->dma_device = &rdev->en_dev->pdev->dev;
+	ibdev->alloc_pd			= bnxt_re_alloc_pd;
+	ibdev->dealloc_pd		= bnxt_re_dealloc_pd;
+	ibdev->alloc_ucontext		= bnxt_re_alloc_ucontext;
+	ibdev->dealloc_ucontext		= bnxt_re_dealloc_ucontext;
+	ibdev->mmap			= bnxt_re_mmap;
+
 	return ib_register_device(ibdev, NULL);
 }
 
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_res.c b/drivers/infiniband/hw/bnxt_re/qplib_res.c
index c9ef4c2..1648b45 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_res.c
+++ b/drivers/infiniband/hw/bnxt_re/qplib_res.c
@@ -527,6 +527,34 @@ static int bnxt_qplib_alloc_pkey_tbl(struct bnxt_qplib_res *res,
 	return 0;
 };
 
+/* PDs */
+int bnxt_qplib_alloc_pd(struct bnxt_qplib_pd_tbl *pdt, struct bnxt_qplib_pd *pd)
+{
+	u32 bit_num;
+
+	bit_num = find_first_bit(pdt->tbl, pdt->max);
+	if (bit_num == pdt->max)
+		return -ENOMEM;
+
+	/* Found unused PD */
+	clear_bit(bit_num, pdt->tbl);
+	pd->id = bit_num;
+	return 0;
+}
+
+int bnxt_qplib_dealloc_pd(struct bnxt_qplib_res *res,
+			  struct bnxt_qplib_pd_tbl *pdt,
+			  struct bnxt_qplib_pd *pd)
+{
+	if (test_and_set_bit(pd->id, pdt->tbl)) {
+		dev_warn(&res->pdev->dev, "Freeing an unused PD? pdn = %d",
+			 pd->id);
+		return -EINVAL;
+	}
+	pd->id = 0;
+	return 0;
+}
+
 static void bnxt_qplib_free_pd_tbl(struct bnxt_qplib_pd_tbl *pdt)
 {
 	kfree(pdt->tbl);
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_res.h b/drivers/infiniband/hw/bnxt_re/qplib_res.h
index 571feda..c9e376a 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_res.h
+++ b/drivers/infiniband/hw/bnxt_re/qplib_res.h
@@ -186,6 +186,7 @@ struct bnxt_qplib_res {
 	struct bnxt_qplib_dpi_tbl	dpi_tbl;
 };
 
+struct bnxt_qplib_pd;
 struct bnxt_qplib_dev_attr;
 
 void bnxt_qplib_free_hwq(struct pci_dev *pdev, struct bnxt_qplib_hwq *hwq);
@@ -193,6 +194,11 @@ int bnxt_qplib_alloc_init_hwq(struct pci_dev *pdev, struct bnxt_qplib_hwq *hwq,
 			      struct scatterlist *sl, int nmap, u32 *elements,
 			      u32 elements_per_page, u32 aux, u32 pg_size,
 			      enum bnxt_qplib_hwq_type hwq_type);
+int bnxt_qplib_alloc_pd(struct bnxt_qplib_pd_tbl *pd_tbl,
+			struct bnxt_qplib_pd *pd);
+int bnxt_qplib_dealloc_pd(struct bnxt_qplib_res *res,
+			  struct bnxt_qplib_pd_tbl *pd_tbl,
+			  struct bnxt_qplib_pd *pd);
 int bnxt_qplib_alloc_dpi(struct bnxt_qplib_dpi_tbl *dpit,
 			 struct bnxt_qplib_dpi     *dpi,
 			 void                      *app);
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_sp.h b/drivers/infiniband/hw/bnxt_re/qplib_sp.h
index 0b5adda..7de6600 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_sp.h
+++ b/drivers/infiniband/hw/bnxt_re/qplib_sp.h
@@ -70,6 +70,10 @@ struct bnxt_qplib_dev_attr {
 	u8				tqm_alloc_reqs[MAX_TQM_ALLOC_REQ];
 };
 
+struct bnxt_qplib_pd {
+	u32				id;
+};
+
 struct bnxt_qplib_gid {
 	u8				data[16];
 };
diff --git a/include/uapi/rdma/bnxt_re-abi.h b/include/uapi/rdma/bnxt_re-abi.h
new file mode 100644
index 0000000..7998eff
--- /dev/null
+++ b/include/uapi/rdma/bnxt_re-abi.h
@@ -0,0 +1,59 @@
+/*
+ * Broadcom NetXtreme-E RoCE driver.
+ *
+ * Copyright (c) 2016, Broadcom. All rights reserved.  The term
+ * Broadcom refers to Broadcom Limited and/or its subsidiaries.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * BSD license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
+ * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Description: Uverbs ABI header file
+ */
+
+#ifndef __BNXT_RE_UVERBS_ABI_H__
+#define __BNXT_RE_UVERBS_ABI_H__
+
+#define BNXT_RE_ABI_VERSION	1
+
+struct bnxt_re_uctx_resp {
+	__u32 dev_id;
+	__u32 max_qp;
+	__u32 pg_size;
+	__u32 cqe_sz;
+	__u32 max_cqd;
+	__u32 rsvd;
+};
+
+struct bnxt_re_pd_resp {
+	__u32 pdid;
+	__u32 dpi;
+	__u64 dbr;
+};
+
+#endif /* __BNXT_RE_UVERBS_ABI_H__*/
-- 
2.5.5
