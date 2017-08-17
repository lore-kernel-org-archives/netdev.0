From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V6 02/21] net-next/hinic: Initialize hw device components
Date: Thu, 17 Aug 2017 20:25:10 +0800
Message-ID: <e7d3439ef9fba3e388dcaa39eebb531d616a205d.1502972068.git.aviad.krawczyk@huawei.com>
References: <cover.1502972068.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502972068.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initialize hw device by calling the initialization functions of aeqs and
management channel.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/Makefile        |   3 +-
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c  | 172 ++++++++++++++++++++--
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h  |  14 +-
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c  | 149 +++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h  | 107 ++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h   |   8 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c |  92 ++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h |  45 ++++++
 8 files changed, 576 insertions(+), 14 deletions(-)
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h

diff --git a/drivers/net/ethernet/huawei/hinic/Makefile b/drivers/net/ethernet/huawei/hinic/Makefile
index 353cee0..717ad71 100644
--- a/drivers/net/ethernet/huawei/hinic/Makefile
+++ b/drivers/net/ethernet/huawei/hinic/Makefile
@@ -1,3 +1,4 @@
 obj-$(CONFIG_HINIC) += hinic.o
 
-hinic-y := hinic_main.o hinic_hw_dev.o hinic_hw_if.o
+hinic-y := hinic_main.o hinic_hw_dev.o hinic_hw_mgmt.o hinic_hw_eqs.o \
+	   hinic_hw_if.o
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
index f681846..d430e60 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
@@ -23,11 +23,132 @@
 #include <linux/err.h>
 
 #include "hinic_hw_if.h"
+#include "hinic_hw_eqs.h"
+#include "hinic_hw_mgmt.h"
 #include "hinic_hw_dev.h"
 
 #define MAX_IRQS(max_qps, num_aeqs, num_ceqs)   \
 		 (2 * (max_qps) + (num_aeqs) + (num_ceqs))
 
+enum intr_type {
+	INTR_MSIX_TYPE,
+};
+
+/* HW struct */
+struct hinic_dev_cap {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u8      rsvd1[5];
+	u8      intr_type;
+	u8      rsvd2[66];
+	u16     max_sqs;
+	u16     max_rqs;
+	u8      rsvd3[208];
+};
+
+/**
+ * get_capability - convert device capabilities to NIC capabilities
+ * @hwdev: the HW device to set and convert device capabilities for
+ * @dev_cap: device capabilities from FW
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int get_capability(struct hinic_hwdev *hwdev,
+			  struct hinic_dev_cap *dev_cap)
+{
+	struct hinic_cap *nic_cap = &hwdev->nic_cap;
+	int num_aeqs, num_ceqs, num_irqs;
+
+	if (!HINIC_IS_PF(hwdev->hwif) && !HINIC_IS_PPF(hwdev->hwif))
+		return -EINVAL;
+
+	if (dev_cap->intr_type != INTR_MSIX_TYPE)
+		return -EFAULT;
+
+	num_aeqs = HINIC_HWIF_NUM_AEQS(hwdev->hwif);
+	num_ceqs = HINIC_HWIF_NUM_CEQS(hwdev->hwif);
+	num_irqs = HINIC_HWIF_NUM_IRQS(hwdev->hwif);
+
+	/* Each QP has its own (SQ + RQ) interrupts */
+	nic_cap->num_qps = (num_irqs - (num_aeqs + num_ceqs)) / 2;
+
+	/* num_qps must be power of 2 */
+	nic_cap->num_qps = BIT(fls(nic_cap->num_qps) - 1);
+
+	nic_cap->max_qps = dev_cap->max_sqs + 1;
+	if (nic_cap->max_qps != (dev_cap->max_rqs + 1))
+		return -EFAULT;
+
+	if (nic_cap->num_qps > nic_cap->max_qps)
+		nic_cap->num_qps = nic_cap->max_qps;
+
+	return 0;
+}
+
+/**
+ * get_cap_from_fw - get device capabilities from FW
+ * @pfhwdev: the PF HW device to get capabilities for
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int get_cap_from_fw(struct hinic_pfhwdev *pfhwdev)
+{
+	struct hinic_hwdev *hwdev = &pfhwdev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_dev_cap dev_cap;
+	u16 in_len, out_len;
+	int err;
+
+	in_len = 0;
+	out_len = sizeof(dev_cap);
+
+	err = hinic_msg_to_mgmt(&pfhwdev->pf_to_mgmt, HINIC_MOD_CFGM,
+				HINIC_CFG_NIC_CAP, &dev_cap, in_len, &dev_cap,
+				&out_len, HINIC_MGMT_MSG_SYNC);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to get capability from FW\n");
+		return err;
+	}
+
+	return get_capability(hwdev, &dev_cap);
+}
+
+/**
+ * get_dev_cap - get device capabilities
+ * @hwdev: the NIC HW device to get capabilities for
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int get_dev_cap(struct hinic_hwdev *hwdev)
+{
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_pfhwdev *pfhwdev;
+	int err;
+
+	switch (HINIC_FUNC_TYPE(hwif)) {
+	case HINIC_PPF:
+	case HINIC_PF:
+		pfhwdev = container_of(hwdev, struct hinic_pfhwdev, hwdev);
+
+		err = get_cap_from_fw(pfhwdev);
+		if (err) {
+			dev_err(&pdev->dev, "Failed to get capability from FW\n");
+			return err;
+		}
+		break;
+
+	default:
+		dev_err(&pdev->dev, "Unsupported PCI Function type\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 /**
  * init_msix - enable the msix and save the entries
  * @hwdev: the NIC HW device
@@ -86,7 +207,17 @@ static void disable_msix(struct hinic_hwdev *hwdev)
  **/
 static int init_pfhwdev(struct hinic_pfhwdev *pfhwdev)
 {
-	/* Initialize PF HW device extended components */
+	struct hinic_hwdev *hwdev = &pfhwdev->hwdev;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int err;
+
+	err = hinic_pf_to_mgmt_init(&pfhwdev->pf_to_mgmt, hwif);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to initialize PF to MGMT channel\n");
+		return err;
+	}
+
 	return 0;
 }
 
@@ -96,6 +227,7 @@ static int init_pfhwdev(struct hinic_pfhwdev *pfhwdev)
  **/
 static void free_pfhwdev(struct hinic_pfhwdev *pfhwdev)
 {
+	hinic_pf_to_mgmt_free(&pfhwdev->pf_to_mgmt);
 }
 
 /**
@@ -111,7 +243,7 @@ struct hinic_hwdev *hinic_init_hwdev(struct pci_dev *pdev)
 	struct hinic_pfhwdev *pfhwdev;
 	struct hinic_hwdev *hwdev;
 	struct hinic_hwif *hwif;
-	int err;
+	int err, num_aeqs;
 
 	hwif = devm_kzalloc(&pdev->dev, sizeof(*hwif), GFP_KERNEL);
 	if (!hwif)
@@ -144,15 +276,37 @@ struct hinic_hwdev *hinic_init_hwdev(struct pci_dev *pdev)
 		goto err_init_msix;
 	}
 
+	num_aeqs = HINIC_HWIF_NUM_AEQS(hwif);
+
+	err = hinic_aeqs_init(&hwdev->aeqs, hwif, num_aeqs,
+			      HINIC_DEFAULT_AEQ_LEN, HINIC_EQ_PAGE_SIZE,
+			      hwdev->msix_entries);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to init async event queues\n");
+		goto err_aeqs_init;
+	}
+
 	err = init_pfhwdev(pfhwdev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to init PF HW device\n");
 		goto err_init_pfhwdev;
 	}
 
+	err = get_dev_cap(hwdev);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to get device capabilities\n");
+		goto err_dev_cap;
+	}
+
 	return hwdev;
 
+err_dev_cap:
+	free_pfhwdev(pfhwdev);
+
 err_init_pfhwdev:
+	hinic_aeqs_free(&hwdev->aeqs);
+
+err_aeqs_init:
 	disable_msix(hwdev);
 
 err_init_msix:
@@ -174,6 +328,8 @@ void hinic_free_hwdev(struct hinic_hwdev *hwdev)
 
 	free_pfhwdev(pfhwdev);
 
+	hinic_aeqs_free(&hwdev->aeqs);
+
 	disable_msix(hwdev);
 
 	hinic_free_hwif(hwdev->hwif);
@@ -187,15 +343,7 @@ void hinic_free_hwdev(struct hinic_hwdev *hwdev)
  **/
 int hinic_hwdev_num_qps(struct hinic_hwdev *hwdev)
 {
-	int num_aeqs, num_ceqs, nr_irqs, num_qps;
+	struct hinic_cap *nic_cap = &hwdev->nic_cap;
 
-	num_aeqs = HINIC_HWIF_NUM_AEQS(hwdev->hwif);
-	num_ceqs = HINIC_HWIF_NUM_CEQS(hwdev->hwif);
-	nr_irqs  = HINIC_HWIF_NUM_IRQS(hwdev->hwif);
-
-	/* Each QP has its own (SQ + RQ) interrupt */
-	num_qps = (nr_irqs - (num_aeqs + num_ceqs)) / 2;
-
-	/* num_qps must be power of 2 */
-	return BIT(fls(num_qps) - 1);
+	return nic_cap->num_qps;
 }
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
index b42e0eb..feb60138 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
@@ -17,20 +17,32 @@
 #define HINIC_HW_DEV_H
 
 #include <linux/pci.h>
+#include <linux/types.h>
 
 #include "hinic_hw_if.h"
+#include "hinic_hw_eqs.h"
+#include "hinic_hw_mgmt.h"
 
 #define HINIC_MAX_QPS   32
 
+struct hinic_cap {
+	u16     max_qps;
+	u16     num_qps;
+};
+
 struct hinic_hwdev {
 	struct hinic_hwif               *hwif;
 	struct msix_entry               *msix_entries;
+
+	struct hinic_aeqs               aeqs;
+
+	struct hinic_cap                nic_cap;
 };
 
 struct hinic_pfhwdev {
 	struct hinic_hwdev              hwdev;
 
-	/* PF Extended components should be here */
+	struct hinic_pf_to_mgmt         pf_to_mgmt;
 };
 
 struct hinic_hwdev *hinic_init_hwdev(struct pci_dev *pdev);
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
new file mode 100644
index 0000000..a099d20
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
@@ -0,0 +1,149 @@
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
+#include <linux/errno.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/workqueue.h>
+
+#include "hinic_hw_if.h"
+#include "hinic_hw_eqs.h"
+
+#define HINIC_EQS_WQ_NAME                       "hinic_eqs"
+
+/**
+ * hinic_aeq_register_hw_cb - register AEQ callback for specific event
+ * @aeqs: pointer to Async eqs of the chip
+ * @event: aeq event to register callback for it
+ * @handle: private data will be used by the callback
+ * @hw_handler: callback function
+ **/
+void hinic_aeq_register_hw_cb(struct hinic_aeqs *aeqs,
+			      enum hinic_aeq_type event, void *handle,
+			      void (*hwe_handler)(void *handle, void *data,
+						  u8 size))
+{
+	struct hinic_hw_event_cb *hwe_cb = &aeqs->hwe_cb[event];
+
+	hwe_cb->hwe_handler = hwe_handler;
+	hwe_cb->handle = handle;
+	hwe_cb->hwe_state = HINIC_EQE_ENABLED;
+}
+
+/**
+ * hinic_aeq_unregister_hw_cb - unregister the AEQ callback for specific event
+ * @aeqs: pointer to Async eqs of the chip
+ * @event: aeq event to unregister callback for it
+ **/
+void hinic_aeq_unregister_hw_cb(struct hinic_aeqs *aeqs,
+				enum hinic_aeq_type event)
+{
+	struct hinic_hw_event_cb *hwe_cb = &aeqs->hwe_cb[event];
+
+	hwe_cb->hwe_state &= ~HINIC_EQE_ENABLED;
+
+	while (hwe_cb->hwe_state & HINIC_EQE_RUNNING)
+		schedule();
+
+	hwe_cb->hwe_handler = NULL;
+}
+
+/**
+ * init_eq - initialize Event Queue
+ * @eq: the event queue
+ * @hwif: the HW interface of a PCI function device
+ * @type: the type of the event queue, aeq or ceq
+ * @q_id: Queue id number
+ * @q_len: the number of EQ elements
+ * @page_size: the page size of the pages in the event queue
+ * @entry: msix entry associated with the event queue
+ *
+ * Return 0 - Success, Negative - Failure
+ **/
+static int init_eq(struct hinic_eq *eq, struct hinic_hwif *hwif,
+		   enum hinic_eq_type type, int q_id, u32 q_len, u32 page_size,
+		   struct msix_entry entry)
+{
+	/* should be implemented */
+	return 0;
+}
+
+/**
+ * remove_eq - remove Event Queue
+ * @eq: the event queue
+ **/
+static void remove_eq(struct hinic_eq *eq)
+{
+	/* should be implemented */
+}
+
+/**
+ * hinic_aeqs_init - initialize all the aeqs
+ * @aeqs: pointer to Async eqs of the chip
+ * @hwif: the HW interface of a PCI function device
+ * @num_aeqs: number of AEQs
+ * @q_len: number of EQ elements
+ * @page_size: the page size of the pages in the event queue
+ * @msix_entries: msix entries associated with the event queues
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_aeqs_init(struct hinic_aeqs *aeqs, struct hinic_hwif *hwif,
+		    int num_aeqs, u32 q_len, u32 page_size,
+		    struct msix_entry *msix_entries)
+{
+	struct pci_dev *pdev = hwif->pdev;
+	int err, i, q_id;
+
+	aeqs->workq = create_singlethread_workqueue(HINIC_EQS_WQ_NAME);
+	if (!aeqs->workq)
+		return -ENOMEM;
+
+	aeqs->hwif = hwif;
+	aeqs->num_aeqs = num_aeqs;
+
+	for (q_id = 0; q_id < num_aeqs; q_id++) {
+		err = init_eq(&aeqs->aeq[q_id], hwif, HINIC_AEQ, q_id, q_len,
+			      page_size, msix_entries[q_id]);
+		if (err) {
+			dev_err(&pdev->dev, "Failed to init aeq %d\n", q_id);
+			goto err_init_aeq;
+		}
+	}
+
+	return 0;
+
+err_init_aeq:
+	for (i = 0; i < q_id; i++)
+		remove_eq(&aeqs->aeq[i]);
+
+	destroy_workqueue(aeqs->workq);
+	return err;
+}
+
+/**
+ * hinic_aeqs_free - free all the aeqs
+ * @aeqs: pointer to Async eqs of the chip
+ **/
+void hinic_aeqs_free(struct hinic_aeqs *aeqs)
+{
+	int q_id;
+
+	for (q_id = 0; q_id < aeqs->num_aeqs ; q_id++)
+		remove_eq(&aeqs->aeq[q_id]);
+
+	destroy_workqueue(aeqs->workq);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
new file mode 100644
index 0000000..1580127
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
@@ -0,0 +1,107 @@
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
+#ifndef HINIC_HW_EQS_H
+#define HINIC_HW_EQS_H
+
+#include <linux/types.h>
+#include <linux/workqueue.h>
+#include <linux/pci.h>
+#include <linux/sizes.h>
+#include <linux/bitops.h>
+
+#include "hinic_hw_if.h"
+
+#define HINIC_MAX_AEQS                  4
+
+#define HINIC_DEFAULT_AEQ_LEN           64
+
+#define HINIC_EQ_PAGE_SIZE              SZ_4K
+
+enum hinic_eq_type {
+	HINIC_AEQ,
+};
+
+enum hinic_aeq_type {
+	HINIC_MSG_FROM_MGMT_CPU = 2,
+
+	HINIC_MAX_AEQ_EVENTS,
+};
+
+enum hinic_eqe_state {
+	HINIC_EQE_ENABLED = BIT(0),
+	HINIC_EQE_RUNNING = BIT(1),
+};
+
+struct hinic_eq_work {
+	struct work_struct      work;
+	void                    *data;
+};
+
+struct hinic_eq {
+	struct hinic_hwif       *hwif;
+
+	enum hinic_eq_type      type;
+	int                     q_id;
+	u32                     q_len;
+	u32                     page_size;
+
+	u32                     cons_idx;
+	int                     wrapped;
+
+	size_t                  elem_size;
+	int                     num_pages;
+	int                     num_elem_in_pg;
+
+	struct msix_entry       msix_entry;
+
+	dma_addr_t              *dma_addr;
+	void                    **virt_addr;
+
+	struct hinic_eq_work    aeq_work;
+};
+
+struct hinic_hw_event_cb {
+	void    (*hwe_handler)(void *handle, void *data, u8 size);
+	void                    *handle;
+	unsigned long           hwe_state;
+};
+
+struct hinic_aeqs {
+	struct hinic_hwif       *hwif;
+
+	struct hinic_eq         aeq[HINIC_MAX_AEQS];
+	int                     num_aeqs;
+
+	struct hinic_hw_event_cb hwe_cb[HINIC_MAX_AEQ_EVENTS];
+
+	struct workqueue_struct *workq;
+};
+
+void hinic_aeq_register_hw_cb(struct hinic_aeqs *aeqs,
+			      enum hinic_aeq_type event, void *handle,
+			      void (*hwe_handler)(void *handle, void *data,
+						  u8 size));
+
+void hinic_aeq_unregister_hw_cb(struct hinic_aeqs *aeqs,
+				enum hinic_aeq_type event);
+
+int hinic_aeqs_init(struct hinic_aeqs *aeqs, struct hinic_hwif *hwif,
+		    int num_aeqs, u32 q_len, u32 page_size,
+		    struct msix_entry *msix_entries);
+
+void hinic_aeqs_free(struct hinic_aeqs *aeqs);
+
+#endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
index d1a8fa2..b6d9850 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
@@ -119,6 +119,14 @@ enum hinic_func_type {
 	HINIC_PPF       = 2,
 };
 
+enum hinic_mod_type {
+	HINIC_MOD_COMM  = 0,    /* HW communication module */
+	HINIC_MOD_L2NIC = 1,    /* L2NIC module */
+	HINIC_MOD_CFGM  = 7,    /* Configuration module */
+
+	HINIC_MOD_MAX   = 15
+};
+
 struct hinic_func_attr {
 	u16                     func_idx;
 	u8                      pf_idx;
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
new file mode 100644
index 0000000..8ae8ed9
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
@@ -0,0 +1,92 @@
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
+#include <linux/errno.h>
+
+#include "hinic_hw_if.h"
+#include "hinic_hw_eqs.h"
+#include "hinic_hw_mgmt.h"
+#include "hinic_hw_dev.h"
+
+#define mgmt_to_pfhwdev(pf_mgmt)        \
+		container_of(pf_mgmt, struct hinic_pfhwdev, pf_to_mgmt)
+
+/**
+ * hinic_msg_to_mgmt - send message to mgmt
+ * @pf_to_mgmt: PF to MGMT channel
+ * @mod: module in the chip that will get the message
+ * @cmd: command of the message
+ * @buf_in: the msg data
+ * @in_size: the msg data length
+ * @buf_out: response
+ * @out_size: returned response length
+ * @sync: sync msg or async msg
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_msg_to_mgmt(struct hinic_pf_to_mgmt *pf_to_mgmt,
+		      enum hinic_mod_type mod, u8 cmd,
+		      void *buf_in, u16 in_size, void *buf_out, u16 *out_size,
+		      enum hinic_mgmt_msg_type sync)
+{
+	/* should be implemented */
+	return -EINVAL;
+}
+
+/**
+ * mgmt_msg_aeqe_handler - handler for a mgmt message event
+ * @handle: PF to MGMT channel
+ * @data: the header of the message
+ * @size: unused
+ **/
+static void mgmt_msg_aeqe_handler(void *handle, void *data, u8 size)
+{
+	/* should be implemented */
+}
+
+/**
+ * hinic_pf_to_mgmt_init - initialize PF to MGMT channel
+ * @pf_to_mgmt: PF to MGMT channel
+ * @hwif: HW interface the PF to MGMT will use for accessing HW
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_pf_to_mgmt_init(struct hinic_pf_to_mgmt *pf_to_mgmt,
+			  struct hinic_hwif *hwif)
+{
+	struct hinic_pfhwdev *pfhwdev = mgmt_to_pfhwdev(pf_to_mgmt);
+	struct hinic_hwdev *hwdev = &pfhwdev->hwdev;
+
+	pf_to_mgmt->hwif = hwif;
+
+	hinic_aeq_register_hw_cb(&hwdev->aeqs, HINIC_MSG_FROM_MGMT_CPU,
+				 pf_to_mgmt,
+				 mgmt_msg_aeqe_handler);
+	return 0;
+}
+
+/**
+ * hinic_pf_to_mgmt_free - free PF to MGMT channel
+ * @pf_to_mgmt: PF to MGMT channel
+ **/
+void hinic_pf_to_mgmt_free(struct hinic_pf_to_mgmt *pf_to_mgmt)
+{
+	struct hinic_pfhwdev *pfhwdev = mgmt_to_pfhwdev(pf_to_mgmt);
+	struct hinic_hwdev *hwdev = &pfhwdev->hwdev;
+
+	hinic_aeq_unregister_hw_cb(&hwdev->aeqs, HINIC_MSG_FROM_MGMT_CPU);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
new file mode 100644
index 0000000..b4b34b7
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
@@ -0,0 +1,45 @@
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
+#ifndef HINIC_HW_MGMT_H
+#define HINIC_HW_MGMT_H
+
+#include <linux/types.h>
+
+#include "hinic_hw_if.h"
+
+enum hinic_mgmt_msg_type {
+	HINIC_MGMT_MSG_SYNC = 1,
+};
+
+enum hinic_cfg_cmd {
+	HINIC_CFG_NIC_CAP = 0,
+};
+
+struct hinic_pf_to_mgmt {
+	struct hinic_hwif               *hwif;
+};
+
+int hinic_msg_to_mgmt(struct hinic_pf_to_mgmt *pf_to_mgmt,
+		      enum hinic_mod_type mod, u8 cmd,
+		      void *buf_in, u16 in_size, void *buf_out, u16 *out_size,
+		      enum hinic_mgmt_msg_type sync);
+
+int hinic_pf_to_mgmt_init(struct hinic_pf_to_mgmt *pf_to_mgmt,
+			  struct hinic_hwif *hwif);
+
+void hinic_pf_to_mgmt_free(struct hinic_pf_to_mgmt *pf_to_mgmt);
+
+#endif
-- 
1.9.1
