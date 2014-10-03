From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v2 6/7] driver-core: add driver module asynchronous probe support
Date: Fri,  3 Oct 2014 14:44:42 -0700
Message-ID: <1412372683-2003-7-git-send-email-mcgrof@do-not-panic.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412372683-2003-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

Some init systems may wish to express the desire to have
device drivers run their device driver's bus probe() run
asynchronously. This implements support for this and
allows userspace to request async probe as a preference
through a generic shared device driver module parameter,
async_probe. Implemention for async probe is supported
through a module parameter given that since synchronous
probe has been prevalent for years some userspace might
exist which relies on the fact that the device driver will
probe synchronously and the assumption that devices it
provides will be immediately available after this.

Some device driver might not be able to run async probe
so we enable device drivers to annotate this to prevent
this module parameter from having any effect on them.

This implementation uses queue_work(system_unbound_wq)
to queue async probes, this should enable probe to run
slightly *faster* if the driver's probe path did not
have much interaction with other workqueues otherwise
it may run _slightly_ slower. Tests were done with cxgb4,
which is known to take long on probe, both without
having to run request_firmware() [0] and then by
requiring it to use request_firmware() [1]. The
difference in run time are only measurable in microseconds:

=====================================================================|
strategy                                fw (usec)       no-fw (usec) |
---------------------------------------------------------------------|
synchronous                             24472569        1307563      |
kthread                                 25066415.5      1309868.5    |
queue_work(system_unbound_wq)           24913661.5      1307631      |
---------------------------------------------------------------------|

In practice, in seconds, the difference is barely noticeable:

=====================================================================|
strategy                                fw (s)          no-fw (s)    |
---------------------------------------------------------------------|
synchronous                             24.47           1.31         |
kthread                                 25.07           1.31         |
queue_work(system_unbound_wq)           24.91           1.31         |
---------------------------------------------------------------------|

[0] http://ftp.suse.com/pub/people/mcgrof/async-probe/probe-cgxb4-no-firmware.png
[1] http://ftp.suse.com/pub/people/mcgrof/async-probe/probe-cgxb4-firmware.png

Systemd should consider enabling async probe on device drivers
it loads through systemd-udev but probably does not want to
enable it for modules loaded through systemd-modules-load
(modules-load.d). At least on my booting enabling async probe
for all modules fails to boot as such in order to make this
a bit more useful we whitelist a few buses where it should be
at least in theory safe to try to enable async probe. This
way even if systemd tried to ask to enable async probe for all
its device drivers the kernel won't blindly do this. We also
have the sync_probe flag which device drivers can themselves
enable *iff* its known the device driver should never async
probe.

In order to help *test* things folks can use the kernel parameter
bus.__DEBUG__module_safe_mod_async_probe=1 which will work as if
userspace would have requested all modules to load with async probe.
Daring folks can also use bus.__DEBUG__module_force_mod_async_probe=1
which will enable asynch probe even on buses not tested in any way yet,
if you use that though you're on your own. Both of these flag taint
the kernel as being in a debug intrusive mode to avoid spurious bug
reports while this mechanism gets tested.

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
Acked-by: Tom Gundersen <teg@jklm.no>
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 Documentation/kernel-parameters.txt |   7 +++
 drivers/base/base.h                 |   6 +++
 drivers/base/bus.c                  | 104 ++++++++++++++++++++++++++++++++++--
 drivers/base/dd.c                   |   7 +++
 include/linux/module.h              |   2 +
 kernel/module.c                     |  12 ++++-
 6 files changed, 133 insertions(+), 5 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 10d51c2..e4be3b8 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -914,6 +914,13 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			Enable debug messages at boot time.  See
 			Documentation/dynamic-debug-howto.txt for details.
 
+	module.async_probe [KNL]
+			Enable asynchronous probe on this module.
+	bus.__DEBUG__module_force_mod_async_probe=1 [KNL]
+			Enable asynchronous probe on all modules. This is
+			testing parameter and using it will taint your
+			kernel.
+
 	early_ioremap_debug [KNL]
 			Enable debug messages in early_ioremap support. This
 			is useful for tracking down temporary early mappings
diff --git a/drivers/base/base.h b/drivers/base/base.h
index 251c5d3..24836f1 100644
--- a/drivers/base/base.h
+++ b/drivers/base/base.h
@@ -43,11 +43,17 @@ struct subsys_private {
 };
 #define to_subsys_private(obj) container_of(obj, struct subsys_private, subsys.kobj)
 
+struct driver_attach_work {
+	struct work_struct work;
+	struct device_driver *driver;
+};
+
 struct driver_private {
 	struct kobject kobj;
 	struct klist klist_devices;
 	struct klist_node knode_bus;
 	struct module_kobject *mkobj;
+	struct driver_attach_work *attach_work;
 	struct device_driver *driver;
 };
 #define to_driver(obj) container_of(obj, struct driver_private, kobj)
diff --git a/drivers/base/bus.c b/drivers/base/bus.c
index a5f41e4..ec203d6 100644
--- a/drivers/base/bus.c
+++ b/drivers/base/bus.c
@@ -85,6 +85,7 @@ static void driver_release(struct kobject *kobj)
 	struct driver_private *drv_priv = to_driver(kobj);
 
 	pr_debug("driver: '%s': %s\n", kobject_name(kobj), __func__);
+	kfree(drv_priv->attach_work);
 	kfree(drv_priv);
 }
 
@@ -662,10 +663,93 @@ static void remove_driver_private(struct device_driver *drv)
 	struct driver_private *priv = drv->p;
 
 	kobject_put(&priv->kobj);
+	kfree(priv->attach_work);
 	kfree(priv);
 	drv->p = NULL;
 }
 
+static void driver_attach_workfn(struct work_struct *work)
+{
+	struct driver_attach_work *attach_work =
+		container_of(work, struct driver_attach_work, work);
+	struct device_driver *drv = attach_work->driver;
+	int ret;
+
+	ret = driver_attach(drv);
+	if (ret != 0) {
+		remove_driver_private(drv);
+		bus_put(drv->bus);
+	}
+}
+
+int bus_driver_async_probe(struct device_driver *drv)
+{
+	struct driver_private *priv = drv->p;
+
+	priv->attach_work = kzalloc(sizeof(struct driver_attach_work),
+				    GFP_KERNEL);
+	if (!priv->attach_work)
+		return -ENOMEM;
+
+	priv->attach_work->driver = drv;
+	INIT_WORK(&priv->attach_work->work, driver_attach_workfn);
+
+	/* Keep this as pr_info() until this is prevalent */
+	pr_info("bus: '%s': probe for driver %s is run asynchronously\n",
+		 drv->bus->name, drv->name);
+
+	queue_work(system_unbound_wq, &priv->attach_work->work);
+
+	return 0;
+}
+
+static bool force_mod_async = false;
+module_param_named(__DEBUG__module_force_mod_async_probe, force_mod_async, bool, 0400);
+MODULE_PARM_DESC(__DEBUG__module_force_mod_async_probe,
+		 "Force async probe on all modules");
+
+/**
+ * drv_enable_async_probe - evaluates if async probe should be used
+ * @drv: device driver to evaluate
+ * @bus: the bus for the device driver
+ *
+ * The driver core supports enabling asynchronous probe on device drivers
+ * through a few mechanisms. We're careful to ensure that async probe can
+ * only be used by userspace that is prepared and has been vetted to support
+ * async probe support given that the driver core has historically only
+ * supported synchronous probe. If any driver is known to not work well with
+ * async probe the @drv can enable sync_probe and asynchronous probe will never
+ * be used on it.
+ *
+ * Drivers can be built-in or modules. Userspace can inform the kernel that
+ * it is prepared for async probe by passing the module parameter
+ * async_probe on each module it wishes to load. The async_probe parameter is
+ * module specific and gives userspace the flexibility to opt out of using
+ * async probe for certain types of modules. Built-in drivers are currently
+ * not supported for async probe.
+ *
+ * If you'd like to test enabling async probe for all modules you can enable
+ * the bus.__DEBUG__module_force_mod_async_probe=1 kernel parameter. This
+ * parameter should only be used to help test and should be used with caution.
+ */
+static bool drv_enable_async_probe(struct device_driver *drv,
+				   struct bus_type *bus)
+{
+	struct module *mod;
+
+	if (!drv->owner || drv->sync_probe)
+		return false;
+
+	if (force_mod_async)
+		return true;
+
+	mod = drv->owner;
+	if (!mod->async_probe_requested)
+		return false;
+
+	return true;
+}
+
 /**
  * bus_add_driver - Add a driver to the bus.
  * @drv: driver.
@@ -675,6 +759,7 @@ int bus_add_driver(struct device_driver *drv)
 	struct bus_type *bus;
 	struct driver_private *priv;
 	int error = 0;
+	bool async_probe = false;
 
 	bus = bus_get(drv->bus);
 	if (!bus)
@@ -696,11 +781,19 @@ int bus_add_driver(struct device_driver *drv)
 	if (error)
 		goto out_unregister;
 
+	async_probe = drv_enable_async_probe(drv, bus);
+
 	klist_add_tail(&priv->knode_bus, &bus->p->klist_drivers);
 	if (drv->bus->p->drivers_autoprobe) {
-		error = driver_attach(drv);
-		if (error)
-			goto out_unregister;
+		if (async_probe) {
+			error = bus_driver_async_probe(drv);
+			if (error)
+				goto out_unregister;
+		} else {
+			error = driver_attach(drv);
+			if (error)
+				goto out_unregister;
+		}
 	}
 	module_add_driver(drv->owner, drv);
 
@@ -1267,6 +1360,11 @@ EXPORT_SYMBOL_GPL(subsys_virtual_register);
 
 int __init buses_init(void)
 {
+	if (unlikely(force_mod_async)) {
+		pr_info("Enabling force_mod_async -- you're on your own!\n");
+		add_taint(TAINT_DEBUG, LOCKDEP_STILL_OK);
+	}
+
 	bus_kset = kset_create_and_add("bus", &bus_uevent_ops, NULL);
 	if (!bus_kset)
 		return -ENOMEM;
diff --git a/drivers/base/dd.c b/drivers/base/dd.c
index e4ffbcf..7999aba 100644
--- a/drivers/base/dd.c
+++ b/drivers/base/dd.c
@@ -507,6 +507,13 @@ static void __device_release_driver(struct device *dev)
 
 	drv = dev->driver;
 	if (drv) {
+		if (drv->owner && !drv->sync_probe) {
+			struct module *mod = drv->owner;
+			struct driver_private *priv = drv->p;
+
+			if (mod->async_probe_requested)
+				flush_work(&priv->attach_work->work);
+		}
 		pm_runtime_get_sync(dev);
 
 		driver_sysfs_remove(dev);
diff --git a/include/linux/module.h b/include/linux/module.h
index 71f282a..1e9e017 100644
--- a/include/linux/module.h
+++ b/include/linux/module.h
@@ -271,6 +271,8 @@ struct module {
 	bool sig_ok;
 #endif
 
+	bool async_probe_requested;
+
 	/* symbols that will be GPL-only in the near future. */
 	const struct kernel_symbol *gpl_future_syms;
 	const unsigned long *gpl_future_crcs;
diff --git a/kernel/module.c b/kernel/module.c
index 6a07671..f5f709d 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -3175,8 +3175,16 @@ out:
 static int unknown_module_param_cb(char *param, char *val, const char *modname,
 				   void *arg)
 {
+	struct module *mod = arg;
+	int ret;
+
+	if (strcmp(param, "async_probe") == 0) {
+		mod->async_probe_requested = true;
+		return 0;
+	}
+
 	/* Check for magic 'dyndbg' arg */ 
-	int ret = ddebug_dyndbg_module_param_cb(param, val, modname);
+	ret = ddebug_dyndbg_module_param_cb(param, val, modname);
 	if (ret != 0)
 		pr_warn("%s: unknown parameter '%s' ignored\n", modname, param);
 	return 0;
@@ -3278,7 +3286,7 @@ static int load_module(struct load_info *info, const char __user *uargs,
 
 	/* Module is ready to execute: parsing args may do that. */
 	after_dashes = parse_args(mod->name, mod->args, mod->kp, mod->num_kp,
-				  -32768, 32767, NULL,
+				  -32768, 32767, mod,
 				  unknown_module_param_cb);
 	if (IS_ERR(after_dashes)) {
 		err = PTR_ERR(after_dashes);
-- 
2.1.1
