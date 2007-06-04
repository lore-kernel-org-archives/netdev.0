From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] NET: Multiqueue network device support.
Date: Mon, 04 Jun 2007 14:40:45 -0700
Message-ID: <20070604214045.1524.18254.stgit@localhost.localdomain>
References: <20070604214037.1524.58506.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23177 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752701AbXFDVkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 17:40:47 -0400
In-Reply-To: <20070604214037.1524.58506.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

API added to support multiple hardware queues on an ethernet device.
    Round-robin scheduler added (sch_rr) to provide a no-scheduling policy
    qdisc for hardware with multiple queues.

    Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 include/linux/etherdevice.h |    3 
 include/linux/netdevice.h   |   62 +++++
 include/linux/pkt_sched.h   |   11 +
 include/linux/skbuff.h      |    2 
 net/core/dev.c              |   27 ++
 net/core/skbuff.c           |    3 
 net/ethernet/eth.c          |    9 -
 net/sched/Kconfig           |   22 ++
 net/sched/Makefile          |    1 
 net/sched/sch_generic.c     |    4 
 net/sched/sch_prio.c        |   66 +++++-
 net/sched/sch_rr.c          |  516 +++++++++++++++++++++++++++++++++++++++++++
 12 files changed, 706 insertions(+), 20 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 071c67a..283e687 100644
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
index f671cd2..376a0d2 100644
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
@@ -540,6 +549,10 @@ struct net_device
 	struct device		dev;
 	/* space for optional statistics and wireless sysfs groups */
 	struct attribute_group  *sysfs_groups[3];
+
+	/* The TX queue control structures */
+	struct net_device_subqueue	*egress_subqueue;
+	int				egress_subqueue_count;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -702,6 +715,48 @@ static inline int netif_running(const struct net_device *dev)
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
diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d10f353..0d1adaf 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -22,6 +22,7 @@
 #define TC_PRIO_CONTROL			7
 
 #define TC_PRIO_MAX			15
+#define TC_RR_MAX			15
 
 /* Generic queue statistics, available for all the elements.
    Particular schedulers may have also their private records.
@@ -90,6 +91,16 @@ struct tc_fifo_qopt
 	__u32	limit;	/* Queue length: bytes for bfifo, packets for pfifo */
 };
 
+/* RR section */
+#define TCQ_RR_BANDS	16
+#define TCQ_MIN_RR_BANDS 2
+
+struct tc_rr_qopt
+{
+	int	bands;			/* Number of bands */
+	__u8	priomap[TC_RR_MAX+1];	/* Map: Linux priority -> RR band */
+};
+
 /* PRIO section */
 
 #define TCQ_PRIO_BANDS	16
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e7367c7..8bcd870 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -215,6 +215,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@pkt_type: Packet class
  *	@fclone: skbuff clone status
  *	@ip_summed: Driver fed us an IP checksum
+ *	@queue_mapping: Queue mapping for multiqueue devices
  *	@priority: Packet queueing priority
  *	@users: User count - see {datagram,tcp}.c
  *	@protocol: Packet protocol from driver
@@ -269,6 +270,7 @@ struct sk_buff {
 			__u16	csum_offset;
 		};
 	};
+	__u16			queue_mapping;
 	__u32			priority;
 	__u8			local_df:1,
 				cloned:1,
diff --git a/net/core/dev.c b/net/core/dev.c
index 4317c1b..27c90e1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1477,6 +1477,8 @@ gso:
 		spin_lock(&dev->queue_lock);
 		q = dev->qdisc;
 		if (q->enqueue) {
+			/* reset queue_mapping to zero */
+			skb->queue_mapping = 0;
 			rc = q->enqueue(skb, q);
 			qdisc_run(dev);
 			spin_unlock(&dev->queue_lock);
@@ -3273,16 +3275,18 @@ static struct net_device_stats *internal_stats(struct net_device *dev)
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
@@ -3307,12 +3311,23 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 	if (sizeof_priv)
 		dev->priv = netdev_priv(dev);
 
+  	alloc_size = (sizeof(struct net_device_subqueue) * queue_count);
+  
+  	p = kzalloc(alloc_size, GFP_KERNEL);
+  	if (!p) {
+  		printk(KERN_ERR "alloc_netdev: Unable to allocate queues.\n");
+  		return NULL;
+  	}
+  
+  	dev->egress_subqueue = p;
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
@@ -3326,6 +3341,7 @@ void free_netdev(struct net_device *dev)
 {
 #ifdef CONFIG_SYSFS
 	/*  Compatibility with error handling in drivers */
+	kfree((char *)dev->egress_subqueue);
 	if (dev->reg_state == NETREG_UNINITIALIZED) {
 		kfree((char *)dev - dev->padded);
 		return;
@@ -3337,6 +3353,7 @@ void free_netdev(struct net_device *dev)
 	/* will free via device release */
 	put_device(&dev->dev);
 #else
+	kfree((char *)dev->egress_subqueue);
 	kfree((char *)dev - dev->padded);
 #endif
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1422573..0528cf3 100644
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
@@ -1926,6 +1928,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
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
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 475df84..a532554 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -111,6 +111,28 @@ config NET_SCH_PRIO
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_prio.
 
+config NET_SCH_PRIO_MQ
+	bool "Multiple hardware queue support for PRIO"
+	depends on NET_SCH_PRIO
+	---help---
+	  Say Y here if you want to allow the PRIO qdisc to assign
+	  flows to multiple hardware queues on an ethernet device.  This
+	  will still work on devices with 1 queue.
+
+	  Consider this scheduler for devices that do not use
+	  hardware-based scheduling policies.  Otherwise, use NET_SCH_RR.
+
+	  Most people will say N here.
+
+config NET_SCH_RR
+	tristate "Multi Band Round Robin Queuing (RR)"
+	---help---
+	  Say Y here if you want to use an n-band round robin packet
+	  scheduler.
+
+	  To compile this code as a module, choose M here: the
+	  module will be caleld sch_rr.
+
 config NET_SCH_RED
 	tristate "Random Early Detection (RED)"
 	---help---
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 020767a..d3ed44e 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -26,6 +26,7 @@ obj-$(CONFIG_NET_SCH_SFQ)	+= sch_sfq.o
 obj-$(CONFIG_NET_SCH_TBF)	+= sch_tbf.o
 obj-$(CONFIG_NET_SCH_TEQL)	+= sch_teql.o
 obj-$(CONFIG_NET_SCH_PRIO)	+= sch_prio.o
+obj-$(CONFIG_NET_SCH_RR)	+= sch_rr.o
 obj-$(CONFIG_NET_SCH_ATM)	+= sch_atm.o
 obj-$(CONFIG_NET_SCH_NETEM)	+= sch_netem.o
 obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f28bb2d..b9dc2a6 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -123,7 +123,8 @@ static inline int qdisc_restart(struct net_device *dev)
 			/* And release queue */
 			spin_unlock(&dev->queue_lock);
 
-			if (!netif_queue_stopped(dev)) {
+			if (!netif_queue_stopped(dev) &&
+			    !netif_subqueue_stopped(dev, skb->queue_mapping)) {
 				int ret;
 
 				ret = dev_hard_start_xmit(skb, dev);
@@ -141,7 +142,6 @@ static inline int qdisc_restart(struct net_device *dev)
 					goto collision;
 				}
 			}
-
 			/* NETDEV_TX_BUSY - we need to requeue */
 			/* Release the driver */
 			if (!nolock) {
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 269a6e1..c78dba4 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -43,6 +43,7 @@ struct prio_sched_data
 	struct tcf_proto *filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
+	u16 band2queue[TC_PRIO_MAX + 1];
 };
 
 
@@ -70,13 +71,26 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 #endif
 			if (TC_H_MAJ(band))
 				band = 0;
+#ifdef CONFIG_NET_SCH_PRIO_MQ
+ 			skb->queue_mapping =
+ 				  q->band2queue[q->prio2band[band&TC_PRIO_MAX]];
+#endif
+
 			return q->queues[q->prio2band[band&TC_PRIO_MAX]];
 		}
 		band = res.classid;
 	}
 	band = TC_H_MIN(band) - 1;
-	if (band > q->bands)
+	if (band > q->bands) {
+#ifdef CONFIG_NET_SCH_PRIO_MQ
+ 		skb->queue_mapping = q->band2queue[q->prio2band[0]];
+#endif
 		return q->queues[q->prio2band[0]];
+	}
+
+#ifdef CONFIG_NET_SCH_PRIO_MQ
+ 	skb->queue_mapping = q->band2queue[band];
+#endif
 
 	return q->queues[band];
 }
@@ -144,12 +158,22 @@ prio_dequeue(struct Qdisc* sch)
 	struct Qdisc *qdisc;
 
 	for (prio = 0; prio < q->bands; prio++) {
-		qdisc = q->queues[prio];
-		skb = qdisc->dequeue(qdisc);
-		if (skb) {
-			sch->q.qlen--;
-			return skb;
+#ifdef CONFIG_NET_SCH_PRIO_MQ
+		/* Check if the target subqueue is available before
+		 * pulling an skb.  This way we avoid excessive requeues
+		 * for slower queues.
+		 */
+		if (!netif_subqueue_stopped(sch->dev, q->band2queue[prio])) {
+#endif
+			qdisc = q->queues[prio];
+			skb = qdisc->dequeue(qdisc);
+			if (skb) {
+				sch->q.qlen--;
+				return skb;
+			}
+#ifdef CONFIG_NET_SCH_PRIO_MQ
 		}
+#endif
 	}
 	return NULL;
 
@@ -200,6 +224,10 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tc_prio_qopt *qopt = RTA_DATA(opt);
 	int i;
+	int queue;
+	int qmapoffset;
+	int offset;
+	int mod;
 
 	if (opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
 		return -EINVAL;
@@ -242,6 +270,32 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 			}
 		}
 	}
+#ifdef CONFIG_NET_SCH_PRIO_MQ
+	/* setup queue to band mapping */
+	if (q->bands < sch->dev->egress_subqueue_count) {
+		qmapoffset = 1;
+		mod = sch->dev->egress_subqueue_count;
+	} else {
+		mod = q->bands % sch->dev->egress_subqueue_count;
+		qmapoffset = q->bands / sch->dev->egress_subqueue_count
+				+ ((mod) ? 1 : 0);
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
+#endif
 	return 0;
 }
 
diff --git a/net/sched/sch_rr.c b/net/sched/sch_rr.c
new file mode 100644
index 0000000..ce9f237
--- /dev/null
+++ b/net/sched/sch_rr.c
@@ -0,0 +1,516 @@
+/*
+ * net/sched/sch_rr.c	Simple n-band round-robin scheduler.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * The core part of this qdisc is based on sch_prio.  ->dequeue() is where
+ * this scheduler functionally differs.
+ *
+ * Author:	PJ Waskiewicz, <peter.p.waskiewicz.jr@intel.com>
+ *
+ * Original Authors (from PRIO): Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
+ * Fixes:       19990609: J Hadi Salim <hadi@nortelnetworks.com>:
+ *              Init --  EINVAL when opt undefined
+ */
+
+#include <linux/module.h>
+#include <asm/uaccess.h>
+#include <asm/system.h>
+#include <linux/bitops.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/in.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/if_ether.h>
+#include <linux/inet.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/notifier.h>
+#include <net/ip.h>
+#include <net/route.h>
+#include <linux/skbuff.h>
+#include <net/netlink.h>
+#include <net/sock.h>
+#include <net/pkt_sched.h>
+
+
+struct rr_sched_data
+{
+	int bands;
+	int curband;
+	struct tcf_proto *filter_list;
+	u8  prio2band[TC_RR_MAX + 1];
+	struct Qdisc *queues[TCQ_RR_BANDS];
+	u16 band2queue[TC_RR_MAX + 1];
+};
+
+
+static struct Qdisc *rr_classify(struct sk_buff *skb, struct Qdisc *sch,
+				 int *qerr)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+	u32 band = skb->priority;
+	struct tcf_result res;
+
+	*qerr = NET_XMIT_BYPASS;
+	if (TC_H_MAJ(skb->priority) != sch->handle) {
+#ifdef CONFIG_NET_CLS_ACT
+		switch (tc_classify(skb, q->filter_list, &res)) {
+		case TC_ACT_STOLEN:
+		case TC_ACT_QUEUED:
+			*qerr = NET_XMIT_SUCCESS;
+		case TC_ACT_SHOT:
+			return NULL;
+		}
+
+		if (!q->filter_list ) {
+#else
+		if (!q->filter_list || tc_classify(skb, q->filter_list, &res)) {
+#endif
+			if (TC_H_MAJ(band))
+				band = 0;
+ 			skb->queue_mapping =
+ 				  q->band2queue[q->prio2band[band&TC_RR_MAX]];
+
+			return q->queues[q->prio2band[band&TC_RR_MAX]];
+		}
+		band = res.classid;
+	}
+	band = TC_H_MIN(band) - 1;
+	if (band > q->bands) {
+ 		skb->queue_mapping = q->band2queue[q->prio2band[0]];
+		return q->queues[q->prio2band[0]];
+	}
+
+ 	skb->queue_mapping = q->band2queue[band];
+
+	return q->queues[band];
+}
+
+static int rr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct Qdisc *qdisc;
+	int ret;
+
+	qdisc = rr_classify(skb, sch, &ret);
+#ifdef CONFIG_NET_CLS_ACT
+	if (qdisc == NULL) {
+
+		if (ret == NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+#endif
+
+	if ((ret = qdisc->enqueue(skb, qdisc)) == NET_XMIT_SUCCESS) {
+		sch->bstats.bytes += skb->len;
+		sch->bstats.packets++;
+		sch->q.qlen++;
+		return NET_XMIT_SUCCESS;
+	}
+	sch->qstats.drops++;
+	return ret;
+}
+
+
+static int rr_requeue(struct sk_buff *skb, struct Qdisc* sch)
+{
+	struct Qdisc *qdisc;
+	int ret;
+
+	qdisc = rr_classify(skb, sch, &ret);
+#ifdef CONFIG_NET_CLS_ACT
+	if (qdisc == NULL) {
+		if (ret == NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+#endif
+
+	if ((ret = qdisc->ops->requeue(skb, qdisc)) == NET_XMIT_SUCCESS) {
+		sch->q.qlen++;
+		sch->qstats.requeues++;
+		return 0;
+	}
+	sch->qstats.drops++;
+	return NET_XMIT_DROP;
+}
+
+
+static struct sk_buff *rr_dequeue(struct Qdisc* sch)
+{
+	struct sk_buff *skb;
+	struct rr_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *qdisc;
+	int bandcount;
+
+	/* Only take one pass through the queues.  If nothing is available,
+	 * return nothing.
+	 */
+	for (bandcount = 0; bandcount < q->bands; bandcount++) {
+		/* Check if the target subqueue is available before
+		 * pulling an skb.  This way we avoid excessive requeues
+		 * for slower queues.  If the queue is stopped, try the
+		 * next queue.
+		 */
+		if (!netif_subqueue_stopped(sch->dev, q->band2queue[q->curband])) {
+			qdisc = q->queues[q->curband];
+			skb = qdisc->dequeue(qdisc);
+			if (skb) {
+				sch->q.qlen--;
+				q->curband++;
+				if (q->curband >= q->bands)
+					q->curband = 0;
+				return skb;
+			}
+		}
+		q->curband++;
+		if (q->curband >= q->bands)
+			q->curband = 0;
+	}
+	return NULL;
+}
+
+static unsigned int rr_drop(struct Qdisc* sch)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+	int band;
+	unsigned int len;
+	struct Qdisc *qdisc;
+
+	for (band = q->bands - 1; band >= 0; band--) {
+		qdisc = q->queues[band];
+		if (qdisc->ops->drop && (len = qdisc->ops->drop(qdisc)) != 0) {
+			sch->q.qlen--;
+			return len;
+		}
+	}
+	return 0;
+}
+
+
+static void rr_reset(struct Qdisc* sch)
+{
+	int band;
+	struct rr_sched_data *q = qdisc_priv(sch);
+
+	for (band = 0; band < q->bands; band++)
+		qdisc_reset(q->queues[band]);
+	sch->q.qlen = 0;
+}
+
+static void rr_destroy(struct Qdisc* sch)
+{
+	int band;
+	struct rr_sched_data *q = qdisc_priv(sch);
+
+	tcf_destroy_chain(q->filter_list);
+	for (band = 0; band < q->bands; band++)
+		qdisc_destroy(q->queues[band]);
+}
+
+static int rr_tune(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+	struct tc_rr_qopt *qopt = RTA_DATA(opt);
+	int i;
+	int queue;
+	int qmapoffset;
+	int offset;
+	int mod;
+
+	if (opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
+		return -EINVAL;
+	if (qopt->bands > TCQ_RR_BANDS || qopt->bands < 2)
+		return -EINVAL;
+
+	for (i = 0; i <= TC_RR_MAX; i++) {
+		if (qopt->priomap[i] >= qopt->bands)
+			return -EINVAL;
+	}
+
+	sch_tree_lock(sch);
+	q->bands = qopt->bands;
+	memcpy(q->prio2band, qopt->priomap, TC_PRIO_MAX+1);
+	q->curband = 0;
+
+	for (i = q->bands; i < TCQ_RR_BANDS; i++) {
+		struct Qdisc *child = xchg(&q->queues[i], &noop_qdisc);
+		if (child != &noop_qdisc) {
+			qdisc_tree_decrease_qlen(child, child->q.qlen);
+			qdisc_destroy(child);
+		}
+	}
+	sch_tree_unlock(sch);
+
+	for (i = 0; i < q->bands; i++) {
+		if (q->queues[i] == &noop_qdisc) {
+			struct Qdisc *child;
+			child = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+						  TC_H_MAKE(sch->handle, i + 1));
+			if (child) {
+				sch_tree_lock(sch);
+				child = xchg(&q->queues[i], child);
+
+				if (child != &noop_qdisc) {
+					qdisc_tree_decrease_qlen(child,
+								 child->q.qlen);
+					qdisc_destroy(child);
+				}
+				sch_tree_unlock(sch);
+			}
+		}
+	}
+	/* setup queue to band mapping - best effort to map into available
+	 * hardware queues
+	 */
+	if (q->bands < sch->dev->egress_subqueue_count) {
+		qmapoffset = 1;
+		mod = sch->dev->egress_subqueue_count;
+	} else {
+		mod = q->bands % sch->dev->egress_subqueue_count;
+		qmapoffset = q->bands / sch->dev->egress_subqueue_count
+				+ ((mod) ? 1 : 0);
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
+
+	return 0;
+}
+
+static int rr_init(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+	int i;
+
+	for (i = 0; i < TCQ_RR_BANDS; i++)
+		q->queues[i] = &noop_qdisc;
+
+	if (opt == NULL) {
+		return -EINVAL;
+	} else {
+		int err;
+
+		if ((err = rr_tune(sch, opt)) != 0)
+			return err;
+	}
+	return 0;
+}
+
+static int rr_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tc_rr_qopt opt;
+
+	opt.bands = q->bands;
+	memcpy(&opt.priomap, q->prio2band, TC_RR_MAX + 1);
+	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	return skb->len;
+
+rtattr_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static int rr_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
+		    struct Qdisc **old)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+	unsigned long band = arg - 1;
+
+	if (band >= q->bands)
+		return -EINVAL;
+
+	if (new == NULL)
+		new = &noop_qdisc;
+
+	sch_tree_lock(sch);
+	*old = q->queues[band];
+	q->queues[band] = new;
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+	qdisc_reset(*old);
+	sch_tree_unlock(sch);
+
+	return 0;
+}
+
+static struct Qdisc *rr_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+	unsigned long band = arg - 1;
+
+	if (band >= q->bands)
+		return NULL;
+
+	return q->queues[band];
+}
+
+static unsigned long rr_get(struct Qdisc *sch, u32 classid)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+	unsigned long band = TC_H_MIN(classid);
+
+	if (band - 1 >= q->bands)
+		return 0;
+	return band;
+}
+
+static unsigned long rr_bind(struct Qdisc *sch, unsigned long parent,
+			     u32 classid)
+{
+	return rr_get(sch, classid);
+}
+
+
+static void rr_put(struct Qdisc *q, unsigned long cl)
+{
+	return;
+}
+
+static int rr_change(struct Qdisc *sch, u32 handle, u32 parent,
+		     struct rtattr **tca, unsigned long *arg)
+{
+	unsigned long cl = *arg;
+	struct rr_sched_data *q = qdisc_priv(sch);
+
+	if (cl - 1 > q->bands)
+		return -ENOENT;
+	return 0;
+}
+
+static int rr_delete(struct Qdisc *sch, unsigned long cl)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+	if (cl - 1 > q->bands)
+		return -ENOENT;
+	return 0;
+}
+
+
+static int rr_dump_class(struct Qdisc *sch, unsigned long cl,
+			 struct sk_buff *skb, struct tcmsg *tcm)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+
+	if (cl - 1 > q->bands)
+		return -ENOENT;
+	tcm->tcm_handle |= TC_H_MIN(cl);
+	if (q->queues[cl - 1])
+		tcm->tcm_info = q->queues[cl - 1]->handle;
+	return 0;
+}
+
+static int rr_dump_class_stats(struct Qdisc *sch, unsigned long cl,
+			       struct gnet_dump *d)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *cl_q;
+
+	cl_q = q->queues[cl - 1];
+	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
+	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
+		return -1;
+
+	return 0;
+}
+
+static void rr_walk(struct Qdisc *sch, struct qdisc_walker *arg)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+	int band;
+
+	if (arg->stop)
+		return;
+
+	for (band = 0; band < q->bands; band++) {
+		if (arg->count < arg->skip) {
+			arg->count++;
+			continue;
+		}
+		if (arg->fn(sch, band + 1, arg) < 0) {
+			arg->stop = 1;
+			break;
+		}
+		arg->count++;
+	}
+}
+
+static struct tcf_proto **rr_find_tcf(struct Qdisc *sch, unsigned long cl)
+{
+	struct rr_sched_data *q = qdisc_priv(sch);
+
+	if (cl)
+		return NULL;
+	return &q->filter_list;
+}
+
+static struct Qdisc_class_ops rr_class_ops = {
+	.graft		=	rr_graft,
+	.leaf		=	rr_leaf,
+	.get		=	rr_get,
+	.put		=	rr_put,
+	.change		=	rr_change,
+	.delete		=	rr_delete,
+	.walk		=	rr_walk,
+	.tcf_chain	=	rr_find_tcf,
+	.bind_tcf	=	rr_bind,
+	.unbind_tcf	=	rr_put,
+	.dump		=	rr_dump_class,
+	.dump_stats	=	rr_dump_class_stats,
+};
+
+static struct Qdisc_ops rr_qdisc_ops = {
+	.next		=	NULL,
+	.cl_ops		=	&rr_class_ops,
+	.id		=	"rr",
+	.priv_size	=	sizeof(struct rr_sched_data),
+	.enqueue	=	rr_enqueue,
+	.dequeue	=	rr_dequeue,
+	.requeue	=	rr_requeue,
+	.drop		=	rr_drop,
+	.init		=	rr_init,
+	.reset		=	rr_reset,
+	.destroy	=	rr_destroy,
+	.change		=	rr_tune,
+	.dump		=	rr_dump,
+	.owner		=	THIS_MODULE,
+};
+
+static int __init rr_module_init(void)
+{
+	return register_qdisc(&rr_qdisc_ops);
+}
+
+static void __exit rr_module_exit(void)
+{
+	unregister_qdisc(&rr_qdisc_ops);
+}
+
+module_init(rr_module_init)
+module_exit(rr_module_exit)
+
+MODULE_LICENSE("GPL");
