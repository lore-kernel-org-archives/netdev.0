From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v1 5/5] driver-core: add driver asynchronous probe support
Date: Fri, 26 Sep 2014 14:57:17 -0700
Message-ID: <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com>
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
In-Reply-To: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com>
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

The rest of the commit log documents why this feature was implemented
primarily first for systemd and things it should consider next.

Systemd has a general timeout for all workers currently set to 180
seconds after which it will send a sigkill signal. Systemd now has a
warning which is issued once it reaches 1/3 of the timeout. The original
motivation for the systemd timeout was to help track device drivers
which do not use asynch firmware loading on init() and the timeout was
originally set to 30 seconds.

Since systemd + kernel are heavily tied in for the purposes of this
patch it is assumed you have merged on systemd the following
commits:

671174136525ddf208cdbe75d6d6bd159afa961f        udev: timeout - warn after a third of the timeout before killing
b5338a19864ac3f5632aee48069a669479621dca        udev: timeout - increase timeout
2e92633dbae52f5ac9b7b2e068935990d475d2cd        udev: bump event timeout to 60 seconds
be2ea723b1d023b3d385d3b791ee4607cbfb20ca        udev: remove userspace firmware loading support
9f20a8a376f924c8eb5423cfc1f98644fc1e2d1a        udev: fixup commit
dd5eddd28a74a49607a8fffcaf960040dba98479        udev: unify event timeout handling
9719859c07aa13539ed2cd4b31972cd30f678543        udevd: add --event-timeout commandline option

Since we bundle together serially driver init() and probe()
on module initialiation systemd's imposed timeout  put a limit on the
amount of time a driver init() and probe routines can take. There's a
few overlooked issues with this and the timeout in general:

0) Not all drivers are killed, the signal is just sent and
   the kill will only be acted upoon if the driver you loaded
   happens to have some code path that either uses kthreads (which
   as of 786235ee are now killable), or uses some code which checks for
   fatal_signal_pending() on the kernel somewhere -- i.e: pci_read_vpd().

1) Since systemd is the only one logging the sigkill debugging that
   drivers are not loaded or in the worst case *failed to boot* because
   of a sigkill has proven hard to debug.

2) When and if the signal is received by the driver somehow
   the driver may fail at different points in its initialization
   and unless all error paths on the driver are implemented
   perfectly this could mean leaving a device in a half
   initialized state.

3) The timeout is penalizing device drivers that take long on
   probe(), this wasn't the original motivation. Systemd seems
   to have been under assumption that probe was asynchronous,
   this perhaps is true as an *objective* and goal for *some
   subsystems* but by no means is it true that we've been on a wide
   crusade to ensure this for all device drivers. It may be a good
   idea for *many* device drivers but penalizing them with a kill
   for taking long on probe is simply unacceptable specially
   when the timeout is completely arbitrary.

4) The driver core calls probe for *all* devices that a driver can
   claim and it does so serially, so if a device driver will need
   to probe 3 devices and if probe on the device driver is synchronous
   the amount of time that module loading will take will be:

   driver load time = init() + probe for 3 devices serially

   The timeout ultimatley ends up limiting the number of devices that
   *any* device driver can support based on the following formula:

   number_devices =          systemd_timeout
                      -------------------------------------
                         max known probe time for driver

   Lastly since the error value passed down is the value of
   the probe for the last device probed the module will fail
   to load and all devices will fail to be available.

In the Linux kernel we don't want to work around the timeout,
instead systemd must be changed to take all the above into
consideration when issuing any kills on device drivers, ideally
the sigkill should be considered to be ignored at least for
kmod. In addition to this we help systemd by giving it what it
originally considered was there and enable it to ask device
drivers to use asynchronous probe. This patch addresses that
feature.

Systemd should consider enabling async probe on device drivers
it loads through systemd-udev but probably does not want to
enable it for modules loaded through systemd-modules-load
(modules-load.d). At least on my booting enablign async probe
for all modules fails to boot as such in order to make this
a bit more useful we whitelist a few buses where it should be
at least in theory safe to try to enable async probe. This
way even if systemd tried to ask to enable async probe for all
its device drivers the kernel won't blindly do this. We also
have the sync_probe flag which device drivers can themselves
enable *iff* its known the device driver should never async
probe.

In order to help *test* things folks can use the bus.safe_mod_async_probe=1
kernel parameter which will work as if userspace would have
requested all modules to load with async probe. Daring folks can
also use bus.force_mod_async_probe=1 which will enable asynch probe
even on buses not tested in any way yet, if you use that though
you're on your own.

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
 drivers/base/base.h    |   6 +++
 drivers/base/bus.c     | 137 +++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/base/dd.c      |   7 +++
 include/linux/module.h |   2 +
 kernel/module.c        |  12 ++++-
 5 files changed, 159 insertions(+), 5 deletions(-)

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
index a5f41e4..41e321e6 100644
--- a/drivers/base/bus.c
+++ b/drivers/base/bus.c
@@ -85,6 +85,7 @@ static void driver_release(struct kobject *kobj)
 	struct driver_private *drv_priv = to_driver(kobj);
 
 	pr_debug("driver: '%s': %s\n", kobject_name(kobj), __func__);
+	kfree(drv_priv->attach_work);
 	kfree(drv_priv);
 }
 
@@ -662,10 +663,125 @@ static void remove_driver_private(struct device_driver *drv)
 	struct driver_private *priv = drv->p;
 
 	kobject_put(&priv->kobj);
+	kfree(priv->attach_work);
 	kfree(priv);
 	drv->p = NULL;
 }
 
+static void driver_attach_workfn(struct work_struct *work)
+{
+	int ret;
+	struct driver_attach_work *attach_work =
+		container_of(work, struct driver_attach_work, work);
+	struct device_driver *drv = attach_work->driver;
+	ktime_t calltime, delta, rettime;
+	unsigned long long duration;
+
+	calltime = ktime_get();
+
+	ret = driver_attach(drv);
+	if (ret != 0) {
+		remove_driver_private(drv);
+		bus_put(drv->bus);
+	}
+
+	rettime = ktime_get();
+	delta = ktime_sub(rettime, calltime);
+	duration = (unsigned long long) ktime_to_ns(delta) >> 10;
+
+	pr_debug("bus: '%s': add driver %s attach completed after %lld usecs\n",
+		 drv->bus->name, drv->name, duration);
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
+/*
+ */
+static bool safe_mod_async = false;
+module_param_named(safe_mod_async_probe, safe_mod_async, bool, 0400);
+MODULE_PARM_DESC(safe_mod_async_probe,
+		 "Enable async probe on all modules safely");
+
+static bool force_mod_async = false;
+module_param_named(force_mod_async_probe, force_mod_async, bool, 0400);
+MODULE_PARM_DESC(force_mod_async_probe,
+		 "Force async probe on all modules");
+
+/**
+ * drv_enable_async_probe - evaluates if async probe should be used
+ * @drv: device driver to evaluate
+ * @bus: the bus for the device driver
+ *
+ * The driver core supports enabling asynchronous probe on device drivers
+ * by requiring userspace to pass the module parameter "async_probe".
+ * Currently only modules are enabled to use this feature. If a device
+ * driver is known to not work properly with asynchronous probe they
+ * can force disable asynchronous probe from being enabled through
+ * userspace by adding setting sync_probe to true on the @drv. We require
+ * async probe to be requested from userspace given that we have historically
+ * supported synchronous probe and some userspaces may exist which depend
+ * on this functionality. Userspace may wish to use asynchronous probe for
+ * most device drivers but since this can fail boot in practice we only
+ * enable it currently for a set of buses.
+ *
+ * If you'd like to test enabling async probe for all buses whitelisted
+ * you can enable the safe_mod_async_probe module parameter. Note that its
+ * not a good idea to always enable this, in particular you probably don't
+ * want drivers under modules-load.d to use this. This module parameter should
+ * only be used to help test. If you'd like to test even futher you can
+ * use force_mod_async_probe, that will force enable async probe on all
+ * drivers, regardless if its bus type, it should however be used with
+ * caution.
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
+	if (!safe_mod_async && !mod->async_probe_requested)
+		return false;
+
+	/* For now lets avoid stupid bug reports */
+	if (!strcmp(bus->name, "pci") ||
+	    !strcmp(bus->name, "pci_express") ||
+	    !strcmp(bus->name, "hid") ||
+	    !strcmp(bus->name, "sdio") ||
+	    !strcmp(bus->name, "gameport") ||
+	    !strcmp(bus->name, "mmc") ||
+	    !strcmp(bus->name, "i2c") ||
+	    !strcmp(bus->name, "platform") ||
+	    !strcmp(bus->name, "usb"))
+		return true;
+
+	return false;
+}
+
 /**
  * bus_add_driver - Add a driver to the bus.
  * @drv: driver.
@@ -675,6 +791,7 @@ int bus_add_driver(struct device_driver *drv)
 	struct bus_type *bus;
 	struct driver_private *priv;
 	int error = 0;
+	bool async_probe = false;
 
 	bus = bus_get(drv->bus);
 	if (!bus)
@@ -696,11 +813,19 @@ int bus_add_driver(struct device_driver *drv)
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
 
@@ -1267,6 +1392,12 @@ EXPORT_SYMBOL_GPL(subsys_virtual_register);
 
 int __init buses_init(void)
 {
+	if (unlikely(safe_mod_async))
+		pr_info("Enabled safe_mod_async -- you may run into issues\n");
+
+	if (unlikely(force_mod_async))
+		pr_info("Enabling force_mod_async -- you're on your own!\n");
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
index 88f3d6c..31d71ff 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -3175,8 +3175,16 @@ out:
 static int unknown_module_param_cb(char *param, char *val, const char *modname,
 				   void *arg)
 {
+	int ret;
+	struct module *mod = arg;
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
2.1.0
