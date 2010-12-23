From: <Narendra_K@Dell.com>
Subject: Re: [PATCH] Export ACPI _DSM provided firmware instance number and
 string name to sysfs
Date: Thu, 23 Dec 2010 11:24:36 -0800
Message-ID: <20101223194927.GA2717@fedora14-r610.oslab.blr.amer.dell.com>
References: <20101222170737.GA2428@fedora14-r610.oslab.blr.amer.dell.com>
 <20101223143203.GA12256@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-pci@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<netdev@vger.kernel.org>, <Jordan_Hargrave@Dell.com>,
	<Charles_Rose@Dell.com>, <Vijay_Nijhawan@Dell.com>
To: <Matt_Domsch@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20101223143203.GA12256@auslistsprd01.us.dell.com>
Content-Language: en-US
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 23, 2010 at 08:02:03PM +0530, Domsch, Matt wrote:
> On Wed, Dec 22, 2010 at 08:42:39AM -0800, Narendra_K@Dell.com wrote:
> > Hello,
> > 
> > This patch exports ACPI _DSM provided firmware instance number and
> > string name to sysfs.
> > 
> > Please review -
> 
> There are now two different meanings for the 'index' file:
> 
> 1) SMBIOS-provided "type instance" value, which I've only seen in
>    range [1..N] for N devices, monotonically stepwise increasing.
> 
> 2) ACPI-provided "index" value, which per spec only needs to be a
>    "sort key", not starting at 0 or 1, and while monotonically
>    increasing, not necessarily stepwise.  It's perfectly valid for the
>    values to be (12, 16, 27, 29) if that's convenient for BIOS to
>    generate.
> 
> Therefore, a consumer of this value (such as biosdevname) must know
> which of the two it's dealing with, and either accept the value as-is,
> or sort the value list.  While I suppose it could sort the value list
> in either case, I'd prefer the ACPI value to be exposed in its own
> file, perhaps 'acpi_index', to make this explicit rather than
> implicit.
> 
> 'label' is fine for either case, with ACPI taking priority over
> SMBIOS if both happen to be present.
> 

Matt,

Thanks for the suggestion. I agree.

Please find the version 2 of the patch.

V1 -> V2:

The attribute 'index' is changed to 'acpi_index' as the semantics of
SMBIOS provided device type instance and ACPI _DSM provided instance
number are different.

From: Narendra K <narendra_k@dell.com>
Subject: [PATCH V2] Export ACPI _DSM provided firmware instance number and string to sysfs

This patch exports ACPI _DSM (Device Specific Method) provided firmware
instance number and string name of PCI devices as defined by
'PCI Firmware Specification Revision 3.1' section 4.6.7.( DSM for Naming
a PCI or PCI Express Device Under Operating Systems) to sysfs.

New files created are:
  /sys/bus/pci/devices/.../label which contains the firmware name for
the device in question, and
  /sys/bus/pci/devices/.../acpi_index which contains the firmware device type
instance for the given device.

cat /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/acpi_index
1
cat /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/label
Embedded Broadcom 5709C NIC 1

cat /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.1/acpi_index
2
cat /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.1/label
Embedded Broadcom 5709C NIC 2

The ACPI _DSM provided firmware 'instance number' and 'string name' will
be given priority if the firmware also provides 'SMBIOS type 41 device
type instance and string'.

Signed-off-by: Jordan Hargrave <jordan_hargrave@dell.com>
Signed-off-by: Narendra K <narendra_k@dell.com>
---
 Documentation/ABI/testing/sysfs-bus-pci |   31 +++-
 drivers/pci/Makefile                    |    3 +-
 drivers/pci/pci-label.c                 |  236 ++++++++++++++++++++++++++++++-
 drivers/pci/pci.h                       |    2 +-
 4 files changed, 260 insertions(+), 12 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-bus-pci b/Documentation/ABI/testing/sysfs-bus-pci
index f979d82..36bf454 100644
--- a/Documentation/ABI/testing/sysfs-bus-pci
+++ b/Documentation/ABI/testing/sysfs-bus-pci
@@ -145,9 +145,11 @@ Date:		July 2010
 Contact:	Narendra K <narendra_k@dell.com>, linux-bugs@dell.com
 Description:
 		Reading this attribute will provide the firmware
-		given name(SMBIOS type 41 string) of the PCI device.
-		The attribute will be created only if the firmware
-		has given a name to the PCI device.
+		given name (SMBIOS type 41 string or ACPI _DSM string) of
+		the PCI device.	The attribute will be created only
+		if the firmware	has given a name to the PCI device.
+		ACPI _DSM string name will be given priority if the
+		system firmware provides SMBIOS type 41 string also.
 Users:
 		Userspace applications interested in knowing the
 		firmware assigned name of the PCI device.
@@ -157,12 +159,27 @@ Date:		July 2010
 Contact:	Narendra K <narendra_k@dell.com>, linux-bugs@dell.com
 Description:
 		Reading this attribute will provide the firmware
-		given instance(SMBIOS type 41 device type instance)
-		of the PCI device. The attribute will be created
-		only if the firmware has given a device type instance
-		to the PCI device.
+		given instance (SMBIOS type 41 device type instance) of the
+		PCI device. The attribute will be created only if the firmware
+		has given an instance number to the PCI device.
 Users:
 		Userspace applications interested in knowing the
 		firmware assigned device type instance of the PCI
 		device that can help in understanding the firmware
 		intended order of the PCI device.
+
+What:		/sys/bus/pci/devices/.../acpi_index
+Date:		July 2010
+Contact:	Narendra K <narendra_k@dell.com>, linux-bugs@dell.com
+Description:
+		Reading this attribute will provide the firmware
+		given instance (ACPI _DSM instance number) of the PCI device.
+		The attribute will be created only if the firmware has given
+		an instance number to the PCI device. ACPI _DSM instance number
+		will be given priority if the system firmware provides SMBIOS
+		type 41 device type instance also.
+Users:
+		Userspace applications interested in knowing the
+		firmware assigned instance number of the PCI
+		device that can help in understanding the firmware
+		intended order of the PCI device.
diff --git a/drivers/pci/Makefile b/drivers/pci/Makefile
index 98e6fdf..bb1d3b2 100644
--- a/drivers/pci/Makefile
+++ b/drivers/pci/Makefile
@@ -53,8 +53,9 @@ obj-$(CONFIG_TILE) += setup-bus.o setup-irq.o
 
 #
 # ACPI Related PCI FW Functions
+# ACPI _DSM provided firmware instance and string name
 #
-obj-$(CONFIG_ACPI)    += pci-acpi.o
+obj-$(CONFIG_ACPI)    += pci-acpi.o pci-label.o
 
 # SMBIOS provided firmware instance and labels
 obj-$(CONFIG_DMI)    += pci-label.o
diff --git a/drivers/pci/pci-label.c b/drivers/pci/pci-label.c
index 90c0a72..d46693c 100644
--- a/drivers/pci/pci-label.c
+++ b/drivers/pci/pci-label.c
@@ -5,6 +5,13 @@
  * by Narendra K <Narendra_K@dell.com>,
  * Jordan Hargrave <Jordan_Hargrave@dell.com>
  *
+ * PCI Firmware Specification Revision 3.1 section 4.6.7 (DSM for Naming a
+ * PCI or PCI Express Device Under Operating Systems) defines an instance
+ * number and string name. This code retrieves them and exports them to sysfs.
+ * If the system firmware does not provide the ACPI _DSM (Device Specific
+ * Method), then the SMBIOS type 41 instance number and string is exported to
+ * sysfs.
+ *
  * SMBIOS defines type 41 for onboard pci devices. This code retrieves
  * the instance number and string from the type 41 record and exports
  * it to sysfs.
@@ -19,8 +26,30 @@
 #include <linux/pci_ids.h>
 #include <linux/module.h>
 #include <linux/device.h>
+#include <linux/nls.h>
+#include <linux/acpi.h>
+#include <linux/pci-acpi.h>
+#include <acpi/acpi_drivers.h>
+#include <acpi/acpi_bus.h>
 #include "pci.h"
 
+#define	DEVICE_LABEL_DSM	0x07
+
+#ifndef CONFIG_DMI
+
+static inline int
+pci_create_smbiosname_file(struct pci_dev *pdev)
+{
+	return -1;
+}
+
+static inline void
+pci_remove_smbiosname_file(struct pci_dev *pdev)
+{
+}
+
+#else
+
 enum smbios_attr_enum {
 	SMBIOS_ATTR_NONE = 0,
 	SMBIOS_ATTR_LABEL_SHOW,
@@ -131,13 +160,214 @@ pci_remove_smbiosname_file(struct pci_dev *pdev)
 	sysfs_remove_group(&pdev->dev.kobj, &smbios_attr_group);
 }
 
+#endif
+
+#ifndef CONFIG_ACPI
+
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
+
+#else
+
+static const char device_label_dsm_uuid[] = {
+	0xD0, 0x37, 0xC9, 0xE5, 0x53, 0x35, 0x7A, 0x4D,
+	0x91, 0x17, 0xEA, 0x4D, 0x19, 0xC3, 0x43, 0x4D
+};
+
+enum acpi_attr_enum {
+	ACPI_ATTR_NONE = 0,
+	ACPI_ATTR_LABEL_SHOW,
+	ACPI_ATTR_INDEX_SHOW,
+};
+
+static int dsm_label_utf16s_to_utf8s(union acpi_object *obj, char *buf)
+{
+	int err;
+	err = utf16s_to_utf8s((const wchar_t *)obj->
+			      package.elements[1].string.pointer,
+			      obj->package.elements[1].string.length,
+			      UTF16_LITTLE_ENDIAN,
+			      buf, PAGE_SIZE);
+	buf[err] = '\n';
+	return err;
+}
+
+static int
+dsm_get_label(acpi_handle handle, int func,
+	      struct acpi_buffer *output,
+	      char *buf, enum acpi_attr_enum attribute)
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
+	obj = (union acpi_object *)output->pointer;
+
+	switch (obj->type) {
+	case ACPI_TYPE_PACKAGE:
+		if (obj->package.count != 2)
+			break;
+		len = obj->package.elements[0].integer.value;
+		if (buf) {
+			if (attribute == ACPI_ATTR_INDEX_SHOW)
+				scnprintf(buf, PAGE_SIZE, "%llu\n",
+				obj->package.elements[0].integer.value);
+			else if (attribute == ACPI_ATTR_LABEL_SHOW) {
+				if (dsm_label_utf16s_to_utf8s(obj, buf) < 0)
+					return -1;
+			}
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
+static mode_t
+acpi_index_string_exist(struct kobject *kobj, struct attribute *attr, int n)
+{
+	struct device *dev;
+	struct acpi_buffer output = {ACPI_ALLOCATE_BUFFER, NULL};
+	acpi_handle handle;
+	int length;
+
+	dev = container_of(kobj, struct device, kobj);
+	handle = DEVICE_ACPI_HANDLE(dev);
+
+	if (!handle)
+		return 0;
+
+	length = dsm_get_label(handle, DEVICE_LABEL_DSM,
+			       &output, NULL, ACPI_ATTR_NONE);
+
+	return (length > 0) ? S_IRUGO : 0;
+}
+
+static ssize_t
+acpilabel_show(struct device *dev, struct device_attribute *attr, char *buf)
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
+	length = dsm_get_label(handle, DEVICE_LABEL_DSM,
+			       &output, buf, ACPI_ATTR_LABEL_SHOW);
+
+	if (length < 1)
+		return -1;
+
+	return length;
+}
+
+static ssize_t
+acpiindex_show(struct device *dev, struct device_attribute *attr, char *buf)
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
+	length = dsm_get_label(handle, DEVICE_LABEL_DSM,
+			       &output, buf, ACPI_ATTR_INDEX_SHOW);
+
+	if (length < 0)
+		return -1;
+
+	return length;
+
+}
+
+static struct device_attribute acpi_attr_label = {
+	.attr = {.name = "label", .mode = 0444},
+	.show = acpilabel_show,
+};
+
+static struct device_attribute acpi_attr_index = {
+	.attr = {.name = "acpi_index", .mode = 0444},
+	.show = acpiindex_show,
+};
+
+static struct attribute *acpi_attributes[] = {
+	&acpi_attr_label.attr,
+	&acpi_attr_index.attr,
+	NULL,
+};
+
+static struct attribute_group acpi_attr_group = {
+	.attrs = acpi_attributes,
+	.is_visible = acpi_index_string_exist,
+};
+
+static int
+pci_create_acpi_index_label_files(struct pci_dev *pdev)
+{
+	if (!sysfs_create_group(&pdev->dev.kobj, &acpi_attr_group))
+		return 0;
+	return -ENODEV;
+}
+
+static int
+pci_remove_acpi_index_label_files(struct pci_dev *pdev)
+{
+	sysfs_remove_group(&pdev->dev.kobj, &acpi_attr_group);
+	return 0;
+}
+#endif
+
 void pci_create_firmware_label_files(struct pci_dev *pdev)
 {
-	if (!pci_create_smbiosname_file(pdev))
-		;
+	if (!pci_create_acpi_index_label_files(pdev))
+		return;
+	pci_create_smbiosname_file(pdev);
 }
 
 void pci_remove_firmware_label_files(struct pci_dev *pdev)
 {
-	pci_remove_smbiosname_file(pdev);
+	if (!pci_remove_acpi_index_label_files(pdev))
+		return;
+	else
+		pci_remove_smbiosname_file(pdev);
 }
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index 7d33f66..d0d0bd4 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -11,7 +11,7 @@
 extern int pci_uevent(struct device *dev, struct kobj_uevent_env *env);
 extern int pci_create_sysfs_dev_files(struct pci_dev *pdev);
 extern void pci_remove_sysfs_dev_files(struct pci_dev *pdev);
-#ifndef CONFIG_DMI
+#if !defined(CONFIG_DMI) && !defined(CONFIG_ACPI)
 static inline void pci_create_firmware_label_files(struct pci_dev *pdev)
 { return; }
 static inline void pci_remove_firmware_label_files(struct pci_dev *pdev)
-- 
1.7.3.1

With regards,
Narendra K