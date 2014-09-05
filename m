From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v2 2/6] driver-core: add driver async_probe support
Date: Thu,  4 Sep 2014 23:37:23 -0700
Message-ID: <1409899047-13045-3-git-send-email-mcgrof@do-not-panic.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
Cc: linux-kernel@vger.kernel.org, oleg@redhat.com, hare@suse.com,
	akpm@linux-foundation.org, penguin-kernel@i-love.sakura.ne.jp,
	joseph.salisbury@canonical.com, bpoirier@suse.de,
	santosh@chelsio.com, "Luis R. Rodriguez" <mcgrof@suse.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	falcon@meizu.com, tiwai@suse.de, tj@kernel.org,
	arjan@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

We now have two documented use cases for probing asynchronously:

0) since we bundle together driver init() and probe() systemd's
   new 30 second timeout has put a limit on the amount of time
   a driver probe routine can take, we need to enable drivers
   to complete probe gracefully

1) when a built-in driver takes a few seconds to initialize its
   delays can stall the overall boot process

The built-in driver issues is pretty straight forward, and for
that we just need to let the probing happen behind the scenes.

The systemd issue is a bit more complex given the history of
how it was identified and work arounds proposed and evaluated.
The systemd issue was first identified first by Joseph when he
bisected and found that Tetsuo Handa's commit 786235ee
"kthread: make kthread_create() killable" modified kthread_create()
to bail as soon as SIGKILL is received [0] [1]. This was found
to cause some issues with some drivers and at times boot. There
are other patches which could also enable the SIGKILL trigger on
driver loading though:

70834d30 "usermodehelper: use UMH_WAIT_PROC consistently"
b3449922 "usermodehelper: introduce umh_complete(sub_info)"
d0bd587a "usermodehelper: implement UMH_KILLABLE"
9d944ef3 "usermodehelper: kill umh_wait, renumber UMH_* constants"
5b9bd473 "usermodehelper: ____call_usermodehelper() doesn't need do_exit()"
3e63a93b "kmod: introduce call_modprobe() helper"
1cc684ab "kmod: make __request_module() killable"

All of these went in on 3.4 upstream, and were part of the fixes
for CVE-2012-4398 [2] and documented more properly on Red Hat's
bugzilla [3]. Any of these patches may contribute to having a
module be properly killed now, but 786235ee is the latest in the
series. For instance on SLE12 cxgb4 has been fond to get the
SIGKILL even though SLE12 does not yet have 786235ee merged [4].

Joseph found that the systemd-udevd process sends SIGKILL to
systemd's usage of kmod for module loading if probe on a driver
takes over 30 seconds [5] [6]. When this happens probe will fail
on any driver, but *iff* its probe path ends up using kthreads.
Its why booting on some systems will fail if the driver happens
to be a storage related driver.  When helping debug the issue
Tetsuo suggested fixing this issue by kmodifying kthread_create()
to not leave upon SIGKILL immediately *unless* the source of the
SIGKILL was the OOM, and actually wait for 10 seconds more before
completing the kill [7] *unless* the source of the killer was OOM.
This is not the only source of a kill, as noted above, this same
issue is present on kernels without commit 786235ee. Additionally
upon review of this patch Oleg rejected this change [8] and the
discussion was punted out to systemd-devel to see if the default
timeout could be increased from 30 seconds to 120 [9]. The opinion
of the systemd maintainers was that the driver's behavior should
be fixed [10].  Linus seems to agree [11], however more recently
even networking drivers have been reported to fail on probe
since just writing the firmware to a device and kicking it can
take easy over 60 seconds [4]. Benjamim was able to trace the
issues reported on cxgb4 down to the same systemd-udevd 30
second timeout [6].  Even if asynch firmware loading was used
on the cxgb4 driver the driver would *still* hit other delays
due to the way the driver is currently designed, fixing that
will require a bit of time and until then some users are left
with a completely dysfunctional device.

Folks were a bit confused here though -- its not only module
initialization which is being penalized, because the driver core
will immediately trigger the driver's own bus probe routine if
autoprobe is enabled each driver's probe routine must also
complete within the same 30 second timeout.  This means not only
should driver's init complete within the set default systemd
timeout of 30 seconds but so should the probe routine, and
probe would obviously also have less time given that the
timeout is for both the module's init() and its own bus' probe().
A few drivers fail to complete the bus' probe within 30 seconds,
its not the init routine that takes long. The timeout seems
to currently hit *iff* kthreads are used somehow on the driver's
probe path. For example purposely breaking the e1000e driver
by adding a 30 second timeout on the probe path does not let
systemd kill it, however doing the same for iwlwifi triggers
the kill, this is because this driver uses request_threaded_irq()
and behind the scenes the kernel uses ktread_create() on
__setup_irq() to handle the thread *iff* its not nested, these
are drivers that set irq_set_nested_thread(irq, 1).

Hannes Reinecke has implemented now a timeout modifier for
systemd, however *systemd* still needs a way to gracefully
annotate drivers with long probes instead of failing these
drivers and at worst boot. On the kernel side of things we
can circumvent the timeout by probing asynchronously on only
drivers that need it. If a driver is changed to use this new
asynch probing, folks should be aware that any userspace
that assumed that completing driver loading would enable
device functionality will need to changed until the device
appears.

[0]  http://thread.gmane.org/gmane.linux.ubuntu.devel.kernel.general/39123
[1]  https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1276705
[2]  http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2012-4398
[3]  https://bugzilla.redhat.com/show_bug.cgi?id=CVE-2012-4398
[4]  https://bugzilla.novell.com/show_bug.cgi?id=877622
[5]  http://article.gmane.org/gmane.linux.kernel/1669550
[6]  https://bugs.launchpad.net/ubuntu/+source/systemd/+bug/1297248
[7]  https://launchpadlibrarian.net/169657493/kthread-defer-leaving.patch
[8]  http://article.gmane.org/gmane.linux.kernel/1669604
[9]  http://lists.freedesktop.org/archives/systemd-devel/2014-March/018006.html
[10] http://article.gmane.org/gmane.comp.sysutils.systemd.devel/17860
[11] http://article.gmane.org/gmane.linux.kernel/1671333

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
 drivers/base/base.h    |  6 +++++
 drivers/base/bus.c     | 59 +++++++++++++++++++++++++++++++++++++++++++++++---
 drivers/base/dd.c      |  4 ++++
 include/linux/device.h |  5 +++++
 4 files changed, 71 insertions(+), 3 deletions(-)

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
index a5f41e4..70d51b2 100644
--- a/drivers/base/bus.c
+++ b/drivers/base/bus.c
@@ -85,6 +85,7 @@ static void driver_release(struct kobject *kobj)
 	struct driver_private *drv_priv = to_driver(kobj);
 
 	pr_debug("driver: '%s': %s\n", kobject_name(kobj), __func__);
+	kfree(drv_priv->attach_work);
 	kfree(drv_priv);
 }
 
@@ -662,10 +663,56 @@ static void remove_driver_private(struct device_driver *drv)
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
+	pr_debug("bus: '%s': probe for driver %s is run asynchronously\n",
+		 drv->bus->name, drv->name);
+
+	queue_work(system_unbound_wq, &priv->attach_work->work);
+
+	return 0;
+}
+
 /**
  * bus_add_driver - Add a driver to the bus.
  * @drv: driver.
@@ -698,9 +745,15 @@ int bus_add_driver(struct device_driver *drv)
 
 	klist_add_tail(&priv->knode_bus, &bus->p->klist_drivers);
 	if (drv->bus->p->drivers_autoprobe) {
-		error = driver_attach(drv);
-		if (error)
-			goto out_unregister;
+		if (drv->owner && drv->async_probe) {
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
 
diff --git a/drivers/base/dd.c b/drivers/base/dd.c
index e4ffbcf..f1565f3 100644
--- a/drivers/base/dd.c
+++ b/drivers/base/dd.c
@@ -507,6 +507,10 @@ static void __device_release_driver(struct device *dev)
 
 	drv = dev->driver;
 	if (drv) {
+		if (drv->owner && drv->async_probe) {
+			struct driver_private *priv = drv->p;
+			flush_work(&priv->attach_work->work);
+		}
 		pm_runtime_get_sync(dev);
 
 		driver_sysfs_remove(dev);
diff --git a/include/linux/device.h b/include/linux/device.h
index 43d183a..7de1386b 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -200,6 +200,10 @@ extern struct klist *bus_get_device_klist(struct bus_type *bus);
  * @owner:	The module owner.
  * @mod_name:	Used for built-in modules.
  * @suppress_bind_attrs: Disables bind/unbind via sysfs.
+ * @async_probe: requests probe to be run asynchronously. Drivers that
+ * 	have this enabled must take care that userspace will return
+ * 	immediately upon driver loading as probing will happen behind the
+ * 	schenes asynchronously.
  * @of_match_table: The open firmware table.
  * @acpi_match_table: The ACPI match table.
  * @probe:	Called to query the existence of a specific device,
@@ -233,6 +237,7 @@ struct device_driver {
 	const char		*mod_name;	/* used for built-in modules */
 
 	bool suppress_bind_attrs;	/* disables bind/unbind via sysfs */
+	bool async_probe;
 
 	const struct of_device_id	*of_match_table;
 	const struct acpi_device_id	*acpi_match_table;
-- 
2.0.3
