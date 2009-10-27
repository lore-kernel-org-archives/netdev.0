From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/6] net: Introduce unregister_netdevice_many()
Date: Tue, 27 Oct 2009 18:04:19 +0100
Message-ID: <4AE72813.5080709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50949 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755920AbZJ0REj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 13:04:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce rollback_registered_many() and unregister_netdevice_many()

rollback_registered_many() is able to perform necessary steps at device dismantle
time, factorizing two expensive synchronize_net() calls.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    1 
 net/core/dev.c            |   97 ++++++++++++++++++++++++------------
 2 files changed, 66 insertions(+), 32 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0ded0a4..e7c227d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1119,6 +1119,7 @@ extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
 extern void		unregister_netdevice_queue(struct net_device *dev,
 						   struct list_head *head);
+extern void		unregister_netdevice_many(struct list_head *head);
 static inline void unregister_netdevice(struct net_device *dev)
 {
 	unregister_netdevice_queue(dev, NULL);
diff --git a/net/core/dev.c b/net/core/dev.c
index ff94e2b..15d1453 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4637,59 +4637,76 @@ static void net_set_todo(struct net_device *dev)
 	list_add_tail(&dev->todo_list, &net_todo_list);
 }
 
-static void rollback_registered(struct net_device *dev)
+static void rollback_registered_many(struct list_head *head)
 {
+	struct net_device *dev;
+
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
 
-	/* Some devices call without registering for initialization unwind. */
-	if (dev->reg_state == NETREG_UNINITIALIZED) {
-		printk(KERN_DEBUG "unregister_netdevice: device %s/%p never "
-				  "was registered\n", dev->name, dev);
+	list_for_each_entry(dev, head, unreg_list) {
+		/* Some devices call without registering
+		 * for initialization unwind.
+		 */
+		if (dev->reg_state == NETREG_UNINITIALIZED) {
+			pr_debug("unregister_netdevice: device %s/%p never "
+				 "was registered\n", dev->name, dev);
 
-		WARN_ON(1);
-		return;
-	}
+			WARN_ON(1);
+			return;
+		}
 
-	BUG_ON(dev->reg_state != NETREG_REGISTERED);
+		BUG_ON(dev->reg_state != NETREG_REGISTERED);
 
-	/* If device is running, close it first. */
-	dev_close(dev);
+		/* If device is running, close it first. */
+		dev_close(dev);
 
-	/* And unlink it from device chain. */
-	unlist_netdevice(dev);
+		/* And unlink it from device chain. */
+		unlist_netdevice(dev);
 
-	dev->reg_state = NETREG_UNREGISTERING;
+		dev->reg_state = NETREG_UNREGISTERING;
+	}
 
 	synchronize_net();
 
-	/* Shutdown queueing discipline. */
-	dev_shutdown(dev);
+	list_for_each_entry(dev, head, unreg_list) {
+		/* Shutdown queueing discipline. */
+		dev_shutdown(dev);
 
 
-	/* Notify protocols, that we are about to destroy
-	   this device. They should clean all the things.
-	*/
-	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
+		/* Notify protocols, that we are about to destroy
+		   this device. They should clean all the things.
+		*/
+		call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
 
-	/*
-	 *	Flush the unicast and multicast chains
-	 */
-	dev_unicast_flush(dev);
-	dev_addr_discard(dev);
+		/*
+		 *	Flush the unicast and multicast chains
+		 */
+		dev_unicast_flush(dev);
+		dev_addr_discard(dev);
 
-	if (dev->netdev_ops->ndo_uninit)
-		dev->netdev_ops->ndo_uninit(dev);
+		if (dev->netdev_ops->ndo_uninit)
+			dev->netdev_ops->ndo_uninit(dev);
 
-	/* Notifier chain MUST detach us from master device. */
-	WARN_ON(dev->master);
+		/* Notifier chain MUST detach us from master device. */
+		WARN_ON(dev->master);
 
-	/* Remove entries from kobject tree */
-	netdev_unregister_kobject(dev);
+		/* Remove entries from kobject tree */
+		netdev_unregister_kobject(dev);
+	}
 
 	synchronize_net();
 
-	dev_put(dev);
+	list_for_each_entry(dev, head, unreg_list)
+		dev_put(dev);
+}
+
+static void rollback_registered(struct net_device *dev)
+{
+	LIST_HEAD(single);
+	
+	list_add(&dev->unreg_list, &single);
+	rollback_registered_many(&single);
 }
 
 static void __netdev_init_queue_locks_one(struct net_device *dev,
@@ -5272,6 +5289,22 @@ void unregister_netdevice_queue(struct net_device *dev, struct list_head *head)
 EXPORT_SYMBOL(unregister_netdevice_queue);
 
 /**
+ *	unregister_netdevice_many - unregister many devices
+ *	@head: list of devices
+ *
+ */
+void unregister_netdevice_many(struct list_head *head)
+{
+	struct net_device *dev;
+
+	if (!list_empty(head)) {
+		rollback_registered_many(head);
+		list_for_each_entry(dev, head, unreg_list)
+			net_set_todo(dev);
+	}
+}
+
+/**
  *	unregister_netdev - remove device from the kernel
  *	@dev: device
  *
