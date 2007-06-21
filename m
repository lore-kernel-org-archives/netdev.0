From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware
	support API
Date: Thu, 21 Jun 2007 14:26:42 -0700
Message-ID: <20070621212642.31066.89375.stgit@localhost.localdomain>
References: <20070621212629.31066.92148.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	kaber@trash.net, hadi@cyberus.ca
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18069 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755798AbXFUV0o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 17:26:44 -0400
In-Reply-To: <20070621212629.31066.92148.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the multiqueue hardware device support API to the core network
stack.  Allow drivers to allocate multiple queues and manage them
at the netdev level if they choose to do so.

Added a new field to sk_buff, namely queue_mapping, for drivers to
know which tx_ring to select based on OS classification of the flow.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 include/linux/etherdevice.h |    3 +-
 include/linux/netdevice.h   |   62 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/skbuff.h      |    4 ++-
 net/core/dev.c              |   20 ++++++++++----
 net/core/skbuff.c           |    3 ++
 net/ethernet/eth.c          |    9 +++---
 6 files changed, 87 insertions(+), 14 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index f48eb89..b3fbb54 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -39,7 +39,8 @@ extern void		eth_header_cache_update(struct hh_cache *hh, struct net_device *dev
 extern int		eth_header_cache(struct neighbour *neigh,
 					 struct hh_cache *hh);
 
-extern struct net_device *alloc_etherdev(int sizeof_priv);
+extern struct net_device *alloc_etherdev_mq(int sizeof_priv, int queue_count);
+#define alloc_etherdev(sizeof_priv) alloc_etherdev_mq(sizeof_priv, 1)
 
 /**
  * is_zero_ether_addr - Determine if give Ethernet address is all zeros.
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e7913ee..6509eb4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -108,6 +108,14 @@ struct wireless_dev;
 #define MAX_HEADER (LL_MAX_HEADER + 48)
 #endif
 
+struct net_device_subqueue
+{
+	/* Give a control state for each queue.  This struct may contain
+	 * per-queue locks in the future.
+	 */
+	unsigned long	state;
+};
+
 /*
  *	Network device statistics. Akin to the 2.0 ether stats but
  *	with byte counters.
@@ -325,6 +333,7 @@ struct net_device
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -543,6 +552,10 @@ struct net_device
 
 	/* rtnetlink link ops */
 	const struct rtnl_link_ops *rtnl_link_ops;
+
+ 	/* The TX queue control structures */
+ 	int				egress_subqueue_count;
+ 	struct net_device_subqueue	egress_subqueue[0];
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -705,6 +718,48 @@ static inline int netif_running(const struct net_device *dev)
 	return test_bit(__LINK_STATE_START, &dev->state);
 }
 
+/*
+ * Routines to manage the subqueues on a device.  We only need start
+ * stop, and a check if it's stopped.  All other device management is
+ * done at the overall netdevice level.
+ * Also test the device if we're multiqueue.
+ */
+static inline void netif_start_subqueue(struct net_device *dev, u16 queue_index)
+{
+	clear_bit(__LINK_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
+}
+
+static inline void netif_stop_subqueue(struct net_device *dev, u16 queue_index)
+{
+#ifdef CONFIG_NETPOLL_TRAP
+	if (netpoll_trap())
+		return;
+#endif
+	set_bit(__LINK_STATE_XOFF, &dev->egress_subqueue[queue_index].state);
+}
+
+static inline int netif_subqueue_stopped(const struct net_device *dev,
+                                         u16 queue_index)
+{
+	return test_bit(__LINK_STATE_XOFF,
+	                &dev->egress_subqueue[queue_index].state);
+}
+
+static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
+{
+#ifdef CONFIG_NETPOLL_TRAP
+	if (netpoll_trap())
+		return;
+#endif
+	if (test_and_clear_bit(__LINK_STATE_XOFF,
+	                       &dev->egress_subqueue[queue_index].state))
+		__netif_schedule(dev);
+}
+
+static inline int netif_is_multiqueue(const struct net_device *dev)
+{
+	return (!!(NETIF_F_MULTI_QUEUE & dev->features));
+}
 
 /* Use this variant when it is known for sure that it
  * is executing from interrupt context.
@@ -995,8 +1050,11 @@ static inline void netif_tx_disable(struct net_device *dev)
 extern void		ether_setup(struct net_device *dev);
 
 /* Support for loadable net-drivers */
-extern struct net_device *alloc_netdev(int sizeof_priv, const char *name,
-				       void (*setup)(struct net_device *));
+extern struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
+					  void (*setup)(struct net_device *),
+					  int queue_count);
+#define alloc_netdev(sizeof_priv, name, setup) \
+	alloc_netdev_mq(sizeof_priv, name, setup, 1)
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
 /* Functions used for multicast support */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e7367c7..01b5e25 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -197,6 +197,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@tstamp: Time we arrived
  *	@dev: Device we arrived on/are leaving by
  *	@iif: ifindex of device we arrived on
+ *	@queue_mapping: Queue mapping for multiqueue devices
  *	@transport_header: Transport layer header
  *	@network_header: Network layer header
  *	@mac_header: Link layer header
@@ -246,7 +247,8 @@ struct sk_buff {
 	ktime_t			tstamp;
 	struct net_device	*dev;
 	int			iif;
-	/* 4 byte hole on 64 bit*/
+	__u16			queue_mapping;
+	/* 2 byte hole on 64 bit*/
 
 	struct  dst_entry	*dst;
 	struct	sec_path	*sp;
diff --git a/net/core/dev.c b/net/core/dev.c
index 2609062..66909aa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1545,6 +1545,8 @@ gso:
 		spin_lock(&dev->queue_lock);
 		q = dev->qdisc;
 		if (q->enqueue) {
+			/* reset queue_mapping to zero */
+			skb->queue_mapping = 0;
 			rc = q->enqueue(skb, q);
 			qdisc_run(dev);
 			spin_unlock(&dev->queue_lock);
@@ -3343,16 +3345,18 @@ static struct net_device_stats *internal_stats(struct net_device *dev)
 }
 
 /**
- *	alloc_netdev - allocate network device
+ *	alloc_netdev_mq - allocate network device
  *	@sizeof_priv:	size of private data to allocate space for
  *	@name:		device name format string
  *	@setup:		callback to initialize device
+ *	@queue_count:	the number of subqueues to allocate
  *
  *	Allocates a struct net_device with private data area for driver use
- *	and performs basic initialization.
+ *	and performs basic initialization.  Also allocates subqueue structs
+ *	for each queue on the device at the end of the netdevice.
  */
-struct net_device *alloc_netdev(int sizeof_priv, const char *name,
-		void (*setup)(struct net_device *))
+struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
+		void (*setup)(struct net_device *), int queue_count)
 {
 	void *p;
 	struct net_device *dev;
@@ -3361,7 +3365,9 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
 	/* ensure 32-byte alignment of both the device and private area */
-	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
+	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
+		     (sizeof(struct net_device_subqueue) * (queue_count - 1))) &
+		     ~NETDEV_ALIGN_CONST;
 	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
@@ -3377,12 +3383,14 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 	if (sizeof_priv)
 		dev->priv = netdev_priv(dev);
 
+  	dev->egress_subqueue_count = queue_count;
+
 	dev->get_stats = internal_stats;
 	setup(dev);
 	strcpy(dev->name, name);
 	return dev;
 }
-EXPORT_SYMBOL(alloc_netdev);
+EXPORT_SYMBOL(alloc_netdev_mq);
 
 /**
  *	free_netdev - free network device
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7c6a34e..7bbed45 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -418,6 +418,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	n->nohdr = 0;
 	C(pkt_type);
 	C(ip_summed);
+	C(queue_mapping);
 	C(priority);
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	C(ipvs_property);
@@ -459,6 +460,7 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #endif
 	new->sk		= NULL;
 	new->dev	= old->dev;
+	new->queue_mapping = old->queue_mapping;
 	new->priority	= old->priority;
 	new->protocol	= old->protocol;
 	new->dst	= dst_clone(old->dst);
@@ -1925,6 +1927,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 		tail = nskb;
 
 		nskb->dev = skb->dev;
+		nskb->queue_mapping = skb->queue_mapping;
 		nskb->priority = skb->priority;
 		nskb->protocol = skb->protocol;
 		nskb->dst = dst_clone(skb->dst);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 0ac2524..87a509c 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -316,9 +316,10 @@ void ether_setup(struct net_device *dev)
 EXPORT_SYMBOL(ether_setup);
 
 /**
- * alloc_etherdev - Allocates and sets up an Ethernet device
+ * alloc_etherdev_mq - Allocates and sets up an Ethernet device
  * @sizeof_priv: Size of additional driver-private structure to be allocated
  *	for this Ethernet device
+ * @queue_count: The number of queues this device has.
  *
  * Fill in the fields of the device structure with Ethernet-generic
  * values. Basically does everything except registering the device.
@@ -328,8 +329,8 @@ EXPORT_SYMBOL(ether_setup);
  * this private data area.
  */
 
-struct net_device *alloc_etherdev(int sizeof_priv)
+struct net_device *alloc_etherdev_mq(int sizeof_priv, int queue_count)
 {
-	return alloc_netdev(sizeof_priv, "eth%d", ether_setup);
+	return alloc_netdev_mq(sizeof_priv, "eth%d", ether_setup, queue_count);
 }
-EXPORT_SYMBOL(alloc_etherdev);
+EXPORT_SYMBOL(alloc_etherdev_mq);
