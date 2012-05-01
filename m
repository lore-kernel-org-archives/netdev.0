From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 5/8] ixgbe: add hwmon interface to export thermal data
Date: Tue,  1 May 2012 01:51:06 -0700
Message-ID: <1335862269-28914-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335862269-28914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:64126 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753979Ab2EAIvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 04:51:14 -0400
In-Reply-To: <1335862269-28914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Some of our adapters have thermal data available, this patch exports
this data via hwmon sysfs interface.  Other sysfs read-only file follow in
another patch.  Some of the functions introduced there take that into
account.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig              |    8 +
 drivers/net/ethernet/intel/ixgbe/Makefile       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |   26 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    6 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c  |  271 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |    2 +
 9 files changed, 322 insertions(+), 7 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 74215c0..546efe3 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -193,6 +193,14 @@ config IXGBE
 	  To compile this driver as a module, choose M here. The module
 	  will be called ixgbe.
 
+config IXGBE_HWMON
+	bool "Intel(R) 10GbE PCI Express adapters HWMON support"
+	default y
+	depends on IXGBE && HWMON && !(IXGBE=y && HWMON=m)
+	---help---
+	  Say Y if you want to expose the thermal sensor data on some of
+	  our cards, via a hwmon sysfs interface.
+
 config IXGBE_DCA
 	bool "Direct Cache Access (DCA) Support"
 	default y
diff --git a/drivers/net/ethernet/intel/ixgbe/Makefile b/drivers/net/ethernet/intel/ixgbe/Makefile
index 8be1d1b..0708d7e 100644
--- a/drivers/net/ethernet/intel/ixgbe/Makefile
+++ b/drivers/net/ethernet/intel/ixgbe/Makefile
@@ -34,7 +34,7 @@ obj-$(CONFIG_IXGBE) += ixgbe.o
 
 ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
               ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o ixgbe_sriov.o \
-              ixgbe_mbx.o ixgbe_x540.o ixgbe_lib.o
+              ixgbe_mbx.o ixgbe_x540.o ixgbe_sysfs.o ixgbe_lib.o
 
 ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
                               ixgbe_dcb_82599.o ixgbe_dcb_nl.o
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 8e082f2..89cebc8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -331,6 +331,26 @@ struct ixgbe_q_vector {
 	/* for dynamic allocation of rings associated with this q_vector */
 	struct ixgbe_ring ring[0] ____cacheline_internodealigned_in_smp;
 };
+#ifdef CONFIG_IXGBE_HWMON
+
+#define IXGBE_HWMON_TYPE_LOC		0
+#define IXGBE_HWMON_TYPE_TEMP		1
+#define IXGBE_HWMON_TYPE_CAUTION	2
+#define IXGBE_HWMON_TYPE_MAX		3
+
+struct hwmon_attr {
+	struct device_attribute dev_attr;
+	struct ixgbe_hw *hw;
+	struct ixgbe_thermal_diode_data *sensor;
+	char name[12];
+};
+
+struct hwmon_buff {
+	struct device *device;
+	struct hwmon_attr *hwmon_list;
+	unsigned int n_hwmon;
+};
+#endif /* CONFIG_IXGBE_HWMON */
 
 /*
  * microsecond values for various ITR rates shifted by 2 to fit itr register
@@ -535,6 +555,10 @@ struct ixgbe_adapter {
 
 	u32 timer_event_accumulator;
 	u32 vferr_refcount;
+	struct kobject *info_kobj;
+#ifdef CONFIG_IXGBE_HWMON
+	struct hwmon_buff ixgbe_hwmon_buff;
+#endif /* CONFIG_IXGBE_HWMON */
 };
 
 struct ixgbe_fdir_filter {
@@ -635,6 +659,8 @@ extern int ixgbe_setup_tc(struct net_device *dev, u8 tc);
 #endif
 extern void ixgbe_tx_ctxtdesc(struct ixgbe_ring *, u32, u32, u32, u32);
 extern void ixgbe_do_reset(struct net_device *netdev);
+extern void ixgbe_sysfs_exit(struct ixgbe_adapter *adapter);
+extern int ixgbe_sysfs_init(struct ixgbe_adapter *adapter);
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fso(struct ixgbe_ring *tx_ring,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 56fd468..6175845 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -1277,6 +1277,8 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 	.set_fw_drv_ver         = NULL,
 	.acquire_swfw_sync      = &ixgbe_acquire_swfw_sync,
 	.release_swfw_sync      = &ixgbe_release_swfw_sync,
+	.get_thermal_sensor_data = NULL,
+	.init_thermal_sensor_thresh = NULL,
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_82598 = {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 9c14685..dee64d2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -2119,6 +2119,8 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.set_vlan_anti_spoofing = &ixgbe_set_vlan_anti_spoofing,
 	.acquire_swfw_sync      = &ixgbe_acquire_swfw_sync,
 	.release_swfw_sync      = &ixgbe_release_swfw_sync,
+	.get_thermal_sensor_data = &ixgbe_get_thermal_sensor_data_generic,
+	.init_thermal_sensor_thresh = &ixgbe_init_thermal_sensor_thresh_generic,
 
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 6c6c66e..e2b0519 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3669,9 +3669,8 @@ s32 ixgbe_get_thermal_sensor_data_generic(struct ixgbe_hw *hw)
 	u8  i;
 	struct ixgbe_thermal_sensor_data *data = &hw->mac.thermal_sensor_data;
 
-	/* Only support thermal sensors attached to 82599 physical port 0 */
-	if ((hw->mac.type != ixgbe_mac_82599EB) ||
-	     (IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1)) {
+	/* Only support thermal sensors attached to physical port 0 */
+	if ((IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1)) {
 		status = IXGBE_NOT_IMPLEMENTED;
 		goto out;
 	}
@@ -3732,9 +3731,8 @@ s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw)
 
 	memset(data, 0, sizeof(struct ixgbe_thermal_sensor_data));
 
-	/* Only support thermal sensors attached to 82599 physical port 0 */
-	if ((hw->mac.type != ixgbe_mac_82599EB) ||
-	    (IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1)) {
+	/* Only support thermal sensors attached to physical port 0 */
+	if ((IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1)) {
 		status = IXGBE_NOT_IMPLEMENTED;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index aa29edb..e8897cc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7219,6 +7219,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	e_dev_info("%s\n", ixgbe_default_device_descr);
 	cards_found++;
+
+	if (ixgbe_sysfs_init(adapter))
+		e_err(probe, "failed to allocate sysfs resources\n");
+
 	return 0;
 
 err_register:
@@ -7265,6 +7269,8 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	}
 
 #endif
+	ixgbe_sysfs_exit(adapter);
+
 #ifdef IXGBE_FCOE
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
 		ixgbe_cleanup_fcoe(adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
new file mode 100644
index 0000000..aa41fb7
--- /dev/null
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -0,0 +1,271 @@
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
+#include "ixgbe.h"
+#include "ixgbe_common.h"
+#include "ixgbe_type.h"
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/sysfs.h>
+#include <linux/kobject.h>
+#include <linux/device.h>
+#include <linux/netdevice.h>
+#include <linux/hwmon.h>
+
+/*
+ * This file provides a sysfs interface to export information from the
+ * driver.  The information presented is READ-ONLY.
+ */
+#ifdef CONFIG_IXGBE_HWMON
+
+/* hwmon callback functions */
+static ssize_t ixgbe_hwmon_show_location(struct device *dev,
+					 struct device_attribute *attr,
+					 char *buf)
+{
+	struct hwmon_attr *ixgbe_attr = container_of(attr, struct hwmon_attr,
+						     dev_attr);
+	return sprintf(buf, "loc%u\n",
+		       ixgbe_attr->sensor->location);
+}
+
+static ssize_t ixgbe_hwmon_show_temp(struct device *dev,
+				     struct device_attribute *attr,
+				     char *buf)
+{
+	struct hwmon_attr *ixgbe_attr = container_of(attr, struct hwmon_attr,
+						     dev_attr);
+	unsigned int value;
+
+	/* reset the temp field */
+	ixgbe_attr->hw->mac.ops.get_thermal_sensor_data(ixgbe_attr->hw);
+
+	value = ixgbe_attr->sensor->temp;
+
+	/* display millidegree */
+	value *= 1000;
+
+	return sprintf(buf, "%u\n", value);
+}
+
+static ssize_t ixgbe_hwmon_show_cautionthresh(struct device *dev,
+				     struct device_attribute *attr,
+				     char *buf)
+{
+	struct hwmon_attr *ixgbe_attr = container_of(attr, struct hwmon_attr,
+						     dev_attr);
+	unsigned int value = ixgbe_attr->sensor->caution_thresh;
+
+	/* display millidegree */
+	value *= 1000;
+
+	return sprintf(buf, "%u\n", value);
+}
+
+static ssize_t ixgbe_hwmon_show_maxopthresh(struct device *dev,
+				     struct device_attribute *attr,
+				     char *buf)
+{
+	struct hwmon_attr *ixgbe_attr = container_of(attr, struct hwmon_attr,
+						     dev_attr);
+	unsigned int value = ixgbe_attr->sensor->max_op_thresh;
+
+	/* display millidegree */
+	value *= 1000;
+
+	return sprintf(buf, "%u\n", value);
+}
+
+/*
+ * ixgbe_add_hwmon_attr - Create hwmon attr table for a hwmon sysfs file.
+ * @ adapter: pointer to the adapter structure
+ * @ offset: offset in the eeprom sensor data table
+ * @ type: type of sensor data to display
+ *
+ * For each file we want in hwmon's sysfs interface we need a device_attribute
+ * This is included in our hwmon_attr struct that contains the references to
+ * the data structures we need to get the data to display.
+ */
+static int ixgbe_add_hwmon_attr(struct ixgbe_adapter *adapter,
+				unsigned int offset, int type) {
+	int rc;
+	unsigned int n_attr;
+	struct hwmon_attr *ixgbe_attr;
+
+	n_attr = adapter->ixgbe_hwmon_buff.n_hwmon;
+	ixgbe_attr = &adapter->ixgbe_hwmon_buff.hwmon_list[n_attr];
+
+	switch (type) {
+	case IXGBE_HWMON_TYPE_LOC:
+		ixgbe_attr->dev_attr.show = ixgbe_hwmon_show_location;
+		snprintf(ixgbe_attr->name, sizeof(ixgbe_attr->name),
+			 "temp%u_label", offset);
+		break;
+	case IXGBE_HWMON_TYPE_TEMP:
+		ixgbe_attr->dev_attr.show = ixgbe_hwmon_show_temp;
+		snprintf(ixgbe_attr->name, sizeof(ixgbe_attr->name),
+			 "temp%u_input", offset);
+		break;
+	case IXGBE_HWMON_TYPE_CAUTION:
+		ixgbe_attr->dev_attr.show = ixgbe_hwmon_show_cautionthresh;
+		snprintf(ixgbe_attr->name, sizeof(ixgbe_attr->name),
+			 "temp%u_max", offset);
+		break;
+	case IXGBE_HWMON_TYPE_MAX:
+		ixgbe_attr->dev_attr.show = ixgbe_hwmon_show_maxopthresh;
+		snprintf(ixgbe_attr->name, sizeof(ixgbe_attr->name),
+			 "temp%u_crit", offset);
+		break;
+	default:
+		rc = -EPERM;
+		return rc;
+	}
+
+	/* These always the same regardless of type */
+	ixgbe_attr->sensor =
+		&adapter->hw.mac.thermal_sensor_data.sensor[offset];
+	ixgbe_attr->hw = &adapter->hw;
+	ixgbe_attr->dev_attr.store = NULL;
+	ixgbe_attr->dev_attr.attr.mode = S_IRUGO;
+	ixgbe_attr->dev_attr.attr.name = ixgbe_attr->name;
+
+	rc = device_create_file(&adapter->pdev->dev,
+				&ixgbe_attr->dev_attr);
+
+	if (rc == 0)
+		++adapter->ixgbe_hwmon_buff.n_hwmon;
+
+	return rc;
+}
+#endif /* CONFIG_IXGBE_HWMON */
+
+static void ixgbe_sysfs_del_adapter(struct ixgbe_adapter *adapter)
+{
+#ifdef CONFIG_IXGBE_HWMON
+	int i;
+#endif /* CONFIG_IXGBE_HWMON */
+
+	if (adapter == NULL)
+		return;
+#ifdef CONFIG_IXGBE_HWMON
+
+	for (i = 0; i < adapter->ixgbe_hwmon_buff.n_hwmon; i++) {
+		device_remove_file(&adapter->pdev->dev,
+			   &adapter->ixgbe_hwmon_buff.hwmon_list[i].dev_attr);
+	}
+
+	kfree(adapter->ixgbe_hwmon_buff.hwmon_list);
+
+	if (adapter->ixgbe_hwmon_buff.device)
+		hwmon_device_unregister(adapter->ixgbe_hwmon_buff.device);
+#endif /* CONFIG_IXGBE_HWMON */
+
+	if (adapter->info_kobj != NULL)
+		kobject_put(adapter->info_kobj);
+}
+
+/* called from ixgbe_main.c */
+void ixgbe_sysfs_exit(struct ixgbe_adapter *adapter)
+{
+	ixgbe_sysfs_del_adapter(adapter);
+}
+
+/* called from ixgbe_main.c */
+int ixgbe_sysfs_init(struct ixgbe_adapter *adapter)
+{
+#ifdef CONFIG_IXGBE_HWMON
+	struct hwmon_buff *ixgbe_hwmon = &adapter->ixgbe_hwmon_buff;
+	unsigned int i;
+	int n_attrs;
+#endif /* CONFIG_IXGBE_HWMON */
+	struct net_device *netdev = adapter->netdev;
+	int rc = 0;
+
+	/* create info kobj and attribute listings in kobj */
+	adapter->info_kobj = kobject_create_and_add("info", &netdev->dev.kobj);
+	if (adapter->info_kobj == NULL) {
+		rc = -ENOMEM;
+		goto err;
+	}
+
+#ifdef CONFIG_IXGBE_HWMON
+	/* If this method isn't defined we don't support thermals */
+	if (adapter->hw.mac.ops.init_thermal_sensor_thresh == NULL) {
+		rc = -EPERM;
+		goto err;
+	}
+
+	/* Don't create thermal hwmon interface if no sensors present */
+	rc = adapter->hw.mac.ops.init_thermal_sensor_thresh(&adapter->hw);
+	if (rc)
+		goto err;
+
+	/*
+	 * Allocation space for max attributs
+	 * max num sensors * values (loc, temp, max, caution)
+	 */
+	n_attrs = IXGBE_MAX_SENSORS * 4;
+	ixgbe_hwmon->hwmon_list = kcalloc(n_attrs, sizeof(struct hwmon_attr),
+					  GFP_KERNEL);
+	if (!ixgbe_hwmon->hwmon_list) {
+		rc = -ENOMEM;
+		goto err;
+	}
+
+	ixgbe_hwmon->device = hwmon_device_register(&adapter->pdev->dev);
+	if (IS_ERR(ixgbe_hwmon->device)) {
+		rc = PTR_ERR(ixgbe_hwmon->device);
+		goto err;
+	}
+
+	for (i = 0; i < IXGBE_MAX_SENSORS; i++) {
+		/*
+		 * Only create hwmon sysfs entries for sensors that have
+		 * meaningful data for.
+		 */
+		if (adapter->hw.mac.thermal_sensor_data.sensor[i].location == 0)
+			continue;
+
+		/* Bail if any hwmon attr struct fails to initialize */
+		rc = ixgbe_add_hwmon_attr(adapter, i, IXGBE_HWMON_TYPE_CAUTION);
+		rc |= ixgbe_add_hwmon_attr(adapter, i, IXGBE_HWMON_TYPE_LOC);
+		rc |= ixgbe_add_hwmon_attr(adapter, i, IXGBE_HWMON_TYPE_TEMP);
+		rc |= ixgbe_add_hwmon_attr(adapter, i, IXGBE_HWMON_TYPE_MAX);
+		if (rc)
+			goto err;
+	}
+#endif /* CONFIG_IXGBE_HWMON */
+
+	goto exit;
+
+err:
+	ixgbe_sysfs_del_adapter(adapter);
+exit:
+	return rc;
+}
+
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 97a9914..f90ec07 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -849,6 +849,8 @@ static struct ixgbe_mac_operations mac_ops_X540 = {
 	.release_swfw_sync      = &ixgbe_release_swfw_sync_X540,
 	.disable_rx_buff	= &ixgbe_disable_rx_buff_generic,
 	.enable_rx_buff		= &ixgbe_enable_rx_buff_generic,
+	.get_thermal_sensor_data = NULL,
+	.init_thermal_sensor_thresh = NULL,
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_X540 = {
-- 
1.7.7.6
