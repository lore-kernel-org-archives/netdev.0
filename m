From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netdev: hotplug napi race cleanup
Date: Mon, 24 Apr 2006 15:23:41 -0700
Message-ID: <20060424152341.094b72d8@localhost.localdomain>
References: <20060421102503.4e44eb28@localhost.localdomain>
	<E1FX5zQ-000177-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: patrakov@ums.usu.ru, netdev@vger.kernel.org, davem@davemloft.net,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:41661 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751326AbWDXW0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 18:26:45 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FX5zQ-000177-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This follows after the earlier two patches.

Change the initialization of the class device portion of the net device
to be done earlier, so that any races before registration completes are
harmless.  Add a mutex to avoid changes to netdevice during the
class device registration. 

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- linux-2.6.orig/net/core/dev.c	2006-04-24 10:31:15.000000000 -0700
+++ linux-2.6/net/core/dev.c	2006-04-24 10:31:16.000000000 -0700
@@ -203,10 +203,12 @@
 
 #ifdef CONFIG_SYSFS
 extern int netdev_sysfs_init(void);
-extern int netdev_register_sysfs(struct net_device *);
-extern void netdev_unregister_sysfs(struct net_device *);
+extern void netdev_init_classdev(struct net_device *);
+#define netdev_register_sysfs(dev)	class_device_add(&(dev->class_dev))
+#define	netdev_unregister_sysfs(dev)	class_device_del(&(dev->class_dev))
 #else
 #define netdev_sysfs_init()	 	(0)
+#define netdev_init_classdev(dev)	do { } while(0)
 #define netdev_register_sysfs(dev)	(0)
 #define	netdev_unregister_sysfs(dev)	do { } while(0)
 #endif
@@ -2870,6 +2872,8 @@
 
 	set_bit(__LINK_STATE_PRESENT, &dev->state);
 
+	netdev_init_classdev(dev);
+
 	dev->next = NULL;
 	dev_init_scheduler(dev);
 	write_lock_bh(&dev_base_lock);
@@ -3047,7 +3051,10 @@
 			 * this is a delayed call after register_netdevice
 			 * so no way to tell device driver what is wrong.
 			 */
+			rtnl_lock();
 			err = netdev_register_sysfs(dev);
+			__rtnl_unlock();
+
 			if (err) {
 				printk(KERN_ERR "%s: failed sysfs registration (%d)\n",
 				       dev->name, err);
--- sky2-2.6.17.orig/net/core/net-sysfs.c	2006-04-24 10:31:14.000000000 -0700
+++ sky2-2.6.17/net/core/net-sysfs.c	2006-04-24 10:31:16.000000000 -0700
@@ -443,13 +443,8 @@
 #endif
 };
 
-void netdev_unregister_sysfs(struct net_device * net)
-{
-	class_device_del(&(net->class_dev));
-}
-
-/* Create sysfs entries for network device. */
-int netdev_register_sysfs(struct net_device *net)
+/* Setup class device */
+void netdev_init_classdev(struct net_device *net)
 {
 	struct class_device *class_dev = &(net->class_dev);
 	struct attribute_group **groups = net->sysfs_groups;
@@ -470,8 +465,6 @@
 	    || (net->wireless_handlers && net->wireless_handlers->get_wireless_stats))
 		*groups++ = &wireless_group;
 #endif
-
-	return class_device_add(class_dev);
 }
 
 int netdev_sysfs_init(void)
