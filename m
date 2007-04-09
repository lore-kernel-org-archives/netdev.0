From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 2/2] NET: Multiqueue network device support implementation.
Date: Mon, 09 Apr 2007 14:28:41 -0700
Message-ID: <20070409212841.31670.59366.stgit@gitlost.site>
References: <20070409212723.31670.27976.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj@intel.com, auke-jan.h.kok@intel.com,
	christopher.leech@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1767 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965864AbXDIVMm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2007 17:12:42 -0400
In-Reply-To: <20070409212723.31670.27976.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Added an API and associated supporting routines for multiqueue network devices.
This allows network devices supporting multiple TX queues to configure each
queue within the netdevice and manage each queue independantly.  Changes to the
PRIO Qdisc also allow a user to map multiple flows to individual TX queues,
taking advantage of each queue on the device.

Removed typecast when assigning net_device_subqueue in alloc_etherdev_mq.

Signed-off-by: Peter P. Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 include/linux/etherdevice.h |    3 +-
 include/linux/netdevice.h   |   66 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/skbuff.h      |    2 +
 net/core/dev.c              |   25 +++++++++++++---
 net/core/skbuff.c           |    3 ++
 net/ethernet/eth.c          |    9 +++---
 net/sched/sch_generic.c     |    4 +--
 net/sched/sch_prio.c        |   55 +++++++++++++++++++++++++++++++-----
 8 files changed, 146 insertions(+), 21 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 745c988..446de39 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -39,7 +39,8 @@ extern void		eth_header_cache_update(struct hh_cache *hh, struct net_device *dev
 extern int		eth_header_cache(struct neighbour *neigh,
 					 struct hh_cache *hh);
 
-extern struct net_device *alloc_etherdev(int sizeof_priv);
+extern struct net_device *alloc_etherdev_mq(int sizeof_priv, int queue_count);
+#define alloc_etherdev(sizeof_priv) alloc_etherdev_mq(sizeof_priv, 1)
 static inline void eth_copy_and_sum (struct sk_buff *dest, 
 				     const unsigned char *src, 
 				     int len, int base)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 71fc8ff..db06169 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -106,6 +106,14 @@ struct netpoll_info;
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
@@ -324,6 +332,7 @@ struct net_device
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
 #define NETIF_F_INTERNAL_STATS	8192	/* Use stats structure in net_device */
+#define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -534,6 +543,14 @@ struct net_device
 	struct device		dev;
 	/* space for optional statistics and wireless sysfs groups */
 	struct attribute_group  *sysfs_groups[3];
+
+	/* To retrieve statistics per subqueue - FOR FUTURE USE */
+	struct net_device_stats* (*get_subqueue_stats)(struct net_device *dev,
+							int queue_index);
+
+	/* The TX queue control structures */
+	struct net_device_subqueue	*egress_subqueue;
+	int				egress_subqueue_count;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -675,6 +692,48 @@ static inline int netif_running(const struct net_device *dev)
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
@@ -968,8 +1027,11 @@ static inline void netif_tx_disable(struct net_device *dev)
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
index 08fa5c8..96fd263 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -212,6 +212,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@pkt_type: Packet class
  *	@fclone: skbuff clone status
  *	@ip_summed: Driver fed us an IP checksum
+ *	@queue_mapping: Queue mapping for multiqueue devices
  *	@priority: Packet queueing priority
  *	@users: User count - see {datagram,tcp}.c
  *	@protocol: Packet protocol from driver
@@ -264,6 +265,7 @@ struct sk_buff {
 		__wsum		csum;
 		__u32		csum_offset;
 	};
+	__u16			queue_mapping;
 	__u32			priority;
 	__u8			local_df:1,
 				cloned:1,
diff --git a/net/core/dev.c b/net/core/dev.c
index 219a57f..86c9a89 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3292,16 +3292,18 @@ static struct net_device_stats *maybe_internal_stats(struct net_device *dev)
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
+ *	for each queue on the device.
  */
-struct net_device *alloc_netdev(int sizeof_priv, const char *name,
-		void (*setup)(struct net_device *))
+struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
+		void (*setup)(struct net_device *), int queue_count)
 {
 	void *p;
 	struct net_device *dev;
@@ -3326,12 +3328,23 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 	if (sizeof_priv)
 		dev->priv = netdev_priv(dev);
 
+ 	alloc_size = (sizeof(struct net_device_subqueue) * queue_count);
+ 
+ 	p = kzalloc(alloc_size, GFP_KERNEL);
+ 	if (!p) {
+ 		printk(KERN_ERR "alloc_netdev: Unable to allocate queues.\n");
+ 		return NULL;
+ 	}
+ 
+ 	dev->egress_subqueue = p;
+ 	dev->egress_subqueue_count = queue_count;
+
 	dev->get_stats = maybe_internal_stats;
 	setup(dev);
 	strcpy(dev->name, name);
 	return dev;
 }
-EXPORT_SYMBOL(alloc_netdev);
+EXPORT_SYMBOL(alloc_netdev_mq);
 
 /**
  *	free_netdev - free network device
@@ -3345,6 +3358,7 @@ void free_netdev(struct net_device *dev)
 {
 #ifdef CONFIG_SYSFS
 	/*  Compatibility with error handling in drivers */
+	kfree((char *)dev->egress_subqueue);
 	if (dev->reg_state == NETREG_UNINITIALIZED) {
 		kfree((char *)dev - dev->padded);
 		return;
@@ -3356,6 +3370,7 @@ void free_netdev(struct net_device *dev)
 	/* will free via device release */
 	put_device(&dev->dev);
 #else
+	kfree((char *)dev->egress_subqueue);
 	kfree((char *)dev - dev->padded);
 #endif
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e60864e..642aab9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -474,6 +474,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	n->nohdr = 0;
 	C(pkt_type);
 	C(ip_summed);
+	C(queue_mapping);
 	C(priority);
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	C(ipvs_property);
@@ -516,6 +517,7 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #endif
 	new->sk		= NULL;
 	new->dev	= old->dev;
+	new->queue_mapping = old->queue_mapping;
 	new->priority	= old->priority;
 	new->protocol	= old->protocol;
 	new->dst	= dst_clone(old->dst);
@@ -1974,6 +1976,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
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
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 52eb343..8f0063a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -133,7 +133,8 @@ static inline int qdisc_restart(struct net_device *dev)
 			/* And release queue */
 			spin_unlock(&dev->queue_lock);
 
-			if (!netif_queue_stopped(dev)) {
+			if (!netif_queue_stopped(dev) &&
+			    !netif_subqueue_stopped(dev, skb->queue_mapping)) {
 				int ret;
 
 				ret = dev_hard_start_xmit(skb, dev);
@@ -149,7 +150,6 @@ static inline int qdisc_restart(struct net_device *dev)
 					goto collision;
 				}
 			}
-
 			/* NETDEV_TX_BUSY - we need to requeue */
 			/* Release the driver */
 			if (!nolock) {
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 5cfe60b..7365621 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -43,6 +43,7 @@ struct prio_sched_data
 	struct tcf_proto *filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
+	u16 band2queue[TC_PRIO_MAX + 1];
 };
 
 
@@ -63,20 +64,26 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		case TC_ACT_SHOT:
 			return NULL;
 		};
-
 		if (!q->filter_list ) {
 #else
 		if (!q->filter_list || tc_classify(skb, q->filter_list, &res)) {
 #endif
 			if (TC_H_MAJ(band))
 				band = 0;
+			skb->queue_mapping =
+				  q->prio2band[q->band2queue[band&TC_PRIO_MAX]];
+
 			return q->queues[q->prio2band[band&TC_PRIO_MAX]];
 		}
 		band = res.classid;
 	}
 	band = TC_H_MIN(band) - 1;
-	if (band > q->bands)
+	if (band > q->bands) {
+		skb->queue_mapping = q->prio2band[q->band2queue[0]];
 		return q->queues[q->prio2band[0]];
+	}
+
+	skb->queue_mapping = q->band2queue[band];
 
 	return q->queues[band];
 }
@@ -144,11 +151,17 @@ prio_dequeue(struct Qdisc* sch)
 	struct Qdisc *qdisc;
 
 	for (prio = 0; prio < q->bands; prio++) {
-		qdisc = q->queues[prio];
-		skb = qdisc->dequeue(qdisc);
-		if (skb) {
-			sch->q.qlen--;
-			return skb;
+		/* Check if the target subqueue is available before
+		 * pulling an skb.  This way we avoid excessive requeues
+		 * for slower queues.
+		 */
+		if (!netif_subqueue_stopped(sch->dev, q->band2queue[prio])) {
+			qdisc = q->queues[prio];
+			skb = qdisc->dequeue(qdisc);
+			if (skb) {
+				sch->q.qlen--;
+				return skb;
+			}
 		}
 	}
 	return NULL;
@@ -200,6 +213,10 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tc_prio_qopt *qopt = RTA_DATA(opt);
 	int i;
+	int queue;
+	int qmapoffset;
+	int offset;
+	int mod;
 
 	if (opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
 		return -EINVAL;
@@ -242,6 +259,30 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 			}
 		}
 	}
+	/* setup queue to band mapping */
+	if (q->bands < sch->dev->egress_subqueue_count) {
+		qmapoffset = 1;
+		mod = 0;
+	} else {
+		mod = q->bands % sch->dev->egress_subqueue_count;
+		qmapoffset = q->bands / sch->dev->egress_subqueue_count +
+				((mod) ? 1 : 0);
+	}
+
+	queue = 0;
+	offset = 0;
+	for (i = 0; i < q->bands; i++) {
+		q->band2queue[i] = queue;
+		if ( ((i + 1) - offset) == qmapoffset) {
+			queue++;
+			offset += qmapoffset;
+			if (mod)
+				mod--;
+			qmapoffset = q->bands /
+				sch->dev->egress_subqueue_count +
+				((mod) ? 1 : 0);
+		}
+	}
 	return 0;
 }
 

