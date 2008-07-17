From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 17/31]: pkt_sched: Add and use qdisc_root() and
 qdisc_root_lock().
Date: Thu, 17 Jul 2008 05:17:10 -0700 (PDT)
Message-ID: <20080717.051710.82593078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


When code wants to lock the qdisc tree state, the logic
operation it's doing is locking the top-level qdisc that
sits of the root of the netdev_queue.

Add qdisc_root_lock() to represent this and convert the
easiest cases.

In order for this to work out in all cases, we have to
hook up the noop_qdisc to a dummy netdev_queue.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/net/sch_generic.h |   12 ++++++++++++
 net/sched/sch_api.c       |    8 ++++----
 net/sched/sch_cbq.c       |    9 +++++----
 net/sched/sch_generic.c   |   21 ++++++++++++++++-----
 net/sched/sch_hfsc.c      |    4 ++--
 net/sched/sch_htb.c       |   18 ++++++++++--------
 net/sched/sch_netem.c     |    9 ++++++---
 7 files changed, 55 insertions(+), 26 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index bc2a09d..9241782 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -161,6 +161,18 @@ struct tcf_proto
 	struct tcf_proto_ops	*ops;
 };
 
+static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
+{
+	return qdisc->dev_queue->qdisc;
+}
+
+static inline spinlock_t *qdisc_root_lock(struct Qdisc *qdisc)
+{
+	struct Qdisc *root = qdisc_root(qdisc);
+
+	return &root->dev_queue->lock;
+}
+
 static inline struct net_device *qdisc_dev(struct Qdisc *qdisc)
 {
 	return qdisc->dev_queue->dev;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 830ccc5..19c244a 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -633,7 +633,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS])) == 0) {
 		if (tca[TCA_RATE]) {
 			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
-						&sch->dev_queue->lock,
+						qdisc_root_lock(sch),
 						tca[TCA_RATE]);
 			if (err) {
 				/*
@@ -675,7 +675,7 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 	}
 	if (tca[TCA_RATE])
 		gen_replace_estimator(&sch->bstats, &sch->rate_est,
-				      &sch->dev_queue->lock, tca[TCA_RATE]);
+				      qdisc_root_lock(sch), tca[TCA_RATE]);
 	return 0;
 }
 
@@ -967,7 +967,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	q->qstats.qlen = q->q.qlen;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
-					 TCA_XSTATS, &q->dev_queue->lock, &d) < 0)
+					 TCA_XSTATS, qdisc_root_lock(q), &d) < 0)
 		goto nla_put_failure;
 
 	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
@@ -1216,7 +1216,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 		goto nla_put_failure;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
-					 TCA_XSTATS, &q->dev_queue->lock, &d) < 0)
+					 TCA_XSTATS, qdisc_root_lock(q), &d) < 0)
 		goto nla_put_failure;
 
 	if (cl_ops->dump_stats && cl_ops->dump_stats(q, cl, &d) < 0)
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 4efc836..37ae653 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1744,12 +1744,13 @@ static void cbq_put(struct Qdisc *sch, unsigned long arg)
 
 	if (--cl->refcnt == 0) {
 #ifdef CONFIG_NET_CLS_ACT
+		spinlock_t *root_lock = qdisc_root_lock(sch);
 		struct cbq_sched_data *q = qdisc_priv(sch);
 
-		spin_lock_bh(&sch->dev_queue->lock);
+		spin_lock_bh(root_lock);
 		if (q->rx_class == cl)
 			q->rx_class = NULL;
-		spin_unlock_bh(&sch->dev_queue->lock);
+		spin_unlock_bh(root_lock);
 #endif
 
 		cbq_destroy_class(sch, cl);
@@ -1828,7 +1829,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev_queue->lock,
+					      qdisc_root_lock(sch),
 					      tca[TCA_RATE]);
 		return 0;
 	}
@@ -1919,7 +1920,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 
 	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev_queue->lock, tca[TCA_RATE]);
+				  qdisc_root_lock(sch), tca[TCA_RATE]);
 
 	*arg = (unsigned long)cl;
 	return 0;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ac208c2..739a871 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -151,14 +151,17 @@ static inline int qdisc_restart(struct netdev_queue *txq,
 {
 	int ret = NETDEV_TX_BUSY;
 	struct net_device *dev;
+	spinlock_t *root_lock;
 	struct sk_buff *skb;
 
 	/* Dequeue packet */
 	if (unlikely((skb = dequeue_skb(q)) == NULL))
 		return 0;
 
-	/* And release queue */
-	spin_unlock(&txq->lock);
+	root_lock = qdisc_root_lock(q);
+
+	/* And release qdisc */
+	spin_unlock(root_lock);
 
 	dev = txq->dev;
 
@@ -167,7 +170,7 @@ static inline int qdisc_restart(struct netdev_queue *txq,
 		ret = dev_hard_start_xmit(skb, dev, txq);
 	HARD_TX_UNLOCK(dev, txq);
 
-	spin_lock(&txq->lock);
+	spin_lock(root_lock);
 
 	switch (ret) {
 	case NETDEV_TX_OK:
@@ -345,12 +348,18 @@ struct Qdisc_ops noop_qdisc_ops __read_mostly = {
 	.owner		=	THIS_MODULE,
 };
 
+static struct netdev_queue noop_netdev_queue = {
+	.lock		=	__SPIN_LOCK_UNLOCKED(noop_netdev_queue.lock),
+	.qdisc		=	&noop_qdisc,
+};
+
 struct Qdisc noop_qdisc = {
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noop_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
+	.dev_queue	=	&noop_netdev_queue,
 };
 EXPORT_SYMBOL(noop_qdisc);
 
@@ -666,19 +675,21 @@ static bool some_qdisc_is_running(struct net_device *dev, int lock)
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *dev_queue;
+		spinlock_t *root_lock;
 		struct Qdisc *q;
 		int val;
 
 		dev_queue = netdev_get_tx_queue(dev, i);
 		q = dev_queue->qdisc;
+		root_lock = qdisc_root_lock(q);
 
 		if (lock)
-			spin_lock_bh(&dev_queue->lock);
+			spin_lock_bh(root_lock);
 
 		val = test_bit(__QDISC_STATE_RUNNING, &q->state);
 
 		if (lock)
-			spin_unlock_bh(&dev_queue->lock);
+			spin_unlock_bh(root_lock);
 
 		if (val)
 			return true;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 997d520..5090708 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1045,7 +1045,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev_queue->lock,
+					      qdisc_root_lock(sch),
 					      tca[TCA_RATE]);
 		return 0;
 	}
@@ -1104,7 +1104,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev_queue->lock, tca[TCA_RATE]);
+				  qdisc_root_lock(sch), tca[TCA_RATE]);
 	*arg = (unsigned long)cl;
 	return 0;
 }
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c8ca54c..ee48457 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1039,11 +1039,12 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 
 static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
+	spinlock_t *root_lock = qdisc_root_lock(sch);
 	struct htb_sched *q = qdisc_priv(sch);
 	struct nlattr *nest;
 	struct tc_htb_glob gopt;
 
-	spin_lock_bh(&sch->dev_queue->lock);
+	spin_lock_bh(root_lock);
 
 	gopt.direct_pkts = q->direct_pkts;
 	gopt.version = HTB_VER;
@@ -1057,11 +1058,11 @@ static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 	NLA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
 	nla_nest_end(skb, nest);
 
-	spin_unlock_bh(&sch->dev_queue->lock);
+	spin_unlock_bh(root_lock);
 	return skb->len;
 
 nla_put_failure:
-	spin_unlock_bh(&sch->dev_queue->lock);
+	spin_unlock_bh(root_lock);
 	nla_nest_cancel(skb, nest);
 	return -1;
 }
@@ -1070,10 +1071,11 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 			  struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
+	spinlock_t *root_lock = qdisc_root_lock(sch);
 	struct nlattr *nest;
 	struct tc_htb_opt opt;
 
-	spin_lock_bh(&sch->dev_queue->lock);
+	spin_lock_bh(root_lock);
 	tcm->tcm_parent = cl->parent ? cl->parent->common.classid : TC_H_ROOT;
 	tcm->tcm_handle = cl->common.classid;
 	if (!cl->level && cl->un.leaf.q)
@@ -1095,11 +1097,11 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	NLA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
 
 	nla_nest_end(skb, nest);
-	spin_unlock_bh(&sch->dev_queue->lock);
+	spin_unlock_bh(root_lock);
 	return skb->len;
 
 nla_put_failure:
-	spin_unlock_bh(&sch->dev_queue->lock);
+	spin_unlock_bh(root_lock);
 	nla_nest_cancel(skb, nest);
 	return -1;
 }
@@ -1365,7 +1367,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			goto failure;
 
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev_queue->lock,
+				  qdisc_root_lock(sch),
 				  tca[TCA_RATE] ? : &est.nla);
 		cl->refcnt = 1;
 		cl->children = 0;
@@ -1420,7 +1422,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	} else {
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev_queue->lock,
+					      qdisc_root_lock(sch),
 					      tca[TCA_RATE]);
 		sch_tree_lock(sch);
 	}
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index bc585f2..c5ea40c 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -180,7 +180,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	 * skb will be queued.
 	 */
 	if (count > 1 && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL) {
-		struct Qdisc *rootq = sch->dev_queue->qdisc;
+		struct Qdisc *rootq = qdisc_root(sch);
 		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
 		q->duplicate = 0;
 
@@ -319,6 +319,7 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	unsigned long n = nla_len(attr)/sizeof(__s16);
 	const __s16 *data = nla_data(attr);
+	spinlock_t *root_lock;
 	struct disttable *d;
 	int i;
 
@@ -333,9 +334,11 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 	for (i = 0; i < n; i++)
 		d->table[i] = data[i];
 
-	spin_lock_bh(&sch->dev_queue->lock);
+	root_lock = qdisc_root_lock(sch);
+
+	spin_lock_bh(root_lock);
 	d = xchg(&q->delay_dist, d);
-	spin_unlock_bh(&sch->dev_queue->lock);
+	spin_unlock_bh(root_lock);
 
 	kfree(d);
 	return 0;
-- 
1.5.6.2.255.gbed62

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
