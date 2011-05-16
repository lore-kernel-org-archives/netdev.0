From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 1/2] driver core: add device_add_noevent() and
	device_uevent()
Date: Mon, 16 May 2011 17:46:39 +0300
Message-ID: <20110516144638.13838.28971.stgit@localhost6.localdomain6>
References: <20110516143913.13838.85357.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110516143913.13838.85357.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kalle.valo-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>

To make it possible to postpone uevent after the device is registered
create the two new functions: device_add_noevent() and device_uevent().
This is needed by register_netdevice() to fix a race where the netdevice
is not ready until the initialisation has finished.

Signed-off-by: Kalle Valo <kalle.valo-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
---
 drivers/base/core.c    |   76 +++++++++++++++++++++++++++++++++++++-----------
 include/linux/device.h |    2 +
 2 files changed, 61 insertions(+), 17 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 81b78ed..54208e0 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -872,22 +872,7 @@ int device_private_init(struct device *dev)
 	return 0;
 }
 
-/**
- * device_add - add device to device hierarchy.
- * @dev: device.
- *
- * This is part 2 of device_register(), though may be called
- * separately _iff_ device_initialize() has been called separately.
- *
- * This adds @dev to the kobject hierarchy via kobject_add(), adds it
- * to the global and sibling lists for the device, then
- * adds it to the other relevant subsystems of the driver model.
- *
- * NOTE: _Never_ directly free @dev after calling this function, even
- * if it returned an error! Always use put_device() to give up your
- * reference instead.
- */
-int device_add(struct device *dev)
+static int __device_add(struct device *dev, bool event)
 {
 	struct device *parent = NULL;
 	struct class_interface *class_intf;
@@ -974,7 +959,9 @@ int device_add(struct device *dev)
 		blocking_notifier_call_chain(&dev->bus->p->bus_notifier,
 					     BUS_NOTIFY_ADD_DEVICE, dev);
 
-	kobject_uevent(&dev->kobj, KOBJ_ADD);
+	if (event)
+		kobject_uevent(&dev->kobj, KOBJ_ADD);
+
 	bus_probe_device(dev);
 	if (parent)
 		klist_add_tail(&dev->p->knode_parent,
@@ -1026,6 +1013,61 @@ name_error:
 }
 
 /**
+ * device_add - add device to device hierarchy.
+ * @dev: device.
+ *
+ * This is part 2 of device_register(), though may be called
+ * separately _iff_ device_initialize() has been called separately.
+ *
+ * This adds @dev to the kobject hierarchy via kobject_add(), adds it
+ * to the global and sibling lists for the device, then
+ * adds it to the other relevant subsystems of the driver model.
+ *
+ * NOTE: _Never_ directly free @dev after calling this function, even
+ * if it returned an error! Always use put_device() to give up your
+ * reference instead.
+ */
+int device_add(struct device *dev)
+{
+	return __device_add(dev, true);
+}
+
+/**
+ * device_add - add device to device hierarchy but omit uevent
+ * @dev: device.
+ *
+ * This is part 2 of device_register(), though may be called
+ * separately _iff_ device_initialize() has been called separately.
+ *
+ * This adds @dev to the kobject hierarchy via kobject_add(), adds it
+ * to the global and sibling lists for the device, then
+ * adds it to the other relevant subsystems of the driver model.
+ *
+ * This version differs from device_add() so that it does not emit uevent.
+ * Instead call device_uevent() separately.
+ *
+ * NOTE: _Never_ directly free @dev after calling this function, even
+ * if it returned an error! Always use put_device() to give up your
+ * reference instead.
+ */
+int device_add_noevent(struct device *dev)
+{
+	return __device_add(dev, false);
+}
+
+/**
+ * device_uevent - emit uevent for device addition
+ * @dev: device.
+ *
+ * This is part 2 of device_add_noevent(). It emits the signal which was
+ * not sent when device_add_noevent() was called.
+ */
+void device_uevent(struct device *dev)
+{
+	kobject_uevent(&dev->kobj, KOBJ_ADD);
+}
+
+/**
  * device_register - register a device with the system.
  * @dev: pointer to the device structure
  *
diff --git a/include/linux/device.h b/include/linux/device.h
index ab8dfc0..408d4f0 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -546,6 +546,8 @@ extern int __must_check device_register(struct device *dev);
 extern void device_unregister(struct device *dev);
 extern void device_initialize(struct device *dev);
 extern int __must_check device_add(struct device *dev);
+extern int __must_check device_add_noevent(struct device *dev);
+extern void device_uevent(struct device *dev);
 extern void device_del(struct device *dev);
 extern int device_for_each_child(struct device *dev, void *data,
 		     int (*fn)(struct device *dev, void *data));

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
