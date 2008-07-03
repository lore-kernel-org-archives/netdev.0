From: David Miller <davem@davemloft.net>
Subject: [PATCH 07/39]: netdev: Move rest of qdisc state into struct
 netdev_queue
Date: Thu, 03 Jul 2008 00:03:08 -0700 (PDT)
Message-ID: <20080703.000308.25864187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755541AbYGCHDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:03:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now qdisc, qdisc_sleeping, and qdisc_list also live there.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/i4l/isdn_net.c    |    2 +-
 include/linux/netdevice.h      |   10 +---
 include/net/irda/irda_device.h |    2 +-
 net/core/dev.c                 |    4 +-
 net/core/link_watch.c          |    8 +++-
 net/core/rtnetlink.c           |    6 ++-
 net/ipv6/addrconf.c            |    3 +-
 net/mac80211/wme.c             |   20 ++++++---
 net/sched/cls_api.c            |    7 ++-
 net/sched/sch_api.c            |   34 ++++++++++-----
 net/sched/sch_generic.c        |   90 +++++++++++++++++++++++++---------------
 net/sched/sch_netem.c          |    2 +-
 net/sched/sch_teql.c           |   14 ++++---
 13 files changed, 125 insertions(+), 77 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index ef1a300..457bbd1 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -287,7 +287,7 @@ isdn_net_unbind_channel(isdn_net_local * lp)
 		   BEWARE! This chunk of code cannot be called from hardware
 		   interrupt handler. I hope it is true. --ANK
 		 */
-		qdisc_reset(lp->netdev->dev->qdisc);
+		qdisc_reset(lp->netdev->dev->tx_queue.qdisc);
 	}
 	lp->dialstate = 0;
 	dev->rx_netdev[isdn_dc2minor(lp->isdn_device, lp->isdn_channel)] = NULL;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ec88b46..e1e033b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -451,6 +451,9 @@ static inline void napi_synchronize(const struct napi_struct *n)
 struct netdev_queue {
 	spinlock_t		lock;
 	struct net_device	*dev;
+	struct Qdisc		*qdisc;
+	struct Qdisc		*qdisc_sleeping;
+	struct list_head	qdisc_list;
 };
 
 /*
@@ -634,13 +637,6 @@ struct net_device
 
 	struct Qdisc		*qdisc_ingress;
 
-/*
- * Cache line mostly used on queue transmit path (qdisc)
- */
-	/* device queue lock */
-	struct Qdisc		*qdisc;
-	struct Qdisc		*qdisc_sleeping;
-	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 
 	/* Partially transmitted GSO packet. */
diff --git a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
index f70e9b3..16fbf67 100644
--- a/include/net/irda/irda_device.h
+++ b/include/net/irda/irda_device.h
@@ -223,7 +223,7 @@ int  irda_device_is_receiving(struct net_device *dev);
 /* Interface for internal use */
 static inline int irda_device_txqueue_empty(const struct net_device *dev)
 {
-	return skb_queue_empty(&dev->qdisc->q);
+	return skb_queue_empty(&dev->tx_queue.qdisc->q);
 }
 int  irda_device_set_raw_mode(struct net_device* self, int status);
 struct net_device *alloc_irdadev(int sizeof_priv);
diff --git a/net/core/dev.c b/net/core/dev.c
index 7013562..3ccb6da 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1720,14 +1720,14 @@ gso:
 	 * also serializes access to the device queue.
 	 */
 
-	q = rcu_dereference(dev->qdisc);
+	q = rcu_dereference(txq->qdisc);
 #ifdef CONFIG_NET_CLS_ACT
 	skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
 #endif
 	if (q->enqueue) {
 		/* Grab device queue */
 		spin_lock(&txq->lock);
-		q = dev->qdisc;
+		q = txq->qdisc;
 		if (q->enqueue) {
 			/* reset queue_mapping to zero */
 			skb_set_queue_mapping(skb, 0);
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index a5e372b..5021821 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -79,8 +79,10 @@ static void rfc2863_policy(struct net_device *dev)
 
 static int linkwatch_urgent_event(struct net_device *dev)
 {
+	struct netdev_queue *txq = &dev->tx_queue;
+
 	return netif_running(dev) && netif_carrier_ok(dev) &&
-	       dev->qdisc != dev->qdisc_sleeping;
+	       txq->qdisc != txq->qdisc_sleeping;
 }
 
 
@@ -181,7 +183,9 @@ static void __linkwatch_run_queue(int urgent_only)
 		rfc2863_policy(dev);
 		if (dev->flags & IFF_UP) {
 			if (netif_carrier_ok(dev)) {
-				WARN_ON(dev->qdisc_sleeping == &noop_qdisc);
+				struct netdev_queue *txq = &dev->tx_queue;
+
+				WARN_ON(txq->qdisc_sleeping == &noop_qdisc);
 				dev_activate(dev);
 			} else
 				dev_deactivate(dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 6c8d7f0..8ef9f1d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -605,6 +605,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags)
 {
+	struct netdev_queue *txq;
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
 	struct net_device_stats *stats;
@@ -635,8 +636,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (dev->master)
 		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
 
-	if (dev->qdisc_sleeping)
-		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc_sleeping->ops->id);
+	txq = &dev->tx_queue;
+	if (txq->qdisc_sleeping)
+		NLA_PUT_STRING(skb, IFLA_QDISC, txq->qdisc_sleeping->ops->id);
 
 	if (1) {
 		struct rtnl_link_ifmap map = {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 84127d8..e6acb89 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -226,7 +226,8 @@ const struct in6_addr in6addr_linklocal_allrouters = IN6ADDR_LINKLOCAL_ALLROUTER
 /* Check if a valid qdisc is available */
 static inline int addrconf_qdisc_ok(struct net_device *dev)
 {
-	return (dev->qdisc != &noop_qdisc);
+	struct netdev_queue *txq = &dev->tx_queue;
+	return (txq->qdisc != &noop_qdisc);
 }
 
 /* Check if a route is valid prefix route */
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 8bd8fa2..811d0de 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -576,9 +576,10 @@ static struct Qdisc_ops wme_qdisc_ops __read_mostly =
 
 void ieee80211_install_qdisc(struct net_device *dev)
 {
+	struct netdev_queue *txq = &dev->tx_queue;
 	struct Qdisc *qdisc;
 
-	qdisc = qdisc_create_dflt(dev, &dev->tx_queue,
+	qdisc = qdisc_create_dflt(dev, txq,
 				  &wme_qdisc_ops, TC_H_ROOT);
 	if (!qdisc) {
 		printk(KERN_ERR "%s: qdisc installation failed\n", dev->name);
@@ -589,15 +590,17 @@ void ieee80211_install_qdisc(struct net_device *dev)
 	qdisc->handle = 0x80010000;
 
 	qdisc_lock_tree(dev);
-	list_add_tail(&qdisc->list, &dev->qdisc_list);
-	dev->qdisc_sleeping = qdisc;
+	list_add_tail(&qdisc->list, &txq->qdisc_list);
+	txq->qdisc_sleeping = qdisc;
 	qdisc_unlock_tree(dev);
 }
 
 
 int ieee80211_qdisc_installed(struct net_device *dev)
 {
-	return dev->qdisc_sleeping->ops == &wme_qdisc_ops;
+	struct netdev_queue *txq = &dev->tx_queue;
+
+	return txq->qdisc_sleeping->ops == &wme_qdisc_ops;
 }
 
 
@@ -616,8 +619,9 @@ int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
 			struct sta_info *sta, u16 tid)
 {
 	int i;
+	struct netdev_queue *txq = &local->mdev->tx_queue;
 	struct ieee80211_sched_data *q =
-			qdisc_priv(local->mdev->qdisc_sleeping);
+			qdisc_priv(txq->qdisc_sleeping);
 	DECLARE_MAC_BUF(mac);
 
 	/* prepare the filter and save it for the SW queue
@@ -657,8 +661,9 @@ void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
 				   u8 requeue)
 {
 	struct ieee80211_hw *hw = &local->hw;
+	struct netdev_queue *txq = &local->mdev->tx_queue;
 	struct ieee80211_sched_data *q =
-		qdisc_priv(local->mdev->qdisc_sleeping);
+		qdisc_priv(txq->qdisc_sleeping);
 	int agg_queue = sta->tid_to_tx_q[tid];
 
 	/* return the qdisc to the pool */
@@ -673,7 +678,8 @@ void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
 
 void ieee80211_requeue(struct ieee80211_local *local, int queue)
 {
-	struct Qdisc *root_qd = local->mdev->qdisc_sleeping;
+	struct netdev_queue *txq = &local->mdev->tx_queue;
+	struct Qdisc *root_qd = txq->qdisc_sleeping;
 	struct ieee80211_sched_data *q = qdisc_priv(root_qd);
 	struct Qdisc *qdisc = q->queues[queue];
 	struct sk_buff *skb = NULL;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index e2389f1..b483bbe 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -166,7 +166,8 @@ replay:
 
 	/* Find qdisc */
 	if (!parent) {
-		q = dev->qdisc_sleeping;
+		struct netdev_queue *dev_queue = &dev->tx_queue;
+		q = dev_queue->qdisc_sleeping;
 		parent = q->handle;
 	} else {
 		q = qdisc_lookup(dev, TC_H_MAJ(t->tcm_parent));
@@ -390,6 +391,7 @@ static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
 static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
+	struct netdev_queue *dev_queue;
 	int t;
 	int s_t;
 	struct net_device *dev;
@@ -408,8 +410,9 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	if ((dev = dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
 		return skb->len;
 
+	dev_queue = &dev->tx_queue;
 	if (!tcm->tcm_parent)
-		q = dev->qdisc_sleeping;
+		q = dev_queue->qdisc_sleeping;
 	else
 		q = qdisc_lookup(dev, TC_H_MAJ(tcm->tcm_parent));
 	if (!q)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c33e65a..4a51729 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -185,9 +185,10 @@ EXPORT_SYMBOL(unregister_qdisc);
 
 struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 {
+	struct netdev_queue *dev_queue = &dev->tx_queue;
 	struct Qdisc *q;
 
-	list_for_each_entry(q, &dev->qdisc_list, list) {
+	list_for_each_entry(q, &dev_queue->qdisc_list, list) {
 		if (q->handle == handle)
 			return q;
 	}
@@ -337,6 +338,7 @@ static u32 qdisc_alloc_handle(struct net_device *dev)
 static struct Qdisc *
 dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
 {
+	struct netdev_queue *dev_queue;
 	struct Qdisc *oqdisc;
 
 	if (dev->flags & IFF_UP)
@@ -355,8 +357,8 @@ dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
 		}
 
 	} else {
-
-		oqdisc = dev->qdisc_sleeping;
+		dev_queue = &dev->tx_queue;
+		oqdisc = dev_queue->qdisc_sleeping;
 
 		/* Prune old scheduler */
 		if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
@@ -365,8 +367,8 @@ dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
 		/* ... and graft new one */
 		if (qdisc == NULL)
 			qdisc = &noop_qdisc;
-		dev->qdisc_sleeping = qdisc;
-		dev->qdisc = &noop_qdisc;
+		dev_queue->qdisc_sleeping = qdisc;
+		dev_queue->qdisc = &noop_qdisc;
 	}
 
 	qdisc_unlock_tree(dev);
@@ -529,7 +531,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			}
 		}
 		qdisc_lock_tree(dev);
-		list_add_tail(&sch->list, &dev->qdisc_list);
+		list_add_tail(&sch->list, &dev_queue->qdisc_list);
 		qdisc_unlock_tree(dev);
 
 		return sch;
@@ -636,7 +638,8 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 				q = dev->qdisc_ingress;
 			}
 		} else {
-			q = dev->qdisc_sleeping;
+			struct netdev_queue *dev_queue = &dev->tx_queue;
+			q = dev_queue->qdisc_sleeping;
 		}
 		if (!q)
 			return -ENOENT;
@@ -710,7 +713,8 @@ replay:
 				q = dev->qdisc_ingress;
 			}
 		} else {
-			q = dev->qdisc_sleeping;
+			struct netdev_queue *dev_queue = &dev->tx_queue;
+			q = dev_queue->qdisc_sleeping;
 		}
 
 		/* It may be default qdisc, ignore it */
@@ -911,12 +915,14 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 	read_lock(&dev_base_lock);
 	idx = 0;
 	for_each_netdev(&init_net, dev) {
+		struct netdev_queue *dev_queue;
 		if (idx < s_idx)
 			goto cont;
 		if (idx > s_idx)
 			s_q_idx = 0;
 		q_idx = 0;
-		list_for_each_entry(q, &dev->qdisc_list, list) {
+		dev_queue = &dev->tx_queue;
+		list_for_each_entry(q, &dev_queue->qdisc_list, list) {
 			if (q_idx < s_q_idx) {
 				q_idx++;
 				continue;
@@ -950,6 +956,7 @@ done:
 static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
+	struct netdev_queue *dev_queue;
 	struct tcmsg *tcm = NLMSG_DATA(n);
 	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
@@ -987,6 +994,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 
 	/* Step 1. Determine qdisc handle X:0 */
 
+	dev_queue = &dev->tx_queue;
 	if (pid != TC_H_ROOT) {
 		u32 qid1 = TC_H_MAJ(pid);
 
@@ -997,7 +1005,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		} else if (qid1) {
 			qid = qid1;
 		} else if (qid == 0)
-			qid = dev->qdisc_sleeping->handle;
+			qid = dev_queue->qdisc_sleeping->handle;
 
 		/* Now qid is genuine qdisc handle consistent
 		   both with parent and child.
@@ -1008,7 +1016,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 			pid = TC_H_MAKE(qid, pid);
 	} else {
 		if (qid == 0)
-			qid = dev->qdisc_sleeping->handle;
+			qid = dev_queue->qdisc_sleeping->handle;
 	}
 
 	/* OK. Locate qdisc */
@@ -1144,6 +1152,7 @@ static int qdisc_class_dump(struct Qdisc *q, unsigned long cl, struct qdisc_walk
 static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
+	struct netdev_queue *dev_queue;
 	int t;
 	int s_t;
 	struct net_device *dev;
@@ -1162,7 +1171,8 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	s_t = cb->args[0];
 	t = 0;
 
-	list_for_each_entry(q, &dev->qdisc_list, list) {
+	dev_queue = &dev->tx_queue;
+	list_for_each_entry(q, &dev_queue->qdisc_list, list) {
 		if (t < s_t || !q->ops->cl_ops ||
 		    (tcm->tcm_parent &&
 		     TC_H_MAJ(tcm->tcm_parent) != q->handle)) {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 804d44b..da709d1 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -122,7 +122,7 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
  *
  * __LINK_STATE_QDISC_RUNNING guarantees only one CPU can process this
  * device at a time. queue->lock serializes queue accesses for
- * this device AND dev->qdisc pointer itself.
+ * this device AND dev_queue->qdisc pointer itself.
  *
  *  netif_tx_lock serializes accesses to device driver.
  *
@@ -138,7 +138,8 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
  */
 static inline int qdisc_restart(struct net_device *dev)
 {
-	struct Qdisc *q = dev->qdisc;
+	struct netdev_queue *dev_queue = &dev->tx_queue;
+	struct Qdisc *q = dev_queue->qdisc;
 	struct sk_buff *skb;
 	int ret = NETDEV_TX_BUSY;
 
@@ -148,15 +149,15 @@ static inline int qdisc_restart(struct net_device *dev)
 
 
 	/* And release queue */
-	spin_unlock(&q->dev_queue->lock);
+	spin_unlock(&dev_queue->lock);
 
 	HARD_TX_LOCK(dev, smp_processor_id());
 	if (!netif_subqueue_stopped(dev, skb))
 		ret = dev_hard_start_xmit(skb, dev);
 	HARD_TX_UNLOCK(dev);
 
-	spin_lock(&q->dev_queue->lock);
-	q = dev->qdisc;
+	spin_lock(&dev_queue->lock);
+	q = dev_queue->qdisc;
 
 	switch (ret) {
 	case NETDEV_TX_OK:
@@ -207,9 +208,10 @@ void __qdisc_run(struct net_device *dev)
 static void dev_watchdog(unsigned long arg)
 {
 	struct net_device *dev = (struct net_device *)arg;
+	struct netdev_queue *dev_queue = &dev->tx_queue;
 
 	netif_tx_lock(dev);
-	if (dev->qdisc != &noop_qdisc) {
+	if (dev_queue->qdisc != &noop_qdisc) {
 		if (netif_device_present(dev) &&
 		    netif_running(dev) &&
 		    netif_carrier_ok(dev)) {
@@ -539,53 +541,63 @@ EXPORT_SYMBOL(qdisc_destroy);
 
 void dev_activate(struct net_device *dev)
 {
+	struct netdev_queue *dev_queue = &dev->tx_queue;
+
 	/* No queueing discipline is attached to device;
 	   create default one i.e. pfifo_fast for devices,
 	   which need queueing and noqueue_qdisc for
 	   virtual interfaces
 	 */
 
-	if (dev->qdisc_sleeping == &noop_qdisc) {
+	if (dev_queue->qdisc_sleeping == &noop_qdisc) {
 		struct Qdisc *qdisc;
 		if (dev->tx_queue_len) {
-			qdisc = qdisc_create_dflt(dev, &dev->tx_queue,
+			qdisc = qdisc_create_dflt(dev, dev_queue,
 						  &pfifo_fast_ops,
 						  TC_H_ROOT);
 			if (qdisc == NULL) {
 				printk(KERN_INFO "%s: activation failed\n", dev->name);
 				return;
 			}
-			list_add_tail(&qdisc->list, &dev->qdisc_list);
+			list_add_tail(&qdisc->list, &dev_queue->qdisc_list);
 		} else {
 			qdisc =  &noqueue_qdisc;
 		}
-		dev->qdisc_sleeping = qdisc;
+		dev_queue->qdisc_sleeping = qdisc;
 	}
 
 	if (!netif_carrier_ok(dev))
 		/* Delay activation until next carrier-on event */
 		return;
 
-	spin_lock_bh(&dev->tx_queue.lock);
-	rcu_assign_pointer(dev->qdisc, dev->qdisc_sleeping);
-	if (dev->qdisc != &noqueue_qdisc) {
+	spin_lock_bh(&dev_queue->lock);
+	rcu_assign_pointer(dev_queue->qdisc, dev_queue->qdisc_sleeping);
+	if (dev_queue->qdisc != &noqueue_qdisc) {
 		dev->trans_start = jiffies;
 		dev_watchdog_up(dev);
 	}
-	spin_unlock_bh(&dev->tx_queue.lock);
+	spin_unlock_bh(&dev_queue->lock);
+}
+
+static void dev_deactivate_queue(struct net_device *dev,
+				 struct netdev_queue *dev_queue,
+				 struct Qdisc *qdisc_default)
+{
+	struct Qdisc *qdisc = dev_queue->qdisc;
+
+	if (qdisc) {
+		dev_queue->qdisc = qdisc_default;
+		qdisc_reset(qdisc);
+	}
 }
 
 void dev_deactivate(struct net_device *dev)
 {
-	struct Qdisc *qdisc;
 	struct sk_buff *skb;
 	int running;
 
 	spin_lock_bh(&dev->tx_queue.lock);
-	qdisc = dev->qdisc;
-	dev->qdisc = &noop_qdisc;
-
-	qdisc_reset(qdisc);
+	dev_deactivate_queue(dev, &dev->tx_queue, &noop_qdisc);
 
 	skb = dev->gso_skb;
 	dev->gso_skb = NULL;
@@ -622,32 +634,44 @@ void dev_deactivate(struct net_device *dev)
 	} while (WARN_ON_ONCE(running));
 }
 
+static void dev_init_scheduler_queue(struct net_device *dev,
+				     struct netdev_queue *dev_queue,
+				     struct Qdisc *qdisc)
+{
+	dev_queue->qdisc = qdisc;
+	dev_queue->qdisc_sleeping = qdisc;
+	INIT_LIST_HEAD(&dev_queue->qdisc_list);
+}
+
 void dev_init_scheduler(struct net_device *dev)
 {
 	qdisc_lock_tree(dev);
-	dev->qdisc = &noop_qdisc;
-	dev->qdisc_sleeping = &noop_qdisc;
-	INIT_LIST_HEAD(&dev->qdisc_list);
+	dev_init_scheduler_queue(dev, &dev->tx_queue, &noop_qdisc);
+	dev_init_scheduler_queue(dev, &dev->rx_queue, NULL);
 	qdisc_unlock_tree(dev);
 
 	setup_timer(&dev->watchdog_timer, dev_watchdog, (unsigned long)dev);
 }
 
-void dev_shutdown(struct net_device *dev)
+static void dev_shutdown_scheduler_queue(struct net_device *dev,
+					 struct netdev_queue *dev_queue,
+					 struct Qdisc *qdisc_default)
 {
-	struct Qdisc *qdisc;
+	struct Qdisc *qdisc = dev_queue->qdisc_sleeping;
+
+	if (qdisc) {
+		dev_queue->qdisc = qdisc_default;
+		dev_queue->qdisc_sleeping = qdisc_default;
 
-	qdisc_lock_tree(dev);
-	qdisc = dev->qdisc_sleeping;
-	dev->qdisc = &noop_qdisc;
-	dev->qdisc_sleeping = &noop_qdisc;
-	qdisc_destroy(qdisc);
-#if defined(CONFIG_NET_SCH_INGRESS) || defined(CONFIG_NET_SCH_INGRESS_MODULE)
-	if ((qdisc = dev->qdisc_ingress) != NULL) {
-		dev->qdisc_ingress = NULL;
 		qdisc_destroy(qdisc);
 	}
-#endif
+}
+
+void dev_shutdown(struct net_device *dev)
+{
+	qdisc_lock_tree(dev);
+	dev_shutdown_scheduler_queue(dev, &dev->tx_queue, &noop_qdisc);
+	dev_shutdown_scheduler_queue(dev, &dev->rx_queue, NULL);
 	BUG_TRAP(!timer_pending(&dev->watchdog_timer));
 	qdisc_unlock_tree(dev);
 }
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index cf04cd6..4439aea 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -180,7 +180,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	 * skb will be queued.
 	 */
 	if (count > 1 && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL) {
-		struct Qdisc *rootq = qdisc_dev(sch)->qdisc;
+		struct Qdisc *rootq = qdisc_dev(sch)->tx_queue.qdisc;
 		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
 		q->duplicate = 0;
 
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 4f3054e..8ac0598 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -107,17 +107,19 @@ static struct sk_buff *
 teql_dequeue(struct Qdisc* sch)
 {
 	struct teql_sched_data *dat = qdisc_priv(sch);
+	struct netdev_queue *dat_queue;
 	struct sk_buff *skb;
 
 	skb = __skb_dequeue(&dat->q);
+	dat_queue = &dat->m->dev->tx_queue;
 	if (skb == NULL) {
-		struct net_device *m = qdisc_dev(dat->m->dev->qdisc);
+		struct net_device *m = qdisc_dev(dat_queue->qdisc);
 		if (m) {
 			dat->m->slaves = sch;
 			netif_wake_queue(m);
 		}
 	}
-	sch->q.qlen = dat->q.qlen + dat->m->dev->qdisc->q.qlen;
+	sch->q.qlen = dat->q.qlen + dat_queue->qdisc->q.qlen;
 	return skb;
 }
 
@@ -155,7 +157,7 @@ teql_destroy(struct Qdisc* sch)
 					if (q == master->slaves) {
 						master->slaves = NULL;
 						spin_lock_bh(&master->dev->tx_queue.lock);
-						qdisc_reset(master->dev->qdisc);
+						qdisc_reset(master->dev->tx_queue.qdisc);
 						spin_unlock_bh(&master->dev->tx_queue.lock);
 					}
 				}
@@ -216,7 +218,7 @@ static int teql_qdisc_init(struct Qdisc *sch, struct nlattr *opt)
 static int
 __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *dev)
 {
-	struct teql_sched_data *q = qdisc_priv(dev->qdisc);
+	struct teql_sched_data *q = qdisc_priv(dev->tx_queue.qdisc);
 	struct neighbour *mn = skb->dst->neighbour;
 	struct neighbour *n = q->ncache;
 
@@ -252,7 +254,7 @@ __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *
 static inline int teql_resolve(struct sk_buff *skb,
 			       struct sk_buff *skb_res, struct net_device *dev)
 {
-	if (dev->qdisc == &noop_qdisc)
+	if (dev->tx_queue.qdisc == &noop_qdisc)
 		return -ENODEV;
 
 	if (dev->header_ops == NULL ||
@@ -284,7 +286,7 @@ restart:
 	do {
 		struct net_device *slave = qdisc_dev(q);
 
-		if (slave->qdisc_sleeping != q)
+		if (slave->tx_queue.qdisc_sleeping != q)
 			continue;
 		if (netif_queue_stopped(slave) ||
 		    __netif_subqueue_stopped(slave, subq) ||
-- 
1.5.6

