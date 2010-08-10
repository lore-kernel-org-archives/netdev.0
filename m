From: Patrick Pannuto <ppannuto@codeaurora.org>
Subject: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform buses
Date: Tue, 10 Aug 2010 16:49:34 -0700
Message-ID: <1281484174-32174-3-git-send-email-ppannuto@codeaurora.org>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org>
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
In-Reply-To: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(lkml.org seems to have lost August 3rd...)
RFC: http://lkml.indiana.edu/hypermail//linux/kernel/1008.0/01342.html
 v1: http://lkml.indiana.edu/hypermail//linux/kernel/1008.0/01942.html

Based on the idea and code originally proposed by Kevin Hilman:
http://www.mail-archive.com/linux-omap@vger.kernel.org/msg31161.html

Changes from v1:

   * "Pseduo" buses are no longer init'd, they are [un]registered by:
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

EXAMPLE USAGE

/arch/ARCH/MY_ARCH/my_bus.c:

	#include <linux/device.h>
	#include <linux/platform_device.h>

	struct bus_type SOC_bus_type = {
		.name = "SOC-bus-type",
	};
	EXPORT_SYMBOL_GPL(SOC_bus_type);

	struct platform_device SOC_bus1 = {
		.name	 = "SOC-bus1",
		.id		= -1,
		.dev.bus = &SOC_bus_type;
	};
	EXPORT_SYMBOL_GPL(SOC_bus1);

	struct platform_device SOC_bus2 = {
		.name	 = "SOC-bus2",
		.id		= -2,
		.dev.bus = &SOC_bus_type;
	};
	EXPORT_SYMBOL_GPL(SOC_bus2);

	static int __init SOC_bus_init(void)
	{
		int error;

		error = pseudo_platform_bus_register(&SOC_bus_type);
		if (error)
			return error;

		error = platform_device_register(&SOC_bus1);
		if (error)
			goto fail_bus1;

		error = platform_device_register(&SOC_bus2);
		if (error)
			goto fail_bus2;

		return error;

		/* platform_device_unregister(&SOC_bus2); */
fail_bus2:
		platform_device_unregister(&SOC_bus1);
fail_bus1:
		pseudo_platform_bus_unregister(&SOC_bus_type);

		return error;
	}

/drivers/my_driver.c:
	static struct platform_driver my_driver = {
		.driver = {
			.name	= "my-driver",
			.owner	= THIS_MODULE,
			.bus	= &SOC_bus_type,
		},
	};

/somewhere/my_device.c:
	static struct platform_device my_device = {
		.name		= "my-device",
		.id		= -1,
		.dev.bus	= &my_bus_type,
		.dev.parent	= &SOC_bus1.dev,
	};

This will build a device tree that mirrors the actual system:

/sys/bus
|-- SOC-bus-type
|   |-- devices
|   |   |-- SOC_bus1 -> ../../../devices/SOC_bus1
|   |   |-- SOC_bus2 -> ../../../devices/SOC_bus2
|   |   |-- my-device -> ../../../devices/SOC_bus1/my-device
|   |-- drivers
|   |   |-- my-driver

/sys/devices
|-- SOC_bus1
|   |-- my-device
|-- SOC_bus2

Driver can drive any device on the SOC, which is logical, without
actually being registered on multiple /bus_types/, even though the
devices may be on different /physical buses/ (which are actually
just devices).

THOUGHTS:

1.
Notice that for a device / driver, only 3 lines were added to
switch from the platform bus to the new SOC_bus. This is
especially valuable if we consider supporting a legacy SOCs
and new SOCs where the same driver is used, but may need to
be on either the platform bus or the new SOC_bus. The above
code then becomes:

	(possibly in a header)
	#ifdef CONFIG_MY_BUS
	#define MY_BUS_TYPE     &SOC_bus_type
	#else
	#define MY_BUS_TYPE     NULL
	#endif

/drivers/my_driver.c
	static struct platform_driver my_driver = {
		.driver = {
			.name   = "my-driver",
			.owner  = THIS_MODULE,
			.bus    = MY_BUS_TYPE,
		},
	};

Which will allow the same driver to easily to used on either
the platform bus or the newly defined bus type.

2.
Implementations wishing to make dynamic / run-time decisions on where
devices are placed could easily create wrapper functions, that is

	int SOC_device_register(struct platform_device *pdev)
	{
		if (pdev->archdata->flag)
			pdev->dev.parent = &SOC_bus1.dev;
		else
			pdev->dev.parent = &SOC_bus2.dev;

		return platform_device_register(pdev);
	}

A similar solution also would allow for run-time determination of dev.bus,
if that were necessary for your platform.

3.
I'm not convinced that dynamically allocating a new copy of dev_pm_ops is
the best solution. I *AM*, however, convinced that removing const from
	struct bus_type {
		...
		const struct dev_pm_ops *pm;
		...
	};
would be a mistake; it is far too easy to overwrite one of the function
pointers on accident, and the const serves a very useful purpose here.

Cc: Kevin Hilman <khilman@deeprootsystems.com>
Signed-off-by: Patrick Pannuto <ppannuto@codeaurora.org>
---
 drivers/base/platform.c         |   92 +++++++++++++++++++++++++++++++++++++-
 include/linux/platform_device.h |    3 +
 2 files changed, 92 insertions(+), 3 deletions(-)

diff --git a/drivers/base/platform.c b/drivers/base/platform.c
index b69ccb4..933e0c1 100644
--- a/drivers/base/platform.c
+++ b/drivers/base/platform.c
@@ -238,8 +238,12 @@ int platform_device_add(struct platform_device *pdev)
 	if (!pdev)
 		return -EINVAL;
 
-	if (!pdev->dev.parent)
-		pdev->dev.parent = &platform_bus;
+	if (!pdev->dev.bus) {
+		pdev->dev.bus = &platform_bus_type;
+
+		if (!pdev->dev.parent)
+			pdev->dev.parent = &platform_bus;
+	}
 
 	pdev->dev.bus = &platform_bus_type;
 
@@ -482,7 +486,8 @@ static void platform_drv_shutdown(struct device *_dev)
  */
 int platform_driver_register(struct platform_driver *drv)
 {
-	drv->driver.bus = &platform_bus_type;
+	if (!drv->driver.bus)
+		drv->driver.bus = &platform_bus_type;
 	if (drv->probe)
 		drv->driver.probe = platform_drv_probe;
 	if (drv->remove)
@@ -1017,6 +1022,87 @@ struct bus_type platform_bus_type = {
 };
 EXPORT_SYMBOL_GPL(platform_bus_type);
 
+/** pseudo_platform_bus_register - register an "almost platform bus"
+ * @bus: partially complete bus type to register
+ *
+ * This init will fill in any ommitted fields in @bus, however, it
+ * also allocates memory and replaces the pm field in @bus, since
+ * pm is const, but some of its pointers may need this one-time
+ * initialziation overwrite.
+ *
+ * @bus's registered this way should be released with
+ * pseudo_platform_bus_unregister
+ */
+int pseudo_platform_bus_register(struct bus_type *bus)
+{
+	int error;
+	struct dev_pm_ops* heap_pm;
+	heap_pm = kmalloc(sizeof (*heap_pm), GFP_KERNEL);
+
+	if (!heap_pm)
+		return -ENOMEM;
+
+	if (!bus->dev_attrs)
+		bus->dev_attrs = platform_bus_type.dev_attrs;
+	if (!bus->match)
+		bus->match = platform_bus_type.match;
+	if (!bus->uevent)
+		bus->uevent = platform_bus_type.uevent;
+	if (!bus->pm)
+		memcpy(heap_pm, &platform_bus_type.pm, sizeof(*heap_pm));
+	else {
+		heap_pm->prepare = (bus->pm->prepare) ?
+			bus->pm->prepare : platform_pm_prepare;
+		heap_pm->complete = (bus->pm->complete) ?
+			bus->pm->complete : platform_pm_complete;
+		heap_pm->suspend = (bus->pm->suspend) ?
+			bus->pm->suspend : platform_pm_suspend;
+		heap_pm->resume = (bus->pm->resume) ?
+			bus->pm->resume : platform_pm_resume;
+		heap_pm->freeze = (bus->pm->freeze) ?
+			bus->pm->freeze : platform_pm_freeze;
+		heap_pm->thaw = (bus->pm->thaw) ?
+			bus->pm->thaw : platform_pm_thaw;
+		heap_pm->poweroff = (bus->pm->poweroff) ?
+			bus->pm->poweroff : platform_pm_poweroff;
+		heap_pm->restore = (bus->pm->restore) ?
+			bus->pm->restore : platform_pm_restore;
+		heap_pm->suspend_noirq = (bus->pm->suspend_noirq) ?
+			bus->pm->suspend_noirq : platform_pm_suspend_noirq;
+		heap_pm->resume_noirq = (bus->pm->resume_noirq) ?
+			bus->pm->resume_noirq : platform_pm_resume_noirq;
+		heap_pm->freeze_noirq = (bus->pm->freeze_noirq) ?
+			bus->pm->freeze_noirq : platform_pm_freeze_noirq;
+		heap_pm->thaw_noirq = (bus->pm->thaw_noirq) ?
+			bus->pm->thaw_noirq : platform_pm_thaw_noirq;
+		heap_pm->poweroff_noirq = (bus->pm->poweroff_noirq) ?
+			bus->pm->poweroff_noirq : platform_pm_poweroff_noirq;
+		heap_pm->restore_noirq = (bus->pm->restore_noirq) ?
+			bus->pm->restore_noirq : platform_pm_restore_noirq;
+		heap_pm->runtime_suspend = (bus->pm->runtime_suspend) ?
+			bus->pm->runtime_suspend : platform_pm_runtime_suspend;
+		heap_pm->runtime_resume = (bus->pm->runtime_resume) ?
+			bus->pm->runtime_resume : platform_pm_runtime_resume;
+		heap_pm->runtime_idle = (bus->pm->runtime_idle) ?
+			bus->pm->runtime_idle : platform_pm_runtime_idle;
+	}
+	bus->pm = heap_pm;
+
+	error = bus_register(bus);
+	if (error)
+		kfree(bus->pm);
+
+	return error;
+}
+EXPORT_SYMBOL_GPL(pseudo_platform_bus_register);
+
+void pseudo_platform_bus_unregister(struct bus_type *bus)
+{
+	bus_unregister(bus);
+	kfree(bus->pm);
+}
+EXPORT_SYMBOL_GPL(pseudo_platform_bus_unregister);
+
 int __init platform_bus_init(void)
 {
 	int error;
diff --git a/include/linux/platform_device.h b/include/linux/platform_device.h
index 5417944..5ec827c 100644
--- a/include/linux/platform_device.h
+++ b/include/linux/platform_device.h
@@ -79,6 +79,9 @@ extern int platform_driver_probe(struct platform_driver *driver,
 #define platform_get_drvdata(_dev)	dev_get_drvdata(&(_dev)->dev)
 #define platform_set_drvdata(_dev,data)	dev_set_drvdata(&(_dev)->dev, (data))
 
+extern int pseudo_platform_bus_register(struct bus_type *);
+extern void pseudo_platform_bus_unregister(struct bus_type *);
+
 extern struct platform_device *platform_create_bundle(struct platform_driver *driver,
 					int (*probe)(struct platform_device *),
 					struct resource *res, unsigned int n_res,
-- 
1.7.2
