From: Jiri Kosina <jikos@kernel.org>
Subject: [RFC PATCH] net: sched: convert qdisc linked list to hashtable (was
 Re: Deleting child qdisc doesn't reset parent to default qdisc?)
Date: Thu, 7 Jul 2016 11:04:48 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1607071102010.24757@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>  <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>  <20160414151813.GE3715@orbyte.nwl.cc>  <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
 <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>  <5710E1C1.2090209@mojatatu.com> <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Phil Sutter <phil@nwl.cc>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Apr 2016, Eric Dumazet wrote:

> Anyway, we probably need to improve our ability to understand qdisc 
> hierarchies. Having some hidden qdiscs is the real problem here.
> 
> We need to add some hash table so that qdisc_match_from_root() does not 
> have to scan hundred of qdiscs.

So how about something like the patch below? I already have preliminary 
patches on top which unhide the default qdiscs, but let's make this one 
step after the other.

Thanks.




From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] net: sched: convert qdisc linked list to hashtable

Convert the per-device linked list into a hashtable. The primary motivation
for this change is that currently, we're not tracking all the qdiscs in
hierarchy (e.g. excluding default qdiscs), as the lookup performed over the
linked list by qdisc_match_from_root() is rather expensive.

The ultimate goal is to get rid of hidden qdiscs completely, which will bring
much more determinism in user experience.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 include/linux/netdevice.h |  2 ++
 include/net/pkt_sched.h   |  4 ++--
 include/net/sch_generic.h |  2 +-
 net/core/dev.c            |  1 +
 net/sched/sch_api.c       | 23 +++++++++++++----------
 net/sched/sch_generic.c   |  6 +++---
 net/sched/sch_mq.c        |  2 +-
 net/sched/sch_mqprio.c    |  2 +-
 8 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f45929c..630838e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -52,6 +52,7 @@
 #include <uapi/linux/netdevice.h>
 #include <uapi/linux/if_bonding.h>
 #include <uapi/linux/pkt_cls.h>
+#include <linux/hashtable.h>
 
 struct netpoll_info;
 struct device;
@@ -1778,6 +1779,7 @@ struct net_device {
 	unsigned int		num_tx_queues;
 	unsigned int		real_num_tx_queues;
 	struct Qdisc		*qdisc;
+	DECLARE_HASHTABLE	(qdisc_hash, 16);
 	unsigned long		tx_queue_len;
 	spinlock_t		tx_global_lock;
 	int			watchdog_timeo;
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index fea53f4..8ba11b4 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -90,8 +90,8 @@ int unregister_qdisc(struct Qdisc_ops *qops);
 void qdisc_get_default(char *id, size_t len);
 int qdisc_set_default(const char *id);
 
-void qdisc_list_add(struct Qdisc *q);
-void qdisc_list_del(struct Qdisc *q);
+void qdisc_hash_add(struct Qdisc *q);
+void qdisc_hash_del(struct Qdisc *q);
 struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
 struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
 struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 62d5531..26f5cb3 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -67,7 +67,7 @@ struct Qdisc {
 	u32			limit;
 	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
-	struct list_head	list;
+	struct hlist_node       hash;
 	u32			handle;
 	u32			parent;
 	int			(*reshape_fail)(struct sk_buff *skb,
diff --git a/net/core/dev.c b/net/core/dev.c
index 904ff43..edc1617 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7511,6 +7511,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	INIT_LIST_HEAD(&dev->all_adj_list.lower);
 	INIT_LIST_HEAD(&dev->ptype_all);
 	INIT_LIST_HEAD(&dev->ptype_specific);
+	hash_init(dev->qdisc_hash);
 	dev->priv_flags = IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM;
 	setup(dev);
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ddf047d..82953cb 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -29,6 +29,7 @@
 #include <linux/hrtimer.h>
 #include <linux/lockdep.h>
 #include <linux/slab.h>
+#include <linux/hashtable.h>
 
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -265,33 +266,33 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 	    root->handle == handle)
 		return root;
 
-	list_for_each_entry_rcu(q, &root->list, list) {
+	hash_for_each_possible_rcu(qdisc_dev(root)->qdisc_hash, q, hash, handle) {
 		if (q->handle == handle)
 			return q;
 	}
 	return NULL;
 }
 
-void qdisc_list_add(struct Qdisc *q)
+void qdisc_hash_add(struct Qdisc *q)
 {
 	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {
 		struct Qdisc *root = qdisc_dev(q)->qdisc;
 
 		WARN_ON_ONCE(root == &noop_qdisc);
 		ASSERT_RTNL();
-		list_add_tail_rcu(&q->list, &root->list);
+		hash_add_rcu(qdisc_dev(q)->qdisc_hash, &q->hash, q->handle);
 	}
 }
-EXPORT_SYMBOL(qdisc_list_add);
+EXPORT_SYMBOL(qdisc_hash_add);
 
-void qdisc_list_del(struct Qdisc *q)
+void qdisc_hash_del(struct Qdisc *q)
 {
 	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {
 		ASSERT_RTNL();
-		list_del_rcu(&q->list);
+		hash_del_rcu(&q->hash);
 	}
 }
-EXPORT_SYMBOL(qdisc_list_del);
+EXPORT_SYMBOL(qdisc_hash_del);
 
 struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 {
@@ -1004,7 +1005,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				goto err_out4;
 		}
 
-		qdisc_list_add(sch);
+		qdisc_hash_add(sch);
 
 		return sch;
 	}
@@ -1440,6 +1441,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 {
 	int ret = 0, q_idx = *q_idx_p;
 	struct Qdisc *q;
+	int b;
 
 	if (!root)
 		return 0;
@@ -1454,7 +1456,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 			goto done;
 		q_idx++;
 	}
-	list_for_each_entry(q, &root->list, list) {
+	hash_for_each(qdisc_dev(root)->qdisc_hash, b, q, hash) {
 		if (q_idx < s_q_idx) {
 			q_idx++;
 			continue;
@@ -1771,6 +1773,7 @@ static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
 			       int *t_p, int s_t)
 {
 	struct Qdisc *q;
+	int b;
 
 	if (!root)
 		return 0;
@@ -1778,7 +1781,7 @@ static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
 	if (tc_dump_tclass_qdisc(root, skb, tcm, cb, t_p, s_t) < 0)
 		return -1;
 
-	list_for_each_entry(q, &root->list, list) {
+	hash_for_each_rcu(qdisc_dev(root)->qdisc_hash, b, q, hash) {
 		if (tc_dump_tclass_qdisc(q, skb, tcm, cb, t_p, s_t) < 0)
 			return -1;
 	}
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index f9e0e9c..7efc923 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -378,7 +378,6 @@ struct Qdisc noop_qdisc = {
 	.dequeue	=	noop_dequeue,
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noop_qdisc_ops,
-	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
 	.dev_queue	=	&noop_netdev_queue,
 	.busylock	=	__SPIN_LOCK_UNLOCKED(noop_qdisc.busylock),
@@ -565,7 +564,6 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 		sch = (struct Qdisc *) QDISC_ALIGN((unsigned long) p);
 		sch->padded = (char *) sch - (char *) p;
 	}
-	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
 
 	spin_lock_init(&sch->busylock);
@@ -645,7 +643,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 		return;
 
 #ifdef CONFIG_NET_SCHED
-	qdisc_list_del(qdisc);
+	qdisc_hash_del(qdisc);
 
 	qdisc_put_stab(rtnl_dereference(qdisc->stab));
 #endif
@@ -732,6 +730,8 @@ static void attach_default_qdiscs(struct net_device *dev)
 			qdisc->ops->attach(qdisc);
 		}
 	}
+	if (dev->qdisc)
+		qdisc_hash_add(dev->qdisc);
 }
 
 static void transition_one_qdisc(struct net_device *dev,
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 56a77b8..3bee15d 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -88,7 +88,7 @@ static void mq_attach(struct Qdisc *sch)
 			qdisc_destroy(old);
 #ifdef CONFIG_NET_SCHED
 		if (ntx < dev->real_num_tx_queues)
-			qdisc_list_add(qdisc);
+			qdisc_hash_add(qdisc);
 #endif
 
 	}
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index b8002ce..dbfb3a5 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -182,7 +182,7 @@ static void mqprio_attach(struct Qdisc *sch)
 		if (old)
 			qdisc_destroy(old);
 		if (ntx < dev->real_num_tx_queues)
-			qdisc_list_add(qdisc);
+			qdisc_hash_add(qdisc);
 	}
 	kfree(priv->qdiscs);
 	priv->qdiscs = NULL;

-- 
Jiri Kosina
SUSE Labs
