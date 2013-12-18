From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] ixgbe: Convert to use devm_hwmon_device_register_with_groups
Date: Tue, 17 Dec 2013 22:44:39 -0800
Message-ID: <1387349082-18506-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24896 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841Ab3LRGpC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 01:45:02 -0500
In-Reply-To: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>

Simplify the code. Attach hwmon sysfs attributes to hwmon device
instead of pci device. Avoid race conditions caused by attributes
being created after hwmon device registration. Implicitly
(through hwmon API) add mandatory 'name' sysfs attribute.

Other cleanup:

Instead of allocating memory for hwmon attributes, move attributes
and all other hwmon related data into struct hwmon_buff and allocate
the entire structure using devm_kzalloc.

Check return value from calls to igb_add_hwmon_attr() one by one instead
of logically combining them all together.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  8 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c | 76 +++++++++++---------------
 2 files changed, 36 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index f38fc0a..49531cd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -552,8 +552,10 @@ struct hwmon_attr {
 };
 
 struct hwmon_buff {
-	struct device *device;
-	struct hwmon_attr *hwmon_list;
+	struct attribute_group group;
+	const struct attribute_group *groups[2];
+	struct attribute *attrs[IXGBE_MAX_SENSORS * 4 + 1];
+	struct hwmon_attr hwmon_list[IXGBE_MAX_SENSORS * 4];
 	unsigned int n_hwmon;
 };
 #endif /* CONFIG_IXGBE_HWMON */
@@ -775,7 +777,7 @@ struct ixgbe_adapter {
 	u32 vferr_refcount;
 	struct kobject *info_kobj;
 #ifdef CONFIG_IXGBE_HWMON
-	struct hwmon_buff ixgbe_hwmon_buff;
+	struct hwmon_buff *ixgbe_hwmon_buff;
 #endif /* CONFIG_IXGBE_HWMON */
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *ixgbe_dbg_adapter;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
index d118def..3081974 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -111,8 +111,8 @@ static int ixgbe_add_hwmon_attr(struct ixgbe_adapter *adapter,
 	unsigned int n_attr;
 	struct hwmon_attr *ixgbe_attr;
 
-	n_attr = adapter->ixgbe_hwmon_buff.n_hwmon;
-	ixgbe_attr = &adapter->ixgbe_hwmon_buff.hwmon_list[n_attr];
+	n_attr = adapter->ixgbe_hwmon_buff->n_hwmon;
+	ixgbe_attr = &adapter->ixgbe_hwmon_buff->hwmon_list[n_attr];
 
 	switch (type) {
 	case IXGBE_HWMON_TYPE_LOC:
@@ -147,32 +147,17 @@ static int ixgbe_add_hwmon_attr(struct ixgbe_adapter *adapter,
 	ixgbe_attr->dev_attr.store = NULL;
 	ixgbe_attr->dev_attr.attr.mode = S_IRUGO;
 	ixgbe_attr->dev_attr.attr.name = ixgbe_attr->name;
+	sysfs_attr_init(&ixgbe_attr->dev_attr.attr);
 
-	rc = device_create_file(&adapter->pdev->dev,
-				&ixgbe_attr->dev_attr);
+	adapter->ixgbe_hwmon_buff->attrs[n_attr] = &ixgbe_attr->dev_attr.attr;
 
-	if (rc == 0)
-		++adapter->ixgbe_hwmon_buff.n_hwmon;
+	++adapter->ixgbe_hwmon_buff->n_hwmon;
 
-	return rc;
+	return 0;
 }
 
 static void ixgbe_sysfs_del_adapter(struct ixgbe_adapter *adapter)
 {
-	int i;
-
-	if (adapter == NULL)
-		return;
-
-	for (i = 0; i < adapter->ixgbe_hwmon_buff.n_hwmon; i++) {
-		device_remove_file(&adapter->pdev->dev,
-			   &adapter->ixgbe_hwmon_buff.hwmon_list[i].dev_attr);
-	}
-
-	kfree(adapter->ixgbe_hwmon_buff.hwmon_list);
-
-	if (adapter->ixgbe_hwmon_buff.device)
-		hwmon_device_unregister(adapter->ixgbe_hwmon_buff.device);
 }
 
 /* called from ixgbe_main.c */
@@ -184,9 +169,9 @@ void ixgbe_sysfs_exit(struct ixgbe_adapter *adapter)
 /* called from ixgbe_main.c */
 int ixgbe_sysfs_init(struct ixgbe_adapter *adapter)
 {
-	struct hwmon_buff *ixgbe_hwmon = &adapter->ixgbe_hwmon_buff;
+	struct hwmon_buff *ixgbe_hwmon;
+	struct device *hwmon_dev;
 	unsigned int i;
-	int n_attrs;
 	int rc = 0;
 
 	/* If this method isn't defined we don't support thermals */
@@ -198,23 +183,13 @@ int ixgbe_sysfs_init(struct ixgbe_adapter *adapter)
 	if (adapter->hw.mac.ops.init_thermal_sensor_thresh(&adapter->hw))
 		goto exit;
 
-	/*
-	 * Allocation space for max attributs
-	 * max num sensors * values (loc, temp, max, caution)
-	 */
-	n_attrs = IXGBE_MAX_SENSORS * 4;
-	ixgbe_hwmon->hwmon_list = kcalloc(n_attrs, sizeof(struct hwmon_attr),
-					  GFP_KERNEL);
-	if (!ixgbe_hwmon->hwmon_list) {
+	ixgbe_hwmon = devm_kzalloc(&adapter->pdev->dev, sizeof(*ixgbe_hwmon),
+				   GFP_KERNEL);
+	if (ixgbe_hwmon == NULL) {
 		rc = -ENOMEM;
-		goto err;
-	}
-
-	ixgbe_hwmon->device = hwmon_device_register(&adapter->pdev->dev);
-	if (IS_ERR(ixgbe_hwmon->device)) {
-		rc = PTR_ERR(ixgbe_hwmon->device);
-		goto err;
+		goto exit;
 	}
+	adapter->ixgbe_hwmon_buff = ixgbe_hwmon;
 
 	for (i = 0; i < IXGBE_MAX_SENSORS; i++) {
 		/*
@@ -226,17 +201,28 @@ int ixgbe_sysfs_init(struct ixgbe_adapter *adapter)
 
 		/* Bail if any hwmon attr struct fails to initialize */
 		rc = ixgbe_add_hwmon_attr(adapter, i, IXGBE_HWMON_TYPE_CAUTION);
-		rc |= ixgbe_add_hwmon_attr(adapter, i, IXGBE_HWMON_TYPE_LOC);
-		rc |= ixgbe_add_hwmon_attr(adapter, i, IXGBE_HWMON_TYPE_TEMP);
-		rc |= ixgbe_add_hwmon_attr(adapter, i, IXGBE_HWMON_TYPE_MAX);
 		if (rc)
-			goto err;
+			goto exit;
+		rc = ixgbe_add_hwmon_attr(adapter, i, IXGBE_HWMON_TYPE_LOC);
+		if (rc)
+			goto exit;
+		rc = ixgbe_add_hwmon_attr(adapter, i, IXGBE_HWMON_TYPE_TEMP);
+		if (rc)
+			goto exit;
+		rc = ixgbe_add_hwmon_attr(adapter, i, IXGBE_HWMON_TYPE_MAX);
+		if (rc)
+			goto exit;
 	}
 
-	goto exit;
+	ixgbe_hwmon->groups[0] = &ixgbe_hwmon->group;
+	ixgbe_hwmon->group.attrs = ixgbe_hwmon->attrs;
 
-err:
-	ixgbe_sysfs_del_adapter(adapter);
+	hwmon_dev = devm_hwmon_device_register_with_groups(&adapter->pdev->dev,
+							   "ixgbe",
+							   ixgbe_hwmon,
+							   ixgbe_hwmon->groups);
+	if (IS_ERR(hwmon_dev))
+		rc = PTR_ERR(hwmon_dev);
 exit:
 	return rc;
 }
-- 
1.8.3.1
