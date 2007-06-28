From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware
	support API
Date: Thu, 28 Jun 2007 09:21:13 -0700
Message-ID: <20070628162113.18728.20109.stgit@localhost.localdomain>
References: <20070628162056.18728.20195.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	hadi@cyberus.ca, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2611 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755743AbXF1QVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 12:21:42 -0400
In-Reply-To: <20070628162056.18728.20195.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updated: Fixed allocation of subqueues in alloc_netdev_mq() to
allocate all subqueues, not num - 1.

Added checks for netif_subqueue_stopped() to netpoll,
pktgen, and software device dev_queue_xmit().  This will ensure
external events to these subsystems will be handled correctly if
a subqueue is shut down.

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
 net/core/dev.c              |   27 +++++++++++++------
 net/core/netpoll.c          |    8 +++---
 net/core/pktgen.c           |   10 +++++--
 net/core/skbuff.c           |    3 ++
 net/ethernet/eth.c          |    9 +++---
 8 files changed, 104 insertions(+), 22 deletions(-)

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
index 2c0cc19..7078745 100644
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
+	unsigned long   state;
+};
+
 /*
  *	Network device statistics. Akin to the 2.0 ether stats but
  *	with byte counters.
@@ -331,6 +339,7 @@ struct net_device
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -557,6 +566,10 @@ struct net_device
 
 	/* rtnetlink link ops */
 	const struct rtnl_link_ops *rtnl_link_ops;
+
+	/* The TX queue control structures */
+	int				egress_subqueue_count;
+	struct net_device_subqueue	egress_subqueue[0];
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -719,6 +732,48 @@ static inline int netif_running(const struct net_device *dev)
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
+					 u16 queue_index)
+{
+	return test_bit(__LINK_STATE_XOFF,
+			&dev->egress_subqueue[queue_index].state);
+}
+
+static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
+{
+#ifdef CONFIG_NETPOLL_TRAP
+	if (netpoll_trap())
+		return;
+#endif
+	if (test_and_clear_bit(__LINK_STATE_XOFF,
+			       &dev->egress_subqueue[queue_index].state))
+		__netif_schedule(dev);
+}
+
+static inline int netif_is_multiqueue(const struct net_device *dev)
+{
+	return (!!(NETIF_F_MULTI_QUEUE & dev->features));
+}
 
 /* Use this variant when it is known for sure that it
  * is executing from interrupt context.
@@ -1009,8 +1064,11 @@ static inline void netif_tx_disable(struct net_device *dev)
 extern void		ether_setup(struct net_device *dev);
 
 /* Support for loadable net-drivers */
-extern struct net_device *alloc_netdev(int sizeof_priv, const char *name,
-				       void (*setup)(struct net_device *));
+extern struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
+				       void (*setup)(struct net_device *),
+				       int queue_count);
+#define alloc_netdev(sizeof_priv, name, setup) \
+	alloc_netdev_mq(sizeof_priv, name, setup, 1)
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
 /* Functions used for secondary unicast and multicast support */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b7b2628..6979f4b 100644
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
@@ -247,7 +248,8 @@ struct sk_buff {
 	ktime_t			tstamp;
 	struct net_device	*dev;
 	int			iif;
-	/* 4 byte hole on 64 bit*/
+	__u16			queue_mapping;
+	/* 2 byte hole on 64 bit*/
 
 	struct  dst_entry	*dst;
 	struct	sec_path	*sp;
diff --git a/net/core/dev.c b/net/core/dev.c
index 778e102..d244771 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1429,7 +1429,9 @@ gso:
 			skb->next = nskb;
 			return rc;
 		}
-		if (unlikely(netif_queue_stopped(dev) && skb->next))
+		if (unlikely((netif_queue_stopped(dev) ||
+			     netif_subqueue_stopped(dev, skb->queue_mapping)) &&
+			     skb->next))
 			return NETDEV_TX_BUSY;
 	} while (skb->next);
 
@@ -1547,6 +1549,8 @@ gso:
 		spin_lock(&dev->queue_lock);
 		q = dev->qdisc;
 		if (q->enqueue) {
+			/* reset queue_mapping to zero */
+			skb->queue_mapping = 0;
 			rc = q->enqueue(skb, q);
 			qdisc_run(dev);
 			spin_unlock(&dev->queue_lock);
@@ -1576,7 +1580,8 @@ gso:
 
 			HARD_TX_LOCK(dev, cpu);
 
-			if (!netif_queue_stopped(dev)) {
+			if (!netif_queue_stopped(dev) &&
+			    !netif_subqueue_stopped(dev, skb->queue_mapping)) {
 				rc = 0;
 				if (!dev_hard_start_xmit(skb, dev)) {
 					HARD_TX_UNLOCK(dev);
@@ -3539,16 +3544,18 @@ static struct net_device_stats *internal_stats(struct net_device *dev)
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
+ *	and performs basic initialization.  Also allocates subquue structs
+ *	for each queue on the device at the end of the netdevice.
  */
-struct net_device *alloc_netdev(int sizeof_priv, const char *name,
-		void (*setup)(struct net_device *))
+struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
+		void (*setup)(struct net_device *), int queue_count)
 {
 	void *p;
 	struct net_device *dev;
@@ -3557,7 +3564,9 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
 	/* ensure 32-byte alignment of both the device and private area */
-	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
+	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
+		     (sizeof(struct net_device_subqueue) * queue_count)) &
+		     ~NETDEV_ALIGN_CONST;
 	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
@@ -3573,12 +3582,14 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 	if (sizeof_priv)
 		dev->priv = netdev_priv(dev);
 
+	dev->egress_subqueue_count = queue_count;
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
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 758dafe..2ace33d 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -66,8 +66,9 @@ static void queue_process(struct work_struct *work)
 
 		local_irq_save(flags);
 		netif_tx_lock(dev);
-		if (netif_queue_stopped(dev) ||
-		    dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
+		if ((netif_queue_stopped(dev) ||
+		     netif_subqueue_stopped(dev, skb->queue_mapping)) ||
+		     dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
 			netif_tx_unlock(dev);
 			local_irq_restore(flags);
@@ -254,7 +255,8 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 			/* try until next clock tick */
 			for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
 					tries > 0; --tries) {
-				if (!netif_queue_stopped(dev))
+				if (!netif_queue_stopped(dev) &&
+				    !netif_subqueue_stopped(dev, skb->queue_mapping))
 					status = dev->hard_start_xmit(skb, dev);
 
 				if (status == NETDEV_TX_OK)
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 9cd3a1c..dffe067 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3139,7 +3139,9 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		}
 	}
 
-	if (netif_queue_stopped(odev) || need_resched()) {
+	if ((netif_queue_stopped(odev) ||
+	     netif_subqueue_stopped(odev, pkt_dev->skb->queue_mapping)) ||
+	     need_resched()) {
 		idle_start = getCurUs();
 
 		if (!netif_running(odev)) {
@@ -3154,7 +3156,8 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 		pkt_dev->idle_acc += getCurUs() - idle_start;
 
-		if (netif_queue_stopped(odev)) {
+		if (netif_queue_stopped(odev) ||
+		    netif_subqueue_stopped(odev, pkt_dev->skb->queue_mapping)) {
 			pkt_dev->next_tx_us = getCurUs();	/* TODO */
 			pkt_dev->next_tx_ns = 0;
 			goto out;	/* Try the next interface */
@@ -3181,7 +3184,8 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	}
 
 	netif_tx_lock_bh(odev);
-	if (!netif_queue_stopped(odev)) {
+	if (!netif_queue_stopped(odev) &&
+	    !netif_subqueue_stopped(odev, pkt_dev->skb->queue_mapping)) {
 
 		atomic_inc(&(pkt_dev->skb->users));
 	      retry_now:
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8d8e8fc..e9eea50 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -419,6 +419,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	n->nohdr = 0;
 	C(pkt_type);
 	C(ip_summed);
+	C(queue_mapping);
 	C(priority);
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	C(ipvs_property);
@@ -460,6 +461,7 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #endif
 	new->sk		= NULL;
 	new->dev	= old->dev;
+	new->queue_mapping = old->queue_mapping;
 	new->priority	= old->priority;
 	new->protocol	= old->protocol;
 	new->dst	= dst_clone(old->dst);
@@ -1927,6 +1929,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
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
