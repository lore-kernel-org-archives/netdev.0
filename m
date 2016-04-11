From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 03/11] fjes: Add debugs facility for fjes module
Date: Mon, 11 Apr 2016 17:10:11 +0900
Message-ID: <1460362211-15122-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym04.jp.fujitsu.com ([211.128.242.43]:19067 "EHLO
	mgwym04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133AbcDKISe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:18:34 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 01CC1AC00AC
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:18:28 +0900 (JST)
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces debugfs facility for fjes module.
You can get EP status information by reading
/sys/kernel/debug/fjes/fjes.N/status file.
This is useful for debugging.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/Makefile       |   2 +-
 drivers/net/fjes/fjes.h         |  16 ++++++
 drivers/net/fjes/fjes_debugfs.c | 113 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_main.c    |  12 ++++-
 4 files changed, 141 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/fjes/fjes_debugfs.c

diff --git a/drivers/net/fjes/Makefile b/drivers/net/fjes/Makefile
index 523e3d7..51c20ce 100644
--- a/drivers/net/fjes/Makefile
+++ b/drivers/net/fjes/Makefile
@@ -27,4 +27,4 @@
 
 obj-$(CONFIG_FUJITSU_ES) += fjes.o
 
-fjes-objs := fjes_main.o fjes_hw.o fjes_ethtool.o
+fjes-objs := fjes_main.o fjes_hw.o fjes_ethtool.o fjes_debugfs.o
diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
index a592fe2..a528f75 100644
--- a/drivers/net/fjes/fjes.h
+++ b/drivers/net/fjes/fjes.h
@@ -66,6 +66,10 @@ struct fjes_adapter {
 	bool interrupt_watch_enable;
 
 	struct fjes_hw hw;
+
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *dbg_adapter;
+#endif /* CONFIG_DEBUG_FS */
 };
 
 extern char fjes_driver_name[];
@@ -74,4 +78,16 @@ extern const u32 fjes_support_mtu[];
 
 void fjes_set_ethtool_ops(struct net_device *);
 
+#ifdef CONFIG_DEBUG_FS
+void fjes_dbg_adapter_init(struct fjes_adapter *adapter);
+void fjes_dbg_adapter_exit(struct fjes_adapter *adapter);
+void fjes_dbg_init(void);
+void fjes_dbg_exit(void);
+#else
+static inline void fjes_dbg_adapter_init(struct fjes_adapter *adapter) {}
+static inline void fjes_dbg_adapter_exit(struct fjes_adapter *adapter) {}
+static inline void fjes_dbg_init(void) {}
+static inline void fjes_dbg_exit(void) {}
+#endif /* CONFIG_DEBUF_FS */
+
 #endif /* FJES_H_ */
diff --git a/drivers/net/fjes/fjes_debugfs.c b/drivers/net/fjes/fjes_debugfs.c
new file mode 100644
index 0000000..d2fd892
--- /dev/null
+++ b/drivers/net/fjes/fjes_debugfs.c
@@ -0,0 +1,113 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+/* debugfs support for fjes */
+
+#ifdef CONFIG_DEBUG_FS
+
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
+#include <linux/platform_device.h>
+
+#include "fjes.h"
+
+static struct dentry *fjes_debug_root;
+
+static int fjes_dbg_status_show(struct seq_file *m, void *v)
+{
+	struct fjes_adapter *adapter = m->private;
+	struct fjes_hw *hw = &adapter->hw;
+	int max_epid = hw->max_epid;
+	int my_epid = hw->my_epid;
+	int epidx;
+
+	seq_printf(m,
+		   "status debug EP ID(n) n is partner status: UNSHARE(%d), SHARED(%d), WAITING(%d), COMPLETE(%d)\n",
+		   EP_PARTNER_UNSHARE, EP_PARTNER_SHARED, EP_PARTNER_WAITING,
+		   EP_PARTNER_COMPLETE);
+	seq_printf(m, "EP ID          SAME ZONE        CONNECTED\n");
+	for (epidx = 0; epidx < max_epid; epidx++) {
+		seq_printf(m, "%d", epidx);
+		if (epidx == my_epid)
+			seq_printf(m, "(self)        %c                %c\n",
+				   '-', '-');
+		else
+			seq_printf(m, "(%d)           %c                %c\n",
+				   fjes_hw_get_partner_ep_status(hw, epidx),
+				   fjes_hw_epid_is_same_zone(hw, epidx) ? 'Y' : 'N',
+				   fjes_hw_epid_is_shared(hw->hw_info.share, epidx) ? 'Y' : 'N');
+	}
+
+	return 0;
+}
+
+static int fjes_dbg_status_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, fjes_dbg_status_show, inode->i_private);
+}
+
+static const struct file_operations fjes_dbg_status_fops = {
+	.owner		= THIS_MODULE,
+	.open		= fjes_dbg_status_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+void fjes_dbg_adapter_init(struct fjes_adapter *adapter)
+{
+	const char *name = dev_name(&adapter->plat_dev->dev);
+	struct dentry *pfile;
+
+	adapter->dbg_adapter = debugfs_create_dir(name, fjes_debug_root);
+	if (!adapter->dbg_adapter) {
+		dev_err(&adapter->plat_dev->dev,
+			"debugfs entry for %s failed\n", name);
+		return;
+	}
+
+	pfile = debugfs_create_file("status", 0444, adapter->dbg_adapter,
+				    adapter, &fjes_dbg_status_fops);
+	if (!pfile)
+		dev_err(&adapter->plat_dev->dev,
+			"debugfs status for %s failed\n", name);
+}
+
+void fjes_dbg_adapter_exit(struct fjes_adapter *adapter)
+{
+	debugfs_remove_recursive(adapter->dbg_adapter);
+	adapter->dbg_adapter = NULL;
+}
+
+void fjes_dbg_init(void)
+{
+	fjes_debug_root = debugfs_create_dir(fjes_driver_name, NULL);
+	if (!fjes_debug_root)
+		pr_info("init of debugfs failed\n");
+}
+
+void fjes_dbg_exit(void)
+{
+	debugfs_remove_recursive(fjes_debug_root);
+	fjes_debug_root = NULL;
+}
+
+#endif /* CONFIG_DEBUG_FS */
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 40cf65d..7595415 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -1359,6 +1359,8 @@ static int fjes_probe(struct platform_device *plat_dev)
 
 	netif_carrier_off(netdev);
 
+	fjes_dbg_adapter_init(adapter);
+
 	return 0;
 
 err_hw_exit:
@@ -1376,6 +1378,8 @@ static int fjes_remove(struct platform_device *plat_dev)
 	struct fjes_adapter *adapter = netdev_priv(netdev);
 	struct fjes_hw *hw = &adapter->hw;
 
+	fjes_dbg_adapter_exit(adapter);
+
 	cancel_delayed_work_sync(&adapter->interrupt_watch_task);
 	cancel_work_sync(&adapter->unshare_watch_task);
 	cancel_work_sync(&adapter->raise_intr_rxdata_task);
@@ -1566,9 +1570,13 @@ static int __init fjes_init_module(void)
 	pr_info("%s - version %s - %s\n",
 		fjes_driver_string, fjes_driver_version, fjes_copyright);
 
+	fjes_dbg_init();
+
 	result = platform_driver_register(&fjes_driver);
-	if (result < 0)
+	if (result < 0) {
+		fjes_dbg_exit();
 		return result;
+	}
 
 	result = acpi_bus_register_driver(&fjes_acpi_driver);
 	if (result < 0)
@@ -1578,6 +1586,7 @@ static int __init fjes_init_module(void)
 
 fail_acpi_driver:
 	platform_driver_unregister(&fjes_driver);
+	fjes_dbg_exit();
 	return result;
 }
 
@@ -1588,6 +1597,7 @@ static void __exit fjes_exit_module(void)
 {
 	acpi_bus_unregister_driver(&fjes_acpi_driver);
 	platform_driver_unregister(&fjes_driver);
+	fjes_dbg_exit();
 }
 
 module_exit(fjes_exit_module);
-- 
2.4.3
