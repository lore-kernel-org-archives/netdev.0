From: Narendra K <Narendra_K@dell.com>
Subject: Re: [PATCH] Export smbios strings associated with onboard devices
	to sysfs
Date: Tue, 2 Mar 2010 11:33:04 -0600
Message-ID: <20100302173302.GA20936@mock.linuxdev.us.dell.com>
References: <20100225202941.GA19404@mock.linuxdev.us.dell.com> <20100225204905.GC20147@mdomsch-pws380.aus.amer.dell.com> <EDA0A4495861324DA2618B4C45DCB3EE6122A2@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, jordan_hargrave@dell.com,
	sandeep_k_shandilya@dell.com, charles_rose@dell.com,
	shyam_iyer@dell.com
To: matt_domsch@dell.com
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE6122A2@blrx3m08.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > -----Original Message-----
> > From: Domsch, Matt [mailto:Matt_Domsch@Dell.com]
> > Sent: Friday, February 26, 2010 2:19 AM
> > To: K, Narendra
> > Cc: netdev@vger.kernel.org; linux-hotplug@vger.kernel.org; linux-
> > pci@vger.kernel.org; Hargrave, Jordan; Shandilya, Sandeep K; Rose,
> > Charles; Iyer, Shyam
> > Subject: Re: [PATCH] Export smbios strings associated with onboard
> > devices to sysfs
> > 
> > On Thu, Feb 25, 2010 at 02:29:42PM -0600, K, Narendra wrote:
> > > 1.Export smbios strings of onboard devices, to sysfs. For example -
> > 
> > I like the idea in this patch, which exports this additional
> > smbios-provided string in sysfs.  This removes the need to parse the
> > SMBIOS table in userspace, which requires root privs.
> > 
> > The concept is also extensible to other methods (e.g. ACPI) that I
> > expect will appear for the platform BIOS to provide naming hints to
> > the OS - I want those to appear in sysfs also.
> > 
> > now, for the patch:
> > 
> > > +		if (!(strcmp(attr_name(bus->dev_attrs[i]),
> "smbiosname")))
> > {
> > > +			if (!smbiosname_string_is_valid(dev, NULL))
> > > +				continue;
> > > +		}
> > >  		error = device_create_file(dev, &bus->dev_attrs[i]);
> > >  		if (error) {
> > >  			while (--i >= 0)
> > 
> > This cannot go in bus.c.  It needs to go in pci-sysfs.c.
> > 

Resending the patch with review comments incorporated.

Signed-off-by: Jordan Hargrave <Jordan_Hargrave@dell.com>
Signed-off-by: Narendra K <Narendra_K@dell.com>
---
 drivers/firmware/dmi_scan.c |   23 ++++++++++++++++++
 drivers/pci/pci-sysfs.c     |   54 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/dmi.h         |    9 +++++++
 3 files changed, 86 insertions(+), 0 deletions(-)

diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index 31b983d..1d10663 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -278,6 +278,28 @@ static void __init dmi_save_ipmi_device(const struct dmi_header *dm)
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
+	slot->dev.name = &slot[1];
+	slot->dev.device_data = slot;
+
+	list_add(&slot->dev.list, &dmi_devices);
+}
+
 static void __init dmi_save_extended_devices(const struct dmi_header *dm)
 {
 	const u8 *d = (u8*) dm + 5;
@@ -286,6 +308,7 @@ static void __init dmi_save_extended_devices(const struct dmi_header *dm)
 	if ((*d & 0x80) == 0)
 		return;
 
+	dmi_save_devslot(-1, *(u16 *)(d+2), *(d+4), *(d+5), dmi_string_nosave(dm, *(d-1)));
 	dmi_save_one_device(*d & 0x7f, dmi_string_nosave(dm, *(d - 1)));
 }
 
diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index 807224e..85d5d79 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -142,6 +142,54 @@ static ssize_t modalias_show(struct device *dev, struct device_attribute *attr,
 		       (u8)(pci_dev->class));
 }
 
+#ifdef CONFIG_DMI
+#include <linux/dmi.h>
+static ssize_t
+smbiosname_string_is_valid(struct device *dev, char *buf)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+  	struct dmi_device *dmi;
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
+}
+
+static ssize_t
+smbiosname_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	return smbiosname_string_is_valid(dev, buf);
+
+}
+
+struct smbios_attribute {
+	struct attribute attr;
+	ssize_t(*show) (struct device * edev, char *buf);
+	int (*test) (struct device * edev, char *buf);
+};
+
+#define SMBIOSNAME_DEVICE_ATTR(_name, _mode, _show, _test) \
+struct smbios_attribute smbios_attr_##_name = { 	\
+	.attr = {.name = __stringify(_name), .mode = _mode },	\
+	.show	= _show,				\
+	.test	= _test,				\
+};
+
+static SMBIOSNAME_DEVICE_ATTR(smbiosname, 0444, smbiosname_show, smbiosname_string_is_valid);
+#endif
+
 static ssize_t is_enabled_store(struct device *dev,
 				struct device_attribute *attr, const char *buf,
 				size_t count)
@@ -1140,6 +1188,7 @@ static int __init pci_sysfs_init(void)
 {
 	struct pci_dev *pdev = NULL;
 	int retval;
+	struct smbios_attribute *attr = &smbios_attr_smbiosname;
 
 	sysfs_initialized = 1;
 	for_each_pci_dev(pdev) {
@@ -1148,6 +1197,11 @@ static int __init pci_sysfs_init(void)
 			pci_dev_put(pdev);
 			return retval;
 		}
+#ifdef CONFIG_DMI
+		/* if the device does not have an associated smbios string in the smbios table, do not create this attribute */ 
+		if (attr->test && attr->test(&pdev->dev, NULL))
+			sysfs_create_file(&pdev->dev.kobj, &attr->attr);
+#endif
 	}
 
 	return 0;
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
