From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 2/5] igb: Convert to use devm_hwmon_device_register_with_groups
Date: Fri, 22 Nov 2013 22:07:58 -0800
Message-ID: <1385186881-7931-3-git-send-email-linux@roeck-us.net>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	e1000-devel@lists.sourceforge.net, lm-sensors@lm-sensors.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:54039 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab3KWGIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 01:08:18 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so2248737pdj.30
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 22:08:17 -0800 (PST)
In-Reply-To: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify the code. Attach hwmon sysfs attributes to hwmon device
instead of pci device. Avoid race conditions caused by attributes
being created after registration and provide mandatory 'name'
attribute by using new hwmon API.

Other cleanup:

Instead of allocating memory for hwmon attributes, move attributes
and all other hwmon related data into struct hwmon_buff and allocate
the entire structure using devm_kzalloc.

Check return value from calls to igb_add_hwmon_attr() one by one instead
of logically combining them all together.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/intel/igb/igb.h       |    8 ++-
 drivers/net/ethernet/intel/igb/igb_hwmon.c |  100 +++++++++++++---------------
 2 files changed, 53 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 5e9ed89..99c3d33 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -337,8 +337,10 @@ struct hwmon_attr {
 	};
 
 struct hwmon_buff {
-	struct device *device;
-	struct hwmon_attr *hwmon_list;
+	struct attribute_group group;
+	const struct attribute_group *groups[2];
+	struct attribute *attrs[E1000_MAX_SENSORS * 4 + 1];
+	struct hwmon_attr hwmon_list[E1000_MAX_SENSORS * 4];
 	unsigned int n_hwmon;
 	};
 #endif
@@ -440,7 +442,7 @@ struct igb_adapter {
 
 	char fw_version[32];
 #ifdef CONFIG_IGB_HWMON
-	struct hwmon_buff igb_hwmon_buff;
+	struct hwmon_buff *igb_hwmon_buff;
 	bool ets;
 #endif
 	struct i2c_algo_bit_data i2c_algo;
diff --git a/drivers/net/ethernet/intel/igb/igb_hwmon.c b/drivers/net/ethernet/intel/igb/igb_hwmon.c
index 58f1ce9..2e7ef2d 100644
--- a/drivers/net/ethernet/intel/igb/igb_hwmon.c
+++ b/drivers/net/ethernet/intel/igb/igb_hwmon.c
@@ -117,8 +117,8 @@ static int igb_add_hwmon_attr(struct igb_adapter *adapter,
 	unsigned int n_attr;
 	struct hwmon_attr *igb_attr;
 
-	n_attr = adapter->igb_hwmon_buff.n_hwmon;
-	igb_attr = &adapter->igb_hwmon_buff.hwmon_list[n_attr];
+	n_attr = adapter->igb_hwmon_buff->n_hwmon;
+	igb_attr = &adapter->igb_hwmon_buff->hwmon_list[n_attr];
 
 	switch (type) {
 	case IGB_HWMON_TYPE_LOC:
@@ -154,30 +154,16 @@ static int igb_add_hwmon_attr(struct igb_adapter *adapter,
 	igb_attr->dev_attr.attr.mode = S_IRUGO;
 	igb_attr->dev_attr.attr.name = igb_attr->name;
 	sysfs_attr_init(&igb_attr->dev_attr.attr);
-	rc = device_create_file(&adapter->pdev->dev,
-				&igb_attr->dev_attr);
-	if (rc == 0)
-		++adapter->igb_hwmon_buff.n_hwmon;
 
-	return rc;
+	adapter->igb_hwmon_buff->attrs[n_attr] = &igb_attr->dev_attr.attr;
+
+	++adapter->igb_hwmon_buff->n_hwmon;
+
+	return 0;
 }
 
 static void igb_sysfs_del_adapter(struct igb_adapter *adapter)
 {
-	int i;
-
-	if (adapter == NULL)
-		return;
-
-	for (i = 0; i < adapter->igb_hwmon_buff.n_hwmon; i++) {
-		device_remove_file(&adapter->pdev->dev,
-			   &adapter->igb_hwmon_buff.hwmon_list[i].dev_attr);
-	}
-
-	kfree(adapter->igb_hwmon_buff.hwmon_list);
-
-	if (adapter->igb_hwmon_buff.device)
-		hwmon_device_unregister(adapter->igb_hwmon_buff.device);
 }
 
 /* called from igb_main.c */
@@ -189,11 +175,11 @@ void igb_sysfs_exit(struct igb_adapter *adapter)
 /* called from igb_main.c */
 int igb_sysfs_init(struct igb_adapter *adapter)
 {
-	struct hwmon_buff *igb_hwmon = &adapter->igb_hwmon_buff;
+	struct hwmon_buff *igb_hwmon;
+	struct i2c_client *client;
+	struct device *hwmon_dev;
 	unsigned int i;
-	int n_attrs;
 	int rc = 0;
-	struct i2c_client *client = NULL;
 
 	/* If this method isn't defined we don't support thermals */
 	if (adapter->hw.mac.ops.init_thermal_sensor_thresh == NULL)
@@ -201,34 +187,16 @@ int igb_sysfs_init(struct igb_adapter *adapter)
 
 	/* Don't create thermal hwmon interface if no sensors present */
 	rc = (adapter->hw.mac.ops.init_thermal_sensor_thresh(&adapter->hw));
-		if (rc)
-			goto exit;
-
-	/* init i2c_client */
-	client = i2c_new_device(&adapter->i2c_adap, &i350_sensor_info);
-	if (client == NULL) {
-		dev_info(&adapter->pdev->dev,
-			"Failed to create new i2c device..\n");
+	if (rc)
 		goto exit;
-	}
-	adapter->i2c_client = client;
 
-	/* Allocation space for max attributes
-	 * max num sensors * values (loc, temp, max, caution)
-	 */
-	n_attrs = E1000_MAX_SENSORS * 4;
-	igb_hwmon->hwmon_list = kcalloc(n_attrs, sizeof(struct hwmon_attr),
-					GFP_KERNEL);
-	if (!igb_hwmon->hwmon_list) {
+	igb_hwmon = devm_kzalloc(&adapter->pdev->dev, sizeof(*igb_hwmon),
+				 GFP_KERNEL);
+	if (!igb_hwmon) {
 		rc = -ENOMEM;
-		goto err;
-	}
-
-	igb_hwmon->device = hwmon_device_register(&adapter->pdev->dev);
-	if (IS_ERR(igb_hwmon->device)) {
-		rc = PTR_ERR(igb_hwmon->device);
-		goto err;
+		goto exit;
 	}
+	adapter->igb_hwmon_buff = igb_hwmon;
 
 	for (i = 0; i < E1000_MAX_SENSORS; i++) {
 
@@ -240,11 +208,39 @@ int igb_sysfs_init(struct igb_adapter *adapter)
 
 		/* Bail if any hwmon attr struct fails to initialize */
 		rc = igb_add_hwmon_attr(adapter, i, IGB_HWMON_TYPE_CAUTION);
-		rc |= igb_add_hwmon_attr(adapter, i, IGB_HWMON_TYPE_LOC);
-		rc |= igb_add_hwmon_attr(adapter, i, IGB_HWMON_TYPE_TEMP);
-		rc |= igb_add_hwmon_attr(adapter, i, IGB_HWMON_TYPE_MAX);
 		if (rc)
-			goto err;
+			goto exit;
+		rc = igb_add_hwmon_attr(adapter, i, IGB_HWMON_TYPE_LOC);
+		if (rc)
+			goto exit;
+		rc = igb_add_hwmon_attr(adapter, i, IGB_HWMON_TYPE_TEMP);
+		if (rc)
+			goto exit;
+		rc = igb_add_hwmon_attr(adapter, i, IGB_HWMON_TYPE_MAX);
+		if (rc)
+			goto exit;
+	}
+
+	/* init i2c_client */
+	client = i2c_new_device(&adapter->i2c_adap, &i350_sensor_info);
+	if (client == NULL) {
+		dev_info(&adapter->pdev->dev,
+			 "Failed to create new i2c device.\n");
+		rc = -ENODEV;
+		goto exit;
+	}
+	adapter->i2c_client = client;
+
+	igb_hwmon->groups[0] = &igb_hwmon->group;
+	igb_hwmon->group.attrs = igb_hwmon->attrs;
+
+	hwmon_dev = devm_hwmon_device_register_with_groups(&adapter->pdev->dev,
+							   client->name,
+							   igb_hwmon,
+							   igb_hwmon->groups);
+	if (IS_ERR(hwmon_dev)) {
+		rc = PTR_ERR(hwmon_dev);
+		goto err;
 	}
 
 	goto exit;
-- 
1.7.9.7
