From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V4 net-next 19/21] net-next/hinic: Add Tx operation
Date: Wed, 16 Aug 2017 20:03:04 +0800
Message-ID: <9405c4244fe2b1c8c906c4d5da4d4cf123c6d6c0.1502883967.git.aviad.krawczyk@huawei.com>
References: <cover.1502883967.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:3571 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752790AbdHPMEO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 08:04:14 -0400
In-Reply-To: <cover.1502883967.git.aviad.krawczyk@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add transmit operation for sending data by qp operations.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_dev.h    |   1 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c |  47 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h |  22 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c  | 257 ++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h  |  48 +++
 drivers/net/ethernet/huawei/hinic/hinic_main.c   |  12 +-
 drivers/net/ethernet/huawei/hinic/hinic_tx.c     | 406 +++++++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_tx.h     |  11 +
 8 files changed, 802 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
index 3d0f6cf..15d0c2e 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
@@ -43,6 +43,7 @@ struct hinic_dev {
 	struct hinic_hwdev              *hwdev;
 
 	u32                             msg_enable;
+	unsigned int                    tx_weight;
 	unsigned int                    rx_weight;
 
 	unsigned int                    flags;
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
index 03149e8..6606fba 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
@@ -40,6 +40,8 @@
 #define MAX_IRQS(max_qps, num_aeqs, num_ceqs)   \
 		 (2 * (max_qps) + (num_aeqs) + (num_ceqs))
 
+#define ADDR_IN_4BYTES(addr)            ((addr) >> 2)
+
 enum intr_type {
 	INTR_MSIX_TYPE,
 };
@@ -996,3 +998,48 @@ int hinic_hwdev_msix_set(struct hinic_hwdev *hwdev, u16 msix_index,
 				   lli_timer_cfg, lli_credit_limit,
 				   resend_timer);
 }
+
+/**
+ * hinic_hwdev_hw_ci_addr_set - set cons idx addr and attributes in HW for sq
+ * @hwdev: the NIC HW device
+ * @sq: send queue
+ * @pending_limit: the maximum pending update ci events (unit 8)
+ * @coalesc_timer: coalesc period for update ci (unit 8 us)
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_hwdev_hw_ci_addr_set(struct hinic_hwdev *hwdev, struct hinic_sq *sq,
+			       u8 pending_limit, u8 coalesc_timer)
+{
+	struct hinic_qp *qp = container_of(sq, struct hinic_qp, sq);
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_pfhwdev *pfhwdev;
+	struct hinic_cmd_hw_ci hw_ci;
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "Unsupported PCI Function type\n");
+		return -EINVAL;
+	}
+
+	hw_ci.dma_attr_off  = 0;
+	hw_ci.pending_limit = pending_limit;
+	hw_ci.coalesc_timer  = coalesc_timer;
+
+	hw_ci.msix_en = 1;
+	hw_ci.msix_entry_idx = sq->msix_entry;
+
+	hw_ci.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+
+	hw_ci.sq_id = qp->q_id;
+
+	hw_ci.ci_addr = ADDR_IN_4BYTES(sq->hw_ci_dma_addr);
+
+	pfhwdev = container_of(hwdev, struct hinic_pfhwdev, hwdev);
+
+	return hinic_msg_to_mgmt(&pfhwdev->pf_to_mgmt,
+				 HINIC_MOD_COMM,
+				 HINIC_COMM_CMD_SQ_HI_CI_SET,
+				 &hw_ci, sizeof(hw_ci), NULL,
+				 NULL, HINIC_MGMT_MSG_SYNC);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
index e7277d1..0f5563f 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
@@ -153,6 +153,25 @@ struct hinic_cmd_base_qpn {
 	u16     qpn;
 };
 
+struct hinic_cmd_hw_ci {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+
+	u8      dma_attr_off;
+	u8      pending_limit;
+	u8      coalesc_timer;
+
+	u8      msix_en;
+	u16     msix_entry_idx;
+
+	u32     sq_id;
+	u32     rsvd1;
+	u64     ci_addr;
+};
+
 struct hinic_hwdev {
 	struct hinic_hwif               *hwif;
 	struct msix_entry               *msix_entries;
@@ -214,4 +233,7 @@ int hinic_hwdev_msix_set(struct hinic_hwdev *hwdev, u16 msix_index,
 			 u8 lli_timer_cfg, u8 lli_credit_limit,
 			 u8 resend_timer);
 
+int hinic_hwdev_hw_ci_addr_set(struct hinic_hwdev *hwdev, struct hinic_sq *sq,
+			       u8 pending_limit, u8 coalesc_timer);
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
index 6e540d2..97ee8eb 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
@@ -23,6 +23,7 @@
 #include <linux/sizes.h>
 #include <linux/atomic.h>
 #include <linux/skbuff.h>
+#include <linux/io.h>
 #include <asm/barrier.h>
 #include <asm/byteorder.h>
 
@@ -32,6 +33,7 @@
 #include "hinic_hw_wq.h"
 #include "hinic_hw_qp_ctxt.h"
 #include "hinic_hw_qp.h"
+#include "hinic_hw_io.h"
 
 #define SQ_DB_OFF               SZ_2K
 
@@ -55,8 +57,24 @@
 
 #define SIZE_16BYTES(size)      (ALIGN(size, 16) >> 4)
 #define SIZE_8BYTES(size)       (ALIGN(size, 8) >> 3)
+#define SECT_SIZE_FROM_8BYTES(size)     ((size) << 3)
+
+#define SQ_DB_PI_HI_SHIFT       8
+#define SQ_DB_PI_HI(prod_idx)   ((prod_idx) >> SQ_DB_PI_HI_SHIFT)
+
+#define SQ_DB_PI_LOW_MASK       0xFF
+#define SQ_DB_PI_LOW(prod_idx)  ((prod_idx) & SQ_DB_PI_LOW_MASK)
+
+#define SQ_DB_ADDR(sq, pi)      ((u64 *)((sq)->db_base) + SQ_DB_PI_LOW(pi))
 
 #define RQ_MASKED_IDX(rq, idx)  ((idx) & (rq)->wq->mask)
+#define SQ_MASKED_IDX(sq, idx)  ((idx) & (sq)->wq->mask)
+
+#define TX_MAX_MSS_DEFAULT      0x3E00
+
+enum sq_wqe_type {
+	SQ_NORMAL_WQE = 0,
+};
 
 enum rq_completion_fmt {
 	RQ_COMPLETE_SGE = 1
@@ -435,6 +453,19 @@ void hinic_clean_rq(struct hinic_rq *rq)
 }
 
 /**
+ * hinic_get_sq_free_wqebbs - return number of free wqebbs for use
+ * @sq: send queue
+ *
+ * Return number of free wqebbs
+ **/
+int hinic_get_sq_free_wqebbs(struct hinic_sq *sq)
+{
+	struct hinic_wq *wq = sq->wq;
+
+	return atomic_read(&wq->delta) - 1;
+}
+
+/**
  * hinic_get_rq_free_wqebbs - return number of free wqebbs for use
  * @rq: recv queue
  *
@@ -447,6 +478,232 @@ int hinic_get_rq_free_wqebbs(struct hinic_rq *rq)
 	return atomic_read(&wq->delta) - 1;
 }
 
+static void sq_prepare_ctrl(struct hinic_sq_ctrl *ctrl, u16 prod_idx,
+			    int nr_descs)
+{
+	u32 ctrl_size, task_size, bufdesc_size;
+
+	ctrl_size = SIZE_8BYTES(sizeof(struct hinic_sq_ctrl));
+	task_size = SIZE_8BYTES(sizeof(struct hinic_sq_task));
+	bufdesc_size = nr_descs * sizeof(struct hinic_sq_bufdesc);
+	bufdesc_size = SIZE_8BYTES(bufdesc_size);
+
+	ctrl->ctrl_info = HINIC_SQ_CTRL_SET(bufdesc_size, BUFDESC_SECT_LEN) |
+			HINIC_SQ_CTRL_SET(task_size, TASKSECT_LEN)      |
+			HINIC_SQ_CTRL_SET(SQ_NORMAL_WQE, DATA_FORMAT)   |
+			HINIC_SQ_CTRL_SET(ctrl_size, LEN);
+
+	ctrl->queue_info = HINIC_SQ_CTRL_SET(TX_MAX_MSS_DEFAULT,
+					     QUEUE_INFO_MSS);
+}
+
+static void sq_prepare_task(struct hinic_sq_task *task)
+{
+	task->pkt_info0 =
+		HINIC_SQ_TASK_INFO0_SET(0, L2HDR_LEN) |
+		HINIC_SQ_TASK_INFO0_SET(HINIC_L4_OFF_DISABLE, L4_OFFLOAD) |
+		HINIC_SQ_TASK_INFO0_SET(HINIC_OUTER_L3TYPE_UNKNOWN,
+					INNER_L3TYPE) |
+		HINIC_SQ_TASK_INFO0_SET(HINIC_VLAN_OFF_DISABLE,
+					VLAN_OFFLOAD) |
+		HINIC_SQ_TASK_INFO0_SET(HINIC_PKT_NOT_PARSED, PARSE_FLAG);
+
+	task->pkt_info1 =
+		HINIC_SQ_TASK_INFO1_SET(HINIC_MEDIA_UNKNOWN, MEDIA_TYPE) |
+		HINIC_SQ_TASK_INFO1_SET(0, INNER_L4_LEN) |
+		HINIC_SQ_TASK_INFO1_SET(0, INNER_L3_LEN);
+
+	task->pkt_info2 =
+		HINIC_SQ_TASK_INFO2_SET(0, TUNNEL_L4_LEN) |
+		HINIC_SQ_TASK_INFO2_SET(0, OUTER_L3_LEN) |
+		HINIC_SQ_TASK_INFO2_SET(HINIC_TUNNEL_L4TYPE_UNKNOWN,
+					TUNNEL_L4TYPE) |
+		HINIC_SQ_TASK_INFO2_SET(HINIC_OUTER_L3TYPE_UNKNOWN,
+					OUTER_L3TYPE);
+
+	task->ufo_v6_identify = 0;
+
+	task->pkt_info4 = HINIC_SQ_TASK_INFO4_SET(HINIC_L2TYPE_ETH, L2TYPE);
+
+	task->zero_pad = 0;
+}
+
+/**
+ * hinic_sq_prepare_wqe - prepare wqe before insert to the queue
+ * @sq: send queue
+ * @prod_idx: pi value
+ * @sq_wqe: wqe to prepare
+ * @sges: sges for use by the wqe for send for buf addresses
+ * @nr_sges: number of sges
+ **/
+void hinic_sq_prepare_wqe(struct hinic_sq *sq, u16 prod_idx,
+			  struct hinic_sq_wqe *sq_wqe, struct hinic_sge *sges,
+			  int nr_sges)
+{
+	int i;
+
+	sq_prepare_ctrl(&sq_wqe->ctrl, prod_idx, nr_sges);
+
+	sq_prepare_task(&sq_wqe->task);
+
+	for (i = 0; i < nr_sges; i++)
+		sq_wqe->buf_descs[i].sge = sges[i];
+}
+
+/**
+ * sq_prepare_db - prepare doorbell to write
+ * @sq: send queue
+ * @prod_idx: pi value for the doorbell
+ * @cos: cos of the doorbell
+ *
+ * Return db value
+ **/
+static u32 sq_prepare_db(struct hinic_sq *sq, u16 prod_idx, unsigned int cos)
+{
+	struct hinic_qp *qp = container_of(sq, struct hinic_qp, sq);
+	int hi_prod_idx = SQ_DB_PI_HI(SQ_MASKED_IDX(sq, prod_idx));
+
+	/* Data should be written to HW in Big Endian Format */
+	return cpu_to_be32(HINIC_SQ_DB_INFO_SET(hi_prod_idx, PI_HI)     |
+			   HINIC_SQ_DB_INFO_SET(HINIC_DB_SQ_TYPE, TYPE) |
+			   HINIC_SQ_DB_INFO_SET(HINIC_DATA_PATH, PATH)  |
+			   HINIC_SQ_DB_INFO_SET(cos, COS)               |
+			   HINIC_SQ_DB_INFO_SET(qp->q_id, QID));
+}
+
+/**
+ * hinic_sq_write_db- write doorbell
+ * @sq: send queue
+ * @prod_idx: pi value for the doorbell
+ * @wqe_size: wqe size
+ * @cos: cos of the doorbell
+ **/
+void hinic_sq_write_db(struct hinic_sq *sq, u16 prod_idx, unsigned int wqe_size,
+		       unsigned int cos)
+{
+	struct hinic_wq *wq = sq->wq;
+
+	/* increment prod_idx to the next */
+	prod_idx += ALIGN(wqe_size, wq->wqebb_size) / wq->wqebb_size;
+
+	wmb();  /* Write all before the doorbell */
+
+	writel(sq_prepare_db(sq, prod_idx, cos), SQ_DB_ADDR(sq, prod_idx));
+}
+
+/**
+ * hinic_sq_get_wqe - get wqe ptr in the current pi and update the pi
+ * @sq: sq to get wqe from
+ * @wqe_size: wqe size
+ * @prod_idx: returned pi
+ *
+ * Return wqe pointer
+ **/
+struct hinic_sq_wqe *hinic_sq_get_wqe(struct hinic_sq *sq,
+				      unsigned int wqe_size, u16 *prod_idx)
+{
+	struct hinic_hw_wqe *hw_wqe = hinic_get_wqe(sq->wq, wqe_size,
+						    prod_idx);
+
+	if (IS_ERR(hw_wqe))
+		return NULL;
+
+	return &hw_wqe->sq_wqe;
+}
+
+/**
+ * hinic_sq_write_wqe - write the wqe to the sq
+ * @sq: send queue
+ * @prod_idx: pi of the wqe
+ * @sq_wqe: the wqe to write
+ * @skb: skb to save
+ * @wqe_size: the size of the wqe
+ **/
+void hinic_sq_write_wqe(struct hinic_sq *sq, u16 prod_idx,
+			struct hinic_sq_wqe *sq_wqe,
+			struct sk_buff *skb, unsigned int wqe_size)
+{
+	struct hinic_hw_wqe *hw_wqe = (struct hinic_hw_wqe *)sq_wqe;
+
+	sq->saved_skb[prod_idx] = skb;
+
+	/* The data in the HW should be in Big Endian Format */
+	hinic_cpu_to_be32(sq_wqe, wqe_size);
+
+	hinic_write_wqe(sq->wq, hw_wqe, wqe_size);
+}
+
+/**
+ * hinic_sq_read_wqe - read wqe ptr in the current ci and update the ci
+ * @sq: send queue
+ * @skb: return skb that was saved
+ * @wqe_size: the size of the wqe
+ * @cons_idx: consumer index of the wqe
+ *
+ * Return wqe in ci position
+ **/
+struct hinic_sq_wqe *hinic_sq_read_wqe(struct hinic_sq *sq,
+				       struct sk_buff **skb,
+				       unsigned int *wqe_size, u16 *cons_idx)
+{
+	struct hinic_hw_wqe *hw_wqe;
+	struct hinic_sq_wqe *sq_wqe;
+	struct hinic_sq_ctrl *ctrl;
+	struct hinic_wq *wq;
+	int buf_sect_len;
+	u32 ctrl_info;
+
+	/* read the ctrl section for getting wqe size */
+	hw_wqe = hinic_read_wqe(sq->wq, sizeof(struct hinic_sq_ctrl),
+				cons_idx);
+	if (IS_ERR(hw_wqe))
+		return NULL;
+
+	sq_wqe = &hw_wqe->sq_wqe;
+	ctrl = &sq_wqe->ctrl;
+	ctrl_info = be32_to_cpu(ctrl->ctrl_info);
+	buf_sect_len = HINIC_SQ_CTRL_GET(ctrl_info, BUFDESC_SECT_LEN);
+
+	*wqe_size = sizeof(*ctrl) + sizeof(sq_wqe->task);
+	*wqe_size += SECT_SIZE_FROM_8BYTES(buf_sect_len);
+
+	wq = sq->wq;
+	*wqe_size = ALIGN(*wqe_size, wq->wqebb_size);
+	*skb = sq->saved_skb[*cons_idx];
+
+	/* using the real wqe size to read wqe again */
+	hw_wqe = hinic_read_wqe(wq, *wqe_size, cons_idx);
+
+	return &hw_wqe->sq_wqe;
+}
+
+/**
+ * hinic_sq_put_wqe - release the ci for new wqes
+ * @sq: send queue
+ * @wqe_size: the size of the wqe
+ **/
+void hinic_sq_put_wqe(struct hinic_sq *sq, unsigned int wqe_size)
+{
+	hinic_put_wqe(sq->wq, wqe_size);
+}
+
+/**
+ * hinic_sq_get_sges - get sges from the wqe
+ * @sq_wqe: wqe to get the sges from its buffer addresses
+ * @sges: returned sges
+ * @nr_sges: number sges to return
+ **/
+void hinic_sq_get_sges(struct hinic_sq_wqe *sq_wqe, struct hinic_sge *sges,
+		       int nr_sges)
+{
+	int i;
+
+	for (i = 0; i < nr_sges && i < HINIC_MAX_SQ_BUFDESCS; i++) {
+		sges[i] = sq_wqe->buf_descs[i].sge;
+		hinic_be32_to_cpu(&sges[i], sizeof(sges[i]));
+	}
+}
+
 /**
  * hinic_rq_get_wqe - get wqe ptr in the current pi and update the pi
  * @rq: rq to get wqe from
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
index 1331bd4..0565edc 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
@@ -16,6 +16,7 @@
 #ifndef HINIC_HW_QP_H
 #define HINIC_HW_QP_H
 
+#include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/sizes.h>
 #include <linux/pci.h>
@@ -27,6 +28,22 @@
 #include "hinic_hw_wq.h"
 #include "hinic_hw_qp_ctxt.h"
 
+#define HINIC_SQ_DB_INFO_PI_HI_SHIFT            0
+#define HINIC_SQ_DB_INFO_QID_SHIFT              8
+#define HINIC_SQ_DB_INFO_PATH_SHIFT             23
+#define HINIC_SQ_DB_INFO_COS_SHIFT              24
+#define HINIC_SQ_DB_INFO_TYPE_SHIFT             27
+
+#define HINIC_SQ_DB_INFO_PI_HI_MASK             0xFF
+#define HINIC_SQ_DB_INFO_QID_MASK               0x3FF
+#define HINIC_SQ_DB_INFO_PATH_MASK              0x1
+#define HINIC_SQ_DB_INFO_COS_MASK               0x7
+#define HINIC_SQ_DB_INFO_TYPE_MASK              0x1F
+
+#define HINIC_SQ_DB_INFO_SET(val, member)       \
+		(((u32)(val) & HINIC_SQ_DB_INFO_##member##_MASK) \
+		 << HINIC_SQ_DB_INFO_##member##_SHIFT)
+
 #define HINIC_SQ_WQEBB_SIZE                     64
 #define HINIC_RQ_WQEBB_SIZE                     32
 
@@ -38,6 +55,12 @@
 
 #define HINIC_RX_BUF_SZ                         2048
 
+#define HINIC_MIN_TX_WQE_SIZE(wq)               \
+		ALIGN(HINIC_SQ_WQE_SIZE(1), (wq)->wqebb_size)
+
+#define HINIC_MIN_TX_NUM_WQEBBS(sq)             \
+		(HINIC_MIN_TX_WQE_SIZE((sq)->wq) / (sq)->wq->wqebb_size)
+
 struct hinic_sq {
 	struct hinic_hwif       *hwif;
 
@@ -101,8 +124,33 @@ int hinic_init_rq(struct hinic_rq *rq, struct hinic_hwif *hwif,
 
 void hinic_clean_rq(struct hinic_rq *rq);
 
+int hinic_get_sq_free_wqebbs(struct hinic_sq *sq);
+
 int hinic_get_rq_free_wqebbs(struct hinic_rq *rq);
 
+void hinic_sq_prepare_wqe(struct hinic_sq *sq, u16 prod_idx,
+			  struct hinic_sq_wqe *wqe, struct hinic_sge *sges,
+			  int nr_sges);
+
+void hinic_sq_write_db(struct hinic_sq *sq, u16 prod_idx, unsigned int wqe_size,
+		       unsigned int cos);
+
+struct hinic_sq_wqe *hinic_sq_get_wqe(struct hinic_sq *sq,
+				      unsigned int wqe_size, u16 *prod_idx);
+
+void hinic_sq_write_wqe(struct hinic_sq *sq, u16 prod_idx,
+			struct hinic_sq_wqe *wqe, struct sk_buff *skb,
+			unsigned int wqe_size);
+
+struct hinic_sq_wqe *hinic_sq_read_wqe(struct hinic_sq *sq,
+				       struct sk_buff **skb,
+				       unsigned int *wqe_size, u16 *cons_idx);
+
+void hinic_sq_put_wqe(struct hinic_sq *sq, unsigned int wqe_size);
+
+void hinic_sq_get_sges(struct hinic_sq_wqe *wqe, struct hinic_sge *sges,
+		       int nr_sges);
+
 struct hinic_rq_wqe *hinic_rq_get_wqe(struct hinic_rq *rq,
 				      unsigned int wqe_size, u16 *prod_idx);
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
index 053e5f3..4a5f23f 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
@@ -43,6 +43,10 @@
 MODULE_DESCRIPTION("Huawei Intelligent NIC driver");
 MODULE_LICENSE("GPL");
 
+static unsigned int tx_weight = 64;
+module_param(tx_weight, uint, 0644);
+MODULE_PARM_DESC(tx_weight, "Number Tx packets for NAPI budget (default=64)");
+
 static unsigned int rx_weight = 64;
 module_param(rx_weight, uint, 0644);
 MODULE_PARM_DESC(rx_weight, "Number Rx packets for NAPI budget (default=64)");
@@ -569,9 +573,11 @@ static void hinic_set_rx_mode(struct net_device *netdev)
 	queue_work(nic_dev->workq, &rx_mode_work->work);
 }
 
-netdev_tx_t hinic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static void hinic_tx_timeout(struct net_device *netdev)
 {
-	return NETDEV_TX_BUSY;
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+
+	netif_err(nic_dev, drv, netdev, "Tx timeout\n");
 }
 
 static const struct net_device_ops hinic_netdev_ops = {
@@ -584,6 +590,7 @@ netdev_tx_t hinic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	.ndo_vlan_rx_kill_vid = hinic_vlan_rx_kill_vid,
 	.ndo_set_rx_mode = hinic_set_rx_mode,
 	.ndo_start_xmit = hinic_xmit_frame,
+	.ndo_tx_timeout = hinic_tx_timeout,
 	/* more operations should be filled */
 };
 
@@ -690,6 +697,7 @@ static int nic_dev_init(struct pci_dev *pdev)
 	nic_dev->flags = 0;
 	nic_dev->txqs = NULL;
 	nic_dev->rxqs = NULL;
+	nic_dev->tx_weight = tx_weight;
 	nic_dev->rx_weight = rx_weight;
 
 	sema_init(&nic_dev->mgmt_lock, 1);
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_tx.c b/drivers/net/ethernet/huawei/hinic/hinic_tx.c
index 9c27fb2..d0c539f 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_tx.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_tx.c
@@ -13,12 +13,42 @@
  *
  */
 
+#include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/u64_stats_sync.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/dma-mapping.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/skbuff.h>
+#include <linux/smp.h>
+#include <asm/byteorder.h>
 
+#include "hinic_common.h"
+#include "hinic_hw_if.h"
+#include "hinic_hw_wqe.h"
+#include "hinic_hw_wq.h"
 #include "hinic_hw_qp.h"
+#include "hinic_hw_dev.h"
+#include "hinic_dev.h"
 #include "hinic_tx.h"
 
+#define TX_IRQ_NO_PENDING               0
+#define TX_IRQ_NO_COALESC               0
+#define TX_IRQ_NO_LLI_TIMER             0
+#define TX_IRQ_NO_CREDIT                0
+#define TX_IRQ_NO_RESEND_TIMER          0
+
+#define CI_UPDATE_NO_PENDING            0
+#define CI_UPDATE_NO_COALESC            0
+
+#define HW_CONS_IDX(sq)         be16_to_cpu(*(u16 *)((sq)->hw_ci_addr))
+
+#define MIN_SKB_LEN             64
+
 /**
  * hinic_txq_clean_stats - Clean the statistics of specific queue
  * @txq: Logical Tx Queue
@@ -49,6 +79,321 @@ static void txq_stats_init(struct hinic_txq *txq)
 }
 
 /**
+ * tx_map_skb - dma mapping for skb and return sges
+ * @nic_dev: nic device
+ * @skb: the skb
+ * @sges: returned sges
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int tx_map_skb(struct hinic_dev *nic_dev, struct sk_buff *skb,
+		      struct hinic_sge *sges)
+{
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct skb_frag_struct *frag;
+	dma_addr_t dma_addr;
+	int i, j;
+
+	dma_addr = dma_map_single(&pdev->dev, skb->data, skb_headlen(skb),
+				  DMA_TO_DEVICE);
+	if (dma_mapping_error(&pdev->dev, dma_addr)) {
+		dev_err(&pdev->dev, "Failed to map Tx skb data\n");
+		return -EFAULT;
+	}
+
+	hinic_set_sge(&sges[0], dma_addr, skb_headlen(skb));
+
+	for (i = 0 ; i < skb_shinfo(skb)->nr_frags; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+
+		dma_addr = skb_frag_dma_map(&pdev->dev, frag, 0,
+					    skb_frag_size(frag),
+					    DMA_TO_DEVICE);
+		if (dma_mapping_error(&pdev->dev, dma_addr)) {
+			dev_err(&pdev->dev, "Failed to map Tx skb frag\n");
+			goto err_tx_map;
+		}
+
+		hinic_set_sge(&sges[i + 1], dma_addr, skb_frag_size(frag));
+	}
+
+	return 0;
+
+err_tx_map:
+	for (j = 0; j < i; j++)
+		dma_unmap_page(&pdev->dev, hinic_sge_to_dma(&sges[j + 1]),
+			       sges[j + 1].len, DMA_TO_DEVICE);
+
+	dma_unmap_single(&pdev->dev, hinic_sge_to_dma(&sges[0]), sges[0].len,
+			 DMA_TO_DEVICE);
+	return -EFAULT;
+}
+
+/**
+ * tx_unmap_skb - unmap the dma address of the skb
+ * @nic_dev: nic device
+ * @skb: the skb
+ * @sges: the sges that are connected to the skb
+ **/
+static void tx_unmap_skb(struct hinic_dev *nic_dev, struct sk_buff *skb,
+			 struct hinic_sge *sges)
+{
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int i;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags ; i++)
+		dma_unmap_page(&pdev->dev, hinic_sge_to_dma(&sges[i + 1]),
+			       sges[i + 1].len, DMA_TO_DEVICE);
+
+	dma_unmap_single(&pdev->dev, hinic_sge_to_dma(&sges[0]), sges[0].len,
+			 DMA_TO_DEVICE);
+}
+
+netdev_tx_t hinic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	struct netdev_queue *netdev_txq;
+	int nr_sges, err = NETDEV_TX_OK;
+	struct hinic_sq_wqe *sq_wqe;
+	unsigned int wqe_size;
+	struct hinic_txq *txq;
+	struct hinic_qp *qp;
+	u16 prod_idx;
+
+	txq = &nic_dev->txqs[skb->queue_mapping];
+	qp = container_of(txq->sq, struct hinic_qp, sq);
+
+	if (skb->len < MIN_SKB_LEN) {
+		if (skb_pad(skb, MIN_SKB_LEN - skb->len)) {
+			netdev_err(netdev, "Failed to pad skb\n");
+			goto skb_error;
+		}
+
+		skb->len = MIN_SKB_LEN;
+	}
+
+	nr_sges = skb_shinfo(skb)->nr_frags + 1;
+	if (nr_sges > txq->max_sges) {
+		netdev_err(netdev, "Too many Tx sges\n");
+		goto skb_error;
+	}
+
+	err = tx_map_skb(nic_dev, skb, txq->sges);
+	if (err)
+		goto skb_error;
+
+	wqe_size = HINIC_SQ_WQE_SIZE(nr_sges);
+
+	sq_wqe = hinic_sq_get_wqe(txq->sq, wqe_size, &prod_idx);
+	if (!sq_wqe) {
+		tx_unmap_skb(nic_dev, skb, txq->sges);
+
+		netif_stop_subqueue(netdev, qp->q_id);
+
+		u64_stats_update_begin(&txq->txq_stats.syncp);
+		txq->txq_stats.tx_busy++;
+		u64_stats_update_end(&txq->txq_stats.syncp);
+		err = NETDEV_TX_BUSY;
+		goto flush_skbs;
+	}
+
+	hinic_sq_prepare_wqe(txq->sq, prod_idx, sq_wqe, txq->sges, nr_sges);
+
+	hinic_sq_write_wqe(txq->sq, prod_idx, sq_wqe, skb, wqe_size);
+
+flush_skbs:
+	netdev_txq = netdev_get_tx_queue(netdev, skb->queue_mapping);
+	if ((!skb->xmit_more) || (netif_xmit_stopped(netdev_txq)))
+		hinic_sq_write_db(txq->sq, prod_idx, wqe_size, 0);
+	return err;
+
+skb_error:
+	dev_kfree_skb_any(skb);
+
+	u64_stats_update_begin(&txq->txq_stats.syncp);
+	txq->txq_stats.tx_dropped++;
+	u64_stats_update_end(&txq->txq_stats.syncp);
+	return err;
+}
+
+/**
+ * tx_free_skb - unmap and free skb
+ * @nic_dev: nic device
+ * @skb: the skb
+ * @sges: the sges that are connected to the skb
+ **/
+static void tx_free_skb(struct hinic_dev *nic_dev, struct sk_buff *skb,
+			struct hinic_sge *sges)
+{
+	tx_unmap_skb(nic_dev, skb, sges);
+
+	dev_kfree_skb_any(skb);
+}
+
+/**
+ * free_all_rx_skbs - free all skbs in tx queue
+ * @txq: tx queue
+ **/
+static void free_all_tx_skbs(struct hinic_txq *txq)
+{
+	struct hinic_dev *nic_dev = netdev_priv(txq->netdev);
+	struct hinic_sq *sq = txq->sq;
+	struct hinic_sq_wqe *sq_wqe;
+	unsigned int wqe_size;
+	struct sk_buff *skb;
+	int nr_sges;
+	u16 ci;
+
+	while ((sq_wqe = hinic_sq_read_wqe(sq, &skb, &wqe_size, &ci))) {
+		nr_sges = skb_shinfo(skb)->nr_frags + 1;
+
+		hinic_sq_get_sges(sq_wqe, txq->free_sges, nr_sges);
+
+		hinic_sq_put_wqe(sq, wqe_size);
+
+		tx_free_skb(nic_dev, skb, txq->free_sges);
+	}
+}
+
+/**
+ * free_tx_poll - free finished tx skbs in tx queue that connected to napi
+ * @napi: napi
+ * @budget: number of tx
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int free_tx_poll(struct napi_struct *napi, int budget)
+{
+	struct hinic_txq *txq = container_of(napi, struct hinic_txq, napi);
+	struct hinic_qp *qp = container_of(txq->sq, struct hinic_qp, sq);
+	struct hinic_dev *nic_dev = netdev_priv(txq->netdev);
+	struct netdev_queue *netdev_txq;
+	struct hinic_sq *sq = txq->sq;
+	struct hinic_wq *wq = sq->wq;
+	struct hinic_sq_wqe *sq_wqe;
+	unsigned int wqe_size;
+	int nr_sges, pkts = 0;
+	struct sk_buff *skb;
+	u64 tx_bytes = 0;
+	u16 hw_ci, sw_ci;
+
+	do {
+		hw_ci = HW_CONS_IDX(sq) & wq->mask;
+
+		sq_wqe = hinic_sq_read_wqe(sq, &skb, &wqe_size, &sw_ci);
+		if ((!sq_wqe) ||
+		    (((hw_ci - sw_ci) & wq->mask) * wq->wqebb_size < wqe_size))
+			break;
+
+		tx_bytes += skb->len;
+		pkts++;
+
+		nr_sges = skb_shinfo(skb)->nr_frags + 1;
+
+		hinic_sq_get_sges(sq_wqe, txq->free_sges, nr_sges);
+
+		hinic_sq_put_wqe(sq, wqe_size);
+
+		tx_free_skb(nic_dev, skb, txq->free_sges);
+	} while (pkts < budget);
+
+	if (__netif_subqueue_stopped(nic_dev->netdev, qp->q_id) &&
+	    hinic_get_sq_free_wqebbs(sq) >= HINIC_MIN_TX_NUM_WQEBBS(sq)) {
+		netdev_txq = netdev_get_tx_queue(txq->netdev, qp->q_id);
+
+		__netif_tx_lock(netdev_txq, smp_processor_id());
+
+		netif_wake_subqueue(nic_dev->netdev, qp->q_id);
+
+		__netif_tx_unlock(netdev_txq);
+
+		u64_stats_update_begin(&txq->txq_stats.syncp);
+		txq->txq_stats.tx_wake++;
+		u64_stats_update_end(&txq->txq_stats.syncp);
+	}
+
+	u64_stats_update_begin(&txq->txq_stats.syncp);
+	txq->txq_stats.bytes += tx_bytes;
+	txq->txq_stats.pkts += pkts;
+	u64_stats_update_end(&txq->txq_stats.syncp);
+
+	if (pkts < budget) {
+		napi_complete(napi);
+		enable_irq(sq->irq);
+		return pkts;
+	}
+
+	return budget;
+}
+
+static void tx_napi_add(struct hinic_txq *txq, int weight)
+{
+	netif_napi_add(txq->netdev, &txq->napi, free_tx_poll, weight);
+	napi_enable(&txq->napi);
+}
+
+static void tx_napi_del(struct hinic_txq *txq)
+{
+	napi_disable(&txq->napi);
+	netif_napi_del(&txq->napi);
+}
+
+static irqreturn_t tx_irq(int irq, void *data)
+{
+	struct hinic_txq *txq = (struct hinic_txq *)data;
+	struct hinic_sq *sq = txq->sq;
+	struct hinic_dev *nic_dev;
+
+	nic_dev = netdev_priv(txq->netdev);
+
+	/* Disable the interrupt until napi will be completed */
+	disable_irq_nosync(sq->irq);
+
+	hinic_hwdev_msix_cnt_set(nic_dev->hwdev, sq->msix_entry);
+
+	napi_schedule(&txq->napi);
+	return IRQ_HANDLED;
+}
+
+static int tx_request_irq(struct hinic_txq *txq)
+{
+	struct hinic_dev *nic_dev = netdev_priv(txq->netdev);
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_sq *sq = txq->sq;
+	int err;
+
+	tx_napi_add(txq, nic_dev->tx_weight);
+
+	hinic_hwdev_msix_set(nic_dev->hwdev, sq->msix_entry,
+			     TX_IRQ_NO_PENDING, TX_IRQ_NO_COALESC,
+			     TX_IRQ_NO_LLI_TIMER, TX_IRQ_NO_CREDIT,
+			     TX_IRQ_NO_RESEND_TIMER);
+
+	err = request_irq(sq->irq, tx_irq, 0, txq->irq_name, txq);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to request Tx irq\n");
+		tx_napi_del(txq);
+		return err;
+	}
+
+	return 0;
+}
+
+static void tx_free_irq(struct hinic_txq *txq)
+{
+	struct hinic_sq *sq = txq->sq;
+
+	free_irq(sq->irq, txq);
+	tx_napi_del(txq);
+}
+
+/**
  * hinic_init_txq - Initialize the Tx Queue
  * @txq: Logical Tx Queue
  * @sq: Hardware Tx Queue to connect the Logical queue with
@@ -59,11 +404,63 @@ static void txq_stats_init(struct hinic_txq *txq)
 int hinic_init_txq(struct hinic_txq *txq, struct hinic_sq *sq,
 		   struct net_device *netdev)
 {
+	struct hinic_qp *qp = container_of(sq, struct hinic_qp, sq);
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	int err, irqname_len;
+	size_t sges_size;
+
 	txq->netdev = netdev;
 	txq->sq = sq;
 
 	txq_stats_init(txq);
+
+	txq->max_sges = HINIC_MAX_SQ_BUFDESCS;
+
+	sges_size = txq->max_sges * sizeof(*txq->sges);
+	txq->sges = devm_kzalloc(&netdev->dev, sges_size, GFP_KERNEL);
+	if (!txq->sges)
+		return -ENOMEM;
+
+	sges_size = txq->max_sges * sizeof(*txq->free_sges);
+	txq->free_sges = devm_kzalloc(&netdev->dev, sges_size, GFP_KERNEL);
+	if (!txq->free_sges) {
+		err = -ENOMEM;
+		goto err_alloc_free_sges;
+	}
+
+	irqname_len = snprintf(NULL, 0, "hinic_txq%d", qp->q_id) + 1;
+	txq->irq_name = devm_kzalloc(&netdev->dev, irqname_len, GFP_KERNEL);
+	if (!txq->irq_name) {
+		err = -ENOMEM;
+		goto err_alloc_irqname;
+	}
+
+	sprintf(txq->irq_name, "hinic_txq%d", qp->q_id);
+
+	err = hinic_hwdev_hw_ci_addr_set(hwdev, sq, CI_UPDATE_NO_PENDING,
+					 CI_UPDATE_NO_COALESC);
+	if (err)
+		goto err_hw_ci;
+
+	err = tx_request_irq(txq);
+	if (err) {
+		netdev_err(netdev, "Failed to request Tx irq\n");
+		goto err_req_tx_irq;
+	}
+
 	return 0;
+
+err_req_tx_irq:
+err_hw_ci:
+	devm_kfree(&netdev->dev, txq->irq_name);
+
+err_alloc_irqname:
+	devm_kfree(&netdev->dev, txq->free_sges);
+
+err_alloc_free_sges:
+	devm_kfree(&netdev->dev, txq->sges);
+	return err;
 }
 
 /**
@@ -72,4 +469,13 @@ int hinic_init_txq(struct hinic_txq *txq, struct hinic_sq *sq,
  **/
 void hinic_clean_txq(struct hinic_txq *txq)
 {
+	struct net_device *netdev = txq->netdev;
+
+	tx_free_irq(txq);
+
+	free_all_tx_skbs(txq);
+
+	devm_kfree(&netdev->dev, txq->irq_name);
+	devm_kfree(&netdev->dev, txq->free_sges);
+	devm_kfree(&netdev->dev, txq->sges);
 }
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_tx.h b/drivers/net/ethernet/huawei/hinic/hinic_tx.h
index bbdb4b6..7123c7f 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_tx.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_tx.h
@@ -18,8 +18,10 @@
 
 #include <linux/types.h>
 #include <linux/netdevice.h>
+#include <linux/skbuff.h>
 #include <linux/u64_stats_sync.h>
 
+#include "hinic_common.h"
 #include "hinic_hw_qp.h"
 
 struct hinic_txq_stats {
@@ -37,10 +39,19 @@ struct hinic_txq {
 	struct hinic_sq         *sq;
 
 	struct hinic_txq_stats  txq_stats;
+
+	int                     max_sges;
+	struct hinic_sge        *sges;
+	struct hinic_sge        *free_sges;
+
+	char                    *irq_name;
+	struct napi_struct      napi;
 };
 
 void hinic_txq_clean_stats(struct hinic_txq *txq);
 
+netdev_tx_t hinic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+
 int hinic_init_txq(struct hinic_txq *txq, struct hinic_sq *sq,
 		   struct net_device *netdev);
 
-- 
1.9.1
