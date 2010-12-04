From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: init ingress queue
Date: Sat,  4 Dec 2010 20:31:41 +0800
Message-ID: <1291465901-3189-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:46720 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754616Ab0LDMcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 07:32:19 -0500
Received: by iwn6 with SMTP id 6so1056328iwn.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 04:32:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dev field of ingress queue is forgot to initialized, then NULL
pointer dereference happens in qdisc_alloc().

Move inits of tx queues to netif_alloc_netdev_queues().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v2: factorize the two inits in netdev_init_queues() and move inits of
    tx queues to netif_alloc_netdev_queues().
 net/core/dev.c |   35 +++++++++++++----------------------
 1 file changed, 13 insertions(+), 22 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index cd24374..4a7fc32 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5109,11 +5109,21 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 }
 #endif
 
+static void netdev_init_one_queue(struct net_device *dev,
+				  struct netdev_queue *queue, void *_unused)
+{
+	/* Initialize queue lock */
+	spin_lock_init(&queue->_xmit_lock);
+	netdev_set_xmit_lockdep_class(&queue->_xmit_lock, dev->type);
+	queue->xmit_lock_owner = -1;
+	netdev_queue_numa_node_write(queue, -1);
+	queue->dev = dev;
+}
+
 static int netif_alloc_netdev_queues(struct net_device *dev)
 {
 	unsigned int count = dev->num_tx_queues;
 	struct netdev_queue *tx;
-	int i;
 
 	BUG_ON(count < 1);
 
@@ -5125,27 +5135,10 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 	}
 	dev->_tx = tx;
 
-	for (i = 0; i < count; i++) {
-		netdev_queue_numa_node_write(&tx[i], -1);
-		tx[i].dev = dev;
-	}
-	return 0;
-}
-
-static void netdev_init_one_queue(struct net_device *dev,
-				  struct netdev_queue *queue,
-				  void *_unused)
-{
-	/* Initialize queue lock */
-	spin_lock_init(&queue->_xmit_lock);
-	netdev_set_xmit_lockdep_class(&queue->_xmit_lock, dev->type);
-	queue->xmit_lock_owner = -1;
-}
-
-static void netdev_init_queues(struct net_device *dev)
-{
 	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
 	spin_lock_init(&dev->tx_global_lock);
+
+	return 0;
 }
 
 /**
@@ -5184,8 +5177,6 @@ int register_netdevice(struct net_device *dev)
 
 	dev->iflink = -1;
 
-	netdev_init_queues(dev);
-
 	/* Init, if this function is available */
 	if (dev->netdev_ops->ndo_init) {
 		ret = dev->netdev_ops->ndo_init(dev);
