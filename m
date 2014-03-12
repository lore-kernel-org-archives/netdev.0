From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] igb: Add debugfs skeleton
Date: Tue, 11 Mar 2014 22:53:29 -0700
Message-ID: <1394603618-1044-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Josh Hay <hayja@mail.uc.edu>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57958 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753989AbaCLFxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 01:53:42 -0400
In-Reply-To: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds the basic init and exit functions for debugfs.

Signed-off-by: Josh Hay <hayja@mail.uc.edu>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper  <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/Makefile      |  2 +-
 drivers/net/ethernet/intel/igb/igb.h         | 15 +++++++
 drivers/net/ethernet/intel/igb/igb_debugfs.c | 64 ++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c    |  8 ++++
 4 files changed, 88 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_debugfs.c

diff --git a/drivers/net/ethernet/intel/igb/Makefile b/drivers/net/ethernet/intel/igb/Makefile
index 5bcb2de..9336024 100644
--- a/drivers/net/ethernet/intel/igb/Makefile
+++ b/drivers/net/ethernet/intel/igb/Makefile
@@ -33,4 +33,4 @@ obj-$(CONFIG_IGB) += igb.o
 
 igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
 	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o \
-	    e1000_i210.o igb_ptp.o igb_hwmon.o
+	    e1000_i210.o igb_ptp.o igb_hwmon.o igb_debugfs.o
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index a202c96..68b32d4a 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -457,6 +457,9 @@ struct igb_adapter {
 	int copper_tries;
 	struct e1000_info ei;
 	u16 eee_advert;
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *igb_dbg_adapter;
+#endif /* CONFIG_DEBUG_FS */
 };
 
 #define IGB_FLAG_HAS_MSI		(1 << 0)
@@ -588,4 +591,16 @@ static inline struct netdev_queue *txring_txq(const struct igb_ring *tx_ring)
 	return netdev_get_tx_queue(tx_ring->netdev, tx_ring->queue_index);
 }
 
+#ifdef CONFIG_DEBUG_FS
+extern void igb_dbg_adapter_init(struct igb_adapter *adapter);
+extern void igb_dbg_adapter_exit(struct igb_adapter *adapter);
+extern void igb_dbg_init(void);
+extern void igb_dbg_exit(void);
+#else
+static inline void igb_dbg_adapter_init(struct igb_adapter *adapter) {}
+static inline void igb_dbg_adapter_exit(struct igb_adapter *adapter) {}
+static inline void igb_dbg_init(void) {}
+static inline void igb_dbg_exit(void) {}
+#endif /* CONFIG_DEBUG_FS */
+
 #endif /* _IGB_H_ */
diff --git a/drivers/net/ethernet/intel/igb/igb_debugfs.c b/drivers/net/ethernet/intel/igb/igb_debugfs.c
new file mode 100644
index 0000000..c38dd13
--- /dev/null
+++ b/drivers/net/ethernet/intel/igb/igb_debugfs.c
@@ -0,0 +1,64 @@
+/*******************************************************************************
+
+  Intel(R) Gigabit Ethernet Linux driver
+  Copyright(c) 2007-2014 Intel Corporation.
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
+  You should have received a copy of the GNU General Public License along
+  with this program.  If not, see <http://www.gnu.org/licenses/>.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+#include <linux/fs.h>
+#include <linux/debugfs.h>
+#include <linux/pci.h>
+
+#include "igb.h"
+
+static struct dentry *igb_dbg_root;
+
+/**
+ * igb_dbp_adapter_init - setup the debugfs directory for the adapter
+ * @adapter: the adapter that is starting up
+ **/
+void igb_dbg_adapter_init(struct igb_adapter *adapter)
+{
+	const char *name = pci_name(adapter->pdev);
+
+	adapter->igb_dbg_adapter = debugfs_create_dir(name, igb_dbg_root);
+	if (!adapter->igb_dbg_adapter)
+		dev_err(&adapter->pdev->dev,
+			"debugfs entry for %s failed\n", name);
+}
+
+/**
+ * igb_dbg_init - start up debugfs for the driver
+ **/
+void igb_dbg_init(void)
+{
+	igb_dbg_root = debugfs_create_dir(igb_driver_name, NULL);
+	if (igb_dbg_root == NULL)
+		pr_err("debugfs init failed\n");
+}
+
+/**
+ * igb_dbg_exit - clean out the driver's debugfs entries
+ **/
+void igb_dbg_exit(void)
+{
+	debugfs_remove_recursive(igb_dbg_root);
+}
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 340a344..a709caf 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -686,10 +686,15 @@ static int __init igb_init_module(void)
 
 	pr_info("%s\n", igb_copyright);
 
+	igb_dbg_init();
+
 #ifdef CONFIG_IGB_DCA
 	dca_register_notify(&dca_notifier);
 #endif
 	ret = pci_register_driver(&igb_driver);
+	if (ret < 0)
+		igb_dbg_exit();
+
 	return ret;
 }
 
@@ -703,6 +708,8 @@ module_init(igb_init_module);
  **/
 static void __exit igb_exit_module(void)
 {
+	igb_dbg_exit();
+
 #ifdef CONFIG_IGB_DCA
 	dca_unregister_notify(&dca_notifier);
 #endif
@@ -2609,6 +2616,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			break;
 		}
 	}
+	igb_dbg_adapter_init(adapter);
 	pm_runtime_put_noidle(&pdev->dev);
 	return 0;
 
-- 
1.8.3.1
