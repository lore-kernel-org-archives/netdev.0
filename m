From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH 4/5] driver core: set up ownership of class devices in sysfs
Date: Tue, 16 Aug 2016 15:33:14 -0700
Message-ID: <1471386795-32918-5-git-send-email-dmitry.torokhov@gmail.com>
References: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Plumb in get_ownership() callback for devices belonging to a class so that
they can be created with uid/gid different from global root. This will
allow network devices in a container to belong to container's root and not
global root.

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 drivers/base/core.c    | 9 +++++++++
 include/linux/device.h | 5 +++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 0a8bdad..0f95454 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -263,10 +263,19 @@ static const void *device_namespace(struct kobject *kobj)
 	return ns;
 }
 
+static void device_get_ownership(struct kobject *kobj, kuid_t *uid, kgid_t *gid)
+{
+	struct device *dev = kobj_to_dev(kobj);
+
+	if (dev->class && dev->class->get_ownership)
+		dev->class->get_ownership(dev, uid, gid);
+}
+
 static struct kobj_type device_ktype = {
 	.release	= device_release,
 	.sysfs_ops	= &dev_sysfs_ops,
 	.namespace	= device_namespace,
+	.get_ownership	= device_get_ownership,
 };
 
 
diff --git a/include/linux/device.h b/include/linux/device.h
index 38f0281..da20b12 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -374,6 +374,9 @@ int subsys_virtual_register(struct bus_type *subsys,
  * @resume:	Used to bring the device from the sleep mode.
  * @ns_type:	Callbacks so sysfs can detemine namespaces.
  * @namespace:	Namespace of the device belongs to this class.
+ * @get_ownership: Allows class to specify uid/gid of the sysfs directories
+ *		for the devices belonging to the class. Usually tied to
+ *		device's namespace.
  * @pm:		The default device power management operations of this class.
  * @p:		The private data of the driver core, no one other than the
  *		driver core can touch this.
@@ -404,6 +407,8 @@ struct class {
 	const struct kobj_ns_type_operations *ns_type;
 	const void *(*namespace)(struct device *dev);
 
+	void (*get_ownership)(struct device *dev, kuid_t *uid, kgid_t *gid);
+
 	const struct dev_pm_ops *pm;
 
 	struct subsys_private *p;
-- 
2.8.0.rc3.226.g39d4020
