From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V8 net-next 10/22] net-next/hinic: Add logical Txq and Rxq
Date: Mon, 21 Aug 2017 23:55:56 +0800
Message-ID: <3bc69bfecd77125c077d0bb4f438163ae02675dc.1503330613.git.aviad.krawczyk@huawei.com>
References: <cover.1503330613.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1503330613.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Create the logical queues of the nic.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/Makefile       |   5 +-
 drivers/net/ethernet/huawei/hinic/hinic_dev.h    |   5 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c | 131 +++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h |  20 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c  | 144 +++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h  |  46 ++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h  |  32 +++++
 drivers/net/ethernet/huawei/hinic/hinic_main.c   | 172 ++++++++++++++++++++++-
 drivers/net/ethernet/huawei/hinic/hinic_rx.c     |  72 ++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_rx.h     |  46 ++++++
 drivers/net/ethernet/huawei/hinic/hinic_tx.c     |  75 ++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_tx.h     |  49 +++++++
 12 files changed, 793 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_rx.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_rx.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_tx.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_tx.h

diff --git a/drivers/net/ethernet/huawei/hinic/Makefile b/drivers/net/ethernet/huawei/hinic/Makefile
index dbb1b9d..f60c449 100644
--- a/drivers/net/ethernet/huawei/hinic/Makefile
+++ b/drivers/net/ethernet/huawei/hinic/Makefile
@@ -1,4 +1,5 @@
 obj-$(CONFIG_HINIC) += hinic.o
 
-hinic-y := hinic_main.o hinic_port.o hinic_hw_dev.o hinic_hw_mgmt.o \
-	   hinic_hw_api_cmd.o hinic_hw_eqs.o hinic_hw_if.o
+hinic-y := hinic_main.o hinic_tx.o hinic_rx.o hinic_port.o hinic_hw_dev.o \
+	   hinic_hw_io.o hinic_hw_mgmt.o hinic_hw_api_cmd.o hinic_hw_eqs.o \
+	   hinic_hw_if.o
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
index 5c5b4e9..5b8231d 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
@@ -23,6 +23,8 @@
 #include <linux/bitops.h>
 
 #include "hinic_hw_dev.h"
+#include "hinic_tx.h"
+#include "hinic_rx.h"
 
 #define HINIC_DRV_NAME          "hinic"
 
@@ -49,6 +51,9 @@ struct hinic_dev {
 
 	struct hinic_rx_mode_work       rx_mode_work;
 	struct workqueue_struct         *workq;
+
+	struct hinic_txq                *txqs;
+	struct hinic_rxq                *rxqs;
 };
 
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
index c3122b0..5ae1c36 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
@@ -25,6 +25,8 @@
 #include "hinic_hw_if.h"
 #include "hinic_hw_eqs.h"
 #include "hinic_hw_mgmt.h"
+#include "hinic_hw_qp.h"
+#include "hinic_hw_io.h"
 #include "hinic_hw_dev.h"
 
 #define MAX_IRQS(max_qps, num_aeqs, num_ceqs)   \
@@ -230,6 +232,99 @@ int hinic_port_msg_cmd(struct hinic_hwdev *hwdev, enum hinic_port_cmd cmd,
 }
 
 /**
+ * get_base_qpn - get the first qp number
+ * @hwdev: the NIC HW device
+ * @base_qpn: returned qp number
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int get_base_qpn(struct hinic_hwdev *hwdev, u16 *base_qpn)
+{
+	struct hinic_cmd_base_qpn cmd_base_qpn;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	u16 out_size;
+	int err;
+
+	cmd_base_qpn.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+
+	err = hinic_port_msg_cmd(hwdev, HINIC_PORT_CMD_GET_GLOBAL_QPN,
+				 &cmd_base_qpn, sizeof(cmd_base_qpn),
+				 &cmd_base_qpn, &out_size);
+	if (err || (out_size != sizeof(cmd_base_qpn)) || cmd_base_qpn.status) {
+		dev_err(&pdev->dev, "Failed to get base qpn, status = %d\n",
+			cmd_base_qpn.status);
+		return -EFAULT;
+	}
+
+	*base_qpn = cmd_base_qpn.qpn;
+	return 0;
+}
+
+/**
+ * hinic_hwdev_ifup - Preparing the HW for passing IO
+ * @hwdev: the NIC HW device
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_hwdev_ifup(struct hinic_hwdev *hwdev)
+{
+	struct hinic_func_to_io *func_to_io = &hwdev->func_to_io;
+	struct hinic_cap *nic_cap = &hwdev->nic_cap;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	int err, num_aeqs, num_ceqs, num_qps;
+	struct msix_entry *sq_msix_entries;
+	struct msix_entry *rq_msix_entries;
+	struct pci_dev *pdev = hwif->pdev;
+	u16 base_qpn;
+
+	err = get_base_qpn(hwdev, &base_qpn);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to get global base qp number\n");
+		return err;
+	}
+
+	num_aeqs = HINIC_HWIF_NUM_AEQS(hwif);
+	num_ceqs = HINIC_HWIF_NUM_CEQS(hwif);
+	err = hinic_io_init(func_to_io, hwif, nic_cap->max_qps, 0, NULL);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init IO channel\n");
+		return err;
+	}
+
+	num_qps = nic_cap->num_qps;
+	sq_msix_entries = &hwdev->msix_entries[num_aeqs + num_ceqs];
+	rq_msix_entries = &hwdev->msix_entries[num_aeqs + num_ceqs + num_qps];
+
+	err = hinic_io_create_qps(func_to_io, base_qpn, num_qps,
+				  sq_msix_entries, rq_msix_entries);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to create QPs\n");
+		goto err_create_qps;
+	}
+
+	return 0;
+
+err_create_qps:
+	hinic_io_free(func_to_io);
+	return err;
+}
+
+/**
+ * hinic_hwdev_ifdown - Closing the HW for passing IO
+ * @hwdev: the NIC HW device
+ *
+ **/
+void hinic_hwdev_ifdown(struct hinic_hwdev *hwdev)
+{
+	struct hinic_func_to_io *func_to_io = &hwdev->func_to_io;
+	struct hinic_cap *nic_cap = &hwdev->nic_cap;
+
+	hinic_io_destroy_qps(func_to_io, nic_cap->num_qps);
+	hinic_io_free(func_to_io);
+}
+
+/**
  * hinic_hwdev_cb_register - register callback handler for MGMT events
  * @hwdev: the NIC HW device
  * @cmd: the mgmt event
@@ -499,3 +594,39 @@ int hinic_hwdev_num_qps(struct hinic_hwdev *hwdev)
 
 	return nic_cap->num_qps;
 }
+
+/**
+ * hinic_hwdev_get_sq - get SQ
+ * @hwdev: the NIC HW device
+ * @i: the position of the SQ
+ *
+ * Return: the SQ in the i position
+ **/
+struct hinic_sq *hinic_hwdev_get_sq(struct hinic_hwdev *hwdev, int i)
+{
+	struct hinic_func_to_io *func_to_io = &hwdev->func_to_io;
+	struct hinic_qp *qp = &func_to_io->qps[i];
+
+	if (i >= hinic_hwdev_num_qps(hwdev))
+		return NULL;
+
+	return &qp->sq;
+}
+
+/**
+ * hinic_hwdev_get_sq - get RQ
+ * @hwdev: the NIC HW device
+ * @i: the position of the RQ
+ *
+ * Return: the RQ in the i position
+ **/
+struct hinic_rq *hinic_hwdev_get_rq(struct hinic_hwdev *hwdev, int i)
+{
+	struct hinic_func_to_io *func_to_io = &hwdev->func_to_io;
+	struct hinic_qp *qp = &func_to_io->qps[i];
+
+	if (i >= hinic_hwdev_num_qps(hwdev))
+		return NULL;
+
+	return &qp->rq;
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
index 1cd8159..81c2c6e 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
@@ -23,6 +23,8 @@
 #include "hinic_hw_if.h"
 #include "hinic_hw_eqs.h"
 #include "hinic_hw_mgmt.h"
+#include "hinic_hw_qp.h"
+#include "hinic_hw_io.h"
 
 #define HINIC_MAX_QPS   32
 
@@ -72,11 +74,21 @@ enum hinic_cb_state {
 	HINIC_CB_RUNNING = BIT(1),
 };
 
+struct hinic_cmd_base_qpn {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+	u16     qpn;
+};
+
 struct hinic_hwdev {
 	struct hinic_hwif               *hwif;
 	struct msix_entry               *msix_entries;
 
 	struct hinic_aeqs               aeqs;
+	struct hinic_func_to_io         func_to_io;
 
 	struct hinic_cap                nic_cap;
 };
@@ -111,10 +123,18 @@ int hinic_port_msg_cmd(struct hinic_hwdev *hwdev, enum hinic_port_cmd cmd,
 		       void *buf_in, u16 in_size, void *buf_out,
 		       u16 *out_size);
 
+int hinic_hwdev_ifup(struct hinic_hwdev *hwdev);
+
+void hinic_hwdev_ifdown(struct hinic_hwdev *hwdev);
+
 struct hinic_hwdev *hinic_init_hwdev(struct pci_dev *pdev);
 
 void hinic_free_hwdev(struct hinic_hwdev *hwdev);
 
 int hinic_hwdev_num_qps(struct hinic_hwdev *hwdev);
 
+struct hinic_sq *hinic_hwdev_get_sq(struct hinic_hwdev *hwdev, int i);
+
+struct hinic_rq *hinic_hwdev_get_rq(struct hinic_hwdev *hwdev, int i);
+
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
new file mode 100644
index 0000000..ebe28ee
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
@@ -0,0 +1,144 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+
+#include "hinic_hw_if.h"
+#include "hinic_hw_qp.h"
+#include "hinic_hw_io.h"
+
+/**
+ * init_qp - Initialize a Queue Pair
+ * @func_to_io: func to io channel that holds the IO components
+ * @qp: pointer to the qp to initialize
+ * @q_id: the id of the qp
+ * @sq_msix_entry: msix entry for sq
+ * @rq_msix_entry: msix entry for rq
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int init_qp(struct hinic_func_to_io *func_to_io,
+		   struct hinic_qp *qp, int q_id,
+		   struct msix_entry *sq_msix_entry,
+		   struct msix_entry *rq_msix_entry)
+{
+	/* should be implemented */
+	return 0;
+}
+
+/**
+ * destroy_qp - Clean the resources of a Queue Pair
+ * @func_to_io: func to io channel that holds the IO components
+ * @qp: pointer to the qp to clean
+ **/
+static void destroy_qp(struct hinic_func_to_io *func_to_io,
+		       struct hinic_qp *qp)
+{
+	/* should be implemented */
+}
+
+/**
+ * hinic_io_create_qps - Create Queue Pairs
+ * @func_to_io: func to io channel that holds the IO components
+ * @base_qpn: base qp number
+ * @num_qps: number queue pairs to create
+ * @sq_msix_entry: msix entries for sq
+ * @rq_msix_entry: msix entries for rq
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
+			u16 base_qpn, int num_qps,
+			struct msix_entry *sq_msix_entries,
+			struct msix_entry *rq_msix_entries)
+{
+	struct hinic_hwif *hwif = func_to_io->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	size_t qps_size;
+	int i, j, err;
+
+	qps_size = num_qps * sizeof(*func_to_io->qps);
+	func_to_io->qps = devm_kzalloc(&pdev->dev, qps_size, GFP_KERNEL);
+	if (!func_to_io->qps)
+		return -ENOMEM;
+
+	for (i = 0; i < num_qps; i++) {
+		err = init_qp(func_to_io, &func_to_io->qps[i], i,
+			      &sq_msix_entries[i], &rq_msix_entries[i]);
+		if (err) {
+			dev_err(&pdev->dev, "Failed to create QP %d\n", i);
+			goto err_init_qp;
+		}
+	}
+
+	return 0;
+
+err_init_qp:
+	for (j = 0; j < i; j++)
+		destroy_qp(func_to_io, &func_to_io->qps[j]);
+
+	devm_kfree(&pdev->dev, func_to_io->qps);
+	return err;
+}
+
+/**
+ * hinic_io_destroy_qps - Destroy the IO Queue Pairs
+ * @func_to_io: func to io channel that holds the IO components
+ * @num_qps: number queue pairs to destroy
+ **/
+void hinic_io_destroy_qps(struct hinic_func_to_io *func_to_io, int num_qps)
+{
+	struct hinic_hwif *hwif = func_to_io->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int i;
+
+	for (i = 0; i < num_qps; i++)
+		destroy_qp(func_to_io, &func_to_io->qps[i]);
+
+	devm_kfree(&pdev->dev, func_to_io->qps);
+}
+
+/**
+ * hinic_io_init - Initialize the IO components
+ * @func_to_io: func to io channel that holds the IO components
+ * @hwif: HW interface for accessing IO
+ * @max_qps: maximum QPs in HW
+ * @num_ceqs: number completion event queues
+ * @ceq_msix_entries: msix entries for ceqs
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_io_init(struct hinic_func_to_io *func_to_io,
+		  struct hinic_hwif *hwif, u16 max_qps, int num_ceqs,
+		  struct msix_entry *ceq_msix_entries)
+{
+	func_to_io->hwif = hwif;
+	func_to_io->qps = NULL;
+	func_to_io->max_qps = max_qps;
+
+	return 0;
+}
+
+/**
+ * hinic_io_free - Free the IO components
+ * @func_to_io: func to io channel that holds the IO components
+ **/
+void hinic_io_free(struct hinic_func_to_io *func_to_io)
+{
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
new file mode 100644
index 0000000..7cdcffd
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
@@ -0,0 +1,46 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#ifndef HINIC_HW_IO_H
+#define HINIC_HW_IO_H
+
+#include <linux/types.h>
+#include <linux/pci.h>
+
+#include "hinic_hw_if.h"
+#include "hinic_hw_qp.h"
+
+struct hinic_func_to_io {
+	struct hinic_hwif       *hwif;
+
+	struct hinic_qp         *qps;
+	u16                     max_qps;
+};
+
+int hinic_io_create_qps(struct hinic_func_to_io *func_to_io,
+			u16 base_qpn, int num_qps,
+			struct msix_entry *sq_msix_entries,
+			struct msix_entry *rq_msix_entries);
+
+void hinic_io_destroy_qps(struct hinic_func_to_io *func_to_io,
+			  int num_qps);
+
+int hinic_io_init(struct hinic_func_to_io *func_to_io,
+		  struct hinic_hwif *hwif, u16 max_qps, int num_ceqs,
+		  struct msix_entry *ceq_msix_entries);
+
+void hinic_io_free(struct hinic_func_to_io *func_to_io);
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
new file mode 100644
index 0000000..64330fb
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
@@ -0,0 +1,32 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#ifndef HINIC_HW_QP_H
+#define HINIC_HW_QP_H
+
+struct hinic_sq {
+	/* should be implemented */
+};
+
+struct hinic_rq {
+	/* should be implemented */
+};
+
+struct hinic_qp {
+	struct hinic_sq         sq;
+	struct hinic_rq         rq;
+};
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
index 7aebc62..22d5b61 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
@@ -31,8 +31,11 @@
 #include <linux/delay.h>
 #include <linux/err.h>
 
+#include "hinic_hw_qp.h"
 #include "hinic_hw_dev.h"
 #include "hinic_port.h"
+#include "hinic_tx.h"
+#include "hinic_rx.h"
 #include "hinic_dev.h"
 
 MODULE_AUTHOR("Huawei Technologies CO., Ltd");
@@ -57,17 +60,164 @@
 
 static int change_mac_addr(struct net_device *netdev, const u8 *addr);
 
+/**
+ * create_txqs - Create the Logical Tx Queues of specific NIC device
+ * @nic_dev: the specific NIC device
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int create_txqs(struct hinic_dev *nic_dev)
+{
+	int err, i, j, num_txqs = hinic_hwdev_num_qps(nic_dev->hwdev);
+	struct net_device *netdev = nic_dev->netdev;
+	size_t txq_size;
+
+	if (nic_dev->txqs)
+		return -EINVAL;
+
+	txq_size = num_txqs * sizeof(*nic_dev->txqs);
+	nic_dev->txqs = devm_kzalloc(&netdev->dev, txq_size, GFP_KERNEL);
+	if (!nic_dev->txqs)
+		return -ENOMEM;
+
+	for (i = 0; i < num_txqs; i++) {
+		struct hinic_sq *sq = hinic_hwdev_get_sq(nic_dev->hwdev, i);
+
+		err = hinic_init_txq(&nic_dev->txqs[i], sq, netdev);
+		if (err) {
+			netif_err(nic_dev, drv, netdev,
+				  "Failed to init Txq\n");
+			goto err_init_txq;
+		}
+	}
+
+	return 0;
+
+err_init_txq:
+	for (j = 0; j < i; j++)
+		hinic_clean_txq(&nic_dev->txqs[j]);
+
+	devm_kfree(&netdev->dev, nic_dev->txqs);
+	return err;
+}
+
+/**
+ * free_txqs - Free the Logical Tx Queues of specific NIC device
+ * @nic_dev: the specific NIC device
+ **/
+static void free_txqs(struct hinic_dev *nic_dev)
+{
+	int i, num_txqs = hinic_hwdev_num_qps(nic_dev->hwdev);
+	struct net_device *netdev = nic_dev->netdev;
+
+	if (!nic_dev->txqs)
+		return;
+
+	for (i = 0; i < num_txqs; i++)
+		hinic_clean_txq(&nic_dev->txqs[i]);
+
+	devm_kfree(&netdev->dev, nic_dev->txqs);
+	nic_dev->txqs = NULL;
+}
+
+/**
+ * create_txqs - Create the Logical Rx Queues of specific NIC device
+ * @nic_dev: the specific NIC device
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int create_rxqs(struct hinic_dev *nic_dev)
+{
+	int err, i, j, num_rxqs = hinic_hwdev_num_qps(nic_dev->hwdev);
+	struct net_device *netdev = nic_dev->netdev;
+	size_t rxq_size;
+
+	if (nic_dev->rxqs)
+		return -EINVAL;
+
+	rxq_size = num_rxqs * sizeof(*nic_dev->rxqs);
+	nic_dev->rxqs = devm_kzalloc(&netdev->dev, rxq_size, GFP_KERNEL);
+	if (!nic_dev->rxqs)
+		return -ENOMEM;
+
+	for (i = 0; i < num_rxqs; i++) {
+		struct hinic_rq *rq = hinic_hwdev_get_rq(nic_dev->hwdev, i);
+
+		err = hinic_init_rxq(&nic_dev->rxqs[i], rq, netdev);
+		if (err) {
+			netif_err(nic_dev, drv, netdev,
+				  "Failed to init rxq\n");
+			goto err_init_rxq;
+		}
+	}
+
+	return 0;
+
+err_init_rxq:
+	for (j = 0; j < i; j++)
+		hinic_clean_rxq(&nic_dev->rxqs[j]);
+
+	devm_kfree(&netdev->dev, nic_dev->rxqs);
+	return err;
+}
+
+/**
+ * free_txqs - Free the Logical Rx Queues of specific NIC device
+ * @nic_dev: the specific NIC device
+ **/
+static void free_rxqs(struct hinic_dev *nic_dev)
+{
+	int i, num_rxqs = hinic_hwdev_num_qps(nic_dev->hwdev);
+	struct net_device *netdev = nic_dev->netdev;
+
+	if (!nic_dev->rxqs)
+		return;
+
+	for (i = 0; i < num_rxqs; i++)
+		hinic_clean_rxq(&nic_dev->rxqs[i]);
+
+	devm_kfree(&netdev->dev, nic_dev->rxqs);
+	nic_dev->rxqs = NULL;
+}
+
 static int hinic_open(struct net_device *netdev)
 {
 	struct hinic_dev *nic_dev = netdev_priv(netdev);
 	enum hinic_port_link_state link_state;
-	int err, ret;
+	int err, ret, num_qps;
+
+	if (!(nic_dev->flags & HINIC_INTF_UP)) {
+		err = hinic_hwdev_ifup(nic_dev->hwdev);
+		if (err) {
+			netif_err(nic_dev, drv, netdev,
+				  "Failed - HW interface up\n");
+			return err;
+		}
+	}
+
+	err = create_txqs(nic_dev);
+	if (err) {
+		netif_err(nic_dev, drv, netdev,
+			  "Failed to create Tx queues\n");
+		goto err_create_txqs;
+	}
+
+	err = create_rxqs(nic_dev);
+	if (err) {
+		netif_err(nic_dev, drv, netdev,
+			  "Failed to create Rx queues\n");
+		goto err_create_rxqs;
+	}
+
+	num_qps = hinic_hwdev_num_qps(nic_dev->hwdev);
+	netif_set_real_num_tx_queues(netdev, num_qps);
+	netif_set_real_num_rx_queues(netdev, num_qps);
 
 	err = hinic_port_set_state(nic_dev, HINIC_PORT_ENABLE);
 	if (err) {
 		netif_err(nic_dev, drv, netdev,
 			  "Failed to set port state\n");
-		return err;
+		goto err_port_state;
 	}
 
 	/* Wait up to 3 sec between port enable to link state */
@@ -104,6 +254,16 @@ static int hinic_open(struct net_device *netdev)
 	if (ret)
 		netif_warn(nic_dev, drv, netdev,
 			   "Failed to revert port state\n");
+
+err_port_state:
+	free_rxqs(nic_dev);
+
+err_create_rxqs:
+	free_txqs(nic_dev);
+
+err_create_txqs:
+	if (!(nic_dev->flags & HINIC_INTF_UP))
+		hinic_hwdev_ifdown(nic_dev->hwdev);
 	return err;
 }
 
@@ -130,6 +290,12 @@ static int hinic_close(struct net_device *netdev)
 		return err;
 	}
 
+	free_rxqs(nic_dev);
+	free_txqs(nic_dev);
+
+	if (flags & HINIC_INTF_UP)
+		hinic_hwdev_ifdown(nic_dev->hwdev);
+
 	netif_info(nic_dev, drv, netdev, "HINIC_INTF is DOWN\n");
 	return 0;
 }
@@ -496,6 +662,8 @@ static int nic_dev_init(struct pci_dev *pdev)
 	nic_dev->hwdev  = hwdev;
 	nic_dev->msg_enable = MSG_ENABLE_DEFAULT;
 	nic_dev->flags = 0;
+	nic_dev->txqs = NULL;
+	nic_dev->rxqs = NULL;
 
 	sema_init(&nic_dev->mgmt_lock, 1);
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_rx.c b/drivers/net/ethernet/huawei/hinic/hinic_rx.c
new file mode 100644
index 0000000..3c79f65
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_rx.c
@@ -0,0 +1,72 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#include <linux/netdevice.h>
+#include <linux/u64_stats_sync.h>
+
+#include "hinic_hw_qp.h"
+#include "hinic_rx.h"
+
+/**
+ * hinic_rxq_clean_stats - Clean the statistics of specific queue
+ * @rxq: Logical Rx Queue
+ **/
+void hinic_rxq_clean_stats(struct hinic_rxq *rxq)
+{
+	struct hinic_rxq_stats *rxq_stats = &rxq->rxq_stats;
+
+	u64_stats_update_begin(&rxq_stats->syncp);
+	rxq_stats->pkts  = 0;
+	rxq_stats->bytes = 0;
+	u64_stats_update_end(&rxq_stats->syncp);
+}
+
+/**
+ * rxq_stats_init - Initialize the statistics of specific queue
+ * @rxq: Logical Rx Queue
+ **/
+static void rxq_stats_init(struct hinic_rxq *rxq)
+{
+	struct hinic_rxq_stats *rxq_stats = &rxq->rxq_stats;
+
+	u64_stats_init(&rxq_stats->syncp);
+	hinic_rxq_clean_stats(rxq);
+}
+
+/**
+ * hinic_init_rxq - Initialize the Rx Queue
+ * @rxq: Logical Rx Queue
+ * @rq: Hardware Rx Queue to connect the Logical queue with
+ * @netdev: network device to connect the Logical queue with
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_init_rxq(struct hinic_rxq *rxq, struct hinic_rq *rq,
+		   struct net_device *netdev)
+{
+	rxq->netdev = netdev;
+	rxq->rq = rq;
+
+	rxq_stats_init(rxq);
+	return 0;
+}
+
+/**
+ * hinic_clean_rxq - Clean the Rx Queue
+ * @rxq: Logical Rx Queue
+ **/
+void hinic_clean_rxq(struct hinic_rxq *rxq)
+{
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_rx.h b/drivers/net/ethernet/huawei/hinic/hinic_rx.h
new file mode 100644
index 0000000..fbd0246
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_rx.h
@@ -0,0 +1,46 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#ifndef HINIC_RX_H
+#define HINIC_RX_H
+
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/u64_stats_sync.h>
+
+#include "hinic_hw_qp.h"
+
+struct hinic_rxq_stats {
+	u64                     pkts;
+	u64                     bytes;
+
+	struct u64_stats_sync   syncp;
+};
+
+struct hinic_rxq {
+	struct net_device       *netdev;
+	struct hinic_rq         *rq;
+
+	struct hinic_rxq_stats  rxq_stats;
+};
+
+void hinic_rxq_clean_stats(struct hinic_rxq *rxq);
+
+int hinic_init_rxq(struct hinic_rxq *rxq, struct hinic_rq *rq,
+		   struct net_device *netdev);
+
+void hinic_clean_rxq(struct hinic_rxq *rxq);
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_tx.c b/drivers/net/ethernet/huawei/hinic/hinic_tx.c
new file mode 100644
index 0000000..9835912
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_tx.c
@@ -0,0 +1,75 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#include <linux/netdevice.h>
+#include <linux/u64_stats_sync.h>
+
+#include "hinic_hw_qp.h"
+#include "hinic_tx.h"
+
+/**
+ * hinic_txq_clean_stats - Clean the statistics of specific queue
+ * @txq: Logical Tx Queue
+ **/
+void hinic_txq_clean_stats(struct hinic_txq *txq)
+{
+	struct hinic_txq_stats *txq_stats = &txq->txq_stats;
+
+	u64_stats_update_begin(&txq_stats->syncp);
+	txq_stats->pkts    = 0;
+	txq_stats->bytes   = 0;
+	txq_stats->tx_busy = 0;
+	txq_stats->tx_wake = 0;
+	txq_stats->tx_dropped = 0;
+	u64_stats_update_end(&txq_stats->syncp);
+}
+
+/**
+ * txq_stats_init - Initialize the statistics of specific queue
+ * @txq: Logical Tx Queue
+ **/
+static void txq_stats_init(struct hinic_txq *txq)
+{
+	struct hinic_txq_stats *txq_stats = &txq->txq_stats;
+
+	u64_stats_init(&txq_stats->syncp);
+	hinic_txq_clean_stats(txq);
+}
+
+/**
+ * hinic_init_txq - Initialize the Tx Queue
+ * @txq: Logical Tx Queue
+ * @sq: Hardware Tx Queue to connect the Logical queue with
+ * @netdev: network device to connect the Logical queue with
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_init_txq(struct hinic_txq *txq, struct hinic_sq *sq,
+		   struct net_device *netdev)
+{
+	txq->netdev = netdev;
+	txq->sq = sq;
+
+	txq_stats_init(txq);
+	return 0;
+}
+
+/**
+ * hinic_clean_txq - Clean the Tx Queue
+ * @txq: Logical Tx Queue
+ **/
+void hinic_clean_txq(struct hinic_txq *txq)
+{
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_tx.h b/drivers/net/ethernet/huawei/hinic/hinic_tx.h
new file mode 100644
index 0000000..bbdb4b6
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_tx.h
@@ -0,0 +1,49 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#ifndef HINIC_TX_H
+#define HINIC_TX_H
+
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/u64_stats_sync.h>
+
+#include "hinic_hw_qp.h"
+
+struct hinic_txq_stats {
+	u64     pkts;
+	u64     bytes;
+	u64     tx_busy;
+	u64     tx_wake;
+	u64     tx_dropped;
+
+	struct u64_stats_sync   syncp;
+};
+
+struct hinic_txq {
+	struct net_device       *netdev;
+	struct hinic_sq         *sq;
+
+	struct hinic_txq_stats  txq_stats;
+};
+
+void hinic_txq_clean_stats(struct hinic_txq *txq);
+
+int hinic_init_txq(struct hinic_txq *txq, struct hinic_sq *sq,
+		   struct net_device *netdev);
+
+void hinic_clean_txq(struct hinic_txq *txq);
+
+#endif
-- 
1.9.1
