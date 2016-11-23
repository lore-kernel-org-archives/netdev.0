From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V3 for-next 01/11] IB/hns: Add the interface for querying QP1
Date: Wed, 23 Nov 2016 19:40:59 +0000
Message-ID: <20161123194109.420760-2-salil.mehta@huawei.com>
References: <20161123194109.420760-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xushaobo2-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <lijun_nudt-9Onoh4P/yGk@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161123194109.420760-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

In old code, It only added the interface for querying non-specific
QP. This patch mainly adds an interface for querying QP1.

Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Reviewed-by: Wei Hu (Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Salil Mehta  <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
Change Log

Patch V2: Addressed the comment provided by Anurup M
	Link: https://patchwork.kernel.org/patch/9412855/
Patch V1: Initial Submit
---
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c |   83 +++++++++++++++++++++++++++-
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h |    6 +-
 2 files changed, 86 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 71232e5..7485514 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -2630,8 +2630,78 @@ static int hns_roce_v1_query_qpc(struct hns_roce_dev *hr_dev,
 	return ret;
 }
 
-int hns_roce_v1_query_qp(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
-			 int qp_attr_mask, struct ib_qp_init_attr *qp_init_attr)
+static int hns_roce_v1_q_sqp(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
+			     int qp_attr_mask,
+			     struct ib_qp_init_attr *qp_init_attr)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	struct hns_roce_sqp_context context;
+	u32 addr;
+
+	mutex_lock(&hr_qp->mutex);
+
+	if (hr_qp->state == IB_QPS_RESET) {
+		qp_attr->qp_state = IB_QPS_RESET;
+		goto done;
+	}
+
+	addr = ROCEE_QP1C_CFG0_0_REG + 
+		hr_qp->port * sizeof(struct hns_roce_sqp_context);
+	context.qp1c_bytes_4 = roce_read(hr_dev, addr);
+	context.sq_rq_bt_l = roce_read(hr_dev, addr + 1);
+	context.qp1c_bytes_12 = roce_read(hr_dev, addr + 2);
+	context.qp1c_bytes_16 = roce_read(hr_dev, addr + 3);
+	context.qp1c_bytes_20 = roce_read(hr_dev, addr + 4);
+	context.cur_rq_wqe_ba_l = roce_read(hr_dev, addr + 5);
+	context.qp1c_bytes_28 = roce_read(hr_dev, addr + 6);
+	context.qp1c_bytes_32 = roce_read(hr_dev, addr + 7);
+	context.cur_sq_wqe_ba_l = roce_read(hr_dev, addr + 8);
+	context.qp1c_bytes_40 = roce_read(hr_dev, addr + 9);
+
+	hr_qp->state = roce_get_field(context.qp1c_bytes_4,
+				      QP1C_BYTES_4_QP_STATE_M,
+				      QP1C_BYTES_4_QP_STATE_S);
+	qp_attr->qp_state	= hr_qp->state;
+	qp_attr->path_mtu	= IB_MTU_256;
+	qp_attr->path_mig_state	= IB_MIG_ARMED;
+	qp_attr->qkey		= QKEY_VAL;
+	qp_attr->rq_psn		= 0;
+	qp_attr->sq_psn		= 0;
+	qp_attr->dest_qp_num	= 1;
+	qp_attr->qp_access_flags = 6;
+
+	qp_attr->pkey_index = roce_get_field(context.qp1c_bytes_20,
+					     QP1C_BYTES_20_PKEY_IDX_M,
+					     QP1C_BYTES_20_PKEY_IDX_S);
+	qp_attr->port_num = hr_qp->port + 1;
+	qp_attr->sq_draining = 0;
+	qp_attr->max_rd_atomic = 0;
+	qp_attr->max_dest_rd_atomic = 0;
+	qp_attr->min_rnr_timer = 0;
+	qp_attr->timeout = 0;
+	qp_attr->retry_cnt = 0;
+	qp_attr->rnr_retry = 0;
+	qp_attr->alt_timeout = 0;
+
+done:
+	qp_attr->cur_qp_state = qp_attr->qp_state;
+	qp_attr->cap.max_recv_wr = hr_qp->rq.wqe_cnt;
+	qp_attr->cap.max_recv_sge = hr_qp->rq.max_gs;
+	qp_attr->cap.max_send_wr = hr_qp->sq.wqe_cnt;
+	qp_attr->cap.max_send_sge = hr_qp->sq.max_gs;
+	qp_attr->cap.max_inline_data = 0;
+	qp_init_attr->cap = qp_attr->cap;
+	qp_init_attr->create_flags = 0;
+
+	mutex_unlock(&hr_qp->mutex);
+
+	return 0;
+}
+
+static int hns_roce_v1_q_qp(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
+			    int qp_attr_mask,
+			    struct ib_qp_init_attr *qp_init_attr)
 {
 	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
 	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
@@ -2767,6 +2837,15 @@ int hns_roce_v1_query_qp(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
 	return ret;
 }
 
+int hns_roce_v1_query_qp(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
+			 int qp_attr_mask, struct ib_qp_init_attr *qp_init_attr)
+{
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+
+	return hr_qp->doorbell_qpn <= 1 ?
+		hns_roce_v1_q_sqp(ibqp, qp_attr, qp_attr_mask, qp_init_attr) :
+		hns_roce_v1_q_qp(ibqp, qp_attr, qp_attr_mask, qp_init_attr);
+}
 static void hns_roce_v1_destroy_qp_common(struct hns_roce_dev *hr_dev,
 					  struct hns_roce_qp *hr_qp,
 					  int is_user)
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index 539b0a3b..2e1878b 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -480,13 +480,17 @@ struct hns_roce_sqp_context {
 	u32 qp1c_bytes_12;
 	u32 qp1c_bytes_16;
 	u32 qp1c_bytes_20;
-	u32 qp1c_bytes_28;
 	u32 cur_rq_wqe_ba_l;
+	u32 qp1c_bytes_28;
 	u32 qp1c_bytes_32;
 	u32 cur_sq_wqe_ba_l;
 	u32 qp1c_bytes_40;
 };
 
+#define QP1C_BYTES_4_QP_STATE_S 0
+#define QP1C_BYTES_4_QP_STATE_M   \
+	(((1UL << 3) - 1) << QP1C_BYTES_4_QP_STATE_S)
+
 #define QP1C_BYTES_4_SQ_WQE_SHIFT_S 8
 #define QP1C_BYTES_4_SQ_WQE_SHIFT_M   \
 	(((1UL << 4) - 1) << QP1C_BYTES_4_SQ_WQE_SHIFT_S)
-- 
1.7.9.5


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
