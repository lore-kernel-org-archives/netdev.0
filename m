From: Patrick Pannuto <ppannuto@codeaurora.org>
Subject: [PATCH 2/4] platform: Facilitate the creation of pseudo-platform buses
Date: Wed, 18 Aug 2010 12:15:41 -0700
Message-ID: <1282158943-11902-3-git-send-email-ppannuto@codeaurora.org>
References: <1282158943-11902-1-git-send-email-ppannuto@codeaurora.org>
Cc: ppannuto@codeaurora.org, linux-arm-msm@vger.kernel.org,
	magnus.damm@gmail.com, grant.likely@secretlab.ca, gregkh@suse.de,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Eric Miao <eric.y.miao@gmail.com>,
	Dmitry Torokhov <dtor@mail.ru>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282158943-11902-1-git-send-email-ppannuto@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(lkml.org seems to have lost August 3rd...)
RFC: http://lkml.indiana.edu/hypermail/linux/kernel/1008.0/01342.html
 v1: http://lkml.indiana.edu/hypermail/linux/kernel/1008.0/01942.html
 v2: http://lkml.indiana.edu/hypermail/linux/kernel/1008.1/00958.html

Based on the idea and code originally proposed by Kevin Hilman:
http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html

Changes from v2:
   * Remove the pseudo_platform_bus_[un]register functions
   * Split affected platform functions:
       - Platform functions are split into a wrapper (with the
         original function name) that retains the 'bus-setting'
         and 'parent-setting' duties, and then exports all the
         heavy-lifting to new __platform* counterparts
       - "Pseudo" buses work the same as the platform bus now,
         writing their own wrappers and calling the __platform
         functions
   * Export a *lot* of platform symbols to allow for intialization
     of "pseudo" platform bus types.
       - I personally like this model a lot, I think it is very
         clean from an implementation perspective, even if it
         does export a lot of new symbols
       - Thanks to Michal Miroslaw <mirqus@gmail.com> for the
         suggestion here
   * Add more use-cases justifying the need of platform-ish bus types

Changes from v1:

   * "Pseudo" buses are no longer init'd, they are [un]registered by:
       - pseudo_platform_bus_register(struct bus_type *)
       - pseudo_platform_bus_unregister(struct bus_type *)
   * These registrations [de]allocate a dev_pm_ops structure for the
     pseudo bus_type
   * Do not overwrite the parent if .bus is already set (that is, allow
     pseudo bus devices to be root devices)

   * Split into 2 patches:
       - 1/2: Already sent separately, but included here for clarity
       - 2/2: The real meat of the patch (this patch)

INTRO

As SOCs become more popular, the desire to quickly define a simple,
but functional, bus type with only a few unique properties becomes
desirable. As they become more complicated, the ability to nest these
simple busses and otherwise orchestrate them to match the actual
topology also becomes desirable.

Also, as power management becomes more challenging, grouping devices
on the same SOC under the same /logical bus/ provides a very natural
interface and location for power-management issues for that SOC.

This is a fairly natural extension of the "platform" bus; ultimately,
this patch series allows for the creation of multiple platform buses (SOC
buses), with the correct name and quirks for each of the "platforms" (SOCs)
they are trying to support.

EXAMPLE USAGE

See follow-on patches implementing the MSM bus and moving the
MSM uart device / driver onto it.

Change-Id: I10d2fa4671302e81be8f9cac01a3855cef4eeebf
Cc: Kevin Hilman <khilman@deeprootsystems.com>
Signed-off-by: Patrick Pannuto <ppannuto@codeaurora.org>
---
 drivers/base/platform.c         |  184 ++++++++++++++++++++------------------
 include/linux/platform_device.h |   87 ++++++++++++++++++
 2 files changed, 184 insertions(+), 87 deletions(-)

diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index b69ccb4..e75640f 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -224,25 +224,10 @@ int platform_device_add_data(struct platform_device *pdev, const void *data,
 }
 EXPORT_SYMBOL_GPL(platform_device_add_data);
 
-/**
- * platform_device_add - add a platform device to device hierarchy
- * @pdev: platform device we're adding
- *
- * This is part 2 of platform_device_register(), though may be called
- * separately _iff_ pdev was allocated by platform_device_alloc().
- */
-int platform_device_add(struct platform_device *pdev)
+int __platform_device_add(struct platform_device *pdev)
 {
 	int i, ret = 0;
 
-	if (!pdev)
-		return -EINVAL;
-
-	if (!pdev->dev.parent)
-		pdev->dev.parent = &platform_bus;
-
-	pdev->dev.bus = &platform_bus_type;
-
 	if (pdev->id != -1)
 		dev_set_name(&pdev->dev, "%s.%d", pdev->name,  pdev->id);
 	else
@@ -289,6 +274,27 @@ int platform_device_add(struct platform_device *pdev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(__platform_device_add);
+
+/**
+ * platform_device_add - add a platform device to device hierarchy
+ * @pdev: platform device we're adding
+ *
+ * This is part 2 of platform_device_register(), though may be called
+ * separately _iff_ pdev was allocated by platform_device_alloc().
+ */
+int platform_device_add(struct platform_device *pdev)
+{
+	if (!pdev)
+		return -EINVAL;
+
+	if (!pdev->dev.parent)
+		pdev->dev.parent = &platform_bus;
+
+	pdev->dev.bus = &platform_bus_type;
+
+	return __platform_device_add(pdev);
+}
 EXPORT_SYMBOL_GPL(platform_device_add);
 
 /**
@@ -476,13 +482,8 @@ static void platform_drv_shutdown(struct device *_dev)
 	drv->shutdown(dev);
 }
 
-/**
- * platform_driver_register - register a driver for platform-level devices
- * @drv: platform driver structure
- */
-int platform_driver_register(struct platform_driver *drv)
+int __platform_driver_register(struct platform_driver *drv)
 {
-	drv->driver.bus = &platform_bus_type;
 	if (drv->probe)
 		drv->driver.probe = platform_drv_probe;
 	if (drv->remove)
@@ -492,6 +493,18 @@ int platform_driver_register(struct platform_driver *drv)
 
 	return driver_register(&drv->driver);
 }
+EXPORT_SYMBOL_GPL(__platform_driver_register);
+
+/**
+ * platform_driver_register - register a driver for platform-level devices
+ * @drv: platform driver structure
+ */
+int platform_driver_register(struct platform_driver *drv)
+{
+	drv->driver.bus = &platform_bus_type;
+
+	return __platform_driver_register(drv);
+}
 EXPORT_SYMBOL_GPL(platform_driver_register);
 
 /**
@@ -504,25 +517,9 @@ void platform_driver_unregister(struct platform_driver *drv)
 }
 EXPORT_SYMBOL_GPL(platform_driver_unregister);
 
-/**
- * platform_driver_probe - register driver for non-hotpluggable device
- * @drv: platform driver structure
- * @probe: the driver probe routine, probably from an __init section
- *
- * Use this instead of platform_driver_register() when you know the device
- * is not hotpluggable and has already been registered, and you want to
- * remove its run-once probe() infrastructure from memory after the driver
- * has bound to the device.
- *
- * One typical use for this would be with drivers for controllers integrated
- * into system-on-chip processors, where the controller devices have been
- * configured as part of board setup.
- *
- * Returns zero if the driver registered and bound to a device, else returns
- * a negative error code and with the driver not registered.
- */
-int __init_or_module platform_driver_probe(struct platform_driver *drv,
-		int (*probe)(struct platform_device *))
+int __init_or_module __platform_driver_probe(struct platform_driver *drv,
+		int (*probe)(struct platform_device *),
+		int (*bustype_driver_register)(struct platform_driver *))
 {
 	int retval, code;
 
@@ -531,7 +528,7 @@ int __init_or_module platform_driver_probe(struct platform_driver *drv,
 
 	/* temporary section violation during probe() */
 	drv->probe = probe;
-	retval = code = platform_driver_register(drv);
+	retval = code = bustype_driver_register(drv);
 
 	/*
 	 * Fixup that section violation, being paranoid about code scanning
@@ -550,6 +547,30 @@ int __init_or_module platform_driver_probe(struct platform_driver *drv,
 		platform_driver_unregister(drv);
 	return retval;
 }
+EXPORT_SYMBOL_GPL(__platform_driver_probe);
+
+/**
+ * platform_driver_probe - register driver for non-hotpluggable device
+ * @drv: platform driver structure
+ * @probe: the driver probe routine, probably from an __init section
+ *
+ * Use this instead of platform_driver_register() when you know the device
+ * is not hotpluggable and has already been registered, and you want to
+ * remove its run-once probe() infrastructure from memory after the driver
+ * has bound to the device.
+ *
+ * One typical use for this would be with drivers for controllers integrated
+ * into system-on-chip processors, where the controller devices have been
+ * configured as part of board setup.
+ *
+ * Returns zero if the driver registered and bound to a device, else returns
+ * a negative error code and with the driver not registered.
+ */
+int __init_or_module platform_driver_probe(struct platform_driver *drv,
+		int (*probe)(struct platform_device *))
+{
+	return __platform_driver_probe(drv, probe, &platform_driver_register);
+}
 EXPORT_SYMBOL_GPL(platform_driver_probe);
 
 /**
@@ -627,12 +648,13 @@ static ssize_t modalias_show(struct device *dev, struct device_attribute *a,
 	return (len >= PAGE_SIZE) ? (PAGE_SIZE - 1) : len;
 }
 
-static struct device_attribute platform_dev_attrs[] = {
+struct device_attribute platform_dev_attrs[] = {
 	__ATTR_RO(modalias),
 	__ATTR_NULL,
 };
+EXPORT_SYMBOL_GPL(platform_dev_attrs);
 
-static int platform_uevent(struct device *dev, struct kobj_uevent_env *env)
+int platform_uevent(struct device *dev, struct kobj_uevent_env *env)
 {
 	struct platform_device	*pdev = to_platform_device(dev);
 
@@ -640,6 +662,7 @@ static int platform_uevent(struct device *dev, struct kobj_uevent_env *env)
 		(pdev->id_entry) ? pdev->id_entry->name : pdev->name);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(platform_uevent);
 
 static const struct platform_device_id *platform_match_id(
 			const struct platform_device_id *id,
@@ -668,7 +691,7 @@ static const struct platform_device_id *platform_match_id(
  * and compare it against the name of the driver. Return whether they match
  * or not.
  */
-static int platform_match(struct device *dev, struct device_driver *drv)
+int platform_match(struct device *dev, struct device_driver *drv)
 {
 	struct platform_device *pdev = to_platform_device(dev);
 	struct platform_driver *pdrv = to_platform_driver(drv);
@@ -680,10 +703,11 @@ static int platform_match(struct device *dev, struct device_driver *drv)
 	/* fall-back to driver name match */
 	return (strcmp(pdev->name, drv->name) == 0);
 }
+EXPORT_SYMBOL_GPL(platform_match);
 
 #ifdef CONFIG_PM_SLEEP
 
-static int platform_legacy_suspend(struct device *dev, pm_message_t mesg)
+int platform_legacy_suspend(struct device *dev, pm_message_t mesg)
 {
 	struct platform_driver *pdrv = to_platform_driver(dev->driver);
 	struct platform_device *pdev = to_platform_device(dev);
@@ -695,7 +719,7 @@ static int platform_legacy_suspend(struct device *dev, pm_message_t mesg)
 	return ret;
 }
 
-static int platform_legacy_resume(struct device *dev)
+int platform_legacy_resume(struct device *dev)
 {
 	struct platform_driver *pdrv = to_platform_driver(dev->driver);
 	struct platform_device *pdev = to_platform_device(dev);
@@ -707,7 +731,7 @@ static int platform_legacy_resume(struct device *dev)
 	return ret;
 }
 
-static int platform_pm_prepare(struct device *dev)
+int platform_pm_prepare(struct device *dev)
 {
 	struct device_driver *drv = dev->driver;
 	int ret = 0;
@@ -717,19 +741,16 @@ static int platform_pm_prepare(struct device *dev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(platform_pm_prepare);
 
-static void platform_pm_complete(struct device *dev)
+void platform_pm_complete(struct device *dev)
 {
 	struct device_driver *drv = dev->driver;
 
 	if (drv && drv->pm && drv->pm->complete)
 		drv->pm->complete(dev);
 }
-
-#else /* !CONFIG_PM_SLEEP */
-
-#define platform_pm_prepare		NULL
-#define platform_pm_complete		NULL
+EXPORT_SYMBOL_GPL(platform_pm_complete);
 
 #endif /* !CONFIG_PM_SLEEP */
 
@@ -752,6 +773,7 @@ int __weak platform_pm_suspend(struct device *dev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(platform_pm_suspend);
 
 int __weak platform_pm_suspend_noirq(struct device *dev)
 {
@@ -768,6 +790,7 @@ int __weak platform_pm_suspend_noirq(struct device *dev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(platform_pm_suspend_noirq);
 
 int __weak platform_pm_resume(struct device *dev)
 {
@@ -786,6 +809,7 @@ int __weak platform_pm_resume(struct device *dev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(platform_pm_resume);
 
 int __weak platform_pm_resume_noirq(struct device *dev)
 {
@@ -802,19 +826,13 @@ int __weak platform_pm_resume_noirq(struct device *dev)
 
 	return ret;
 }
-
-#else /* !CONFIG_SUSPEND */
-
-#define platform_pm_suspend		NULL
-#define platform_pm_resume		NULL
-#define platform_pm_suspend_noirq	NULL
-#define platform_pm_resume_noirq	NULL
+EXPORT_SYMBOL_GPL(platform_pm_resume_noirq);
 
 #endif /* !CONFIG_SUSPEND */
 
 #ifdef CONFIG_HIBERNATION
 
-static int platform_pm_freeze(struct device *dev)
+int platform_pm_freeze(struct device *dev)
 {
 	struct device_driver *drv = dev->driver;
 	int ret = 0;
@@ -831,8 +849,9 @@ static int platform_pm_freeze(struct device *dev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(platform_pm_freeze);
 
-static int platform_pm_freeze_noirq(struct device *dev)
+int platform_pm_freeze_noirq(struct device *dev)
 {
 	struct device_driver *drv = dev->driver;
 	int ret = 0;
@@ -847,8 +866,9 @@ static int platform_pm_freeze_noirq(struct device *dev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(platform_pm_freeze_noirq);
 
-static int platform_pm_thaw(struct device *dev)
+int platform_pm_thaw(struct device *dev)
 {
 	struct device_driver *drv = dev->driver;
 	int ret = 0;
@@ -865,8 +885,9 @@ static int platform_pm_thaw(struct device *dev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(platform_pm_thaw);
 
-static int platform_pm_thaw_noirq(struct device *dev)
+int platform_pm_thaw_noirq(struct device *dev)
 {
 	struct device_driver *drv = dev->driver;
 	int ret = 0;
@@ -881,8 +902,9 @@ static int platform_pm_thaw_noirq(struct device *dev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(platform_pm_thaw_noirq);
 
-static int platform_pm_poweroff(struct device *dev)
+int platform_pm_poweroff(struct device *dev)
 {
 	struct device_driver *drv = dev->driver;
 	int ret = 0;
@@ -899,8 +921,9 @@ static int platform_pm_poweroff(struct device *dev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(platform_pm_poweroff);
 
-static int platform_pm_poweroff_noirq(struct device *dev)
+int platform_pm_poweroff_noirq(struct device *dev)
 {
 	struct device_driver *drv = dev->driver;
 	int ret = 0;
@@ -915,8 +938,9 @@ static int platform_pm_poweroff_noirq(struct device *dev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(platform_pm_poweroff_noirq);
 
-static int platform_pm_restore(struct device *dev)
+int platform_pm_restore(struct device *dev)
 {
 	struct device_driver *drv = dev->driver;
 	int ret = 0;
@@ -933,8 +957,9 @@ static int platform_pm_restore(struct device *dev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(platform_pm_restore);
 
-static int platform_pm_restore_noirq(struct device *dev)
+int platform_pm_restore_noirq(struct device *dev)
 {
 	struct device_driver *drv = dev->driver;
 	int ret = 0;
@@ -949,17 +974,7 @@ static int platform_pm_restore_noirq(struct device *dev)
 
 	return ret;
 }
-
-#else /* !CONFIG_HIBERNATION */
-
-#define platform_pm_freeze		NULL
-#define platform_pm_thaw		NULL
-#define platform_pm_poweroff		NULL
-#define platform_pm_restore		NULL
-#define platform_pm_freeze_noirq	NULL
-#define platform_pm_thaw_noirq		NULL
-#define platform_pm_poweroff_noirq	NULL
-#define platform_pm_restore_noirq	NULL
+EXPORT_SYMBOL_GPL(platform_pm_restore_noirq);
 
 #endif /* !CONFIG_HIBERNATION */
 
@@ -980,15 +995,9 @@ int __weak platform_pm_runtime_idle(struct device *dev)
 	return pm_generic_runtime_idle(dev);
 };
 
-#else /* !CONFIG_PM_RUNTIME */
-
-#define platform_pm_runtime_suspend NULL
-#define platform_pm_runtime_resume NULL
-#define platform_pm_runtime_idle NULL
-
 #endif /* !CONFIG_PM_RUNTIME */
 
-static const struct dev_pm_ops platform_dev_pm_ops = {
+const struct dev_pm_ops platform_dev_pm_ops = {
 	.prepare = platform_pm_prepare,
 	.complete = platform_pm_complete,
 	.suspend = platform_pm_suspend,
@@ -1007,6 +1016,7 @@ static const struct dev_pm_ops platform_dev_pm_ops = {
 	.runtime_resume = platform_pm_runtime_resume,
 	.runtime_idle = platform_pm_runtime_idle,
 };
+EXPORT_SYMBOL_GPL(platform_dev_pm_ops);
 
 struct bus_type platform_bus_type = {
 	.name		= "platform",
diff --git a/include/linux/platform_device.h b/include/linux/platform_device.h
index 5417944..6d7d399 100644
--- a/include/linux/platform_device.h
+++ b/include/linux/platform_device.h
@@ -53,6 +53,7 @@ extern int platform_device_add_resources(struct platform_device *pdev,
 					 const struct resource *res,
 					 unsigned int num);
 extern int platform_device_add_data(struct platform_device *pdev, const void *data, size_t size);
+extern int __platform_device_add(struct platform_device *pdev);
 extern int platform_device_add(struct platform_device *pdev);
 extern void platform_device_del(struct platform_device *pdev);
 extern void platform_device_put(struct platform_device *pdev);
@@ -67,12 +68,16 @@ struct platform_driver {
 	const struct platform_device_id *id_table;
 };
 
+extern int __platform_driver_register(struct platform_driver *);
 extern int platform_driver_register(struct platform_driver *);
 extern void platform_driver_unregister(struct platform_driver *);
 
 /* non-hotpluggable platform devices may use this so that probe() and
  * its support may live in __init sections, conserving runtime memory.
  */
+extern int __platform_driver_probe(struct platform_driver *driver,
+		int (*probe)(struct platform_device *),
+		int (*bustype_driver_register)(struct platform_driver *));
 extern int platform_driver_probe(struct platform_driver *driver,
 		int (*probe)(struct platform_device *));
 
@@ -84,6 +89,88 @@ extern struct platform_device *platform_create_bundle(struct platform_driver *dr
 					struct resource *res, unsigned int n_res,
 					const void *data, size_t size);
 
+extern struct device_attribute platform_dev_attrs[];
+extern int platform_uevent(struct device *dev, struct kobj_uevent_env *env);
+extern int platform_match(struct device *dev, struct device_driver *drv);
+
+#ifdef CONFIG_PM_SLEEP
+extern int platform_pm_prepare(struct device *dev);
+extern void platform_pm_complete(struct device *dev);
+#else  /* !CONFIG_PM_SLEEP */
+#define platform_pm_prepare		NULL
+#define platform_pm_complete		NULL
+#endif /* !CONFIG_PM_SLEEP */
+
+#ifdef CONFIG_SUSPEND
+extern int __weak platform_pm_suspend(struct device *dev);
+extern int __weak platform_pm_suspend_noirq(struct device *dev);
+extern int __weak platform_pm_resume(struct device *dev);
+extern int __weak platform_pm_resume_noirq(struct device *dev);
+#else  /* !CONFIG_SUSPEND */
+#define platform_pm_suspend		NULL
+#define platform_pm_resume		NULL
+#define platform_pm_suspend_noirq	NULL
+#define platform_pm_resume_noirq	NULL
+#endif /* !CONFIG_SUSPEND */
+
+#ifdef CONFIG_HIBERNATION
+extern int platform_pm_freeze(struct device *dev);
+extern int platform_pm_freeze_noirq(struct device *dev);
+extern int platform_pm_thaw(struct device *dev);
+extern int platform_pm_thaw_noirq(struct device *dev);
+extern int platform_pm_poweroff(struct device *dev);
+extern int platform_pm_poweroff_noirq(struct device *dev);
+extern int platform_pm_restore(struct device *dev);
+extern int platform_pm_restore_noirq(struct device *dev);
+#else  /* !CONFIG_HIBERNATION */
+#define platform_pm_freeze		NULL
+#define platform_pm_thaw		NULL
+#define platform_pm_poweroff		NULL
+#define platform_pm_restore		NULL
+#define platform_pm_freeze_noirq	NULL
+#define platform_pm_thaw_noirq		NULL
+#define platform_pm_poweroff_noirq	NULL
+#define platform_pm_restore_noirq	NULL
+#endif /* !CONFIG_HIBERNATION */
+
+#ifdef CONFIG_PM_RUNTIME
+extern int __weak platform_pm_runtime_suspend(struct device *dev);
+extern int __weak platform_pm_runtime_resume(struct device *dev);
+extern int __weak platform_pm_runtime_idle(struct device *dev);
+#else  /* !CONFIG_PM_RUNTIME */
+#define platform_pm_runtime_suspend NULL
+#define platform_pm_runtime_resume NULL
+#define platform_pm_runtime_idle NULL
+#endif /* !CONFIG_PM_RUNTIME */
+
+extern const struct dev_pm_ops platform_dev_pm_ops;
+
+#define PLATFORM_BUS_TEMPLATE \
+	.name		= "XXX_OVERRIDEME_XXX",	\
+	.dev_attrs	= platform_dev_attrs,	\
+	.match		= platform_match,	\
+	.uevent		= platform_uevent,	\
+	.pm		= &platform_dev_pm_ops
+
+#define PLATFORM_PM_OPS_TEMPLATE \
+	.prepare = platform_pm_prepare,			\
+	.complete = platform_pm_complete,		\
+	.suspend = platform_pm_suspend,			\
+	.resume = platform_pm_resume,			\
+	.freeze = platform_pm_freeze,			\
+	.thaw = platform_pm_thaw,			\
+	.poweroff = platform_pm_poweroff,		\
+	.restore = platform_pm_restore,			\
+	.suspend_noirq = platform_pm_suspend_noirq,	\
+	.resume_noirq = platform_pm_resume_noirq,	\
+	.freeze_noirq = platform_pm_freeze_noirq,	\
+	.thaw_noirq = platform_pm_thaw_noirq,		\
+	.poweroff_noirq = platform_pm_poweroff_noirq,	\
+	.restore_noirq = platform_pm_restore_noirq,	\
+	.runtime_suspend = platform_pm_runtime_suspend,	\
+	.runtime_resume = platform_pm_runtime_resume,	\
+	.runtime_idle = platform_pm_runtime_idle
+
 /* early platform driver interface */
 struct early_platform_driver {
 	const char *class_str;
-- 
1.7.2.1
