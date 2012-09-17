From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/8] ixgbe: add debugfs support
Date: Sun, 16 Sep 2012 21:15:39 -0700
Message-ID: <1347855342-6610-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8883 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750788Ab2IQEPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 00:15:50 -0400
In-Reply-To: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

This patch adds debugfs support to the ixgbe driver to give
users the ability to access kernel information and to
simulate kernel events.

The filesystem is set up in the following driver/PCI-instance
hierarchy:
<debugfs>
   |-- ixgbe
	|-- PCI instance
	|	|-- attribute files

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/Makefile        |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         | 10 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c | 79 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 17 +++++
 4 files changed, 106 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c

diff --git a/drivers/net/ethernet/intel/ixgbe/Makefile b/drivers/net/ethernet/intel/ixgbe/Makefile
index 5fd5d04..89f40e5 100644
--- a/drivers/net/ethernet/intel/ixgbe/Makefile
+++ b/drivers/net/ethernet/intel/ixgbe/Makefile
@@ -32,7 +32,7 @@
 
 obj-$(CONFIG_IXGBE) += ixgbe.o
 
-ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
+ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o ixgbe_debugfs.o\
               ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o ixgbe_sriov.o \
               ixgbe_mbx.o ixgbe_x540.o ixgbe_lib.o
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index bffcf1f..5bd2676 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -597,6 +597,9 @@ struct ixgbe_adapter {
 #ifdef CONFIG_IXGBE_HWMON
 	struct hwmon_buff ixgbe_hwmon_buff;
 #endif /* CONFIG_IXGBE_HWMON */
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *ixgbe_dbg_adapter;
+#endif /*CONFIG_DEBUG_FS*/
 };
 
 struct ixgbe_fdir_filter {
@@ -725,7 +728,12 @@ extern int ixgbe_fcoe_get_hbainfo(struct net_device *netdev,
 				  struct netdev_fcoe_hbainfo *info);
 extern u8 ixgbe_fcoe_get_tc(struct ixgbe_adapter *adapter);
 #endif /* IXGBE_FCOE */
-
+#ifdef CONFIG_DEBUG_FS
+extern void ixgbe_dbg_adapter_init(struct ixgbe_adapter *adapter);
+extern void ixgbe_dbg_adapter_exit(struct ixgbe_adapter *adapter);
+extern void ixgbe_dbg_init(void);
+extern void ixgbe_dbg_exit(void);
+#endif /* CONFIG_DEBUG_FS */
 static inline struct netdev_queue *txring_txq(const struct ixgbe_ring *ring)
 {
 	return netdev_get_tx_queue(ring->netdev, ring->queue_index);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
new file mode 100644
index 0000000..0b08b6c
--- /dev/null
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
@@ -0,0 +1,79 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2012 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifdef CONFIG_DEBUG_FS
+
+#include <linux/debugfs.h>
+#include <linux/module.h>
+
+#include "ixgbe.h"
+
+static struct dentry *ixgbe_dbg_root;
+
+/**
+ * ixgbe_dbg_adapter_init - setup the debugfs directory for the adapter
+ * @adapter: the adapter that is starting up
+ **/
+void ixgbe_dbg_adapter_init(struct ixgbe_adapter *adapter)
+{
+	const char *name = pci_name(adapter->pdev);
+
+	adapter->ixgbe_dbg_adapter = debugfs_create_dir(name, ixgbe_dbg_root);
+	if (!adapter->ixgbe_dbg_adapter)
+		e_dev_err("debugfs entry for %s failed\n", name);
+}
+
+/**
+ * ixgbe_dbg_adapter_exit - clear out the adapter's debugfs entries
+ * @pf: the pf that is stopping
+ **/
+void ixgbe_dbg_adapter_exit(struct ixgbe_adapter *adapter)
+{
+	if (adapter->ixgbe_dbg_adapter)
+		debugfs_remove_recursive(adapter->ixgbe_dbg_adapter);
+	adapter->ixgbe_dbg_adapter = NULL;
+}
+
+/**
+ * ixgbe_dbg_init - start up debugfs for the driver
+ **/
+void ixgbe_dbg_init(void)
+{
+	ixgbe_dbg_root = debugfs_create_dir(ixgbe_driver_name, NULL);
+	if (ixgbe_dbg_root == NULL)
+		pr_err("init of debugfs failed\n");
+}
+
+/**
+ * ixgbe_dbg_exit - clean out the driver's debugfs entries
+ **/
+void ixgbe_dbg_exit(void)
+{
+	debugfs_remove_recursive(ixgbe_dbg_root);
+}
+
+#endif /* CONFIG_DEBUG_FS */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e641f14..b3b846b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7448,6 +7448,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		e_err(probe, "failed to allocate sysfs resources\n");
 #endif /* CONFIG_IXGBE_HWMON */
 
+#ifdef CONFIG_DEBUG_FS
+	ixgbe_dbg_adapter_init(adapter);
+#endif /* CONFIG_DEBUG_FS */
+
 	return 0;
 
 err_register:
@@ -7482,6 +7486,10 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
 
+#ifdef CONFIG_DEBUG_FS
+	ixgbe_dbg_adapter_exit(adapter);
+#endif /*CONFIG_DEBUG_FS */
+
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	cancel_work_sync(&adapter->service_task);
 
@@ -7737,6 +7745,10 @@ static int __init ixgbe_init_module(void)
 	pr_info("%s - version %s\n", ixgbe_driver_string, ixgbe_driver_version);
 	pr_info("%s\n", ixgbe_copyright);
 
+#ifdef CONFIG_DEBUG_FS
+	ixgbe_dbg_init();
+#endif /* CONFIG_DEBUG_FS */
+
 #ifdef CONFIG_IXGBE_DCA
 	dca_register_notify(&dca_notifier);
 #endif
@@ -7759,6 +7771,11 @@ static void __exit ixgbe_exit_module(void)
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&ixgbe_driver);
+
+#ifdef CONFIG_DEBUG_FS
+	ixgbe_dbg_exit();
+#endif /* CONFIG_DEBUG_FS */
+
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
-- 
1.7.11.4
