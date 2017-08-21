From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V8 net-next 01/22] net-next/hinic: Initialize hw interface
Date: Mon, 21 Aug 2017 23:55:47 +0800
Message-ID: <0c409781cbf41b3a47136c77f1994577d1227a98.1503330613.git.aviad.krawczyk@huawei.com>
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

Initialize hw interface as part of the nic initialization for accessing hw.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 Documentation/networking/hinic.txt               | 125 ++++++++++++++
 drivers/net/ethernet/Kconfig                     |   1 +
 drivers/net/ethernet/Makefile                    |   1 +
 drivers/net/ethernet/huawei/Kconfig              |  19 +++
 drivers/net/ethernet/huawei/Makefile             |   5 +
 drivers/net/ethernet/huawei/hinic/Kconfig        |  13 ++
 drivers/net/ethernet/huawei/hinic/Makefile       |   3 +
 drivers/net/ethernet/huawei/hinic/hinic_dev.h    |  33 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h |  36 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c | 201 ++++++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h |  42 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.c  | 208 +++++++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h  | 160 +++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_main.c   | 195 +++++++++++++++++++++
 14 files changed, 1042 insertions(+)
 create mode 100644 Documentation/networking/hinic.txt
 create mode 100644 drivers/net/ethernet/huawei/Kconfig
 create mode 100644 drivers/net/ethernet/huawei/Makefile
 create mode 100644 drivers/net/ethernet/huawei/hinic/Kconfig
 create mode 100644 drivers/net/ethernet/huawei/hinic/Makefile
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_dev.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_main.c

diff --git a/Documentation/networking/hinic.txt b/Documentation/networking/hinic.txt
new file mode 100644
index 0000000..989366a
--- /dev/null
+++ b/Documentation/networking/hinic.txt
@@ -0,0 +1,125 @@
+Linux Kernel Driver for Huawei Intelligent NIC(HiNIC) family
+============================================================
+
+Overview:
+=========
+HiNIC is a network interface card for the Data Center Area.
+
+The driver supports a range of link-speed devices (10GbE, 25GbE, 40GbE, etc.).
+The driver supports also a negotiated and extendable feature set.
+
+Some HiNIC devices support SR-IOV. This driver is used for Physical Function
+(PF).
+
+HiNIC devices support MSI-X interrupt vector for each Tx/Rx queue and
+adaptive interrupt moderation.
+
+HiNIC devices support also various offload features such as checksum offload,
+TCP Transmit Segmentation Offload(TSO), Receive-Side Scaling(RSS) and
+LRO(Large Receive Offload).
+
+
+Supported PCI vendor ID/device IDs:
+===================================
+
+19e5:1822 - HiNIC PF
+
+
+Driver Architecture and Source Code:
+====================================
+
+hinic_dev - Implement a Logical Network device that is independent from
+specific HW details about HW data structure formats.
+
+hinic_hwdev - Implement the HW details of the device and include the components
+for accessing the PCI NIC.
+
+hinic_hwdev contains the following components:
+===============================================
+
+HW Interface:
+=============
+
+The interface for accessing the pci device (DMA memory and PCI BARs).
+(hinic_hw_if.c, hinic_hw_if.h)
+
+Configuration Status Registers Area that describes the HW Registers on the
+configuration and status BAR0. (hinic_hw_csr.h)
+
+MGMT components:
+================
+
+Asynchronous Event Queues(AEQs) - The event queues for receiving messages from
+the MGMT modules on the cards. (hinic_hw_eqs.c, hinic_hw_eqs.h)
+
+Application Programmable Interface commands(API CMD) - Interface for sending
+MGMT commands to the card. (hinic_hw_api_cmd.c, hinic_hw_api_cmd.h)
+
+Management (MGMT) - the PF to MGMT channel that uses API CMD for sending MGMT
+commands to the card and receives notifications from the MGMT modules on the
+card by AEQs. Also set the addresses of the IO CMDQs in HW.
+(hinic_hw_mgmt.c, hinic_hw_mgmt.h)
+
+IO components:
+==============
+
+Completion Event Queues(CEQs) - The completion Event Queues that describe IO
+tasks that are finished. (hinic_hw_eqs.c, hinic_hw_eqs.h)
+
+Work Queues(WQ) - Contain the memory and operations for use by CMD queues and
+the Queue Pairs. The WQ is a Memory Block in a Page. The Block contains
+pointers to Memory Areas that are the Memory for the Work Queue Elements(WQEs).
+(hinic_hw_wq.c, hinic_hw_wq.h)
+
+Command Queues(CMDQ) - The queues for sending commands for IO management and is
+used to set the QPs addresses in HW. The commands completion events are
+accumulated on the CEQ that is configured to receive the CMDQ completion events.
+(hinic_hw_cmdq.c, hinic_hw_cmdq.h)
+
+Queue Pairs(QPs) - The HW Receive and Send queues for Receiving and Transmitting
+Data. (hinic_hw_qp.c, hinic_hw_qp.h, hinic_hw_qp_ctxt.h)
+
+IO - de/constructs all the IO components. (hinic_hw_io.c, hinic_hw_io.h)
+
+HW device:
+==========
+
+HW device - de/constructs the HW Interface, the MGMT components on the
+initialization of the driver and the IO components on the case of Interface
+UP/DOWN Events. (hinic_hw_dev.c, hinic_hw_dev.h)
+
+
+hinic_dev contains the following components:
+===============================================
+
+PCI ID table - Contains the supported PCI Vendor/Device IDs.
+(hinic_pci_tbl.h)
+
+Port Commands - Send commands to the HW device for port management
+(MAC, Vlan, MTU, ...). (hinic_port.c, hinic_port.h)
+
+Tx Queues - Logical Tx Queues that use the HW Send Queues for transmit.
+The Logical Tx queue is not dependent on the format of the HW Send Queue.
+(hinic_tx.c, hinic_tx.h)
+
+Rx Queues - Logical Rx Queues that use the HW Receive Queues for receive.
+The Logical Rx queue is not dependent on the format of the HW Receive Queue.
+(hinic_rx.c, hinic_rx.h)
+
+hinic_dev - de/constructs the Logical Tx and Rx Queues.
+(hinic_main.c, hinic_dev.h)
+
+
+Miscellaneous:
+=============
+
+Common functions that are used by HW and Logical Device.
+(hinic_common.c, hinic_common.h)
+
+
+Support
+=======
+
+If an issue is identified with the released source code on the supported kernel
+with a supported adapter, email the specific information related to the issue to
+aviad.krawczyk@huawei.com.
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index edae15ac..c604213 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -78,6 +78,7 @@ source "drivers/net/ethernet/freescale/Kconfig"
 source "drivers/net/ethernet/fujitsu/Kconfig"
 source "drivers/net/ethernet/hisilicon/Kconfig"
 source "drivers/net/ethernet/hp/Kconfig"
+source "drivers/net/ethernet/huawei/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index bf7f450..a0a03d4 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -41,6 +41,7 @@ obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
 obj-$(CONFIG_NET_VENDOR_FUJITSU) += fujitsu/
 obj-$(CONFIG_NET_VENDOR_HISILICON) += hisilicon/
 obj-$(CONFIG_NET_VENDOR_HP) += hp/
+obj-$(CONFIG_NET_VENDOR_HUAWEI) += huawei/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
diff --git a/drivers/net/ethernet/huawei/Kconfig b/drivers/net/ethernet/huawei/Kconfig
new file mode 100644
index 0000000..c1a95ae
--- /dev/null
+++ b/drivers/net/ethernet/huawei/Kconfig
@@ -0,0 +1,19 @@
+#
+# Huawei driver configuration
+#
+
+config NET_VENDOR_HUAWEI
+	bool "Huawei devices"
+	default y
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y.
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Huawei cards. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+if NET_VENDOR_HUAWEI
+
+source "drivers/net/ethernet/huawei/hinic/Kconfig"
+
+endif # NET_VENDOR_HUAWEI
diff --git a/drivers/net/ethernet/huawei/Makefile b/drivers/net/ethernet/huawei/Makefile
new file mode 100644
index 0000000..5c37cc8
--- /dev/null
+++ b/drivers/net/ethernet/huawei/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Huawei device drivers.
+#
+
+obj-$(CONFIG_HINIC) += hinic/
diff --git a/drivers/net/ethernet/huawei/hinic/Kconfig b/drivers/net/ethernet/huawei/hinic/Kconfig
new file mode 100644
index 0000000..69f2b1f
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/Kconfig
@@ -0,0 +1,13 @@
+#
+# Huawei driver configuration
+#
+
+config HINIC
+	tristate "Huawei Intelligent PCIE Network Interface Card"
+	depends on (PCI_MSI && X86)
+	default m
+	---help---
+	  This driver supports HiNIC PCIE Ethernet cards.
+	  To compile this driver as part of the kernel, choose Y here.
+	  If unsure, choose N.
+	  The default is compiled as module.
diff --git a/drivers/net/ethernet/huawei/hinic/Makefile b/drivers/net/ethernet/huawei/hinic/Makefile
new file mode 100644
index 0000000..353cee0
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_HINIC) += hinic.o
+
+hinic-y := hinic_main.o hinic_hw_dev.o hinic_hw_if.o
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
new file mode 100644
index 0000000..6c2c896
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
@@ -0,0 +1,33 @@
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
+#ifndef HINIC_DEV_H
+#define HINIC_DEV_H
+
+#include <linux/netdevice.h>
+#include <linux/types.h>
+
+#include "hinic_hw_dev.h"
+
+#define HINIC_DRV_NAME          "hinic"
+
+struct hinic_dev {
+	struct net_device               *netdev;
+	struct hinic_hwdev              *hwdev;
+
+	u32                             msg_enable;
+};
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
new file mode 100644
index 0000000..c3440a9
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
@@ -0,0 +1,36 @@
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
+#ifndef HINIC_HW_CSR_H
+#define HINIC_HW_CSR_H
+
+/* HW interface registers */
+#define HINIC_CSR_FUNC_ATTR0_ADDR                       0x0
+#define HINIC_CSR_FUNC_ATTR1_ADDR                       0x4
+
+#define HINIC_DMA_ATTR_BASE                             0xC80
+#define HINIC_ELECTION_BASE                             0x4200
+
+#define HINIC_DMA_ATTR_STRIDE                           0x4
+#define HINIC_CSR_DMA_ATTR_ADDR(idx)                    \
+	(HINIC_DMA_ATTR_BASE + (idx) * HINIC_DMA_ATTR_STRIDE)
+
+#define HINIC_PPF_ELECTION_STRIDE                       0x4
+#define HINIC_CSR_MAX_PORTS                             4
+
+#define HINIC_CSR_PPF_ELECTION_ADDR(idx)                \
+	(HINIC_ELECTION_BASE +  (idx) * HINIC_PPF_ELECTION_STRIDE)
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
new file mode 100644
index 0000000..f681846
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
@@ -0,0 +1,201 @@
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
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/bitops.h>
+#include <linux/err.h>
+
+#include "hinic_hw_if.h"
+#include "hinic_hw_dev.h"
+
+#define MAX_IRQS(max_qps, num_aeqs, num_ceqs)   \
+		 (2 * (max_qps) + (num_aeqs) + (num_ceqs))
+
+/**
+ * init_msix - enable the msix and save the entries
+ * @hwdev: the NIC HW device
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int init_msix(struct hinic_hwdev *hwdev)
+{
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int nr_irqs, num_aeqs, num_ceqs;
+	size_t msix_entries_size;
+	int i, err;
+
+	num_aeqs = HINIC_HWIF_NUM_AEQS(hwif);
+	num_ceqs = HINIC_HWIF_NUM_CEQS(hwif);
+	nr_irqs = MAX_IRQS(HINIC_MAX_QPS, num_aeqs, num_ceqs);
+	if (nr_irqs > HINIC_HWIF_NUM_IRQS(hwif))
+		nr_irqs = HINIC_HWIF_NUM_IRQS(hwif);
+
+	msix_entries_size = nr_irqs * sizeof(*hwdev->msix_entries);
+	hwdev->msix_entries = devm_kzalloc(&pdev->dev, msix_entries_size,
+					   GFP_KERNEL);
+	if (!hwdev->msix_entries)
+		return -ENOMEM;
+
+	for (i = 0; i < nr_irqs; i++)
+		hwdev->msix_entries[i].entry = i;
+
+	err = pci_enable_msix_exact(pdev, hwdev->msix_entries, nr_irqs);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to enable pci msix\n");
+		return err;
+	}
+
+	return 0;
+}
+
+/**
+ * disable_msix - disable the msix
+ * @hwdev: the NIC HW device
+ **/
+static void disable_msix(struct hinic_hwdev *hwdev)
+{
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+
+	pci_disable_msix(pdev);
+}
+
+/**
+ * init_pfhwdev - Initialize the extended components of PF
+ * @pfhwdev: the HW device for PF
+ *
+ * Return 0 - success, negative - failure
+ **/
+static int init_pfhwdev(struct hinic_pfhwdev *pfhwdev)
+{
+	/* Initialize PF HW device extended components */
+	return 0;
+}
+
+/**
+ * free_pfhwdev - Free the extended components of PF
+ * @pfhwdev: the HW device for PF
+ **/
+static void free_pfhwdev(struct hinic_pfhwdev *pfhwdev)
+{
+}
+
+/**
+ * hinic_init_hwdev - Initialize the NIC HW
+ * @pdev: the NIC pci device
+ *
+ * Return initialized NIC HW device
+ *
+ * Initialize the NIC HW device and return a pointer to it
+ **/
+struct hinic_hwdev *hinic_init_hwdev(struct pci_dev *pdev)
+{
+	struct hinic_pfhwdev *pfhwdev;
+	struct hinic_hwdev *hwdev;
+	struct hinic_hwif *hwif;
+	int err;
+
+	hwif = devm_kzalloc(&pdev->dev, sizeof(*hwif), GFP_KERNEL);
+	if (!hwif)
+		return ERR_PTR(-ENOMEM);
+
+	err = hinic_init_hwif(hwif, pdev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init HW interface\n");
+		return ERR_PTR(err);
+	}
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "Unsupported PCI Function type\n");
+		err = -EFAULT;
+		goto err_func_type;
+	}
+
+	pfhwdev = devm_kzalloc(&pdev->dev, sizeof(*pfhwdev), GFP_KERNEL);
+	if (!pfhwdev) {
+		err = -ENOMEM;
+		goto err_pfhwdev_alloc;
+	}
+
+	hwdev = &pfhwdev->hwdev;
+	hwdev->hwif = hwif;
+
+	err = init_msix(hwdev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init msix\n");
+		goto err_init_msix;
+	}
+
+	err = init_pfhwdev(pfhwdev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init PF HW device\n");
+		goto err_init_pfhwdev;
+	}
+
+	return hwdev;
+
+err_init_pfhwdev:
+	disable_msix(hwdev);
+
+err_init_msix:
+err_pfhwdev_alloc:
+err_func_type:
+	hinic_free_hwif(hwif);
+	return ERR_PTR(err);
+}
+
+/**
+ * hinic_free_hwdev - Free the NIC HW device
+ * @hwdev: the NIC HW device
+ **/
+void hinic_free_hwdev(struct hinic_hwdev *hwdev)
+{
+	struct hinic_pfhwdev *pfhwdev = container_of(hwdev,
+						     struct hinic_pfhwdev,
+						     hwdev);
+
+	free_pfhwdev(pfhwdev);
+
+	disable_msix(hwdev);
+
+	hinic_free_hwif(hwdev->hwif);
+}
+
+/**
+ * hinic_hwdev_num_qps - return the number QPs available for use
+ * @hwdev: the NIC HW device
+ *
+ * Return number QPs available for use
+ **/
+int hinic_hwdev_num_qps(struct hinic_hwdev *hwdev)
+{
+	int num_aeqs, num_ceqs, nr_irqs, num_qps;
+
+	num_aeqs = HINIC_HWIF_NUM_AEQS(hwdev->hwif);
+	num_ceqs = HINIC_HWIF_NUM_CEQS(hwdev->hwif);
+	nr_irqs  = HINIC_HWIF_NUM_IRQS(hwdev->hwif);
+
+	/* Each QP has its own (SQ + RQ) interrupt */
+	num_qps = (nr_irqs - (num_aeqs + num_ceqs)) / 2;
+
+	/* num_qps must be power of 2 */
+	return BIT(fls(num_qps) - 1);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
new file mode 100644
index 0000000..b42e0eb
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
@@ -0,0 +1,42 @@
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
+#ifndef HINIC_HW_DEV_H
+#define HINIC_HW_DEV_H
+
+#include <linux/pci.h>
+
+#include "hinic_hw_if.h"
+
+#define HINIC_MAX_QPS   32
+
+struct hinic_hwdev {
+	struct hinic_hwif               *hwif;
+	struct msix_entry               *msix_entries;
+};
+
+struct hinic_pfhwdev {
+	struct hinic_hwdev              hwdev;
+
+	/* PF Extended components should be here */
+};
+
+struct hinic_hwdev *hinic_init_hwdev(struct pci_dev *pdev);
+
+void hinic_free_hwdev(struct hinic_hwdev *hwdev);
+
+int hinic_hwdev_num_qps(struct hinic_hwdev *hwdev);
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
new file mode 100644
index 0000000..edf1842
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
@@ -0,0 +1,208 @@
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
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/errno.h>
+#include <linux/io.h>
+#include <linux/types.h>
+#include <linux/bitops.h>
+
+#include "hinic_hw_csr.h"
+#include "hinic_hw_if.h"
+
+#define PCIE_ATTR_ENTRY         0
+
+/**
+ * hwif_ready - test if the HW is ready for use
+ * @hwif: the HW interface of a pci function device
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int hwif_ready(struct hinic_hwif *hwif)
+{
+	struct pci_dev *pdev = hwif->pdev;
+	u32 addr, attr1;
+
+	addr   = HINIC_CSR_FUNC_ATTR1_ADDR;
+	attr1  = hinic_hwif_read_reg(hwif, addr);
+
+	if (!HINIC_FA1_GET(attr1, INIT_STATUS)) {
+		dev_err(&pdev->dev, "hwif status is not ready\n");
+		return -EFAULT;
+	}
+
+	return 0;
+}
+
+/**
+ * set_hwif_attr - set the attributes in the relevant members in hwif
+ * @hwif: the HW interface of a pci function device
+ * @attr0: the first attribute that was read from the hw
+ * @attr1: the second attribute that was read from the hw
+ **/
+static void set_hwif_attr(struct hinic_hwif *hwif, u32 attr0, u32 attr1)
+{
+	hwif->attr.func_idx     = HINIC_FA0_GET(attr0, FUNC_IDX);
+	hwif->attr.pf_idx       = HINIC_FA0_GET(attr0, PF_IDX);
+	hwif->attr.pci_intf_idx = HINIC_FA0_GET(attr0, PCI_INTF_IDX);
+	hwif->attr.func_type    = HINIC_FA0_GET(attr0, FUNC_TYPE);
+
+	hwif->attr.num_aeqs = BIT(HINIC_FA1_GET(attr1, AEQS_PER_FUNC));
+	hwif->attr.num_ceqs = BIT(HINIC_FA1_GET(attr1, CEQS_PER_FUNC));
+	hwif->attr.num_irqs = BIT(HINIC_FA1_GET(attr1, IRQS_PER_FUNC));
+	hwif->attr.num_dma_attr = BIT(HINIC_FA1_GET(attr1, DMA_ATTR_PER_FUNC));
+}
+
+/**
+ * read_hwif_attr - read the attributes and set members in hwif
+ * @hwif: the HW interface of a pci function device
+ **/
+static void read_hwif_attr(struct hinic_hwif *hwif)
+{
+	u32 addr, attr0, attr1;
+
+	addr   = HINIC_CSR_FUNC_ATTR0_ADDR;
+	attr0  = hinic_hwif_read_reg(hwif, addr);
+
+	addr   = HINIC_CSR_FUNC_ATTR1_ADDR;
+	attr1  = hinic_hwif_read_reg(hwif, addr);
+
+	set_hwif_attr(hwif, attr0, attr1);
+}
+
+/**
+ * set_ppf - try to set hwif as ppf and set the type of hwif in this case
+ * @hwif: the HW interface of a pci function device
+ **/
+static void set_ppf(struct hinic_hwif *hwif)
+{
+	struct hinic_func_attr *attr = &hwif->attr;
+	u32 addr, val, ppf_election;
+
+	/* Read Modify Write */
+	addr = HINIC_CSR_PPF_ELECTION_ADDR(HINIC_HWIF_PCI_INTF(hwif));
+
+	val = hinic_hwif_read_reg(hwif, addr);
+	val = HINIC_PPF_ELECTION_CLEAR(val, IDX);
+
+	ppf_election = HINIC_PPF_ELECTION_SET(HINIC_HWIF_FUNC_IDX(hwif), IDX);
+
+	val |= ppf_election;
+	hinic_hwif_write_reg(hwif, addr, val);
+
+	/* check PPF */
+	val = hinic_hwif_read_reg(hwif, addr);
+
+	attr->ppf_idx = HINIC_PPF_ELECTION_GET(val, IDX);
+	if (attr->ppf_idx == HINIC_HWIF_FUNC_IDX(hwif))
+		attr->func_type = HINIC_PPF;
+}
+
+/**
+ * set_dma_attr - set the dma attributes in the HW
+ * @hwif: the HW interface of a pci function device
+ * @entry_idx: the entry index in the dma table
+ * @st: PCIE TLP steering tag
+ * @at: PCIE TLP AT field
+ * @ph: PCIE TLP Processing Hint field
+ * @no_snooping: PCIE TLP No snooping
+ * @tph_en: PCIE TLP Processing Hint Enable
+ **/
+static void set_dma_attr(struct hinic_hwif *hwif, u32 entry_idx,
+			 u8 st, u8 at, u8 ph,
+			 enum hinic_pcie_nosnoop no_snooping,
+			 enum hinic_pcie_tph tph_en)
+{
+	u32 addr, val, dma_attr_entry;
+
+	/* Read Modify Write */
+	addr = HINIC_CSR_DMA_ATTR_ADDR(entry_idx);
+
+	val = hinic_hwif_read_reg(hwif, addr);
+	val = HINIC_DMA_ATTR_CLEAR(val, ST)             &
+	      HINIC_DMA_ATTR_CLEAR(val, AT)             &
+	      HINIC_DMA_ATTR_CLEAR(val, PH)             &
+	      HINIC_DMA_ATTR_CLEAR(val, NO_SNOOPING)    &
+	      HINIC_DMA_ATTR_CLEAR(val, TPH_EN);
+
+	dma_attr_entry = HINIC_DMA_ATTR_SET(st, ST)                     |
+			 HINIC_DMA_ATTR_SET(at, AT)                     |
+			 HINIC_DMA_ATTR_SET(ph, PH)                     |
+			 HINIC_DMA_ATTR_SET(no_snooping, NO_SNOOPING)   |
+			 HINIC_DMA_ATTR_SET(tph_en, TPH_EN);
+
+	val |= dma_attr_entry;
+	hinic_hwif_write_reg(hwif, addr, val);
+}
+
+/**
+ * dma_attr_table_init - initialize the the default dma attributes
+ * @hwif: the HW interface of a pci function device
+ **/
+static void dma_attr_init(struct hinic_hwif *hwif)
+{
+	set_dma_attr(hwif, PCIE_ATTR_ENTRY, HINIC_PCIE_ST_DISABLE,
+		     HINIC_PCIE_AT_DISABLE, HINIC_PCIE_PH_DISABLE,
+		     HINIC_PCIE_SNOOP, HINIC_PCIE_TPH_DISABLE);
+}
+
+/**
+ * hinic_init_hwif - initialize the hw interface
+ * @hwif: the HW interface of a pci function device
+ * @pdev: the pci device for acessing PCI resources
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_init_hwif(struct hinic_hwif *hwif, struct pci_dev *pdev)
+{
+	int err;
+
+	hwif->pdev = pdev;
+
+	hwif->cfg_regs_bar = pci_ioremap_bar(pdev, HINIC_PCI_CFG_REGS_BAR);
+	if (!hwif->cfg_regs_bar) {
+		dev_err(&pdev->dev, "Failed to map configuration regs\n");
+		return -ENOMEM;
+	}
+
+	err = hwif_ready(hwif);
+	if (err) {
+		dev_err(&pdev->dev, "HW interface is not ready\n");
+		goto err_hwif_ready;
+	}
+
+	read_hwif_attr(hwif);
+
+	if (HINIC_IS_PF(hwif))
+		set_ppf(hwif);
+
+	/* No transactionss before DMA is initialized */
+	dma_attr_init(hwif);
+	return 0;
+
+err_hwif_ready:
+	iounmap(hwif->cfg_regs_bar);
+	return err;
+}
+
+/**
+ * hinic_free_hwif - free the HW interface
+ * @hwif: the HW interface of a pci function device
+ **/
+void hinic_free_hwif(struct hinic_hwif *hwif)
+{
+	iounmap(hwif->cfg_regs_bar);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
new file mode 100644
index 0000000..d1a8fa2
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
@@ -0,0 +1,160 @@
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
+#ifndef HINIC_HW_IF_H
+#define HINIC_HW_IF_H
+
+#include <linux/pci.h>
+#include <linux/io.h>
+#include <linux/types.h>
+#include <asm/byteorder.h>
+
+#define HINIC_DMA_ATTR_ST_SHIFT                                 0
+#define HINIC_DMA_ATTR_AT_SHIFT                                 8
+#define HINIC_DMA_ATTR_PH_SHIFT                                 10
+#define HINIC_DMA_ATTR_NO_SNOOPING_SHIFT                        12
+#define HINIC_DMA_ATTR_TPH_EN_SHIFT                             13
+
+#define HINIC_DMA_ATTR_ST_MASK                                  0xFF
+#define HINIC_DMA_ATTR_AT_MASK                                  0x3
+#define HINIC_DMA_ATTR_PH_MASK                                  0x3
+#define HINIC_DMA_ATTR_NO_SNOOPING_MASK                         0x1
+#define HINIC_DMA_ATTR_TPH_EN_MASK                              0x1
+
+#define HINIC_DMA_ATTR_SET(val, member)                         \
+	(((u32)(val) & HINIC_DMA_ATTR_##member##_MASK) <<       \
+	 HINIC_DMA_ATTR_##member##_SHIFT)
+
+#define HINIC_DMA_ATTR_CLEAR(val, member)                       \
+	((val) & (~(HINIC_DMA_ATTR_##member##_MASK              \
+	 << HINIC_DMA_ATTR_##member##_SHIFT)))
+
+#define HINIC_FA0_FUNC_IDX_SHIFT                                0
+#define HINIC_FA0_PF_IDX_SHIFT                                  10
+#define HINIC_FA0_PCI_INTF_IDX_SHIFT                            14
+/* reserved members - off 16 */
+#define HINIC_FA0_FUNC_TYPE_SHIFT                               24
+
+#define HINIC_FA0_FUNC_IDX_MASK                                 0x3FF
+#define HINIC_FA0_PF_IDX_MASK                                   0xF
+#define HINIC_FA0_PCI_INTF_IDX_MASK                             0x3
+#define HINIC_FA0_FUNC_TYPE_MASK                                0x1
+
+#define HINIC_FA0_GET(val, member)                              \
+	(((val) >> HINIC_FA0_##member##_SHIFT) & HINIC_FA0_##member##_MASK)
+
+#define HINIC_FA1_AEQS_PER_FUNC_SHIFT                           8
+/* reserved members - off 10 */
+#define HINIC_FA1_CEQS_PER_FUNC_SHIFT                           12
+/* reserved members - off 15 */
+#define HINIC_FA1_IRQS_PER_FUNC_SHIFT                           20
+#define HINIC_FA1_DMA_ATTR_PER_FUNC_SHIFT                       24
+/* reserved members - off 27 */
+#define HINIC_FA1_INIT_STATUS_SHIFT                             30
+
+#define HINIC_FA1_AEQS_PER_FUNC_MASK                            0x3
+#define HINIC_FA1_CEQS_PER_FUNC_MASK                            0x7
+#define HINIC_FA1_IRQS_PER_FUNC_MASK                            0xF
+#define HINIC_FA1_DMA_ATTR_PER_FUNC_MASK                        0x7
+#define HINIC_FA1_INIT_STATUS_MASK                              0x1
+
+#define HINIC_FA1_GET(val, member)                              \
+	(((val) >> HINIC_FA1_##member##_SHIFT) & HINIC_FA1_##member##_MASK)
+
+#define HINIC_PPF_ELECTION_IDX_SHIFT                            0
+#define HINIC_PPF_ELECTION_IDX_MASK                             0x1F
+
+#define HINIC_PPF_ELECTION_SET(val, member)                     \
+	(((u32)(val) & HINIC_PPF_ELECTION_##member##_MASK) <<   \
+	 HINIC_PPF_ELECTION_##member##_SHIFT)
+
+#define HINIC_PPF_ELECTION_GET(val, member)                     \
+	(((val) >> HINIC_PPF_ELECTION_##member##_SHIFT) &       \
+	 HINIC_PPF_ELECTION_##member##_MASK)
+
+#define HINIC_PPF_ELECTION_CLEAR(val, member)                   \
+	((val) & (~(HINIC_PPF_ELECTION_##member##_MASK          \
+	 << HINIC_PPF_ELECTION_##member##_SHIFT)))
+
+#define HINIC_HWIF_NUM_AEQS(hwif)       ((hwif)->attr.num_aeqs)
+#define HINIC_HWIF_NUM_CEQS(hwif)       ((hwif)->attr.num_ceqs)
+#define HINIC_HWIF_NUM_IRQS(hwif)       ((hwif)->attr.num_irqs)
+#define HINIC_HWIF_FUNC_IDX(hwif)       ((hwif)->attr.func_idx)
+#define HINIC_HWIF_PCI_INTF(hwif)       ((hwif)->attr.pci_intf_idx)
+
+#define HINIC_FUNC_TYPE(hwif)           ((hwif)->attr.func_type)
+#define HINIC_IS_PF(hwif)               (HINIC_FUNC_TYPE(hwif) == HINIC_PF)
+#define HINIC_IS_PPF(hwif)              (HINIC_FUNC_TYPE(hwif) == HINIC_PPF)
+
+#define HINIC_PCI_CFG_REGS_BAR          0
+
+#define HINIC_PCIE_ST_DISABLE           0
+#define HINIC_PCIE_AT_DISABLE           0
+#define HINIC_PCIE_PH_DISABLE           0
+
+enum hinic_pcie_nosnoop {
+	HINIC_PCIE_SNOOP        = 0,
+	HINIC_PCIE_NO_SNOOP     = 1,
+};
+
+enum hinic_pcie_tph {
+	HINIC_PCIE_TPH_DISABLE  = 0,
+	HINIC_PCIE_TPH_ENABLE   = 1,
+};
+
+enum hinic_func_type {
+	HINIC_PF        = 0,
+	HINIC_PPF       = 2,
+};
+
+struct hinic_func_attr {
+	u16                     func_idx;
+	u8                      pf_idx;
+	u8                      pci_intf_idx;
+
+	enum hinic_func_type    func_type;
+
+	u8                      ppf_idx;
+
+	u16                     num_irqs;
+	u8                      num_aeqs;
+	u8                      num_ceqs;
+
+	u8                      num_dma_attr;
+};
+
+struct hinic_hwif {
+	struct pci_dev          *pdev;
+	void __iomem            *cfg_regs_bar;
+
+	struct hinic_func_attr  attr;
+};
+
+static inline u32 hinic_hwif_read_reg(struct hinic_hwif *hwif, u32 reg)
+{
+	return be32_to_cpu(readl(hwif->cfg_regs_bar + reg));
+}
+
+static inline void hinic_hwif_write_reg(struct hinic_hwif *hwif, u32 reg,
+					u32 val)
+{
+	writel(cpu_to_be32(val), hwif->cfg_regs_bar + reg);
+}
+
+int hinic_init_hwif(struct hinic_hwif *hwif, struct pci_dev *pdev);
+
+void hinic_free_hwif(struct hinic_hwif *hwif);
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
new file mode 100644
index 0000000..1d7aed0
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
@@ -0,0 +1,195 @@
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
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/etherdevice.h>
+#include <linux/netdevice.h>
+#include <linux/err.h>
+
+#include "hinic_hw_dev.h"
+#include "hinic_dev.h"
+
+MODULE_AUTHOR("Huawei Technologies CO., Ltd");
+MODULE_DESCRIPTION("Huawei Intelligent NIC driver");
+MODULE_LICENSE("GPL");
+
+#define PCI_DEVICE_ID_HI1822_PF         0x1822
+
+#define MSG_ENABLE_DEFAULT              (NETIF_MSG_DRV | NETIF_MSG_PROBE | \
+					 NETIF_MSG_IFUP |                  \
+					 NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR)
+
+static const struct net_device_ops hinic_netdev_ops = {
+	/* Operations are empty, should be filled */
+};
+
+/**
+ * nic_dev_init - Initialize the NIC device
+ * @pdev: the NIC pci device
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int nic_dev_init(struct pci_dev *pdev)
+{
+	struct hinic_dev *nic_dev;
+	struct net_device *netdev;
+	struct hinic_hwdev *hwdev;
+	int err, num_qps;
+
+	hwdev = hinic_init_hwdev(pdev);
+	if (IS_ERR(hwdev)) {
+		dev_err(&pdev->dev, "Failed to initialize HW device\n");
+		return PTR_ERR(hwdev);
+	}
+
+	num_qps = hinic_hwdev_num_qps(hwdev);
+	if (num_qps <= 0) {
+		dev_err(&pdev->dev, "Invalid number of QPS\n");
+		err = -EINVAL;
+		goto err_num_qps;
+	}
+
+	netdev = alloc_etherdev_mq(sizeof(*nic_dev), num_qps);
+	if (!netdev) {
+		dev_err(&pdev->dev, "Failed to allocate Ethernet device\n");
+		err = -ENOMEM;
+		goto err_alloc_etherdev;
+	}
+
+	netdev->netdev_ops = &hinic_netdev_ops;
+
+	nic_dev = netdev_priv(netdev);
+	nic_dev->netdev = netdev;
+	nic_dev->hwdev  = hwdev;
+	nic_dev->msg_enable = MSG_ENABLE_DEFAULT;
+
+	pci_set_drvdata(pdev, netdev);
+
+	netif_carrier_off(netdev);
+
+	err = register_netdev(netdev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to register netdev\n");
+		goto err_reg_netdev;
+	}
+
+	return 0;
+
+err_reg_netdev:
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(netdev);
+
+err_alloc_etherdev:
+err_num_qps:
+	hinic_free_hwdev(hwdev);
+	return err;
+}
+
+static int hinic_probe(struct pci_dev *pdev,
+		       const struct pci_device_id *id)
+{
+	int err = pci_enable_device(pdev);
+
+	if (err) {
+		dev_err(&pdev->dev, "Failed to enable PCI device\n");
+		return err;
+	}
+
+	err = pci_request_regions(pdev, HINIC_DRV_NAME);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to request PCI regions\n");
+		goto err_pci_regions;
+	}
+
+	pci_set_master(pdev);
+
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
+	if (err) {
+		dev_warn(&pdev->dev, "Couldn't set 64-bit DMA mask\n");
+		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (err) {
+			dev_err(&pdev->dev, "Failed to set DMA mask\n");
+			goto err_dma_mask;
+		}
+	}
+
+	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
+	if (err) {
+		dev_warn(&pdev->dev,
+			 "Couldn't set 64-bit consistent DMA mask\n");
+		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
+		if (err) {
+			dev_err(&pdev->dev,
+				"Failed to set consistent DMA mask\n");
+			goto err_dma_consistent_mask;
+		}
+	}
+
+	err = nic_dev_init(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to initialize NIC device\n");
+		goto err_nic_dev_init;
+	}
+
+	dev_info(&pdev->dev, "HiNIC driver - probed\n");
+	return 0;
+
+err_nic_dev_init:
+err_dma_consistent_mask:
+err_dma_mask:
+	pci_release_regions(pdev);
+
+err_pci_regions:
+	pci_disable_device(pdev);
+	return err;
+}
+
+static void hinic_remove(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+
+	unregister_netdev(netdev);
+
+	pci_set_drvdata(pdev, NULL);
+
+	hinic_free_hwdev(nic_dev->hwdev);
+
+	free_netdev(netdev);
+
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+
+	dev_info(&pdev->dev, "HiNIC driver - removed\n");
+}
+
+static const struct pci_device_id hinic_pci_table[] = {
+	{ PCI_VDEVICE(HUAWEI, PCI_DEVICE_ID_HI1822_PF), 0},
+	{ 0, 0}
+};
+MODULE_DEVICE_TABLE(pci, hinic_pci_table);
+
+static struct pci_driver hinic_driver = {
+	.name           = HINIC_DRV_NAME,
+	.id_table       = hinic_pci_table,
+	.probe          = hinic_probe,
+	.remove         = hinic_remove,
+};
+
+module_pci_driver(hinic_driver);
-- 
1.9.1
