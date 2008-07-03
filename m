From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 05/39]: netdev: Move queue_lock into struct netdev_queue.
Date: Thu, 03 Jul 2008 00:02:56 -0700 (PDT)
Message-ID: <20080703.000256.209343548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Matheos.Worku-UdXhSnd/wVw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


The lock is now an attribute of the device queue.

One thing to notice is that "suspicious" places
emerge which will need specific training about
multiple queue handling.  They are so marked with
explicit "netdev->rx_queue" and "netdev->tx_queue"
references.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/net/ifb.c         |    8 ++++----
 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |   33 ++++++++++++++++++++++-----------
 net/mac80211/main.c       |   10 +++++-----
 net/mac80211/wme.c        |    2 +-
 net/sched/sch_api.c       |    2 +-
 net/sched/sch_cbq.c       |    8 ++++----
 net/sched/sch_generic.c   |   40 ++++++++++++++++++++--------------------
 net/sched/sch_hfsc.c      |    4 ++--
 net/sched/sch_htb.c       |   16 ++++++++--------
 net/sched/sch_netem.c     |    4 ++--
 net/sched/sch_teql.c      |    4 ++--
 12 files changed, 72 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index af233b5..bc3de27 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -229,12 +229,12 @@ module_param(numifbs, int, 0);
 MODULE_PARM_DESC(numifbs, "Number of ifb devices");
 
 /*
- * dev_ifb->queue_lock is usually taken after dev->ingress_lock,
+ * dev_ifb->tx_queue.lock is usually taken after dev->ingress_lock,
  * reversely to e.g. qdisc_lock_tree(). It should be safe until
- * ifb doesn't take dev->queue_lock with dev_ifb->ingress_lock.
+ * ifb doesn't take dev->tx_queue.lock with dev_ifb->ingress_lock.
  * But lockdep should know that ifb has different locks from dev.
  */
-static struct lock_class_key ifb_queue_lock_key;
+static struct lock_class_key ifb_tx_queue_lock_key;
 static struct lock_class_key ifb_ingress_lock_key;
 
 
@@ -258,7 +258,7 @@ static int __init ifb_init_one(int index)
 	if (err < 0)
 		goto err;
 
-	lockdep_set_class(&dev_ifb->queue_lock, &ifb_queue_lock_key);
+	lockdep_set_class(&dev_ifb->tx_queue.lock, &ifb_tx_queue_lock_key);
 	lockdep_set_class(&dev_ifb->ingress_lock, &ifb_ingress_lock_key);
 
 	return 0;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2c792e6..40542e3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -449,6 +449,7 @@ static inline void napi_synchronize(const struct napi_struct *n)
 #endif
 
 struct netdev_queue {
+	spinlock_t		lock;
 	struct net_device	*dev;
 };
 
@@ -639,7 +640,6 @@ struct net_device
  * Cache line mostly used on queue transmit path (qdisc)
  */
 	/* device queue lock */
-	spinlock_t		queue_lock ____cacheline_aligned_in_smp;
 	struct Qdisc		*qdisc;
 	struct Qdisc		*qdisc_sleeping;
 	struct list_head	qdisc_list;
diff --git a/net/core/dev.c b/net/core/dev.c
index 26ba606..8565f94 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1667,6 +1667,7 @@ out_kfree_skb:
 int dev_queue_xmit(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
+	struct netdev_queue *txq;
 	struct Qdisc *q;
 	int rc = -ENOMEM;
 
@@ -1699,14 +1700,15 @@ int dev_queue_xmit(struct sk_buff *skb)
 	}
 
 gso:
-	spin_lock_prefetch(&dev->queue_lock);
+	txq = &dev->tx_queue;
+	spin_lock_prefetch(&txq->lock);
 
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */
 	rcu_read_lock_bh();
 
-	/* Updates of qdisc are serialized by queue_lock.
+	/* Updates of qdisc are serialized by queue->lock.
 	 * The struct Qdisc which is pointed to by qdisc is now a
 	 * rcu structure - it may be accessed without acquiring
 	 * a lock (but the structure may be stale.) The freeing of the
@@ -1714,7 +1716,7 @@ gso:
 	 * more references to it.
 	 *
 	 * If the qdisc has an enqueue function, we still need to
-	 * hold the queue_lock before calling it, since queue_lock
+	 * hold the queue->lock before calling it, since queue->lock
 	 * also serializes access to the device queue.
 	 */
 
@@ -1724,19 +1726,19 @@ gso:
 #endif
 	if (q->enqueue) {
 		/* Grab device queue */
-		spin_lock(&dev->queue_lock);
+		spin_lock(&txq->lock);
 		q = dev->qdisc;
 		if (q->enqueue) {
 			/* reset queue_mapping to zero */
 			skb_set_queue_mapping(skb, 0);
 			rc = q->enqueue(skb, q);
 			qdisc_run(dev);
-			spin_unlock(&dev->queue_lock);
+			spin_unlock(&txq->lock);
 
 			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
 			goto out;
 		}
-		spin_unlock(&dev->queue_lock);
+		spin_unlock(&txq->lock);
 	}
 
 	/* The device has no queue. Common case for software devices:
@@ -1919,14 +1921,17 @@ static void net_tx_action(struct softirq_action *h)
 
 		while (head) {
 			struct net_device *dev = head;
+			struct netdev_queue *txq;
 			head = head->next_sched;
 
+			txq = &dev->tx_queue;
+
 			smp_mb__before_clear_bit();
 			clear_bit(__LINK_STATE_SCHED, &dev->state);
 
-			if (spin_trylock(&dev->queue_lock)) {
+			if (spin_trylock(&txq->lock)) {
 				qdisc_run(dev);
-				spin_unlock(&dev->queue_lock);
+				spin_unlock(&txq->lock);
 			} else {
 				netif_schedule(dev);
 			}
@@ -3787,7 +3792,6 @@ int register_netdevice(struct net_device *dev)
 	BUG_ON(!dev_net(dev));
 	net = dev_net(dev);
 
-	spin_lock_init(&dev->queue_lock);
 	spin_lock_init(&dev->_xmit_lock);
 	netdev_set_lockdep_class(&dev->_xmit_lock, dev->type);
 	dev->xmit_lock_owner = -1;
@@ -4072,10 +4076,17 @@ static struct net_device_stats *internal_stats(struct net_device *dev)
 	return &dev->stats;
 }
 
+static void netdev_init_one_queue(struct net_device *dev,
+				  struct netdev_queue *queue)
+{
+	spin_lock_init(&queue->lock);
+	queue->dev = dev;
+}
+
 static void netdev_init_queues(struct net_device *dev)
 {
-	dev->rx_queue.dev = dev;
-	dev->tx_queue.dev = dev;
+	netdev_init_one_queue(dev, &dev->rx_queue);
+	netdev_init_one_queue(dev, &dev->tx_queue);
 }
 
 /**
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index b661ee5..81fe145 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -632,7 +632,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 
 	/* ensure that TX flow won't interrupt us
 	 * until the end of the call to requeue function */
-	spin_lock_bh(&local->mdev->queue_lock);
+	spin_lock_bh(&local->mdev->tx_queue.lock);
 
 	/* create a new queue for this aggregation */
 	ret = ieee80211_ht_agg_queue_add(local, sta, tid);
@@ -671,7 +671,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 
 	/* Will put all the packets in the new SW queue */
 	ieee80211_requeue(local, ieee802_1d_to_ac[tid]);
-	spin_unlock_bh(&local->mdev->queue_lock);
+	spin_unlock_bh(&local->mdev->tx_queue.lock);
 	spin_unlock_bh(&sta->lock);
 
 	/* send an addBA request */
@@ -695,7 +695,7 @@ int ieee80211_start_tx_ba_session(struct ieee80211_hw *hw, u8 *ra, u16 tid)
 err_unlock_queue:
 	kfree(sta->ampdu_mlme.tid_tx[tid]);
 	sta->ampdu_mlme.tid_tx[tid] = NULL;
-	spin_unlock_bh(&local->mdev->queue_lock);
+	spin_unlock_bh(&local->mdev->tx_queue.lock);
 	ret = -EBUSY;
 err_unlock_sta:
 	spin_unlock_bh(&sta->lock);
@@ -855,10 +855,10 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_hw *hw, u8 *ra, u8 tid)
 
 	/* avoid ordering issues: we are the only one that can modify
 	 * the content of the qdiscs */
-	spin_lock_bh(&local->mdev->queue_lock);
+	spin_lock_bh(&local->mdev->tx_queue.lock);
 	/* remove the queue for this aggregation */
 	ieee80211_ht_agg_queue_remove(local, sta, tid, 1);
-	spin_unlock_bh(&local->mdev->queue_lock);
+	spin_unlock_bh(&local->mdev->tx_queue.lock);
 
 	/* we just requeued the all the frames that were in the removed
 	 * queue, and since we might miss a softirq we do netif_schedule.
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index cc8b5a9..8bd8fa2 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -650,7 +650,7 @@ int ieee80211_ht_agg_queue_add(struct ieee80211_local *local,
 }
 
 /**
- * the caller needs to hold local->mdev->queue_lock
+ * the caller needs to hold local->mdev->tx_queue.lock
  */
 void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
 				   struct sta_info *sta, u16 tid,
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 8bb8929..e3feb88 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -502,7 +502,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 		sch->stats_lock = &dev->ingress_lock;
 		handle = TC_H_MAKE(TC_H_INGRESS, 0);
 	} else {
-		sch->stats_lock = &dev->queue_lock;
+		sch->stats_lock = &dev_queue->lock;
 		if (handle == 0) {
 			handle = qdisc_alloc_handle(dev);
 			err = -ENOMEM;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index c7adc38..abaa25d 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1753,10 +1753,10 @@ static void cbq_put(struct Qdisc *sch, unsigned long arg)
 #ifdef CONFIG_NET_CLS_ACT
 		struct cbq_sched_data *q = qdisc_priv(sch);
 
-		spin_lock_bh(&qdisc_dev(sch)->queue_lock);
+		spin_lock_bh(&sch->dev_queue->lock);
 		if (q->rx_class == cl)
 			q->rx_class = NULL;
-		spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
+		spin_unlock_bh(&sch->dev_queue->lock);
 #endif
 
 		cbq_destroy_class(sch, cl);
@@ -1834,7 +1834,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &qdisc_dev(sch)->queue_lock,
+					      &sch->dev_queue->lock,
 					      tca[TCA_RATE]);
 		return 0;
 	}
@@ -1923,7 +1923,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 
 	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &qdisc_dev(sch)->queue_lock, tca[TCA_RATE]);
+				  &sch->dev_queue->lock, tca[TCA_RATE]);
 
 	*arg = (unsigned long)cl;
 	return 0;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index b626a4f..ee8f9f7 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -29,31 +29,31 @@
 /* Main transmission queue. */
 
 /* Modifications to data participating in scheduling must be protected with
- * dev->queue_lock spinlock.
+ * queue->lock spinlock.
  *
  * The idea is the following:
  * - enqueue, dequeue are serialized via top level device
- *   spinlock dev->queue_lock.
+ *   spinlock queue->lock.
  * - ingress filtering is serialized via top level device
  *   spinlock dev->ingress_lock.
  * - updates to tree and tree walking are only done under the rtnl mutex.
  */
 
 void qdisc_lock_tree(struct net_device *dev)
-	__acquires(dev->queue_lock)
+	__acquires(dev->tx_queue.lock)
 	__acquires(dev->ingress_lock)
 {
-	spin_lock_bh(&dev->queue_lock);
+	spin_lock_bh(&dev->tx_queue.lock);
 	spin_lock(&dev->ingress_lock);
 }
 EXPORT_SYMBOL(qdisc_lock_tree);
 
 void qdisc_unlock_tree(struct net_device *dev)
 	__releases(dev->ingress_lock)
-	__releases(dev->queue_lock)
+	__releases(dev->tx_queue.lock)
 {
 	spin_unlock(&dev->ingress_lock);
-	spin_unlock_bh(&dev->queue_lock);
+	spin_unlock_bh(&dev->tx_queue.lock);
 }
 EXPORT_SYMBOL(qdisc_unlock_tree);
 
@@ -118,15 +118,15 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 }
 
 /*
- * NOTE: Called under dev->queue_lock with locally disabled BH.
+ * NOTE: Called under queue->lock with locally disabled BH.
  *
  * __LINK_STATE_QDISC_RUNNING guarantees only one CPU can process this
- * device at a time. dev->queue_lock serializes queue accesses for
+ * device at a time. queue->lock serializes queue accesses for
  * this device AND dev->qdisc pointer itself.
  *
  *  netif_tx_lock serializes accesses to device driver.
  *
- *  dev->queue_lock and netif_tx_lock are mutually exclusive,
+ *  queue->lock and netif_tx_lock are mutually exclusive,
  *  if one is grabbed, another must be free.
  *
  * Note, that this procedure can be called by a watchdog timer
@@ -148,14 +148,14 @@ static inline int qdisc_restart(struct net_device *dev)
 
 
 	/* And release queue */
-	spin_unlock(&dev->queue_lock);
+	spin_unlock(&q->dev_queue->lock);
 
 	HARD_TX_LOCK(dev, smp_processor_id());
 	if (!netif_subqueue_stopped(dev, skb))
 		ret = dev_hard_start_xmit(skb, dev);
 	HARD_TX_UNLOCK(dev);
 
-	spin_lock(&dev->queue_lock);
+	spin_lock(&q->dev_queue->lock);
 	q = dev->qdisc;
 
 	switch (ret) {
@@ -482,7 +482,7 @@ struct Qdisc * qdisc_create_dflt(struct net_device *dev,
 	sch = qdisc_alloc(dev_queue, ops);
 	if (IS_ERR(sch))
 		goto errout;
-	sch->stats_lock = &dev->queue_lock;
+	sch->stats_lock = &dev_queue->lock;
 	sch->parent = parentid;
 
 	if (!ops->init || ops->init(sch, NULL) == 0)
@@ -494,7 +494,7 @@ errout:
 }
 EXPORT_SYMBOL(qdisc_create_dflt);
 
-/* Under dev->queue_lock and BH! */
+/* Under queue->lock and BH! */
 
 void qdisc_reset(struct Qdisc *qdisc)
 {
@@ -514,7 +514,7 @@ static void __qdisc_destroy(struct rcu_head *head)
 	kfree((char *) qdisc - qdisc->padded);
 }
 
-/* Under dev->queue_lock and BH! */
+/* Under queue->lock and BH! */
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
@@ -566,13 +566,13 @@ void dev_activate(struct net_device *dev)
 		/* Delay activation until next carrier-on event */
 		return;
 
-	spin_lock_bh(&dev->queue_lock);
+	spin_lock_bh(&dev->tx_queue.lock);
 	rcu_assign_pointer(dev->qdisc, dev->qdisc_sleeping);
 	if (dev->qdisc != &noqueue_qdisc) {
 		dev->trans_start = jiffies;
 		dev_watchdog_up(dev);
 	}
-	spin_unlock_bh(&dev->queue_lock);
+	spin_unlock_bh(&dev->tx_queue.lock);
 }
 
 void dev_deactivate(struct net_device *dev)
@@ -581,7 +581,7 @@ void dev_deactivate(struct net_device *dev)
 	struct sk_buff *skb;
 	int running;
 
-	spin_lock_bh(&dev->queue_lock);
+	spin_lock_bh(&dev->tx_queue.lock);
 	qdisc = dev->qdisc;
 	dev->qdisc = &noop_qdisc;
 
@@ -589,7 +589,7 @@ void dev_deactivate(struct net_device *dev)
 
 	skb = dev->gso_skb;
 	dev->gso_skb = NULL;
-	spin_unlock_bh(&dev->queue_lock);
+	spin_unlock_bh(&dev->tx_queue.lock);
 
 	kfree_skb(skb);
 
@@ -607,9 +607,9 @@ void dev_deactivate(struct net_device *dev)
 		 * Double-check inside queue lock to ensure that all effects
 		 * of the queue run are visible when we return.
 		 */
-		spin_lock_bh(&dev->queue_lock);
+		spin_lock_bh(&dev->tx_queue.lock);
 		running = test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
-		spin_unlock_bh(&dev->queue_lock);
+		spin_unlock_bh(&dev->tx_queue.lock);
 
 		/*
 		 * The running flag should never be set at this point because
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 78fa9ad..f27e968 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1057,7 +1057,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &qdisc_dev(sch)->queue_lock,
+					      &sch->dev_queue->lock,
 					      tca[TCA_RATE]);
 		return 0;
 	}
@@ -1114,7 +1114,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &qdisc_dev(sch)->queue_lock, tca[TCA_RATE]);
+				  &sch->dev_queue->lock, tca[TCA_RATE]);
 	*arg = (unsigned long)cl;
 	return 0;
 }
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index ec770ea..46e9d4d 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1065,7 +1065,7 @@ static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 	struct nlattr *nest;
 	struct tc_htb_glob gopt;
 
-	spin_lock_bh(&qdisc_dev(sch)->queue_lock);
+	spin_lock_bh(&sch->dev_queue->lock);
 
 	gopt.direct_pkts = q->direct_pkts;
 	gopt.version = HTB_VER;
@@ -1079,11 +1079,11 @@ static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 	NLA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
 	nla_nest_end(skb, nest);
 
-	spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
+	spin_unlock_bh(&sch->dev_queue->lock);
 	return skb->len;
 
 nla_put_failure:
-	spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
+	spin_unlock_bh(&sch->dev_queue->lock);
 	nla_nest_cancel(skb, nest);
 	return -1;
 }
@@ -1095,7 +1095,7 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	struct nlattr *nest;
 	struct tc_htb_opt opt;
 
-	spin_lock_bh(&qdisc_dev(sch)->queue_lock);
+	spin_lock_bh(&sch->dev_queue->lock);
 	tcm->tcm_parent = cl->parent ? cl->parent->classid : TC_H_ROOT;
 	tcm->tcm_handle = cl->classid;
 	if (!cl->level && cl->un.leaf.q)
@@ -1117,11 +1117,11 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	NLA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
 
 	nla_nest_end(skb, nest);
-	spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
+	spin_unlock_bh(&sch->dev_queue->lock);
 	return skb->len;
 
 nla_put_failure:
-	spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
+	spin_unlock_bh(&sch->dev_queue->lock);
 	nla_nest_cancel(skb, nest);
 	return -1;
 }
@@ -1394,7 +1394,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			goto failure;
 
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &qdisc_dev(sch)->queue_lock,
+				  &sch->dev_queue->lock,
 				  tca[TCA_RATE] ? : &est.nla);
 		cl->refcnt = 1;
 		INIT_LIST_HEAD(&cl->sibling);
@@ -1451,7 +1451,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	} else {
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &qdisc_dev(sch)->queue_lock,
+					      &sch->dev_queue->lock,
 					      tca[TCA_RATE]);
 		sch_tree_lock(sch);
 	}
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 130dd13..cf04cd6 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -355,9 +355,9 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 	for (i = 0; i < n; i++)
 		d->table[i] = data[i];
 
-	spin_lock_bh(&qdisc_dev(sch)->queue_lock);
+	spin_lock_bh(&sch->dev_queue->lock);
 	d = xchg(&q->delay_dist, d);
-	spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
+	spin_unlock_bh(&sch->dev_queue->lock);
 
 	kfree(d);
 	return 0;
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index b3fc826..4f3054e 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -154,9 +154,9 @@ teql_destroy(struct Qdisc* sch)
 					master->slaves = NEXT_SLAVE(q);
 					if (q == master->slaves) {
 						master->slaves = NULL;
-						spin_lock_bh(&master->dev->queue_lock);
+						spin_lock_bh(&master->dev->tx_queue.lock);
 						qdisc_reset(master->dev->qdisc);
-						spin_unlock_bh(&master->dev->queue_lock);
+						spin_unlock_bh(&master->dev->tx_queue.lock);
 					}
 				}
 				skb_queue_purge(&dat->q);
-- 
1.5.6

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
