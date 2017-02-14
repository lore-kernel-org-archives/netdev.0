From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH v2 3/4] ptp: use is_visible method to hide unused attributes
Date: Tue, 14 Feb 2017 10:23:33 -0800
Message-ID: <20170214182334.23296-4-dmitry.torokhov@gmail.com>
References: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35737 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbdBNSXl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 13:23:41 -0500
In-Reply-To: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of creating selected attributes after the device is created (and
after userspace potentially seen uevent), lets use attribute group
is_visible() method to control which attributes are shown. This will allow
us to create all attributes (except "pins" group, which will be taken care
of later) before userspace gets notified about new ptp class device.

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 drivers/ptp/ptp_sysfs.c | 125 +++++++++++++++++++++---------------------------
 1 file changed, 55 insertions(+), 70 deletions(-)

diff --git a/drivers/ptp/ptp_sysfs.c b/drivers/ptp/ptp_sysfs.c
index 27cd46ab5e32..426e42c51df4 100644
--- a/drivers/ptp/ptp_sysfs.c
+++ b/drivers/ptp/ptp_sysfs.c
@@ -46,27 +46,6 @@ PTP_SHOW_INT(n_periodic_outputs, n_per_out);
 PTP_SHOW_INT(n_programmable_pins, n_pins);
 PTP_SHOW_INT(pps_available, pps);
 
-static struct attribute *ptp_attrs[] = {
-	&dev_attr_clock_name.attr,
-	&dev_attr_max_adjustment.attr,
-	&dev_attr_n_alarms.attr,
-	&dev_attr_n_external_timestamps.attr,
-	&dev_attr_n_periodic_outputs.attr,
-	&dev_attr_n_programmable_pins.attr,
-	&dev_attr_pps_available.attr,
-	NULL,
-};
-
-static const struct attribute_group ptp_group = {
-	.attrs = ptp_attrs,
-};
-
-const struct attribute_group *ptp_groups[] = {
-	&ptp_group,
-	NULL,
-};
-
-
 static ssize_t extts_enable_store(struct device *dev,
 				  struct device_attribute *attr,
 				  const char *buf, size_t count)
@@ -91,6 +70,7 @@ static ssize_t extts_enable_store(struct device *dev,
 out:
 	return err;
 }
+static DEVICE_ATTR(extts_enable, 0220, NULL, extts_enable_store);
 
 static ssize_t extts_fifo_show(struct device *dev,
 			       struct device_attribute *attr, char *page)
@@ -124,6 +104,7 @@ static ssize_t extts_fifo_show(struct device *dev,
 	mutex_unlock(&ptp->tsevq_mux);
 	return cnt;
 }
+static DEVICE_ATTR(fifo, 0444, extts_fifo_show, NULL);
 
 static ssize_t period_store(struct device *dev,
 			    struct device_attribute *attr,
@@ -151,6 +132,7 @@ static ssize_t period_store(struct device *dev,
 out:
 	return err;
 }
+static DEVICE_ATTR(period, 0220, NULL, period_store);
 
 static ssize_t pps_enable_store(struct device *dev,
 				struct device_attribute *attr,
@@ -177,6 +159,57 @@ static ssize_t pps_enable_store(struct device *dev,
 out:
 	return err;
 }
+static DEVICE_ATTR(pps_enable, 0220, NULL, pps_enable_store);
+
+static struct attribute *ptp_attrs[] = {
+	&dev_attr_clock_name.attr,
+
+	&dev_attr_max_adjustment.attr,
+	&dev_attr_n_alarms.attr,
+	&dev_attr_n_external_timestamps.attr,
+	&dev_attr_n_periodic_outputs.attr,
+	&dev_attr_n_programmable_pins.attr,
+	&dev_attr_pps_available.attr,
+
+	&dev_attr_extts_enable.attr,
+	&dev_attr_fifo.attr,
+	&dev_attr_period.attr,
+	&dev_attr_pps_enable.attr,
+	NULL
+};
+
+static umode_t ptp_is_attribute_visible(struct kobject *kobj,
+					struct attribute *attr, int n)
+{
+	struct device *dev = kobj_to_dev(kobj);
+	struct ptp_clock *ptp = dev_get_drvdata(dev);
+	struct ptp_clock_info *info = ptp->info;
+	umode_t mode = attr->mode;
+
+	if (attr == &dev_attr_extts_enable.attr ||
+	    attr == &dev_attr_fifo.attr) {
+		if (!info->n_ext_ts)
+			mode = 0;
+	} else if (attr == &dev_attr_period.attr) {
+		if (!info->n_per_out)
+			mode = 0;
+	} else if (attr == &dev_attr_pps_enable.attr) {
+		if (!info->pps)
+			mode = 0;
+	}
+
+	return mode;
+}
+
+static const struct attribute_group ptp_group = {
+	.is_visible	= ptp_is_attribute_visible,
+	.attrs		= ptp_attrs,
+};
+
+const struct attribute_group *ptp_groups[] = {
+	&ptp_group,
+	NULL
+};
 
 static int ptp_pin_name2index(struct ptp_clock *ptp, const char *name)
 {
@@ -235,26 +268,11 @@ static ssize_t ptp_pin_store(struct device *dev, struct device_attribute *attr,
 	return count;
 }
 
-static DEVICE_ATTR(extts_enable, 0220, NULL, extts_enable_store);
-static DEVICE_ATTR(fifo,         0444, extts_fifo_show, NULL);
-static DEVICE_ATTR(period,       0220, NULL, period_store);
-static DEVICE_ATTR(pps_enable,   0220, NULL, pps_enable_store);
-
 int ptp_cleanup_sysfs(struct ptp_clock *ptp)
 {
 	struct device *dev = ptp->dev;
 	struct ptp_clock_info *info = ptp->info;
 
-	if (info->n_ext_ts) {
-		device_remove_file(dev, &dev_attr_extts_enable);
-		device_remove_file(dev, &dev_attr_fifo);
-	}
-	if (info->n_per_out)
-		device_remove_file(dev, &dev_attr_period);
-
-	if (info->pps)
-		device_remove_file(dev, &dev_attr_pps_enable);
-
 	if (info->n_pins) {
 		sysfs_remove_group(&dev->kobj, &ptp->pin_attr_group);
 		kfree(ptp->pin_attr);
@@ -306,46 +324,13 @@ static int ptp_populate_pins(struct ptp_clock *ptp)
 
 int ptp_populate_sysfs(struct ptp_clock *ptp)
 {
-	struct device *dev = ptp->dev;
 	struct ptp_clock_info *info = ptp->info;
 	int err;
 
-	if (info->n_ext_ts) {
-		err = device_create_file(dev, &dev_attr_extts_enable);
-		if (err)
-			goto out1;
-		err = device_create_file(dev, &dev_attr_fifo);
-		if (err)
-			goto out2;
-	}
-	if (info->n_per_out) {
-		err = device_create_file(dev, &dev_attr_period);
-		if (err)
-			goto out3;
-	}
-	if (info->pps) {
-		err = device_create_file(dev, &dev_attr_pps_enable);
-		if (err)
-			goto out4;
-	}
 	if (info->n_pins) {
 		err = ptp_populate_pins(ptp);
 		if (err)
-			goto out5;
+			return err;
 	}
 	return 0;
-out5:
-	if (info->pps)
-		device_remove_file(dev, &dev_attr_pps_enable);
-out4:
-	if (info->n_per_out)
-		device_remove_file(dev, &dev_attr_period);
-out3:
-	if (info->n_ext_ts)
-		device_remove_file(dev, &dev_attr_fifo);
-out2:
-	if (info->n_ext_ts)
-		device_remove_file(dev, &dev_attr_extts_enable);
-out1:
-	return err;
 }
-- 
2.11.0.483.g087da7b7c-goog
