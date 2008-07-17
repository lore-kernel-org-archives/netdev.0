From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH RFC 3/3] net_sched: Add size table for qdiscs
Date: Thu, 17 Jul 2008 13:09:39 +0300
Message-ID: <20080717100938.3327.45121.stgit@fate.lan>
References: <20080717100921.3327.3324.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:62795 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755647AbYGQKJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 06:09:41 -0400
In-Reply-To: <20080717100921.3327.3324.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add size table functions for qdiscs and calculate packet size in
qdisc_enqueue().

Based on patch by Patrick McHardy
 http://marc.info/?l=linux-netdev&m=115201979221729&w=2

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |   21 ++++++++
 include/linux/rtnetlink.h |    1 
 include/net/pkt_sched.h   |    1 
 include/net/sch_generic.h |   30 +++++++++++-
 net/core/dev.c            |    1 
 net/sched/sch_api.c       |  117 ++++++++++++++++++++++++++++++++++++++++++++-
 net/sched/sch_generic.c   |    1 
 net/sched/sch_netem.c     |    3 +
 net/sched/sch_tbf.c       |    6 +-
 9 files changed, 174 insertions(+), 7 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..eae53bf 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -85,6 +85,27 @@ struct tc_ratespec
 
 #define TC_RTAB_SIZE	1024
 
+struct tc_sizespec {
+	unsigned char	cell_log;
+	unsigned char	size_log;
+	short		cell_align;
+	int		overhead;
+	unsigned	linklayer;
+	unsigned	mpu;
+	unsigned	mtu;
+};
+
+#define TC_STAB_DATA_SIZE 1024
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
index d58c1a5..7a8a2a0 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -83,6 +83,7 @@ extern struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
 extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 		struct nlattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
+extern void qdisc_put_stab(struct qdisc_size_table *tab);
 
 extern void __qdisc_run(struct netdev_queue *txq);
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1f1de3b..81805d0 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -23,6 +23,13 @@ struct qdisc_rate_table
 	int		refcnt;
 };
 
+struct qdisc_size_table {
+	struct list_head	list;
+	struct tc_sizespec	szopts;
+	int			refcnt;
+	u16			data[512];
+};
+
 struct Qdisc
 {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
@@ -33,6 +40,7 @@ struct Qdisc
 #define TCQ_F_INGRESS	4
 	int			padded;
 	struct Qdisc_ops	*ops;
+	struct qdisc_size_table	*stab;
 	u32			handle;
 	u32			parent;
 	atomic_t		refcnt;
@@ -154,6 +162,16 @@ struct tcf_proto
 	struct tcf_proto_ops	*ops;
 };
 
+struct qdisc_skb_cb {
+	unsigned int		tx_len;
+	char			data[];
+};
+
+static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
+{
+	return (struct qdisc_skb_cb *)skb->cb;
+}
+
 static inline struct net_device *qdisc_dev(struct Qdisc *qdisc)
 {
 	return qdisc->dev_queue->dev;
@@ -224,6 +242,8 @@ extern struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
 				       struct netdev_queue *dev_queue,
 				       struct Qdisc_ops *ops, u32 parentid);
+extern void qdisc_calculate_tx_len(struct sk_buff *skb,
+				   struct qdisc_size_table *stab);
 extern void tcf_destroy(struct tcf_proto *tp);
 extern void tcf_destroy_chain(struct tcf_proto **fl);
 
@@ -258,13 +278,21 @@ static inline bool qdisc_tx_is_noop(const struct net_device *dev)
 	return (txq->qdisc == &noop_qdisc);
 }
 
+static inline void qdisc_root_init_tx_len(struct sk_buff *skb,
+					  struct Qdisc *sch)
+{
+	qdisc_skb_cb(skb)->tx_len = skb->len;
+}
+
 static inline unsigned int qdisc_tx_len(struct sk_buff *skb)
 {
-	return skb->len;
+	return qdisc_skb_cb(skb)->tx_len;
 }
 
 static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
+	if (sch->stab)
+		qdisc_calculate_tx_len(skb, sch->stab);
 	return sch->enqueue(skb, sch);
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index ee2df34..8223b56 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1733,6 +1733,7 @@ gso:
 		if (q->enqueue) {
 			/* reset queue_mapping to zero */
 			skb_set_queue_mapping(skb, 0);
+			qdisc_root_init_tx_len(skb, q);
 			rc = qdisc_enqueue(skb, q);
 			qdisc_run(txq);
 			spin_unlock(&txq->lock);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 95873f8..4d98cb7 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -278,6 +278,97 @@ void qdisc_put_rtab(struct qdisc_rate_table *tab)
 }
 EXPORT_SYMBOL(qdisc_put_rtab);
 
+static LIST_HEAD(qdisc_stab_list);
+
+static const struct nla_policy stab_policy[TCA_STAB_MAX + 1] = {
+	[TCA_STAB_BASE]	= { .len = sizeof(struct tc_sizespec) },
+	[TCA_STAB_DATA] = { .type = NLA_BINARY, .len = TC_STAB_DATA_SIZE },
+};
+
+static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt, int *err)
+{
+	struct nlattr *tb[TCA_STAB_MAX + 1];
+	struct qdisc_size_table *stab;
+	struct tc_sizespec *s;
+	u16 *tab;
+
+	*err = nla_parse_nested(tb, TCA_STAB_MAX, opt, stab_policy);
+	if (*err < 0)
+		return NULL;
+
+	s = nla_data(tb[TCA_STAB_BASE]);
+	tab = nla_data(tb[TCA_STAB_DATA]);
+
+	*err = -EINVAL;
+	if (!s || !tab || nla_len(tb[TCA_STAB_DATA]) < TC_STAB_DATA_SIZE)
+		return NULL;
+
+	list_for_each_entry(stab, &qdisc_stab_list, list) {
+		if (memcmp(&stab->szopts, s, sizeof(*s)) == 0 &&
+		    memcmp(stab->data, tab, TC_STAB_DATA_SIZE) == 0) {
+			stab->refcnt++;
+			*err = 0;
+			return stab;
+		}
+	}
+
+	*err = -ENOMEM;
+	stab = kmalloc(sizeof(*stab), GFP_KERNEL);
+	if (stab) {
+		stab->szopts = *s;
+		stab->refcnt = 1;
+		memcpy(stab->data, tab, TC_STAB_DATA_SIZE);
+		list_add_tail(&stab->list, &qdisc_stab_list);
+		*err = 0;
+	}
+	return stab;
+}
+
+void qdisc_put_stab(struct qdisc_size_table *tab)
+{
+	if (!tab || --tab->refcnt)
+		return;
+	list_del(&tab->list);
+	kfree(tab);
+}
+EXPORT_SYMBOL(qdisc_put_stab);
+
+static int qdisc_dump_stab(struct sk_buff *skb, struct qdisc_size_table *stab)
+{
+	struct nlattr *nest;
+
+	nest = nla_nest_start(skb, TCA_STAB);
+	NLA_PUT(skb, TCA_STAB_BASE, sizeof(stab->szopts), &stab->szopts);
+	NLA_PUT(skb, TCA_STAB_DATA, TC_STAB_DATA_SIZE, stab->data);
+	nla_nest_end(skb, nest);
+
+	return skb->len;
+
+nla_put_failure:
+	return -1;
+}
+
+void qdisc_calculate_tx_len(struct sk_buff *skb, struct qdisc_size_table *stab)
+{
+	unsigned int pktlen = skb->len;
+	unsigned char size_log;
+	int slot;
+
+	slot = pktlen + stab->szopts.cell_align + stab->szopts.overhead;
+	if (unlikely(slot < 0))
+		slot = 0;
+	slot >>= stab->szopts.cell_log;
+	size_log = stab->szopts.size_log;
+	if (unlikely(slot > 511))
+		pktlen = ((u32)stab->data[511] << size_log) * (slot >> 9) +
+			((u32)stab->data[slot & 0x1FF] << size_log);
+	else
+		pktlen = (u32)stab->data[slot] << size_log;
+
+	qdisc_skb_cb(skb)->tx_len = pktlen;
+}
+EXPORT_SYMBOL(qdisc_calculate_tx_len);
+
 static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
@@ -619,6 +710,11 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 	sch->handle = handle;
 
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS])) == 0) {
+		if (tca[TCA_STAB]) {
+			sch->stab = qdisc_get_stab(tca[TCA_STAB], &err);
+			if (sch->stab == NULL)
+				goto err_out3;
+		}
 		if (tca[TCA_RATE]) {
 			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
 						&sch->dev_queue->lock,
@@ -641,6 +737,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 		return sch;
 	}
 err_out3:
+	qdisc_put_stab(sch->stab);
 	dev_put(dev);
 	kfree((char *) sch - sch->padded);
 err_out2:
@@ -652,15 +749,28 @@ err_out:
 
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
+		stab = qdisc_get_stab(tca[TCA_STAB], &err);
+		if (stab == NULL)
+			return err;
+	}
+
+	spin_lock_bh(&sch->dev_queue->lock);
+	qdisc_put_stab(sch->stab);
+	sch->stab = stab;
+	spin_unlock_bh(&sch->dev_queue->lock);
+
 	if (tca[TCA_RATE])
 		gen_replace_estimator(&sch->bstats, &sch->rate_est,
 				      &sch->dev_queue->lock, tca[TCA_RATE]);
@@ -952,6 +1062,9 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		goto nla_put_failure;
 	q->qstats.qlen = q->q.qlen;
 
+	if (q->stab != NULL && qdisc_dump_stab(skb, q->stab) < 0)
+		goto nla_put_failure;
+
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
 					 TCA_XSTATS, &q->dev_queue->lock, &d) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 243de93..53e941b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -530,6 +530,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 		return;
 
 	list_del(&qdisc->list);
+	qdisc_put_stab(qdisc->stab);
 	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
 	if (ops->reset)
 		ops->reset(qdisc);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index bc9d6af..f75ba82 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -84,7 +84,7 @@ struct netem_skb_cb {
 
 static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
 {
-	return (struct netem_skb_cb *)skb->cb;
+	return (struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
 }
 
 /* init_crandom - initialize correlated random number generator
@@ -189,6 +189,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
 		q->duplicate = 0;
 
+		qdisc_root_init_tx_len(skb2, rootq);
 		qdisc_enqueue(skb2, rootq);
 		q->duplicate = dupsave;
 	}
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 1e3d52e..862c0e3 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -123,9 +123,9 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	/* qdisc_tx_len() before qdisc_enqueue() wrapper, might return different
-	 * length than after wrapper. Should recalculate tx_len here if q->qdisc
-	 * has size table? */
+	if (q->qdisc->stab)
+		qdisc_calculate_tx_len(skb, q->qdisc->stab);
+
 	if (qdisc_tx_len(skb) > q->max_size) {
 		sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_ACT

