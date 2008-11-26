From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 19/39] i2400m: sysfs controls
Date: Wed, 26 Nov 2008 14:40:38 -0800
Message-ID: <8393b57d107460e5b17e0329751fde2b46ccfb62.1227691434.git.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:45655 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752750AbYKZWlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 17:41:20 -0500
In-Reply-To: <cover.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expose knobs to control the device (induce reset, power saving,
querying tx or rx stats, internal debug information and debug level
manipulation).

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sysfs.c |  458 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 458 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wimax/i2400m/sysfs.c

diff --git a/drivers/net/wimax/i2400m/sysfs.c b/drivers/net/wimax/i2400m/sysfs.c
new file mode 100644
index 0000000..3640719
--- /dev/null
+++ b/drivers/net/wimax/i2400m/sysfs.c
@@ -0,0 +1,458 @@
+/*
+ * Intel Wireless WiMAX Connection 2400m
+ * Sysfs interfaces to show driver and device information
+ *
+ *
+ * Copyright (C) 2007 Intel Corporation <linux-wimax@intel.com>
+ * Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/spinlock.h>
+#include <linux/device.h>
+#include "i2400m.h"
+
+
+#define D_SUBMODULE sysfs
+#include "debug-levels.h"
+
+/*
+ * Cold reset the device (deferred work routine)
+ *
+ * Need to use a workstruct because when done from sysfs, the device
+ * lock is taken, so after a reset, the new device "instance" is
+ * connected before we have a chance to disconnect the current
+ * instance. This creates problems for upper layers, as for example
+ * the management daemon for a while could think we have two wimax
+ * connections in the system.
+ *
+ * Note calling _put before _reset_cold is ok because _put uses
+ * netdev's dev_put(), which won't free anything.
+ *
+ * In any case, it has to be before, as if not we enter a race
+ * coindition calling reset_cold(); it would try to unregister the
+ * device, but it will keep the reference count and because reset had
+ * a device lock...well, big mess.
+ */
+static
+void __i2400m_reset_cold_work(struct work_struct *ws)
+{
+	struct i2400m_work *iw =
+		container_of(ws, struct i2400m_work, ws);
+	i2400m_put(iw->i2400m);
+	iw->i2400m->bus_reset(iw->i2400m, I2400M_RT_COLD);
+	kfree(iw);
+}
+
+static
+ssize_t i2400m_reset_cold_store(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t size)
+{
+	ssize_t result;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+	unsigned val;
+
+	result = -EINVAL;
+	if (sscanf(buf, "%u\n", &val) != 1)
+		goto error_no_unsigned;
+	if (val != 1)
+		goto error_bad_value;
+	i2400m_schedule_work(i2400m, __i2400m_reset_cold_work, GFP_KERNEL);
+	if (result >= 1)
+		result = size;
+error_no_unsigned:
+error_bad_value:
+	return result;
+}
+
+static
+DEVICE_ATTR(i2400m_reset_cold, S_IRUGO | S_IWUSR,
+	    NULL, i2400m_reset_cold_store);
+
+
+/*
+ * Warm reset the device
+ *
+ * We just warm reset the device; no need to defer, as the device will
+ * not disconnect.
+ */
+static
+ssize_t i2400m_reset_warm_store(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t size)
+{
+	ssize_t result;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+	unsigned val;
+
+	result = -EINVAL;
+	if (sscanf(buf, "%u\n", &val) != 1)
+		goto error_no_unsigned;
+	if (val != 1)
+		goto error_bad_value;
+	result = i2400m->bus_reset(i2400m, I2400M_RT_WARM);
+	if (result >= 0)
+		result = size;
+error_no_unsigned:
+error_bad_value:
+	return result;
+}
+
+static
+DEVICE_ATTR(i2400m_reset_warm, S_IRUGO | S_IWUSR,
+	    NULL, i2400m_reset_warm_store);
+
+
+/*
+ * Show RX statistics
+ *
+ * Total #payloads | min #payloads in a RX | max #payloads in a RX
+ * Total #RXs | Total bytes | min #bytes in a RX | max #bytes in a RX
+ *
+ * Write 1 to clear.
+ */
+static
+ssize_t i2400m_rx_stats_show(struct device *dev,
+			     struct device_attribute *attr,
+			     char *buf)
+{
+	ssize_t result;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+	unsigned long flags;
+
+	spin_lock_irqsave(&i2400m->rx_lock, flags);
+	result = snprintf(buf, PAGE_SIZE, "%u %u %u %u %u %u %u\n",
+			  i2400m->rx_pl_num, i2400m->rx_pl_min,
+			  i2400m->rx_pl_max, i2400m->rx_num,
+			  i2400m->rx_size_acc,
+			  i2400m->rx_size_min, i2400m->rx_size_max);
+	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
+	return result;
+}
+
+static
+ssize_t i2400m_rx_stats_store(struct device *dev,
+			      struct device_attribute *attr,
+			      const char *buf, size_t size)
+{
+	ssize_t result;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+	unsigned val;
+	unsigned long flags;
+
+	result = -EINVAL;
+	if (sscanf(buf, "%u\n", &val) != 1)
+		goto error_no_unsigned;
+	if (val != 1)
+		goto error_bad_value;
+	spin_lock_irqsave(&i2400m->rx_lock, flags);
+	i2400m->rx_pl_num = 0;
+	i2400m->rx_pl_max = 0;
+	i2400m->rx_pl_min = UINT_MAX;
+	i2400m->rx_num = 0;
+	i2400m->rx_size_acc = 0;
+	i2400m->rx_size_min = UINT_MAX;
+	i2400m->rx_size_max = 0;
+	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
+	result = size;
+error_no_unsigned:
+error_bad_value:
+	return result;
+}
+
+static
+DEVICE_ATTR(i2400m_rx_stats, S_IRUGO | S_IWUSR,
+	    i2400m_rx_stats_show, i2400m_rx_stats_store);
+
+
+/*
+ * Show TX statistics
+ *
+ * Total #payloads | min #payloads in a TX | max #payloads in a TX
+ * Total #TXs | Total bytes | min #bytes in a TX | max #bytes in a TX
+ *
+ * Write 1 to clear.
+ */
+static
+ssize_t i2400m_tx_stats_show(struct device *dev,
+			     struct device_attribute *attr,
+			     char *buf)
+{
+	ssize_t result;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+	unsigned long flags;
+
+	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	result = snprintf(buf, PAGE_SIZE, "%u %u %u %u %u %u %u\n",
+			  i2400m->tx_pl_num, i2400m->tx_pl_min,
+			  i2400m->tx_pl_max, i2400m->tx_num,
+			  i2400m->tx_size_acc,
+			  i2400m->tx_size_min, i2400m->tx_size_max);
+	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
+	return result;
+}
+
+static
+ssize_t i2400m_tx_stats_store(struct device *dev,
+			      struct device_attribute *attr,
+			      const char *buf, size_t size)
+{
+	ssize_t result;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+	unsigned val;
+	unsigned long flags;
+
+	result = -EINVAL;
+	if (sscanf(buf, "%u\n", &val) != 1)
+		goto error_no_unsigned;
+	if (val != 1)
+		goto error_bad_value;
+	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	i2400m->tx_pl_num = 0;
+	i2400m->tx_pl_max = 0;
+	i2400m->tx_pl_min = UINT_MAX;
+	i2400m->tx_num = 0;
+	i2400m->tx_size_acc = 0;
+	i2400m->tx_size_min = UINT_MAX;
+	i2400m->tx_size_max = 0;
+	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
+	result = size;
+error_no_unsigned:
+error_bad_value:
+	return result;
+}
+
+static
+DEVICE_ATTR(i2400m_tx_stats, S_IRUGO | S_IWUSR,
+	    i2400m_tx_stats_show, i2400m_tx_stats_store);
+
+/*
+ * Show debug stuff
+ *
+ * Don't poke with this unless you know what you are doing.
+ */
+static
+ssize_t i2400m_debug_store(struct device *dev,
+			   struct device_attribute *attr,
+			   const char *buf, size_t size)
+{
+	ssize_t result = 0;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+	char var[256], val[256];
+
+	result = -EINVAL;
+	if (sscanf(buf, "%254s %254s\n", var, val) != 2) {
+		dev_err(dev, "debug: bad format, expected VARIABLE VALUE\n");
+		goto error;
+	}
+
+	if (!strcmp(var, "state")) {
+		enum i2400m_system_state state;
+		if (sscanf(val, "%u", &state) != 1) {
+			dev_err(dev, "debug/state: can't parse unsigned %s\n",
+				val);
+			goto error;
+		}
+		if (state < I2400M_SS_UNINITIALIZED || state >= I2400M_SS_MAX) {
+			dev_err(dev, "debug/state: %u is out of range\n",
+				state);
+			goto error;
+		}
+		i2400m->state = state;
+		result = size;
+	} else
+		dev_err(dev, "debug: unknown variable %s\n", var);
+error:
+	return result;
+}
+
+/*
+ * Show debug stuff
+ */
+static
+ssize_t i2400m_debug_show(struct device *dev,
+			  struct device_attribute *attr,
+			  char *buf)
+{
+	ssize_t result = 0;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+	unsigned long flags;
+
+	result += scnprintf(
+		buf, PAGE_SIZE,
+		"Don't poke with this unless you know what you are doing. \n"
+		"It provides means to modify internal settings in the \n"
+		"driver that can be used to exercise error paths.\n"
+		"\n"
+		"Format for setting them is 'echo FIELD VALUE' (fields \n"
+		"marked ! can't be set)\n"
+		"\n");
+
+	result += scnprintf(buf + result, PAGE_SIZE - result,
+			    "!queue: %s\n",
+			    netif_queue_stopped(to_net_dev(dev)) ?
+			    "stopped" : "running");
+
+	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	result += scnprintf(
+		buf + result, PAGE_SIZE - result,
+		"!TX FIFO in: %zu\n"
+		"!TX FIFO out: %zu (%zu used)\n"
+		"!TX FIFO msg: @%zd\n",
+		i2400m->tx_in, i2400m->tx_out,
+		i2400m->tx_out - i2400m->tx_in,
+		(size_t) (i2400m->tx_msg ?
+			  (void *) i2400m->tx_msg - i2400m->tx_buf : -1));
+	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
+
+	result += scnprintf(
+		buf + result, PAGE_SIZE - result,
+		"state: %u\n", i2400m->state);
+	return result;
+}
+static
+DEVICE_ATTR(i2400m_debug, S_IRUGO | S_IWUSR,
+	    i2400m_debug_show, i2400m_debug_store);
+
+
+/*
+ * Trace received messages from user space
+ *
+ * In order to tap the bidirectional message stream in the 'msg' pipe,
+ * user space can read from the 'msg' pipe; however, due to
+ * limitations in libnl, we can't know what the different applications
+ * are sending down to the kernel.
+ *
+ * So we have this hack where the driver will echo any message
+ * received on the msg pipe from user space [through a call to
+ * wimax_dev->op_msg_from_user() into i2400m_op_msg_from_user()] into
+ * the 'trace' pipe that this driver creates.
+ *
+ * So then, reading from both the 'trace' and 'msg' pipes in user spce
+ * will provide a full dump of the traffic.
+ *
+ * Write 1 to activate, 0 to clear.
+ *
+ * It is not really very atomic, but it is also not too critical.
+ */
+static
+ssize_t i2400m_trace_msg_from_user_show(struct device *dev,
+					struct device_attribute *attr,
+					char *buf)
+{
+	ssize_t result;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+
+	result = snprintf(buf, PAGE_SIZE, "%u\n",
+			  i2400m->trace_msg_from_user);
+	return result;
+}
+
+static
+ssize_t i2400m_trace_msg_from_user_store(struct device *dev,
+					 struct device_attribute *attr,
+					 const char *buf, size_t size)
+{
+	ssize_t result;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+	unsigned val;
+
+	result = -EINVAL;
+	if (sscanf(buf, "%u\n", &val) == 1) {
+		i2400m->trace_msg_from_user = val ? 1 : 0;
+		result = size;
+	}
+	return result;
+}
+
+static
+DEVICE_ATTR(i2400m_trace_msg_from_user, S_IRUGO | S_IWUSR,
+	    i2400m_trace_msg_from_user_show, i2400m_trace_msg_from_user_store);
+
+
+/*
+ * Ask the device to enter power saving mode.
+ *
+ * This is not really selective suspend mode, but asking the device to
+ * enter selective suspend on its own.
+ */
+static
+ssize_t i2400m_suspend_store(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t size)
+{
+	ssize_t result;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+	unsigned val;
+
+	result = -EINVAL;
+	if (sscanf(buf, "%u\n", &val) != 1)
+		goto error_no_unsigned;
+	if (val != 1)
+		goto error_bad_value;
+	result = i2400m_cmd_enter_powersave(i2400m);
+	if (result >= 0)
+		result = size;
+error_no_unsigned:
+error_bad_value:
+	return result;
+}
+
+static
+DEVICE_ATTR(i2400m_suspend, S_IRUGO | S_IWUSR,
+	    NULL, i2400m_suspend_store);
+
+
+/*
+ * Debug levels control; see debug.h
+ */
+struct d_level D_LEVEL[] = {
+	D_SUBMODULE_DEFINE(control),
+	D_SUBMODULE_DEFINE(driver),
+	D_SUBMODULE_DEFINE(fw),
+	D_SUBMODULE_DEFINE(netdev),
+	D_SUBMODULE_DEFINE(rfkill),
+	D_SUBMODULE_DEFINE(rx),
+	D_SUBMODULE_DEFINE(sysfs),
+	D_SUBMODULE_DEFINE(tx),
+};
+size_t D_LEVEL_SIZE = ARRAY_SIZE(D_LEVEL);
+
+static
+DEVICE_ATTR(i2400m_debug_levels, S_IRUGO | S_IWUSR,
+	    d_level_show, d_level_store);
+
+
+static
+struct attribute *i2400m_dev_attrs[] = {
+	&dev_attr_i2400m_reset_cold.attr,
+	&dev_attr_i2400m_reset_warm.attr,
+	&dev_attr_i2400m_suspend.attr,
+	&dev_attr_i2400m_rx_stats.attr,
+	&dev_attr_i2400m_tx_stats.attr,
+	&dev_attr_i2400m_debug.attr,
+	&dev_attr_i2400m_debug_levels.attr,
+	&dev_attr_i2400m_trace_msg_from_user.attr,
+	NULL,
+};
+
+struct attribute_group i2400m_dev_attr_group = {
+	.name = NULL,		/* we want them in the same directory */
+	.attrs = i2400m_dev_attrs,
+};
-- 
1.5.6.5

