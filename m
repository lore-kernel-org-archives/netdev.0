From: Gregory Haskins <ghaskins@novell.com>
Subject: [-next PATCH 3/4] vbus: add autoprobe capability to guest
Date: Mon, 23 Nov 2009 14:54:44 -0500
Message-ID: <20091123195444.8184.93080.stgit@dev.haskins.net>
References: <20091123195136.8184.68042.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net
To: linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091123195136.8184.68042.stgit@dev.haskins.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This enables the guest to automatically load the appropriate driver
when vbus devices are detected.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/net/vbus-enet.c     |    2 ++
 drivers/vbus/bus-proxy.c    |   33 ++++++++++++++++++++++++++++++++-
 include/linux/vbus_driver.h |    2 ++
 3 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vbus-enet.c b/drivers/net/vbus-enet.c
index 25c6bea..4e9ecac 100644
--- a/drivers/net/vbus-enet.c
+++ b/drivers/net/vbus-enet.c
@@ -1556,3 +1556,5 @@ vbus_enet_cleanup(void)
 
 module_init(vbus_enet_init_module);
 module_exit(vbus_enet_cleanup);
+
+VBUS_DRIVER_AUTOPROBE(VENET_TYPE);
diff --git a/drivers/vbus/bus-proxy.c b/drivers/vbus/bus-proxy.c
index 5d34942..106e2fe 100644
--- a/drivers/vbus/bus-proxy.c
+++ b/drivers/vbus/bus-proxy.c
@@ -48,6 +48,16 @@ static int vbus_dev_proxy_match(struct device *_dev, struct device_driver *_drv)
 	return !strcmp(dev->type, drv->type);
 }
 
+static int vbus_dev_proxy_uevent(struct device *_dev, struct kobj_uevent_env *env)
+{
+	struct vbus_device_proxy *dev = to_dev(_dev);
+
+	if (add_uevent_var(env, "MODALIAS=vbus-proxy:%s", dev->type))
+		return -ENOMEM;
+
+	return 0;
+}
+
 /*
  * This function is invoked after the bus infrastructure has already made a
  * match.  The device will contain a reference to the paired driver which
@@ -68,6 +78,7 @@ static int vbus_dev_proxy_probe(struct device *_dev)
 static struct bus_type vbus_proxy = {
 	.name   = VBUS_PROXY_NAME,
 	.match  = vbus_dev_proxy_match,
+	.uevent = vbus_dev_proxy_uevent,
 };
 
 static struct device vbus_proxy_rootdev = {
@@ -99,18 +110,38 @@ static void device_release(struct device *dev)
 	_dev->ops->release(_dev);
 }
 
+static ssize_t _show_modalias(struct device *dev,
+			      struct device_attribute *attr, char *buf)
+{
+	return sprintf(buf, "vbus-proxy:%s\n", to_dev(dev)->type);
+}
+DEVICE_ATTR(modalias, S_IRUSR | S_IRGRP | S_IROTH, _show_modalias, NULL);
+
 int vbus_device_proxy_register(struct vbus_device_proxy *new)
 {
+	int ret;
+
 	new->dev.parent  = &vbus_proxy_rootdev;
 	new->dev.bus     = &vbus_proxy;
 	new->dev.release = &device_release;
 
-	return device_register(&new->dev);
+	ret = device_register(&new->dev);
+	if (ret < 0)
+		return ret;
+
+	ret = device_create_file(&new->dev, &dev_attr_modalias);
+	if (ret < 0) {
+		device_unregister(&new->dev);
+		return ret;
+	}
+
+	return 0;
 }
 EXPORT_SYMBOL_GPL(vbus_device_proxy_register);
 
 void vbus_device_proxy_unregister(struct vbus_device_proxy *dev)
 {
+	device_remove_file(&dev->dev, &dev_attr_modalias);
 	device_unregister(&dev->dev);
 }
 EXPORT_SYMBOL_GPL(vbus_device_proxy_unregister);
diff --git a/include/linux/vbus_driver.h b/include/linux/vbus_driver.h
index 2b1dac4..8a7acb1 100644
--- a/include/linux/vbus_driver.h
+++ b/include/linux/vbus_driver.h
@@ -78,4 +78,6 @@ void vbus_driver_unregister(struct vbus_driver *drv);
 int vbus_driver_ioq_alloc(struct vbus_device_proxy *dev, const char *name,
 			  int id, int prio, size_t ringsize, struct ioq **ioq);
 
+#define VBUS_DRIVER_AUTOPROBE(name) MODULE_ALIAS("vbus-proxy:" name)
+
 #endif /* _LINUX_VBUS_DRIVER_H */
