From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH for bnxt_re V3 14/21] bnxt_re: Support post_send verb
Date: Tue, 20 Dec 2016 01:13:24 -0800
Message-ID: <1482225211-22423-15-git-send-email-selvin.xavier@broadcom.com>
References: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:35210 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933796AbcLTJOs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 04:14:48 -0500
Received: by mail-qt0-f179.google.com with SMTP id c47so171082739qtc.2
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 01:14:47 -0800 (PST)
In-Reply-To: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enables the ib_post_send fastpath verb for posting Send work
requests on QPs.

v2: Fixed some sparse warnings
v3: Fixes endianness related warnings reported by sparse. Changes
    some of the macros to inline functions.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c    | 268 ++++++++++++
 drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h    |   8 +
 drivers/infiniband/hw/bnxtre/bnxt_re.h          |   4 +
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c | 544 +++++++++++++++++++++++-
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h |   2 +
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c     |   1 +
 6 files changed, 824 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
index 8fc5928..d1ccf66 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.c
@@ -1078,6 +1078,274 @@ int bnxt_qplib_destroy_qp(struct bnxt_qplib_res *res,
 	return 0;
 }
 
+void *bnxt_qplib_get_qp1_sq_buf(struct bnxt_qplib_qp *qp,
+				struct bnxt_qplib_sge *sge)
+{
+	struct bnxt_qplib_q *sq = &qp->sq;
+	u32 sw_prod;
+
+	memset(sge, 0, sizeof(*sge));
+
+	if (qp->sq_hdr_buf) {
+		sw_prod = HWQ_CMP(sq->hwq.prod, &sq->hwq);
+		sge->addr = (dma_addr_t)(qp->sq_hdr_buf_map +
+					 sw_prod * qp->sq_hdr_buf_size);
+		sge->lkey = 0xFFFFFFFF;
+		sge->size = qp->sq_hdr_buf_size;
+		return qp->sq_hdr_buf + sw_prod * sge->size;
+	}
+	return NULL;
+}
+
+void bnxt_qplib_post_send_db(struct bnxt_qplib_qp *qp)
+{
+	struct bnxt_qplib_q *sq = &qp->sq;
+	struct dbr_dbr db_msg = { 0 };
+	u32 sw_prod;
+
+	sw_prod = HWQ_CMP(sq->hwq.prod, &sq->hwq);
+
+	db_msg.index = cpu_to_le32((sw_prod << DBR_DBR_INDEX_SFT) &
+				   DBR_DBR_INDEX_MASK);
+	db_msg.type_xid =
+		cpu_to_le32(((qp->id << DBR_DBR_XID_SFT) & DBR_DBR_XID_MASK) |
+			    DBR_DBR_TYPE_SQ);
+	/* Flush all the WQE writes to HW */
+	wmb();
+	__iowrite64_copy(qp->dpi->dbr, &db_msg, sizeof(db_msg) / sizeof(u64));
+}
+
+int bnxt_qplib_post_send(struct bnxt_qplib_qp *qp,
+			 struct bnxt_qplib_swqe *wqe)
+{
+	struct bnxt_qplib_q *sq = &qp->sq;
+	struct bnxt_qplib_swq *swq;
+	struct sq_send *hw_sq_send_hdr, **hw_sq_send_ptr;
+	struct sq_sge *hw_sge;
+	u32 sw_prod;
+	u8 wqe_size16;
+	int i, rc = 0, data_len = 0, pkt_num = 0;
+	__le32 temp32;
+
+	if (qp->state != CMDQ_MODIFY_QP_NEW_STATE_RTS) {
+		rc = -EINVAL;
+		goto done;
+	}
+	if (HWQ_CMP((sq->hwq.prod + 1), &sq->hwq) ==
+	    HWQ_CMP(sq->hwq.cons, &sq->hwq)) {
+		rc = -ENOMEM;
+		goto done;
+	}
+	sw_prod = HWQ_CMP(sq->hwq.prod, &sq->hwq);
+	swq = &sq->swq[sw_prod];
+	swq->wr_id = wqe->wr_id;
+	swq->type = wqe->type;
+	swq->flags = wqe->flags;
+	if (qp->sig_type)
+		swq->flags |= SQ_SEND_FLAGS_SIGNAL_COMP;
+	swq->start_psn = sq->psn & BTH_PSN_MASK;
+
+	hw_sq_send_ptr = (struct sq_send **)sq->hwq.pbl_ptr;
+	hw_sq_send_hdr = &hw_sq_send_ptr[get_sqe_pg(sw_prod)]
+					[get_sqe_idx(sw_prod)];
+
+	memset(hw_sq_send_hdr, 0, BNXT_QPLIB_MAX_SQE_ENTRY_SIZE);
+
+	if (wqe->flags & BNXT_QPLIB_SWQE_FLAGS_INLINE) {
+		/* Copy the inline data */
+		if (wqe->inline_len > BNXT_QPLIB_SWQE_MAX_INLINE_LENGTH) {
+			dev_warn(&sq->hwq.pdev->dev,
+				 "QPLIB: Inline data length > 96 detected");
+			data_len = BNXT_QPLIB_SWQE_MAX_INLINE_LENGTH;
+		} else {
+			data_len = wqe->inline_len;
+		}
+		memcpy(hw_sq_send_hdr->data, wqe->inline_data, data_len);
+		wqe_size16 = (data_len + 15) >> 4;
+	} else {
+		for (i = 0, hw_sge = (struct sq_sge *)hw_sq_send_hdr->data;
+		     i < wqe->num_sge; i++, hw_sge++) {
+			hw_sge->va_or_pa = cpu_to_le64(wqe->sg_list[i].addr);
+			hw_sge->l_key = cpu_to_le32(wqe->sg_list[i].lkey);
+			hw_sge->size = cpu_to_le32(wqe->sg_list[i].size);
+			data_len += wqe->sg_list[i].size;
+		}
+		/* Each SGE entry = 1 WQE size16 */
+		wqe_size16 = wqe->num_sge;
+	}
+
+	/* Specifics */
+	switch (wqe->type) {
+	case BNXT_QPLIB_SWQE_TYPE_SEND:
+		if (qp->type == CMDQ_CREATE_QP1_TYPE_GSI) {
+			/* Assemble info for Raw Ethertype QPs */
+			struct sq_send_raweth_qp1 *sqe =
+				(struct sq_send_raweth_qp1 *)hw_sq_send_hdr;
+
+			sqe->wqe_type = wqe->type;
+			sqe->flags = wqe->flags;
+			sqe->wqe_size = wqe_size16 +
+				((offsetof(typeof(*sqe), data) + 15) >> 4);
+			sqe->cfa_action = cpu_to_le16(wqe->rawqp1.cfa_action);
+			sqe->lflags = cpu_to_le16(wqe->rawqp1.lflags);
+			sqe->length = cpu_to_le32(data_len);
+			sqe->cfa_meta = cpu_to_le32((wqe->rawqp1.cfa_meta &
+				SQ_SEND_RAWETH_QP1_CFA_META_VLAN_VID_MASK) <<
+				SQ_SEND_RAWETH_QP1_CFA_META_VLAN_VID_SFT);
+
+			break;
+		}
+		/* else, just fall thru */
+	case BNXT_QPLIB_SWQE_TYPE_SEND_WITH_IMM:
+	case BNXT_QPLIB_SWQE_TYPE_SEND_WITH_INV:
+	{
+		struct sq_send *sqe = (struct sq_send *)hw_sq_send_hdr;
+
+		sqe->wqe_type = wqe->type;
+		sqe->flags = wqe->flags;
+		sqe->wqe_size = wqe_size16 +
+				((offsetof(typeof(*sqe), data) + 15) >> 4);
+		sqe->inv_key_or_imm_data = cpu_to_le32(
+						wqe->send.inv_key);
+		if (qp->type == CMDQ_CREATE_QP_TYPE_UD) {
+			sqe->q_key = cpu_to_le32(wqe->send.q_key);
+			sqe->dst_qp = cpu_to_le32(
+					wqe->send.dst_qp & SQ_SEND_DST_QP_MASK);
+			sqe->length = cpu_to_le32(data_len);
+			sqe->avid = cpu_to_le32(wqe->send.avid &
+						SQ_SEND_AVID_MASK);
+			sq->psn = (sq->psn + 1) & BTH_PSN_MASK;
+		} else {
+			sqe->length = cpu_to_le32(data_len);
+			sqe->dst_qp = 0;
+			sqe->avid = 0;
+			if (qp->mtu)
+				pkt_num = (data_len + qp->mtu - 1) / qp->mtu;
+			if (!pkt_num)
+				pkt_num = 1;
+			sq->psn = (sq->psn + pkt_num) & BTH_PSN_MASK;
+		}
+		break;
+	}
+	case BNXT_QPLIB_SWQE_TYPE_RDMA_WRITE:
+	case BNXT_QPLIB_SWQE_TYPE_RDMA_WRITE_WITH_IMM:
+	case BNXT_QPLIB_SWQE_TYPE_RDMA_READ:
+	{
+		struct sq_rdma *sqe = (struct sq_rdma *)hw_sq_send_hdr;
+
+		sqe->wqe_type = wqe->type;
+		sqe->flags = wqe->flags;
+		sqe->wqe_size = wqe_size16 +
+				((offsetof(typeof(*sqe), data) + 15) >> 4);
+		sqe->imm_data = cpu_to_le32(wqe->rdma.inv_key);
+		sqe->length = cpu_to_le32((u32)data_len);
+		sqe->remote_va = cpu_to_le64(wqe->rdma.remote_va);
+		sqe->remote_key = cpu_to_le32(wqe->rdma.r_key);
+		if (qp->mtu)
+			pkt_num = (data_len + qp->mtu - 1) / qp->mtu;
+		if (!pkt_num)
+			pkt_num = 1;
+		sq->psn = (sq->psn + pkt_num) & BTH_PSN_MASK;
+		break;
+	}
+	case BNXT_QPLIB_SWQE_TYPE_ATOMIC_CMP_AND_SWP:
+	case BNXT_QPLIB_SWQE_TYPE_ATOMIC_FETCH_AND_ADD:
+	{
+		struct sq_atomic *sqe = (struct sq_atomic *)hw_sq_send_hdr;
+
+		sqe->wqe_type = wqe->type;
+		sqe->flags = wqe->flags;
+		sqe->remote_key = cpu_to_le32(wqe->atomic.r_key);
+		sqe->remote_va = cpu_to_le64(wqe->atomic.remote_va);
+		sqe->swap_data = cpu_to_le64(wqe->atomic.swap_data);
+		sqe->cmp_data = cpu_to_le64(wqe->atomic.cmp_data);
+		if (qp->mtu)
+			pkt_num = (data_len + qp->mtu - 1) / qp->mtu;
+		if (!pkt_num)
+			pkt_num = 1;
+		sq->psn = (sq->psn + pkt_num) & BTH_PSN_MASK;
+		break;
+	}
+	case BNXT_QPLIB_SWQE_TYPE_LOCAL_INV:
+	{
+		struct sq_localinvalidate *sqe =
+				(struct sq_localinvalidate *)hw_sq_send_hdr;
+
+		sqe->wqe_type = wqe->type;
+		sqe->flags = wqe->flags;
+		sqe->inv_l_key = cpu_to_le32(wqe->local_inv.inv_l_key);
+
+		break;
+	}
+	case BNXT_QPLIB_SWQE_TYPE_FAST_REG_MR:
+	{
+		struct sq_fr_pmr *sqe = (struct sq_fr_pmr *)hw_sq_send_hdr;
+
+		sqe->wqe_type = wqe->type;
+		sqe->flags = wqe->flags;
+		sqe->access_cntl = wqe->frmr.access_cntl |
+				   SQ_FR_PMR_ACCESS_CNTL_LOCAL_WRITE;
+		sqe->zero_based_page_size_log =
+			(wqe->frmr.pg_sz_log & SQ_FR_PMR_PAGE_SIZE_LOG_MASK) <<
+			SQ_FR_PMR_PAGE_SIZE_LOG_SFT |
+			(wqe->frmr.zero_based ? SQ_FR_PMR_ZERO_BASED : 0);
+		sqe->l_key = cpu_to_le32(wqe->frmr.l_key);
+		temp32 = cpu_to_le32(wqe->frmr.length);
+		memcpy(sqe->length, &temp32, sizeof(wqe->frmr.length));
+		sqe->numlevels_pbl_page_size_log =
+			((wqe->frmr.pbl_pg_sz_log <<
+					SQ_FR_PMR_PBL_PAGE_SIZE_LOG_SFT) &
+					SQ_FR_PMR_PBL_PAGE_SIZE_LOG_MASK) |
+			((wqe->frmr.levels << SQ_FR_PMR_NUMLEVELS_SFT) &
+					SQ_FR_PMR_NUMLEVELS_MASK);
+
+		for (i = 0; i < wqe->frmr.page_list_len; i++)
+			wqe->frmr.pbl_ptr[i] = cpu_to_le64(
+						wqe->frmr.page_list[i] |
+						PTU_PTE_VALID);
+		sqe->pblptr = cpu_to_le64(wqe->frmr.pbl_dma_ptr);
+		sqe->va = cpu_to_le64(wqe->frmr.va);
+
+		break;
+	}
+	case BNXT_QPLIB_SWQE_TYPE_BIND_MW:
+	{
+		struct sq_bind *sqe = (struct sq_bind *)hw_sq_send_hdr;
+
+		sqe->wqe_type = wqe->type;
+		sqe->flags = wqe->flags;
+		sqe->access_cntl = wqe->bind.access_cntl;
+		sqe->mw_type_zero_based = wqe->bind.mw_type |
+			(wqe->bind.zero_based ? SQ_BIND_ZERO_BASED : 0);
+		sqe->parent_l_key = cpu_to_le32(wqe->bind.parent_l_key);
+		sqe->l_key = cpu_to_le32(wqe->bind.r_key);
+		sqe->va = cpu_to_le64(wqe->bind.va);
+		temp32 = cpu_to_le32(wqe->bind.length);
+		memcpy(&sqe->length, &temp32, sizeof(wqe->bind.length));
+		break;
+	}
+	default:
+		/* Bad wqe, return error */
+		rc = -EINVAL;
+		goto done;
+	}
+	swq->next_psn = sq->psn & BTH_PSN_MASK;
+	if (swq->psn_search) {
+		swq->psn_search->opcode_start_psn = cpu_to_le32(
+			((swq->start_psn << SQ_PSN_SEARCH_START_PSN_SFT) &
+			 SQ_PSN_SEARCH_START_PSN_MASK) |
+			((wqe->type << SQ_PSN_SEARCH_OPCODE_SFT) &
+			 SQ_PSN_SEARCH_OPCODE_MASK));
+		swq->psn_search->flags_next_psn = cpu_to_le32(
+			((swq->next_psn << SQ_PSN_SEARCH_NEXT_PSN_SFT) &
+			 SQ_PSN_SEARCH_NEXT_PSN_MASK));
+	}
+
+	sq->hwq.prod++;
+done:
+	return rc;
+}
+
 /* CQ */
 
 /* Spinlock must be held */
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h
index e62c750..0a87920 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_qplib_fp.h
@@ -38,6 +38,9 @@
 
 #ifndef __BNXT_QPLIB_FP_H__
 #define __BNXT_QPLIB_FP_H__
+
+#define BNXT_QPLIB_ETHTYPE_ROCEV1      0x8915
+
 struct bnxt_qplib_sge {
 	u64				addr;
 	u32				lkey;
@@ -415,6 +418,11 @@ int bnxt_qplib_create_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp);
 int bnxt_qplib_modify_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp);
 int bnxt_qplib_query_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp);
 int bnxt_qplib_destroy_qp(struct bnxt_qplib_res *res, struct bnxt_qplib_qp *qp);
+void *bnxt_qplib_get_qp1_sq_buf(struct bnxt_qplib_qp *qp,
+				struct bnxt_qplib_sge *sge);
+void bnxt_qplib_post_send_db(struct bnxt_qplib_qp *qp);
+int bnxt_qplib_post_send(struct bnxt_qplib_qp *qp,
+			 struct bnxt_qplib_swqe *wqe);
 int bnxt_qplib_create_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq);
 int bnxt_qplib_destroy_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq);
 
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re.h b/drivers/infiniband/hw/bnxtre/bnxt_re.h
index f53ebd9..6281e23 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re.h
@@ -131,6 +131,10 @@ struct bnxt_re_dev {
 #define to_bnxt_re_dev(ptr, member)	\
 	container_of((ptr), struct bnxt_re_dev, member)
 
+#define BNXT_RE_ROCE_V1_PACKET		0
+#define BNXT_RE_ROCEV2_IPV4_PACKET	2
+#define BNXT_RE_ROCEV2_IPV6_PACKET	3
+
 static inline struct device *rdev_to_dev(struct bnxt_re_dev *rdev)
 {
 	if (rdev)
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
index 9df6fb8..ff406e9 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
@@ -60,6 +60,20 @@
 #include "bnxt_re_ib_verbs.h"
 #include <rdma/bnxtre-abi.h>
 
+static int bnxt_re_build_sgl(struct ib_sge *ib_sg_list,
+			     struct bnxt_qplib_sge *sg_list, int num)
+{
+	int i, total = 0;
+
+	for (i = 0; i < num; i++) {
+		sg_list[i].addr = ib_sg_list[i].addr;
+		sg_list[i].lkey = ib_sg_list[i].lkey;
+		sg_list[i].size = ib_sg_list[i].length;
+		total += sg_list[i].size;
+	}
+	return total;
+}
+
 /* Device */
 struct net_device *bnxt_re_get_netdev(struct ib_device *ibdev, u8 port_num)
 {
@@ -698,8 +712,6 @@ static u8 __from_ib_qp_type(enum ib_qp_type type)
 		return CMDQ_CREATE_QP_TYPE_RC;
 	case IB_QPT_UD:
 		return CMDQ_CREATE_QP_TYPE_UD;
-	case IB_QPT_RAW_ETHERTYPE:
-		return CMDQ_CREATE_QP_TYPE_RAW_ETHERTYPE;
 	default:
 		return IB_QPT_MAX;
 	}
@@ -873,7 +885,6 @@ struct ib_qp *bnxt_re_create_qp(struct ib_pd *ib_pd,
 	struct bnxt_re_dev *rdev = pd->rdev;
 	struct bnxt_qplib_dev_attr *dev_attr = &rdev->dev_attr;
 	struct bnxt_re_qp *qp;
-	struct bnxt_re_srq *srq;
 	struct bnxt_re_cq *cq;
 	int rc, entries;
 
@@ -1445,6 +1456,533 @@ int bnxt_re_query_qp(struct ib_qp *ib_qp, struct ib_qp_attr *qp_attr,
 	return 0;
 }
 
+/* Routine for sending QP1 packets for RoCE V1 an V2
+ */
+static int bnxt_re_build_qp1_send_v2(struct bnxt_re_qp *qp,
+				     struct ib_send_wr *wr,
+				     struct bnxt_qplib_swqe *wqe,
+				     int payload_size)
+{
+	struct ib_device *ibdev = &qp->rdev->ibdev;
+	struct bnxt_re_ah *ah = container_of(ud_wr(wr)->ah, struct bnxt_re_ah,
+					     ib_ah);
+	struct bnxt_qplib_ah *qplib_ah = &ah->qplib_ah;
+	struct bnxt_qplib_sge sge;
+	union ib_gid sgid;
+	u8 nw_type;
+	u16 ether_type;
+	struct ib_gid_attr sgid_attr;
+	union ib_gid dgid;
+	bool is_eth = false;
+	bool is_vlan = false;
+	bool is_grh = false;
+	bool is_udp = false;
+	u8 ip_version = 0;
+	u16 vlan_id = 0xFFFF;
+	void *buf;
+	int i, rc = 0, size;
+
+	memset(&qp->qp1_hdr, 0, sizeof(qp->qp1_hdr));
+
+	rc = ib_get_cached_gid(ibdev, 1,
+			       qplib_ah->host_sgid_index, &sgid,
+			       &sgid_attr);
+	if (rc) {
+		dev_err(rdev_to_dev(qp->rdev),
+			"Failed to query gid at index %d",
+			qplib_ah->host_sgid_index);
+		return rc;
+	}
+	if (sgid_attr.ndev) {
+		if (is_vlan_dev(sgid_attr.ndev))
+			vlan_id = vlan_dev_vlan_id(sgid_attr.ndev);
+		dev_put(sgid_attr.ndev);
+	}
+	/* Get network header type for this GID */
+	nw_type = ib_gid_to_network_type(sgid_attr.gid_type, &sgid);
+	switch (nw_type) {
+	case RDMA_NETWORK_IPV4:
+		nw_type = BNXT_RE_ROCEV2_IPV4_PACKET;
+		break;
+	case RDMA_NETWORK_IPV6:
+		nw_type = BNXT_RE_ROCEV2_IPV6_PACKET;
+		break;
+	default:
+		nw_type = BNXT_RE_ROCE_V1_PACKET;
+		break;
+	}
+	memcpy(&dgid.raw, &qplib_ah->dgid, 16);
+	is_udp = sgid_attr.gid_type == IB_GID_TYPE_ROCE_UDP_ENCAP;
+	if (is_udp) {
+		if (ipv6_addr_v4mapped((struct in6_addr *)&sgid)) {
+			ip_version = 4;
+			ether_type = ETH_P_IP;
+		} else {
+			ip_version = 6;
+			ether_type = ETH_P_IPV6;
+		}
+		is_grh = false;
+	} else {
+		ether_type = BNXT_QPLIB_ETHTYPE_ROCEV1;
+		is_grh = true;
+	}
+
+	is_eth = true;
+	is_vlan = (vlan_id && (vlan_id < 0x1000)) ? true : false;
+
+	ib_ud_header_init(payload_size, !is_eth, is_eth, is_vlan, is_grh,
+			  ip_version, is_udp, 0, &qp->qp1_hdr);
+
+	/* ETH */
+	ether_addr_copy(qp->qp1_hdr.eth.dmac_h, ah->qplib_ah.dmac);
+	ether_addr_copy(qp->qp1_hdr.eth.smac_h, qp->qplib_qp.smac);
+
+	/* For vlan, check the sgid for vlan existence */
+
+	if (!is_vlan) {
+		qp->qp1_hdr.eth.type = cpu_to_be16(ether_type);
+	} else {
+		qp->qp1_hdr.vlan.type = cpu_to_be16(ether_type);
+		qp->qp1_hdr.vlan.tag = cpu_to_be16(vlan_id);
+	}
+
+	if (is_grh || (ip_version == 6)) {
+		memcpy(qp->qp1_hdr.grh.source_gid.raw, sgid.raw, sizeof(sgid));
+		memcpy(qp->qp1_hdr.grh.destination_gid.raw, qplib_ah->dgid.data,
+		       sizeof(sgid));
+		qp->qp1_hdr.grh.hop_limit     = qplib_ah->hop_limit;
+	}
+
+	if (ip_version == 4) {
+		qp->qp1_hdr.ip4.tos = 0;
+		qp->qp1_hdr.ip4.id = 0;
+		qp->qp1_hdr.ip4.frag_off = htons(IP_DF);
+		qp->qp1_hdr.ip4.ttl = qplib_ah->hop_limit;
+
+		memcpy(&qp->qp1_hdr.ip4.saddr, sgid.raw + 12, 4);
+		memcpy(&qp->qp1_hdr.ip4.daddr, qplib_ah->dgid.data + 12, 4);
+		qp->qp1_hdr.ip4.check = ib_ud_ip4_csum(&qp->qp1_hdr);
+	}
+
+	if (is_udp) {
+		qp->qp1_hdr.udp.dport = htons(ROCE_V2_UDP_DPORT);
+		qp->qp1_hdr.udp.sport = htons(0x8CD1);
+		qp->qp1_hdr.udp.csum = 0;
+	}
+
+	/* BTH */
+	if (wr->opcode == IB_WR_SEND_WITH_IMM) {
+		qp->qp1_hdr.bth.opcode = IB_OPCODE_UD_SEND_ONLY_WITH_IMMEDIATE;
+		qp->qp1_hdr.immediate_present = 1;
+	} else {
+		qp->qp1_hdr.bth.opcode = IB_OPCODE_UD_SEND_ONLY;
+	}
+	if (wr->send_flags & IB_SEND_SOLICITED)
+		qp->qp1_hdr.bth.solicited_event = 1;
+	/* pad_count */
+	qp->qp1_hdr.bth.pad_count = (4 - payload_size) & 3;
+
+	/* P_key for QP1 is for all members */
+	qp->qp1_hdr.bth.pkey = cpu_to_be16(0xFFFF);
+	qp->qp1_hdr.bth.destination_qpn = IB_QP1;
+	qp->qp1_hdr.bth.ack_req = 0;
+	qp->send_psn++;
+	qp->send_psn &= BTH_PSN_MASK;
+	qp->qp1_hdr.bth.psn = cpu_to_be32(qp->send_psn);
+	/* DETH */
+	/* Use the priviledged Q_Key for QP1 */
+	qp->qp1_hdr.deth.qkey = cpu_to_be32(IB_QP1_QKEY);
+	qp->qp1_hdr.deth.source_qpn = IB_QP1;
+
+	/* Pack the QP1 to the transmit buffer */
+	buf = bnxt_qplib_get_qp1_sq_buf(&qp->qplib_qp, &sge);
+	if (buf) {
+		size = ib_ud_header_pack(&qp->qp1_hdr, buf);
+		for (i = wqe->num_sge; i; i--) {
+			wqe->sg_list[i].addr = wqe->sg_list[i - 1].addr;
+			wqe->sg_list[i].lkey = wqe->sg_list[i - 1].lkey;
+			wqe->sg_list[i].size = wqe->sg_list[i - 1].size;
+		}
+
+		/*
+		 * Max Header buf size for IPV6 RoCE V2 is 86,
+		 * which is same as the QP1 SQ header buffer.
+		 * Header buf size for IPV4 RoCE V2 can be 66.
+		 * ETH(14) + VLAN(4)+ IP(20) + UDP (8) + BTH(20).
+		 * Subtract 20 bytes from QP1 SQ header buf size
+		 */
+		if (is_udp && ip_version == 4)
+			sge.size -= 20;
+		/*
+		 * Max Header buf size for RoCE V1 is 78.
+		 * ETH(14) + VLAN(4) + GRH(40) + BTH(20).
+		 * Subtract 8 bytes from QP1 SQ header buf size
+		 */
+		if (!is_udp)
+			sge.size -= 8;
+
+		/* Subtract 4 bytes for non vlan packets */
+		if (!is_vlan)
+			sge.size -= 4;
+
+		wqe->sg_list[0].addr = sge.addr;
+		wqe->sg_list[0].lkey = sge.lkey;
+		wqe->sg_list[0].size = sge.size;
+		wqe->num_sge++;
+
+	} else {
+		dev_err(rdev_to_dev(qp->rdev), "QP1 buffer is empty!");
+		rc = -ENOMEM;
+	}
+	return rc;
+}
+
+static int is_ud_qp(struct bnxt_re_qp *qp)
+{
+	return qp->qplib_qp.type == CMDQ_CREATE_QP_TYPE_UD;
+}
+
+static int bnxt_re_build_send_wqe(struct bnxt_re_qp *qp,
+				  struct ib_send_wr *wr,
+				  struct bnxt_qplib_swqe *wqe)
+{
+	struct bnxt_re_ah *ah = NULL;
+
+	if (is_ud_qp(qp)) {
+		ah = container_of(ud_wr(wr)->ah, struct bnxt_re_ah, ib_ah);
+		wqe->send.q_key = ud_wr(wr)->remote_qkey;
+		wqe->send.dst_qp = ud_wr(wr)->remote_qpn;
+		wqe->send.avid = ah->qplib_ah.id;
+	}
+	switch (wr->opcode) {
+	case IB_WR_SEND:
+		wqe->type = BNXT_QPLIB_SWQE_TYPE_SEND;
+		break;
+	case IB_WR_SEND_WITH_IMM:
+		wqe->type = BNXT_QPLIB_SWQE_TYPE_SEND_WITH_IMM;
+		wqe->send.imm_data = wr->ex.imm_data;
+		break;
+	case IB_WR_SEND_WITH_INV:
+		wqe->type = BNXT_QPLIB_SWQE_TYPE_SEND_WITH_INV;
+		wqe->send.inv_key = wr->ex.invalidate_rkey;
+		break;
+	default:
+		return -EINVAL;
+	}
+	if (wr->send_flags & IB_SEND_SIGNALED)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_SIGNAL_COMP;
+	if (wr->send_flags & IB_SEND_FENCE)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_UC_FENCE;
+	if (wr->send_flags & IB_SEND_SOLICITED)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_SOLICIT_EVENT;
+	if (wr->send_flags & IB_SEND_INLINE)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_INLINE;
+
+	return 0;
+}
+
+static int bnxt_re_build_rdma_wqe(struct ib_send_wr *wr,
+				  struct bnxt_qplib_swqe *wqe)
+{
+	switch (wr->opcode) {
+	case IB_WR_RDMA_WRITE:
+		wqe->type = BNXT_QPLIB_SWQE_TYPE_RDMA_WRITE;
+		break;
+	case IB_WR_RDMA_WRITE_WITH_IMM:
+		wqe->type = BNXT_QPLIB_SWQE_TYPE_RDMA_WRITE_WITH_IMM;
+		wqe->rdma.imm_data = wr->ex.imm_data;
+		break;
+	case IB_WR_RDMA_READ:
+		wqe->type = BNXT_QPLIB_SWQE_TYPE_RDMA_READ;
+		wqe->rdma.inv_key = wr->ex.invalidate_rkey;
+		break;
+	default:
+		return -EINVAL;
+	}
+	wqe->rdma.remote_va = rdma_wr(wr)->remote_addr;
+	wqe->rdma.r_key = rdma_wr(wr)->rkey;
+	if (wr->send_flags & IB_SEND_SIGNALED)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_SIGNAL_COMP;
+	if (wr->send_flags & IB_SEND_FENCE)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_UC_FENCE;
+	if (wr->send_flags & IB_SEND_SOLICITED)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_SOLICIT_EVENT;
+	if (wr->send_flags & IB_SEND_INLINE)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_INLINE;
+
+	return 0;
+}
+
+static int bnxt_re_build_atomic_wqe(struct ib_send_wr *wr,
+				    struct bnxt_qplib_swqe *wqe)
+{
+	switch (wr->opcode) {
+	case IB_WR_ATOMIC_CMP_AND_SWP:
+		wqe->type = BNXT_QPLIB_SWQE_TYPE_ATOMIC_CMP_AND_SWP;
+		wqe->atomic.swap_data = atomic_wr(wr)->swap;
+		break;
+	case IB_WR_ATOMIC_FETCH_AND_ADD:
+		wqe->type = BNXT_QPLIB_SWQE_TYPE_ATOMIC_FETCH_AND_ADD;
+		wqe->atomic.cmp_data = atomic_wr(wr)->compare_add;
+		break;
+	default:
+		return -EINVAL;
+	}
+	wqe->atomic.remote_va = atomic_wr(wr)->remote_addr;
+	wqe->atomic.r_key = atomic_wr(wr)->rkey;
+	if (wr->send_flags & IB_SEND_SIGNALED)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_SIGNAL_COMP;
+	if (wr->send_flags & IB_SEND_FENCE)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_UC_FENCE;
+	if (wr->send_flags & IB_SEND_SOLICITED)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_SOLICIT_EVENT;
+	return 0;
+}
+
+static int bnxt_re_build_inv_wqe(struct ib_send_wr *wr,
+				 struct bnxt_qplib_swqe *wqe)
+{
+	wqe->type = BNXT_QPLIB_SWQE_TYPE_LOCAL_INV;
+	wqe->local_inv.inv_l_key = wr->ex.invalidate_rkey;
+
+	if (wr->send_flags & IB_SEND_SIGNALED)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_SIGNAL_COMP;
+	if (wr->send_flags & IB_SEND_FENCE)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_UC_FENCE;
+	if (wr->send_flags & IB_SEND_SOLICITED)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_SOLICIT_EVENT;
+
+	return 0;
+}
+
+static int bnxt_re_build_reg_wqe(struct ib_reg_wr *wr,
+				 struct bnxt_qplib_swqe *wqe)
+{
+	struct bnxt_re_mr *mr = container_of(wr->mr, struct bnxt_re_mr, ib_mr);
+	struct bnxt_qplib_frpl *qplib_frpl = &mr->qplib_frpl;
+	int access = wr->access;
+
+	wqe->frmr.pbl_ptr = (__le64 *)qplib_frpl->hwq.pbl_ptr[0];
+	wqe->frmr.pbl_dma_ptr = qplib_frpl->hwq.pbl_dma_ptr[0];
+	wqe->frmr.page_list = mr->pages;
+	wqe->frmr.page_list_len = mr->npages;
+	wqe->frmr.levels = qplib_frpl->hwq.level + 1;
+	wqe->type = BNXT_QPLIB_SWQE_TYPE_REG_MR;
+
+	if (wr->wr.send_flags & IB_SEND_FENCE)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_UC_FENCE;
+	if (wr->wr.send_flags & IB_SEND_SIGNALED)
+		wqe->flags |= BNXT_QPLIB_SWQE_FLAGS_SIGNAL_COMP;
+
+	if (access & IB_ACCESS_LOCAL_WRITE)
+		wqe->frmr.access_cntl |= SQ_FR_PMR_ACCESS_CNTL_LOCAL_WRITE;
+	if (access & IB_ACCESS_REMOTE_READ)
+		wqe->frmr.access_cntl |= SQ_FR_PMR_ACCESS_CNTL_REMOTE_READ;
+	if (access & IB_ACCESS_REMOTE_WRITE)
+		wqe->frmr.access_cntl |= SQ_FR_PMR_ACCESS_CNTL_REMOTE_WRITE;
+	if (access & IB_ACCESS_REMOTE_ATOMIC)
+		wqe->frmr.access_cntl |= SQ_FR_PMR_ACCESS_CNTL_REMOTE_ATOMIC;
+	if (access & IB_ACCESS_MW_BIND)
+		wqe->frmr.access_cntl |= SQ_FR_PMR_ACCESS_CNTL_WINDOW_BIND;
+
+	wqe->frmr.l_key = wr->key;
+	wqe->frmr.length = wr->mr->length;
+	wqe->frmr.pbl_pg_sz_log = (wr->mr->page_size >> PAGE_SHIFT_4K) - 1;
+	wqe->frmr.va = wr->mr->iova;
+	return 0;
+}
+
+static int bnxt_re_copy_inline_data(struct bnxt_re_dev *rdev,
+				    struct ib_send_wr *wr,
+				    struct bnxt_qplib_swqe *wqe)
+{
+	/*  Copy the inline data to the data  field */
+	u8 *in_data;
+	u32 i, sge_len;
+	void *sge_addr;
+
+	in_data = wqe->inline_data;
+	for (i = 0; i < wr->num_sge; i++) {
+		sge_addr = (void *)(unsigned long)
+				wr->sg_list[i].addr;
+		sge_len = wr->sg_list[i].length;
+
+		if ((sge_len + wqe->inline_len) >
+		    BNXT_QPLIB_SWQE_MAX_INLINE_LENGTH) {
+			dev_err(rdev_to_dev(rdev),
+				"Inline data size requested > supported value");
+			return -EINVAL;
+		}
+		sge_len = wr->sg_list[i].length;
+
+		memcpy(in_data, sge_addr, sge_len);
+		in_data += wr->sg_list[i].length;
+		wqe->inline_len += wr->sg_list[i].length;
+	}
+	return wqe->inline_len;
+}
+
+static int bnxt_re_copy_wr_payload(struct bnxt_re_dev *rdev,
+				   struct ib_send_wr *wr,
+				   struct bnxt_qplib_swqe *wqe)
+{
+	int payload_sz = 0;
+
+	if (wr->send_flags & IB_SEND_INLINE)
+		payload_sz = bnxt_re_copy_inline_data(rdev, wr, wqe);
+	else
+		payload_sz = bnxt_re_build_sgl(wr->sg_list, wqe->sg_list,
+					       wqe->num_sge);
+
+	return payload_sz;
+}
+
+static int bnxt_re_post_send_shadow_qp(struct bnxt_re_dev *rdev,
+				       struct bnxt_re_qp *qp,
+				struct ib_send_wr *wr)
+{
+	struct bnxt_qplib_swqe wqe;
+	int rc = 0, payload_sz = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&qp->sq_lock, flags);
+	memset(&wqe, 0, sizeof(wqe));
+	while (wr) {
+		/* House keeping */
+		memset(&wqe, 0, sizeof(wqe));
+
+		/* Common */
+		wqe.num_sge = wr->num_sge;
+		if (wr->num_sge > qp->qplib_qp.sq.max_sge) {
+			dev_err(rdev_to_dev(rdev),
+				"Limit exceeded for Send SGEs");
+			rc = -EINVAL;
+			goto bad;
+		}
+
+		payload_sz = bnxt_re_copy_wr_payload(qp->rdev, wr, &wqe);
+		if (payload_sz < 0) {
+			rc = -EINVAL;
+			goto bad;
+		}
+		wqe.wr_id = wr->wr_id;
+
+		wqe.type = BNXT_QPLIB_SWQE_TYPE_SEND;
+
+		rc = bnxt_re_build_send_wqe(qp, wr, &wqe);
+		if (!rc)
+			rc = bnxt_qplib_post_send(&qp->qplib_qp, &wqe);
+bad:
+		if (rc) {
+			dev_err(rdev_to_dev(rdev),
+				"Post send failed opcode = %#x rc = %d",
+				wr->opcode, rc);
+			break;
+		}
+		wr = wr->next;
+	}
+	bnxt_qplib_post_send_db(&qp->qplib_qp);
+	spin_unlock_irqrestore(&qp->sq_lock, flags);
+	return rc;
+}
+
+int bnxt_re_post_send(struct ib_qp *ib_qp, struct ib_send_wr *wr,
+		      struct ib_send_wr **bad_wr)
+{
+	struct bnxt_re_qp *qp = container_of(ib_qp, struct bnxt_re_qp, ib_qp);
+	struct bnxt_qplib_swqe wqe;
+	int rc = 0, payload_sz = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&qp->sq_lock, flags);
+	while (wr) {
+		/* House keeping */
+		memset(&wqe, 0, sizeof(wqe));
+
+		/* Common */
+		wqe.num_sge = wr->num_sge;
+		if (wr->num_sge > qp->qplib_qp.sq.max_sge) {
+			dev_err(rdev_to_dev(qp->rdev),
+				"Limit exceeded for Send SGEs");
+			rc = -EINVAL;
+			goto bad;
+		}
+
+		payload_sz = bnxt_re_copy_wr_payload(qp->rdev, wr, &wqe);
+		if (payload_sz < 0) {
+			rc = -EINVAL;
+			goto bad;
+		}
+		wqe.wr_id = wr->wr_id;
+
+		switch (wr->opcode) {
+		case IB_WR_SEND:
+		case IB_WR_SEND_WITH_IMM:
+			if (ib_qp->qp_type == IB_QPT_GSI) {
+				rc = bnxt_re_build_qp1_send_v2(qp, wr, &wqe,
+							       payload_sz);
+				if (rc)
+					goto bad;
+				wqe.rawqp1.lflags |=
+					SQ_SEND_RAWETH_QP1_LFLAGS_ROCE_CRC;
+			}
+			switch (wr->send_flags) {
+			case IB_SEND_IP_CSUM:
+				wqe.rawqp1.lflags |=
+					SQ_SEND_RAWETH_QP1_LFLAGS_IP_CHKSUM;
+				break;
+			default:
+				break;
+			}
+			/* Fall thru to build the wqe */
+		case IB_WR_SEND_WITH_INV:
+			rc = bnxt_re_build_send_wqe(qp, wr, &wqe);
+			break;
+		case IB_WR_RDMA_WRITE:
+		case IB_WR_RDMA_WRITE_WITH_IMM:
+		case IB_WR_RDMA_READ:
+			rc = bnxt_re_build_rdma_wqe(wr, &wqe);
+			break;
+		case IB_WR_ATOMIC_CMP_AND_SWP:
+		case IB_WR_ATOMIC_FETCH_AND_ADD:
+			rc = bnxt_re_build_atomic_wqe(wr, &wqe);
+			break;
+		case IB_WR_RDMA_READ_WITH_INV:
+			dev_err(rdev_to_dev(qp->rdev),
+				"RDMA Read with Invalidate is not supported");
+			rc = -EINVAL;
+			goto bad;
+		case IB_WR_LOCAL_INV:
+			rc = bnxt_re_build_inv_wqe(wr, &wqe);
+			break;
+		case IB_WR_REG_MR:
+			rc = bnxt_re_build_reg_wqe(reg_wr(wr), &wqe);
+			break;
+		default:
+			/* Unsupported WRs */
+			dev_err(rdev_to_dev(qp->rdev),
+				"WR (%#x) is not supported", wr->opcode);
+			rc = -EINVAL;
+			goto bad;
+		}
+		if (!rc)
+			rc = bnxt_qplib_post_send(&qp->qplib_qp, &wqe);
+bad:
+		if (rc) {
+			dev_err(rdev_to_dev(qp->rdev),
+				"post_send failed op:%#x qps = %#x rc = %d\n",
+				wr->opcode, qp->qplib_qp.state, rc);
+			*bad_wr = wr;
+			break;
+		}
+		wr = wr->next;
+	}
+	bnxt_qplib_post_send_db(&qp->qplib_qp);
+	spin_unlock_irqrestore(&qp->sq_lock, flags);
+
+	return rc;
+}
+
 /* Completion Queues */
 int bnxt_re_destroy_cq(struct ib_cq *ib_cq)
 {
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
index 75ee88a..becdcdc 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
@@ -162,6 +162,8 @@ int bnxt_re_modify_qp(struct ib_qp *qp, struct ib_qp_attr *qp_attr,
 int bnxt_re_query_qp(struct ib_qp *qp, struct ib_qp_attr *qp_attr,
 		     int qp_attr_mask, struct ib_qp_init_attr *qp_init_attr);
 int bnxt_re_destroy_qp(struct ib_qp *qp);
+int bnxt_re_post_send(struct ib_qp *qp, struct ib_send_wr *send_wr,
+		      struct ib_send_wr **bad_send_wr);
 struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
 				const struct ib_cq_init_attr *attr,
 				struct ib_ucontext *context,
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
index 2396730..03a34c0 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -462,6 +462,7 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 	ibdev->query_qp			= bnxt_re_query_qp;
 	ibdev->destroy_qp		= bnxt_re_destroy_qp;
 
+	ibdev->post_send		= bnxt_re_post_send;
 	ibdev->create_cq		= bnxt_re_create_cq;
 	ibdev->destroy_cq		= bnxt_re_destroy_cq;
 	ibdev->req_notify_cq		= bnxt_re_req_notify_cq;
-- 
2.5.5
