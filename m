From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 04/06]: Convert packet schedulers from rtnetlink to new netlink API
Date: Tue, 22 Jan 2008 15:56:13 +0100 (MET)
Message-ID: <20080122145547.6862.43719.sendpatchset@localhost.localdomain>
References: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50738 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbYAVO4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:56:14 -0500
In-Reply-To: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Convert packet schedulers from rtnetlink to new netlink API

Convert packet schedulers to use the netlink API. Unfortunately a gradual
conversion is not possible without breaking compilation in the middle or
adding lots of casts, so this patch converts them all in one step. The
patch has been mostly generated automatically with some minor edits to
at least allow seperate conversion of classifiers and actions.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 07a5a2c72eb790323d3e11bb2e1131f8fd43ae1d
tree 163a3ee6f3cda46634493eb55dc870294c97fde5
parent 8a6648ddc22e03bbdf6675780c917e8c8519f205
author Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:41 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:41 +0100

 include/net/gen_stats.h    |    6 +-
 include/net/pkt_sched.h    |    2 -
 include/net/sch_generic.h  |    6 +-
 net/core/gen_estimator.c   |    8 +-
 net/core/gen_stats.c       |    9 +--
 net/mac80211/wme.c         |   14 ++--
 net/netfilter/xt_RATEEST.c |    7 +-
 net/sched/act_api.c        |    2 -
 net/sched/act_police.c     |    6 +-
 net/sched/sch_api.c        |   87 ++++++++++++++-----------
 net/sched/sch_atm.c        |   48 +++++++-------
 net/sched/sch_cbq.c        |  156 ++++++++++++++++++++++----------------------
 net/sched/sch_dsmark.c     |   85 ++++++++++++++----------
 net/sched/sch_fifo.c       |   10 +--
 net/sched/sch_generic.c    |    6 +-
 net/sched/sch_gred.c       |   59 +++++++++--------
 net/sched/sch_hfsc.c       |   72 ++++++++++----------
 net/sched/sch_htb.c        |   68 ++++++++++---------
 net/sched/sch_ingress.c    |   14 ++--
 net/sched/sch_netem.c      |  100 ++++++++++++++--------------
 net/sched/sch_prio.c       |   30 +++++---
 net/sched/sch_red.c        |   52 ++++++++-------
 net/sched/sch_sfq.c        |   12 ++-
 net/sched/sch_tbf.c        |   49 +++++++-------
 net/sched/sch_teql.c       |    2 -
 25 files changed, 474 insertions(+), 436 deletions(-)

diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index 0b95cf0..8cd8185 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -10,7 +10,7 @@ struct gnet_dump
 {
 	spinlock_t *      lock;
 	struct sk_buff *  skb;
-	struct rtattr *   tail;
+	struct nlattr *   tail;
 
 	/* Backward compatability */
 	int               compat_tc_stats;
@@ -39,11 +39,11 @@ extern int gnet_stats_finish_copy(struct gnet_dump *d);
 
 extern int gen_new_estimator(struct gnet_stats_basic *bstats,
 			     struct gnet_stats_rate_est *rate_est,
-			     spinlock_t *stats_lock, struct rtattr *opt);
+			     spinlock_t *stats_lock, struct nlattr *opt);
 extern void gen_kill_estimator(struct gnet_stats_basic *bstats,
 			       struct gnet_stats_rate_est *rate_est);
 extern int gen_replace_estimator(struct gnet_stats_basic *bstats,
 				 struct gnet_stats_rate_est *rate_est,
-				 spinlock_t *stats_lock, struct rtattr *opt);
+				 spinlock_t *stats_lock, struct nlattr *opt);
 
 #endif
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index ab61809..46fb4d8 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -77,7 +77,7 @@ extern int unregister_qdisc(struct Qdisc_ops *qops);
 extern struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
 extern struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
 extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
-		struct rtattr *tab);
+		struct nlattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 
 extern void __qdisc_run(struct net_device *dev);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9418ac2..8cacdff 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -66,7 +66,7 @@ struct Qdisc_class_ops
 	unsigned long		(*get)(struct Qdisc *, u32 classid);
 	void			(*put)(struct Qdisc *, unsigned long);
 	int			(*change)(struct Qdisc *, u32, u32,
-					struct rtattr **, unsigned long *);
+					struct nlattr **, unsigned long *);
 	int			(*delete)(struct Qdisc *, unsigned long);
 	void			(*walk)(struct Qdisc *, struct qdisc_walker * arg);
 
@@ -95,10 +95,10 @@ struct Qdisc_ops
 	int 			(*requeue)(struct sk_buff *, struct Qdisc *);
 	unsigned int		(*drop)(struct Qdisc *);
 
-	int			(*init)(struct Qdisc *, struct rtattr *arg);
+	int			(*init)(struct Qdisc *, struct nlattr *arg);
 	void			(*reset)(struct Qdisc *);
 	void			(*destroy)(struct Qdisc *);
-	int			(*change)(struct Qdisc *, struct rtattr *arg);
+	int			(*change)(struct Qdisc *, struct nlattr *arg);
 
 	int			(*dump)(struct Qdisc *, struct sk_buff *);
 	int			(*dump_stats)(struct Qdisc *, struct gnet_dump *);
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 7ab9060..57abe82 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -159,13 +159,13 @@ skip:
 int gen_new_estimator(struct gnet_stats_basic *bstats,
 		      struct gnet_stats_rate_est *rate_est,
 		      spinlock_t *stats_lock,
-		      struct rtattr *opt)
+		      struct nlattr *opt)
 {
 	struct gen_estimator *est;
-	struct gnet_estimator *parm = RTA_DATA(opt);
+	struct gnet_estimator *parm = nla_data(opt);
 	int idx;
 
-	if (RTA_PAYLOAD(opt) < sizeof(*parm))
+	if (nla_len(opt) < sizeof(*parm))
 		return -EINVAL;
 
 	if (parm->interval < -2 || parm->interval > 3)
@@ -254,7 +254,7 @@ void gen_kill_estimator(struct gnet_stats_basic *bstats,
  */
 int gen_replace_estimator(struct gnet_stats_basic *bstats,
 			  struct gnet_stats_rate_est *rate_est,
-			  spinlock_t *stats_lock, struct rtattr *opt)
+			  spinlock_t *stats_lock, struct nlattr *opt)
 {
 	gen_kill_estimator(bstats, rate_est);
 	return gen_new_estimator(bstats, rate_est, stats_lock, opt);
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 8073561..c3d0ffe 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -20,16 +20,17 @@
 #include <linux/socket.h>
 #include <linux/rtnetlink.h>
 #include <linux/gen_stats.h>
+#include <net/netlink.h>
 #include <net/gen_stats.h>
 
 
 static inline int
 gnet_stats_copy(struct gnet_dump *d, int type, void *buf, int size)
 {
-	RTA_PUT(d->skb, type, size, buf);
+	NLA_PUT(d->skb, type, size, buf);
 	return 0;
 
-rtattr_failure:
+nla_put_failure:
 	spin_unlock_bh(d->lock);
 	return -1;
 }
@@ -62,7 +63,7 @@ gnet_stats_start_copy_compat(struct sk_buff *skb, int type, int tc_stats_type,
 	spin_lock_bh(lock);
 	d->lock = lock;
 	if (type)
-		d->tail = (struct rtattr *)skb_tail_pointer(skb);
+		d->tail = (struct nlattr *)skb_tail_pointer(skb);
 	d->skb = skb;
 	d->compat_tc_stats = tc_stats_type;
 	d->compat_xstats = xstats_type;
@@ -213,7 +214,7 @@ int
 gnet_stats_finish_copy(struct gnet_dump *d)
 {
 	if (d->tail)
-		d->tail->rta_len = skb_tail_pointer(d->skb) - (u8 *)d->tail;
+		d->tail->nla_len = skb_tail_pointer(d->skb) - (u8 *)d->tail;
 
 	if (d->compat_tc_stats)
 		if (gnet_stats_copy(d, d->compat_tc_stats, &d->tc_stats,
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 455fadc..a6da213 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -296,16 +296,16 @@ static void wme_qdiscop_destroy(struct Qdisc* qd)
 
 
 /* called whenever parameters are updated on existing qdisc */
-static int wme_qdiscop_tune(struct Qdisc *qd, struct rtattr *opt)
+static int wme_qdiscop_tune(struct Qdisc *qd, struct nlattr *opt)
 {
 /*	struct ieee80211_sched_data *q = qdisc_priv(qd);
 */
 	/* check our options block is the right size */
 	/* copy any options to our local structure */
 /*	Ignore options block for now - always use static mapping
-	struct tc_ieee80211_qopt *qopt = RTA_DATA(opt);
+	struct tc_ieee80211_qopt *qopt = nla_data(opt);
 
-	if (opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
+	if (opt->nla_len < nla_attr_size(sizeof(*qopt)))
 		return -EINVAL;
 	memcpy(q->tag2queue, qopt->tag2queue, sizeof(qopt->tag2queue));
 */
@@ -314,7 +314,7 @@ static int wme_qdiscop_tune(struct Qdisc *qd, struct rtattr *opt)
 
 
 /* called during initial creation of qdisc on device */
-static int wme_qdiscop_init(struct Qdisc *qd, struct rtattr *opt)
+static int wme_qdiscop_init(struct Qdisc *qd, struct nlattr *opt)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
 	struct net_device *dev = qd->dev;
@@ -369,10 +369,10 @@ static int wme_qdiscop_dump(struct Qdisc *qd, struct sk_buff *skb)
 	struct tc_ieee80211_qopt opt;
 
 	memcpy(&opt.tag2queue, q->tag2queue, TC_80211_MAX_TAG + 1);
-	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 */	return skb->len;
 /*
-rtattr_failure:
+nla_put_failure:
 	skb_trim(skb, p - skb->data);*/
 	return -1;
 }
@@ -443,7 +443,7 @@ static void wme_classop_put(struct Qdisc *q, unsigned long cl)
 
 
 static int wme_classop_change(struct Qdisc *qd, u32 handle, u32 parent,
-			      struct rtattr **tca, unsigned long *arg)
+			      struct nlattr **tca, unsigned long *arg)
 {
 	unsigned long cl = *arg;
 	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index c5ba525..24c73ba 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -12,6 +12,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/random.h>
 #include <net/gen_stats.h>
+#include <net/netlink.h>
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_RATEEST.h>
@@ -98,7 +99,7 @@ xt_rateest_tg_checkentry(const char *tablename,
 	struct xt_rateest_target_info *info = (void *)targinfo;
 	struct xt_rateest *est;
 	struct {
-		struct rtattr		opt;
+		struct nlattr		opt;
 		struct gnet_estimator	est;
 	} cfg;
 
@@ -128,8 +129,8 @@ xt_rateest_tg_checkentry(const char *tablename,
 	est->params.interval	= info->interval;
 	est->params.ewma_log	= info->ewma_log;
 
-	cfg.opt.rta_len		= RTA_LENGTH(sizeof(cfg.est));
-	cfg.opt.rta_type	= TCA_STATS_RATE_EST;
+	cfg.opt.nla_len		= nla_attr_size(sizeof(cfg.est));
+	cfg.opt.nla_type	= TCA_STATS_RATE_EST;
 	cfg.est.interval	= info->interval;
 	cfg.est.ewma_log	= info->ewma_log;
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 3825508..11f3097 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -227,7 +227,7 @@ struct tcf_common *tcf_hash_create(u32 index, struct rtattr *est, struct tc_acti
 	p->tcfc_tm.lastuse = jiffies;
 	if (est)
 		gen_new_estimator(&p->tcfc_bstats, &p->tcfc_rate_est,
-				  &p->tcfc_lock, est);
+				  &p->tcfc_lock, (struct nlattr *)est);
 	a->priv = (void *) p;
 	return p;
 }
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index a73e3e6..07ffdf9 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -174,12 +174,12 @@ static int tcf_act_police_locate(struct rtattr *rta, struct rtattr *est,
 override:
 	if (parm->rate.rate) {
 		err = -ENOMEM;
-		R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE-1]);
+		R_tab = qdisc_get_rtab(&parm->rate, (struct nlattr *)tb[TCA_POLICE_RATE-1]);
 		if (R_tab == NULL)
 			goto failure;
 		if (parm->peakrate.rate) {
 			P_tab = qdisc_get_rtab(&parm->peakrate,
-					       tb[TCA_POLICE_PEAKRATE-1]);
+					       (struct nlattr *)tb[TCA_POLICE_PEAKRATE-1]);
 			if (P_tab == NULL) {
 				qdisc_put_rtab(R_tab);
 				goto failure;
@@ -216,7 +216,7 @@ override:
 	if (est)
 		gen_replace_estimator(&police->tcf_bstats,
 				      &police->tcf_rate_est,
-				      &police->tcf_lock, est);
+				      &police->tcf_lock, (struct nlattr *)est);
 
 	spin_unlock_bh(&police->tcf_lock);
 	if (ret != ACT_P_CREATED)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index dc89a93..7abb028 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -213,14 +213,14 @@ static struct Qdisc *qdisc_leaf(struct Qdisc *p, u32 classid)
 
 /* Find queueing discipline by name */
 
-static struct Qdisc_ops *qdisc_lookup_ops(struct rtattr *kind)
+static struct Qdisc_ops *qdisc_lookup_ops(struct nlattr *kind)
 {
 	struct Qdisc_ops *q = NULL;
 
 	if (kind) {
 		read_lock(&qdisc_mod_lock);
 		for (q = qdisc_base; q; q = q->next) {
-			if (rtattr_strcmp(kind, q->id) == 0) {
+			if (nla_strcmp(kind, q->id) == 0) {
 				if (!try_module_get(q->owner))
 					q = NULL;
 				break;
@@ -233,7 +233,7 @@ static struct Qdisc_ops *qdisc_lookup_ops(struct rtattr *kind)
 
 static struct qdisc_rate_table *qdisc_rtab_list;
 
-struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r, struct rtattr *tab)
+struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r, struct nlattr *tab)
 {
 	struct qdisc_rate_table *rtab;
 
@@ -244,14 +244,14 @@ struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r, struct rtattr *ta
 		}
 	}
 
-	if (tab == NULL || r->rate == 0 || r->cell_log == 0 || RTA_PAYLOAD(tab) != 1024)
+	if (tab == NULL || r->rate == 0 || r->cell_log == 0 || nla_len(tab) != 1024)
 		return NULL;
 
 	rtab = kmalloc(sizeof(*rtab), GFP_KERNEL);
 	if (rtab) {
 		rtab->rate = *r;
 		rtab->refcnt = 1;
-		memcpy(rtab->data, RTA_DATA(tab), 1024);
+		memcpy(rtab->data, nla_data(tab), 1024);
 		rtab->next = qdisc_rtab_list;
 		qdisc_rtab_list = rtab;
 	}
@@ -445,10 +445,10 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 
 static struct Qdisc *
 qdisc_create(struct net_device *dev, u32 parent, u32 handle,
-	   struct rtattr **tca, int *errp)
+	   struct nlattr **tca, int *errp)
 {
 	int err;
-	struct rtattr *kind = tca[TCA_KIND-1];
+	struct nlattr *kind = tca[TCA_KIND];
 	struct Qdisc *sch;
 	struct Qdisc_ops *ops;
 
@@ -456,7 +456,7 @@ qdisc_create(struct net_device *dev, u32 parent, u32 handle,
 #ifdef CONFIG_KMOD
 	if (ops == NULL && kind != NULL) {
 		char name[IFNAMSIZ];
-		if (rtattr_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
+		if (nla_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
 			/* We dropped the RTNL semaphore in order to
 			 * perform the module load.  So, even if we
 			 * succeeded in loading the module we have to
@@ -509,11 +509,11 @@ qdisc_create(struct net_device *dev, u32 parent, u32 handle,
 
 	sch->handle = handle;
 
-	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS-1])) == 0) {
-		if (tca[TCA_RATE-1]) {
+	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS])) == 0) {
+		if (tca[TCA_RATE]) {
 			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
 						sch->stats_lock,
-						tca[TCA_RATE-1]);
+						tca[TCA_RATE]);
 			if (err) {
 				/*
 				 * Any broken qdiscs that would require
@@ -541,20 +541,20 @@ err_out:
 	return NULL;
 }
 
-static int qdisc_change(struct Qdisc *sch, struct rtattr **tca)
+static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 {
-	if (tca[TCA_OPTIONS-1]) {
+	if (tca[TCA_OPTIONS]) {
 		int err;
 
 		if (sch->ops->change == NULL)
 			return -EINVAL;
-		err = sch->ops->change(sch, tca[TCA_OPTIONS-1]);
+		err = sch->ops->change(sch, tca[TCA_OPTIONS]);
 		if (err)
 			return err;
 	}
-	if (tca[TCA_RATE-1])
+	if (tca[TCA_RATE])
 		gen_replace_estimator(&sch->bstats, &sch->rate_est,
-			sch->stats_lock, tca[TCA_RATE-1]);
+			sch->stats_lock, tca[TCA_RATE]);
 	return 0;
 }
 
@@ -606,7 +606,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = skb->sk->sk_net;
 	struct tcmsg *tcm = NLMSG_DATA(n);
-	struct rtattr **tca = arg;
+	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
 	u32 clid = tcm->tcm_parent;
 	struct Qdisc *q = NULL;
@@ -619,6 +619,10 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
 		return -ENODEV;
 
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
+	if (err < 0)
+		return err;
+
 	if (clid) {
 		if (clid != TC_H_ROOT) {
 			if (TC_H_MAJ(clid) != TC_H_MAJ(TC_H_INGRESS)) {
@@ -641,7 +645,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 			return -ENOENT;
 	}
 
-	if (tca[TCA_KIND-1] && rtattr_strcmp(tca[TCA_KIND-1], q->ops->id))
+	if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id))
 		return -EINVAL;
 
 	if (n->nlmsg_type == RTM_DELQDISC) {
@@ -671,7 +675,7 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = skb->sk->sk_net;
 	struct tcmsg *tcm;
-	struct rtattr **tca;
+	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
 	u32 clid;
 	struct Qdisc *q, *p;
@@ -683,13 +687,16 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 replay:
 	/* Reinit, just in case something touches this. */
 	tcm = NLMSG_DATA(n);
-	tca = arg;
 	clid = tcm->tcm_parent;
 	q = p = NULL;
 
 	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
 		return -ENODEV;
 
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
+	if (err < 0)
+		return err;
+
 	if (clid) {
 		if (clid != TC_H_ROOT) {
 			if (clid != TC_H_INGRESS) {
@@ -717,7 +724,7 @@ replay:
 					goto create_n_graft;
 				if (n->nlmsg_flags&NLM_F_EXCL)
 					return -EEXIST;
-				if (tca[TCA_KIND-1] && rtattr_strcmp(tca[TCA_KIND-1], q->ops->id))
+				if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id))
 					return -EINVAL;
 				if (q == p ||
 				    (p && check_loop(q, p, 0)))
@@ -750,8 +757,8 @@ replay:
 				if ((n->nlmsg_flags&NLM_F_CREATE) &&
 				    (n->nlmsg_flags&NLM_F_REPLACE) &&
 				    ((n->nlmsg_flags&NLM_F_EXCL) ||
-				     (tca[TCA_KIND-1] &&
-				      rtattr_strcmp(tca[TCA_KIND-1], q->ops->id))))
+				     (tca[TCA_KIND] &&
+				      nla_strcmp(tca[TCA_KIND], q->ops->id))))
 					goto create_n_graft;
 			}
 		}
@@ -766,7 +773,7 @@ replay:
 		return -ENOENT;
 	if (n->nlmsg_flags&NLM_F_EXCL)
 		return -EEXIST;
-	if (tca[TCA_KIND-1] && rtattr_strcmp(tca[TCA_KIND-1], q->ops->id))
+	if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id))
 		return -EINVAL;
 	err = qdisc_change(q, tca);
 	if (err == 0)
@@ -827,31 +834,31 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	tcm->tcm_parent = clid;
 	tcm->tcm_handle = q->handle;
 	tcm->tcm_info = atomic_read(&q->refcnt);
-	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, q->ops->id);
+	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, q->ops->id);
 	if (q->ops->dump && q->ops->dump(q, skb) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 	q->qstats.qlen = q->q.qlen;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
 			TCA_XSTATS, q->stats_lock, &d) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(&d, &q->rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, &q->qstats) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	if (gnet_stats_finish_copy(&d) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
 nlmsg_failure:
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -939,7 +946,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = skb->sk->sk_net;
 	struct tcmsg *tcm = NLMSG_DATA(n);
-	struct rtattr **tca = arg;
+	struct nlattr *tca[TCA_MAX + 1];
 	struct net_device *dev;
 	struct Qdisc *q = NULL;
 	const struct Qdisc_class_ops *cops;
@@ -956,6 +963,10 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	if ((dev = __dev_get_by_index(&init_net, tcm->tcm_ifindex)) == NULL)
 		return -ENODEV;
 
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
+	if (err < 0)
+		return err;
+
 	/*
 	   parent == TC_H_UNSPEC - unspecified parent.
 	   parent == TC_H_ROOT   - class is root, which has no parent.
@@ -1069,25 +1080,25 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	tcm->tcm_parent = q->handle;
 	tcm->tcm_handle = q->handle;
 	tcm->tcm_info = 0;
-	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, q->ops->id);
+	NLA_PUT(skb, TCA_KIND, IFNAMSIZ, q->ops->id);
 	if (cl_ops->dump && cl_ops->dump(q, cl, skb, tcm) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
 			TCA_XSTATS, q->stats_lock, &d) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	if (cl_ops->dump_stats && cl_ops->dump_stats(q, cl, &d) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	if (gnet_stats_finish_copy(&d) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
 nlmsg_failure:
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 734be9d..eb01aae 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -196,13 +196,13 @@ static const u8 llc_oui_ip[] = {
 };				/* Ethertype IP (0800) */
 
 static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
-			 struct rtattr **tca, unsigned long *arg)
+			 struct nlattr **tca, unsigned long *arg)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)*arg;
 	struct atm_flow_data *excess = NULL;
-	struct rtattr *opt = tca[TCA_OPTIONS - 1];
-	struct rtattr *tb[TCA_ATM_MAX];
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct nlattr *tb[TCA_ATM_MAX + 1];
 	struct socket *sock;
 	int fd, error, hdr_len;
 	void *hdr;
@@ -223,31 +223,31 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 	 */
 	if (flow)
 		return -EBUSY;
-	if (opt == NULL || rtattr_parse_nested(tb, TCA_ATM_MAX, opt))
+	if (opt == NULL || nla_parse_nested(tb, TCA_ATM_MAX, opt, NULL))
 		return -EINVAL;
-	if (!tb[TCA_ATM_FD - 1] || RTA_PAYLOAD(tb[TCA_ATM_FD - 1]) < sizeof(fd))
+	if (!tb[TCA_ATM_FD] || nla_len(tb[TCA_ATM_FD]) < sizeof(fd))
 		return -EINVAL;
-	fd = *(int *)RTA_DATA(tb[TCA_ATM_FD - 1]);
+	fd = *(int *)nla_data(tb[TCA_ATM_FD]);
 	pr_debug("atm_tc_change: fd %d\n", fd);
-	if (tb[TCA_ATM_HDR - 1]) {
-		hdr_len = RTA_PAYLOAD(tb[TCA_ATM_HDR - 1]);
-		hdr = RTA_DATA(tb[TCA_ATM_HDR - 1]);
+	if (tb[TCA_ATM_HDR]) {
+		hdr_len = nla_len(tb[TCA_ATM_HDR]);
+		hdr = nla_data(tb[TCA_ATM_HDR]);
 	} else {
 		hdr_len = RFC1483LLC_LEN;
 		hdr = NULL;	/* default LLC/SNAP for IP */
 	}
-	if (!tb[TCA_ATM_EXCESS - 1])
+	if (!tb[TCA_ATM_EXCESS])
 		excess = NULL;
 	else {
-		if (RTA_PAYLOAD(tb[TCA_ATM_EXCESS - 1]) != sizeof(u32))
+		if (nla_len(tb[TCA_ATM_EXCESS]) != sizeof(u32))
 			return -EINVAL;
 		excess = (struct atm_flow_data *)
-			atm_tc_get(sch, *(u32 *)RTA_DATA(tb[TCA_ATM_EXCESS - 1]));
+			atm_tc_get(sch, *(u32 *)nla_data(tb[TCA_ATM_EXCESS]));
 		if (!excess)
 			return -ENOENT;
 	}
 	pr_debug("atm_tc_change: type %d, payload %lu, hdr_len %d\n",
-		 opt->rta_type, RTA_PAYLOAD(opt), hdr_len);
+		 opt->nla_type, nla_len(opt), hdr_len);
 	sock = sockfd_lookup(fd, &error);
 	if (!sock)
 		return error;	/* f_count++ */
@@ -541,7 +541,7 @@ static unsigned int atm_tc_drop(struct Qdisc *sch)
 	return 0;
 }
 
-static int atm_tc_init(struct Qdisc *sch, struct rtattr *opt)
+static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 
@@ -602,7 +602,7 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 
 	pr_debug("atm_tc_dump_class(sch %p,[qdisc %p],flow %p,skb %p,tcm %p)\n",
 		sch, p, flow, skb, tcm);
@@ -610,9 +610,9 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 		return -EINVAL;
 	tcm->tcm_handle = flow->classid;
 	tcm->tcm_info = flow->q->handle;
-	rta = (struct rtattr *)b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
-	RTA_PUT(skb, TCA_ATM_HDR, flow->hdr_len, flow->hdr);
+	nla = (struct nlattr *)b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	NLA_PUT(skb, TCA_ATM_HDR, flow->hdr_len, flow->hdr);
 	if (flow->vcc) {
 		struct sockaddr_atmpvc pvc;
 		int state;
@@ -621,21 +621,21 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 		pvc.sap_addr.itf = flow->vcc->dev ? flow->vcc->dev->number : -1;
 		pvc.sap_addr.vpi = flow->vcc->vpi;
 		pvc.sap_addr.vci = flow->vcc->vci;
-		RTA_PUT(skb, TCA_ATM_ADDR, sizeof(pvc), &pvc);
+		NLA_PUT(skb, TCA_ATM_ADDR, sizeof(pvc), &pvc);
 		state = ATM_VF2VS(flow->vcc->flags);
-		RTA_PUT(skb, TCA_ATM_STATE, sizeof(state), &state);
+		NLA_PUT(skb, TCA_ATM_STATE, sizeof(state), &state);
 	}
 	if (flow->excess)
-		RTA_PUT(skb, TCA_ATM_EXCESS, sizeof(u32), &flow->classid);
+		NLA_PUT(skb, TCA_ATM_EXCESS, sizeof(u32), &flow->classid);
 	else {
 		static u32 zero;
 
-		RTA_PUT(skb, TCA_ATM_EXCESS, sizeof(zero), &zero);
+		NLA_PUT(skb, TCA_ATM_EXCESS, sizeof(zero), &zero);
 	}
-	rta->rta_len = skb_tail_pointer(skb) - b;
+	nla->nla_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index bea123f..5c8667e 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1377,24 +1377,24 @@ static int cbq_set_fopt(struct cbq_class *cl, struct tc_cbq_fopt *fopt)
 	return 0;
 }
 
-static int cbq_init(struct Qdisc *sch, struct rtattr *opt)
+static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	struct rtattr *tb[TCA_CBQ_MAX];
+	struct nlattr *tb[TCA_CBQ_MAX + 1];
 	struct tc_ratespec *r;
 
-	if (rtattr_parse_nested(tb, TCA_CBQ_MAX, opt) < 0 ||
-	    tb[TCA_CBQ_RTAB-1] == NULL || tb[TCA_CBQ_RATE-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_CBQ_RATE-1]) < sizeof(struct tc_ratespec))
+	if (nla_parse_nested(tb, TCA_CBQ_MAX, opt, NULL) < 0 ||
+	    tb[TCA_CBQ_RTAB] == NULL || tb[TCA_CBQ_RATE] == NULL ||
+	    nla_len(tb[TCA_CBQ_RATE]) < sizeof(struct tc_ratespec))
 		return -EINVAL;
 
-	if (tb[TCA_CBQ_LSSOPT-1] &&
-	    RTA_PAYLOAD(tb[TCA_CBQ_LSSOPT-1]) < sizeof(struct tc_cbq_lssopt))
+	if (tb[TCA_CBQ_LSSOPT] &&
+	    nla_len(tb[TCA_CBQ_LSSOPT]) < sizeof(struct tc_cbq_lssopt))
 		return -EINVAL;
 
-	r = RTA_DATA(tb[TCA_CBQ_RATE-1]);
+	r = nla_data(tb[TCA_CBQ_RATE]);
 
-	if ((q->link.R_tab = qdisc_get_rtab(r, tb[TCA_CBQ_RTAB-1])) == NULL)
+	if ((q->link.R_tab = qdisc_get_rtab(r, tb[TCA_CBQ_RTAB])) == NULL)
 		return -EINVAL;
 
 	q->link.refcnt = 1;
@@ -1427,8 +1427,8 @@ static int cbq_init(struct Qdisc *sch, struct rtattr *opt)
 
 	cbq_link_class(&q->link);
 
-	if (tb[TCA_CBQ_LSSOPT-1])
-		cbq_set_lss(&q->link, RTA_DATA(tb[TCA_CBQ_LSSOPT-1]));
+	if (tb[TCA_CBQ_LSSOPT])
+		cbq_set_lss(&q->link, nla_data(tb[TCA_CBQ_LSSOPT]));
 
 	cbq_addprio(q, &q->link);
 	return 0;
@@ -1438,10 +1438,10 @@ static __inline__ int cbq_dump_rate(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 
-	RTA_PUT(skb, TCA_CBQ_RATE, sizeof(cl->R_tab->rate), &cl->R_tab->rate);
+	NLA_PUT(skb, TCA_CBQ_RATE, sizeof(cl->R_tab->rate), &cl->R_tab->rate);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -1463,10 +1463,10 @@ static __inline__ int cbq_dump_lss(struct sk_buff *skb, struct cbq_class *cl)
 	opt.minidle = (u32)(-cl->minidle);
 	opt.offtime = cl->offtime;
 	opt.change = ~0;
-	RTA_PUT(skb, TCA_CBQ_LSSOPT, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_CBQ_LSSOPT, sizeof(opt), &opt);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -1481,10 +1481,10 @@ static __inline__ int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
 	opt.priority = cl->priority+1;
 	opt.cpriority = cl->cpriority+1;
 	opt.weight = cl->weight;
-	RTA_PUT(skb, TCA_CBQ_WRROPT, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_CBQ_WRROPT, sizeof(opt), &opt);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -1498,10 +1498,10 @@ static __inline__ int cbq_dump_ovl(struct sk_buff *skb, struct cbq_class *cl)
 	opt.priority2 = cl->priority2+1;
 	opt.pad = 0;
 	opt.penalty = cl->penalty;
-	RTA_PUT(skb, TCA_CBQ_OVL_STRATEGY, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_CBQ_OVL_STRATEGY, sizeof(opt), &opt);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -1515,11 +1515,11 @@ static __inline__ int cbq_dump_fopt(struct sk_buff *skb, struct cbq_class *cl)
 		opt.split = cl->split ? cl->split->classid : 0;
 		opt.defmap = cl->defmap;
 		opt.defchange = ~0;
-		RTA_PUT(skb, TCA_CBQ_FOPT, sizeof(opt), &opt);
+		NLA_PUT(skb, TCA_CBQ_FOPT, sizeof(opt), &opt);
 	}
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -1534,11 +1534,11 @@ static __inline__ int cbq_dump_police(struct sk_buff *skb, struct cbq_class *cl)
 		opt.police = cl->police;
 		opt.__res1 = 0;
 		opt.__res2 = 0;
-		RTA_PUT(skb, TCA_CBQ_POLICE, sizeof(opt), &opt);
+		NLA_PUT(skb, TCA_CBQ_POLICE, sizeof(opt), &opt);
 	}
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -1562,16 +1562,16 @@ static int cbq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 
-	rta = (struct rtattr*)b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nla = (struct nlattr*)b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	if (cbq_dump_attr(skb, &q->link) < 0)
-		goto rtattr_failure;
-	rta->rta_len = skb_tail_pointer(skb) - b;
+		goto nla_put_failure;
+	nla->nla_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -1591,7 +1591,7 @@ cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 {
 	struct cbq_class *cl = (struct cbq_class*)arg;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 
 	if (cl->tparent)
 		tcm->tcm_parent = cl->tparent->classid;
@@ -1600,14 +1600,14 @@ cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 	tcm->tcm_handle = cl->classid;
 	tcm->tcm_info = cl->q->handle;
 
-	rta = (struct rtattr*)b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nla = (struct nlattr*)b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	if (cbq_dump_attr(skb, cl) < 0)
-		goto rtattr_failure;
-	rta->rta_len = skb_tail_pointer(skb) - b;
+		goto nla_put_failure;
+	nla->nla_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -1753,43 +1753,43 @@ static void cbq_put(struct Qdisc *sch, unsigned long arg)
 }
 
 static int
-cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **tca,
+cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **tca,
 		 unsigned long *arg)
 {
 	int err;
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = (struct cbq_class*)*arg;
-	struct rtattr *opt = tca[TCA_OPTIONS-1];
-	struct rtattr *tb[TCA_CBQ_MAX];
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct nlattr *tb[TCA_CBQ_MAX + 1];
 	struct cbq_class *parent;
 	struct qdisc_rate_table *rtab = NULL;
 
-	if (opt==NULL || rtattr_parse_nested(tb, TCA_CBQ_MAX, opt))
+	if (opt==NULL || nla_parse_nested(tb, TCA_CBQ_MAX, opt, NULL))
 		return -EINVAL;
 
-	if (tb[TCA_CBQ_OVL_STRATEGY-1] &&
-	    RTA_PAYLOAD(tb[TCA_CBQ_OVL_STRATEGY-1]) < sizeof(struct tc_cbq_ovl))
+	if (tb[TCA_CBQ_OVL_STRATEGY] &&
+	    nla_len(tb[TCA_CBQ_OVL_STRATEGY]) < sizeof(struct tc_cbq_ovl))
 		return -EINVAL;
 
-	if (tb[TCA_CBQ_FOPT-1] &&
-	    RTA_PAYLOAD(tb[TCA_CBQ_FOPT-1]) < sizeof(struct tc_cbq_fopt))
+	if (tb[TCA_CBQ_FOPT] &&
+	    nla_len(tb[TCA_CBQ_FOPT]) < sizeof(struct tc_cbq_fopt))
 		return -EINVAL;
 
-	if (tb[TCA_CBQ_RATE-1] &&
-	    RTA_PAYLOAD(tb[TCA_CBQ_RATE-1]) < sizeof(struct tc_ratespec))
+	if (tb[TCA_CBQ_RATE] &&
+	    nla_len(tb[TCA_CBQ_RATE]) < sizeof(struct tc_ratespec))
 			return -EINVAL;
 
-	if (tb[TCA_CBQ_LSSOPT-1] &&
-	    RTA_PAYLOAD(tb[TCA_CBQ_LSSOPT-1]) < sizeof(struct tc_cbq_lssopt))
+	if (tb[TCA_CBQ_LSSOPT] &&
+	    nla_len(tb[TCA_CBQ_LSSOPT]) < sizeof(struct tc_cbq_lssopt))
 			return -EINVAL;
 
-	if (tb[TCA_CBQ_WRROPT-1] &&
-	    RTA_PAYLOAD(tb[TCA_CBQ_WRROPT-1]) < sizeof(struct tc_cbq_wrropt))
+	if (tb[TCA_CBQ_WRROPT] &&
+	    nla_len(tb[TCA_CBQ_WRROPT]) < sizeof(struct tc_cbq_wrropt))
 			return -EINVAL;
 
 #ifdef CONFIG_NET_CLS_ACT
-	if (tb[TCA_CBQ_POLICE-1] &&
-	    RTA_PAYLOAD(tb[TCA_CBQ_POLICE-1]) < sizeof(struct tc_cbq_police))
+	if (tb[TCA_CBQ_POLICE] &&
+	    nla_len(tb[TCA_CBQ_POLICE]) < sizeof(struct tc_cbq_police))
 			return -EINVAL;
 #endif
 
@@ -1802,8 +1802,8 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 				return -EINVAL;
 		}
 
-		if (tb[TCA_CBQ_RATE-1]) {
-			rtab = qdisc_get_rtab(RTA_DATA(tb[TCA_CBQ_RATE-1]), tb[TCA_CBQ_RTAB-1]);
+		if (tb[TCA_CBQ_RATE]) {
+			rtab = qdisc_get_rtab(nla_data(tb[TCA_CBQ_RATE]), tb[TCA_CBQ_RTAB]);
 			if (rtab == NULL)
 				return -EINVAL;
 		}
@@ -1819,45 +1819,45 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 			qdisc_put_rtab(rtab);
 		}
 
-		if (tb[TCA_CBQ_LSSOPT-1])
-			cbq_set_lss(cl, RTA_DATA(tb[TCA_CBQ_LSSOPT-1]));
+		if (tb[TCA_CBQ_LSSOPT])
+			cbq_set_lss(cl, nla_data(tb[TCA_CBQ_LSSOPT]));
 
-		if (tb[TCA_CBQ_WRROPT-1]) {
+		if (tb[TCA_CBQ_WRROPT]) {
 			cbq_rmprio(q, cl);
-			cbq_set_wrr(cl, RTA_DATA(tb[TCA_CBQ_WRROPT-1]));
+			cbq_set_wrr(cl, nla_data(tb[TCA_CBQ_WRROPT]));
 		}
 
-		if (tb[TCA_CBQ_OVL_STRATEGY-1])
-			cbq_set_overlimit(cl, RTA_DATA(tb[TCA_CBQ_OVL_STRATEGY-1]));
+		if (tb[TCA_CBQ_OVL_STRATEGY])
+			cbq_set_overlimit(cl, nla_data(tb[TCA_CBQ_OVL_STRATEGY]));
 
 #ifdef CONFIG_NET_CLS_ACT
-		if (tb[TCA_CBQ_POLICE-1])
-			cbq_set_police(cl, RTA_DATA(tb[TCA_CBQ_POLICE-1]));
+		if (tb[TCA_CBQ_POLICE])
+			cbq_set_police(cl, nla_data(tb[TCA_CBQ_POLICE]));
 #endif
 
-		if (tb[TCA_CBQ_FOPT-1])
-			cbq_set_fopt(cl, RTA_DATA(tb[TCA_CBQ_FOPT-1]));
+		if (tb[TCA_CBQ_FOPT])
+			cbq_set_fopt(cl, nla_data(tb[TCA_CBQ_FOPT]));
 
 		if (cl->q->q.qlen)
 			cbq_activate_class(cl);
 
 		sch_tree_unlock(sch);
 
-		if (tca[TCA_RATE-1])
+		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
 					      &sch->dev->queue_lock,
-					      tca[TCA_RATE-1]);
+					      tca[TCA_RATE]);
 		return 0;
 	}
 
 	if (parentid == TC_H_ROOT)
 		return -EINVAL;
 
-	if (tb[TCA_CBQ_WRROPT-1] == NULL || tb[TCA_CBQ_RATE-1] == NULL ||
-	    tb[TCA_CBQ_LSSOPT-1] == NULL)
+	if (tb[TCA_CBQ_WRROPT] == NULL || tb[TCA_CBQ_RATE] == NULL ||
+	    tb[TCA_CBQ_LSSOPT] == NULL)
 		return -EINVAL;
 
-	rtab = qdisc_get_rtab(RTA_DATA(tb[TCA_CBQ_RATE-1]), tb[TCA_CBQ_RTAB-1]);
+	rtab = qdisc_get_rtab(nla_data(tb[TCA_CBQ_RATE]), tb[TCA_CBQ_RTAB]);
 	if (rtab == NULL)
 		return -EINVAL;
 
@@ -1912,8 +1912,8 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 		cl->share = cl->tparent;
 	cbq_adjust_levels(parent);
 	cl->minidle = -0x7FFFFFFF;
-	cbq_set_lss(cl, RTA_DATA(tb[TCA_CBQ_LSSOPT-1]));
-	cbq_set_wrr(cl, RTA_DATA(tb[TCA_CBQ_WRROPT-1]));
+	cbq_set_lss(cl, nla_data(tb[TCA_CBQ_LSSOPT]));
+	cbq_set_wrr(cl, nla_data(tb[TCA_CBQ_WRROPT]));
 	if (cl->ewma_log==0)
 		cl->ewma_log = q->link.ewma_log;
 	if (cl->maxidle==0)
@@ -1921,19 +1921,19 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 	if (cl->avpkt==0)
 		cl->avpkt = q->link.avpkt;
 	cl->overlimit = cbq_ovl_classic;
-	if (tb[TCA_CBQ_OVL_STRATEGY-1])
-		cbq_set_overlimit(cl, RTA_DATA(tb[TCA_CBQ_OVL_STRATEGY-1]));
+	if (tb[TCA_CBQ_OVL_STRATEGY])
+		cbq_set_overlimit(cl, nla_data(tb[TCA_CBQ_OVL_STRATEGY]));
 #ifdef CONFIG_NET_CLS_ACT
-	if (tb[TCA_CBQ_POLICE-1])
-		cbq_set_police(cl, RTA_DATA(tb[TCA_CBQ_POLICE-1]));
+	if (tb[TCA_CBQ_POLICE])
+		cbq_set_police(cl, nla_data(tb[TCA_CBQ_POLICE]));
 #endif
-	if (tb[TCA_CBQ_FOPT-1])
-		cbq_set_fopt(cl, RTA_DATA(tb[TCA_CBQ_FOPT-1]));
+	if (tb[TCA_CBQ_FOPT])
+		cbq_set_fopt(cl, nla_data(tb[TCA_CBQ_FOPT]));
 	sch_tree_unlock(sch);
 
-	if (tca[TCA_RATE-1])
+	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev->queue_lock, tca[TCA_RATE-1]);
+				  &sch->dev->queue_lock, tca[TCA_RATE]);
 
 	*arg = (unsigned long)cl;
 	return 0;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 40e06a6..f183ab7 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -100,11 +100,11 @@ static void dsmark_put(struct Qdisc *sch, unsigned long cl)
 }
 
 static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
-			 struct rtattr **tca, unsigned long *arg)
+			 struct nlattr **tca, unsigned long *arg)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
-	struct rtattr *opt = tca[TCA_OPTIONS-1];
-	struct rtattr *tb[TCA_DSMARK_MAX];
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct nlattr *tb[TCA_DSMARK_MAX + 1];
 	int err = -EINVAL;
 	u8 mask = 0;
 
@@ -113,24 +113,29 @@ static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
 
 	if (!dsmark_valid_index(p, *arg)) {
 		err = -ENOENT;
-		goto rtattr_failure;
+		goto errout;
 	}
 
-	if (!opt || rtattr_parse_nested(tb, TCA_DSMARK_MAX, opt))
-		goto rtattr_failure;
-
-	if (tb[TCA_DSMARK_MASK-1])
-		mask = RTA_GET_U8(tb[TCA_DSMARK_MASK-1]);
+	if (!opt || nla_parse_nested(tb, TCA_DSMARK_MAX, opt, NULL))
+		goto errout;
 
-	if (tb[TCA_DSMARK_VALUE-1])
-		p->value[*arg-1] = RTA_GET_U8(tb[TCA_DSMARK_VALUE-1]);
+	if (tb[TCA_DSMARK_MASK]) {
+		if (nla_len(tb[TCA_DSMARK_MASK]) < sizeof(u8))
+			goto errout;
+		mask = nla_get_u8(tb[TCA_DSMARK_MASK]);
+	}
+	if (tb[TCA_DSMARK_VALUE]) {
+		if (nla_len(tb[TCA_DSMARK_VALUE]) < sizeof(u8))
+			goto errout;
+		p->value[*arg-1] = nla_get_u8(tb[TCA_DSMARK_VALUE]);
+	}
 
-	if (tb[TCA_DSMARK_MASK-1])
+	if (tb[TCA_DSMARK_MASK])
 		p->mask[*arg-1] = mask;
 
 	err = 0;
 
-rtattr_failure:
+errout:
 	return err;
 }
 
@@ -335,10 +340,10 @@ static unsigned int dsmark_drop(struct Qdisc *sch)
 	return len;
 }
 
-static int dsmark_init(struct Qdisc *sch, struct rtattr *opt)
+static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
-	struct rtattr *tb[TCA_DSMARK_MAX];
+	struct nlattr *tb[TCA_DSMARK_MAX + 1];
 	int err = -EINVAL;
 	u32 default_index = NO_DEFAULT_INDEX;
 	u16 indices;
@@ -346,16 +351,21 @@ static int dsmark_init(struct Qdisc *sch, struct rtattr *opt)
 
 	pr_debug("dsmark_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
 
-	if (!opt || rtattr_parse_nested(tb, TCA_DSMARK_MAX, opt) < 0)
+	if (!opt || nla_parse_nested(tb, TCA_DSMARK_MAX, opt, NULL) < 0)
 		goto errout;
 
-	indices = RTA_GET_U16(tb[TCA_DSMARK_INDICES-1]);
+	if (nla_len(tb[TCA_DSMARK_INDICES]) < sizeof(u16))
+		goto errout;
+	indices = nla_get_u16(tb[TCA_DSMARK_INDICES]);
 
 	if (hweight32(indices) != 1)
 		goto errout;
 
-	if (tb[TCA_DSMARK_DEFAULT_INDEX-1])
-		default_index = RTA_GET_U16(tb[TCA_DSMARK_DEFAULT_INDEX-1]);
+	if (tb[TCA_DSMARK_DEFAULT_INDEX]) {
+		if (nla_len(tb[TCA_DSMARK_DEFAULT_INDEX]) < sizeof(u16))
+			goto errout;
+		default_index = nla_get_u16(tb[TCA_DSMARK_DEFAULT_INDEX]);
+	}
 
 	mask = kmalloc(indices * 2, GFP_KERNEL);
 	if (mask == NULL) {
@@ -371,7 +381,7 @@ static int dsmark_init(struct Qdisc *sch, struct rtattr *opt)
 
 	p->indices = indices;
 	p->default_index = default_index;
-	p->set_tc_index = RTA_GET_FLAG(tb[TCA_DSMARK_SET_TC_INDEX-1]);
+	p->set_tc_index = nla_get_flag(tb[TCA_DSMARK_SET_TC_INDEX]);
 
 	p->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, sch->handle);
 	if (p->q == NULL)
@@ -381,7 +391,6 @@ static int dsmark_init(struct Qdisc *sch, struct rtattr *opt)
 
 	err = 0;
 errout:
-rtattr_failure:
 	return err;
 }
 
@@ -409,7 +418,7 @@ static int dsmark_dump_class(struct Qdisc *sch, unsigned long cl,
 			     struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
-	struct rtattr *opts = NULL;
+	struct nlattr *opts = NULL;
 
 	pr_debug("dsmark_dump_class(sch %p,[qdisc %p],class %ld\n", sch, p, cl);
 
@@ -419,34 +428,38 @@ static int dsmark_dump_class(struct Qdisc *sch, unsigned long cl,
 	tcm->tcm_handle = TC_H_MAKE(TC_H_MAJ(sch->handle), cl-1);
 	tcm->tcm_info = p->q->handle;
 
-	opts = RTA_NEST(skb, TCA_OPTIONS);
-	RTA_PUT_U8(skb, TCA_DSMARK_MASK, p->mask[cl-1]);
-	RTA_PUT_U8(skb, TCA_DSMARK_VALUE, p->value[cl-1]);
+	opts = nla_nest_start(skb, TCA_OPTIONS);
+	if (opts == NULL)
+		goto nla_put_failure;
+	NLA_PUT_U8(skb, TCA_DSMARK_MASK, p->mask[cl-1]);
+	NLA_PUT_U8(skb, TCA_DSMARK_VALUE, p->value[cl-1]);
 
-	return RTA_NEST_END(skb, opts);
+	return nla_nest_end(skb, opts);
 
-rtattr_failure:
-	return RTA_NEST_CANCEL(skb, opts);
+nla_put_failure:
+	return nla_nest_cancel(skb, opts);
 }
 
 static int dsmark_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
-	struct rtattr *opts = NULL;
+	struct nlattr *opts = NULL;
 
-	opts = RTA_NEST(skb, TCA_OPTIONS);
-	RTA_PUT_U16(skb, TCA_DSMARK_INDICES, p->indices);
+	opts = nla_nest_start(skb, TCA_OPTIONS);
+	if (opts == NULL)
+		goto nla_put_failure;
+	NLA_PUT_U16(skb, TCA_DSMARK_INDICES, p->indices);
 
 	if (p->default_index != NO_DEFAULT_INDEX)
-		RTA_PUT_U16(skb, TCA_DSMARK_DEFAULT_INDEX, p->default_index);
+		NLA_PUT_U16(skb, TCA_DSMARK_DEFAULT_INDEX, p->default_index);
 
 	if (p->set_tc_index)
-		RTA_PUT_FLAG(skb, TCA_DSMARK_SET_TC_INDEX);
+		NLA_PUT_FLAG(skb, TCA_DSMARK_SET_TC_INDEX);
 
-	return RTA_NEST_END(skb, opts);
+	return nla_nest_end(skb, opts);
 
-rtattr_failure:
-	return RTA_NEST_CANCEL(skb, opts);
+nla_put_failure:
+	return nla_nest_cancel(skb, opts);
 }
 
 static const struct Qdisc_class_ops dsmark_class_ops = {
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index fd05919..95ed482 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -43,7 +43,7 @@ static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return qdisc_reshape_fail(skb, sch);
 }
 
-static int fifo_init(struct Qdisc *sch, struct rtattr *opt)
+static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
@@ -55,9 +55,9 @@ static int fifo_init(struct Qdisc *sch, struct rtattr *opt)
 
 		q->limit = limit;
 	} else {
-		struct tc_fifo_qopt *ctl = RTA_DATA(opt);
+		struct tc_fifo_qopt *ctl = nla_data(opt);
 
-		if (RTA_PAYLOAD(opt) < sizeof(*ctl))
+		if (nla_len(opt) < sizeof(*ctl))
 			return -EINVAL;
 
 		q->limit = ctl->limit;
@@ -71,10 +71,10 @@ static int fifo_dump(struct Qdisc *sch, struct sk_buff *skb)
 	struct fifo_sched_data *q = qdisc_priv(sch);
 	struct tc_fifo_qopt opt = { .limit = q->limit };
 
-	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	return -1;
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 51e64ac..10b5c08 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -397,14 +397,14 @@ static int pfifo_fast_dump(struct Qdisc *qdisc, struct sk_buff *skb)
 	struct tc_prio_qopt opt = { .bands = PFIFO_FAST_BANDS };
 
 	memcpy(&opt.priomap, prio2band, TC_PRIO_MAX+1);
-	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	return -1;
 }
 
-static int pfifo_fast_init(struct Qdisc *qdisc, struct rtattr *opt)
+static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
 {
 	int prio;
 	struct sk_buff_head *list = qdisc_priv(qdisc);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index e2bcd66..6b78483 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -350,16 +350,16 @@ static inline void gred_destroy_vq(struct gred_sched_data *q)
 	kfree(q);
 }
 
-static inline int gred_change_table_def(struct Qdisc *sch, struct rtattr *dps)
+static inline int gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
 {
 	struct gred_sched *table = qdisc_priv(sch);
 	struct tc_gred_sopt *sopt;
 	int i;
 
-	if (dps == NULL || RTA_PAYLOAD(dps) < sizeof(*sopt))
+	if (dps == NULL || nla_len(dps) < sizeof(*sopt))
 		return -EINVAL;
 
-	sopt = RTA_DATA(dps);
+	sopt = nla_data(dps);
 
 	if (sopt->DPs > MAX_DPs || sopt->DPs == 0 || sopt->def_DP >= sopt->DPs)
 		return -EINVAL;
@@ -425,28 +425,28 @@ static inline int gred_change_vq(struct Qdisc *sch, int dp,
 	return 0;
 }
 
-static int gred_change(struct Qdisc *sch, struct rtattr *opt)
+static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct gred_sched *table = qdisc_priv(sch);
 	struct tc_gred_qopt *ctl;
-	struct rtattr *tb[TCA_GRED_MAX];
+	struct nlattr *tb[TCA_GRED_MAX + 1];
 	int err = -EINVAL, prio = GRED_DEF_PRIO;
 	u8 *stab;
 
-	if (opt == NULL || rtattr_parse_nested(tb, TCA_GRED_MAX, opt))
+	if (opt == NULL || nla_parse_nested(tb, TCA_GRED_MAX, opt, NULL))
 		return -EINVAL;
 
-	if (tb[TCA_GRED_PARMS-1] == NULL && tb[TCA_GRED_STAB-1] == NULL)
+	if (tb[TCA_GRED_PARMS] == NULL && tb[TCA_GRED_STAB] == NULL)
 		return gred_change_table_def(sch, opt);
 
-	if (tb[TCA_GRED_PARMS-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_GRED_PARMS-1]) < sizeof(*ctl) ||
-	    tb[TCA_GRED_STAB-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_GRED_STAB-1]) < 256)
+	if (tb[TCA_GRED_PARMS] == NULL ||
+	    nla_len(tb[TCA_GRED_PARMS]) < sizeof(*ctl) ||
+	    tb[TCA_GRED_STAB] == NULL ||
+	    nla_len(tb[TCA_GRED_STAB]) < 256)
 		return -EINVAL;
 
-	ctl = RTA_DATA(tb[TCA_GRED_PARMS-1]);
-	stab = RTA_DATA(tb[TCA_GRED_STAB-1]);
+	ctl = nla_data(tb[TCA_GRED_PARMS]);
+	stab = nla_data(tb[TCA_GRED_STAB]);
 
 	if (ctl->DP >= table->DPs)
 		goto errout;
@@ -486,23 +486,23 @@ errout:
 	return err;
 }
 
-static int gred_init(struct Qdisc *sch, struct rtattr *opt)
+static int gred_init(struct Qdisc *sch, struct nlattr *opt)
 {
-	struct rtattr *tb[TCA_GRED_MAX];
+	struct nlattr *tb[TCA_GRED_MAX + 1];
 
-	if (opt == NULL || rtattr_parse_nested(tb, TCA_GRED_MAX, opt))
+	if (opt == NULL || nla_parse_nested(tb, TCA_GRED_MAX, opt, NULL))
 		return -EINVAL;
 
-	if (tb[TCA_GRED_PARMS-1] || tb[TCA_GRED_STAB-1])
+	if (tb[TCA_GRED_PARMS] || tb[TCA_GRED_STAB])
 		return -EINVAL;
 
-	return gred_change_table_def(sch, tb[TCA_GRED_DPS-1]);
+	return gred_change_table_def(sch, tb[TCA_GRED_DPS]);
 }
 
 static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct gred_sched *table = qdisc_priv(sch);
-	struct rtattr *parms, *opts = NULL;
+	struct nlattr *parms, *opts = NULL;
 	int i;
 	struct tc_gred_sopt sopt = {
 		.DPs	= table->DPs,
@@ -511,9 +511,13 @@ static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 		.flags	= table->red_flags,
 	};
 
-	opts = RTA_NEST(skb, TCA_OPTIONS);
-	RTA_PUT(skb, TCA_GRED_DPS, sizeof(sopt), &sopt);
-	parms = RTA_NEST(skb, TCA_GRED_PARMS);
+	opts = nla_nest_start(skb, TCA_OPTIONS);
+	if (opts == NULL)
+		goto nla_put_failure;
+	NLA_PUT(skb, TCA_GRED_DPS, sizeof(sopt), &sopt);
+	parms = nla_nest_start(skb, TCA_GRED_PARMS);
+	if (parms == NULL)
+		goto nla_put_failure;
 
 	for (i = 0; i < MAX_DPs; i++) {
 		struct gred_sched_data *q = table->tab[i];
@@ -555,15 +559,16 @@ static int gred_dump(struct Qdisc *sch, struct sk_buff *skb)
 		opt.qave = red_calc_qavg(&q->parms, q->parms.qavg);
 
 append_opt:
-		RTA_APPEND(skb, sizeof(opt), &opt);
+		if (nla_append(skb, sizeof(opt), &opt) < 0)
+			goto nla_put_failure;
 	}
 
-	RTA_NEST_END(skb, parms);
+	nla_nest_end(skb, parms);
 
-	return RTA_NEST_END(skb, opts);
+	return nla_nest_end(skb, opts);
 
-rtattr_failure:
-	return RTA_NEST_CANCEL(skb, opts);
+nla_put_failure:
+	return nla_nest_cancel(skb, opts);
 }
 
 static void gred_destroy(struct Qdisc *sch)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 69dc3bc..4e6a164 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -988,39 +988,39 @@ hfsc_change_usc(struct hfsc_class *cl, struct tc_service_curve *usc,
 
 static int
 hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-		  struct rtattr **tca, unsigned long *arg)
+		  struct nlattr **tca, unsigned long *arg)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl = (struct hfsc_class *)*arg;
 	struct hfsc_class *parent = NULL;
-	struct rtattr *opt = tca[TCA_OPTIONS-1];
-	struct rtattr *tb[TCA_HFSC_MAX];
+	struct nlattr *opt = tca[TCA_OPTIONS];
+	struct nlattr *tb[TCA_HFSC_MAX + 1];
 	struct tc_service_curve *rsc = NULL, *fsc = NULL, *usc = NULL;
 	u64 cur_time;
 
-	if (opt == NULL || rtattr_parse_nested(tb, TCA_HFSC_MAX, opt))
+	if (opt == NULL || nla_parse_nested(tb, TCA_HFSC_MAX, opt, NULL))
 		return -EINVAL;
 
-	if (tb[TCA_HFSC_RSC-1]) {
-		if (RTA_PAYLOAD(tb[TCA_HFSC_RSC-1]) < sizeof(*rsc))
+	if (tb[TCA_HFSC_RSC]) {
+		if (nla_len(tb[TCA_HFSC_RSC]) < sizeof(*rsc))
 			return -EINVAL;
-		rsc = RTA_DATA(tb[TCA_HFSC_RSC-1]);
+		rsc = nla_data(tb[TCA_HFSC_RSC]);
 		if (rsc->m1 == 0 && rsc->m2 == 0)
 			rsc = NULL;
 	}
 
-	if (tb[TCA_HFSC_FSC-1]) {
-		if (RTA_PAYLOAD(tb[TCA_HFSC_FSC-1]) < sizeof(*fsc))
+	if (tb[TCA_HFSC_FSC]) {
+		if (nla_len(tb[TCA_HFSC_FSC]) < sizeof(*fsc))
 			return -EINVAL;
-		fsc = RTA_DATA(tb[TCA_HFSC_FSC-1]);
+		fsc = nla_data(tb[TCA_HFSC_FSC]);
 		if (fsc->m1 == 0 && fsc->m2 == 0)
 			fsc = NULL;
 	}
 
-	if (tb[TCA_HFSC_USC-1]) {
-		if (RTA_PAYLOAD(tb[TCA_HFSC_USC-1]) < sizeof(*usc))
+	if (tb[TCA_HFSC_USC]) {
+		if (nla_len(tb[TCA_HFSC_USC]) < sizeof(*usc))
 			return -EINVAL;
-		usc = RTA_DATA(tb[TCA_HFSC_USC-1]);
+		usc = nla_data(tb[TCA_HFSC_USC]);
 		if (usc->m1 == 0 && usc->m2 == 0)
 			usc = NULL;
 	}
@@ -1050,10 +1050,10 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		}
 		sch_tree_unlock(sch);
 
-		if (tca[TCA_RATE-1])
+		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
 					      &sch->dev->queue_lock,
-					      tca[TCA_RATE-1]);
+					      tca[TCA_RATE]);
 		return 0;
 	}
 
@@ -1106,9 +1106,9 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->cl_pcvtoff = parent->cl_cvtoff;
 	sch_tree_unlock(sch);
 
-	if (tca[TCA_RATE-1])
+	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev->queue_lock, tca[TCA_RATE-1]);
+				  &sch->dev->queue_lock, tca[TCA_RATE]);
 	*arg = (unsigned long)cl;
 	return 0;
 }
@@ -1304,11 +1304,11 @@ hfsc_dump_sc(struct sk_buff *skb, int attr, struct internal_sc *sc)
 	tsc.m1 = sm2m(sc->sm1);
 	tsc.d  = dx2d(sc->dx);
 	tsc.m2 = sm2m(sc->sm2);
-	RTA_PUT(skb, attr, sizeof(tsc), &tsc);
+	NLA_PUT(skb, attr, sizeof(tsc), &tsc);
 
 	return skb->len;
 
- rtattr_failure:
+ nla_put_failure:
 	return -1;
 }
 
@@ -1317,19 +1317,19 @@ hfsc_dump_curves(struct sk_buff *skb, struct hfsc_class *cl)
 {
 	if ((cl->cl_flags & HFSC_RSC) &&
 	    (hfsc_dump_sc(skb, TCA_HFSC_RSC, &cl->cl_rsc) < 0))
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	if ((cl->cl_flags & HFSC_FSC) &&
 	    (hfsc_dump_sc(skb, TCA_HFSC_FSC, &cl->cl_fsc) < 0))
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	if ((cl->cl_flags & HFSC_USC) &&
 	    (hfsc_dump_sc(skb, TCA_HFSC_USC, &cl->cl_usc) < 0))
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	return skb->len;
 
- rtattr_failure:
+ nla_put_failure:
 	return -1;
 }
 
@@ -1339,20 +1339,20 @@ hfsc_dump_class(struct Qdisc *sch, unsigned long arg, struct sk_buff *skb,
 {
 	struct hfsc_class *cl = (struct hfsc_class *)arg;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta = (struct rtattr *)b;
+	struct nlattr *nla = (struct nlattr *)b;
 
 	tcm->tcm_parent = cl->cl_parent ? cl->cl_parent->classid : TC_H_ROOT;
 	tcm->tcm_handle = cl->classid;
 	if (cl->level == 0)
 		tcm->tcm_info = cl->qdisc->handle;
 
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	if (hfsc_dump_curves(skb, cl) < 0)
-		goto rtattr_failure;
-	rta->rta_len = skb_tail_pointer(skb) - b;
+		goto nla_put_failure;
+	nla->nla_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
- rtattr_failure:
+ nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -1423,15 +1423,15 @@ hfsc_schedule_watchdog(struct Qdisc *sch)
 }
 
 static int
-hfsc_init_qdisc(struct Qdisc *sch, struct rtattr *opt)
+hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 	struct tc_hfsc_qopt *qopt;
 	unsigned int i;
 
-	if (opt == NULL || RTA_PAYLOAD(opt) < sizeof(*qopt))
+	if (opt == NULL || nla_len(opt) < sizeof(*qopt))
 		return -EINVAL;
-	qopt = RTA_DATA(opt);
+	qopt = nla_data(opt);
 
 	q->defcls = qopt->defcls;
 	for (i = 0; i < HFSC_HSIZE; i++)
@@ -1459,14 +1459,14 @@ hfsc_init_qdisc(struct Qdisc *sch, struct rtattr *opt)
 }
 
 static int
-hfsc_change_qdisc(struct Qdisc *sch, struct rtattr *opt)
+hfsc_change_qdisc(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 	struct tc_hfsc_qopt *qopt;
 
-	if (opt == NULL || RTA_PAYLOAD(opt) < sizeof(*qopt))
+	if (opt == NULL || nla_len(opt) < sizeof(*qopt))
 		return -EINVAL;
-	qopt = RTA_DATA(opt);
+	qopt = nla_data(opt);
 
 	sch_tree_lock(sch);
 	q->defcls = qopt->defcls;
@@ -1550,10 +1550,10 @@ hfsc_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
 	struct tc_hfsc_qopt qopt;
 
 	qopt.defcls = q->defcls;
-	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
+	NLA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
 	return skb->len;
 
- rtattr_failure:
+ nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 6a2352c..3b3ff64 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -992,19 +992,19 @@ static void htb_reset(struct Qdisc *sch)
 		INIT_LIST_HEAD(q->drops + i);
 }
 
-static int htb_init(struct Qdisc *sch, struct rtattr *opt)
+static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	struct rtattr *tb[TCA_HTB_INIT];
+	struct nlattr *tb[TCA_HTB_INIT + 1];
 	struct tc_htb_glob *gopt;
 	int i;
-	if (!opt || rtattr_parse_nested(tb, TCA_HTB_INIT, opt) ||
-	    tb[TCA_HTB_INIT - 1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_HTB_INIT - 1]) < sizeof(*gopt)) {
+	if (!opt || nla_parse_nested(tb, TCA_HTB_INIT, opt, NULL) ||
+	    tb[TCA_HTB_INIT] == NULL ||
+	    nla_len(tb[TCA_HTB_INIT]) < sizeof(*gopt)) {
 		printk(KERN_ERR "HTB: hey probably you have bad tc tool ?\n");
 		return -EINVAL;
 	}
-	gopt = RTA_DATA(tb[TCA_HTB_INIT - 1]);
+	gopt = nla_data(tb[TCA_HTB_INIT]);
 	if (gopt->version != HTB_VER >> 16) {
 		printk(KERN_ERR
 		       "HTB: need tc/htb version %d (minor is %d), you have %d\n",
@@ -1036,7 +1036,7 @@ static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 	struct tc_htb_glob gopt;
 	spin_lock_bh(&sch->dev->queue_lock);
 	gopt.direct_pkts = q->direct_pkts;
@@ -1045,13 +1045,13 @@ static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 	gopt.rate2quantum = q->rate2quantum;
 	gopt.defcls = q->defcls;
 	gopt.debug = 0;
-	rta = (struct rtattr *)b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
-	RTA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
-	rta->rta_len = skb_tail_pointer(skb) - b;
+	nla = (struct nlattr *)b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	NLA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
+	nla->nla_len = skb_tail_pointer(skb) - b;
 	spin_unlock_bh(&sch->dev->queue_lock);
 	return skb->len;
-rtattr_failure:
+nla_put_failure:
 	spin_unlock_bh(&sch->dev->queue_lock);
 	nlmsg_trim(skb, skb_tail_pointer(skb));
 	return -1;
@@ -1062,7 +1062,7 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 {
 	struct htb_class *cl = (struct htb_class *)arg;
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 	struct tc_htb_opt opt;
 
 	spin_lock_bh(&sch->dev->queue_lock);
@@ -1071,8 +1071,8 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	if (!cl->level && cl->un.leaf.q)
 		tcm->tcm_info = cl->un.leaf.q->handle;
 
-	rta = (struct rtattr *)b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nla = (struct nlattr *)b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 
 	memset(&opt, 0, sizeof(opt));
 
@@ -1083,11 +1083,11 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	opt.quantum = cl->un.leaf.quantum;
 	opt.prio = cl->un.leaf.prio;
 	opt.level = cl->level;
-	RTA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
-	rta->rta_len = skb_tail_pointer(skb) - b;
+	NLA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
+	nla->nla_len = skb_tail_pointer(skb) - b;
 	spin_unlock_bh(&sch->dev->queue_lock);
 	return skb->len;
-rtattr_failure:
+nla_put_failure:
 	spin_unlock_bh(&sch->dev->queue_lock);
 	nlmsg_trim(skb, b);
 	return -1;
@@ -1290,29 +1290,29 @@ static void htb_put(struct Qdisc *sch, unsigned long arg)
 }
 
 static int htb_change_class(struct Qdisc *sch, u32 classid,
-			    u32 parentid, struct rtattr **tca,
+			    u32 parentid, struct nlattr **tca,
 			    unsigned long *arg)
 {
 	int err = -EINVAL;
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)*arg, *parent;
-	struct rtattr *opt = tca[TCA_OPTIONS - 1];
+	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct qdisc_rate_table *rtab = NULL, *ctab = NULL;
-	struct rtattr *tb[TCA_HTB_RTAB];
+	struct nlattr *tb[TCA_HTB_RTAB + 1];
 	struct tc_htb_opt *hopt;
 
 	/* extract all subattrs from opt attr */
-	if (!opt || rtattr_parse_nested(tb, TCA_HTB_RTAB, opt) ||
-	    tb[TCA_HTB_PARMS - 1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_HTB_PARMS - 1]) < sizeof(*hopt))
+	if (!opt || nla_parse_nested(tb, TCA_HTB_RTAB, opt, NULL) ||
+	    tb[TCA_HTB_PARMS] == NULL ||
+	    nla_len(tb[TCA_HTB_PARMS]) < sizeof(*hopt))
 		goto failure;
 
 	parent = parentid == TC_H_ROOT ? NULL : htb_find(parentid, sch);
 
-	hopt = RTA_DATA(tb[TCA_HTB_PARMS - 1]);
+	hopt = nla_data(tb[TCA_HTB_PARMS]);
 
-	rtab = qdisc_get_rtab(&hopt->rate, tb[TCA_HTB_RTAB - 1]);
-	ctab = qdisc_get_rtab(&hopt->ceil, tb[TCA_HTB_CTAB - 1]);
+	rtab = qdisc_get_rtab(&hopt->rate, tb[TCA_HTB_RTAB]);
+	ctab = qdisc_get_rtab(&hopt->ceil, tb[TCA_HTB_CTAB]);
 	if (!rtab || !ctab)
 		goto failure;
 
@@ -1320,12 +1320,12 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		struct Qdisc *new_q;
 		int prio;
 		struct {
-			struct rtattr		rta;
+			struct nlattr		nla;
 			struct gnet_estimator	opt;
 		} est = {
-			.rta = {
-				.rta_len	= RTA_LENGTH(sizeof(est.opt)),
-				.rta_type	= TCA_RATE,
+			.nla = {
+				.nla_len	= nla_attr_size(sizeof(est.opt)),
+				.nla_type	= TCA_RATE,
 			},
 			.opt = {
 				/* 4s interval, 16s averaging constant */
@@ -1350,7 +1350,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
 				  &sch->dev->queue_lock,
-				  tca[TCA_RATE-1] ? : &est.rta);
+				  tca[TCA_RATE] ? : &est.nla);
 		cl->refcnt = 1;
 		INIT_LIST_HEAD(&cl->sibling);
 		INIT_HLIST_NODE(&cl->hlist);
@@ -1403,10 +1403,10 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		list_add_tail(&cl->sibling,
 			      parent ? &parent->children : &q->root);
 	} else {
-		if (tca[TCA_RATE-1])
+		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
 					      &sch->dev->queue_lock,
-					      tca[TCA_RATE-1]);
+					      tca[TCA_RATE]);
 		sch_tree_lock(sch);
 	}
 
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 7252571..f6decbb 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -57,7 +57,7 @@ static void ingress_put(struct Qdisc *sch, unsigned long cl)
 }
 
 static int ingress_change(struct Qdisc *sch, u32 classid, u32 parent,
-			  struct rtattr **tca, unsigned long *arg)
+			  struct nlattr **tca, unsigned long *arg)
 {
 	return 0;
 }
@@ -156,7 +156,7 @@ static struct nf_hook_ops ing_ops[] __read_mostly = {
 };
 #endif
 
-static int ingress_init(struct Qdisc *sch, struct rtattr *opt)
+static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 {
 #if !defined(CONFIG_NET_CLS_ACT) && defined(CONFIG_NETFILTER)
 	printk("Ingress scheduler: Classifier actions prefered over netfilter\n");
@@ -184,14 +184,14 @@ static void ingress_destroy(struct Qdisc *sch)
 static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 
-	rta = (struct rtattr *)b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
-	rta->rta_len = skb_tail_pointer(skb) - b;
+	nla = (struct nlattr *)b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nla->nla_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 6c344ad..a7b58df 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -313,21 +313,21 @@ static void netem_reset(struct Qdisc *sch)
 /* Pass size change message down to embedded FIFO */
 static int set_fifo_limit(struct Qdisc *q, int limit)
 {
-	struct rtattr *rta;
+	struct nlattr *nla;
 	int ret = -ENOMEM;
 
 	/* Hack to avoid sending change message to non-FIFO */
 	if (strncmp(q->ops->id + 1, "fifo", 4) != 0)
 		return 0;
 
-	rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
-	if (rta) {
-		rta->rta_type = RTM_NEWQDISC;
-		rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
-		((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
+	nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
+	if (nla) {
+		nla->nla_type = RTM_NEWQDISC;
+		nla->nla_len = nla_attr_size(sizeof(struct tc_fifo_qopt));
+		((struct tc_fifo_qopt *)nla_data(nla))->limit = limit;
 
-		ret = q->ops->change(q, rta);
-		kfree(rta);
+		ret = q->ops->change(q, nla);
+		kfree(nla);
 	}
 	return ret;
 }
@@ -336,11 +336,11 @@ static int set_fifo_limit(struct Qdisc *q, int limit)
  * Distribution data is a variable size payload containing
  * signed 16 bit values.
  */
-static int get_dist_table(struct Qdisc *sch, const struct rtattr *attr)
+static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	unsigned long n = RTA_PAYLOAD(attr)/sizeof(__s16);
-	const __s16 *data = RTA_DATA(attr);
+	unsigned long n = nla_len(attr)/sizeof(__s16);
+	const __s16 *data = nla_data(attr);
 	struct disttable *d;
 	int i;
 
@@ -363,12 +363,12 @@ static int get_dist_table(struct Qdisc *sch, const struct rtattr *attr)
 	return 0;
 }
 
-static int get_correlation(struct Qdisc *sch, const struct rtattr *attr)
+static int get_correlation(struct Qdisc *sch, const struct nlattr *attr)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	const struct tc_netem_corr *c = RTA_DATA(attr);
+	const struct tc_netem_corr *c = nla_data(attr);
 
-	if (RTA_PAYLOAD(attr) != sizeof(*c))
+	if (nla_len(attr) != sizeof(*c))
 		return -EINVAL;
 
 	init_crandom(&q->delay_cor, c->delay_corr);
@@ -377,12 +377,12 @@ static int get_correlation(struct Qdisc *sch, const struct rtattr *attr)
 	return 0;
 }
 
-static int get_reorder(struct Qdisc *sch, const struct rtattr *attr)
+static int get_reorder(struct Qdisc *sch, const struct nlattr *attr)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	const struct tc_netem_reorder *r = RTA_DATA(attr);
+	const struct tc_netem_reorder *r = nla_data(attr);
 
-	if (RTA_PAYLOAD(attr) != sizeof(*r))
+	if (nla_len(attr) != sizeof(*r))
 		return -EINVAL;
 
 	q->reorder = r->probability;
@@ -390,12 +390,12 @@ static int get_reorder(struct Qdisc *sch, const struct rtattr *attr)
 	return 0;
 }
 
-static int get_corrupt(struct Qdisc *sch, const struct rtattr *attr)
+static int get_corrupt(struct Qdisc *sch, const struct nlattr *attr)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	const struct tc_netem_corrupt *r = RTA_DATA(attr);
+	const struct tc_netem_corrupt *r = nla_data(attr);
 
-	if (RTA_PAYLOAD(attr) != sizeof(*r))
+	if (nla_len(attr) != sizeof(*r))
 		return -EINVAL;
 
 	q->corrupt = r->probability;
@@ -404,16 +404,16 @@ static int get_corrupt(struct Qdisc *sch, const struct rtattr *attr)
 }
 
 /* Parse netlink message to set options */
-static int netem_change(struct Qdisc *sch, struct rtattr *opt)
+static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct tc_netem_qopt *qopt;
 	int ret;
 
-	if (opt == NULL || RTA_PAYLOAD(opt) < sizeof(*qopt))
+	if (opt == NULL || nla_len(opt) < sizeof(*qopt))
 		return -EINVAL;
 
-	qopt = RTA_DATA(opt);
+	qopt = nla_data(opt);
 	ret = set_fifo_limit(q->qdisc, qopt->limit);
 	if (ret) {
 		pr_debug("netem: can't set fifo limit\n");
@@ -437,33 +437,33 @@ static int netem_change(struct Qdisc *sch, struct rtattr *opt)
 	/* Handle nested options after initial queue options.
 	 * Should have put all options in nested format but too late now.
 	 */
-	if (RTA_PAYLOAD(opt) > sizeof(*qopt)) {
-		struct rtattr *tb[TCA_NETEM_MAX];
-		if (rtattr_parse(tb, TCA_NETEM_MAX,
-				 RTA_DATA(opt) + sizeof(*qopt),
-				 RTA_PAYLOAD(opt) - sizeof(*qopt)))
+	if (nla_len(opt) > sizeof(*qopt)) {
+		struct nlattr *tb[TCA_NETEM_MAX + 1];
+		if (nla_parse(tb, TCA_NETEM_MAX,
+			      nla_data(opt) + sizeof(*qopt),
+			      nla_len(opt) - sizeof(*qopt), NULL))
 			return -EINVAL;
 
-		if (tb[TCA_NETEM_CORR-1]) {
-			ret = get_correlation(sch, tb[TCA_NETEM_CORR-1]);
+		if (tb[TCA_NETEM_CORR]) {
+			ret = get_correlation(sch, tb[TCA_NETEM_CORR]);
 			if (ret)
 				return ret;
 		}
 
-		if (tb[TCA_NETEM_DELAY_DIST-1]) {
-			ret = get_dist_table(sch, tb[TCA_NETEM_DELAY_DIST-1]);
+		if (tb[TCA_NETEM_DELAY_DIST]) {
+			ret = get_dist_table(sch, tb[TCA_NETEM_DELAY_DIST]);
 			if (ret)
 				return ret;
 		}
 
-		if (tb[TCA_NETEM_REORDER-1]) {
-			ret = get_reorder(sch, tb[TCA_NETEM_REORDER-1]);
+		if (tb[TCA_NETEM_REORDER]) {
+			ret = get_reorder(sch, tb[TCA_NETEM_REORDER]);
 			if (ret)
 				return ret;
 		}
 
-		if (tb[TCA_NETEM_CORRUPT-1]) {
-			ret = get_corrupt(sch, tb[TCA_NETEM_CORRUPT-1]);
+		if (tb[TCA_NETEM_CORRUPT]) {
+			ret = get_corrupt(sch, tb[TCA_NETEM_CORRUPT]);
 			if (ret)
 				return ret;
 		}
@@ -515,13 +515,13 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 	return qdisc_reshape_fail(nskb, sch);
 }
 
-static int tfifo_init(struct Qdisc *sch, struct rtattr *opt)
+static int tfifo_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
 	if (opt) {
-		struct tc_fifo_qopt *ctl = RTA_DATA(opt);
-		if (RTA_PAYLOAD(opt) < sizeof(*ctl))
+		struct tc_fifo_qopt *ctl = nla_data(opt);
+		if (nla_len(opt) < sizeof(*ctl))
 			return -EINVAL;
 
 		q->limit = ctl->limit;
@@ -537,10 +537,10 @@ static int tfifo_dump(struct Qdisc *sch, struct sk_buff *skb)
 	struct fifo_sched_data *q = qdisc_priv(sch);
 	struct tc_fifo_qopt opt = { .limit = q->limit };
 
-	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	return -1;
 }
 
@@ -557,7 +557,7 @@ static struct Qdisc_ops tfifo_qdisc_ops __read_mostly = {
 	.dump		=	tfifo_dump,
 };
 
-static int netem_init(struct Qdisc *sch, struct rtattr *opt)
+static int netem_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	int ret;
@@ -595,7 +595,7 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	const struct netem_sched_data *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta = (struct rtattr *) b;
+	struct nlattr *nla = (struct nlattr *) b;
 	struct tc_netem_qopt qopt;
 	struct tc_netem_corr cor;
 	struct tc_netem_reorder reorder;
@@ -607,26 +607,26 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 	qopt.loss = q->loss;
 	qopt.gap = q->gap;
 	qopt.duplicate = q->duplicate;
-	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
+	NLA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
 
 	cor.delay_corr = q->delay_cor.rho;
 	cor.loss_corr = q->loss_cor.rho;
 	cor.dup_corr = q->dup_cor.rho;
-	RTA_PUT(skb, TCA_NETEM_CORR, sizeof(cor), &cor);
+	NLA_PUT(skb, TCA_NETEM_CORR, sizeof(cor), &cor);
 
 	reorder.probability = q->reorder;
 	reorder.correlation = q->reorder_cor.rho;
-	RTA_PUT(skb, TCA_NETEM_REORDER, sizeof(reorder), &reorder);
+	NLA_PUT(skb, TCA_NETEM_REORDER, sizeof(reorder), &reorder);
 
 	corrupt.probability = q->corrupt;
 	corrupt.correlation = q->corrupt_cor.rho;
-	RTA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
+	NLA_PUT(skb, TCA_NETEM_CORRUPT, sizeof(corrupt), &corrupt);
 
-	rta->rta_len = skb_tail_pointer(skb) - b;
+	nla->nla_len = skb_tail_pointer(skb) - b;
 
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -678,7 +678,7 @@ static void netem_put(struct Qdisc *sch, unsigned long arg)
 }
 
 static int netem_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct rtattr **tca, unsigned long *arg)
+			    struct nlattr **tca, unsigned long *arg)
 {
 	return -ENOSYS;
 }
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 2243aaa..a4f932d 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -224,15 +224,15 @@ prio_destroy(struct Qdisc* sch)
 		qdisc_destroy(q->queues[prio]);
 }
 
-static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
+static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tc_prio_qopt *qopt;
-	struct rtattr *tb[TCA_PRIO_MAX];
+	struct nlattr *tb[TCA_PRIO_MAX + 1];
 	int i;
 
-	if (rtattr_parse_nested_compat(tb, TCA_PRIO_MAX, opt, qopt,
-				       sizeof(*qopt)))
+	if (nla_parse_nested_compat(tb, TCA_PRIO_MAX, opt, NULL, qopt,
+				    sizeof(*qopt)))
 		return -EINVAL;
 	q->bands = qopt->bands;
 	/* If we're multiqueue, make sure the number of incoming bands
@@ -242,7 +242,7 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 	 * only one that is enabled for multiqueue, since it's the only one
 	 * that interacts with the underlying device.
 	 */
-	q->mq = RTA_GET_FLAG(tb[TCA_PRIO_MQ - 1]);
+	q->mq = nla_get_flag(tb[TCA_PRIO_MQ]);
 	if (q->mq) {
 		if (sch->parent != TC_H_ROOT)
 			return -EINVAL;
@@ -296,7 +296,7 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 	return 0;
 }
 
-static int prio_init(struct Qdisc *sch, struct rtattr *opt)
+static int prio_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	int i;
@@ -319,20 +319,24 @@ static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *nest;
+	struct nlattr *nest;
 	struct tc_prio_qopt opt;
 
 	opt.bands = q->bands;
 	memcpy(&opt.priomap, q->prio2band, TC_PRIO_MAX+1);
 
-	nest = RTA_NEST_COMPAT(skb, TCA_OPTIONS, sizeof(opt), &opt);
-	if (q->mq)
-		RTA_PUT_FLAG(skb, TCA_PRIO_MQ);
-	RTA_NEST_COMPAT_END(skb, nest);
+	nest = nla_nest_compat_start(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	if (nest == NULL)
+		goto nla_put_failure;
+	if (q->mq) {
+		if (nla_put_flag(skb, TCA_PRIO_MQ) < 0)
+			goto nla_put_failure;
+	}
+	nla_nest_compat_end(skb, nest);
 
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -392,7 +396,7 @@ static void prio_put(struct Qdisc *q, unsigned long cl)
 	return;
 }
 
-static int prio_change(struct Qdisc *sch, u32 handle, u32 parent, struct rtattr **tca, unsigned long *arg)
+static int prio_change(struct Qdisc *sch, u32 handle, u32 parent, struct nlattr **tca, unsigned long *arg)
 {
 	unsigned long cl = *arg;
 	struct prio_sched_data *q = qdisc_priv(sch);
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index f1e9647..6ce8da5 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -177,21 +177,21 @@ static void red_destroy(struct Qdisc *sch)
 static struct Qdisc *red_create_dflt(struct Qdisc *sch, u32 limit)
 {
 	struct Qdisc *q;
-	struct rtattr *rta;
+	struct nlattr *nla;
 	int ret;
 
 	q = qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops,
 			      TC_H_MAKE(sch->handle, 1));
 	if (q) {
-		rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)),
+		nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)),
 			      GFP_KERNEL);
-		if (rta) {
-			rta->rta_type = RTM_NEWQDISC;
-			rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
-			((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
+		if (nla) {
+			nla->nla_type = RTM_NEWQDISC;
+			nla->nla_len = nla_attr_size(sizeof(struct tc_fifo_qopt));
+			((struct tc_fifo_qopt *)nla_data(nla))->limit = limit;
 
-			ret = q->ops->change(q, rta);
-			kfree(rta);
+			ret = q->ops->change(q, nla);
+			kfree(nla);
 
 			if (ret == 0)
 				return q;
@@ -201,23 +201,23 @@ static struct Qdisc *red_create_dflt(struct Qdisc *sch, u32 limit)
 	return NULL;
 }
 
-static int red_change(struct Qdisc *sch, struct rtattr *opt)
+static int red_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
-	struct rtattr *tb[TCA_RED_MAX];
+	struct nlattr *tb[TCA_RED_MAX + 1];
 	struct tc_red_qopt *ctl;
 	struct Qdisc *child = NULL;
 
-	if (opt == NULL || rtattr_parse_nested(tb, TCA_RED_MAX, opt))
+	if (opt == NULL || nla_parse_nested(tb, TCA_RED_MAX, opt, NULL))
 		return -EINVAL;
 
-	if (tb[TCA_RED_PARMS-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_RED_PARMS-1]) < sizeof(*ctl) ||
-	    tb[TCA_RED_STAB-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_RED_STAB-1]) < RED_STAB_SIZE)
+	if (tb[TCA_RED_PARMS] == NULL ||
+	    nla_len(tb[TCA_RED_PARMS]) < sizeof(*ctl) ||
+	    tb[TCA_RED_STAB] == NULL ||
+	    nla_len(tb[TCA_RED_STAB]) < RED_STAB_SIZE)
 		return -EINVAL;
 
-	ctl = RTA_DATA(tb[TCA_RED_PARMS-1]);
+	ctl = nla_data(tb[TCA_RED_PARMS]);
 
 	if (ctl->limit > 0) {
 		child = red_create_dflt(sch, ctl->limit);
@@ -235,7 +235,7 @@ static int red_change(struct Qdisc *sch, struct rtattr *opt)
 
 	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
 				 ctl->Plog, ctl->Scell_log,
-				 RTA_DATA(tb[TCA_RED_STAB-1]));
+				 nla_data(tb[TCA_RED_STAB]));
 
 	if (skb_queue_empty(&sch->q))
 		red_end_of_idle_period(&q->parms);
@@ -244,7 +244,7 @@ static int red_change(struct Qdisc *sch, struct rtattr *opt)
 	return 0;
 }
 
-static int red_init(struct Qdisc* sch, struct rtattr *opt)
+static int red_init(struct Qdisc* sch, struct nlattr *opt)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 
@@ -255,7 +255,7 @@ static int red_init(struct Qdisc* sch, struct rtattr *opt)
 static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
-	struct rtattr *opts = NULL;
+	struct nlattr *opts = NULL;
 	struct tc_red_qopt opt = {
 		.limit		= q->limit,
 		.flags		= q->flags,
@@ -266,12 +266,14 @@ static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 		.Scell_log	= q->parms.Scell_log,
 	};
 
-	opts = RTA_NEST(skb, TCA_OPTIONS);
-	RTA_PUT(skb, TCA_RED_PARMS, sizeof(opt), &opt);
-	return RTA_NEST_END(skb, opts);
+	opts = nla_nest_start(skb, TCA_OPTIONS);
+	if (opts == NULL)
+		goto nla_put_failure;
+	NLA_PUT(skb, TCA_RED_PARMS, sizeof(opt), &opt);
+	return nla_nest_end(skb, opts);
 
-rtattr_failure:
-	return RTA_NEST_CANCEL(skb, opts);
+nla_put_failure:
+	return nla_nest_cancel(skb, opts);
 }
 
 static int red_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
@@ -332,7 +334,7 @@ static void red_put(struct Qdisc *sch, unsigned long arg)
 }
 
 static int red_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct rtattr **tca, unsigned long *arg)
+			    struct nlattr **tca, unsigned long *arg)
 {
 	return -ENOSYS;
 }
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 25afe0f..91af539 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -397,13 +397,13 @@ static void sfq_perturbation(unsigned long arg)
 		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
 }
 
-static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
+static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	struct tc_sfq_qopt *ctl = RTA_DATA(opt);
+	struct tc_sfq_qopt *ctl = nla_data(opt);
 	unsigned int qlen;
 
-	if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
+	if (opt->nla_len < nla_attr_size(sizeof(*ctl)))
 		return -EINVAL;
 
 	sch_tree_lock(sch);
@@ -426,7 +426,7 @@ static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 	return 0;
 }
 
-static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
+static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	int i;
@@ -481,11 +481,11 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opt.divisor = SFQ_HASH_DIVISOR;
 	opt.flows = q->limit;
 
-	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index d88fea9..6c4ad7e 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -245,20 +245,21 @@ static void tbf_reset(struct Qdisc* sch)
 static struct Qdisc *tbf_create_dflt_qdisc(struct Qdisc *sch, u32 limit)
 {
 	struct Qdisc *q;
-	struct rtattr *rta;
+	struct nlattr *nla;
 	int ret;
 
 	q = qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops,
 			      TC_H_MAKE(sch->handle, 1));
 	if (q) {
-		rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
-		if (rta) {
-			rta->rta_type = RTM_NEWQDISC;
-			rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
-			((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
+		nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)),
+			      GFP_KERNEL);
+		if (nla) {
+			nla->nla_type = RTM_NEWQDISC;
+			nla->nla_len = nla_attr_size(sizeof(struct tc_fifo_qopt));
+			((struct tc_fifo_qopt *)nla_data(nla))->limit = limit;
 
-			ret = q->ops->change(q, rta);
-			kfree(rta);
+			ret = q->ops->change(q, nla);
+			kfree(nla);
 
 			if (ret == 0)
 				return q;
@@ -269,30 +270,30 @@ static struct Qdisc *tbf_create_dflt_qdisc(struct Qdisc *sch, u32 limit)
 	return NULL;
 }
 
-static int tbf_change(struct Qdisc* sch, struct rtattr *opt)
+static int tbf_change(struct Qdisc* sch, struct nlattr *opt)
 {
 	int err = -EINVAL;
 	struct tbf_sched_data *q = qdisc_priv(sch);
-	struct rtattr *tb[TCA_TBF_PTAB];
+	struct nlattr *tb[TCA_TBF_PTAB + 1];
 	struct tc_tbf_qopt *qopt;
 	struct qdisc_rate_table *rtab = NULL;
 	struct qdisc_rate_table *ptab = NULL;
 	struct Qdisc *child = NULL;
 	int max_size,n;
 
-	if (rtattr_parse_nested(tb, TCA_TBF_PTAB, opt) ||
-	    tb[TCA_TBF_PARMS-1] == NULL ||
-	    RTA_PAYLOAD(tb[TCA_TBF_PARMS-1]) < sizeof(*qopt))
+	if (nla_parse_nested(tb, TCA_TBF_PTAB, opt, NULL) ||
+	    tb[TCA_TBF_PARMS] == NULL ||
+	    nla_len(tb[TCA_TBF_PARMS]) < sizeof(*qopt))
 		goto done;
 
-	qopt = RTA_DATA(tb[TCA_TBF_PARMS-1]);
-	rtab = qdisc_get_rtab(&qopt->rate, tb[TCA_TBF_RTAB-1]);
+	qopt = nla_data(tb[TCA_TBF_PARMS]);
+	rtab = qdisc_get_rtab(&qopt->rate, tb[TCA_TBF_RTAB]);
 	if (rtab == NULL)
 		goto done;
 
 	if (qopt->peakrate.rate) {
 		if (qopt->peakrate.rate > qopt->rate.rate)
-			ptab = qdisc_get_rtab(&qopt->peakrate, tb[TCA_TBF_PTAB-1]);
+			ptab = qdisc_get_rtab(&qopt->peakrate, tb[TCA_TBF_PTAB]);
 		if (ptab == NULL)
 			goto done;
 	}
@@ -339,7 +340,7 @@ done:
 	return err;
 }
 
-static int tbf_init(struct Qdisc* sch, struct rtattr *opt)
+static int tbf_init(struct Qdisc* sch, struct nlattr *opt)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
@@ -371,11 +372,11 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
-	struct rtattr *rta;
+	struct nlattr *nla;
 	struct tc_tbf_qopt opt;
 
-	rta = (struct rtattr*)b;
-	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	nla = (struct nlattr*)b;
+	NLA_PUT(skb, TCA_OPTIONS, 0, NULL);
 
 	opt.limit = q->limit;
 	opt.rate = q->R_tab->rate;
@@ -385,12 +386,12 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
 		memset(&opt.peakrate, 0, sizeof(opt.peakrate));
 	opt.mtu = q->mtu;
 	opt.buffer = q->buffer;
-	RTA_PUT(skb, TCA_TBF_PARMS, sizeof(opt), &opt);
-	rta->rta_len = skb_tail_pointer(skb) - b;
+	NLA_PUT(skb, TCA_TBF_PARMS, sizeof(opt), &opt);
+	nla->nla_len = skb_tail_pointer(skb) - b;
 
 	return skb->len;
 
-rtattr_failure:
+nla_put_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -442,7 +443,7 @@ static void tbf_put(struct Qdisc *sch, unsigned long arg)
 }
 
 static int tbf_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
-			    struct rtattr **tca, unsigned long *arg)
+			    struct nlattr **tca, unsigned long *arg)
 {
 	return -ENOSYS;
 }
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index c0ed06d..1411c7b 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -168,7 +168,7 @@ teql_destroy(struct Qdisc* sch)
 	}
 }
 
-static int teql_qdisc_init(struct Qdisc *sch, struct rtattr *opt)
+static int teql_qdisc_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct net_device *dev = sch->dev;
 	struct teql_master *m = (struct teql_master*)sch->ops;
