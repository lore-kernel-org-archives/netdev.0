From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 1/5] tg3: Convert to use hwmon_device_register_with_groups
Date: Fri, 22 Nov 2013 22:07:57 -0800
Message-ID: <1385186881-7931-2-git-send-email-linux@roeck-us.net>
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
Received: from mail-pb0-f49.google.com ([209.85.160.49]:58710 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957Ab3KWGIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 01:08:16 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so2342162pbb.22
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 22:08:15 -0800 (PST)
In-Reply-To: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use new hwmon API to simplify code, provide missing mandatory 'name'
sysfs attribute, and attach hwmon attributes to hwmon device instead
of pci device.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/broadcom/tg3.c |   25 ++++++-------------------
 1 file changed, 6 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a9e0684..369b736 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10629,10 +10629,8 @@ static void tg3_sd_scan_scratchpad(struct tg3 *tp, struct tg3_ocir *ocir)
 static ssize_t tg3_show_temp(struct device *dev,
 			     struct device_attribute *devattr, char *buf)
 {
-	struct pci_dev *pdev = to_pci_dev(dev);
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct tg3 *tp = netdev_priv(netdev);
 	struct sensor_device_attribute *attr = to_sensor_dev_attr(devattr);
+	struct tg3 *tp = dev_get_drvdata(dev);
 	u32 temperature;
 
 	spin_lock_bh(&tp->lock);
@@ -10650,29 +10648,25 @@ static SENSOR_DEVICE_ATTR(temp1_crit, S_IRUGO, tg3_show_temp, NULL,
 static SENSOR_DEVICE_ATTR(temp1_max, S_IRUGO, tg3_show_temp, NULL,
 			  TG3_TEMP_MAX_OFFSET);
 
-static struct attribute *tg3_attributes[] = {
+static struct attribute *tg3_attrs[] = {
 	&sensor_dev_attr_temp1_input.dev_attr.attr,
 	&sensor_dev_attr_temp1_crit.dev_attr.attr,
 	&sensor_dev_attr_temp1_max.dev_attr.attr,
 	NULL
 };
-
-static const struct attribute_group tg3_group = {
-	.attrs = tg3_attributes,
-};
+ATTRIBUTE_GROUPS(tg3);
 
 static void tg3_hwmon_close(struct tg3 *tp)
 {
 	if (tp->hwmon_dev) {
 		hwmon_device_unregister(tp->hwmon_dev);
 		tp->hwmon_dev = NULL;
-		sysfs_remove_group(&tp->pdev->dev.kobj, &tg3_group);
 	}
 }
 
 static void tg3_hwmon_open(struct tg3 *tp)
 {
-	int i, err;
+	int i;
 	u32 size = 0;
 	struct pci_dev *pdev = tp->pdev;
 	struct tg3_ocir ocirs[TG3_SD_NUM_RECS];
@@ -10690,18 +10684,11 @@ static void tg3_hwmon_open(struct tg3 *tp)
 	if (!size)
 		return;
 
-	/* Register hwmon sysfs hooks */
-	err = sysfs_create_group(&pdev->dev.kobj, &tg3_group);
-	if (err) {
-		dev_err(&pdev->dev, "Cannot create sysfs group, aborting\n");
-		return;
-	}
-
-	tp->hwmon_dev = hwmon_device_register(&pdev->dev);
+	tp->hwmon_dev = hwmon_device_register_with_groups(&pdev->dev, "tg3",
+							  tp, tg3_groups);
 	if (IS_ERR(tp->hwmon_dev)) {
 		tp->hwmon_dev = NULL;
 		dev_err(&pdev->dev, "Cannot register hwmon device, aborting\n");
-		sysfs_remove_group(&pdev->dev.kobj, &tg3_group);
 	}
 }
 
-- 
1.7.9.7
