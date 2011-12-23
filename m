From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Fri, 23 Dec 2011 01:09:16 -0800
Message-ID: <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44079 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957Ab1LWJJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 04:09:24 -0500
In-Reply-To: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Some of our adapters have thermal data available, this patch exports this
data via a read-only sysfs interface.  More patches will follow that will
contain additional information to be exported.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/Makefile      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    4 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    6 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |  305 ++++++++++++++++++++++++
 5 files changed, 318 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c

diff --git a/drivers/net/ethernet/intel/ixgbe/Makefile b/drivers/net/ethernet/intel/ixgbe/Makefile
index 7d7387f..852bf86 100644
--- a/drivers/net/ethernet/intel/ixgbe/Makefile
+++ b/drivers/net/ethernet/intel/ixgbe/Makefile
@@ -34,7 +34,7 @@ obj-$(CONFIG_IXGBE) += ixgbe.o
 
 ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
               ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o ixgbe_sriov.o \
-              ixgbe_mbx.o ixgbe_x540.o
+              ixgbe_mbx.o ixgbe_x540.o ixgbe_sysfs.o
 
 ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
                               ixgbe_dcb_82599.o ixgbe_dcb_nl.o
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index a8368d5..3531dc9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -518,6 +518,8 @@ struct ixgbe_adapter {
 	int fdir_filter_count;
 	u32 timer_event_accumulator;
 	u32 vferr_refcount;
+	struct kobject *info_kobj;
+	struct kobject *therm_kobj[IXGBE_MAX_SENSORS];
 };
 
 struct ixgbe_fdir_filter {
@@ -606,6 +608,8 @@ extern void ixgbe_set_rx_mode(struct net_device *netdev);
 extern int ixgbe_setup_tc(struct net_device *dev, u8 tc);
 extern void ixgbe_tx_ctxtdesc(struct ixgbe_ring *, u32, u32, u32, u32);
 extern void ixgbe_do_reset(struct net_device *netdev);
+extern void ixgbe_sysfs_exit(struct ixgbe_adapter *adapter);
+extern int ixgbe_sysfs_init(struct ixgbe_adapter *adapter);
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fso(struct ixgbe_ring *tx_ring, struct sk_buff *skb,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 7720721..1a3810e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -2137,6 +2137,8 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.set_vlan_anti_spoofing = &ixgbe_set_vlan_anti_spoofing,
 	.acquire_swfw_sync      = &ixgbe_acquire_swfw_sync,
 	.release_swfw_sync      = &ixgbe_release_swfw_sync,
+	.get_thermal_sensor_data = &ixgbe_get_thermal_sensor_data_generic,
+	.init_thermal_sensor_thresh = &ixgbe_init_thermal_sensor_thresh_generic,
 
 };
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e27e4d1..b5cef7e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7717,6 +7717,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	e_dev_info("Intel(R) 10 Gigabit Network Connection\n");
 	cards_found++;
+
+	if (ixgbe_sysfs_init(adapter))
+		e_err(probe, "failed to allocate sysfs resources\n");
+
 	return 0;
 
 err_register:
@@ -7764,6 +7768,8 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	}
 
 #endif
+	ixgbe_sysfs_exit(adapter);
+
 #ifdef IXGBE_FCOE
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
 		ixgbe_cleanup_fcoe(adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
new file mode 100644
index 0000000..db818ae
--- /dev/null
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -0,0 +1,305 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2011 Intel Corporation.
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
+
+/*
+ * This file provides a sysfs interface to export information from the
+ * driver.  The information presented is READ-ONLY.
+ */
+
+static struct net_device *ixgbe_get_netdev(struct kobject *kobj)
+{
+	struct net_device *netdev;
+	struct device *device_info_kobj;
+
+	if (kobj == NULL)
+		return NULL;
+
+	device_info_kobj = container_of(kobj->parent, struct device, kobj);
+	if (device_info_kobj == NULL)
+		return NULL;
+
+	netdev = container_of(device_info_kobj, struct net_device, dev);
+	return netdev;
+}
+
+static struct ixgbe_adapter *ixgbe_get_adapter(struct kobject *kobj)
+{
+	struct ixgbe_adapter *adapter;
+	struct net_device *netdev = ixgbe_get_netdev(kobj);
+
+	if (netdev == NULL)
+		return NULL;
+
+	adapter = netdev_priv(netdev);
+	return adapter;
+}
+
+static bool ixgbe_thermal_present(struct kobject *kobj)
+{
+	s32 status;
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj);
+
+	if (adapter == NULL)
+		return false;
+
+	status = ixgbe_init_thermal_sensor_thresh_generic(&(adapter->hw));
+	if (status != 0)
+		return false;
+
+	return true;
+}
+
+/*
+ * ixgbe_name_to_idx - Convert the directory name to the sensor offset.
+ * @ c: pointer to the directory name string
+ *
+ * The directory name is in the form "sensor_n" where n is '0' -
+ * 'IXGBE_MAX_SENSORS'.  IXGBE_MAX_SENSORS will never be greater than
+ * 9.  This function takes advantage of that to keep it simple.
+ */
+static int ixgbe_name_to_idx(const char *c)
+{
+	/* find first digit */
+	while (*c < '0' || *c > '9') {
+		if (*c == '\n')
+			return -1;
+		c++;
+	}
+
+	return (int)(*c - '0');
+}
+
+static s32 ixgbe_sysfs_get_thermal_data(struct kobject *kobj, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj->parent);
+	s32 status;
+
+	if (adapter == NULL) {
+		snprintf(buf, PAGE_SIZE, "error: missing adapter\n");
+		return 0;
+	}
+
+	if (&adapter->hw == NULL) {
+		snprintf(buf, PAGE_SIZE, "error: missing hw\n");
+		return 0;
+	}
+
+	status = ixgbe_get_thermal_sensor_data_generic(&adapter->hw);
+
+	return status;
+}
+
+static ssize_t ixgbe_sysfs_location(struct kobject *kobj,
+				    struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj->parent);
+	int idx;
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	idx = ixgbe_name_to_idx(kobj->name);
+	if (idx == -1)
+		return snprintf(buf, PAGE_SIZE,
+			"error: invalid sensor name %s\n", kobj->name);
+
+	return snprintf(buf, PAGE_SIZE, "%d\n",
+		adapter->hw.mac.thermal_sensor_data.sensor[idx].location);
+}
+
+static ssize_t ixgbe_sysfs_temp(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj->parent);
+	int idx;
+
+	s32 status = ixgbe_sysfs_get_thermal_data(kobj, buf);
+
+	if (status != 0)
+		return snprintf(buf, PAGE_SIZE, "error: status %d returned",
+				status);
+
+	idx = ixgbe_name_to_idx(kobj->name);
+	if (idx == -1)
+		return snprintf(buf, PAGE_SIZE,
+			"error: invalid sensor name %s\n", kobj->name);
+
+	return snprintf(buf, PAGE_SIZE, "%d\n",
+		adapter->hw.mac.thermal_sensor_data.sensor[idx].temp);
+}
+
+static ssize_t ixgbe_sysfs_maxopthresh(struct kobject *kobj,
+				       struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj->parent);
+	int idx;
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	idx = ixgbe_name_to_idx(kobj->name);
+	if (idx == -1)
+		return snprintf(buf, PAGE_SIZE,
+			"error: invalid sensor name %s\n", kobj->name);
+
+	return snprintf(buf, PAGE_SIZE, "%d\n",
+		adapter->hw.mac.thermal_sensor_data.sensor[idx].max_op_thresh);
+}
+
+static ssize_t ixgbe_sysfs_cautionthresh(struct kobject *kobj,
+					 struct kobj_attribute *attr, char *buf)
+{
+	struct ixgbe_adapter *adapter = ixgbe_get_adapter(kobj->parent);
+	int idx;
+
+	if (adapter == NULL)
+		return snprintf(buf, PAGE_SIZE, "error: no adapter\n");
+
+	idx = ixgbe_name_to_idx(kobj->name);
+	if (idx == -1)
+		return snprintf(buf, PAGE_SIZE,
+			"error: invalid sensor name %s\n", kobj->name);
+
+	return snprintf(buf, PAGE_SIZE, "%d\n",
+		adapter->hw.mac.thermal_sensor_data.sensor[idx].caution_thresh);
+}
+
+/* Initialize the attributes */
+static struct kobj_attribute ixgbe_sysfs_location_attr =
+	__ATTR(location, 0444, ixgbe_sysfs_location, NULL);
+static struct kobj_attribute ixgbe_sysfs_temp_attr =
+	__ATTR(temp, 0444, ixgbe_sysfs_temp, NULL);
+static struct kobj_attribute ixgbe_sysfs_cautionthresh_attr =
+	__ATTR(cautionthresh, 0444, ixgbe_sysfs_cautionthresh, NULL);
+static struct kobj_attribute ixgbe_sysfs_maxopthresh_attr =
+	__ATTR(maxopthresh, 0444, ixgbe_sysfs_maxopthresh, NULL);
+
+/* Add the attributes into an array, to be added to a group */
+static struct attribute *therm_attrs[] = {
+	&ixgbe_sysfs_location_attr.attr,
+	&ixgbe_sysfs_temp_attr.attr,
+	&ixgbe_sysfs_cautionthresh_attr.attr,
+	&ixgbe_sysfs_maxopthresh_attr.attr,
+	NULL
+};
+
+/* add attributes to a group */
+static struct attribute_group therm_attr_group = {
+	.attrs = therm_attrs,
+};
+
+static void ixgbe_del_adapter(struct ixgbe_adapter *adapter)
+{
+	int i;
+
+	if (adapter == NULL)
+		return;
+
+	for (i = 0; i < IXGBE_MAX_SENSORS; i++) {
+		if (adapter->therm_kobj[i] == NULL)
+			continue;
+		sysfs_remove_group(adapter->therm_kobj[i], &therm_attr_group);
+		kobject_put(adapter->therm_kobj[i]);
+	}
+	if (adapter->info_kobj != NULL)
+		kobject_put(adapter->info_kobj);
+}
+
+/* called from ixgbe_main.c */
+void ixgbe_sysfs_exit(struct ixgbe_adapter *adapter)
+{
+	ixgbe_del_adapter(adapter);
+}
+
+/* called from ixgbe_main.c */
+int ixgbe_sysfs_init(struct ixgbe_adapter *adapter)
+{
+	struct net_device *netdev;
+	int rc = 0;
+	int i;
+	char buf[16];
+
+	if (adapter == NULL)
+		goto err;
+	netdev = adapter->netdev;
+	if (netdev == NULL)
+		goto err;
+
+	adapter->info_kobj = NULL;
+	for (i = 0; i < IXGBE_MAX_SENSORS; i++)
+		adapter->therm_kobj[i] = NULL;
+
+	/* create info kobj and attribute listings in kobj */
+	adapter->info_kobj = kobject_create_and_add("info",
+					&(netdev->dev.kobj));
+	if (adapter->info_kobj == NULL)
+		goto err;
+
+	/* Don't create thermal subkobjs if no data present */
+	if (ixgbe_thermal_present(adapter->info_kobj) != true)
+		goto exit;
+
+	for (i = 0; i < IXGBE_MAX_SENSORS; i++) {
+
+		/*
+		 * Likewise only create individual kobjs that have
+		 * meaningful data.
+		 */
+		if (adapter->hw.mac.thermal_sensor_data.sensor[i].location == 0)
+			continue;
+
+		/* directory named after sensor offset */
+		snprintf(buf, sizeof(buf), "sensor_%d", i);
+		adapter->therm_kobj[i] =
+			kobject_create_and_add(buf, adapter->info_kobj);
+		if (adapter->therm_kobj[i] == NULL)
+			goto err;
+		if (sysfs_create_group(adapter->therm_kobj[i],
+				       &therm_attr_group))
+			goto err;
+	}
+
+	goto exit;
+
+err:
+	ixgbe_del_adapter(adapter);
+	rc = -1;
+exit:
+	return rc;
+}
+
-- 
1.7.7.4
