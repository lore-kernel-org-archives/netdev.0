From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/31]: netdev: Allocate multiple queues for TX.
Date: Thu, 17 Jul 2008 05:15:45 -0700 (PDT)
Message-ID: <20080717.051545.150785763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51613
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754865AbYGQMPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:15:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


alloc_netdev_mq() now allocates an array of netdev_queue
structures for TX, based upon the queue_count argument.

Furthermore, all accesses to the TX queues are now vectored
through the netdev_get_tx_queue() and netdev_for_each_tx_queue()
interfaces.  This makes it easy to grep the tree for all
things that want to get to a TX queue of a net device.

Problem spots which are not really multiqueue aware yet, and
only work with one queue, can easily be spotted by grepping
for all netdev_get_tx_queue() calls that pass in a zero index.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/bonding/bond_main.c         |    6 +-
 drivers/net/hamradio/bpqether.c         |    6 +-
 drivers/net/ifb.c                       |   12 ++-
 drivers/net/macvlan.c                   |    6 +-
 drivers/net/wireless/hostap/hostap_hw.c |    6 +-
 include/linux/netdevice.h               |   69 ++++++++----
 include/net/sch_generic.h               |   37 +++++--
 net/8021q/vlan_dev.c                    |   10 +-
 net/core/dev.c                          |   40 ++++++--
 net/core/rtnetlink.c                    |    2 +-
 net/mac80211/main.c                     |    4 +-
 net/mac80211/wme.c                      |   12 +-
 net/netrom/af_netrom.c                  |    6 +-
 net/rose/af_rose.c                      |    6 +-
 net/sched/cls_api.c                     |    4 +-
 net/sched/sch_api.c                     |   32 ++++--
 net/sched/sch_generic.c                 |  178 ++++++++++++++++++++++--------
 net/sched/sch_teql.c                    |   21 +++--
 18 files changed, 320 insertions(+), 137 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fd87dbe..9737c06 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5042,7 +5042,9 @@ static int bond_check_params(struct bond_params *params)
 
 static struct lock_class_key bonding_netdev_xmit_lock_key;
 
-static void bond_set_lockdep_class_one(struct netdev_queue *txq)
+static void bond_set_lockdep_class_one(struct net_device *dev,
+				       struct netdev_queue *txq,
+				       void *_unused)
 {
 	lockdep_set_class(&txq->_xmit_lock,
 			  &bonding_netdev_xmit_lock_key);
@@ -5050,7 +5052,7 @@ static void bond_set_lockdep_class_one(struct netdev_queue *txq)
 
 static void bond_set_lockdep_class(struct net_device *dev)
 {
-	bond_set_lockdep_class_one(&dev->tx_queue);
+	netdev_for_each_tx_queue(dev, bond_set_lockdep_class_one, NULL);
 }
 
 /* Create a new bond based on the specified name and bonding parameters.
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index fb186b8..b6500b2 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -124,14 +124,16 @@ static LIST_HEAD(bpq_devices);
  */
 static struct lock_class_key bpq_netdev_xmit_lock_key;
 
-static void bpq_set_lockdep_class_one(struct netdev_queue *txq)
+static void bpq_set_lockdep_class_one(struct net_device *dev,
+				      struct netdev_queue *txq,
+				      void *_unused)
 {
 	lockdep_set_class(&txq->_xmit_lock, &bpq_netdev_xmit_lock_key);
 }
 
 static void bpq_set_lockdep_class(struct net_device *dev)
 {
-	bpq_set_lockdep_class_one(&dev->tx_queue);
+	netdev_for_each_tx_queue(dev, bpq_set_lockdep_class_one, NULL);
 }
 
 /* ------------------------------------------------------------------------ */
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index ccbd655..897b05e 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -229,14 +229,20 @@ module_param(numifbs, int, 0);
 MODULE_PARM_DESC(numifbs, "Number of ifb devices");
 
 /*
- * dev_ifb->tx_queue.lock is usually taken after dev->rx_queue.lock,
+ * dev_ifb's TX queue lock is usually taken after dev->rx_queue.lock,
  * reversely to e.g. qdisc_lock_tree(). It should be safe until
- * ifb doesn't take dev->tx_queue.lock with dev_ifb->rx_queue.lock.
+ * ifb doesn't take dev's TX queue lock with dev_ifb->rx_queue.lock.
  * But lockdep should know that ifb has different locks from dev.
  */
 static struct lock_class_key ifb_tx_queue_lock_key;
 static struct lock_class_key ifb_rx_queue_lock_key;
 
+static void set_tx_lockdep_key(struct net_device *dev,
+			       struct netdev_queue *txq,
+			       void *_unused)
+{
+	lockdep_set_class(&txq->lock, &ifb_tx_queue_lock_key);
+}
 
 static int __init ifb_init_one(int index)
 {
@@ -258,7 +264,7 @@ static int __init ifb_init_one(int index)
 	if (err < 0)
 		goto err;
 
-	lockdep_set_class(&dev_ifb->tx_queue.lock, &ifb_tx_queue_lock_key);
+	netdev_for_each_tx_queue(dev_ifb, set_tx_lockdep_key, NULL);
 	lockdep_set_class(&dev_ifb->rx_queue.lock, &ifb_rx_queue_lock_key);
 
 	return 0;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 980001c..72745ce 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -285,7 +285,9 @@ static struct lock_class_key macvlan_netdev_xmit_lock_key;
 #define MACVLAN_STATE_MASK \
 	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
 
-static void macvlan_set_lockdep_class_one(struct netdev_queue *txq)
+static void macvlan_set_lockdep_class_one(struct net_device *dev,
+					  struct netdev_queue *txq,
+					  void *_unused)
 {
 	lockdep_set_class(&txq->_xmit_lock,
 			  &macvlan_netdev_xmit_lock_key);
@@ -293,7 +295,7 @@ static void macvlan_set_lockdep_class_one(struct netdev_queue *txq)
 
 static void macvlan_set_lockdep_class(struct net_device *dev)
 {
-	macvlan_set_lockdep_class_one(&dev->tx_queue);
+	netdev_for_each_tx_queue(dev, macvlan_set_lockdep_class_one, NULL);
 }
 
 static int macvlan_init(struct net_device *dev)
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index c1f4bb0..13d5882 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -3102,7 +3102,9 @@ static void prism2_clear_set_tim_queue(local_info_t *local)
  */
 static struct lock_class_key hostap_netdev_xmit_lock_key;
 
-static void prism2_set_lockdep_class_one(struct netdev_queue *txq)
+static void prism2_set_lockdep_class_one(struct net_device *dev,
+					 struct netdev_queue *txq,
+					 void *_unused)
 {
 	lockdep_set_class(&txq->_xmit_lock,
 			  &hostap_netdev_xmit_lock_key);
@@ -3110,7 +3112,7 @@ static void prism2_set_lockdep_class_one(struct netdev_queue *txq)
 
 static void prism2_set_lockdep_class(struct net_device *dev)
 {
-	prism2_set_lockdep_class_one(&dev->tx_queue);
+	netdev_for_each_tx_queue(dev, prism2_set_lockdep_class_one, NULL);
 }
 
 static struct net_device *
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 570cf7a..f25d4f5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -463,7 +463,7 @@ struct netdev_queue {
 	struct Qdisc		*qdisc_sleeping;
 	struct list_head	qdisc_list;
 	struct netdev_queue	*next_sched;
-};
+} ____cacheline_aligned_in_smp;
 
 /*
  *	The DEVICE structure.
@@ -641,7 +641,9 @@ struct net_device
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 
 	struct netdev_queue	rx_queue;
-	struct netdev_queue	tx_queue ____cacheline_aligned_in_smp;
+
+	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
+	unsigned int		num_tx_queues;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 
 /*
@@ -764,6 +766,25 @@ struct net_device
 #define	NETDEV_ALIGN		32
 #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
+static inline
+struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
+					 unsigned int index)
+{
+	return &dev->_tx[index];
+}
+
+static inline void netdev_for_each_tx_queue(struct net_device *dev,
+					    void (*f)(struct net_device *,
+						      struct netdev_queue *,
+						      void *),
+					    void *arg)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++)
+		f(dev, &dev->_tx[i], arg);
+}
+
 /*
  * Net namespace inlines
  */
@@ -977,7 +998,7 @@ static inline void netif_schedule_queue(struct netdev_queue *txq)
 
 static inline void netif_schedule(struct net_device *dev)
 {
-	netif_schedule_queue(&dev->tx_queue);
+	netif_schedule_queue(netdev_get_tx_queue(dev, 0));
 }
 
 /**
@@ -993,7 +1014,7 @@ static inline void netif_tx_start_queue(struct netdev_queue *dev_queue)
 
 static inline void netif_start_queue(struct net_device *dev)
 {
-	netif_tx_start_queue(&dev->tx_queue);
+	netif_tx_start_queue(netdev_get_tx_queue(dev, 0));
 }
 
 /**
@@ -1017,7 +1038,7 @@ static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
 
 static inline void netif_wake_queue(struct net_device *dev)
 {
-	netif_tx_wake_queue(&dev->tx_queue);
+	netif_tx_wake_queue(netdev_get_tx_queue(dev, 0));
 }
 
 /**
@@ -1034,7 +1055,7 @@ static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
 
 static inline void netif_stop_queue(struct net_device *dev)
 {
-	netif_tx_stop_queue(&dev->tx_queue);
+	netif_tx_stop_queue(netdev_get_tx_queue(dev, 0));
 }
 
 /**
@@ -1050,7 +1071,7 @@ static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
 
 static inline int netif_queue_stopped(const struct net_device *dev)
 {
-	return netif_tx_queue_stopped(&dev->tx_queue);
+	return netif_tx_queue_stopped(netdev_get_tx_queue(dev, 0));
 }
 
 /**
@@ -1134,7 +1155,7 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 #endif
 	if (test_and_clear_bit(__QUEUE_STATE_XOFF,
 			       &dev->egress_subqueue[queue_index].state))
-		__netif_schedule(&dev->tx_queue);
+		__netif_schedule(netdev_get_tx_queue(dev, 0));
 }
 
 /**
@@ -1430,18 +1451,19 @@ static inline void __netif_tx_lock(struct netdev_queue *txq, int cpu)
 
 static inline void netif_tx_lock(struct net_device *dev)
 {
-	__netif_tx_lock(&dev->tx_queue, smp_processor_id());
-}
+	int cpu = smp_processor_id();
+	unsigned int i;
 
-static inline void __netif_tx_lock_bh(struct netdev_queue *txq)
-{
-	spin_lock_bh(&txq->_xmit_lock);
-	txq->xmit_lock_owner = smp_processor_id();
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		__netif_tx_lock(txq, cpu);
+	}
 }
 
 static inline void netif_tx_lock_bh(struct net_device *dev)
 {
-	__netif_tx_lock_bh(&dev->tx_queue);
+	local_bh_disable();
+	netif_tx_lock(dev);
 }
 
 static inline int __netif_tx_trylock(struct netdev_queue *txq)
@@ -1454,7 +1476,7 @@ static inline int __netif_tx_trylock(struct netdev_queue *txq)
 
 static inline int netif_tx_trylock(struct net_device *dev)
 {
-	return __netif_tx_trylock(&dev->tx_queue);
+	return __netif_tx_trylock(netdev_get_tx_queue(dev, 0));
 }
 
 static inline void __netif_tx_unlock(struct netdev_queue *txq)
@@ -1465,18 +1487,19 @@ static inline void __netif_tx_unlock(struct netdev_queue *txq)
 
 static inline void netif_tx_unlock(struct net_device *dev)
 {
-	__netif_tx_unlock(&dev->tx_queue);
-}
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		__netif_tx_unlock(txq);
+	}
 
-static inline void __netif_tx_unlock_bh(struct netdev_queue *txq)
-{
-	txq->xmit_lock_owner = -1;
-	spin_unlock_bh(&txq->_xmit_lock);
 }
 
 static inline void netif_tx_unlock_bh(struct net_device *dev)
 {
-	__netif_tx_unlock_bh(&dev->tx_queue);
+	netif_tx_unlock(dev);
+	local_bh_enable();
 }
 
 #define HARD_TX_LOCK(dev, txq, cpu) {			\
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 5ba66b5..b47f556 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -230,32 +230,47 @@ extern void tcf_destroy_chain(struct tcf_proto **fl);
 /* Reset all TX qdiscs of a device.  */
 static inline void qdisc_reset_all_tx(struct net_device *dev)
 {
-	qdisc_reset(dev->tx_queue.qdisc);
+	unsigned int i;
+	for (i = 0; i < dev->num_tx_queues; i++)
+		qdisc_reset(netdev_get_tx_queue(dev, i)->qdisc);
 }
 
 /* Are all TX queues of the device empty?  */
 static inline bool qdisc_all_tx_empty(const struct net_device *dev)
 {
-	const struct netdev_queue *txq = &dev->tx_queue;
-	const struct Qdisc *q = txq->qdisc;
+	unsigned int i;
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		const struct Qdisc *q = txq->qdisc;
 
-	return (q->q.qlen == 0);
+		if (q->q.qlen)
+			return false;
+	}
+	return true;
 }
 
 /* Are any of the TX qdiscs changing?  */
 static inline bool qdisc_tx_changing(struct net_device *dev)
 {
-	struct netdev_queue *txq = &dev->tx_queue;
-
-	return (txq->qdisc != txq->qdisc_sleeping);
+	unsigned int i;
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		if (txq->qdisc != txq->qdisc_sleeping)
+			return true;
+	}
+	return false;
 }
 
-/* Is the device using the noop qdisc?  */
+/* Is the device using the noop qdisc on all queues?  */
 static inline bool qdisc_tx_is_noop(const struct net_device *dev)
 {
-	const struct netdev_queue *txq = &dev->tx_queue;
-
-	return (txq->qdisc == &noop_qdisc);
+	unsigned int i;
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		if (txq->qdisc != &noop_qdisc)
+			return false;
+	}
+	return true;
 }
 
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 6b985f2..f42bc2b 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -570,16 +570,18 @@ static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
  */
 static struct lock_class_key vlan_netdev_xmit_lock_key;
 
-static void vlan_dev_set_lockdep_one(struct netdev_queue *txq,
-				     int subclass)
+static void vlan_dev_set_lockdep_one(struct net_device *dev,
+				     struct netdev_queue *txq,
+				     void *_subclass)
 {
 	lockdep_set_class_and_subclass(&txq->_xmit_lock,
-				       &vlan_netdev_xmit_lock_key, subclass);
+				       &vlan_netdev_xmit_lock_key,
+				       *(int *)_subclass);
 }
 
 static void vlan_dev_set_lockdep_class(struct net_device *dev, int subclass)
 {
-	vlan_dev_set_lockdep_one(&dev->tx_queue, subclass);
+	netdev_for_each_tx_queue(dev, vlan_dev_set_lockdep_one, &subclass);
 }
 
 static const struct header_ops vlan_header_ops = {
diff --git a/net/core/dev.c b/net/core/dev.c
index 9b49f74..69378f2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1666,6 +1666,12 @@ out_kfree_skb:
  *          --BLG
  */
 
+static struct netdev_queue *dev_pick_tx(struct net_device *dev,
+					struct sk_buff *skb)
+{
+	return netdev_get_tx_queue(dev, 0);
+}
+
 int dev_queue_xmit(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
@@ -1702,7 +1708,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 	}
 
 gso:
-	txq = &dev->tx_queue;
+	txq = dev_pick_tx(dev, skb);
 	spin_lock_prefetch(&txq->lock);
 
 	/* Disable soft irqs for various locks below. Also
@@ -3788,8 +3794,9 @@ static void rollback_registered(struct net_device *dev)
 	dev_put(dev);
 }
 
-static void __netdev_init_queue_locks_one(struct netdev_queue *dev_queue,
-					  struct net_device *dev)
+static void __netdev_init_queue_locks_one(struct net_device *dev,
+					  struct netdev_queue *dev_queue,
+					  void *_unused)
 {
 	spin_lock_init(&dev_queue->_xmit_lock);
 	netdev_set_lockdep_class(&dev_queue->_xmit_lock, dev->type);
@@ -3798,8 +3805,8 @@ static void __netdev_init_queue_locks_one(struct netdev_queue *dev_queue,
 
 static void netdev_init_queue_locks(struct net_device *dev)
 {
-	__netdev_init_queue_locks_one(&dev->tx_queue, dev);
-	__netdev_init_queue_locks_one(&dev->rx_queue, dev);
+	netdev_for_each_tx_queue(dev, __netdev_init_queue_locks_one, NULL);
+	__netdev_init_queue_locks_one(dev, &dev->rx_queue, NULL);
 }
 
 /**
@@ -4119,7 +4126,8 @@ static struct net_device_stats *internal_stats(struct net_device *dev)
 }
 
 static void netdev_init_one_queue(struct net_device *dev,
-				  struct netdev_queue *queue)
+				  struct netdev_queue *queue,
+				  void *_unused)
 {
 	spin_lock_init(&queue->lock);
 	queue->dev = dev;
@@ -4127,8 +4135,8 @@ static void netdev_init_one_queue(struct net_device *dev,
 
 static void netdev_init_queues(struct net_device *dev)
 {
-	netdev_init_one_queue(dev, &dev->rx_queue);
-	netdev_init_one_queue(dev, &dev->tx_queue);
+	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
+	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
 }
 
 /**
@@ -4145,9 +4153,10 @@ static void netdev_init_queues(struct net_device *dev)
 struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		void (*setup)(struct net_device *), unsigned int queue_count)
 {
-	void *p;
+	struct netdev_queue *tx;
 	struct net_device *dev;
 	int alloc_size;
+	void *p;
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
@@ -4167,11 +4176,22 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		return NULL;
 	}
 
+	tx = kzalloc(sizeof(struct netdev_queue) * queue_count, GFP_KERNEL);
+	if (!tx) {
+		printk(KERN_ERR "alloc_netdev: Unable to allocate "
+		       "tx qdiscs.\n");
+		kfree(p);
+		return NULL;
+	}
+
 	dev = (struct net_device *)
 		(((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 	dev->padded = (char *)dev - (char *)p;
 	dev_net_set(dev, &init_net);
 
+	dev->_tx = tx;
+	dev->num_tx_queues = queue_count;
+
 	if (sizeof_priv) {
 		dev->priv = ((char *)dev +
 			     ((sizeof(struct net_device) +
@@ -4205,6 +4225,8 @@ void free_netdev(struct net_device *dev)
 {
 	release_net(dev_net(dev));
 
+	kfree(dev->_tx);
+
 	/*  Compatibility with error handling in drivers */
 	if (dev->reg_state == NETREG_UNINITIALIZED) {
 		kfree((char *)dev - dev->padded);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8ef9f1d..71edb8b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -636,7 +636,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (dev->master)
 		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
 
-	txq = &dev->tx_queue;
+	txq = netdev_get_tx_queue(dev, 0);
 	if (txq->qdisc_sleeping)
 		NLA_PUT_STRING(skb, IFLA_QDISC, txq->qdisc_sleeping->ops->id);
 
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index af0056e..b486e63 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -621,7 +621,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 
 	/* ensure that TX flow won't interrupt us
 	 * until the end of the call to requeue function */
-	txq = &local->mdev->tx_queue;
+	txq = netdev_get_tx_queue(local->mdev, 0);
 	spin_lock_bh(&txq->lock);
 
 	/* create a new queue for this aggregation */
@@ -862,7 +862,7 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_hw *hw, u8 *ra, u8 tid)
 
 	/* avoid ordering issues: we are the only one that can modify
 	 * the content of the qdiscs */
-	txq = &local->mdev->tx_queue;
+	txq = netdev_get_tx_queue(local->mdev, 0);
 	spin_lock_bh(&txq->lock);
 	/* remove the queue for this aggregation */
 	ieee80211_ht_agg_queue_remove(local, sta, tid, 1);
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 6ae43a3..f014cd3 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -574,7 +574,7 @@ static struct Qdisc_ops wme_qdisc_ops __read_mostly =
 
 void ieee80211_install_qdisc(struct net_device *dev)
 {
-	struct netdev_queue *txq = &dev->tx_queue;
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
 	struct Qdisc *qdisc;
 
 	qdisc = qdisc_create_dflt(dev, txq,
@@ -596,7 +596,7 @@ void ieee80211_install_qdisc(struct net_device *dev)
 
 int ieee80211_qdisc_installed(struct net_device *dev)
 {
-	struct netdev_queue *txq = &dev->tx_queue;
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
 
 	return txq->qdisc_sleeping->ops == &wme_qdisc_ops;
 }
@@ -617,7 +617,7 @@ int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
 			struct sta_info *sta, u16 tid)
 {
 	int i;
-	struct netdev_queue *txq = &local->mdev->tx_queue;
+	struct netdev_queue *txq = netdev_get_tx_queue(local->mdev, 0);
 	struct ieee80211_sched_data *q =
 			qdisc_priv(txq->qdisc_sleeping);
 	DECLARE_MAC_BUF(mac);
@@ -652,14 +652,14 @@ int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
 }
 
 /**
- * the caller needs to hold local->mdev->tx_queue.lock
+ * the caller needs to hold netdev_get_tx_queue(local->mdev, X)->lock
  */
 void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
 				   struct sta_info *sta, u16 tid,
 				   u8 requeue)
 {
 	struct ieee80211_hw *hw = &local->hw;
-	struct netdev_queue *txq = &local->mdev->tx_queue;
+	struct netdev_queue *txq = netdev_get_tx_queue(local->mdev, 0);
 	struct ieee80211_sched_data *q =
 		qdisc_priv(txq->qdisc_sleeping);
 	int agg_queue = sta->tid_to_tx_q[tid];
@@ -676,7 +676,7 @@ void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
 
 void ieee80211_requeue(struct ieee80211_local *local, int queue)
 {
-	struct netdev_queue *txq = &local->mdev->tx_queue;
+	struct netdev_queue *txq = netdev_get_tx_queue(local->mdev, 0);
 	struct Qdisc *root_qd = txq->qdisc_sleeping;
 	struct ieee80211_sched_data *q = qdisc_priv(root_qd);
 	struct Qdisc *qdisc = q->queues[queue];
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 819afc4..d41be0d 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -74,14 +74,16 @@ static const struct proto_ops nr_proto_ops;
  */
 static struct lock_class_key nr_netdev_xmit_lock_key;
 
-static void nr_set_lockdep_one(struct netdev_queue *txq)
+static void nr_set_lockdep_one(struct net_device *dev,
+			       struct netdev_queue *txq,
+			       void *_unused)
 {
 	lockdep_set_class(&txq->_xmit_lock, &nr_netdev_xmit_lock_key);
 }
 
 static void nr_set_lockdep_key(struct net_device *dev)
 {
-	nr_set_lockdep_one(&dev->tx_queue);
+	netdev_for_each_tx_queue(dev, nr_set_lockdep_one, NULL);
 }
 
 /*
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 7dbbc08..f3a691f 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -75,14 +75,16 @@ ax25_address rose_callsign;
  */
 static struct lock_class_key rose_netdev_xmit_lock_key;
 
-static void rose_set_lockdep_one(struct netdev_queue *txq)
+static void rose_set_lockdep_one(struct net_device *dev,
+				 struct netdev_queue *txq,
+				 void *_unused)
 {
 	lockdep_set_class(&txq->_xmit_lock, &rose_netdev_xmit_lock_key);
 }
 
 static void rose_set_lockdep_key(struct net_device *dev)
 {
-	rose_set_lockdep_one(&dev->tx_queue);
+	netdev_for_each_tx_queue(dev, rose_set_lockdep_one, NULL);
 }
 
 /*
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index b483bbe..d0b0a9b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -166,7 +166,7 @@ replay:
 
 	/* Find qdisc */
 	if (!parent) {
-		struct netdev_queue *dev_queue = &dev->tx_queue;
+		struct netdev_queue *dev_queue = netdev_get_tx_queue(dev, 0);
 		q = dev_queue->qdisc_sleeping;
 		parent = q->handle;
 	} else {
@@ -410,7 +410,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	if ((dev = dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
 		return skb->len;
 
-	dev_queue = &dev->tx_queue;
+	dev_queue = netdev_get_tx_queue(dev, 0);
 	if (!tcm->tcm_parent)
 		q = dev_queue->qdisc_sleeping;
 	else
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 95873f8..830ccc5 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -183,9 +183,8 @@ EXPORT_SYMBOL(unregister_qdisc);
    (root qdisc, all its children, children of children etc.)
  */
 
-struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
+static struct Qdisc *__qdisc_lookup(struct netdev_queue *dev_queue, u32 handle)
 {
-	struct netdev_queue *dev_queue = &dev->tx_queue;
 	struct Qdisc *q;
 
 	list_for_each_entry(q, &dev_queue->qdisc_list, list) {
@@ -195,6 +194,19 @@ struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 	return NULL;
 }
 
+struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		struct Qdisc *q = __qdisc_lookup(txq, handle);
+		if (q)
+			return q;
+	}
+	return NULL;
+}
+
 static struct Qdisc *qdisc_leaf(struct Qdisc *p, u32 classid)
 {
 	unsigned long cl;
@@ -462,7 +474,7 @@ dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
 		}
 
 	} else {
-		dev_queue = &dev->tx_queue;
+		dev_queue = netdev_get_tx_queue(dev, 0);
 		oqdisc = dev_queue->qdisc_sleeping;
 
 		/* Prune old scheduler */
@@ -742,7 +754,8 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 				q = dev->rx_queue.qdisc;
 			}
 		} else {
-			struct netdev_queue *dev_queue = &dev->tx_queue;
+			struct netdev_queue *dev_queue;
+			dev_queue = netdev_get_tx_queue(dev, 0);
 			q = dev_queue->qdisc_sleeping;
 		}
 		if (!q)
@@ -817,7 +830,8 @@ replay:
 				q = dev->rx_queue.qdisc;
 			}
 		} else {
-			struct netdev_queue *dev_queue = &dev->tx_queue;
+			struct netdev_queue *dev_queue;
+			dev_queue = netdev_get_tx_queue(dev, 0);
 			q = dev_queue->qdisc_sleeping;
 		}
 
@@ -899,7 +913,7 @@ create_n_graft:
 				 tcm->tcm_parent, tcm->tcm_parent,
 				 tca, &err);
 	else
-		q = qdisc_create(dev, &dev->tx_queue,
+		q = qdisc_create(dev, netdev_get_tx_queue(dev, 0),
 				 tcm->tcm_parent, tcm->tcm_handle,
 				 tca, &err);
 	if (q == NULL) {
@@ -1025,7 +1039,7 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 		if (idx > s_idx)
 			s_q_idx = 0;
 		q_idx = 0;
-		dev_queue = &dev->tx_queue;
+		dev_queue = netdev_get_tx_queue(dev, 0);
 		list_for_each_entry(q, &dev_queue->qdisc_list, list) {
 			if (q_idx < s_q_idx) {
 				q_idx++;
@@ -1098,7 +1112,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 
 	/* Step 1. Determine qdisc handle X:0 */
 
-	dev_queue = &dev->tx_queue;
+	dev_queue = netdev_get_tx_queue(dev, 0);
 	if (pid != TC_H_ROOT) {
 		u32 qid1 = TC_H_MAJ(pid);
 
@@ -1275,7 +1289,7 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	s_t = cb->args[0];
 	t = 0;
 
-	dev_queue = &dev->tx_queue;
+	dev_queue = netdev_get_tx_queue(dev, 0);
 	list_for_each_entry(q, &dev_queue->qdisc_list, list) {
 		if (t < s_t || !q->ops->cl_ops ||
 		    (tcm->tcm_parent &&
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 243de93..4e2b865 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -40,20 +40,30 @@
  */
 
 void qdisc_lock_tree(struct net_device *dev)
-	__acquires(dev->tx_queue.lock)
 	__acquires(dev->rx_queue.lock)
 {
-	spin_lock_bh(&dev->tx_queue.lock);
+	unsigned int i;
+
+	local_bh_disable();
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		spin_lock(&txq->lock);
+	}
 	spin_lock(&dev->rx_queue.lock);
 }
 EXPORT_SYMBOL(qdisc_lock_tree);
 
 void qdisc_unlock_tree(struct net_device *dev)
 	__releases(dev->rx_queue.lock)
-	__releases(dev->tx_queue.lock)
 {
+	unsigned int i;
+
 	spin_unlock(&dev->rx_queue.lock);
-	spin_unlock_bh(&dev->tx_queue.lock);
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+		spin_unlock(&txq->lock);
+	}
+	local_bh_enable();
 }
 EXPORT_SYMBOL(qdisc_unlock_tree);
 
@@ -212,22 +222,37 @@ void __qdisc_run(struct netdev_queue *txq)
 static void dev_watchdog(unsigned long arg)
 {
 	struct net_device *dev = (struct net_device *)arg;
-	struct netdev_queue *txq = &dev->tx_queue;
 
 	netif_tx_lock(dev);
-	if (txq->qdisc != &noop_qdisc) {
+	if (!qdisc_tx_is_noop(dev)) {
 		if (netif_device_present(dev) &&
 		    netif_running(dev) &&
 		    netif_carrier_ok(dev)) {
-			if (netif_queue_stopped(dev) &&
-			    time_after(jiffies, dev->trans_start + dev->watchdog_timeo)) {
+			int some_queue_stopped = 0;
+			unsigned int i;
+
+			for (i = 0; i < dev->num_tx_queues; i++) {
+				struct netdev_queue *txq;
+
+				txq = netdev_get_tx_queue(dev, i);
+				if (netif_tx_queue_stopped(txq)) {
+					some_queue_stopped = 1;
+					break;
+				}
+			}
 
-				printk(KERN_INFO "NETDEV WATCHDOG: %s: transmit timed out\n",
+			if (some_queue_stopped &&
+			    time_after(jiffies, (dev->trans_start +
+						 dev->watchdog_timeo))) {
+				printk(KERN_INFO "NETDEV WATCHDOG: %s: "
+				       "transmit timed out\n",
 				       dev->name);
 				dev->tx_timeout(dev);
 				WARN_ON_ONCE(1);
 			}
-			if (!mod_timer(&dev->watchdog_timer, round_jiffies(jiffies + dev->watchdog_timeo)))
+			if (!mod_timer(&dev->watchdog_timer,
+				       round_jiffies(jiffies +
+						     dev->watchdog_timeo)))
 				dev_hold(dev);
 		}
 	}
@@ -542,9 +567,55 @@ void qdisc_destroy(struct Qdisc *qdisc)
 }
 EXPORT_SYMBOL(qdisc_destroy);
 
+static bool dev_all_qdisc_sleeping_noop(struct net_device *dev)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
+
+		if (txq->qdisc_sleeping != &noop_qdisc)
+			return false;
+	}
+	return true;
+}
+
+static void attach_one_default_qdisc(struct net_device *dev,
+				     struct netdev_queue *dev_queue,
+				     void *_unused)
+{
+	struct Qdisc *qdisc;
+
+	if (dev->tx_queue_len) {
+		qdisc = qdisc_create_dflt(dev, dev_queue,
+					  &pfifo_fast_ops, TC_H_ROOT);
+		if (!qdisc) {
+			printk(KERN_INFO "%s: activation failed\n", dev->name);
+			return;
+		}
+		list_add_tail(&qdisc->list, &dev_queue->qdisc_list);
+	} else {
+		qdisc =  &noqueue_qdisc;
+	}
+	dev_queue->qdisc_sleeping = qdisc;
+}
+
+static void transition_one_qdisc(struct net_device *dev,
+				 struct netdev_queue *dev_queue,
+				 void *_need_watchdog)
+{
+	int *need_watchdog_p = _need_watchdog;
+
+	spin_lock_bh(&dev_queue->lock);
+	rcu_assign_pointer(dev_queue->qdisc, dev_queue->qdisc_sleeping);
+	if (dev_queue->qdisc != &noqueue_qdisc)
+		*need_watchdog_p = 1;
+	spin_unlock_bh(&dev_queue->lock);
+}
+
 void dev_activate(struct net_device *dev)
 {
-	struct netdev_queue *txq = &dev->tx_queue;
+	int need_watchdog;
 
 	/* No queueing discipline is attached to device;
 	   create default one i.e. pfifo_fast for devices,
@@ -552,39 +623,27 @@ void dev_activate(struct net_device *dev)
 	   virtual interfaces
 	 */
 
-	if (txq->qdisc_sleeping == &noop_qdisc) {
-		struct Qdisc *qdisc;
-		if (dev->tx_queue_len) {
-			qdisc = qdisc_create_dflt(dev, txq,
-						  &pfifo_fast_ops,
-						  TC_H_ROOT);
-			if (qdisc == NULL) {
-				printk(KERN_INFO "%s: activation failed\n", dev->name);
-				return;
-			}
-			list_add_tail(&qdisc->list, &txq->qdisc_list);
-		} else {
-			qdisc =  &noqueue_qdisc;
-		}
-		txq->qdisc_sleeping = qdisc;
-	}
+	if (dev_all_qdisc_sleeping_noop(dev))
+		netdev_for_each_tx_queue(dev, attach_one_default_qdisc, NULL);
 
 	if (!netif_carrier_ok(dev))
 		/* Delay activation until next carrier-on event */
 		return;
 
-	spin_lock_bh(&txq->lock);
-	rcu_assign_pointer(txq->qdisc, txq->qdisc_sleeping);
-	if (txq->qdisc != &noqueue_qdisc) {
+	need_watchdog = 0;
+	netdev_for_each_tx_queue(dev, transition_one_qdisc, &need_watchdog);
+
+	if (need_watchdog) {
 		dev->trans_start = jiffies;
 		dev_watchdog_up(dev);
 	}
-	spin_unlock_bh(&txq->lock);
 }
 
-static void dev_deactivate_queue(struct netdev_queue *dev_queue,
-				 struct Qdisc *qdisc_default)
+static void dev_deactivate_queue(struct net_device *dev,
+				 struct netdev_queue *dev_queue,
+				 void *_qdisc_default)
 {
+	struct Qdisc *qdisc_default = _qdisc_default;
 	struct Qdisc *qdisc;
 	struct sk_buff *skb;
 
@@ -603,12 +662,35 @@ static void dev_deactivate_queue(struct netdev_queue *dev_queue,
 	kfree_skb(skb);
 }
 
+static bool some_qdisc_is_running(struct net_device *dev, int lock)
+{
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		struct netdev_queue *dev_queue;
+		int val;
+
+		dev_queue = netdev_get_tx_queue(dev, i);
+
+		if (lock)
+			spin_lock_bh(&dev_queue->lock);
+
+		val = test_bit(__QUEUE_STATE_QDISC_RUNNING, &dev_queue->state);
+
+		if (lock)
+			spin_unlock_bh(&dev_queue->lock);
+
+		if (val)
+			return true;
+	}
+	return false;
+}
+
 void dev_deactivate(struct net_device *dev)
 {
-	struct netdev_queue *dev_queue = &dev->tx_queue;
-	int running;
+	bool running;
 
-	dev_deactivate_queue(dev_queue, &noop_qdisc);
+	netdev_for_each_tx_queue(dev, dev_deactivate_queue, &noop_qdisc);
 
 	dev_watchdog_down(dev);
 
@@ -617,17 +699,14 @@ void dev_deactivate(struct net_device *dev)
 
 	/* Wait for outstanding qdisc_run calls. */
 	do {
-		while (test_bit(__QUEUE_STATE_QDISC_RUNNING, &dev_queue->state))
+		while (some_qdisc_is_running(dev, 0))
 			yield();
 
 		/*
 		 * Double-check inside queue lock to ensure that all effects
 		 * of the queue run are visible when we return.
 		 */
-		spin_lock_bh(&dev_queue->lock);
-		running = test_bit(__QUEUE_STATE_QDISC_RUNNING,
-				   &dev_queue->state);
-		spin_unlock_bh(&dev_queue->lock);
+		running = some_qdisc_is_running(dev, 1);
 
 		/*
 		 * The running flag should never be set at this point because
@@ -642,8 +721,10 @@ void dev_deactivate(struct net_device *dev)
 
 static void dev_init_scheduler_queue(struct net_device *dev,
 				     struct netdev_queue *dev_queue,
-				     struct Qdisc *qdisc)
+				     void *_qdisc)
 {
+	struct Qdisc *qdisc = _qdisc;
+
 	dev_queue->qdisc = qdisc;
 	dev_queue->qdisc_sleeping = qdisc;
 	INIT_LIST_HEAD(&dev_queue->qdisc_list);
@@ -652,18 +733,19 @@ static void dev_init_scheduler_queue(struct net_device *dev,
 void dev_init_scheduler(struct net_device *dev)
 {
 	qdisc_lock_tree(dev);
-	dev_init_scheduler_queue(dev, &dev->tx_queue, &noop_qdisc);
+	netdev_for_each_tx_queue(dev, dev_init_scheduler_queue, &noop_qdisc);
 	dev_init_scheduler_queue(dev, &dev->rx_queue, NULL);
 	qdisc_unlock_tree(dev);
 
 	setup_timer(&dev->watchdog_timer, dev_watchdog, (unsigned long)dev);
 }
 
-static void dev_shutdown_scheduler_queue(struct net_device *dev,
-					 struct netdev_queue *dev_queue,
-					 struct Qdisc *qdisc_default)
+static void shutdown_scheduler_queue(struct net_device *dev,
+				     struct netdev_queue *dev_queue,
+				     void *_qdisc_default)
 {
 	struct Qdisc *qdisc = dev_queue->qdisc_sleeping;
+	struct Qdisc *qdisc_default = _qdisc_default;
 
 	if (qdisc) {
 		dev_queue->qdisc = qdisc_default;
@@ -676,8 +758,8 @@ static void dev_shutdown_scheduler_queue(struct net_device *dev,
 void dev_shutdown(struct net_device *dev)
 {
 	qdisc_lock_tree(dev);
-	dev_shutdown_scheduler_queue(dev, &dev->tx_queue, &noop_qdisc);
-	dev_shutdown_scheduler_queue(dev, &dev->rx_queue, NULL);
+	netdev_for_each_tx_queue(dev, shutdown_scheduler_queue, &noop_qdisc);
+	shutdown_scheduler_queue(dev, &dev->rx_queue, NULL);
 	BUG_TRAP(!timer_pending(&dev->watchdog_timer));
 	qdisc_unlock_tree(dev);
 }
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 8ac0598..44a2c34 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -111,7 +111,7 @@ teql_dequeue(struct Qdisc* sch)
 	struct sk_buff *skb;
 
 	skb = __skb_dequeue(&dat->q);
-	dat_queue = &dat->m->dev->tx_queue;
+	dat_queue = netdev_get_tx_queue(dat->m->dev, 0);
 	if (skb == NULL) {
 		struct net_device *m = qdisc_dev(dat_queue->qdisc);
 		if (m) {
@@ -155,10 +155,13 @@ teql_destroy(struct Qdisc* sch)
 				if (q == master->slaves) {
 					master->slaves = NEXT_SLAVE(q);
 					if (q == master->slaves) {
+						struct netdev_queue *txq;
+
+						txq = netdev_get_tx_queue(master->dev, 0);
 						master->slaves = NULL;
-						spin_lock_bh(&master->dev->tx_queue.lock);
-						qdisc_reset(master->dev->tx_queue.qdisc);
-						spin_unlock_bh(&master->dev->tx_queue.lock);
+						spin_lock_bh(&txq->lock);
+						qdisc_reset(txq->qdisc);
+						spin_unlock_bh(&txq->lock);
 					}
 				}
 				skb_queue_purge(&dat->q);
@@ -218,7 +221,8 @@ static int teql_qdisc_init(struct Qdisc *sch, struct nlattr *opt)
 static int
 __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *dev)
 {
-	struct teql_sched_data *q = qdisc_priv(dev->tx_queue.qdisc);
+	struct netdev_queue *dev_queue = netdev_get_tx_queue(dev, 0);
+	struct teql_sched_data *q = qdisc_priv(dev_queue->qdisc);
 	struct neighbour *mn = skb->dst->neighbour;
 	struct neighbour *n = q->ncache;
 
@@ -254,7 +258,8 @@ __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *
 static inline int teql_resolve(struct sk_buff *skb,
 			       struct sk_buff *skb_res, struct net_device *dev)
 {
-	if (dev->tx_queue.qdisc == &noop_qdisc)
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
+	if (txq->qdisc == &noop_qdisc)
 		return -ENODEV;
 
 	if (dev->header_ops == NULL ||
@@ -285,8 +290,10 @@ restart:
 
 	do {
 		struct net_device *slave = qdisc_dev(q);
+		struct netdev_queue *slave_txq;
 
-		if (slave->tx_queue.qdisc_sleeping != q)
+		slave_txq = netdev_get_tx_queue(slave, 0);
+		if (slave_txq->qdisc_sleeping != q)
 			continue;
 		if (netif_queue_stopped(slave) ||
 		    __netif_subqueue_stopped(slave, subq) ||
-- 
1.5.6.2.255.gbed62

