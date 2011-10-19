From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH 10/10] RDMA/cxgb4: Add query_qp support in driver to query the qp state before flushing.
Date: Wed, 19 Oct 2011 22:41:04 +0530
Message-ID: <1319044264-779-11-git-send-email-vipul@chelsio.com>
References: <1319044264-779-1-git-send-email-vipul@chelsio.com>
Cc: roland@purestorage.com, davem@davemloft.net, divy@chelsio.com,
	dm@chelsio.com, kumaras@chelsio.com, swise@opengridcomputing.com,
	Vipul Pandya <vipul@chelsio.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7965 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756923Ab1JSRNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 13:13:50 -0400
In-Reply-To: <1319044264-779-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |   19 +++++++++++++++++++
 drivers/infiniband/hw/cxgb4/provider.c |    2 ++
 drivers/infiniband/hw/cxgb4/qp.c       |   11 +++++++++++
 3 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 9e26b76..8aa1744 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -550,6 +550,23 @@ static inline int c4iw_convert_state(enum ib_qp_state ib_state)
 	}
 }
 
+static inline int to_ib_qp_state(int c4iw_qp_state)
+{
+	switch (c4iw_qp_state) {
+	case C4IW_QP_STATE_IDLE:
+		return IB_QPS_INIT;
+	case C4IW_QP_STATE_RTS:
+		return IB_QPS_RTS;
+	case C4IW_QP_STATE_CLOSING:
+		return IB_QPS_SQD;
+	case C4IW_QP_STATE_TERMINATE:
+		return IB_QPS_SQE;
+	case C4IW_QP_STATE_ERROR:
+		return IB_QPS_ERR;
+	}
+	return IB_QPS_ERR;
+}
+
 static inline u32 c4iw_ib_to_tpt_access(int a)
 {
 	return (a & IB_ACCESS_REMOTE_WRITE ? FW_RI_MEM_ACCESS_REM_WRITE : 0) |
@@ -845,6 +862,8 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd,
 			     struct ib_udata *udata);
 int c4iw_ib_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
 				 int attr_mask, struct ib_udata *udata);
+int c4iw_ib_query_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
+		     int attr_mask, struct ib_qp_init_attr *init_attr);
 struct ib_qp *c4iw_get_qp(struct ib_device *dev, int qpn);
 u32 c4iw_rqtpool_alloc(struct c4iw_rdev *rdev, int size);
 void c4iw_rqtpool_free(struct c4iw_rdev *rdev, u32 addr, int size);
diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index db1debc..3cb1128 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -443,6 +443,7 @@ int c4iw_register_device(struct c4iw_dev *dev)
 	    (1ull << IB_USER_VERBS_CMD_REQ_NOTIFY_CQ) |
 	    (1ull << IB_USER_VERBS_CMD_CREATE_QP) |
 	    (1ull << IB_USER_VERBS_CMD_MODIFY_QP) |
+	    (1ull << IB_USER_VERBS_CMD_QUERY_QP) |
 	    (1ull << IB_USER_VERBS_CMD_POLL_CQ) |
 	    (1ull << IB_USER_VERBS_CMD_DESTROY_QP) |
 	    (1ull << IB_USER_VERBS_CMD_POST_SEND) |
@@ -465,6 +466,7 @@ int c4iw_register_device(struct c4iw_dev *dev)
 	dev->ibdev.destroy_ah = c4iw_ah_destroy;
 	dev->ibdev.create_qp = c4iw_create_qp;
 	dev->ibdev.modify_qp = c4iw_ib_modify_qp;
+	dev->ibdev.query_qp = c4iw_ib_query_qp;
 	dev->ibdev.destroy_qp = c4iw_destroy_qp;
 	dev->ibdev.create_cq = c4iw_create_cq;
 	dev->ibdev.destroy_cq = c4iw_destroy_cq;
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 215b66a..a7b8713 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -1696,3 +1696,14 @@ struct ib_qp *c4iw_get_qp(struct ib_device *dev, int qpn)
 	PDBG("%s ib_dev %p qpn 0x%x\n", __func__, dev, qpn);
 	return (struct ib_qp *)get_qhp(to_c4iw_dev(dev), qpn);
 }
+
+int c4iw_ib_query_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
+		     int attr_mask, struct ib_qp_init_attr *init_attr)
+{
+	struct c4iw_qp *qhp = to_c4iw_qp(ibqp);
+
+	memset(attr, 0, sizeof *attr);
+	memset(init_attr, 0, sizeof *init_attr);
+	attr->qp_state = to_ib_qp_state(qhp->attr.state);
+	return 0;
+}
-- 
1.7.1
