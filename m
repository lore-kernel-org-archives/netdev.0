From: Stefan Achatz <erazor_de@users.sourceforge.net>
Subject: [PATCH 1/5] sysfs: Introducing binary attributes for struct class
Date: Fri, 26 Nov 2010 20:57:29 +0100
Message-ID: <1290801449.18750.162.camel__7958.00299752063$1290801577$gmane$org@neuromancer>
Reply-To: erazor_de@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@xenotime.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Jiri Kosina <jkosina@suse.cz>,
	Stefan Achatz <erazor_de@users.sourceforge.net>,
	linux-doc@vger.kernel.org, l
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-01.arcor-online.net ([151.189.21.41]:50825 "EHLO
	mail-in-01.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751005Ab0KZT5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 14:57:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added dev_bin_attrs to struct class similar to existing dev_attrs.

Signed-off-by: Stefan Achatz <erazor_de@users.sourceforge.net>
---
 drivers/base/core.c    |   41 +++++++++++++++++++++++++++++++++++++++--
 include/linux/device.h |    1 +
 2 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 6ed6454..7613592 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -338,6 +338,35 @@ static void device_remove_attributes(struct device *dev,
 			device_remove_file(dev, &attrs[i]);
 }
 
+static int device_add_bin_attributes(struct device *dev,
+				     struct bin_attribute *attrs)
+{
+	int error = 0;
+	int i;
+
+	if (attrs) {
+		for (i = 0; attr_name(attrs[i]); i++) {
+			error = device_create_bin_file(dev, &attrs[i]);
+			if (error)
+				break;
+		}
+		if (error)
+			while (--i >= 0)
+				device_remove_bin_file(dev, &attrs[i]);
+	}
+	return error;
+}
+
+static void device_remove_bin_attributes(struct device *dev,
+					 struct bin_attribute *attrs)
+{
+	int i;
+
+	if (attrs)
+		for (i = 0; attr_name(attrs[i]); i++)
+			device_remove_bin_file(dev, &attrs[i]);
+}
+
 static int device_add_groups(struct device *dev,
 			     const struct attribute_group **groups)
 {
@@ -378,12 +407,15 @@ static int device_add_attrs(struct device *dev)
 		error = device_add_attributes(dev, class->dev_attrs);
 		if (error)
 			return error;
+		error = device_add_bin_attributes(dev, class->dev_bin_attrs);
+		if (error)
+			goto err_remove_class_attrs;
 	}
 
 	if (type) {
 		error = device_add_groups(dev, type->groups);
 		if (error)
-			goto err_remove_class_attrs;
+			goto err_remove_class_bin_attrs;
 	}
 
 	error = device_add_groups(dev, dev->groups);
@@ -395,6 +427,9 @@ static int device_add_attrs(struct device *dev)
  err_remove_type_groups:
 	if (type)
 		device_remove_groups(dev, type->groups);
+ err_remove_class_bin_attrs:
+	if (class)
+		device_remove_bin_attributes(dev, class->dev_bin_attrs);
  err_remove_class_attrs:
 	if (class)
 		device_remove_attributes(dev, class->dev_attrs);
@@ -412,8 +447,10 @@ static void device_remove_attrs(struct device *dev)
 	if (type)
 		device_remove_groups(dev, type->groups);
 
-	if (class)
+	if (class) {
 		device_remove_attributes(dev, class->dev_attrs);
+		device_remove_bin_attributes(dev, class->dev_bin_attrs);
+	}
 }
 
 
diff --git a/include/linux/device.h b/include/linux/device.h
index dd48953..032bdb5 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -197,6 +197,7 @@ struct class {
 
 	struct class_attribute		*class_attrs;
 	struct device_attribute		*dev_attrs;
+	struct bin_attribute		*dev_bin_attrs;
 	struct kobject			*dev_kobj;
 
 	int (*dev_uevent)(struct device *dev, struct kobj_uevent_env *env);
-- 
1.7.2.3



