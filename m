From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v2 7/7] driver-core: add preferred async probe option for built-in and modules
Date: Fri,  3 Oct 2014 14:44:43 -0700
Message-ID: <1412372683-2003-8-git-send-email-mcgrof@do-not-panic.com>
References: <1412372683-2003-1-git-send-email-mcgrof@do-not-panic.com>
Cc: teg@jklm.no, rmilasan@suse.com, werner@suse.com, oleg@redhat.com,
	hare@suse.com, bpoirier@suse.de, santosh@chelsio.com,
	pmladek@suse.cz, dbueso@suse.com, mcgrof@suse.com,
	linux-kernel@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vg
To: gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	tiwai@suse.de, tj@kernel.org, arjan@linux.intel.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1412372683-2003-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

At times we may wish to express the desire to prefer to have
a device driver probe asynchronously by default. We cannot
simply enable all device drivers to do this without vetting
that userspace is prepared for this though given that some
old userspace is expected to exist which is not equipped to
deal with broad async probe support. This defines a new kernel
parameter, bus.enable_kern_async=1, to help address this both to
help enable async probe support for built-in drivers and to
enable drivers to specify a preference to opt in for async
probe support.

If you have a device driver that should use async probe
support when possible enable the prefer_async_probe bool.

Folks wishing to test enabling async probe for all built-in
drivers can enable bus.__DEBUG__kernel_force_mod_async_probe=1,
if you use that though you are on your own.

Cc: Tejun Heo <tj@kernel.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Joseph Salisbury <joseph.salisbury@canonical.com>
Cc: Kay Sievers <kay@vrfy.org>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Tim Gardner <tim.gardner@canonical.com>
Cc: Pierre Fersing <pierre-fersing@pierref.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Benjamin Poirier <bpoirier@suse.de>
Cc: Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>
Cc: Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>
Cc: Sreekanth Reddy <sreekanth.reddy@avagotech.com>
Cc: Abhijit Mahajan <abhijit.mahajan@avagotech.com>
Cc: Casey Leedom <leedom@chelsio.com>
Cc: Hariprasad S <hariprasad@chelsio.com>
Cc: Santosh Rastapur <santosh@chelsio.com>
Cc: MPT-FusionLinux.pdl@avagotech.com
Cc: linux-scsi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 Documentation/kernel-parameters.txt |  9 +++++++
 drivers/base/bus.c                  | 52 ++++++++++++++++++++++++++++++-------
 include/linux/device.h              |  9 +++++++
 3 files changed, 60 insertions(+), 10 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index e4be3b8..56f4d4e 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -914,12 +914,21 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			Enable debug messages at boot time.  See
 			Documentation/dynamic-debug-howto.txt for details.
 
+	bus.enable_kern_async=1 [KNL]
+			This tells the kernel userspace has been vetted for
+			asynchronous probe support and can listen to the device
+			driver prefer_async_probe flag for both built-in device
+			drivers and modules.
 	module.async_probe [KNL]
 			Enable asynchronous probe on this module.
 	bus.__DEBUG__module_force_mod_async_probe=1 [KNL]
 			Enable asynchronous probe on all modules. This is
 			testing parameter and using it will taint your
 			kernel.
+	bus.__DEBUG__kernel_force_mod_async_probe=1 [KNL]
+			Enable asynchronous probe on all built-in drivers. This
+			is testing parameter and using it will taint your
+			kernel.
 
 	early_ioremap_debug [KNL]
 			Enable debug messages in early_ioremap support. This
diff --git a/drivers/base/bus.c b/drivers/base/bus.c
index ec203d6..25d0412 100644
--- a/drivers/base/bus.c
+++ b/drivers/base/bus.c
@@ -695,8 +695,10 @@ int bus_driver_async_probe(struct device_driver *drv)
 	INIT_WORK(&priv->attach_work->work, driver_attach_workfn);
 
 	/* Keep this as pr_info() until this is prevalent */
-	pr_info("bus: '%s': probe for driver %s is run asynchronously\n",
-		 drv->bus->name, drv->name);
+	pr_info("bus: '%s': probe for %s driver %s is run asynchronously\n",
+		 drv->bus->name,
+		 drv->owner ? "module" : "built-in",
+		 drv->name);
 
 	queue_work(system_unbound_wq, &priv->attach_work->work);
 
@@ -708,6 +710,16 @@ module_param_named(__DEBUG__module_force_mod_async_probe, force_mod_async, bool,
 MODULE_PARM_DESC(__DEBUG__module_force_mod_async_probe,
 		 "Force async probe on all modules");
 
+static bool force_kern_async = false;
+module_param_named(__DEBUG__kernel_force_mod_async_probe, force_kern_async, bool, 0400);
+MODULE_PARM_DESC(__DEBUG__kernel_force_mod_async_probe,
+		 "Force async probe on all modules");
+
+static bool enable_kern_async = false;
+module_param_named(enable_kern_async, enable_kern_async, bool, 0400);
+MODULE_PARM_DESC(enable_kern_async,
+		 "Userspace is vetted to handle driver async probe");
+
 /**
  * drv_enable_async_probe - evaluates if async probe should be used
  * @drv: device driver to evaluate
@@ -722,25 +734,41 @@ MODULE_PARM_DESC(__DEBUG__module_force_mod_async_probe,
  * be used on it.
  *
  * Drivers can be built-in or modules. Userspace can inform the kernel that
- * it is prepared for async probe by passing the module parameter
- * async_probe on each module it wishes to load. The async_probe parameter is
+ * it is prepared for async probe by either passing the module parameter
+ * async_probe on each module it wishes to load or by enabling the
+ * bus.enable_kern_async=1 kernel parameter. The async_probe parameter is
  * module specific and gives userspace the flexibility to opt out of using
- * async probe for certain types of modules. Built-in drivers are currently
- * not supported for async probe.
+ * async probe for certain types of modules. Built-in drivers and modules which
+ * are known to work well with async probe can enable @drv->prefer_async_probe,
+ * async probe will be used for it if the kernel parameter but only if the
+ * kernel parameter bus.enable_kern_async=1 has been set.
  *
  * If you'd like to test enabling async probe for all modules you can enable
- * the bus.__DEBUG__module_force_mod_async_probe=1 kernel parameter. This
- * parameter should only be used to help test and should be used with caution.
+ * the bus.__DEBUG__module_force_mod_async_probe=1 kernel parameter. If you'd
+ * like to test enabling async probe for all built-in drivers you can enable
+ * the bus.__DEBUG__kernel_force_mod_async_probe=1 kernel parameter. These
+ * parameters should only be used to help test and should be used with caution.
  */
 static bool drv_enable_async_probe(struct device_driver *drv,
 				   struct bus_type *bus)
 {
 	struct module *mod;
 
-	if (!drv->owner || drv->sync_probe)
+	if (drv->sync_probe)
+		return false;
+
+	/* built-in drivers */
+	if (!drv->owner) {
+		if (!enable_kern_async)
+			return false;
+		if (drv->prefer_async_probe || force_kern_async)
+			return true;
 		return false;
+	}
 
-	if (force_mod_async)
+	/* modules */
+	if ((enable_kern_async && drv->prefer_async_probe) ||
+	    force_mod_async)
 		return true;
 
 	mod = drv->owner;
@@ -1364,6 +1392,10 @@ int __init buses_init(void)
 		pr_info("Enabling force_mod_async -- you're on your own!\n");
 		add_taint(TAINT_DEBUG, LOCKDEP_STILL_OK);
 	}
+	if (unlikely(force_kern_async)) {
+		pr_info("Enabling force_kern_async -- you're on your own!\n");
+		add_taint(TAINT_DEBUG, LOCKDEP_STILL_OK);
+	}
 
 	bus_kset = kset_create_and_add("bus", &bus_uevent_ops, NULL);
 	if (!bus_kset)
diff --git a/include/linux/device.h b/include/linux/device.h
index aa14b95..058a8e0 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -202,6 +202,14 @@ extern struct klist *bus_get_device_klist(struct bus_type *bus);
  * @suppress_bind_attrs: Disables bind/unbind via sysfs.
  * @sync_probe:	Use this to annotate drivers which don't work well with
  *		async probe.
+ * @prefer_async_probe: if userspace is vetted for async probe support enable
+ * 		async probe on this device driver whether module or built-in.
+ * 		Userspace expresses it is vetted for async probe support by
+ * 		enabling the bus.enable_kern_async=1 kernel parameter. Without
+ * 		this option enabled userspace can still request modules to be
+ * 		loaded asynchronously by using the shared async_probe module
+ * 		parameter. Built-in drivers must however enable
+ * 		prefer_async_probe and cope with bus.enable_kern_async=1
  * @of_match_table: The open firmware table.
  * @acpi_match_table: The ACPI match table.
  * @probe:	Called to query the existence of a specific device,
@@ -236,6 +244,7 @@ struct device_driver {
 
 	bool suppress_bind_attrs;	/* disables bind/unbind via sysfs */
 	bool sync_probe;
+	bool prefer_async_probe;
 
 	const struct of_device_id	*of_match_table;
 	const struct acpi_device_id	*acpi_match_table;
-- 
2.1.1

