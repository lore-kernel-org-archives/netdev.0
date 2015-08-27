From: sfeldma@gmail.com
Subject: [RFC PATCH net-next 1/2] switchdev: create new switchdev device class
Date: Thu, 27 Aug 2015 00:16:45 -0700
Message-ID: <1440659806-56582-2-git-send-email-sfeldma@gmail.com>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, davem@davemloft.net, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35565 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbbH0HOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 03:14:12 -0400
Received: by pacdd16 with SMTP id dd16so15810298pac.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 00:14:12 -0700 (PDT)
In-Reply-To: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   16 ++++++++++
 net/switchdev/switchdev.c |   76 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 92 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 319baab..d61e73c 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -16,6 +16,11 @@
 
 #define SWITCHDEV_F_NO_RECURSE		BIT(0)
 
+struct switchdev {
+	struct device dev;
+	atomic_t foo;
+};
+
 enum switchdev_trans {
 	SWITCHDEV_TRANS_NONE,
 	SWITCHDEV_TRANS_PREPARE,
@@ -126,6 +131,8 @@ switchdev_notifier_info_to_dev(const struct switchdev_notifier_info *info)
 
 #ifdef CONFIG_NET_SWITCHDEV
 
+int register_switchdev(struct switchdev *sdev, const char *name);
+void unregister_switchdev(struct switchdev *sdev);
 int switchdev_port_attr_get(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_attr_set(struct net_device *dev,
@@ -164,6 +171,15 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
 
 #else
 
+static inline int register_switchdev(struct switchdev *sdev, const char *name)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline void unregister_switchdev(struct switchdev *sdev)
+{
+}
+
 static inline int switchdev_port_attr_get(struct net_device *dev,
 					  struct switchdev_attr *attr)
 {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 16c1c43..f705202 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
 #include <linux/mutex.h>
@@ -19,6 +20,63 @@
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
 
+#define to_switchdev(d) container_of(d, struct switchdev, dev)
+
+static void switchdev_release(struct device *dev)
+{
+}
+
+static ssize_t foo_show(struct device *dev, struct device_attribute *attr,
+			char *buf)
+{
+	struct switchdev *switchdev = to_switchdev(dev);
+
+	return sprintf(buf, "%d\n", atomic_read(&switchdev->foo));
+}
+
+static DEVICE_ATTR_RO(foo);
+
+static struct attribute *switchdev_attrs[] = {
+	&dev_attr_foo.attr
+};
+
+ATTRIBUTE_GROUPS(switchdev);
+
+static int switchdev_uevent(struct device *d, struct kobj_uevent_env *env)
+{
+	return 0;
+}
+
+static struct class switchdev_class = {
+	.name = "switchdev",
+	.dev_release = switchdev_release,
+	.dev_groups = switchdev_groups,
+	.dev_uevent = switchdev_uevent,
+};
+
+int register_switchdev(struct switchdev *sdev, const char *name)
+{
+	struct device *dev = &sdev->dev;
+	int err;
+
+	device_initialize(dev);
+
+	dev->class = &switchdev_class;
+
+	err = dev_set_name(dev, "%s", name);
+	if (err)
+		return err;
+
+	return device_add(dev);
+}
+EXPORT_SYMBOL_GPL(register_switchdev);
+
+void unregister_switchdev(struct switchdev *sdev)
+{
+	put_device(&sdev->dev);
+}
+EXPORT_SYMBOL_GPL(unregister_switchdev);
+
 /**
  *	switchdev_port_attr_get - Get port attribute
  *
@@ -1142,3 +1200,21 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
 	dev->offload_fwd_mark = mark;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fwd_mark_set);
+
+static int __init switchdev_module_init(void)
+{
+	return class_register(&switchdev_class);
+}
+
+static void __exit switchdev_module_exit(void)
+{
+	class_unregister(&switchdev_class);
+}
+
+module_init(switchdev_module_init);
+module_exit(switchdev_module_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
+MODULE_AUTHOR("Scott Feldman <sfeldma@gmail.com>");
+MODULE_DESCRIPTION("Ethernet switch device model");
-- 
1.7.10.4
