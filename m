From: Narendra K <Narendra_K@dell.com>
Subject: [PATCH] Export smbios strings associated with onboard devices to
	sysfs
Date: Thu, 25 Feb 2010 14:29:42 -0600
Message-ID: <20100225202941.GA19404@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matt_domsch@dell.com, jordan_hargrave@dell.com,
	sandeep_k_shandilya@dell.com, charles_rose@dell.com,
	shyam_iyer@dell.com
To: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

[Please let me know if any other list needs to be copied]

* We have been having discussions in the netdev list about creating multiple names for the network interfaces to bring determinism into the way network interfaces are named in the OSes. In specific, "eth0 in the OS does not always map to the integrated NIC Gb1 as labelled on the chassis".  

http://marc.info/?l=linux-netdev&m=125510301513312&w=2 - (Re: PATCH: Network Device Naming mechanism and policy)
http://marc.info/?l=linux-netdev&m=125619338904322&w=2 - ([PATCH] udev: create empty regular files to represent net)

This was not favored.

* We also had proposed an installer based approach where installers would provide options to rename kernel eth names to namespaces based on different policies like smbios names etc. That was also not favored.

As a result of these discussions we propose another solution - 

1.Export smbios strings of onboard devices, to sysfs. For example -

cat /sys/class/net/eth0/device/smbiosname
Embedded NIC 2

cat  /sys/bus/pci/devices/0000\:03\:00.0/smbiosname
Embedded NIC 2

2. User space library like libnetdevname would map these smbiosname names to eth names and eth names to smbiosnames

3. User space tools would use the smbios alias names in addition to the eth names they already support. This ensures that, right interface is referred to, irrespective of how the interface is named by the kernel (eth0 or eth1..).

For example:

/sbin/ethtool -p "Embedded NIC 1" (Might be eth0 or eth1)
/sbin/ip link show "Embedded NIC 2"

Please refer to - 

* http://linux.dell.com/wiki/index.php/Oss/libnetdevname#Linux_Enumeration_of_NICs_in_the_Enterprise -  for more information for more information on the issue we are trying to address
* http://linux.dell.com/wiki/index.php/Oss/libnetdevname#Proposal_2:  - for more information on the current proposal.

Submitting the patch which addresses point 1 mentioned above for review. 


Signed-off-by: Jordan Hargrave <Jordan_Hargrave@dell.com>
Signed-off-by: Narendra K <Narendra_K@dell.com>
---
 drivers/base/bus.c          |    5 +++++
 drivers/firmware/dmi_scan.c |   23 +++++++++++++++++++++++
 drivers/pci/pci-sysfs.c     |   38 ++++++++++++++++++++++++++++++++++++++
 include/linux/device.h      |    4 ++++
 include/linux/dmi.h         |    9 +++++++++
 5 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/drivers/base/bus.c b/drivers/base/bus.c
index c0c5a43..ad0fcfb 100644
--- a/drivers/base/bus.c
+++ b/drivers/base/bus.c
@@ -419,6 +419,11 @@ static int device_add_attrs(struct bus_type *bus, struct device *dev)
 		return 0;
 
 	for (i = 0; attr_name(bus->dev_attrs[i]); i++) {
+		/* if the device does not have an associated smbios string in the smbios table, do not create this attribute */ 
+		if (!(strcmp(attr_name(bus->dev_attrs[i]), "smbiosname"))) {
+			if (!smbiosname_string_is_valid(dev, NULL)) 
+				continue;
+		}
 		error = device_create_file(dev, &bus->dev_attrs[i]);
 		if (error) {
 			while (--i >= 0)
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
index c5df94e..a3b9bf9 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -140,6 +140,41 @@ static ssize_t modalias_show(struct device *dev, struct device_attribute *attr,
 		       (u8)(pci_dev->class));
 }
 
+#ifdef CONFIG_DMI
+#include <linux/dmi.h>
+ssize_t
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
+		
+	}
+}
+EXPORT_SYMBOL(smbiosname_string_is_valid);
+
+static ssize_t
+smbiosname_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	return smbiosname_string_is_valid(dev, buf);
+
+}
+#endif
+
 static ssize_t is_enabled_store(struct device *dev,
 				struct device_attribute *attr, const char *buf,
 				size_t count)
@@ -324,6 +359,9 @@ struct device_attribute pci_dev_attrs[] = {
 	__ATTR_RO(class),
 	__ATTR_RO(irq),
 	__ATTR_RO(local_cpus),
+#ifdef CONFIG_DMI
+	__ATTR_RO(smbiosname),
+#endif
 	__ATTR_RO(local_cpulist),
 	__ATTR_RO(modalias),
 #ifdef CONFIG_NUMA
diff --git a/include/linux/device.h b/include/linux/device.h
index a62799f..647246c 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -427,6 +427,10 @@ struct device {
 	void	(*release)(struct device *dev);
 };
 
+#ifdef CONFIG_DMI
+extern ssize_t smbiosname_string_is_valid(struct device *, char *);
+#endif
+
 /* Get the wakeup routines, which depend on struct device */
 #include <linux/pm_wakeup.h>
 
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
