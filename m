From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/4) move code inline if short and used once.
Date: Fri, 15 Aug 2003 15:36:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815153613.295aba61.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Now that unregister_sysfs got smaller, just eliminate it and call 
class_device_unregister directly.  netdev_finish_unregister is called
one place, therefore it is easier to understand if we just put those
few lines into wait_allrefs state machine.


diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Fri Aug 15 15:24:32 2003
+++ b/net/core/dev.c	Fri Aug 15 15:24:32 2003
@@ -187,7 +187,6 @@
 
 extern int netdev_sysfs_init(void);
 extern int netdev_register_sysfs(struct net_device *);
-extern void netdev_unregister_sysfs(struct net_device *);
 
 
 /*******************************************************************************
@@ -2706,38 +2705,17 @@
 	goto out;
 }
 
-/**
- *	netdev_finish_unregister - complete unregistration
- *	@dev: device
+/*
+ * netdev_wait_allrefs - wait until all references are gone.
  *
- *	Destroy and free a dead device. A value of zero is returned on
- *	success.
+ * This is called when unregistering network devices.
+ *
+ * Any protocol or device that holds a reference should register
+ * for netdevice notification, and cleanup and put back the
+ * reference if they receive an UNREGISTER event.
+ * We can get stuck here if buggy protocols don't correctly
+ * call dev_put. 
  */
-static int netdev_finish_unregister(struct net_device *dev)
-{
-	BUG_TRAP(!dev->ip_ptr);
-	BUG_TRAP(!dev->ip6_ptr);
-	BUG_TRAP(!dev->dn_ptr);
-
-	if (dev->reg_state != NETREG_UNREGISTERED) {
-		printk(KERN_ERR "Freeing alive device %p, %s\n",
-		       dev, dev->name);
-		return 0;
-	}
-#ifdef NET_REFCNT_DEBUG
-	printk(KERN_DEBUG "netdev_finish_unregister: %s%s.\n", dev->name,
-	       (dev->destructor != NULL)?"":", old style");
-#endif
-
-	/* It must be the very last action, after this 'dev' may point
-	 * to freed up memory.
-	 */
-	if (dev->destructor)
-		dev->destructor(dev);
-
-	return 0;
-}
-
 static void netdev_wait_allrefs(struct net_device *dev)
 {
 	unsigned long rebroadcast_time, warning_time;
@@ -2833,13 +2811,23 @@
 			break;
 
 		case NETREG_UNREGISTERING:
-			netdev_unregister_sysfs(dev);
+			class_device_unregister(&dev->class_dev);
 			dev->reg_state = NETREG_UNREGISTERED;
 
 			netdev_wait_allrefs(dev);
+
+			/* paranoia */
 			BUG_ON(atomic_read(&dev->refcnt));
-				
-			netdev_finish_unregister(dev);
+			BUG_TRAP(!dev->ip_ptr);
+			BUG_TRAP(!dev->ip6_ptr);
+			BUG_TRAP(!dev->dn_ptr);
+
+
+			/* It must be the very last action, 
+			 * after this 'dev' may point to freed up memory.
+			 */
+			if (dev->destructor)
+				dev->destructor(dev);
 			break;
 
 		default:
diff -Nru a/net/core/net-sysfs.c b/net/core/net-sysfs.c
--- a/net/core/net-sysfs.c	Fri Aug 15 15:24:32 2003
+++ b/net/core/net-sysfs.c	Fri Aug 15 15:24:32 2003
@@ -341,11 +341,6 @@
 	return ret;
 }
 
-void netdev_unregister_sysfs(struct net_device *net)
-{
-	class_device_unregister(&net->class_dev);
-}
-
 int netdev_sysfs_init(void)
 {
 	return class_register(&net_class);
