From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH 01/34] System Firmware Interface
Date: Mon, 18 Jul 2011 09:08:15 -0400
Message-ID: <1310994528-26276-2-git-send-email-prarit@redhat.com>
References: <1310994528-26276-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	platform-driver-x86@vger.kernel.org, grant.likely@secretlab.ca,
	linux-ide@vger.kernel.org, linux-i2c@vger.kernel.org,
	device-drivers-devel@blackfin.uclinux.org, abelay@mit.edu,
	Prarit Bhargava <prarit@redhat.com>, eric.piel@tremplin-utc.net,
	x86@kernel.org, lm-sensors@lm-sensors.org,
	linux-acpi@vger.kernel.org, linux-input@vger.kernel.org,
	linux-media@vger.kernel.org, johnpol@2ka.mipt.ru,
	linux-watchdog@vger.kernel.org, rtc-linux@googlegroups.com,
	dz@debian.org, openipmi-developer@lists.sourceforge.net,
	evel@driverdev.osuosl.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, rpurdie@rpsys.net, linux-crypto@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org>
In-Reply-To: <1310994528-26276-1-git-send-email-prarit@redhat.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Sender: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
Errors-To: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
List-Id: netdev.vger.kernel.org

This patch introduces a general System Firmware interface to the kernel, called
sysfw.

Inlcluded in this interface is the ability to search a standard set of fields,
sysfw_lookup().  The fields are currently based upon the x86 and ia64 SMBIOS
fields but exapandable to fields that other arches may introduce.  Also
included is  the ability to search and match against those fields, and run
a callback function against the matches, sysfw_callback().

Modify module code to use sysfw instead of old DMI interface.

[v2]: Modified sysfw_id to include up to 8 matches.  Almost all declarations of
sysfw_id are __init so the increased kernel image size isn't a big issue.

[v3]: Use sysfs bus instead of class, restore existing dmi class for backwards
compatibility.

Cc: linux-ia64@vger.kernel.org
Cc: x86@kernel.org
Cc: linux-acpi@vger.kernel.org
Cc: linux-ide@vger.kernel.org
Cc: openipmi-developer@lists.sourceforge.net
Cc: platform-driver-x86@vger.kernel.org
Cc: linux-crypto@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: lm-sensors@lm-sensors.org
Cc: linux-i2c@vger.kernel.org
Cc: linux-ide@vger.kernel.org
Cc: linux-input@vger.kernel.org
Cc: linux-media@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
Cc: rtc-linux@googlegroups.com
Cc: evel@driverdev.osuosl.org
Cc: linux-usb@vger.kernel.org
Cc: device-drivers-devel@blackfin.uclinux.org
Cc: linux-watchdog@vger.kernel.org
Cc: grant.likely@secretlab.ca
Cc: dz@debian.org
Cc: rpurdie@rpsys.net
Cc: eric.piel@tremplin-utc.net
Cc: abelay@mit.edu
Cc: johnpol@2ka.mipt.ru
Signed-off-by: Prarit Bhargava <prarit@redhat.com>
---
 drivers/firmware/Kconfig        |   25 +++
 drivers/firmware/Makefile       |    3 +-
 drivers/firmware/sysfw-sysfs.c  |  306 +++++++++++++++++++++++++++++++++++++++
 drivers/firmware/sysfw.c        |  168 +++++++++++++++++++++
 include/linux/mod_devicetable.h |   62 ++++++++
 include/linux/sysfw.h           |  113 ++++++++++++++
 init/main.c                     |    3 +
 scripts/mod/file2alias.c        |   52 ++++----
 8 files changed, 705 insertions(+), 27 deletions(-)
 create mode 100644 drivers/firmware/sysfw-sysfs.c
 create mode 100644 drivers/firmware/sysfw.c
 create mode 100644 include/linux/sysfw.h

diff --git a/drivers/firmware/Kconfig b/drivers/firmware/Kconfig
index efba163..79a1b9d 100644
--- a/drivers/firmware/Kconfig
+++ b/drivers/firmware/Kconfig
@@ -157,6 +157,31 @@ config SIGMA
 	  If unsure, say N here.  Drivers that need these helpers will select
 	  this option automatically.
 
+config SYSTEM_FIRMWARE
+	bool "System Firmware Interface"
+	default y
+	help
+	  Enables common System Firmware Interface to export system firmware
+	  (SMBIOS, DMI, etc.) information to kernel and userspace.
+
+config SYSTEM_FIRMWARE_SYSFS
+	bool "Export System Firmware identification via sysfs to userspace"
+	depends on SYSTEM_FIRMWARE
+	help
+	  Say Y here if you want to query system identification information
+	  from userspace through /sys/class/sysfw/id/ or if you want
+	  system firmware (sysfw) based module auto-loading.
+
+config SYSTEM_FIRMWARE_DMI_COMPAT
+	bool "Export dmi compatibility class in sysfs"
+	depends on SYSTEM_FIRMWARE
+	default y
+	help
+	  This exposes /sys/class/dmi/* as a pointer to the sysfw class for
+	  old software.  This is purely a backwards compatability feature and
+	  should not be used in new user space software.  Please see
+	  Documentation/ABI for details.
+
 source "drivers/firmware/google/Kconfig"
 
 endmenu
diff --git a/drivers/firmware/Makefile b/drivers/firmware/Makefile
index 47338c9..41bc64a 100644
--- a/drivers/firmware/Makefile
+++ b/drivers/firmware/Makefile
@@ -13,5 +13,6 @@ obj-$(CONFIG_ISCSI_IBFT_FIND)	+= iscsi_ibft_find.o
 obj-$(CONFIG_ISCSI_IBFT)	+= iscsi_ibft.o
 obj-$(CONFIG_FIRMWARE_MEMMAP)	+= memmap.o
 obj-$(CONFIG_SIGMA)		+= sigma.o
-
 obj-$(CONFIG_GOOGLE_FIRMWARE)	+= google/
+obj-$(CONFIG_SYSTEM_FIRMWARE)	+= sysfw.o
+obj-$(CONFIG_SYSTEM_FIRMWARE_SYSFS)	+= sysfw-sysfs.o
diff --git a/drivers/firmware/sysfw-sysfs.c b/drivers/firmware/sysfw-sysfs.c
new file mode 100644
index 0000000..48d7d07
--- /dev/null
+++ b/drivers/firmware/sysfw-sysfs.c
@@ -0,0 +1,306 @@
+/*
+ * Export sysfs sysfw_field's to userspace
+ *
+ * Updated 2011, Prarit Bhargava, prarit@redhat.com
+ * Copyright 2007, Lennart Poettering
+ *
+ * Licensed under GPLv2
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/sysfw.h>
+#include <linux/device.h>
+#include <linux/slab.h>
+#include <linux/sysfw.h>
+
+struct sysfw_device_attribute {
+	struct device_attribute dev_attr;
+	int field;
+};
+#define to_sysfw_dev_attr(_dev_attr) \
+	container_of(_dev_attr, struct sysfw_device_attribute, dev_attr)
+
+static ssize_t sys_sysfw_field_show(struct device *dev,
+				  struct device_attribute *attr,
+				  char *page)
+{
+	int field = to_sysfw_dev_attr(attr)->field;
+	ssize_t len;
+	len = scnprintf(page, PAGE_SIZE, "%s\n", sysfw_lookup(field));
+	page[len-1] = '\n';
+	return len;
+}
+
+#define SYSFW_ATTR(_name, _mode, _show, _field)			\
+	{ .dev_attr = __ATTR(_name, _mode, _show, NULL),	\
+	  .field = _field }
+
+#define DEFINE_SYSFW_ATTR_WITH_SHOW(_name, _mode, _field)		\
+static struct sysfw_device_attribute sys_sysfw_##_name##_attr =	\
+	SYSFW_ATTR(_name, _mode, sys_sysfw_field_show, _field);
+
+DEFINE_SYSFW_ATTR_WITH_SHOW(bios_vendor,	0444, SYSFW_BIOS_VENDOR);
+DEFINE_SYSFW_ATTR_WITH_SHOW(bios_version,	0444, SYSFW_BIOS_VERSION);
+DEFINE_SYSFW_ATTR_WITH_SHOW(bios_date,		0444, SYSFW_BIOS_DATE);
+DEFINE_SYSFW_ATTR_WITH_SHOW(sys_vendor,	0444, SYSFW_SYS_VENDOR);
+DEFINE_SYSFW_ATTR_WITH_SHOW(product_name,	0444, SYSFW_PRODUCT_NAME);
+DEFINE_SYSFW_ATTR_WITH_SHOW(product_version,	0444, SYSFW_PRODUCT_VERSION);
+DEFINE_SYSFW_ATTR_WITH_SHOW(product_serial,	0400, SYSFW_PRODUCT_SERIAL);
+DEFINE_SYSFW_ATTR_WITH_SHOW(product_uuid,	0400, SYSFW_PRODUCT_UUID);
+DEFINE_SYSFW_ATTR_WITH_SHOW(board_vendor,	0444, SYSFW_BOARD_VENDOR);
+DEFINE_SYSFW_ATTR_WITH_SHOW(board_name,	0444, SYSFW_BOARD_NAME);
+DEFINE_SYSFW_ATTR_WITH_SHOW(board_version,	0444, SYSFW_BOARD_VERSION);
+DEFINE_SYSFW_ATTR_WITH_SHOW(board_serial,	0400, SYSFW_BOARD_SERIAL);
+DEFINE_SYSFW_ATTR_WITH_SHOW(board_asset_tag,	0444, SYSFW_BOARD_ASSET_TAG);
+DEFINE_SYSFW_ATTR_WITH_SHOW(chassis_vendor,	0444, SYSFW_CHASSIS_VENDOR);
+DEFINE_SYSFW_ATTR_WITH_SHOW(chassis_type,	0444, SYSFW_CHASSIS_TYPE);
+DEFINE_SYSFW_ATTR_WITH_SHOW(chassis_version,	0444, SYSFW_CHASSIS_VERSION);
+DEFINE_SYSFW_ATTR_WITH_SHOW(chassis_serial,	0400, SYSFW_CHASSIS_SERIAL);
+DEFINE_SYSFW_ATTR_WITH_SHOW(chassis_asset_tag,	0444, SYSFW_CHASSIS_ASSET_TAG);
+
+static void ascii_filter(char *d, const char *s)
+{
+	/* Filter out characters we don't want to see in the modalias string */
+	for (; *s; s++)
+		if (*s > ' ' && *s < 127 && *s != ':')
+			*(d++) = *s;
+
+	*d = 0;
+}
+
+static ssize_t get_modalias(char *buffer, size_t buffer_size,
+			    struct device *dev)
+{
+	static const struct mafield {
+		const char *prefix;
+		int field;
+	} fields[] = {
+		{ "bvn", SYSFW_BIOS_VENDOR },
+		{ "bvr", SYSFW_BIOS_VERSION },
+		{ "bd",  SYSFW_BIOS_DATE },
+		{ "svn", SYSFW_SYS_VENDOR },
+		{ "pn",  SYSFW_PRODUCT_NAME },
+		{ "pvr", SYSFW_PRODUCT_VERSION },
+		{ "rvn", SYSFW_BOARD_VENDOR },
+		{ "rn",  SYSFW_BOARD_NAME },
+		{ "rvr", SYSFW_BOARD_VERSION },
+		{ "cvn", SYSFW_CHASSIS_VENDOR },
+		{ "ct",  SYSFW_CHASSIS_TYPE },
+		{ "cvr", SYSFW_CHASSIS_VERSION },
+		{ NULL,  SYSFW_NONE }
+	};
+	ssize_t l, left;
+	char *p;
+	const struct mafield *f;
+	const char *name = dev_name(dev);
+
+	left = buffer_size;
+	p = buffer;
+	name = dev_name(dev);
+	if (!strncmp(dev_name(dev), "sysfw", 5)) {
+		strcpy(buffer, "sysfw");
+		p += 5;
+		left -= 6;
+	}
+#ifdef CONFIG_SYSTEM_FIRMWARE_DMI_COMPAT
+	if (!strncmp(dev_name(dev), "id", 2)) { /* old dmi */
+		strcpy(buffer, "dmi");
+		p +=  3;
+		left -= 4;
+	}
+#endif
+
+	for (f = fields; f->prefix && left > 0; f++) {
+		const char *c;
+		char *t;
+
+		c = sysfw_lookup(f->field);
+		if (!c)
+			continue;
+
+		t = kmalloc(strlen(c) + 1, GFP_KERNEL);
+		if (!t)
+			break;
+		ascii_filter(t, c);
+		l = scnprintf(p, left, ":%s%s", f->prefix, t);
+		kfree(t);
+
+		p += l;
+		left -= l;
+	}
+
+	p[0] = ':';
+	p[1] = 0;
+
+	return p - buffer + 1;
+}
+
+static ssize_t sys_sysfw_modalias_show(struct device *dev,
+				       struct device_attribute *attr,
+				       char *page)
+{
+	ssize_t r;
+	r = get_modalias(page, PAGE_SIZE-1, dev);
+	page[r] = '\n';
+	page[r+1] = 0;
+	return r+1;
+}
+
+static struct device_attribute sys_sysfw_modalias_attr =
+	__ATTR(modalias, 0444, sys_sysfw_modalias_show, NULL);
+
+static struct attribute *sys_sysfw_attributes[SYSFW_STRING_MAX+2];
+
+static struct attribute_group sys_sysfw_attribute_group = {
+	.attrs = sys_sysfw_attributes,
+};
+
+static const struct attribute_group *sys_sysfw_attribute_groups[] = {
+	&sys_sysfw_attribute_group,
+	NULL
+};
+
+static void sys_sysfw_release(struct device *dev)
+{
+	/* nothing to do */
+	return;
+}
+
+static struct device_type sysfw_type = {
+	.groups = sys_sysfw_attribute_groups,
+	.release = sys_sysfw_release,
+};
+
+/* Initialization */
+
+#define ADD_SYSFW_ATTR(_name, _field) \
+	if (sysfw_lookup(_field)) \
+		sys_sysfw_attributes[i++] = \
+		&sys_sysfw_##_name##_attr.dev_attr.attr;
+
+/* In a separate function to keep gcc 3.2 happy - do NOT merge this in
+   sysfw_bus_init! */
+static void __init sysfw_id_init_attr_table(void)
+{
+	int i;
+
+	/* Not necessarily all SYSFW fields are available on all
+	 * systems, hence let's built an attribute table of just
+	 * what's available */
+	i = 0;
+	ADD_SYSFW_ATTR(bios_vendor,       SYSFW_BIOS_VENDOR);
+	ADD_SYSFW_ATTR(bios_version,      SYSFW_BIOS_VERSION);
+	ADD_SYSFW_ATTR(bios_date,         SYSFW_BIOS_DATE);
+	ADD_SYSFW_ATTR(sys_vendor,        SYSFW_SYS_VENDOR);
+	ADD_SYSFW_ATTR(product_name,      SYSFW_PRODUCT_NAME);
+	ADD_SYSFW_ATTR(product_version,   SYSFW_PRODUCT_VERSION);
+	ADD_SYSFW_ATTR(product_serial,    SYSFW_PRODUCT_SERIAL);
+	ADD_SYSFW_ATTR(product_uuid,      SYSFW_PRODUCT_UUID);
+	ADD_SYSFW_ATTR(board_vendor,      SYSFW_BOARD_VENDOR);
+	ADD_SYSFW_ATTR(board_name,        SYSFW_BOARD_NAME);
+	ADD_SYSFW_ATTR(board_version,     SYSFW_BOARD_VERSION);
+	ADD_SYSFW_ATTR(board_serial,      SYSFW_BOARD_SERIAL);
+	ADD_SYSFW_ATTR(board_asset_tag,   SYSFW_BOARD_ASSET_TAG);
+	ADD_SYSFW_ATTR(chassis_vendor,    SYSFW_CHASSIS_VENDOR);
+	ADD_SYSFW_ATTR(chassis_type,      SYSFW_CHASSIS_TYPE);
+	ADD_SYSFW_ATTR(chassis_version,   SYSFW_CHASSIS_VERSION);
+	ADD_SYSFW_ATTR(chassis_serial,    SYSFW_CHASSIS_SERIAL);
+	ADD_SYSFW_ATTR(chassis_asset_tag, SYSFW_CHASSIS_ASSET_TAG);
+	sys_sysfw_attributes[i++] = &sys_sysfw_modalias_attr.attr;
+}
+
+static int sysfw_dev_uevent(struct device *dev, struct kobj_uevent_env *env)
+{
+	ssize_t len;
+
+	if (add_uevent_var(env, "MODALIAS="))
+		return -ENOMEM;
+	len = get_modalias(&env->buf[env->buflen - 1],
+			   sizeof(env->buf) - env->buflen, dev);
+	if (len >= (sizeof(env->buf) - env->buflen))
+		return -ENOMEM;
+	env->buflen += len;
+	return 0;
+}
+
+#ifdef CONFIG_SYSTEM_FIRMWARE_DMI_COMPAT
+/* Hopefully someday we can get rid of this. */
+static struct class dmi_class = {
+	.name = "dmi",
+	.dev_release = (void(*)(struct device *)) kfree,
+	.dev_uevent = sysfw_dev_uevent,
+};
+
+static struct device dmi_dev = {
+	.class = &dmi_class,
+	.groups = sys_sysfw_attribute_groups,
+};
+
+static int __init sysfw_legacy_dmi(void)
+{
+	int ret;
+
+	ret = class_register(&dmi_class);
+	if (ret)
+		return ret;
+
+	dev_set_name(&dmi_dev, "id");
+	ret = device_register(&dmi_dev);
+	return ret;
+}
+#else
+static int __init sysfw_legacy_dmi(void)
+{
+	return 0;
+}
+#endif
+
+static int sysfw_bus_match(struct device *dev, struct device_driver *drv)
+{
+	return 1;
+}
+
+struct bus_type sysfw_bus_type = {
+	.name = "sysfw",
+	.match = sysfw_bus_match,
+	.uevent = sysfw_dev_uevent,
+};
+
+static struct device sysfw_dev = {
+	.bus = &sysfw_bus_type,
+	.type = &sysfw_type,
+};
+
+void sysfw_sysfs_device_init(const char *name)
+{
+	if (!dev_name(&sysfw_dev))
+		dev_set_name(&sysfw_dev, name);
+}
+
+static int __init sysfw_bus_init(void)
+{
+	int ret;
+
+	sysfw_id_init_attr_table();
+
+	ret = bus_register(&sysfw_bus_type);
+	if (ret)
+		return ret;
+
+	ret = device_register(&sysfw_dev);
+	if (ret) {
+		bus_unregister(&sysfw_bus_type);
+	}
+	return ret;
+
+	/* Failing to setup legacy DMI is NOT a fatal error */
+	ret = sysfw_legacy_dmi();
+	if (ret)
+		printk(KERN_ERR "SYSFW: DMI Legacy sysfs did not "
+		       "initialize.\n");
+
+	return 0;
+}
+arch_initcall(sysfw_bus_init);
diff --git a/drivers/firmware/sysfw.c b/drivers/firmware/sysfw.c
new file mode 100644
index 0000000..c37e19e
--- /dev/null
+++ b/drivers/firmware/sysfw.c
@@ -0,0 +1,168 @@
+/*
+ * System Firmware (sysfw) support
+ *
+ * started by Prarit Bhargava, Copyright (C) 2011 Red Hat, Inc.
+ *
+ * SYSFW interface to export commonly used values from System Firmware
+ *
+ * Some bits copied directly from original x86 and ia64 dmi*.c files
+ */
+#include <linux/device.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/mod_devicetable.h>
+#include <linux/slab.h>
+#include <linux/sysfw.h>
+
+/* Global sysfw instance */
+static struct sysfw_driver *sysfw;
+
+/**
+ * sysfw_driver_register - register a firmware driver
+ * @driver: sysfw_driver struct representing driver to register
+ *
+ * This function registers a sysfw driver.  Since the FW exists for the
+ * lifetime of the system there is no need for an unregister function.
+ */
+int __init sysfw_driver_register(struct sysfw_driver *driver)
+{
+	int ret;
+
+	if (!driver->init || !driver->name) {
+		WARN(1, "System Firmware Interface: driver error\n");
+		return -EFAULT;
+	}
+
+	if (sysfw) {
+		WARN(1, "System Firmware Interface: already registered\n");
+		return -EBUSY;
+	}
+
+	sysfw = driver;
+	ret = sysfw->init();
+	if (ret)
+		return -ENODEV;
+
+	return 0;
+}
+
+/* called in start_kernel(), after memory management has been initialized. */
+void __init sysfw_init_late(void)
+{
+	if (sysfw && sysfw->late)
+		sysfw->late();
+	sysfw_sysfs_device_init(sysfw->name);
+}
+
+/**
+ * sysfw_lookup - find a sysfw value for a given field.
+ * @field: field to lookup
+ *
+ * This function calls into the system firmware and returns an appropriate
+ * string.
+ */
+const char *sysfw_lookup(int field)
+{
+	if (sysfw && sysfw->lookup)
+		return sysfw->lookup(field);
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(sysfw_lookup);
+
+/**
+ * sysfw_vendor_is - checks to see if the vendor fields in the firmware
+ * contain a string
+ * @str: string to search for
+ *
+ * Returns true/false if the string is in any of the SYSFW_*VENDOR* fields.
+ */
+bool sysfw_vendor_is(const char *str)
+{
+	static int fields[] = { SYSFW_BIOS_VENDOR, SYSFW_BIOS_VERSION,
+				SYSFW_SYS_VENDOR, SYSFW_PRODUCT_NAME,
+				SYSFW_PRODUCT_VERSION, SYSFW_BOARD_VENDOR,
+				SYSFW_BOARD_NAME, SYSFW_BOARD_VERSION,
+				SYSFW_NONE };
+	int i;
+
+	if (!sysfw)
+		return false;
+
+	if (!sysfw->lookup)
+		return false;
+
+	for (i = 0; fields[i] != SYSFW_NONE; i++) {
+		if (sysfw_lookup(i) && strstr(sysfw_lookup(i), str))
+			return true;
+	}
+	return false;
+}
+EXPORT_SYMBOL(sysfw_vendor_is);
+
+/**
+ * sysfw_get_date - returns the date of the firmware in YYYYMMDD format.
+ *
+ * Retuns the date the firmware was built in YYYYMMDD for easy comparisons.
+ */
+int sysfw_get_date(void)
+{
+	if (sysfw && sysfw->date)
+		return sysfw->date();
+	return 0;
+}
+EXPORT_SYMBOL(sysfw_get_date);
+
+/* compares and matches the strings in sysfw_id */
+static bool sysfw_match_fields(const struct sysfw_id *id, int exactmatch)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(id->matches); i++) {
+		int s = id->matches[i].slot;
+		if (s == SYSFW_NONE)
+			break;
+		if (!sysfw_lookup(s))
+			continue;
+		if (exactmatch &&
+		    !strcmp(sysfw_lookup(s), id->matches[i].substr))
+			continue;
+		if (!exactmatch &&
+		    strstr(sysfw_lookup(s), id->matches[i].substr))
+			continue;
+		/* No match */
+		return false;
+	}
+	return true;
+}
+
+static bool sysfw_is_end_of_table(const struct sysfw_id *id)
+{
+	return id->matches[0].slot == SYSFW_NONE;
+}
+
+/**
+ * sysfw_callback - go through a list and run a function on all matching ids
+ * @list: list of ids to search
+ *
+ * This function takes a list of fields and strings to compare, attempts to
+ * compare the strings to the sysfw fields and runs a callback function for
+ * each positive comparison.  The comparison can stop by returning 0 in
+ * the callback function.
+ */
+const struct sysfw_id *sysfw_callback(const struct sysfw_id *list)
+{
+	const struct sysfw_id *id;
+
+	if (!sysfw)
+		return NULL;
+
+	for (id = list; !sysfw_is_end_of_table(id); id++)
+		if (sysfw_match_fields(id, id->exactmatch)) {
+			if (id->callback)
+				id->callback(id);
+			return id;
+		}
+	return NULL;
+}
+EXPORT_SYMBOL(sysfw_callback);
diff --git a/include/linux/mod_devicetable.h b/include/linux/mod_devicetable.h
index ae28e93..89153ad 100644
--- a/include/linux/mod_devicetable.h
+++ b/include/linux/mod_devicetable.h
@@ -482,6 +482,68 @@ struct dmi_system_id {
 
 #define DMI_MATCH(a, b)	{ a, b }
 
+/*
+ * sysfw field - right now these are based on x86/ia64's SMBIOS fields.  But
+ * other arches are certainly welcome to add additional fields.  The
+ * sys_lookup() functions must be careful to return NULL on non-populated
+ * fields.
+ */
+enum sysfw_field {
+	SYSFW_NONE,
+	SYSFW_BIOS_VENDOR,
+	SYSFW_BIOS_VERSION,
+	SYSFW_BIOS_DATE,
+	SYSFW_SYS_VENDOR,
+	SYSFW_PRODUCT_NAME,
+	SYSFW_PRODUCT_VERSION,
+	SYSFW_PRODUCT_SERIAL,
+	SYSFW_PRODUCT_UUID,
+	SYSFW_BOARD_VENDOR,
+	SYSFW_BOARD_NAME,
+	SYSFW_BOARD_VERSION,
+	SYSFW_BOARD_SERIAL,
+	SYSFW_BOARD_ASSET_TAG,
+	SYSFW_CHASSIS_VENDOR,
+	SYSFW_CHASSIS_TYPE,
+	SYSFW_CHASSIS_VERSION,
+	SYSFW_CHASSIS_SERIAL,
+	SYSFW_CHASSIS_ASSET_TAG,
+	SYSFW_STRING_MAX,
+};
+
+struct sysfw_strmatch {
+	unsigned char slot;
+	char substr[79];
+};
+
+#ifndef __KERNEL__
+struct sysfw_id {
+	kernel_ulong_t callback;
+	kernel_ulong_t ident;
+	struct sysfw_strmatch matches[8];
+	kernel_ulong_t driver_data
+			__attribute__((aligned(sizeof(kernel_ulong_t))));
+	kernel_ulong_t exactmatch;
+};
+#else
+struct sysfw_id {
+	int (*callback)(const struct sysfw_id *);
+	const char *ident;
+	struct sysfw_strmatch matches[8];
+	void *driver_data;
+	kernel_ulong_t exactmatch;
+};
+/*
+ * struct sysfw_device_id appears during expansion of
+ * "MODULE_DEVICE_TABLE(sysfw, x)". Compiler doesn't look inside it
+ * but this is enough for gcc 3.4.6 to error out:
+ *	error: storage size of '__mod_sysfw_device_table' isn't known
+ */
+#define sysfw_device_id sysfw_system_id
+#endif
+
+#define SYSFW_MATCH(a, b)	{ a, b }
+
 #define PLATFORM_NAME_SIZE	20
 #define PLATFORM_MODULE_PREFIX	"platform:"
 
diff --git a/include/linux/sysfw.h b/include/linux/sysfw.h
new file mode 100644
index 0000000..8dcb674
--- /dev/null
+++ b/include/linux/sysfw.h
@@ -0,0 +1,113 @@
+/*
+ * include/linux/sysfw.h
+ *
+ * System Firmware (sysfw) Interface
+ */
+#ifndef _SYSFW_H
+#define _SYSFW_H
+
+#include <linux/mod_devicetable.h>
+
+/*
+ * sysfw_id and sysfw_field (the SYSFW_*) enums are defined in
+ * mod_devicetable.h
+ */
+
+/*
+ * sysfw_driver struct -- passed in to sysfw_init() by every firmware
+ * driver
+ */
+struct sysfw_driver {
+	const char *name;
+	/* find & evaluate firmware */
+	int (*init)(void);
+	/* late init, done after memory management is initialized */
+	int (*late)(void);
+	/* find a specific value in sysfw_field */
+	const char * (*lookup)(int field);
+	/* return date in YYYYMMDD format */
+	int (*date)(void);
+};
+
+#ifdef CONFIG_SYSTEM_FIRMWARE
+/**
+ * sysfw_driver_register - register a firmware driver
+ * @driver: sysfw_driver struct representing driver to register
+ *
+ * This function registers a sysfw driver.  Since the FW exists for the
+ * lifetime of the system there is no need for an unregister function.
+ */
+extern int sysfw_driver_register(struct sysfw_driver *driver);
+
+/**
+ * sysfw_lookup - find a sysfw value for a given field.
+ * @field: field to lookup
+ *
+ * This function calls into the system firmware and returns an appropriate
+ * string.
+ */
+extern const char *sysfw_lookup(int field);
+
+/**
+ * sysfw_get_date - returns the date of the firmware in YYYYMMDD format.
+ *
+ * Retuns the date the firmware was built in YYYYMMDD for easy comparisons.
+ */
+extern int sysfw_get_date(void);
+
+/**
+ * sysfw_vendor_is - checks to see if the vendor fields in the firmware
+ * contain a string
+ * @str: string to search for
+ *
+ * Returns true/false if the string is in any of the SYSFW_*VENDOR* fields.
+ */
+extern bool sysfw_vendor_is(const char *str);
+
+/**
+ * sysfw_callback - go through a list and run a function on all matching ids
+ * @list: list of ids to search
+ *
+ * This function takes a list of fields and strings to compare, attempts to
+ * compare the strings to the sysfw fields and runs a callback function for
+ * each positive comparison.  The comparison can stop by returning 0 in
+ * the callback function.  The function returns the first match in the list.
+ */
+extern const struct sysfw_id *sysfw_callback(const struct sysfw_id *list);
+
+/* Kernel internal only, run after memory management has been initialized */
+extern void sysfw_init_late(void);
+/* Kernel internal only, init's sysfs for the sysfw device */
+extern void sysfw_sysfs_device_init(const char *name);
+
+#else /* CONFIG_SYSTEM_FIRMWARE */
+
+static inline int sysfw_driver_register(struct sysfw_driver *driver)
+{
+	return -1;
+}
+static inline const char *sysfw_lookup(int field)
+{
+	return NULL;
+}
+static inline int sysfw_get_date(void)
+{
+	return 0;
+}
+static inline bool sysfw_vendor_is(const char *str)
+{
+	return false;
+}
+static const struct sysfw_id *sysfw_callback(const struct sysfw_id *list)
+{
+	return NULL;
+}
+static inline void sysfw_init_late(void)
+{
+	return;
+}
+#endif /* CONFIG_SYSTEM_FIRMWARE */
+
+#define sysfw_vendor_contains(str) sysfw_vendor_is(str)
+
+#endif /* _SYSFW_H */
diff --git a/init/main.c b/init/main.c
index d7211fa..8b99aeb 100644
--- a/init/main.c
+++ b/init/main.c
@@ -68,6 +68,7 @@
 #include <linux/shmem_fs.h>
 #include <linux/slab.h>
 #include <linux/perf_event.h>
+#include <linux/sysfw.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -554,6 +555,8 @@ asmlinkage void __init start_kernel(void)
 
 	kmem_cache_init_late();
 
+	sysfw_init_late();
+
 	/*
 	 * HACK ALERT! This is early. We're enabling the console before
 	 * we've done PCI setups etc, and console_init() must be aware of
diff --git a/scripts/mod/file2alias.c b/scripts/mod/file2alias.c
index e26e2fb..92a27e3 100644
--- a/scripts/mod/file2alias.c
+++ b/scripts/mod/file2alias.c
@@ -753,26 +753,26 @@ static int do_spi_entry(const char *filename, struct spi_device_id *id,
 	return 1;
 }
 
-static const struct dmifield {
+static const struct sysfwfield {
 	const char *prefix;
 	int field;
-} dmi_fields[] = {
-	{ "bvn", DMI_BIOS_VENDOR },
-	{ "bvr", DMI_BIOS_VERSION },
-	{ "bd",  DMI_BIOS_DATE },
-	{ "svn", DMI_SYS_VENDOR },
-	{ "pn",  DMI_PRODUCT_NAME },
-	{ "pvr", DMI_PRODUCT_VERSION },
-	{ "rvn", DMI_BOARD_VENDOR },
-	{ "rn",  DMI_BOARD_NAME },
-	{ "rvr", DMI_BOARD_VERSION },
-	{ "cvn", DMI_CHASSIS_VENDOR },
-	{ "ct",  DMI_CHASSIS_TYPE },
-	{ "cvr", DMI_CHASSIS_VERSION },
-	{ NULL,  DMI_NONE }
+} sysfw_fields[] = {
+	{ "bvn", SYSFW_BIOS_VENDOR },
+	{ "bvr", SYSFW_BIOS_VERSION },
+	{ "bd",  SYSFW_BIOS_DATE },
+	{ "svn", SYSFW_SYS_VENDOR },
+	{ "pn",  SYSFW_PRODUCT_NAME },
+	{ "pvr", SYSFW_PRODUCT_VERSION },
+	{ "rvn", SYSFW_BOARD_VENDOR },
+	{ "rn",  SYSFW_BOARD_NAME },
+	{ "rvr", SYSFW_BOARD_VERSION },
+	{ "cvn", SYSFW_CHASSIS_VENDOR },
+	{ "ct",  SYSFW_CHASSIS_TYPE },
+	{ "cvr", SYSFW_CHASSIS_VERSION },
+	{ NULL,  SYSFW_NONE }
 };
 
-static void dmi_ascii_filter(char *d, const char *s)
+static void sysfw_ascii_filter(char *d, const char *s)
 {
 	/* Filter out characters we don't want to see in the modalias string */
 	for (; *s; s++)
@@ -783,20 +783,20 @@ static void dmi_ascii_filter(char *d, const char *s)
 }
 
 
-static int do_dmi_entry(const char *filename, struct dmi_system_id *id,
-			char *alias)
+static int do_sysfw_entry(const char *filename, struct sysfw_id *id,
+			  char *alias)
 {
 	int i, j;
 
-	sprintf(alias, "dmi*");
+	sprintf(alias, "sysfw*");
 
-	for (i = 0; i < ARRAY_SIZE(dmi_fields); i++) {
+	for (i = 0; i < ARRAY_SIZE(sysfw_fields); i++) {
 		for (j = 0; j < 4; j++) {
 			if (id->matches[j].slot &&
-			    id->matches[j].slot == dmi_fields[i].field) {
+			    id->matches[j].slot == sysfw_fields[i].field) {
 				sprintf(alias + strlen(alias), ":%s*",
-					dmi_fields[i].prefix);
-				dmi_ascii_filter(alias + strlen(alias),
+					sysfw_fields[i].prefix);
+				sysfw_ascii_filter(alias + strlen(alias),
 						 id->matches[j].substr);
 				strcat(alias, "*");
 			}
@@ -1002,10 +1002,10 @@ void handle_moddevtable(struct module *mod, struct elf_info *info,
 		do_table(symval, sym->st_size,
 			 sizeof(struct spi_device_id), "spi",
 			 do_spi_entry, mod);
-	else if (sym_is(symname, "__mod_dmi_device_table"))
+	else if (sym_is(symname, "__mod_sysfw_device_table"))
 		do_table(symval, sym->st_size,
-			 sizeof(struct dmi_system_id), "dmi",
-			 do_dmi_entry, mod);
+			 sizeof(struct sysfw_id), "sysfw",
+			 do_sysfw_entry, mod);
 	else if (sym_is(symname, "__mod_platform_device_table"))
 		do_table(symval, sym->st_size,
 			 sizeof(struct platform_device_id), "platform",
-- 
1.6.5.2
