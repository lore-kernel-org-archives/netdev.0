From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/9) free_netdev - free network device on last
 class_device usage
Date: Tue, 19 Aug 2003 12:18:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819121806.1e06a4b9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds the free_netdev function and associated
changes so that net_device structures are not freed until
last reference to the network device class is released.

diff -urNp -X dontdiff linux-2.5/include/linux/netdevice.h net-dev-2.5/include/linux/netdevice.h
--- linux-2.5/include/linux/netdevice.h	2003-08-18 09:20:55.749112711 -0700
+++ net-dev-2.5/include/linux/netdevice.h	2003-08-18 09:43:45.159545904 -0700
@@ -384,6 +384,7 @@ struct net_device
 	       NETREG_REGISTERED,	/* completed register todo */
 	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
 	       NETREG_UNREGISTERED,	/* completed unregister todo */
+	       NETREG_RELEASED,		/* called free_netdev */
 	} reg_state;
 
 	/* Net device features */
@@ -516,6 +517,7 @@ extern int		dev_close(struct net_device 
 extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
 extern int		unregister_netdevice(struct net_device *dev);
+extern void		free_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
 extern int		unregister_netdevice_notifier(struct notifier_block *nb);
diff -urNp -X dontdiff linux-2.5/net/core/dev.c net-dev-2.5/net/core/dev.c
--- linux-2.5/net/core/dev.c	2003-08-18 09:20:55.831097541 -0700
+++ net-dev-2.5/net/core/dev.c	2003-08-18 09:43:45.991391795 -0700
@@ -2643,7 +2643,7 @@ int register_netdevice(struct net_device
 	ASSERT_RTNL();
 
 	/* When net_device's are persistent, this will be fatal. */
-	WARN_ON(dev->reg_state != NETREG_UNINITIALIZED);
+	BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
 
 	spin_lock_init(&dev->queue_lock);
 	spin_lock_init(&dev->xmit_lock);
@@ -2788,6 +2788,8 @@ static void netdev_wait_allrefs(struct n
  *	unregister_netdevice(y2);
  *      ...
  *	rtnl_unlock();
+ *	free_netdev(y1);
+ *	free_netdev(y2);
  *
  * We are invoked by rtnl_unlock() after it drops the semaphore.
  * This allows us to deal with problems:
@@ -2827,7 +2829,7 @@ void netdev_run_todo(void)
 			break;
 
 		case NETREG_UNREGISTERING:
-			class_device_unregister(&dev->class_dev);
+			class_device_del(&dev->class_dev);
 			dev->reg_state = NETREG_UNREGISTERED;
 
 			netdev_wait_allrefs(dev);
@@ -2856,6 +2858,29 @@ void netdev_run_todo(void)
 	up(&net_todo_run_mutex);
 }
 
+/**
+ *	free_netdev - free network device
+ *	@dev: device
+ *
+ *	This function does the last stage of destroying an allocated device 
+ * 	interface. The reference to the device object is released.  
+ *	If this is the last reference then it will be freed.
+ */
+void free_netdev(struct net_device *dev)
+{
+	/*  Compatiablity with error handling in drivers */
+	if (dev->reg_state == NETREG_UNINITIALIZED) {
+		kfree(dev);
+		return;
+	}
+
+	BUG_ON(dev->reg_state != NETREG_UNREGISTERED);
+	dev->reg_state = NETREG_RELEASED;
+
+	/* will free via class release */
+	class_device_put(&dev->class_dev);
+}
+ 
 /* Synchronize with packet receive processing. */
 void synchronize_net(void) 
 {
diff -urNp -X dontdiff linux-2.5/net/core/net-sysfs.c net-dev-2.5/net/core/net-sysfs.c
--- linux-2.5/net/core/net-sysfs.c	2003-08-18 09:20:55.833097171 -0700
+++ net-dev-2.5/net/core/net-sysfs.c	2003-08-18 09:43:45.996390869 -0700
@@ -361,8 +361,23 @@ static int netdev_hotplug(struct class_d
 }
 #endif
 
+/*
+ *	netdev_release -- destroy and free a dead device. 
+ *	Called when last reference to class_device kobject is gone.
+ */
+static void netdev_release(struct class_device *cd)
+{
+	struct net_device *dev 
+		= container_of(cd, struct net_device, class_dev);
+
+	BUG_ON(dev->reg_state != NETREG_RELEASED);
+
+	kfree(dev);
+}
+
 static struct class net_class = {
 	.name = "net",
+	.release = netdev_release,
 #ifdef CONFIG_HOTPLUG
 	.hotplug = netdev_hotplug,
 #endif
diff -urNp -X dontdiff linux-2.5/net/netsyms.c net-dev-2.5/net/netsyms.c
--- linux-2.5/net/netsyms.c	2003-08-18 09:20:55.822099206 -0700
+++ net-dev-2.5/net/netsyms.c	2003-08-18 09:43:45.943400686 -0700
@@ -480,6 +480,7 @@ EXPORT_SYMBOL(call_netdevice_notifiers);
 EXPORT_SYMBOL(loopback_dev);
 EXPORT_SYMBOL(register_netdevice);
 EXPORT_SYMBOL(unregister_netdevice);
+EXPORT_SYMBOL(free_netdev);
 EXPORT_SYMBOL(synchronize_net);
 EXPORT_SYMBOL(netdev_state_change);
 EXPORT_SYMBOL(netdev_boot_setup_check);
