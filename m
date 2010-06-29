From: Narendra K <Narendra_K@dell.com>
Subject: Re: [PATCH 1/2] Export firmware assigned labels of network devices to sysfs
Date: Tue, 29 Jun 2010 11:28:18 -0500
Message-ID: <20100629162818.GA17099@auslistsprd01.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612AB6@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, jordan_hargrave@dell.com,
	charles_rose@dell.com, vijay_nijhawan@dell.com
To: greg@kroah.com, matt_domsch@dell.com
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE612AB6@blrx3m08.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Greg KH [mailto:greg@kroah.com] 
> Sent: Wednesday, June 09, 2010 8:33 PM
> To: Domsch, Matt
> Cc: K, Narendra; netdev@vger.kernel.org; linux-hotplug@vger.kernel.org;
> linux-pci@vger.kernel.org; Hargrave, Jordan; Rose, Charles; Nijhawan,
> Vijay
> Subject: Re: [PATCH 1/2] Export firmware assigned labels of network
> devices to sysfs
> 
> On Tue, Jun 08, 2010 at 11:17:09PM -0500, Matt Domsch wrote:
> > On Fri, May 28, 2010 at 11:51:40PM -0500, Domsch, Matt wrote:
> > > On Fri, May 28, 2010 at 05:27:45PM -0500, Greg KH wrote:
> > > > Care to post that ECN publically?  And no, the Linux Foundation
> does not
> > > > have a PCI-SIG membership, the PCI-SIG keeps forbidding it.  Other
> > > > operating systems are allowed to join but not Linux.  Strange but
> > > > true...
> > > 
> > > I'm looking into it, and should know more next week.
> > 
> > I'm advised that I cannot post the ECN publically, due to it being an
> > in-progress work item of a SIG working group, and therefore falls
> > under the confidentiality rules that SIG members agree to.  Members of
> > the PCI SIG have access, which unfortunately is not everyone.
> 
> Then we can't properly review this, sorry.  How about waiting until the
> ECN is finalized?  Then we could review and possibly accept this.
> 

As the ACPI ECR might take some time to become public, we have split the
original patch into SMBIOS and ACPI parts and would want to get the SMBIOS
part to get reviewed/accepted. Once the ECR is publicly available, we
would submit the ACPI specific patch.

Please find the patch addressing the SMBIOS part below -

From: Narendra K <narendra_k@dell.com>
Subject: [PATCH] Export SMBIOS provided firmware instance and lable to sysfs

This patch exports SMBIOS provided firmware instance and label of
onboard pci devices to sysfs

Signed-off-by: Jordan Hargrave <jordan_hargrave@dell.com>
Signed-off-by: Narendra K <narendra_k@dell.com>
---
 drivers/firmware/dmi_scan.c |   25 ++++++++
 drivers/pci/Makefile        |    2 +-
 drivers/pci/pci-label.c     |  140 +++++++++++++++++++++++++++++++++++++++++++
 drivers/pci/pci-sysfs.c     |    5 ++
 drivers/pci/pci.h           |    2 +
 include/linux/dmi.h         |    9 +++
 6 files changed, 182 insertions(+), 1 deletions(-)
 create mode 100644 drivers/pci/pci-label.c

diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index d464672..ce73fcc 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -277,6 +277,29 @@ static void __init dmi_save_ipmi_device(const struct dmi_header *dm)
 	list_add_tail(&dev->list, &dmi_devices);
 }
 
+static void __init dmi_save_dev_onboard(int instance, int segment, int bus, 
+                                    int devfn, const char *name)
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
@@ -285,6 +308,7 @@ static void __init dmi_save_extended_devices(const struct dmi_header *dm)
 	if ((*d & 0x80) == 0)
 		return;
 
+	dmi_save_dev_onboard(*(d+1), *(u16 *)(d+2), *(d+4), *(d+5), dmi_string_nosave(dm, *(d-1)));
 	dmi_save_one_device(*d & 0x7f, dmi_string_nosave(dm, *(d - 1)));
 }
 
@@ -333,6 +357,7 @@ static void __init dmi_decode(const struct dmi_header *dm, void *dummy)
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
index 0000000..0f824d6
--- /dev/null
+++ b/drivers/pci/pci-label.c
@@ -0,0 +1,140 @@
+/*
+ * Purpose: Export the firmware instance/index and label associated with 
+ * a pci device to sysfs
+ * Copyright (C) 2010 Dell Inc.
+ * by Narendra K <Narendra_K@dell.com>, Jordan Hargrave <Jordan_Hargrave@dell.com>
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
+#include "pci.h"
+
+#ifndef CONFIG_DMI
+
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
+
+#else
+
+struct smbios_attribute {
+	struct attribute attr;
+	ssize_t (*show) (struct device *dev, struct device_attribute *, char *buf);
+	ssize_t (*test) (struct device *dev, char *buf, char *attribute);
+};
+
+static ssize_t
+smbios_instance_string_exist(struct device *dev, char *buf, char *attribute)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+  	const struct dmi_device *dmi;
+  	struct dmi_dev_onboard *donboard;
+  	int bus;
+  	int devfn;
+	int attribute_is_instance = 0;
+
+  	bus = pdev->bus->number;
+  	devfn = pdev->devfn;
+
+	if (attribute && !strncmp(attribute, "instance", strlen(attribute)))
+		attribute_is_instance=1;
+
+  	dmi = NULL;
+  	while ((dmi = dmi_find_device(DMI_DEV_TYPE_DEV_ONBOARD, NULL, dmi)) != NULL) {
+    		donboard = dmi->device_data;
+    		if (donboard && donboard->bus == bus && donboard->devfn == devfn) {
+			if (buf) {
+				if (attribute_is_instance)
+      					return scnprintf(buf, PAGE_SIZE, 
+							 "%d\n", donboard->instance);
+				else
+      					return scnprintf(buf, PAGE_SIZE, 
+							 "%s\n", dmi->name);
+			}
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
+	return smbios_instance_string_exist(dev, buf, "label");
+}
+
+static ssize_t
+smbiosinstance_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	return smbios_instance_string_exist(dev, buf, "instance");
+}
+
+struct smbios_attribute smbios_attr_label = {
+	.attr = {.name = "label", .mode = 0444, .owner = THIS_MODULE},
+	.show = smbiosname_show,
+	.test = smbios_instance_string_exist,
+};
+
+struct smbios_attribute smbios_attr_instance = {
+	.attr = {.name = "index", .mode = 0444, .owner = THIS_MODULE},
+	.show = smbiosinstance_show,
+	.test = smbios_instance_string_exist,
+};
+
+static int 
+pci_create_smbiosname_file(struct pci_dev *pdev)
+{
+	if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL, NULL)) {
+		if (sysfs_create_file(&pdev->dev.kobj, &smbios_attr_label.attr))
+			return -1;
+		if (sysfs_create_file(&pdev->dev.kobj, &smbios_attr_instance.attr))
+			return -1;
+		return 0;
+	}
+	return -1;	
+}
+
+static int 
+pci_remove_smbiosname_file(struct pci_dev *pdev)
+{
+	if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL, NULL)) {
+		sysfs_remove_file(&pdev->dev.kobj, &smbios_attr_label.attr);
+		sysfs_remove_file(&pdev->dev.kobj, &smbios_attr_instance.attr);
+		return 0;
+	}
+	return -1;
+}
+#endif
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
index c9957f6..2e2e69c 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -1097,6 +1097,8 @@ int __must_check pci_create_sysfs_dev_files (struct pci_dev *pdev)
 	if (retval)
 		goto err_vga_file;
 
+	pci_create_firmware_label_files(pdev);
+
 	return 0;
 
 err_vga_file:
@@ -1164,6 +1166,9 @@ void pci_remove_sysfs_dev_files(struct pci_dev *pdev)
 		sysfs_remove_bin_file(&pdev->dev.kobj, pdev->rom_attr);
 		kfree(pdev->rom_attr);
 	}
+
+	pci_remove_firmware_label_files(pdev);
+
 }
 
 static int __init pci_sysfs_init(void)
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index f8077b3..a0f160d 100644
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
