From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rps: allocate rx queues in register_netdevice
 only
Date: Fri, 24 Sep 2010 05:26:35 +0200
Message-ID: <1285298795.2380.54.camel@edumazet-laptop>
References: <1285273118.7794.23.camel@achroite.uk.solarflarecom.com>
	 <1285273194.7794.24.camel@achroite.uk.solarflarecom.com>
	 <1285296505.2380.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, Tom Herbert <therbert@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52324 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491Ab0IXD0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 23:26:41 -0400
Received: by fxm3 with SMTP id 3so518211fxm.19
        for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 20:26:40 -0700 (PDT)
In-Reply-To: <1285296505.2380.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Also, I dont understand why we need to restrict
> netif_set_real_num_rx_queues() to lower the count.
> This wastes memory.
> 
> Why dont we allocate dev->_rx once we know the real count, not in
> alloc_netdev_mq() but in register_netdevice() ?
> 
> 

Here is a patch to make this possible

I guess a similar thing could be done for tx queues.

boot tested, but please double check.

Thanks

[PATCH net-next-2.6] rps: allocate rx queues in register_netdevice()

Instead of having two places were we allocate dev->_rx, introduce
netif_alloc_rx_queues() helper and call it only from
register_netdevice(), not from alloc_netdev_mq()

Goal is to let drivers change dev->num_rx_queues after allocating netdev
and before registering it.

This also removes a lot of ifdefs in net/core/dev.c

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   76 +++++++++++++++++++----------------------------
 1 file changed, 32 insertions(+), 44 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2c7934f..9110b8d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4964,6 +4964,34 @@ void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 }
 EXPORT_SYMBOL(netif_stacked_transfer_operstate);
 
+static int netif_alloc_rx_queues(struct net_device *dev)
+{
+#ifdef CONFIG_RPS
+	unsigned int i, count = dev->num_rx_queues;
+
+	if (count) {
+		struct netdev_rx_queue *rx;
+
+		rx = kcalloc(count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
+		if (!rx) {
+			pr_err("netdev: Unable to allocate %u rx queues.\n",
+			       count);
+			return -ENOMEM;
+		}
+		dev->_rx = rx;
+		atomic_set(&rx->count, count);
+
+		/*
+		 * Set a pointer to first element in the array which holds the
+		 * reference count.
+		 */
+		for (i = 0; i < count; i++)
+			rx[i].first = rx;
+	}
+#endif
+	return 0;
+}
+
 /**
  *	register_netdevice	- register a network device
  *	@dev: device to register
@@ -5001,24 +5029,10 @@ int register_netdevice(struct net_device *dev)
 
 	dev->iflink = -1;
 
-#ifdef CONFIG_RPS
-	if (!dev->num_rx_queues) {
-		/*
-		 * Allocate a single RX queue if driver never called
-		 * alloc_netdev_mq
-		 */
-
-		dev->_rx = kzalloc(sizeof(struct netdev_rx_queue), GFP_KERNEL);
-		if (!dev->_rx) {
-			ret = -ENOMEM;
-			goto out;
-		}
+	ret = netif_alloc_rx_queues(dev);
+	if (ret)
+		goto out;
 
-		dev->_rx->first = dev->_rx;
-		atomic_set(&dev->_rx->count, 1);
-		dev->num_rx_queues = 1;
-	}
-#endif
 	/* Init, if this function is available */
 	if (dev->netdev_ops->ndo_init) {
 		ret = dev->netdev_ops->ndo_init(dev);
@@ -5414,10 +5428,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	struct net_device *dev;
 	size_t alloc_size;
 	struct net_device *p;
-#ifdef CONFIG_RPS
-	struct netdev_rx_queue *rx;
-	int i;
-#endif
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
@@ -5443,29 +5453,12 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		goto free_p;
 	}
 
-#ifdef CONFIG_RPS
-	rx = kcalloc(queue_count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
-	if (!rx) {
-		printk(KERN_ERR "alloc_netdev: Unable to allocate "
-		       "rx queues.\n");
-		goto free_tx;
-	}
-
-	atomic_set(&rx->count, queue_count);
-
-	/*
-	 * Set a pointer to first element in the array which holds the
-	 * reference count.
-	 */
-	for (i = 0; i < queue_count; i++)
-		rx[i].first = rx;
-#endif
 
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
 	if (dev_addr_init(dev))
-		goto free_rx;
+		goto free_tx;
 
 	dev_mc_init(dev);
 	dev_uc_init(dev);
@@ -5477,7 +5470,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev->real_num_tx_queues = queue_count;
 
 #ifdef CONFIG_RPS
-	dev->_rx = rx;
 	dev->num_rx_queues = queue_count;
 #endif
 
@@ -5495,11 +5487,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	strcpy(dev->name, name);
 	return dev;
 
-free_rx:
-#ifdef CONFIG_RPS
-	kfree(rx);
 free_tx:
-#endif
 	kfree(tx);
 free_p:
 	kfree(p);


