From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/2] netdev: do sysfs registration as part of register_netdevice
Date: Wed, 10 May 2006 10:14:53 -0700
Message-ID: <20060510171623.684680000@localhost.localdomain>
References: <20060510171452.619146000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:3994 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965005AbWEJRRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 13:17:42 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=dev-register-sleep.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The last step of netdevice registration was being done by a delayed
call, but because it was delayed, it was impossible to return any error
code if the class_device registration failed.

Side effects:
 * one state in registration process is unnecessary.
 * register_netdevice can sleep inside class_device registration/hotplug
 * code in netdev_run_todo only does unregistration so it is simpler.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- bridge.orig/include/linux/netdevice.h	2006-05-09 11:17:08.000000000 -0700
+++ bridge/include/linux/netdevice.h	2006-05-09 11:18:52.000000000 -0700
@@ -433,8 +433,7 @@
 
 	/* register/unregister state machine */
 	enum { NETREG_UNINITIALIZED=0,
-	       NETREG_REGISTERING,	/* called register_netdevice */
-	       NETREG_REGISTERED,	/* completed register todo */
+	       NETREG_REGISTERED,	/* completed register_netdevice */
 	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
 	       NETREG_UNREGISTERED,	/* completed unregister todo */
 	       NETREG_RELEASED,		/* called free_netdev */
--- bridge.orig/net/core/dev.c	2006-05-09 11:17:09.000000000 -0700
+++ bridge/net/core/dev.c	2006-05-09 11:37:18.000000000 -0700
@@ -2777,6 +2777,8 @@
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
 
+	might_sleep();
+
 	/* When net_device's are persistent, this will be fatal. */
 	BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
 
@@ -2863,6 +2865,11 @@
 	if (!dev->rebuild_header)
 		dev->rebuild_header = default_rebuild_header;
 
+	ret = netdev_register_sysfs(dev);
+	if (ret)
+		goto out_err;
+	dev->reg_state = NETREG_REGISTERED;
+
 	/*
 	 *	Default initial state at registry is that the
 	 *	device is present.
@@ -2878,14 +2885,11 @@
 	hlist_add_head(&dev->name_hlist, head);
 	hlist_add_head(&dev->index_hlist, dev_index_hash(dev->ifindex));
 	dev_hold(dev);
-	dev->reg_state = NETREG_REGISTERING;
 	write_unlock_bh(&dev_base_lock);
 
 	/* Notify protocols, that a new device appeared. */
 	blocking_notifier_call_chain(&netdev_chain, NETDEV_REGISTER, dev);
 
-	/* Finish registration after unlock */
-	net_set_todo(dev);
 	ret = 0;
 
 out:
@@ -3008,7 +3012,7 @@
  *
  * We are invoked by rtnl_unlock() after it drops the semaphore.
  * This allows us to deal with problems:
- * 1) We can create/delete sysfs objects which invoke hotplug
+ * 1) We can delete sysfs objects which invoke hotplug
  *    without deadlocking with linkwatch via keventd.
  * 2) Since we run with the RTNL semaphore not held, we can sleep
  *    safely in order to wait for the netdev refcnt to drop to zero.
@@ -3017,8 +3021,6 @@
 void netdev_run_todo(void)
 {
 	struct list_head list = LIST_HEAD_INIT(list);
-	int err;
-
 
 	/* Need to guard against multiple cpu's getting out of order. */
 	mutex_lock(&net_todo_run_mutex);
@@ -3041,40 +3043,29 @@
 			= list_entry(list.next, struct net_device, todo_list);
 		list_del(&dev->todo_list);
 
-		switch(dev->reg_state) {
-		case NETREG_REGISTERING:
-			err = netdev_register_sysfs(dev);
-			if (err)
-				printk(KERN_ERR "%s: failed sysfs registration (%d)\n",
-				       dev->name, err);
-			dev->reg_state = NETREG_REGISTERED;
-			break;
-
-		case NETREG_UNREGISTERING:
-			netdev_unregister_sysfs(dev);
-			dev->reg_state = NETREG_UNREGISTERED;
-
-			netdev_wait_allrefs(dev);
-
-			/* paranoia */
-			BUG_ON(atomic_read(&dev->refcnt));
-			BUG_TRAP(!dev->ip_ptr);
-			BUG_TRAP(!dev->ip6_ptr);
-			BUG_TRAP(!dev->dn_ptr);
-
-
-			/* It must be the very last action, 
-			 * after this 'dev' may point to freed up memory.
-			 */
-			if (dev->destructor)
-				dev->destructor(dev);
-			break;
-
-		default:
+		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
 			printk(KERN_ERR "network todo '%s' but state %d\n",
 			       dev->name, dev->reg_state);
-			break;
+			dump_stack();
+			continue;
 		}
+
+		netdev_unregister_sysfs(dev);
+		dev->reg_state = NETREG_UNREGISTERED;
+
+		netdev_wait_allrefs(dev);
+
+		/* paranoia */
+		BUG_ON(atomic_read(&dev->refcnt));
+		BUG_TRAP(!dev->ip_ptr);
+		BUG_TRAP(!dev->ip6_ptr);
+		BUG_TRAP(!dev->dn_ptr);
+
+		/* It must be the very last action,
+		 * after this 'dev' may point to freed up memory.
+		 */
+		if (dev->destructor)
+			dev->destructor(dev);
 	}
 
 out:

--

