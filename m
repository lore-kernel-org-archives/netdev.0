From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70] Add release_netdev -- hook for sysfs/net device
 cleanup
Date: Fri, 6 Jun 2003 14:58:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030606145835.3a263df8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is the first phase of a sequence of patches to resolve network
device reference count issues exposed by the new sysfs interface.

Phase I:  introduces release_netdev which is the hook to allow later
   changes to hold onto the net device after the device has potentially
   unloaded.  Includes patch for the easy to fix devices. 

Phase II: fixes devices that encapsulate network device structure
   inside their own structure, or allocate private data in a way
   that will break later.

Phase III: changes release_netdev to handle the case of delayed freeing
   of the network device, and appropriate state checking.


diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Thu Jun  5 14:44:28 2003
+++ b/include/linux/netdevice.h	Thu Jun  5 14:44:28 2003
@@ -491,6 +491,7 @@
 extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
 extern int		unregister_netdevice(struct net_device *dev);
+extern void		release_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
 extern int		unregister_netdevice_notifier(struct notifier_block *nb);
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Thu Jun  5 14:44:28 2003
+++ b/net/core/dev.c	Thu Jun  5 14:44:28 2003
@@ -2768,6 +2768,21 @@
 	}
 }
 
+
+/**
+ *	release_netdev - free network device
+ *	@dev: device
+ *
+ *	This function does the last stage of destroying an allocated device 
+ * 	interface. Currently, it just frees the device.
+ *
+ */
+
+void release_netdev(struct net_device *dev)
+{
+	kfree(dev);
+}
+
 /* Synchronize with packet receive processing. */
 void synchronize_net(void) 
 {
diff -Nru a/net/netsyms.c b/net/netsyms.c
--- a/net/netsyms.c	Thu Jun  5 14:44:28 2003
+++ b/net/netsyms.c	Thu Jun  5 14:44:28 2003
@@ -558,6 +558,7 @@
 EXPORT_SYMBOL(loopback_dev);
 EXPORT_SYMBOL(register_netdevice);
 EXPORT_SYMBOL(unregister_netdevice);
+EXPORT_SYMBOL(release_netdev);
 EXPORT_SYMBOL(synchronize_net);
 EXPORT_SYMBOL(netdev_state_change);
 EXPORT_SYMBOL(dev_new_index);
