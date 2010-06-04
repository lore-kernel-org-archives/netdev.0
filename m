From: Narendra K <Narendra_K@dell.com>
Subject: Re: [PATCH V3 1/2] Export firmware assigned labels of network devices to sysfs
Date: Fri, 4 Jun 2010 16:07:33 -0500
Message-ID: <20100604210733.GA22620@auslistsprd01.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612918@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	jordan_hargrave@dell.com, charles_rose@dell.com
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:34017 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755329Ab0FDVHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 17:07:35 -0400
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE612918@blrx3m08.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Narendra K
> Sent: Friday, June 04, 2010 2:37 AM
> To: greg@kroah.com
> Cc: netdev@vger.kernel.org; linux-hotplug@vger.kernel.org; linux-pci@vger.kernel.org; Domsch, Matt
> Subject: Re: [PATCH V2 1/2] Export firmware assigned labels of network devices to sysfs
> 
> In addition to these changes there are a coulple of changes i have done -
> 
> 1.Removed the check for network devices and evaulate _DSM for any pci device
> that has _DSM defined in adherence to the spec.
> 
> 2.Renamed the functions pci_create,remove-acpi_attr_files to 
> pci_create,remove_firmware_label_files.
> 
> 3.Added checks for conditional compilation of if CONFIG_ACPI || CONFIG_DMI
> 

V2 -> V3: I had missed fixing warnings in the patch. Please find the V3
of the patch with the warnings fixed -


From: Narendra K <narendra_k@dell.com>
Subject: [PATCH V3 1/2] Export firmware assigned labels of pci devices to sysfs

This patch exports the firmware assigned labels of pci devices to
sysfs which could be used by user space.

Signed-off-by: Jordan Hargrave <jordan_hargrave@dell.com>
Signed-off-by: Narendra K <narendra_k@dell.com>
---
 drivers/firmware/dmi_scan.c |   24 ++++
 drivers/pci/Makefile        |    2 +-
 drivers/pci/pci-label.c     |  274 +++++++++++++++++++++++++++++++++++++++++++
 drivers/pci/pci-sysfs.c     |    5 +
 drivers/pci/pci.h           |    2 +
 include/linux/dmi.h         |    9 ++
 6 files changed, 315 insertions(+), 1 deletions(-)
 create mode 100644 drivers/pci/pci-label.c

diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index d464672..7d8439b 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -277,6 +277,28 @@ static void __init dmi_save_ipmi_device(const struct dmi_header *dm)
 	list_add_tail(&dev->list, &dmi_devices);
 }
 
+static void __init dmi_save_devslot(int id, int seg, int bus, int devfn, const char *name)
+{
+	struct dmi_devslot *slot;
+
+	slot = dmi_alloc(sizeof(*slot) + strlen(name) + 1);
+	if (!slot) {
+		printk(KERN_ERR "dmi_save_devslot: out of memory.\n");
+		return;
+	}	
+	slot->id = id;
+	slot->seg = seg;
+	slot->bus = bus;
+	slot->devfn = devfn;
+
+	strcpy((char *)&slot[1], name);
+	slot->dev.type = DMI_DEV_TYPE_DEVSLOT;
+	slot->dev.name = (char *)&slot[1];
+	slot->dev.device_data = slot;
+
+	list_add(&slot->dev.list, &dmi_devices);
+}
+
 static void __init dmi_save_extended_devices(const struct dmi_header *dm)
 {
 	const u8 *d = (u8*) dm + 5;
@@ -285,6 +307,7 @@ static void __init dmi_save_extended_devices(const struct dmi_header *dm)
 	if ((*d & 0x80) == 0)
 		return;
 
+	dmi_save_devslot(-1, *(u16 *)(d+2), *(d+4), *(d+5), dmi_string_nosave(dm, *(d-1)));
 	dmi_save_one_device(*d & 0x7f, dmi_string_nosave(dm, *(d - 1)));
 }
 
@@ -333,6 +356,7 @@ static void __init dmi_decode(const struct dmi_header *dm, void *dummy)
 		break;
 	case 41:	/* Onboard Devices Extended Information */
 		dmi_save_extended_devices(dm);
+		break;
 	}
 }
 
diff --git a/drivers/pci/Makefile b/drivers/pci/Makefile
index 0b51857..69c503a 100644
--- a/drivers/pci/Makefile
+++ b/drivers/pci/Makefile
@@ -4,7 +4,7 @@
 
 obj-y		+= access.o bus.o probe.o remove.o pci.o \
 			pci-driver.o search.o pci-sysfs.o rom.o setup-res.o \
-			irq.o vpd.o
+			irq.o vpd.o pci-label.o
 obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_SYSFS) += slot.o
 
diff --git a/drivers/pci/pci-label.c b/drivers/pci/pci-label.c
new file mode 100644
index 0000000..d6e0e9b
--- /dev/null
+++ b/drivers/pci/pci-label.c
@@ -0,0 +1,274 @@
+/*
+ * Purpose: Export the firmware label associated with a pci network interface
+ * device to sysfs
+ * Copyright (C) 2010 Dell Inc.
+ * by Narendra K <Narendra_K@dell.com>, Jordan Hargrave <Jordan_Hargrave@dell.com>
+ *
+ * This code checks if the pci network device has a related ACPI _DSM. If
+ * available, the code calls the _DSM to retrieve the index and string and
+ * exports them to sysfs. If the ACPI _DSM is not available, it falls back on
+ * SMBIOS. SMBIOS defines type 41 for onboard pci devices. This code retrieves
+ * strings associated with the type 41 and exports it to sysfs.
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
+#include <linux/acpi.h>
+#include <linux/pci-acpi.h>
+#include <acpi/acpi_drivers.h>
+#include <acpi/acpi_bus.h>
+#include "pci.h"
+
+#define	DEVICE_LABEL_DSM	0x07
+
+#if defined CONFIG_DMI
+
+struct smbios_attribute {
+	struct attribute attr;
+	ssize_t (*show) (struct device *dev, struct device_attribute *, char *buf);
+	ssize_t (*test) (struct device *dev, char *buf);
+};
+
+static ssize_t
+smbiosname_string_exists(struct device *dev, char *buf)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+  	const struct dmi_device *dmi;
+  	struct dmi_devslot *dslot;
+  	int bus;
+  	int devfn;
+
+  	bus = pdev->bus->number;
+  	devfn = pdev->devfn;
+
+  	dmi = NULL;
+  	while ((dmi = dmi_find_device(DMI_DEV_TYPE_DEVSLOT, NULL, dmi)) != NULL) {
+    		dslot = dmi->device_data;
+    		if (dslot && dslot->bus == bus && dslot->devfn == devfn) {
+			if (buf)
+      				return scnprintf(buf, PAGE_SIZE, "%s\n", dmi->name);
+			return strlen(dmi->name);
+		}
+	}
+	
+	return 0;
+}
+
+static ssize_t
+smbiosname_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	return smbiosname_string_exists(dev, buf);
+}
+
+struct smbios_attribute smbios_attr_label = {
+	.attr = {.name = "label", .mode = 0444, .owner = THIS_MODULE},
+	.show = smbiosname_show,
+	.test = smbiosname_string_exists,
+};
+
+static int 
+pci_create_smbiosname_file(struct pci_dev *pdev)
+{
+	if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL)) {
+		if (sysfs_create_file(&pdev->dev.kobj, &smbios_attr_label.attr))
+			return -1;
+		return 0;
+	}
+	return -1;	
+}
+
+static int 
+pci_remove_smbiosname_file(struct pci_dev *pdev)
+{
+	if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL)) {
+		sysfs_remove_file(&pdev->dev.kobj, &smbios_attr_label.attr);
+		return 0;
+	}
+	return -1;
+}
+#else
+static inline int 
+pci_create_smbiosname_file(struct pci_dev *pdev)
+{
+	return -1;
+}
+
+static inline int 
+pci_remove_smbiosname_file(struct pci_dev *pdev)
+{
+	return -1;
+}
+#endif
+
+#if defined CONFIG_ACPI
+
+static const char device_label_dsm_uuid[] = {
+	0xD0, 0x37, 0xC9, 0xE5, 0x53, 0x35, 0x7A, 0x4D,
+	0x91, 0x17, 0xEA, 0x4D, 0x19, 0xC3, 0x43, 0x4D
+};
+
+struct acpi_attribute {
+	struct attribute attr;
+	ssize_t (*show) (struct device *dev, struct device_attribute *attr, char *buf);
+	ssize_t (*test) (struct device *dev, char *buf, char *attribute);
+};
+
+static int
+dsm_get_label(acpi_handle handle, int func, 
+              struct acpi_buffer *output, 
+              char *buf, char *attribute)
+{
+	struct acpi_object_list input;
+	union acpi_object params[4];
+	union acpi_object *obj; 
+	int len = 0;
+
+	int err;
+
+	input.count = 4;
+	input.pointer = params;
+	params[0].type = ACPI_TYPE_BUFFER;
+	params[0].buffer.length = sizeof(device_label_dsm_uuid);
+	params[0].buffer.pointer = (char *)device_label_dsm_uuid;
+	params[1].type = ACPI_TYPE_INTEGER;
+	params[1].integer.value = 0x02;
+	params[2].type = ACPI_TYPE_INTEGER;
+	params[2].integer.value = func;
+	params[3].type = ACPI_TYPE_PACKAGE;
+	params[3].package.count = 0;
+	params[3].package.elements = NULL;
+
+	err = acpi_evaluate_object(handle, "_DSM", &input, output);
+	if (err) 
+		return -1;
+	
+	
+	obj = (union acpi_object *)output->pointer;
+
+	switch (obj->type) {
+	case ACPI_TYPE_PACKAGE:
+		if (obj->package.count != 2) 
+			break;
+		len = obj->package.elements[0].integer.value;
+		if (buf) {
+			if (!strncmp(attribute, "index", strlen(attribute)))
+				scnprintf(buf, PAGE_SIZE, "%llu\n", 
+				obj->package.elements[0].integer.value);
+			else
+				scnprintf(buf, PAGE_SIZE, "%s\n", 
+				obj->package.elements[1].string.pointer);
+			kfree(output->pointer);
+			return strlen(buf);
+		}
+		kfree(output->pointer);
+		return len;
+	break;
+	default:
+		kfree(output->pointer);
+	}
+	return -1;
+}	
+
+static ssize_t
+acpi_index_string_exist(struct device *dev, char *buf, char *attribute)
+{
+	struct acpi_buffer output = {ACPI_ALLOCATE_BUFFER, NULL};
+	acpi_handle handle;
+	int length;
+	
+	handle = DEVICE_ACPI_HANDLE(dev);
+
+	if (!handle) 
+		return -1;
+
+	if ((length = dsm_get_label(handle, DEVICE_LABEL_DSM, 
+				    &output, buf, attribute)) < 0)
+		return -1;
+
+	return length;
+}
+	
+static ssize_t
+acpilabel_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	return acpi_index_string_exist(dev, buf, "label");
+}
+
+static ssize_t
+acpiindex_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	return acpi_index_string_exist(dev, buf, "index");
+}
+
+struct acpi_attribute acpi_attr_label = {
+	.attr = {.name = "label", .mode = 0444, .owner = THIS_MODULE},
+	.show = acpilabel_show,
+	.test = acpi_index_string_exist,
+};
+
+struct acpi_attribute acpi_attr_index = {
+	.attr = {.name = "index", .mode = 0444, .owner = THIS_MODULE},
+	.show = acpiindex_show,
+	.test = acpi_index_string_exist,
+};
+
+static int
+pci_create_acpi_index_label_files(struct pci_dev *pdev)
+{
+	if (acpi_attr_label.test && acpi_attr_label.test(&pdev->dev, NULL, NULL) > 0) {
+		if (sysfs_create_file(&pdev->dev.kobj, &acpi_attr_label.attr)) 
+			return -1;
+		if (sysfs_create_file(&pdev->dev.kobj, &acpi_attr_index.attr)) 
+			return -1;
+		return 0;
+	}
+	return -1;
+}
+
+static int
+pci_remove_acpi_index_label_files(struct pci_dev *pdev)
+{
+	if (acpi_attr_label.test && acpi_attr_label.test(&pdev->dev, NULL, NULL) > 0) {
+		sysfs_remove_file(&pdev->dev.kobj, &acpi_attr_label.attr);
+		sysfs_remove_file(&pdev->dev.kobj, &acpi_attr_index.attr);
+		return 0;
+	}
+	return -1;
+}
+#else
+static inline int
+pci_create_acpi_index_label_files(struct pci_dev *pdev)
+{
+	return -1;
+}
+
+static inline int
+pci_remove_acpi_index_label_files(struct pci_dev *pdev)
+{
+	return -1;
+}
+#endif
+
+int pci_create_firmware_label_files(struct pci_dev *pdev)
+{
+	if (!pci_create_acpi_index_label_files(pdev))
+		return 0;
+	if (!pci_create_smbiosname_file(pdev))
+		return 0;
+	return -ENODEV;
+}
+
+int pci_remove_firmware_label_files(struct pci_dev *pdev)
+{
+	if (!pci_remove_acpi_index_label_files(pdev))
+		return 0;
+	if (!pci_remove_smbiosname_file(pdev))
+		return 0;
+	return -ENODEV;
+}
diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index fad9398..4ed517f 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -1073,6 +1073,8 @@ int __must_check pci_create_sysfs_dev_files (struct pci_dev *pdev)
 	if (retval)
 		goto err_vga_file;
 
+	pci_create_firmware_label_files(pdev);
+
 	return 0;
 
 err_vga_file:
@@ -1140,6 +1142,9 @@ void pci_remove_sysfs_dev_files(struct pci_dev *pdev)
 		sysfs_remove_bin_file(&pdev->dev.kobj, pdev->rom_attr);
 		kfree(pdev->rom_attr);
 	}
+
+	pci_remove_firmware_label_files(pdev);
+
 }
 
 static int __init pci_sysfs_init(void)
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index 4eb10f4..f223283 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -11,6 +11,8 @@
 extern int pci_uevent(struct device *dev, struct kobj_uevent_env *env);
 extern int pci_create_sysfs_dev_files(struct pci_dev *pdev);
 extern void pci_remove_sysfs_dev_files(struct pci_dev *pdev);
+extern int pci_create_firmware_label_files(struct pci_dev *pdev);
+extern int pci_remove_firmware_label_files(struct pci_dev *pdev);
 extern void pci_cleanup_rom(struct pci_dev *dev);
 #ifdef HAVE_PCI_MMAP
 extern int pci_mmap_fits(struct pci_dev *pdev, int resno,
diff --git a/include/linux/dmi.h b/include/linux/dmi.h
index a8a3e1a..cc57c3a 100644
--- a/include/linux/dmi.h
+++ b/include/linux/dmi.h
@@ -20,6 +20,7 @@ enum dmi_device_type {
 	DMI_DEV_TYPE_SAS,
 	DMI_DEV_TYPE_IPMI = -1,
 	DMI_DEV_TYPE_OEM_STRING = -2,
+	DMI_DEV_TYPE_DEVSLOT = -3,
 };
 
 struct dmi_header {
@@ -37,6 +38,14 @@ struct dmi_device {
 
 #ifdef CONFIG_DMI
 
+struct dmi_devslot {
+	struct dmi_device dev;
+	int id;
+	int seg;
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
