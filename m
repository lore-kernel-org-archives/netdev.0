From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH V2  10/22] bnxt_re: Support for CQ verbs
Date: Thu,  8 Dec 2016 22:48:04 -0800
Message-ID: <1481266096-23331-11-git-send-email-selvin.xavier@broadcom.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch implements support for create_cq, destroy_cq and req_notify_cq
verbs.

Signed-off-by: Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c    | 183 ++++++++++++++++++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h    |  47 ++++++
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c | 154 ++++++++++++++++++++
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h |  19 +++
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c     |   4 +
 include/uapi/rdma/bnxt_re_uverbs_abi.h          |  11 ++
 6 files changed, 418 insertions(+)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
index 9e63032..636306f 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
@@ -49,14 +49,17 @@
 #include "bnxt_qplib_sp.h"
 #include "bnxt_qplib_fp.h"
 
+static void bnxt_qplib_arm_cq_enable(struct bnxt_qplib_cq *cq);
 static void bnxt_qplib_service_nq(unsigned long data)
 {
 	struct bnxt_qplib_nq *nq = (struct bnxt_qplib_nq *)data;
 	struct bnxt_qplib_hwq *hwq = &nq->hwq;
 	struct nq_base *nqe, **nq_ptr;
+	int num_cqne_processed = 0;
 	u32 sw_cons, raw_cons;
 	u32 type;
 	int budget = nq->budget;
+	u64 q_handle;
 
 	/* Service the NQ until empty */
 	raw_cons = hwq->cons;
@@ -70,7 +73,23 @@ static void bnxt_qplib_service_nq(unsigned long data)
 		type = le16_to_cpu(nqe->info10_type & NQ_BASE_TYPE_MASK);
 		switch (type) {
 		case NQ_BASE_TYPE_CQ_NOTIFICATION:
+		{
+			struct nq_cn *nqcne = (struct nq_cn *)nqe;
+
+			q_handle = le32_to_cpu(nqcne->cq_handle_low);
+			q_handle |= (u64)le32_to_cpu(nqcne->cq_handle_high)
+						     << 32;
+			bnxt_qplib_arm_cq_enable((struct bnxt_qplib_cq *)
+						 q_handle);
+			if (!nq->cqn_handler(nq, (struct bnxt_qplib_cq *)
+						 q_handle))
+				num_cqne_processed++;
+			else
+				dev_warn(&nq->pdev->dev,
+					 "QPLIB: cqn - type 0x%x not handled",
+					 type);
 			break;
+		}
 		case NQ_BASE_TYPE_DBQ_EVENT:
 			break;
 		default:
@@ -195,3 +214,167 @@ int bnxt_qplib_alloc_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq)
 	nq->budget = 8;
 	return 0;
 }
+
+/* CQ */
+
+/* Spinlock must be held */
+static void bnxt_qplib_arm_cq_enable(struct bnxt_qplib_cq *cq)
+{
+	struct dbr_dbr db_msg = { 0 };
+
+	db_msg.type_xid =
+		cpu_to_le32(((cq->id << DBR_DBR_XID_SFT) & DBR_DBR_XID_MASK) |
+			    DBR_DBR_TYPE_CQ_ARMENA);
+	/* Flush memory writes before enabling the CQ */
+	wmb();
+	__iowrite64_copy(cq->dbr_base, &db_msg, sizeof(db_msg) / sizeof(u64));
+}
+
+static void bnxt_qplib_arm_cq(struct bnxt_qplib_cq *cq, u32 arm_type)
+{
+	struct bnxt_qplib_hwq *cq_hwq = &cq->hwq;
+	struct dbr_dbr db_msg = { 0 };
+	u32 sw_cons;
+
+	/* Ring DB */
+	sw_cons = HWQ_CMP(cq_hwq->cons, cq_hwq);
+	db_msg.index = cpu_to_le32((sw_cons << DBR_DBR_INDEX_SFT) &
+				    DBR_DBR_INDEX_MASK);
+	db_msg.type_xid =
+		cpu_to_le32(((cq->id << DBR_DBR_XID_SFT) & DBR_DBR_XID_MASK) |
+			    arm_type);
+	/* flush memory writes before arming the CQ */
+	wmb();
+	__iowrite64_copy(cq->dpi->dbr, &db_msg, sizeof(db_msg) / sizeof(u64));
+}
+
+int bnxt_qplib_create_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_create_cq req;
+	struct creq_create_cq_resp *resp;
+	struct bnxt_qplib_pbl *pbl;
+	u16 cmd_flags = 0;
+	int rc;
+
+	cq->hwq.max_elements = cq->max_wqe;
+	rc = bnxt_qplib_alloc_init_hwq(res->pdev, &cq->hwq, cq->sghead,
+				       cq->nmap, &cq->hwq.max_elements,
+				       BNXT_QPLIB_MAX_CQE_ENTRY_SIZE, 0,
+				       PAGE_SIZE, HWQ_TYPE_QUEUE);
+	if (rc)
+		goto exit;
+
+	RCFW_CMD_PREP(req, CREATE_CQ, cmd_flags);
+
+	if (!cq->dpi) {
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: FP: CREATE_CQ failed due to NULL DPI");
+		return -EINVAL;
+	}
+	req.dpi = cpu_to_le32(cq->dpi->dpi);
+	req.cq_handle = cpu_to_le64(cq->cq_handle);
+
+	req.cq_size = cpu_to_le32(cq->hwq.max_elements);
+	pbl = &cq->hwq.pbl[PBL_LVL_0];
+	req.pg_size_lvl = cpu_to_le32(
+	    ((cq->hwq.level & CMDQ_CREATE_CQ_LVL_MASK) <<
+						CMDQ_CREATE_CQ_LVL_SFT) |
+	    (pbl->pg_size == ROCE_PG_SIZE_4K ? CMDQ_CREATE_CQ_PG_SIZE_PG_4K :
+	     pbl->pg_size == ROCE_PG_SIZE_8K ? CMDQ_CREATE_CQ_PG_SIZE_PG_8K :
+	     pbl->pg_size == ROCE_PG_SIZE_64K ? CMDQ_CREATE_CQ_PG_SIZE_PG_64K :
+	     pbl->pg_size == ROCE_PG_SIZE_2M ? CMDQ_CREATE_CQ_PG_SIZE_PG_2M :
+	     pbl->pg_size == ROCE_PG_SIZE_8M ? CMDQ_CREATE_CQ_PG_SIZE_PG_8M :
+	     pbl->pg_size == ROCE_PG_SIZE_1G ? CMDQ_CREATE_CQ_PG_SIZE_PG_1G :
+	     CMDQ_CREATE_CQ_PG_SIZE_PG_4K));
+
+	req.pbl = cpu_to_le64(pbl->pg_map_arr[0]);
+
+	req.cq_fco_cnq_id = cpu_to_le16(
+			((cq->cnq_hw_ring_id & CMDQ_CREATE_CQ_CNQ_ID_MASK) <<
+			 CMDQ_CREATE_CQ_CNQ_ID_SFT) | 0);
+
+	resp = (struct creq_create_cq_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 0);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: CREATE_CQ send failed");
+		return -EINVAL;
+	}
+	/**/
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: CREATE_CQ timed out");
+		rc = -ETIMEDOUT;
+		goto fail;
+	}
+	if (RCFW_RESP_STATUS(resp) ||
+	    RCFW_RESP_COOKIE(resp) != RCFW_CMDQ_COOKIE(req)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: CREATE_CQ failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			RCFW_RESP_STATUS(resp), RCFW_CMDQ_COOKIE(req),
+			RCFW_RESP_COOKIE(resp));
+		rc = -EINVAL;
+		goto fail;
+	}
+	cq->id = le32_to_cpu(resp->xid);
+	cq->dbr_base = res->dpi_tbl.dbr_bar_reg_iomem;
+	cq->period = BNXT_QPLIB_QUEUE_START_PERIOD;
+	init_waitqueue_head(&cq->waitq);
+
+	bnxt_qplib_arm_cq_enable(cq);
+	return 0;
+
+fail:
+	bnxt_qplib_free_hwq(res->pdev, &cq->hwq);
+exit:
+	return rc;
+}
+
+int bnxt_qplib_destroy_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_destroy_cq req;
+	struct creq_destroy_cq_resp *resp;
+	u16 cmd_flags = 0;
+
+	RCFW_CMD_PREP(req, DESTROY_CQ, cmd_flags);
+
+	req.cq_cid = cpu_to_le32(cq->id);
+	resp = (struct creq_destroy_cq_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 0);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: DESTROY_CQ send failed");
+		return -EINVAL;
+	}
+	/**/
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: DESTROY_CQ timed out");
+		return -ETIMEDOUT;
+	}
+	if (RCFW_RESP_STATUS(resp) ||
+	    RCFW_RESP_COOKIE(resp) != RCFW_CMDQ_COOKIE(req)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: DESTROY_CQ failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			RCFW_RESP_STATUS(resp), RCFW_CMDQ_COOKIE(req),
+			RCFW_RESP_COOKIE(resp));
+		return -EINVAL;
+	}
+	bnxt_qplib_free_hwq(res->pdev, &cq->hwq);
+	return 0;
+}
+
+void bnxt_qplib_req_notify_cq(struct bnxt_qplib_cq *cq, u32 arm_type)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cq->hwq.lock, flags);
+	if (arm_type)
+		bnxt_qplib_arm_cq(cq, arm_type);
+
+	spin_unlock_irqrestore(&cq->hwq.lock, flags);
+}
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h
index d5cd39e..1991eaa 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h
@@ -38,6 +38,49 @@
 
 #ifndef __BNXT_QPLIB_FP_H__
 #define __BNXT_QPLIB_FP_H__
+#define BNXT_QPLIB_MAX_CQE_ENTRY_SIZE	sizeof(struct cq_base)
+
+struct bnxt_qplib_cqe {
+	u8				status;
+	u8				type;
+	u8				opcode;
+	u32				length;
+	u64				wr_id;
+	u32				immdata_or_invrkey;
+	u64				qp_handle;
+	u64				mr_handle;
+	u16				flags;
+	u8				smac[6];
+	u32				src_qp;
+	u16				raweth_qp1_flags;
+	u16				raweth_qp1_errors;
+	u16				raweth_qp1_cfa_code;
+	u32				raweth_qp1_flags2;
+	u32				raweth_qp1_metadata;
+	u8				raweth_qp1_payload_offset;
+	u16				pkey_index;
+};
+
+#define BNXT_QPLIB_QUEUE_START_PERIOD		0x01
+struct bnxt_qplib_cq {
+	struct bnxt_qplib_dpi		*dpi;
+	void __iomem			*dbr_base;
+	u32				max_wqe;
+	u32				id;
+	u16				count;
+	u16				period;
+	struct bnxt_qplib_hwq		hwq;
+	u32				cnq_hw_ring_id;
+	bool				resize_in_progress;
+	struct scatterlist		*sghead;
+	u32				nmap;
+	u64				cq_handle;
+
+#define CQ_RESIZE_WAIT_TIME_MS		500
+	unsigned long			flags;
+#define CQ_FLAGS_RESIZE_IN_PROG		1
+	wait_queue_head_t		waitq;
+};
 
 #define BNXT_QPLIB_MAX_NQE_ENTRY_SIZE	sizeof(struct nq_base)
 
@@ -97,6 +140,10 @@ int bnxt_qplib_enable_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq,
 			 int (*srqn_handler)(struct bnxt_qplib_nq *nq,
 					     void *srq,
 					     u8 event));
+int bnxt_qplib_create_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq);
+int bnxt_qplib_destroy_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq);
+
+void bnxt_qplib_req_notify_cq(struct bnxt_qplib_cq *cq, u32 arm_type);
 void bnxt_qplib_free_nq(struct bnxt_qplib_nq *nq);
 int bnxt_qplib_alloc_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq);
 #endif /* __BNXT_QPLIB_FP_H__ */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
index 3417829..f316598 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
@@ -60,6 +60,16 @@
 #include "bnxt_re_ib_verbs.h"
 #include <rdma/bnxt_re_uverbs_abi.h>
 
+static int bnxt_re_copy_to_udata(struct bnxt_re_dev *rdev, void *data, int len,
+				 struct ib_udata *udata)
+{
+	int rc;
+
+	rc = ib_copy_to_udata(udata, data, len);
+
+	return rc ? -EFAULT : 0;
+}
+
 /* Device */
 struct net_device *bnxt_re_get_netdev(struct ib_device *ibdev, u8 port_num)
 {
@@ -492,6 +502,150 @@ struct ib_pd *bnxt_re_alloc_pd(struct ib_device *ibdev,
 	return ERR_PTR(rc);
 }
 
+/* Completion Queues */
+int bnxt_re_destroy_cq(struct ib_cq *ib_cq)
+{
+	struct bnxt_re_cq *cq = to_bnxt_re(ib_cq, struct bnxt_re_cq, ib_cq);
+	struct bnxt_re_dev *rdev = cq->rdev;
+	int rc;
+
+	rc = bnxt_qplib_destroy_cq(&rdev->qplib_res, &cq->qplib_cq);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev), "Failed to destroy HW CQ");
+		return rc;
+	}
+	if (cq->umem && !IS_ERR(cq->umem))
+		ib_umem_release(cq->umem);
+
+	if (cq) {
+		kfree(cq->cql);
+		kfree(cq);
+	}
+	atomic_dec(&rdev->cq_count);
+	rdev->nq.budget--;
+	return 0;
+}
+
+struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
+				const struct ib_cq_init_attr *attr,
+				struct ib_ucontext *context,
+				struct ib_udata *udata)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
+	struct bnxt_qplib_dev_attr *dev_attr = &rdev->dev_attr;
+	struct bnxt_re_cq *cq = NULL;
+	int rc, entries;
+	int cqe = attr->cqe;
+
+	/* Validate CQ fields */
+	if (cqe < 1 || cqe > dev_attr->max_cq_wqes) {
+		dev_err(rdev_to_dev(rdev), "Failed to create CQ -max exceeded");
+		return ERR_PTR(-EINVAL);
+	}
+	cq = kzalloc(sizeof(*cq), GFP_KERNEL);
+	if (!cq)
+		return ERR_PTR(-ENOMEM);
+
+	cq->rdev = rdev;
+	cq->qplib_cq.cq_handle = (u64)&cq->qplib_cq;
+
+	entries = roundup_pow_of_two(cqe + 1);
+	if (entries > dev_attr->max_cq_wqes + 1)
+		entries = dev_attr->max_cq_wqes + 1;
+
+	if (context) {
+		struct bnxt_re_cq_req req;
+		struct bnxt_re_ucontext *uctx = to_bnxt_re(context,
+						   struct bnxt_re_ucontext,
+						   ib_uctx);
+		if (ib_copy_from_udata(&req, udata, sizeof(req))) {
+			rc = -EFAULT;
+			goto fail;
+		}
+
+		cq->umem = ib_umem_get(context, req.cq_va,
+				       entries * sizeof(struct cq_base),
+				       IB_ACCESS_LOCAL_WRITE, 1);
+		if (IS_ERR(cq->umem)) {
+			rc = PTR_ERR(cq->umem);
+			goto fail;
+		}
+		cq->qplib_cq.sghead = cq->umem->sg_head.sgl;
+		cq->qplib_cq.nmap = cq->umem->nmap;
+		cq->qplib_cq.dpi = uctx->dpi;
+	} else {
+		cq->max_cql = entries > MAX_CQL_PER_POLL ? MAX_CQL_PER_POLL :
+					entries;
+		cq->max_cql = min_t(u32, entries, MAX_CQL_PER_POLL);
+		cq->cql = kcalloc(cq->max_cql, sizeof(struct bnxt_qplib_cqe),
+				  GFP_KERNEL);
+		if (!cq->cql) {
+			rc = -ENOMEM;
+			goto fail;
+		}
+
+		cq->qplib_cq.dpi = &rdev->dpi_privileged;
+		cq->qplib_cq.sghead = NULL;
+		cq->qplib_cq.nmap = 0;
+	}
+	cq->qplib_cq.max_wqe = entries;
+	cq->qplib_cq.cnq_hw_ring_id = rdev->nq.ring_id;
+
+	rc = bnxt_qplib_create_cq(&rdev->qplib_res, &cq->qplib_cq);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev), "Failed to create HW CQ");
+		goto fail;
+	}
+
+	cq->ib_cq.cqe = entries;
+	cq->cq_period = cq->qplib_cq.period;
+	rdev->nq.budget++;
+
+	atomic_inc(&rdev->cq_count);
+
+	if (context) {
+		struct bnxt_re_cq_resp resp;
+
+		resp.cqid = cq->qplib_cq.id;
+		resp.tail = cq->qplib_cq.hwq.cons;
+		resp.phase = cq->qplib_cq.period;
+		rc = bnxt_re_copy_to_udata(rdev, &resp, sizeof(resp), udata);
+		if (rc) {
+			dev_err(rdev_to_dev(rdev), "Failed to copy CQ udata");
+			bnxt_qplib_destroy_cq(&rdev->qplib_res, &cq->qplib_cq);
+			goto c2fail;
+		}
+	}
+
+	return &cq->ib_cq;
+
+c2fail:
+	if (context && cq->umem && !IS_ERR(cq->umem))
+		ib_umem_release(cq->umem);
+fail:
+	kfree(cq->cql);
+	kfree(cq);
+	return ERR_PTR(rc);
+}
+
+int bnxt_re_req_notify_cq(struct ib_cq *ib_cq,
+			  enum ib_cq_notify_flags ib_cqn_flags)
+{
+	struct bnxt_re_cq *cq = to_bnxt_re(ib_cq, struct bnxt_re_cq, ib_cq);
+	int type = 0;
+
+	/* Trigger on the very next completion */
+	if (ib_cqn_flags & IB_CQ_NEXT_COMP)
+		type = DBR_DBR_TYPE_CQ_ARMALL;
+	/* Trigger on the next solicited completion */
+	else if (ib_cqn_flags & IB_CQ_SOLICITED)
+		type = DBR_DBR_TYPE_CQ_ARMSE;
+
+	bnxt_qplib_req_notify_cq(&cq->qplib_cq, type);
+
+	return 0;
+}
+
 struct ib_ucontext *bnxt_re_alloc_ucontext(struct ib_device *ibdev,
 					   struct ib_udata *udata)
 {
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
index c10fd63..1efb3c8 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
@@ -51,6 +51,19 @@ struct bnxt_re_pd {
 	struct bnxt_qplib_dpi	dpi;
 };
 
+struct bnxt_re_cq {
+	struct bnxt_re_dev	*rdev;
+	spinlock_t              cq_lock;	/* protect cq */
+	u16			cq_count;
+	u16			cq_period;
+	struct ib_cq		ib_cq;
+	struct bnxt_qplib_cq	qplib_cq;
+	struct bnxt_qplib_cqe	*cql;
+#define MAX_CQL_PER_POLL	1024
+	u32			max_cql;
+	struct ib_umem		*umem;
+};
+
 struct bnxt_re_ucontext {
 	struct bnxt_re_dev	*rdev;
 	struct ib_ucontext	ib_uctx;
@@ -89,6 +102,12 @@ struct ib_pd *bnxt_re_alloc_pd(struct ib_device *ibdev,
 			       struct ib_ucontext *context,
 			       struct ib_udata *udata);
 int bnxt_re_dealloc_pd(struct ib_pd *pd);
+struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
+				const struct ib_cq_init_attr *attr,
+				struct ib_ucontext *context,
+				struct ib_udata *udata);
+int bnxt_re_destroy_cq(struct ib_cq *cq);
+int bnxt_re_req_notify_cq(struct ib_cq *cq, enum ib_cq_notify_flags flags);
 struct ib_ucontext *bnxt_re_alloc_ucontext(struct ib_device *ibdev,
 					   struct ib_udata *udata);
 int bnxt_re_dealloc_ucontext(struct ib_ucontext *context);
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
index 313798f..2e20e2c 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -440,6 +440,10 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 
 	ibdev->alloc_pd			= bnxt_re_alloc_pd;
 	ibdev->dealloc_pd		= bnxt_re_dealloc_pd;
+
+	ibdev->create_cq		= bnxt_re_create_cq;
+	ibdev->destroy_cq		= bnxt_re_destroy_cq;
+	ibdev->req_notify_cq		= bnxt_re_req_notify_cq;
 	ibdev->alloc_ucontext		= bnxt_re_alloc_ucontext;
 	ibdev->dealloc_ucontext		= bnxt_re_dealloc_ucontext;
 	ibdev->mmap			= bnxt_re_mmap;
diff --git a/include/uapi/rdma/bnxt_re_uverbs_abi.h b/include/uapi/rdma/bnxt_re_uverbs_abi.h
index 3815184..9080cf8 100644
--- a/include/uapi/rdma/bnxt_re_uverbs_abi.h
+++ b/include/uapi/rdma/bnxt_re_uverbs_abi.h
@@ -55,4 +55,15 @@ struct bnxt_re_pd_resp {
 	__u64 dbr;
 } __packed;
 
+struct bnxt_re_cq_req {
+	__u64 cq_va;
+	__u64 cq_handle;
+} __packed;
+
+struct bnxt_re_cq_resp {
+	__u32 cqid;
+	__u32 tail;
+	__u32 phase;
+} __packed;
+
 #endif /* __BNXT_RE_UVERBS_ABI_H__*/
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
