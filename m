From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH v2 1/2] net: sched: make default fifo qdiscs appear in the
 dump
Date: Wed, 8 Mar 2017 13:03:42 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1703081302240.31814@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>

The original reason [1] for having hidden qdiscs (potential scalability
issues in qdisc_match_from_root() with single linked list in case of large
amount of qdiscs) has been invalidated by 59cc1f61f0 ("net: sched: convert
qdisc linked list to hashtable").

This allows us for bringing more clarity and determinism into the dump by
making default pfifo qdiscs visible.

We're not turning this on by default though, at it was deemed [2] too
intrusive / unnecessary change of default behavior towards userspace.
Instead, TCA_DUMP_INVISIBLE netlink attribute is introduced, which allows
applications to request complete qdisc hierarchy dump, including the
ones that have always been implicit/invisible.

Singleton noop_qdisc stays invisible, as teaching the whole infrastructure
about singletons would require quite some surgery with very little gain
(seeing no qdisc or seeing noop qdisc in the dump is probably setting
the same user expectation).

[1] http://lkml.kernel.org/r/1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com
[2] http://lkml.kernel.org/r/20161021.105935.1907696543877061916.davem@davemloft.net

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---

v1 -> v2: introduce exception for singleton noop_qdisc

 include/net/pkt_sched.h        |  2 +-
 include/net/sch_generic.h      |  1 +
 include/uapi/linux/rtnetlink.h |  1 +
 net/sched/sch_api.c            | 42 ++++++++++++++++++++++++++++++------------
 net/sched/sch_cbq.c            |  5 +++++
 net/sched/sch_drr.c            |  2 ++
 net/sched/sch_dsmark.c         |  2 ++
 net/sched/sch_generic.c        |  2 +-
 net/sched/sch_hfsc.c           |  4 ++++
 net/sched/sch_htb.c            |  2 ++
 net/sched/sch_mq.c             |  2 +-
 net/sched/sch_mqprio.c         |  2 +-
 net/sched/sch_multiq.c         |  2 ++
 net/sched/sch_prio.c           |  5 ++++-
 net/sched/sch_qfq.c            |  2 ++
 net/sched/sch_red.c            |  2 ++
 net/sched/sch_sfb.c            |  2 ++
 net/sched/sch_tbf.c            |  2 ++
 18 files changed, 65 insertions(+), 17 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index cd334c9584e9..0625eac2c601 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -90,7 +90,7 @@ int unregister_qdisc(struct Qdisc_ops *qops);
 void qdisc_get_default(char *id, size_t len);
 int qdisc_set_default(const char *id);
 
-void qdisc_hash_add(struct Qdisc *q);
+void qdisc_hash_add(struct Qdisc *q, bool invisible);
 void qdisc_hash_del(struct Qdisc *q);
 struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
 struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e6aa0a249672..e7dca250d115 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -66,6 +66,7 @@ struct Qdisc {
 #define TCQ_F_NOPARENT		0x40 /* root of its hierarchy :
 				      * qdisc_tree_decrease_qlen() should stop.
 				      */
+#define TCQ_F_INVISIBLE		0x80 /* invisible by default in dump */
 	u32			limit;
 	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 262f0379d83a..c7de00e09797 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -542,6 +542,7 @@ enum {
 	TCA_FCNT,
 	TCA_STATS2,
 	TCA_STAB,
+	TCA_DUMP_INVISIBLE,
 	TCA_PAD,
 	__TCA_MAX
 };
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 206dc24add3a..8e4e6ab1847a 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -274,7 +274,7 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 	return NULL;
 }
 
-void qdisc_hash_add(struct Qdisc *q)
+void qdisc_hash_add(struct Qdisc *q, bool invisible)
 {
 	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {
 		struct Qdisc *root = qdisc_dev(q)->qdisc;
@@ -282,6 +282,8 @@ void qdisc_hash_add(struct Qdisc *q)
 		WARN_ON_ONCE(root == &noop_qdisc);
 		ASSERT_RTNL();
 		hash_add_rcu(qdisc_dev(q)->qdisc_hash, &q->hash, q->handle);
+		if (invisible)
+			q->flags |= TCQ_F_INVISIBLE;
 	}
 }
 EXPORT_SYMBOL(qdisc_hash_add);
@@ -1004,7 +1006,7 @@ static struct Qdisc *qdisc_create(struct net_device *dev,
 				goto err_out4;
 		}
 
-		qdisc_hash_add(sch);
+		qdisc_hash_add(sch, false);
 
 		return sch;
 	}
@@ -1400,9 +1402,14 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	return -1;
 }
 
-static bool tc_qdisc_dump_ignore(struct Qdisc *q)
+static bool tc_qdisc_dump_ignore(struct Qdisc *q, bool dump_invisible)
 {
-	return (q->flags & TCQ_F_BUILTIN) ? true : false;
+	if (q->flags & TCQ_F_BUILTIN)
+		return true;
+	if ((q->flags & TCQ_F_INVISIBLE) && !dump_invisible)
+		return true;
+
+	return false;
 }
 
 static int qdisc_notify(struct net *net, struct sk_buff *oskb,
@@ -1416,12 +1423,12 @@ static int qdisc_notify(struct net *net, struct sk_buff *oskb,
 	if (!skb)
 		return -ENOBUFS;
 
-	if (old && !tc_qdisc_dump_ignore(old)) {
+	if (old && !tc_qdisc_dump_ignore(old, false)) {
 		if (tc_fill_qdisc(skb, old, clid, portid, n->nlmsg_seq,
 				  0, RTM_DELQDISC) < 0)
 			goto err_out;
 	}
-	if (new && !tc_qdisc_dump_ignore(new)) {
+	if (new && !tc_qdisc_dump_ignore(new, false)) {
 		if (tc_fill_qdisc(skb, new, clid, portid, n->nlmsg_seq,
 				  old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
 			goto err_out;
@@ -1438,7 +1445,8 @@ static int qdisc_notify(struct net *net, struct sk_buff *oskb,
 
 static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 			      struct netlink_callback *cb,
-			      int *q_idx_p, int s_q_idx, bool recur)
+			      int *q_idx_p, int s_q_idx, bool recur,
+			      bool dump_invisible)
 {
 	int ret = 0, q_idx = *q_idx_p;
 	struct Qdisc *q;
@@ -1451,7 +1459,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 	if (q_idx < s_q_idx) {
 		q_idx++;
 	} else {
-		if (!tc_qdisc_dump_ignore(q) &&
+		if (!tc_qdisc_dump_ignore(q, dump_invisible) &&
 		    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).portid,
 				  cb->nlh->nlmsg_seq, NLM_F_MULTI,
 				  RTM_NEWQDISC) <= 0)
@@ -1473,7 +1481,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 			q_idx++;
 			continue;
 		}
-		if (!tc_qdisc_dump_ignore(q) &&
+		if (!tc_qdisc_dump_ignore(q, dump_invisible) &&
 		    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).portid,
 				  cb->nlh->nlmsg_seq, NLM_F_MULTI,
 				  RTM_NEWQDISC) <= 0)
@@ -1495,12 +1503,21 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 	int idx, q_idx;
 	int s_idx, s_q_idx;
 	struct net_device *dev;
+	const struct nlmsghdr *nlh = cb->nlh;
+	struct tcmsg *tcm = nlmsg_data(nlh);
+	struct nlattr *tca[TCA_MAX + 1];
+	int err;
 
 	s_idx = cb->args[0];
 	s_q_idx = q_idx = cb->args[1];
 
 	idx = 0;
 	ASSERT_RTNL();
+
+	err = nlmsg_parse(nlh, sizeof(*tcm), tca, TCA_MAX, NULL);
+	if (err < 0)
+		return err;
+
 	for_each_netdev(net, dev) {
 		struct netdev_queue *dev_queue;
 
@@ -1511,13 +1528,14 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 		q_idx = 0;
 
 		if (tc_dump_qdisc_root(dev->qdisc, skb, cb, &q_idx, s_q_idx,
-				       true) < 0)
+				       true, tca[TCA_DUMP_INVISIBLE]) < 0)
 			goto done;
 
 		dev_queue = dev_ingress_queue(dev);
 		if (dev_queue &&
 		    tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb,
-				       &q_idx, s_q_idx, false) < 0)
+				       &q_idx, s_q_idx, false,
+				       tca[TCA_DUMP_INVISIBLE]) < 0)
 			goto done;
 
 cont:
@@ -1761,7 +1779,7 @@ static int tc_dump_tclass_qdisc(struct Qdisc *q, struct sk_buff *skb,
 {
 	struct qdisc_dump_args arg;
 
-	if (tc_qdisc_dump_ignore(q) ||
+	if (tc_qdisc_dump_ignore(q, false) ||
 	    *t_p < s_t || !q->ops->cl_ops ||
 	    (tcm->tcm_parent &&
 	     TC_H_MAJ(tcm->tcm_parent) != q->handle)) {
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index beb554aa8cfb..a8d4da17a299 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1160,6 +1160,8 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 				      sch->handle);
 	if (!q->link.q)
 		q->link.q = &noop_qdisc;
+	else
+		qdisc_hash_add(q->link.q, true);
 
 	q->link.priority = TC_CBQ_MAXPRIO - 1;
 	q->link.priority2 = TC_CBQ_MAXPRIO - 1;
@@ -1599,6 +1601,9 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	cl->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, classid);
 	if (!cl->q)
 		cl->q = &noop_qdisc;
+	else
+		qdisc_hash_add(cl->q, true);
+
 	cl->common.classid = classid;
 	cl->tparent = parent;
 	cl->qdisc = sch;
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 8af5c59eef84..ec749385f7e0 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -117,6 +117,8 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 					       &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
+	else
+		qdisc_hash_add(cl->qdisc, true);
 
 	if (tca[TCA_RATE]) {
 		err = gen_replace_estimator(&cl->bstats, NULL, &cl->rate_est,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 1308bbf460f7..8b0099667e27 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -367,6 +367,8 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	p->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, sch->handle);
 	if (p->q == NULL)
 		p->q = &noop_qdisc;
+	else
+		qdisc_hash_add(p->q, true);
 
 	pr_debug("%s: qdisc %p\n", __func__, p->q);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6cfb6e9038c2..e54c6ccf1ada 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -795,7 +795,7 @@ static void attach_default_qdiscs(struct net_device *dev)
 	}
 #ifdef CONFIG_NET_SCHED
 	if (dev->qdisc)
-		qdisc_hash_add(dev->qdisc);
+		qdisc_hash_add(dev->qdisc, false);
 #endif
 }
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 000f1d36128e..32081a696a3a 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1066,6 +1066,8 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 				      &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
+	else
+		qdisc_hash_add(cl->qdisc, true);
 	INIT_LIST_HEAD(&cl->children);
 	cl->vt_tree = RB_ROOT;
 	cl->cf_tree = RB_ROOT;
@@ -1425,6 +1427,8 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 					  sch->handle);
 	if (q->root.qdisc == NULL)
 		q->root.qdisc = &noop_qdisc;
+	else
+		qdisc_hash_add(q->root.qdisc, true);
 	INIT_LIST_HEAD(&q->root.children);
 	q->root.vt_tree = RB_ROOT;
 	q->root.cf_tree = RB_ROOT;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c798d0de8a9d..a028fab05913 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1459,6 +1459,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		qdisc_class_hash_insert(&q->clhash, &cl->common);
 		if (parent)
 			parent->children++;
+		if (cl->un.leaf.q != &noop_qdisc)
+			qdisc_hash_add(cl->un.leaf.q, true);
 	} else {
 		if (tca[TCA_RATE]) {
 			err = gen_replace_estimator(&cl->bstats, NULL,
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 2bc8d7f8df16..c735ce06f4c1 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -88,7 +88,7 @@ static void mq_attach(struct Qdisc *sch)
 			qdisc_destroy(old);
 #ifdef CONFIG_NET_SCHED
 		if (ntx < dev->real_num_tx_queues)
-			qdisc_hash_add(qdisc);
+			qdisc_hash_add(qdisc, false);
 #endif
 
 	}
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index b5c502c78143..4587716b9775 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -182,7 +182,7 @@ static void mqprio_attach(struct Qdisc *sch)
 		if (old)
 			qdisc_destroy(old);
 		if (ntx < dev->real_num_tx_queues)
-			qdisc_hash_add(qdisc);
+			qdisc_hash_add(qdisc, false);
 	}
 	kfree(priv->qdiscs);
 	priv->qdiscs = NULL;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 9ffbb025b37e..73b68c00f82b 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -217,6 +217,8 @@ static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
 				sch_tree_lock(sch);
 				old = q->queues[i];
 				q->queues[i] = child;
+				if (child != &noop_qdisc)
+					qdisc_hash_add(child, true);
 
 				if (old != &noop_qdisc) {
 					qdisc_tree_reduce_backlog(old,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 8f575899adfa..f511ab70c5e7 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -192,8 +192,11 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 		qdisc_destroy(child);
 	}
 
-	for (i = oldbands; i < q->bands; i++)
+	for (i = oldbands; i < q->bands; i++) {
 		q->queues[i] = queues[i];
+		if (q->queues[i] != &noop_qdisc)
+			qdisc_hash_add(q->queues[i], true);
+	}
 
 	sch_tree_unlock(sch);
 	return 0;
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index ca0516e6f743..48d67f2c51af 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -494,6 +494,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 			goto destroy_class;
 	}
 
+	if (cl->qdisc != &noop_qdisc)
+		qdisc_hash_add(cl->qdisc, true);
 	sch_tree_lock(sch);
 	qdisc_class_hash_insert(&q->clhash, &cl->common);
 	sch_tree_unlock(sch);
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 249b2a18acbd..799ea6dd69b2 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -191,6 +191,8 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 			return PTR_ERR(child);
 	}
 
+	if (child != &noop_qdisc)
+		qdisc_hash_add(child, true);
 	sch_tree_lock(sch);
 	q->flags = ctl->flags;
 	q->limit = ctl->limit;
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 20a350bd1b1d..49ab6be43b71 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -512,6 +512,8 @@ static int sfb_change(struct Qdisc *sch, struct nlattr *opt)
 	if (IS_ERR(child))
 		return PTR_ERR(child);
 
+	if (child != &noop_qdisc)
+		qdisc_hash_add(child, true);
 	sch_tree_lock(sch);
 
 	qdisc_tree_reduce_backlog(q->qdisc, q->qdisc->q.qlen,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 303355c449ab..40c29a801391 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -396,6 +396,8 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 					  q->qdisc->qstats.backlog);
 		qdisc_destroy(q->qdisc);
 		q->qdisc = child;
+		if (child != &noop_qdisc);
+			qdisc_hash_add(child, true);
 	}
 	q->limit = qopt->limit;
 	if (tb[TCA_TBF_PBURST])
-- 
Jiri Kosina
SUSE Labs
