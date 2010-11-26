From: Stefan Achatz <erazor_de@users.sourceforge.net>
Subject: [PATCH 2/5] HID: roccat: Using class for char device for sysfs
 attribute creation
Date: Fri, 26 Nov 2010 20:57:33 +0100
Message-ID: <1290801453.18750.163.camel__28915.2022022337$1290801514$gmane$org@neuromancer>
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
Received: from mail-in-05.arcor-online.net ([151.189.21.45]:33781 "EHLO
	mail-in-05.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751410Ab0KZT5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 14:57:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding sysfs attributes to an already created device raises no userland
notification. Now the device drivers associate the devices attributes
with a class and use this for roccat event char device creation.

Signed-off-by: Stefan Achatz <erazor_de@users.sourceforge.net>
---
 drivers/hid/hid-roccat-kone.c |  297 ++++++++++++++++++-----------------------
 drivers/hid/hid-roccat-pyra.c |  273 ++++++++++---------------------------
 drivers/hid/hid-roccat.c      |   17 +--
 drivers/hid/hid-roccat.h      |    5 +-
 4 files changed, 209 insertions(+), 383 deletions(-)

diff --git a/drivers/hid/hid-roccat-kone.c b/drivers/hid/hid-roccat-kone.c
index f776957..a837b8a 100644
--- a/drivers/hid/hid-roccat-kone.c
+++ b/drivers/hid/hid-roccat-kone.c
@@ -35,6 +35,9 @@
 #include "hid-roccat.h"
 #include "hid-roccat-kone.h"
 
+/* kone_class is used for creating sysfs attributes via roccat char device */
+static struct class *kone_class;
+
 static void kone_set_settings_checksum(struct kone_settings *settings)
 {
 	uint16_t checksum = 0;
@@ -262,7 +265,8 @@ static int kone_get_firmware_version(struct usb_device *usb_dev, int *result)
 static ssize_t kone_sysfs_read_settings(struct file *fp, struct kobject *kobj,
 		struct bin_attribute *attr, char *buf,
 		loff_t off, size_t count) {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
 	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
 
 	if (off >= sizeof(struct kone_settings))
@@ -286,7 +290,8 @@ static ssize_t kone_sysfs_read_settings(struct file *fp, struct kobject *kobj,
 static ssize_t kone_sysfs_write_settings(struct file *fp, struct kobject *kobj,
 		struct bin_attribute *attr, char *buf,
 		loff_t off, size_t count) {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
 	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
 	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
 	int retval = 0, difference;
@@ -322,7 +327,8 @@ static ssize_t kone_sysfs_write_settings(struct file *fp, struct kobject *kobj,
 static ssize_t kone_sysfs_read_profilex(struct kobject *kobj,
 		struct bin_attribute *attr, char *buf,
 		loff_t off, size_t count, int number) {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
 	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
 
 	if (off >= sizeof(struct kone_profile))
@@ -372,7 +378,8 @@ static ssize_t kone_sysfs_read_profile5(struct file *fp, struct kobject *kobj,
 static ssize_t kone_sysfs_write_profilex(struct kobject *kobj,
 		struct bin_attribute *attr, char *buf,
 		loff_t off, size_t count, int number) {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
 	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
 	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
 	struct kone_profile *profile;
@@ -433,14 +440,16 @@ static ssize_t kone_sysfs_write_profile5(struct file *fp, struct kobject *kobj,
 static ssize_t kone_sysfs_show_actual_profile(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
+	struct kone_device *kone =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
 	return snprintf(buf, PAGE_SIZE, "%d\n", kone->actual_profile);
 }
 
 static ssize_t kone_sysfs_show_actual_dpi(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
+	struct kone_device *kone =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
 	return snprintf(buf, PAGE_SIZE, "%d\n", kone->actual_dpi);
 }
 
@@ -448,11 +457,15 @@ static ssize_t kone_sysfs_show_actual_dpi(struct device *dev,
 static ssize_t kone_sysfs_show_weight(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
-	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
+	struct kone_device *kone;
+	struct usb_device *usb_dev;
 	int weight = 0;
 	int retval;
 
+	dev = dev->parent->parent;
+	kone = hid_get_drvdata(dev_get_drvdata(dev));
+	usb_dev = interface_to_usbdev(to_usb_interface(dev));
+
 	mutex_lock(&kone->kone_lock);
 	retval = kone_get_weight(usb_dev, &weight);
 	mutex_unlock(&kone->kone_lock);
@@ -465,14 +478,16 @@ static ssize_t kone_sysfs_show_weight(struct device *dev,
 static ssize_t kone_sysfs_show_firmware_version(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
+	struct kone_device *kone =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
 	return snprintf(buf, PAGE_SIZE, "%d\n", kone->firmware_version);
 }
 
 static ssize_t kone_sysfs_show_tcu(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
+	struct kone_device *kone =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
 	return snprintf(buf, PAGE_SIZE, "%d\n", kone->settings.tcu);
 }
 
@@ -504,11 +519,15 @@ static int kone_tcu_command(struct usb_device *usb_dev, int number)
 static ssize_t kone_sysfs_set_tcu(struct device *dev,
 		struct device_attribute *attr, char const *buf, size_t size)
 {
-	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
-	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
+	struct kone_device *kone;
+	struct usb_device *usb_dev;
 	int retval;
 	unsigned long state;
 
+	dev = dev->parent->parent;
+	kone = hid_get_drvdata(dev_get_drvdata(dev));
+	usb_dev = interface_to_usbdev(to_usb_interface(dev));
+
 	retval = strict_strtoul(buf, 10, &state);
 	if (retval)
 		return retval;
@@ -579,18 +598,23 @@ exit_unlock:
 static ssize_t kone_sysfs_show_startup_profile(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
+	struct kone_device *kone =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
 	return snprintf(buf, PAGE_SIZE, "%d\n", kone->settings.startup_profile);
 }
 
 static ssize_t kone_sysfs_set_startup_profile(struct device *dev,
 		struct device_attribute *attr, char const *buf, size_t size)
 {
-	struct kone_device *kone = hid_get_drvdata(dev_get_drvdata(dev));
-	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
+	struct kone_device *kone;
+	struct usb_device *usb_dev;
 	int retval;
 	unsigned long new_startup_profile;
 
+	dev = dev->parent->parent;
+	kone = hid_get_drvdata(dev_get_drvdata(dev));
+	usb_dev = interface_to_usbdev(to_usb_interface(dev));
+
 	retval = strict_strtoul(buf, 10, &new_startup_profile);
 	if (retval)
 		return retval;
@@ -617,160 +641,87 @@ static ssize_t kone_sysfs_set_startup_profile(struct device *dev,
 	return size;
 }
 
-/*
- * Read actual dpi settings.
- * Returns raw value for further processing. Refer to enum kone_polling_rates to
- * get real value.
- */
-static DEVICE_ATTR(actual_dpi, 0440, kone_sysfs_show_actual_dpi, NULL);
-
-static DEVICE_ATTR(actual_profile, 0440, kone_sysfs_show_actual_profile, NULL);
-
-/*
- * The mouse can be equipped with one of four supplied weights from 5 to 20
- * grams which are recognized and its value can be read out.
- * This returns the raw value reported by the mouse for easy evaluation by
- * software. Refer to enum kone_weights to get corresponding real weight.
- */
-static DEVICE_ATTR(weight, 0440, kone_sysfs_show_weight, NULL);
-
-/*
- * Prints firmware version stored in mouse as integer.
- * The raw value reported by the mouse is returned for easy evaluation, to get
- * the real version number the decimal point has to be shifted 2 positions to
- * the left. E.g. a value of 138 means 1.38.
- */
-static DEVICE_ATTR(firmware_version, 0440,
-		kone_sysfs_show_firmware_version, NULL);
-
-/*
- * Prints state of Tracking Control Unit as number where 0 = off and 1 = on
- * Writing 0 deactivates tcu and writing 1 calibrates and activates the tcu
- */
-static DEVICE_ATTR(tcu, 0660, kone_sysfs_show_tcu, kone_sysfs_set_tcu);
-
-/* Prints and takes the number of the profile the mouse starts with */
-static DEVICE_ATTR(startup_profile, 0660,
-		kone_sysfs_show_startup_profile,
-		kone_sysfs_set_startup_profile);
-
-static struct attribute *kone_attributes[] = {
-		&dev_attr_actual_dpi.attr,
-		&dev_attr_actual_profile.attr,
-		&dev_attr_weight.attr,
-		&dev_attr_firmware_version.attr,
-		&dev_attr_tcu.attr,
-		&dev_attr_startup_profile.attr,
-		NULL
-};
-
-static struct attribute_group kone_attribute_group = {
-		.attrs = kone_attributes
-};
-
-static struct bin_attribute kone_settings_attr = {
-	.attr = { .name = "settings", .mode = 0660 },
-	.size = sizeof(struct kone_settings),
-	.read = kone_sysfs_read_settings,
-	.write = kone_sysfs_write_settings
-};
+static struct device_attribute kone_attributes[] = {
+	/*
+	 * Read actual dpi settings.
+	 * Returns raw value for further processing. Refer to enum
+	 * kone_polling_rates to get real value.
+	 */
+	__ATTR(actual_dpi, 0440, kone_sysfs_show_actual_dpi, NULL),
+	__ATTR(actual_profile, 0440, kone_sysfs_show_actual_profile, NULL),
 
-static struct bin_attribute kone_profile1_attr = {
-	.attr = { .name = "profile1", .mode = 0660 },
-	.size = sizeof(struct kone_profile),
-	.read = kone_sysfs_read_profile1,
-	.write = kone_sysfs_write_profile1
-};
+	/*
+	 * The mouse can be equipped with one of four supplied weights from 5
+	 * to 20 grams which are recognized and its value can be read out.
+	 * This returns the raw value reported by the mouse for easy evaluation
+	 * by software. Refer to enum kone_weights to get corresponding real
+	 * weight.
+	 */
+	__ATTR(weight, 0440, kone_sysfs_show_weight, NULL),
 
-static struct bin_attribute kone_profile2_attr = {
-	.attr = { .name = "profile2", .mode = 0660 },
-	.size = sizeof(struct kone_profile),
-	.read = kone_sysfs_read_profile2,
-	.write = kone_sysfs_write_profile2
-};
+	/*
+	 * Prints firmware version stored in mouse as integer.
+	 * The raw value reported by the mouse is returned for easy evaluation,
+	 * to get the real version number the decimal point has to be shifted 2
+	 * positions to the left. E.g. a value of 138 means 1.38.
+	 */
+	__ATTR(firmware_version, 0440,
+			kone_sysfs_show_firmware_version, NULL),
 
-static struct bin_attribute kone_profile3_attr = {
-	.attr = { .name = "profile3", .mode = 0660 },
-	.size = sizeof(struct kone_profile),
-	.read = kone_sysfs_read_profile3,
-	.write = kone_sysfs_write_profile3
-};
+	/*
+	 * Prints state of Tracking Control Unit as number where 0 = off and
+	 * 1 = on. Writing 0 deactivates tcu and writing 1 calibrates and
+	 * activates the tcu
+	 */
+	__ATTR(tcu, 0660, kone_sysfs_show_tcu, kone_sysfs_set_tcu),
 
-static struct bin_attribute kone_profile4_attr = {
-	.attr = { .name = "profile4", .mode = 0660 },
-	.size = sizeof(struct kone_profile),
-	.read = kone_sysfs_read_profile4,
-	.write = kone_sysfs_write_profile4
+	/* Prints and takes the number of the profile the mouse starts with */
+	__ATTR(startup_profile, 0660,
+			kone_sysfs_show_startup_profile,
+			kone_sysfs_set_startup_profile),
+	__ATTR_NULL
 };
 
-static struct bin_attribute kone_profile5_attr = {
-	.attr = { .name = "profile5", .mode = 0660 },
-	.size = sizeof(struct kone_profile),
-	.read = kone_sysfs_read_profile5,
-	.write = kone_sysfs_write_profile5
+static struct bin_attribute kone_bin_attributes[] = {
+	{
+		.attr = { .name = "settings", .mode = 0660 },
+		.size = sizeof(struct kone_settings),
+		.read = kone_sysfs_read_settings,
+		.write = kone_sysfs_write_settings
+	},
+	{
+		.attr = { .name = "profile1", .mode = 0660 },
+		.size = sizeof(struct kone_profile),
+		.read = kone_sysfs_read_profile1,
+		.write = kone_sysfs_write_profile1
+	},
+	{
+		.attr = { .name = "profile2", .mode = 0660 },
+		.size = sizeof(struct kone_profile),
+		.read = kone_sysfs_read_profile2,
+		.write = kone_sysfs_write_profile2
+	},
+	{
+		.attr = { .name = "profile3", .mode = 0660 },
+		.size = sizeof(struct kone_profile),
+		.read = kone_sysfs_read_profile3,
+		.write = kone_sysfs_write_profile3
+	},
+	{
+		.attr = { .name = "profile4", .mode = 0660 },
+		.size = sizeof(struct kone_profile),
+		.read = kone_sysfs_read_profile4,
+		.write = kone_sysfs_write_profile4
+	},
+	{
+		.attr = { .name = "profile5", .mode = 0660 },
+		.size = sizeof(struct kone_profile),
+		.read = kone_sysfs_read_profile5,
+		.write = kone_sysfs_write_profile5
+	},
+	__ATTR_NULL
 };
 
-static int kone_create_sysfs_attributes(struct usb_interface *intf)
-{
-	int retval;
-
-	retval = sysfs_create_group(&intf->dev.kobj, &kone_attribute_group);
-	if (retval)
-		goto exit_1;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj, &kone_settings_attr);
-	if (retval)
-		goto exit_2;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj, &kone_profile1_attr);
-	if (retval)
-		goto exit_3;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj, &kone_profile2_attr);
-	if (retval)
-		goto exit_4;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj, &kone_profile3_attr);
-	if (retval)
-		goto exit_5;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj, &kone_profile4_attr);
-	if (retval)
-		goto exit_6;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj, &kone_profile5_attr);
-	if (retval)
-		goto exit_7;
-
-	return 0;
-
-exit_7:
-	sysfs_remove_bin_file(&intf->dev.kobj, &kone_profile4_attr);
-exit_6:
-	sysfs_remove_bin_file(&intf->dev.kobj, &kone_profile3_attr);
-exit_5:
-	sysfs_remove_bin_file(&intf->dev.kobj, &kone_profile2_attr);
-exit_4:
-	sysfs_remove_bin_file(&intf->dev.kobj, &kone_profile1_attr);
-exit_3:
-	sysfs_remove_bin_file(&intf->dev.kobj, &kone_settings_attr);
-exit_2:
-	sysfs_remove_group(&intf->dev.kobj, &kone_attribute_group);
-exit_1:
-	return retval;
-}
-
-static void kone_remove_sysfs_attributes(struct usb_interface *intf)
-{
-	sysfs_remove_bin_file(&intf->dev.kobj, &kone_profile5_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &kone_profile4_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &kone_profile3_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &kone_profile2_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &kone_profile1_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &kone_settings_attr);
-	sysfs_remove_group(&intf->dev.kobj, &kone_attribute_group);
-}
-
 static int kone_init_kone_device_struct(struct usb_device *usb_dev,
 		struct kone_device *kone)
 {
@@ -830,7 +781,7 @@ static int kone_init_specials(struct hid_device *hdev)
 			goto exit_free;
 		}
 
-		retval = roccat_connect(hdev);
+		retval = roccat_connect(kone_class, hdev);
 		if (retval < 0) {
 			dev_err(&hdev->dev, "couldn't init char dev\n");
 			/* be tolerant about not getting chrdev */
@@ -839,11 +790,6 @@ static int kone_init_specials(struct hid_device *hdev)
 			kone->chrdev_minor = retval;
 		}
 
-		retval = kone_create_sysfs_attributes(intf);
-		if (retval) {
-			dev_err(&hdev->dev, "cannot create sysfs files\n");
-			goto exit_free;
-		}
 	} else {
 		hid_set_drvdata(hdev, NULL);
 	}
@@ -854,7 +800,6 @@ exit_free:
 	return retval;
 }
 
-
 static void kone_remove_specials(struct hid_device *hdev)
 {
 	struct usb_interface *intf = to_usb_interface(hdev->dev.parent);
@@ -862,7 +807,6 @@ static void kone_remove_specials(struct hid_device *hdev)
 
 	if (intf->cur_altsetting->desc.bInterfaceProtocol
 			== USB_INTERFACE_PROTOCOL_MOUSE) {
-		kone_remove_sysfs_attributes(intf);
 		kone = hid_get_drvdata(hdev);
 		if (kone->roccat_claimed)
 			roccat_disconnect(kone->chrdev_minor);
@@ -1006,11 +950,24 @@ static struct hid_driver kone_driver = {
 
 static int __init kone_init(void)
 {
-	return hid_register_driver(&kone_driver);
+	int retval;
+
+	/* class name has to be same as driver name */
+	kone_class = class_create(THIS_MODULE, "kone");
+	if (IS_ERR(kone_class))
+		return PTR_ERR(kone_class);
+	kone_class->dev_attrs = kone_attributes;
+	kone_class->dev_bin_attrs = kone_bin_attributes;
+
+	retval = hid_register_driver(&kone_driver);
+	if (retval)
+		class_destroy(kone_class);
+	return retval;
 }
 
 static void __exit kone_exit(void)
 {
+	class_destroy(kone_class);
 	hid_unregister_driver(&kone_driver);
 }
 
diff --git a/drivers/hid/hid-roccat-pyra.c b/drivers/hid/hid-roccat-pyra.c
index 9bf2304..a50c89e 100644
--- a/drivers/hid/hid-roccat-pyra.c
+++ b/drivers/hid/hid-roccat-pyra.c
@@ -27,6 +27,9 @@
 #include "hid-roccat.h"
 #include "hid-roccat-pyra.h"
 
+/* pyra_class is used for creating sysfs attributes via roccat char device */
+static struct class *pyra_class;
+
 static void profile_activated(struct pyra_device *pyra,
 		unsigned int new_profile)
 {
@@ -223,7 +226,8 @@ static ssize_t pyra_sysfs_read_profilex_settings(struct file *fp,
 		struct kobject *kobj, struct bin_attribute *attr, char *buf,
 		loff_t off, size_t count, int number)
 {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
 	struct pyra_device *pyra = hid_get_drvdata(dev_get_drvdata(dev));
 
 	if (off >= sizeof(struct pyra_profile_settings))
@@ -284,7 +288,8 @@ static ssize_t pyra_sysfs_read_profilex_buttons(struct file *fp,
 		struct kobject *kobj, struct bin_attribute *attr, char *buf,
 		loff_t off, size_t count, int number)
 {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
 	struct pyra_device *pyra = hid_get_drvdata(dev_get_drvdata(dev));
 
 	if (off >= sizeof(struct pyra_profile_buttons))
@@ -345,7 +350,8 @@ static ssize_t pyra_sysfs_write_profile_settings(struct file *fp,
 		struct kobject *kobj, struct bin_attribute *attr, char *buf,
 		loff_t off, size_t count)
 {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
 	struct pyra_device *pyra = hid_get_drvdata(dev_get_drvdata(dev));
 	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
 	int retval = 0;
@@ -381,7 +387,8 @@ static ssize_t pyra_sysfs_write_profile_buttons(struct file *fp,
 		struct kobject *kobj, struct bin_attribute *attr, char *buf,
 		loff_t off, size_t count)
 {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
 	struct pyra_device *pyra = hid_get_drvdata(dev_get_drvdata(dev));
 	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
 	int retval = 0;
@@ -417,7 +424,8 @@ static ssize_t pyra_sysfs_read_settings(struct file *fp,
 		struct kobject *kobj, struct bin_attribute *attr, char *buf,
 		loff_t off, size_t count)
 {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
 	struct pyra_device *pyra = hid_get_drvdata(dev_get_drvdata(dev));
 
 	if (off >= sizeof(struct pyra_settings))
@@ -437,7 +445,8 @@ static ssize_t pyra_sysfs_write_settings(struct file *fp,
 		struct kobject *kobj, struct bin_attribute *attr, char *buf,
 		loff_t off, size_t count)
 {
-	struct device *dev = container_of(kobj, struct device, kobj);
+	struct device *dev =
+			container_of(kobj, struct device, kobj)->parent->parent;
 	struct pyra_device *pyra = hid_get_drvdata(dev_get_drvdata(dev));
 	struct usb_device *usb_dev = interface_to_usbdev(to_usb_interface(dev));
 	int retval = 0;
@@ -469,255 +478,115 @@ static ssize_t pyra_sysfs_write_settings(struct file *fp,
 static ssize_t pyra_sysfs_show_actual_cpi(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	struct pyra_device *pyra = hid_get_drvdata(dev_get_drvdata(dev));
+	struct pyra_device *pyra =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
 	return snprintf(buf, PAGE_SIZE, "%d\n", pyra->actual_cpi);
 }
 
 static ssize_t pyra_sysfs_show_actual_profile(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	struct pyra_device *pyra = hid_get_drvdata(dev_get_drvdata(dev));
+	struct pyra_device *pyra =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
 	return snprintf(buf, PAGE_SIZE, "%d\n", pyra->actual_profile);
 }
 
 static ssize_t pyra_sysfs_show_firmware_version(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	struct pyra_device *pyra = hid_get_drvdata(dev_get_drvdata(dev));
+	struct pyra_device *pyra =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
 	return snprintf(buf, PAGE_SIZE, "%d\n", pyra->firmware_version);
 }
 
 static ssize_t pyra_sysfs_show_startup_profile(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	struct pyra_device *pyra = hid_get_drvdata(dev_get_drvdata(dev));
+	struct pyra_device *pyra =
+			hid_get_drvdata(dev_get_drvdata(dev->parent->parent));
 	return snprintf(buf, PAGE_SIZE, "%d\n", pyra->settings.startup_profile);
 }
 
-static DEVICE_ATTR(actual_cpi, 0440, pyra_sysfs_show_actual_cpi, NULL);
-
-static DEVICE_ATTR(actual_profile, 0440, pyra_sysfs_show_actual_profile, NULL);
-
-static DEVICE_ATTR(firmware_version, 0440,
-		pyra_sysfs_show_firmware_version, NULL);
-
-static DEVICE_ATTR(startup_profile, 0440,
-		pyra_sysfs_show_startup_profile, NULL);
-
-static struct attribute *pyra_attributes[] = {
-		&dev_attr_actual_cpi.attr,
-		&dev_attr_actual_profile.attr,
-		&dev_attr_firmware_version.attr,
-		&dev_attr_startup_profile.attr,
-		NULL
-};
-
-static struct attribute_group pyra_attribute_group = {
-		.attrs = pyra_attributes
+static struct device_attribute pyra_attributes[] = {
+	__ATTR(actual_cpi, 0440, pyra_sysfs_show_actual_cpi, NULL),
+	__ATTR(actual_profile, 0440, pyra_sysfs_show_actual_profile, NULL),
+	__ATTR(firmware_version, 0440,
+			pyra_sysfs_show_firmware_version, NULL),
+	__ATTR(startup_profile, 0440,
+			pyra_sysfs_show_startup_profile, NULL),
+	__ATTR_NULL
 };
 
-static struct bin_attribute pyra_profile_settings_attr = {
+static struct bin_attribute pyra_bin_attributes[] = {
+	{
 		.attr = { .name = "profile_settings", .mode = 0220 },
 		.size = sizeof(struct pyra_profile_settings),
 		.write = pyra_sysfs_write_profile_settings
-};
-
-static struct bin_attribute pyra_profile1_settings_attr = {
+	},
+	{
 		.attr = { .name = "profile1_settings", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_settings),
 		.read = pyra_sysfs_read_profile1_settings
-};
-
-static struct bin_attribute pyra_profile2_settings_attr = {
+	},
+	{
 		.attr = { .name = "profile2_settings", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_settings),
 		.read = pyra_sysfs_read_profile2_settings
-};
-
-static struct bin_attribute pyra_profile3_settings_attr = {
+	},
+	{
 		.attr = { .name = "profile3_settings", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_settings),
 		.read = pyra_sysfs_read_profile3_settings
-};
-
-static struct bin_attribute pyra_profile4_settings_attr = {
+	},
+	{
 		.attr = { .name = "profile4_settings", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_settings),
 		.read = pyra_sysfs_read_profile4_settings
-};
-
-static struct bin_attribute pyra_profile5_settings_attr = {
+	},
+	{
 		.attr = { .name = "profile5_settings", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_settings),
 		.read = pyra_sysfs_read_profile5_settings
-};
-
-static struct bin_attribute pyra_profile_buttons_attr = {
+	},
+	{
 		.attr = { .name = "profile_buttons", .mode = 0220 },
 		.size = sizeof(struct pyra_profile_buttons),
 		.write = pyra_sysfs_write_profile_buttons
-};
-
-static struct bin_attribute pyra_profile1_buttons_attr = {
+	},
+	{
 		.attr = { .name = "profile1_buttons", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_buttons),
 		.read = pyra_sysfs_read_profile1_buttons
-};
-
-static struct bin_attribute pyra_profile2_buttons_attr = {
+	},
+	{
 		.attr = { .name = "profile2_buttons", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_buttons),
 		.read = pyra_sysfs_read_profile2_buttons
-};
-
-static struct bin_attribute pyra_profile3_buttons_attr = {
+	},
+	{
 		.attr = { .name = "profile3_buttons", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_buttons),
 		.read = pyra_sysfs_read_profile3_buttons
-};
-
-static struct bin_attribute pyra_profile4_buttons_attr = {
+	},
+	{
 		.attr = { .name = "profile4_buttons", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_buttons),
 		.read = pyra_sysfs_read_profile4_buttons
-};
-
-static struct bin_attribute pyra_profile5_buttons_attr = {
+	},
+	{
 		.attr = { .name = "profile5_buttons", .mode = 0440 },
 		.size = sizeof(struct pyra_profile_buttons),
 		.read = pyra_sysfs_read_profile5_buttons
-};
-
-static struct bin_attribute pyra_settings_attr = {
+	},
+	{
 		.attr = { .name = "settings", .mode = 0660 },
 		.size = sizeof(struct pyra_settings),
 		.read = pyra_sysfs_read_settings,
 		.write = pyra_sysfs_write_settings
+	},
+	__ATTR_NULL
 };
 
-static int pyra_create_sysfs_attributes(struct usb_interface *intf)
-{
-	int retval;
-
-	retval = sysfs_create_group(&intf->dev.kobj, &pyra_attribute_group);
-	if (retval)
-		goto exit_1;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile_settings_attr);
-	if (retval)
-		goto exit_2;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile1_settings_attr);
-	if (retval)
-		goto exit_3;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile2_settings_attr);
-	if (retval)
-		goto exit_4;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile3_settings_attr);
-	if (retval)
-		goto exit_5;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile4_settings_attr);
-	if (retval)
-		goto exit_6;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile5_settings_attr);
-	if (retval)
-		goto exit_7;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile_buttons_attr);
-	if (retval)
-		goto exit_8;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile1_buttons_attr);
-	if (retval)
-		goto exit_9;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile2_buttons_attr);
-	if (retval)
-		goto exit_10;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile3_buttons_attr);
-	if (retval)
-		goto exit_11;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile4_buttons_attr);
-	if (retval)
-		goto exit_12;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_profile5_buttons_attr);
-	if (retval)
-		goto exit_13;
-
-	retval = sysfs_create_bin_file(&intf->dev.kobj,
-			&pyra_settings_attr);
-	if (retval)
-		goto exit_14;
-
-	return 0;
-
-exit_14:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile5_buttons_attr);
-exit_13:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile4_buttons_attr);
-exit_12:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile3_buttons_attr);
-exit_11:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile2_buttons_attr);
-exit_10:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile1_buttons_attr);
-exit_9:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile_buttons_attr);
-exit_8:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile5_settings_attr);
-exit_7:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile4_settings_attr);
-exit_6:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile3_settings_attr);
-exit_5:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile2_settings_attr);
-exit_4:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile1_settings_attr);
-exit_3:
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile_settings_attr);
-exit_2:
-	sysfs_remove_group(&intf->dev.kobj, &pyra_attribute_group);
-exit_1:
-	return retval;
-}
-
-static void pyra_remove_sysfs_attributes(struct usb_interface *intf)
-{
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_settings_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile5_buttons_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile4_buttons_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile3_buttons_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile2_buttons_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile1_buttons_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile_buttons_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile5_settings_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile4_settings_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile3_settings_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile2_settings_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile1_settings_attr);
-	sysfs_remove_bin_file(&intf->dev.kobj, &pyra_profile_settings_attr);
-	sysfs_remove_group(&intf->dev.kobj, &pyra_attribute_group);
-}
-
 static int pyra_init_pyra_device_struct(struct usb_device *usb_dev,
 		struct pyra_device *pyra)
 {
@@ -782,19 +651,13 @@ static int pyra_init_specials(struct hid_device *hdev)
 			goto exit_free;
 		}
 
-		retval = roccat_connect(hdev);
+		retval = roccat_connect(pyra_class, hdev);
 		if (retval < 0) {
 			dev_err(&hdev->dev, "couldn't init char dev\n");
 		} else {
 			pyra->chrdev_minor = retval;
 			pyra->roccat_claimed = 1;
 		}
-
-		retval = pyra_create_sysfs_attributes(intf);
-		if (retval) {
-			dev_err(&hdev->dev, "cannot create sysfs files\n");
-			goto exit_free;
-		}
 	} else {
 		hid_set_drvdata(hdev, NULL);
 	}
@@ -812,7 +675,6 @@ static void pyra_remove_specials(struct hid_device *hdev)
 
 	if (intf->cur_altsetting->desc.bInterfaceProtocol
 			== USB_INTERFACE_PROTOCOL_MOUSE) {
-		pyra_remove_sysfs_attributes(intf);
 		pyra = hid_get_drvdata(hdev);
 		if (pyra->roccat_claimed)
 			roccat_disconnect(pyra->chrdev_minor);
@@ -952,11 +814,24 @@ static struct hid_driver pyra_driver = {
 
 static int __init pyra_init(void)
 {
-	return hid_register_driver(&pyra_driver);
+	int retval;
+
+	/* class name has to be same as driver name */
+	pyra_class = class_create(THIS_MODULE, "pyra");
+	if (IS_ERR(pyra_class))
+		return PTR_ERR(pyra_class);
+	pyra_class->dev_attrs = pyra_attributes;
+	pyra_class->dev_bin_attrs = pyra_bin_attributes;
+
+	retval = hid_register_driver(&pyra_driver);
+	if (retval)
+		class_destroy(pyra_class);
+	return retval;
 }
 
 static void __exit pyra_exit(void)
 {
+	class_destroy(pyra_class);
 	hid_unregister_driver(&pyra_driver);
 }
 
diff --git a/drivers/hid/hid-roccat.c b/drivers/hid/hid-roccat.c
index 5a6879e..7bc9c8a 100644
--- a/drivers/hid/hid-roccat.c
+++ b/drivers/hid/hid-roccat.c
@@ -65,7 +65,6 @@ struct roccat_reader {
 };
 
 static int roccat_major;
-static struct class *roccat_class;
 static struct cdev roccat_cdev;
 
 static struct roccat_device *devices[ROCCAT_MAX_DEVICES];
@@ -295,12 +294,14 @@ EXPORT_SYMBOL_GPL(roccat_report_event);
 
 /*
  * roccat_connect() - create a char device for special event output
+ * @class: the class thats used to create the device. Meant to hold device
+ * specific sysfs attributes.
  * @hid: the hid device the char device should be connected to.
  *
  * Return value is minor device number in Range [0, ROCCAT_MAX_DEVICES] on
  * success, a negative error code on failure.
  */
-int roccat_connect(struct hid_device *hid)
+int roccat_connect(struct class *klass, struct hid_device *hid)
 {
 	unsigned int minor;
 	struct roccat_device *device;
@@ -326,7 +327,7 @@ int roccat_connect(struct hid_device *hid)
 		return -EINVAL;
 	}
 
-	device->dev = device_create(roccat_class, &hid->dev,
+	device->dev = device_create(klass, &hid->dev,
 			MKDEV(roccat_major, minor), NULL,
 			"%s%s%d", "roccat", hid->driver->name, minor);
 
@@ -367,7 +368,7 @@ void roccat_disconnect(int minor)
 
 	device->exist = 0; /* TODO exist maybe not needed */
 
-	device_destroy(roccat_class, MKDEV(roccat_major, minor));
+	device_destroy(device->dev->class, MKDEV(roccat_major, minor));
 
 	if (device->open) {
 		device->hid->ll_driver->close(device->hid);
@@ -402,13 +403,6 @@ static int __init roccat_init(void)
 		return retval;
 	}
 
-	roccat_class = class_create(THIS_MODULE, "roccat");
-	if (IS_ERR(roccat_class)) {
-		retval = PTR_ERR(roccat_class);
-		unregister_chrdev_region(dev_id, ROCCAT_MAX_DEVICES);
-		return retval;
-	}
-
 	cdev_init(&roccat_cdev, &roccat_ops);
 	cdev_add(&roccat_cdev, dev_id, ROCCAT_MAX_DEVICES);
 
@@ -420,7 +414,6 @@ static void __exit roccat_exit(void)
 	dev_t dev_id = MKDEV(roccat_major, 0);
 
 	cdev_del(&roccat_cdev);
-	class_destroy(roccat_class);
 	unregister_chrdev_region(dev_id, ROCCAT_MAX_DEVICES);
 }
 
diff --git a/drivers/hid/hid-roccat.h b/drivers/hid/hid-roccat.h
index 09e864e..5784281 100644
--- a/drivers/hid/hid-roccat.h
+++ b/drivers/hid/hid-roccat.h
@@ -16,11 +16,12 @@
 #include <linux/types.h>
 
 #if defined(CONFIG_HID_ROCCAT) || defined(CONFIG_HID_ROCCAT_MODULE)
-int roccat_connect(struct hid_device *hid);
+int roccat_connect(struct class *klass, struct hid_device *hid);
 void roccat_disconnect(int minor);
 int roccat_report_event(int minor, u8 const *data, int len);
 #else
-static inline int roccat_connect(struct hid_device *hid) { return -1; }
+static inline int roccat_connect(struct class *klass,
+		struct hid_device *hid) { return -1; }
 static inline void roccat_disconnect(int minor) {}
 static inline int roccat_report_event(int minor, u8 const *data, int len)
 {
-- 
1.7.2.3



