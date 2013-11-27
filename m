From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] sfc: Convert to use hwmon_device_register_with_groups
Date: Tue, 26 Nov 2013 19:33:07 -0800
Message-ID: <1385523187-31996-1-git-send-email-linux@roeck-us.net>
Cc: linux-net-drivers@solarflare.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	lm-sensors@lm-sensors.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:61977 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab3K0DdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 22:33:17 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so9071844pdj.9
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 19:33:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify the code. Avoid race conditions caused by attributes
being created after hwmon device registration. Implicitly
(through hwmon API) add mandatory 'name' sysfs attribute.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Compile tested only.

 drivers/net/ethernet/sfc/mcdi.h     |    2 +
 drivers/net/ethernet/sfc/mcdi_mon.c |   76 +++++++++++++----------------------
 2 files changed, 31 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 656a327..15816ca 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -75,6 +75,8 @@ struct efx_mcdi_mon {
 	unsigned long last_update;
 	struct device *device;
 	struct efx_mcdi_mon_attribute *attrs;
+	struct attribute_group group;
+	const struct attribute_group *groups[2];
 	unsigned int n_attrs;
 };
 
diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index 4cc5d95..ee7ce65 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -139,13 +139,6 @@ static int efx_mcdi_mon_update(struct efx_nic *efx)
 	return rc;
 }
 
-static ssize_t efx_mcdi_mon_show_name(struct device *dev,
-				      struct device_attribute *attr,
-				      char *buf)
-{
-	return sprintf(buf, "%s\n", KBUILD_MODNAME);
-}
-
 static int efx_mcdi_mon_get_entry(struct device *dev, unsigned int index,
 				  efx_dword_t *entry)
 {
@@ -263,7 +256,7 @@ static ssize_t efx_mcdi_mon_show_label(struct device *dev,
 		       efx_mcdi_sensor_type[mon_attr->type].label);
 }
 
-static int
+static void
 efx_mcdi_mon_add_attr(struct efx_nic *efx, const char *name,
 		      ssize_t (*reader)(struct device *,
 					struct device_attribute *, char *),
@@ -272,7 +265,6 @@ efx_mcdi_mon_add_attr(struct efx_nic *efx, const char *name,
 {
 	struct efx_mcdi_mon *hwmon = efx_mcdi_mon(efx);
 	struct efx_mcdi_mon_attribute *attr = &hwmon->attrs[hwmon->n_attrs];
-	int rc;
 
 	strlcpy(attr->name, name, sizeof(attr->name));
 	attr->index = index;
@@ -286,10 +278,7 @@ efx_mcdi_mon_add_attr(struct efx_nic *efx, const char *name,
 	attr->dev_attr.attr.name = attr->name;
 	attr->dev_attr.attr.mode = S_IRUGO;
 	attr->dev_attr.show = reader;
-	rc = device_create_file(&efx->pci_dev->dev, &attr->dev_attr);
-	if (rc == 0)
-		++hwmon->n_attrs;
-	return rc;
+	hwmon->group.attrs[hwmon->n_attrs++] = &attr->dev_attr.attr;
 }
 
 int efx_mcdi_mon_probe(struct efx_nic *efx)
@@ -338,26 +327,22 @@ int efx_mcdi_mon_probe(struct efx_nic *efx)
 	efx_mcdi_mon_update(efx);
 
 	/* Allocate space for the maximum possible number of
-	 * attributes for this set of sensors: name of the driver plus
+	 * attributes for this set of sensors:
 	 * value, min, max, crit, alarm and label for each sensor.
 	 */
-	n_attrs = 1 + 6 * n_sensors;
+	n_attrs = 6 * n_sensors;
 	hwmon->attrs = kcalloc(n_attrs, sizeof(*hwmon->attrs), GFP_KERNEL);
 	if (!hwmon->attrs) {
 		rc = -ENOMEM;
 		goto fail;
 	}
-
-	hwmon->device = hwmon_device_register(&efx->pci_dev->dev);
-	if (IS_ERR(hwmon->device)) {
-		rc = PTR_ERR(hwmon->device);
+	hwmon->group.attrs = kcalloc(n_attrs + 1, sizeof(struct attribute *),
+				     GFP_KERNEL);
+	if (!hwmon->group.attrs) {
+		rc = -ENOMEM;
 		goto fail;
 	}
 
-	rc = efx_mcdi_mon_add_attr(efx, "name", efx_mcdi_mon_show_name, 0, 0, 0);
-	if (rc)
-		goto fail;
-
 	for (i = 0, j = -1, type = -1; ; i++) {
 		enum efx_hwmon_type hwmon_type;
 		const char *hwmon_prefix;
@@ -372,7 +357,7 @@ int efx_mcdi_mon_probe(struct efx_nic *efx)
 				page = type / 32;
 				j = -1;
 				if (page == n_pages)
-					return 0;
+					goto hwmon_register;
 
 				MCDI_SET_DWORD(inbuf, SENSOR_INFO_EXT_IN_PAGE,
 					       page);
@@ -453,28 +438,22 @@ int efx_mcdi_mon_probe(struct efx_nic *efx)
 		if (min1 != max1) {
 			snprintf(name, sizeof(name), "%s%u_input",
 				 hwmon_prefix, hwmon_index);
-			rc = efx_mcdi_mon_add_attr(
+			efx_mcdi_mon_add_attr(
 				efx, name, efx_mcdi_mon_show_value, i, type, 0);
-			if (rc)
-				goto fail;
 
 			if (hwmon_type != EFX_HWMON_POWER) {
 				snprintf(name, sizeof(name), "%s%u_min",
 					 hwmon_prefix, hwmon_index);
-				rc = efx_mcdi_mon_add_attr(
+				efx_mcdi_mon_add_attr(
 					efx, name, efx_mcdi_mon_show_limit,
 					i, type, min1);
-				if (rc)
-					goto fail;
 			}
 
 			snprintf(name, sizeof(name), "%s%u_max",
 				 hwmon_prefix, hwmon_index);
-			rc = efx_mcdi_mon_add_attr(
+			efx_mcdi_mon_add_attr(
 				efx, name, efx_mcdi_mon_show_limit,
 				i, type, max1);
-			if (rc)
-				goto fail;
 
 			if (min2 != max2) {
 				/* Assume max2 is critical value.
@@ -482,32 +461,38 @@ int efx_mcdi_mon_probe(struct efx_nic *efx)
 				 */
 				snprintf(name, sizeof(name), "%s%u_crit",
 					 hwmon_prefix, hwmon_index);
-				rc = efx_mcdi_mon_add_attr(
+				efx_mcdi_mon_add_attr(
 					efx, name, efx_mcdi_mon_show_limit,
 					i, type, max2);
-				if (rc)
-					goto fail;
 			}
 		}
 
 		snprintf(name, sizeof(name), "%s%u_alarm",
 			 hwmon_prefix, hwmon_index);
-		rc = efx_mcdi_mon_add_attr(
+		efx_mcdi_mon_add_attr(
 			efx, name, efx_mcdi_mon_show_alarm, i, type, 0);
-		if (rc)
-			goto fail;
 
 		if (type < ARRAY_SIZE(efx_mcdi_sensor_type) &&
 		    efx_mcdi_sensor_type[type].label) {
 			snprintf(name, sizeof(name), "%s%u_label",
 				 hwmon_prefix, hwmon_index);
-			rc = efx_mcdi_mon_add_attr(
+			efx_mcdi_mon_add_attr(
 				efx, name, efx_mcdi_mon_show_label, i, type, 0);
-			if (rc)
-				goto fail;
 		}
 	}
 
+hwmon_register:
+	hwmon->groups[0] = &hwmon->group;
+	hwmon->device = hwmon_device_register_with_groups(&efx->pci_dev->dev,
+							  KBUILD_MODNAME, NULL,
+							  hwmon->groups);
+	if (IS_ERR(hwmon->device)) {
+		rc = PTR_ERR(hwmon->device);
+		goto fail;
+	}
+
+	return 0;
+
 fail:
 	efx_mcdi_mon_remove(efx);
 	return rc;
@@ -516,14 +501,11 @@ fail:
 void efx_mcdi_mon_remove(struct efx_nic *efx)
 {
 	struct efx_mcdi_mon *hwmon = efx_mcdi_mon(efx);
-	unsigned int i;
 
-	for (i = 0; i < hwmon->n_attrs; i++)
-		device_remove_file(&efx->pci_dev->dev,
-				   &hwmon->attrs[i].dev_attr);
-	kfree(hwmon->attrs);
 	if (hwmon->device)
 		hwmon_device_unregister(hwmon->device);
+	kfree(hwmon->attrs);
+	kfree(hwmon->group.attrs);
 	efx_nic_free_buffer(efx, &hwmon->dma_buf);
 }
 
-- 
1.7.9.7
