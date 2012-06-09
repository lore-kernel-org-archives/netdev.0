From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] igb: Add hwmon interface to export thermal data.
Date: Sat,  9 Jun 2012 01:20:56 -0700
Message-ID: <1339230063-12545-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16442 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968Ab2FIIVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 04:21:08 -0400
In-Reply-To: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Some of our adapters have thermal data available, this patch exports
this data via hwmon sysfs interface.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig           |   10 ++
 drivers/net/ethernet/intel/igb/Makefile      |    2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c |    4 +
 drivers/net/ethernet/intel/igb/e1000_hw.h    |    5 +-
 drivers/net/ethernet/intel/igb/igb.h         |   29 +++
 drivers/net/ethernet/intel/igb/igb_main.c    |   25 +++
 drivers/net/ethernet/intel/igb/igb_sysfs.c   |  245 ++++++++++++++++++++++++++
 7 files changed, 318 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_sysfs.c

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 79b07ec..fdb9280 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -111,6 +111,16 @@ config IGB
 	  To compile this driver as a module, choose M here. The module
 	  will be called igb.
 
+config IGB_HWMON
+	bool "Intel(R) PCI-Express Gigabit adapters HWMON support"
+	default y
+	depends on IGB && HWMON && !(IGB=y && HWMON=m)
+	---help---
+	  Say Y if you want to expose thermal sensor data on Intel devices.
+
+	  Some of our devices contain thermal sensors, both external and internal.
+	  This data is available via the hwmon sysfs interface.
+
 config IGB_DCA
 	bool "Direct Cache Access (DCA) Support"
 	default y
diff --git a/drivers/net/ethernet/intel/igb/Makefile b/drivers/net/ethernet/intel/igb/Makefile
index 97c197f..346c3de 100644
--- a/drivers/net/ethernet/intel/igb/Makefile
+++ b/drivers/net/ethernet/intel/igb/Makefile
@@ -34,6 +34,6 @@ obj-$(CONFIG_IGB) += igb.o
 
 igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
 	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o \
-	    e1000_i210.o
+	    e1000_i210.o igb_sysfs.o
 
 igb-$(CONFIG_IGB_PTP) += igb_ptp.o
diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 9623833..cd9e3e0 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -2916,6 +2916,10 @@ static struct e1000_mac_operations e1000_mac_ops_82575 = {
 	.rar_set              = igb_rar_set,
 	.read_mac_addr        = igb_read_mac_addr_82575,
 	.get_speed_and_duplex = igb_get_speed_and_duplex_copper,
+#ifdef CONFIG_IGB_HWMON
+	.get_thermal_sensor_data = igb_get_thermal_sensor_data_generic,
+	.init_thermal_sensor_thresh = igb_init_thermal_sensor_thresh_generic,
+#endif
 };
 
 static struct e1000_phy_operations e1000_phy_ops_82575 = {
diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index 837a274..6dddbc6 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -325,7 +325,10 @@ struct e1000_mac_operations {
 	s32  (*get_speed_and_duplex)(struct e1000_hw *, u16 *, u16 *);
 	s32  (*acquire_swfw_sync)(struct e1000_hw *, u16);
 	void (*release_swfw_sync)(struct e1000_hw *, u16);
-
+#ifdef CONFIG_IGB_HWMON
+	s32 (*get_thermal_sensor_data)(struct e1000_hw *);
+	s32 (*init_thermal_sensor_thresh)(struct e1000_hw *);
+#endif
 };
 
 struct e1000_phy_operations {
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index ae6d3f3..4bf856f 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -281,6 +281,27 @@ static inline int igb_desc_unused(struct igb_ring *ring)
 	return ring->count + ring->next_to_clean - ring->next_to_use - 1;
 }
 
+#ifdef CONFIG_IGB_HWMON
+
+#define IGB_HWMON_TYPE_LOC	0
+#define IGB_HWMON_TYPE_TEMP	1
+#define IGB_HWMON_TYPE_CAUTION	2
+#define IGB_HWMON_TYPE_MAX	3
+
+struct hwmon_attr {
+	struct device_attribute dev_attr;
+	struct e1000_hw *hw;
+	struct e1000_thermal_diode_data *sensor;
+	char name[12];
+	};
+
+struct hwmon_buff {
+	struct device *device;
+	struct hwmon_attr *hwmon_list;
+	unsigned int n_hwmon;
+	};
+#endif /* CONFIG_IGB_HWMON */
+
 /* board specific private data structure */
 struct igb_adapter {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
@@ -371,6 +392,10 @@ struct igb_adapter {
 	spinlock_t tmreg_lock;
 	struct cyclecounter cc;
 	struct timecounter tc;
+#ifdef CONFIG_IGB_HWMON
+	struct hwmon_buff igb_hwmon_buff;
+	bool ets;
+#endif /* CONFIG_IGB_HWMON */
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
@@ -429,6 +454,10 @@ extern void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
 				   u64 systim);
 
 #endif
+#ifdef CONFIG_IGB_HWMON
+extern void igb_sysfs_exit(struct igb_adapter *adapter);
+extern int igb_sysfs_init(struct igb_adapter *adapter);
+#endif
 static inline s32 igb_reset_phy(struct e1000_hw *hw)
 {
 	if (hw->phy.ops.reset)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index dd3bfe8..e94a99b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2119,6 +2119,27 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	}
 
 #endif
+#ifdef CONFIG_IGB_HWMON
+	/* Initialize the thermal sensor on i350 devices. */
+	if (hw->mac.type == e1000_i350 && hw->bus.func == 0) {
+		u16 ets_word;
+
+		/*
+		 * Read the NVM to determine if this i350 device supports an
+		 * external thermal sensor.
+		 */
+		hw->nvm.ops.read(hw, NVM_ETS_CFG, 1, &ets_word);
+		if (ets_word != 0x0000 && ets_word != 0xFFFF)
+			adapter->ets = true;
+		else
+			adapter->ets = false;
+		if (igb_sysfs_init(adapter))
+			dev_err(&pdev->dev,
+				"failed to allocate sysfs resources\n");
+	} else {
+		adapter->ets = false;
+	}
+#endif /* CONFIG_IGB_HWMON */
 #ifdef CONFIG_IGB_PTP
 	/* do hw tstamp init after resetting */
 	igb_ptp_init(adapter);
@@ -2201,6 +2222,10 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	igb_ptp_remove(adapter);
 
 #endif
+#ifdef CONFIG_IGB_HWMON
+	igb_sysfs_exit(adapter);
+
+#endif /* CONFIG_IGB_HWMON */
 	/*
 	 * The watchdog timer may be rescheduled, so explicitly
 	 * disable watchdog from being rescheduled.
diff --git a/drivers/net/ethernet/intel/igb/igb_sysfs.c b/drivers/net/ethernet/intel/igb/igb_sysfs.c
new file mode 100644
index 0000000..10ffcf7
--- /dev/null
+++ b/drivers/net/ethernet/intel/igb/igb_sysfs.c
@@ -0,0 +1,245 @@
+/*******************************************************************************
+
+  Intel(R) Gigabit Ethernet Linux driver
+  Copyright(c) 2007-2012 Intel Corporation.
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
+#include "igb.h"
+#include "e1000_82575.h"
+#include "e1000_hw.h"
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/sysfs.h>
+#include <linux/kobject.h>
+#include <linux/device.h>
+#include <linux/netdevice.h>
+#include <linux/hwmon.h>
+#include <linux/pci.h>
+
+#ifdef CONFIG_IGB_HWMON
+/* hwmon callback functions */
+static ssize_t igb_hwmon_show_location(struct device *dev,
+					 struct device_attribute *attr,
+					 char *buf)
+{
+	struct hwmon_attr *igb_attr = container_of(attr, struct hwmon_attr,
+						     dev_attr);
+	return sprintf(buf, "loc%u\n",
+		       igb_attr->sensor->location);
+}
+
+static ssize_t igb_hwmon_show_temp(struct device *dev,
+				     struct device_attribute *attr,
+				     char *buf)
+{
+	struct hwmon_attr *igb_attr = container_of(attr, struct hwmon_attr,
+						     dev_attr);
+	unsigned int value;
+
+	/* reset the temp field */
+	igb_attr->hw->mac.ops.get_thermal_sensor_data(igb_attr->hw);
+
+	value = igb_attr->sensor->temp;
+
+	/* display millidegree */
+	value *= 1000;
+
+	return sprintf(buf, "%u\n", value);
+}
+
+static ssize_t igb_hwmon_show_cautionthresh(struct device *dev,
+				     struct device_attribute *attr,
+				     char *buf)
+{
+	struct hwmon_attr *igb_attr = container_of(attr, struct hwmon_attr,
+						     dev_attr);
+	unsigned int value = igb_attr->sensor->caution_thresh;
+
+	/* display millidegree */
+	value *= 1000;
+
+	return sprintf(buf, "%u\n", value);
+}
+
+static ssize_t igb_hwmon_show_maxopthresh(struct device *dev,
+				     struct device_attribute *attr,
+				     char *buf)
+{
+	struct hwmon_attr *igb_attr = container_of(attr, struct hwmon_attr,
+						     dev_attr);
+	unsigned int value = igb_attr->sensor->max_op_thresh;
+
+	/* display millidegree */
+	value *= 1000;
+
+	return sprintf(buf, "%u\n", value);
+}
+
+/*
+ * igb_add_hwmon_attr - Create hwmon attr table for a hwmon sysfs file.
+ * @ adapter: pointer to the adapter structure
+ * @ offset: offset in the eeprom sensor data table
+ * @ type: type of sensor data to display
+ *
+ * For each file we want in hwmon's sysfs interface we need a device_attribute
+ * This is included in our hwmon_attr struct that contains the references to
+ * the data structures we need to get the data to display.
+ */
+static int igb_add_hwmon_attr(struct igb_adapter *adapter,
+				unsigned int offset, int type) {
+	int rc;
+	unsigned int n_attr;
+	struct hwmon_attr *igb_attr;
+
+	n_attr = adapter->igb_hwmon_buff.n_hwmon;
+	igb_attr = &adapter->igb_hwmon_buff.hwmon_list[n_attr];
+
+	switch (type) {
+	case IGB_HWMON_TYPE_LOC:
+		igb_attr->dev_attr.show = igb_hwmon_show_location;
+		snprintf(igb_attr->name, sizeof(igb_attr->name),
+			 "temp%u_label", offset);
+		break;
+	case IGB_HWMON_TYPE_TEMP:
+		igb_attr->dev_attr.show = igb_hwmon_show_temp;
+		snprintf(igb_attr->name, sizeof(igb_attr->name),
+			 "temp%u_input", offset);
+		break;
+	case IGB_HWMON_TYPE_CAUTION:
+		igb_attr->dev_attr.show = igb_hwmon_show_cautionthresh;
+		snprintf(igb_attr->name, sizeof(igb_attr->name),
+			 "temp%u_max", offset);
+		break;
+	case IGB_HWMON_TYPE_MAX:
+		igb_attr->dev_attr.show = igb_hwmon_show_maxopthresh;
+		snprintf(igb_attr->name, sizeof(igb_attr->name),
+			 "temp%u_crit", offset);
+		break;
+	default:
+		rc = -EPERM;
+		return rc;
+	}
+
+	/* These always the same regardless of type */
+	igb_attr->sensor =
+		&adapter->hw.mac.thermal_sensor_data.sensor[offset];
+	igb_attr->hw = &adapter->hw;
+	igb_attr->dev_attr.store = NULL;
+	igb_attr->dev_attr.attr.mode = S_IRUGO;
+	igb_attr->dev_attr.attr.name = igb_attr->name;
+
+	rc = device_create_file(&adapter->pdev->dev,
+				&igb_attr->dev_attr);
+
+	if (rc == 0)
+		++adapter->igb_hwmon_buff.n_hwmon;
+
+	return rc;
+}
+
+static void igb_sysfs_del_adapter(struct igb_adapter *adapter)
+{
+	int i;
+
+	if (adapter == NULL)
+		return;
+
+	for (i = 0; i < adapter->igb_hwmon_buff.n_hwmon; i++) {
+		device_remove_file(&adapter->pdev->dev,
+			   &adapter->igb_hwmon_buff.hwmon_list[i].dev_attr);
+	}
+
+	kfree(adapter->igb_hwmon_buff.hwmon_list);
+
+	if (adapter->igb_hwmon_buff.device)
+		hwmon_device_unregister(adapter->igb_hwmon_buff.device);
+}
+
+/* called from igb_main.c */
+void igb_sysfs_exit(struct igb_adapter *adapter)
+{
+	igb_sysfs_del_adapter(adapter);
+}
+
+/* called from igb_main.c */
+int igb_sysfs_init(struct igb_adapter *adapter)
+{
+	struct hwmon_buff *igb_hwmon = &adapter->igb_hwmon_buff;
+	unsigned int i;
+	int n_attrs;
+	int rc = 0;
+
+	/* If this method isn't defined we don't support thermals */
+	if (adapter->hw.mac.ops.init_thermal_sensor_thresh == NULL)
+		goto exit;
+
+	/* Don't create thermal hwmon interface if no sensors present */
+	rc = (adapter->hw.mac.ops.init_thermal_sensor_thresh(&adapter->hw));
+		if (rc)
+			goto exit;
+
+	/*
+	 * Allocation space for max attributs
+	 * max num sensors * values (loc, temp, max, caution)
+	 */
+	n_attrs = E1000_MAX_SENSORS * 4;
+	igb_hwmon->hwmon_list = kcalloc(n_attrs, sizeof(struct hwmon_attr),
+					  GFP_KERNEL);
+	if (!igb_hwmon->hwmon_list) {
+		rc = -ENOMEM;
+		goto err;
+	}
+
+	igb_hwmon->device = hwmon_device_register(&adapter->pdev->dev);
+	if (IS_ERR(igb_hwmon->device)) {
+		rc = PTR_ERR(igb_hwmon->device);
+		goto err;
+	}
+
+	for (i = 0; i < E1000_MAX_SENSORS; i++) {
+		/*
+		 * Only create hwmon sysfs entries for sensors that have
+		 * meaningful data for.
+		 */
+		if (adapter->hw.mac.thermal_sensor_data.sensor[i].location == 0)
+			continue;
+
+		/* Bail if any hwmon attr struct fails to initialize */
+		rc = igb_add_hwmon_attr(adapter, i, IGB_HWMON_TYPE_CAUTION);
+		rc |= igb_add_hwmon_attr(adapter, i, IGB_HWMON_TYPE_LOC);
+		rc |= igb_add_hwmon_attr(adapter, i, IGB_HWMON_TYPE_TEMP);
+		rc |= igb_add_hwmon_attr(adapter, i, IGB_HWMON_TYPE_MAX);
+		if (rc)
+			goto err;
+	}
+
+	goto exit;
+
+err:
+	igb_sysfs_del_adapter(adapter);
+exit:
+	return rc;
+}
+#endif /* CONFIG_IGB_HWMON */
-- 
1.7.10.2
