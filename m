From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] simplify netdev_sysfs_xxx if SYSFS is not configured
Date: Fri, 28 May 2004 11:03:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040528110332.2206b9ac@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don't need all the network sysfs code if CONFIG_SYSFS is not enabled.
Also:
	* netdev_sysfs_unregister is declaration mismatch
	* if netdev_sysfs_register fails print a warning.
	  Need to still mark it as registered so the unregister_netdevice works,
	  but we will probably end up leaking memory in that case.

diff -Nru a/net/core/Makefile b/net/core/Makefile
--- a/net/core/Makefile	2004-05-28 10:09:11 -07:00
+++ b/net/core/Makefile	2004-05-28 10:09:11 -07:00
@@ -6,9 +6,10 @@
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
-obj-y		     += flow.o dev.o ethtool.o net-sysfs.o dev_mcast.o dst.o \
+obj-y		     += flow.o dev.o ethtool.o dev_mcast.o dst.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
 
+obj-$(CONFIG_SYSFS) += net-sysfs.o
 obj-$(CONFIG_NETFILTER) += netfilter.o
 obj-$(CONFIG_NET_DIVERT) += dv.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-05-28 10:09:11 -07:00
+++ b/net/core/dev.c	2004-05-28 10:09:11 -07:00
@@ -220,9 +220,15 @@
 int netdev_fastroute_obstacles;
 #endif
 
+#ifdef CONFIG_SYSFS
 extern int netdev_sysfs_init(void);
 extern int netdev_register_sysfs(struct net_device *);
-extern int netdev_unregister_sysfs(struct net_device *);
+extern void netdev_unregister_sysfs(struct net_device *);
+#else
+#define netdev_sysfs_init()	 	(0)
+#define netdev_register_sysfs(dev)	(0)
+#define	netdev_unregister_sysfs(dev)	do { } while(0)
+#endif
 
 
 /*******************************************************************************
@@ -2971,6 +2977,7 @@
 void netdev_run_todo(void)
 {
 	struct list_head list = LIST_HEAD_INIT(list);
+	int err;
 
 	/* Safe outside mutex since we only care about entries that
 	 * this cpu put into queue while under RTNL.
@@ -2993,7 +3000,10 @@
 
 		switch(dev->reg_state) {
 		case NETREG_REGISTERING:
-			netdev_register_sysfs(dev);
+			err = netdev_register_sysfs(dev);
+			if (err)
+				printk(KERN_ERR "%s: failed sysfs registration (%d)\n",
+				       dev->name, err);
 			dev->reg_state = NETREG_REGISTERED;
 			break;
 
@@ -3037,6 +3047,7 @@
  */
 void free_netdev(struct net_device *dev)
 {
+#ifdef CONFIG_SYSFS
 	/*  Compatiablity with error handling in drivers */
 	if (dev->reg_state == NETREG_UNINITIALIZED) {
 		kfree((char *)dev - dev->padded);
@@ -3048,6 +3059,9 @@
 
 	/* will free via class release */
 	class_device_put(&dev->class_dev);
+#else
+	kfree((char *)dev - dev->padded);
+#endif
 }
  
 /* Synchronize with packet receive processing. */
