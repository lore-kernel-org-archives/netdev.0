From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH for bnxt_re V4 13/21] RDMA/bnxt_re: Support QP verbs
Date: Wed, 21 Dec 2016 03:42:02 -0800
Message-ID: <1482320530-5344-14-git-send-email-selvin.xavier@broadcom.com>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f169.google.com ([209.85.210.169]:32853 "EHLO
        mail-wj0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758008AbcLULnm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 06:43:42 -0500
Received: by mail-wj0-f169.google.com with SMTP id xy5so199970872wjc.0
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 03:43:40 -0800 (PST)
In-Reply-To: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements create_qp, destroy_qp, query_qp and modify_qp verbs.

v2: Fixed sparse warnings
v3: Splits __filter_modify_flags function to avoid nested switch cases.
    Removes unwanted macros. Also, fix the endianness related issues
    reported by sparse.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxt_re/bnxt_re.h  |  14 +
 drivers/infiniband/hw/bnxt_re/ib_verbs.c | 764 +++++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/ib_verbs.h |  21 +
 drivers/infiniband/hw/bnxt_re/main.c     |   6 +
 drivers/infiniband/hw/bnxt_re/qplib_fp.c | 862 +++++++++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/qplib_fp.h | 272 ++++++++++
 include/uapi/rdma/bnxt_re-abi.h          |  11 +
 7 files changed, 1950 insertions(+)

diff --git a/drivers/infiniband/hw/bnxt_re/bnxt_re.h b/drivers/infiniband/hw/bnxt_re/bnxt_re.h
index cac1173..f53ebd9 100644
--- a/drivers/infiniband/hw/bnxt_re/bnxt_re.h
+++ b/drivers/infiniband/hw/bnxt_re/bnxt_re.h
@@ -64,6 +64,14 @@ struct bnxt_re_work {
 	struct net_device	*vlan_dev;
 };
 
+struct bnxt_re_sqp_entries {
+	struct bnxt_qplib_sge sge;
+	u64 wrid;
+	/* For storing the actual qp1 cqe */
+	struct bnxt_qplib_cqe cqe;
+	struct bnxt_re_qp *qp1_qp;
+};
+
 #define BNXT_RE_MIN_MSIX		2
 #define BNXT_RE_MAX_MSIX		16
 #define BNXT_RE_AEQ_IDX			0
@@ -112,6 +120,12 @@ struct bnxt_re_dev {
 	atomic_t			mw_count;
 	/* Max of 2 lossless traffic class supported per port */
 	u16				cosq[2];
+
+	/* QP for for handling QP1 packets */
+	u32				sqp_id;
+	struct bnxt_re_qp		*qp1_sqp;
+	struct bnxt_re_ah		*sqp_ah;
+	struct bnxt_re_sqp_entries sqp_tbl[1024];
 };
 
 #define to_bnxt_re_dev(ptr, member)	\
diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.c b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
index 8af6436..2189cad 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.c
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
@@ -639,6 +639,484 @@ int bnxt_re_query_ah(struct ib_ah *ib_ah, struct ib_ah_attr *ah_attr)
 	return 0;
 }
 
+/* Queue Pairs */
+int bnxt_re_destroy_qp(struct ib_qp *ib_qp)
+{
+	struct bnxt_re_qp *qp = container_of(ib_qp, struct bnxt_re_qp, ib_qp);
+	struct bnxt_re_dev *rdev = qp->rdev;
+	int rc;
+
+	rc = bnxt_qplib_destroy_qp(&rdev->qplib_res, &qp->qplib_qp);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev), "Failed to destroy HW QP");
+		return rc;
+	}
+	if (ib_qp->qp_type == IB_QPT_GSI && rdev->qp1_sqp) {
+		rc = bnxt_qplib_destroy_ah(&rdev->qplib_res,
+					   &rdev->sqp_ah->qplib_ah);
+		if (rc) {
+			dev_err(rdev_to_dev(rdev),
+				"Failed to destroy HW AH for shadow QP");
+			return rc;
+		}
+
+		rc = bnxt_qplib_destroy_qp(&rdev->qplib_res,
+					   &rdev->qp1_sqp->qplib_qp);
+		if (rc) {
+			dev_err(rdev_to_dev(rdev),
+				"Failed to destroy Shadow QP");
+			return rc;
+		}
+		mutex_lock(&rdev->qp_lock);
+		list_del(&rdev->qp1_sqp->list);
+		atomic_dec(&rdev->qp_count);
+		mutex_unlock(&rdev->qp_lock);
+
+		kfree(rdev->sqp_ah);
+		kfree(rdev->qp1_sqp);
+	}
+
+	if (qp->rumem && !IS_ERR(qp->rumem))
+		ib_umem_release(qp->rumem);
+	if (qp->sumem && !IS_ERR(qp->sumem))
+		ib_umem_release(qp->sumem);
+
+	mutex_lock(&rdev->qp_lock);
+	list_del(&qp->list);
+	atomic_dec(&rdev->qp_count);
+	mutex_unlock(&rdev->qp_lock);
+	kfree(qp);
+	return 0;
+}
+
+static u8 __from_ib_qp_type(enum ib_qp_type type)
+{
+	switch (type) {
+	case IB_QPT_GSI:
+		return CMDQ_CREATE_QP1_TYPE_GSI;
+	case IB_QPT_RC:
+		return CMDQ_CREATE_QP_TYPE_RC;
+	case IB_QPT_UD:
+		return CMDQ_CREATE_QP_TYPE_UD;
+	case IB_QPT_RAW_ETHERTYPE:
+		return CMDQ_CREATE_QP_TYPE_RAW_ETHERTYPE;
+	default:
+		return IB_QPT_MAX;
+	}
+}
+
+static int bnxt_re_init_user_qp(struct bnxt_re_dev *rdev, struct bnxt_re_pd *pd,
+				struct bnxt_re_qp *qp, struct ib_udata *udata)
+{
+	struct bnxt_re_qp_req ureq;
+	struct bnxt_qplib_qp *qplib_qp = &qp->qplib_qp;
+	struct ib_umem *umem;
+	int bytes = 0;
+	struct ib_ucontext *context = pd->ib_pd.uobject->context;
+	struct bnxt_re_ucontext *cntx = container_of(context,
+						     struct bnxt_re_ucontext,
+						     ib_uctx);
+	if (ib_copy_from_udata(&ureq, udata, sizeof(ureq)))
+		return -EFAULT;
+
+	bytes = (qplib_qp->sq.max_wqe * BNXT_QPLIB_MAX_SQE_ENTRY_SIZE);
+	/* Consider mapping PSN search memory only for RC QPs. */
+	if (qplib_qp->type == CMDQ_CREATE_QP_TYPE_RC)
+		bytes += (qplib_qp->sq.max_wqe * sizeof(struct sq_psn_search));
+	bytes = PAGE_ALIGN(bytes);
+	umem = ib_umem_get(context, ureq.qpsva, bytes,
+			   IB_ACCESS_LOCAL_WRITE, 1);
+	if (IS_ERR(umem))
+		return PTR_ERR(umem);
+
+	qp->sumem = umem;
+	qplib_qp->sq.sglist = umem->sg_head.sgl;
+	qplib_qp->sq.nmap = umem->nmap;
+	qplib_qp->qp_handle = ureq.qp_handle;
+
+	if (!qp->qplib_qp.srq) {
+		bytes = (qplib_qp->rq.max_wqe * BNXT_QPLIB_MAX_RQE_ENTRY_SIZE);
+		bytes = PAGE_ALIGN(bytes);
+		umem = ib_umem_get(context, ureq.qprva, bytes,
+				   IB_ACCESS_LOCAL_WRITE, 1);
+		if (IS_ERR(umem))
+			goto rqfail;
+		qp->rumem = umem;
+		qplib_qp->rq.sglist = umem->sg_head.sgl;
+		qplib_qp->rq.nmap = umem->nmap;
+	}
+
+	qplib_qp->dpi = cntx->dpi;
+	return 0;
+rqfail:
+	ib_umem_release(qp->sumem);
+	qp->sumem = NULL;
+	qplib_qp->sq.sglist = NULL;
+	qplib_qp->sq.nmap = 0;
+
+	return PTR_ERR(umem);
+}
+
+static struct bnxt_re_ah *bnxt_re_create_shadow_qp_ah
+				(struct bnxt_re_pd *pd,
+				 struct bnxt_qplib_res *qp1_res,
+				 struct bnxt_qplib_qp *qp1_qp)
+{
+	struct bnxt_re_dev *rdev = pd->rdev;
+	struct bnxt_re_ah *ah;
+	union ib_gid sgid;
+	int rc;
+
+	ah = kzalloc(sizeof(*ah), GFP_KERNEL);
+	if (!ah)
+		return NULL;
+
+	memset(ah, 0, sizeof(*ah));
+	ah->rdev = rdev;
+	ah->qplib_ah.pd = &pd->qplib_pd;
+
+	rc = bnxt_re_query_gid(&rdev->ibdev, 1, 0, &sgid);
+	if (rc)
+		goto fail;
+
+	/* supply the dgid data same as sgid */
+	memcpy(ah->qplib_ah.dgid.data, &sgid.raw,
+	       sizeof(union ib_gid));
+	ah->qplib_ah.sgid_index = 0;
+
+	ah->qplib_ah.traffic_class = 0;
+	ah->qplib_ah.flow_label = 0;
+	ah->qplib_ah.hop_limit = 1;
+	ah->qplib_ah.sl = 0;
+	/* Have DMAC same as SMAC */
+	ether_addr_copy(ah->qplib_ah.dmac, rdev->netdev->dev_addr);
+
+	rc = bnxt_qplib_create_ah(&rdev->qplib_res, &ah->qplib_ah);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev),
+			"Failed to allocate HW AH for Shadow QP");
+		goto fail;
+	}
+
+	return ah;
+
+fail:
+	kfree(ah);
+	return NULL;
+}
+
+static struct bnxt_re_qp *bnxt_re_create_shadow_qp
+				(struct bnxt_re_pd *pd,
+				 struct bnxt_qplib_res *qp1_res,
+				 struct bnxt_qplib_qp *qp1_qp)
+{
+	struct bnxt_re_dev *rdev = pd->rdev;
+	struct bnxt_re_qp *qp;
+	int rc;
+
+	qp = kzalloc(sizeof(*qp), GFP_KERNEL);
+	if (!qp)
+		return NULL;
+
+	memset(qp, 0, sizeof(*qp));
+	qp->rdev = rdev;
+
+	/* Initialize the shadow QP structure from the QP1 values */
+	ether_addr_copy(qp->qplib_qp.smac, rdev->netdev->dev_addr);
+
+	qp->qplib_qp.pd = &pd->qplib_pd;
+	qp->qplib_qp.qp_handle = (u64)(unsigned long)(&qp->qplib_qp);
+	qp->qplib_qp.type = IB_QPT_UD;
+
+	qp->qplib_qp.max_inline_data = 0;
+	qp->qplib_qp.sig_type = true;
+
+	/* Shadow QP SQ depth should be same as QP1 RQ depth */
+	qp->qplib_qp.sq.max_wqe = qp1_qp->rq.max_wqe;
+	qp->qplib_qp.sq.max_sge = 2;
+
+	qp->qplib_qp.scq = qp1_qp->scq;
+	qp->qplib_qp.rcq = qp1_qp->rcq;
+
+	qp->qplib_qp.rq.max_wqe = qp1_qp->rq.max_wqe;
+	qp->qplib_qp.rq.max_sge = qp1_qp->rq.max_sge;
+
+	qp->qplib_qp.mtu = qp1_qp->mtu;
+
+	qp->qplib_qp.sq_hdr_buf_size = 0;
+	qp->qplib_qp.rq_hdr_buf_size = BNXT_QPLIB_MAX_GRH_HDR_SIZE_IPV6;
+	qp->qplib_qp.dpi = &rdev->dpi_privileged;
+
+	rc = bnxt_qplib_create_qp(qp1_res, &qp->qplib_qp);
+	if (rc)
+		goto fail;
+
+	rdev->sqp_id = qp->qplib_qp.id;
+
+	spin_lock_init(&qp->sq_lock);
+	INIT_LIST_HEAD(&qp->list);
+	mutex_lock(&rdev->qp_lock);
+	list_add_tail(&qp->list, &rdev->qp_list);
+	atomic_inc(&rdev->qp_count);
+	mutex_unlock(&rdev->qp_lock);
+	return qp;
+fail:
+	kfree(qp);
+	return NULL;
+}
+
+struct ib_qp *bnxt_re_create_qp(struct ib_pd *ib_pd,
+				struct ib_qp_init_attr *qp_init_attr,
+				struct ib_udata *udata)
+{
+	struct bnxt_re_pd *pd = container_of(ib_pd, struct bnxt_re_pd, ib_pd);
+	struct bnxt_re_dev *rdev = pd->rdev;
+	struct bnxt_qplib_dev_attr *dev_attr = &rdev->dev_attr;
+	struct bnxt_re_qp *qp;
+	struct bnxt_re_srq *srq;
+	struct bnxt_re_cq *cq;
+	int rc, entries;
+
+	if ((qp_init_attr->cap.max_send_wr > dev_attr->max_qp_wqes) ||
+	    (qp_init_attr->cap.max_recv_wr > dev_attr->max_qp_wqes) ||
+	    (qp_init_attr->cap.max_send_sge > dev_attr->max_qp_sges) ||
+	    (qp_init_attr->cap.max_recv_sge > dev_attr->max_qp_sges) ||
+	    (qp_init_attr->cap.max_inline_data > dev_attr->max_inline_data))
+		return ERR_PTR(-EINVAL);
+
+	qp = kzalloc(sizeof(*qp), GFP_KERNEL);
+	if (!qp)
+		return ERR_PTR(-ENOMEM);
+
+	qp->rdev = rdev;
+	ether_addr_copy(qp->qplib_qp.smac, rdev->netdev->dev_addr);
+	qp->qplib_qp.pd = &pd->qplib_pd;
+	qp->qplib_qp.qp_handle = (u64)(unsigned long)(&qp->qplib_qp);
+	qp->qplib_qp.type = __from_ib_qp_type(qp_init_attr->qp_type);
+	if (qp->qplib_qp.type == IB_QPT_MAX) {
+		dev_err(rdev_to_dev(rdev), "QP type 0x%x not supported",
+			qp->qplib_qp.type);
+		rc = -EINVAL;
+		goto fail;
+	}
+	qp->qplib_qp.max_inline_data = qp_init_attr->cap.max_inline_data;
+	qp->qplib_qp.sig_type = ((qp_init_attr->sq_sig_type ==
+				  IB_SIGNAL_ALL_WR) ? true : false);
+
+	entries = roundup_pow_of_two(qp_init_attr->cap.max_send_wr + 1);
+	if (entries > dev_attr->max_qp_wqes + 1)
+		entries = dev_attr->max_qp_wqes + 1;
+	qp->qplib_qp.sq.max_wqe = entries;
+
+	qp->qplib_qp.sq.max_sge = qp_init_attr->cap.max_send_sge;
+	if (qp->qplib_qp.sq.max_sge > dev_attr->max_qp_sges)
+		qp->qplib_qp.sq.max_sge = dev_attr->max_qp_sges;
+
+	if (qp_init_attr->send_cq) {
+		cq = container_of(qp_init_attr->send_cq, struct bnxt_re_cq,
+				  ib_cq);
+		if (!cq) {
+			dev_err(rdev_to_dev(rdev), "Send CQ not found");
+			rc = -EINVAL;
+			goto fail;
+		}
+		qp->qplib_qp.scq = &cq->qplib_cq;
+	}
+
+	if (qp_init_attr->recv_cq) {
+		cq = container_of(qp_init_attr->recv_cq, struct bnxt_re_cq,
+				  ib_cq);
+		if (!cq) {
+			dev_err(rdev_to_dev(rdev), "Receive CQ not found");
+			rc = -EINVAL;
+			goto fail;
+		}
+		qp->qplib_qp.rcq = &cq->qplib_cq;
+	}
+
+	if (qp_init_attr->srq) {
+		dev_err(rdev_to_dev(rdev), "SRQ not supported");
+		rc = -ENOTSUPP;
+		goto fail;
+	} else {
+		/* Allocate 1 more than what's provided so posting max doesn't
+		 * mean empty
+		 */
+		entries = roundup_pow_of_two(qp_init_attr->cap.max_recv_wr + 1);
+		if (entries > dev_attr->max_qp_wqes + 1)
+			entries = dev_attr->max_qp_wqes + 1;
+		qp->qplib_qp.rq.max_wqe = entries;
+
+		qp->qplib_qp.rq.max_sge = qp_init_attr->cap.max_recv_sge;
+		if (qp->qplib_qp.rq.max_sge > dev_attr->max_qp_sges)
+			qp->qplib_qp.rq.max_sge = dev_attr->max_qp_sges;
+	}
+
+	qp->qplib_qp.mtu = ib_mtu_enum_to_int(iboe_get_mtu(rdev->netdev->mtu));
+
+	if (qp_init_attr->qp_type == IB_QPT_GSI) {
+		qp->qplib_qp.rq.max_sge = dev_attr->max_qp_sges;
+		if (qp->qplib_qp.rq.max_sge > dev_attr->max_qp_sges)
+			qp->qplib_qp.rq.max_sge = dev_attr->max_qp_sges;
+		qp->qplib_qp.sq.max_sge++;
+		if (qp->qplib_qp.sq.max_sge > dev_attr->max_qp_sges)
+			qp->qplib_qp.sq.max_sge = dev_attr->max_qp_sges;
+
+		qp->qplib_qp.rq_hdr_buf_size =
+					BNXT_QPLIB_MAX_QP1_RQ_HDR_SIZE_V2;
+
+		qp->qplib_qp.sq_hdr_buf_size =
+					BNXT_QPLIB_MAX_QP1_SQ_HDR_SIZE_V2;
+		qp->qplib_qp.dpi = &rdev->dpi_privileged;
+		rc = bnxt_qplib_create_qp1(&rdev->qplib_res, &qp->qplib_qp);
+		if (rc) {
+			dev_err(rdev_to_dev(rdev), "Failed to create HW QP1");
+			goto fail;
+		}
+		/* Create a shadow QP to handle the QP1 traffic */
+		rdev->qp1_sqp = bnxt_re_create_shadow_qp(pd, &rdev->qplib_res,
+							 &qp->qplib_qp);
+		if (!rdev->qp1_sqp) {
+			rc = -EINVAL;
+			dev_err(rdev_to_dev(rdev),
+				"Failed to create Shadow QP for QP1");
+			goto qp_destroy;
+		}
+		rdev->sqp_ah = bnxt_re_create_shadow_qp_ah(pd, &rdev->qplib_res,
+							   &qp->qplib_qp);
+		if (!rdev->sqp_ah) {
+			bnxt_qplib_destroy_qp(&rdev->qplib_res,
+					      &rdev->qp1_sqp->qplib_qp);
+			rc = -EINVAL;
+			dev_err(rdev_to_dev(rdev),
+				"Failed to create AH entry for ShadowQP");
+			goto qp_destroy;
+		}
+
+	} else {
+		qp->qplib_qp.max_rd_atomic = dev_attr->max_qp_rd_atom;
+		qp->qplib_qp.max_dest_rd_atomic = dev_attr->max_qp_init_rd_atom;
+		if (udata) {
+			rc = bnxt_re_init_user_qp(rdev, pd, qp, udata);
+			if (rc)
+				goto fail;
+		} else {
+			qp->qplib_qp.dpi = &rdev->dpi_privileged;
+		}
+
+		rc = bnxt_qplib_create_qp(&rdev->qplib_res, &qp->qplib_qp);
+		if (rc) {
+			dev_err(rdev_to_dev(rdev), "Failed to create HW QP");
+			goto fail;
+		}
+	}
+
+	qp->ib_qp.qp_num = qp->qplib_qp.id;
+	spin_lock_init(&qp->sq_lock);
+
+	if (udata) {
+		struct bnxt_re_qp_resp resp;
+
+		resp.qpid = qp->ib_qp.qp_num;
+		resp.rsvd = 0;
+		rc = ib_copy_to_udata(udata, &resp, sizeof(resp));
+		if (rc) {
+			dev_err(rdev_to_dev(rdev), "Failed to copy QP udata");
+			goto qp_destroy;
+		}
+	}
+	INIT_LIST_HEAD(&qp->list);
+	mutex_lock(&rdev->qp_lock);
+	list_add_tail(&qp->list, &rdev->qp_list);
+	atomic_inc(&rdev->qp_count);
+	mutex_unlock(&rdev->qp_lock);
+
+	return &qp->ib_qp;
+qp_destroy:
+	bnxt_qplib_destroy_qp(&rdev->qplib_res, &qp->qplib_qp);
+fail:
+	kfree(qp);
+	return ERR_PTR(rc);
+}
+
+static u8 __from_ib_qp_state(enum ib_qp_state state)
+{
+	switch (state) {
+	case IB_QPS_RESET:
+		return CMDQ_MODIFY_QP_NEW_STATE_RESET;
+	case IB_QPS_INIT:
+		return CMDQ_MODIFY_QP_NEW_STATE_INIT;
+	case IB_QPS_RTR:
+		return CMDQ_MODIFY_QP_NEW_STATE_RTR;
+	case IB_QPS_RTS:
+		return CMDQ_MODIFY_QP_NEW_STATE_RTS;
+	case IB_QPS_SQD:
+		return CMDQ_MODIFY_QP_NEW_STATE_SQD;
+	case IB_QPS_SQE:
+		return CMDQ_MODIFY_QP_NEW_STATE_SQE;
+	case IB_QPS_ERR:
+	default:
+		return CMDQ_MODIFY_QP_NEW_STATE_ERR;
+	}
+}
+
+static enum ib_qp_state __to_ib_qp_state(u8 state)
+{
+	switch (state) {
+	case CMDQ_MODIFY_QP_NEW_STATE_RESET:
+		return IB_QPS_RESET;
+	case CMDQ_MODIFY_QP_NEW_STATE_INIT:
+		return IB_QPS_INIT;
+	case CMDQ_MODIFY_QP_NEW_STATE_RTR:
+		return IB_QPS_RTR;
+	case CMDQ_MODIFY_QP_NEW_STATE_RTS:
+		return IB_QPS_RTS;
+	case CMDQ_MODIFY_QP_NEW_STATE_SQD:
+		return IB_QPS_SQD;
+	case CMDQ_MODIFY_QP_NEW_STATE_SQE:
+		return IB_QPS_SQE;
+	case CMDQ_MODIFY_QP_NEW_STATE_ERR:
+	default:
+		return IB_QPS_ERR;
+	}
+}
+
+static u32 __from_ib_mtu(enum ib_mtu mtu)
+{
+	switch (mtu) {
+	case IB_MTU_256:
+		return CMDQ_MODIFY_QP_PATH_MTU_MTU_256;
+	case IB_MTU_512:
+		return CMDQ_MODIFY_QP_PATH_MTU_MTU_512;
+	case IB_MTU_1024:
+		return CMDQ_MODIFY_QP_PATH_MTU_MTU_1024;
+	case IB_MTU_2048:
+		return CMDQ_MODIFY_QP_PATH_MTU_MTU_2048;
+	case IB_MTU_4096:
+		return CMDQ_MODIFY_QP_PATH_MTU_MTU_4096;
+	default:
+		return CMDQ_MODIFY_QP_PATH_MTU_MTU_2048;
+	}
+}
+
+static enum ib_mtu __to_ib_mtu(u32 mtu)
+{
+	switch (mtu & CREQ_QUERY_QP_RESP_SB_PATH_MTU_MASK) {
+	case CMDQ_MODIFY_QP_PATH_MTU_MTU_256:
+		return IB_MTU_256;
+	case CMDQ_MODIFY_QP_PATH_MTU_MTU_512:
+		return IB_MTU_512;
+	case CMDQ_MODIFY_QP_PATH_MTU_MTU_1024:
+		return IB_MTU_1024;
+	case CMDQ_MODIFY_QP_PATH_MTU_MTU_2048:
+		return IB_MTU_2048;
+	case CMDQ_MODIFY_QP_PATH_MTU_MTU_4096:
+		return IB_MTU_4096;
+	default:
+		return IB_MTU_2048;
+	}
+}
+
 static int __from_ib_access_flags(int iflags)
 {
 	int qflags = 0;
@@ -681,6 +1159,292 @@ static enum ib_access_flags __to_ib_access_flags(int qflags)
 	return iflags;
 };
 
+static int bnxt_re_modify_shadow_qp(struct bnxt_re_dev *rdev,
+				    struct bnxt_re_qp *qp1_qp,
+				    int qp_attr_mask)
+{
+	struct bnxt_re_qp *qp = rdev->qp1_sqp;
+	int rc = 0;
+
+	if (qp_attr_mask & IB_QP_STATE) {
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_STATE;
+		qp->qplib_qp.state = qp1_qp->qplib_qp.state;
+	}
+	if (qp_attr_mask & IB_QP_PKEY_INDEX) {
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_PKEY;
+		qp->qplib_qp.pkey_index = qp1_qp->qplib_qp.pkey_index;
+	}
+
+	if (qp_attr_mask & IB_QP_QKEY) {
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_QKEY;
+		/* Using a Random  QKEY */
+		qp->qplib_qp.qkey = 0x81818181;
+	}
+	if (qp_attr_mask & IB_QP_SQ_PSN) {
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_SQ_PSN;
+		qp->qplib_qp.sq.psn = qp1_qp->qplib_qp.sq.psn;
+	}
+
+	rc = bnxt_qplib_modify_qp(&rdev->qplib_res, &qp->qplib_qp);
+	if (rc)
+		dev_err(rdev_to_dev(rdev),
+			"Failed to modify Shadow QP for QP1");
+	return rc;
+}
+
+int bnxt_re_modify_qp(struct ib_qp *ib_qp, struct ib_qp_attr *qp_attr,
+		      int qp_attr_mask, struct ib_udata *udata)
+{
+	struct bnxt_re_qp *qp = container_of(ib_qp, struct bnxt_re_qp, ib_qp);
+	struct bnxt_re_dev *rdev = qp->rdev;
+	struct bnxt_qplib_dev_attr *dev_attr = &rdev->dev_attr;
+	enum ib_qp_state curr_qp_state, new_qp_state;
+	int rc, entries;
+	int status;
+	union ib_gid sgid;
+	struct ib_gid_attr sgid_attr;
+	u8 nw_type;
+
+	qp->qplib_qp.modify_flags = 0;
+	if (qp_attr_mask & IB_QP_STATE) {
+		curr_qp_state = __to_ib_qp_state(qp->qplib_qp.cur_qp_state);
+		new_qp_state = qp_attr->qp_state;
+		if (!ib_modify_qp_is_ok(curr_qp_state, new_qp_state,
+					ib_qp->qp_type, qp_attr_mask,
+					IB_LINK_LAYER_ETHERNET)) {
+			dev_err(rdev_to_dev(rdev),
+				"Invalid attribute mask: %#x specified ",
+				qp_attr_mask);
+			dev_err(rdev_to_dev(rdev),
+				"for qpn: %#x type: %#x",
+				ib_qp->qp_num, ib_qp->qp_type);
+			dev_err(rdev_to_dev(rdev),
+				"curr_qp_state=0x%x, new_qp_state=0x%x\n",
+				curr_qp_state, new_qp_state);
+			return -EINVAL;
+		}
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_STATE;
+		qp->qplib_qp.state = __from_ib_qp_state(qp_attr->qp_state);
+	}
+	if (qp_attr_mask & IB_QP_EN_SQD_ASYNC_NOTIFY) {
+		qp->qplib_qp.modify_flags |=
+				CMDQ_MODIFY_QP_MODIFY_MASK_EN_SQD_ASYNC_NOTIFY;
+		qp->qplib_qp.en_sqd_async_notify = true;
+	}
+	if (qp_attr_mask & IB_QP_ACCESS_FLAGS) {
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_ACCESS;
+		qp->qplib_qp.access =
+			__from_ib_access_flags(qp_attr->qp_access_flags);
+		/* LOCAL_WRITE access must be set to allow RC receive */
+		qp->qplib_qp.access |= BNXT_QPLIB_ACCESS_LOCAL_WRITE;
+	}
+	if (qp_attr_mask & IB_QP_PKEY_INDEX) {
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_PKEY;
+		qp->qplib_qp.pkey_index = qp_attr->pkey_index;
+	}
+	if (qp_attr_mask & IB_QP_QKEY) {
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_QKEY;
+		qp->qplib_qp.qkey = qp_attr->qkey;
+	}
+	if (qp_attr_mask & IB_QP_AV) {
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_DGID |
+				     CMDQ_MODIFY_QP_MODIFY_MASK_FLOW_LABEL |
+				     CMDQ_MODIFY_QP_MODIFY_MASK_SGID_INDEX |
+				     CMDQ_MODIFY_QP_MODIFY_MASK_HOP_LIMIT |
+				     CMDQ_MODIFY_QP_MODIFY_MASK_TRAFFIC_CLASS |
+				     CMDQ_MODIFY_QP_MODIFY_MASK_DEST_MAC |
+				     CMDQ_MODIFY_QP_MODIFY_MASK_VLAN_ID;
+		memcpy(qp->qplib_qp.ah.dgid.data, qp_attr->ah_attr.grh.dgid.raw,
+		       sizeof(qp->qplib_qp.ah.dgid.data));
+		qp->qplib_qp.ah.flow_label = qp_attr->ah_attr.grh.flow_label;
+		/* If RoCE V2 is enabled, stack will have two entries for
+		 * each GID entry. Avoiding this duplicte entry in HW. Dividing
+		 * the GID index by 2 for RoCE V2
+		 */
+		qp->qplib_qp.ah.sgid_index =
+					qp_attr->ah_attr.grh.sgid_index / 2;
+		qp->qplib_qp.ah.host_sgid_index =
+					qp_attr->ah_attr.grh.sgid_index;
+		qp->qplib_qp.ah.hop_limit = qp_attr->ah_attr.grh.hop_limit;
+		qp->qplib_qp.ah.traffic_class =
+					qp_attr->ah_attr.grh.traffic_class;
+		qp->qplib_qp.ah.sl = qp_attr->ah_attr.sl;
+		ether_addr_copy(qp->qplib_qp.ah.dmac, qp_attr->ah_attr.dmac);
+
+		status = ib_get_cached_gid(&rdev->ibdev, 1,
+					   qp_attr->ah_attr.grh.sgid_index,
+					   &sgid, &sgid_attr);
+		if (!status && sgid_attr.ndev) {
+			memcpy(qp->qplib_qp.smac, sgid_attr.ndev->dev_addr,
+			       ETH_ALEN);
+			dev_put(sgid_attr.ndev);
+			nw_type = ib_gid_to_network_type(sgid_attr.gid_type,
+							 &sgid);
+			switch (nw_type) {
+			case RDMA_NETWORK_IPV4:
+				qp->qplib_qp.nw_type =
+					CMDQ_MODIFY_QP_NETWORK_TYPE_ROCEV2_IPV4;
+				break;
+			case RDMA_NETWORK_IPV6:
+				qp->qplib_qp.nw_type =
+					CMDQ_MODIFY_QP_NETWORK_TYPE_ROCEV2_IPV6;
+				break;
+			default:
+				qp->qplib_qp.nw_type =
+					CMDQ_MODIFY_QP_NETWORK_TYPE_ROCEV1;
+				break;
+			}
+		}
+	}
+
+	if (qp_attr_mask & IB_QP_PATH_MTU) {
+		qp->qplib_qp.modify_flags |=
+				CMDQ_MODIFY_QP_MODIFY_MASK_PATH_MTU;
+		qp->qplib_qp.path_mtu = __from_ib_mtu(qp_attr->path_mtu);
+	} else if (qp_attr->qp_state == IB_QPS_RTR) {
+		qp->qplib_qp.modify_flags |=
+			CMDQ_MODIFY_QP_MODIFY_MASK_PATH_MTU;
+		qp->qplib_qp.path_mtu =
+			__from_ib_mtu(iboe_get_mtu(rdev->netdev->mtu));
+	}
+
+	if (qp_attr_mask & IB_QP_TIMEOUT) {
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_TIMEOUT;
+		qp->qplib_qp.timeout = qp_attr->timeout;
+	}
+	if (qp_attr_mask & IB_QP_RETRY_CNT) {
+		qp->qplib_qp.modify_flags |=
+				CMDQ_MODIFY_QP_MODIFY_MASK_RETRY_CNT;
+		qp->qplib_qp.retry_cnt = qp_attr->retry_cnt;
+	}
+	if (qp_attr_mask & IB_QP_RNR_RETRY) {
+		qp->qplib_qp.modify_flags |=
+				CMDQ_MODIFY_QP_MODIFY_MASK_RNR_RETRY;
+		qp->qplib_qp.rnr_retry = qp_attr->rnr_retry;
+	}
+	if (qp_attr_mask & IB_QP_MIN_RNR_TIMER) {
+		qp->qplib_qp.modify_flags |=
+				CMDQ_MODIFY_QP_MODIFY_MASK_MIN_RNR_TIMER;
+		qp->qplib_qp.min_rnr_timer = qp_attr->min_rnr_timer;
+	}
+	if (qp_attr_mask & IB_QP_RQ_PSN) {
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_RQ_PSN;
+		qp->qplib_qp.rq.psn = qp_attr->rq_psn;
+	}
+	if (qp_attr_mask & IB_QP_MAX_QP_RD_ATOMIC) {
+		qp->qplib_qp.modify_flags |=
+				CMDQ_MODIFY_QP_MODIFY_MASK_MAX_RD_ATOMIC;
+		qp->qplib_qp.max_rd_atomic = qp_attr->max_rd_atomic;
+	}
+	if (qp_attr_mask & IB_QP_SQ_PSN) {
+		qp->qplib_qp.modify_flags |= CMDQ_MODIFY_QP_MODIFY_MASK_SQ_PSN;
+		qp->qplib_qp.sq.psn = qp_attr->sq_psn;
+	}
+	if (qp_attr_mask & IB_QP_MAX_DEST_RD_ATOMIC) {
+		qp->qplib_qp.modify_flags |=
+				CMDQ_MODIFY_QP_MODIFY_MASK_MAX_DEST_RD_ATOMIC;
+		qp->qplib_qp.max_dest_rd_atomic = qp_attr->max_dest_rd_atomic;
+	}
+	if (qp_attr_mask & IB_QP_CAP) {
+		qp->qplib_qp.modify_flags |=
+				CMDQ_MODIFY_QP_MODIFY_MASK_SQ_SIZE |
+				CMDQ_MODIFY_QP_MODIFY_MASK_RQ_SIZE |
+				CMDQ_MODIFY_QP_MODIFY_MASK_SQ_SGE |
+				CMDQ_MODIFY_QP_MODIFY_MASK_RQ_SGE |
+				CMDQ_MODIFY_QP_MODIFY_MASK_MAX_INLINE_DATA;
+		if ((qp_attr->cap.max_send_wr >= dev_attr->max_qp_wqes) ||
+		    (qp_attr->cap.max_recv_wr >= dev_attr->max_qp_wqes) ||
+		    (qp_attr->cap.max_send_sge >= dev_attr->max_qp_sges) ||
+		    (qp_attr->cap.max_recv_sge >= dev_attr->max_qp_sges) ||
+		    (qp_attr->cap.max_inline_data >=
+						dev_attr->max_inline_data)) {
+			dev_err(rdev_to_dev(rdev),
+				"Create QP failed - max exceeded");
+			return -EINVAL;
+		}
+		entries = roundup_pow_of_two(qp_attr->cap.max_send_wr);
+		if (entries > dev_attr->max_qp_wqes)
+			entries = dev_attr->max_qp_wqes;
+		qp->qplib_qp.sq.max_wqe = entries;
+		qp->qplib_qp.sq.max_sge = qp_attr->cap.max_send_sge;
+		if (qp->qplib_qp.rq.max_wqe) {
+			entries = roundup_pow_of_two(qp_attr->cap.max_recv_wr);
+			if (entries > dev_attr->max_qp_wqes)
+				entries = dev_attr->max_qp_wqes;
+			qp->qplib_qp.rq.max_wqe = entries;
+			qp->qplib_qp.rq.max_sge = qp_attr->cap.max_recv_sge;
+		} else {
+			/* SRQ was used prior, just ignore the RQ caps */
+		}
+	}
+	if (qp_attr_mask & IB_QP_DEST_QPN) {
+		qp->qplib_qp.modify_flags |=
+				CMDQ_MODIFY_QP_MODIFY_MASK_DEST_QP_ID;
+		qp->qplib_qp.dest_qpn = qp_attr->dest_qp_num;
+	}
+	rc = bnxt_qplib_modify_qp(&rdev->qplib_res, &qp->qplib_qp);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev), "Failed to modify HW QP");
+		return rc;
+	}
+	if (ib_qp->qp_type == IB_QPT_GSI && rdev->qp1_sqp)
+		rc = bnxt_re_modify_shadow_qp(rdev, qp, qp_attr_mask);
+	return rc;
+}
+
+int bnxt_re_query_qp(struct ib_qp *ib_qp, struct ib_qp_attr *qp_attr,
+		     int qp_attr_mask, struct ib_qp_init_attr *qp_init_attr)
+{
+	struct bnxt_re_qp *qp = container_of(ib_qp, struct bnxt_re_qp, ib_qp);
+	struct bnxt_re_dev *rdev = qp->rdev;
+	struct bnxt_qplib_qp qplib_qp;
+	int rc;
+
+	memset(&qplib_qp, 0, sizeof(struct bnxt_qplib_qp));
+	qplib_qp.id = qp->qplib_qp.id;
+	qplib_qp.ah.host_sgid_index = qp->qplib_qp.ah.host_sgid_index;
+
+	rc = bnxt_qplib_query_qp(&rdev->qplib_res, &qplib_qp);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev), "Failed to query HW QP");
+		return rc;
+	}
+	qp_attr->qp_state = __to_ib_qp_state(qplib_qp.state);
+	qp_attr->en_sqd_async_notify = qplib_qp.en_sqd_async_notify ? 1 : 0;
+	qp_attr->qp_access_flags = __to_ib_access_flags(qplib_qp.access);
+	qp_attr->pkey_index = qplib_qp.pkey_index;
+	qp_attr->qkey = qplib_qp.qkey;
+	memcpy(qp_attr->ah_attr.grh.dgid.raw, qplib_qp.ah.dgid.data,
+	       sizeof(qplib_qp.ah.dgid.data));
+	qp_attr->ah_attr.grh.flow_label = qplib_qp.ah.flow_label;
+	qp_attr->ah_attr.grh.sgid_index = qplib_qp.ah.host_sgid_index;
+	qp_attr->ah_attr.grh.hop_limit = qplib_qp.ah.hop_limit;
+	qp_attr->ah_attr.grh.traffic_class = qplib_qp.ah.traffic_class;
+	qp_attr->ah_attr.sl = qplib_qp.ah.sl;
+	ether_addr_copy(qp_attr->ah_attr.dmac, qplib_qp.ah.dmac);
+	qp_attr->path_mtu = __to_ib_mtu(qplib_qp.path_mtu);
+	qp_attr->timeout = qplib_qp.timeout;
+	qp_attr->retry_cnt = qplib_qp.retry_cnt;
+	qp_attr->rnr_retry = qplib_qp.rnr_retry;
+	qp_attr->min_rnr_timer = qplib_qp.min_rnr_timer;
+	qp_attr->rq_psn = qplib_qp.rq.psn;
+	qp_attr->max_rd_atomic = qplib_qp.max_rd_atomic;
+	qp_attr->sq_psn = qplib_qp.sq.psn;
+	qp_attr->max_dest_rd_atomic = qplib_qp.max_dest_rd_atomic;
+	qp_init_attr->sq_sig_type = qplib_qp.sig_type ? IB_SIGNAL_ALL_WR :
+							IB_SIGNAL_REQ_WR;
+	qp_attr->dest_qp_num = qplib_qp.dest_qpn;
+
+	qp_attr->cap.max_send_wr = qp->qplib_qp.sq.max_wqe;
+	qp_attr->cap.max_send_sge = qp->qplib_qp.sq.max_sge;
+	qp_attr->cap.max_recv_wr = qp->qplib_qp.rq.max_wqe;
+	qp_attr->cap.max_recv_sge = qp->qplib_qp.rq.max_sge;
+	qp_attr->cap.max_inline_data = qp->qplib_qp.max_inline_data;
+	qp_init_attr->cap = qp_attr->cap;
+
+	return 0;
+}
+
 /* Completion Queues */
 int bnxt_re_destroy_cq(struct ib_cq *ib_cq)
 {
diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.h b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
index ba9a4c9..75ee88a 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.h
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
@@ -57,6 +57,19 @@ struct bnxt_re_ah {
 	struct bnxt_qplib_ah	qplib_ah;
 };
 
+struct bnxt_re_qp {
+	struct list_head	list;
+	struct bnxt_re_dev	*rdev;
+	struct ib_qp		ib_qp;
+	spinlock_t		sq_lock;	/* protect sq */
+	struct bnxt_qplib_qp	qplib_qp;
+	struct ib_umem		*sumem;
+	struct ib_umem		*rumem;
+	/* QP1 */
+	u32			send_psn;
+	struct ib_ud_header	qp1_hdr;
+};
+
 struct bnxt_re_cq {
 	struct bnxt_re_dev	*rdev;
 	spinlock_t              cq_lock;	/* protect cq */
@@ -141,6 +154,14 @@ struct ib_ah *bnxt_re_create_ah(struct ib_pd *pd,
 int bnxt_re_modify_ah(struct ib_ah *ah, struct ib_ah_attr *ah_attr);
 int bnxt_re_query_ah(struct ib_ah *ah, struct ib_ah_attr *ah_attr);
 int bnxt_re_destroy_ah(struct ib_ah *ah);
+struct ib_qp *bnxt_re_create_qp(struct ib_pd *pd,
+				struct ib_qp_init_attr *qp_init_attr,
+				struct ib_udata *udata);
+int bnxt_re_modify_qp(struct ib_qp *qp, struct ib_qp_attr *qp_attr,
+		      int qp_attr_mask, struct ib_udata *udata);
+int bnxt_re_query_qp(struct ib_qp *qp, struct ib_qp_attr *qp_attr,
+		     int qp_attr_mask, struct ib_qp_init_attr *qp_init_attr);
+int bnxt_re_destroy_qp(struct ib_qp *qp);
 struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
 				const struct ib_cq_init_attr *attr,
 				struct ib_ucontext *context,
diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index 70b07ac..d68f08d 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -456,6 +456,12 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 	ibdev->modify_ah		= bnxt_re_modify_ah;
 	ibdev->query_ah			= bnxt_re_query_ah;
 	ibdev->destroy_ah		= bnxt_re_destroy_ah;
+
+	ibdev->create_qp		= bnxt_re_create_qp;
+	ibdev->modify_qp		= bnxt_re_modify_qp;
+	ibdev->query_qp			= bnxt_re_query_qp;
+	ibdev->destroy_qp		= bnxt_re_destroy_qp;
+
 	ibdev->create_cq		= bnxt_re_create_cq;
 	ibdev->destroy_cq		= bnxt_re_destroy_cq;
 	ibdev->req_notify_cq		= bnxt_re_req_notify_cq;
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_fp.c b/drivers/infiniband/hw/bnxt_re/qplib_fp.c
index b61b0db..f1f9095 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_fp.c
+++ b/drivers/infiniband/hw/bnxt_re/qplib_fp.c
@@ -51,6 +51,69 @@
 #include "qplib_fp.h"
 
 static void bnxt_qplib_arm_cq_enable(struct bnxt_qplib_cq *cq);
+
+static void bnxt_qplib_free_qp_hdr_buf(struct bnxt_qplib_res *res,
+				       struct bnxt_qplib_qp *qp)
+{
+	struct bnxt_qplib_q *rq = &qp->rq;
+	struct bnxt_qplib_q *sq = &qp->sq;
+
+	if (qp->rq_hdr_buf)
+		dma_free_coherent(&res->pdev->dev,
+				  rq->hwq.max_elements * qp->rq_hdr_buf_size,
+				  qp->rq_hdr_buf, qp->rq_hdr_buf_map);
+	if (qp->sq_hdr_buf)
+		dma_free_coherent(&res->pdev->dev,
+				  sq->hwq.max_elements * qp->sq_hdr_buf_size,
+				  qp->sq_hdr_buf, qp->sq_hdr_buf_map);
+	qp->rq_hdr_buf = NULL;
+	qp->sq_hdr_buf = NULL;
+	qp->rq_hdr_buf_map = 0;
+	qp->sq_hdr_buf_map = 0;
+	qp->sq_hdr_buf_size = 0;
+	qp->rq_hdr_buf_size = 0;
+}
+
+static int bnxt_qplib_alloc_qp_hdr_buf(struct bnxt_qplib_res *res,
+				       struct bnxt_qplib_qp *qp)
+{
+	struct bnxt_qplib_q *rq = &qp->rq;
+	struct bnxt_qplib_q *sq = &qp->rq;
+	int rc = 0;
+
+	if (qp->sq_hdr_buf_size && sq->hwq.max_elements) {
+		qp->sq_hdr_buf = dma_alloc_coherent(&res->pdev->dev,
+					sq->hwq.max_elements *
+					qp->sq_hdr_buf_size,
+					&qp->sq_hdr_buf_map, GFP_KERNEL);
+		if (!qp->sq_hdr_buf) {
+			rc = -ENOMEM;
+			dev_err(&res->pdev->dev,
+				"QPLIB: Failed to create sq_hdr_buf");
+			goto fail;
+		}
+	}
+
+	if (qp->rq_hdr_buf_size && rq->hwq.max_elements) {
+		qp->rq_hdr_buf = dma_alloc_coherent(&res->pdev->dev,
+						    rq->hwq.max_elements *
+						    qp->rq_hdr_buf_size,
+						    &qp->rq_hdr_buf_map,
+						    GFP_KERNEL);
+		if (!qp->rq_hdr_buf) {
+			rc = -ENOMEM;
+			dev_err(&res->pdev->dev,
+				"QPLIB: Failed to create rq_hdr_buf");
+			goto fail;
+		}
+	}
+	return 0;
+
+fail:
+	bnxt_qplib_free_qp_hdr_buf(res, qp);
+	return rc;
+}
+
 static void bnxt_qplib_service_nq(unsigned long data)
 {
 	struct bnxt_qplib_nq *nq = (struct bnxt_qplib_nq *)data;
@@ -216,6 +279,805 @@ int bnxt_qplib_alloc_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq)
 	return 0;
 }
 
+/* QP */
+int bnxt_qplib_create_qp1(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_create_qp1 req;
+	struct creq_create_qp1_resp *resp;
+	struct bnxt_qplib_pbl *pbl;
+	struct bnxt_qplib_q *sq = &qp->sq;
+	struct bnxt_qplib_q *rq = &qp->rq;
+	int rc;
+	u16 cmd_flags = 0;
+	u32 qp_flags = 0;
+
+	RCFW_CMD_PREP(req, CREATE_QP1, cmd_flags);
+
+	/* General */
+	req.type = qp->type;
+	req.dpi = cpu_to_le32(qp->dpi->dpi);
+	req.qp_handle = cpu_to_le64(qp->qp_handle);
+
+	/* SQ */
+	sq->hwq.max_elements = sq->max_wqe;
+	rc = bnxt_qplib_alloc_init_hwq(res->pdev, &sq->hwq, NULL, 0,
+				       &sq->hwq.max_elements,
+				       BNXT_QPLIB_MAX_SQE_ENTRY_SIZE, 0,
+				       PAGE_SIZE, HWQ_TYPE_QUEUE);
+	if (rc)
+		goto exit;
+
+	sq->swq = kcalloc(sq->hwq.max_elements, sizeof(*sq->swq), GFP_KERNEL);
+	if (!sq->swq) {
+		rc = -ENOMEM;
+		goto fail_sq;
+	}
+	pbl = &sq->hwq.pbl[PBL_LVL_0];
+	req.sq_pbl = cpu_to_le64(pbl->pg_map_arr[0]);
+	req.sq_pg_size_sq_lvl =
+		((sq->hwq.level & CMDQ_CREATE_QP1_SQ_LVL_MASK)
+				<<  CMDQ_CREATE_QP1_SQ_LVL_SFT) |
+		(pbl->pg_size == ROCE_PG_SIZE_4K ?
+				CMDQ_CREATE_QP1_SQ_PG_SIZE_PG_4K :
+		 pbl->pg_size == ROCE_PG_SIZE_8K ?
+				CMDQ_CREATE_QP1_SQ_PG_SIZE_PG_8K :
+		 pbl->pg_size == ROCE_PG_SIZE_64K ?
+				CMDQ_CREATE_QP1_SQ_PG_SIZE_PG_64K :
+		 pbl->pg_size == ROCE_PG_SIZE_2M ?
+				CMDQ_CREATE_QP1_SQ_PG_SIZE_PG_2M :
+		 pbl->pg_size == ROCE_PG_SIZE_8M ?
+				CMDQ_CREATE_QP1_SQ_PG_SIZE_PG_8M :
+		 pbl->pg_size == ROCE_PG_SIZE_1G ?
+				CMDQ_CREATE_QP1_SQ_PG_SIZE_PG_1G :
+		 CMDQ_CREATE_QP1_SQ_PG_SIZE_PG_4K);
+
+	if (qp->scq)
+		req.scq_cid = cpu_to_le32(qp->scq->id);
+
+	qp_flags |= CMDQ_CREATE_QP1_QP_FLAGS_RESERVED_LKEY_ENABLE;
+
+	/* RQ */
+	if (rq->max_wqe) {
+		rq->hwq.max_elements = qp->rq.max_wqe;
+		rc = bnxt_qplib_alloc_init_hwq(res->pdev, &rq->hwq, NULL, 0,
+					       &rq->hwq.max_elements,
+					       BNXT_QPLIB_MAX_RQE_ENTRY_SIZE, 0,
+					       PAGE_SIZE, HWQ_TYPE_QUEUE);
+		if (rc)
+			goto fail_sq;
+
+		rq->swq = kcalloc(rq->hwq.max_elements, sizeof(*rq->swq),
+				  GFP_KERNEL);
+		if (!rq->swq) {
+			rc = -ENOMEM;
+			goto fail_rq;
+		}
+		pbl = &rq->hwq.pbl[PBL_LVL_0];
+		req.rq_pbl = cpu_to_le64(pbl->pg_map_arr[0]);
+		req.rq_pg_size_rq_lvl =
+			((rq->hwq.level & CMDQ_CREATE_QP1_RQ_LVL_MASK) <<
+			 CMDQ_CREATE_QP1_RQ_LVL_SFT) |
+				(pbl->pg_size == ROCE_PG_SIZE_4K ?
+					CMDQ_CREATE_QP1_RQ_PG_SIZE_PG_4K :
+				 pbl->pg_size == ROCE_PG_SIZE_8K ?
+					CMDQ_CREATE_QP1_RQ_PG_SIZE_PG_8K :
+				 pbl->pg_size == ROCE_PG_SIZE_64K ?
+					CMDQ_CREATE_QP1_RQ_PG_SIZE_PG_64K :
+				 pbl->pg_size == ROCE_PG_SIZE_2M ?
+					CMDQ_CREATE_QP1_RQ_PG_SIZE_PG_2M :
+				 pbl->pg_size == ROCE_PG_SIZE_8M ?
+					CMDQ_CREATE_QP1_RQ_PG_SIZE_PG_8M :
+				 pbl->pg_size == ROCE_PG_SIZE_1G ?
+					CMDQ_CREATE_QP1_RQ_PG_SIZE_PG_1G :
+				 CMDQ_CREATE_QP1_RQ_PG_SIZE_PG_4K);
+		if (qp->rcq)
+			req.rcq_cid = cpu_to_le32(qp->rcq->id);
+	}
+
+	/* Header buffer - allow hdr_buf pass in */
+	rc = bnxt_qplib_alloc_qp_hdr_buf(res, qp);
+	if (rc) {
+		rc = -ENOMEM;
+		goto fail;
+	}
+	req.qp_flags = cpu_to_le32(qp_flags);
+	req.sq_size = cpu_to_le32(sq->hwq.max_elements);
+	req.rq_size = cpu_to_le32(rq->hwq.max_elements);
+
+	req.sq_fwo_sq_sge =
+		cpu_to_le16((sq->max_sge & CMDQ_CREATE_QP1_SQ_SGE_MASK) <<
+			    CMDQ_CREATE_QP1_SQ_SGE_SFT);
+	req.rq_fwo_rq_sge =
+		cpu_to_le16((rq->max_sge & CMDQ_CREATE_QP1_RQ_SGE_MASK) <<
+			    CMDQ_CREATE_QP1_RQ_SGE_SFT);
+
+	req.pd_id = cpu_to_le32(qp->pd->id);
+
+	resp = (struct creq_create_qp1_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 0);
+	if (!resp) {
+		dev_err(&res->pdev->dev, "QPLIB: FP: CREATE_QP1 send failed");
+		rc = -EINVAL;
+		goto fail;
+	}
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: CREATE_QP1 timed out");
+		rc = -ETIMEDOUT;
+		goto fail;
+	}
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: CREATE_QP1 failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		rc = -EINVAL;
+		goto fail;
+	}
+	qp->id = le32_to_cpu(resp->xid);
+	qp->cur_qp_state = CMDQ_MODIFY_QP_NEW_STATE_RESET;
+	sq->flush_in_progress = false;
+	rq->flush_in_progress = false;
+
+	return 0;
+
+fail:
+	bnxt_qplib_free_qp_hdr_buf(res, qp);
+fail_rq:
+	bnxt_qplib_free_hwq(res->pdev, &rq->hwq);
+	kfree(rq->swq);
+fail_sq:
+	bnxt_qplib_free_hwq(res->pdev, &sq->hwq);
+	kfree(sq->swq);
+exit:
+	return rc;
+}
+
+int bnxt_qplib_create_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct sq_send *hw_sq_send_hdr, **hw_sq_send_ptr;
+	struct cmdq_create_qp req;
+	struct creq_create_qp_resp *resp;
+	struct bnxt_qplib_pbl *pbl;
+	struct sq_psn_search **psn_search_ptr;
+	unsigned long int psn_search, poff = 0;
+	struct bnxt_qplib_q *sq = &qp->sq;
+	struct bnxt_qplib_q *rq = &qp->rq;
+	struct bnxt_qplib_hwq *xrrq;
+	int i, rc, req_size, psn_sz;
+	u16 cmd_flags = 0, max_ssge;
+	u32 sw_prod, qp_flags = 0;
+
+	RCFW_CMD_PREP(req, CREATE_QP, cmd_flags);
+
+	/* General */
+	req.type = qp->type;
+	req.dpi = cpu_to_le32(qp->dpi->dpi);
+	req.qp_handle = cpu_to_le64(qp->qp_handle);
+
+	/* SQ */
+	psn_sz = (qp->type == CMDQ_CREATE_QP_TYPE_RC) ?
+		 sizeof(struct sq_psn_search) : 0;
+	sq->hwq.max_elements = sq->max_wqe;
+	rc = bnxt_qplib_alloc_init_hwq(res->pdev, &sq->hwq, sq->sglist,
+				       sq->nmap, &sq->hwq.max_elements,
+				       BNXT_QPLIB_MAX_SQE_ENTRY_SIZE,
+				       psn_sz,
+				       PAGE_SIZE, HWQ_TYPE_QUEUE);
+	if (rc)
+		goto exit;
+
+	sq->swq = kcalloc(sq->hwq.max_elements, sizeof(*sq->swq), GFP_KERNEL);
+	if (!sq->swq) {
+		rc = -ENOMEM;
+		goto fail_sq;
+	}
+	hw_sq_send_ptr = (struct sq_send **)sq->hwq.pbl_ptr;
+	if (psn_sz) {
+		psn_search_ptr = (struct sq_psn_search **)
+				  &hw_sq_send_ptr[get_sqe_pg
+					(sq->hwq.max_elements)];
+		psn_search = (unsigned long int)
+			      &hw_sq_send_ptr[get_sqe_pg(sq->hwq.max_elements)]
+			      [get_sqe_idx(sq->hwq.max_elements)];
+		if (psn_search & ~PAGE_MASK) {
+			/* If the psn_search does not start on a page boundary,
+			 * then calculate the offset
+			 */
+			poff = (psn_search & ~PAGE_MASK) /
+				BNXT_QPLIB_MAX_PSNE_ENTRY_SIZE;
+		}
+		for (i = 0; i < sq->hwq.max_elements; i++)
+			sq->swq[i].psn_search =
+				&psn_search_ptr[get_psne_pg(i + poff)]
+					       [get_psne_idx(i + poff)];
+	}
+	pbl = &sq->hwq.pbl[PBL_LVL_0];
+	req.sq_pbl = cpu_to_le64(pbl->pg_map_arr[0]);
+	req.sq_pg_size_sq_lvl =
+		((sq->hwq.level & CMDQ_CREATE_QP_SQ_LVL_MASK)
+				 <<  CMDQ_CREATE_QP_SQ_LVL_SFT) |
+		(pbl->pg_size == ROCE_PG_SIZE_4K ?
+				CMDQ_CREATE_QP_SQ_PG_SIZE_PG_4K :
+		 pbl->pg_size == ROCE_PG_SIZE_8K ?
+				CMDQ_CREATE_QP_SQ_PG_SIZE_PG_8K :
+		 pbl->pg_size == ROCE_PG_SIZE_64K ?
+				CMDQ_CREATE_QP_SQ_PG_SIZE_PG_64K :
+		 pbl->pg_size == ROCE_PG_SIZE_2M ?
+				CMDQ_CREATE_QP_SQ_PG_SIZE_PG_2M :
+		 pbl->pg_size == ROCE_PG_SIZE_8M ?
+				CMDQ_CREATE_QP_SQ_PG_SIZE_PG_8M :
+		 pbl->pg_size == ROCE_PG_SIZE_1G ?
+				CMDQ_CREATE_QP_SQ_PG_SIZE_PG_1G :
+		 CMDQ_CREATE_QP_SQ_PG_SIZE_PG_4K);
+
+	/* initialize all SQ WQEs to LOCAL_INVALID (sq prep for hw fetch) */
+	hw_sq_send_ptr = (struct sq_send **)sq->hwq.pbl_ptr;
+	for (sw_prod = 0; sw_prod < sq->hwq.max_elements; sw_prod++) {
+		hw_sq_send_hdr = &hw_sq_send_ptr[get_sqe_pg(sw_prod)]
+						[get_sqe_idx(sw_prod)];
+		hw_sq_send_hdr->wqe_type = SQ_BASE_WQE_TYPE_LOCAL_INVALID;
+	}
+
+	if (qp->scq)
+		req.scq_cid = cpu_to_le32(qp->scq->id);
+
+	qp_flags |= CMDQ_CREATE_QP_QP_FLAGS_RESERVED_LKEY_ENABLE;
+	qp_flags |= CMDQ_CREATE_QP_QP_FLAGS_FR_PMR_ENABLED;
+	if (qp->sig_type)
+		qp_flags |= CMDQ_CREATE_QP_QP_FLAGS_FORCE_COMPLETION;
+
+	/* RQ */
+	if (rq->max_wqe) {
+		rq->hwq.max_elements = rq->max_wqe;
+		rc = bnxt_qplib_alloc_init_hwq(res->pdev, &rq->hwq, rq->sglist,
+					       rq->nmap, &rq->hwq.max_elements,
+					       BNXT_QPLIB_MAX_RQE_ENTRY_SIZE, 0,
+					       PAGE_SIZE, HWQ_TYPE_QUEUE);
+		if (rc)
+			goto fail_sq;
+
+		rq->swq = kcalloc(rq->hwq.max_elements, sizeof(*rq->swq),
+				  GFP_KERNEL);
+		if (!rq->swq) {
+			rc = -ENOMEM;
+			goto fail_rq;
+		}
+		pbl = &rq->hwq.pbl[PBL_LVL_0];
+		req.rq_pbl = cpu_to_le64(pbl->pg_map_arr[0]);
+		req.rq_pg_size_rq_lvl =
+			((rq->hwq.level & CMDQ_CREATE_QP_RQ_LVL_MASK) <<
+			 CMDQ_CREATE_QP_RQ_LVL_SFT) |
+				(pbl->pg_size == ROCE_PG_SIZE_4K ?
+					CMDQ_CREATE_QP_RQ_PG_SIZE_PG_4K :
+				 pbl->pg_size == ROCE_PG_SIZE_8K ?
+					CMDQ_CREATE_QP_RQ_PG_SIZE_PG_8K :
+				 pbl->pg_size == ROCE_PG_SIZE_64K ?
+					CMDQ_CREATE_QP_RQ_PG_SIZE_PG_64K :
+				 pbl->pg_size == ROCE_PG_SIZE_2M ?
+					CMDQ_CREATE_QP_RQ_PG_SIZE_PG_2M :
+				 pbl->pg_size == ROCE_PG_SIZE_8M ?
+					CMDQ_CREATE_QP_RQ_PG_SIZE_PG_8M :
+				 pbl->pg_size == ROCE_PG_SIZE_1G ?
+					CMDQ_CREATE_QP_RQ_PG_SIZE_PG_1G :
+				 CMDQ_CREATE_QP_RQ_PG_SIZE_PG_4K);
+	}
+
+	if (qp->rcq)
+		req.rcq_cid = cpu_to_le32(qp->rcq->id);
+	req.qp_flags = cpu_to_le32(qp_flags);
+	req.sq_size = cpu_to_le32(sq->hwq.max_elements);
+	req.rq_size = cpu_to_le32(rq->hwq.max_elements);
+	qp->sq_hdr_buf = NULL;
+	qp->rq_hdr_buf = NULL;
+
+	rc = bnxt_qplib_alloc_qp_hdr_buf(res, qp);
+	if (rc)
+		goto fail_rq;
+
+	/* CTRL-22434: Irrespective of the requested SGE count on the SQ
+	 * always create the QP with max send sges possible if the requested
+	 * inline size is greater than 0.
+	 */
+	max_ssge = qp->max_inline_data ? 6 : sq->max_sge;
+	req.sq_fwo_sq_sge = cpu_to_le16(
+				((max_ssge & CMDQ_CREATE_QP_SQ_SGE_MASK)
+				 << CMDQ_CREATE_QP_SQ_SGE_SFT) | 0);
+	req.rq_fwo_rq_sge = cpu_to_le16(
+				((rq->max_sge & CMDQ_CREATE_QP_RQ_SGE_MASK)
+				 << CMDQ_CREATE_QP_RQ_SGE_SFT) | 0);
+	/* ORRQ and IRRQ */
+	if (psn_sz) {
+		xrrq = &qp->orrq;
+		xrrq->max_elements =
+			ORD_LIMIT_TO_ORRQ_SLOTS(qp->max_rd_atomic);
+		req_size = xrrq->max_elements *
+			   BNXT_QPLIB_MAX_ORRQE_ENTRY_SIZE + PAGE_SIZE - 1;
+		req_size &= ~(PAGE_SIZE - 1);
+		rc = bnxt_qplib_alloc_init_hwq(res->pdev, xrrq, NULL, 0,
+					       &xrrq->max_elements,
+					       BNXT_QPLIB_MAX_ORRQE_ENTRY_SIZE,
+					       0, req_size, HWQ_TYPE_CTX);
+		if (rc)
+			goto fail_buf_free;
+		pbl = &xrrq->pbl[PBL_LVL_0];
+		req.orrq_addr = cpu_to_le64(pbl->pg_map_arr[0]);
+
+		xrrq = &qp->irrq;
+		xrrq->max_elements = IRD_LIMIT_TO_IRRQ_SLOTS(
+						qp->max_dest_rd_atomic);
+		req_size = xrrq->max_elements *
+			   BNXT_QPLIB_MAX_IRRQE_ENTRY_SIZE + PAGE_SIZE - 1;
+		req_size &= ~(PAGE_SIZE - 1);
+
+		rc = bnxt_qplib_alloc_init_hwq(res->pdev, xrrq, NULL, 0,
+					       &xrrq->max_elements,
+					       BNXT_QPLIB_MAX_IRRQE_ENTRY_SIZE,
+					       0, req_size, HWQ_TYPE_CTX);
+		if (rc)
+			goto fail_orrq;
+
+		pbl = &xrrq->pbl[PBL_LVL_0];
+		req.irrq_addr = cpu_to_le64(pbl->pg_map_arr[0]);
+	}
+	req.pd_id = cpu_to_le32(qp->pd->id);
+
+	resp = (struct creq_create_qp_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 0);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: CREATE_QP send failed");
+		rc = -EINVAL;
+		goto fail;
+	}
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: CREATE_QP timed out");
+		rc = -ETIMEDOUT;
+		goto fail;
+	}
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: CREATE_QP failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		rc = -EINVAL;
+		goto fail;
+	}
+	qp->id = le32_to_cpu(resp->xid);
+	qp->cur_qp_state = CMDQ_MODIFY_QP_NEW_STATE_RESET;
+	sq->flush_in_progress = false;
+	rq->flush_in_progress = false;
+
+	return 0;
+
+fail:
+	if (qp->irrq.max_elements)
+		bnxt_qplib_free_hwq(res->pdev, &qp->irrq);
+fail_orrq:
+	if (qp->orrq.max_elements)
+		bnxt_qplib_free_hwq(res->pdev, &qp->orrq);
+fail_buf_free:
+	bnxt_qplib_free_qp_hdr_buf(res, qp);
+fail_rq:
+	bnxt_qplib_free_hwq(res->pdev, &rq->hwq);
+	kfree(rq->swq);
+fail_sq:
+	bnxt_qplib_free_hwq(res->pdev, &sq->hwq);
+	kfree(sq->swq);
+exit:
+	return rc;
+}
+
+static void __modify_flags_from_init_state(struct bnxt_qplib_qp *qp)
+{
+	switch (qp->state) {
+	case CMDQ_MODIFY_QP_NEW_STATE_RTR:
+		/* INIT->RTR, configure the path_mtu to the default
+		 * 2048 if not being requested
+		 */
+		if (!(qp->modify_flags &
+		    CMDQ_MODIFY_QP_MODIFY_MASK_PATH_MTU)) {
+			qp->modify_flags |=
+				CMDQ_MODIFY_QP_MODIFY_MASK_PATH_MTU;
+			qp->path_mtu =
+				CMDQ_MODIFY_QP_PATH_MTU_MTU_2048;
+		}
+		qp->modify_flags &=
+			~CMDQ_MODIFY_QP_MODIFY_MASK_VLAN_ID;
+		/* Bono FW require the max_dest_rd_atomic to be >= 1 */
+		if (qp->max_dest_rd_atomic < 1)
+			qp->max_dest_rd_atomic = 1;
+		qp->modify_flags &= ~CMDQ_MODIFY_QP_MODIFY_MASK_SRC_MAC;
+		/* Bono FW 20.6.5 requires SGID_INDEX configuration */
+		if (!(qp->modify_flags &
+		    CMDQ_MODIFY_QP_MODIFY_MASK_SGID_INDEX)) {
+			qp->modify_flags |=
+				CMDQ_MODIFY_QP_MODIFY_MASK_SGID_INDEX;
+			qp->ah.sgid_index = 0;
+		}
+		break;
+	default:
+		break;
+	}
+}
+
+static void __modify_flags_from_rtr_state(struct bnxt_qplib_qp *qp)
+{
+	switch (qp->state) {
+	case CMDQ_MODIFY_QP_NEW_STATE_RTS:
+		/* Bono FW requires the max_rd_atomic to be >= 1 */
+		if (qp->max_rd_atomic < 1)
+			qp->max_rd_atomic = 1;
+		/* Bono FW does not allow PKEY_INDEX,
+		 * DGID, FLOW_LABEL, SGID_INDEX, HOP_LIMIT,
+		 * TRAFFIC_CLASS, DEST_MAC, PATH_MTU, RQ_PSN,
+		 * MIN_RNR_TIMER, MAX_DEST_RD_ATOMIC, DEST_QP_ID
+		 * modification
+		 */
+		qp->modify_flags &=
+			~(CMDQ_MODIFY_QP_MODIFY_MASK_PKEY |
+			  CMDQ_MODIFY_QP_MODIFY_MASK_DGID |
+			  CMDQ_MODIFY_QP_MODIFY_MASK_FLOW_LABEL |
+			  CMDQ_MODIFY_QP_MODIFY_MASK_SGID_INDEX |
+			  CMDQ_MODIFY_QP_MODIFY_MASK_HOP_LIMIT |
+			  CMDQ_MODIFY_QP_MODIFY_MASK_TRAFFIC_CLASS |
+			  CMDQ_MODIFY_QP_MODIFY_MASK_DEST_MAC |
+			  CMDQ_MODIFY_QP_MODIFY_MASK_PATH_MTU |
+			  CMDQ_MODIFY_QP_MODIFY_MASK_RQ_PSN |
+			  CMDQ_MODIFY_QP_MODIFY_MASK_MIN_RNR_TIMER |
+			  CMDQ_MODIFY_QP_MODIFY_MASK_MAX_DEST_RD_ATOMIC |
+			  CMDQ_MODIFY_QP_MODIFY_MASK_DEST_QP_ID);
+		break;
+	default:
+		break;
+	}
+}
+
+static void __filter_modify_flags(struct bnxt_qplib_qp *qp)
+{
+	switch (qp->cur_qp_state) {
+	case CMDQ_MODIFY_QP_NEW_STATE_RESET:
+		break;
+	case CMDQ_MODIFY_QP_NEW_STATE_INIT:
+		__modify_flags_from_init_state(qp);
+		break;
+	case CMDQ_MODIFY_QP_NEW_STATE_RTR:
+		__modify_flags_from_rtr_state(qp);
+		break;
+	case CMDQ_MODIFY_QP_NEW_STATE_RTS:
+		break;
+	case CMDQ_MODIFY_QP_NEW_STATE_SQD:
+		break;
+	case CMDQ_MODIFY_QP_NEW_STATE_SQE:
+		break;
+	case CMDQ_MODIFY_QP_NEW_STATE_ERR:
+		break;
+	default:
+		break;
+	}
+}
+
+int bnxt_qplib_modify_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_modify_qp req;
+	struct creq_modify_qp_resp *resp;
+	u16 cmd_flags = 0, pkey;
+	u32 temp32[4];
+	u32 bmask;
+
+	RCFW_CMD_PREP(req, MODIFY_QP, cmd_flags);
+
+	/* Filter out the qp_attr_mask based on the state->new transition */
+	__filter_modify_flags(qp);
+	bmask = qp->modify_flags;
+	req.modify_mask = cpu_to_le32(qp->modify_flags);
+	req.qp_cid = cpu_to_le32(qp->id);
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_STATE) {
+		req.network_type_en_sqd_async_notify_new_state =
+				(qp->state & CMDQ_MODIFY_QP_NEW_STATE_MASK) |
+				(qp->en_sqd_async_notify ?
+					CMDQ_MODIFY_QP_EN_SQD_ASYNC_NOTIFY : 0);
+	}
+	req.network_type_en_sqd_async_notify_new_state |= qp->nw_type;
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_ACCESS)
+		req.access = qp->access;
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_PKEY) {
+		if (!bnxt_qplib_get_pkey(res, &res->pkey_tbl,
+					 qp->pkey_index, &pkey))
+			req.pkey = cpu_to_le16(pkey);
+	}
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_QKEY)
+		req.qkey = cpu_to_le32(qp->qkey);
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_DGID) {
+		memcpy(temp32, qp->ah.dgid.data, sizeof(struct bnxt_qplib_gid));
+		req.dgid[0] = cpu_to_le32(temp32[0]);
+		req.dgid[1] = cpu_to_le32(temp32[1]);
+		req.dgid[2] = cpu_to_le32(temp32[2]);
+		req.dgid[3] = cpu_to_le32(temp32[3]);
+	}
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_FLOW_LABEL)
+		req.flow_label = cpu_to_le32(qp->ah.flow_label);
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_SGID_INDEX)
+		req.sgid_index = cpu_to_le16(res->sgid_tbl.hw_id
+					     [qp->ah.sgid_index]);
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_HOP_LIMIT)
+		req.hop_limit = qp->ah.hop_limit;
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_TRAFFIC_CLASS)
+		req.traffic_class = qp->ah.traffic_class;
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_DEST_MAC)
+		memcpy(req.dest_mac, qp->ah.dmac, 6);
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_PATH_MTU)
+		req.path_mtu = qp->path_mtu;
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_TIMEOUT)
+		req.timeout = qp->timeout;
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_RETRY_CNT)
+		req.retry_cnt = qp->retry_cnt;
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_RNR_RETRY)
+		req.rnr_retry = qp->rnr_retry;
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_MIN_RNR_TIMER)
+		req.min_rnr_timer = qp->min_rnr_timer;
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_RQ_PSN)
+		req.rq_psn = cpu_to_le32(qp->rq.psn);
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_SQ_PSN)
+		req.sq_psn = cpu_to_le32(qp->sq.psn);
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_MAX_RD_ATOMIC)
+		req.max_rd_atomic =
+			ORD_LIMIT_TO_ORRQ_SLOTS(qp->max_rd_atomic);
+
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_MAX_DEST_RD_ATOMIC)
+		req.max_dest_rd_atomic =
+			IRD_LIMIT_TO_IRRQ_SLOTS(qp->max_dest_rd_atomic);
+
+	req.sq_size = cpu_to_le32(qp->sq.hwq.max_elements);
+	req.rq_size = cpu_to_le32(qp->rq.hwq.max_elements);
+	req.sq_sge = cpu_to_le16(qp->sq.max_sge);
+	req.rq_sge = cpu_to_le16(qp->rq.max_sge);
+	req.max_inline_data = cpu_to_le32(qp->max_inline_data);
+	if (bmask & CMDQ_MODIFY_QP_MODIFY_MASK_DEST_QP_ID)
+		req.dest_qp_id = cpu_to_le32(qp->dest_qpn);
+
+	req.vlan_pcp_vlan_dei_vlan_id = cpu_to_le16(qp->vlan_id);
+
+	resp = (struct creq_modify_qp_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 0);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: MODIFY_QP send failed");
+		return -EINVAL;
+	}
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: MODIFY_QP timed out");
+		return -ETIMEDOUT;
+	}
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: MODIFY_QP failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		return -EINVAL;
+	}
+	qp->cur_qp_state = qp->state;
+	return 0;
+}
+
+int bnxt_qplib_query_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_query_qp req;
+	struct creq_query_qp_resp *resp;
+	struct creq_query_qp_resp_sb *sb;
+	u16 cmd_flags = 0;
+	u32 temp32[4];
+	int i;
+
+	RCFW_CMD_PREP(req, QUERY_QP, cmd_flags);
+
+	req.qp_cid = cpu_to_le32(qp->id);
+	req.resp_size = sizeof(*sb) / BNXT_QPLIB_CMDQE_UNITS;
+	resp = (struct creq_query_qp_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     (void **)&sb, 0);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: QUERY_QP send failed");
+		return -EINVAL;
+	}
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: QUERY_QP timed out");
+		return -ETIMEDOUT;
+	}
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: QUERY_QP failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		return -EINVAL;
+	}
+	/* Extract the context from the side buffer */
+	qp->state = sb->en_sqd_async_notify_state &
+			CREQ_QUERY_QP_RESP_SB_STATE_MASK;
+	qp->en_sqd_async_notify = sb->en_sqd_async_notify_state &
+				  CREQ_QUERY_QP_RESP_SB_EN_SQD_ASYNC_NOTIFY ?
+				  true : false;
+	qp->access = sb->access;
+	qp->pkey_index = le16_to_cpu(sb->pkey);
+	qp->qkey = le32_to_cpu(sb->qkey);
+
+	temp32[0] = le32_to_cpu(sb->dgid[0]);
+	temp32[1] = le32_to_cpu(sb->dgid[1]);
+	temp32[2] = le32_to_cpu(sb->dgid[2]);
+	temp32[3] = le32_to_cpu(sb->dgid[3]);
+	memcpy(qp->ah.dgid.data, temp32, sizeof(qp->ah.dgid.data));
+
+	qp->ah.flow_label = le32_to_cpu(sb->flow_label);
+
+	qp->ah.sgid_index = 0;
+	for (i = 0; i < res->sgid_tbl.max; i++) {
+		if (res->sgid_tbl.hw_id[i] == le16_to_cpu(sb->sgid_index)) {
+			qp->ah.sgid_index = i;
+			break;
+		}
+	}
+	if (i == res->sgid_tbl.max)
+		dev_warn(&res->pdev->dev, "QPLIB: SGID not found??");
+
+	qp->ah.hop_limit = sb->hop_limit;
+	qp->ah.traffic_class = sb->traffic_class;
+	memcpy(qp->ah.dmac, sb->dest_mac, 6);
+	qp->ah.vlan_id = (le16_to_cpu(sb->path_mtu_dest_vlan_id) &
+				CREQ_QUERY_QP_RESP_SB_VLAN_ID_MASK) >>
+				CREQ_QUERY_QP_RESP_SB_VLAN_ID_SFT;
+	qp->path_mtu = (le16_to_cpu(sb->path_mtu_dest_vlan_id) &
+				    CREQ_QUERY_QP_RESP_SB_PATH_MTU_MASK) >>
+				    CREQ_QUERY_QP_RESP_SB_PATH_MTU_SFT;
+	qp->timeout = sb->timeout;
+	qp->retry_cnt = sb->retry_cnt;
+	qp->rnr_retry = sb->rnr_retry;
+	qp->min_rnr_timer = sb->min_rnr_timer;
+	qp->rq.psn = le32_to_cpu(sb->rq_psn);
+	qp->max_rd_atomic = ORRQ_SLOTS_TO_ORD_LIMIT(sb->max_rd_atomic);
+	qp->sq.psn = le32_to_cpu(sb->sq_psn);
+	qp->max_dest_rd_atomic =
+			IRRQ_SLOTS_TO_IRD_LIMIT(sb->max_dest_rd_atomic);
+	qp->sq.max_wqe = qp->sq.hwq.max_elements;
+	qp->rq.max_wqe = qp->rq.hwq.max_elements;
+	qp->sq.max_sge = le16_to_cpu(sb->sq_sge);
+	qp->rq.max_sge = le16_to_cpu(sb->rq_sge);
+	qp->max_inline_data = le32_to_cpu(sb->max_inline_data);
+	qp->dest_qpn = le32_to_cpu(sb->dest_qp_id);
+	memcpy(qp->smac, sb->src_mac, 6);
+	qp->vlan_id = le16_to_cpu(sb->vlan_pcp_vlan_dei_vlan_id);
+	return 0;
+}
+
+static void __clean_cq(struct bnxt_qplib_cq *cq, u64 qp)
+{
+	struct bnxt_qplib_hwq *cq_hwq = &cq->hwq;
+	struct cq_base *hw_cqe, **hw_cqe_ptr;
+	int i;
+
+	for (i = 0; i < cq_hwq->max_elements; i++) {
+		hw_cqe_ptr = (struct cq_base **)cq_hwq->pbl_ptr;
+		hw_cqe = &hw_cqe_ptr[CQE_PG(i)][CQE_IDX(i)];
+		if (!CQE_CMP_VALID(hw_cqe, i, cq_hwq->max_elements))
+			continue;
+		switch (hw_cqe->cqe_type_toggle & CQ_BASE_CQE_TYPE_MASK) {
+		case CQ_BASE_CQE_TYPE_REQ:
+		case CQ_BASE_CQE_TYPE_TERMINAL:
+		{
+			struct cq_req *cqe = (struct cq_req *)hw_cqe;
+
+			if (qp == le64_to_cpu(cqe->qp_handle))
+				cqe->qp_handle = 0;
+			break;
+		}
+		case CQ_BASE_CQE_TYPE_RES_RC:
+		case CQ_BASE_CQE_TYPE_RES_UD:
+		case CQ_BASE_CQE_TYPE_RES_RAWETH_QP1:
+		{
+			struct cq_res_rc *cqe = (struct cq_res_rc *)hw_cqe;
+
+			if (qp == le64_to_cpu(cqe->qp_handle))
+				cqe->qp_handle = 0;
+			break;
+		}
+		default:
+			break;
+		}
+	}
+}
+
+int bnxt_qplib_destroy_qp(struct bnxt_qplib_res *res,
+			  struct bnxt_qplib_qp *qp)
+{
+	struct bnxt_qplib_rcfw *rcfw = res->rcfw;
+	struct cmdq_destroy_qp req;
+	struct creq_destroy_qp_resp *resp;
+	unsigned long flags;
+	u16 cmd_flags = 0;
+
+	RCFW_CMD_PREP(req, DESTROY_QP, cmd_flags);
+
+	req.qp_cid = cpu_to_le32(qp->id);
+	resp = (struct creq_destroy_qp_resp *)
+			bnxt_qplib_rcfw_send_message(rcfw, (void *)&req,
+						     NULL, 0);
+	if (!resp) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: DESTROY_QP send failed");
+		return -EINVAL;
+	}
+	if (!bnxt_qplib_rcfw_wait_for_resp(rcfw, le16_to_cpu(req.cookie))) {
+		/* Cmd timed out */
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: DESTROY_QP timed out");
+		return -ETIMEDOUT;
+	}
+	if (resp->status ||
+	    le16_to_cpu(resp->cookie) != le16_to_cpu(req.cookie)) {
+		dev_err(&rcfw->pdev->dev, "QPLIB: FP: DESTROY_QP failed ");
+		dev_err(&rcfw->pdev->dev,
+			"QPLIB: with status 0x%x cmdq 0x%x resp 0x%x",
+			resp->status, le16_to_cpu(req.cookie),
+			le16_to_cpu(resp->cookie));
+		return -EINVAL;
+	}
+
+	/* Must walk the associated CQs to nullified the QP ptr */
+	spin_lock_irqsave(&qp->scq->hwq.lock, flags);
+
+	__clean_cq(qp->scq, (u64)(unsigned long)qp);
+
+	if (qp->rcq && qp->rcq != qp->scq) {
+		spin_lock(&qp->rcq->hwq.lock);
+		__clean_cq(qp->rcq, (u64)(unsigned long)qp);
+		spin_unlock(&qp->rcq->hwq.lock);
+	}
+
+	spin_unlock_irqrestore(&qp->scq->hwq.lock, flags);
+
+	bnxt_qplib_free_qp_hdr_buf(res, qp);
+	bnxt_qplib_free_hwq(res->pdev, &qp->sq.hwq);
+	kfree(qp->sq.swq);
+
+	bnxt_qplib_free_hwq(res->pdev, &qp->rq.hwq);
+	kfree(qp->rq.swq);
+
+	if (qp->irrq.max_elements)
+		bnxt_qplib_free_hwq(res->pdev, &qp->irrq);
+	if (qp->orrq.max_elements)
+		bnxt_qplib_free_hwq(res->pdev, &qp->orrq);
+
+	return 0;
+}
+
 /* CQ */
 
 /* Spinlock must be held */
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_fp.h b/drivers/infiniband/hw/bnxt_re/qplib_fp.h
index 9797138..e62c750 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_fp.h
+++ b/drivers/infiniband/hw/bnxt_re/qplib_fp.h
@@ -38,8 +38,268 @@
 
 #ifndef __BNXT_QPLIB_FP_H__
 #define __BNXT_QPLIB_FP_H__
+struct bnxt_qplib_sge {
+	u64				addr;
+	u32				lkey;
+	u32				size;
+};
+
+#define BNXT_QPLIB_MAX_SQE_ENTRY_SIZE	sizeof(struct sq_send)
+
+#define SQE_CNT_PER_PG		(PAGE_SIZE / BNXT_QPLIB_MAX_SQE_ENTRY_SIZE)
+#define SQE_MAX_IDX_PER_PG	(SQE_CNT_PER_PG - 1)
+
+static inline u32 get_sqe_pg(u32 val)
+{
+	return ((val & ~SQE_MAX_IDX_PER_PG) / SQE_CNT_PER_PG);
+}
+
+static inline u32 get_sqe_idx(u32 val)
+{
+	return (val & SQE_MAX_IDX_PER_PG);
+}
+
+#define BNXT_QPLIB_MAX_PSNE_ENTRY_SIZE	sizeof(struct sq_psn_search)
+
+#define PSNE_CNT_PER_PG		(PAGE_SIZE / BNXT_QPLIB_MAX_PSNE_ENTRY_SIZE)
+#define PSNE_MAX_IDX_PER_PG	(PSNE_CNT_PER_PG - 1)
+
+static inline u32 get_psne_pg(u32 val)
+{
+	return ((val & ~PSNE_MAX_IDX_PER_PG) / PSNE_CNT_PER_PG);
+}
+
+static inline u32 get_psne_idx(u32 val)
+{
+	return (val & PSNE_MAX_IDX_PER_PG);
+}
+
+#define BNXT_QPLIB_QP_MAX_SGL	6
+
+struct bnxt_qplib_swq {
+	u64				wr_id;
+	u8				type;
+	u8				flags;
+	u32				start_psn;
+	u32				next_psn;
+	struct sq_psn_search		*psn_search;
+};
+
+struct bnxt_qplib_swqe {
+	/* General */
+	u64				wr_id;
+	u8				reqs_type;
+	u8				type;
+#define BNXT_QPLIB_SWQE_TYPE_SEND			0
+#define BNXT_QPLIB_SWQE_TYPE_SEND_WITH_IMM		1
+#define BNXT_QPLIB_SWQE_TYPE_SEND_WITH_INV		2
+#define BNXT_QPLIB_SWQE_TYPE_RDMA_WRITE			4
+#define BNXT_QPLIB_SWQE_TYPE_RDMA_WRITE_WITH_IMM	5
+#define BNXT_QPLIB_SWQE_TYPE_RDMA_READ			6
+#define BNXT_QPLIB_SWQE_TYPE_ATOMIC_CMP_AND_SWP		8
+#define BNXT_QPLIB_SWQE_TYPE_ATOMIC_FETCH_AND_ADD	11
+#define BNXT_QPLIB_SWQE_TYPE_LOCAL_INV			12
+#define BNXT_QPLIB_SWQE_TYPE_FAST_REG_MR		13
+#define BNXT_QPLIB_SWQE_TYPE_REG_MR			13
+#define BNXT_QPLIB_SWQE_TYPE_BIND_MW			14
+#define BNXT_QPLIB_SWQE_TYPE_RECV			128
+#define BNXT_QPLIB_SWQE_TYPE_RECV_RDMA_IMM		129
+	u8				flags;
+#define BNXT_QPLIB_SWQE_FLAGS_SIGNAL_COMP		BIT(0)
+#define BNXT_QPLIB_SWQE_FLAGS_RD_ATOMIC_FENCE		BIT(1)
+#define BNXT_QPLIB_SWQE_FLAGS_UC_FENCE			BIT(2)
+#define BNXT_QPLIB_SWQE_FLAGS_SOLICIT_EVENT		BIT(3)
+#define BNXT_QPLIB_SWQE_FLAGS_INLINE			BIT(4)
+	struct bnxt_qplib_sge		sg_list[BNXT_QPLIB_QP_MAX_SGL];
+	int				num_sge;
+	/* Max inline data is 96 bytes */
+	u32				inline_len;
+#define BNXT_QPLIB_SWQE_MAX_INLINE_LENGTH		96
+	u8		inline_data[BNXT_QPLIB_SWQE_MAX_INLINE_LENGTH];
+
+	union {
+		/* Send, with imm, inval key */
+		struct {
+			union {
+				__be32	imm_data;
+				u32	inv_key;
+			};
+			u32		q_key;
+			u32		dst_qp;
+			u16		avid;
+		} send;
+
+		/* Send Raw Ethernet and QP1 */
+		struct {
+			u16		lflags;
+			u16		cfa_action;
+			u32		cfa_meta;
+		} rawqp1;
+
+		/* RDMA write, with imm, read */
+		struct {
+			union {
+				__be32	imm_data;
+				u32	inv_key;
+			};
+			u64		remote_va;
+			u32		r_key;
+		} rdma;
+
+		/* Atomic cmp/swap, fetch/add */
+		struct {
+			u64		remote_va;
+			u32		r_key;
+			u64		swap_data;
+			u64		cmp_data;
+		} atomic;
+
+		/* Local Invalidate */
+		struct {
+			u32		inv_l_key;
+		} local_inv;
+
+		/* FR-PMR */
+		struct {
+			u8		access_cntl;
+			u8		pg_sz_log;
+			bool		zero_based;
+			u32		l_key;
+			u32		length;
+			u8		pbl_pg_sz_log;
+#define BNXT_QPLIB_SWQE_PAGE_SIZE_4K			0
+#define BNXT_QPLIB_SWQE_PAGE_SIZE_8K			1
+#define BNXT_QPLIB_SWQE_PAGE_SIZE_64K			4
+#define BNXT_QPLIB_SWQE_PAGE_SIZE_256K			6
+#define BNXT_QPLIB_SWQE_PAGE_SIZE_1M			8
+#define BNXT_QPLIB_SWQE_PAGE_SIZE_2M			9
+#define BNXT_QPLIB_SWQE_PAGE_SIZE_4M			10
+#define BNXT_QPLIB_SWQE_PAGE_SIZE_1G			18
+			u8		levels;
+#define PAGE_SHIFT_4K	12
+			__le64		*pbl_ptr;
+			dma_addr_t	pbl_dma_ptr;
+			u64		*page_list;
+			u16		page_list_len;
+			u64		va;
+		} frmr;
+
+		/* Bind */
+		struct {
+			u8		access_cntl;
+#define BNXT_QPLIB_BIND_SWQE_ACCESS_LOCAL_WRITE		BIT(0)
+#define BNXT_QPLIB_BIND_SWQE_ACCESS_REMOTE_READ		BIT(1)
+#define BNXT_QPLIB_BIND_SWQE_ACCESS_REMOTE_WRITE	BIT(2)
+#define BNXT_QPLIB_BIND_SWQE_ACCESS_REMOTE_ATOMIC	BIT(3)
+#define BNXT_QPLIB_BIND_SWQE_ACCESS_WINDOW_BIND		BIT(4)
+			bool		zero_based;
+			u8		mw_type;
+			u32		parent_l_key;
+			u32		r_key;
+			u64		va;
+			u32		length;
+		} bind;
+	};
+};
+
+#define BNXT_QPLIB_MAX_RQE_ENTRY_SIZE	sizeof(struct rq_wqe)
+
+#define RQE_CNT_PER_PG		(PAGE_SIZE / BNXT_QPLIB_MAX_RQE_ENTRY_SIZE)
+#define RQE_MAX_IDX_PER_PG	(RQE_CNT_PER_PG - 1)
+#define RQE_PG(x)		(((x) & ~RQE_MAX_IDX_PER_PG) / RQE_CNT_PER_PG)
+#define RQE_IDX(x)		((x) & RQE_MAX_IDX_PER_PG)
+
+struct bnxt_qplib_q {
+	struct bnxt_qplib_hwq		hwq;
+	struct bnxt_qplib_swq		*swq;
+	struct scatterlist		*sglist;
+	u32				nmap;
+	u32				max_wqe;
+	u16				max_sge;
+	u32				psn;
+	bool				flush_in_progress;
+};
+
+struct bnxt_qplib_qp {
+	struct bnxt_qplib_pd		*pd;
+	struct bnxt_qplib_dpi		*dpi;
+	u64				qp_handle;
+	u32				id;
+	u8				type;
+	u8				sig_type;
+	u32				modify_flags;
+	u8				state;
+	u8				cur_qp_state;
+	u32				max_inline_data;
+	u32				mtu;
+	u8				path_mtu;
+	bool				en_sqd_async_notify;
+	u16				pkey_index;
+	u32				qkey;
+	u32				dest_qp_id;
+	u8				access;
+	u8				timeout;
+	u8				retry_cnt;
+	u8				rnr_retry;
+	u32				min_rnr_timer;
+	u32				max_rd_atomic;
+	u32				max_dest_rd_atomic;
+	u32				dest_qpn;
+	u8				smac[6];
+	u16				vlan_id;
+	u8				nw_type;
+	struct bnxt_qplib_ah		ah;
+
+#define BTH_PSN_MASK			((1 << 24) - 1)
+	/* SQ */
+	struct bnxt_qplib_q		sq;
+	/* RQ */
+	struct bnxt_qplib_q		rq;
+	/* SRQ */
+	struct bnxt_qplib_srq		*srq;
+	/* CQ */
+	struct bnxt_qplib_cq		*scq;
+	struct bnxt_qplib_cq		*rcq;
+	/* IRRQ and ORRQ */
+	struct bnxt_qplib_hwq		irrq;
+	struct bnxt_qplib_hwq		orrq;
+	/* Header buffer for QP1 */
+	int				sq_hdr_buf_size;
+	int				rq_hdr_buf_size;
+/*
+ * Buffer space for ETH(14), IP or GRH(40), UDP header(8)
+ * and ib_bth + ib_deth (20).
+ * Max required is 82 when RoCE V2 is enabled
+ */
+#define BNXT_QPLIB_MAX_QP1_SQ_HDR_SIZE_V2	86
+	/* Ethernet header	=  14 */
+	/* ib_grh		=  40 (provided by MAD) */
+	/* ib_bth + ib_deth	=  20 */
+	/* MAD			= 256 (provided by MAD) */
+	/* iCRC			=   4 */
+#define BNXT_QPLIB_MAX_QP1_RQ_ETH_HDR_SIZE	14
+#define BNXT_QPLIB_MAX_QP1_RQ_HDR_SIZE_V2	512
+#define BNXT_QPLIB_MAX_GRH_HDR_SIZE_IPV4	20
+#define BNXT_QPLIB_MAX_GRH_HDR_SIZE_IPV6	40
+#define BNXT_QPLIB_MAX_QP1_RQ_BDETH_HDR_SIZE	20
+	void				*sq_hdr_buf;
+	dma_addr_t			sq_hdr_buf_map;
+	void				*rq_hdr_buf;
+	dma_addr_t			rq_hdr_buf_map;
+};
+
 #define BNXT_QPLIB_MAX_CQE_ENTRY_SIZE	sizeof(struct cq_base)
 
+#define CQE_CNT_PER_PG		(PAGE_SIZE / BNXT_QPLIB_MAX_CQE_ENTRY_SIZE)
+#define CQE_MAX_IDX_PER_PG	(CQE_CNT_PER_PG - 1)
+#define CQE_PG(x)		(((x) & ~CQE_MAX_IDX_PER_PG) / CQE_CNT_PER_PG)
+#define CQE_IDX(x)		((x) & CQE_MAX_IDX_PER_PG)
+
+#define ROCE_CQE_CMP_V			0
+#define CQE_CMP_VALID(hdr, raw_cons, cp_bit)			\
+	(!!((hdr)->cqe_type_toggle & CQ_BASE_TOGGLE) ==		\
+	   !((raw_cons) & (cp_bit)))
+
 struct bnxt_qplib_cqe {
 	u8				status;
 	u8				type;
@@ -85,6 +345,13 @@ struct bnxt_qplib_cq {
 	wait_queue_head_t		waitq;
 };
 
+#define BNXT_QPLIB_MAX_IRRQE_ENTRY_SIZE	sizeof(struct xrrq_irrq)
+#define BNXT_QPLIB_MAX_ORRQE_ENTRY_SIZE	sizeof(struct xrrq_orrq)
+#define IRD_LIMIT_TO_IRRQ_SLOTS(x)	(2 * (x) + 2)
+#define IRRQ_SLOTS_TO_IRD_LIMIT(s)	(((s) >> 1) - 1)
+#define ORD_LIMIT_TO_ORRQ_SLOTS(x)	((x) + 1)
+#define ORRQ_SLOTS_TO_ORD_LIMIT(s)	((s) - 1)
+
 #define BNXT_QPLIB_MAX_NQE_ENTRY_SIZE	sizeof(struct nq_base)
 
 #define NQE_CNT_PER_PG		(PAGE_SIZE / BNXT_QPLIB_MAX_NQE_ENTRY_SIZE)
@@ -143,6 +410,11 @@ int bnxt_qplib_enable_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq,
 			 int (*srqn_handler)(struct bnxt_qplib_nq *nq,
 					     void *srq,
 					     u8 event));
+int bnxt_qplib_create_qp1(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp);
+int bnxt_qplib_create_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp);
+int bnxt_qplib_modify_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp);
+int bnxt_qplib_query_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp);
+int bnxt_qplib_destroy_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp);
 int bnxt_qplib_create_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq);
 int bnxt_qplib_destroy_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq);
 
diff --git a/include/uapi/rdma/bnxt_re-abi.h b/include/uapi/rdma/bnxt_re-abi.h
index 024579b..ad8c916 100644
--- a/include/uapi/rdma/bnxt_re-abi.h
+++ b/include/uapi/rdma/bnxt_re-abi.h
@@ -68,6 +68,17 @@ struct bnxt_re_cq_resp {
 	__u32 rsvd;
 };
 
+struct bnxt_re_qp_req {
+	__u64 qpsva;
+	__u64 qprva;
+	__u64 qp_handle;
+};
+
+struct bnxt_re_qp_resp {
+	__u32 qpid;
+	__u32 rsvd;
+};
+
 enum bnxt_re_shpg_offt {
 	BNXT_RE_BEG_RESV_OFFT	= 0x00,
 	BNXT_RE_AVID_OFFT	= 0x10,
-- 
2.5.5
