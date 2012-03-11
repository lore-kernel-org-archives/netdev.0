From: <parav.pandit@emulex.com>
Subject: [RFC V1 2/2] be2net: Added functionality to support RoCE driver
Date: Sun, 11 Mar 2012 16:19:30 +0530
Message-ID: <8cd729bc-a494-4b12-a9b2-1fdfdce0fe9c@exht1.ad.emulex.com>
References: <1331462970-18690-1-git-send-email-parav.pandit@emulex.com>
 <1331462970-18690-2-git-send-email-parav.pandit@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parav.pandit@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:34479 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751186Ab2CKGkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 01:40:22 -0500
In-Reply-To: <1331462970-18690-2-git-send-email-parav.pandit@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parav Pandit <parav.pandit@emulex.com>

- Increased MSIX vectors by 5 for RoCE traffic.
- Added macro to check roce support on a device.
- Added device specific doorbell, msix vector fields shared with nic functionality.
- Provides RoCE driver registration and deregistration functions.
- Added support functions which will be invoked on adapter
  add/remove and port up/down events.
- Traverses through the list of adapters for invoking callback functions.

Signed-off-by: Parav Pandit <parav.pandit@emulex.com>
---
 drivers/net/ethernet/emulex/benet/Makefile  |    2 +-
 drivers/net/ethernet/emulex/benet/be.h      |   38 ++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h |    1 +
 drivers/net/ethernet/emulex/benet/be_hw.h   |    4 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   83 ++++++++++--
 drivers/net/ethernet/emulex/benet/be_roce.c |  183 +++++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_roce.h |   75 +++++++++++
 7 files changed, 370 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/ethernet/emulex/benet/be_roce.c
 create mode 100644 drivers/net/ethernet/emulex/benet/be_roce.h

diff --git a/drivers/net/ethernet/emulex/benet/Makefile b/drivers/net/ethernet/emulex/benet/Makefile
index a60cd80..1a91b27 100644
--- a/drivers/net/ethernet/emulex/benet/Makefile
+++ b/drivers/net/ethernet/emulex/benet/Makefile
@@ -4,4 +4,4 @@
 
 obj-$(CONFIG_BE2NET) += be2net.o
 
-be2net-y :=  be_main.o be_cmds.o be_ethtool.o
+be2net-y :=  be_main.o be_cmds.o be_ethtool.o be_roce.o
diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index cbdec25..fc094d9 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -32,6 +32,7 @@
 #include <linux/u64_stats_sync.h>
 
 #include "be_hw.h"
+#include "be_roce.h"
 
 #define DRV_VER			"4.0.100u"
 #define DRV_NAME		"be2net"
@@ -92,7 +93,7 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define MAX_RSS_QS		4	/* BE limit is 4 queues/port */
 #define MAX_RX_QS		(MAX_RSS_QS + 1) /* RSS qs + 1 def Rx */
 #define MAX_TX_QS		8
-#define BE_MAX_MSIX_VECTORS	(MAX_RX_QS + 1)/* RX + TX */
+#define BE_MAX_MSIX_VECTORS	(MAX_RX_QS + 1 + 5)/* RX + TX  + 5 RoCE */
 #define BE_NAPI_WEIGHT		64
 #define MAX_RX_POST 		BE_NAPI_WEIGHT /* Frags posted at a time */
 #define RX_FRAGS_REFILL_WM	(RX_Q_LEN - MAX_RX_POST)
@@ -320,6 +321,7 @@ struct be_adapter {
 
 	struct msix_entry msix_entries[BE_MAX_MSIX_VECTORS];
 	u32 num_msix_vec;
+	u32 num_eqs;
 	bool isr_registered;
 
 	/* TX Rings */
@@ -372,6 +374,16 @@ struct be_adapter {
 	u8 transceiver;
 	u8 autoneg;
 	u8 generation;		/* BladeEngine ASIC generation */
+	u32 if_type;
+	struct {
+		u8 __iomem *base;	/* Door Bell */
+		u32 size;
+		u32 total_size;
+		u64 io_addr;
+	} roce_db;
+	struct ocrdma_dev *ocrdma_dev;
+	struct list_head entry;
+
 	u32 flash_status;
 	struct completion flash_compl;
 
@@ -399,6 +411,10 @@ struct be_adapter {
 #define lancer_chip(adapter)	((adapter->pdev->device == OC_DEVICE_ID3) || \
 				 (adapter->pdev->device == OC_DEVICE_ID4))
 
+#define be_roce_supported(adapter) ((adapter->if_type == SLI_INTF_TYPE_3 || \
+				adapter->sli_family == SKYHAWK_SLI_FAMILY) && \
+				(adapter->function_mode & RDMA_ENABLED))
+
 extern const struct ethtool_ops be_ethtool_ops;
 
 #define msix_enabled(adapter)		(adapter->num_msix_vec > 0)
@@ -539,9 +555,29 @@ static inline bool be_error(struct be_adapter *adapter)
 	return adapter->eeh_err || adapter->ue_detected || adapter->fw_timeout;
 }
 
+
+static inline bool be_type_2_3(struct be_adapter *adapter)
+{
+	return (adapter->if_type == SLI_INTF_TYPE_2 ||
+		adapter->if_type == SLI_INTF_TYPE_3) ? true : false;
+}
+
 extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
 extern void be_link_status_update(struct be_adapter *adapter, u8 link_status);
 extern void be_parse_stats(struct be_adapter *adapter);
 extern int be_load_fw(struct be_adapter *adapter, u8 *func);
+
+/*
+ * internal function to initialize-cleanup roce device.
+ */
+extern void be_roce_dev_add(struct be_adapter *);
+extern void be_roce_dev_remove(struct be_adapter *);
+
+/*
+ * internal function to open-close roce device during ifup-ifdown.
+ */
+extern void be_roce_dev_open(struct be_adapter *);
+extern void be_roce_dev_close(struct be_adapter *);
+
 #endif				/* BE_H */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index dca8924..d7ad03b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1057,6 +1057,7 @@ struct be_cmd_resp_modify_eq_delay {
 #define FLEX10_MODE				0x400
 #define VNIC_MODE				0x20000
 #define UMC_ENABLED				0x1000000
+#define RDMA_ENABLED				0x4
 struct be_cmd_req_query_fw_cfg {
 	struct be_cmd_req_hdr hdr;
 	u32 rsvd[31];
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index f2c89e3..0aa6509 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -98,11 +98,13 @@
 #define SLI_INTF_REV_SHIFT			4
 #define SLI_INTF_FT_MASK			0x00000001
 
+#define SLI_INTF_TYPE_2		2
+#define SLI_INTF_TYPE_3		3
 
 /* SLI family */
 #define BE_SLI_FAMILY		0x0
 #define LANCER_A0_SLI_FAMILY	0xA
-
+#define SKYHAWK_SLI_FAMILY	0x2
 
 /********* ISR0 Register offset **********/
 #define CEV_ISR0_OFFSET 			0xC18
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index e703d64..043fbe3 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1697,8 +1697,10 @@ static void be_tx_queues_destroy(struct be_adapter *adapter)
 	be_eq_clean(adapter, &adapter->tx_eq);
 
 	q = &adapter->tx_eq.q;
-	if (q->created)
+	if (q->created) {
 		be_cmd_q_destroy(adapter, q, QTYPE_EQ);
+		adapter->num_eqs -= 1;
+	}
 	be_queue_free(adapter, q);
 }
 
@@ -1740,6 +1742,7 @@ static int be_tx_queues_create(struct be_adapter *adapter)
 	if (be_cmd_eq_create(adapter, eq, adapter->tx_eq.cur_eqd))
 		goto err;
 	adapter->tx_eq.eq_idx = adapter->eq_next_idx++;
+	adapter->num_eqs += 1;
 
 	for_all_tx_queues(adapter, txo, i) {
 		cq = &txo->cq;
@@ -1777,8 +1780,10 @@ static void be_rx_queues_destroy(struct be_adapter *adapter)
 		be_queue_free(adapter, q);
 
 		q = &rxo->rx_eq.q;
-		if (q->created)
+		if (q->created) {
 			be_cmd_q_destroy(adapter, q, QTYPE_EQ);
+			adapter->num_eqs -= 1;
+		}
 		be_queue_free(adapter, q);
 	}
 }
@@ -1824,6 +1829,7 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 		rc = be_cmd_eq_create(adapter, eq, rxo->rx_eq.cur_eqd);
 		if (rc)
 			goto err;
+		adapter->num_eqs += 1;
 
 		rxo->rx_eq.eq_idx = adapter->eq_next_idx++;
 
@@ -2120,6 +2126,12 @@ static void be_msix_enable(struct be_adapter *adapter)
 
 	num_vec = be_num_rxqs_want(adapter) + 1;
 
+	if (be_roce_supported(adapter)) {
+		num_vec += min_t(u32, MAX_ROCE_MSIX_VECTORS,
+					(num_online_cpus() + 1));
+	}
+	num_vec = min(num_vec, BE_MAX_MSIX_VECTORS);
+
 	for (i = 0; i < num_vec; i++)
 		adapter->msix_entries[i].entry = i;
 
@@ -2330,6 +2342,8 @@ static int be_close(struct net_device *netdev)
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
 	int vec, i;
 
+	be_roce_dev_close(adapter);
+
 	be_async_mcc_disable(adapter);
 
 	if (!lancer_chip(adapter))
@@ -2442,6 +2456,8 @@ static int be_open(struct net_device *netdev)
 	if (!status)
 		be_link_status_update(adapter, link_status);
 
+	be_roce_dev_open(adapter);
+
 	return 0;
 err:
 	be_close(adapter->netdev);
@@ -3139,19 +3155,44 @@ static void be_unmap_pci_bars(struct be_adapter *adapter)
 		iounmap(adapter->csr);
 	if (adapter->db)
 		iounmap(adapter->db);
+	if (adapter->roce_db.base)
+		pci_iounmap(adapter->pdev, adapter->roce_db.base);
+}
+
+static int lancer_roce_map_pci_bars(struct be_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	u8 __iomem *addr;
+
+	addr = pci_iomap(pdev, 2, 0);
+	if (addr == NULL)
+		return -ENOMEM;
+
+	adapter->roce_db.base = addr;
+	adapter->roce_db.io_addr = pci_resource_start(pdev, 2);
+	adapter->roce_db.size = 8192;
+	adapter->roce_db.total_size = pci_resource_len(pdev, 2);
+	return 0;
 }
 
 static int be_map_pci_bars(struct be_adapter *adapter)
 {
+	struct pci_dev *pdev = adapter->pdev;
 	u8 __iomem *addr;
 	int db_reg;
 
 	if (lancer_chip(adapter)) {
-		addr = ioremap_nocache(pci_resource_start(adapter->pdev, 0),
-			pci_resource_len(adapter->pdev, 0));
-		if (addr == NULL)
-			return -ENOMEM;
-		adapter->db = addr;
+		if (be_type_2_3(adapter)) {
+			addr = ioremap_nocache(pci_resource_start(pdev, 0),
+			    pci_resource_len(adapter->pdev, 0));
+			if (addr == NULL)
+				return -ENOMEM;
+			adapter->db = addr;
+		}
+		if (adapter->if_type == SLI_INTF_TYPE_3) {
+			if (lancer_roce_map_pci_bars(adapter))
+				goto pci_map_err;
+		}
 		return 0;
 	}
 
@@ -3176,7 +3217,11 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 	if (addr == NULL)
 		goto pci_map_err;
 	adapter->db = addr;
-
+	if (adapter->sli_family == SKYHAWK_SLI_FAMILY) {
+		adapter->roce_db.size = 4096;
+		adapter->roce_db.io_addr = pci_resource_start(pdev, db_reg);
+		adapter->roce_db.total_size = pci_resource_len(pdev, db_reg);
+	}
 	return 0;
 pci_map_err:
 	be_unmap_pci_bars(adapter);
@@ -3289,6 +3334,8 @@ static void __devexit be_remove(struct pci_dev *pdev)
 	if (!adapter)
 		return;
 
+	be_roce_dev_remove(adapter);
+
 	cancel_delayed_work_sync(&adapter->work);
 
 	unregister_netdev(adapter->netdev);
@@ -3334,7 +3381,7 @@ static int be_get_config(struct be_adapter *adapter)
 static int be_dev_family_check(struct be_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
-	u32 sli_intf = 0, if_type;
+	u32 sli_intf = 0;
 
 	switch (pdev->device) {
 	case BE_DEVICE_ID1:
@@ -3343,17 +3390,25 @@ static int be_dev_family_check(struct be_adapter *adapter)
 		break;
 	case BE_DEVICE_ID2:
 	case OC_DEVICE_ID2:
-	case OC_DEVICE_ID5:
 		adapter->generation = BE_GEN3;
 		break;
 	case OC_DEVICE_ID3:
 	case OC_DEVICE_ID4:
 		pci_read_config_dword(pdev, SLI_INTF_REG_OFFSET, &sli_intf);
-		if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
+		adapter->if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
 						SLI_INTF_IF_TYPE_SHIFT;
-
 		if (((sli_intf & SLI_INTF_VALID_MASK) != SLI_INTF_VALID) ||
-			if_type != 0x02) {
+			!be_type_2_3(adapter)) {
+			dev_err(&pdev->dev, "SLI_INTF reg val is not valid\n");
+			return -EINVAL;
+		}
+		adapter->sli_family = ((sli_intf & SLI_INTF_FAMILY_MASK) >>
+							SLI_INTF_FAMILY_SHIFT);
+		adapter->generation = BE_GEN3;
+		break;
+	case OC_DEVICE_ID5:
+		pci_read_config_dword(pdev, SLI_INTF_REG_OFFSET, &sli_intf);
+		if ((sli_intf & SLI_INTF_VALID_MASK) != SLI_INTF_VALID) {
 			dev_err(&pdev->dev, "SLI_INTF reg val is not valid\n");
 			return -EINVAL;
 		}
@@ -3621,6 +3676,8 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status != 0)
 		goto unsetup;
 
+	be_roce_dev_add(adapter);
+
 	dev_info(&pdev->dev, "%s port %d\n", nic_name(pdev), adapter->port_num);
 
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
diff --git a/drivers/net/ethernet/emulex/benet/be_roce.c b/drivers/net/ethernet/emulex/benet/be_roce.c
new file mode 100644
index 0000000..0b3e0b7
--- /dev/null
+++ b/drivers/net/ethernet/emulex/benet/be_roce.c
@@ -0,0 +1,183 @@
+/*
+ * Copyright (C) 2005 - 2011 Emulex
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation. The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@emulex.com
+ *
+ * Emulex
+ * 3333 Susan Street
+ * Costa Mesa, CA 92626
+ */
+
+#include <linux/mutex.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/module.h>
+
+#include "be.h"
+#include "be_cmds.h"
+
+static struct ocrdma_driver *ocrdma_drv;
+static LIST_HEAD(be_adapter_list);
+static DEFINE_MUTEX(be_adapter_list_lock);
+
+static void _be_roce_dev_add(struct be_adapter *adapter)
+{
+	struct be_dev_info dev_info;
+	int i, roce_vect_cnt;
+	struct pci_dev *pdev = adapter->pdev;
+
+	if (!ocrdma_drv)
+		return;
+	if (pdev->device == OC_DEVICE_ID5) {
+		/* only msix is supported on these devices */
+		if (!msix_enabled(adapter))
+			return;
+		/* DPP region address and length */
+		dev_info.dpp_unmapped_addr = pci_resource_start(pdev, 2);
+		dev_info.dpp_unmapped_len = pci_resource_len(pdev, 2);
+	} else {
+		dev_info.dpp_unmapped_addr = 0;
+		dev_info.dpp_unmapped_len = 0;
+	}
+	dev_info.pdev = adapter->pdev;
+	if (adapter->sli_family == SKYHAWK_SLI_FAMILY)
+		dev_info.db = adapter->db;
+	else
+		dev_info.db = adapter->roce_db.base;
+	dev_info.unmapped_db = adapter->roce_db.io_addr;
+	dev_info.db_page_size = adapter->roce_db.size;
+	dev_info.db_total_size = adapter->roce_db.total_size;
+	dev_info.netdev = adapter->netdev;
+	memcpy(dev_info.mac_addr, adapter->netdev->dev_addr, ETH_ALEN);
+	dev_info.dev_family = adapter->sli_family;
+	if (msix_enabled(adapter)) {
+		/* provide all the vectors, so that EQ creation response
+		 * can decide which one to use.
+		 */
+		roce_vect_cnt = adapter->num_msix_vec;
+		dev_info.intr_mode = BE_INTERRUPT_MODE_MSIX;
+		dev_info.msix.num_vectors =
+		    min(roce_vect_cnt, MAX_ROCE_MSIX_VECTORS);
+		/* provide start index of the vector,
+		 * so in case of linear usage,
+		 * it can use the base as starting point.
+		 */
+		dev_info.msix.start_vector = adapter->num_eqs;
+		for (i = 0; i < dev_info.msix.num_vectors; i++) {
+			dev_info.msix.vector_list[i] =
+			    adapter->msix_entries[i].vector;
+		}
+	} else {
+		dev_info.msix.num_vectors = 0;
+		dev_info.intr_mode = BE_INTERRUPT_MODE_INTX;
+	}
+	adapter->ocrdma_dev = ocrdma_drv->add(&dev_info);
+}
+
+void be_roce_dev_add(struct be_adapter *adapter)
+{
+	if (be_roce_supported(adapter)) {
+		INIT_LIST_HEAD(&adapter->entry);
+		mutex_lock(&be_adapter_list_lock);
+		list_add_tail(&adapter->entry, &be_adapter_list);
+
+		/* invoke add() routine of roce driver only if
+		 * valid driver registered with add method and add() is not yet
+		 * invoked on a given adapter.
+		 */
+		_be_roce_dev_add(adapter);
+		mutex_unlock(&be_adapter_list_lock);
+	}
+}
+
+void _be_roce_dev_remove(struct be_adapter *adapter)
+{
+	if (ocrdma_drv && ocrdma_drv->remove && adapter->ocrdma_dev)
+		ocrdma_drv->remove(adapter->ocrdma_dev);
+	adapter->ocrdma_dev = NULL;
+}
+
+void be_roce_dev_remove(struct be_adapter *adapter)
+{
+	if (be_roce_supported(adapter)) {
+		mutex_lock(&be_adapter_list_lock);
+		_be_roce_dev_remove(adapter);
+		list_del(&adapter->entry);
+		mutex_unlock(&be_adapter_list_lock);
+	}
+}
+
+void _be_roce_dev_open(struct be_adapter *adapter)
+{
+	if (ocrdma_drv && adapter->ocrdma_dev &&
+	    ocrdma_drv->state_change_handler)
+		ocrdma_drv->state_change_handler(adapter->ocrdma_dev, 0);
+}
+
+void be_roce_dev_open(struct be_adapter *adapter)
+{
+	if (be_roce_supported(adapter)) {
+		mutex_lock(&be_adapter_list_lock);
+		_be_roce_dev_open(adapter);
+		mutex_unlock(&be_adapter_list_lock);
+	}
+}
+
+void _be_roce_dev_close(struct be_adapter *adapter)
+{
+	if (ocrdma_drv && adapter->ocrdma_dev &&
+	    ocrdma_drv->state_change_handler)
+		ocrdma_drv->state_change_handler(adapter->ocrdma_dev, 1);
+}
+
+void be_roce_dev_close(struct be_adapter *adapter)
+{
+	if (be_roce_supported(adapter)) {
+		mutex_lock(&be_adapter_list_lock);
+		_be_roce_dev_close(adapter);
+		mutex_unlock(&be_adapter_list_lock);
+	}
+}
+
+int be_roce_register_driver(struct ocrdma_driver *drv)
+{
+	struct be_adapter *dev;
+
+	mutex_lock(&be_adapter_list_lock);
+	if (ocrdma_drv) {
+		mutex_unlock(&be_adapter_list_lock);
+		return -EINVAL;
+	}
+	ocrdma_drv = drv;
+	list_for_each_entry(dev, &be_adapter_list, entry) {
+		struct net_device *netdev;
+		_be_roce_dev_add(dev);
+		netdev = dev->netdev;
+		if (netif_running(netdev) && netif_oper_up(netdev))
+			_be_roce_dev_open(dev);
+	}
+	mutex_unlock(&be_adapter_list_lock);
+	return 0;
+}
+EXPORT_SYMBOL(be_roce_register_driver);
+
+void be_roce_unregister_driver(struct ocrdma_driver *drv)
+{
+	struct be_adapter *dev;
+
+	mutex_lock(&be_adapter_list_lock);
+	list_for_each_entry(dev, &be_adapter_list, entry) {
+		if (dev->ocrdma_dev)
+			_be_roce_dev_remove(dev);
+	}
+	ocrdma_drv = NULL;
+	mutex_unlock(&be_adapter_list_lock);
+}
+EXPORT_SYMBOL(be_roce_unregister_driver);
diff --git a/drivers/net/ethernet/emulex/benet/be_roce.h b/drivers/net/ethernet/emulex/benet/be_roce.h
new file mode 100644
index 0000000..db4ea80
--- /dev/null
+++ b/drivers/net/ethernet/emulex/benet/be_roce.h
@@ -0,0 +1,75 @@
+/*
+ * Copyright (C) 2005 - 2011 Emulex
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation. The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@emulex.com
+ *
+ * Emulex
+ * 3333 Susan Street
+ * Costa Mesa, CA 92626
+ */
+
+#ifndef BE_ROCE_H
+#define BE_ROCE_H
+
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+struct ocrdma_dev;
+
+enum be_interrupt_mode {
+	BE_INTERRUPT_MODE_MSIX	= 0,
+	BE_INTERRUPT_MODE_INTX	= 1,
+	BE_INTERRUPT_MODE_MSI	= 2,
+};
+
+#define MAX_ROCE_MSIX_VECTORS   16
+struct be_dev_info {
+	u8 __iomem *db;
+	u64 unmapped_db;
+	u32 db_page_size;
+	u32 db_total_size;
+	u64 dpp_unmapped_addr;
+	u32 dpp_unmapped_len;
+	struct pci_dev *pdev;
+	struct net_device *netdev;
+	u8 mac_addr[ETH_ALEN];
+	u32 dev_family;
+	enum be_interrupt_mode intr_mode;
+	struct {
+		int num_vectors;
+		int start_vector;
+		u32 vector_list[MAX_ROCE_MSIX_VECTORS];
+	} msix;
+};
+
+/* ocrdma driver register's the callback functions with nic driver. */
+struct ocrdma_driver {
+	unsigned char name[32];
+	struct ocrdma_dev *(*add) (struct be_dev_info *dev_info);
+	void (*remove) (struct ocrdma_dev *);
+	void (*state_change_handler) (struct ocrdma_dev *, u32 new_state);
+};
+
+enum {
+	BE_DEV_UP	= 0,
+	BE_DEV_DOWN	= 1
+};
+
+/* APIs for RoCE driver to register callback handlers,
+ * which will be invoked when device is added, removed, ifup, ifdown
+ */
+int be_roce_register_driver(struct ocrdma_driver *drv);
+void be_roce_unregister_driver(struct ocrdma_driver *drv);
+
+/* API for RoCE driver to issue mailbox commands */
+int be_roce_mcc_cmd(void *netdev_handle, void *wrb_payload,
+		    int wrb_payload_size, u16 *cmd_status, u16 *ext_status);
+
+#endif /* BE_ROCE_H */
-- 
1.6.0.2
