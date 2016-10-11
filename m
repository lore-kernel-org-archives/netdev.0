From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 4/6] fjes: Implement debug mode for fjes driver
Date: Tue, 11 Oct 2016 17:55:20 +0900
Message-ID: <1476176120-18859-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1476176047-18670-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:19204 "EHLO
        mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752581AbcJKJRl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 05:17:41 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
        by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 43D54AC007E
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 18:06:15 +0900 (JST)
In-Reply-To: <1476176047-18670-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements debug mode for fjes driver.
You can get firmware activity information by enabling
debug mode. This is useful for debugging.

To enable debug mode, write value of debugging mode to
debug_mode file in debugfs:

  # echo 1 > /sys/kernel/debug/fjes/fjes.0/debug_mode

To disable debug mode, write 0 to debug_mode file in debugfs:

  # echo 0 > /sys/kernel/debug/fjes/fjes.0/debug_mode

Firmware activity information can be retrieved via
/sys/kernel/debug/fjes/fjes.0/debug_data file.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/Makefile       |   2 +-
 drivers/net/fjes/fjes.h         |  18 +++++
 drivers/net/fjes/fjes_debugfs.c | 169 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_hw.c      | 122 +++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_hw.h      |  15 ++++
 drivers/net/fjes/fjes_main.c    |  12 ++-
 drivers/net/fjes/fjes_trace.h   |  69 ++++++++++++++++
 7 files changed, 405 insertions(+), 2 deletions(-)
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
index a592fe2..3f4dc73 100644
--- a/drivers/net/fjes/fjes.h
+++ b/drivers/net/fjes/fjes.h
@@ -23,6 +23,7 @@
 #define FJES_H_
 
 #include <linux/acpi.h>
+#include <linux/debugfs.h>
 
 #include "fjes_hw.h"
 
@@ -66,6 +67,11 @@ struct fjes_adapter {
 	bool interrupt_watch_enable;
 
 	struct fjes_hw hw;
+
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *dbg_adapter;
+	struct debugfs_blob_wrapper blob;
+#endif /* CONFIG_DEBUG_FS */
 };
 
 extern char fjes_driver_name[];
@@ -74,4 +80,16 @@ extern const u32 fjes_support_mtu[];
 
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
index 0000000..d868fe7
--- /dev/null
+++ b/drivers/net/fjes/fjes_debugfs.c
@@ -0,0 +1,169 @@
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
+static ssize_t fjes_dbg_dbg_mode_read(struct file *file, char __user *ubuf,
+				      size_t count, loff_t *ppos)
+{
+	struct fjes_adapter *adapter = file->private_data;
+	struct fjes_hw *hw = &adapter->hw;
+	char buf[64];
+	int size;
+
+	size = sprintf(buf, "%d\n", hw->debug_mode);
+
+	return simple_read_from_buffer(ubuf, count, ppos, buf, size);
+}
+
+static ssize_t fjes_dbg_dbg_mode_write(struct file *file,
+				       const char __user *ubuf, size_t count,
+				       loff_t *ppos)
+{
+	struct fjes_adapter *adapter = file->private_data;
+	struct fjes_hw *hw = &adapter->hw;
+	unsigned int value;
+	int ret;
+
+	ret = kstrtouint_from_user(ubuf, count, 10, &value);
+	if (ret)
+		return ret;
+
+	if (value) {
+		if (hw->debug_mode)
+			return -EPERM;
+
+		hw->debug_mode = value;
+
+		/* enable debug mode */
+		mutex_lock(&hw->hw_info.lock);
+		ret = fjes_hw_start_debug(hw);
+		mutex_unlock(&hw->hw_info.lock);
+
+		if (ret) {
+			hw->debug_mode = 0;
+			return ret;
+		}
+	} else {
+		if (!hw->debug_mode)
+			return -EPERM;
+
+		/* disable debug mode */
+		mutex_lock(&hw->hw_info.lock);
+		ret = fjes_hw_stop_debug(hw);
+		mutex_unlock(&hw->hw_info.lock);
+
+		if (ret)
+			return ret;
+	}
+
+	(*ppos)++;
+
+	return count;
+}
+
+static const struct file_operations fjes_dbg_dbg_mode_fops = {
+	.owner		= THIS_MODULE,
+	.open		= simple_open,
+	.read		= fjes_dbg_dbg_mode_read,
+	.write		= fjes_dbg_dbg_mode_write,
+};
+
+void fjes_dbg_adapter_init(struct fjes_adapter *adapter)
+{
+	const char *name = dev_name(&adapter->plat_dev->dev);
+	struct fjes_hw *hw = &adapter->hw;
+	struct dentry *pfile;
+
+	adapter->dbg_adapter = debugfs_create_dir(name, fjes_debug_root);
+	if (!adapter->dbg_adapter) {
+		dev_err(&adapter->plat_dev->dev,
+			"debugfs entry for %s failed\n", name);
+		return;
+	}
+
+	pfile = debugfs_create_file("debug_mode", 0644, adapter->dbg_adapter,
+				    adapter, &fjes_dbg_dbg_mode_fops);
+	if (!pfile)
+		dev_err(&adapter->plat_dev->dev,
+			"debugfs debug_mode for %s failed\n", name);
+
+	adapter->blob.data = vzalloc(FJES_DEBUG_BUFFER_SIZE);
+	adapter->blob.size = FJES_DEBUG_BUFFER_SIZE;
+	if (adapter->blob.data) {
+		pfile = debugfs_create_blob("debug_data", 0444,
+					    adapter->dbg_adapter,
+					    &adapter->blob);
+		if (!pfile)
+			dev_err(&adapter->plat_dev->dev,
+				"debugfs debug_data for %s failed\n", name);
+
+		hw->hw_info.trace = adapter->blob.data;
+		hw->hw_info.trace_size = adapter->blob.size;
+	} else {
+		hw->hw_info.trace = NULL;
+		hw->hw_info.trace_size = 0;
+	}
+}
+
+void fjes_dbg_adapter_exit(struct fjes_adapter *adapter)
+{
+	struct fjes_hw *hw = &adapter->hw;
+
+	debugfs_remove_recursive(adapter->dbg_adapter);
+	adapter->dbg_adapter = NULL;
+
+	if (hw->debug_mode) {
+		/* disable debug mode */
+		mutex_lock(&hw->hw_info.lock);
+		fjes_hw_stop_debug(hw);
+		mutex_unlock(&hw->hw_info.lock);
+	}
+	vfree(hw->hw_info.trace);
+	hw->hw_info.trace = NULL;
+	hw->hw_info.trace_size = 0;
+	hw->debug_mode = 0;
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
diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index dba59dc..adc0bfa 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -1175,3 +1175,125 @@ static void fjes_hw_epstop_task(struct work_struct *work)
 		}
 	}
 }
+
+int fjes_hw_start_debug(struct fjes_hw *hw)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int page_count;
+	int result = 0;
+	void *addr;
+	int i;
+
+	if (!hw->hw_info.trace)
+		return -EPERM;
+	memset(hw->hw_info.trace, 0, FJES_DEBUG_BUFFER_SIZE);
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->start_trace.length =
+		FJES_DEV_COMMAND_START_DBG_REQ_LEN(hw->hw_info.trace_size);
+	req_buf->start_trace.mode = hw->debug_mode;
+	req_buf->start_trace.buffer_len = hw->hw_info.trace_size;
+	page_count = hw->hw_info.trace_size / FJES_DEBUG_PAGE_SIZE;
+	for (i = 0; i < page_count; i++) {
+		addr = ((u8 *)hw->hw_info.trace) + i * FJES_DEBUG_PAGE_SIZE;
+		req_buf->start_trace.buffer[i] =
+			(__le64)(page_to_phys(vmalloc_to_page(addr)) +
+			offset_in_page(addr));
+	}
+
+	res_buf->start_trace.length = 0;
+	res_buf->start_trace.code = 0;
+
+	trace_fjes_hw_start_debug_req(req_buf);
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_START_DEBUG);
+	trace_fjes_hw_start_debug(res_buf);
+
+	if (res_buf->start_trace.length !=
+		FJES_DEV_COMMAND_START_DBG_RES_LEN) {
+		result = -ENOMSG;
+		trace_fjes_hw_start_debug_err("Invalid res_buf");
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->start_trace.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	} else {
+		switch (ret) {
+		case FJES_CMD_STATUS_UNKNOWN:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_TIMEOUT:
+			trace_fjes_hw_start_debug_err("Busy Timeout");
+			result = -EBUSY;
+			break;
+		case FJES_CMD_STATUS_ERROR_PARAM:
+		case FJES_CMD_STATUS_ERROR_STATUS:
+		default:
+			result = -EPERM;
+			break;
+		}
+	}
+
+	return result;
+}
+
+int fjes_hw_stop_debug(struct fjes_hw *hw)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int result = 0;
+
+	if (!hw->hw_info.trace)
+		return -EPERM;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+	req_buf->stop_trace.length = FJES_DEV_COMMAND_STOP_DBG_REQ_LEN;
+
+	res_buf->stop_trace.length = 0;
+	res_buf->stop_trace.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_STOP_DEBUG);
+	trace_fjes_hw_stop_debug(res_buf);
+
+	if (res_buf->stop_trace.length != FJES_DEV_COMMAND_STOP_DBG_RES_LEN) {
+		trace_fjes_hw_stop_debug_err("Invalid res_buf");
+		result = -ENOMSG;
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->stop_trace.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			hw->debug_mode = 0;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	} else {
+		switch (ret) {
+		case FJES_CMD_STATUS_UNKNOWN:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_TIMEOUT:
+			result = -EBUSY;
+			trace_fjes_hw_stop_debug_err("Busy Timeout");
+			break;
+		case FJES_CMD_STATUS_ERROR_PARAM:
+		case FJES_CMD_STATUS_ERROR_STATUS:
+		default:
+			result = -EPERM;
+			break;
+		}
+	}
+
+	return result;
+}
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
index 205182e..3a6da09 100644
--- a/drivers/net/fjes/fjes_hw.h
+++ b/drivers/net/fjes/fjes_hw.h
@@ -33,6 +33,9 @@ struct fjes_hw;
 #define EP_BUFFER_SUPPORT_VLAN_MAX 4
 #define EP_BUFFER_INFO_SIZE 4096
 
+#define FJES_DEBUG_PAGE_SIZE 4096
+#define FJES_DEBUG_BUFFER_SIZE	(16 * FJES_DEBUG_PAGE_SIZE)
+
 #define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3 * 8) /* sec */
 #define FJES_COMMAND_REQ_TIMEOUT  ((5 + 1) * 3 * 8) /* sec */
 #define FJES_COMMAND_REQ_BUFF_TIMEOUT	(60 * 3) /* sec */
@@ -94,6 +97,12 @@ struct fjes_hw;
 #define FJES_DEV_RES_BUF_SIZE(maxep) \
 	FJES_DEV_COMMAND_INFO_RES_LEN(maxep)
 
+#define FJES_DEV_COMMAND_START_DBG_REQ_LEN(byte) \
+	(16 + (8 * (byte) / FJES_DEBUG_PAGE_SIZE))
+#define FJES_DEV_COMMAND_START_DBG_RES_LEN (8)
+#define FJES_DEV_COMMAND_STOP_DBG_REQ_LEN (4)
+#define FJES_DEV_COMMAND_STOP_DBG_RES_LEN (8)
+
 /* Frame & MTU */
 struct esmem_frame {
 	__le32 frame_size;
@@ -173,6 +182,8 @@ enum fjes_dev_command_request_type {
 	FJES_CMD_REQ_INFO		= 0x0001,
 	FJES_CMD_REQ_SHARE_BUFFER	= 0x0002,
 	FJES_CMD_REQ_UNSHARE_BUFFER	= 0x0004,
+	FJES_CMD_REQ_START_DEBUG	= 0x0100,
+	FJES_CMD_REQ_STOP_DEBUG		= 0x0200,
 };
 
 /* parameter for command control */
@@ -321,6 +332,8 @@ struct fjes_hw {
 	struct fjes_hw_info hw_info;
 
 	spinlock_t rx_status_lock; /* spinlock for rx_status */
+
+	u32 debug_mode;
 };
 
 int fjes_hw_init(struct fjes_hw *);
@@ -353,4 +366,6 @@ void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *, size_t *);
 void fjes_hw_epbuf_rx_curpkt_drop(struct epbuf_handler *);
 int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *, void *, size_t);
 
+int fjes_hw_start_debug(struct fjes_hw *);
+int fjes_hw_stop_debug(struct fjes_hw *);
 #endif /* FJES_HW_H_ */
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
diff --git a/drivers/net/fjes/fjes_trace.h b/drivers/net/fjes/fjes_trace.h
index 32f9752..db355cac 100644
--- a/drivers/net/fjes/fjes_trace.h
+++ b/drivers/net/fjes/fjes_trace.h
@@ -210,6 +210,75 @@ TRACE_EVENT(fjes_hw_unregister_buff_addr_err,
 	TP_printk("%s", __get_str(err))
 );
 
+TRACE_EVENT(fjes_hw_start_debug_req,
+	TP_PROTO(union fjes_device_command_req *req_buf),
+	TP_ARGS(req_buf),
+	TP_STRUCT__entry(
+		__field(int, length)
+		__field(int, mode)
+		__field(phys_addr_t, buffer)
+	),
+	TP_fast_assign(
+		__entry->length = req_buf->start_trace.length;
+		__entry->mode = req_buf->start_trace.mode;
+		__entry->buffer = req_buf->start_trace.buffer[0];
+	),
+	TP_printk("req_buf=[length=%d, mode=%d, buffer=%p]",
+		  __entry->length, __entry->mode, (void *)__entry->buffer)
+);
+
+TRACE_EVENT(fjes_hw_start_debug,
+	TP_PROTO(union fjes_device_command_res *res_buf),
+	TP_ARGS(res_buf),
+	TP_STRUCT__entry(
+		__field(int, length)
+		__field(int, code)
+	),
+	TP_fast_assign(
+		__entry->length = res_buf->start_trace.length;
+		__entry->code = res_buf->start_trace.code;
+	),
+	TP_printk("res_buf=[length=%d, code=%d]", __entry->length, __entry->code)
+);
+
+TRACE_EVENT(fjes_hw_start_debug_err,
+	TP_PROTO(char *err),
+	TP_ARGS(err),
+	TP_STRUCT__entry(
+		 __string(err, err)
+	),
+	TP_fast_assign(
+		__assign_str(err, err)
+	),
+	TP_printk("%s", __get_str(err))
+);
+
+TRACE_EVENT(fjes_hw_stop_debug,
+	TP_PROTO(union fjes_device_command_res *res_buf),
+	TP_ARGS(res_buf),
+	TP_STRUCT__entry(
+		__field(int, length)
+		__field(int, code)
+	),
+	TP_fast_assign(
+		__entry->length = res_buf->stop_trace.length;
+		__entry->code = res_buf->stop_trace.code;
+	),
+	TP_printk("res_buf=[length=%d, code=%d]", __entry->length, __entry->code)
+);
+
+TRACE_EVENT(fjes_hw_stop_debug_err,
+	TP_PROTO(char *err),
+	TP_ARGS(err),
+	TP_STRUCT__entry(
+		 __string(err, err)
+	),
+	TP_fast_assign(
+		__assign_str(err, err)
+	),
+	TP_printk("%s", __get_str(err))
+);
+
 /* tracepoints for fjes_main.c */
 
 TRACE_EVENT(fjes_txrx_stop_req_irq_pre,
-- 
2.6.6
