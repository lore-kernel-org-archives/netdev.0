From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [PATCH] core: fix free_netdev when register fails during notification
 call chain
Date: Tue, 30 Oct 2007 11:20:42 +0100
Message-ID: <4727057A.4050605@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:7466 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbXJ3KXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 06:23:37 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l9UANax0491816
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 10:23:36 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9UANakH3088414
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 10:23:36 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9UANJmD004600
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 10:23:19 GMT
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Point 1:
The unregistering of a network device schedule a netdev_run_todo.
This function calls dev->destructor when it is set and the
destructor calls free_netdev.

Point 2:
In the case of an initialization of a network device the usual code
is:
  * alloc_netdev
  * register_netdev
     -> if this one fails, call free_netdev and exit with error.

Point 3:
In the register_netdevice function at the later state, when the device
is at the registered state, a call to the netdevice_notifiers is made.
If one of the notification falls into an error, a rollback to the
registered state is done using unregister_netdevice.

Conclusion:
When a network device fails to register during initialization because
one network subsystem returned an error during a notification call
chain, the network device is freed twice because of fact 1 and fact 2.
The second free_netdev will be done with an invalid pointer.

Proposed solution:
The following patch move all the code of unregister_netdevice *except*
the call to net_set_todo, to a new function "rollback_registered".

The following functions are changed in this way:
  * register_netdevice: calls rollback_registered when a notification fails
  * unregister_netdevice: calls rollback_register + net_set_todo, the call
                          order to net_set_todo is changed because it is the
                          latest now. Since it justs add an element to a 
list
                          that should not break anything.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
  net/core/dev.c |  112 
++++++++++++++++++++++++++++++---------------------------
  1 file changed, 59 insertions(+), 53 deletions(-)

Index: net-2.6/net/core/dev.c
===================================================================
--- net-2.6.orig/net/core/dev.c
+++ net-2.6/net/core/dev.c
@@ -3496,6 +3496,60 @@ static void net_set_todo(struct net_devi
      spin_unlock(&net_todo_list_lock);
  }

+static void rollback_registered(struct net_device *dev)
+{
+    BUG_ON(dev_boot_phase);
+    ASSERT_RTNL();
+
+    /* Some devices call without registering for initialization unwind. */
+    if (dev->reg_state == NETREG_UNINITIALIZED) {
+        printk(KERN_DEBUG "unregister_netdevice: device %s/%p never "
+                  "was registered\n", dev->name, dev);
+
+        WARN_ON(1);
+        return;
+    }
+
+    BUG_ON(dev->reg_state != NETREG_REGISTERED);
+
+    /* If device is running, close it first. */
+    dev_close(dev);
+
+    /* And unlink it from device chain. */
+    unlist_netdevice(dev);
+
+    dev->reg_state = NETREG_UNREGISTERING;
+
+    synchronize_net();
+
+    /* Shutdown queueing discipline. */
+    dev_shutdown(dev);
+
+
+    /* Notify protocols, that we are about to destroy
+       this device. They should clean all the things.
+    */
+    call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
+
+    /*
+     *    Flush the unicast and multicast chains
+     */
+    dev_addr_discard(dev);
+
+    if (dev->uninit)
+        dev->uninit(dev);
+
+    /* Notifier chain MUST detach us from master device. */
+    BUG_TRAP(!dev->master);
+
+    /* Remove entries from kobject tree */
+    netdev_unregister_kobject(dev);
+
+    synchronize_net();
+
+    dev_put(dev);
+}
+
  /**
   *    register_netdevice    - register a network device
   *    @dev: device to register
@@ -3633,8 +3687,10 @@ int register_netdevice(struct net_device
      /* Notify protocols, that a new device appeared. */
      ret = call_netdevice_notifiers(NETDEV_REGISTER, dev);
      ret = notifier_to_errno(ret);
-    if (ret)
-        unregister_netdevice(dev);
+    if (ret) {
+        rollback_registered(dev);
+        dev->reg_state = NETREG_UNREGISTERED;
+    }

  out:
      return ret;
@@ -3911,59 +3967,9 @@ void synchronize_net(void)

  void unregister_netdevice(struct net_device *dev)
  {
-    BUG_ON(dev_boot_phase);
-    ASSERT_RTNL();
-
-    /* Some devices call without registering for initialization unwind. */
-    if (dev->reg_state == NETREG_UNINITIALIZED) {
-        printk(KERN_DEBUG "unregister_netdevice: device %s/%p never "
-                  "was registered\n", dev->name, dev);
-
-        WARN_ON(1);
-        return;
-    }
-
-    BUG_ON(dev->reg_state != NETREG_REGISTERED);
-
-    /* If device is running, close it first. */
-    dev_close(dev);
-
-    /* And unlink it from device chain. */
-    unlist_netdevice(dev);
-
-    dev->reg_state = NETREG_UNREGISTERING;
-
-    synchronize_net();
-
-    /* Shutdown queueing discipline. */
-    dev_shutdown(dev);
-
-
-    /* Notify protocols, that we are about to destroy
-       this device. They should clean all the things.
-    */
-    call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
-
-    /*
-     *    Flush the unicast and multicast chains
-     */
-    dev_addr_discard(dev);
-
-    if (dev->uninit)
-        dev->uninit(dev);
-
-    /* Notifier chain MUST detach us from master device. */
-    BUG_TRAP(!dev->master);
-
-    /* Remove entries from kobject tree */
-    netdev_unregister_kobject(dev);
-
+    rollback_registered(dev);
      /* Finish processing unregister after unlock */
      net_set_todo(dev);
-
-    synchronize_net();
-
-    dev_put(dev);
  }

  /**
