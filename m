From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH V5 for-next 15/21] RDMA/bnxt_re: Support post_recv
Date: Fri, 10 Feb 2017 03:19:47 -0800
Message-ID: <1486725593-9872-16-git-send-email-selvin.xavier@broadcom.com>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:35319 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751477AbdBJLXE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 06:23:04 -0500
Received: by mail-qt0-f179.google.com with SMTP id x49so31268795qtc.2
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 03:21:10 -0800 (PST)
In-Reply-To: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enables the fastpath verb ib_post_recv.

v3: Fixes sparse warnings
v5: Code cleanup to avoid goto statement in post_recv
    routines, as per Leon's suggestions.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxt_re/ib_verbs.c | 123 +++++++++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/ib_verbs.h |   2 +
 drivers/infiniband/hw/bnxt_re/main.c     |   2 +
 drivers/infiniband/hw/bnxt_re/qplib_fp.c | 100 +++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/qplib_fp.h |   8 ++
 5 files changed, 235 insertions(+)

diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.c b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
index 9401717..54d85bc 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.c
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
@@ -1635,6 +1635,52 @@ static int bnxt_re_build_qp1_send_v2(struct bnxt_re_qp *qp,
 	return rc;
 }
 
+/* For the MAD layer, it only provides the recv SGE the size of
+ * ib_grh + MAD datagram.  No Ethernet headers, Ethertype, BTH, DETH,
+ * nor RoCE iCRC.  The Cu+ solution must provide buffer for the entire
+ * receive packet (334 bytes) with no VLAN and then copy the GRH
+ * and the MAD datagram out to the provided SGE.
+ */
+static int bnxt_re_build_qp1_shadow_qp_recv(struct bnxt_re_qp *qp,
+					    struct ib_recv_wr *wr,
+					    struct bnxt_qplib_swqe *wqe,
+					    int payload_size)
+{
+	struct bnxt_qplib_sge ref, sge;
+	u32 rq_prod_index;
+	struct bnxt_re_sqp_entries *sqp_entry;
+
+	rq_prod_index = bnxt_qplib_get_rq_prod_index(&qp->qplib_qp);
+
+	if (!bnxt_qplib_get_qp1_rq_buf(&qp->qplib_qp, &sge))
+		return -ENOMEM;
+
+	/* Create 1 SGE to receive the entire
+	 * ethernet packet
+	 */
+	/* Save the reference from ULP */
+	ref.addr = wqe->sg_list[0].addr;
+	ref.lkey = wqe->sg_list[0].lkey;
+	ref.size = wqe->sg_list[0].size;
+
+	sqp_entry = &qp->rdev->sqp_tbl[rq_prod_index];
+
+	/* SGE 1 */
+	wqe->sg_list[0].addr = sge.addr;
+	wqe->sg_list[0].lkey = sge.lkey;
+	wqe->sg_list[0].size = BNXT_QPLIB_MAX_QP1_RQ_HDR_SIZE_V2;
+	sge.size -= wqe->sg_list[0].size;
+
+	sqp_entry->sge.addr = ref.addr;
+	sqp_entry->sge.lkey = ref.lkey;
+	sqp_entry->sge.size = ref.size;
+	/* Store the wrid for reporting completion */
+	sqp_entry->wrid = wqe->wr_id;
+	/* change the wqe->wrid to table index */
+	wqe->wr_id = rq_prod_index;
+	return 0;
+}
+
 static int is_ud_qp(struct bnxt_re_qp *qp)
 {
 	return qp->qplib_qp.type == CMDQ_CREATE_QP_TYPE_UD;
@@ -1981,6 +2027,83 @@ int bnxt_re_post_send(struct ib_qp *ib_qp, struct ib_send_wr *wr,
 	return rc;
 }
 
+static int bnxt_re_post_recv_shadow_qp(struct bnxt_re_dev *rdev,
+				       struct bnxt_re_qp *qp,
+				       struct ib_recv_wr *wr)
+{
+	struct bnxt_qplib_swqe wqe;
+	int rc = 0, payload_sz = 0;
+
+	memset(&wqe, 0, sizeof(wqe));
+	while (wr) {
+		/* House keeping */
+		memset(&wqe, 0, sizeof(wqe));
+
+		/* Common */
+		wqe.num_sge = wr->num_sge;
+		if (wr->num_sge > qp->qplib_qp.rq.max_sge) {
+			dev_err(rdev_to_dev(rdev),
+				"Limit exceeded for Receive SGEs");
+			rc = -EINVAL;
+			break;
+		}
+		payload_sz = bnxt_re_build_sgl(wr->sg_list, wqe.sg_list,
+					       wr->num_sge);
+		wqe.wr_id = wr->wr_id;
+		wqe.type = BNXT_QPLIB_SWQE_TYPE_RECV;
+
+		rc = bnxt_qplib_post_recv(&qp->qplib_qp, &wqe);
+		if (rc)
+			break;
+
+		wr = wr->next;
+	}
+	if (!rc)
+		bnxt_qplib_post_recv_db(&qp->qplib_qp);
+	return rc;
+}
+
+int bnxt_re_post_recv(struct ib_qp *ib_qp, struct ib_recv_wr *wr,
+		      struct ib_recv_wr **bad_wr)
+{
+	struct bnxt_re_qp *qp = container_of(ib_qp, struct bnxt_re_qp, ib_qp);
+	struct bnxt_qplib_swqe wqe;
+	int rc = 0, payload_sz = 0;
+
+	while (wr) {
+		/* House keeping */
+		memset(&wqe, 0, sizeof(wqe));
+
+		/* Common */
+		wqe.num_sge = wr->num_sge;
+		if (wr->num_sge > qp->qplib_qp.rq.max_sge) {
+			dev_err(rdev_to_dev(qp->rdev),
+				"Limit exceeded for Receive SGEs");
+			rc = -EINVAL;
+			*bad_wr = wr;
+			break;
+		}
+
+		payload_sz = bnxt_re_build_sgl(wr->sg_list, wqe.sg_list,
+					       wr->num_sge);
+		wqe.wr_id = wr->wr_id;
+		wqe.type = BNXT_QPLIB_SWQE_TYPE_RECV;
+
+		if (ib_qp->qp_type == IB_QPT_GSI)
+			rc = bnxt_re_build_qp1_shadow_qp_recv(qp, wr, &wqe,
+							      payload_sz);
+		if (!rc)
+			rc = bnxt_qplib_post_recv(&qp->qplib_qp, &wqe);
+		if (rc) {
+			*bad_wr = wr;
+			break;
+		}
+		wr = wr->next;
+	}
+	bnxt_qplib_post_recv_db(&qp->qplib_qp);
+	return rc;
+}
+
 /* Completion Queues */
 int bnxt_re_destroy_cq(struct ib_cq *ib_cq)
 {
diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.h b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
index 2bb36b9..839c25c 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.h
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
@@ -165,6 +165,8 @@ int bnxt_re_query_qp(struct ib_qp *qp, struct ib_qp_attr *qp_attr,
 int bnxt_re_destroy_qp(struct ib_qp *qp);
 int bnxt_re_post_send(struct ib_qp *qp, struct ib_send_wr *send_wr,
 		      struct ib_send_wr **bad_send_wr);
+int bnxt_re_post_recv(struct ib_qp *qp, struct ib_recv_wr *recv_wr,
+		      struct ib_recv_wr **bad_recv_wr);
 struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
 				const struct ib_cq_init_attr *attr,
 				struct ib_ucontext *context,
diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index cb909c4..310addd 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -459,6 +459,8 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 	ibdev->destroy_qp		= bnxt_re_destroy_qp;
 
 	ibdev->post_send		= bnxt_re_post_send;
+	ibdev->post_recv		= bnxt_re_post_recv;
+
 	ibdev->create_cq		= bnxt_re_create_cq;
 	ibdev->destroy_cq		= bnxt_re_destroy_cq;
 	ibdev->req_notify_cq		= bnxt_re_req_notify_cq;
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_fp.c b/drivers/infiniband/hw/bnxt_re/qplib_fp.c
index b2e9afe..3f5854c 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_fp.c
+++ b/drivers/infiniband/hw/bnxt_re/qplib_fp.c
@@ -1097,6 +1097,37 @@ void *bnxt_qplib_get_qp1_sq_buf(struct bnxt_qplib_qp *qp,
 	return NULL;
 }
 
+u32 bnxt_qplib_get_rq_prod_index(struct bnxt_qplib_qp *qp)
+{
+	struct bnxt_qplib_q *rq = &qp->rq;
+
+	return HWQ_CMP(rq->hwq.prod, &rq->hwq);
+}
+
+dma_addr_t bnxt_qplib_get_qp_buf_from_index(struct bnxt_qplib_qp *qp, u32 index)
+{
+	return (qp->rq_hdr_buf_map + index * qp->rq_hdr_buf_size);
+}
+
+void *bnxt_qplib_get_qp1_rq_buf(struct bnxt_qplib_qp *qp,
+				struct bnxt_qplib_sge *sge)
+{
+	struct bnxt_qplib_q *rq = &qp->rq;
+	u32 sw_prod;
+
+	memset(sge, 0, sizeof(*sge));
+
+	if (qp->rq_hdr_buf) {
+		sw_prod = HWQ_CMP(rq->hwq.prod, &rq->hwq);
+		sge->addr = (dma_addr_t)(qp->rq_hdr_buf_map +
+					 sw_prod * qp->rq_hdr_buf_size);
+		sge->lkey = 0xFFFFFFFF;
+		sge->size = qp->rq_hdr_buf_size;
+		return qp->rq_hdr_buf + sw_prod * sge->size;
+	}
+	return NULL;
+}
+
 void bnxt_qplib_post_send_db(struct bnxt_qplib_qp *qp)
 {
 	struct bnxt_qplib_q *sq = &qp->sq;
@@ -1346,6 +1377,75 @@ int bnxt_qplib_post_send(struct bnxt_qplib_qp *qp,
 	return rc;
 }
 
+void bnxt_qplib_post_recv_db(struct bnxt_qplib_qp *qp)
+{
+	struct bnxt_qplib_q *rq = &qp->rq;
+	struct dbr_dbr db_msg = { 0 };
+	u32 sw_prod;
+
+	sw_prod = HWQ_CMP(rq->hwq.prod, &rq->hwq);
+	db_msg.index = cpu_to_le32((sw_prod << DBR_DBR_INDEX_SFT) &
+				   DBR_DBR_INDEX_MASK);
+	db_msg.type_xid =
+		cpu_to_le32(((qp->id << DBR_DBR_XID_SFT) & DBR_DBR_XID_MASK) |
+			    DBR_DBR_TYPE_RQ);
+
+	/* Flush the writes to HW Rx WQE before the ringing Rx DB */
+	wmb();
+	__iowrite64_copy(qp->dpi->dbr, &db_msg, sizeof(db_msg) / sizeof(u64));
+}
+
+int bnxt_qplib_post_recv(struct bnxt_qplib_qp *qp,
+			 struct bnxt_qplib_swqe *wqe)
+{
+	struct bnxt_qplib_q *rq = &qp->rq;
+	struct rq_wqe *rqe, **rqe_ptr;
+	struct sq_sge *hw_sge;
+	u32 sw_prod;
+	int i, rc = 0;
+
+	if (qp->state == CMDQ_MODIFY_QP_NEW_STATE_ERR) {
+		dev_err(&rq->hwq.pdev->dev,
+			"QPLIB: FP: QP (0x%x) is in the 0x%x state",
+			qp->id, qp->state);
+		rc = -EINVAL;
+		goto done;
+	}
+	if (HWQ_CMP((rq->hwq.prod + 1), &rq->hwq) ==
+	    HWQ_CMP(rq->hwq.cons, &rq->hwq)) {
+		dev_err(&rq->hwq.pdev->dev,
+			"QPLIB: FP: QP (0x%x) RQ is full!", qp->id);
+		rc = -EINVAL;
+		goto done;
+	}
+	sw_prod = HWQ_CMP(rq->hwq.prod, &rq->hwq);
+	rq->swq[sw_prod].wr_id = wqe->wr_id;
+
+	rqe_ptr = (struct rq_wqe **)rq->hwq.pbl_ptr;
+	rqe = &rqe_ptr[RQE_PG(sw_prod)][RQE_IDX(sw_prod)];
+
+	memset(rqe, 0, BNXT_QPLIB_MAX_RQE_ENTRY_SIZE);
+
+	/* Calculate wqe_size16 and data_len */
+	for (i = 0, hw_sge = (struct sq_sge *)rqe->data;
+	     i < wqe->num_sge; i++, hw_sge++) {
+		hw_sge->va_or_pa = cpu_to_le64(wqe->sg_list[i].addr);
+		hw_sge->l_key = cpu_to_le32(wqe->sg_list[i].lkey);
+		hw_sge->size = cpu_to_le32(wqe->sg_list[i].size);
+	}
+	rqe->wqe_type = wqe->type;
+	rqe->flags = wqe->flags;
+	rqe->wqe_size = wqe->num_sge +
+			((offsetof(typeof(*rqe), data) + 15) >> 4);
+
+	/* Supply the rqe->wr_id index to the wr_id_tbl for now */
+	rqe->wr_id[0] = cpu_to_le32(sw_prod);
+
+	rq->hwq.prod++;
+done:
+	return rc;
+}
+
 /* CQ */
 
 /* Spinlock must be held */
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_fp.h b/drivers/infiniband/hw/bnxt_re/qplib_fp.h
index 3db8fb9..5dcdd9d 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_fp.h
+++ b/drivers/infiniband/hw/bnxt_re/qplib_fp.h
@@ -418,9 +418,17 @@ int bnxt_qplib_query_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp);
 int bnxt_qplib_destroy_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp);
 void *bnxt_qplib_get_qp1_sq_buf(struct bnxt_qplib_qp *qp,
 				struct bnxt_qplib_sge *sge);
+void *bnxt_qplib_get_qp1_rq_buf(struct bnxt_qplib_qp *qp,
+				struct bnxt_qplib_sge *sge);
+u32 bnxt_qplib_get_rq_prod_index(struct bnxt_qplib_qp *qp);
+dma_addr_t bnxt_qplib_get_qp_buf_from_index(struct bnxt_qplib_qp *qp,
+					    u32 index);
 void bnxt_qplib_post_send_db(struct bnxt_qplib_qp *qp);
 int bnxt_qplib_post_send(struct bnxt_qplib_qp *qp,
 			 struct bnxt_qplib_swqe *wqe);
+void bnxt_qplib_post_recv_db(struct bnxt_qplib_qp *qp);
+int bnxt_qplib_post_recv(struct bnxt_qplib_qp *qp,
+			 struct bnxt_qplib_swqe *wqe);
 int bnxt_qplib_create_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq);
 int bnxt_qplib_destroy_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq);
 
-- 
2.5.5
