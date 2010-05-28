From: "K, Narendra" <Narendra_K@dell.com>
Subject: [PATCH 1/2] Export firmware assigned labels of network devices to
 sysfs
Date: Fri, 28 May 2010 06:55:21 -0500
Message-ID: <20100528115520.GA24114@littleblue.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Domsch, Matt" <Matt_Domsch@dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@dell.com>,
	"Rose, Charles" <Charles_Rose@dell.com>,
	"Nijhawan, Vijay" <Vijay_Nijhawan@dell.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This patch is in continuation of an earlier discussion -

http://marc.info/?l=linux-netdev&m=126712978908314&w=3

The patch has the following review suggestions from the community incorporated -

1. The name of the attribute has been changed from "smbiosname" to "label" to hide
the implementation details.
2. The implementation has been moved to a new file drivers/pci/pci-label.c

The patch has following enhancements over the earlier patch -

1.Implement support for ACPI _DSM(Device Specific Method) provided by
the system firmware. The _DSM returns an index which is the instance number and
a label assigned to the network device by the system firmware. The onboard devices
will have lower indexes than the add-in devices. The patch exports both index and
the label to sysfs.

For Example -

cat /sys/class/net/eth0/device/label
Embedded Broadcom 5709C NIC 1

cat /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/index
1

Please refer to the PCI-SIG Draft ECN
"PCIe Device Labeling under Operating Systems Draft ECN" at this link -
http://www.pcisig.com/specifications/pciexpress/review_zone/.

It would be great to know your views on this ECN. Please let us know if you have
have any suggestions or changes.

2.If the system firmware does not provide ACPI _DSM, then implementation falls back
onto SMBIOS and exports SMBIOS labels to sysfs.

3. If SMBIOS is not available, no label will be created.

For an example user space implementation please look at this link -
http://linux.dell.com/wiki/index.php/Oss/libnetdevname

Please review -


From: Narendra K <Narendra_K@dell.com>

This patch exports the firmware assigned labels of network devices to
sysfs which could be used by user space.This helps in providing more
meaningful names to network devices such as

Embedded Broadcom 5709C NIC 1 - First on board netwrok interface

Signed-off-by: Jordan Hargrave <Jordan_Hargrave@dell.com>
Signed-off-by: Narendra K <Narendra_K@dell.com>
---
 drivers/firmware/dmi_scan.c |   24 +++++
 drivers/pci/Makefile        |    2 +-
 drivers/pci/pci-label.c     |  242 +++++++++++++++++++++++++++++++++++++++++++
 drivers/pci/pci-sysfs.c     |    6 +
 include/linux/dmi.h         |    9 ++
 include/linux/pci-label.h   |   38 +++++++
 6 files changed, 320 insertions(+), 1 deletions(-)
 create mode 100644 drivers/pci/pci-label.c
 create mode 100644 include/linux/pci-label.h

diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index d464672..7d8439b 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -277,6 +277,28 @@ static void __init dmi_save_ipmi_device(const struct dmi_header *dm)
        list_add_tail(&dev->list, &dmi_devices);
 }

+static void __init dmi_save_devslot(int id, int seg, int bus, int devfn, const char *name)
+{
+       struct dmi_devslot *slot;
+
+       slot = dmi_alloc(sizeof(*slot) + strlen(name) + 1);
+       if (!slot) {
+               printk(KERN_ERR "dmi_save_devslot: out of memory.\n");
+               return;
+       }
+       slot->id = id;
+       slot->seg = seg;
+       slot->bus = bus;
+       slot->devfn = devfn;
+
+       strcpy((char *)&slot[1], name);
+       slot->dev.type = DMI_DEV_TYPE_DEVSLOT;
+       slot->dev.name = (char *)&slot[1];
+       slot->dev.device_data = slot;
+
+       list_add(&slot->dev.list, &dmi_devices);
+}
+
 static void __init dmi_save_extended_devices(const struct dmi_header *dm)
 {
        const u8 *d = (u8*) dm + 5;
@@ -285,6 +307,7 @@ static void __init dmi_save_extended_devices(const struct dmi_header *dm)
        if ((*d & 0x80) == 0)
                return;

+       dmi_save_devslot(-1, *(u16 *)(d+2), *(d+4), *(d+5), dmi_string_nosave(dm, *(d-1)));
        dmi_save_one_device(*d & 0x7f, dmi_string_nosave(dm, *(d - 1)));
 }

@@ -333,6 +356,7 @@ static void __init dmi_decode(const struct dmi_header *dm, void *dummy)
                break;
        case 41:        /* Onboard Devices Extended Information */
                dmi_save_extended_devices(dm);
+               break;
        }
 }

diff --git a/drivers/pci/Makefile b/drivers/pci/Makefile
index 0b51857..69c503a 100644
--- a/drivers/pci/Makefile
+++ b/drivers/pci/Makefile
@@ -4,7 +4,7 @@

 obj-y          += access.o bus.o probe.o remove.o pci.o \
                        pci-driver.o search.o pci-sysfs.o rom.o setup-res.o \
-                       irq.o vpd.o
+                       irq.o vpd.o pci-label.o
 obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_SYSFS) += slot.o

diff --git a/drivers/pci/pci-label.c b/drivers/pci/pci-label.c
new file mode 100644
index 0000000..f3f4c37
--- /dev/null
+++ b/drivers/pci/pci-label.c
@@ -0,0 +1,242 @@
+/*
+ * File:       drivers/pci/pci-label.c
+ * Purpose:    Export the firmware label associated with a pci network interface
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
+#include <linux/pci-label.h>
+
+static ssize_t
+smbiosname_string_exists(struct device *dev, char *buf)
+{
+       struct pci_dev *pdev = to_pci_dev(dev);
+       const struct dmi_device *dmi;
+       struct dmi_devslot *dslot;
+       int bus;
+       int devfn;
+
+       bus = pdev->bus->number;
+       devfn = pdev->devfn;
+
+       dmi = NULL;
+       while ((dmi = dmi_find_device(DMI_DEV_TYPE_DEVSLOT, NULL, dmi)) != NULL) {
+               dslot = dmi->device_data;
+               if (dslot && dslot->bus == bus && dslot->devfn == devfn) {
+                       if (buf)
+                               return scnprintf(buf, PAGE_SIZE, "%s\n", dmi->name);
+                       return strlen(dmi->name);
+               }
+       }
+
+       return 0;
+}
+
+static ssize_t
+smbiosname_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+       return smbiosname_string_exists(dev, buf);
+}
+
+struct smbios_attribute smbios_attr_label = {
+       .attr = {.name = __stringify(label), .mode = 0444, .owner = THIS_MODULE},
+       .show = smbiosname_show,
+       .test = smbiosname_string_exists,
+};
+
+static int
+pci_create_smbiosname_file(struct pci_dev *pdev)
+{
+       if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL)) {
+               sysfs_create_file(&pdev->dev.kobj, &smbios_attr_label.attr);
+               return 0;
+       }
+       return -1;
+}
+
+static int
+pci_remove_smbiosname_file(struct pci_dev *pdev)
+{
+       if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL)) {
+               sysfs_remove_file(&pdev->dev.kobj, &smbios_attr_label.attr);
+               return 0;
+       }
+       return -1;
+}
+
+static const char dell_dsm_uuid[] = {
+       0xD0, 0x37, 0xC9, 0xE5, 0x53, 0x35, 0x7A, 0x4D,
+       0x91, 0x17, 0xEA, 0x4D, 0x19, 0xC3, 0x43, 0x4D
+};
+
+
+static int
+dsm_get_label(acpi_handle handle, int func,
+              struct acpi_buffer *output,
+              char *buf, char *attribute)
+{
+       struct acpi_object_list input;
+       union acpi_object params[4];
+       union acpi_object *obj;
+       int len = 0;
+
+       int err;
+
+       input.count = 4;
+       input.pointer = params;
+       params[0].type = ACPI_TYPE_BUFFER;
+       params[0].buffer.length = sizeof(dell_dsm_uuid);
+       params[0].buffer.pointer = (char *)dell_dsm_uuid;
+       params[1].type = ACPI_TYPE_INTEGER;
+       params[1].integer.value = 0x02;
+       params[2].type = ACPI_TYPE_INTEGER;
+       params[2].integer.value = func;
+       params[3].type = ACPI_TYPE_PACKAGE;
+       params[3].package.count = 0;
+       params[3].package.elements = NULL;
+
+       err = acpi_evaluate_object(handle, "_DSM", &input, output);
+       if (err) {
+               printk(KERN_INFO "failed to evaulate _DSM\n");
+               return -1;
+       }
+
+       obj = (union acpi_object *)output->pointer;
+
+       switch (obj->type) {
+       case ACPI_TYPE_PACKAGE:
+               if (obj->package.count == 2) {
+                       len = obj->package.elements[0].integer.value;
+                       if (buf) {
+                               if (!strncmp(attribute, "index", strlen(attribute)))
+                                       scnprintf(buf, PAGE_SIZE, "%lu\n",
+                                       obj->package.elements[0].integer.value);
+                               else
+                                       scnprintf(buf, PAGE_SIZE, "%s\n",
+                                       obj->package.elements[1].string.pointer);
+                               kfree(output->pointer);
+                               return strlen(buf);
+                       }
+               }
+               kfree(output->pointer);
+               return len;
+       break;
+       default:
+               return -1;
+       }
+}
+
+static ssize_t
+acpi_index_string_exist(struct device *dev, char *buf, char *attribute)
+{
+       struct pci_dev *pdev = to_pci_dev(dev);
+
+       struct acpi_buffer output = {ACPI_ALLOCATE_BUFFER, NULL};
+       acpi_handle handle;
+       int length;
+       int is_addin_card = 0;
+
+       if ((pdev->class >> 16) != PCI_BASE_CLASS_NETWORK)
+               return -1;
+
+       handle = DEVICE_ACPI_HANDLE(dev);
+
+       if (!handle) {
+               /*
+                * The device is an add-in network controller and does have
+                * a valid handle. Try until we get the handle for the parent
+                * bridge
+                */
+               struct pci_bus *pbus;
+               for (pbus = pdev->bus; pbus; pbus = pbus->parent) {
+                       handle = DEVICE_ACPI_HANDLE(&(pbus->self->dev));
+                       if (handle)
+                               break;
+
+               }
+       }
+
+       if ((length = dsm_get_label(handle, DELL_DSM_NETWORK,
+                                   &output, buf, attribute)) < 0)
+               return -1;
+
+       return length;
+}
+
+static ssize_t
+acpilabel_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+       return acpi_index_string_exist(dev, buf, "label");
+}
+
+static ssize_t
+acpiindex_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+       return acpi_index_string_exist(dev, buf, "index");
+}
+
+struct acpi_attribute acpi_attr_label = {
+       .attr = {.name = __stringify(label), .mode = 0444, .owner = THIS_MODULE},
+       .show = acpilabel_show,
+       .test = acpi_index_string_exist,
+};
+
+struct acpi_attribute acpi_attr_index = {
+       .attr = {.name = __stringify(index), .mode = 0444, .owner = THIS_MODULE},
+       .show = acpiindex_show,
+       .test = acpi_index_string_exist,
+};
+
+static int
+pci_create_acpi_index_label_files(struct pci_dev *pdev)
+{
+       if (acpi_attr_label.test && acpi_attr_label.test(&pdev->dev, NULL) > 0) {
+               sysfs_create_file(&pdev->dev.kobj, &acpi_attr_label.attr);
+               sysfs_create_file(&pdev->dev.kobj, &acpi_attr_index.attr);
+               return 0;
+       }
+       return -1;
+}
+
+static int
+pci_remove_acpi_index_label_files(struct pci_dev *pdev)
+{
+       if (acpi_attr_label.test && acpi_attr_label.test(&pdev->dev, NULL) > 0) {
+               sysfs_remove_file(&pdev->dev.kobj, &acpi_attr_label.attr);
+               sysfs_remove_file(&pdev->dev.kobj, &acpi_attr_index.attr);
+               return 0;
+       }
+       return -1;
+}
+
+int pci_create_acpi_attr_files(struct pci_dev *pdev)
+{
+       if (!pci_create_acpi_index_label_files(pdev))
+               return 0;
+       if (!pci_create_smbiosname_file(pdev))
+               return 0;
+       return -ENODEV;
+}
+EXPORT_SYMBOL(pci_create_acpi_attr_files);
+
+int pci_remove_acpi_attr_files(struct pci_dev *pdev)
+{
+       if (!pci_remove_acpi_index_label_files(pdev))
+               return 0;
+       if (!pci_remove_smbiosname_file(pdev))
+               return 0;
+       return -ENODEV;
+
+}
+EXPORT_SYMBOL(pci_remove_acpi_attr_files);
+
diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index fad9398..30fa62b 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -23,6 +23,7 @@
 #include <linux/mm.h>
 #include <linux/capability.h>
 #include <linux/pci-aspm.h>
+#include <linux/pci-label.h>
 #include <linux/slab.h>
 #include "pci.h"

@@ -1073,6 +1074,8 @@ int __must_check pci_create_sysfs_dev_files (struct pci_dev *pdev)
        if (retval)
                goto err_vga_file;

+       pci_create_acpi_attr_files(pdev);
+
        return 0;

 err_vga_file:
@@ -1140,6 +1143,9 @@ void pci_remove_sysfs_dev_files(struct pci_dev *pdev)
                sysfs_remove_bin_file(&pdev->dev.kobj, pdev->rom_attr);
                kfree(pdev->rom_attr);
        }
+
+       pci_remove_acpi_attr_files(pdev);
+
 }

 static int __init pci_sysfs_init(void)
diff --git a/include/linux/dmi.h b/include/linux/dmi.h
index a8a3e1a..cc57c3a 100644
--- a/include/linux/dmi.h
+++ b/include/linux/dmi.h
@@ -20,6 +20,7 @@ enum dmi_device_type {
        DMI_DEV_TYPE_SAS,
        DMI_DEV_TYPE_IPMI = -1,
        DMI_DEV_TYPE_OEM_STRING = -2,
+       DMI_DEV_TYPE_DEVSLOT = -3,
 };

 struct dmi_header {
@@ -37,6 +38,14 @@ struct dmi_device {

 #ifdef CONFIG_DMI

+struct dmi_devslot {
+       struct dmi_device dev;
+       int id;
+       int seg;
+       int bus;
+       int devfn;
+};
+
 extern int dmi_check_system(const struct dmi_system_id *list);
 const struct dmi_system_id *dmi_first_match(const struct dmi_system_id *list);
 extern const char * dmi_get_system_info(int field);
diff --git a/include/linux/pci-label.h b/include/linux/pci-label.h
new file mode 100644
index 0000000..e9a4dfb
--- /dev/null
+++ b/include/linux/pci-label.h
@@ -0,0 +1,38 @@
+/*
+ * File                include/linux/pci-label.h
+ * Copyright (C) 2010 Dell Inc.
+ * by Narendra K <Narendra_K@dell.com>, Jordan Hargrave <Jordan_Hargrave@dell.com>
+ */
+
+#ifndef _PCI_LABEL_H_
+#define _PCI_LABEL_H_
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
+
+struct smbios_attribute {
+       struct attribute attr;
+       ssize_t (*show) (struct device *dev, char *buf);
+       ssize_t (*test) (struct device *dev, char *buf);
+};
+
+struct acpi_attribute {
+       struct attribute attr;
+       ssize_t (*show) (struct device *dev, char *buf);
+       ssize_t (*test) (struct device *dev, char *buf);
+};
+
+#define DELL_DSM_NETWORK       0x07
+
+extern int pci_create_acpi_attr_files(struct pci_dev *pdev);
+extern int pci_remove_acpi_attr_files(struct pci_dev *pdev);
+
+#endif  /* _PCI_LABEL_H_ */
+
--
1.6.5.2


With regards,
Narendra K
