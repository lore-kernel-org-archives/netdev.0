From: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [RFC v2 02/12] qedr: Add RoCE driver framework
Date: Tue, 20 Sep 2016 13:35:54 +0300
Message-ID: <1474367764-9555-3-git-send-email-Ram.Amrani@cavium.com>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Ram amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1474367764-9555-1-git-send-email-Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ram amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Adds a skeletal implementation of the qed* RoCE driver -
basically the ability to communicate with the qede driver and
receive notifications from it regarding various init/exit events.

Signed-off-by: Rajesh Borundia <rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/Kconfig                   |   2 +
 drivers/infiniband/hw/Makefile               |   1 +
 drivers/infiniband/hw/qedr/Kconfig           |   7 +
 drivers/infiniband/hw/qedr/Makefile          |   3 +
 drivers/infiniband/hw/qedr/main.c            | 276 ++++++++++++++++++++++++
 drivers/infiniband/hw/qedr/qedr.h            |  59 +++++
 drivers/net/ethernet/qlogic/qede/Makefile    |   1 +
 drivers/net/ethernet/qlogic/qede/qede.h      |   9 +
 drivers/net/ethernet/qlogic/qede/qede_main.c |  35 ++-
 drivers/net/ethernet/qlogic/qede/qede_roce.c | 309 +++++++++++++++++++++++++++
 include/linux/qed/qed_if.h                   |   3 +-
 include/linux/qed/qede_roce.h                |  88 ++++++++
 include/uapi/linux/pci_regs.h                |   3 +
 13 files changed, 785 insertions(+), 11 deletions(-)
 create mode 100644 drivers/infiniband/hw/qedr/Kconfig
 create mode 100644 drivers/infiniband/hw/qedr/Makefile
 create mode 100644 drivers/infiniband/hw/qedr/main.c
 create mode 100644 drivers/infiniband/hw/qedr/qedr.h
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_roce.c
 create mode 100644 include/linux/qed/qede_roce.h

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index e9b7dc0..77ab0f3 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -88,4 +88,6 @@ source "drivers/infiniband/sw/rxe/Kconfig"
 
 source "drivers/infiniband/hw/hfi1/Kconfig"
 
+source "drivers/infiniband/hw/qedr/Kconfig"
+
 endif # INFINIBAND
diff --git a/drivers/infiniband/hw/Makefile b/drivers/infiniband/hw/Makefile
index c0c7cf8..c51e464 100644
--- a/drivers/infiniband/hw/Makefile
+++ b/drivers/infiniband/hw/Makefile
@@ -9,3 +9,4 @@ obj-$(CONFIG_INFINIBAND_NES)		+= nes/
 obj-$(CONFIG_INFINIBAND_OCRDMA)		+= ocrdma/
 obj-$(CONFIG_INFINIBAND_USNIC)		+= usnic/
 obj-$(CONFIG_INFINIBAND_HFI1)		+= hfi1/
+obj-$(CONFIG_INFINIBAND_QEDR)		+= qedr/
diff --git a/drivers/infiniband/hw/qedr/Kconfig b/drivers/infiniband/hw/qedr/Kconfig
new file mode 100644
index 0000000..58b584f
--- /dev/null
+++ b/drivers/infiniband/hw/qedr/Kconfig
@@ -0,0 +1,7 @@
+config INFINIBAND_QEDR
+	tristate "QLogic RoCE driver"
+	depends on NETDEVICES && ETHERNET && PCI && 64BIT && QEDE
+	select QED_LL2
+	---help---
+	  This driver provides low-level InfiniBand over Ethernet
+	  support for QLogic QED host channel adapters (HCAs).
diff --git a/drivers/infiniband/hw/qedr/Makefile b/drivers/infiniband/hw/qedr/Makefile
new file mode 100644
index 0000000..3a5b7a2
--- /dev/null
+++ b/drivers/infiniband/hw/qedr/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_INFINIBAND_QEDR) := qedr.o
+
+qedr-y := main.o
diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
new file mode 100644
index 0000000..f60dc80
--- /dev/null
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -0,0 +1,276 @@
+/* QLogic qedr NIC Driver
+ * Copyright (c) 2015-2016  QLogic Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and /or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include <linux/module.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_addr.h>
+#include <linux/netdevice.h>
+#include <linux/iommu.h>
+#include <net/addrconf.h>
+#include <linux/qed/qede_roce.h>
+#include "qedr.h"
+
+MODULE_DESCRIPTION("QLogic 40G/100G ROCE Driver");
+MODULE_AUTHOR("QLogic Corporation");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(QEDR_MODULE_VERSION);
+
+uint debug;
+module_param(debug, uint, 0);
+MODULE_PARM_DESC(debug, "Default debug msglevel");
+
+static LIST_HEAD(qedr_dev_list);
+
+void qedr_ib_dispatch_event(struct qedr_dev *dev, u8 port_num,
+			    enum ib_event_type type)
+{
+	struct ib_event ibev;
+
+	ibev.device = &dev->ibdev;
+	ibev.element.port_num = port_num;
+	ibev.event = type;
+
+	ib_dispatch_event(&ibev);
+}
+
+static enum rdma_link_layer qedr_link_layer(struct ib_device *device,
+					    u8 port_num)
+{
+	return IB_LINK_LAYER_ETHERNET;
+}
+
+static int qedr_register_device(struct qedr_dev *dev)
+{
+	strlcpy(dev->ibdev.name, "qedr%d", IB_DEVICE_NAME_MAX);
+
+	memcpy(dev->ibdev.node_desc, QEDR_NODE_DESC, sizeof(QEDR_NODE_DESC));
+	dev->ibdev.owner = THIS_MODULE;
+
+	dev->ibdev.get_link_layer = qedr_link_layer;
+
+	return 0;
+}
+
+/* QEDR sysfs interface */
+static ssize_t show_rev(struct device *device, struct device_attribute *attr,
+			char *buf)
+{
+	struct qedr_dev *dev = dev_get_drvdata(device);
+
+	return scnprintf(buf, PAGE_SIZE, "0x%x\n", dev->pdev->vendor);
+}
+
+static ssize_t show_hca_type(struct device *device,
+			     struct device_attribute *attr, char *buf)
+{
+	return scnprintf(buf, PAGE_SIZE, "%s\n", "HCA_TYPE_TO_SET");
+}
+
+static DEVICE_ATTR(hw_rev, S_IRUGO, show_rev, NULL);
+static DEVICE_ATTR(hca_type, S_IRUGO, show_hca_type, NULL);
+
+static struct device_attribute *qedr_attributes[] = {
+	&dev_attr_hw_rev,
+	&dev_attr_hca_type
+};
+
+static void qedr_remove_sysfiles(struct qedr_dev *dev)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(qedr_attributes); i++)
+		device_remove_file(&dev->ibdev.dev, qedr_attributes[i]);
+}
+
+void qedr_config_debug(uint debug, u32 *p_dp_module, u8 *p_dp_level)
+{
+	*p_dp_level = 0;
+	*p_dp_module = 0;
+
+	if (debug & QED_LOG_VERBOSE_MASK) {
+		*p_dp_level = QED_LEVEL_VERBOSE;
+		*p_dp_module = (debug & 0x3FFFFFFF);
+	} else if (debug & QED_LOG_INFO_MASK) {
+		*p_dp_level = QED_LEVEL_INFO;
+	} else if (debug & QED_LOG_NOTICE_MASK) {
+		*p_dp_level = QED_LEVEL_NOTICE;
+	}
+}
+
+static void qedr_pci_set_atomic(struct qedr_dev *dev, struct pci_dev *pdev)
+{
+	struct pci_dev *bridge;
+	u32 val;
+
+	dev->atomic_cap = IB_ATOMIC_NONE;
+
+	bridge = pdev->bus->self;
+	if (!bridge)
+		return;
+
+	/* Check whether we are connected directly or via a switch */
+	while (bridge && bridge->bus->parent) {
+		DP_NOTICE(dev,
+			  "Device is not connected directly to root. bridge->bus->number=%d primary=%d\n",
+			  bridge->bus->number, bridge->bus->primary);
+		/* Need to check Atomic Op Routing Supported all the way to
+		 * root complex.
+		 */
+		pcie_capability_read_dword(bridge, PCI_EXP_DEVCAP2, &val);
+		if (!(val & PCI_EXP_DEVCAP2_ATOMIC_ROUTE)) {
+			pcie_capability_clear_word(pdev,
+						   PCI_EXP_DEVCTL2,
+						   PCI_EXP_DEVCTL2_ATOMIC_REQ);
+			return;
+		}
+		bridge = bridge->bus->parent->self;
+	}
+	bridge = pdev->bus->self;
+
+	/* according to bridge capability */
+	pcie_capability_read_dword(bridge, PCI_EXP_DEVCAP2, &val);
+	if (val & PCI_EXP_DEVCAP2_ATOMIC_COMP64) {
+		pcie_capability_set_word(pdev, PCI_EXP_DEVCTL2,
+					 PCI_EXP_DEVCTL2_ATOMIC_REQ);
+		dev->atomic_cap = IB_ATOMIC_GLOB;
+	} else {
+		pcie_capability_clear_word(pdev, PCI_EXP_DEVCTL2,
+					   PCI_EXP_DEVCTL2_ATOMIC_REQ);
+	}
+}
+
+static struct qedr_dev *qedr_add(struct qed_dev *cdev, struct pci_dev *pdev,
+				 struct net_device *ndev)
+{
+	struct qedr_dev *dev;
+	int rc = 0, i;
+
+	dev = (struct qedr_dev *)ib_alloc_device(sizeof(*dev));
+	if (!dev) {
+		pr_err("Unable to allocate ib device\n");
+		return NULL;
+	}
+
+	qedr_config_debug(debug, &dev->dp_module, &dev->dp_level);
+	DP_VERBOSE(dev, QEDR_MSG_INIT, "qedr add device called\n");
+
+	dev->pdev = pdev;
+	dev->ndev = ndev;
+	dev->cdev = cdev;
+
+	qedr_pci_set_atomic(dev, pdev);
+
+	rc = qedr_register_device(dev);
+	if (rc) {
+		DP_ERR(dev, "Unable to allocate register device\n");
+		goto init_err;
+	}
+
+	for (i = 0; i < ARRAY_SIZE(qedr_attributes); i++)
+		if (device_create_file(&dev->ibdev.dev, qedr_attributes[i]))
+			goto init_err;
+
+	DP_VERBOSE(dev, QEDR_MSG_INIT, "qedr driver loaded successfully\n");
+	return dev;
+
+init_err:
+	ib_dealloc_device(&dev->ibdev);
+	DP_ERR(dev, "qedr driver load failed rc=%d\n", rc);
+
+	return NULL;
+}
+
+static void qedr_remove(struct qedr_dev *dev)
+{
+	/* First unregister with stack to stop all the active traffic
+	 * of the registered clients.
+	 */
+	qedr_remove_sysfiles(dev);
+
+	ib_dealloc_device(&dev->ibdev);
+}
+
+static int qedr_close(struct qedr_dev *dev)
+{
+	qedr_ib_dispatch_event(dev, 1, IB_EVENT_PORT_ERR);
+
+	return 0;
+}
+
+static void qedr_shutdown(struct qedr_dev *dev)
+{
+	qedr_close(dev);
+	qedr_remove(dev);
+}
+
+/* event handling via NIC driver ensures that all the NIC specific
+ * initialization done before RoCE driver notifies
+ * event to stack.
+ */
+static void qedr_notify(struct qedr_dev *dev, enum qede_roce_event event)
+{
+	switch (event) {
+	case QEDE_UP:
+		qedr_ib_dispatch_event(dev, 1, IB_EVENT_PORT_ACTIVE);
+		break;
+	case QEDE_DOWN:
+		qedr_close(dev);
+		break;
+	case QEDE_CLOSE:
+		qedr_shutdown(dev);
+		break;
+	case QEDE_CHANGE_ADDR:
+		qedr_ib_dispatch_event(dev, 1, IB_EVENT_GID_CHANGE);
+		break;
+	default:
+		pr_err("Event not supported\n");
+	}
+}
+
+static struct qedr_driver qedr_drv = {
+	.name = "qedr_driver",
+	.add = qedr_add,
+	.remove = qedr_remove,
+	.notify = qedr_notify,
+};
+
+static int __init qedr_init_module(void)
+{
+	return qede_roce_register_driver(&qedr_drv);
+}
+
+static void __exit qedr_exit_module(void)
+{
+	qede_roce_unregister_driver(&qedr_drv);
+}
+
+module_init(qedr_init_module);
+module_exit(qedr_exit_module);
diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
new file mode 100644
index 0000000..c8a1f61
--- /dev/null
+++ b/drivers/infiniband/hw/qedr/qedr.h
@@ -0,0 +1,59 @@
+/* QLogic qedr NIC Driver
+ * Copyright (c) 2015-2016  QLogic Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and /or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#ifndef __QEDR_H__
+#define __QEDR_H__
+
+#include <linux/pci.h>
+#include <rdma/ib_addr.h>
+#include <linux/qed/qed_if.h>
+#include <linux/qed/qede_roce.h>
+
+#define QEDR_MODULE_VERSION	"8.10.10.0"
+#define QEDR_NODE_DESC "QLogic 579xx RoCE HCA"
+#define DP_NAME(dev) ((dev)->ibdev.name)
+
+enum DP_QEDR_MODULE {
+	QEDR_MSG_INIT = 0x10000,
+};
+
+struct qedr_dev {
+	struct ib_device	ibdev;
+	struct qed_dev		*cdev;
+	struct pci_dev		*pdev;
+	struct net_device	*ndev;
+
+	enum ib_atomic_cap	atomic_cap;
+
+	u32			dp_module;
+	u8			dp_level;
+};
+#endif
diff --git a/drivers/net/ethernet/qlogic/qede/Makefile b/drivers/net/ethernet/qlogic/qede/Makefile
index 74a4985..28dc589 100644
--- a/drivers/net/ethernet/qlogic/qede/Makefile
+++ b/drivers/net/ethernet/qlogic/qede/Makefile
@@ -2,3 +2,4 @@ obj-$(CONFIG_QEDE) := qede.o
 
 qede-y := qede_main.o qede_ethtool.o
 qede-$(CONFIG_DCB) += qede_dcbnl.o
+qede-$(CONFIG_INFINIBAND_QEDR) += qede_roce.o
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index e01adce..28c0e9f 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -106,6 +106,13 @@ struct qede_vlan {
 	bool configured;
 };
 
+struct qede_rdma_dev {
+	struct qedr_dev *qedr_dev;
+	struct list_head entry;
+	struct list_head roce_event_list;
+	struct workqueue_struct *roce_wq;
+};
+
 struct qede_dev {
 	struct qed_dev			*cdev;
 	struct net_device		*ndev;
@@ -185,6 +192,8 @@ struct qede_dev {
 	unsigned long			sp_flags;
 	u16				vxlan_dst_port;
 	u16				geneve_dst_port;
+
+	struct qede_rdma_dev		rdma_info;
 };
 
 enum QEDE_STATE {
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index cd23a29..37f3a77 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -36,7 +36,7 @@
 #include <linux/random.h>
 #include <net/ip6_checksum.h>
 #include <linux/bitops.h>
-
+#include <linux/qed/qede_roce.h>
 #include "qede.h"
 
 static char version[] =
@@ -189,8 +189,7 @@ static int qede_netdev_event(struct notifier_block *this, unsigned long event,
 	struct ethtool_drvinfo drvinfo;
 	struct qede_dev *edev;
 
-	/* Currently only support name change */
-	if (event != NETDEV_CHANGENAME)
+	if (event != NETDEV_CHANGENAME && event != NETDEV_CHANGEADDR)
 		goto done;
 
 	/* Check whether this is a qede device */
@@ -203,11 +202,18 @@ static int qede_netdev_event(struct notifier_block *this, unsigned long event,
 		goto done;
 	edev = netdev_priv(ndev);
 
-	/* Notify qed of the name change */
-	if (!edev->ops || !edev->ops->common)
-		goto done;
-	edev->ops->common->set_id(edev->cdev, edev->ndev->name,
-				  "qede");
+	switch (event) {
+	case NETDEV_CHANGENAME:
+		/* Notify qed of the name change */
+		if (!edev->ops || !edev->ops->common)
+			goto done;
+		edev->ops->common->set_id(edev->cdev, edev->ndev->name, "qede");
+		break;
+	case NETDEV_CHANGEADDR:
+		edev = netdev_priv(ndev);
+		qede_roce_event_changeaddr(edev);
+		break;
+	}
 
 done:
 	return NOTIFY_DONE;
@@ -2541,10 +2547,14 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 
 	qede_init_ndev(edev);
 
+	rc = qede_roce_dev_add(edev);
+	if (rc)
+		goto err3;
+
 	rc = register_netdev(edev->ndev);
 	if (rc) {
 		DP_NOTICE(edev, "Cannot register net-device\n");
-		goto err3;
+		goto err4;
 	}
 
 	edev->ops->common->set_id(cdev, edev->ndev->name, DRV_MODULE_VERSION);
@@ -2564,6 +2574,8 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 
 	return 0;
 
+err4:
+	qede_roce_dev_remove(edev);
 err3:
 	free_netdev(edev->ndev);
 err2:
@@ -2610,8 +2622,11 @@ static void __qede_remove(struct pci_dev *pdev, enum qede_remove_mode mode)
 	DP_INFO(edev, "Starting qede_remove\n");
 
 	cancel_delayed_work_sync(&edev->sp_task);
+
 	unregister_netdev(ndev);
 
+	qede_roce_dev_remove(edev);
+
 	edev->ops->common->set_power_state(cdev, PCI_D0);
 
 	pci_set_drvdata(pdev, NULL);
@@ -3508,6 +3523,7 @@ static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode)
 
 	DP_INFO(edev, "Starting qede unload\n");
 
+	qede_roce_dev_event_close(edev);
 	mutex_lock(&edev->qede_lock);
 	edev->state = QEDE_STATE_CLOSED;
 
@@ -3608,6 +3624,7 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 	/* Query whether link is already-up */
 	memset(&link_output, 0, sizeof(link_output));
 	edev->ops->common->get_link(edev->cdev, &link_output);
+	qede_roce_dev_event_open(edev);
 	qede_link_update(edev, &link_output);
 
 	DP_INFO(edev, "Ending successfully qede load\n");
diff --git a/drivers/net/ethernet/qlogic/qede/qede_roce.c b/drivers/net/ethernet/qlogic/qede/qede_roce.c
new file mode 100644
index 0000000..3d12a44
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qede/qede_roce.c
@@ -0,0 +1,309 @@
+/* QLogic qedr NIC Driver
+ * Copyright (c) 2015-2016  QLogic Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and /or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/qed/qede_roce.h>
+#include "qede.h"
+
+static struct qedr_driver *qedr_drv;
+static LIST_HEAD(qedr_dev_list);
+static DEFINE_MUTEX(qedr_dev_list_lock);
+
+bool qede_roce_supported(struct qede_dev *dev)
+{
+	return dev->dev_info.common.rdma_supported;
+}
+
+static void _qede_roce_dev_add(struct qede_dev *edev)
+{
+	if (!qedr_drv)
+		return;
+
+	edev->rdma_info.qedr_dev = qedr_drv->add(edev->cdev, edev->pdev,
+						 edev->ndev);
+}
+
+static int qede_roce_create_wq(struct qede_dev *edev)
+{
+	INIT_LIST_HEAD(&edev->rdma_info.roce_event_list);
+	edev->rdma_info.roce_wq = create_singlethread_workqueue("roce_wq");
+	if (!edev->rdma_info.roce_wq) {
+		pr_err("qedr: Could not create workqueue\n");
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void qede_roce_cleanup_event(struct qede_dev *edev)
+{
+	struct list_head *head = &edev->rdma_info.roce_event_list;
+	struct qede_roce_event_work *event_node;
+
+	flush_workqueue(edev->rdma_info.roce_wq);
+	while (!list_empty(head)) {
+		event_node = list_entry(head->next, struct qede_roce_event_work,
+					list);
+		cancel_work_sync(&event_node->work);
+		list_del(&event_node->list);
+		kfree(event_node);
+	}
+}
+
+static void qede_roce_destroy_wq(struct qede_dev *edev)
+{
+	qede_roce_cleanup_event(edev);
+	destroy_workqueue(edev->rdma_info.roce_wq);
+}
+
+int qede_roce_dev_add(struct qede_dev *edev)
+{
+	int rc = 0;
+
+	if (qede_roce_supported(edev)) {
+		rc = qede_roce_create_wq(edev);
+		if (rc)
+			return rc;
+
+		INIT_LIST_HEAD(&edev->rdma_info.entry);
+		mutex_lock(&qedr_dev_list_lock);
+		list_add_tail(&edev->rdma_info.entry, &qedr_dev_list);
+		_qede_roce_dev_add(edev);
+		mutex_unlock(&qedr_dev_list_lock);
+	}
+
+	return rc;
+}
+
+static void _qede_roce_dev_remove(struct qede_dev *edev)
+{
+	if (qedr_drv && qedr_drv->remove && edev->rdma_info.qedr_dev)
+		qedr_drv->remove(edev->rdma_info.qedr_dev);
+	edev->rdma_info.qedr_dev = NULL;
+}
+
+void qede_roce_dev_remove(struct qede_dev *edev)
+{
+	if (!qede_roce_supported(edev))
+		return;
+
+	qede_roce_destroy_wq(edev);
+	mutex_lock(&qedr_dev_list_lock);
+	_qede_roce_dev_remove(edev);
+	list_del(&edev->rdma_info.entry);
+	mutex_unlock(&qedr_dev_list_lock);
+}
+
+static void _qede_roce_dev_open(struct qede_dev *edev)
+{
+	if (qedr_drv && edev->rdma_info.qedr_dev && qedr_drv->notify)
+		qedr_drv->notify(edev->rdma_info.qedr_dev, QEDE_UP);
+}
+
+void qede_roce_dev_open(struct qede_dev *edev)
+{
+	if (!qede_roce_supported(edev))
+		return;
+
+	mutex_lock(&qedr_dev_list_lock);
+	_qede_roce_dev_open(edev);
+	mutex_unlock(&qedr_dev_list_lock);
+}
+
+static void _qede_roce_dev_close(struct qede_dev *edev)
+{
+	if (qedr_drv && edev->rdma_info.qedr_dev && qedr_drv->notify)
+		qedr_drv->notify(edev->rdma_info.qedr_dev, QEDE_DOWN);
+}
+
+void qede_roce_dev_close(struct qede_dev *edev)
+{
+	if (!qede_roce_supported(edev))
+		return;
+
+	mutex_lock(&qedr_dev_list_lock);
+	_qede_roce_dev_close(edev);
+	mutex_unlock(&qedr_dev_list_lock);
+}
+
+void qede_roce_dev_shutdown(struct qede_dev *edev)
+{
+	if (!qede_roce_supported(edev))
+		return;
+
+	mutex_lock(&qedr_dev_list_lock);
+	if (qedr_drv && edev->rdma_info.qedr_dev && qedr_drv->notify)
+		qedr_drv->notify(edev->rdma_info.qedr_dev, QEDE_CLOSE);
+	mutex_unlock(&qedr_dev_list_lock);
+}
+
+int qede_roce_register_driver(struct qedr_driver *drv)
+{
+	struct qede_dev *edev;
+	u8 qedr_counter = 0;
+
+	mutex_lock(&qedr_dev_list_lock);
+	if (qedr_drv) {
+		mutex_unlock(&qedr_dev_list_lock);
+		return -EINVAL;
+	}
+	qedr_drv = drv;
+
+	list_for_each_entry(edev, &qedr_dev_list, rdma_info.entry) {
+		struct net_device *netdev;
+
+		qedr_counter++;
+		_qede_roce_dev_add(edev);
+		netdev = edev->ndev;
+		if (netif_running(netdev) && netif_oper_up(netdev))
+			_qede_roce_dev_open(edev);
+	}
+	mutex_unlock(&qedr_dev_list_lock);
+
+	pr_err("qedr: discovered and registered %d RoCE funcs\n", qedr_counter);
+
+	return 0;
+}
+EXPORT_SYMBOL(qede_roce_register_driver);
+
+void qede_roce_unregister_driver(struct qedr_driver *drv)
+{
+	struct qede_dev *edev;
+
+	mutex_lock(&qedr_dev_list_lock);
+	list_for_each_entry(edev, &qedr_dev_list, rdma_info.entry) {
+		if (edev->rdma_info.qedr_dev)
+			_qede_roce_dev_remove(edev);
+	}
+	qedr_drv = NULL;
+	mutex_unlock(&qedr_dev_list_lock);
+}
+EXPORT_SYMBOL(qede_roce_unregister_driver);
+
+void qede_roce_changeaddr(struct qede_dev *edev)
+{
+	if (!qede_roce_supported(edev))
+		return;
+
+	if (qedr_drv && edev->rdma_info.qedr_dev && qedr_drv->notify)
+		qedr_drv->notify(edev->rdma_info.qedr_dev, QEDE_CHANGE_ADDR);
+}
+
+struct qede_roce_event_work *qede_roce_get_free_event_node(struct qede_dev
+							   *edev)
+{
+	struct qede_roce_event_work *event_node = NULL;
+	struct list_head *list_node = NULL;
+	bool found = false;
+
+	list_for_each(list_node, &edev->rdma_info.roce_event_list) {
+		event_node = list_entry(list_node, struct qede_roce_event_work,
+					list);
+		if (!work_pending(&event_node->work)) {
+			found = true;
+			break;
+		}
+	}
+
+	if (!found) {
+		event_node = kzalloc(sizeof(*event_node), GFP_KERNEL);
+		if (!event_node) {
+			pr_err("qedr: Could not allocate memory for roce work\n");
+			return NULL;
+		}
+		list_add_tail(&event_node->list,
+			      &edev->rdma_info.roce_event_list);
+	}
+
+	return event_node;
+}
+
+static void qede_roce_handle_event(struct work_struct *work)
+{
+	struct qede_roce_event_work *event_node;
+	enum qede_roce_event event;
+	struct qede_dev *edev;
+
+	event_node = container_of(work, struct qede_roce_event_work, work);
+	event = event_node->event;
+	edev = event_node->ptr;
+
+	switch (event) {
+	case QEDE_UP:
+		qede_roce_dev_open(edev);
+		break;
+	case QEDE_DOWN:
+		qede_roce_dev_close(edev);
+		break;
+	case QEDE_CLOSE:
+		qede_roce_dev_shutdown(edev);
+		break;
+	case QEDE_CHANGE_ADDR:
+		qede_roce_changeaddr(edev);
+		break;
+	default:
+		pr_err("qede: Invalid roce event %d", event);
+	}
+}
+
+static void qede_roce_add_event(struct qede_dev *edev,
+				enum qede_roce_event event)
+{
+	struct qede_roce_event_work *event_node;
+
+	event_node = qede_roce_get_free_event_node(edev);
+	if (!event_node)
+		return;
+
+	event_node->event = event;
+	event_node->ptr = edev;
+
+	INIT_WORK(&event_node->work, qede_roce_handle_event);
+	queue_work(edev->rdma_info.roce_wq, &event_node->work);
+}
+
+void qede_roce_dev_event_open(struct qede_dev *edev)
+{
+	qede_roce_add_event(edev, QEDE_UP);
+}
+
+void qede_roce_dev_event_close(struct qede_dev *edev)
+{
+	qede_roce_add_event(edev, QEDE_DOWN);
+}
+
+void qede_roce_event_changeaddr(struct qede_dev *edev)
+{
+	qede_roce_add_event(edev, QEDE_CHANGE_ADDR);
+}
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index c2d74e8..e313742 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -260,11 +260,10 @@ struct qed_dev_info {
 	/* MFW version */
 	u32		mfw_rev;
 
-	bool rdma_supported;
-
 	u32		flash_size;
 	u8		mf_mode;
 	bool		tx_switching;
+	bool		rdma_supported;
 };
 
 enum qed_sb_type {
diff --git a/include/linux/qed/qede_roce.h b/include/linux/qed/qede_roce.h
new file mode 100644
index 0000000..fd7acc1
--- /dev/null
+++ b/include/linux/qed/qede_roce.h
@@ -0,0 +1,88 @@
+/* QLogic qedr NIC Driver
+ * Copyright (c) 2015-2016  QLogic Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and /or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#ifndef QEDE_ROCE_H
+#define QEDE_ROCE_H
+
+struct qedr_dev;
+struct qed_dev;
+struct qede_dev;
+
+enum qede_roce_event {
+	QEDE_UP,
+	QEDE_DOWN,
+	QEDE_CHANGE_ADDR,
+	QEDE_CLOSE
+};
+
+struct qede_roce_event_work {
+	struct list_head list;
+	struct work_struct work;
+	void *ptr;
+	enum qede_roce_event event;
+};
+
+struct qedr_driver {
+	unsigned char name[32];
+
+	struct qedr_dev* (*add)(struct qed_dev *, struct pci_dev *,
+				struct net_device *);
+
+	void (*remove)(struct qedr_dev *);
+	void (*notify)(struct qedr_dev *, enum qede_roce_event);
+};
+
+/* APIs for RoCE driver to register callback handlers,
+ * which will be invoked when device is added, removed, ifup, ifdown
+ */
+int qede_roce_register_driver(struct qedr_driver *drv);
+void qede_roce_unregister_driver(struct qedr_driver *drv);
+
+bool qede_roce_supported(struct qede_dev *dev);
+
+#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
+int qede_roce_dev_add(struct qede_dev *dev);
+void qede_roce_dev_event_open(struct qede_dev *dev);
+void qede_roce_dev_event_close(struct qede_dev *dev);
+void qede_roce_dev_remove(struct qede_dev *dev);
+void qede_roce_event_changeaddr(struct qede_dev *qedr);
+#else
+static int qede_roce_dev_add(struct qede_dev *dev)
+{
+	return 0;
+}
+
+static void qede_roce_dev_event_open(struct qede_dev *dev) {}
+static void qede_roce_dev_event_close(struct qede_dev *dev) {}
+static void qede_roce_dev_remove(struct qede_dev *dev) {}
+static void qede_roce_event_changeaddr(struct qede_dev *qedr) {}
+#endif
+#endif
diff --git a/include/uapi/linux/pci_regs.h b/include/uapi/linux/pci_regs.h
index 4040951..3973000 100644
--- a/include/uapi/linux/pci_regs.h
+++ b/include/uapi/linux/pci_regs.h
@@ -612,6 +612,8 @@
  */
 #define PCI_EXP_DEVCAP2		36	/* Device Capabilities 2 */
 #define  PCI_EXP_DEVCAP2_ARI		0x00000020 /* Alternative Routing-ID */
+#define  PCI_EXP_DEVCAP2_ATOMIC_ROUTE	0x00000040 /* Atomic Op routing */
+#define PCI_EXP_DEVCAP2_ATOMIC_COMP64	0x00000100 /* Atomic 64-bit comparison */
 #define  PCI_EXP_DEVCAP2_LTR		0x00000800 /* Latency tolerance reporting */
 #define  PCI_EXP_DEVCAP2_OBFF_MASK	0x000c0000 /* OBFF support mechanism */
 #define  PCI_EXP_DEVCAP2_OBFF_MSG	0x00040000 /* New message signaling */
@@ -619,6 +621,7 @@
 #define PCI_EXP_DEVCTL2		40	/* Device Control 2 */
 #define  PCI_EXP_DEVCTL2_COMP_TIMEOUT	0x000f	/* Completion Timeout Value */
 #define  PCI_EXP_DEVCTL2_ARI		0x0020	/* Alternative Routing-ID */
+#define PCI_EXP_DEVCTL2_ATOMIC_REQ	0x0040	/* Set Atomic requests */
 #define  PCI_EXP_DEVCTL2_IDO_REQ_EN	0x0100	/* Allow IDO for requests */
 #define  PCI_EXP_DEVCTL2_IDO_CMP_EN	0x0200	/* Allow IDO for completions */
 #define  PCI_EXP_DEVCTL2_LTR_EN		0x0400	/* Enable LTR mechanism */
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
