From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH V5 for-next 05/21] RDMA/bnxt_re: Adding Notification Queue support
Date: Fri, 10 Feb 2017 03:19:37 -0800
Message-ID: <1486725593-9872-6-git-send-email-selvin.xavier@broadcom.com>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:34684 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752513AbdBJL2D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 06:28:03 -0500
Received: by mail-qk0-f173.google.com with SMTP id s186so35519253qkb.1
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 03:28:03 -0800 (PST)
In-Reply-To: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Completion Notifcations are handled by Notification Queue (NQ). This
patch configures the NQs. Also, configures the Door bell page mapping

v3: Fixes some sparse warnings related to endianness checks
v4: Change include file names

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxt_re/bnxt_re.h   |   8 ++
 drivers/infiniband/hw/bnxt_re/main.c      |  52 +++++++++-
 drivers/infiniband/hw/bnxt_re/qplib_fp.c  | 161 ++++++++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/qplib_fp.h  |  60 +++++++++++
 drivers/infiniband/hw/bnxt_re/qplib_res.h |   6 ++
 5 files changed, 286 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/bnxt_re/bnxt_re.h b/drivers/infiniband/hw/bnxt_re/bnxt_re.h
index cbc2fb2..cac4096 100644
--- a/drivers/infiniband/hw/bnxt_re/bnxt_re.h
+++ b/drivers/infiniband/hw/bnxt_re/bnxt_re.h
@@ -59,6 +59,8 @@ struct bnxt_re_work {
 #define BNXT_RE_MIN_MSIX		2
 #define BNXT_RE_MAX_MSIX		16
 #define BNXT_RE_AEQ_IDX			0
+#define BNXT_RE_NQ_IDX			1
+
 struct bnxt_re_dev {
 	struct ib_device		ibdev;
 	struct list_head		list;
@@ -76,9 +78,15 @@ struct bnxt_re_dev {
 
 	int				id;
 
+	/* FP Notification Queue (CQ & SRQ) */
+	struct tasklet_struct		nq_task;
+
 	/* RCFW Channel */
 	struct bnxt_qplib_rcfw		rcfw;
 
+	/* NQ */
+	struct bnxt_qplib_nq		nq;
+
 	/* Device Resources */
 	struct bnxt_qplib_dev_attr	dev_attr;
 	struct bnxt_qplib_ctx		qplib_ctx;
diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index 6fdf726..9091caf 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -551,6 +551,9 @@ static int bnxt_re_aeq_handler(struct bnxt_qplib_rcfw *rcfw,
 
 static void bnxt_re_cleanup_res(struct bnxt_re_dev *rdev)
 {
+	if (rdev->nq.hwq.max_elements)
+		bnxt_qplib_disable_nq(&rdev->nq);
+
 	if (rdev->qplib_res.rcfw)
 		bnxt_qplib_cleanup_res(&rdev->qplib_res);
 }
@@ -561,11 +564,32 @@ static int bnxt_re_init_res(struct bnxt_re_dev *rdev)
 
 	bnxt_qplib_init_res(&rdev->qplib_res);
 
+	if (rdev->msix_entries[BNXT_RE_NQ_IDX].vector <= 0)
+		return -EINVAL;
+
+	rc = bnxt_qplib_enable_nq(rdev->en_dev->pdev, &rdev->nq,
+				  rdev->msix_entries[BNXT_RE_NQ_IDX].vector,
+				  rdev->msix_entries[BNXT_RE_NQ_IDX].db_offset,
+				  NULL,
+				  NULL);
+
+	if (rc)
+		dev_err(rdev_to_dev(rdev), "Failed to enable NQ: %#x", rc);
+
 	return rc;
 }
 
 static void bnxt_re_free_res(struct bnxt_re_dev *rdev, bool lock_wait)
 {
+	if (rdev->nq.hwq.max_elements) {
+		bnxt_re_net_ring_free(rdev, rdev->nq.ring_id, lock_wait);
+		bnxt_qplib_free_nq(&rdev->nq);
+	}
+	if (rdev->qplib_res.dpi_tbl.max) {
+		bnxt_qplib_dealloc_dpi(&rdev->qplib_res,
+				       &rdev->qplib_res.dpi_tbl,
+				       &rdev->dpi_privileged);
+	}
 	if (rdev->qplib_res.rcfw) {
 		bnxt_qplib_free_res(&rdev->qplib_res);
 		rdev->qplib_res.rcfw = NULL;
@@ -587,8 +611,34 @@ static int bnxt_re_alloc_res(struct bnxt_re_dev *rdev)
 	if (rc)
 		goto fail;
 
-	return 0;
+	rc = bnxt_qplib_alloc_dpi(&rdev->qplib_res.dpi_tbl,
+				  &rdev->dpi_privileged,
+				  rdev);
+	if (rc)
+		goto fail;
 
+	rdev->nq.hwq.max_elements = BNXT_RE_MAX_CQ_COUNT +
+				    BNXT_RE_MAX_SRQC_COUNT + 2;
+	rc = bnxt_qplib_alloc_nq(rdev->en_dev->pdev, &rdev->nq);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev),
+			"Failed to allocate NQ memory: %#x", rc);
+		goto fail;
+	}
+	rc = bnxt_re_net_ring_alloc
+			(rdev, rdev->nq.hwq.pbl[PBL_LVL_0].pg_map_arr,
+			 rdev->nq.hwq.pbl[rdev->nq.hwq.level].pg_count,
+			 HWRM_RING_ALLOC_CMPL, BNXT_QPLIB_NQE_MAX_CNT - 1,
+			 rdev->msix_entries[BNXT_RE_NQ_IDX].ring_idx,
+			 &rdev->nq.ring_id);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev),
+			"Failed to allocate NQ ring: %#x", rc);
+		goto free_nq;
+	}
+	return 0;
+free_nq:
+	bnxt_qplib_free_nq(&rdev->nq);
 fail:
 	rdev->qplib_res.rcfw = NULL;
 	return rc;
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_fp.c b/drivers/infiniband/hw/bnxt_re/qplib_fp.c
index ef0f85c..7c98950 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_fp.c
+++ b/drivers/infiniband/hw/bnxt_re/qplib_fp.c
@@ -35,3 +35,164 @@
  *
  * Description: Fast Path Operators
  */
+
+#include <linux/interrupt.h>
+#include <linux/spinlock.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/pci.h>
+#include <linux/prefetch.h>
+
+#include "roce_hsi.h"
+
+#include "qplib_res.h"
+#include "qplib_rcfw.h"
+#include "qplib_sp.h"
+#include "qplib_fp.h"
+
+static void bnxt_qplib_service_nq(unsigned long data)
+{
+	struct bnxt_qplib_nq *nq = (struct bnxt_qplib_nq *)data;
+	struct bnxt_qplib_hwq *hwq = &nq->hwq;
+	struct nq_base *nqe, **nq_ptr;
+	u32 sw_cons, raw_cons;
+	u16 type;
+	int budget = nq->budget;
+
+	/* Service the NQ until empty */
+	raw_cons = hwq->cons;
+	while (budget--) {
+		sw_cons = HWQ_CMP(raw_cons, hwq);
+		nq_ptr = (struct nq_base **)hwq->pbl_ptr;
+		nqe = &nq_ptr[NQE_PG(sw_cons)][NQE_IDX(sw_cons)];
+		if (!NQE_CMP_VALID(nqe, raw_cons, hwq->max_elements))
+			break;
+
+		type = le16_to_cpu(nqe->info10_type) & NQ_BASE_TYPE_MASK;
+		switch (type) {
+		case NQ_BASE_TYPE_CQ_NOTIFICATION:
+			break;
+		case NQ_BASE_TYPE_DBQ_EVENT:
+			break;
+		default:
+			dev_warn(&nq->pdev->dev,
+				 "QPLIB: nqe with type = 0x%x not handled",
+				 type);
+			break;
+		}
+		raw_cons++;
+	}
+	if (hwq->cons != raw_cons) {
+		hwq->cons = raw_cons;
+		NQ_DB_REARM(nq->bar_reg_iomem, hwq->cons, hwq->max_elements);
+	}
+}
+
+static irqreturn_t bnxt_qplib_nq_irq(int irq, void *dev_instance)
+{
+	struct bnxt_qplib_nq *nq = dev_instance;
+	struct bnxt_qplib_hwq *hwq = &nq->hwq;
+	struct nq_base **nq_ptr;
+	u32 sw_cons;
+
+	/* Prefetch the NQ element */
+	sw_cons = HWQ_CMP(hwq->cons, hwq);
+	nq_ptr = (struct nq_base **)nq->hwq.pbl_ptr;
+	prefetch(&nq_ptr[NQE_PG(sw_cons)][NQE_IDX(sw_cons)]);
+
+	/* Fan out to CPU affinitized kthreads? */
+	tasklet_schedule(&nq->worker);
+
+	return IRQ_HANDLED;
+}
+
+void bnxt_qplib_disable_nq(struct bnxt_qplib_nq *nq)
+{
+	/* Make sure the HW is stopped! */
+	synchronize_irq(nq->vector);
+	tasklet_disable(&nq->worker);
+	tasklet_kill(&nq->worker);
+
+	if (nq->requested) {
+		free_irq(nq->vector, nq);
+		nq->requested = false;
+	}
+	if (nq->bar_reg_iomem)
+		iounmap(nq->bar_reg_iomem);
+	nq->bar_reg_iomem = NULL;
+
+	nq->cqn_handler = NULL;
+	nq->srqn_handler = NULL;
+	nq->vector = 0;
+}
+
+int bnxt_qplib_enable_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq,
+			 int msix_vector, int bar_reg_offset,
+			 int (*cqn_handler)(struct bnxt_qplib_nq *nq,
+					    void *),
+			 int (*srqn_handler)(struct bnxt_qplib_nq *nq,
+					     void *, u8 event))
+{
+	resource_size_t nq_base;
+	int rc;
+
+	nq->pdev = pdev;
+	nq->vector = msix_vector;
+
+	nq->cqn_handler = cqn_handler;
+
+	nq->srqn_handler = srqn_handler;
+
+	tasklet_init(&nq->worker, bnxt_qplib_service_nq, (unsigned long)nq);
+
+	nq->requested = false;
+	rc = request_irq(nq->vector, bnxt_qplib_nq_irq, 0, "bnxt_qplib_nq", nq);
+	if (rc) {
+		dev_err(&nq->pdev->dev,
+			"Failed to request IRQ for NQ: %#x", rc);
+		bnxt_qplib_disable_nq(nq);
+		goto fail;
+	}
+	nq->requested = true;
+	nq->bar_reg = NQ_CONS_PCI_BAR_REGION;
+	nq->bar_reg_off = bar_reg_offset;
+	nq_base = pci_resource_start(pdev, nq->bar_reg);
+	if (!nq_base) {
+		rc = -ENOMEM;
+		goto fail;
+	}
+	nq->bar_reg_iomem = ioremap_nocache(nq_base + nq->bar_reg_off, 4);
+	if (!nq->bar_reg_iomem) {
+		rc = -ENOMEM;
+		goto fail;
+	}
+	NQ_DB_REARM(nq->bar_reg_iomem, nq->hwq.cons, nq->hwq.max_elements);
+
+	return 0;
+fail:
+	bnxt_qplib_disable_nq(nq);
+	return rc;
+}
+
+void bnxt_qplib_free_nq(struct bnxt_qplib_nq *nq)
+{
+	if (nq->hwq.max_elements)
+		bnxt_qplib_free_hwq(nq->pdev, &nq->hwq);
+}
+
+int bnxt_qplib_alloc_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq)
+{
+	nq->pdev = pdev;
+	if (!nq->hwq.max_elements ||
+	    nq->hwq.max_elements > BNXT_QPLIB_NQE_MAX_CNT)
+		nq->hwq.max_elements = BNXT_QPLIB_NQE_MAX_CNT;
+
+	if (bnxt_qplib_alloc_init_hwq(nq->pdev, &nq->hwq, NULL, 0,
+				      &nq->hwq.max_elements,
+				      BNXT_QPLIB_MAX_NQE_ENTRY_SIZE, 0,
+				      PAGE_SIZE, HWQ_TYPE_L2_CMPL))
+		return -ENOMEM;
+
+	nq->budget = 8;
+	return 0;
+}
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_fp.h b/drivers/infiniband/hw/bnxt_re/qplib_fp.h
index 4128ab7..78e1717 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_fp.h
+++ b/drivers/infiniband/hw/bnxt_re/qplib_fp.h
@@ -39,4 +39,64 @@
 #ifndef __BNXT_QPLIB_FP_H__
 #define __BNXT_QPLIB_FP_H__
 
+#define BNXT_QPLIB_MAX_NQE_ENTRY_SIZE	sizeof(struct nq_base)
+
+#define NQE_CNT_PER_PG		(PAGE_SIZE / BNXT_QPLIB_MAX_NQE_ENTRY_SIZE)
+#define NQE_MAX_IDX_PER_PG	(NQE_CNT_PER_PG - 1)
+#define NQE_PG(x)		(((x) & ~NQE_MAX_IDX_PER_PG) / NQE_CNT_PER_PG)
+#define NQE_IDX(x)		((x) & NQE_MAX_IDX_PER_PG)
+
+#define NQE_CMP_VALID(hdr, raw_cons, cp_bit)			\
+	(!!(le32_to_cpu((hdr)->info63_v[0]) & NQ_BASE_V) ==	\
+	   !((raw_cons) & (cp_bit)))
+
+#define BNXT_QPLIB_NQE_MAX_CNT		(128 * 1024)
+
+#define NQ_CONS_PCI_BAR_REGION		2
+#define NQ_DB_KEY_CP			(0x2 << CMPL_DOORBELL_KEY_SFT)
+#define NQ_DB_IDX_VALID			CMPL_DOORBELL_IDX_VALID
+#define NQ_DB_IRQ_DIS			CMPL_DOORBELL_MASK
+#define NQ_DB_CP_FLAGS_REARM		(NQ_DB_KEY_CP |		\
+					 NQ_DB_IDX_VALID)
+#define NQ_DB_CP_FLAGS			(NQ_DB_KEY_CP    |	\
+					 NQ_DB_IDX_VALID |	\
+					 NQ_DB_IRQ_DIS)
+#define NQ_DB_REARM(db, raw_cons, cp_bit)			\
+	writel(NQ_DB_CP_FLAGS_REARM | ((raw_cons) & ((cp_bit) - 1)), db)
+#define NQ_DB(db, raw_cons, cp_bit)				\
+	writel(NQ_DB_CP_FLAGS | ((raw_cons) & ((cp_bit) - 1)), db)
+
+struct bnxt_qplib_nq {
+	struct pci_dev			*pdev;
+
+	int				vector;
+	int				budget;
+	bool				requested;
+	struct tasklet_struct		worker;
+	struct bnxt_qplib_hwq		hwq;
+
+	u16				bar_reg;
+	u16				bar_reg_off;
+	u16				ring_id;
+	void __iomem			*bar_reg_iomem;
+
+	int				(*cqn_handler)
+						(struct bnxt_qplib_nq *nq,
+						 void *cq);
+	int				(*srqn_handler)
+						(struct bnxt_qplib_nq *nq,
+						 void *srq,
+						 u8 event);
+};
+
+void bnxt_qplib_disable_nq(struct bnxt_qplib_nq *nq);
+int bnxt_qplib_enable_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq,
+			 int msix_vector, int bar_reg_offset,
+			 int (*cqn_handler)(struct bnxt_qplib_nq *nq,
+					    void *cq),
+			 int (*srqn_handler)(struct bnxt_qplib_nq *nq,
+					     void *srq,
+					     u8 event));
+void bnxt_qplib_free_nq(struct bnxt_qplib_nq *nq);
+int bnxt_qplib_alloc_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq);
 #endif /* __BNXT_QPLIB_FP_H__ */
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_res.h b/drivers/infiniband/hw/bnxt_re/qplib_res.h
index b3acbbd..a3405e7 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_res.h
+++ b/drivers/infiniband/hw/bnxt_re/qplib_res.h
@@ -193,6 +193,12 @@ int bnxt_qplib_alloc_init_hwq(struct pci_dev *pdev, struct bnxt_qplib_hwq *hwq,
 			      struct scatterlist *sl, int nmap, u32 *elements,
 			      u32 elements_per_page, u32 aux, u32 pg_size,
 			      enum bnxt_qplib_hwq_type hwq_type);
+int bnxt_qplib_alloc_dpi(struct bnxt_qplib_dpi_tbl *dpit,
+			 struct bnxt_qplib_dpi     *dpi,
+			 void                      *app);
+int bnxt_qplib_dealloc_dpi(struct bnxt_qplib_res *res,
+			   struct bnxt_qplib_dpi_tbl *dpi_tbl,
+			   struct bnxt_qplib_dpi *dpi);
 void bnxt_qplib_cleanup_res(struct bnxt_qplib_res *res);
 int bnxt_qplib_init_res(struct bnxt_qplib_res *res);
 void bnxt_qplib_free_res(struct bnxt_qplib_res *res);
-- 
2.5.5
