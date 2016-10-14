From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next v2 5/6] fjes: Add debugfs entry for EP status information in fjes driver
Date: Fri, 14 Oct 2016 20:28:07 +0900
Message-ID: <1476444487-28899-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1476444345-28673-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm02.jp.fujitsu.com ([202.219.69.169]:62387 "EHLO
        mgwkm02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754310AbcJNLjQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 07:39:16 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
        by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 32EEDAC021A
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 20:39:07 +0900 (JST)
In-Reply-To: <1476444345-28673-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds debugfs entry to show EP status information.
You can get each EP's status information like the following:

  # cat /sys/kernel/debug/fjes/fjes.0/status

EPID    STATUS           SAME_ZONE        CONNECTED
ep0     shared           Y                Y
ep1     -                -                -
ep2     unshared         N                N
ep3     unshared         N                N
ep4     unshared         N                N
ep5     unshared         N                N
ep6     unshared         N                N
ep7     unshared         N                N

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/Makefile       |   2 +-
 drivers/net/fjes/fjes.h         |  16 ++++++
 drivers/net/fjes/fjes_debugfs.c | 117 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_main.c    |  12 ++++-
 4 files changed, 145 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/fjes/fjes_debugfs.c

diff --git a/drivers/net/fjes/Makefile b/drivers/net/fjes/Makefile
index 6705d1b..bc47b35 100644
--- a/drivers/net/fjes/Makefile
+++ b/drivers/net/fjes/Makefile
@@ -27,4 +27,4 @@
 
 obj-$(CONFIG_FUJITSU_ES) += fjes.o
 
-fjes-objs := fjes_main.o fjes_hw.o fjes_ethtool.o fjes_trace.o
+fjes-objs := fjes_main.o fjes_hw.o fjes_ethtool.o fjes_trace.o fjes_debugfs.o
diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
index a592fe2..0372be3 100644
--- a/drivers/net/fjes/fjes.h
+++ b/drivers/net/fjes/fjes.h
@@ -66,6 +66,10 @@ struct fjes_adapter {
 	bool interrupt_watch_enable;
 
 	struct fjes_hw hw;
+
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *dbg_adapter;
+#endif
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
+#endif /* CONFIG_DEBUG_FS */
+
 #endif /* FJES_H_ */
diff --git a/drivers/net/fjes/fjes_debugfs.c b/drivers/net/fjes/fjes_debugfs.c
new file mode 100644
index 0000000..30052eb
--- /dev/null
+++ b/drivers/net/fjes/fjes_debugfs.c
@@ -0,0 +1,117 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015-2016 FUJITSU LIMITED
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
+/* debugfs support for fjes driver */
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
+static const char * const ep_status_string[] = {
+	"unshared",
+	"shared",
+	"waiting",
+	"complete",
+};
+
+static int fjes_dbg_status_show(struct seq_file *m, void *v)
+{
+	struct fjes_adapter *adapter = m->private;
+	struct fjes_hw *hw = &adapter->hw;
+	int max_epid = hw->max_epid;
+	int my_epid = hw->my_epid;
+	int epidx;
+
+	seq_puts(m, "EPID\tSTATUS           SAME_ZONE        CONNECTED\n");
+	for (epidx = 0; epidx < max_epid; epidx++) {
+		if (epidx == my_epid) {
+			seq_printf(m, "ep%d\t%-16c %-16c %-16c\n",
+				   epidx, '-', '-', '-');
+		} else {
+			seq_printf(m, "ep%d\t%-16s %-16c %-16c\n",
+				   epidx,
+				   ep_status_string[fjes_hw_get_partner_ep_status(hw, epidx)],
+				   fjes_hw_epid_is_same_zone(hw, epidx) ? 'Y' : 'N',
+				   fjes_hw_epid_is_shared(hw->hw_info.share, epidx) ? 'Y' : 'N');
+		}
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
index 4c135ae..359e7a5 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -1257,6 +1257,8 @@ static int fjes_probe(struct platform_device *plat_dev)
 
 	netif_carrier_off(netdev);
 
+	fjes_dbg_adapter_init(adapter);
+
 	return 0;
 
 err_hw_exit:
@@ -1274,6 +1276,8 @@ static int fjes_remove(struct platform_device *plat_dev)
 	struct fjes_adapter *adapter = netdev_priv(netdev);
 	struct fjes_hw *hw = &adapter->hw;
 
+	fjes_dbg_adapter_exit(adapter);
+
 	cancel_delayed_work_sync(&adapter->interrupt_watch_task);
 	cancel_work_sync(&adapter->unshare_watch_task);
 	cancel_work_sync(&adapter->raise_intr_rxdata_task);
@@ -1478,9 +1482,13 @@ static int __init fjes_init_module(void)
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
@@ -1490,6 +1498,7 @@ static int __init fjes_init_module(void)
 
 fail_acpi_driver:
 	platform_driver_unregister(&fjes_driver);
+	fjes_dbg_exit();
 	return result;
 }
 
@@ -1500,6 +1509,7 @@ static void __exit fjes_exit_module(void)
 {
 	acpi_bus_unregister_driver(&fjes_acpi_driver);
 	platform_driver_unregister(&fjes_driver);
+	fjes_dbg_exit();
 }
 
 module_exit(fjes_exit_module);
-- 
2.6.6
