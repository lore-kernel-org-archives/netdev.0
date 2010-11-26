From: Stefan Achatz <erazor_de@users.sourceforge.net>
Subject: [PATCH 4/5] HID: roccat: Reducing number of functions in kone and
 pyra drivers
Date: Fri, 26 Nov 2010 20:57:38 +0100
Message-ID: <1290801458.18750.165.camel__17930.2360317253$1290801523$gmane$org@neuromancer>
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
Received: from mail-in-10.arcor-online.net ([151.189.21.50]:55481 "EHLO
	mail-in-10.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751697Ab0KZT5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 14:57:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The profile number is now passed via bin_attribute->private instead
of function parameter to reduce number of functions.

Signed-off-by: Stefan Achatz <erazor_de@users.sourceforge.net>
---
 drivers/hid/hid-roccat-kone.c |  106 +++++++++---------------------------
 drivers/hid/hid-roccat-pyra.c |  120 +++++++++--------------------------------
 2 files changed, 53 insertions(+), 173 deletions(-)

diff --git a/drivers/hid/hid-roccat-kone.c b/drivers/hid/hid-roccat-kone.c
index a837b8a..005a7be 100644
--- a/drivers/hid/hid-roccat-kone.c
+++ b/drivers/hid/hid-roccat-kone.c
@@ -35,6 +35,8 @@
 #include "hid-roccat.h"
 #include "hid-roccat-kone.h"
 
+static uint profile_numbers[5] = {0, 1, 2, 3, 4};
+
 /* kone_class is used for creating sysfs attributes via roccat char device */
 static struct class *kone_class;
 
@@ -324,9 +326,9 @@ static ssize_t kone_sysfs_write_settings(struct file *fp, struct kobject *kobj,
 	return sizeof(struct kone_settings);
 }
 
-static ssize_t kone_sysfs_read_profilex(struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count, int number) {
+static ssize_t kone_sysfs_read_profilex(struct file *fp,
+		struct kobject *kobj, struct bin_attribute *attr,
+		char *buf, loff_t off, size_t count) {
 	struct device *dev =
 			container_of(kobj, struct device, kobj)->parent->parent;
 	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
@@ -338,46 +340,16 @@ static ssize_t kone_sysfs_read_profilex(struct kobject *kobj,
 		count = sizeof(struct kone_profile) - off;
 
 	mutex_lock(&kone->kone_lock);
-	memcpy(buf, ((char const *)&kone->profiles[number - 1]) + off, count);
+	memcpy(buf, ((char const *)&kone->profiles[*(uint *)(attr->private)]) + off, count);
 	mutex_unlock(&kone->kone_lock);
 
 	return count;
 }
 
-static ssize_t kone_sysfs_read_profile1(struct file *fp, struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count) {
-	return kone_sysfs_read_profilex(kobj, attr, buf, off, count, 1);
-}
-
-static ssize_t kone_sysfs_read_profile2(struct file *fp, struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count) {
-	return kone_sysfs_read_profilex(kobj, attr, buf, off, count, 2);
-}
-
-static ssize_t kone_sysfs_read_profile3(struct file *fp, struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count) {
-	return kone_sysfs_read_profilex(kobj, attr, buf, off, count, 3);
-}
-
-static ssize_t kone_sysfs_read_profile4(struct file *fp, struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count) {
-	return kone_sysfs_read_profilex(kobj, attr, buf, off, count, 4);
-}
-
-static ssize_t kone_sysfs_read_profile5(struct file *fp, struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count) {
-	return kone_sysfs_read_profilex(kobj, attr, buf, off, count, 5);
-}
-
 /* Writes data only if different to stored data */
-static ssize_t kone_sysfs_write_profilex(struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count, int number) {
+static ssize_t kone_sysfs_write_profilex(struct file *fp,
+		struct kobject *kobj, struct bin_attribute *attr,
+		char *buf, loff_t off, size_t count) {
 	struct device *dev =
 			container_of(kobj, struct device, kobj)->parent->parent;
 	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
@@ -389,13 +361,14 @@ static ssize_t kone_sysfs_write_profilex(struct kobject *kobj,
 	if (off != 0 || count != sizeof(struct kone_profile))
 		return -EINVAL;
 
-	profile = &kone->profiles[number - 1];
+	profile = &kone->profiles[*(uint *)(attr->private)];
 
 	mutex_lock(&kone->kone_lock);
 	difference = memcmp(buf, profile, sizeof(struct kone_profile));
 	if (difference) {
 		retval = kone_set_profile(usb_dev,
-				(struct kone_profile const *)buf, number);
+				(struct kone_profile const *)buf,
+				*(uint *)(attr->private) + 1);
 		if (!retval)
 			memcpy(profile, buf, sizeof(struct kone_profile));
 	}
@@ -407,36 +380,6 @@ static ssize_t kone_sysfs_write_profilex(struct kobject *kobj,
 	return sizeof(struct kone_profile);
 }
 
-static ssize_t kone_sysfs_write_profile1(struct file *fp, struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count) {
-	return kone_sysfs_write_profilex(kobj, attr, buf, off, count, 1);
-}
-
-static ssize_t kone_sysfs_write_profile2(struct file *fp, struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count) {
-	return kone_sysfs_write_profilex(kobj, attr, buf, off, count, 2);
-}
-
-static ssize_t kone_sysfs_write_profile3(struct file *fp, struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count) {
-	return kone_sysfs_write_profilex(kobj, attr, buf, off, count, 3);
-}
-
-static ssize_t kone_sysfs_write_profile4(struct file *fp, struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count) {
-	return kone_sysfs_write_profilex(kobj, attr, buf, off, count, 4);
-}
-
-static ssize_t kone_sysfs_write_profile5(struct file *fp, struct kobject *kobj,
-		struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count) {
-	return kone_sysfs_write_profilex(kobj, attr, buf, off, count, 5);
-}
-
 static ssize_t kone_sysfs_show_actual_profile(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
@@ -692,32 +635,37 @@ static struct bin_attribute kone_bin_attributes[] = {
 	{
 		.attr = { .name = "profile1", .mode = 0660 },
 		.size = sizeof(struct kone_profile),
-		.read = kone_sysfs_read_profile1,
-		.write = kone_sysfs_write_profile1
+		.read = kone_sysfs_read_profilex,
+		.write = kone_sysfs_write_profilex,
+		.private = &profile_numbers[0]
 	},
 	{
 		.attr = { .name = "profile2", .mode = 0660 },
 		.size = sizeof(struct kone_profile),
-		.read = kone_sysfs_read_profile2,
-		.write = kone_sysfs_write_profile2
+		.read = kone_sysfs_read_profilex,
+		.write = kone_sysfs_write_profilex,
+		.private = &profile_numbers[1]
 	},
 	{
 		.attr = { .name = "profile3", .mode = 0660 },
 		.size = sizeof(struct kone_profile),
-		.read = kone_sysfs_read_profile3,
-		.write = kone_sysfs_write_profile3
+		.read = kone_sysfs_read_profilex,
+		.write = kone_sysfs_write_profilex,
+		.private = &profile_numbers[2]
 	},
 	{
 		.attr = { .name = "profile4", .mode = 0660 },
 		.size = sizeof(struct kone_profile),
-		.read = kone_sysfs_read_profile4,
-		.write = kone_sysfs_write_profile4
+		.read = kone_sysfs_read_profilex,
+		.write = kone_sysfs_write_profilex,
+		.private = &profile_numbers[3]
 	},
 	{
 		.attr = { .name = "profile5", .mode = 0660 },
 		.size = sizeof(struct kone_profile),
-		.read = kone_sysfs_read_profile5,
-		.write = kone_sysfs_write_profile5
+		.read = kone_sysfs_read_profilex,
+		.write = kone_sysfs_write_profilex,
+		.private = &profile_numbers[4]
 	},
 	__ATTR_NULL
 };
diff --git a/drivers/hid/hid-roccat-pyra.c b/drivers/hid/hid-roccat-pyra.c
index a50c89e..5ce0580 100644
--- a/drivers/hid/hid-roccat-pyra.c
+++ b/drivers/hid/hid-roccat-pyra.c
@@ -27,6 +27,8 @@
 #include "hid-roccat.h"
 #include "hid-roccat-pyra.h"
 
+static uint profile_numbers[5] = {0, 1, 2, 3, 4};
+
 /* pyra_class is used for creating sysfs attributes via roccat char device */
 static struct class *pyra_class;
 
@@ -224,7 +226,7 @@ static int pyra_set_settings(struct usb_device *usb_dev,
 
 static ssize_t pyra_sysfs_read_profilex_settings(struct file *fp,
 		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count, int number)
+		loff_t off, size_t count)
 {
 	struct device *dev =
 			container_of(kobj, struct device, kobj)->parent->parent;
@@ -237,56 +239,16 @@ static ssize_t pyra_sysfs_read_profilex_settings(struct file *fp,
 		count = sizeof(struct pyra_profile_settings) - off;
 
 	mutex_lock(&pyra->pyra_lock);
-	memcpy(buf, ((char const *)&pyra->profile_settings[number]) + off,
+	memcpy(buf, ((char const *)&pyra->profile_settings[*(uint *)(attr->private)]) + off,
 			count);
 	mutex_unlock(&pyra->pyra_lock);
 
 	return count;
 }
 
-static ssize_t pyra_sysfs_read_profile1_settings(struct file *fp,
-		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count)
-{
-	return pyra_sysfs_read_profilex_settings(fp, kobj,
-			attr, buf, off, count, 0);
-}
-
-static ssize_t pyra_sysfs_read_profile2_settings(struct file *fp,
-		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count)
-{
-	return pyra_sysfs_read_profilex_settings(fp, kobj,
-			attr, buf, off, count, 1);
-}
-
-static ssize_t pyra_sysfs_read_profile3_settings(struct file *fp,
-		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count)
-{
-	return pyra_sysfs_read_profilex_settings(fp, kobj,
-			attr, buf, off, count, 2);
-}
-
-static ssize_t pyra_sysfs_read_profile4_settings(struct file *fp,
-		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count)
-{
-	return pyra_sysfs_read_profilex_settings(fp, kobj,
-			attr, buf, off, count, 3);
-}
-
-static ssize_t pyra_sysfs_read_profile5_settings(struct file *fp,
-		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count)
-{
-	return pyra_sysfs_read_profilex_settings(fp, kobj,
-			attr, buf, off, count, 4);
-}
-
 static ssize_t pyra_sysfs_read_profilex_buttons(struct file *fp,
 		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count, int number)
+		loff_t off, size_t count)
 {
 	struct device *dev =
 			container_of(kobj, struct device, kobj)->parent->parent;
@@ -299,53 +261,13 @@ static ssize_t pyra_sysfs_read_profilex_buttons(struct file *fp,
 		count = sizeof(struct pyra_profile_buttons) - off;
 
 	mutex_lock(&pyra->pyra_lock);
-	memcpy(buf, ((char const *)&pyra->profile_buttons[number]) + off,
+	memcpy(buf, ((char const *)&pyra->profile_buttons[*(uint *)(attr->private)]) + off,
 			count);
 	mutex_unlock(&pyra->pyra_lock);
 
 	return count;
 }
 
-static ssize_t pyra_sysfs_read_profile1_buttons(struct file *fp,
-		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count)
-{
-	return pyra_sysfs_read_profilex_buttons(fp, kobj,
-			attr, buf, off, count, 0);
-}
-
-static ssize_t pyra_sysfs_read_profile2_buttons(struct file *fp,
-		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count)
-{
-	return pyra_sysfs_read_profilex_buttons(fp, kobj,
-			attr, buf, off, count, 1);
-}
-
-static ssize_t pyra_sysfs_read_profile3_buttons(struct file *fp,
-		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count)
-{
-	return pyra_sysfs_read_profilex_buttons(fp, kobj,
-			attr, buf, off, count, 2);
-}
-
-static ssize_t pyra_sysfs_read_profile4_buttons(struct file *fp,
-		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count)
-{
-	return pyra_sysfs_read_profilex_buttons(fp, kobj,
-			attr, buf, off, count, 3);
-}
-
-static ssize_t pyra_sysfs_read_profile5_buttons(struct file *fp,
-		struct kobject *kobj, struct bin_attribute *attr, char *buf,
-		loff_t off, size_t count)
-{
-	return pyra_sysfs_read_profilex_buttons(fp, kobj,
-			attr, buf, off, count, 4);
-}
-
 static ssize_t pyra_sysfs_write_profile_settings(struct file *fp,
 		struct kobject *kobj, struct bin_attribute *attr, char *buf,
 		loff_t off, size_t count)
@@ -526,27 +448,32 @@ static struct bin_attribute pyra_bin_attributes[] = {
 	{
 		.attr = { .name = "profile1_settings", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_settings),
-		.read = pyra_sysfs_read_profile1_settings
+		.read = pyra_sysfs_read_profilex_settings,
+		.private = &profile_numbers[0]
 	},
 	{
 		.attr = { .name = "profile2_settings", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_settings),
-		.read = pyra_sysfs_read_profile2_settings
+		.read = pyra_sysfs_read_profilex_settings,
+		.private = &profile_numbers[1]
 	},
 	{
 		.attr = { .name = "profile3_settings", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_settings),
-		.read = pyra_sysfs_read_profile3_settings
+		.read = pyra_sysfs_read_profilex_settings,
+		.private = &profile_numbers[2]
 	},
 	{
 		.attr = { .name = "profile4_settings", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_settings),
-		.read = pyra_sysfs_read_profile4_settings
+		.read = pyra_sysfs_read_profilex_settings,
+		.private = &profile_numbers[3]
 	},
 	{
 		.attr = { .name = "profile5_settings", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_settings),
-		.read = pyra_sysfs_read_profile5_settings
+		.read = pyra_sysfs_read_profilex_settings,
+		.private = &profile_numbers[4]
 	},
 	{
 		.attr = { .name = "profile_buttons", .mode = 0220 },
@@ -556,27 +483,32 @@ static struct bin_attribute pyra_bin_attributes[] = {
 	{
 		.attr = { .name = "profile1_buttons", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_buttons),
-		.read = pyra_sysfs_read_profile1_buttons
+		.read = pyra_sysfs_read_profilex_buttons,
+		.private = &profile_numbers[0]
 	},
 	{
 		.attr = { .name = "profile2_buttons", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_buttons),
-		.read = pyra_sysfs_read_profile2_buttons
+		.read = pyra_sysfs_read_profilex_buttons,
+		.private = &profile_numbers[1]
 	},
 	{
 		.attr = { .name = "profile3_buttons", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_buttons),
-		.read = pyra_sysfs_read_profile3_buttons
+		.read = pyra_sysfs_read_profilex_buttons,
+		.private = &profile_numbers[2]
 	},
 	{
 		.attr = { .name = "profile4_buttons", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_buttons),
-		.read = pyra_sysfs_read_profile4_buttons
+		.read = pyra_sysfs_read_profilex_buttons,
+		.private = &profile_numbers[3]
 	},
 	{
 		.attr = { .name = "profile5_buttons", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_buttons),
-		.read = pyra_sysfs_read_profile5_buttons
+		.read = pyra_sysfs_read_profilex_buttons,
+		.private = &profile_numbers[4]
 	},
 	{
 		.attr = { .name = "settings", .mode = 0660 },
-- 
1.7.2.3



