From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH V3 5/9] IB/mlx5: Mellanox Connect-IB, IB driver part 1/5
Date: Sun,  7 Jul 2013 17:25:53 +0300
Message-ID: <1373207157-13914-6-git-send-email-ogerlitz@mellanox.com>
References: <1373207157-13914-1-git-send-email-ogerlitz@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org,
	eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1373207157-13914-1-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Signed-off-by: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/ah.c       |   92 ++++
 drivers/infiniband/hw/mlx5/cq.c       |  843 +++++++++++++++++++++++++++++++++
 drivers/infiniband/hw/mlx5/doorbell.c |  100 ++++
 drivers/infiniband/hw/mlx5/mad.c      |  139 ++++++
 4 files changed, 1174 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/hw/mlx5/ah.c
 create mode 100644 drivers/infiniband/hw/mlx5/cq.c
 create mode 100644 drivers/infiniband/hw/mlx5/doorbell.c
 create mode 100644 drivers/infiniband/hw/mlx5/mad.c

diff --git a/drivers/infiniband/hw/mlx5/ah.c b/drivers/infiniband/hw/mlx5/ah.c
new file mode 100644
index 0000000..39ab0ca
--- /dev/null
+++ b/drivers/infiniband/hw/mlx5/ah.c
@@ -0,0 +1,92 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include "mlx5_ib.h"
+
+struct ib_ah *create_ib_ah(struct ib_ah_attr *ah_attr,
+			   struct mlx5_ib_ah *ah)
+{
+	if (ah_attr->ah_flags & IB_AH_GRH) {
+		memcpy(ah->av.rgid, &ah_attr->grh.dgid, 16);
+		ah->av.grh_gid_fl = cpu_to_be32(ah_attr->grh.flow_label |
+						(1 << 30) |
+						ah_attr->grh.sgid_index << 20);
+		ah->av.hop_limit = ah_attr->grh.hop_limit;
+		ah->av.tclass = ah_attr->grh.traffic_class;
+	}
+
+	ah->av.rlid = cpu_to_be16(ah_attr->dlid);
+	ah->av.fl_mlid = ah_attr->src_path_bits & 0x7f;
+	ah->av.stat_rate_sl = (ah_attr->static_rate << 4) | (ah_attr->sl & 0xf);
+
+	return &ah->ibah;
+}
+
+struct ib_ah *mlx5_ib_create_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr)
+{
+	struct mlx5_ib_ah *ah;
+
+	ah = kzalloc(sizeof(*ah), GFP_ATOMIC);
+	if (!ah)
+		return ERR_PTR(-ENOMEM);
+
+	return create_ib_ah(ah_attr, ah); /* never fails */
+}
+
+int mlx5_ib_query_ah(struct ib_ah *ibah, struct ib_ah_attr *ah_attr)
+{
+	struct mlx5_ib_ah *ah = to_mah(ibah);
+	u32 tmp;
+
+	memset(ah_attr, 0, sizeof(*ah_attr));
+
+	tmp = be32_to_cpu(ah->av.grh_gid_fl);
+	if (tmp & (1 << 30)) {
+		ah_attr->ah_flags = IB_AH_GRH;
+		ah_attr->grh.sgid_index = (tmp >> 20) & 0xff;
+		ah_attr->grh.flow_label = tmp & 0xfffff;
+		memcpy(&ah_attr->grh.dgid, ah->av.rgid, 16);
+		ah_attr->grh.hop_limit = ah->av.hop_limit;
+		ah_attr->grh.traffic_class = ah->av.tclass;
+	}
+	ah_attr->dlid = be16_to_cpu(ah->av.rlid);
+	ah_attr->static_rate = ah->av.stat_rate_sl >> 4;
+	ah_attr->sl = ah->av.stat_rate_sl & 0xf;
+
+	return 0;
+}
+
+int mlx5_ib_destroy_ah(struct ib_ah *ah)
+{
+	kfree(to_mah(ah));
+	return 0;
+}
diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
new file mode 100644
index 0000000..344ab03
--- /dev/null
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -0,0 +1,843 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/kref.h>
+#include <rdma/ib_umem.h>
+#include "mlx5_ib.h"
+#include "user.h"
+
+static void mlx5_ib_cq_comp(struct mlx5_core_cq *cq)
+{
+	struct ib_cq *ibcq = &to_mibcq(cq)->ibcq;
+
+	ibcq->comp_handler(ibcq, ibcq->cq_context);
+}
+
+static void mlx5_ib_cq_event(struct mlx5_core_cq *mcq, enum mlx5_event type)
+{
+	struct mlx5_ib_cq *cq = container_of(mcq, struct mlx5_ib_cq, mcq);
+	struct mlx5_ib_dev *dev = to_mdev(cq->ibcq.device);
+	struct ib_cq *ibcq = &cq->ibcq;
+	struct ib_event event;
+
+	if (type != MLX5_EVENT_TYPE_CQ_ERROR) {
+		mlx5_ib_warn(dev, "Unexpected event type %d on CQ %06x\n",
+			     type, mcq->cqn);
+		return;
+	}
+
+	if (ibcq->event_handler) {
+		event.device     = &dev->ib_dev;
+		event.event      = IB_EVENT_CQ_ERR;
+		event.element.cq = ibcq;
+		ibcq->event_handler(&event, ibcq->cq_context);
+	}
+}
+
+static void *get_cqe_from_buf(struct mlx5_ib_cq_buf *buf, int n, int size)
+{
+	return mlx5_buf_offset(&buf->buf, n * size);
+}
+
+static void *get_cqe(struct mlx5_ib_cq *cq, int n)
+{
+	return get_cqe_from_buf(&cq->buf, n, cq->mcq.cqe_sz);
+}
+
+static void *get_sw_cqe(struct mlx5_ib_cq *cq, int n)
+{
+	void *cqe = get_cqe(cq, n & cq->ibcq.cqe);
+	struct mlx5_cqe64 *cqe64;
+
+	cqe64 = (cq->mcq.cqe_sz == 64) ? cqe : cqe + 64;
+	return ((cqe64->op_own & MLX5_CQE_OWNER_MASK) ^
+		!!(n & (cq->ibcq.cqe + 1))) ? NULL : cqe;
+}
+
+static void *next_cqe_sw(struct mlx5_ib_cq *cq)
+{
+	return get_sw_cqe(cq, cq->mcq.cons_index);
+}
+
+static enum ib_wc_opcode get_umr_comp(struct mlx5_ib_wq *wq, int idx)
+{
+	switch (wq->wr_data[idx]) {
+	case MLX5_IB_WR_UMR:
+		return 0;
+
+	case IB_WR_LOCAL_INV:
+		return IB_WC_LOCAL_INV;
+
+	case IB_WR_FAST_REG_MR:
+		return IB_WC_FAST_REG_MR;
+
+	default:
+		pr_warn("unknown completion status\n");
+		return 0;
+	}
+}
+
+static void handle_good_req(struct ib_wc *wc, struct mlx5_cqe64 *cqe,
+			    struct mlx5_ib_wq *wq, int idx)
+{
+	wc->wc_flags = 0;
+	switch (be32_to_cpu(cqe->sop_drop_qpn) >> 24) {
+	case MLX5_OPCODE_RDMA_WRITE_IMM:
+		wc->wc_flags |= IB_WC_WITH_IMM;
+	case MLX5_OPCODE_RDMA_WRITE:
+		wc->opcode    = IB_WC_RDMA_WRITE;
+		break;
+	case MLX5_OPCODE_SEND_IMM:
+		wc->wc_flags |= IB_WC_WITH_IMM;
+	case MLX5_OPCODE_SEND:
+	case MLX5_OPCODE_SEND_INVAL:
+		wc->opcode    = IB_WC_SEND;
+		break;
+	case MLX5_OPCODE_RDMA_READ:
+		wc->opcode    = IB_WC_RDMA_READ;
+		wc->byte_len  = be32_to_cpu(cqe->byte_cnt);
+		break;
+	case MLX5_OPCODE_ATOMIC_CS:
+		wc->opcode    = IB_WC_COMP_SWAP;
+		wc->byte_len  = 8;
+		break;
+	case MLX5_OPCODE_ATOMIC_FA:
+		wc->opcode    = IB_WC_FETCH_ADD;
+		wc->byte_len  = 8;
+		break;
+	case MLX5_OPCODE_ATOMIC_MASKED_CS:
+		wc->opcode    = IB_WC_MASKED_COMP_SWAP;
+		wc->byte_len  = 8;
+		break;
+	case MLX5_OPCODE_ATOMIC_MASKED_FA:
+		wc->opcode    = IB_WC_MASKED_FETCH_ADD;
+		wc->byte_len  = 8;
+		break;
+	case MLX5_OPCODE_BIND_MW:
+		wc->opcode    = IB_WC_BIND_MW;
+		break;
+	case MLX5_OPCODE_UMR:
+		wc->opcode = get_umr_comp(wq, idx);
+		break;
+	}
+}
+
+enum {
+	MLX5_GRH_IN_BUFFER = 1,
+	MLX5_GRH_IN_CQE	   = 2,
+};
+
+static void handle_responder(struct ib_wc *wc, struct mlx5_cqe64 *cqe,
+			     struct mlx5_ib_qp *qp)
+{
+	struct mlx5_ib_dev *dev = to_mdev(qp->ibqp.device);
+	struct mlx5_ib_srq *srq;
+	struct mlx5_ib_wq *wq;
+	u16 wqe_ctr;
+	u8 g;
+
+	if (qp->ibqp.srq || qp->ibqp.xrcd) {
+		struct mlx5_core_srq *msrq = NULL;
+
+		if (qp->ibqp.xrcd) {
+			msrq = mlx5_core_get_srq(&dev->mdev,
+						 be32_to_cpu(cqe->srqn));
+			srq = to_mibsrq(msrq);
+		} else {
+			srq = to_msrq(qp->ibqp.srq);
+		}
+		if (srq) {
+			wqe_ctr = be16_to_cpu(cqe->wqe_counter);
+			wc->wr_id = srq->wrid[wqe_ctr];
+			mlx5_ib_free_srq_wqe(srq, wqe_ctr);
+			if (msrq && atomic_dec_and_test(&msrq->refcount))
+				complete(&msrq->free);
+		}
+	} else {
+		wq	  = &qp->rq;
+		wc->wr_id = wq->wrid[wq->tail & (wq->wqe_cnt - 1)];
+		++wq->tail;
+	}
+	wc->byte_len = be32_to_cpu(cqe->byte_cnt);
+
+	switch (cqe->op_own >> 4) {
+	case MLX5_CQE_RESP_WR_IMM:
+		wc->opcode	= IB_WC_RECV_RDMA_WITH_IMM;
+		wc->wc_flags	= IB_WC_WITH_IMM;
+		wc->ex.imm_data = cqe->imm_inval_pkey;
+		break;
+	case MLX5_CQE_RESP_SEND:
+		wc->opcode   = IB_WC_RECV;
+		wc->wc_flags = 0;
+		break;
+	case MLX5_CQE_RESP_SEND_IMM:
+		wc->opcode	= IB_WC_RECV;
+		wc->wc_flags	= IB_WC_WITH_IMM;
+		wc->ex.imm_data = cqe->imm_inval_pkey;
+		break;
+	case MLX5_CQE_RESP_SEND_INV:
+		wc->opcode	= IB_WC_RECV;
+		wc->wc_flags	= IB_WC_WITH_INVALIDATE;
+		wc->ex.invalidate_rkey = be32_to_cpu(cqe->imm_inval_pkey);
+		break;
+	}
+	wc->slid	   = be16_to_cpu(cqe->slid);
+	wc->sl		   = (be32_to_cpu(cqe->flags_rqpn) >> 24) & 0xf;
+	wc->src_qp	   = be32_to_cpu(cqe->flags_rqpn) & 0xffffff;
+	wc->dlid_path_bits = cqe->ml_path;
+	g = (be32_to_cpu(cqe->flags_rqpn) >> 28) & 3;
+	wc->wc_flags |= g ? IB_WC_GRH : 0;
+	wc->pkey_index     = be32_to_cpu(cqe->imm_inval_pkey) & 0xffff;
+}
+
+static void dump_cqe(struct mlx5_ib_dev *dev, struct mlx5_err_cqe *cqe)
+{
+	__be32 *p = (__be32 *)cqe;
+	int i;
+
+	mlx5_ib_warn(dev, "dump error cqe\n");
+	for (i = 0; i < sizeof(*cqe) / 16; i++, p += 4)
+		pr_info("%08x %08x %08x %08x\n", be32_to_cpu(p[0]),
+			be32_to_cpu(p[1]), be32_to_cpu(p[2]),
+			be32_to_cpu(p[3]));
+}
+
+static void mlx5_handle_error_cqe(struct mlx5_ib_dev *dev,
+				  struct mlx5_err_cqe *cqe,
+				  struct ib_wc *wc)
+{
+	int dump = 1;
+
+	switch (cqe->syndrome) {
+	case MLX5_CQE_SYNDROME_LOCAL_LENGTH_ERR:
+		wc->status = IB_WC_LOC_LEN_ERR;
+		break;
+	case MLX5_CQE_SYNDROME_LOCAL_QP_OP_ERR:
+		wc->status = IB_WC_LOC_QP_OP_ERR;
+		break;
+	case MLX5_CQE_SYNDROME_LOCAL_PROT_ERR:
+		wc->status = IB_WC_LOC_PROT_ERR;
+		break;
+	case MLX5_CQE_SYNDROME_WR_FLUSH_ERR:
+		dump = 0;
+		wc->status = IB_WC_WR_FLUSH_ERR;
+		break;
+	case MLX5_CQE_SYNDROME_MW_BIND_ERR:
+		wc->status = IB_WC_MW_BIND_ERR;
+		break;
+	case MLX5_CQE_SYNDROME_BAD_RESP_ERR:
+		wc->status = IB_WC_BAD_RESP_ERR;
+		break;
+	case MLX5_CQE_SYNDROME_LOCAL_ACCESS_ERR:
+		wc->status = IB_WC_LOC_ACCESS_ERR;
+		break;
+	case MLX5_CQE_SYNDROME_REMOTE_INVAL_REQ_ERR:
+		wc->status = IB_WC_REM_INV_REQ_ERR;
+		break;
+	case MLX5_CQE_SYNDROME_REMOTE_ACCESS_ERR:
+		wc->status = IB_WC_REM_ACCESS_ERR;
+		break;
+	case MLX5_CQE_SYNDROME_REMOTE_OP_ERR:
+		wc->status = IB_WC_REM_OP_ERR;
+		break;
+	case MLX5_CQE_SYNDROME_TRANSPORT_RETRY_EXC_ERR:
+		wc->status = IB_WC_RETRY_EXC_ERR;
+		dump = 0;
+		break;
+	case MLX5_CQE_SYNDROME_RNR_RETRY_EXC_ERR:
+		wc->status = IB_WC_RNR_RETRY_EXC_ERR;
+		dump = 0;
+		break;
+	case MLX5_CQE_SYNDROME_REMOTE_ABORTED_ERR:
+		wc->status = IB_WC_REM_ABORT_ERR;
+		break;
+	default:
+		wc->status = IB_WC_GENERAL_ERR;
+		break;
+	}
+
+	wc->vendor_err = cqe->vendor_err_synd;
+	if (dump)
+		dump_cqe(dev, cqe);
+}
+
+static int is_atomic_response(struct mlx5_ib_qp *qp, uint16_t idx)
+{
+	/* TBD: waiting decision
+	*/
+	return 0;
+}
+
+static void *mlx5_get_atomic_laddr(struct mlx5_ib_qp *qp, uint16_t idx)
+{
+	struct mlx5_wqe_data_seg *dpseg;
+	void *addr;
+
+	dpseg = mlx5_get_send_wqe(qp, idx) + sizeof(struct mlx5_wqe_ctrl_seg) +
+		sizeof(struct mlx5_wqe_raddr_seg) +
+		sizeof(struct mlx5_wqe_atomic_seg);
+	addr = (void *)(unsigned long)be64_to_cpu(dpseg->addr);
+	return addr;
+}
+
+static void handle_atomic(struct mlx5_ib_qp *qp, struct mlx5_cqe64 *cqe64,
+			  uint16_t idx)
+{
+	void *addr;
+	int byte_count;
+	int i;
+
+	if (!is_atomic_response(qp, idx))
+		return;
+
+	byte_count = be32_to_cpu(cqe64->byte_cnt);
+	addr = mlx5_get_atomic_laddr(qp, idx);
+
+	if (byte_count == 4) {
+		*(uint32_t *)addr = be32_to_cpu(*((__be32 *)addr));
+	} else {
+		for (i = 0; i < byte_count; i += 8) {
+			*(uint64_t *)addr = be64_to_cpu(*((__be64 *)addr));
+			addr += 8;
+		}
+	}
+
+	return;
+}
+
+static void handle_atomics(struct mlx5_ib_qp *qp, struct mlx5_cqe64 *cqe64,
+			   u16 tail, u16 head)
+{
+	int idx;
+
+	do {
+		idx = tail & (qp->sq.wqe_cnt - 1);
+		handle_atomic(qp, cqe64, idx);
+		if (idx == head)
+			break;
+
+		tail = qp->sq.w_list[idx].next;
+	} while (1);
+	tail = qp->sq.w_list[idx].next;
+	qp->sq.last_poll = tail;
+}
+
+static int mlx5_poll_one(struct mlx5_ib_cq *cq,
+			 struct mlx5_ib_qp **cur_qp,
+			 struct ib_wc *wc)
+{
+	struct mlx5_ib_dev *dev = to_mdev(cq->ibcq.device);
+	struct mlx5_err_cqe *err_cqe;
+	struct mlx5_cqe64 *cqe64;
+	struct mlx5_core_qp *mqp;
+	struct mlx5_ib_wq *wq;
+	uint8_t opcode;
+	uint32_t qpn;
+	u16 wqe_ctr;
+	void *cqe;
+	int idx;
+
+	cqe = next_cqe_sw(cq);
+	if (!cqe)
+		return -EAGAIN;
+
+	cqe64 = (cq->mcq.cqe_sz == 64) ? cqe : cqe + 64;
+
+	++cq->mcq.cons_index;
+
+	/* Make sure we read CQ entry contents after we've checked the
+	 * ownership bit.
+	 */
+	rmb();
+
+	/* TBD: resize CQ */
+
+	qpn = ntohl(cqe64->sop_drop_qpn) & 0xffffff;
+	if (!*cur_qp || (qpn != (*cur_qp)->ibqp.qp_num)) {
+		/* We do not have to take the QP table lock here,
+		 * because CQs will be locked while QPs are removed
+		 * from the table.
+		 */
+		mqp = __mlx5_qp_lookup(&dev->mdev, qpn);
+		if (unlikely(!mqp)) {
+			mlx5_ib_warn(dev, "CQE@CQ %06x for unknown QPN %6x\n",
+				     cq->mcq.cqn, qpn);
+			return -EINVAL;
+		}
+
+		*cur_qp = to_mibqp(mqp);
+	}
+
+	wc->qp  = &(*cur_qp)->ibqp;
+	opcode = cqe64->op_own >> 4;
+	switch (opcode) {
+	case MLX5_CQE_REQ:
+		wq = &(*cur_qp)->sq;
+		wqe_ctr = be16_to_cpu(cqe64->wqe_counter);
+		idx = wqe_ctr & (wq->wqe_cnt - 1);
+		handle_good_req(wc, cqe64, wq, idx);
+		handle_atomics(*cur_qp, cqe64, wq->last_poll, idx);
+		wc->wr_id = wq->wrid[idx];
+		wq->tail = wq->wqe_head[idx] + 1;
+		wc->status = IB_WC_SUCCESS;
+		break;
+	case MLX5_CQE_RESP_WR_IMM:
+	case MLX5_CQE_RESP_SEND:
+	case MLX5_CQE_RESP_SEND_IMM:
+	case MLX5_CQE_RESP_SEND_INV:
+		handle_responder(wc, cqe64, *cur_qp);
+		wc->status = IB_WC_SUCCESS;
+		break;
+	case MLX5_CQE_RESIZE_CQ:
+		break;
+	case MLX5_CQE_REQ_ERR:
+	case MLX5_CQE_RESP_ERR:
+		err_cqe = (struct mlx5_err_cqe *)cqe64;
+		mlx5_handle_error_cqe(dev, err_cqe, wc);
+		mlx5_ib_dbg(dev, "%s error cqe on cqn 0x%x:\n",
+			    opcode == MLX5_CQE_REQ_ERR ?
+			    "Requestor" : "Responder", cq->mcq.cqn);
+		mlx5_ib_dbg(dev, "syndrome 0x%x, vendor syndrome 0x%x\n",
+			    err_cqe->syndrome, err_cqe->vendor_err_synd);
+		if (opcode == MLX5_CQE_REQ_ERR) {
+			wq = &(*cur_qp)->sq;
+			wqe_ctr = be16_to_cpu(cqe64->wqe_counter);
+			idx = wqe_ctr & (wq->wqe_cnt - 1);
+			wc->wr_id = wq->wrid[idx];
+			wq->tail = wq->wqe_head[idx] + 1;
+		} else {
+			struct mlx5_ib_srq *srq;
+
+			if ((*cur_qp)->ibqp.srq) {
+				srq = to_msrq((*cur_qp)->ibqp.srq);
+				wqe_ctr = be16_to_cpu(cqe64->wqe_counter);
+				wc->wr_id = srq->wrid[wqe_ctr];
+				mlx5_ib_free_srq_wqe(srq, wqe_ctr);
+			} else {
+				wq = &(*cur_qp)->rq;
+				wc->wr_id = wq->wrid[wq->tail & (wq->wqe_cnt - 1)];
+				++wq->tail;
+			}
+		}
+		break;
+	}
+
+	return 0;
+}
+
+int mlx5_ib_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc)
+{
+	struct mlx5_ib_cq *cq = to_mcq(ibcq);
+	struct mlx5_ib_qp *cur_qp = NULL;
+	unsigned long flags;
+	int npolled;
+	int err = 0;
+
+	spin_lock_irqsave(&cq->lock, flags);
+
+	for (npolled = 0; npolled < num_entries; npolled++) {
+		err = mlx5_poll_one(cq, &cur_qp, wc + npolled);
+		if (err)
+			break;
+	}
+
+	if (npolled)
+		mlx5_cq_set_ci(&cq->mcq);
+
+	spin_unlock_irqrestore(&cq->lock, flags);
+
+	if (err == 0 || err == -EAGAIN)
+		return npolled;
+	else
+		return err;
+}
+
+int mlx5_ib_arm_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags flags)
+{
+	mlx5_cq_arm(&to_mcq(ibcq)->mcq,
+		    (flags & IB_CQ_SOLICITED_MASK) == IB_CQ_SOLICITED ?
+		    MLX5_CQ_DB_REQ_NOT_SOL : MLX5_CQ_DB_REQ_NOT,
+		    to_mdev(ibcq->device)->mdev.priv.uuari.uars[0].map,
+		    MLX5_GET_DOORBELL_LOCK(&to_mdev(ibcq->device)->mdev.priv.cq_uar_lock));
+
+	return 0;
+}
+
+static int alloc_cq_buf(struct mlx5_ib_dev *dev, struct mlx5_ib_cq_buf *buf,
+			int nent, int cqe_size)
+{
+	int err;
+
+	err = mlx5_buf_alloc(&dev->mdev, nent * cqe_size,
+			     PAGE_SIZE * 2, &buf->buf);
+	if (err)
+		return err;
+
+	buf->cqe_size = cqe_size;
+
+	return 0;
+}
+
+static void free_cq_buf(struct mlx5_ib_dev *dev, struct mlx5_ib_cq_buf *buf)
+{
+	mlx5_buf_free(&dev->mdev, &buf->buf);
+}
+
+static int create_cq_user(struct mlx5_ib_dev *dev, struct ib_udata *udata,
+			  struct ib_ucontext *context, struct mlx5_ib_cq *cq,
+			  int entries, struct mlx5_create_cq_mbox_in **cqb,
+			  int *cqe_size, int *index, int *inlen)
+{
+	struct mlx5_ib_create_cq ucmd;
+	int page_shift;
+	int npages;
+	int ncont;
+	int err;
+
+	if (ib_copy_from_udata(&ucmd, udata, sizeof(ucmd)))
+		return -EFAULT;
+
+	if (ucmd.cqe_size != 64 && ucmd.cqe_size != 128)
+		return -EINVAL;
+
+	*cqe_size = ucmd.cqe_size;
+
+	cq->buf.umem = ib_umem_get(context, ucmd.buf_addr,
+				   entries * ucmd.cqe_size,
+				   IB_ACCESS_LOCAL_WRITE, 1);
+	if (IS_ERR(cq->buf.umem)) {
+		err = PTR_ERR(cq->buf.umem);
+		return err;
+	}
+
+	err = mlx5_ib_db_map_user(to_mucontext(context), ucmd.db_addr,
+				  &cq->db);
+	if (err)
+		goto err_umem;
+
+	mlx5_ib_cont_pages(cq->buf.umem, ucmd.buf_addr, &npages, &page_shift,
+			   &ncont, NULL);
+	mlx5_ib_dbg(dev, "addr 0x%llx, size %u, npages %d, page_shift %d, ncont %d\n",
+		    ucmd.buf_addr, entries * ucmd.cqe_size, npages, page_shift, ncont);
+
+	*inlen = sizeof(**cqb) + sizeof(*(*cqb)->pas) * ncont;
+	*cqb = mlx5_vzalloc(*inlen);
+	if (!*cqb) {
+		err = -ENOMEM;
+		goto err_db;
+	}
+	mlx5_ib_populate_pas(dev, cq->buf.umem, page_shift, (*cqb)->pas, 0);
+	(*cqb)->ctx.log_pg_sz = page_shift - PAGE_SHIFT;
+
+	*index = to_mucontext(context)->uuari.uars[0].index;
+
+	return 0;
+
+err_db:
+	mlx5_ib_db_unmap_user(to_mucontext(context), &cq->db);
+
+err_umem:
+	ib_umem_release(cq->buf.umem);
+	return err;
+}
+
+static void destroy_cq_user(struct mlx5_ib_cq *cq, struct ib_ucontext *context)
+{
+	mlx5_ib_db_unmap_user(to_mucontext(context), &cq->db);
+	ib_umem_release(cq->buf.umem);
+}
+
+static void init_cq_buf(struct mlx5_ib_cq *cq, int nent)
+{
+	int i;
+	void *cqe;
+	struct mlx5_cqe64 *cqe64;
+
+	for (i = 0; i < nent; i++) {
+		cqe = get_cqe(cq, i);
+		cqe64 = (cq->buf.cqe_size == 64) ? cqe : cqe + 64;
+		cqe64->op_own = 0xf1;
+	}
+}
+
+static int create_cq_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_cq *cq,
+			    int entries, int cqe_size,
+			    struct mlx5_create_cq_mbox_in **cqb,
+			    int *index, int *inlen)
+{
+	int err;
+
+	err = mlx5_db_alloc(&dev->mdev, &cq->db);
+	if (err)
+		return err;
+
+	cq->mcq.set_ci_db  = cq->db.db;
+	cq->mcq.arm_db     = cq->db.db + 1;
+	*cq->mcq.set_ci_db = 0;
+	*cq->mcq.arm_db    = 0;
+	cq->mcq.cqe_sz = cqe_size;
+
+	err = alloc_cq_buf(dev, &cq->buf, entries, cqe_size);
+	if (err)
+		goto err_db;
+
+	init_cq_buf(cq, entries);
+
+	*inlen = sizeof(**cqb) + sizeof(*(*cqb)->pas) * cq->buf.buf.npages;
+	*cqb = mlx5_vzalloc(*inlen);
+	if (!*cqb) {
+		err = -ENOMEM;
+		goto err_buf;
+	}
+	mlx5_fill_page_array(&cq->buf.buf, (*cqb)->pas);
+
+	(*cqb)->ctx.log_pg_sz = cq->buf.buf.page_shift - PAGE_SHIFT;
+	*index = dev->mdev.priv.uuari.uars[0].index;
+
+	return 0;
+
+err_buf:
+	free_cq_buf(dev, &cq->buf);
+
+err_db:
+	mlx5_db_free(&dev->mdev, &cq->db);
+	return err;
+}
+
+static void destroy_cq_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_cq *cq)
+{
+	free_cq_buf(dev, &cq->buf);
+	mlx5_db_free(&dev->mdev, &cq->db);
+}
+
+struct ib_cq *mlx5_ib_create_cq(struct ib_device *ibdev, int entries,
+				int vector, struct ib_ucontext *context,
+				struct ib_udata *udata)
+{
+	struct mlx5_create_cq_mbox_in *cqb = NULL;
+	struct mlx5_ib_dev *dev = to_mdev(ibdev);
+	struct mlx5_ib_cq *cq;
+	int uninitialized_var(index);
+	int uninitialized_var(inlen);
+	int cqe_size;
+	int irqn;
+	int eqn;
+	int err;
+
+	entries = roundup_pow_of_two(entries + 1);
+	if (entries < 1 || entries > dev->mdev.caps.max_cqes)
+		return ERR_PTR(-EINVAL);
+
+	cq = kzalloc(sizeof(*cq), GFP_KERNEL);
+	if (!cq)
+		return ERR_PTR(-ENOMEM);
+
+	cq->ibcq.cqe = entries - 1;
+	mutex_init(&cq->resize_mutex);
+	spin_lock_init(&cq->lock);
+	cq->resize_buf = NULL;
+	cq->resize_umem = NULL;
+
+	if (context) {
+		err = create_cq_user(dev, udata, context, cq, entries,
+				     &cqb, &cqe_size, &index, &inlen);
+		if (err)
+			goto err_create;
+	} else {
+		/* for now choose 64 bytes till we have a proper interface */
+		cqe_size = 64;
+		err = create_cq_kernel(dev, cq, entries, cqe_size, &cqb,
+				       &index, &inlen);
+		if (err)
+			goto err_create;
+	}
+
+	cq->cqe_size = cqe_size;
+	cqb->ctx.cqe_sz_flags = cqe_sz_to_mlx_sz(cqe_size) << 5;
+	cqb->ctx.log_sz_usr_page = cpu_to_be32((ilog2(entries) << 24) | index);
+	err = mlx5_vector2eqn(dev, vector, &eqn, &irqn);
+	if (err)
+		goto err_cqb;
+
+	cqb->ctx.c_eqn = cpu_to_be16(eqn);
+	cqb->ctx.db_record_addr = cpu_to_be64(cq->db.dma);
+
+	err = mlx5_core_create_cq(&dev->mdev, &cq->mcq, cqb, inlen);
+	if (err)
+		goto err_cqb;
+
+	mlx5_ib_dbg(dev, "cqn 0x%x\n", cq->mcq.cqn);
+	cq->mcq.irqn = irqn;
+	cq->mcq.comp  = mlx5_ib_cq_comp;
+	cq->mcq.event = mlx5_ib_cq_event;
+
+	if (context)
+		if (ib_copy_to_udata(udata, &cq->mcq.cqn, sizeof(__u32))) {
+			err = -EFAULT;
+			goto err_cmd;
+		}
+
+
+	mlx5_vfree(cqb);
+	return &cq->ibcq;
+
+err_cmd:
+	mlx5_core_destroy_cq(&dev->mdev, &cq->mcq);
+
+err_cqb:
+	mlx5_vfree(cqb);
+	if (context)
+		destroy_cq_user(cq, context);
+	else
+		destroy_cq_kernel(dev, cq);
+
+err_create:
+	kfree(cq);
+
+	return ERR_PTR(err);
+}
+
+
+int mlx5_ib_destroy_cq(struct ib_cq *cq)
+{
+	struct mlx5_ib_dev *dev = to_mdev(cq->device);
+	struct mlx5_ib_cq *mcq = to_mcq(cq);
+	struct ib_ucontext *context = NULL;
+
+	if (cq->uobject)
+		context = cq->uobject->context;
+
+	mlx5_core_destroy_cq(&dev->mdev, &mcq->mcq);
+	if (context)
+		destroy_cq_user(mcq, context);
+	else
+		destroy_cq_kernel(dev, mcq);
+
+	kfree(mcq);
+
+	return 0;
+}
+
+static int is_equal_rsn(struct mlx5_cqe64 *cqe64, struct mlx5_ib_srq *srq,
+			u32 rsn)
+{
+	u32 lrsn;
+
+	if (srq)
+		lrsn = be32_to_cpu(cqe64->srqn) & 0xffffff;
+	else
+		lrsn = be32_to_cpu(cqe64->sop_drop_qpn) & 0xffffff;
+
+	return rsn == lrsn;
+}
+
+void __mlx5_ib_cq_clean(struct mlx5_ib_cq *cq, u32 rsn, struct mlx5_ib_srq *srq)
+{
+	struct mlx5_cqe64 *cqe64, *dest64;
+	void *cqe, *dest;
+	u32 prod_index;
+	int nfreed = 0;
+	u8 owner_bit;
+
+	if (!cq)
+		return;
+
+	/* First we need to find the current producer index, so we
+	 * know where to start cleaning from.  It doesn't matter if HW
+	 * adds new entries after this loop -- the QP we're worried
+	 * about is already in RESET, so the new entries won't come
+	 * from our QP and therefore don't need to be checked.
+	 */
+	for (prod_index = cq->mcq.cons_index; get_sw_cqe(cq, prod_index); prod_index++)
+		if (prod_index == cq->mcq.cons_index + cq->ibcq.cqe)
+			break;
+
+	/* Now sweep backwards through the CQ, removing CQ entries
+	 * that match our QP by copying older entries on top of them.
+	 */
+	while ((int) --prod_index - (int) cq->mcq.cons_index >= 0) {
+		cqe = get_cqe(cq, prod_index & cq->ibcq.cqe);
+		cqe64 = (cq->mcq.cqe_sz == 64) ? cqe : cqe + 64;
+		if (is_equal_rsn(cqe64, srq, rsn)) {
+			if (srq)
+				mlx5_ib_free_srq_wqe(srq, be16_to_cpu(cqe64->wqe_counter));
+			++nfreed;
+		} else if (nfreed) {
+			dest = get_cqe(cq, (prod_index + nfreed) & cq->ibcq.cqe);
+			dest64 = (cq->mcq.cqe_sz == 64) ? dest : dest + 64;
+			owner_bit = dest64->op_own & MLX5_CQE_OWNER_MASK;
+			memcpy(dest, cqe, cq->mcq.cqe_sz);
+			dest64->op_own = owner_bit |
+				(dest64->op_own & ~MLX5_CQE_OWNER_MASK);
+		}
+	}
+
+	if (nfreed) {
+		cq->mcq.cons_index += nfreed;
+		/* Make sure update of buffer contents is done before
+		 * updating consumer index.
+		 */
+		wmb();
+		mlx5_cq_set_ci(&cq->mcq);
+	}
+}
+
+void mlx5_ib_cq_clean(struct mlx5_ib_cq *cq, u32 qpn, struct mlx5_ib_srq *srq)
+{
+	if (!cq)
+		return;
+
+	spin_lock_irq(&cq->lock);
+	__mlx5_ib_cq_clean(cq, qpn, srq);
+	spin_unlock_irq(&cq->lock);
+}
+
+int mlx5_ib_modify_cq(struct ib_cq *cq, u16 cq_count, u16 cq_period)
+{
+	return -ENOSYS;
+}
+
+int mlx5_ib_resize_cq(struct ib_cq *ibcq, int entries, struct ib_udata *udata)
+{
+	return -ENOSYS;
+}
+
+int mlx5_ib_get_cqe_size(struct mlx5_ib_dev *dev, struct ib_cq *ibcq)
+{
+	struct mlx5_ib_cq *cq;
+
+	if (!ibcq)
+		return 128;
+
+	cq = to_mcq(ibcq);
+	return cq->cqe_size;
+}
diff --git a/drivers/infiniband/hw/mlx5/doorbell.c b/drivers/infiniband/hw/mlx5/doorbell.c
new file mode 100644
index 0000000..256a233
--- /dev/null
+++ b/drivers/infiniband/hw/mlx5/doorbell.c
@@ -0,0 +1,100 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/kref.h>
+#include <linux/slab.h>
+#include <rdma/ib_umem.h>
+
+#include "mlx5_ib.h"
+
+struct mlx5_ib_user_db_page {
+	struct list_head	list;
+	struct ib_umem	       *umem;
+	unsigned long		user_virt;
+	int			refcnt;
+};
+
+int mlx5_ib_db_map_user(struct mlx5_ib_ucontext *context, unsigned long virt,
+			struct mlx5_db *db)
+{
+	struct mlx5_ib_user_db_page *page;
+	struct ib_umem_chunk *chunk;
+	int err = 0;
+
+	mutex_lock(&context->db_page_mutex);
+
+	list_for_each_entry(page, &context->db_page_list, list)
+		if (page->user_virt == (virt & PAGE_MASK))
+			goto found;
+
+	page = kmalloc(sizeof(*page), GFP_KERNEL);
+	if (!page) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	page->user_virt = (virt & PAGE_MASK);
+	page->refcnt    = 0;
+	page->umem      = ib_umem_get(&context->ibucontext, virt & PAGE_MASK,
+				      PAGE_SIZE, 0, 0);
+	if (IS_ERR(page->umem)) {
+		err = PTR_ERR(page->umem);
+		kfree(page);
+		goto out;
+	}
+
+	list_add(&page->list, &context->db_page_list);
+
+found:
+	chunk = list_entry(page->umem->chunk_list.next, struct ib_umem_chunk, list);
+	db->dma		= sg_dma_address(chunk->page_list) + (virt & ~PAGE_MASK);
+	db->u.user_page = page;
+	++page->refcnt;
+
+out:
+	mutex_unlock(&context->db_page_mutex);
+
+	return err;
+}
+
+void mlx5_ib_db_unmap_user(struct mlx5_ib_ucontext *context, struct mlx5_db *db)
+{
+	mutex_lock(&context->db_page_mutex);
+
+	if (!--db->u.user_page->refcnt) {
+		list_del(&db->u.user_page->list);
+		ib_umem_release(db->u.user_page->umem);
+		kfree(db->u.user_page);
+	}
+
+	mutex_unlock(&context->db_page_mutex);
+}
diff --git a/drivers/infiniband/hw/mlx5/mad.c b/drivers/infiniband/hw/mlx5/mad.c
new file mode 100644
index 0000000..5c8938b
--- /dev/null
+++ b/drivers/infiniband/hw/mlx5/mad.c
@@ -0,0 +1,139 @@
+/*
+ * Copyright (c) 2013, Mellanox Technologies inc.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/mlx5/cmd.h>
+#include <rdma/ib_mad.h>
+#include <rdma/ib_smi.h>
+#include "mlx5_ib.h"
+
+enum {
+	MLX5_IB_VENDOR_CLASS1 = 0x9,
+	MLX5_IB_VENDOR_CLASS2 = 0xa
+};
+
+int mlx5_MAD_IFC(struct mlx5_ib_dev *dev, int ignore_mkey, int ignore_bkey,
+		 int port, struct ib_wc *in_wc, struct ib_grh *in_grh,
+		 void *in_mad, void *response_mad)
+{
+	u8 op_modifier = 0;
+
+	/* Key check traps can't be generated unless we have in_wc to
+	 * tell us where to send the trap.
+	 */
+	if (ignore_mkey || !in_wc)
+		op_modifier |= 0x1;
+	if (ignore_bkey || !in_wc)
+		op_modifier |= 0x2;
+
+	return mlx5_core_mad_ifc(&dev->mdev, in_mad, response_mad, op_modifier, port);
+}
+
+int mlx5_ib_process_mad(struct ib_device *ibdev, int mad_flags, u8 port_num,
+			struct ib_wc *in_wc, struct ib_grh *in_grh,
+			struct ib_mad *in_mad, struct ib_mad *out_mad)
+{
+	u16 slid;
+	int err;
+
+	slid = in_wc ? in_wc->slid : be16_to_cpu(IB_LID_PERMISSIVE);
+
+	if (in_mad->mad_hdr.method == IB_MGMT_METHOD_TRAP && slid == 0)
+		return IB_MAD_RESULT_SUCCESS | IB_MAD_RESULT_CONSUMED;
+
+	if (in_mad->mad_hdr.mgmt_class == IB_MGMT_CLASS_SUBN_LID_ROUTED ||
+	    in_mad->mad_hdr.mgmt_class == IB_MGMT_CLASS_SUBN_DIRECTED_ROUTE) {
+		if (in_mad->mad_hdr.method   != IB_MGMT_METHOD_GET &&
+		    in_mad->mad_hdr.method   != IB_MGMT_METHOD_SET &&
+		    in_mad->mad_hdr.method   != IB_MGMT_METHOD_TRAP_REPRESS)
+			return IB_MAD_RESULT_SUCCESS;
+
+		/* Don't process SMInfo queries -- the SMA can't handle them.
+		 */
+		if (in_mad->mad_hdr.attr_id == IB_SMP_ATTR_SM_INFO)
+			return IB_MAD_RESULT_SUCCESS;
+	} else if (in_mad->mad_hdr.mgmt_class == IB_MGMT_CLASS_PERF_MGMT ||
+		   in_mad->mad_hdr.mgmt_class == MLX5_IB_VENDOR_CLASS1   ||
+		   in_mad->mad_hdr.mgmt_class == MLX5_IB_VENDOR_CLASS2   ||
+		   in_mad->mad_hdr.mgmt_class == IB_MGMT_CLASS_CONG_MGMT) {
+		if (in_mad->mad_hdr.method  != IB_MGMT_METHOD_GET &&
+		    in_mad->mad_hdr.method  != IB_MGMT_METHOD_SET)
+			return IB_MAD_RESULT_SUCCESS;
+	} else {
+		return IB_MAD_RESULT_SUCCESS;
+	}
+
+	err = mlx5_MAD_IFC(to_mdev(ibdev),
+			   mad_flags & IB_MAD_IGNORE_MKEY,
+			   mad_flags & IB_MAD_IGNORE_BKEY,
+			   port_num, in_wc, in_grh, in_mad, out_mad);
+	if (err)
+		return IB_MAD_RESULT_FAILURE;
+
+	/* set return bit in status of directed route responses */
+	if (in_mad->mad_hdr.mgmt_class == IB_MGMT_CLASS_SUBN_DIRECTED_ROUTE)
+		out_mad->mad_hdr.status |= cpu_to_be16(1 << 15);
+
+	if (in_mad->mad_hdr.method == IB_MGMT_METHOD_TRAP_REPRESS)
+		/* no response for trap repress */
+		return IB_MAD_RESULT_SUCCESS | IB_MAD_RESULT_CONSUMED;
+
+	return IB_MAD_RESULT_SUCCESS | IB_MAD_RESULT_REPLY;
+}
+
+int mlx5_query_ext_port_caps(struct mlx5_ib_dev *dev, u8 port)
+{
+	struct ib_smp *in_mad  = NULL;
+	struct ib_smp *out_mad = NULL;
+	int err = -ENOMEM;
+	u16 packet_error;
+
+	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
+	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
+	if (!in_mad || !out_mad)
+		goto out;
+
+	init_query_mad(in_mad);
+	in_mad->attr_id = MLX5_ATTR_EXTENDED_PORT_INFO;
+	in_mad->attr_mod = cpu_to_be32(port);
+
+	err = mlx5_MAD_IFC(dev, 1, 1, 1, NULL, NULL, in_mad, out_mad);
+
+	packet_error = be16_to_cpu(out_mad->status);
+
+	dev->mdev.caps.ext_port_cap[port - 1] = (!err && !packet_error) ?
+		MLX_EXT_PORT_CAP_FLAG_EXTENDED_PORT_INFO : 0;
+
+out:
+	kfree(in_mad);
+	kfree(out_mad);
+	return err;
+}
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
