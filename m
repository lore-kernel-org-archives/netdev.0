From: Tom Herbert <therbert@google.com>
Subject: [PATCH] net: Allocate RX and TX queues in alloc_netdev_mq
Date: Thu, 28 Oct 2010 10:45:45 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1010281036350.22486@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:63162 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758881Ab0J1Rpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:45:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both TX and RX queue allocations in the netdev structure had been moved
to register_device with the idea that the number of queues could be
changed between device allocation and registration.  It was determined
that changing the num_queues after the call to alloc_netdev_mq was not
a good idea, so that was abandoned.  Also, some drivers call
netif_queue_start without registering device, which causes panic
when dev->_tx queue structure is accessed.  This patch moves queue
allocations back to alloc_netdev_mq to fix these issues.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |   38 ++++++++++++++++++--------------------
 1 files changed, 18 insertions(+), 20 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b2269ac..1f729d6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5009,10 +5009,10 @@ void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 }
 EXPORT_SYMBOL(netif_stacked_transfer_operstate);
 
-static int netif_alloc_rx_queues(struct net_device *dev)
+static int netif_alloc_rx_queues(struct net_device *dev, int count)
 {
 #ifdef CONFIG_RPS
-	unsigned int i, count = dev->num_rx_queues;
+	int i;
 	struct netdev_rx_queue *rx;
 
 	BUG_ON(count < 1);
@@ -5030,13 +5030,15 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 	 */
 	for (i = 0; i < count; i++)
 		rx[i].first = rx;
+
+	dev->num_rx_queues = count;
+	dev->real_num_rx_queues = count;
 #endif
 	return 0;
 }
 
-static int netif_alloc_netdev_queues(struct net_device *dev)
+static int netif_alloc_netdev_queues(struct net_device *dev, int count)
 {
-	unsigned int count = dev->num_tx_queues;
 	struct netdev_queue *tx;
 
 	BUG_ON(count < 1);
@@ -5048,6 +5050,10 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 		return -ENOMEM;
 	}
 	dev->_tx = tx;
+
+	dev->num_tx_queues = count;
+	dev->real_num_tx_queues = count;
+
 	return 0;
 }
 
@@ -5105,14 +5111,6 @@ int register_netdevice(struct net_device *dev)
 
 	dev->iflink = -1;
 
-	ret = netif_alloc_rx_queues(dev);
-	if (ret)
-		goto out;
-
-	ret = netif_alloc_netdev_queues(dev);
-	if (ret)
-		goto out;
-
 	netdev_init_queues(dev);
 
 	/* Init, if this function is available */
@@ -5558,6 +5556,12 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
+	if (netif_alloc_netdev_queues(dev, queue_count))
+		goto free_p;
+	
+	if (netif_alloc_rx_queues(dev, queue_count))
+		goto free_p;
+
 	dev->pcpu_refcnt = alloc_percpu(int);
 	if (!dev->pcpu_refcnt)
 		goto free_p;
@@ -5570,14 +5574,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev_net_set(dev, &init_net);
 
-	dev->num_tx_queues = queue_count;
-	dev->real_num_tx_queues = queue_count;
-
-#ifdef CONFIG_RPS
-	dev->num_rx_queues = queue_count;
-	dev->real_num_rx_queues = queue_count;
-#endif
-
 	dev->gso_max_size = GSO_MAX_SIZE;
 
 	INIT_LIST_HEAD(&dev->ethtool_ntuple_list.list);
@@ -5593,6 +5589,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 free_pcpu:
 	free_percpu(dev->pcpu_refcnt);
 free_p:
+	kfree(dev->_tx);
+	kfree(dev->_rx);
 	kfree(p);
 	return NULL;
 }
-- 
1.7.3.1

