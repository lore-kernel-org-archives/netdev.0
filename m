From: David Miller <davem@davemloft.net>
Subject: [PATCH 20/39]: netdev: Move _xmit_lock and xmit_lock_owner into
 netdev_queue.
Date: Thu, 03 Jul 2008 00:04:18 -0700 (PDT)
Message-ID: <20080703.000418.48183683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50602
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757853AbYGCHET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:04:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Accesses are mostly structured such that when there are multiple
TX queues the code transformations will be a little bit simpler.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/bonding/bond_main.c         |   13 ++++++-
 drivers/net/hamradio/bpqether.c         |   12 +++++-
 drivers/net/macvlan.c                   |   14 ++++++-
 drivers/net/wireless/hostap/hostap_hw.c |   12 +++++-
 include/linux/netdevice.h               |   62 +++++++++++++++++++-----------
 net/8021q/vlan_dev.c                    |   15 ++++++-
 net/core/dev.c                          |   28 ++++++++++----
 net/netrom/af_netrom.c                  |   12 +++++-
 net/rose/af_rose.c                      |   12 +++++-
 net/sched/sch_generic.c                 |    9 ++--
 10 files changed, 145 insertions(+), 44 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d57b65d..3f4d87e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5019,6 +5019,17 @@ static int bond_check_params(struct bond_params *params)
 
 static struct lock_class_key bonding_netdev_xmit_lock_key;
 
+static void bond_set_lockdep_class_one(struct netdev_queue *dev_queue)
+{
+	lockdep_set_class(&dev_queue->_xmit_lock,
+			  &bonding_netdev_xmit_lock_key);
+}
+
+static void bond_set_lockdep_class(struct net_device *dev)
+{
+	bond_set_lockdep_class_one(&dev->tx_queue);
+}
+
 /* Create a new bond based on the specified name and bonding parameters.
  * If name is NULL, obtain a suitable "bond%d" name for us.
  * Caller must NOT hold rtnl_lock; we need to release it here before we
@@ -5076,7 +5087,7 @@ int bond_create(char *name, struct bond_params *params)
 		goto out_bond;
 	}
 
-	lockdep_set_class(&bond_dev->_xmit_lock, &bonding_netdev_xmit_lock_key);
+	bond_set_lockdep_class(bond_dev);
 
 	netif_carrier_off(bond_dev);
 
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 5f4b4c6..b20acb0 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -124,6 +124,16 @@ static LIST_HEAD(bpq_devices);
  */
 static struct lock_class_key bpq_netdev_xmit_lock_key;
 
+static void bpq_set_lockdep_class_one(struct netdev_queue *dev_queue)
+{
+	lockdep_set_class(&dev_queue->_xmit_lock, &bpq_netdev_xmit_lock_key);
+}
+
+static void bpq_set_lockdep_class(struct net_device *dev)
+{
+	bpq_set_lockdep_class_one(&dev->tx_queue);
+}
+
 /* ------------------------------------------------------------------------ */
 
 
@@ -523,7 +533,7 @@ static int bpq_new_device(struct net_device *edev)
 	err = register_netdevice(ndev);
 	if (err)
 		goto error;
-	lockdep_set_class(&ndev->_xmit_lock, &bpq_netdev_xmit_lock_key);
+	bpq_set_lockdep_class(ndev);
 
 	/* List protected by RTNL */
 	list_add_rcu(&bpq->bpq_list, &bpq_devices);
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index c36a03a..42c463d 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -277,6 +277,17 @@ static struct lock_class_key macvlan_netdev_xmit_lock_key;
 #define MACVLAN_STATE_MASK \
 	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
 
+static void macvlan_set_lockdep_class_one(struct netdev_queue *dev_queue)
+{
+	lockdep_set_class(&dev_queue->_xmit_lock,
+			  &macvlan_netdev_xmit_lock_key);
+}
+
+static void macvlan_set_lockdep_class(struct net_device *dev)
+{
+	macvlan_set_lockdep_class_one(&dev->tx_queue);
+}
+
 static int macvlan_init(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
@@ -287,7 +298,8 @@ static int macvlan_init(struct net_device *dev)
 	dev->features 		= lowerdev->features & MACVLAN_FEATURES;
 	dev->iflink		= lowerdev->ifindex;
 
-	lockdep_set_class(&dev->_xmit_lock, &macvlan_netdev_xmit_lock_key);
+	macvlan_set_lockdep_class(dev);
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index cdf90c4..76fa737 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -3102,6 +3102,16 @@ static void prism2_clear_set_tim_queue(local_info_t *local)
  */
 static struct lock_class_key hostap_netdev_xmit_lock_key;
 
+static void prism2_set_lockdep_class_one(struct netdev_queue *dev_queue)
+{
+	lockdep_set_class(&dev_queue->_xmit_lock,
+			  &hostap_netdev_xmit_lock_key);
+}
+
+static void prism2_set_lockdep_class(struct net_device *dev)
+{
+	prism2_set_lockdep_class_one(&dev->tx_queue);
+}
 
 static struct net_device *
 prism2_init_local_data(struct prism2_helper_functions *funcs, int card_idx,
@@ -3267,7 +3277,7 @@ while (0)
 	if (ret >= 0)
 		ret = register_netdevice(dev);
 
-	lockdep_set_class(&dev->_xmit_lock, &hostap_netdev_xmit_lock_key);
+	prism2_set_lockdep_class(dev);
 	rtnl_unlock();
 	if (ret < 0) {
 		printk(KERN_WARNING "%s: register netdevice failed!\n",
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 140638c..f5f8bb6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -453,6 +453,8 @@ struct netdev_queue {
 	struct net_device	*dev;
 	struct Qdisc		*qdisc;
 	struct sk_buff		*gso_skb;
+	spinlock_t		_xmit_lock;
+	int			xmit_lock_owner;
 	struct Qdisc		*qdisc_sleeping;
 	struct list_head	qdisc_list;
 	struct netdev_queue	*next_sched;
@@ -639,12 +641,6 @@ struct net_device
 /*
  * One part is mostly used on xmit path (device)
  */
-	/* hard_start_xmit synchronizer */
-	spinlock_t		_xmit_lock ____cacheline_aligned_in_smp;
-	/* cpu id of processor entered to hard_start_xmit or -1,
-	   if nobody entered there.
-	 */
-	int			xmit_lock_owner;
 	void			*priv;	/* pointer to private data	*/
 	int			(*hard_start_xmit) (struct sk_buff *skb,
 						    struct net_device *dev);
@@ -1400,52 +1396,72 @@ static inline void netif_rx_complete(struct net_device *dev,
  *
  * Get network device transmit lock
  */
-static inline void __netif_tx_lock(struct net_device *dev, int cpu)
+static inline void __netif_tx_lock(struct netdev_queue *dev_queue, int cpu)
 {
-	spin_lock(&dev->_xmit_lock);
-	dev->xmit_lock_owner = cpu;
+	spin_lock(&dev_queue->_xmit_lock);
+	dev_queue->xmit_lock_owner = cpu;
 }
 
 static inline void netif_tx_lock(struct net_device *dev)
 {
-	__netif_tx_lock(dev, smp_processor_id());
+	__netif_tx_lock(&dev->tx_queue, smp_processor_id());
+}
+
+static inline void __netif_tx_lock_bh(struct netdev_queue *dev_queue)
+{
+	spin_lock_bh(&dev_queue->_xmit_lock);
+	dev_queue->xmit_lock_owner = smp_processor_id();
 }
 
 static inline void netif_tx_lock_bh(struct net_device *dev)
 {
-	spin_lock_bh(&dev->_xmit_lock);
-	dev->xmit_lock_owner = smp_processor_id();
+	__netif_tx_lock_bh(&dev->tx_queue);
 }
 
-static inline int netif_tx_trylock(struct net_device *dev)
+static inline int __netif_tx_trylock(struct netdev_queue *dev_queue)
 {
-	int ok = spin_trylock(&dev->_xmit_lock);
+	int ok = spin_trylock(&dev_queue->_xmit_lock);
 	if (likely(ok))
-		dev->xmit_lock_owner = smp_processor_id();
+		dev_queue->xmit_lock_owner = smp_processor_id();
 	return ok;
 }
 
+static inline int netif_tx_trylock(struct net_device *dev)
+{
+	return __netif_tx_trylock(&dev->tx_queue);
+}
+
+static inline void __netif_tx_unlock(struct netdev_queue *dev_queue)
+{
+	dev_queue->xmit_lock_owner = -1;
+	spin_unlock(&dev_queue->_xmit_lock);
+}
+
 static inline void netif_tx_unlock(struct net_device *dev)
 {
-	dev->xmit_lock_owner = -1;
-	spin_unlock(&dev->_xmit_lock);
+	__netif_tx_unlock(&dev->tx_queue);
+}
+
+static inline void __netif_tx_unlock_bh(struct netdev_queue *dev_queue)
+{
+	dev_queue->xmit_lock_owner = -1;
+	spin_unlock_bh(&dev_queue->_xmit_lock);
 }
 
 static inline void netif_tx_unlock_bh(struct net_device *dev)
 {
-	dev->xmit_lock_owner = -1;
-	spin_unlock_bh(&dev->_xmit_lock);
+	__netif_tx_unlock_bh(&dev->tx_queue);
 }
 
-#define HARD_TX_LOCK(dev, cpu) {			\
+#define HARD_TX_LOCK(dev, dev_queue, cpu) {		\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
-		__netif_tx_lock(dev, cpu);			\
+		__netif_tx_lock(dev_queue, cpu);	\
 	}						\
 }
 
-#define HARD_TX_UNLOCK(dev) {				\
+#define HARD_TX_UNLOCK(dev, dev_queue) {		\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
-		netif_tx_unlock(dev);			\
+		__netif_tx_unlock(dev_queue);		\
 	}						\
 }
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5d055c2..6ad4a8c 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -645,6 +645,18 @@ static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
  */
 static struct lock_class_key vlan_netdev_xmit_lock_key;
 
+static void vlan_dev_set_lockdep_one(struct netdev_queue *dev_queue,
+				     int subclass)
+{
+	lockdep_set_class_and_subclass(&dev_queue->_xmit_lock,
+				       &vlan_netdev_xmit_lock_key, subclass);
+}
+
+static void vlan_dev_set_lockdep_class(struct net_device *dev, int subclass)
+{
+	vlan_dev_set_lockdep_one(&dev->tx_queue, subclass);
+}
+
 static const struct header_ops vlan_header_ops = {
 	.create	 = vlan_dev_hard_header,
 	.rebuild = vlan_dev_rebuild_header,
@@ -686,8 +698,7 @@ static int vlan_dev_init(struct net_device *dev)
 	if (real_dev->priv_flags & IFF_802_1Q_VLAN)
 		subclass = 1;
 
-	lockdep_set_class_and_subclass(&dev->_xmit_lock,
-				&vlan_netdev_xmit_lock_key, subclass);
+	vlan_dev_set_lockdep_class(dev, subclass);
 	return 0;
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index bb4a724..039ceff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -258,7 +258,7 @@ DEFINE_PER_CPU(struct softnet_data, softnet_data);
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 /*
- * register_netdevice() inits dev->_xmit_lock and sets lockdep class
+ * register_netdevice() inits dev_queue->_xmit_lock and sets lockdep class
  * according to dev->type
  */
 static const unsigned short netdev_lock_type[] =
@@ -1758,19 +1758,19 @@ gso:
 	if (dev->flags & IFF_UP) {
 		int cpu = smp_processor_id(); /* ok because BHs are off */
 
-		if (dev->xmit_lock_owner != cpu) {
+		if (txq->xmit_lock_owner != cpu) {
 
-			HARD_TX_LOCK(dev, cpu);
+			HARD_TX_LOCK(dev, txq, cpu);
 
 			if (!netif_queue_stopped(dev) &&
 			    !netif_subqueue_stopped(dev, skb)) {
 				rc = 0;
 				if (!dev_hard_start_xmit(skb, dev)) {
-					HARD_TX_UNLOCK(dev);
+					HARD_TX_UNLOCK(dev, txq);
 					goto out;
 				}
 			}
-			HARD_TX_UNLOCK(dev);
+			HARD_TX_UNLOCK(dev, txq);
 			if (net_ratelimit())
 				printk(KERN_CRIT "Virtual device %s asks to "
 				       "queue packet!\n", dev->name);
@@ -3761,6 +3761,20 @@ static void rollback_registered(struct net_device *dev)
 	dev_put(dev);
 }
 
+static void __netdev_init_queue_locks_one(struct netdev_queue *dev_queue,
+					  struct net_device *dev)
+{
+	spin_lock_init(&dev_queue->_xmit_lock);
+	netdev_set_lockdep_class(&dev_queue->_xmit_lock, dev->type);
+	dev_queue->xmit_lock_owner = -1;
+}
+
+static void netdev_init_queue_locks(struct net_device *dev)
+{
+	__netdev_init_queue_locks_one(&dev->tx_queue, dev);
+	__netdev_init_queue_locks_one(&dev->rx_queue, dev);
+}
+
 /**
  *	register_netdevice	- register a network device
  *	@dev: device to register
@@ -3795,9 +3809,7 @@ int register_netdevice(struct net_device *dev)
 	BUG_ON(!dev_net(dev));
 	net = dev_net(dev);
 
-	spin_lock_init(&dev->_xmit_lock);
-	netdev_set_lockdep_class(&dev->_xmit_lock, dev->type);
-	dev->xmit_lock_owner = -1;
+	netdev_init_queue_locks(dev);
 
 	dev->iflink = -1;
 
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 74884f4..73d1e14 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -74,6 +74,16 @@ static const struct proto_ops nr_proto_ops;
  */
 static struct lock_class_key nr_netdev_xmit_lock_key;
 
+static void nr_set_lockdep_one(struct netdev_queue *dev_queue)
+{
+	lockdep_set_class(&dev_queue->_xmit_lock, &nr_netdev_xmit_lock_key);
+}
+
+static void nr_set_lockdep_key(struct net_device *dev)
+{
+	nr_set_lockdep_one(&dev->tx_queue);
+}
+
 /*
  *	Socket removal during an interrupt is now safe.
  */
@@ -1430,7 +1440,7 @@ static int __init nr_proto_init(void)
 			free_netdev(dev);
 			goto fail;
 		}
-		lockdep_set_class(&dev->_xmit_lock, &nr_netdev_xmit_lock_key);
+		nr_set_lockdep_key(dev);
 		dev_nr[i] = dev;
 	}
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 46461a6..37046f9 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -75,6 +75,16 @@ ax25_address rose_callsign;
  */
 static struct lock_class_key rose_netdev_xmit_lock_key;
 
+static void rose_set_lockdep_one(struct netdev_queue *dev_queue)
+{
+	lockdep_set_class(&dev_queue->_xmit_lock, &rose_netdev_xmit_lock_key);
+}
+
+static void rose_set_lockdep_key(struct net_device *dev)
+{
+	rose_set_lockdep_one(&dev->tx_queue);
+}
+
 /*
  *	Convert a ROSE address into text.
  */
@@ -1576,7 +1586,7 @@ static int __init rose_proto_init(void)
 			free_netdev(dev);
 			goto fail;
 		}
-		lockdep_set_class(&dev->_xmit_lock, &rose_netdev_xmit_lock_key);
+		rose_set_lockdep_key(dev);
 		dev_rose[i] = dev;
 	}
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 3f3e699..00f4e3e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -92,10 +92,9 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 					   struct netdev_queue *dev_queue,
 					   struct Qdisc *q)
 {
-	struct net_device *dev = dev_queue->dev;
 	int ret;
 
-	if (unlikely(dev->xmit_lock_owner == smp_processor_id())) {
+	if (unlikely(dev_queue->xmit_lock_owner == smp_processor_id())) {
 		/*
 		 * Same CPU holding the lock. It may be a transient
 		 * configuration error, when hard_start_xmit() recurses. We
@@ -105,7 +104,7 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 		kfree_skb(skb);
 		if (net_ratelimit())
 			printk(KERN_WARNING "Dead loop on netdevice %s, "
-			       "fix it urgently!\n", dev->name);
+			       "fix it urgently!\n", dev_queue->dev->name);
 		ret = qdisc_qlen(q);
 	} else {
 		/*
@@ -155,10 +154,10 @@ static inline int qdisc_restart(struct netdev_queue *dev_queue)
 
 	dev = dev_queue->dev;
 
-	HARD_TX_LOCK(dev, smp_processor_id());
+	HARD_TX_LOCK(dev, dev_queue, smp_processor_id());
 	if (!netif_subqueue_stopped(dev, skb))
 		ret = dev_hard_start_xmit(skb, dev);
-	HARD_TX_UNLOCK(dev);
+	HARD_TX_UNLOCK(dev, dev_queue);
 
 	spin_lock(&dev_queue->lock);
 	q = dev_queue->qdisc;
-- 
1.5.6

