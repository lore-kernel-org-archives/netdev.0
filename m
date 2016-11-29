From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH for-next 1/6] IB/hns: Fix the bug when destroy qp
Date: Tue, 29 Nov 2016 23:10:25 +0000
Message-ID: <20161129231030.1105600-2-salil.mehta@huawei.com>
References: <20161129231030.1105600-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xushaobo2-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <lijun_nudt-9Onoh4P/yGk@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Dongdong Huang <hdd.huang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161129231030.1105600-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

If send queue is still working when qp is in reset state by modify qp
in destroy qp function, hardware will hold on and don't work in hip06
SoC. In current codes, RoCE driver check hardware pointer of sending and
hardware pointer of processing to ensure that hardware has processed all
the dbs of this qp. But while the environment of wire becomes not good,
The checking time maybe too long.

In order to solve this problem, RoCE driver created a workqueue at probe
function. If there is a timeout when checking the status of qp, driver
initialize work entry and push it into the workqueue, Work function will
finish checking and release the related resources later.

Signed-off-by: Wei Hu (Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Dongdong Huang(Donald) <hdd.huang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/hns/hns_roce_common.h |   40 +++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |  435 +++++++++++++++++++++------
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |   23 ++
 3 files changed, 402 insertions(+), 96 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
index 0dcb620..a055632 100644
--- a/drivers/infiniband/hw/hns/hns_roce_common.h
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -57,6 +57,32 @@
 #define roce_set_bit(origin, shift, val) \
 	roce_set_field((origin), (1ul << (shift)), (shift), (val))
 
+/*
+ * roce_hw_index_cmp_lt - Compare two hardware index values in hisilicon
+ *                        SOC, check if a is less than b.
+ * @a: hardware index value
+ * @b: hardware index value
+ * @bits: the number of bits of a and b, range: 0~31.
+ *
+ * Hardware index increases continuously till max value, and then restart
+ * from zero, again and again. Because the bits of reg field is often
+ * limited, the reg field can only hold the low bits of the hardware index
+ * in hisilicon SOC.
+ * In some scenes we need to compare two values(a,b) getted from two reg
+ * fields in this driver, for example:
+ * If a equals 0xfffe, b equals 0x1 and bits equals 16, we think b has
+ * incresed from 0xffff to 0x1 and a is less than b.
+ * If a equals 0xfffe, b equals 0x0xf001 and bits equals 16, we think a
+ * is bigger than b.
+ *
+ * Return true on a less than b, otherwise false.
+ */
+#define roce_hw_index_mask(bits)	((1ul << (bits)) - 1)
+#define roce_hw_index_shift(bits)	(32 - (bits))
+#define roce_hw_index_cmp_lt(a, b, bits) \
+	((int)((((a) - (b)) & roce_hw_index_mask(bits)) << \
+		roce_hw_index_shift(bits)) < 0)
+
 #define ROCEE_GLB_CFG_ROCEE_DB_SQ_MODE_S 3
 #define ROCEE_GLB_CFG_ROCEE_DB_OTH_MODE_S 4
 
@@ -245,10 +271,22 @@
 #define ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M   \
 	(((1UL << 28) - 1) << ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S)
 
+#define ROCEE_SDB_PTR_CMP_BITS 28
+
 #define ROCEE_SDB_INV_CNT_SDB_INV_CNT_S 0
 #define ROCEE_SDB_INV_CNT_SDB_INV_CNT_M   \
 	(((1UL << 16) - 1) << ROCEE_SDB_INV_CNT_SDB_INV_CNT_S)
 
+#define ROCEE_SDB_RETRY_CNT_SDB_RETRY_CT_S	0
+#define ROCEE_SDB_RETRY_CNT_SDB_RETRY_CT_M	\
+	(((1UL << 16) - 1) << ROCEE_SDB_RETRY_CNT_SDB_RETRY_CT_S)
+
+#define ROCEE_SDB_CNT_CMP_BITS 16
+
+#define ROCEE_TSP_BP_ST_QH_FIFO_ENTRY_S	20
+
+#define ROCEE_CNT_CLR_CE_CNT_CLR_CE_S 0
+
 /*************ROCEE_REG DEFINITION****************/
 #define ROCEE_VENDOR_ID_REG			0x0
 #define ROCEE_VENDOR_PART_ID_REG		0x4
@@ -317,6 +355,8 @@
 #define ROCEE_SDB_ISSUE_PTR_REG			0x758
 #define ROCEE_SDB_SEND_PTR_REG			0x75C
 #define ROCEE_SDB_INV_CNT_REG			0x9A4
+#define ROCEE_SDB_RETRY_CNT_REG			0x9AC
+#define ROCEE_TSP_BP_ST_REG			0x9EC
 #define ROCEE_ECC_UCERR_ALM0_REG		0xB34
 #define ROCEE_ECC_CERR_ALM0_REG			0xB40
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 125ab90..aee1d01 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -948,6 +948,38 @@ int hns_roce_v1_reset(struct hns_roce_dev *hr_dev, bool dereset)
 	return ret;
 }
 
+static int hns_roce_des_qp_init(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_des_qp *des_qp;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	des_qp = &priv->des_qp;
+
+	des_qp->requeue_flag = 1;
+	des_qp->qp_wq = create_singlethread_workqueue("hns_roce_destroy_qp");
+	if (!des_qp->qp_wq) {
+		dev_err(dev, "Create destroy qp workqueue failed!\n");
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void hns_roce_des_qp_free(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_des_qp *des_qp;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	des_qp = &priv->des_qp;
+
+	des_qp->requeue_flag = 0;
+	flush_workqueue(des_qp->qp_wq);
+	destroy_workqueue(des_qp->qp_wq);
+}
+
 void hns_roce_v1_profile(struct hns_roce_dev *hr_dev)
 {
 	int i = 0;
@@ -1050,8 +1082,6 @@ int hns_roce_v1_init(struct hns_roce_dev *hr_dev)
 		goto error_failed_raq_init;
 	}
 
-	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_UP);
-
 	ret = hns_roce_bt_init(hr_dev);
 	if (ret) {
 		dev_err(dev, "bt init failed!\n");
@@ -1064,13 +1094,23 @@ int hns_roce_v1_init(struct hns_roce_dev *hr_dev)
 		goto error_failed_tptr_init;
 	}
 
+	ret = hns_roce_des_qp_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "des qp init failed!\n");
+		goto error_failed_des_qp_init;
+	}
+
+	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_UP);
+
 	return 0;
 
+error_failed_des_qp_init:
+	hns_roce_tptr_free(hr_dev);
+
 error_failed_tptr_init:
 	hns_roce_bt_free(hr_dev);
 
 error_failed_bt_init:
-	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_DOWN);
 	hns_roce_raq_free(hr_dev);
 
 error_failed_raq_init:
@@ -1080,9 +1120,10 @@ int hns_roce_v1_init(struct hns_roce_dev *hr_dev)
 
 void hns_roce_v1_exit(struct hns_roce_dev *hr_dev)
 {
+	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_DOWN);
+	hns_roce_des_qp_free(hr_dev);
 	hns_roce_tptr_free(hr_dev);
 	hns_roce_bt_free(hr_dev);
-	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_DOWN);
 	hns_roce_raq_free(hr_dev);
 	hns_roce_db_free(hr_dev);
 }
@@ -2906,132 +2947,334 @@ int hns_roce_v1_query_qp(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
 		hns_roce_v1_q_sqp(ibqp, qp_attr, qp_attr_mask, qp_init_attr) :
 		hns_roce_v1_q_qp(ibqp, qp_attr, qp_attr_mask, qp_init_attr);
 }
-static void hns_roce_v1_destroy_qp_common(struct hns_roce_dev *hr_dev,
-					  struct hns_roce_qp *hr_qp,
-					  int is_user)
+
+static int check_qp_db_process_status(struct hns_roce_dev *hr_dev,
+				      struct hns_roce_qp *hr_qp,
+				      u32 sdb_issue_ptr,
+				      u32 *sdb_inv_cnt,
+				      u32 *wait_stage)
 {
-	u32 sdbinvcnt;
-	unsigned long end = 0;
-	u32 sdbinvcnt_val;
-	u32 sdbsendptr_val;
-	u32 sdbisusepr_val;
-	struct hns_roce_cq *send_cq, *recv_cq;
 	struct device *dev = &hr_dev->pdev->dev;
+	u32 sdb_retry_cnt, old_retry;
+	u32 sdb_send_ptr, old_send;
+	u32 success_flags = 0;
+	u32 cur_cnt, old_cnt;
+	unsigned long end;
+	u32 send_ptr;
+	u32 inv_cnt;
+	u32 tsp_st;
+
+	if (*wait_stage > HNS_ROCE_V1_DB_STAGE2 ||
+	    *wait_stage < HNS_ROCE_V1_DB_STAGE1) {
+		dev_err(dev, "QP(0x%lx) db status wait stage(%d) error!\n",
+			hr_qp->qpn, *wait_stage);
+		return -EINVAL;
+	}
 
-	if (hr_qp->ibqp.qp_type == IB_QPT_RC) {
-		if (hr_qp->state != IB_QPS_RESET) {
-			/*
-			 * Set qp to ERR,
-			 * waiting for hw complete processing all dbs
-			 */
-			if (hns_roce_v1_qp_modify(hr_dev, NULL,
-					to_hns_roce_state(
-						(enum ib_qp_state)hr_qp->state),
-						HNS_ROCE_QP_STATE_ERR, NULL,
-						hr_qp))
-				dev_err(dev, "modify QP %06lx to ERR failed.\n",
-					hr_qp->qpn);
-
-			/* Record issued doorbell */
-			sdbisusepr_val = roce_read(hr_dev,
-					 ROCEE_SDB_ISSUE_PTR_REG);
-			/*
-			 * Query db process status,
-			 * until hw process completely
-			 */
-			end = msecs_to_jiffies(
-			      HNS_ROCE_QP_DESTROY_TIMEOUT_MSECS) + jiffies;
-			do {
-				sdbsendptr_val = roce_read(hr_dev,
+	/* Calculate the total timeout for the entire verification process */
+	end = msecs_to_jiffies(HNS_ROCE_V1_CHECK_DB_TIMEOUT_MSECS) + jiffies;
+
+	if (*wait_stage == HNS_ROCE_V1_DB_STAGE1) {
+		/* Query db process status, until hw process completely */
+		sdb_send_ptr = roce_read(hr_dev, ROCEE_SDB_SEND_PTR_REG);
+		while (roce_hw_index_cmp_lt(sdb_send_ptr, sdb_issue_ptr,
+					    ROCEE_SDB_PTR_CMP_BITS)) {
+			if (!time_before(jiffies, end)) {
+				dev_dbg(dev, "QP(0x%lx) db process stage1 timeout. issue 0x%x send 0x%x.\n",
+					hr_qp->qpn, sdb_issue_ptr,
+					sdb_send_ptr);
+				return 0;
+			}
+
+			msleep(HNS_ROCE_V1_CHECK_DB_SLEEP_MSECS);
+			sdb_send_ptr = roce_read(hr_dev,
 						 ROCEE_SDB_SEND_PTR_REG);
-				if (!time_before(jiffies, end)) {
-					dev_err(dev, "destroy qp(0x%lx) timeout!!!",
-						hr_qp->qpn);
-					break;
-				}
-			} while ((short)(roce_get_field(sdbsendptr_val,
-					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M,
-					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S) -
-				roce_get_field(sdbisusepr_val,
-					ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_M,
-					ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_S)
-				) < 0);
+		}
 
-			/* Get list pointer */
-			sdbinvcnt = roce_read(hr_dev, ROCEE_SDB_INV_CNT_REG);
+		if (roce_get_field(sdb_issue_ptr,
+				   ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_M,
+				   ROCEE_SDB_ISSUE_PTR_SDB_ISSUE_PTR_S) ==
+		    roce_get_field(sdb_send_ptr,
+				   ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M,
+				   ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S)) {
+			old_send = roce_read(hr_dev, ROCEE_SDB_SEND_PTR_REG);
+			old_retry = roce_read(hr_dev, ROCEE_SDB_RETRY_CNT_REG);
 
-			/* Query db's list status, until hw reversal */
 			do {
-				sdbinvcnt_val = roce_read(hr_dev,
-						ROCEE_SDB_INV_CNT_REG);
+				tsp_st = roce_read(hr_dev, ROCEE_TSP_BP_ST_REG);
+				if (roce_get_bit(tsp_st,
+					ROCEE_TSP_BP_ST_QH_FIFO_ENTRY_S) == 1) {
+					*wait_stage = HNS_ROCE_V1_DB_WAIT_OK;
+					return 0;
+				}
+
 				if (!time_before(jiffies, end)) {
-					dev_err(dev, "destroy qp(0x%lx) timeout!!!",
-						hr_qp->qpn);
-					dev_err(dev, "SdbInvCnt = 0x%x\n",
-						sdbinvcnt_val);
-					break;
+					dev_dbg(dev, "QP(0x%lx) db process stage1 timeout when send ptr equals issue ptr.\n"
+						     "issue 0x%x send 0x%x.\n",
+						hr_qp->qpn, sdb_issue_ptr,
+						sdb_send_ptr);
+					return 0;
 				}
-			} while ((short)(roce_get_field(sdbinvcnt_val,
-				  ROCEE_SDB_INV_CNT_SDB_INV_CNT_M,
-				  ROCEE_SDB_INV_CNT_SDB_INV_CNT_S) -
-				  (sdbinvcnt + SDB_INV_CNT_OFFSET)) < 0);
-
-			/* Modify qp to reset before destroying qp */
-			if (hns_roce_v1_qp_modify(hr_dev, NULL,
-					to_hns_roce_state(
-					(enum ib_qp_state)hr_qp->state),
-					HNS_ROCE_QP_STATE_RST, NULL, hr_qp))
-				dev_err(dev, "modify QP %06lx to RESET failed.\n",
-					hr_qp->qpn);
+
+				msleep(HNS_ROCE_V1_CHECK_DB_SLEEP_MSECS);
+
+				sdb_send_ptr = roce_read(hr_dev,
+							ROCEE_SDB_SEND_PTR_REG);
+				sdb_retry_cnt =	roce_read(hr_dev,
+						       ROCEE_SDB_RETRY_CNT_REG);
+				cur_cnt = roce_get_field(sdb_send_ptr,
+					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M,
+					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S) +
+					roce_get_field(sdb_retry_cnt,
+					ROCEE_SDB_RETRY_CNT_SDB_RETRY_CT_M,
+					ROCEE_SDB_RETRY_CNT_SDB_RETRY_CT_S);
+				if (!roce_get_bit(tsp_st,
+					ROCEE_CNT_CLR_CE_CNT_CLR_CE_S)) {
+					old_cnt = roce_get_field(old_send,
+					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M,
+					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S) +
+					roce_get_field(old_retry,
+					ROCEE_SDB_RETRY_CNT_SDB_RETRY_CT_M,
+					ROCEE_SDB_RETRY_CNT_SDB_RETRY_CT_S);
+					if (cur_cnt - old_cnt > SDB_ST_CMP_VAL)
+						success_flags = 1;
+				} else {
+					old_cnt = roce_get_field(old_send,
+					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M,
+					ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S);
+					if (cur_cnt - old_cnt > SDB_ST_CMP_VAL)
+						success_flags = 1;
+					else {
+					    send_ptr = roce_get_field(old_send,
+					    ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M,
+					    ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S) +
+					    roce_get_field(sdb_retry_cnt,
+					    ROCEE_SDB_RETRY_CNT_SDB_RETRY_CT_M,
+					    ROCEE_SDB_RETRY_CNT_SDB_RETRY_CT_S);
+					    roce_set_field(old_send,
+					    ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_M,
+					    ROCEE_SDB_SEND_PTR_SDB_SEND_PTR_S,
+						send_ptr);
+					}
+				}
+			} while (!success_flags);
+		}
+
+		*wait_stage = HNS_ROCE_V1_DB_STAGE2;
+
+		/* Get list pointer */
+		*sdb_inv_cnt = roce_read(hr_dev, ROCEE_SDB_INV_CNT_REG);
+		dev_dbg(dev, "QP(0x%lx) db process stage2. inv cnt = 0x%x.\n",
+			hr_qp->qpn, *sdb_inv_cnt);
+	}
+
+	if (*wait_stage == HNS_ROCE_V1_DB_STAGE2) {
+		/* Query db's list status, until hw reversal */
+		inv_cnt = roce_read(hr_dev, ROCEE_SDB_INV_CNT_REG);
+		while (roce_hw_index_cmp_lt(inv_cnt,
+					    *sdb_inv_cnt + SDB_INV_CNT_OFFSET,
+					    ROCEE_SDB_CNT_CMP_BITS)) {
+			if (!time_before(jiffies, end)) {
+				dev_dbg(dev, "QP(0x%lx) db process stage2 timeout. inv cnt 0x%x.\n",
+					hr_qp->qpn, inv_cnt);
+				return 0;
+			}
+
+			msleep(HNS_ROCE_V1_CHECK_DB_SLEEP_MSECS);
+			inv_cnt = roce_read(hr_dev, ROCEE_SDB_INV_CNT_REG);
 		}
+
+		*wait_stage = HNS_ROCE_V1_DB_WAIT_OK;
+	}
+
+	return 0;
+}
+
+static int check_qp_reset_state(struct hns_roce_dev *hr_dev,
+				struct hns_roce_qp *hr_qp,
+				struct hns_roce_qp_work *qp_work_entry,
+				int *is_timeout)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	u32 sdb_issue_ptr;
+	int ret;
+
+	if (hr_qp->state != IB_QPS_RESET) {
+		/* Set qp to ERR, waiting for hw complete processing all dbs */
+		ret = hns_roce_v1_modify_qp(&hr_qp->ibqp, NULL, 0, hr_qp->state,
+					    IB_QPS_ERR);
+		if (ret) {
+			dev_err(dev, "Modify QP(0x%lx) to ERR failed!\n",
+				hr_qp->qpn);
+			return ret;
+		}
+
+		/* Record issued doorbell */
+		sdb_issue_ptr = roce_read(hr_dev, ROCEE_SDB_ISSUE_PTR_REG);
+		qp_work_entry->sdb_issue_ptr = sdb_issue_ptr;
+		qp_work_entry->db_wait_stage = HNS_ROCE_V1_DB_STAGE1;
+
+		/* Query db process status, until hw process completely */
+		ret = check_qp_db_process_status(hr_dev, hr_qp, sdb_issue_ptr,
+						 &qp_work_entry->sdb_inv_cnt,
+						 &qp_work_entry->db_wait_stage);
+		if (ret) {
+			dev_err(dev, "Check QP(0x%lx) db process status failed!\n",
+				hr_qp->qpn);
+			return ret;
+		}
+
+		if (qp_work_entry->db_wait_stage != HNS_ROCE_V1_DB_WAIT_OK) {
+			qp_work_entry->sche_cnt = 0;
+			*is_timeout = 1;
+			return 0;
+		}
+
+		/* Modify qp to reset before destroying qp */
+		ret = hns_roce_v1_modify_qp(&hr_qp->ibqp, NULL, 0, hr_qp->state,
+					    IB_QPS_RESET);
+		if (ret) {
+			dev_err(dev, "Modify QP(0x%lx) to RST failed!\n",
+				hr_qp->qpn);
+			return ret;
+		}
+	}
+
+	return 0;
+}
+
+static void hns_roce_v1_destroy_qp_work_fn(struct work_struct *work)
+{
+	struct hns_roce_qp_work *qp_work_entry;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_dev *hr_dev;
+	struct hns_roce_qp *hr_qp;
+	struct device *dev;
+	int ret;
+
+	qp_work_entry = container_of(work, struct hns_roce_qp_work, work);
+	hr_dev = to_hr_dev(qp_work_entry->ib_dev);
+	dev = &hr_dev->pdev->dev;
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	hr_qp = qp_work_entry->qp;
+
+	dev_dbg(dev, "Schedule destroy QP(0x%lx) work.\n", hr_qp->qpn);
+
+	qp_work_entry->sche_cnt++;
+
+	/* Query db process status, until hw process completely */
+	ret = check_qp_db_process_status(hr_dev, hr_qp,
+					 qp_work_entry->sdb_issue_ptr,
+					 &qp_work_entry->sdb_inv_cnt,
+					 &qp_work_entry->db_wait_stage);
+	if (ret) {
+		dev_err(dev, "Check QP(0x%lx) db process status failed!\n",
+			hr_qp->qpn);
+		return;
+	}
+
+	if (qp_work_entry->db_wait_stage != HNS_ROCE_V1_DB_WAIT_OK &&
+	    priv->des_qp.requeue_flag) {
+		queue_work(priv->des_qp.qp_wq, work);
+		return;
+	}
+
+	/* Modify qp to reset before destroying qp */
+	ret = hns_roce_v1_modify_qp(&hr_qp->ibqp, NULL, 0, hr_qp->state,
+				    IB_QPS_RESET);
+	if (ret) {
+		dev_err(dev, "Modify QP(0x%lx) to RST failed!\n", hr_qp->qpn);
+		return;
+	}
+
+	hns_roce_qp_remove(hr_dev, hr_qp);
+	hns_roce_qp_free(hr_dev, hr_qp);
+
+	if (hr_qp->ibqp.qp_type == IB_QPT_RC) {
+		/* RC QP, release QPN */
+		hns_roce_release_range_qp(hr_dev, hr_qp->qpn, 1);
+		kfree(hr_qp);
+	} else
+		kfree(hr_to_hr_sqp(hr_qp));
+
+	kfree(qp_work_entry);
+
+	dev_dbg(dev, "Accomplished destroy QP(0x%lx) work.\n", hr_qp->qpn);
+}
+
+int hns_roce_v1_destroy_qp(struct ib_qp *ibqp)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
+	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_qp_work qp_work_entry;
+	struct hns_roce_qp_work *qp_work;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_cq *send_cq, *recv_cq;
+	int is_user = !!ibqp->pd->uobject;
+	int is_timeout = 0;
+	int ret;
+
+	ret = check_qp_reset_state(hr_dev, hr_qp, &qp_work_entry, &is_timeout);
+	if (ret) {
+		dev_err(dev, "QP reset state check failed(%d)!\n", ret);
+		return ret;
 	}
 
 	send_cq = to_hr_cq(hr_qp->ibqp.send_cq);
 	recv_cq = to_hr_cq(hr_qp->ibqp.recv_cq);
 
 	hns_roce_lock_cqs(send_cq, recv_cq);
-
 	if (!is_user) {
 		__hns_roce_v1_cq_clean(recv_cq, hr_qp->qpn, hr_qp->ibqp.srq ?
 				       to_hr_srq(hr_qp->ibqp.srq) : NULL);
 		if (send_cq != recv_cq)
 			__hns_roce_v1_cq_clean(send_cq, hr_qp->qpn, NULL);
 	}
-
-	hns_roce_qp_remove(hr_dev, hr_qp);
-
 	hns_roce_unlock_cqs(send_cq, recv_cq);
 
-	hns_roce_qp_free(hr_dev, hr_qp);
+	if (!is_timeout) {
+		hns_roce_qp_remove(hr_dev, hr_qp);
+		hns_roce_qp_free(hr_dev, hr_qp);
 
-	/* Not special_QP, free their QPN */
-	if ((hr_qp->ibqp.qp_type == IB_QPT_RC) ||
-	    (hr_qp->ibqp.qp_type == IB_QPT_UC) ||
-	    (hr_qp->ibqp.qp_type == IB_QPT_UD))
-		hns_roce_release_range_qp(hr_dev, hr_qp->qpn, 1);
+		/* RC QP, release QPN */
+		if (hr_qp->ibqp.qp_type == IB_QPT_RC)
+			hns_roce_release_range_qp(hr_dev, hr_qp->qpn, 1);
+	}
 
 	hns_roce_mtt_cleanup(hr_dev, &hr_qp->mtt);
 
-	if (is_user) {
+	if (is_user)
 		ib_umem_release(hr_qp->umem);
-	} else {
+	else {
 		kfree(hr_qp->sq.wrid);
 		kfree(hr_qp->rq.wrid);
+
 		hns_roce_buf_free(hr_dev, hr_qp->buff_size, &hr_qp->hr_buf);
 	}
-}
 
-int hns_roce_v1_destroy_qp(struct ib_qp *ibqp)
-{
-	struct hns_roce_dev *hr_dev = to_hr_dev(ibqp->device);
-	struct hns_roce_qp *hr_qp = to_hr_qp(ibqp);
-
-	hns_roce_v1_destroy_qp_common(hr_dev, hr_qp, !!ibqp->pd->uobject);
-
-	if (hr_qp->ibqp.qp_type == IB_QPT_GSI)
-		kfree(hr_to_hr_sqp(hr_qp));
-	else
-		kfree(hr_qp);
+	if (!is_timeout) {
+		if (hr_qp->ibqp.qp_type == IB_QPT_RC)
+			kfree(hr_qp);
+		else
+			kfree(hr_to_hr_sqp(hr_qp));
+	} else {
+		qp_work = kzalloc(sizeof(*qp_work), GFP_KERNEL);
+		if (!qp_work)
+			return -ENOMEM;
+
+		INIT_WORK(&qp_work->work, hns_roce_v1_destroy_qp_work_fn);
+		qp_work->ib_dev	= &hr_dev->ib_dev;
+		qp_work->qp		= hr_qp;
+		qp_work->db_wait_stage	= qp_work_entry.db_wait_stage;
+		qp_work->sdb_issue_ptr	= qp_work_entry.sdb_issue_ptr;
+		qp_work->sdb_inv_cnt	= qp_work_entry.sdb_inv_cnt;
+		qp_work->sche_cnt	= qp_work_entry.sche_cnt;
+
+		priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+		queue_work(priv->des_qp.qp_wq, &qp_work->work);
+		dev_dbg(dev, "Begin destroy QP(0x%lx) work.\n", hr_qp->qpn);
+	}
 
 	return 0;
 }
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index cf28f1b..1d250c0 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -102,6 +102,12 @@
 #define HNS_ROCE_V1_EXT_ODB_ALFUL	\
 	(HNS_ROCE_V1_EXT_ODB_DEPTH - HNS_ROCE_V1_DB_RSVD)
 
+#define HNS_ROCE_V1_DB_WAIT_OK				0
+#define HNS_ROCE_V1_DB_STAGE1				1
+#define HNS_ROCE_V1_DB_STAGE2				2
+#define HNS_ROCE_V1_CHECK_DB_TIMEOUT_MSECS		10000
+#define HNS_ROCE_V1_CHECK_DB_SLEEP_MSECS		20
+
 #define HNS_ROCE_BT_RSV_BUF_SIZE			(1 << 17)
 
 #define HNS_ROCE_V1_TPTR_ENTRY_SIZE			2
@@ -144,6 +150,7 @@
 #define SQ_PSN_SHIFT					8
 #define QKEY_VAL					0x80010000
 #define SDB_INV_CNT_OFFSET				8
+#define SDB_ST_CMP_VAL					8
 
 struct hns_roce_cq_context {
 	u32 cqc_byte_4;
@@ -993,11 +1000,27 @@ struct hns_roce_tptr_table {
 	struct hns_roce_buf_list tptr_buf;
 };
 
+struct hns_roce_qp_work {
+	struct	work_struct work;
+	struct	ib_device *ib_dev;
+	struct	hns_roce_qp *qp;
+	u32	db_wait_stage;
+	u32	sdb_issue_ptr;
+	u32	sdb_inv_cnt;
+	u32	sche_cnt;
+};
+
+struct hns_roce_des_qp {
+	struct workqueue_struct	*qp_wq;
+	int	requeue_flag;
+};
+
 struct hns_roce_v1_priv {
 	struct hns_roce_db_table  db_table;
 	struct hns_roce_raq_table raq_table;
 	struct hns_roce_bt_table  bt_table;
 	struct hns_roce_tptr_table tptr_table;
+	struct hns_roce_des_qp des_qp;
 };
 
 int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool dereset);
-- 
1.7.9.5


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
