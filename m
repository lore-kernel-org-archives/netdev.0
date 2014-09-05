From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [RFC v2 2/6] driver-core: add driver async_probe support
Date: Fri, 5 Sep 2014 15:10:29 -0700
Message-ID: <20140905221029.GA35667@core.coreip.homeip.net>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <1409899047-13045-3-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, falcon@meizu.com, tiwai@suse.de,
	tj@kernel.org, arjan@linux.intel.com, linux-kernel@vger.kernel.org,
	oleg@redhat.com, hare@suse.com, akpm@linux-foundation.org,
	penguin-kernel@i-love.sakura.ne.jp, joseph.salisbury@canonical.com,
	bpoirier@suse.de, santosh@chelsio.com,
	"Luis R. Rodriguez" <mcgrof@suse.com>, Kay Sievers <kay@vrfy.org>,
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
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:46909 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbaIEWKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 18:10:34 -0400
Content-Disposition: inline
In-Reply-To: <1409899047-13045-3-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Luis,

On Thu, Sep 04, 2014 at 11:37:23PM -0700, Luis R. Rodriguez wrote:
> 1) when a built-in driver takes a few seconds to initialize its
>    delays can stall the overall boot process

This patch does not solve the 2nd issue fully as it only calls probe
asynchronously during driver registration (and also only for modules???
- it checks drv->owner in a few places). The device may get created
  after driver is initialized, in this case we still want probe to be
called asynchronously.

I think something like the patch below should work. Note that it uses
async_checdule(), so that will satisy for the moment Tejun's objections
to the behavior with regard to module loading and initialization, but it
does not solve your issue with modules being killed after 30 seconds.

To tell the truth I think systemd should not be doing it; it is not its
place to dictate how long module should take to load. It may print
warnings and we'll work on fixing the drivers, but aborting boot just
because they feel like it took too long is not a good idea.

Thanks.

-- 
Dmitry


driver-core: add driver async_probe support

From: Dmitry Torokhov <dmitry.torokhov@gmail.com>

Some devices take a long time when initializing, and not all drivers are
suited to initialize their devices when they are open. For example, input
drivers need to interrogate device in order to publish its capabilities
before userspace will open them. When such drivers are compiled into kernel
they may stall entire kernel initialization.

This change allows drivers request for their probe functions to be called
asynchronously during driver and device registration (manual binding is
still synchronous). Because async_schedule is used to perform asynchronous
calls module loading will still wait for the probing to complete.

This is based on earlier patch by "Luis R. Rodriguez" <mcgrof@suse.com>

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 drivers/base/bus.c     |   31 ++++++++++----
 drivers/base/dd.c      |  106 +++++++++++++++++++++++++++++++++++++++---------
 include/linux/device.h |    2 +
 3 files changed, 112 insertions(+), 27 deletions(-)

diff --git a/drivers/base/bus.c b/drivers/base/bus.c
index 83e910a..49fe573 100644
--- a/drivers/base/bus.c
+++ b/drivers/base/bus.c
@@ -10,6 +10,7 @@
  *
  */
 
+#include <linux/async.h>
 #include <linux/device.h>
 #include <linux/module.h>
 #include <linux/errno.h>
@@ -547,15 +548,12 @@ void bus_probe_device(struct device *dev)
 {
 	struct bus_type *bus = dev->bus;
 	struct subsys_interface *sif;
-	int ret;
 
 	if (!bus)
 		return;
 
-	if (bus->p->drivers_autoprobe) {
-		ret = device_attach(dev);
-		WARN_ON(ret < 0);
-	}
+	if (bus->p->drivers_autoprobe)
+		device_initial_probe(dev);
 
 	mutex_lock(&bus->p->mutex);
 	list_for_each_entry(sif, &bus->p->interfaces, node)
@@ -657,6 +655,17 @@ static ssize_t uevent_store(struct device_driver *drv, const char *buf,
 }
 static DRIVER_ATTR_WO(uevent);
 
+static void driver_attach_async(void *_drv, async_cookie_t cookie)
+{
+	struct device_driver *drv = _drv;
+	int ret;
+
+	ret = driver_attach(drv);
+
+	pr_debug("bus: '%s': driver %s async attach completed: %d\n",
+		 drv->bus->name, drv->name, ret);
+}
+
 /**
  * bus_add_driver - Add a driver to the bus.
  * @drv: driver.
@@ -689,9 +698,15 @@ int bus_add_driver(struct device_driver *drv)
 
 	klist_add_tail(&priv->knode_bus, &bus->p->klist_drivers);
 	if (drv->bus->p->drivers_autoprobe) {
-		error = driver_attach(drv);
-		if (error)
-			goto out_unregister;
+		if (drv->async_probe) {
+			pr_debug("bus: '%s': probing driver %s asynchronously\n",
+				drv->bus->name, drv->name);
+			async_schedule(driver_attach_async, drv);
+		} else {
+			error = driver_attach(drv);
+			if (error)
+				goto out_unregister;
+		}
 	}
 	module_add_driver(drv->owner, drv);
 
diff --git a/drivers/base/dd.c b/drivers/base/dd.c
index e4ffbcf..67a2f85 100644
--- a/drivers/base/dd.c
+++ b/drivers/base/dd.c
@@ -402,31 +402,52 @@ int driver_probe_device(struct device_driver *drv, struct device *dev)
 	return ret;
 }
 
-static int __device_attach(struct device_driver *drv, void *data)
+struct device_attach_data {
+	struct device *dev;
+	bool check_async;
+	bool want_async;
+	bool have_async;
+};
+
+static int __device_attach_driver(struct device_driver *drv, void *_data)
 {
-	struct device *dev = data;
+	struct device_attach_data *data = _data;
+	struct device *dev = data->dev;
 
 	if (!driver_match_device(drv, dev))
 		return 0;
 
+	if (drv->async_probe)
+		data->have_async = true;
+
+	if (data->check_async && drv->async_probe != data->want_async)
+		return 0;
+
 	return driver_probe_device(drv, dev);
 }
 
-/**
- * device_attach - try to attach device to a driver.
- * @dev: device.
- *
- * Walk the list of drivers that the bus has and call
- * driver_probe_device() for each pair. If a compatible
- * pair is found, break out and return.
- *
- * Returns 1 if the device was bound to a driver;
- * 0 if no matching driver was found;
- * -ENODEV if the device is not registered.
- *
- * When called for a USB interface, @dev->parent lock must be held.
- */
-int device_attach(struct device *dev)
+static void __device_attach_async_helper(void *_dev, async_cookie_t cookie)
+{
+	struct device *dev = _dev;
+	struct device_attach_data data = {
+		.dev		= dev,
+		.check_async	= true,
+		.want_async	= true,
+	};
+
+	device_lock(dev);
+
+	bus_for_each_drv(dev->bus, NULL, &data, __device_attach_driver);
+	dev_dbg(dev, "async probe completed\n");
+
+	pm_request_idle(dev);
+
+	device_unlock(dev);
+
+	put_device(dev);
+}
+
+int __device_attach(struct device *dev, bool allow_async)
 {
 	int ret = 0;
 
@@ -444,15 +465,59 @@ int device_attach(struct device *dev)
 			ret = 0;
 		}
 	} else {
-		ret = bus_for_each_drv(dev->bus, NULL, dev, __device_attach);
-		pm_request_idle(dev);
+		struct device_attach_data data = {
+			.dev = dev,
+			.check_async = allow_async,
+			.want_async = false,
+		};
+
+		ret = bus_for_each_drv(dev->bus, NULL, &data,
+					__device_attach_driver);
+		if (!ret && allow_async && data.have_async) {
+			/*
+			 * If we could not find appropriate driver
+			 * synchronously and we are allowed to do
+			 * async probes and there are drivers that
+			 * want to probe asynchronously, we'll
+			 * try them.
+			 */
+			dev_dbg(dev, "scheduling asynchronous probe\n");
+			get_device(dev);
+			async_schedule(__device_attach_async_helper, dev);
+		} else {
+			pm_request_idle(dev);
+		}
 	}
 out_unlock:
 	device_unlock(dev);
 	return ret;
 }
+
+/**
+ * device_attach - try to attach device to a driver.
+ * @dev: device.
+ *
+ * Walk the list of drivers that the bus has and call
+ * driver_probe_device() for each pair. If a compatible
+ * pair is found, break out and return.
+ *
+ * Returns 1 if the device was bound to a driver;
+ * 0 if no matching driver was found;
+ * -ENODEV if the device is not registered.
+ *
+ * When called for a USB interface, @dev->parent lock must be held.
+ */
+int device_attach(struct device *dev)
+{
+	return __device_attach(dev, false);
+}
 EXPORT_SYMBOL_GPL(device_attach);
 
+void device_initial_probe(struct device *dev)
+{
+	__device_attach(dev, true);
+}
+
 static int __driver_attach(struct device *dev, void *data)
 {
 	struct device_driver *drv = data;
@@ -507,6 +572,9 @@ static void __device_release_driver(struct device *dev)
 
 	drv = dev->driver;
 	if (drv) {
+		if (drv->async_probe)
+			async_synchronize_full();
+
 		pm_runtime_get_sync(dev);
 
 		driver_sysfs_remove(dev);
diff --git a/include/linux/device.h b/include/linux/device.h
index 43d183a..c6fa2e7 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -233,6 +233,7 @@ struct device_driver {
 	const char		*mod_name;	/* used for built-in modules */
 
 	bool suppress_bind_attrs;	/* disables bind/unbind via sysfs */
+	bool async_probe;
 
 	const struct of_device_id	*of_match_table;
 	const struct acpi_device_id	*acpi_match_table;
@@ -966,6 +967,7 @@ extern int __must_check device_bind_driver(struct device *dev);
 extern void device_release_driver(struct device *dev);
 extern int  __must_check device_attach(struct device *dev);
 extern int __must_check driver_attach(struct device_driver *drv);
+extern void device_initial_probe(struct device *dev);
 extern int __must_check device_reprobe(struct device *dev);
 
 /*
