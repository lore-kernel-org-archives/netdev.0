From: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Subject: RE: [PATCH 1/2] NET: Multiple queue network device support
Date: Fri, 23 Feb 2007 04:02:26 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77013F3840@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Peter Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"David Miller" <davem@davemloft.net>,
	"Garzik, Jeff" <jgarzik@pobox.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932186AbXBWJOe@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Function "map_queue" returns queue_index as 0 always. There is no
support to return different queue numbers.

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Kok, Auke
Sent: Friday, February 09, 2007 5:40 AM
To: David Miller; Garzik, Jeff; netdev@vger.kernel.org;
linux-kernel@vger.kernel.org
Cc: Kok, Auke; Peter Waskiewicz Jr; Brandeburg, Jesse; Kok, Auke;
Ronciak, John
Subject: [PATCH 1/2] NET: Multiple queue network device support


From: Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Added an API and associated supporting routines for multiqueue network
devices.  This allows network devices supporting multiple TX queues to
configure each queue within the netdevice and manage each queue
independantly.  Changes to the PRIO Qdisc also allow a user to map
multiple flows to individual TX queues, taking advantage of each queue
on the device.

Signed-off-by: Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 include/linux/netdevice.h |   73 ++++++++++++++++++++++++++++
 include/net/sch_generic.h |    3 +
 net/Kconfig               |   20 ++++++++
 net/core/dev.c            |   51 ++++++++++++++++++++
 net/sched/sch_generic.c   |  117
+++++++++++++++++++++++++++++++++++++++++++++
 net/sched/sch_prio.c      |  106
++++++++++++++++++++++++++++++++++++++---
 6 files changed, 364 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h index
2e37f50..c7f94a8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -106,6 +106,16 @@ struct netpoll_info;  #define MAX_HEADER
(LL_MAX_HEADER + 48)  #endif
 
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+
+struct net_device_subqueue
+{
+	/* Give a lock and a flow control state for each queue */
+	unsigned long	state;
+	spinlock_t	queue_lock ____cacheline_aligned_in_smp;
+};
+#endif
+
 /*
  *	Network device statistics. Akin to the 2.0 ether stats but
  *	with byte counters.
@@ -339,6 +349,10 @@ struct net_device
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
 
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+#define NETIF_F_MULTI_QUEUE	8192	/* Has multiple TX/RX queues */
+#endif
+
 	struct net_device	*next_sched;
 
 	/* Interface index. Unique device identifier	*/
@@ -532,6 +546,19 @@ struct net_device
 	struct device		dev;
 	/* space for optional statistics and wireless sysfs groups */
 	struct attribute_group  *sysfs_groups[3];
+
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	/* To retrieve statistics per subqueue - FOR FUTURE USE */
+	struct net_device_stats* (*get_subqueue_stats)(struct net_device
*dev,
+							int
queue_index);
+
+	/* The TX queue control structures */
+	struct net_device_subqueue	*egress_subqueue;
+	int				egress_subqueue_count;
+	int			(*hard_start_subqueue_xmit)(struct
sk_buff *skb,
+							struct
net_device *dev,
+							int
queue_index);
+#endif /* CONFIG_NET_MULTI_QUEUE_DEVICE */
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -673,6 +700,52 @@ static inline int netif_running(const struct
net_device *dev)
 	return test_bit(__LINK_STATE_START, &dev->state);  }
 
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+
+/*
+ * Routines to manage the subqueues on a device.  We only need start
+ * stop, and a check if it's stopped.  All other device management is
+ * done at the overall netdevice level.
+ * Also test the netif state if we're multi-queue at all.
+ */
+static inline void netif_start_subqueue(struct net_device *dev, int
+queue_index) {
+	clear_bit(__LINK_STATE_XOFF,
+&dev->egress_subqueue[queue_index].state);
+}
+
+static inline void netif_stop_subqueue(struct net_device *dev, int
+queue_index) { #ifdef CONFIG_NETPOLL_TRAP
+	if (netpoll_trap())
+		return;
+#endif
+	set_bit(__LINK_STATE_XOFF,
&dev->egress_subqueue[queue_index].state);
+}
+
+static inline int netif_subqueue_stopped(const struct net_device *dev,
+                                         int queue_index) {
+	return test_bit(__LINK_STATE_XOFF,
+	                &dev->egress_subqueue[queue_index].state);
+}
+
+static inline void netif_wake_subqueue(struct net_device *dev, int
+queue_index) { #ifdef CONFIG_NETPOLL_TRAP
+	if (netpoll_trap())
+		return;
+#endif
+	if (test_and_clear_bit(__LINK_STATE_XOFF,
+
&dev->egress_subqueue[queue_index].state))
+		__netif_schedule(dev);
+}
+
+static inline int netif_is_multiqueue(const struct net_device *dev) {
+	return (!!(NETIF_F_MULTI_QUEUE & dev->features)); } #endif /* 
+CONFIG_NET_MULTI_QUEUE_DEVICE */
+
 
 /* Use this variant when it is known for sure that it
  * is executing from interrupt context.
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h index
8208639..8751ba6 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -102,6 +102,9 @@ struct Qdisc_ops
 
 	int			(*dump)(struct Qdisc *, struct sk_buff
*);
 	int			(*dump_stats)(struct Qdisc *, struct
gnet_dump *);
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	int			(*map_queue)(struct sk_buff *, struct
Qdisc *);
+#endif
 
 	struct module		*owner;
 };
diff --git a/net/Kconfig b/net/Kconfig
index 7dfc949..796edb3 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -38,6 +38,26 @@ source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
 
+config NET_MULTI_QUEUE_DEVICE
+	bool "Multiple queue network device support (EXPERIMENTAL)"
+	depends on NET_SCHED && EXPERIMENTAL
+	help
+	  Saying Y here will add support for network devices that have
more than
+	  one physical TX queue and/or RX queue.
+
+	  Multiple queue devices will require qdiscs that understand how
to
+	  queue to multiple targets.  The default packet scheduler will
default
+	  to the first queue in a device.  In other words, if you need
the
+	  ability to spread traffic across queues, your queueing
discipline
+	  needs to know how to do that.
+
+	  Note that saying Y here will give preferential treatment to
multiple
+	  queue devices in the network stack.  A slight drop in
single-queue
+	  device performance may be seen.
+
+	  Say N here unless you know your network device supports
multiple
+	  TX and/or RX queues.
+
 config INET
 	bool "TCP/IP networking"
 	---help---
diff --git a/net/core/dev.c b/net/core/dev.c index 455d589..42b635c
100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1477,6 +1477,49 @@ gso:
 	skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
 #endif
 	if (q->enqueue) {
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+		int queue_index;
+		/* If we're a multi-queue device, get a queue index to
lock */
+		if (netif_is_multiqueue(dev))
+		{
+			/* Get the queue index and lock it. */
+			if (likely(q->ops->map_queue)) {
+				queue_index = q->ops->map_queue(skb, q);
+
spin_lock(&dev->egress_subqueue[queue_index].queue_lock);
+				rc = q->enqueue(skb, q);
+				/*
+				 * Unlock because the underlying qdisc
+				 * may queue and send a packet from a
+				 * different queue.
+				 */
+
spin_unlock(&dev->egress_subqueue[queue_index].queue_lock);
+				qdisc_run(dev);
+				rc = rc == NET_XMIT_BYPASS
+				           ? NET_XMIT_SUCCESS : rc;
+				goto out;
+			} else {
+				printk(KERN_CRIT "Device %s is "
+					"multiqueue, but map_queue is "
+					"undefined in the qdisc!!\n",
+					dev->name);
+				kfree_skb(skb);
+			}
+		} else {
+			/* We're not a multi-queue device. */
+			spin_lock(&dev->queue_lock);
+			q = dev->qdisc;
+			if (q->enqueue) {
+				rc = q->enqueue(skb, q);
+				qdisc_run(dev);
+				spin_unlock(&dev->queue_lock);
+				rc = rc == NET_XMIT_BYPASS
+				           ? NET_XMIT_SUCCESS : rc;
+				goto out;
+			}
+			spin_unlock(&dev->queue_lock);
+		}
+#else /* No multi-queue support compiled in */
+
 		/* Grab device queue */
 		spin_lock(&dev->queue_lock);
 		q = dev->qdisc;
@@ -1489,6 +1532,7 @@ gso:
 			goto out;
 		}
 		spin_unlock(&dev->queue_lock);
+#endif /* CONFIG_NET_MULTI_QUEUE_DEVICE */
 	}
 
 	/* The device has no queue. Common case for software devices:
@@ -2879,6 +2923,9 @@ int register_netdevice(struct net_device *dev)
 	struct hlist_head *head;
 	struct hlist_node *p;
 	int ret;
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	int i;
+#endif
 
 	BUG_ON(dev_boot_phase);
 	ASSERT_RTNL();
@@ -2894,6 +2941,10 @@ int register_netdevice(struct net_device *dev)
#ifdef CONFIG_NET_CLS_ACT
 	spin_lock_init(&dev->ingress_lock);
 #endif
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	for (i = 0; i < dev->egress_subqueue_count; i++)
+		spin_lock_init(&dev->egress_subqueue[i].queue_lock);
+#endif
 
 	dev->iflink = -1;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c index
bc116bd..62ca23e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -42,6 +42,7 @@
    to data, participating in scheduling must be additionally
    protected with dev->queue_lock spinlock.
 
+   For single-queue devices:
    The idea is the following:
    - enqueue, dequeue are serialized via top level device
      spinlock dev->queue_lock.
@@ -51,6 +52,12 @@
      hence this lock may be made without local bh disabling.
 
    qdisc_tree_lock must be grabbed BEFORE dev->queue_lock!
+
+   For multi-queue devices:
+   - enqueue, dequeue are serialized with individual queue locks,
+     dev->egress_subqueue[queue_index].queue_lock.
+   - Everything else with tree protection with single queue devices
apply
+     to multiqueue devices.
  */
 DEFINE_RWLOCK(qdisc_tree_lock);
 
@@ -92,6 +99,9 @@ static inline int qdisc_restart(struct net_device
*dev)  {
 	struct Qdisc *q = dev->qdisc;
 	struct sk_buff *skb;
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	int queue_index = 0;
+#endif
 
 	/* Dequeue packet */
 	if (((skb = dev->gso_skb)) || ((skb = q->dequeue(q)))) { @@
-130,6 +140,72 @@ static inline int qdisc_restart(struct net_device
*dev)
 		}
 		
 		{
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+			if (netif_is_multiqueue(dev)) {
+				if (likely(q->ops->map_queue)) {
+					queue_index =
q->ops->map_queue(skb, q);
+				} else {
+					printk(KERN_CRIT "Device %s is "
+						"multiqueue, but
map_queue is "
+						"undefined in the
qdisc!!\n",
+						dev->name);
+					goto requeue;
+				}
+
spin_unlock(&dev->egress_subqueue[queue_index].queue_lock);
+				/* Check top level device, and any
sub-device */
+				if ((!netif_queue_stopped(dev)) &&
+				  (!netif_subqueue_stopped(dev,
queue_index))) {
+					int ret;
+					ret =
dev->hard_start_subqueue_xmit(skb, dev, queue_index);
+					if (ret == NETDEV_TX_OK) {
+						if (!nolock) {
+
netif_tx_unlock(dev);
+						}
+						return -1;
+					}
+					if (ret == NETDEV_TX_LOCKED &&
nolock) {
+
spin_lock(&dev->egress_subqueue[queue_index].queue_lock);
+						goto collision;
+					}
+				}
+				/* NETDEV_TX_BUSY - we need to requeue
*/
+				/* Release the driver */
+				if (!nolock) {
+					netif_tx_unlock(dev);
+				}
+
spin_lock(&dev->egress_subqueue[queue_index].queue_lock);
+				q = dev->qdisc;
+			}
+			else
+			{
+				/* We're a single-queue device */
+				/* And release queue */
+				spin_unlock(&dev->queue_lock);
+				if (!netif_queue_stopped(dev)) {
+					int ret;
+
+					ret = dev->hard_start_xmit(skb,
dev);
+					if (ret == NETDEV_TX_OK) {
+						if (!nolock) {
+
netif_tx_unlock(dev);
+						}
+
spin_lock(&dev->queue_lock);
+						return -1;
+					}
+					if (ret == NETDEV_TX_LOCKED &&
nolock) {
+
spin_lock(&dev->queue_lock);
+						goto collision;
+					}
+				}
+				/* NETDEV_TX_BUSY - we need to requeue
*/
+				/* Release the driver */
+				if (!nolock) {
+					netif_tx_unlock(dev);
+				}
+				spin_lock(&dev->queue_lock);
+				q = dev->qdisc;
+			}
+#else /* CONFIG_NET_MULTI_QUEUE_DEVICE */
 			/* And release queue */
 			spin_unlock(&dev->queue_lock);
 
@@ -157,6 +233,7 @@ static inline int qdisc_restart(struct net_device
*dev)
 			} 
 			spin_lock(&dev->queue_lock);
 			q = dev->qdisc;
+#endif /* CONFIG_NET_MULTI_QUEUE_DEVICE */
 		}
 
 		/* Device kicked us out :(
@@ -175,9 +252,17 @@ requeue:
 		else
 			q->ops->requeue(skb, q);
 		netif_schedule(dev);
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+		if (netif_is_multiqueue(dev))
+
spin_unlock(&dev->egress_subqueue[queue_index].queue_lock);
+#endif
 		return 1;
 	}
 	BUG_ON((int) q->q.qlen < 0);
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	if (netif_is_multiqueue(dev))
+
spin_unlock(&dev->egress_subqueue[queue_index].queue_lock);
+#endif
 	return q->q.qlen;
 }
 
@@ -287,12 +372,22 @@ static int noop_requeue(struct sk_buff *skb,
struct Qdisc* qdisc)
 	return NET_XMIT_CN;
 }
 
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+static int noop_map_queue(struct sk_buff *skb, struct Qdisc *qdisc) {
+	return 0;
+}
+#endif
+
 struct Qdisc_ops noop_qdisc_ops = {
 	.id		=	"noop",
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
 	.requeue	=	noop_requeue,
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	.map_queue	=	noop_map_queue,
+#endif
 	.owner		=	THIS_MODULE,
 };
 
@@ -310,6 +405,9 @@ static struct Qdisc_ops noqueue_qdisc_ops = {
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
 	.requeue	=	noop_requeue,
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	.map_queue	=	noop_map_queue,
+#endif
 	.owner		=	THIS_MODULE,
 };
 
@@ -356,10 +454,18 @@ static struct sk_buff *pfifo_fast_dequeue(struct
Qdisc* qdisc)
 	struct sk_buff_head *list = qdisc_priv(qdisc);
 
 	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+		if (netif_is_multiqueue(qdisc->dev))
+
spin_lock(&qdisc->dev->egress_subqueue[0].queue_lock);
+#endif
 		if (!skb_queue_empty(list + prio)) {
 			qdisc->q.qlen--;
 			return __qdisc_dequeue_head(qdisc, list + prio);
 		}
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+		if (netif_is_multiqueue(qdisc->dev))
+
spin_unlock(&qdisc->dev->egress_subqueue[0].queue_lock);
+#endif
 	}
 
 	return NULL;
@@ -406,6 +512,14 @@ static int pfifo_fast_init(struct Qdisc *qdisc,
struct rtattr *opt)
 	return 0;
 }
 
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+static int pfifo_fast_map_queue(struct sk_buff *skb, struct Qdisc
+*qdisc) {
+	/* Generic qdisc, so always return queue index 0. */
+	return 0;
+}
+#endif
+
 static struct Qdisc_ops pfifo_fast_ops = {
 	.id		=	"pfifo_fast",
 	.priv_size	=	PFIFO_FAST_BANDS * sizeof(struct
sk_buff_head),
@@ -415,6 +529,9 @@ static struct Qdisc_ops pfifo_fast_ops = {
 	.init		=	pfifo_fast_init,
 	.reset		=	pfifo_fast_reset,
 	.dump		=	pfifo_fast_dump,
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	.map_queue	=	pfifo_fast_map_queue,
+#endif
 	.owner		=	THIS_MODULE,
 };
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c index
2567b4c..0e24071 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -43,16 +43,19 @@ struct prio_sched_data
 	struct tcf_proto *filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	int band2queue[TC_PRIO_MAX + 1];
+#endif
 };
 
-
 static struct Qdisc *
-prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
+prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr, int
+*retband)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	u32 band = skb->priority;
 	struct tcf_result res;
 
+	*retband = band;
 	*qerr = NET_XMIT_BYPASS;
 	if (TC_H_MAJ(skb->priority) != sch->handle) {  #ifdef
CONFIG_NET_CLS_ACT @@ -68,13 +71,16 @@ prio_classify(struct sk_buff
*skb, struct Qdisc *sch, int *qerr)  #else
 		if (!q->filter_list || tc_classify(skb, q->filter_list,
&res)) {  #endif
-			if (TC_H_MAJ(band))
+			if (TC_H_MAJ(band)) {
 				band = 0;
+				*retband = 0;
+			}
 			return
q->queues[q->prio2band[band&TC_PRIO_MAX]];
 		}
 		band = res.classid;
 	}
 	band = TC_H_MIN(band) - 1;
+	*retband = band;
 	if (band > q->bands)
 		return q->queues[q->prio2band[0]];
 
@@ -86,8 +92,15 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
{
 	struct Qdisc *qdisc;
 	int ret;
+	int band; /* Unused in this function, just here for multi-queue
*/
+
+	/*
+	 * NOTE: if a device is multiqueue, then it is imperative the
+	 * underlying qdisc NOT be another PRIO qdisc.  Otherwise we're
going
+	 * to deadlock.  Fixme please.
+	 */
+	qdisc = prio_classify(skb, sch, &ret, &band);
 
-	qdisc = prio_classify(skb, sch, &ret);
 #ifdef CONFIG_NET_CLS_ACT
 	if (qdisc == NULL) {
 
@@ -108,14 +121,34 @@ prio_enqueue(struct sk_buff *skb, struct Qdisc
*sch)
 	return ret;
 }
 
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+static int
+prio_map_queue(struct sk_buff *skb, struct Qdisc *sch) {
+	/*
+	 * We'll classify the skb here, so return the Qdisc back through
+	 * the function call.  The return value is the queue we need to
+	 * lock, which will be the value returned through band.  This
will help
+	 * speed up enqueue, since it won't have to do the classify
again.
+	 */
+	int ret;
+	int band;
+	struct prio_sched_data *q = qdisc_priv(sch);
+
+	sch = prio_classify(skb, sch, &ret, &band);
+	return q->band2queue[band];
+}
+#endif
 
 static int
 prio_requeue(struct sk_buff *skb, struct Qdisc* sch)  {
 	struct Qdisc *qdisc;
 	int ret;
+	int band;
+
+	qdisc = prio_classify(skb, sch, &ret, &band);
 
-	qdisc = prio_classify(skb, sch, &ret);
 #ifdef CONFIG_NET_CLS_ACT
 	if (qdisc == NULL) {
 		if (ret == NET_XMIT_BYPASS)
@@ -141,18 +174,53 @@ prio_dequeue(struct Qdisc* sch)
 	struct sk_buff *skb;
 	struct prio_sched_data *q = qdisc_priv(sch);
 	int prio;
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	int queue;
+#endif
 	struct Qdisc *qdisc;
 
+	/*
+	 * If we're multiqueue, the basic approach is try the lock on
each
+	 * queue.  If it's locked, either we're already dequeuing, or
enqueue
+	 * is doing something.  Go to the next band if we're locked.
Once we
+	 * have a packet, unlock the queue.  NOTE: the underlying qdisc
CANNOT
+	 * be a PRIO qdisc, otherwise we will deadlock.  FIXME
+	 */
 	for (prio = 0; prio < q->bands; prio++) {
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+		if (netif_is_multiqueue(sch->dev)) {
+			queue = q->band2queue[prio];
+			if
(spin_trylock(&sch->dev->egress_subqueue[queue].queue_lock)) {
+				qdisc = q->queues[prio];
+				skb = qdisc->dequeue(qdisc);
+				if (skb) {
+					sch->q.qlen--;
+					skb->priority = prio;
+
spin_unlock(&sch->dev->egress_subqueue[queue].queue_lock);
+					return skb;
+				}
+
spin_unlock(&sch->dev->egress_subqueue[queue].queue_lock);
+			}
+		} else {
+			qdisc = q->queues[prio];
+			skb = qdisc->dequeue(qdisc);
+			if (skb) {
+				sch->q.qlen--;
+				skb->priority = prio;
+				return skb;
+			}
+		}
+#else
 		qdisc = q->queues[prio];
 		skb = qdisc->dequeue(qdisc);
 		if (skb) {
 			sch->q.qlen--;
+			skb->priority = prio;
 			return skb;
 		}
+#endif
 	}
 	return NULL;
-
 }
 
 static unsigned int prio_drop(struct Qdisc* sch) @@ -205,6 +273,10 @@
static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tc_prio_qopt *qopt = RTA_DATA(opt);
 	int i;
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	int queue;
+	int qmapoffset;
+#endif
 
 	if (opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
 		return -EINVAL;
@@ -247,6 +319,25 @@ static int prio_tune(struct Qdisc *sch, struct
rtattr *opt)
 			}
 		}
 	}
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	/* setup queue to band mapping */
+	if (netif_is_multiqueue(sch->dev)) {
+		if (q->bands == sch->dev->egress_subqueue_count)
+			qmapoffset = 0;
+		else
+			qmapoffset = q->bands /
sch->dev->egress_subqueue_count;
+
+		queue = 0;
+		for (i = 0; i < q->bands; i++) {
+			q->band2queue[i] = queue;
+			if ( (((i + 1) - queue) == qmapoffset) &&
+			     (queue < (sch->dev->egress_subqueue_count -
1))) {
+				queue++;
+			}
+		}
+	}
+
+#endif
 	return 0;
 }
 
@@ -430,6 +521,9 @@ static struct Qdisc_ops prio_qdisc_ops = {
 	.destroy	=	prio_destroy,
 	.change		=	prio_tune,
 	.dump		=	prio_dump,
+#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
+	.map_queue	=	prio_map_queue,
+#endif
 	.owner		=	THIS_MODULE,
 };
 



---
Auke Kok <auke-jan.h.kok@intel.com>
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
