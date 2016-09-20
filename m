From: Ram Amrani <Ram.Amrani@cavium.com>
Subject: [RFC v2 06/12] qedr: Add support for QP verbs
Date: Tue, 20 Sep 2016 13:35:58 +0300
Message-ID: <1474367764-9555-7-git-send-email-Ram.Amrani@cavium.com>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@cavium.com>, <Michal.Kalderon@cavium.com>,
        <Yuval.Mintz@cavium.com>, <rajesh.borundia@cavium.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        Ram amrani <Ram.Amrani@cavium.com>
To: <davem@davemloft.net>, <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:32932 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932904AbcITKhB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 06:37:01 -0400
In-Reply-To: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram amrani <Ram.Amrani@cavium.com>

Add support for Queue Pair verbs which adds, deletes,
modifies and queries Queue Pairs.

Signed-off-by: Rajesh Borundia <rajesh.borundia@cavium.com>
Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
---
 drivers/infiniband/hw/qedr/main.c          |   15 +-
 drivers/infiniband/hw/qedr/qedr.h          |  126 +++
 drivers/infiniband/hw/qedr/qedr_cm.h       |   40 +
 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h |   11 +
 drivers/infiniband/hw/qedr/verbs.c         | 1095 ++++++++++++++++++++++++-
 drivers/infiniband/hw/qedr/verbs.h         |    7 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.h  |    1 +
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 1211 ++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_roce.h |   71 ++
 include/linux/qed/qed_roce_if.h            |  144 ++++
 include/uapi/rdma/providers/qedr-abi.h     |   35 +
 11 files changed, 2753 insertions(+), 3 deletions(-)
 create mode 100644 drivers/infiniband/hw/qedr/qedr_cm.h

diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index c99dd6a..10ad9ed 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -52,7 +52,7 @@ uint debug;
 module_param(debug, uint, 0);
 MODULE_PARM_DESC(debug, "Default debug msglevel");
 
-static LIST_HEAD(qedr_dev_list);
+#define QEDR_WQ_MULTIPLIER_DFT	(3)
 
 void qedr_ib_dispatch_event(struct qedr_dev *dev, u8 port_num,
 			    enum ib_event_type type)
@@ -99,7 +99,11 @@ static int qedr_register_device(struct qedr_dev *dev)
 				     QEDR_UVERBS(CREATE_CQ) |
 				     QEDR_UVERBS(RESIZE_CQ) |
 				     QEDR_UVERBS(DESTROY_CQ) |
-				     QEDR_UVERBS(REQ_NOTIFY_CQ);
+				     QEDR_UVERBS(REQ_NOTIFY_CQ) |
+				     QEDR_UVERBS(CREATE_QP) |
+				     QEDR_UVERBS(MODIFY_QP) |
+				     QEDR_UVERBS(QUERY_QP) |
+				     QEDR_UVERBS(DESTROY_QP);
 
 	dev->ibdev.phys_port_cnt = 1;
 	dev->ibdev.num_comp_vectors = dev->num_cnq;
@@ -124,6 +128,11 @@ static int qedr_register_device(struct qedr_dev *dev)
 	dev->ibdev.resize_cq = qedr_resize_cq;
 	dev->ibdev.req_notify_cq = qedr_arm_cq;
 
+	dev->ibdev.create_qp = qedr_create_qp;
+	dev->ibdev.modify_qp = qedr_modify_qp;
+	dev->ibdev.query_qp = qedr_query_qp;
+	dev->ibdev.destroy_qp = qedr_destroy_qp;
+
 	dev->ibdev.query_pkey = qedr_query_pkey;
 
 	dev->ibdev.dma_device = &dev->pdev->dev;
@@ -619,6 +628,8 @@ static struct qedr_dev *qedr_add(struct qed_dev *cdev, struct pci_dev *pdev,
 		goto init_err;
 	}
 
+	dev->wq_multiplier = QEDR_WQ_MULTIPLIER_DFT;
+
 	qedr_pci_set_atomic(dev, pdev);
  
 	rc = qedr_alloc_resources(dev);
diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
index dd974d5..05017be 100644
--- a/drivers/infiniband/hw/qedr/qedr.h
+++ b/drivers/infiniband/hw/qedr/qedr.h
@@ -49,6 +49,9 @@
 enum DP_QEDR_MODULE {
 	QEDR_MSG_INIT = 0x10000,
 	QEDR_MSG_CQ = 0x20000,
+	QEDR_MSG_RQ = 0x40000,
+	QEDR_MSG_SQ = 0x80000,
+	QEDR_MSG_QP = (QEDR_MSG_SQ | QEDR_MSG_RQ),
 	QEDR_MSG_MR = 0x100000,
 	QEDR_MSG_MISC = 0x400000,
 };
@@ -141,6 +144,8 @@ struct qedr_dev {
 	u32			dp_module;
 	u8			dp_level;
 	u8			num_hwfns;
+	uint			wq_multiplier;
+
 };
 
 #define QEDR_MAX_SQ_PBL			(0x8000)
@@ -270,6 +275,123 @@ struct qedr_mm {
 	struct list_head entry;
 };
 
+union db_prod32 {
+	struct rdma_pwm_val16_data data;
+	u32 raw;
+};
+
+struct qedr_qp_hwq_info {
+	/* WQE Elements */
+	struct qed_chain pbl;
+	u64 p_phys_addr_tbl;
+	u32 max_sges;
+
+	/* WQE */
+	u16 prod;
+	u16 cons;
+	u16 wqe_cons;
+	u16 max_wr;
+
+	/* DB */
+	void __iomem *db;
+	union db_prod32 db_data;
+};
+
+#define QEDR_INC_SW_IDX(p_info, index)					\
+	do {								\
+		p_info->index = (p_info->index + 1) &			\
+				qed_chain_get_capacity(p_info->pbl)	\
+	} while (0)
+
+enum qedr_qp_err_bitmap {
+	QEDR_QP_ERR_SQ_FULL = 1,
+	QEDR_QP_ERR_RQ_FULL = 2,
+	QEDR_QP_ERR_BAD_SR = 4,
+	QEDR_QP_ERR_BAD_RR = 8,
+	QEDR_QP_ERR_SQ_PBL_FULL = 16,
+	QEDR_QP_ERR_RQ_PBL_FULL = 32,
+};
+
+struct qedr_qp {
+	struct ib_qp ibqp;	/* must be first */
+	struct qedr_dev *dev;
+
+	struct qedr_qp_hwq_info sq;
+	struct qedr_qp_hwq_info rq;
+
+	u32 max_inline_data;
+
+	/* Lock for QP's */
+	spinlock_t q_lock;
+	struct qedr_cq *sq_cq;
+	struct qedr_cq *rq_cq;
+	struct qedr_srq *srq;
+	enum qed_roce_qp_state state;
+	u32 id;
+	struct qedr_pd *pd;
+	enum ib_qp_type qp_type;
+	struct qed_rdma_qp *qed_qp;
+	u32 qp_id;
+	u16 icid;
+	u16 mtu;
+	int sgid_idx;
+	u32 rq_psn;
+	u32 sq_psn;
+	u32 qkey;
+	u32 dest_qp_num;
+
+	/* Relevant to qps created from kernel space only (ULPs) */
+	u8 prev_wqe_size;
+	u16 wqe_cons;
+	u32 err_bitmap;
+	bool signaled;
+
+	/* SQ shadow */
+	struct {
+		u64 wr_id;
+		enum ib_wc_opcode opcode;
+		u32 bytes_len;
+		u8 wqe_size;
+		bool signaled;
+		dma_addr_t icrc_mapping;
+		u32 *icrc;
+		struct qedr_mr *mr;
+	} *wqe_wr_id;
+
+	/* RQ shadow */
+	struct {
+		u64 wr_id;
+		struct ib_sge sg_list[RDMA_MAX_SGE_PER_RQ_WQE];
+		u8 wqe_size;
+
+		u16 vlan_id;
+		int rc;
+	} *rqe_wr_id;
+
+	/* Relevant to qps created from user space only (applications) */
+	struct qedr_userq usq;
+	struct qedr_userq urq;
+};
+
+static inline int qedr_get_dmac(struct qedr_dev *dev,
+				struct ib_ah_attr *ah_attr, u8 *mac_addr)
+{
+	union ib_gid zero_sgid = { { 0 } };
+	struct in6_addr in6;
+
+	if (!memcmp(&ah_attr->grh.dgid, &zero_sgid, sizeof(union ib_gid))) {
+		DP_ERR(dev, "Local port GID not supported\n");
+		eth_zero_addr(mac_addr);
+		return -EINVAL;
+	}
+
+	memcpy(&in6, ah_attr->grh.dgid.raw, sizeof(in6));
+	ether_addr_copy(mac_addr, ah_attr->dmac);
+
+	return 0;
+}
+
+ 
 static inline
 struct qedr_ucontext *get_qedr_ucontext(struct ib_ucontext *ibucontext)
 {
@@ -291,4 +413,8 @@ static inline struct qedr_cq *get_qedr_cq(struct ib_cq *ibcq)
 	return container_of(ibcq, struct qedr_cq, ibcq);
 }
 
+static inline struct qedr_qp *get_qedr_qp(struct ib_qp *ibqp)
+{
+	return container_of(ibqp, struct qedr_qp, ibqp);
+}
 #endif
diff --git a/drivers/infiniband/hw/qedr/qedr_cm.h b/drivers/infiniband/hw/qedr/qedr_cm.h
new file mode 100644
index 0000000..b8a8b76
--- /dev/null
+++ b/drivers/infiniband/hw/qedr/qedr_cm.h
@@ -0,0 +1,40 @@
+/* QLogic qedr NIC Driver
+ * Copyright (c) 2015-2016  QLogic Corporation
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
+ *        disclaimer in the documentation and /or other materials
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
+#ifndef LINUX_QEDR_CM_H_
+#define LINUX_QEDR_CM_H_
+
+static inline u32 qedr_get_ipv4_from_gid(u8 *gid)
+{
+	return *(u32 *)(void *)&gid[12];
+}
+
+#endif
diff --git a/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h b/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
index 84f6520..4770559 100644
--- a/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
+++ b/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
@@ -158,6 +158,17 @@ struct rdma_srq_sge {
 	__le32 l_key;
 };
 
+/* Rdma doorbell data for SQ and RQ */
+struct rdma_pwm_val16_data {
+	__le16 icid;
+	__le16 value;
+};
+
+union rdma_pwm_val16_data_union {
+	struct rdma_pwm_val16_data as_struct;
+	__le32 as_dword;
+};
+
 /* Rdma doorbell data for CQ */
 struct rdma_pwm_val32_data {
 	__le16 icid;
diff --git a/drivers/infiniband/hw/qedr/verbs.c b/drivers/infiniband/hw/qedr/verbs.c
index e5c4aa1..616d656 100644
--- a/drivers/infiniband/hw/qedr/verbs.c
+++ b/drivers/infiniband/hw/qedr/verbs.c
@@ -24,6 +24,7 @@
 #include "qedr.h"
 #include "verbs.h"
 #include <rdma/providers/qedr-abi.h> 
+#include "qedr_cm.h"
 
 #define DB_ADDR_SHIFT(addr)		((addr) << DB_PWM_ADDR_OFFSET_SHIFT)
 
@@ -69,7 +70,6 @@ int qedr_add_gid(struct ib_device *device, u8 port_num,
 
 	if (!context)
 		return -EINVAL;
-
 	return 0;
 }
 
@@ -958,3 +958,1096 @@ int qedr_destroy_cq(struct ib_cq *ibcq)
 
 	return 0;
 }
+
+static inline int get_gid_info_from_table(struct ib_qp *ibqp,
+					  struct ib_qp_attr *attr,
+					  int attr_mask,
+					  struct qed_rdma_modify_qp_in_params
+					  *qp_params)
+{
+	enum rdma_network_type nw_type;
+	struct ib_gid_attr gid_attr;
+	union ib_gid gid;
+	u32 ipv4_addr;
+	int rc = 0;
+	int i;
+
+	rc = ib_get_cached_gid(ibqp->device, attr->ah_attr.port_num,
+			       attr->ah_attr.grh.sgid_index, &gid, &gid_attr);
+	if (rc)
+		return rc;
+
+	if (!memcmp(&gid, &zgid, sizeof(gid)))
+		return -ENOENT;
+
+	if (gid_attr.ndev) {
+		qp_params->vlan_id = rdma_vlan_dev_vlan_id(gid_attr.ndev);
+
+		dev_put(gid_attr.ndev);
+		nw_type = ib_gid_to_network_type(gid_attr.gid_type, &gid);
+		switch (nw_type) {
+		case RDMA_NETWORK_IPV6:
+			memcpy(&qp_params->sgid.bytes[0], &gid.raw[0],
+			       sizeof(qp_params->sgid));
+			memcpy(&qp_params->dgid.bytes[0],
+			       &attr->ah_attr.grh.dgid,
+			       sizeof(qp_params->dgid));
+			qp_params->roce_mode = ROCE_V2_IPV6;
+			SET_FIELD(qp_params->modify_flags,
+				  QED_ROCE_MODIFY_QP_VALID_ROCE_MODE, 1);
+			break;
+		case RDMA_NETWORK_IB:
+			memcpy(&qp_params->sgid.bytes[0], &gid.raw[0],
+			       sizeof(qp_params->sgid));
+			memcpy(&qp_params->dgid.bytes[0],
+			       &attr->ah_attr.grh.dgid,
+			       sizeof(qp_params->dgid));
+			qp_params->roce_mode = ROCE_V1;
+			break;
+		case RDMA_NETWORK_IPV4:
+			memset(&qp_params->sgid, 0, sizeof(qp_params->sgid));
+			memset(&qp_params->dgid, 0, sizeof(qp_params->dgid));
+			ipv4_addr = qedr_get_ipv4_from_gid(gid.raw);
+			qp_params->sgid.ipv4_addr = ipv4_addr;
+			ipv4_addr =
+			    qedr_get_ipv4_from_gid(attr->ah_attr.grh.dgid.raw);
+			qp_params->dgid.ipv4_addr = ipv4_addr;
+			SET_FIELD(qp_params->modify_flags,
+				  QED_ROCE_MODIFY_QP_VALID_ROCE_MODE, 1);
+			qp_params->roce_mode = ROCE_V2_IPV4;
+			break;
+		}
+	}
+
+	for (i = 0; i < 4; i++) {
+		qp_params->sgid.dwords[i] = ntohl(qp_params->sgid.dwords[i]);
+		qp_params->dgid.dwords[i] = ntohl(qp_params->dgid.dwords[i]);
+	}
+
+	if (qp_params->vlan_id >= VLAN_CFI_MASK)
+		qp_params->vlan_id = 0;
+
+	return 0;
+}
+
+static void qedr_cleanup_user_sq(struct qedr_dev *dev, struct qedr_qp *qp)
+{
+	qedr_free_pbl(dev, &qp->usq.pbl_info, qp->usq.pbl_tbl);
+	ib_umem_release(qp->usq.umem);
+}
+
+static void qedr_cleanup_user_rq(struct qedr_dev *dev, struct qedr_qp *qp)
+{
+	qedr_free_pbl(dev, &qp->urq.pbl_info, qp->urq.pbl_tbl);
+	ib_umem_release(qp->urq.umem);
+}
+
+static void qedr_cleanup_kernel_sq(struct qedr_dev *dev, struct qedr_qp *qp)
+{
+	dev->ops->common->chain_free(dev->cdev, &qp->sq.pbl);
+	kfree(qp->wqe_wr_id);
+}
+
+static void qedr_cleanup_kernel_rq(struct qedr_dev *dev, struct qedr_qp *qp)
+{
+	dev->ops->common->chain_free(dev->cdev, &qp->rq.pbl);
+	kfree(qp->rqe_wr_id);
+}
+
+static int qedr_check_qp_attrs(struct ib_pd *ibpd, struct qedr_dev *dev,
+			       struct ib_qp_init_attr *attrs)
+{
+	struct qedr_device_attr *qattr = &dev->attr;
+
+	/* QP0... attrs->qp_type == IB_QPT_GSI */
+	if (attrs->qp_type != IB_QPT_RC && attrs->qp_type != IB_QPT_GSI) {
+		DP_VERBOSE(dev, QEDR_MSG_QP,
+			   "create qp: unsupported qp type=0x%x requested\n",
+			   attrs->qp_type);
+		return -EINVAL;
+	}
+
+	if (attrs->cap.max_send_wr > qattr->max_sqe) {
+		DP_ERR(dev,
+		       "create qp: cannot create a SQ with %d elements (max_send_wr=0x%x)\n",
+		       attrs->cap.max_send_wr, qattr->max_sqe);
+		return -EINVAL;
+	}
+
+	if (attrs->cap.max_inline_data > qattr->max_inline) {
+		DP_ERR(dev,
+		       "create qp: unsupported inline data size=0x%x requested (max_inline=0x%x)\n",
+		       attrs->cap.max_inline_data, qattr->max_inline);
+		return -EINVAL;
+	}
+
+	if (attrs->cap.max_send_sge > qattr->max_sge) {
+		DP_ERR(dev,
+		       "create qp: unsupported send_sge=0x%x requested (max_send_sge=0x%x)\n",
+		       attrs->cap.max_send_sge, qattr->max_sge);
+		return -EINVAL;
+	}
+
+	if (attrs->cap.max_recv_sge > qattr->max_sge) {
+		DP_ERR(dev,
+		       "create qp: unsupported recv_sge=0x%x requested (max_recv_sge=0x%x)\n",
+		       attrs->cap.max_recv_sge, qattr->max_sge);
+		return -EINVAL;
+	}
+
+	/* Unprivileged user space cannot create special QP */
+	if (ibpd->uobject && attrs->qp_type == IB_QPT_GSI) {
+		DP_ERR(dev,
+		       "create qp: userspace can't create special QPs of type=0x%x\n",
+		       attrs->qp_type);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static void qedr_copy_rq_uresp(struct qedr_create_qp_uresp *uresp,
+			       struct qedr_qp *qp)
+{
+	uresp->rq_db_offset = DB_ADDR_SHIFT(DQ_PWM_OFFSET_TCM_ROCE_RQ_PROD);
+	uresp->rq_icid = qp->icid;
+}
+
+static void qedr_copy_sq_uresp(struct qedr_create_qp_uresp *uresp,
+			       struct qedr_qp *qp)
+{
+	uresp->sq_db_offset = DB_ADDR_SHIFT(DQ_PWM_OFFSET_XCM_RDMA_SQ_PROD);
+	uresp->sq_icid = qp->icid + 1;
+}
+
+static int qedr_copy_qp_uresp(struct qedr_dev *dev,
+			      struct qedr_qp *qp, struct ib_udata *udata)
+{
+	struct qedr_create_qp_uresp uresp;
+	int rc;
+
+	memset(&uresp, 0, sizeof(uresp));
+	qedr_copy_sq_uresp(&uresp, qp);
+	qedr_copy_rq_uresp(&uresp, qp);
+
+	uresp.atomic_supported = dev->atomic_cap != IB_ATOMIC_NONE;
+	uresp.qp_id = qp->qp_id;
+
+	rc = ib_copy_to_udata(udata, &uresp, sizeof(uresp));
+	if (rc)
+		DP_ERR(dev,
+		       "create qp: failed a copy to user space with qp icid=0x%x.\n",
+		       qp->icid);
+
+	return rc;
+}
+
+static void qedr_set_qp_init_params(struct qedr_dev *dev,
+				    struct qedr_qp *qp,
+				    struct qedr_pd *pd,
+				    struct ib_qp_init_attr *attrs)
+{
+	qp->pd = pd;
+
+	spin_lock_init(&qp->q_lock);
+
+	qp->qp_type = attrs->qp_type;
+	qp->max_inline_data = attrs->cap.max_inline_data;
+	qp->sq.max_sges = attrs->cap.max_send_sge;
+	qp->state = QED_ROCE_QP_STATE_RESET;
+	qp->signaled = (attrs->sq_sig_type == IB_SIGNAL_ALL_WR) ? true : false;
+	qp->sq_cq = get_qedr_cq(attrs->send_cq);
+	qp->rq_cq = get_qedr_cq(attrs->recv_cq);
+	qp->dev = dev;
+
+	DP_VERBOSE(dev, QEDR_MSG_QP,
+		   "QP params:\tpd = %d, qp_type = %d, max_inline_data = %d, state = %d, signaled = %d, use_srq=%d\n",
+		   pd->pd_id, qp->qp_type, qp->max_inline_data,
+		   qp->state, qp->signaled, (attrs->srq) ? 1 : 0);
+	DP_VERBOSE(dev, QEDR_MSG_QP,
+		   "SQ params:\tsq_max_sges = %d, sq_cq_id = %d\n",
+		   qp->sq.max_sges, qp->sq_cq->icid);
+	qp->rq.max_sges = attrs->cap.max_recv_sge;
+	DP_VERBOSE(dev, QEDR_MSG_QP,
+		   "RQ params:\trq_max_sges = %d, rq_cq_id = %d\n",
+		   qp->rq.max_sges, qp->rq_cq->icid);
+}
+
+static inline void
+qedr_init_qp_user_params(struct qed_rdma_create_qp_in_params *params,
+			 struct qedr_create_qp_ureq *ureq)
+{
+	/* QP handle to be written in CQE */
+	params->qp_handle_lo = ureq->qp_handle_lo;
+	params->qp_handle_hi = ureq->qp_handle_hi;
+}
+
+static inline void
+qedr_init_qp_kernel_doorbell_sq(struct qedr_dev *dev, struct qedr_qp *qp)
+{
+	qp->sq.db = dev->db_addr +
+		    DB_ADDR_SHIFT(DQ_PWM_OFFSET_XCM_RDMA_SQ_PROD);
+	qp->sq.db_data.data.icid = qp->icid + 1;
+}
+
+static inline void
+qedr_init_qp_kernel_doorbell_rq(struct qedr_dev *dev, struct qedr_qp *qp)
+{
+	qp->rq.db = dev->db_addr +
+		    DB_ADDR_SHIFT(DQ_PWM_OFFSET_TCM_ROCE_RQ_PROD);
+	qp->rq.db_data.data.icid = qp->icid;
+}
+
+static inline int
+qedr_init_qp_kernel_params_rq(struct qedr_dev *dev,
+			      struct qedr_qp *qp, struct ib_qp_init_attr *attrs)
+{
+	/* Allocate driver internal RQ array */
+	qp->rqe_wr_id = kcalloc(qp->rq.max_wr, sizeof(*qp->rqe_wr_id),
+				GFP_KERNEL);
+	if (!qp->rqe_wr_id) {
+		DP_ERR(dev, "create qp: failed RQ shadow memory allocation\n");
+		return -ENOMEM;
+	}
+
+	DP_VERBOSE(dev, QEDR_MSG_QP, "RQ max_wr set to %d.\n", qp->rq.max_wr);
+
+	return 0;
+}
+
+static inline int
+qedr_init_qp_kernel_params_sq(struct qedr_dev *dev,
+			      struct qedr_qp *qp,
+			      struct ib_qp_init_attr *attrs,
+			      struct qed_rdma_create_qp_in_params *params)
+{
+	u32 temp_max_wr;
+
+	/* Allocate driver internal SQ array */
+	temp_max_wr = attrs->cap.max_send_wr * dev->wq_multiplier;
+	temp_max_wr = min_t(u32, temp_max_wr, dev->attr.max_sqe);
+
+	/* temp_max_wr < attr->max_sqe < u16 so the casting is safe */
+	qp->sq.max_wr = (u16)temp_max_wr;
+	qp->wqe_wr_id = kcalloc(qp->sq.max_wr, sizeof(*qp->wqe_wr_id),
+				GFP_KERNEL);
+	if (!qp->wqe_wr_id) {
+		DP_ERR(dev, "create qp: failed SQ shadow memory allocation\n");
+		return -ENOMEM;
+	}
+
+	DP_VERBOSE(dev, QEDR_MSG_QP, "SQ max_wr set to %d.\n", qp->sq.max_wr);
+
+	/* QP handle to be written in CQE */
+	params->qp_handle_lo = lower_32_bits((uintptr_t)qp);
+	params->qp_handle_hi = upper_32_bits((uintptr_t)qp);
+
+	return 0;
+}
+
+static inline int qedr_init_qp_kernel_sq(struct qedr_dev *dev,
+					 struct qedr_qp *qp,
+					 struct ib_qp_init_attr *attrs)
+{
+	u32 n_sq_elems, n_sq_entries;
+	int rc;
+
+	/* A single work request may take up to QEDR_MAX_SQ_WQE_SIZE elements in
+	 * the ring. The ring should allow at least a single WR, even if the
+	 * user requested none, due to allocation issues.
+	 */
+	n_sq_entries = attrs->cap.max_send_wr;
+	n_sq_entries = min_t(u32, n_sq_entries, dev->attr.max_sqe);
+	n_sq_entries = max_t(u32, n_sq_entries, 1);
+	n_sq_elems = n_sq_entries * QEDR_MAX_SQE_ELEMENTS_PER_SQE;
+	rc = dev->ops->common->chain_alloc(dev->cdev,
+					   QED_CHAIN_USE_TO_PRODUCE,
+					   QED_CHAIN_MODE_PBL,
+					   QED_CHAIN_CNT_TYPE_U32,
+					   n_sq_elems,
+					   QEDR_SQE_ELEMENT_SIZE,
+					   &qp->sq.pbl);
+	if (rc) {
+		DP_ERR(dev, "failed to allocate QP %p SQ\n", qp);
+		return rc;
+	}
+
+	DP_VERBOSE(dev, QEDR_MSG_SQ,
+		   "SQ Pbl base addr = %llx max_send_wr=%d max_wr=%d capacity=%d, rc=%d\n",
+		   qed_chain_get_pbl_phys(&qp->sq.pbl), attrs->cap.max_send_wr,
+		   n_sq_entries, qed_chain_get_capacity(&qp->sq.pbl), rc);
+	return 0;
+}
+
+static inline int qedr_init_qp_kernel_rq(struct qedr_dev *dev,
+					 struct qedr_qp *qp,
+					 struct ib_qp_init_attr *attrs)
+{
+	u32 n_rq_elems, n_rq_entries;
+	int rc;
+
+	/* A single work request may take up to QEDR_MAX_RQ_WQE_SIZE elements in
+	 * the ring. There ring should allow at least a single WR, even if the
+	 * user requested none, due to allocation issues.
+	 */
+	n_rq_entries = max_t(u32, attrs->cap.max_recv_wr, 1);
+	n_rq_elems = n_rq_entries * QEDR_MAX_RQE_ELEMENTS_PER_RQE;
+	rc = dev->ops->common->chain_alloc(dev->cdev,
+					   QED_CHAIN_USE_TO_CONSUME_PRODUCE,
+					   QED_CHAIN_MODE_PBL,
+					   QED_CHAIN_CNT_TYPE_U32,
+					   n_rq_elems,
+					   QEDR_RQE_ELEMENT_SIZE,
+					   &qp->rq.pbl);
+
+	if (rc) {
+		DP_ERR(dev, "failed to allocate memory for QP %p RQ\n", qp);
+		return -ENOMEM;
+	}
+
+	DP_VERBOSE(dev, QEDR_MSG_RQ,
+		   "RQ Pbl base addr = %llx max_recv_wr=%d max_wr=%d capacity=%d, rc=%d\n",
+		   qed_chain_get_pbl_phys(&qp->rq.pbl), attrs->cap.max_recv_wr,
+		   n_rq_entries, qed_chain_get_capacity(&qp->rq.pbl), rc);
+
+	/* n_rq_entries < u16 so the casting is safe */
+	qp->rq.max_wr = (u16)n_rq_entries;
+
+	return 0;
+}
+
+static inline void
+qedr_init_qp_in_params_sq(struct qedr_dev *dev,
+			  struct qedr_pd *pd,
+			  struct qedr_qp *qp,
+			  struct ib_qp_init_attr *attrs,
+			  struct ib_udata *udata,
+			  struct qed_rdma_create_qp_in_params *params)
+{
+	/* QP handle to be written in an async event */
+	params->qp_handle_async_lo = lower_32_bits((uintptr_t)qp);
+	params->qp_handle_async_hi = upper_32_bits((uintptr_t)qp);
+
+	params->signal_all = (attrs->sq_sig_type == IB_SIGNAL_ALL_WR);
+	params->fmr_and_reserved_lkey = !udata;
+	params->pd = pd->pd_id;
+	params->dpi = pd->uctx ? pd->uctx->dpi : dev->dpi;
+	params->sq_cq_id = get_qedr_cq(attrs->send_cq)->icid;
+	params->max_sq_sges = 0;
+	params->stats_queue = 0;
+
+	if (udata) {
+		params->sq_num_pages = qp->usq.pbl_info.num_pbes;
+		params->sq_pbl_ptr = qp->usq.pbl_tbl->pa;
+	} else {
+		params->sq_num_pages = qed_chain_get_page_cnt(&qp->sq.pbl);
+		params->sq_pbl_ptr = qed_chain_get_pbl_phys(&qp->sq.pbl);
+	}
+}
+
+static inline void
+qedr_init_qp_in_params_rq(struct qedr_qp *qp,
+			  struct ib_qp_init_attr *attrs,
+			  struct ib_udata *udata,
+			  struct qed_rdma_create_qp_in_params *params)
+{
+	params->rq_cq_id = get_qedr_cq(attrs->recv_cq)->icid;
+	params->srq_id = 0;
+	params->use_srq = false;
+
+	if (udata) {
+		params->rq_num_pages = qp->urq.pbl_info.num_pbes;
+		params->rq_pbl_ptr = qp->urq.pbl_tbl->pa;
+	} else {
+		params->rq_num_pages = qed_chain_get_page_cnt(&qp->rq.pbl);
+		params->rq_pbl_ptr = qed_chain_get_pbl_phys(&qp->rq.pbl);
+	}
+}
+
+static inline void qedr_qp_user_print(struct qedr_dev *dev, struct qedr_qp *qp)
+{
+	DP_VERBOSE(dev, QEDR_MSG_QP,
+		   "create qp: successfully created user QP. qp=%p, sq_addr=0x%llx, sq_len=%zd, rq_addr=0x%llx, rq_len=%zd\n",
+		   qp, qp->usq.buf_addr, qp->usq.buf_len, qp->urq.buf_addr,
+		   qp->urq.buf_len);
+}
+
+static inline int qedr_init_user_qp(struct ib_ucontext *ib_ctx,
+				    struct qedr_dev *dev,
+				    struct qedr_qp *qp,
+				    struct qedr_create_qp_ureq *ureq)
+{
+	int rc;
+
+	/* SQ - read access only (0), dma sync not required (0) */
+	rc = qedr_init_user_queue(ib_ctx, dev, &qp->usq, ureq->sq_addr,
+				  ureq->sq_len, 0, 0);
+	if (rc)
+		return rc;
+
+	/* RQ - read access only (0), dma sync not required (0) */
+	rc = qedr_init_user_queue(ib_ctx, dev, &qp->urq, ureq->rq_addr,
+				  ureq->rq_len, 0, 0);
+
+	if (rc)
+		qedr_cleanup_user_sq(dev, qp);
+	return rc;
+}
+
+static inline int
+qedr_init_kernel_qp(struct qedr_dev *dev,
+		    struct qedr_qp *qp,
+		    struct ib_qp_init_attr *attrs,
+		    struct qed_rdma_create_qp_in_params *params)
+{
+	int rc;
+
+	rc = qedr_init_qp_kernel_sq(dev, qp, attrs);
+	if (rc) {
+		DP_ERR(dev, "failed to init kernel QP %p SQ\n", qp);
+		return rc;
+	}
+
+	rc = qedr_init_qp_kernel_params_sq(dev, qp, attrs, params);
+	if (rc) {
+		dev->ops->common->chain_free(dev->cdev, &qp->sq.pbl);
+		DP_ERR(dev, "failed to init kernel QP %p SQ params\n", qp); 
+		return rc;
+	}
+
+	rc = qedr_init_qp_kernel_rq(dev, qp, attrs);
+	if (rc) {
+		qedr_cleanup_kernel_sq(dev, qp);
+		DP_ERR(dev, "failed to init kernel QP %p RQ\n", qp);
+		return rc;
+	}
+
+	rc = qedr_init_qp_kernel_params_rq(dev, qp, attrs);
+	if (rc) {
+		DP_ERR(dev, "failed to init kernel QP %p RQ params\n", qp);
+		qedr_cleanup_kernel_sq(dev, qp);
+		dev->ops->common->chain_free(dev->cdev, &qp->rq.pbl);
+		return rc;
+	}
+
+	return rc;
+}
+
+struct ib_qp *qedr_create_qp(struct ib_pd *ibpd,
+			     struct ib_qp_init_attr *attrs,
+			     struct ib_udata *udata)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibpd->device);
+	struct qed_rdma_create_qp_out_params out_params;
+	struct qed_rdma_create_qp_in_params in_params;
+	struct qedr_pd *pd = get_qedr_pd(ibpd);
+	struct ib_ucontext *ib_ctx = NULL;
+	struct qedr_ucontext *ctx = NULL;
+	struct qedr_create_qp_ureq ureq;
+	struct qedr_qp *qp;
+	int rc = 0;
+
+	DP_VERBOSE(dev, QEDR_MSG_QP, "create qp: called from %s, pd=%p\n",
+		   udata ? "user library" : "kernel", pd);
+
+	rc = qedr_check_qp_attrs(ibpd, dev, attrs);
+	if (rc)
+		return ERR_PTR(rc);
+
+	qp = kzalloc(sizeof(*qp), GFP_KERNEL);
+	if (!qp) {
+		DP_ERR(dev, "create qp: failed allocating memory\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	if (attrs->srq)
+		return ERR_PTR(-EINVAL);
+
+	DP_VERBOSE(dev, QEDR_MSG_QP,
+		   "create qp: sq_cq=%p, sq_icid=%d, rq_cq=%p, rq_icid=%d\n",
+		   get_qedr_cq(attrs->send_cq),
+		   get_qedr_cq(attrs->send_cq)->icid,
+		   get_qedr_cq(attrs->recv_cq),
+		   get_qedr_cq(attrs->recv_cq)->icid);
+
+	qedr_set_qp_init_params(dev, qp, pd, attrs);
+
+	memset(&in_params, 0, sizeof(in_params));
+
+	if (udata) {
+		if (!(udata && ibpd->uobject && ibpd->uobject->context))
+			goto err0;
+
+		ib_ctx = ibpd->uobject->context;
+		ctx = get_qedr_ucontext(ib_ctx);
+
+		memset(&ureq, 0, sizeof(ureq));
+		if (ib_copy_from_udata(&ureq, udata, sizeof(ureq))) {
+			DP_ERR(dev,
+			       "create qp: problem copying data from user space\n");
+			goto err0;
+		}
+
+		rc = qedr_init_user_qp(ib_ctx, dev, qp, &ureq);
+		if (rc)
+			goto err0;
+
+		qedr_init_qp_user_params(&in_params, &ureq);
+	} else {
+		rc = qedr_init_kernel_qp(dev, qp, attrs, &in_params);
+		if (rc)
+			goto err0;
+	}
+
+	qedr_init_qp_in_params_sq(dev, pd, qp, attrs, udata, &in_params);
+	qedr_init_qp_in_params_rq(qp, attrs, udata, &in_params);
+
+	qp->qed_qp = dev->ops->rdma_create_qp(dev->rdma_ctx,
+					      &in_params, &out_params);
+
+	if (!qp->qed_qp)
+		goto err1;
+
+	qp->qp_id = out_params.qp_id;
+	qp->icid = out_params.icid;
+	qp->ibqp.qp_num = qp->qp_id;
+
+	if (udata) {
+		rc = qedr_copy_qp_uresp(dev, qp, udata);
+		if (rc)
+			goto err2;
+
+		qedr_qp_user_print(dev, qp);
+	} else {
+		qedr_init_qp_kernel_doorbell_sq(dev, qp);
+		qedr_init_qp_kernel_doorbell_rq(dev, qp);
+	}
+
+	DP_VERBOSE(dev, QEDR_MSG_QP, "created %s space QP %p\n", udata ? "user" : "kernel", qp);
+
+	return &qp->ibqp;
+
+err2:
+	rc = dev->ops->rdma_destroy_qp(dev->rdma_ctx, qp->qed_qp);
+	if (rc)
+		DP_ERR(dev, "create qp: fatal fault. rc=%d", rc);
+err1:
+	if (udata) {
+		qedr_cleanup_user_sq(dev, qp);
+		qedr_cleanup_user_rq(dev, qp);
+	} else {
+		qedr_cleanup_kernel_sq(dev, qp);
+		qedr_cleanup_kernel_rq(dev, qp);
+	}
+
+err0:
+	kfree(qp);
+
+	return ERR_PTR(-EFAULT);
+}
+
+enum ib_qp_state qedr_get_ibqp_state(enum qed_roce_qp_state qp_state)
+{
+	switch (qp_state) {
+	case QED_ROCE_QP_STATE_RESET:
+		return IB_QPS_RESET;
+	case QED_ROCE_QP_STATE_INIT:
+		return IB_QPS_INIT;
+	case QED_ROCE_QP_STATE_RTR:
+		return IB_QPS_RTR;
+	case QED_ROCE_QP_STATE_RTS:
+		return IB_QPS_RTS;
+	case QED_ROCE_QP_STATE_SQD:
+		return IB_QPS_SQD;
+	case QED_ROCE_QP_STATE_ERR:
+		return IB_QPS_ERR;
+	case QED_ROCE_QP_STATE_SQE:
+		return IB_QPS_SQE;
+	}
+	return IB_QPS_ERR;
+}
+
+enum qed_roce_qp_state qedr_get_state_from_ibqp(enum ib_qp_state qp_state)
+{
+	switch (qp_state) {
+	case IB_QPS_RESET:
+		return QED_ROCE_QP_STATE_RESET;
+	case IB_QPS_INIT:
+		return QED_ROCE_QP_STATE_INIT;
+	case IB_QPS_RTR:
+		return QED_ROCE_QP_STATE_RTR;
+	case IB_QPS_RTS:
+		return QED_ROCE_QP_STATE_RTS;
+	case IB_QPS_SQD:
+		return QED_ROCE_QP_STATE_SQD;
+	case IB_QPS_ERR:
+		return QED_ROCE_QP_STATE_ERR;
+	default:
+		return QED_ROCE_QP_STATE_ERR;
+	}
+}
+
+static void qedr_reset_qp_hwq_info(struct qedr_qp_hwq_info *qph)
+{
+	qed_chain_reset(&qph->pbl);
+	qph->prod = 0;
+	qph->cons = 0;
+	qph->wqe_cons = 0;
+	qph->db_data.data.value = cpu_to_le16(0);
+}
+
+static int qedr_update_qp_state(struct qedr_dev *dev,
+				struct qedr_qp *qp,
+				enum qed_roce_qp_state new_state)
+{
+	int status = 0;
+
+	if (new_state == qp->state)
+		return 1;
+
+	switch (qp->state) {
+	case QED_ROCE_QP_STATE_RESET:
+		switch (new_state) {
+		case QED_ROCE_QP_STATE_INIT:
+			qp->prev_wqe_size = 0;
+			qedr_reset_qp_hwq_info(&qp->sq);
+			qedr_reset_qp_hwq_info(&qp->rq);
+			break;
+		default:
+			status = -EINVAL;
+			break;
+		};
+		break;
+	case QED_ROCE_QP_STATE_INIT:
+		switch (new_state) {
+		case QED_ROCE_QP_STATE_RTR:
+			/* Update doorbell (in case post_recv was
+			 * done before move to RTR)
+			 */
+			wmb();
+			writel(qp->rq.db_data.raw, qp->rq.db);
+			/* Make sure write takes effect */
+			mmiowb();
+			break;
+		case QED_ROCE_QP_STATE_ERR:
+			break;
+		default:
+			/* Invalid state change. */
+			status = -EINVAL;
+			break;
+		};
+		break;
+	case QED_ROCE_QP_STATE_RTR:
+		/* RTR->XXX */
+		switch (new_state) {
+		case QED_ROCE_QP_STATE_RTS:
+			break;
+		case QED_ROCE_QP_STATE_ERR:
+			break;
+		default:
+			/* Invalid state change. */
+			status = -EINVAL;
+			break;
+		};
+		break;
+	case QED_ROCE_QP_STATE_RTS:
+		/* RTS->XXX */
+		switch (new_state) {
+		case QED_ROCE_QP_STATE_SQD:
+			break;
+		case QED_ROCE_QP_STATE_ERR:
+			break;
+		default:
+			/* Invalid state change. */
+			status = -EINVAL;
+			break;
+		};
+		break;
+	case QED_ROCE_QP_STATE_SQD:
+		/* SQD->XXX */
+		switch (new_state) {
+		case QED_ROCE_QP_STATE_RTS:
+		case QED_ROCE_QP_STATE_ERR:
+			break;
+		default:
+			/* Invalid state change. */
+			status = -EINVAL;
+			break;
+		};
+		break;
+	case QED_ROCE_QP_STATE_ERR:
+		/* ERR->XXX */
+		switch (new_state) {
+		case QED_ROCE_QP_STATE_RESET:
+			break;
+		default:
+			status = -EINVAL;
+			break;
+		};
+		break;
+	default:
+		status = -EINVAL;
+		break;
+	};
+
+	return status;
+}
+
+int qedr_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
+		   int attr_mask, struct ib_udata *udata)
+{
+	struct qedr_qp *qp = get_qedr_qp(ibqp);
+	struct qed_rdma_modify_qp_in_params qp_params = { 0 };
+	struct qedr_dev *dev = get_qedr_dev(&qp->dev->ibdev);
+	enum ib_qp_state old_qp_state, new_qp_state;
+	int rc = 0;
+
+	DP_VERBOSE(dev, QEDR_MSG_QP,
+		   "modify qp: qp %p attr_mask=0x%x, state=%d", qp, attr_mask,
+		   attr->qp_state);
+
+	old_qp_state = qedr_get_ibqp_state(qp->state);
+	if (attr_mask & IB_QP_STATE)
+		new_qp_state = attr->qp_state;
+	else
+		new_qp_state = old_qp_state;
+
+	if (!ib_modify_qp_is_ok
+	    (old_qp_state, new_qp_state, ibqp->qp_type, attr_mask,
+	     IB_LINK_LAYER_ETHERNET)) {
+		DP_ERR(dev,
+		       "modify qp: invalid attribute mask=0x%x specified for\n"
+		       "qpn=0x%x of type=0x%x old_qp_state=0x%x, new_qp_state=0x%x\n",
+		       attr_mask, qp->qp_id, ibqp->qp_type, old_qp_state,
+		       new_qp_state);
+		rc = -EINVAL;
+		goto err;
+	}
+
+	/* Translate the masks... */
+	if (attr_mask & IB_QP_STATE) {
+		SET_FIELD(qp_params.modify_flags,
+			  QED_RDMA_MODIFY_QP_VALID_NEW_STATE, 1);
+		qp_params.new_state = qedr_get_state_from_ibqp(attr->qp_state);
+	}
+
+	if (attr_mask & IB_QP_EN_SQD_ASYNC_NOTIFY)
+		qp_params.sqd_async = true;
+
+	if (attr_mask & IB_QP_PKEY_INDEX) {
+		SET_FIELD(qp_params.modify_flags,
+			  QED_ROCE_MODIFY_QP_VALID_PKEY, 1);
+		if (attr->pkey_index >= QEDR_ROCE_PKEY_TABLE_LEN) {
+			rc = -EINVAL;
+			goto err;
+		}
+
+		qp_params.pkey = QEDR_ROCE_PKEY_DEFAULT;
+	}
+
+	if (attr_mask & IB_QP_QKEY)
+		qp->qkey = attr->qkey;
+
+	if (attr_mask & IB_QP_ACCESS_FLAGS) {
+		SET_FIELD(qp_params.modify_flags,
+			  QED_RDMA_MODIFY_QP_VALID_RDMA_OPS_EN, 1);
+		qp_params.incoming_rdma_read_en = attr->qp_access_flags &
+						  IB_ACCESS_REMOTE_READ;
+		qp_params.incoming_rdma_write_en = attr->qp_access_flags &
+						   IB_ACCESS_REMOTE_WRITE;
+		qp_params.incoming_atomic_en = attr->qp_access_flags &
+					       IB_ACCESS_REMOTE_ATOMIC;
+	}
+
+	if (attr_mask & (IB_QP_AV | IB_QP_PATH_MTU)) {
+		if (attr_mask & IB_QP_PATH_MTU) {
+			if (attr->path_mtu < IB_MTU_256 ||
+			    attr->path_mtu > IB_MTU_4096) {
+				pr_err("error: Only MTU sizes of 256, 512, 1024, 2048 and 4096 are supported by RoCE\n");
+				rc = -EINVAL;
+				goto err;
+			}
+			qp->mtu = min(ib_mtu_enum_to_int(attr->path_mtu),
+				      ib_mtu_enum_to_int(iboe_get_mtu
+							 (dev->ndev->mtu)));
+		}
+
+		if (!qp->mtu) {
+			qp->mtu =
+			ib_mtu_enum_to_int(iboe_get_mtu(dev->ndev->mtu));
+			pr_err("Fixing zeroed MTU to qp->mtu = %d\n", qp->mtu);
+		}
+
+		SET_FIELD(qp_params.modify_flags,
+			  QED_ROCE_MODIFY_QP_VALID_ADDRESS_VECTOR, 1);
+
+		qp_params.traffic_class_tos = attr->ah_attr.grh.traffic_class;
+		qp_params.flow_label = attr->ah_attr.grh.flow_label;
+		qp_params.hop_limit_ttl = attr->ah_attr.grh.hop_limit;
+
+		qp->sgid_idx = attr->ah_attr.grh.sgid_index;
+
+		rc = get_gid_info_from_table(ibqp, attr, attr_mask, &qp_params);
+		if (rc) {
+			DP_ERR(dev,
+			       "modify qp: problems with GID index %d (rc=%d)\n",
+			       attr->ah_attr.grh.sgid_index, rc);
+			return rc;
+		}
+
+		rc = qedr_get_dmac(dev, &attr->ah_attr,
+				   qp_params.remote_mac_addr);
+		if (rc)
+			return rc;
+
+		qp_params.use_local_mac = true;
+		ether_addr_copy(qp_params.local_mac_addr, dev->ndev->dev_addr);
+
+		DP_VERBOSE(dev, QEDR_MSG_QP, "dgid=%x:%x:%x:%x\n",
+			   qp_params.dgid.dwords[0], qp_params.dgid.dwords[1],
+			   qp_params.dgid.dwords[2], qp_params.dgid.dwords[3]);
+		DP_VERBOSE(dev, QEDR_MSG_QP, "sgid=%x:%x:%x:%x\n",
+			   qp_params.sgid.dwords[0], qp_params.sgid.dwords[1],
+			   qp_params.sgid.dwords[2], qp_params.sgid.dwords[3]);
+		DP_VERBOSE(dev, QEDR_MSG_QP, "remote_mac=[%pM]\n",
+			   qp_params.remote_mac_addr);
+;
+
+		qp_params.mtu = qp->mtu;
+		qp_params.lb_indication = false;
+	}
+
+	if (!qp_params.mtu) {
+		/* Stay with current MTU */
+		if (qp->mtu)
+			qp_params.mtu = qp->mtu;
+		else
+			qp_params.mtu =
+			    ib_mtu_enum_to_int(iboe_get_mtu(dev->ndev->mtu));
+	}
+
+	if (attr_mask & IB_QP_TIMEOUT) {
+		SET_FIELD(qp_params.modify_flags,
+			  QED_ROCE_MODIFY_QP_VALID_ACK_TIMEOUT, 1);
+
+		qp_params.ack_timeout = attr->timeout;
+		if (attr->timeout) {
+			u32 temp;
+
+			temp = 4096 * (1UL << attr->timeout) / 1000 / 1000;
+			/* FW requires [msec] */
+			qp_params.ack_timeout = temp;
+		} else {
+			/* Infinite */
+			qp_params.ack_timeout = 0;
+		}
+	}
+	if (attr_mask & IB_QP_RETRY_CNT) {
+		SET_FIELD(qp_params.modify_flags,
+			  QED_ROCE_MODIFY_QP_VALID_RETRY_CNT, 1);
+		qp_params.retry_cnt = attr->retry_cnt;
+	}
+
+	if (attr_mask & IB_QP_RNR_RETRY) {
+		SET_FIELD(qp_params.modify_flags,
+			  QED_ROCE_MODIFY_QP_VALID_RNR_RETRY_CNT, 1);
+		qp_params.rnr_retry_cnt = attr->rnr_retry;
+	}
+
+	if (attr_mask & IB_QP_RQ_PSN) {
+		SET_FIELD(qp_params.modify_flags,
+			  QED_ROCE_MODIFY_QP_VALID_RQ_PSN, 1);
+		qp_params.rq_psn = attr->rq_psn;
+		qp->rq_psn = attr->rq_psn;
+	}
+
+	if (attr_mask & IB_QP_MAX_QP_RD_ATOMIC) {
+		if (attr->max_rd_atomic > dev->attr.max_qp_req_rd_atomic_resc) {
+			rc = -EINVAL;
+			DP_ERR(dev,
+			       "unsupported max_rd_atomic=%d, supported=%d\n",
+			       attr->max_rd_atomic,
+			       dev->attr.max_qp_req_rd_atomic_resc);
+			goto err;
+		}
+
+		SET_FIELD(qp_params.modify_flags,
+			  QED_RDMA_MODIFY_QP_VALID_MAX_RD_ATOMIC_REQ, 1);
+		qp_params.max_rd_atomic_req = attr->max_rd_atomic;
+	}
+
+	if (attr_mask & IB_QP_MIN_RNR_TIMER) {
+		SET_FIELD(qp_params.modify_flags,
+			  QED_ROCE_MODIFY_QP_VALID_MIN_RNR_NAK_TIMER, 1);
+		qp_params.min_rnr_nak_timer = attr->min_rnr_timer;
+	}
+
+	if (attr_mask & IB_QP_SQ_PSN) {
+		SET_FIELD(qp_params.modify_flags,
+			  QED_ROCE_MODIFY_QP_VALID_SQ_PSN, 1);
+		qp_params.sq_psn = attr->sq_psn;
+		qp->sq_psn = attr->sq_psn;
+	}
+
+	if (attr_mask & IB_QP_MAX_DEST_RD_ATOMIC) {
+		if (attr->max_dest_rd_atomic >
+		    dev->attr.max_qp_resp_rd_atomic_resc) {
+			DP_ERR(dev,
+			       "unsupported max_dest_rd_atomic=%d, supported=%d\n",
+			       attr->max_dest_rd_atomic,
+			       dev->attr.max_qp_resp_rd_atomic_resc);
+
+			rc = -EINVAL;
+			goto err;
+		}
+
+		SET_FIELD(qp_params.modify_flags,
+			  QED_RDMA_MODIFY_QP_VALID_MAX_RD_ATOMIC_RESP, 1);
+		qp_params.max_rd_atomic_resp = attr->max_dest_rd_atomic;
+	}
+
+	if (attr_mask & IB_QP_DEST_QPN) {
+		SET_FIELD(qp_params.modify_flags,
+			  QED_ROCE_MODIFY_QP_VALID_DEST_QP, 1);
+
+		qp_params.dest_qp = attr->dest_qp_num;
+		qp->dest_qp_num = attr->dest_qp_num;
+	}
+
+	if (qp->qp_type != IB_QPT_GSI)
+		rc = dev->ops->rdma_modify_qp(dev->rdma_ctx,
+					      qp->qed_qp, &qp_params);
+
+	if (attr_mask & IB_QP_STATE) {
+		if ((qp->qp_type != IB_QPT_GSI) && (!udata))
+			qedr_update_qp_state(dev, qp, qp_params.new_state);
+		qp->state = qp_params.new_state;
+	}
+
+err:
+	return rc;
+}
+
+static int qedr_to_ib_qp_acc_flags(struct qed_rdma_query_qp_out_params *params)
+{
+	int ib_qp_acc_flags = 0;
+
+	if (params->incoming_rdma_write_en)
+		ib_qp_acc_flags |= IB_ACCESS_REMOTE_WRITE;
+	if (params->incoming_rdma_read_en)
+		ib_qp_acc_flags |= IB_ACCESS_REMOTE_READ;
+	if (params->incoming_atomic_en)
+		ib_qp_acc_flags |= IB_ACCESS_REMOTE_ATOMIC;
+	ib_qp_acc_flags |= IB_ACCESS_LOCAL_WRITE;
+	return ib_qp_acc_flags;
+}
+
+int qedr_query_qp(struct ib_qp *ibqp,
+		  struct ib_qp_attr *qp_attr,
+		  int attr_mask, struct ib_qp_init_attr *qp_init_attr)
+{
+	struct qed_rdma_query_qp_out_params params;
+	struct qedr_qp *qp = get_qedr_qp(ibqp);
+	struct qedr_dev *dev = qp->dev;
+	int rc = 0;
+
+	memset(&params, 0, sizeof(params));
+
+	rc = dev->ops->rdma_query_qp(dev->rdma_ctx, qp->qed_qp, &params);
+	if (rc)
+		goto err;
+
+	memset(qp_attr, 0, sizeof(*qp_attr));
+	memset(qp_init_attr, 0, sizeof(*qp_init_attr));
+
+	qp_attr->qp_state = qedr_get_ibqp_state(params.state);
+	qp_attr->cur_qp_state = qedr_get_ibqp_state(params.state);
+	qp_attr->path_mtu = iboe_get_mtu(params.mtu);
+	qp_attr->path_mig_state = IB_MIG_MIGRATED;
+	qp_attr->rq_psn = params.rq_psn;
+	qp_attr->sq_psn = params.sq_psn;
+	qp_attr->dest_qp_num = params.dest_qp;
+
+	qp_attr->qp_access_flags = qedr_to_ib_qp_acc_flags(&params);
+
+	qp_attr->cap.max_send_wr = qp->sq.max_wr;
+	qp_attr->cap.max_recv_wr = qp->rq.max_wr;
+	qp_attr->cap.max_send_sge = qp->sq.max_sges;
+	qp_attr->cap.max_recv_sge = qp->rq.max_sges;
+	qp_attr->cap.max_inline_data = qp->max_inline_data;
+	qp_init_attr->cap = qp_attr->cap;
+
+	memcpy(&qp_attr->ah_attr.grh.dgid.raw[0], &params.dgid.bytes[0],
+	       sizeof(qp_attr->ah_attr.grh.dgid.raw));
+
+	qp_attr->ah_attr.grh.flow_label = params.flow_label;
+	qp_attr->ah_attr.grh.sgid_index = qp->sgid_idx;
+	qp_attr->ah_attr.grh.hop_limit = params.hop_limit_ttl;
+	qp_attr->ah_attr.grh.traffic_class = params.traffic_class_tos;
+
+	qp_attr->ah_attr.ah_flags = IB_AH_GRH;
+	qp_attr->ah_attr.port_num = 1;
+	qp_attr->ah_attr.sl = 0;
+	qp_attr->timeout = params.timeout;
+	qp_attr->rnr_retry = params.rnr_retry;
+	qp_attr->retry_cnt = params.retry_cnt;
+	qp_attr->min_rnr_timer = params.min_rnr_nak_timer;
+	qp_attr->pkey_index = params.pkey_index;
+	qp_attr->port_num = 1;
+	qp_attr->ah_attr.src_path_bits = 0;
+	qp_attr->ah_attr.static_rate = 0;
+	qp_attr->alt_pkey_index = 0;
+	qp_attr->alt_port_num = 0;
+	qp_attr->alt_timeout = 0;
+	memset(&qp_attr->alt_ah_attr, 0, sizeof(qp_attr->alt_ah_attr));
+
+	qp_attr->sq_draining = (params.state == QED_ROCE_QP_STATE_SQD) ? 1 : 0;
+	qp_attr->max_dest_rd_atomic = params.max_dest_rd_atomic;
+	qp_attr->max_rd_atomic = params.max_rd_atomic;
+	qp_attr->en_sqd_async_notify = (params.sqd_async) ? 1 : 0;
+
+	DP_VERBOSE(dev, QEDR_MSG_QP, "QEDR_QUERY_QP: max_inline_data=%d\n",
+		   qp_attr->cap.max_inline_data);
+
+err:
+	return rc;
+}
+
+int qedr_destroy_qp(struct ib_qp *ibqp)
+{
+	struct qedr_qp *qp = get_qedr_qp(ibqp);
+	struct qedr_dev *dev = qp->dev;
+	struct ib_qp_attr attr;
+	int attr_mask = 0;
+	int rc = 0;
+
+	DP_VERBOSE(dev, QEDR_MSG_QP, "destroy qp: destroying %p, qp type=%d\n",
+		   qp, qp->qp_type);
+
+	if (qp->state != (QED_ROCE_QP_STATE_RESET | QED_ROCE_QP_STATE_ERR |
+			  QED_ROCE_QP_STATE_INIT)) {
+		attr.qp_state = IB_QPS_ERR;
+		attr_mask |= IB_QP_STATE;
+
+		/* Change the QP state to ERROR */
+		qedr_modify_qp(ibqp, &attr, attr_mask, NULL);
+	}
+
+	if (qp->qp_type != IB_QPT_GSI) {
+		rc = dev->ops->rdma_destroy_qp(dev->rdma_ctx, qp->qed_qp);
+		if (rc)
+			return rc;
+	}
+
+	if (ibqp->uobject && ibqp->uobject->context) {
+		qedr_cleanup_user_sq(dev, qp);
+		qedr_cleanup_user_rq(dev, qp);
+	} else {
+		qedr_cleanup_kernel_sq(dev, qp);
+		qedr_cleanup_kernel_rq(dev, qp);
+	}
+
+	kfree(qp);
+
+	return rc;
+}
diff --git a/drivers/infiniband/hw/qedr/verbs.h b/drivers/infiniband/hw/qedr/verbs.h
index d5e1017..80dbac1 100644
--- a/drivers/infiniband/hw/qedr/verbs.h
+++ b/drivers/infiniband/hw/qedr/verbs.h
@@ -36,5 +36,12 @@ struct ib_cq *qedr_create_cq(struct ib_device *ibdev,
 int qedr_resize_cq(struct ib_cq *, int cqe, struct ib_udata *);
 int qedr_destroy_cq(struct ib_cq *);
 int qedr_arm_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags flags);
+struct ib_qp *qedr_create_qp(struct ib_pd *, struct ib_qp_init_attr *attrs,
+			     struct ib_udata *);
+int qedr_modify_qp(struct ib_qp *, struct ib_qp_attr *attr,
+		   int attr_mask, struct ib_udata *udata);
+int qedr_query_qp(struct ib_qp *, struct ib_qp_attr *qp_attr,
+		  int qp_attr_mask, struct ib_qp_init_attr *);
+int qedr_destroy_qp(struct ib_qp *ibqp);
 
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.h b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
index d00ad05..2b8bdaa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
@@ -176,6 +176,7 @@ u32 qed_cxt_get_proto_tid_count(struct qed_hwfn *p_hwfn,
 				enum protocol_type type);
 u32 qed_cxt_get_proto_cid_start(struct qed_hwfn *p_hwfn,
 				enum protocol_type type);
+int qed_cxt_free_proto_ilt(struct qed_hwfn *p_hwfn, enum protocol_type proto);
 
 #define QED_CTX_WORKING_MEM 0
 #define QED_CTX_FL_MEM 1
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 7b489f0..cf92ff7 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -1114,6 +1114,1213 @@ err:	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
 	return rc;
 }
 
+static void qed_rdma_set_fw_mac(u16 *p_fw_mac, u8 *p_qed_mac)
+{
+	p_fw_mac[0] = cpu_to_le16((p_qed_mac[0] << 8) + p_qed_mac[1]);
+	p_fw_mac[1] = cpu_to_le16((p_qed_mac[2] << 8) + p_qed_mac[3]);
+	p_fw_mac[2] = cpu_to_le16((p_qed_mac[4] << 8) + p_qed_mac[5]);
+}
+
+static void qed_rdma_copy_gids(struct qed_rdma_qp *qp, __le32 *src_gid,
+			       __le32 *dst_gid)
+{
+	u32 i;
+
+	if (qp->roce_mode == ROCE_V2_IPV4) {
+		/* RoCE v2 - IPv4 only */
+		/* The IPv4 addresses shall be aligned to the highest word.
+		 * The lower words must be zero.
+		 */
+		memset(src_gid, 0, sizeof(union qed_gid));
+		memset(dst_gid, 0, sizeof(union qed_gid));
+		src_gid[3] = cpu_to_le32(qp->sgid.ipv4_addr);
+		dst_gid[3] = cpu_to_le32(qp->dgid.ipv4_addr);
+	} else {
+		/* RoCE, and RoCE v2 - IPv6 */
+		/* GIDs and IPv6 addresses coincide in location and size */
+		for (i = 0; i < ARRAY_SIZE(qp->sgid.dwords); i++) {
+			src_gid[i] = cpu_to_le32(qp->sgid.dwords[i]);
+			dst_gid[i] = cpu_to_le32(qp->dgid.dwords[i]);
+		}
+	}
+}
+
+static enum roce_flavor qed_roce_mode_to_flavor(enum roce_mode roce_mode)
+{
+	enum roce_flavor flavor;
+
+	switch (roce_mode) {
+	case ROCE_V1:
+		flavor = PLAIN_ROCE;
+		break;
+	case ROCE_V2_IPV4:
+		flavor = RROCE_IPV4;
+		break;
+	case ROCE_V2_IPV6:
+		flavor = ROCE_V2_IPV6;
+		break;
+	default:
+		flavor = MAX_ROCE_MODE;
+		break;
+	}
+	return flavor;
+}
+
+int qed_roce_alloc_cid(struct qed_hwfn *p_hwfn, u16 *cid)
+{
+	struct qed_rdma_info *p_rdma_info = p_hwfn->p_rdma_info;
+	u32 responder_icid;
+	u32 requester_icid;
+	int rc;
+
+	spin_lock_bh(&p_hwfn->p_rdma_info->lock);
+	rc = qed_rdma_bmap_alloc_id(p_hwfn, &p_rdma_info->cid_map,
+				    &responder_icid);
+	if (rc) {
+		spin_unlock_bh(&p_rdma_info->lock);
+		return rc;
+	}
+
+	rc = qed_rdma_bmap_alloc_id(p_hwfn, &p_rdma_info->cid_map,
+				    &requester_icid);
+
+	spin_unlock_bh(&p_rdma_info->lock);
+	if (rc)
+		goto err;
+
+	/* the two icid's should be adjacent */
+	if ((requester_icid - responder_icid) != 1) {
+		DP_NOTICE(p_hwfn, "Failed to allocate two adjacent qp's'\n");
+		rc = -EINVAL;
+		goto err;
+	}
+
+	responder_icid += qed_cxt_get_proto_cid_start(p_hwfn,
+						      p_rdma_info->proto);
+	requester_icid += qed_cxt_get_proto_cid_start(p_hwfn,
+						      p_rdma_info->proto);
+
+	/* If these icids require a new ILT line allocate DMA-able context for
+	 * an ILT page
+	 */
+	rc = qed_cxt_dynamic_ilt_alloc(p_hwfn, QED_ELEM_CXT, responder_icid);
+	if (rc)
+		goto err;
+
+	rc = qed_cxt_dynamic_ilt_alloc(p_hwfn, QED_ELEM_CXT, requester_icid);
+	if (rc)
+		goto err;
+
+	*cid = (u16)responder_icid;
+	return rc;
+
+err:
+	spin_lock_bh(&p_rdma_info->lock);
+	qed_bmap_release_id(p_hwfn, &p_rdma_info->cid_map, responder_icid);
+	qed_bmap_release_id(p_hwfn, &p_rdma_info->cid_map, requester_icid);
+
+	spin_unlock_bh(&p_rdma_info->lock);
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+		   "Allocate CID - failed, rc = %d\n", rc);
+	return rc;
+}
+
+static int qed_roce_sp_create_responder(struct qed_hwfn *p_hwfn,
+					struct qed_rdma_qp *qp)
+{
+	struct roce_create_qp_resp_ramrod_data *p_ramrod;
+	struct qed_sp_init_data init_data;
+	union qed_qm_pq_params qm_params;
+	enum roce_flavor roce_flavor;
+	struct qed_spq_entry *p_ent;
+	u16 physical_queue0 = 0;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", qp->icid);
+
+	/* Allocate DMA-able memory for IRQ */
+	qp->irq_num_pages = 1;
+	qp->irq = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+				     RDMA_RING_PAGE_SIZE,
+				     &qp->irq_phys_addr, GFP_KERNEL);
+	if (!qp->irq) {
+		rc = -ENOMEM;
+		DP_NOTICE(p_hwfn,
+			  "qed create responder failed: cannot allocate memory (irq). rc = %d\n",
+			  rc);
+		return rc;
+	}
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qp->icid;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent, ROCE_RAMROD_CREATE_QP,
+				 PROTOCOLID_ROCE, &init_data);
+	if (rc)
+		goto err;
+
+	p_ramrod = &p_ent->ramrod.roce_create_qp_resp;
+
+	p_ramrod->flags = 0;
+
+	roce_flavor = qed_roce_mode_to_flavor(qp->roce_mode);
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_RESP_RAMROD_DATA_ROCE_FLAVOR, roce_flavor);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_RESP_RAMROD_DATA_RDMA_RD_EN,
+		  qp->incoming_rdma_read_en);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_RESP_RAMROD_DATA_RDMA_WR_EN,
+		  qp->incoming_rdma_write_en);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_RESP_RAMROD_DATA_ATOMIC_EN,
+		  qp->incoming_atomic_en);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_RESP_RAMROD_DATA_E2E_FLOW_CONTROL_EN,
+		  qp->e2e_flow_control_en);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_RESP_RAMROD_DATA_SRQ_FLG, qp->use_srq);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_RESP_RAMROD_DATA_RESERVED_KEY_EN,
+		  qp->fmr_and_reserved_lkey);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_RESP_RAMROD_DATA_MIN_RNR_NAK_TIMER,
+		  qp->min_rnr_nak_timer);
+
+	p_ramrod->max_ird = qp->max_rd_atomic_resp;
+	p_ramrod->traffic_class = qp->traffic_class_tos;
+	p_ramrod->hop_limit = qp->hop_limit_ttl;
+	p_ramrod->irq_num_pages = qp->irq_num_pages;
+	p_ramrod->p_key = cpu_to_le16(qp->pkey);
+	p_ramrod->flow_label = cpu_to_le32(qp->flow_label);
+	p_ramrod->dst_qp_id = cpu_to_le32(qp->dest_qp);
+	p_ramrod->mtu = cpu_to_le16(qp->mtu);
+	p_ramrod->initial_psn = cpu_to_le32(qp->rq_psn);
+	p_ramrod->pd = cpu_to_le16(qp->pd);
+	p_ramrod->rq_num_pages = cpu_to_le16(qp->rq_num_pages);
+	p_ramrod->rq_pbl_addr.hi = DMA_HI_LE(qp->rq_pbl_ptr);
+	p_ramrod->rq_pbl_addr.lo = DMA_LO_LE(qp->rq_pbl_ptr);
+	p_ramrod->irq_pbl_addr.hi = DMA_HI_LE(qp->irq_phys_addr);
+	p_ramrod->irq_pbl_addr.lo = DMA_LO_LE(qp->irq_phys_addr);
+	qed_rdma_copy_gids(qp, p_ramrod->src_gid, p_ramrod->dst_gid);
+	p_ramrod->qp_handle_for_async.hi = cpu_to_le32(qp->qp_handle_async.hi);
+	p_ramrod->qp_handle_for_async.lo = cpu_to_le32(qp->qp_handle_async.lo);
+	p_ramrod->qp_handle_for_cqe.hi = cpu_to_le32(qp->qp_handle.hi);
+	p_ramrod->qp_handle_for_cqe.lo = cpu_to_le32(qp->qp_handle.lo);
+	p_ramrod->stats_counter_id = p_hwfn->rel_pf_id;
+	p_ramrod->cq_cid = cpu_to_le32((p_hwfn->hw_info.opaque_fid << 16) |
+				       qp->rq_cq_id);
+
+	memset(&qm_params, 0, sizeof(qm_params));
+	qm_params.roce.qpid = (qp->icid >> 1);
+	physical_queue0 = qed_get_qm_pq(p_hwfn, PROTOCOLID_ROCE, &qm_params);
+
+	p_ramrod->physical_queue0 = cpu_to_le16(physical_queue0);
+	p_ramrod->dpi = cpu_to_le16(qp->dpi);
+
+	qed_rdma_set_fw_mac(p_ramrod->remote_mac_addr, qp->remote_mac_addr);
+	qed_rdma_set_fw_mac(p_ramrod->local_mac_addr, qp->local_mac_addr);
+
+	p_ramrod->udp_src_port = qp->udp_src_port;
+	p_ramrod->vlan_id = cpu_to_le16(qp->vlan_id);
+	p_ramrod->srq_id.srq_idx = cpu_to_le16(qp->srq_id);
+	p_ramrod->srq_id.opaque_fid = cpu_to_le16(p_hwfn->hw_info.opaque_fid);
+
+	p_ramrod->stats_counter_id = RESC_START(p_hwfn, QED_RDMA_STATS_QUEUE) +
+				     qp->stats_queue;
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "rc = %d physical_queue0 = 0x%x\n",
+		   rc, physical_queue0);
+
+	if (rc)
+		goto err;
+
+	qp->resp_offloaded = true;
+
+	return rc;
+
+err:
+	DP_NOTICE(p_hwfn, "create responder - failed, rc = %d\n", rc);
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  qp->irq_num_pages * RDMA_RING_PAGE_SIZE,
+			  qp->irq, qp->irq_phys_addr);
+
+	return rc;
+}
+
+static int qed_roce_sp_create_requester(struct qed_hwfn *p_hwfn,
+					struct qed_rdma_qp *qp)
+{
+	struct roce_create_qp_req_ramrod_data *p_ramrod;
+	struct qed_sp_init_data init_data;
+	union qed_qm_pq_params qm_params;
+	enum roce_flavor roce_flavor;
+	struct qed_spq_entry *p_ent;
+	u16 physical_queue0 = 0;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", qp->icid);
+
+	/* Allocate DMA-able memory for ORQ */
+	qp->orq_num_pages = 1;
+	qp->orq = dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+				     RDMA_RING_PAGE_SIZE,
+				     &qp->orq_phys_addr, GFP_KERNEL);
+	if (!qp->orq) {
+		rc = -ENOMEM;
+		DP_NOTICE(p_hwfn,
+			  "qed create requester failed: cannot allocate memory (orq). rc = %d\n",
+			  rc);
+		return rc;
+	}
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qp->icid + 1;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 ROCE_RAMROD_CREATE_QP,
+				 PROTOCOLID_ROCE, &init_data);
+	if (rc)
+		goto err;
+
+	p_ramrod = &p_ent->ramrod.roce_create_qp_req;
+
+	p_ramrod->flags = 0;
+
+	roce_flavor = qed_roce_mode_to_flavor(qp->roce_mode);
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_REQ_RAMROD_DATA_ROCE_FLAVOR, roce_flavor);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_REQ_RAMROD_DATA_FMR_AND_RESERVED_EN,
+		  qp->fmr_and_reserved_lkey);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_REQ_RAMROD_DATA_SIGNALED_COMP, qp->signal_all);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_REQ_RAMROD_DATA_ERR_RETRY_CNT, qp->retry_cnt);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_REQ_RAMROD_DATA_RNR_NAK_CNT,
+		  qp->rnr_retry_cnt);
+
+	p_ramrod->max_ord = qp->max_rd_atomic_req;
+	p_ramrod->traffic_class = qp->traffic_class_tos;
+	p_ramrod->hop_limit = qp->hop_limit_ttl;
+	p_ramrod->orq_num_pages = qp->orq_num_pages;
+	p_ramrod->p_key = cpu_to_le16(qp->pkey);
+	p_ramrod->flow_label = cpu_to_le32(qp->flow_label);
+	p_ramrod->dst_qp_id = cpu_to_le32(qp->dest_qp);
+	p_ramrod->ack_timeout_val = cpu_to_le32(qp->ack_timeout);
+	p_ramrod->mtu = cpu_to_le16(qp->mtu);
+	p_ramrod->initial_psn = cpu_to_le32(qp->sq_psn);
+	p_ramrod->pd = cpu_to_le16(qp->pd);
+	p_ramrod->sq_num_pages = cpu_to_le16(qp->sq_num_pages);
+	p_ramrod->sq_pbl_addr.hi = DMA_HI_LE(qp->sq_pbl_ptr);
+	p_ramrod->sq_pbl_addr.lo = DMA_LO_LE(qp->sq_pbl_ptr);
+	p_ramrod->orq_pbl_addr.hi = DMA_HI_LE(qp->orq_phys_addr);
+	p_ramrod->orq_pbl_addr.lo = DMA_LO_LE(qp->orq_phys_addr);
+	qed_rdma_copy_gids(qp, p_ramrod->src_gid, p_ramrod->dst_gid);
+	p_ramrod->qp_handle_for_async.hi = cpu_to_le32(qp->qp_handle_async.hi);
+	p_ramrod->qp_handle_for_async.lo = cpu_to_le32(qp->qp_handle_async.lo);
+	p_ramrod->qp_handle_for_cqe.hi = cpu_to_le32(qp->qp_handle.hi);
+	p_ramrod->qp_handle_for_cqe.lo = cpu_to_le32(qp->qp_handle.lo);
+	p_ramrod->stats_counter_id = p_hwfn->rel_pf_id;
+	p_ramrod->cq_cid = cpu_to_le32((p_hwfn->hw_info.opaque_fid << 16) |
+				       qp->sq_cq_id);
+
+	memset(&qm_params, 0, sizeof(qm_params));
+	qm_params.roce.qpid = (qp->icid >> 1);
+	physical_queue0 = qed_get_qm_pq(p_hwfn, PROTOCOLID_ROCE, &qm_params);
+
+	p_ramrod->physical_queue0 = cpu_to_le16(physical_queue0);
+	p_ramrod->dpi = cpu_to_le16(qp->dpi);
+
+	qed_rdma_set_fw_mac(p_ramrod->remote_mac_addr, qp->remote_mac_addr);
+	qed_rdma_set_fw_mac(p_ramrod->local_mac_addr, qp->local_mac_addr);
+
+	p_ramrod->udp_src_port = qp->udp_src_port;
+	p_ramrod->vlan_id = cpu_to_le16(qp->vlan_id);
+	p_ramrod->stats_counter_id = RESC_START(p_hwfn, QED_RDMA_STATS_QUEUE) +
+				     qp->stats_queue;
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "rc = %d\n", rc);
+
+	if (rc)
+		goto err;
+
+	qp->req_offloaded = true;
+
+	return rc;
+
+err:
+	DP_NOTICE(p_hwfn, "Create requested - failed, rc = %d\n", rc);
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  qp->orq_num_pages * RDMA_RING_PAGE_SIZE,
+			  qp->orq, qp->orq_phys_addr);
+	return rc;
+}
+
+static int qed_roce_sp_modify_responder(struct qed_hwfn *p_hwfn,
+					struct qed_rdma_qp *qp,
+					bool move_to_err, u32 modify_flags)
+{
+	struct roce_modify_qp_resp_ramrod_data *p_ramrod;
+	struct qed_sp_init_data init_data;
+	struct qed_spq_entry *p_ent;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", qp->icid);
+
+	if (move_to_err && !qp->resp_offloaded)
+		return 0;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qp->icid;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 ROCE_EVENT_MODIFY_QP,
+				 PROTOCOLID_ROCE, &init_data);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "rc = %d\n", rc);
+		return rc;
+	}
+
+	p_ramrod = &p_ent->ramrod.roce_modify_qp_resp;
+
+	p_ramrod->flags = 0;
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_RESP_RAMROD_DATA_MOVE_TO_ERR_FLG, move_to_err);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_RESP_RAMROD_DATA_RDMA_RD_EN,
+		  qp->incoming_rdma_read_en);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_RESP_RAMROD_DATA_RDMA_WR_EN,
+		  qp->incoming_rdma_write_en);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_RESP_RAMROD_DATA_ATOMIC_EN,
+		  qp->incoming_atomic_en);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_CREATE_QP_RESP_RAMROD_DATA_E2E_FLOW_CONTROL_EN,
+		  qp->e2e_flow_control_en);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_RESP_RAMROD_DATA_RDMA_OPS_EN_FLG,
+		  GET_FIELD(modify_flags,
+			    QED_RDMA_MODIFY_QP_VALID_RDMA_OPS_EN));
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_RESP_RAMROD_DATA_P_KEY_FLG,
+		  GET_FIELD(modify_flags, QED_ROCE_MODIFY_QP_VALID_PKEY));
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_RESP_RAMROD_DATA_ADDRESS_VECTOR_FLG,
+		  GET_FIELD(modify_flags,
+			    QED_ROCE_MODIFY_QP_VALID_ADDRESS_VECTOR));
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_RESP_RAMROD_DATA_MAX_IRD_FLG,
+		  GET_FIELD(modify_flags,
+			    QED_RDMA_MODIFY_QP_VALID_MAX_RD_ATOMIC_RESP));
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_RESP_RAMROD_DATA_MIN_RNR_NAK_TIMER_FLG,
+		  GET_FIELD(modify_flags,
+			    QED_ROCE_MODIFY_QP_VALID_MIN_RNR_NAK_TIMER));
+
+	p_ramrod->fields = 0;
+	SET_FIELD(p_ramrod->fields,
+		  ROCE_MODIFY_QP_RESP_RAMROD_DATA_MIN_RNR_NAK_TIMER,
+		  qp->min_rnr_nak_timer);
+
+	p_ramrod->max_ird = qp->max_rd_atomic_resp;
+	p_ramrod->traffic_class = qp->traffic_class_tos;
+	p_ramrod->hop_limit = qp->hop_limit_ttl;
+	p_ramrod->p_key = cpu_to_le16(qp->pkey);
+	p_ramrod->flow_label = cpu_to_le32(qp->flow_label);
+	p_ramrod->mtu = cpu_to_le16(qp->mtu);
+	qed_rdma_copy_gids(qp, p_ramrod->src_gid, p_ramrod->dst_gid);
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Modify responder, rc = %d\n", rc);
+	return rc;
+}
+
+static int qed_roce_sp_modify_requester(struct qed_hwfn *p_hwfn,
+					struct qed_rdma_qp *qp,
+					bool move_to_sqd,
+					bool move_to_err, u32 modify_flags)
+{
+	struct roce_modify_qp_req_ramrod_data *p_ramrod;
+	struct qed_sp_init_data init_data;
+	struct qed_spq_entry *p_ent;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", qp->icid);
+
+	if (move_to_err && !(qp->req_offloaded))
+		return 0;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qp->icid + 1;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 ROCE_EVENT_MODIFY_QP,
+				 PROTOCOLID_ROCE, &init_data);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "rc = %d\n", rc);
+		return rc;
+	}
+
+	p_ramrod = &p_ent->ramrod.roce_modify_qp_req;
+
+	p_ramrod->flags = 0;
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_REQ_RAMROD_DATA_MOVE_TO_ERR_FLG, move_to_err);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_REQ_RAMROD_DATA_MOVE_TO_SQD_FLG, move_to_sqd);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_REQ_RAMROD_DATA_EN_SQD_ASYNC_NOTIFY,
+		  qp->sqd_async);
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_REQ_RAMROD_DATA_P_KEY_FLG,
+		  GET_FIELD(modify_flags, QED_ROCE_MODIFY_QP_VALID_PKEY));
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_REQ_RAMROD_DATA_ADDRESS_VECTOR_FLG,
+		  GET_FIELD(modify_flags,
+			    QED_ROCE_MODIFY_QP_VALID_ADDRESS_VECTOR));
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_REQ_RAMROD_DATA_MAX_ORD_FLG,
+		  GET_FIELD(modify_flags,
+			    QED_RDMA_MODIFY_QP_VALID_MAX_RD_ATOMIC_REQ));
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_REQ_RAMROD_DATA_RNR_NAK_CNT_FLG,
+		  GET_FIELD(modify_flags,
+			    QED_ROCE_MODIFY_QP_VALID_RNR_RETRY_CNT));
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_REQ_RAMROD_DATA_ERR_RETRY_CNT_FLG,
+		  GET_FIELD(modify_flags, QED_ROCE_MODIFY_QP_VALID_RETRY_CNT));
+
+	SET_FIELD(p_ramrod->flags,
+		  ROCE_MODIFY_QP_REQ_RAMROD_DATA_ACK_TIMEOUT_FLG,
+		  GET_FIELD(modify_flags,
+			    QED_ROCE_MODIFY_QP_VALID_ACK_TIMEOUT));
+
+	p_ramrod->fields = 0;
+	SET_FIELD(p_ramrod->fields,
+		  ROCE_MODIFY_QP_REQ_RAMROD_DATA_ERR_RETRY_CNT, qp->retry_cnt);
+
+	SET_FIELD(p_ramrod->fields,
+		  ROCE_MODIFY_QP_REQ_RAMROD_DATA_RNR_NAK_CNT,
+		  qp->rnr_retry_cnt);
+
+	p_ramrod->max_ord = qp->max_rd_atomic_req;
+	p_ramrod->traffic_class = qp->traffic_class_tos;
+	p_ramrod->hop_limit = qp->hop_limit_ttl;
+	p_ramrod->p_key = cpu_to_le16(qp->pkey);
+	p_ramrod->flow_label = cpu_to_le32(qp->flow_label);
+	p_ramrod->ack_timeout_val = cpu_to_le32(qp->ack_timeout);
+	p_ramrod->mtu = cpu_to_le16(qp->mtu);
+	qed_rdma_copy_gids(qp, p_ramrod->src_gid, p_ramrod->dst_gid);
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Modify requester, rc = %d\n", rc);
+	return rc;
+}
+
+static int qed_roce_sp_destroy_qp_responder(struct qed_hwfn *p_hwfn,
+					    struct qed_rdma_qp *qp,
+					    u32 *num_invalidated_mw)
+{
+	struct roce_destroy_qp_resp_output_params *p_ramrod_res;
+	struct roce_destroy_qp_resp_ramrod_data *p_ramrod;
+	struct qed_sp_init_data init_data;
+	struct qed_spq_entry *p_ent;
+	dma_addr_t ramrod_res_phys;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", qp->icid);
+
+	if (!qp->resp_offloaded)
+		return 0;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qp->icid;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 ROCE_RAMROD_DESTROY_QP,
+				 PROTOCOLID_ROCE, &init_data);
+	if (rc)
+		return rc;
+
+	p_ramrod = &p_ent->ramrod.roce_destroy_qp_resp;
+
+	p_ramrod_res = (struct roce_destroy_qp_resp_output_params *)
+	    dma_alloc_coherent(&p_hwfn->cdev->pdev->dev, sizeof(*p_ramrod_res),
+			       &ramrod_res_phys, GFP_KERNEL);
+
+	if (!p_ramrod_res) {
+		rc = -ENOMEM;
+		DP_NOTICE(p_hwfn,
+			  "qed destroy responder failed: cannot allocate memory (ramrod). rc = %d\n",
+			  rc);
+		return rc;
+	}
+
+	DMA_REGPAIR_LE(p_ramrod->output_params_addr, ramrod_res_phys);
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+	if (rc)
+		goto err;
+
+	*num_invalidated_mw = le32_to_cpu(p_ramrod_res->num_invalidated_mw);
+
+	/* Free IRQ - only if ramrod succeeded, in case FW is still using it */
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  qp->irq_num_pages * RDMA_RING_PAGE_SIZE,
+			  qp->irq, qp->irq_phys_addr);
+
+	qp->resp_offloaded = false;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Destroy responder, rc = %d\n", rc);
+
+err:
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  sizeof(struct roce_destroy_qp_resp_output_params),
+			  p_ramrod_res, ramrod_res_phys);
+
+	return rc;
+}
+
+static int qed_roce_sp_destroy_qp_requester(struct qed_hwfn *p_hwfn,
+					    struct qed_rdma_qp *qp,
+					    u32 *num_bound_mw)
+{
+	struct roce_destroy_qp_req_output_params *p_ramrod_res;
+	struct roce_destroy_qp_req_ramrod_data *p_ramrod;
+	struct qed_sp_init_data init_data;
+	struct qed_spq_entry *p_ent;
+	dma_addr_t ramrod_res_phys;
+	int rc = -ENOMEM;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", qp->icid);
+
+	if (!qp->req_offloaded)
+		return 0;
+
+	p_ramrod_res = (struct roce_destroy_qp_req_output_params *)
+		       dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+					  sizeof(*p_ramrod_res),
+					  &ramrod_res_phys, GFP_KERNEL);
+	if (!p_ramrod_res) {
+		DP_NOTICE(p_hwfn,
+			  "qed destroy requester failed: cannot allocate memory (ramrod)\n");
+		return rc;
+	}
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qp->icid + 1;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent, ROCE_RAMROD_DESTROY_QP,
+				 PROTOCOLID_ROCE, &init_data);
+	if (rc)
+		goto err;
+
+	p_ramrod = &p_ent->ramrod.roce_destroy_qp_req;
+	p_ramrod->output_params_addr.hi = DMA_HI_LE(ramrod_res_phys);
+	p_ramrod->output_params_addr.lo = DMA_LO_LE(ramrod_res_phys);
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+	if (rc)
+		goto err;
+
+	*num_bound_mw = le32_to_cpu(p_ramrod_res->num_bound_mw);
+
+	/* Free ORQ - only if ramrod succeeded, in case FW is still using it */
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+			  qp->orq_num_pages * RDMA_RING_PAGE_SIZE,
+			  qp->orq, qp->orq_phys_addr);
+
+	qp->req_offloaded = false;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Destroy requester, rc = %d\n", rc);
+
+err:
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev, sizeof(*p_ramrod_res),
+			  p_ramrod_res, ramrod_res_phys);
+
+	return rc;
+}
+
+int qed_roce_query_qp(struct qed_hwfn *p_hwfn,
+		      struct qed_rdma_qp *qp,
+		      struct qed_rdma_query_qp_out_params *out_params)
+{
+	struct roce_query_qp_resp_output_params *p_resp_ramrod_res;
+	struct roce_query_qp_req_output_params *p_req_ramrod_res;
+	struct roce_query_qp_resp_ramrod_data *p_resp_ramrod;
+	struct roce_query_qp_req_ramrod_data *p_req_ramrod;
+	struct qed_sp_init_data init_data;
+	dma_addr_t resp_ramrod_res_phys;
+	dma_addr_t req_ramrod_res_phys;
+	struct qed_spq_entry *p_ent;
+	bool rq_err_state;
+	bool sq_err_state;
+	bool sq_draining;
+	int rc = -ENOMEM;
+
+	if ((!(qp->resp_offloaded)) && (!(qp->req_offloaded))) {
+		/* We can't send ramrod to the fw since this qp wasn't offloaded
+		 * to the fw yet
+		 */
+		out_params->draining = false;
+		out_params->rq_psn = qp->rq_psn;
+		out_params->sq_psn = qp->sq_psn;
+		out_params->state = qp->cur_state;
+
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "No QPs as no offload\n");
+		return 0;
+	}
+
+	if (!(qp->resp_offloaded)) {
+		DP_NOTICE(p_hwfn,
+			  "The responder's qp should be offloded before requester's\n");
+		return -EINVAL;
+	}
+
+	/* Send a query responder ramrod to FW to get RQ-PSN and state */
+	p_resp_ramrod_res = (struct roce_query_qp_resp_output_params *)
+	    dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+			       sizeof(*p_resp_ramrod_res),
+			       &resp_ramrod_res_phys, GFP_KERNEL);
+	if (!p_resp_ramrod_res) {
+		DP_NOTICE(p_hwfn,
+			  "qed query qp failed: cannot allocate memory (ramrod)\n");
+		return rc;
+	}
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qp->icid;
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+	rc = qed_sp_init_request(p_hwfn, &p_ent, ROCE_RAMROD_QUERY_QP,
+				 PROTOCOLID_ROCE, &init_data);
+	if (rc)
+		goto err_resp;
+
+	p_resp_ramrod = &p_ent->ramrod.roce_query_qp_resp;
+	p_resp_ramrod->output_params_addr.hi = DMA_HI_LE(resp_ramrod_res_phys);
+	p_resp_ramrod->output_params_addr.lo = DMA_LO_LE(resp_ramrod_res_phys);
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+	if (rc)
+		goto err_resp;
+
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev, sizeof(*p_resp_ramrod_res),
+			  p_resp_ramrod_res, resp_ramrod_res_phys);
+
+	out_params->rq_psn = le32_to_cpu(p_resp_ramrod_res->psn);
+	rq_err_state = GET_FIELD(le32_to_cpu(p_resp_ramrod_res->err_flag),
+				 ROCE_QUERY_QP_RESP_OUTPUT_PARAMS_ERROR_FLG);
+
+	if (!(qp->req_offloaded)) {
+		/* Don't send query qp for the requester */
+		out_params->sq_psn = qp->sq_psn;
+		out_params->draining = false;
+
+		if (rq_err_state)
+			qp->cur_state = QED_ROCE_QP_STATE_ERR;
+
+		out_params->state = qp->cur_state;
+
+		return 0;
+	}
+
+	/* Send a query requester ramrod to FW to get SQ-PSN and state */
+	p_req_ramrod_res = (struct roce_query_qp_req_output_params *)
+			   dma_alloc_coherent(&p_hwfn->cdev->pdev->dev,
+					      sizeof(*p_req_ramrod_res),
+					      &req_ramrod_res_phys,
+					      GFP_KERNEL);
+	if (!p_req_ramrod_res) {
+		rc = -ENOMEM;
+		DP_NOTICE(p_hwfn,
+			  "qed query qp failed: cannot allocate memory (ramrod)\n");
+		return rc;
+	}
+
+	/* Get SPQ entry */
+	init_data.cid = qp->icid + 1;
+	rc = qed_sp_init_request(p_hwfn, &p_ent, ROCE_RAMROD_QUERY_QP,
+				 PROTOCOLID_ROCE, &init_data);
+	if (rc)
+		goto err_req;
+
+	p_req_ramrod = &p_ent->ramrod.roce_query_qp_req;
+	p_req_ramrod->output_params_addr.hi = DMA_HI_LE(req_ramrod_res_phys);
+	p_req_ramrod->output_params_addr.lo = DMA_LO_LE(req_ramrod_res_phys);
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+	if (rc)
+		goto err_req;
+
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev, sizeof(*p_req_ramrod_res),
+			  p_req_ramrod_res, req_ramrod_res_phys);
+
+	out_params->sq_psn = le32_to_cpu(p_req_ramrod_res->psn);
+	sq_err_state = GET_FIELD(le32_to_cpu(p_req_ramrod_res->flags),
+				 ROCE_QUERY_QP_REQ_OUTPUT_PARAMS_ERR_FLG);
+	sq_draining =
+		GET_FIELD(le32_to_cpu(p_req_ramrod_res->flags),
+			  ROCE_QUERY_QP_REQ_OUTPUT_PARAMS_SQ_DRAINING_FLG);
+
+	out_params->draining = false;
+
+	if (rq_err_state)
+		qp->cur_state = QED_ROCE_QP_STATE_ERR;
+	else if (sq_err_state)
+		qp->cur_state = QED_ROCE_QP_STATE_SQE;
+	else if (sq_draining)
+		out_params->draining = true;
+	out_params->state = qp->cur_state;
+
+	return 0;
+
+err_req:
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev, sizeof(*p_req_ramrod_res),
+			  p_req_ramrod_res, req_ramrod_res_phys);
+	return rc;
+err_resp:
+	dma_free_coherent(&p_hwfn->cdev->pdev->dev, sizeof(*p_resp_ramrod_res),
+			  p_resp_ramrod_res, resp_ramrod_res_phys);
+	return rc;
+}
+
+int qed_roce_destroy_qp(struct qed_hwfn *p_hwfn, struct qed_rdma_qp *qp)
+{
+	u32 num_invalidated_mw = 0;
+	u32 num_bound_mw = 0;
+	u32 start_cid;
+	int rc;
+
+	/* Destroys the specified QP */
+	if ((qp->cur_state != QED_ROCE_QP_STATE_RESET) &&
+	    (qp->cur_state != QED_ROCE_QP_STATE_ERR) &&
+	    (qp->cur_state != QED_ROCE_QP_STATE_INIT)) {
+		DP_NOTICE(p_hwfn,
+			  "QP must be in error, reset or init state before destroying it\n");
+		return -EINVAL;
+	}
+
+	rc = qed_roce_sp_destroy_qp_responder(p_hwfn, qp, &num_invalidated_mw);
+	if (rc)
+		return rc;
+
+	/* Send destroy requester ramrod */
+	rc = qed_roce_sp_destroy_qp_requester(p_hwfn, qp, &num_bound_mw);
+	if (rc)
+		return rc;
+
+	if (num_invalidated_mw != num_bound_mw) {
+		DP_NOTICE(p_hwfn,
+			  "number of invalidate memory windows is different from bounded ones\n");
+		return -EINVAL;
+	}
+
+	spin_lock_bh(&p_hwfn->p_rdma_info->lock);
+
+	start_cid = qed_cxt_get_proto_cid_start(p_hwfn,
+						p_hwfn->p_rdma_info->proto);
+
+	/* Release responder's icid */
+	qed_bmap_release_id(p_hwfn, &p_hwfn->p_rdma_info->cid_map,
+			    qp->icid - start_cid);
+
+	/* Release requester's icid */
+	qed_bmap_release_id(p_hwfn, &p_hwfn->p_rdma_info->cid_map,
+			    qp->icid + 1 - start_cid);
+
+	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
+
+	return 0;
+}
+
+int qed_rdma_query_qp(void *rdma_cxt,
+		      struct qed_rdma_qp *qp,
+		      struct qed_rdma_query_qp_out_params *out_params)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", qp->icid);
+
+	/* The following fields are filled in from qp and not FW as they can't
+	 * be modified by FW
+	 */
+	out_params->mtu = qp->mtu;
+	out_params->dest_qp = qp->dest_qp;
+	out_params->incoming_atomic_en = qp->incoming_atomic_en;
+	out_params->e2e_flow_control_en = qp->e2e_flow_control_en;
+	out_params->incoming_rdma_read_en = qp->incoming_rdma_read_en;
+	out_params->incoming_rdma_write_en = qp->incoming_rdma_write_en;
+	out_params->dgid = qp->dgid;
+	out_params->flow_label = qp->flow_label;
+	out_params->hop_limit_ttl = qp->hop_limit_ttl;
+	out_params->traffic_class_tos = qp->traffic_class_tos;
+	out_params->timeout = qp->ack_timeout;
+	out_params->rnr_retry = qp->rnr_retry_cnt;
+	out_params->retry_cnt = qp->retry_cnt;
+	out_params->min_rnr_nak_timer = qp->min_rnr_nak_timer;
+	out_params->pkey_index = 0;
+	out_params->max_rd_atomic = qp->max_rd_atomic_req;
+	out_params->max_dest_rd_atomic = qp->max_rd_atomic_resp;
+	out_params->sqd_async = qp->sqd_async;
+
+	rc = qed_roce_query_qp(p_hwfn, qp, out_params);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Query QP, rc = %d\n", rc);
+	return rc;
+}
+
+int qed_rdma_destroy_qp(void *rdma_cxt, struct qed_rdma_qp *qp)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	int rc = 0;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", qp->icid);
+
+	rc = qed_roce_destroy_qp(p_hwfn, qp);
+
+	/* free qp params struct */
+	kfree(qp);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "QP destroyed\n");
+	return rc;
+}
+
+struct qed_rdma_qp *
+qed_rdma_create_qp(void *rdma_cxt,
+		   struct qed_rdma_create_qp_in_params *in_params,
+		   struct qed_rdma_create_qp_out_params *out_params)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	struct qed_rdma_qp *qp;
+	u8 max_stats_queues;
+	int rc;
+
+	if (!rdma_cxt || !in_params || !out_params || !p_hwfn->p_rdma_info) {
+		DP_ERR(p_hwfn->cdev,
+		       "qed roce create qp failed due to NULL entry (rdma_cxt=%p, in=%p, out=%p, roce_info=?\n",
+		       rdma_cxt, in_params, out_params);
+		return NULL;
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+		   "qed rdma create qp called with qp_handle = %08x%08x\n",
+		   in_params->qp_handle_hi, in_params->qp_handle_lo);
+
+	/* Some sanity checks... */
+	max_stats_queues = p_hwfn->p_rdma_info->dev->max_stats_queues;
+	if (in_params->stats_queue >= max_stats_queues) {
+		DP_ERR(p_hwfn->cdev,
+		       "qed rdma create qp failed due to invalid statistics queue %d. maximum is %d\n",
+		       in_params->stats_queue, max_stats_queues);
+		return NULL;
+	}
+
+	qp = kzalloc(sizeof(*qp), GFP_KERNEL);
+	if (!qp) {
+		DP_NOTICE(p_hwfn, "Failed to allocate qed_rdma_qp\n");
+		return NULL;
+	}
+
+	rc = qed_roce_alloc_cid(p_hwfn, &qp->icid);
+	qp->qpid = ((0xFF << 16) | qp->icid);
+
+	DP_INFO(p_hwfn, "ROCE qpid=%x\n", qp->qpid);
+
+	if (rc) {
+		kfree(qp);
+		return NULL;
+	}
+
+	qp->cur_state = QED_ROCE_QP_STATE_RESET;
+	qp->qp_handle.hi = cpu_to_le32(in_params->qp_handle_hi);
+	qp->qp_handle.lo = cpu_to_le32(in_params->qp_handle_lo);
+	qp->qp_handle_async.hi = cpu_to_le32(in_params->qp_handle_async_hi);
+	qp->qp_handle_async.lo = cpu_to_le32(in_params->qp_handle_async_lo);
+	qp->use_srq = in_params->use_srq;
+	qp->signal_all = in_params->signal_all;
+	qp->fmr_and_reserved_lkey = in_params->fmr_and_reserved_lkey;
+	qp->pd = in_params->pd;
+	qp->dpi = in_params->dpi;
+	qp->sq_cq_id = in_params->sq_cq_id;
+	qp->sq_num_pages = in_params->sq_num_pages;
+	qp->sq_pbl_ptr = in_params->sq_pbl_ptr;
+	qp->rq_cq_id = in_params->rq_cq_id;
+	qp->rq_num_pages = in_params->rq_num_pages;
+	qp->rq_pbl_ptr = in_params->rq_pbl_ptr;
+	qp->srq_id = in_params->srq_id;
+	qp->req_offloaded = false;
+	qp->resp_offloaded = false;
+	/* e2e_flow_control cannot be done in case of S-RQ.
+	 * Refer to 9.7.7.2 End-to-End Flow Control section of IB spec
+	 */
+	qp->e2e_flow_control_en = qp->use_srq ? false : true;
+	qp->stats_queue = in_params->stats_queue;
+
+	out_params->icid = qp->icid;
+	out_params->qp_id = qp->qpid;
+
+	/* max_sq_sges future use only */
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Create QP, rc = %d\n", rc);
+	return qp;
+}
+
+static int qed_roce_modify_qp(struct qed_hwfn *p_hwfn,
+			      struct qed_rdma_qp *qp,
+			      enum qed_roce_qp_state prev_state,
+			      struct qed_rdma_modify_qp_in_params *params)
+{
+	u32 num_invalidated_mw = 0, num_bound_mw = 0;
+	int rc = 0;
+
+	/* Perform additional operations according to the current state and the
+	 * next state
+	 */
+	if (((prev_state == QED_ROCE_QP_STATE_INIT) ||
+	     (prev_state == QED_ROCE_QP_STATE_RESET)) &&
+	    (qp->cur_state == QED_ROCE_QP_STATE_RTR)) {
+		/* Init->RTR or Reset->RTR */
+		rc = qed_roce_sp_create_responder(p_hwfn, qp);
+		return rc;
+	} else if ((prev_state == QED_ROCE_QP_STATE_RTR) &&
+		   (qp->cur_state == QED_ROCE_QP_STATE_RTS)) {
+		/* RTR-> RTS */
+		rc = qed_roce_sp_create_requester(p_hwfn, qp);
+		if (rc)
+			return rc;
+
+		/* Send modify responder ramrod */
+		rc = qed_roce_sp_modify_responder(p_hwfn, qp, false,
+						  params->modify_flags);
+		return rc;
+	} else if ((prev_state == QED_ROCE_QP_STATE_RTS) &&
+		   (qp->cur_state == QED_ROCE_QP_STATE_RTS)) {
+		/* RTS->RTS */
+		rc = qed_roce_sp_modify_responder(p_hwfn, qp, false,
+						  params->modify_flags);
+		if (rc)
+			return rc;
+
+		rc = qed_roce_sp_modify_requester(p_hwfn, qp, false, false,
+						  params->modify_flags);
+		return rc;
+	} else if ((prev_state == QED_ROCE_QP_STATE_RTS) &&
+		   (qp->cur_state == QED_ROCE_QP_STATE_SQD)) {
+		/* RTS->SQD */
+		rc = qed_roce_sp_modify_requester(p_hwfn, qp, true, false,
+						  params->modify_flags);
+		return rc;
+	} else if ((prev_state == QED_ROCE_QP_STATE_SQD) &&
+		   (qp->cur_state == QED_ROCE_QP_STATE_SQD)) {
+		/* SQD->SQD */
+		rc = qed_roce_sp_modify_responder(p_hwfn, qp, false,
+						  params->modify_flags);
+		if (rc)
+			return rc;
+
+		rc = qed_roce_sp_modify_requester(p_hwfn, qp, false, false,
+						  params->modify_flags);
+		return rc;
+	} else if ((prev_state == QED_ROCE_QP_STATE_SQD) &&
+		   (qp->cur_state == QED_ROCE_QP_STATE_RTS)) {
+		/* SQD->RTS */
+		rc = qed_roce_sp_modify_responder(p_hwfn, qp, false,
+						  params->modify_flags);
+		if (rc)
+			return rc;
+
+		rc = qed_roce_sp_modify_requester(p_hwfn, qp, false, false,
+						  params->modify_flags);
+
+		return rc;
+	} else if (qp->cur_state == QED_ROCE_QP_STATE_ERR ||
+		   qp->cur_state == QED_ROCE_QP_STATE_SQE) {
+		/* ->ERR */
+		rc = qed_roce_sp_modify_responder(p_hwfn, qp, true,
+						  params->modify_flags);
+		if (rc)
+			return rc;
+
+		rc = qed_roce_sp_modify_requester(p_hwfn, qp, false, true,
+						  params->modify_flags);
+		return rc;
+	} else if (qp->cur_state == QED_ROCE_QP_STATE_RESET) {
+		/* Any state -> RESET */
+
+		rc = qed_roce_sp_destroy_qp_responder(p_hwfn, qp,
+						      &num_invalidated_mw);
+		if (rc)
+			return rc;
+
+		rc = qed_roce_sp_destroy_qp_requester(p_hwfn, qp,
+						      &num_bound_mw);
+
+		if (num_invalidated_mw != num_bound_mw) {
+			DP_NOTICE(p_hwfn,
+				  "number of invalidate memory windows is different from bounded ones\n");
+			return -EINVAL;
+		}
+	} else {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "0\n");
+	}
+
+	return rc;
+}
+
+int qed_rdma_modify_qp(void *rdma_cxt,
+		       struct qed_rdma_qp *qp,
+		       struct qed_rdma_modify_qp_in_params *params)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	enum qed_roce_qp_state prev_state;
+	int rc = 0;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x params->new_state=%d\n",
+		   qp->icid, params->new_state);
+
+	if (rc) {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "rc = %d\n", rc);
+		return rc;
+	}
+
+	if (GET_FIELD(params->modify_flags,
+		      QED_RDMA_MODIFY_QP_VALID_RDMA_OPS_EN)) {
+		qp->incoming_rdma_read_en = params->incoming_rdma_read_en;
+		qp->incoming_rdma_write_en = params->incoming_rdma_write_en;
+		qp->incoming_atomic_en = params->incoming_atomic_en;
+	}
+
+	/* Update QP structure with the updated values */
+	if (GET_FIELD(params->modify_flags, QED_ROCE_MODIFY_QP_VALID_ROCE_MODE))
+		qp->roce_mode = params->roce_mode;
+	if (GET_FIELD(params->modify_flags, QED_ROCE_MODIFY_QP_VALID_PKEY))
+		qp->pkey = params->pkey;
+	if (GET_FIELD(params->modify_flags,
+		      QED_ROCE_MODIFY_QP_VALID_E2E_FLOW_CONTROL_EN))
+		qp->e2e_flow_control_en = params->e2e_flow_control_en;
+	if (GET_FIELD(params->modify_flags, QED_ROCE_MODIFY_QP_VALID_DEST_QP))
+		qp->dest_qp = params->dest_qp;
+	if (GET_FIELD(params->modify_flags,
+		      QED_ROCE_MODIFY_QP_VALID_ADDRESS_VECTOR)) {
+		/* Indicates that the following parameters have changed:
+		 * Traffic class, flow label, hop limit, source GID,
+		 * destination GID, loopback indicator
+		 */
+		qp->traffic_class_tos = params->traffic_class_tos;
+		qp->flow_label = params->flow_label;
+		qp->hop_limit_ttl = params->hop_limit_ttl;
+
+		qp->sgid = params->sgid;
+		qp->dgid = params->dgid;
+		qp->udp_src_port = 0;
+		qp->vlan_id = params->vlan_id;
+		qp->mtu = params->mtu;
+		qp->lb_indication = params->lb_indication;
+		memcpy((u8 *)&qp->remote_mac_addr[0],
+		       (u8 *)&params->remote_mac_addr[0], ETH_ALEN);
+		if (params->use_local_mac) {
+			memcpy((u8 *)&qp->local_mac_addr[0],
+			       (u8 *)&params->local_mac_addr[0], ETH_ALEN);
+		} else {
+			memcpy((u8 *)&qp->local_mac_addr[0],
+			       (u8 *)&p_hwfn->hw_info.hw_mac_addr, ETH_ALEN);
+		}
+	}
+	if (GET_FIELD(params->modify_flags, QED_ROCE_MODIFY_QP_VALID_RQ_PSN))
+		qp->rq_psn = params->rq_psn;
+	if (GET_FIELD(params->modify_flags, QED_ROCE_MODIFY_QP_VALID_SQ_PSN))
+		qp->sq_psn = params->sq_psn;
+	if (GET_FIELD(params->modify_flags,
+		      QED_RDMA_MODIFY_QP_VALID_MAX_RD_ATOMIC_REQ))
+		qp->max_rd_atomic_req = params->max_rd_atomic_req;
+	if (GET_FIELD(params->modify_flags,
+		      QED_RDMA_MODIFY_QP_VALID_MAX_RD_ATOMIC_RESP))
+		qp->max_rd_atomic_resp = params->max_rd_atomic_resp;
+	if (GET_FIELD(params->modify_flags,
+		      QED_ROCE_MODIFY_QP_VALID_ACK_TIMEOUT))
+		qp->ack_timeout = params->ack_timeout;
+	if (GET_FIELD(params->modify_flags, QED_ROCE_MODIFY_QP_VALID_RETRY_CNT))
+		qp->retry_cnt = params->retry_cnt;
+	if (GET_FIELD(params->modify_flags,
+		      QED_ROCE_MODIFY_QP_VALID_RNR_RETRY_CNT))
+		qp->rnr_retry_cnt = params->rnr_retry_cnt;
+	if (GET_FIELD(params->modify_flags,
+		      QED_ROCE_MODIFY_QP_VALID_MIN_RNR_NAK_TIMER))
+		qp->min_rnr_nak_timer = params->min_rnr_nak_timer;
+
+	qp->sqd_async = params->sqd_async;
+
+	prev_state = qp->cur_state;
+	if (GET_FIELD(params->modify_flags,
+		      QED_RDMA_MODIFY_QP_VALID_NEW_STATE)) {
+		qp->cur_state = params->new_state;
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "qp->cur_state=%d\n",
+			   qp->cur_state);
+	}
+
+	rc = qed_roce_modify_qp(p_hwfn, qp, prev_state, params);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Modify QP, rc = %d\n", rc);
+	return rc;
+}
+
 static void *qed_rdma_get_rdma_ctx(struct qed_dev *cdev)
 {
 	return QED_LEADING_HWFN(cdev);
@@ -1208,6 +2415,10 @@ static const struct qed_rdma_ops qed_rdma_ops_pass = {
 	.rdma_dealloc_pd = &qed_rdma_free_pd,
 	.rdma_create_cq = &qed_rdma_create_cq,
 	.rdma_destroy_cq = &qed_rdma_destroy_cq,
+	.rdma_create_qp = &qed_rdma_create_qp,
+	.rdma_modify_qp = &qed_rdma_modify_qp,
+	.rdma_query_qp = &qed_rdma_query_qp,
+	.rdma_destroy_qp = &qed_rdma_destroy_qp,
 };
 
 const struct qed_rdma_ops *qed_get_rdma_ops()
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.h b/drivers/net/ethernet/qlogic/qed/qed_roce.h
index 6802cd0..71b37fc 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.h
@@ -114,6 +114,72 @@ struct qed_rdma_resize_cnq_in_params {
 	u64 pbl_ptr;
 };
 
+struct qed_rdma_qp {
+	struct regpair qp_handle;
+	struct regpair qp_handle_async;
+	u32 qpid;
+	u16 icid;
+	enum qed_roce_qp_state cur_state;
+	bool use_srq;
+	bool signal_all;
+	bool fmr_and_reserved_lkey;
+
+	bool incoming_rdma_read_en;
+	bool incoming_rdma_write_en;
+	bool incoming_atomic_en;
+	bool e2e_flow_control_en;
+
+	u16 pd;
+	u16 pkey;
+	u32 dest_qp;
+	u16 mtu;
+	u16 srq_id;
+	u8 traffic_class_tos;
+	u8 hop_limit_ttl;
+	u16 dpi;
+	u32 flow_label;
+	bool lb_indication;
+	u16 vlan_id;
+	u32 ack_timeout;
+	u8 retry_cnt;
+	u8 rnr_retry_cnt;
+	u8 min_rnr_nak_timer;
+	bool sqd_async;
+	union qed_gid sgid;
+	union qed_gid dgid;
+	enum roce_mode roce_mode;
+	u16 udp_src_port;
+	u8 stats_queue;
+
+	/* requeseter */
+	u8 max_rd_atomic_req;
+	u32 sq_psn;
+	u16 sq_cq_id;
+	u16 sq_num_pages;
+	dma_addr_t sq_pbl_ptr;
+	void *orq;
+	dma_addr_t orq_phys_addr;
+	u8 orq_num_pages;
+	bool req_offloaded;
+
+	/* responder */
+	u8 max_rd_atomic_resp;
+	u32 rq_psn;
+	u16 rq_cq_id;
+	u16 rq_num_pages;
+	dma_addr_t rq_pbl_ptr;
+	void *irq;
+	dma_addr_t irq_phys_addr;
+	u8 irq_num_pages;
+	bool resp_offloaded;
+
+	u8 remote_mac_addr[6];
+	u8 local_mac_addr[6];
+
+	void *shared_queue;
+	dma_addr_t shared_queue_phys_addr;
+};
+
 int
 qed_rdma_add_user(void *rdma_cxt,
 		  struct qed_rdma_add_user_out_params *out_params);
@@ -135,4 +201,9 @@ void qed_rdma_cnq_prod_update(void *rdma_cxt, u8 cnq_index, u16 prod);
 void qed_rdma_resc_free(struct qed_hwfn *p_hwfn);
 void qed_async_roce_event(struct qed_hwfn *p_hwfn,
 			  struct event_ring_entry *p_eqe);
+int qed_rdma_destroy_qp(void *rdma_cxt, struct qed_rdma_qp *qp);
+int qed_rdma_modify_qp(void *rdma_cxt, struct qed_rdma_qp *qp,
+		       struct qed_rdma_modify_qp_in_params *params);
+int qed_rdma_query_qp(void *rdma_cxt, struct qed_rdma_qp *qp,
+		      struct qed_rdma_query_qp_out_params *out_params);
 #endif
diff --git a/include/linux/qed/qed_roce_if.h b/include/linux/qed/qed_roce_if.h
index b559b1c..02321e3 100644
--- a/include/linux/qed/qed_roce_if.h
+++ b/include/linux/qed/qed_roce_if.h
@@ -43,6 +43,17 @@
 #define QED_RDMA_MAX_CNQ_SIZE               (0xFFFF)
 
 /* rdma interface */
+
+enum qed_roce_qp_state {
+	QED_ROCE_QP_STATE_RESET,
+	QED_ROCE_QP_STATE_INIT,
+	QED_ROCE_QP_STATE_RTR,
+	QED_ROCE_QP_STATE_RTS,
+	QED_ROCE_QP_STATE_SQD,
+	QED_ROCE_QP_STATE_ERR,
+	QED_ROCE_QP_STATE_SQE
+};
+
 enum qed_rdma_tid_type {
 	QED_RDMA_TID_REGISTERED_MR,
 	QED_RDMA_TID_FMR,
@@ -292,6 +303,128 @@ struct qed_rdma_destroy_cq_out_params {
 	u16 num_cq_notif;
 };
 
+struct qed_rdma_create_qp_in_params {
+	u32 qp_handle_lo;
+	u32 qp_handle_hi;
+	u32 qp_handle_async_lo;
+	u32 qp_handle_async_hi;
+	bool use_srq;
+	bool signal_all;
+	bool fmr_and_reserved_lkey;
+	u16 pd;
+	u16 dpi;
+	u16 sq_cq_id;
+	u16 sq_num_pages;
+	u64 sq_pbl_ptr;
+	u8 max_sq_sges;
+	u16 rq_cq_id;
+	u16 rq_num_pages;
+	u64 rq_pbl_ptr;
+	u16 srq_id;
+	u8 stats_queue;
+};
+
+struct qed_rdma_create_qp_out_params {
+	u32 qp_id;
+	u16 icid;
+	void *rq_pbl_virt;
+	dma_addr_t rq_pbl_phys;
+	void *sq_pbl_virt;
+	dma_addr_t sq_pbl_phys;
+};
+
+struct qed_rdma_modify_qp_in_params {
+	u32 modify_flags;
+#define QED_RDMA_MODIFY_QP_VALID_NEW_STATE_MASK               0x1
+#define QED_RDMA_MODIFY_QP_VALID_NEW_STATE_SHIFT              0
+#define QED_ROCE_MODIFY_QP_VALID_PKEY_MASK                    0x1
+#define QED_ROCE_MODIFY_QP_VALID_PKEY_SHIFT                   1
+#define QED_RDMA_MODIFY_QP_VALID_RDMA_OPS_EN_MASK             0x1
+#define QED_RDMA_MODIFY_QP_VALID_RDMA_OPS_EN_SHIFT            2
+#define QED_ROCE_MODIFY_QP_VALID_DEST_QP_MASK                 0x1
+#define QED_ROCE_MODIFY_QP_VALID_DEST_QP_SHIFT                3
+#define QED_ROCE_MODIFY_QP_VALID_ADDRESS_VECTOR_MASK          0x1
+#define QED_ROCE_MODIFY_QP_VALID_ADDRESS_VECTOR_SHIFT         4
+#define QED_ROCE_MODIFY_QP_VALID_RQ_PSN_MASK                  0x1
+#define QED_ROCE_MODIFY_QP_VALID_RQ_PSN_SHIFT                 5
+#define QED_ROCE_MODIFY_QP_VALID_SQ_PSN_MASK                  0x1
+#define QED_ROCE_MODIFY_QP_VALID_SQ_PSN_SHIFT                 6
+#define QED_RDMA_MODIFY_QP_VALID_MAX_RD_ATOMIC_REQ_MASK       0x1
+#define QED_RDMA_MODIFY_QP_VALID_MAX_RD_ATOMIC_REQ_SHIFT      7
+#define QED_RDMA_MODIFY_QP_VALID_MAX_RD_ATOMIC_RESP_MASK      0x1
+#define QED_RDMA_MODIFY_QP_VALID_MAX_RD_ATOMIC_RESP_SHIFT     8
+#define QED_ROCE_MODIFY_QP_VALID_ACK_TIMEOUT_MASK             0x1
+#define QED_ROCE_MODIFY_QP_VALID_ACK_TIMEOUT_SHIFT            9
+#define QED_ROCE_MODIFY_QP_VALID_RETRY_CNT_MASK               0x1
+#define QED_ROCE_MODIFY_QP_VALID_RETRY_CNT_SHIFT              10
+#define QED_ROCE_MODIFY_QP_VALID_RNR_RETRY_CNT_MASK           0x1
+#define QED_ROCE_MODIFY_QP_VALID_RNR_RETRY_CNT_SHIFT          11
+#define QED_ROCE_MODIFY_QP_VALID_MIN_RNR_NAK_TIMER_MASK       0x1
+#define QED_ROCE_MODIFY_QP_VALID_MIN_RNR_NAK_TIMER_SHIFT      12
+#define QED_ROCE_MODIFY_QP_VALID_E2E_FLOW_CONTROL_EN_MASK     0x1
+#define QED_ROCE_MODIFY_QP_VALID_E2E_FLOW_CONTROL_EN_SHIFT    13
+#define QED_ROCE_MODIFY_QP_VALID_ROCE_MODE_MASK               0x1
+#define QED_ROCE_MODIFY_QP_VALID_ROCE_MODE_SHIFT              14
+
+	enum qed_roce_qp_state new_state;
+	u16 pkey;
+	bool incoming_rdma_read_en;
+	bool incoming_rdma_write_en;
+	bool incoming_atomic_en;
+	bool e2e_flow_control_en;
+	u32 dest_qp;
+	bool lb_indication;
+	u16 mtu;
+	u8 traffic_class_tos;
+	u8 hop_limit_ttl;
+	u32 flow_label;
+	union qed_gid sgid;
+	union qed_gid dgid;
+	u16 udp_src_port;
+
+	u16 vlan_id;
+
+	u32 rq_psn;
+	u32 sq_psn;
+	u8 max_rd_atomic_resp;
+	u8 max_rd_atomic_req;
+	u32 ack_timeout;
+	u8 retry_cnt;
+	u8 rnr_retry_cnt;
+	u8 min_rnr_nak_timer;
+	bool sqd_async;
+	u8 remote_mac_addr[6];
+	u8 local_mac_addr[6];
+	bool use_local_mac;
+	enum roce_mode roce_mode;
+};
+
+struct qed_rdma_query_qp_out_params {
+	enum qed_roce_qp_state state;
+	u32 rq_psn;
+	u32 sq_psn;
+	bool draining;
+	u16 mtu;
+	u32 dest_qp;
+	bool incoming_rdma_read_en;
+	bool incoming_rdma_write_en;
+	bool incoming_atomic_en;
+	bool e2e_flow_control_en;
+	union qed_gid sgid;
+	union qed_gid dgid;
+	u32 flow_label;
+	u8 hop_limit_ttl;
+	u8 traffic_class_tos;
+	u32 timeout;
+	u8 rnr_retry;
+	u8 retry_cnt;
+	u8 min_rnr_nak_timer;
+	u16 pkey_index;
+	u8 max_rd_atomic;
+	u8 max_dest_rd_atomic;
+	bool sqd_async;
+};
+
 struct qed_rdma_create_srq_out_params {
 	u16 srq_id;
 };
@@ -368,6 +501,17 @@ struct qed_rdma_ops {
 	int (*rdma_destroy_cq)(void *rdma_cxt,
 			       struct qed_rdma_destroy_cq_in_params *iparams,
 			       struct qed_rdma_destroy_cq_out_params *oparams);
+	struct qed_rdma_qp *
+	(*rdma_create_qp)(void *rdma_cxt,
+			  struct qed_rdma_create_qp_in_params *iparams,
+			  struct qed_rdma_create_qp_out_params *oparams);
+
+	int (*rdma_modify_qp)(void *roce_cxt, struct qed_rdma_qp *qp,
+			      struct qed_rdma_modify_qp_in_params *iparams);
+
+	int (*rdma_query_qp)(void *rdma_cxt, struct qed_rdma_qp *qp,
+			     struct qed_rdma_query_qp_out_params *oparams);
+	int (*rdma_destroy_qp)(void *rdma_cxt, struct qed_rdma_qp *qp);
 };
 
 const struct qed_rdma_ops *qed_get_rdma_ops(void);
diff --git a/include/uapi/rdma/providers/qedr-abi.h b/include/uapi/rdma/providers/qedr-abi.h
index 16f3f60..187021b 100644
--- a/include/uapi/rdma/providers/qedr-abi.h
+++ b/include/uapi/rdma/providers/qedr-abi.h
@@ -43,4 +43,39 @@ struct qedr_create_cq_uresp {
        u16 icid;
 };
 
+struct qedr_create_qp_ureq {
+       u32 qp_handle_hi;
+       u32 qp_handle_lo;
+
+       /* SQ */
+       /* user space virtual address of SQ buffer */
+       u64 sq_addr;
+
+       /* length of SQ buffer */
+       size_t sq_len;
+
+       /* RQ */
+       /* user space virtual address of RQ buffer */
+       u64 rq_addr;
+
+       /* length of RQ buffer */
+       size_t rq_len;
+};
+
+struct qedr_create_qp_uresp {
+       u32 qp_id;
+       int atomic_supported;
+
+       /* SQ */
+       u32 sq_db_offset;
+       u16 sq_icid;
+
+       /* RQ */
+       u32 rq_db_offset;
+       u16 rq_icid;
+
+       u32 rq_db2_offset;
+};
+
 #endif /* __QEDR_USER_H__ */
+
-- 
1.8.3.1
