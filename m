From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax/i2400m: allow control of the base-station idle mode
	timeout
Date: Sun,  1 Mar 2009 01:42:50 -0800
Message-ID: <1235900574-15319-4-git-send-email-inaky@linux.intel.com>
References: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
	<1235900574-15319-2-git-send-email-inaky@linux.intel.com>
	<1235900574-15319-3-git-send-email-inaky@linux.intel.com>
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <1235900574-15319-3-git-send-email-inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

For power saving reasons, WiMAX links can be put in idle mode while
connected after a certain time of the link not being used for tx or
rx. In this mode, the device pages the base-station regularly and when
data is ready to be transmitted, the link is revived.

This patch allows the user to control the time the device has to be
idle before it decides to go to idle mode from a sysfs
interace.

It also updates the initialization code to acknowledge the module
variable 'idle_mode_disabled' when the firmware is a newer version
(upcoming 1.4 vs 2.6.29's v1.3).

The method for setting the idle mode timeout in the older firmwares is
much more limited and can be only done at initialization time. Thus,
the sysfs file will return -ENOSYS on older ones.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/Makefile       |    1 +
 drivers/net/wimax/i2400m/control.c      |   98 ++++++++++++++++++++++++++++---
 drivers/net/wimax/i2400m/debug-levels.h |    1 +
 drivers/net/wimax/i2400m/driver.c       |   10 +++
 drivers/net/wimax/i2400m/i2400m.h       |   29 +++++++++
 drivers/net/wimax/i2400m/sysfs.c        |   80 +++++++++++++++++++++++++
 include/linux/wimax/i2400m.h            |   10 +++
 7 files changed, 221 insertions(+), 8 deletions(-)
 create mode 100644 drivers/net/wimax/i2400m/sysfs.c

diff --git a/drivers/net/wimax/i2400m/Makefile b/drivers/net/wimax/i2400m/Makefile
index 1696e93..5d9e018 100644
--- a/drivers/net/wimax/i2400m/Makefile
+++ b/drivers/net/wimax/i2400m/Makefile
@@ -8,6 +8,7 @@ i2400m-y :=		\
 	driver.o	\
 	fw.o		\
 	op-rfkill.o	\
+	sysfs.o		\
 	netdev.o	\
 	tx.o		\
 	rx.o
diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index c8b3a68..c3968b2 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -1222,6 +1222,77 @@ EXPORT_SYMBOL_GPL(i2400m_set_init_config);
 
 
 /**
+ * i2400m_set_idle_timeout - Set the device's idle mode timeout
+ *
+ * @i2400m: i2400m device descriptor
+ *
+ * @msecs: milliseconds for the timeout to enter idle mode. Between
+ *     100 to 300000 (5m); 0 to disable. In increments of 100.
+ *
+ * After this @msecs of the link being idle (no data being sent or
+ * received), the device will negotiate with the basestation entering
+ * idle mode for saving power. The connection is maintained, but
+ * getting out of it (done in tx.c) will require some negotiation,
+ * possible crypto re-handshake and a possible DHCP re-lease.
+ *
+ * Only available if fw_version >= 0x00090002.
+ *
+ * Returns: 0 if ok, < 0 errno code on error.
+ */
+int i2400m_set_idle_timeout(struct i2400m *i2400m, unsigned msecs)
+{
+	int result;
+	struct device *dev = i2400m_dev(i2400m);
+	struct sk_buff *ack_skb;
+	struct {
+		struct i2400m_l3l4_hdr hdr;
+		struct i2400m_tlv_config_idle_timeout cit;
+	} *cmd;
+	const struct i2400m_l3l4_hdr *ack;
+	size_t ack_len;
+	char strerr[32];
+
+	result = -ENOSYS;
+	if (i2400m_le_v1_3(i2400m))
+		goto error_alloc;
+	result = -ENOMEM;
+	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
+	if (cmd == NULL)
+		goto error_alloc;
+	cmd->hdr.type = cpu_to_le16(I2400M_MT_GET_STATE);
+	cmd->hdr.length = cpu_to_le16(sizeof(*cmd) - sizeof(cmd->hdr));
+	cmd->hdr.version = cpu_to_le16(I2400M_L3L4_VERSION);
+
+	cmd->cit.hdr.type =
+		cpu_to_le16(I2400M_TLV_CONFIG_IDLE_TIMEOUT);
+	cmd->cit.hdr.length = cpu_to_le16(sizeof(cmd->cit.timeout));
+	cmd->cit.timeout = cpu_to_le32(msecs);
+
+	ack_skb = i2400m_msg_to_dev(i2400m, cmd, sizeof(*cmd));
+	if (IS_ERR(ack_skb)) {
+		dev_err(dev, "Failed to issue 'set idle timeout' command: "
+			"%ld\n", PTR_ERR(ack_skb));
+		result = PTR_ERR(ack_skb);
+		goto error_msg_to_dev;
+	}
+	ack = wimax_msg_data_len(ack_skb, &ack_len);
+	result = i2400m_msg_check_status(ack, strerr, sizeof(strerr));
+	if (result < 0) {
+		dev_err(dev, "'set idle timeout' (0x%04x) command failed: "
+			"%d - %s\n", I2400M_MT_GET_STATE, result, strerr);
+		goto error_cmd_failed;
+	}
+	result = 0;
+	kfree_skb(ack_skb);
+error_cmd_failed:
+error_msg_to_dev:
+	kfree(cmd);
+error_alloc:
+	return result;
+}
+
+
+/**
  * i2400m_dev_initialize - Initialize the device once communications are ready
  *
  * @i2400m: device descriptor
@@ -1239,19 +1310,28 @@ int i2400m_dev_initialize(struct i2400m *i2400m)
 	int result;
 	struct device *dev = i2400m_dev(i2400m);
 	struct i2400m_tlv_config_idle_parameters idle_params;
+	struct i2400m_tlv_config_idle_timeout idle_timeout;
 	const struct i2400m_tlv_hdr *args[9];
 	unsigned argc = 0;
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
-	/* Useless for now...might change */
 	if (i2400m_idle_mode_disabled) {
-		idle_params.hdr.type =
-			cpu_to_le16(I2400M_TLV_CONFIG_IDLE_PARAMETERS);
-		idle_params.hdr.length = cpu_to_le16(
-			sizeof(idle_params) - sizeof(idle_params.hdr));
-		idle_params.idle_timeout = 0;
-		idle_params.idle_paging_interval = 0;
-		args[argc++] = &idle_params.hdr;
+		if (i2400m_le_v1_3(i2400m)) {
+			idle_params.hdr.type =
+				cpu_to_le16(I2400M_TLV_CONFIG_IDLE_PARAMETERS);
+			idle_params.hdr.length = cpu_to_le16(
+				sizeof(idle_params) - sizeof(idle_params.hdr));
+			idle_params.idle_timeout = 0;
+			idle_params.idle_paging_interval = 0;
+			args[argc++] = &idle_params.hdr;
+		} else {
+			idle_timeout.hdr.type =
+				cpu_to_le16(I2400M_TLV_CONFIG_IDLE_TIMEOUT);
+			idle_timeout.hdr.length = cpu_to_le16(
+				sizeof(idle_timeout) - sizeof(idle_timeout.hdr));
+			idle_timeout.timeout = 0;
+			args[argc++] = &idle_timeout.hdr;
+		}
 	}
 	result = i2400m_set_init_config(i2400m, args, argc);
 	if (result < 0)
@@ -1264,6 +1344,8 @@ int i2400m_dev_initialize(struct i2400m *i2400m)
 	 */
 	result = i2400m_cmd_get_state(i2400m);
 error:
+	if (result < 0)
+		dev_err(dev, "failed to initialize the device: %d\n", result);
 	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
 	return result;
 }
diff --git a/drivers/net/wimax/i2400m/debug-levels.h b/drivers/net/wimax/i2400m/debug-levels.h
index 3183baa..48fbfaa 100644
--- a/drivers/net/wimax/i2400m/debug-levels.h
+++ b/drivers/net/wimax/i2400m/debug-levels.h
@@ -38,6 +38,7 @@ enum d_module {
 	D_SUBMODULE_DECLARE(netdev),
 	D_SUBMODULE_DECLARE(rfkill),
 	D_SUBMODULE_DECLARE(rx),
+	D_SUBMODULE_DECLARE(sysfs),
 	D_SUBMODULE_DECLARE(tx),
 };
 
diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 69a816e..f988771 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -662,6 +662,11 @@ int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 	wimax_state_change(wimax_dev, WIMAX_ST_UNINITIALIZED);
 
 	/* Now setup all that requires a registered net and wimax device. */
+	result = sysfs_create_group(&net_dev->dev.kobj, &i2400m_dev_attr_group);
+	if (result < 0) {
+		dev_err(dev, "cannot setup i2400m's sysfs: %d\n", result);
+		goto error_sysfs_setup;
+	}
 	result = i2400m_debugfs_add(i2400m);
 	if (result < 0) {
 		dev_err(dev, "cannot setup i2400m's debugfs: %d\n", result);
@@ -671,6 +676,9 @@ int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 	return result;
 
 error_debugfs_setup:
+	sysfs_remove_group(&i2400m->wimax_dev.net_dev->dev.kobj,
+			   &i2400m_dev_attr_group);
+error_sysfs_setup:
 	wimax_dev_rm(&i2400m->wimax_dev);
 error_wimax_dev_add:
 	i2400m_dev_stop(i2400m);
@@ -702,6 +710,8 @@ void i2400m_release(struct i2400m *i2400m)
 	netif_stop_queue(i2400m->wimax_dev.net_dev);
 
 	i2400m_debugfs_rm(i2400m);
+	sysfs_remove_group(&i2400m->wimax_dev.net_dev->dev.kobj,
+			   &i2400m_dev_attr_group);
 	wimax_dev_rm(&i2400m->wimax_dev);
 	i2400m_dev_stop(i2400m);
 	unregister_netdev(i2400m->wimax_dev.net_dev);
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 5008cdb..0c60d5c 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -585,6 +585,8 @@ unsigned i2400m_brh_get_signature(const struct i2400m_bootrom_header *hdr)
  * Driver / device setup and internal functions
  */
 extern void i2400m_netdev_setup(struct net_device *net_dev);
+extern int i2400m_sysfs_setup(struct device_driver *);
+extern void i2400m_sysfs_release(struct device_driver *);
 extern int i2400m_tx_setup(struct i2400m *);
 extern void i2400m_wake_tx_work(struct work_struct *);
 extern void i2400m_tx_release(struct i2400m *);
@@ -728,6 +730,7 @@ extern struct sk_buff *i2400m_get_device_info(struct i2400m *);
 extern int i2400m_firmware_check(struct i2400m *);
 extern int i2400m_set_init_config(struct i2400m *,
 				  const struct i2400m_tlv_hdr **, size_t);
+extern int i2400m_set_idle_timeout(struct i2400m *, unsigned);
 
 static inline
 struct usb_endpoint_descriptor *usb_get_epd(struct usb_interface *iface, int ep)
@@ -740,6 +743,32 @@ extern int i2400m_op_rfkill_sw_toggle(struct wimax_dev *,
 extern void i2400m_report_tlv_rf_switches_status(
 	struct i2400m *, const struct i2400m_tlv_rf_switches_status *);
 
+/*
+ * Helpers for firmware backwards compability
+ *
+ * As we aim to support at least the firmware version that was
+ * released with the previous kernel/driver release, some code will be
+ * conditionally executed depending on the firmware version. On each
+ * release, the code to support fw releases past the last two ones
+ * will be purged.
+ *
+ * By making it depend on this macros, it is easier to keep it a tab
+ * on what has to go and what not.
+ */
+static inline
+unsigned i2400m_le_v1_3(struct i2400m *i2400m)
+{
+	/* running fw is lower or v1.3 */
+	return i2400m->fw_version <= 0x00090001;
+}
+
+static inline
+unsigned i2400m_ge_v1_4(struct i2400m *i2400m)
+{
+	/* running fw is higher or v1.4 */
+	return i2400m->fw_version >= 0x00090002;
+}
+
 
 /*
  * Do a millisecond-sleep for allowing wireshark to dump all the data
diff --git a/drivers/net/wimax/i2400m/sysfs.c b/drivers/net/wimax/i2400m/sysfs.c
new file mode 100644
index 0000000..1237109
--- /dev/null
+++ b/drivers/net/wimax/i2400m/sysfs.c
@@ -0,0 +1,80 @@
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
+
+/*
+ * Set the idle timeout (msecs)
+ *
+ * FIXME: eventually this should be a common WiMAX stack method, but
+ * would like to wait to see how other devices manage it.
+ */
+static
+ssize_t i2400m_idle_timeout_store(struct device *dev,
+				  struct device_attribute *attr,
+				  const char *buf, size_t size)
+{
+	ssize_t result;
+	struct i2400m *i2400m = net_dev_to_i2400m(to_net_dev(dev));
+	unsigned val;
+
+	result = -EINVAL;
+	if (sscanf(buf, "%u\n", &val) != 1)
+		goto error_no_unsigned;
+	if (val != 0 && (val < 100 || val > 300000 || val % 100 != 0)) {
+		dev_err(dev, "idle_timeout: %u: invalid msecs specification; "
+			"valid values are 0, 100-300000 in 100 increments\n",
+			val);
+		goto error_bad_value;
+	}
+	result = i2400m_set_idle_timeout(i2400m, val);
+	if (result >= 0)
+		result = size;
+error_no_unsigned:
+error_bad_value:
+	return result;
+}
+
+static
+DEVICE_ATTR(i2400m_idle_timeout, S_IWUSR,
+	    NULL, i2400m_idle_timeout_store);
+
+static
+struct attribute *i2400m_dev_attrs[] = {
+	&dev_attr_i2400m_idle_timeout.attr,
+	NULL,
+};
+
+struct attribute_group i2400m_dev_attr_group = {
+	.name = NULL,		/* we want them in the same directory */
+	.attrs = i2400m_dev_attrs,
+};
diff --git a/include/linux/wimax/i2400m.h b/include/linux/wimax/i2400m.h
index 74198f5..686eeb2 100644
--- a/include/linux/wimax/i2400m.h
+++ b/include/linux/wimax/i2400m.h
@@ -381,6 +381,7 @@ enum i2400m_tlv {
 	I2400M_TLV_RF_STATUS = 163,
 	I2400M_TLV_DEVICE_RESET_TYPE = 132,
 	I2400M_TLV_CONFIG_IDLE_PARAMETERS = 601,
+	I2400M_TLV_CONFIG_IDLE_TIMEOUT = 611,
 };
 
 
@@ -509,4 +510,13 @@ struct i2400m_tlv_media_status {
 	__le32 media_status;
 } __attribute__((packed));
 
+
+/* New in v1.4 */
+struct i2400m_tlv_config_idle_timeout {
+	struct i2400m_tlv_hdr hdr;
+	__le32 timeout;	/* 100 to 300000 ms [5min], 100 increments
+			 * 0 disabled */
+} __attribute__((packed));
+
+
 #endif /* #ifndef __LINUX__WIMAX__I2400M_H__ */
-- 
1.5.6.5
