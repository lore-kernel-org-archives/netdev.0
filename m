From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Fri, 04 Sep 2009 03:43:22 +0200
Message-ID: <4AA070BA.9000105@trash.net>
References: <4A9FD2DC.7070807@trash.net>	<Pine.LNX.4.64.0909031911400.3490@ask.diku.dk>	<4AA00351.4090601@trash.net> <20090903.163101.154177782.davem@davemloft.net> <4AA06F3B.2050500@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090302080206090701050004"
Cc: hawk@diku.dk, cl@linux-foundation.org, eric.dumazet@gmail.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52030 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755411AbZIDBnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 21:43:23 -0400
In-Reply-To: <4AA06F3B.2050500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090302080206090701050004
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> David Miller wrote:
>   
>> You mean just like Intel's multiqueue scheduler and multiqueue
>> classifiers which we already have in the tree :-
>>     
>
> No, actually integrated in the current infrastructure :) The patches
> add a virtual root qdisc, so we still have a single root from userspace's
> POV. This qdisc is only used for sch_api purposes and doesn't necessarily
> match the real root qdiscs. When a "mq" qdisc is attached (done by
> default for multiqueue devices), the queues are exposed as child
> classes of this qdisc and can be individually grafted with different
> qdiscs.
>   

Since its getting late and I won't finish this tonight, here are the
patches I'm currently working on in case someone already wants to have
a look. Its working as intended and should be testable. Patch 1 is good
shape IMO, patch 3 still needs some work. Userspace needs no changes.



--------------090302080206090701050004
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 6ab8d4a8e3df7976fc2db1e1181216a213df89d5
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Sep 4 03:07:39 2009 +0200

    net_sched: reintroduce dev->qdisc for use by sch_api
    
    Currently the multiqueue integration with the qdisc API suffers from
    a few problems:
    
    - with multiple queues, all root qdiscs use the same handle. This means
      they can't be exposed to userspace in a backwards compatible fashion.
    
    - all API operations always refer to queue number 0. Newly created
      qdiscs are automatically shared between all queues, its not possible
      to address individual queues or restore multiqueue behaviour once a
      shared qdisc has been attached.
    
    - Dumps only contain the root qdisc of queue 0, in case of non-shared
      qdiscs this means the statistics are incomplete.
    
    This patch reintroduces dev->qdisc, which points to the (single) root qdisc
    from userspace's point of view. Currently it either points to the first
    (non-shared) default qdisc, or a qdisc shared between all queues. The
    following patches will introduce a classful dummy qdisc, which will be used
    as root qdisc and contain the per-queue qdiscs as children.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 121cbad..a44118b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -832,6 +832,9 @@ struct net_device
 	/* Number of TX queues currently active in device  */
 	unsigned int		real_num_tx_queues;
 
+	/* root qdisc from userspace point of view */
+	struct Qdisc		*qdisc;
+
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 	spinlock_t		tx_global_lock;
 /*
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5c1fe53..1aebdc1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -606,7 +606,6 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags)
 {
-	struct netdev_queue *txq;
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
 	const struct net_device_stats *stats;
@@ -637,9 +636,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (dev->master)
 		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
 
-	txq = netdev_get_tx_queue(dev, 0);
-	if (txq->qdisc_sleeping)
-		NLA_PUT_STRING(skb, IFLA_QDISC, txq->qdisc_sleeping->ops->id);
+	if (dev->qdisc)
+		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc->ops->id);
 
 	if (dev->ifalias)
 		NLA_PUT_STRING(skb, IFLA_IFALIAS, dev->ifalias);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 09cdcdf..e857441 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -168,8 +168,7 @@ replay:
 
 	/* Find qdisc */
 	if (!parent) {
-		struct netdev_queue *dev_queue = netdev_get_tx_queue(dev, 0);
-		q = dev_queue->qdisc_sleeping;
+		q = dev->qdisc;
 		parent = q->handle;
 	} else {
 		q = qdisc_lookup(dev, TC_H_MAJ(t->tcm_parent));
@@ -405,7 +404,6 @@ static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
 static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
-	struct netdev_queue *dev_queue;
 	int t;
 	int s_t;
 	struct net_device *dev;
@@ -424,9 +422,8 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 	if ((dev = dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
 		return skb->len;
 
-	dev_queue = netdev_get_tx_queue(dev, 0);
 	if (!tcm->tcm_parent)
-		q = dev_queue->qdisc_sleeping;
+		q = dev->qdisc;
 	else
 		q = qdisc_lookup(dev, TC_H_MAJ(tcm->tcm_parent));
 	if (!q)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 24d17ce..285ca25 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -207,7 +207,7 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 static void qdisc_list_add(struct Qdisc *q)
 {
 	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS))
-		list_add_tail(&q->list, &qdisc_root_sleeping(q)->list);
+		list_add_tail(&q->list, &qdisc_dev(q)->qdisc->list);
 }
 
 void qdisc_list_del(struct Qdisc *q)
@@ -219,17 +219,11 @@ EXPORT_SYMBOL(qdisc_list_del);
 
 struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 {
-	unsigned int i;
 	struct Qdisc *q;
 
-	for (i = 0; i < dev->num_tx_queues; i++) {
-		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		struct Qdisc *txq_root = txq->qdisc_sleeping;
-
-		q = qdisc_match_from_root(txq_root, handle);
-		if (q)
-			goto out;
-	}
+	q = qdisc_match_from_root(dev->qdisc, handle);
+	if (q)
+		goto out;
 
 	q = qdisc_match_from_root(dev->rx_queue.qdisc_sleeping, handle);
 out:
@@ -720,9 +714,14 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 			if (new && i > 0)
 				atomic_inc(&new->refcnt);
 
-			notify_and_destroy(skb, n, classid, old, new);
+			qdisc_destroy(old);
 		}
 
+		notify_and_destroy(skb, n, classid, dev->qdisc, new);
+		if (new)
+			atomic_inc(&new->refcnt);
+		dev->qdisc = new ? : &noop_qdisc;
+
 		if (dev->flags & IFF_UP)
 			dev_activate(dev);
 	} else {
@@ -974,9 +973,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 				q = dev->rx_queue.qdisc_sleeping;
 			}
 		} else {
-			struct netdev_queue *dev_queue;
-			dev_queue = netdev_get_tx_queue(dev, 0);
-			q = dev_queue->qdisc_sleeping;
+			q = dev->qdisc;
 		}
 		if (!q)
 			return -ENOENT;
@@ -1044,9 +1041,7 @@ replay:
 				q = dev->rx_queue.qdisc_sleeping;
 			}
 		} else {
-			struct netdev_queue *dev_queue;
-			dev_queue = netdev_get_tx_queue(dev, 0);
-			q = dev_queue->qdisc_sleeping;
+			q = dev->qdisc;
 		}
 
 		/* It may be default qdisc, ignore it */
@@ -1291,8 +1286,7 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 			s_q_idx = 0;
 		q_idx = 0;
 
-		dev_queue = netdev_get_tx_queue(dev, 0);
-		if (tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb, &q_idx, s_q_idx) < 0)
+		if (tc_dump_qdisc_root(dev->qdisc, skb, cb, &q_idx, s_q_idx) < 0)
 			goto done;
 
 		dev_queue = &dev->rx_queue;
@@ -1323,7 +1317,6 @@ done:
 static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
-	struct netdev_queue *dev_queue;
 	struct tcmsg *tcm = NLMSG_DATA(n);
 	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
@@ -1361,7 +1354,6 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 
 	/* Step 1. Determine qdisc handle X:0 */
 
-	dev_queue = netdev_get_tx_queue(dev, 0);
 	if (pid != TC_H_ROOT) {
 		u32 qid1 = TC_H_MAJ(pid);
 
@@ -1372,7 +1364,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		} else if (qid1) {
 			qid = qid1;
 		} else if (qid == 0)
-			qid = dev_queue->qdisc_sleeping->handle;
+			qid = dev->qdisc->handle;
 
 		/* Now qid is genuine qdisc handle consistent
 		   both with parent and child.
@@ -1383,7 +1375,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 			pid = TC_H_MAKE(qid, pid);
 	} else {
 		if (qid == 0)
-			qid = dev_queue->qdisc_sleeping->handle;
+			qid = dev->qdisc->handle;
 	}
 
 	/* OK. Locate qdisc */
@@ -1584,8 +1576,7 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
 	s_t = cb->args[0];
 	t = 0;
 
-	dev_queue = netdev_get_tx_queue(dev, 0);
-	if (tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb, &t, s_t) < 0)
+	if (tc_dump_tclass_root(dev->qdisc, skb, tcm, cb, &t, s_t) < 0)
 		goto done;
 
 	dev_queue = &dev->rx_queue;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6128e6f..a91f079 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -623,19 +623,6 @@ void qdisc_destroy(struct Qdisc *qdisc)
 }
 EXPORT_SYMBOL(qdisc_destroy);
 
-static bool dev_all_qdisc_sleeping_noop(struct net_device *dev)
-{
-	unsigned int i;
-
-	for (i = 0; i < dev->num_tx_queues; i++) {
-		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-
-		if (txq->qdisc_sleeping != &noop_qdisc)
-			return false;
-	}
-	return true;
-}
-
 static void attach_one_default_qdisc(struct net_device *dev,
 				     struct netdev_queue *dev_queue,
 				     void *_unused)
@@ -677,6 +664,7 @@ static void transition_one_qdisc(struct net_device *dev,
 
 void dev_activate(struct net_device *dev)
 {
+	struct netdev_queue *txq;
 	int need_watchdog;
 
 	/* No queueing discipline is attached to device;
@@ -685,9 +673,14 @@ void dev_activate(struct net_device *dev)
 	   virtual interfaces
 	 */
 
-	if (dev_all_qdisc_sleeping_noop(dev))
+	if (dev->qdisc == &noop_qdisc) {
 		netdev_for_each_tx_queue(dev, attach_one_default_qdisc, NULL);
 
+		txq = netdev_get_tx_queue(dev, 0);
+		dev->qdisc = txq->qdisc_sleeping;
+		atomic_inc(&dev->qdisc->refcnt);
+	}
+
 	if (!netif_carrier_ok(dev))
 		/* Delay activation until next carrier-on event */
 		return;
@@ -777,6 +770,7 @@ static void dev_init_scheduler_queue(struct net_device *dev,
 
 void dev_init_scheduler(struct net_device *dev)
 {
+	dev->qdisc = &noop_qdisc;
 	netdev_for_each_tx_queue(dev, dev_init_scheduler_queue, &noop_qdisc);
 	dev_init_scheduler_queue(dev, &dev->rx_queue, &noop_qdisc);
 
@@ -802,5 +796,8 @@ void dev_shutdown(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, shutdown_scheduler_queue, &noop_qdisc);
 	shutdown_scheduler_queue(dev, &dev->rx_queue, &noop_qdisc);
+	qdisc_destroy(dev->qdisc);
+	dev->qdisc = &noop_qdisc;
+
 	WARN_ON(timer_pending(&dev->watchdog_timer));
 }

--------------090302080206090701050004
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit 9b1d1d62936b6ec6e51956d77b83743bea67e1ac
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Sep 4 03:13:54 2009 +0200

    net_sched: move dev_graft_qdisc() to sch_generic.c
    
    It will be used in a following patch by the multiqueue qdisc.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 84b3fc2..a1a3f3f 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -302,6 +302,8 @@ extern void dev_init_scheduler(struct net_device *dev);
 extern void dev_shutdown(struct net_device *dev);
 extern void dev_activate(struct net_device *dev);
 extern void dev_deactivate(struct net_device *dev);
+extern struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
+				     struct Qdisc *qdisc);
 extern void qdisc_reset(struct Qdisc *qdisc);
 extern void qdisc_destroy(struct Qdisc *qdisc);
 extern void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 285ca25..c0d2704 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -610,32 +610,6 @@ static u32 qdisc_alloc_handle(struct net_device *dev)
 	return i>0 ? autohandle : 0;
 }
 
-/* Attach toplevel qdisc to device queue. */
-
-static struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
-				     struct Qdisc *qdisc)
-{
-	struct Qdisc *oqdisc = dev_queue->qdisc_sleeping;
-	spinlock_t *root_lock;
-
-	root_lock = qdisc_lock(oqdisc);
-	spin_lock_bh(root_lock);
-
-	/* Prune old scheduler */
-	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
-		qdisc_reset(oqdisc);
-
-	/* ... and graft new one */
-	if (qdisc == NULL)
-		qdisc = &noop_qdisc;
-	dev_queue->qdisc_sleeping = qdisc;
-	rcu_assign_pointer(dev_queue->qdisc, &noop_qdisc);
-
-	spin_unlock_bh(root_lock);
-
-	return oqdisc;
-}
-
 void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 {
 	const struct Qdisc_class_ops *cops;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a91f079..e7c47ce 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -623,6 +623,31 @@ void qdisc_destroy(struct Qdisc *qdisc)
 }
 EXPORT_SYMBOL(qdisc_destroy);
 
+/* Attach toplevel qdisc to device queue. */
+struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
+			      struct Qdisc *qdisc)
+{
+	struct Qdisc *oqdisc = dev_queue->qdisc_sleeping;
+	spinlock_t *root_lock;
+
+	root_lock = qdisc_lock(oqdisc);
+	spin_lock_bh(root_lock);
+
+	/* Prune old scheduler */
+	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
+		qdisc_reset(oqdisc);
+
+	/* ... and graft new one */
+	if (qdisc == NULL)
+		qdisc = &noop_qdisc;
+	dev_queue->qdisc_sleeping = qdisc;
+	rcu_assign_pointer(dev_queue->qdisc, &noop_qdisc);
+
+	spin_unlock_bh(root_lock);
+
+	return oqdisc;
+}
+
 static void attach_one_default_qdisc(struct net_device *dev,
 				     struct netdev_queue *dev_queue,
 				     void *_unused)

--------------090302080206090701050004
Content-Type: text/x-diff;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

commit 7f8e95c412644cc23173c9c5673df794fb9b65f7
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Sep 4 03:24:28 2009 +0200

    net_sched: add classful multiqueue dummy scheduler
    
    This patch adds a classful dummy scheduler which can be used as root qdisc
    for multiqueue devices and exposes each device queue as a child class.
    
    This allows to address queues individually and graft them similar to regular
    classes. Additionally it presents an accumulated view of the statistics of
    all real root qdiscs in the dummy root.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a1a3f3f..b76e4fa 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -122,6 +122,7 @@ struct Qdisc_ops
 	void			(*reset)(struct Qdisc *);
 	void			(*destroy)(struct Qdisc *);
 	int			(*change)(struct Qdisc *, struct nlattr *arg);
+	void			(*attach)(struct Qdisc *);
 
 	int			(*dump)(struct Qdisc *, struct sk_buff *);
 	int			(*dump_stats)(struct Qdisc *, struct gnet_dump *);
@@ -255,6 +256,8 @@ static inline void sch_tree_unlock(struct Qdisc *q)
 
 extern struct Qdisc noop_qdisc;
 extern struct Qdisc_ops noop_qdisc_ops;
+extern struct Qdisc_ops pfifo_fast_ops;
+extern struct Qdisc_ops mq_qdisc_ops;
 
 struct Qdisc_class_common
 {
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 54d950c..f14e71b 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -2,7 +2,7 @@
 # Makefile for the Linux Traffic Control Unit.
 #
 
-obj-y	:= sch_generic.o
+obj-y	:= sch_generic.o sch_mq.o
 
 obj-$(CONFIG_NET_SCHED)		+= sch_api.o sch_blackhole.o
 obj-$(CONFIG_NET_CLS)		+= cls_api.o
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c0d2704..dc41cb1 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -678,6 +678,11 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 		if (dev->flags & IFF_UP)
 			dev_deactivate(dev);
 
+		if (new && new->ops->attach) {
+			new->ops->attach(new);
+			num_q = 0;
+		}
+
 		for (i = 0; i < num_q; i++) {
 			struct netdev_queue *dev_queue = &dev->rx_queue;
 
@@ -692,7 +697,7 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 		}
 
 		notify_and_destroy(skb, n, classid, dev->qdisc, new);
-		if (new)
+		if (new && !new->ops->attach)
 			atomic_inc(&new->refcnt);
 		dev->qdisc = new ? : &noop_qdisc;
 
@@ -1670,6 +1675,7 @@ static int __init pktsched_init(void)
 {
 	register_qdisc(&pfifo_qdisc_ops);
 	register_qdisc(&bfifo_qdisc_ops);
+	register_qdisc(&mq_qdisc_ops);
 	proc_net_fops_create(&init_net, "psched", 0, &psched_fops);
 
 	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e7c47ce..4ae6aa5 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -514,7 +514,7 @@ static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
 	return 0;
 }
 
-static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
+struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.id		=	"pfifo_fast",
 	.priv_size	=	sizeof(struct pfifo_fast_priv),
 	.enqueue	=	pfifo_fast_enqueue,
@@ -670,6 +670,26 @@ static void attach_one_default_qdisc(struct net_device *dev,
 	dev_queue->qdisc_sleeping = qdisc;
 }
 
+static void attach_default_qdiscs(struct net_device *dev)
+{
+	struct netdev_queue *txq;
+	struct Qdisc *qdisc;
+
+	txq = netdev_get_tx_queue(dev, 0);
+
+	if (!netif_is_multiqueue(dev) || dev->tx_queue_len == 0) {
+		netdev_for_each_tx_queue(dev, attach_one_default_qdisc, NULL);
+		dev->qdisc = txq->qdisc_sleeping;
+		atomic_inc(&dev->qdisc->refcnt);
+	} else {
+		qdisc = qdisc_create_dflt(dev, txq, &mq_qdisc_ops, TC_H_ROOT);
+		if (qdisc) {
+			qdisc->ops->attach(qdisc);
+			dev->qdisc = qdisc;
+		}
+	}
+}
+
 static void transition_one_qdisc(struct net_device *dev,
 				 struct netdev_queue *dev_queue,
 				 void *_need_watchdog)
@@ -689,7 +709,6 @@ static void transition_one_qdisc(struct net_device *dev,
 
 void dev_activate(struct net_device *dev)
 {
-	struct netdev_queue *txq;
 	int need_watchdog;
 
 	/* No queueing discipline is attached to device;
@@ -698,13 +717,8 @@ void dev_activate(struct net_device *dev)
 	   virtual interfaces
 	 */
 
-	if (dev->qdisc == &noop_qdisc) {
-		netdev_for_each_tx_queue(dev, attach_one_default_qdisc, NULL);
-
-		txq = netdev_get_tx_queue(dev, 0);
-		dev->qdisc = txq->qdisc_sleeping;
-		atomic_inc(&dev->qdisc->refcnt);
-	}
+	if (dev->qdisc == &noop_qdisc)
+		attach_default_qdiscs(dev);
 
 	if (!netif_carrier_ok(dev))
 		/* Delay activation until next carrier-on event */
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
new file mode 100644
index 0000000..fadaa6d
--- /dev/null
+++ b/net/sched/sch_mq.c
@@ -0,0 +1,244 @@
+/*
+ * net/sched/sch_mq.c		Classful multiqueue dummy scheduler
+ *
+ * Copyright (c) 2009 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+
+struct mq_sched {
+	struct Qdisc		**qdiscs;
+};
+
+static int mq_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct mq_sched *priv = qdisc_priv(sch);
+	struct netdev_queue *dev_queue;
+	struct Qdisc *qdisc;
+	unsigned int ntx;
+
+	if (sch->parent != TC_H_ROOT)
+		return -EOPNOTSUPP;
+
+	if (!netif_is_multiqueue(dev))
+		return -EOPNOTSUPP;
+
+	/* pre-allocate qdiscs, attachment can't fail */
+	priv->qdiscs = kcalloc(dev->num_tx_queues, sizeof(priv->qdiscs[0]),
+			       GFP_KERNEL);
+	if (priv->qdiscs == NULL)
+		return -ENOMEM;
+
+	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
+		dev_queue = netdev_get_tx_queue(dev, ntx);
+		qdisc = qdisc_create_dflt(dev, dev_queue, &pfifo_fast_ops,
+					  TC_H_MAKE(TC_H_MAJ(sch->handle),
+						    TC_H_MIN(ntx + 1)));
+		if (qdisc == NULL)
+			goto err;
+		qdisc->flags |= TCQ_F_CAN_BYPASS;
+		priv->qdiscs[ntx] = qdisc;
+	}
+
+	return 0;
+
+err:
+	while (ntx > 0)
+		qdisc_destroy(priv->qdiscs[--ntx]);
+	kfree(priv->qdiscs);
+	return -ENOMEM;
+}
+
+static void mq_attach(struct Qdisc *sch)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct mq_sched *priv = qdisc_priv(sch);
+	struct Qdisc *qdisc;
+	unsigned int ntx;
+
+	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
+		qdisc = priv->qdiscs[ntx];
+		qdisc = dev_graft_qdisc(qdisc->dev_queue, qdisc);
+		if (qdisc)
+			qdisc_destroy(qdisc);
+	}
+	kfree(priv->qdiscs);
+}
+
+static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct Qdisc *qdisc;
+	unsigned int ntx;
+
+	sch->q.qlen = 0;
+	memset(&sch->bstats, 0, sizeof(sch->bstats));
+	memset(&sch->qstats, 0, sizeof(sch->qstats));
+
+	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
+		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc;
+		sch->q.qlen		+= qdisc->q.qlen;
+		sch->bstats.bytes	+= qdisc->bstats.bytes;
+		sch->bstats.packets	+= qdisc->bstats.packets;
+		sch->qstats.qlen	+= qdisc->qstats.qlen;
+		sch->qstats.backlog	+= qdisc->qstats.backlog;
+		sch->qstats.drops	+= qdisc->qstats.drops;
+		sch->qstats.requeues	+= qdisc->qstats.requeues;
+		sch->qstats.overlimits	+= qdisc->qstats.overlimits;
+	}
+	return 0;
+}
+
+static struct netdev_queue *mq_queue_get(struct Qdisc *sch, unsigned long arg)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	unsigned long ntx = arg - 1;
+
+	if (ntx >= dev->num_tx_queues)
+		return NULL;
+	return netdev_get_tx_queue(dev, ntx);
+}
+
+static int mq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
+		    struct Qdisc **old)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct netdev_queue *dev_queue;
+
+	dev_queue = mq_queue_get(sch, arg);
+	if (dev_queue == NULL)
+		return -ENOENT;
+
+	if (dev->flags & IFF_UP)
+		dev_deactivate(dev);
+
+	*old = dev_graft_qdisc(dev_queue, new);
+
+	if (dev->flags & IFF_UP)
+		dev_activate(dev);
+	return 0;
+}
+
+static struct Qdisc *mq_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	struct netdev_queue *dev_queue;
+
+	dev_queue = mq_queue_get(sch, arg);
+	if (dev_queue == NULL)
+		return NULL;
+
+	return dev_queue->qdisc;
+}
+
+static unsigned long mq_get(struct Qdisc *sch, u32 classid)
+{
+	unsigned int ntx = TC_H_MIN(classid);
+
+	if (!mq_queue_get(sch, ntx))
+		return 0;
+	return ntx;
+}
+
+static void mq_put(struct Qdisc *sch, unsigned long cl)
+{
+	return;
+}
+
+static int mq_change(struct Qdisc *sch, u32 handle, u32 parent,
+		     struct nlattr **tca, unsigned long *arg)
+{
+	if (!mq_queue_get(sch, *arg))
+		return -ENOENT;
+	return 0;
+}
+
+static int mq_delete(struct Qdisc *sch, unsigned long cl)
+{
+	return -EOPNOTSUPP;
+}
+
+static int mq_dump_class(struct Qdisc *sch, unsigned long cl,
+			 struct sk_buff *skb, struct tcmsg *tcm)
+{
+	struct netdev_queue *dev_queue;
+
+	dev_queue = mq_queue_get(sch, cl);
+	if (dev_queue == NULL)
+		return -ENOENT;
+
+	tcm->tcm_parent = TC_H_ROOT;
+	tcm->tcm_handle |= TC_H_MIN(cl);
+	if (dev_queue->qdisc)
+		tcm->tcm_info = dev_queue->qdisc->handle;
+	return 0;
+}
+
+static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
+			       struct gnet_dump *d)
+{
+	struct netdev_queue *dev_queue;
+
+	dev_queue = mq_queue_get(sch, cl);
+	sch = dev_queue->qdisc_sleeping;
+
+	if (gnet_stats_copy_basic(d, &sch->bstats) < 0 ||
+	    gnet_stats_copy_queue(d, &sch->qstats) < 0)
+		return -1;
+	return 0;
+}
+
+static void mq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	unsigned int ntx;
+
+	if (arg->stop)
+		return;
+
+	arg->count = arg->skip;
+	for (ntx = arg->skip; ntx < dev->num_tx_queues; ntx++) {
+		if (arg->fn(sch, ntx + 1, arg) < 0) {
+			arg->stop = 1;
+			break;
+		}
+		arg->count++;
+	}
+}
+
+static const struct Qdisc_class_ops mq_class_ops = {
+	.graft		= mq_graft,
+	.leaf		= mq_leaf,
+	.get		= mq_get,
+	.put		= mq_put,
+	.change		= mq_change,
+	.delete		= mq_delete,
+	.walk		= mq_walk,
+	.tcf_chain	= NULL,
+	.bind_tcf	= NULL,
+	.unbind_tcf	= NULL,
+	.dump		= mq_dump_class,
+	.dump_stats	= mq_dump_class_stats,
+};
+
+struct Qdisc_ops mq_qdisc_ops __read_mostly = {
+	.cl_ops		= &mq_class_ops,
+	.id		= "mq",
+	.priv_size	= sizeof(struct mq_sched),
+	.init		= mq_init,
+	//.reset	= mq_reset,
+	//.destroy	= mq_destroy,
+	.attach		= mq_attach,
+	.dump		= mq_dump,
+	.owner		= THIS_MODULE,
+};

--------------090302080206090701050004--
