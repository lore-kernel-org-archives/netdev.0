From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH v2 3/3] net_sched: Add size table for qdiscs
Date: Sun, 20 Jul 2008 02:35:12 +0300
Message-ID: <20080719233512.12596.70920.stgit@fate.lan>
References: <20080719233441.12596.91242.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:59573 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390AbYGSXfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 19:35:14 -0400
In-Reply-To: <20080719233441.12596.91242.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add size table functions for qdiscs and calculate packet size in
qdisc_enqueue().

Based on patch by Patrick McHardy
 http://marc.info/?l=linux-netdev&m=115201979221729&w=2

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |   20 ++++++
 include/linux/rtnetlink.h |    1 
 include/net/pkt_sched.h   |    1 
 include/net/sch_generic.h |   25 +++++++
 net/sched/sch_api.c       |  151 ++++++++++++++++++++++++++++++++++++++++++++-
 net/sched/sch_generic.c   |    1 
 net/sched/sch_netem.c     |    5 +
 7 files changed, 199 insertions(+), 5 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 87f4e0f..e5de421 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -85,6 +85,26 @@ struct tc_ratespec
 
 #define TC_RTAB_SIZE	1024
 
+struct tc_sizespec {
+	unsigned char	cell_log;
+	unsigned char	size_log;
+	short		cell_align;
+	int		overhead;
+	unsigned int	linklayer;
+	unsigned int	mpu;
+	unsigned int	mtu;
+	unsigned int	tsize;
+};
+
+enum {
+	TCA_STAB_UNSPEC,
+	TCA_STAB_BASE,
+	TCA_STAB_DATA,
+	__TCA_STAB_MAX
+};
+
+#define TCA_STAB_MAX (__TCA_STAB_MAX - 1)
+
 /* FIFO section */
 
 struct tc_fifo_qopt
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index b358c70..f4d386c 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -482,6 +482,7 @@ enum
 	TCA_RATE,
 	TCA_FCNT,
 	TCA_STATS2,
+	TCA_STAB,
 	__TCA_MAX
 };
 
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index e4e3005..6affcfa 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -83,6 +83,7 @@ extern struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
 extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 		struct nlattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
+extern void qdisc_put_stab(struct qdisc_size_table *tab);
 
 extern void __qdisc_run(struct Qdisc *q);
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 8229520..db9ad65 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -29,6 +29,13 @@ enum qdisc_state_t
 	__QDISC_STATE_SCHED,
 };
 
+struct qdisc_size_table {
+	struct list_head	list;
+	struct tc_sizespec	szopts;
+	int			refcnt;
+	u16			data[];
+};
+
 struct Qdisc
 {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
@@ -39,6 +46,7 @@ struct Qdisc
 #define TCQ_F_INGRESS	4
 	int			padded;
 	struct Qdisc_ops	*ops;
+	struct qdisc_size_table	*stab;
 	u32			handle;
 	u32			parent;
 	atomic_t		refcnt;
@@ -165,6 +173,16 @@ struct tcf_proto
 	struct tcf_proto_ops	*ops;
 };
 
+struct qdisc_skb_cb {
+	unsigned int		pkt_len;
+	char			data[];
+};
+
+static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
+{
+	return (struct qdisc_skb_cb *)skb->cb;
+}
+
 static inline spinlock_t *qdisc_lock(struct Qdisc *qdisc)
 {
 	return &qdisc->q.lock;
@@ -257,6 +275,8 @@ extern struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
 				       struct netdev_queue *dev_queue,
 				       struct Qdisc_ops *ops, u32 parentid);
+extern void qdisc_calculate_pkt_len(struct sk_buff *skb,
+				   struct qdisc_size_table *stab);
 extern void tcf_destroy(struct tcf_proto *tp);
 extern void tcf_destroy_chain(struct tcf_proto **fl);
 
@@ -308,16 +328,19 @@ static inline bool qdisc_tx_is_noop(const struct net_device *dev)
 
 static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
 {
-	return skb->len;
+	return qdisc_skb_cb(skb)->pkt_len;
 }
 
 static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
+	if (sch->stab)
+		qdisc_calculate_pkt_len(skb, sch->stab);
 	return sch->enqueue(skb, sch);
 }
 
 static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
 {
+	qdisc_skb_cb(skb)->pkt_len = skb->len;
 	return qdisc_enqueue(skb, sch);
 }
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index fb43731..5219d5f 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -286,6 +286,129 @@ void qdisc_put_rtab(struct qdisc_rate_table *tab)
 }
 EXPORT_SYMBOL(qdisc_put_rtab);
 
+static LIST_HEAD(qdisc_stab_list);
+static DEFINE_SPINLOCK(qdisc_stab_lock);
+
+static const struct nla_policy stab_policy[TCA_STAB_MAX + 1] = {
+	[TCA_STAB_BASE]	= { .len = sizeof(struct tc_sizespec) },
+	[TCA_STAB_DATA] = { .type = NLA_BINARY },
+};
+
+static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
+{
+	struct nlattr *tb[TCA_STAB_MAX + 1];
+	struct qdisc_size_table *stab;
+	struct tc_sizespec *s;
+	unsigned int tsize = 0;
+	u16 *tab = NULL;
+	int err;
+
+	err = nla_parse_nested(tb, TCA_STAB_MAX, opt, stab_policy);
+	if (err < 0)
+		return ERR_PTR(err);
+	if (!tb[TCA_STAB_BASE])
+		return ERR_PTR(-EINVAL);
+
+	s = nla_data(tb[TCA_STAB_BASE]);
+
+	if (s->tsize > 0) {
+		if (!tb[TCA_STAB_DATA])
+			return ERR_PTR(-EINVAL);
+		tab = nla_data(tb[TCA_STAB_DATA]);
+		tsize = nla_len(tb[TCA_STAB_DATA]) / sizeof(u16);
+	}
+
+	if (!s || tsize != s->tsize || (!tab && tsize > 0))
+		return ERR_PTR(-EINVAL);
+
+	spin_lock(&qdisc_stab_lock);
+
+	list_for_each_entry(stab, &qdisc_stab_list, list) {
+		if (memcmp(&stab->szopts, s, sizeof(*s)))
+			continue;
+		if (tsize > 0 && memcmp(stab->data, tab, tsize * sizeof(u16)))
+			continue;
+		stab->refcnt++;
+		spin_unlock(&qdisc_stab_lock);
+		return stab;
+	}
+
+	spin_unlock(&qdisc_stab_lock);
+
+	stab = kmalloc(sizeof(*stab) + tsize * sizeof(u16), GFP_KERNEL);
+	if (!stab)
+		return ERR_PTR(-ENOMEM);
+
+	stab->refcnt = 1;
+	stab->szopts = *s;
+	if (tsize > 0)
+		memcpy(stab->data, tab, tsize * sizeof(u16));
+
+	spin_lock(&qdisc_stab_lock);
+	list_add_tail(&stab->list, &qdisc_stab_list);
+	spin_unlock(&qdisc_stab_lock);
+
+	return stab;
+}
+
+void qdisc_put_stab(struct qdisc_size_table *tab)
+{
+	if (!tab)
+		return;
+
+	spin_lock(&qdisc_stab_lock);
+
+	if (--tab->refcnt == 0) {
+		list_del(&tab->list);
+		kfree(tab);
+	}
+
+	spin_unlock(&qdisc_stab_lock);
+}
+EXPORT_SYMBOL(qdisc_put_stab);
+
+static int qdisc_dump_stab(struct sk_buff *skb, struct qdisc_size_table *stab)
+{
+	struct nlattr *nest;
+
+	nest = nla_nest_start(skb, TCA_STAB);
+	NLA_PUT(skb, TCA_STAB_BASE, sizeof(stab->szopts), &stab->szopts);
+	nla_nest_end(skb, nest);
+
+	return skb->len;
+
+nla_put_failure:
+	return -1;
+}
+
+void qdisc_calculate_pkt_len(struct sk_buff *skb, struct qdisc_size_table *stab)
+{
+	int pkt_len, slot;
+
+	pkt_len = skb->len + stab->szopts.overhead;
+	if (unlikely(!stab->szopts.tsize))
+		goto out;
+
+	slot = pkt_len + stab->szopts.cell_align;
+	if (unlikely(slot < 0))
+		slot = 0;
+
+	slot >>= stab->szopts.cell_log;
+	if (likely(slot < stab->szopts.tsize))
+		pkt_len = stab->data[slot];
+	else
+		pkt_len = stab->data[stab->szopts.tsize - 1] *
+				(slot / stab->szopts.tsize) +
+				stab->data[slot % stab->szopts.tsize];
+
+	pkt_len <<= stab->szopts.size_log;
+out:
+	if (unlikely(pkt_len < 1))
+		pkt_len = 1;
+	qdisc_skb_cb(skb)->pkt_len = pkt_len;
+}
+EXPORT_SYMBOL(qdisc_calculate_pkt_len);
+
 static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
@@ -613,6 +736,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 	struct nlattr *kind = tca[TCA_KIND];
 	struct Qdisc *sch;
 	struct Qdisc_ops *ops;
+	struct qdisc_size_table *stab;
 
 	ops = qdisc_lookup_ops(kind);
 #ifdef CONFIG_KMOD
@@ -670,6 +794,14 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 	sch->handle = handle;
 
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS])) == 0) {
+		if (tca[TCA_STAB]) {
+			stab = qdisc_get_stab(tca[TCA_STAB]);
+			if (IS_ERR(stab)) {
+				err = PTR_ERR(stab);
+				goto err_out3;
+			}
+			sch->stab = stab;
+		}
 		if (tca[TCA_RATE]) {
 			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
 						qdisc_root_lock(sch),
@@ -691,6 +823,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 		return sch;
 	}
 err_out3:
+	qdisc_put_stab(sch->stab);
 	dev_put(dev);
 	kfree((char *) sch - sch->padded);
 err_out2:
@@ -702,15 +835,26 @@ err_out:
 
 static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 {
-	if (tca[TCA_OPTIONS]) {
-		int err;
+	struct qdisc_size_table *stab = NULL;
+	int err = 0;
 
+	if (tca[TCA_OPTIONS]) {
 		if (sch->ops->change == NULL)
 			return -EINVAL;
 		err = sch->ops->change(sch, tca[TCA_OPTIONS]);
 		if (err)
 			return err;
 	}
+
+	if (tca[TCA_STAB]) {
+		stab = qdisc_get_stab(tca[TCA_STAB]);
+		if (IS_ERR(stab))
+			return PTR_ERR(stab);
+	}
+
+	qdisc_put_stab(sch->stab);
+	sch->stab = stab;
+
 	if (tca[TCA_RATE])
 		gen_replace_estimator(&sch->bstats, &sch->rate_est,
 				      qdisc_root_lock(sch), tca[TCA_RATE]);
@@ -994,6 +1138,9 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		goto nla_put_failure;
 	q->qstats.qlen = q->q.qlen;
 
+	if (q->stab && qdisc_dump_stab(skb, q->stab) < 0)
+		goto nla_put_failure;
+
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
 					 TCA_XSTATS, qdisc_root_lock(q), &d) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 522a41a..27a51f0 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -469,6 +469,7 @@ static void __qdisc_destroy(struct rcu_head *head)
 	struct Qdisc *qdisc = container_of(head, struct Qdisc, q_rcu);
 	const struct Qdisc_ops  *ops = qdisc->ops;
 
+	qdisc_put_stab(qdisc->stab);
 	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
 	if (ops->reset)
 		ops->reset(qdisc);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index ae49be0..a590857 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -84,8 +84,9 @@ struct netem_skb_cb {
 
 static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
 {
-	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct netem_skb_cb));
-	return (struct netem_skb_cb *)skb->cb;
+	BUILD_BUG_ON(sizeof(skb->cb) <
+		sizeof(struct qdisc_skb_cb) + sizeof(struct netem_skb_cb));
+	return (struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
 }
 
 /* init_crandom - initialize correlated random number generator

