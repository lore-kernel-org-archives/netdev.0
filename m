From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/6] net: Introduce unregister_netdevice_queue()
Date: Tue, 27 Oct 2009 18:03:04 +0100
Message-ID: <4AE727C8.7010700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50943 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756199AbZJ0RDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 13:03:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchs adds an unreg_list anchor to struct net_device, and
introduces an unregister_netdevice_queue() function, able to queue
a net_device to a list instead of immediately unregister it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    9 ++++++++-
 net/core/dev.c            |   20 +++++++++++++-------
 2 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8380009..0ded0a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -683,6 +683,7 @@ struct net_device
 
 	struct list_head	dev_list;
 	struct list_head	napi_list;
+	struct list_head	unreg_list;
 
 	/* Net device features */
 	unsigned long		features;
@@ -1116,7 +1117,13 @@ extern int		dev_close(struct net_device *dev);
 extern void		dev_disable_lro(struct net_device *dev);
 extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
-extern void		unregister_netdevice(struct net_device *dev);
+extern void		unregister_netdevice_queue(struct net_device *dev,
+						   struct list_head *head);
+static inline void unregister_netdevice(struct net_device *dev)
+{
+	unregister_netdevice_queue(dev, NULL);
+}
+
 extern void		free_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 950c13f..ff94e2b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5245,25 +5245,31 @@ void synchronize_net(void)
 EXPORT_SYMBOL(synchronize_net);
 
 /**
- *	unregister_netdevice - remove device from the kernel
+ *	unregister_netdevice_queue - remove device from the kernel
  *	@dev: device
- *
+ *	@head: list
+
  *	This function shuts down a device interface and removes it
  *	from the kernel tables.
+ *	If head not NULL, device is queued to be unregistered later.
  *
  *	Callers must hold the rtnl semaphore.  You may want
  *	unregister_netdev() instead of this.
  */
 
-void unregister_netdevice(struct net_device *dev)
+void unregister_netdevice_queue(struct net_device *dev, struct list_head *head)
 {
 	ASSERT_RTNL();
 
-	rollback_registered(dev);
-	/* Finish processing unregister after unlock */
-	net_set_todo(dev);
+	if (head) {
+		list_add_tail(&dev->unreg_list, head);
+	} else {
+		rollback_registered(dev);
+		/* Finish processing unregister after unlock */
+		net_set_todo(dev);
+	}
 }
-EXPORT_SYMBOL(unregister_netdevice);
+EXPORT_SYMBOL(unregister_netdevice_queue);
 
 /**
  *	unregister_netdev - remove device from the kernel
