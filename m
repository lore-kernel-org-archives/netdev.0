From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH for-next 5/6] IB/hns: Fix the bug when free cq
Date: Tue, 29 Nov 2016 23:10:29 +0000
Message-ID: <20161129231030.1105600-6-salil.mehta@huawei.com>
References: <20161129231030.1105600-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <xushaobo2@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <lijun_nudt@163.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:36925 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756489AbcK2XLd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 18:11:33 -0500
In-Reply-To: <20161129231030.1105600-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaobo Xu <xushaobo2@huawei.com>

If the resources of cq are freed while executing the user case, hardware
can not been notified in hip06 SoC. Then hardware will hold on when it
writes the cq buffer which has been released.

In order to slove this problem, RoCE driver checks the CQE counter, and
ensure that the outstanding CQE have been written. Then the cq buffer
can be released.

Signed-off-by: Shaobo Xu <xushaobo2@huawei.com>
Reviewed-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_common.h |    2 +
 drivers/infiniband/hw/hns/hns_roce_cq.c     |   27 ++++++++------
 drivers/infiniband/hw/hns/hns_roce_device.h |    8 ++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |   53 +++++++++++++++++++++++++++
 4 files changed, 79 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
index a055632..4af403e 100644
--- a/drivers/infiniband/hw/hns/hns_roce_common.h
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -354,6 +354,8 @@
 
 #define ROCEE_SDB_ISSUE_PTR_REG			0x758
 #define ROCEE_SDB_SEND_PTR_REG			0x75C
+#define ROCEE_CAEP_CQE_WCMD_EMPTY		0x850
+#define ROCEE_SCAEP_WR_CQE_CNT			0x8D0
 #define ROCEE_SDB_INV_CNT_REG			0x9A4
 #define ROCEE_SDB_RETRY_CNT_REG			0x9AC
 #define ROCEE_TSP_BP_ST_REG			0x9EC
diff --git a/drivers/infiniband/hw/hns/hns_roce_cq.c b/drivers/infiniband/hw/hns/hns_roce_cq.c
index c9f6c3d..ff9a6a3 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cq.c
+++ b/drivers/infiniband/hw/hns/hns_roce_cq.c
@@ -179,8 +179,7 @@ static int hns_roce_hw2sw_cq(struct hns_roce_dev *dev,
 				 HNS_ROCE_CMD_TIMEOUT_MSECS);
 }
 
-static void hns_roce_free_cq(struct hns_roce_dev *hr_dev,
-			     struct hns_roce_cq *hr_cq)
+void hns_roce_free_cq(struct hns_roce_dev *hr_dev, struct hns_roce_cq *hr_cq)
 {
 	struct hns_roce_cq_table *cq_table = &hr_dev->cq_table;
 	struct device *dev = &hr_dev->pdev->dev;
@@ -392,19 +391,25 @@ int hns_roce_ib_destroy_cq(struct ib_cq *ib_cq)
 {
 	struct hns_roce_dev *hr_dev = to_hr_dev(ib_cq->device);
 	struct hns_roce_cq *hr_cq = to_hr_cq(ib_cq);
+	int ret = 0;
 
-	hns_roce_free_cq(hr_dev, hr_cq);
-	hns_roce_mtt_cleanup(hr_dev, &hr_cq->hr_buf.hr_mtt);
+	if (hr_dev->hw->destroy_cq) {
+		ret = hr_dev->hw->destroy_cq(ib_cq);
+	} else {
+		hns_roce_free_cq(hr_dev, hr_cq);
+		hns_roce_mtt_cleanup(hr_dev, &hr_cq->hr_buf.hr_mtt);
 
-	if (ib_cq->uobject)
-		ib_umem_release(hr_cq->umem);
-	else
-		/* Free the buff of stored cq */
-		hns_roce_ib_free_cq_buf(hr_dev, &hr_cq->hr_buf, ib_cq->cqe);
+		if (ib_cq->uobject)
+			ib_umem_release(hr_cq->umem);
+		else
+			/* Free the buff of stored cq */
+			hns_roce_ib_free_cq_buf(hr_dev, &hr_cq->hr_buf,
+						ib_cq->cqe);
 
-	kfree(hr_cq);
+		kfree(hr_cq);
+	}
 
-	return 0;
+	return ret;
 }
 
 void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn)
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 1050829..d4f0fce 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -56,6 +56,12 @@
 #define HNS_ROCE_MAX_INNER_MTPT_NUM		0x7
 #define HNS_ROCE_MAX_MTPT_PBL_NUM		0x100000
 
+#define HNS_ROCE_EACH_FREE_CQ_WAIT_MSECS	20
+#define HNS_ROCE_MAX_FREE_CQ_WAIT_CNT	\
+	(5000 / HNS_ROCE_EACH_FREE_CQ_WAIT_MSECS)
+#define HNS_ROCE_CQE_WCMD_EMPTY_BIT		0x2
+#define HNS_ROCE_MIN_CQE_CNT			16
+
 #define HNS_ROCE_MAX_IRQ_NUM			34
 
 #define HNS_ROCE_COMP_VEC_NUM			32
@@ -528,6 +534,7 @@ struct hns_roce_hw {
 	int (*req_notify_cq)(struct ib_cq *ibcq, enum ib_cq_notify_flags flags);
 	int (*poll_cq)(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc);
 	int (*dereg_mr)(struct hns_roce_dev *hr_dev, struct hns_roce_mr *mr);
+	int (*destroy_cq)(struct ib_cq *ibcq);
 	void	*priv;
 };
 
@@ -734,6 +741,7 @@ struct ib_cq *hns_roce_ib_create_cq(struct ib_device *ib_dev,
 				    struct ib_udata *udata);
 
 int hns_roce_ib_destroy_cq(struct ib_cq *ib_cq);
+void hns_roce_free_cq(struct hns_roce_dev *hr_dev, struct hns_roce_cq *hr_cq);
 
 void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn);
 void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_type);
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index f67a3bf..b8111b0 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -3763,6 +3763,58 @@ int hns_roce_v1_destroy_qp(struct ib_qp *ibqp)
 	return 0;
 }
 
+int hns_roce_v1_destroy_cq(struct ib_cq *ibcq)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibcq->device);
+	struct hns_roce_cq *hr_cq = to_hr_cq(ibcq);
+	struct device *dev = &hr_dev->pdev->dev;
+	u32 cqe_cnt_ori;
+	u32 cqe_cnt_cur;
+	u32 cq_buf_size;
+	int wait_time = 0;
+	int ret = 0;
+
+	hns_roce_free_cq(hr_dev, hr_cq);
+
+	/*
+	 * Before freeing cq buffer, we need to ensure that the outstanding CQE
+	 * have been written by checking the CQE counter.
+	 */
+	cqe_cnt_ori = roce_read(hr_dev, ROCEE_SCAEP_WR_CQE_CNT);
+	while (1) {
+		if (roce_read(hr_dev, ROCEE_CAEP_CQE_WCMD_EMPTY) &
+		    HNS_ROCE_CQE_WCMD_EMPTY_BIT)
+			break;
+
+		cqe_cnt_cur = roce_read(hr_dev, ROCEE_SCAEP_WR_CQE_CNT);
+		if ((cqe_cnt_cur - cqe_cnt_ori) >= HNS_ROCE_MIN_CQE_CNT)
+			break;
+
+		msleep(HNS_ROCE_EACH_FREE_CQ_WAIT_MSECS);
+		if (wait_time > HNS_ROCE_MAX_FREE_CQ_WAIT_CNT) {
+			dev_warn(dev, "Destroy cq 0x%lx timeout!\n",
+				hr_cq->cqn);
+			ret = -ETIMEDOUT;
+			break;
+		}
+		wait_time++;
+	}
+
+	hns_roce_mtt_cleanup(hr_dev, &hr_cq->hr_buf.hr_mtt);
+
+	if (ibcq->uobject)
+		ib_umem_release(hr_cq->umem);
+	else {
+		/* Free the buff of stored cq */
+		cq_buf_size = (ibcq->cqe + 1) * hr_dev->caps.cq_entry_sz;
+		hns_roce_buf_free(hr_dev, cq_buf_size, &hr_cq->hr_buf.hr_buf);
+	}
+
+	kfree(hr_cq);
+
+	return ret;
+}
+
 struct hns_roce_v1_priv hr_v1_priv;
 
 struct hns_roce_hw hns_roce_hw_v1 = {
@@ -3784,5 +3836,6 @@ struct hns_roce_hw hns_roce_hw_v1 = {
 	.req_notify_cq = hns_roce_v1_req_notify_cq,
 	.poll_cq = hns_roce_v1_poll_cq,
 	.dereg_mr = hns_roce_v1_dereg_mr,
+	.destroy_cq = hns_roce_v1_destroy_cq,
 	.priv = &hr_v1_priv,
 };
-- 
1.7.9.5
