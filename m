From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V5 net-next 18/21] net-next/hinic: Add Rx handler
Date: Thu, 17 Aug 2017 19:52:59 +0800
Message-ID: <222870d63a101da50562ba6c85d24910ac1b09a7.1502970631.git.aviad.krawczyk@huawei.com>
References: <cover.1502970631.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:3597 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752900AbdHQLzb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 07:55:31 -0400
In-Reply-To: <cover.1502970631.git.aviad.krawczyk@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the io resources in the nic and handle rx events by qp operations.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_dev.h     |   1 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h  |   1 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c  | 361 +++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h  |  77 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.c   |  36 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h   |  35 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h |  13 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c   | 210 +++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h   |  29 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c   |  12 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h   |   2 +
 drivers/net/ethernet/huawei/hinic/hinic_main.c    |  27 ++
 drivers/net/ethernet/huawei/hinic/hinic_port.c    |  32 ++
 drivers/net/ethernet/huawei/hinic/hinic_port.h    |  19 +
 drivers/net/ethernet/huawei/hinic/hinic_rx.c      | 419 ++++++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_rx.h      |   7 +
 16 files changed, 1281 insertions(+)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
index 5b8231d..3d0f6cf 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
@@ -43,6 +43,7 @@ struct hinic_dev {
 	struct hinic_hwdev              *hwdev;
 
 	u32                             msg_enable;
+	unsigned int                    rx_weight;
 
 	unsigned int                    flags;
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
index 10b8c7b..f39b184 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
@@ -20,6 +20,7 @@
 #define HINIC_CSR_FUNC_ATTR0_ADDR                       0x0
 #define HINIC_CSR_FUNC_ATTR1_ADDR                       0x4
 
+#define HINIC_CSR_FUNC_ATTR4_ADDR                       0x10
 #define HINIC_CSR_FUNC_ATTR5_ADDR                       0x14
 
 #define HINIC_DMA_ATTR_BASE                             0xC80
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
index cb4c472..03149e8 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
@@ -20,6 +20,9 @@
 #include <linux/errno.h>
 #include <linux/slab.h>
 #include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/jiffies.h>
+#include <linux/log2.h>
 #include <linux/err.h>
 
 #include "hinic_hw_if.h"
@@ -30,6 +33,10 @@
 #include "hinic_hw_io.h"
 #include "hinic_hw_dev.h"
 
+#define IO_STATUS_TIMEOUT               100
+#define OUTBOUND_STATE_TIMEOUT          100
+#define DB_STATE_TIMEOUT                100
+
 #define MAX_IRQS(max_qps, num_aeqs, num_ceqs)   \
 		 (2 * (max_qps) + (num_aeqs) + (num_ceqs))
 
@@ -37,6 +44,15 @@ enum intr_type {
 	INTR_MSIX_TYPE,
 };
 
+enum io_status {
+	IO_STOPPED = 0,
+	IO_RUNNING = 1,
+};
+
+enum hw_ioctxt_set_cmdq_depth {
+	HW_IOCTXT_SET_CMDQ_DEPTH_DEFAULT,
+};
+
 /* HW struct */
 struct hinic_dev_cap {
 	u8      status;
@@ -51,6 +67,31 @@ struct hinic_dev_cap {
 	u8      rsvd3[208];
 };
 
+struct rx_buf_sz {
+	int     idx;
+	size_t  sz;
+};
+
+static struct rx_buf_sz rx_buf_sz_table[] = {
+	{0, 32},
+	{1, 64},
+	{2, 96},
+	{3, 128},
+	{4, 192},
+	{5, 256},
+	{6, 384},
+	{7, 512},
+	{8, 768},
+	{9, 1024},
+	{10, 1536},
+	{11, 2048},
+	{12, 3072},
+	{13, 4096},
+	{14, 8192},
+	{15, 16384},
+	{-1, -1},
+};
+
 /**
  * get_capability - convert device capabilities to NIC capabilities
  * @hwdev: the HW device to set and convert device capabilities for
@@ -236,6 +277,252 @@ int hinic_port_msg_cmd(struct hinic_hwdev *hwdev, enum hinic_port_cmd cmd,
 }
 
 /**
+ * init_fw_ctxt- Init Firmware tables before network mgmt and io operations
+ * @hwdev: the NIC HW device
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int init_fw_ctxt(struct hinic_hwdev *hwdev)
+{
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_cmd_fw_ctxt fw_ctxt;
+	struct hinic_pfhwdev *pfhwdev;
+	u16 out_size;
+	int err;
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "Unsupported PCI Function type\n");
+		return -EINVAL;
+	}
+
+	fw_ctxt.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+	fw_ctxt.rx_buf_sz = HINIC_RX_BUF_SZ;
+
+	pfhwdev = container_of(hwdev, struct hinic_pfhwdev, hwdev);
+
+	err = hinic_port_msg_cmd(hwdev, HINIC_PORT_CMD_FWCTXT_INIT,
+				 &fw_ctxt, sizeof(fw_ctxt),
+				 &fw_ctxt, &out_size);
+	if (err || (out_size != sizeof(fw_ctxt)) || fw_ctxt.status) {
+		dev_err(&pdev->dev, "Failed to init FW ctxt, ret = %d\n",
+			fw_ctxt.status);
+		return -EFAULT;
+	}
+
+	return 0;
+}
+
+/**
+ * set_hw_ioctxt - set the shape of the IO queues in FW
+ * @hwdev: the NIC HW device
+ * @rq_depth: rq depth
+ * @sq_depth: sq depth
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int set_hw_ioctxt(struct hinic_hwdev *hwdev, unsigned int rq_depth,
+			 unsigned int sq_depth)
+{
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct hinic_cmd_hw_ioctxt hw_ioctxt;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_pfhwdev *pfhwdev;
+	int i;
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "Unsupported PCI Function type\n");
+		return -EINVAL;
+	}
+
+	hw_ioctxt.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+
+	hw_ioctxt.set_cmdq_depth = HW_IOCTXT_SET_CMDQ_DEPTH_DEFAULT;
+	hw_ioctxt.cmdq_depth = 0;
+
+	hw_ioctxt.rq_depth  = ilog2(rq_depth);
+
+	for (i = 0; ; i++) {
+		if ((rx_buf_sz_table[i].sz == HINIC_RX_BUF_SZ) ||
+		    (rx_buf_sz_table[i].sz == -1)) {
+			hw_ioctxt.rx_buf_sz_idx = rx_buf_sz_table[i].idx;
+			break;
+		}
+	}
+
+	if (hw_ioctxt.rx_buf_sz_idx == -1)
+		return -EINVAL;
+
+	hw_ioctxt.sq_depth  = ilog2(sq_depth);
+
+	pfhwdev = container_of(hwdev, struct hinic_pfhwdev, hwdev);
+
+	return hinic_msg_to_mgmt(&pfhwdev->pf_to_mgmt, HINIC_MOD_COMM,
+				 HINIC_COMM_CMD_HWCTXT_SET,
+				 &hw_ioctxt, sizeof(hw_ioctxt), NULL,
+				 NULL, HINIC_MGMT_MSG_SYNC);
+}
+
+static int wait_for_outbound_state(struct hinic_hwdev *hwdev)
+{
+	enum hinic_outbound_state outbound_state;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	unsigned long end;
+
+	end = jiffies + msecs_to_jiffies(OUTBOUND_STATE_TIMEOUT);
+	do {
+		outbound_state = hinic_outbound_state_get(hwif);
+
+		if (outbound_state == HINIC_OUTBOUND_ENABLE)
+			return 0;
+
+		msleep(20);
+	} while (time_before(jiffies, end));
+
+	dev_err(&pdev->dev, "Wait for OUTBOUND - Timeout\n");
+	return -EFAULT;
+}
+
+static int wait_for_db_state(struct hinic_hwdev *hwdev)
+{
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	enum hinic_db_state db_state;
+	unsigned long end;
+
+	end = jiffies + msecs_to_jiffies(DB_STATE_TIMEOUT);
+	do {
+		db_state = hinic_db_state_get(hwif);
+
+		if (db_state == HINIC_DB_ENABLE)
+			return 0;
+
+		msleep(20);
+	} while (time_before(jiffies, end));
+
+	dev_err(&pdev->dev, "Wait for DB - Timeout\n");
+	return -EFAULT;
+}
+
+static int wait_for_io_stopped(struct hinic_hwdev *hwdev)
+{
+	struct hinic_cmd_io_status cmd_io_status;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_pfhwdev *pfhwdev;
+	unsigned long end;
+	u16 out_size;
+	int err;
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "Unsupported PCI Function type\n");
+		return -EINVAL;
+	}
+
+	pfhwdev = container_of(hwdev, struct hinic_pfhwdev, hwdev);
+
+	cmd_io_status.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+
+	end = jiffies + msecs_to_jiffies(IO_STATUS_TIMEOUT);
+	do {
+		err = hinic_msg_to_mgmt(&pfhwdev->pf_to_mgmt, HINIC_MOD_COMM,
+					HINIC_COMM_CMD_IO_STATUS_GET,
+					&cmd_io_status, sizeof(cmd_io_status),
+					&cmd_io_status, &out_size,
+					HINIC_MGMT_MSG_SYNC);
+		if ((err) || (out_size != sizeof(cmd_io_status))) {
+			dev_err(&pdev->dev, "Failed to get IO status, ret = %d\n",
+				err);
+			return err;
+		}
+
+		if (cmd_io_status.status == IO_STOPPED) {
+			dev_info(&pdev->dev, "IO stopped\n");
+			return 0;
+		}
+
+		msleep(20);
+	} while (time_before(jiffies, end));
+
+	dev_err(&pdev->dev, "Wait for IO stopped - Timeout\n");
+	return -ETIMEDOUT;
+}
+
+/**
+ * clear_io_resource - set the IO resources as not active in the NIC
+ * @hwdev: the NIC HW device
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int clear_io_resources(struct hinic_hwdev *hwdev)
+{
+	struct hinic_cmd_clear_io_res cmd_clear_io_res;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_pfhwdev *pfhwdev;
+	int err;
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "Unsupported PCI Function type\n");
+		return -EINVAL;
+	}
+
+	err = wait_for_io_stopped(hwdev);
+	if (err) {
+		dev_err(&pdev->dev, "IO has not stopped yet\n");
+		return err;
+	}
+
+	cmd_clear_io_res.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+
+	pfhwdev = container_of(hwdev, struct hinic_pfhwdev, hwdev);
+
+	err = hinic_msg_to_mgmt(&pfhwdev->pf_to_mgmt, HINIC_MOD_COMM,
+				HINIC_COMM_CMD_IO_RES_CLEAR, &cmd_clear_io_res,
+				sizeof(cmd_clear_io_res), NULL, NULL,
+				HINIC_MGMT_MSG_SYNC);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to clear IO resources\n");
+		return err;
+	}
+
+	return 0;
+}
+
+/**
+ * set_resources_state - set the state of the resources in the NIC
+ * @hwdev: the NIC HW device
+ * @state: the state to set
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int set_resources_state(struct hinic_hwdev *hwdev,
+			       enum hinic_res_state state)
+{
+	struct hinic_cmd_set_res_state res_state;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_pfhwdev *pfhwdev;
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "Unsupported PCI Function type\n");
+		return -EINVAL;
+	}
+
+	res_state.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+	res_state.state = state;
+
+	pfhwdev = container_of(hwdev, struct hinic_pfhwdev, hwdev);
+
+	return hinic_msg_to_mgmt(&pfhwdev->pf_to_mgmt,
+				 HINIC_MOD_COMM,
+				 HINIC_COMM_CMD_RES_STATE_SET,
+				 &res_state, sizeof(res_state), NULL,
+				 NULL, HINIC_MGMT_MSG_SYNC);
+}
+
+/**
  * get_base_qpn - get the first qp number
  * @hwdev: the NIC HW device
  * @base_qpn: returned qp number
@@ -312,8 +599,23 @@ int hinic_hwdev_ifup(struct hinic_hwdev *hwdev)
 		goto err_create_qps;
 	}
 
+	err = wait_for_db_state(hwdev);
+	if (err) {
+		dev_warn(&pdev->dev, "db - disabled, try again\n");
+		hinic_db_state_set(hwif, HINIC_DB_ENABLE);
+	}
+
+	err = set_hw_ioctxt(hwdev, HINIC_SQ_DEPTH, HINIC_RQ_DEPTH);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to set HW IO ctxt\n");
+		goto err_hw_ioctxt;
+	}
+
 	return 0;
 
+err_hw_ioctxt:
+	hinic_io_destroy_qps(func_to_io, num_qps);
+
 err_create_qps:
 	hinic_io_free(func_to_io);
 	return err;
@@ -329,6 +631,8 @@ void hinic_hwdev_ifdown(struct hinic_hwdev *hwdev)
 	struct hinic_func_to_io *func_to_io = &hwdev->func_to_io;
 	struct hinic_cap *nic_cap = &hwdev->nic_cap;
 
+	clear_io_resources(hwdev);
+
 	hinic_io_destroy_qps(func_to_io, nic_cap->num_qps);
 	hinic_io_free(func_to_io);
 }
@@ -528,6 +832,12 @@ struct hinic_hwdev *hinic_init_hwdev(struct pci_dev *pdev)
 		goto err_init_msix;
 	}
 
+	err = wait_for_outbound_state(hwdev);
+	if (err) {
+		dev_warn(&pdev->dev, "outbound - disabled, try again\n");
+		hinic_outbound_state_set(hwif, HINIC_OUTBOUND_ENABLE);
+	}
+
 	num_aeqs = HINIC_HWIF_NUM_AEQS(hwif);
 
 	err = hinic_aeqs_init(&hwdev->aeqs, hwif, num_aeqs,
@@ -550,8 +860,22 @@ struct hinic_hwdev *hinic_init_hwdev(struct pci_dev *pdev)
 		goto err_dev_cap;
 	}
 
+	err = init_fw_ctxt(hwdev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init function table\n");
+		goto err_init_fw_ctxt;
+	}
+
+	err = set_resources_state(hwdev, HINIC_RES_ACTIVE);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to set resources state\n");
+		goto err_resources_state;
+	}
+
 	return hwdev;
 
+err_resources_state:
+err_init_fw_ctxt:
 err_dev_cap:
 	free_pfhwdev(pfhwdev);
 
@@ -578,6 +902,8 @@ void hinic_free_hwdev(struct hinic_hwdev *hwdev)
 						     struct hinic_pfhwdev,
 						     hwdev);
 
+	set_resources_state(hwdev, HINIC_RES_CLEAN);
+
 	free_pfhwdev(pfhwdev);
 
 	hinic_aeqs_free(&hwdev->aeqs);
@@ -635,3 +961,38 @@ struct hinic_rq *hinic_hwdev_get_rq(struct hinic_hwdev *hwdev, int i)
 
 	return &qp->rq;
 }
+
+/**
+ * hinic_hwdev_msix_cnt_set - clear message attribute counters for msix entry
+ * @hwdev: the NIC HW device
+ * @msix_index: msix_index
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_hwdev_msix_cnt_set(struct hinic_hwdev *hwdev, u16 msix_index)
+{
+	return hinic_msix_attr_cnt_clear(hwdev->hwif, msix_index);
+}
+
+/**
+ * hinic_hwdev_msix_set - set message attribute for msix entry
+ * @hwdev: the NIC HW device
+ * @msix_index: msix_index
+ * @pending_limit: the maximum pending interrupt events (unit 8)
+ * @coalesc_timer: coalesc period for interrupt (unit 8 us)
+ * @lli_timer: replenishing period for low latency credit (unit 8 us)
+ * @lli_credit_limit: maximum credits for low latency msix messages (unit 8)
+ * @resend_timer: maximum wait for resending msix (unit coalesc period)
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_hwdev_msix_set(struct hinic_hwdev *hwdev, u16 msix_index,
+			 u8 pending_limit, u8 coalesc_timer,
+			 u8 lli_timer_cfg, u8 lli_credit_limit,
+			 u8 resend_timer)
+{
+	return hinic_msix_attr_set(hwdev->hwif, msix_index,
+				   pending_limit, coalesc_timer,
+				   lli_timer_cfg, lli_credit_limit,
+				   resend_timer);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
index 81c2c6e..e7277d1 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
@@ -74,6 +74,76 @@ enum hinic_cb_state {
 	HINIC_CB_RUNNING = BIT(1),
 };
 
+enum hinic_res_state {
+	HINIC_RES_CLEAN         = 0,
+	HINIC_RES_ACTIVE        = 1,
+};
+
+struct hinic_cmd_fw_ctxt {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+	u16     rx_buf_sz;
+
+	u32     rsvd1;
+};
+
+struct hinic_cmd_hw_ioctxt {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+
+	u16     rsvd1;
+
+	u8      set_cmdq_depth;
+	u8      cmdq_depth;
+
+	u8      rsvd2;
+	u8      rsvd3;
+	u8      rsvd4;
+	u8      rsvd5;
+
+	u16     rq_depth;
+	u16     rx_buf_sz_idx;
+	u16     sq_depth;
+};
+
+struct hinic_cmd_io_status {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+	u8      rsvd1;
+	u8      rsvd2;
+	u32     io_status;
+};
+
+struct hinic_cmd_clear_io_res {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+	u8      rsvd1;
+	u8      rsvd2;
+};
+
+struct hinic_cmd_set_res_state {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+	u8      state;
+	u8      rsvd1;
+	u32     rsvd2;
+};
+
 struct hinic_cmd_base_qpn {
 	u8      status;
 	u8      version;
@@ -137,4 +207,11 @@ int hinic_port_msg_cmd(struct hinic_hwdev *hwdev, enum hinic_port_cmd cmd,
 
 struct hinic_rq *hinic_hwdev_get_rq(struct hinic_hwdev *hwdev, int i);
 
+int hinic_hwdev_msix_cnt_set(struct hinic_hwdev *hwdev, u16 msix_index);
+
+int hinic_hwdev_msix_set(struct hinic_hwdev *hwdev, u16 msix_index,
+			 u8 pending_limit, u8 coalesc_timer,
+			 u8 lli_timer_cfg, u8 lli_credit_limit,
+			 u8 resend_timer);
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
index d4e6ec4..effca4e 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
@@ -133,6 +133,42 @@ void hinic_set_pf_action(struct hinic_hwif *hwif, enum hinic_pf_action action)
 	hinic_hwif_write_reg(hwif, HINIC_CSR_FUNC_ATTR5_ADDR, attr5);
 }
 
+enum hinic_outbound_state hinic_outbound_state_get(struct hinic_hwif *hwif)
+{
+	u32 attr4 = hinic_hwif_read_reg(hwif, HINIC_CSR_FUNC_ATTR4_ADDR);
+
+	return HINIC_FA4_GET(attr4, OUTBOUND_STATE);
+}
+
+void hinic_outbound_state_set(struct hinic_hwif *hwif,
+			      enum hinic_outbound_state outbound_state)
+{
+	u32 attr4 = hinic_hwif_read_reg(hwif, HINIC_CSR_FUNC_ATTR4_ADDR);
+
+	attr4 = HINIC_FA4_CLEAR(attr4, OUTBOUND_STATE);
+	attr4 |= HINIC_FA4_SET(outbound_state, OUTBOUND_STATE);
+
+	hinic_hwif_write_reg(hwif, HINIC_CSR_FUNC_ATTR4_ADDR, attr4);
+}
+
+enum hinic_db_state hinic_db_state_get(struct hinic_hwif *hwif)
+{
+	u32 attr4 = hinic_hwif_read_reg(hwif, HINIC_CSR_FUNC_ATTR4_ADDR);
+
+	return HINIC_FA4_GET(attr4, DB_STATE);
+}
+
+void hinic_db_state_set(struct hinic_hwif *hwif,
+			enum hinic_db_state db_state)
+{
+	u32 attr4 = hinic_hwif_read_reg(hwif, HINIC_CSR_FUNC_ATTR4_ADDR);
+
+	attr4 = HINIC_FA4_CLEAR(attr4, DB_STATE);
+	attr4 |= HINIC_FA4_SET(db_state, DB_STATE);
+
+	hinic_hwif_write_reg(hwif, HINIC_CSR_FUNC_ATTR4_ADDR, attr4);
+}
+
 /**
  * hwif_ready - test if the HW is ready for use
  * @hwif: the HW interface of a pci function device
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
index 8f59195..5b4760c 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
@@ -73,6 +73,21 @@
 #define HINIC_FA1_GET(val, member)                              \
 	(((val) >> HINIC_FA1_##member##_SHIFT) & HINIC_FA1_##member##_MASK)
 
+#define HINIC_FA4_OUTBOUND_STATE_SHIFT                          0
+#define HINIC_FA4_DB_STATE_SHIFT                                1
+
+#define HINIC_FA4_OUTBOUND_STATE_MASK                           0x1
+#define HINIC_FA4_DB_STATE_MASK                                 0x1
+
+#define HINIC_FA4_GET(val, member)                              \
+	(((val) >> HINIC_FA4_##member##_SHIFT) & HINIC_FA4_##member##_MASK)
+
+#define HINIC_FA4_SET(val, member)                              \
+	((((u32)val) & HINIC_FA4_##member##_MASK) << HINIC_FA4_##member##_SHIFT)
+
+#define HINIC_FA4_CLEAR(val, member)                            \
+	((val) & (~(HINIC_FA4_##member##_MASK << HINIC_FA4_##member##_SHIFT)))
+
 #define HINIC_FA5_PF_ACTION_SHIFT                               0
 #define HINIC_FA5_PF_ACTION_MASK                                0xFFFF
 
@@ -182,6 +197,16 @@ enum hinic_pf_action {
 	HINIC_PF_MGMT_ACTIVE = 0x11,
 };
 
+enum hinic_outbound_state {
+	HINIC_OUTBOUND_ENABLE  = 0,
+	HINIC_OUTBOUND_DISABLE = 1,
+};
+
+enum hinic_db_state {
+	HINIC_DB_ENABLE  = 0,
+	HINIC_DB_DISABLE = 1,
+};
+
 struct hinic_func_attr {
 	u16                     func_idx;
 	u8                      pf_idx;
@@ -230,6 +255,16 @@ int hinic_msix_attr_get(struct hinic_hwif *hwif, u16 msix_index,
 
 void hinic_set_pf_action(struct hinic_hwif *hwif, enum hinic_pf_action action);
 
+enum hinic_outbound_state hinic_outbound_state_get(struct hinic_hwif *hwif);
+
+void hinic_outbound_state_set(struct hinic_hwif *hwif,
+			      enum hinic_outbound_state outbound_state);
+
+enum hinic_db_state hinic_db_state_get(struct hinic_hwif *hwif);
+
+void hinic_db_state_set(struct hinic_hwif *hwif,
+			enum hinic_db_state db_state);
+
 int hinic_init_hwif(struct hinic_hwif *hwif, struct pci_dev *pdev);
 
 void hinic_free_hwif(struct hinic_hwif *hwif);
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
index 90116c2..320711e 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
@@ -69,8 +69,21 @@ enum hinic_cfg_cmd {
 };
 
 enum hinic_comm_cmd {
+	HINIC_COMM_CMD_IO_STATUS_GET    = 0x3,
+
 	HINIC_COMM_CMD_CMDQ_CTXT_SET    = 0x10,
 	HINIC_COMM_CMD_CMDQ_CTXT_GET    = 0x11,
+
+	HINIC_COMM_CMD_HWCTXT_SET       = 0x12,
+	HINIC_COMM_CMD_HWCTXT_GET       = 0x13,
+
+	HINIC_COMM_CMD_SQ_HI_CI_SET     = 0x14,
+
+	HINIC_COMM_CMD_RES_STATE_SET    = 0x24,
+
+	HINIC_COMM_CMD_IO_RES_CLEAR     = 0x29,
+
+	HINIC_COMM_CMD_MAX              = 0x32,
 };
 
 enum hinic_mgmt_cb_state {
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
index cfed040..6e540d2 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
@@ -22,10 +22,13 @@
 #include <linux/errno.h>
 #include <linux/sizes.h>
 #include <linux/atomic.h>
+#include <linux/skbuff.h>
+#include <asm/barrier.h>
 #include <asm/byteorder.h>
 
 #include "hinic_common.h"
 #include "hinic_hw_if.h"
+#include "hinic_hw_wqe.h"
 #include "hinic_hw_wq.h"
 #include "hinic_hw_qp_ctxt.h"
 #include "hinic_hw_qp.h"
@@ -51,6 +54,13 @@
 		 + (q_id) * Q_CTXT_SIZE)
 
 #define SIZE_16BYTES(size)      (ALIGN(size, 16) >> 4)
+#define SIZE_8BYTES(size)       (ALIGN(size, 8) >> 3)
+
+#define RQ_MASKED_IDX(rq, idx)  ((idx) & (rq)->wq->mask)
+
+enum rq_completion_fmt {
+	RQ_COMPLETE_SGE = 1
+};
 
 void hinic_qp_prepare_header(struct hinic_qp_ctxt_header *qp_ctxt_hdr,
 			     enum hinic_qp_ctxt_type ctxt_type,
@@ -423,3 +433,203 @@ void hinic_clean_rq(struct hinic_rq *rq)
 	free_rq_cqe(rq);
 	free_rq_skb_arr(rq);
 }
+
+/**
+ * hinic_get_rq_free_wqebbs - return number of free wqebbs for use
+ * @rq: recv queue
+ *
+ * Return number of free wqebbs
+ **/
+int hinic_get_rq_free_wqebbs(struct hinic_rq *rq)
+{
+	struct hinic_wq *wq = rq->wq;
+
+	return atomic_read(&wq->delta) - 1;
+}
+
+/**
+ * hinic_rq_get_wqe - get wqe ptr in the current pi and update the pi
+ * @rq: rq to get wqe from
+ * @wqe_size: wqe size
+ * @prod_idx: returned pi
+ *
+ * Return wqe pointer
+ **/
+struct hinic_rq_wqe *hinic_rq_get_wqe(struct hinic_rq *rq,
+				      unsigned int wqe_size, u16 *prod_idx)
+{
+	struct hinic_hw_wqe *hw_wqe = hinic_get_wqe(rq->wq, wqe_size,
+						    prod_idx);
+
+	if (IS_ERR(hw_wqe))
+		return NULL;
+
+	return &hw_wqe->rq_wqe;
+}
+
+/**
+ * hinic_rq_write_wqe - write the wqe to the rq
+ * @rq: recv queue
+ * @prod_idx: pi of the wqe
+ * @rq_wqe: the wqe to write
+ * @skb: skb to save
+ **/
+void hinic_rq_write_wqe(struct hinic_rq *rq, u16 prod_idx,
+			struct hinic_rq_wqe *rq_wqe, struct sk_buff *skb)
+{
+	struct hinic_hw_wqe *hw_wqe = (struct hinic_hw_wqe *)rq_wqe;
+
+	rq->saved_skb[prod_idx] = skb;
+
+	/* The data in the HW should be in Big Endian Format */
+	hinic_cpu_to_be32(rq_wqe, sizeof(*rq_wqe));
+
+	hinic_write_wqe(rq->wq, hw_wqe, sizeof(*rq_wqe));
+}
+
+/**
+ * hinic_rq_read_wqe - read wqe ptr in the current ci and update the ci
+ * @rq: recv queue
+ * @wqe_size: the size of the wqe
+ * @skb: return saved skb
+ * @cons_idx: consumer index of the wqe
+ *
+ * Return wqe in ci position
+ **/
+struct hinic_rq_wqe *hinic_rq_read_wqe(struct hinic_rq *rq,
+				       unsigned int wqe_size,
+				       struct sk_buff **skb, u16 *cons_idx)
+{
+	struct hinic_hw_wqe *hw_wqe;
+	struct hinic_rq_cqe *cqe;
+	u32 status;
+	int rx_done;
+
+	hw_wqe = hinic_read_wqe(rq->wq, wqe_size, cons_idx);
+
+	if (IS_ERR(hw_wqe))
+		return NULL;
+
+	cqe = rq->cqe[*cons_idx];
+
+	status = be32_to_cpu(cqe->status);
+
+	rx_done = HINIC_RQ_CQE_STATUS_GET(status, RXDONE);
+	if (!rx_done)
+		return NULL;
+
+	*skb = rq->saved_skb[*cons_idx];
+
+	return &hw_wqe->rq_wqe;
+}
+
+/**
+ * hinic_rq_read_next_wqe - increment ci and read the wqe in ci position
+ * @rq: recv queue
+ * @wqe_size: the size of the wqe
+ * @skb: return saved skb
+ * @cons_idx: consumer index in the wq
+ *
+ * Return wqe in incremented ci position
+ **/
+struct hinic_rq_wqe *hinic_rq_read_next_wqe(struct hinic_rq *rq,
+					    unsigned int wqe_size,
+					    struct sk_buff **skb,
+					    u16 *cons_idx)
+{
+	struct hinic_wq *wq = rq->wq;
+	struct hinic_hw_wqe *hw_wqe;
+	unsigned int num_wqebbs;
+
+	wqe_size = ALIGN(wqe_size, wq->wqebb_size);
+	num_wqebbs = wqe_size / wq->wqebb_size;
+
+	*cons_idx = RQ_MASKED_IDX(rq, *cons_idx + num_wqebbs);
+
+	*skb = rq->saved_skb[*cons_idx];
+
+	hw_wqe = hinic_read_wqe_direct(wq, *cons_idx);
+
+	return &hw_wqe->rq_wqe;
+}
+
+/**
+ * hinic_put_wqe - release the ci for new wqes
+ * @rq: recv queue
+ * @cons_idx: consumer index of the wqe
+ * @wqe_size: the size of the wqe
+ **/
+void hinic_rq_put_wqe(struct hinic_rq *rq, u16 cons_idx,
+		      unsigned int wqe_size)
+{
+	struct hinic_rq_cqe *cqe = rq->cqe[cons_idx];
+	u32 status = be32_to_cpu(cqe->status);
+
+	status = HINIC_RQ_CQE_STATUS_CLEAR(status, RXDONE);
+
+	/* Rx WQE size is 1 WQEBB, no wq shadow*/
+	cqe->status = cpu_to_be32(status);
+
+	wmb();          /* clear done flag */
+
+	hinic_put_wqe(rq->wq, wqe_size);
+}
+
+/**
+ * hinic_rq_get_sge - get sge from the wqe
+ * @rq: recv queue
+ * @rq_wqe: wqe to get the sge from its buf address
+ * @cons_idx: consumer index
+ * @sge: returned sge
+ **/
+void hinic_rq_get_sge(struct hinic_rq *rq, struct hinic_rq_wqe *rq_wqe,
+		      u16 cons_idx, struct hinic_sge *sge)
+{
+	struct hinic_rq_cqe *cqe = rq->cqe[cons_idx];
+	u32 len = be32_to_cpu(cqe->len);
+
+	sge->hi_addr = be32_to_cpu(rq_wqe->buf_desc.hi_addr);
+	sge->lo_addr = be32_to_cpu(rq_wqe->buf_desc.lo_addr);
+	sge->len = HINIC_RQ_CQE_SGE_GET(len, LEN);
+}
+
+/**
+ * hinic_rq_prepare_wqe - prepare wqe before insert to the queue
+ * @rq: recv queue
+ * @prod_idx: pi value
+ * @rq_wqe: the wqe
+ * @sge: sge for use by the wqe for recv buf address
+ **/
+void hinic_rq_prepare_wqe(struct hinic_rq *rq, u16 prod_idx,
+			  struct hinic_rq_wqe *rq_wqe, struct hinic_sge *sge)
+{
+	struct hinic_rq_cqe_sect *cqe_sect = &rq_wqe->cqe_sect;
+	struct hinic_rq_bufdesc *buf_desc = &rq_wqe->buf_desc;
+	struct hinic_rq_ctrl *ctrl = &rq_wqe->ctrl;
+	dma_addr_t cqe_dma = rq->cqe_dma[prod_idx];
+
+	ctrl->ctrl_info =
+		HINIC_RQ_CTRL_SET(SIZE_8BYTES(sizeof(*ctrl)), LEN) |
+		HINIC_RQ_CTRL_SET(SIZE_8BYTES(sizeof(*cqe_sect)),
+				  COMPLETE_LEN)                    |
+		HINIC_RQ_CTRL_SET(SIZE_8BYTES(sizeof(*buf_desc)),
+				  BUFDESC_SECT_LEN)                |
+		HINIC_RQ_CTRL_SET(RQ_COMPLETE_SGE, COMPLETE_FORMAT);
+
+	hinic_set_sge(&cqe_sect->sge, cqe_dma, sizeof(struct hinic_rq_cqe));
+
+	buf_desc->hi_addr = sge->hi_addr;
+	buf_desc->lo_addr = sge->lo_addr;
+}
+
+/**
+ * hinic_rq_update - update pi of the rq
+ * @rq: recv queue
+ * @prod_idx: pi value
+ **/
+void hinic_rq_update(struct hinic_rq *rq, u16 prod_idx)
+{
+	struct hinic_wq *wq = rq->wq;
+
+	*rq->pi_virt_addr = cpu_to_be16((prod_idx + 1) & wq->mask);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
index eb10bd9..1331bd4 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
@@ -21,6 +21,7 @@
 #include <linux/pci.h>
 #include <linux/skbuff.h>
 
+#include "hinic_common.h"
 #include "hinic_hw_if.h"
 #include "hinic_hw_wqe.h"
 #include "hinic_hw_wq.h"
@@ -100,4 +101,32 @@ int hinic_init_rq(struct hinic_rq *rq, struct hinic_hwif *hwif,
 
 void hinic_clean_rq(struct hinic_rq *rq);
 
+int hinic_get_rq_free_wqebbs(struct hinic_rq *rq);
+
+struct hinic_rq_wqe *hinic_rq_get_wqe(struct hinic_rq *rq,
+				      unsigned int wqe_size, u16 *prod_idx);
+
+void hinic_rq_write_wqe(struct hinic_rq *rq, u16 prod_idx,
+			struct hinic_rq_wqe *wqe, struct sk_buff *skb);
+
+struct hinic_rq_wqe *hinic_rq_read_wqe(struct hinic_rq *rq,
+				       unsigned int wqe_size,
+				       struct sk_buff **skb, u16 *cons_idx);
+
+struct hinic_rq_wqe *hinic_rq_read_next_wqe(struct hinic_rq *rq,
+					    unsigned int wqe_size,
+					    struct sk_buff **skb,
+					    u16 *cons_idx);
+
+void hinic_rq_put_wqe(struct hinic_rq *rq, u16 cons_idx,
+		      unsigned int wqe_size);
+
+void hinic_rq_get_sge(struct hinic_rq *rq, struct hinic_rq_wqe *wqe,
+		      u16 cons_idx, struct hinic_sge *sge);
+
+void hinic_rq_prepare_wqe(struct hinic_rq *rq, u16 prod_idx,
+			  struct hinic_rq_wqe *wqe, struct hinic_sge *sge);
+
+void hinic_rq_update(struct hinic_rq *rq, u16 prod_idx);
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
index a22e201..1cb3745 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
@@ -828,6 +828,18 @@ struct hinic_hw_wqe *hinic_read_wqe(struct hinic_wq *wq, unsigned int wqe_size,
 }
 
 /**
+ * hinic_read_wqe_direct - read wqe directly from ci position
+ * @wq: wq
+ * @cons_idx: ci position
+ *
+ * Return wqe
+ **/
+struct hinic_hw_wqe *hinic_read_wqe_direct(struct hinic_wq *wq, u16 cons_idx)
+{
+	return WQ_PAGE_ADDR(wq, cons_idx) + WQE_PAGE_OFF(wq, cons_idx);
+}
+
+/**
  * wqe_shadow - check if a wqe is shadow
  * @wq: wq of the wqe
  * @wqe: the wqe for shadow checking
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
index f01477a..9c030a0 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
@@ -109,6 +109,8 @@ struct hinic_hw_wqe *hinic_get_wqe(struct hinic_wq *wq, unsigned int wqe_size,
 struct hinic_hw_wqe *hinic_read_wqe(struct hinic_wq *wq, unsigned int wqe_size,
 				    u16 *cons_idx);
 
+struct hinic_hw_wqe *hinic_read_wqe_direct(struct hinic_wq *wq, u16 cons_idx);
+
 void hinic_write_wqe(struct hinic_wq *wq, struct hinic_hw_wqe *wqe,
 		     unsigned int wqe_size);
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
index 914ce52..053e5f3 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
@@ -15,6 +15,7 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/pci.h>
 #include <linux/device.h>
 #include <linux/errno.h>
@@ -42,6 +43,10 @@
 MODULE_DESCRIPTION("Huawei Intelligent NIC driver");
 MODULE_LICENSE("GPL");
 
+static unsigned int rx_weight = 64;
+module_param(rx_weight, uint, 0644);
+MODULE_PARM_DESC(rx_weight, "Number Rx packets for NAPI budget (default=64)");
+
 #define PCI_DEVICE_ID_HI1822_PF         0x1822
 
 #define HINIC_WQ_NAME                   "hinic_dev"
@@ -220,6 +225,13 @@ static int hinic_open(struct net_device *netdev)
 		goto err_port_state;
 	}
 
+	err = hinic_port_set_func_state(nic_dev, HINIC_FUNC_PORT_ENABLE);
+	if (err) {
+		netif_err(nic_dev, drv, netdev,
+			  "Failed to set func port state\n");
+		goto err_func_port_state;
+	}
+
 	/* Wait up to 3 sec between port enable to link state */
 	msleep(3000);
 
@@ -250,6 +262,12 @@ static int hinic_open(struct net_device *netdev)
 
 err_port_link:
 	up(&nic_dev->mgmt_lock);
+	ret = hinic_port_set_func_state(nic_dev, HINIC_FUNC_PORT_DISABLE);
+	if (ret)
+		netif_warn(nic_dev, drv, netdev,
+			   "Failed to revert func port state\n");
+
+err_func_port_state:
 	ret = hinic_port_set_state(nic_dev, HINIC_PORT_DISABLE);
 	if (ret)
 		netif_warn(nic_dev, drv, netdev,
@@ -283,6 +301,14 @@ static int hinic_close(struct net_device *netdev)
 
 	up(&nic_dev->mgmt_lock);
 
+	err = hinic_port_set_func_state(nic_dev, HINIC_FUNC_PORT_DISABLE);
+	if (err) {
+		netif_err(nic_dev, drv, netdev,
+			  "Failed to set func port state\n");
+		nic_dev->flags |= (flags & HINIC_INTF_UP);
+		return err;
+	}
+
 	err = hinic_port_set_state(nic_dev, HINIC_PORT_DISABLE);
 	if (err) {
 		netif_err(nic_dev, drv, netdev, "Failed to set port state\n");
@@ -664,6 +690,7 @@ static int nic_dev_init(struct pci_dev *pdev)
 	nic_dev->flags = 0;
 	nic_dev->txqs = NULL;
 	nic_dev->rxqs = NULL;
+	nic_dev->rx_weight = rx_weight;
 
 	sema_init(&nic_dev->mgmt_lock, 1);
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_port.c b/drivers/net/ethernet/huawei/hinic/hinic_port.c
index 0dafede..528ec6f 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_port.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_port.c
@@ -314,3 +314,35 @@ int hinic_port_set_state(struct hinic_dev *nic_dev, enum hinic_port_state state)
 
 	return 0;
 }
+
+/**
+ * hinic_port_set_func_state- set func device state
+ * @nic_dev: nic device
+ * @state: the state to set
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_set_func_state(struct hinic_dev *nic_dev,
+			      enum hinic_func_port_state state)
+{
+	struct hinic_port_func_state_cmd func_state;
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	u16 out_size;
+	int err;
+
+	func_state.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+	func_state.state = state;
+
+	err = hinic_port_msg_cmd(hwdev, HINIC_PORT_CMD_SET_FUNC_STATE,
+				 &func_state, sizeof(func_state),
+				 &func_state, &out_size);
+	if (err || (out_size != sizeof(func_state)) || func_state.status) {
+		dev_err(&pdev->dev, "Failed to set port func state, ret = %d\n",
+			func_state.status);
+		return -EFAULT;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_port.h b/drivers/net/ethernet/huawei/hinic/hinic_port.h
index 3a8da8e..17f9d7fc 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_port.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_port.h
@@ -40,6 +40,11 @@ enum hinic_port_state {
 	HINIC_PORT_ENABLE       = 3,
 };
 
+enum hinic_func_port_state {
+	HINIC_FUNC_PORT_DISABLE = 0,
+	HINIC_FUNC_PORT_ENABLE  = 2,
+};
+
 struct hinic_port_mac_cmd {
 	u8              status;
 	u8              version;
@@ -109,6 +114,17 @@ struct hinic_port_link_status {
 	u8      rsvd2;
 };
 
+struct hinic_port_func_state_cmd {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+	u16     rsvd1;
+	u8      state;
+	u8      rsvd2[3];
+};
+
 int hinic_port_add_mac(struct hinic_dev *nic_dev, const u8 *addr,
 		       u16 vlan_id);
 
@@ -131,4 +147,7 @@ int hinic_port_link_state(struct hinic_dev *nic_dev,
 int hinic_port_set_state(struct hinic_dev *nic_dev,
 			 enum hinic_port_state state);
 
+int hinic_port_set_func_state(struct hinic_dev *nic_dev,
+			      enum hinic_func_port_state state);
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_rx.c b/drivers/net/ethernet/huawei/hinic/hinic_rx.c
index 173fe8b..6367fa1 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_rx.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_rx.c
@@ -13,11 +13,35 @@
  *
  */
 
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/pci.h>
+#include <linux/device.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/u64_stats_sync.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/skbuff.h>
+#include <linux/dma-mapping.h>
+#include <linux/prefetch.h>
+#include <asm/barrier.h>
 
+#include "hinic_common.h"
+#include "hinic_hw_if.h"
+#include "hinic_hw_wqe.h"
+#include "hinic_hw_wq.h"
 #include "hinic_hw_qp.h"
+#include "hinic_hw_dev.h"
 #include "hinic_rx.h"
+#include "hinic_dev.h"
+
+#define RX_IRQ_NO_PENDING               0
+#define RX_IRQ_NO_COALESC               0
+#define RX_IRQ_NO_LLI_TIMER             0
+#define RX_IRQ_NO_CREDIT                0
+#define RX_IRQ_NO_RESEND_TIMER          0
 
 /**
  * hinic_rxq_clean_stats - Clean the statistics of specific queue
@@ -46,6 +70,362 @@ static void rxq_stats_init(struct hinic_rxq *rxq)
 }
 
 /**
+ * rx_alloc_skb - allocate skb and map it to dma address
+ * @rxq: rx queue
+ * @dma_addr: returned dma address for the skb
+ *
+ * Return skb
+ **/
+static struct sk_buff *rx_alloc_skb(struct hinic_rxq *rxq,
+				    dma_addr_t *dma_addr)
+{
+	struct hinic_dev *nic_dev = netdev_priv(rxq->netdev);
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_rq *rq = rxq->rq;
+	struct sk_buff *skb;
+	dma_addr_t addr;
+	int err;
+
+	skb = netdev_alloc_skb_ip_align(rxq->netdev, rq->buf_sz);
+	if (!skb) {
+		netdev_err(rxq->netdev, "Failed to allocate Rx SKB\n");
+		return NULL;
+	}
+
+	addr = dma_map_single(&pdev->dev, skb->data, rq->buf_sz,
+			      DMA_FROM_DEVICE);
+	err = dma_mapping_error(&pdev->dev, addr);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to map Rx DMA, err = %d\n", err);
+		goto err_rx_map;
+	}
+
+	*dma_addr = addr;
+	return skb;
+
+err_rx_map:
+	dev_kfree_skb_any(skb);
+	return NULL;
+}
+
+/**
+ * rx_unmap_skb - unmap the dma address of the skb
+ * @rxq: rx queue
+ * @dma_addr: dma address of the skb
+ **/
+static void rx_unmap_skb(struct hinic_rxq *rxq, dma_addr_t dma_addr)
+{
+	struct hinic_dev *nic_dev = netdev_priv(rxq->netdev);
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_rq *rq = rxq->rq;
+
+	dma_unmap_single(&pdev->dev, dma_addr, rq->buf_sz, DMA_FROM_DEVICE);
+}
+
+/**
+ * rx_free_skb - unmap and free skb
+ * @rxq: rx queue
+ * @skb: skb to free
+ * @dma_addr: dma address of the skb
+ **/
+static void rx_free_skb(struct hinic_rxq *rxq, struct sk_buff *skb,
+			dma_addr_t dma_addr)
+{
+	rx_unmap_skb(rxq, dma_addr);
+	dev_kfree_skb_any(skb);
+}
+
+/**
+ * rx_alloc_pkts - allocate pkts in rx queue
+ * @rxq: rx queue
+ *
+ * Return number of skbs allocated
+ **/
+static int rx_alloc_pkts(struct hinic_rxq *rxq)
+{
+	struct hinic_dev *nic_dev = netdev_priv(rxq->netdev);
+	struct hinic_rq_wqe *rq_wqe;
+	unsigned int free_wqebbs;
+	struct hinic_sge sge;
+	dma_addr_t dma_addr;
+	struct sk_buff *skb;
+	int i, alloc_more;
+	u16 prod_idx;
+
+	free_wqebbs = hinic_get_rq_free_wqebbs(rxq->rq);
+	alloc_more = 0;
+
+	/* Limit the allocation chunks */
+	if (free_wqebbs > nic_dev->rx_weight)
+		free_wqebbs = nic_dev->rx_weight;
+
+	for (i = 0; i < free_wqebbs; i++) {
+		skb = rx_alloc_skb(rxq, &dma_addr);
+		if (!skb) {
+			netdev_err(rxq->netdev, "Failed to alloc Rx skb\n");
+			alloc_more = 1;
+			goto skb_out;
+		}
+
+		hinic_set_sge(&sge, dma_addr, skb->len);
+
+		rq_wqe = hinic_rq_get_wqe(rxq->rq, HINIC_RQ_WQE_SIZE,
+					  &prod_idx);
+		if (!rq_wqe) {
+			rx_free_skb(rxq, skb, dma_addr);
+			alloc_more = 1;
+			goto skb_out;
+		}
+
+		hinic_rq_prepare_wqe(rxq->rq, prod_idx, rq_wqe, &sge);
+
+		hinic_rq_write_wqe(rxq->rq, prod_idx, rq_wqe, skb);
+	}
+
+skb_out:
+	if (i) {
+		wmb();  /* write all the wqes before update PI */
+
+		hinic_rq_update(rxq->rq, prod_idx);
+	}
+
+	if (alloc_more)
+		tasklet_schedule(&rxq->rx_task);
+
+	return i;
+}
+
+/**
+ * free_all_rx_skbs - free all skbs in rx queue
+ * @rxq: rx queue
+ **/
+static void free_all_rx_skbs(struct hinic_rxq *rxq)
+{
+	struct hinic_rq *rq = rxq->rq;
+	struct hinic_hw_wqe *hw_wqe;
+	struct hinic_sge sge;
+	u16 ci;
+
+	while ((hw_wqe = hinic_read_wqe(rq->wq, HINIC_RQ_WQE_SIZE, &ci))) {
+		if (IS_ERR(hw_wqe))
+			break;
+
+		hinic_rq_get_sge(rq, &hw_wqe->rq_wqe, ci, &sge);
+
+		hinic_put_wqe(rq->wq, HINIC_RQ_WQE_SIZE);
+
+		rx_free_skb(rxq, rq->saved_skb[ci], hinic_sge_to_dma(&sge));
+	}
+}
+
+/**
+ * rx_alloc_task - tasklet for queue allocation
+ * @data: rx queue
+ **/
+static void rx_alloc_task(unsigned long data)
+{
+	struct hinic_rxq *rxq = (struct hinic_rxq *)data;
+
+	(void)rx_alloc_pkts(rxq);
+}
+
+/**
+ * rx_recv_jumbo_pkt - Rx handler for jumbo pkt
+ * @rxq: rx queue
+ * @head_skb: the first skb in the list
+ * @left_pkt_len: left size of the pkt exclude head skb
+ * @ci: consumer index
+ *
+ * Return number of wqes that used for the left of the pkt
+ **/
+static int rx_recv_jumbo_pkt(struct hinic_rxq *rxq, struct sk_buff *head_skb,
+			     unsigned int left_pkt_len, u16 ci)
+{
+	struct sk_buff *skb, *curr_skb = head_skb;
+	struct hinic_rq_wqe *rq_wqe;
+	unsigned int curr_len;
+	struct hinic_sge sge;
+	int num_wqes = 0;
+
+	while (left_pkt_len > 0) {
+		rq_wqe = hinic_rq_read_next_wqe(rxq->rq, HINIC_RQ_WQE_SIZE,
+						&skb, &ci);
+
+		num_wqes++;
+
+		hinic_rq_get_sge(rxq->rq, rq_wqe, ci, &sge);
+
+		rx_unmap_skb(rxq, hinic_sge_to_dma(&sge));
+
+		prefetch(skb->data);
+
+		curr_len = (left_pkt_len > HINIC_RX_BUF_SZ) ? HINIC_RX_BUF_SZ :
+			    left_pkt_len;
+
+		left_pkt_len -= curr_len;
+
+		__skb_put(skb, curr_len);
+
+		if (curr_skb == head_skb)
+			skb_shinfo(head_skb)->frag_list = skb;
+		else
+			curr_skb->next = skb;
+
+		head_skb->len += skb->len;
+		head_skb->data_len += skb->len;
+		head_skb->truesize += skb->truesize;
+
+		curr_skb = skb;
+	}
+
+	return num_wqes;
+}
+
+/**
+ * rxq_recv - Rx handler
+ * @rxq: rx queue
+ * @budget: maximum pkts to process
+ *
+ * Return number of pkts received
+ **/
+static int rxq_recv(struct hinic_rxq *rxq, int budget)
+{
+	struct hinic_qp *qp = container_of(rxq->rq, struct hinic_qp, rq);
+	u64 pkt_len = 0, rx_bytes = 0;
+	struct hinic_rq_wqe *rq_wqe;
+	int num_wqes, pkts = 0;
+	struct hinic_sge sge;
+	struct sk_buff *skb;
+	u16 ci;
+
+	while (pkts < budget) {
+		num_wqes = 0;
+
+		rq_wqe = hinic_rq_read_wqe(rxq->rq, HINIC_RQ_WQE_SIZE, &skb,
+					   &ci);
+		if (!rq_wqe)
+			break;
+
+		hinic_rq_get_sge(rxq->rq, rq_wqe, ci, &sge);
+
+		rx_unmap_skb(rxq, hinic_sge_to_dma(&sge));
+
+		prefetch(skb->data);
+
+		pkt_len = sge.len;
+
+		if (pkt_len <= HINIC_RX_BUF_SZ) {
+			__skb_put(skb, pkt_len);
+		} else {
+			__skb_put(skb, HINIC_RX_BUF_SZ);
+			num_wqes = rx_recv_jumbo_pkt(rxq, skb, pkt_len -
+						     HINIC_RX_BUF_SZ, ci);
+		}
+
+		hinic_rq_put_wqe(rxq->rq, ci,
+				 (num_wqes + 1) * HINIC_RQ_WQE_SIZE);
+
+		skb_record_rx_queue(skb, qp->q_id);
+		skb->protocol = eth_type_trans(skb, rxq->netdev);
+
+		napi_gro_receive(&rxq->napi, skb);
+
+		pkts++;
+		rx_bytes += pkt_len;
+	}
+
+	if (pkts)
+		tasklet_schedule(&rxq->rx_task); /* hinic_rx_alloc_pkts */
+
+	u64_stats_update_begin(&rxq->rxq_stats.syncp);
+	rxq->rxq_stats.pkts += pkts;
+	rxq->rxq_stats.bytes += rx_bytes;
+	u64_stats_update_end(&rxq->rxq_stats.syncp);
+
+	return pkts;
+}
+
+static int rx_poll(struct napi_struct *napi, int budget)
+{
+	struct hinic_rxq *rxq = container_of(napi, struct hinic_rxq, napi);
+	struct hinic_rq *rq = rxq->rq;
+	int pkts;
+
+	pkts = rxq_recv(rxq, budget);
+	if (pkts >= budget)
+		return budget;
+
+	napi_complete(napi);
+	enable_irq(rq->irq);
+	return pkts;
+}
+
+static void rx_add_napi(struct hinic_rxq *rxq)
+{
+	struct hinic_dev *nic_dev = netdev_priv(rxq->netdev);
+
+	netif_napi_add(rxq->netdev, &rxq->napi, rx_poll, nic_dev->rx_weight);
+	napi_enable(&rxq->napi);
+}
+
+static void rx_del_napi(struct hinic_rxq *rxq)
+{
+	napi_disable(&rxq->napi);
+	netif_napi_del(&rxq->napi);
+}
+
+static irqreturn_t rx_irq(int irq, void *data)
+{
+	struct hinic_rxq *rxq = (struct hinic_rxq *)data;
+	struct hinic_rq *rq = rxq->rq;
+	struct hinic_dev *nic_dev;
+
+	/* Disable the interrupt until napi will be completed */
+	disable_irq_nosync(rq->irq);
+
+	nic_dev = netdev_priv(rxq->netdev);
+	hinic_hwdev_msix_cnt_set(nic_dev->hwdev, rq->msix_entry);
+
+	napi_schedule(&rxq->napi);
+	return IRQ_HANDLED;
+}
+
+static int rx_request_irq(struct hinic_rxq *rxq)
+{
+	struct hinic_dev *nic_dev = netdev_priv(rxq->netdev);
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_rq *rq = rxq->rq;
+	int err;
+
+	rx_add_napi(rxq);
+
+	hinic_hwdev_msix_set(hwdev, rq->msix_entry,
+			     RX_IRQ_NO_PENDING, RX_IRQ_NO_COALESC,
+			     RX_IRQ_NO_LLI_TIMER, RX_IRQ_NO_CREDIT,
+			     RX_IRQ_NO_RESEND_TIMER);
+
+	err = request_irq(rq->irq, rx_irq, 0, rxq->irq_name, rxq);
+	if (err) {
+		rx_del_napi(rxq);
+		return err;
+	}
+
+	return 0;
+}
+
+static void rx_free_irq(struct hinic_rxq *rxq)
+{
+	struct hinic_rq *rq = rxq->rq;
+
+	free_irq(rq->irq, rxq);
+	rx_del_napi(rxq);
+}
+
+/**
  * hinic_init_rxq - Initialize the Rx Queue
  * @rxq: Logical Rx Queue
  * @rq: Hardware Rx Queue to connect the Logical queue with
@@ -56,11 +436,43 @@ static void rxq_stats_init(struct hinic_rxq *rxq)
 int hinic_init_rxq(struct hinic_rxq *rxq, struct hinic_rq *rq,
 		   struct net_device *netdev)
 {
+	struct hinic_qp *qp = container_of(rq, struct hinic_qp, rq);
+	int err, pkts, irqname_len;
+
 	rxq->netdev = netdev;
 	rxq->rq = rq;
 
 	rxq_stats_init(rxq);
+
+	irqname_len = snprintf(NULL, 0, "hinic_rxq%d", qp->q_id) + 1;
+	rxq->irq_name = devm_kzalloc(&netdev->dev, irqname_len, GFP_KERNEL);
+	if (!rxq->irq_name)
+		return -ENOMEM;
+
+	sprintf(rxq->irq_name, "hinic_rxq%d", qp->q_id);
+
+	tasklet_init(&rxq->rx_task, rx_alloc_task, (unsigned long)rxq);
+
+	pkts = rx_alloc_pkts(rxq);
+	if (!pkts) {
+		err = -ENOMEM;
+		goto err_rx_pkts;
+	}
+
+	err = rx_request_irq(rxq);
+	if (err) {
+		netdev_err(netdev, "Failed to request Rx irq\n");
+		goto err_req_rx_irq;
+	}
+
 	return 0;
+
+err_req_rx_irq:
+err_rx_pkts:
+	tasklet_kill(&rxq->rx_task);
+	free_all_rx_skbs(rxq);
+	devm_kfree(&netdev->dev, rxq->irq_name);
+	return err;
 }
 
 /**
@@ -69,4 +481,11 @@ int hinic_init_rxq(struct hinic_rxq *rxq, struct hinic_rq *rq,
  **/
 void hinic_clean_rxq(struct hinic_rxq *rxq)
 {
+	struct net_device *netdev = rxq->netdev;
+
+	rx_free_irq(rxq);
+
+	tasklet_kill(&rxq->rx_task);
+	free_all_rx_skbs(rxq);
+	devm_kfree(&netdev->dev, rxq->irq_name);
 }
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_rx.h b/drivers/net/ethernet/huawei/hinic/hinic_rx.h
index fbd0246..538c886 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_rx.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_rx.h
@@ -19,6 +19,7 @@
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/u64_stats_sync.h>
+#include <linux/interrupt.h>
 
 #include "hinic_hw_qp.h"
 
@@ -34,6 +35,12 @@ struct hinic_rxq {
 	struct hinic_rq         *rq;
 
 	struct hinic_rxq_stats  rxq_stats;
+
+	char                    *irq_name;
+
+	struct tasklet_struct   rx_task;
+
+	struct napi_struct      napi;
 };
 
 void hinic_rxq_clean_stats(struct hinic_rxq *rxq);
-- 
1.9.1
