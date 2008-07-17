From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 24/31]: netdevice: Move qdisc_list back into net_device
 proper.
Date: Thu, 17 Jul 2008 05:17:47 -0700 (PDT)
Message-ID: <20080717.051747.43598391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


And give it it's own lock.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/linux/netdevice.h |    3 ++-
 net/core/dev.c            |    2 ++
 net/sched/sch_api.c       |   31 +++++++------------------------
 net/sched/sch_generic.c   |    9 +++++++--
 4 files changed, 18 insertions(+), 27 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1e839fa..3170bce 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -450,7 +450,6 @@ struct netdev_queue {
 	spinlock_t		_xmit_lock;
 	int			xmit_lock_owner;
 	struct Qdisc		*qdisc_sleeping;
-	struct list_head	qdisc_list;
 } ____cacheline_aligned_in_smp;
 
 /*
@@ -638,6 +637,8 @@ struct net_device
 	unsigned int		real_num_tx_queues;
 
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
+	spinlock_t		qdisc_list_lock;
+	struct list_head	qdisc_list;
 
 /*
  * One part is mostly used on xmit path (device)
diff --git a/net/core/dev.c b/net/core/dev.c
index 0b909b7..6741e34 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3886,6 +3886,8 @@ int register_netdevice(struct net_device *dev)
 	net = dev_net(dev);
 
 	spin_lock_init(&dev->addr_list_lock);
+	spin_lock_init(&dev->qdisc_list_lock);
+	INIT_LIST_HEAD(&dev->qdisc_list);
 	netdev_init_queue_locks(dev);
 
 	dev->iflink = -1;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 8e8c5be..6958fe7 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -183,30 +183,17 @@ EXPORT_SYMBOL(unregister_qdisc);
    (root qdisc, all its children, children of children etc.)
  */
 
-static struct Qdisc *__qdisc_lookup(struct netdev_queue *dev_queue, u32 handle)
+struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 {
 	struct Qdisc *q;
 
-	list_for_each_entry(q, &dev_queue->qdisc_list, list) {
+	list_for_each_entry(q, &dev->qdisc_list, list) {
 		if (q->handle == handle)
 			return q;
 	}
 	return NULL;
 }
 
-struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
-{
-	unsigned int i;
-
-	for (i = 0; i < dev->num_tx_queues; i++) {
-		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		struct Qdisc *q = __qdisc_lookup(txq, handle);
-		if (q)
-			return q;
-	}
-	return NULL;
-}
-
 static struct Qdisc *qdisc_leaf(struct Qdisc *p, u32 classid)
 {
 	unsigned long cl;
@@ -645,9 +632,9 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				goto err_out3;
 			}
 		}
-		qdisc_lock_tree(dev);
-		list_add_tail(&sch->list, &dev_queue->qdisc_list);
-		qdisc_unlock_tree(dev);
+		spin_lock_bh(&dev->qdisc_list_lock);
+		list_add_tail(&sch->list, &dev->qdisc_list);
+		spin_unlock_bh(&dev->qdisc_list_lock);
 
 		return sch;
 	}
@@ -1032,14 +1019,12 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 	read_lock(&dev_base_lock);
 	idx = 0;
 	for_each_netdev(&init_net, dev) {
-		struct netdev_queue *dev_queue;
 		if (idx < s_idx)
 			goto cont;
 		if (idx > s_idx)
 			s_q_idx = 0;
 		q_idx = 0;
-		dev_queue = netdev_get_tx_queue(dev, 0);
-		list_for_each_entry(q, &dev_queue->qdisc_list, list) {
+		list_for_each_entry(q, &dev->qdisc_list, list) {
 			if (q_idx < s_q_idx) {
 				q_idx++;
 				continue;
@@ -1269,7 +1254,6 @@ static int qdisc_class_dump(struct Qdisc *q, unsigned long cl, struct qdisc_walk
 static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
-	struct netdev_queue *dev_queue;
 	int t;
 	int s_t;
 	struct net_device *dev;
@@ -1288,8 +1272,7 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	s_t = cb->args[0];
 	t = 0;
 
-	dev_queue = netdev_get_tx_queue(dev, 0);
-	list_for_each_entry(q, &dev_queue->qdisc_list, list) {
+	list_for_each_entry(q, &dev->qdisc_list, list) {
 		if (t < s_t || !q->ops->cl_ops ||
 		    (tcm->tcm_parent &&
 		     TC_H_MAJ(tcm->tcm_parent) != q->handle)) {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index efa418a..8cdf0b4 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -563,11 +563,15 @@ static void __qdisc_destroy(struct rcu_head *head)
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
+	struct net_device *dev = qdisc_dev(qdisc);
+
 	if (qdisc->flags & TCQ_F_BUILTIN ||
 	    !atomic_dec_and_test(&qdisc->refcnt))
 		return;
 
+	spin_lock_bh(&dev->qdisc_list_lock);
 	list_del(&qdisc->list);
+	spin_unlock_bh(&dev->qdisc_list_lock);
 
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
 }
@@ -599,7 +603,9 @@ static void attach_one_default_qdisc(struct net_device *dev,
 			printk(KERN_INFO "%s: activation failed\n", dev->name);
 			return;
 		}
-		list_add_tail(&qdisc->list, &dev_queue->qdisc_list);
+		spin_lock_bh(&dev->qdisc_list_lock);
+		list_add_tail(&qdisc->list, &dev->qdisc_list);
+		spin_unlock_bh(&dev->qdisc_list_lock);
 	} else {
 		qdisc =  &noqueue_qdisc;
 	}
@@ -738,7 +744,6 @@ static void dev_init_scheduler_queue(struct net_device *dev,
 
 	dev_queue->qdisc = qdisc;
 	dev_queue->qdisc_sleeping = qdisc;
-	INIT_LIST_HEAD(&dev_queue->qdisc_list);
 }
 
 void dev_init_scheduler(struct net_device *dev)
-- 
1.5.6.2.255.gbed62

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
