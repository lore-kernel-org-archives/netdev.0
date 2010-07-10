From: Narendra K <Narendra_K@dell.com>
Subject: [PATCH] Export SMBIOS provided firmware instance and label to sysfs
Date: Sat, 10 Jul 2010 12:14:45 -0500
Message-ID: <20100710171445.GA24568@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matt_domsch@dell.com, charles_rose@dell.com,
	jordan_hargrave@dell.com, vijay_nijhawan@dell.com
To: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:37761 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087Ab0GJROr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 13:14:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This post is in continuation of the discussions in the thread
http://marc.info/?l=linux-pci&m=127852633816819&w=3.

The patch has the following changes -

1.The patch would be compiled only if CONFIG_DMI is set
2.The .test method has been changed to use .is_visible which is part of
already existing infrastructure.

Please find the patch with the above changes here -

From: Narendra K <narendra_k@dell.com>
Subject: [PATCH] Export SMBIOS provided firmware instance and label to sysfs

This patch exports SMBIOS provided firmware instance and label
of onboard pci devices to sysfs

Signed-off-by: Jordan Hargrave <jordan_hargrave@dell.com>
Signed-off-by: Narendra K <narendra_k@dell.com>
---
 drivers/firmware/dmi_scan.c |   26 ++++++++
 drivers/pci/Makefile        |    3 +
 drivers/pci/pci-label.c     |  142 +++++++++++++++++++++++++++++++++++++++++++
 drivers/pci/pci-sysfs.c     |    5 ++
 drivers/pci/pci.h           |    9 +++
 include/linux/dmi.h         |    9 +++
 6 files changed, 194 insertions(+), 0 deletions(-)
 create mode 100644 drivers/pci/pci-label.c

diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index d464672..6894ce4 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -277,6 +277,29 @@ static void __init dmi_save_ipmi_device(const struct dmi_header *dm)
 	list_add_tail(&dev->list, &dmi_devices);
 }
 
+static void __init dmi_save_dev_onboard(int instance, int segment, int bus,
+					int devfn, const char *name)
+{
+	struct dmi_dev_onboard *onboard_dev;
+
+	onboard_dev = dmi_alloc(sizeof(*onboard_dev) + strlen(name) + 1);
+	if (!onboard_dev) {
+		printk(KERN_ERR "dmi_save_dev_onboard: out of memory.\n");
+		return;
+	}
+	onboard_dev->instance = instance;
+	onboard_dev->segment = segment;
+	onboard_dev->bus = bus;
+	onboard_dev->devfn = devfn;
+
+	strcpy((char *)&onboard_dev[1], name);
+	onboard_dev->dev.type = DMI_DEV_TYPE_DEV_ONBOARD;
+	onboard_dev->dev.name = (char *)&onboard_dev[1];
+	onboard_dev->dev.device_data = onboard_dev;
+
+	list_add(&onboard_dev->dev.list, &dmi_devices);
+}
+
 static void __init dmi_save_extended_devices(const struct dmi_header *dm)
 {
 	const u8 *d = (u8*) dm + 5;
@@ -285,6 +308,8 @@ static void __init dmi_save_extended_devices(const struct dmi_header *dm)
 	if ((*d & 0x80) == 0)
 		return;
 
+	dmi_save_dev_onboard(*(d+1), *(u16 *)(d+2), *(d+4), *(d+5),
+			     dmi_string_nosave(dm, *(d-1)));
 	dmi_save_one_device(*d & 0x7f, dmi_string_nosave(dm, *(d - 1)));
 }
 
@@ -333,6 +358,7 @@ static void __init dmi_decode(const struct dmi_header *dm, void *dummy)
 		break;
 	case 41:	/* Onboard Devices Extended Information */
 		dmi_save_extended_devices(dm);
+		break;
 	}
 }
 
diff --git a/drivers/pci/Makefile b/drivers/pci/Makefile
index 0b51857..dc1aa09 100644
--- a/drivers/pci/Makefile
+++ b/drivers/pci/Makefile
@@ -55,6 +55,9 @@ obj-$(CONFIG_MICROBLAZE) += setup-bus.o
 #
 obj-$(CONFIG_ACPI)    += pci-acpi.o
 
+# SMBIOS provided firmware instance and labels
+obj-$(CONFIG_DMI)    += pci-label.o
+
 # Cardbus & CompactPCI use setup-bus
 obj-$(CONFIG_HOTPLUG) += setup-bus.o
 
diff --git a/drivers/pci/pci-label.c b/drivers/pci/pci-label.c
new file mode 100644
index 0000000..d0eb964
--- /dev/null
+++ b/drivers/pci/pci-label.c
@@ -0,0 +1,142 @@
+/*
+ * Purpose: Export the firmware instance/index and label associated with
+ * a pci device to sysfs
+ * Copyright (C) 2010 Dell Inc.
+ * by Narendra K <Narendra_K@dell.com>,
+ * Jordan Hargrave <Jordan_Hargrave@dell.com>
+ *
+ * SMBIOS defines type 41 for onboard pci devices. This code retrieves
+ * the instance number and string from the type 41 record and exports
+ * it to sysfs.
+ *
+ * Please see http://linux.dell.com/wiki/index.php/Oss/libnetdevname for more
+ * information.
+ */
+
+#include <linux/dmi.h>
+#include <linux/sysfs.h>
+#include <linux/pci.h>
+#include <linux/pci_ids.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include "pci.h"
+
+static char smbios_attr[4096];
+
+enum smbios_attr_enum {
+	SMBIOS_ATTR_LABEL_SHOW = 1,
+	SMBIOS_ATTR_INSTANCE_SHOW,
+};
+
+static mode_t
+smbios_instance_string_exist(struct kobject *kobj, struct attribute *attr,
+			     int attribute)
+{
+	struct device *dev;
+	struct pci_dev *pdev;
+	const struct dmi_device *dmi;
+	struct dmi_dev_onboard *donboard;
+	int bus;
+	int devfn;
+
+	dev = container_of(kobj, struct device, kobj);
+	pdev = to_pci_dev(dev);
+
+	bus = pdev->bus->number;
+	devfn = pdev->devfn;
+
+	dmi = NULL;
+	while ((dmi = dmi_find_device(DMI_DEV_TYPE_DEV_ONBOARD,
+				      NULL, dmi)) != NULL) {
+		donboard = dmi->device_data;
+		if (donboard && donboard->bus == bus &&
+					donboard->devfn == devfn) {
+			if (attribute == SMBIOS_ATTR_INSTANCE_SHOW)
+				return scnprintf(smbios_attr, PAGE_SIZE,
+						"%d\n", donboard->instance);
+			else if (attribute == SMBIOS_ATTR_LABEL_SHOW)
+				return scnprintf(smbios_attr, PAGE_SIZE,
+						"%s\n", dmi->name);
+			return strlen(dmi->name);
+		}
+	}
+	return 0;
+}
+
+static ssize_t
+smbiosname_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	ssize_t result;
+	result = smbios_instance_string_exist(&dev->kobj, &attr->attr,
+					      SMBIOS_ATTR_LABEL_SHOW);
+	strncpy(buf, smbios_attr, result);
+	return result;
+}
+
+static ssize_t
+smbiosinstance_show(struct device *dev,
+		    struct device_attribute *attr, char *buf)
+{
+	ssize_t result;
+	result = smbios_instance_string_exist(&dev->kobj, &attr->attr,
+					      SMBIOS_ATTR_INSTANCE_SHOW);
+	strncpy(buf, smbios_attr, result);
+	return result;
+}
+
+static struct device_attribute smbios_attr_label = {
+	.attr = {.name = "label", .mode = 0444, .owner = THIS_MODULE},
+	.show = smbiosname_show,
+};
+
+static struct device_attribute smbios_attr_instance = {
+	.attr = {.name = "index", .mode = 0444, .owner = THIS_MODULE},
+	.show = smbiosinstance_show,
+};
+
+static struct attribute *smbios_attributes[] = {
+	&smbios_attr_label.attr,
+	&smbios_attr_instance.attr,
+	NULL,
+};
+
+static struct attribute_group smbios_attr_group = {
+	.attrs = smbios_attributes,
+	.is_visible = smbios_instance_string_exist,
+};
+
+static int
+pci_create_smbiosname_file(struct pci_dev *pdev)
+{
+	if (smbios_attr_group.is_visible &&
+		smbios_attr_group.is_visible(&pdev->dev.kobj, NULL, 0)) {
+		if (!sysfs_create_group(&pdev->dev.kobj, &smbios_attr_group))
+			return 0;
+	}
+	return -1;
+}
+
+static int
+pci_remove_smbiosname_file(struct pci_dev *pdev)
+{
+	if (smbios_attr_group.is_visible &&
+		smbios_attr_group.is_visible(&pdev->dev.kobj, NULL, 0)) {
+		sysfs_remove_group(&pdev->dev.kobj, &smbios_attr_group);
+		return 0;
+	}
+	return -1;
+}
+
+int pci_create_firmware_label_files(struct pci_dev *pdev)
+{
+	if (!pci_create_smbiosname_file(pdev))
+		return 0;
+	return -ENODEV;
+}
+
+int pci_remove_firmware_label_files(struct pci_dev *pdev)
+{
+	if (!pci_remove_smbiosname_file(pdev))
+		return 0;
+	return -ENODEV;
+}
diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index afd2fbf..01fd799 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -1132,6 +1132,8 @@ int __must_check pci_create_sysfs_dev_files (struct pci_dev *pdev)
 
 	pci_create_slot_links(pdev);
 
+	pci_create_firmware_label_files(pdev);
+
 	return 0;
 
 err_vga_file:
@@ -1201,6 +1203,9 @@ void pci_remove_sysfs_dev_files(struct pci_dev *pdev)
 		sysfs_remove_bin_file(&pdev->dev.kobj, pdev->rom_attr);
 		kfree(pdev->rom_attr);
 	}
+
+	pci_remove_firmware_label_files(pdev);
+
 }
 
 static int __init pci_sysfs_init(void)
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index f8077b3..089f402 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -11,6 +11,15 @@
 extern int pci_uevent(struct device *dev, struct kobj_uevent_env *env);
 extern int pci_create_sysfs_dev_files(struct pci_dev *pdev);
 extern void pci_remove_sysfs_dev_files(struct pci_dev *pdev);
+#ifndef CONFIG_DMI
+static inline int pci_create_firmware_label_files(struct pci_dev *pdev)
+{ return 0; }
+static inline int pci_remove_firmware_label_files(struct pci_dev *pdev)
+{ return 0; }
+#else
+extern int pci_create_firmware_label_files(struct pci_dev *pdev);
+extern int pci_remove_firmware_label_files(struct pci_dev *pdev);
+#endif
 extern void pci_cleanup_rom(struct pci_dev *dev);
 #ifdef HAVE_PCI_MMAP
 extern int pci_mmap_fits(struct pci_dev *pdev, int resno,
diff --git a/include/linux/dmi.h b/include/linux/dmi.h
index a8a3e1a..90e087f 100644
--- a/include/linux/dmi.h
+++ b/include/linux/dmi.h
@@ -20,6 +20,7 @@ enum dmi_device_type {
 	DMI_DEV_TYPE_SAS,
 	DMI_DEV_TYPE_IPMI = -1,
 	DMI_DEV_TYPE_OEM_STRING = -2,
+	DMI_DEV_TYPE_DEV_ONBOARD = -3,
 };
 
 struct dmi_header {
@@ -37,6 +38,14 @@ struct dmi_device {
 
 #ifdef CONFIG_DMI
 
+struct dmi_dev_onboard {
+	struct dmi_device dev;
+	int instance;
+	int segment;
+	int bus;
+	int devfn;
+};
+
 extern int dmi_check_system(const struct dmi_system_id *list);
 const struct dmi_system_id *dmi_first_match(const struct dmi_system_id *list);
 extern const char * dmi_get_system_info(int field);
-- 
1.6.5.2

With regards,
Narendra K
