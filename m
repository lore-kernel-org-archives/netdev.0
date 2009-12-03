From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v2] net: Introduce realloc_netdev_mq()
Date: Thu, 3 Dec 2009 14:39:18 +0000
Message-ID: <20091203143918.GA20526@ff.dom.local>
References: <20091101132017.GA2598@ami.dom.local> <20091102.033533.08766686.davem@davemloft.net> <20091102123029.GA7790@ff.dom.local> <20091102.043907.236634594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, kaber@trash.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:46294 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755959AbZLCOjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 09:39:15 -0500
Received: by bwz27 with SMTP id 27so1135197bwz.21
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 06:39:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091102.043907.236634594.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take 2 (with forgotten headers, sorry).

On Mon, Nov 02, 2009 at 04:39:07AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 2 Nov 2009 12:30:29 +0000
> 
> > Right, but it's not a 50% chance, I guess? A user most of the time
> > gets consistently multiqueue or non-multiqueue behavior after open,
> > unless I miss something. Then such an exceptional state could be
> > handled by real_num_tx_queues (just like in case of powered of cpus).
> > The main difference is to hold in num_tx_queues something that is
> > really available vs max possible value for all configs.
> 
> I see your point, yes this would seem to be a reasonable way
> to start handling num_tx_queues and real_num_tx_queues.

Here is a proposal of netdev api change. I hope Michael finds time
to try if this can be really useful for drivers.

Thanks,
Jarek P.
---------------> (take 2)

This patch separates allocation of TX subqueues from alloc_netdev_mq()
to realloc_netdev_mq() to allow for resizing like in this example:

some_nic_probe()
{
	...
	dev = alloc_etherdev_mq(sizeof(*bp), 1)
	...
	if (MSI-X_available && device_supports_MSI-X_and_multiqueue)
		realloc_netdev_mq(dev, TX_MAX_RINGS)
	register_netdev(dev)
	...
}

The main difference is to hold in num_tx_queues something that is
really available, instead of max possible value for all configs, in
case of drivers allocating net_device at the beginning of the probe.

The description of alloc_netdev_mq() is fixed btw.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   65 +++++++++++++++++++++++++++++++-------------
 2 files changed, 47 insertions(+), 19 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index daf13d3..4b6e2ef 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1904,6 +1904,7 @@ extern void		ether_setup(struct net_device *dev);
 extern struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 				       void (*setup)(struct net_device *),
 				       unsigned int queue_count);
+extern int realloc_netdev_mq(struct net_device *dev, unsigned int queue_count);
 #define alloc_netdev(sizeof_priv, name, setup) \
 	alloc_netdev_mq(sizeof_priv, name, setup, 1)
 extern int		register_netdev(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index e3e18de..7ea3a77 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5265,11 +5265,49 @@ static void netdev_init_one_queue(struct net_device *dev,
 	queue->dev = dev;
 }
 
-static void netdev_init_queues(struct net_device *dev)
+/**
+ *	realloc_netdev_mq - (re)allocate network subqueues
+ *	@dev:		device
+ *	@queue_count:	the number of subqueues to (re)allocate
+ *
+ *	(Re)allocates and initializes subqueue structs for each queue.
+ *	It is allowed to use only until register_netdev().
+ *	On error previous structs are intact.
+ */
+int realloc_netdev_mq(struct net_device *dev, unsigned int queue_count)
 {
-	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
+	struct netdev_queue *tx;
+
+	tx = kcalloc(queue_count, sizeof(struct netdev_queue), GFP_KERNEL);
+	if (!tx) {
+		printk(KERN_ERR "alloc_netdev: Unable to allocate "
+		       "tx qdiscs.\n");
+		return -ENOMEM;
+	}
+
+	kfree(dev->_tx);
+
+	dev->_tx = tx;
+	dev->num_tx_queues = queue_count;
+	dev->real_num_tx_queues = queue_count;
+
 	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
+
+	return 0;
+}
+EXPORT_SYMBOL(realloc_netdev_mq);
+
+static int netdev_init_queues(struct net_device *dev, unsigned int queue_count)
+{
+	int err = realloc_netdev_mq(dev, queue_count);
+
+	if (err)
+		return err;
+
+	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
 	spin_lock_init(&dev->tx_global_lock);
+
+	return 0;
 }
 
 /**
@@ -5280,13 +5318,12 @@ static void netdev_init_queues(struct net_device *dev)
  *	@queue_count:	the number of subqueues to allocate
  *
  *	Allocates a struct net_device with private data area for driver use
- *	and performs basic initialization.  Also allocates subquue structs
- *	for each queue on the device at the end of the netdevice.
+ *	and performs basic initialization.  Also allocates subqueue structs
+ *	for each queue on the device.
  */
 struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		void (*setup)(struct net_device *), unsigned int queue_count)
 {
-	struct netdev_queue *tx;
 	struct net_device *dev;
 	size_t alloc_size;
 	struct net_device *p;
@@ -5308,16 +5345,12 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		return NULL;
 	}
 
-	tx = kcalloc(queue_count, sizeof(struct netdev_queue), GFP_KERNEL);
-	if (!tx) {
-		printk(KERN_ERR "alloc_netdev: Unable to allocate "
-		       "tx qdiscs.\n");
-		goto free_p;
-	}
-
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
+	if (netdev_init_queues(dev, queue_count))
+		goto free_p;
+
 	if (dev_addr_init(dev))
 		goto free_tx;
 
@@ -5325,14 +5358,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev_net_set(dev, &init_net);
 
-	dev->_tx = tx;
-	dev->num_tx_queues = queue_count;
-	dev->real_num_tx_queues = queue_count;
-
 	dev->gso_max_size = GSO_MAX_SIZE;
 
-	netdev_init_queues(dev);
-
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
@@ -5342,7 +5369,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	return dev;
 
 free_tx:
-	kfree(tx);
+	kfree(dev->_tx);
 
 free_p:
 	kfree(p);
