From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v3][NET] gen_estimator: faster gen_kill_estimator
Date: Fri, 25 Jan 2008 23:00:55 +0100
Message-ID: <20080125220055.GA3886@ami.dom.local>
References: <20080120234659.GA2691@ami.dom.local> <20080121223137.GB2758@ami.dom.local> <20080121.162918.148129860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, slavon@bigtelecom.ru, kaber@trash.net,
	hadi@cyberus.ca, shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.234]:9811 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755754AbYAYV6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 16:58:34 -0500
Received: by hu-out-0506.google.com with SMTP id 19so483235hue.21
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 13:58:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080121.162918.148129860.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 04:29:18PM -0800, David Miller wrote:
...
> Fix this right, make a structure like:
> 
> struct kernel_gnet_stats_rate_est {
> 	struct gnet_stats_rate_est	est;
> 	void				*gen_estimator;
> }
> 
> And update all the code as needed.

Hi,

Here is a patch which uses this idea, I hope mostly as expected. This
new structure has to replace the older one in most kernel places. I was
uncertain of gnet_stats_copy_rate_est(), the change wasn't necessary here
but could be considered for uniformity reasons. Currently it's unchanged.
Of course, I admit it's not the last version, and any suggestions are
welcomed (including updating to some later version - I see there is some
queue waiting with sched changes).

Regards,
Jarek P.

--------------> (take 3)

gen_kill_estimator() is called during qdisc_destroy() with BHs disabled,
and each time does searching for each list member. This can block soft
interrupts for quite a long time when many classes are used.

This patch changes this by storing pointers to internal gen_estimator
structures. New kernel_gnet_stats_rate_est structure is created for this
as a wrapper around gnet_stats_rate_est being a part of userspace API.
Respectively all callers of gen_estimator functions, and structures used
by them to store rate_est are modified.

This method removes currently possibile registering in gen_estimator the
same structures more than once, but it isn't used after all.

Thanks to David Miller for pointing errors in first versions of this patch
and for suggesting proper solution.


Reported-by: Badalian Vyacheslav <slavon@bigtelecom.ru>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 Documentation/networking/gen_stats.txt |   10 +++--
 include/linux/gen_stats.h              |   13 ++++++
 include/net/act_api.h                  |    4 +-
 include/net/gen_stats.h                |    8 ++--
 include/net/netfilter/xt_rateest.h     |    2 +-
 include/net/sch_generic.h              |    2 +-
 net/core/gen_estimator.c               |   65 ++++++++++++++------------------
 net/netfilter/xt_RATEEST.c             |    4 +-
 net/netfilter/xt_rateest.c             |    4 +-
 net/sched/act_api.c                    |    7 +--
 net/sched/act_police.c                 |    7 +--
 net/sched/sch_api.c                    |    6 +-
 net/sched/sch_cbq.c                    |   10 ++--
 net/sched/sch_generic.c                |    2 +-
 net/sched/sch_hfsc.c                   |   10 ++--
 net/sched/sch_htb.c                    |   12 +++---
 16 files changed, 85 insertions(+), 81 deletions(-)


diff --git a/Documentation/networking/gen_stats.txt b/Documentation/networking/gen_stats.txt
index 70e6275..fc45f94 100644
--- a/Documentation/networking/gen_stats.txt
+++ b/Documentation/networking/gen_stats.txt
@@ -6,10 +6,12 @@ Statistic counters are grouped into structs:
 Struct               TLV type              Description
 ----------------------------------------------------------------------
 gnet_stats_basic     TCA_STATS_BASIC       Basic statistics
-gnet_stats_rate_est  TCA_STATS_RATE_EST    Rate estimator
+gnet_stats_rate_est* TCA_STATS_RATE_EST    Rate estimator
 gnet_stats_queue     TCA_STATS_QUEUE       Queue statistics
 none                 TCA_STATS_APP         Application specific
 
+* From v2.6.25 kernel uses internal struct kernel_gnet_stats_rate_est
+  for gen_estimator functions calls.
 
 Collecting:
 -----------
@@ -106,9 +108,9 @@ In the kernel when setting up:
 From now on, every time you dump my_rate_est_stats it will contain
 up-to-date info.
 
-Once you are done, call gen_kill_estimator(my_basicstats,
-my_rate_est_stats) Make sure that my_basicstats and my_rate_est_stats
-are still valid (i.e still exist) at the time of making this call.
+Once you are done, call gen_kill_estimator(my_rate_est_stats). Make
+sure that my_rate_est_stats is still valid (i.e still exists) at the
+time of making this call.
 
 
 Authors:
diff --git a/include/linux/gen_stats.h b/include/linux/gen_stats.h
index 13f4e74..12b76d2 100644
--- a/include/linux/gen_stats.h
+++ b/include/linux/gen_stats.h
@@ -35,6 +35,19 @@ struct gnet_stats_rate_est
 	__u32	pps;
 };
 
+#ifdef __KERNEL__
+/**
+ * struct kernel_gnet_stats_rate_est - rate estimator wrapper
+ * @est: rate estimator
+ * @gen_estimator: internal data
+ */
+struct kernel_gnet_stats_rate_est
+{
+	struct gnet_stats_rate_est	est;
+	void				*gen_estimator;
+};
+#endif
+
 /**
  * struct gnet_stats_queue - queuing statistics
  * @qlen: queue length
diff --git a/include/net/act_api.h b/include/net/act_api.h
index c5ac61a..c02ce27 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -18,7 +18,7 @@ struct tcf_common {
 	struct tcf_t			tcfc_tm;
 	struct gnet_stats_basic		tcfc_bstats;
 	struct gnet_stats_queue		tcfc_qstats;
-	struct gnet_stats_rate_est	tcfc_rate_est;
+	struct kernel_gnet_stats_rate_est	tcfc_k_rate_est;
 	spinlock_t			tcfc_lock;
 };
 #define tcf_next	common.tcfc_next
@@ -30,7 +30,7 @@ struct tcf_common {
 #define tcf_tm		common.tcfc_tm
 #define tcf_bstats	common.tcfc_bstats
 #define tcf_qstats	common.tcfc_qstats
-#define tcf_rate_est	common.tcfc_rate_est
+#define tcf_k_rate_est	common.tcfc_k_rate_est
 #define tcf_lock	common.tcfc_lock
 
 struct tcf_police {
diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index 8cd8185..af131f6 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -38,12 +38,12 @@ extern int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
 extern int gnet_stats_finish_copy(struct gnet_dump *d);
 
 extern int gen_new_estimator(struct gnet_stats_basic *bstats,
-			     struct gnet_stats_rate_est *rate_est,
+			     struct kernel_gnet_stats_rate_est *k_rate_est,
 			     spinlock_t *stats_lock, struct nlattr *opt);
-extern void gen_kill_estimator(struct gnet_stats_basic *bstats,
-			       struct gnet_stats_rate_est *rate_est);
+extern void gen_kill_estimator(struct kernel_gnet_stats_rate_est *k_rate_est);
+
 extern int gen_replace_estimator(struct gnet_stats_basic *bstats,
-				 struct gnet_stats_rate_est *rate_est,
+				 struct kernel_gnet_stats_rate_est *k_rate_est,
 				 spinlock_t *stats_lock, struct nlattr *opt);
 
 #endif
diff --git a/include/net/netfilter/xt_rateest.h b/include/net/netfilter/xt_rateest.h
index 65d594d..60aca83 100644
--- a/include/net/netfilter/xt_rateest.h
+++ b/include/net/netfilter/xt_rateest.h
@@ -7,7 +7,7 @@ struct xt_rateest {
 	unsigned int			refcnt;
 	spinlock_t			lock;
 	struct gnet_estimator		params;
-	struct gnet_stats_rate_est	rstats;
+	struct kernel_gnet_stats_rate_est	k_rstats;
 	struct gnet_stats_basic		bstats;
 };
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index ab502ec..ea6f5f4 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -42,7 +42,7 @@ struct Qdisc
 
 	struct gnet_stats_basic	bstats;
 	struct gnet_stats_queue	qstats;
-	struct gnet_stats_rate_est	rate_est;
+	struct kernel_gnet_stats_rate_est	k_rate_est;
 	spinlock_t		*stats_lock;
 	struct rcu_head 	q_rcu;
 	int			(*reshape_fail)(struct sk_buff *skb,
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 57abe82..986fc84 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -142,22 +142,23 @@ skip:
 /**
  * gen_new_estimator - create a new rate estimator
  * @bstats: basic statistics
- * @rate_est: rate estimator statistics
+ * @k_rate_est: rate estimator statistics and internal data
  * @stats_lock: statistics lock
  * @opt: rate estimator configuration TLV
  *
- * Creates a new rate estimator with &bstats as source and &rate_est
+ * Creates a new rate estimator with &bstats as source and &k_rate_est->est
  * as destination. A new timer with the interval specified in the
  * configuration TLV is created. Upon each interval, the latest statistics
  * will be read from &bstats and the estimated rate will be stored in
- * &rate_est with the statistics lock grabed during this period.
+ * &k_rate_est->est with the statistics lock grabed during this period.
+ * &k_rate_est also stores internal data required for gen_kill_estimator.
  *
  * Returns 0 on success or a negative error code.
  *
  * NOTE: Called under rtnl_mutex
  */
 int gen_new_estimator(struct gnet_stats_basic *bstats,
-		      struct gnet_stats_rate_est *rate_est,
+		      struct kernel_gnet_stats_rate_est *k_rate_est,
 		      spinlock_t *stats_lock,
 		      struct nlattr *opt)
 {
@@ -172,18 +173,19 @@ int gen_new_estimator(struct gnet_stats_basic *bstats,
 		return -EINVAL;
 
 	est = kzalloc(sizeof(*est), GFP_KERNEL);
+	k_rate_est->gen_estimator = est;
 	if (est == NULL)
 		return -ENOBUFS;
 
 	idx = parm->interval + 2;
 	est->bstats = bstats;
-	est->rate_est = rate_est;
+	est->rate_est = &k_rate_est->est;
 	est->stats_lock = stats_lock;
 	est->ewma_log = parm->ewma_log;
 	est->last_bytes = bstats->bytes;
-	est->avbps = rate_est->bps<<5;
+	est->avbps = k_rate_est->est.bps << 5;
 	est->last_packets = bstats->packets;
-	est->avpps = rate_est->pps<<10;
+	est->avpps = k_rate_est->est.pps << 10;
 
 	if (!elist[idx].timer.function) {
 		INIT_LIST_HEAD(&elist[idx].list);
@@ -206,44 +208,33 @@ static void __gen_kill_estimator(struct rcu_head *head)
 
 /**
  * gen_kill_estimator - remove a rate estimator
- * @bstats: basic statistics
- * @rate_est: rate estimator statistics
+ * @k_rate_est: rate estimator statistics and internal data
  *
- * Removes the rate estimator specified by &bstats and &rate_est
- * and deletes the timer.
+ * Removes the rate estimator specified by &k_rate_est.
  *
  * NOTE: Called under rtnl_mutex
  */
-void gen_kill_estimator(struct gnet_stats_basic *bstats,
-	struct gnet_stats_rate_est *rate_est)
+void gen_kill_estimator(struct kernel_gnet_stats_rate_est *k_rate_est)
 {
-	int idx;
-	struct gen_estimator *e, *n;
-
-	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
-
-		/* Skip non initialized indexes */
-		if (!elist[idx].timer.function)
-			continue;
-
-		list_for_each_entry_safe(e, n, &elist[idx].list, list) {
-			if (e->rate_est != rate_est || e->bstats != bstats)
-				continue;
-
-			write_lock_bh(&est_lock);
-			e->bstats = NULL;
-			write_unlock_bh(&est_lock);
-
-			list_del_rcu(&e->list);
-			call_rcu(&e->e_rcu, __gen_kill_estimator);
-		}
+	if (k_rate_est && k_rate_est->gen_estimator) {
+		struct gen_estimator *e;
+		
+		e = (struct gen_estimator *)k_rate_est->gen_estimator;
+		k_rate_est->gen_estimator = NULL;
+
+		write_lock_bh(&est_lock);
+		e->bstats = NULL;
+		write_unlock_bh(&est_lock);
+
+		list_del_rcu(&e->list);
+		call_rcu(&e->e_rcu, __gen_kill_estimator);
 	}
 }
 
 /**
  * gen_replace_estimator - replace rate estimator configuration
  * @bstats: basic statistics
- * @rate_est: rate estimator statistics
+ * @k_rate_est: rate estimator statistics and internal data
  * @stats_lock: statistics lock
  * @opt: rate estimator configuration TLV
  *
@@ -253,11 +244,11 @@ void gen_kill_estimator(struct gnet_stats_basic *bstats,
  * Returns 0 on success or a negative error code.
  */
 int gen_replace_estimator(struct gnet_stats_basic *bstats,
-			  struct gnet_stats_rate_est *rate_est,
+			  struct kernel_gnet_stats_rate_est *k_rate_est,
 			  spinlock_t *stats_lock, struct nlattr *opt)
 {
-	gen_kill_estimator(bstats, rate_est);
-	return gen_new_estimator(bstats, rate_est, stats_lock, opt);
+	gen_kill_estimator(k_rate_est);
+	return gen_new_estimator(bstats, k_rate_est, stats_lock, opt);
 }
 
 
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 24c73ba..ac5a4ec 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -63,7 +63,7 @@ void xt_rateest_put(struct xt_rateest *est)
 	mutex_lock(&xt_rateest_mutex);
 	if (--est->refcnt == 0) {
 		hlist_del(&est->list);
-		gen_kill_estimator(&est->bstats, &est->rstats);
+		gen_kill_estimator(&est->k_rstats);
 		kfree(est);
 	}
 	mutex_unlock(&xt_rateest_mutex);
@@ -134,7 +134,7 @@ xt_rateest_tg_checkentry(const char *tablename,
 	cfg.est.interval	= info->interval;
 	cfg.est.ewma_log	= info->ewma_log;
 
-	if (gen_new_estimator(&est->bstats, &est->rstats, &est->lock,
+	if (gen_new_estimator(&est->bstats, &est->k_rstats, &est->lock,
 			      &cfg.opt) < 0)
 		goto err2;
 
diff --git a/net/netfilter/xt_rateest.c b/net/netfilter/xt_rateest.c
index fdb86a5..e2ba9c7 100644
--- a/net/netfilter/xt_rateest.c
+++ b/net/netfilter/xt_rateest.c
@@ -29,7 +29,7 @@ static bool xt_rateest_mt(const struct sk_buff *skb,
 	bool ret = true;
 
 	spin_lock_bh(&info->est1->lock);
-	r = &info->est1->rstats;
+	r = &info->est1->k_rstats.est;
 	if (info->flags & XT_RATEEST_MATCH_DELTA) {
 		bps1 = info->bps1 >= r->bps ? info->bps1 - r->bps : 0;
 		pps1 = info->pps1 >= r->pps ? info->pps1 - r->pps : 0;
@@ -44,7 +44,7 @@ static bool xt_rateest_mt(const struct sk_buff *skb,
 		pps2 = info->pps2;
 	} else {
 		spin_lock_bh(&info->est2->lock);
-		r = &info->est2->rstats;
+		r = &info->est2->k_rstats.est;
 		if (info->flags & XT_RATEEST_MATCH_DELTA) {
 			bps2 = info->bps2 >= r->bps ? info->bps2 - r->bps : 0;
 			pps2 = info->pps2 >= r->pps ? info->pps2 - r->pps : 0;
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index ebd21d2..edfb238 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -34,8 +34,7 @@ void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo)
 			write_lock_bh(hinfo->lock);
 			*p1p = p->tcfc_next;
 			write_unlock_bh(hinfo->lock);
-			gen_kill_estimator(&p->tcfc_bstats,
-					   &p->tcfc_rate_est);
+			gen_kill_estimator(&p->tcfc_k_rate_est);
 			kfree(p);
 			return;
 		}
@@ -226,7 +225,7 @@ struct tcf_common *tcf_hash_create(u32 index, struct nlattr *est, struct tc_acti
 	p->tcfc_tm.install = jiffies;
 	p->tcfc_tm.lastuse = jiffies;
 	if (est)
-		gen_new_estimator(&p->tcfc_bstats, &p->tcfc_rate_est,
+		gen_new_estimator(&p->tcfc_bstats, &p->tcfc_k_rate_est,
 				  &p->tcfc_lock, est);
 	a->priv = (void *) p;
 	return p;
@@ -605,7 +604,7 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 			goto errout;
 
 	if (gnet_stats_copy_basic(&d, &h->tcf_bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &h->tcf_rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &h->tcf_k_rate_est.est) < 0 ||
 	    gnet_stats_copy_queue(&d, &h->tcf_qstats) < 0)
 		goto errout;
 
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 3af5759..c0ca461 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -105,8 +105,7 @@ static void tcf_police_destroy(struct tcf_police *p)
 			write_lock_bh(&police_lock);
 			*p1p = p->tcf_next;
 			write_unlock_bh(&police_lock);
-			gen_kill_estimator(&p->tcf_bstats,
-					   &p->tcf_rate_est);
+			gen_kill_estimator(&p->tcf_k_rate_est);
 			if (p->tcfp_R_tab)
 				qdisc_put_rtab(p->tcfp_R_tab);
 			if (p->tcfp_P_tab)
@@ -215,7 +214,7 @@ override:
 			*(u32*)nla_data(tb[TCA_POLICE_AVRATE]);
 	if (est)
 		gen_replace_estimator(&police->tcf_bstats,
-				      &police->tcf_rate_est,
+				      &police->tcf_k_rate_est,
 				      &police->tcf_lock, est);
 
 	spin_unlock_bh(&police->tcf_lock);
@@ -272,7 +271,7 @@ static int tcf_act_police(struct sk_buff *skb, struct tc_action *a,
 	police->tcf_bstats.packets++;
 
 	if (police->tcfp_ewma_rate &&
-	    police->tcf_rate_est.bps >= police->tcfp_ewma_rate) {
+	    police->tcf_k_rate_est.est.bps >= police->tcfp_ewma_rate) {
 		police->tcf_qstats.overlimits++;
 		spin_unlock(&police->tcf_lock);
 		return police->tcf_action;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 7abb028..87b8113 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -511,7 +511,7 @@ qdisc_create(struct net_device *dev, u32 parent, u32 handle,
 
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS])) == 0) {
 		if (tca[TCA_RATE]) {
-			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
+			err = gen_new_estimator(&sch->bstats, &sch->k_rate_est,
 						sch->stats_lock,
 						tca[TCA_RATE]);
 			if (err) {
@@ -553,7 +553,7 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 			return err;
 	}
 	if (tca[TCA_RATE])
-		gen_replace_estimator(&sch->bstats, &sch->rate_est,
+		gen_replace_estimator(&sch->bstats, &sch->k_rate_est,
 			sch->stats_lock, tca[TCA_RATE]);
 	return 0;
 }
@@ -847,7 +847,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		goto nla_put_failure;
 
 	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &q->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(&d, &q->k_rate_est.est) < 0 ||
 	    gnet_stats_copy_queue(&d, &q->qstats) < 0)
 		goto nla_put_failure;
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 5c8667e..cbf24bd 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -131,7 +131,7 @@ struct cbq_class
 	psched_time_t		penalized;
 	struct gnet_stats_basic bstats;
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est rate_est;
+	struct kernel_gnet_stats_rate_est k_rate_est;
 	struct tc_cbq_xstats	xstats;
 
 	struct tcf_proto	*filter_list;
@@ -1627,7 +1627,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 		cl->xstats.undertime = cl->undertime - q->now;
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->k_rate_est.est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
@@ -1698,7 +1698,7 @@ static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 	tcf_destroy_chain(cl->filter_list);
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->k_rate_est);
 	if (cl != &q->link)
 		kfree(cl);
 }
@@ -1844,7 +1844,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 		sch_tree_unlock(sch);
 
 		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
+			gen_replace_estimator(&cl->bstats, &cl->k_rate_est,
 					      &sch->dev->queue_lock,
 					      tca[TCA_RATE]);
 		return 0;
@@ -1932,7 +1932,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	sch_tree_unlock(sch);
 
 	if (tca[TCA_RATE])
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
+		gen_new_estimator(&cl->bstats, &cl->k_rate_est,
 				  &sch->dev->queue_lock, tca[TCA_RATE]);
 
 	*arg = (unsigned long)cl;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 10b5c08..37206e7 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -509,7 +509,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 		return;
 
 	list_del(&qdisc->list);
-	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
+	gen_kill_estimator(&qdisc->k_rate_est);
 	if (ops->reset)
 		ops->reset(qdisc);
 	if (ops->destroy)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 4e6a164..31b9752 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -118,7 +118,7 @@ struct hfsc_class
 
 	struct gnet_stats_basic bstats;
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est rate_est;
+	struct kernel_gnet_stats_rate_est k_rate_est;
 	unsigned int	level;		/* class level in hierarchy */
 	struct tcf_proto *filter_list;	/* filter list */
 	unsigned int	filter_cnt;	/* filter count */
@@ -1051,7 +1051,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		sch_tree_unlock(sch);
 
 		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
+			gen_replace_estimator(&cl->bstats, &cl->k_rate_est,
 					      &sch->dev->queue_lock,
 					      tca[TCA_RATE]);
 		return 0;
@@ -1107,7 +1107,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	sch_tree_unlock(sch);
 
 	if (tca[TCA_RATE])
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
+		gen_new_estimator(&cl->bstats, &cl->k_rate_est,
 				  &sch->dev->queue_lock, tca[TCA_RATE]);
 	*arg = (unsigned long)cl;
 	return 0;
@@ -1120,7 +1120,7 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 
 	tcf_destroy_chain(cl->filter_list);
 	qdisc_destroy(cl->qdisc);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->k_rate_est);
 	if (cl != &q->root)
 		kfree(cl);
 }
@@ -1371,7 +1371,7 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	xstats.rtwork  = cl->cl_cumul;
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->k_rate_est.est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 3b3ff64..cee8c01 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -54,7 +54,7 @@
 
 #define HTB_HSIZE 16		/* classid hash size */
 #define HTB_HYSTERESIS 1	/* whether to use mode hysteresis for speedup */
-#define HTB_VER 0x30011		/* major must be matched with number suplied by TC as version */
+#define HTB_VER 0x30012		/* major must be matched with number suplied by TC as version */
 
 #if HTB_VER >> 16 != TC_HTB_PROTOVER
 #error "Mismatched sch_htb.c and pkt_sch.h"
@@ -73,7 +73,7 @@ struct htb_class {
 	u32 classid;
 	struct gnet_stats_basic bstats;
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est rate_est;
+	struct kernel_gnet_stats_rate_est k_rate_est;
 	struct tc_htb_xstats xstats;	/* our special stats */
 	int refcnt;		/* usage count of this class */
 
@@ -1104,7 +1104,7 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 	cl->xstats.ctokens = cl->ctokens;
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->k_rate_est.est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
@@ -1195,7 +1195,7 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 		BUG_TRAP(cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
 	}
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->k_rate_est);
 	qdisc_put_rtab(cl->rate);
 	qdisc_put_rtab(cl->ceil);
 
@@ -1348,7 +1348,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
 			goto failure;
 
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
+		gen_new_estimator(&cl->bstats, &cl->k_rate_est,
 				  &sch->dev->queue_lock,
 				  tca[TCA_RATE] ? : &est.nla);
 		cl->refcnt = 1;
@@ -1404,7 +1404,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			      parent ? &parent->children : &q->root);
 	} else {
 		if (tca[TCA_RATE])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
+			gen_replace_estimator(&cl->bstats, &cl->k_rate_est,
 					      &sch->dev->queue_lock,
 					      tca[TCA_RATE]);
 		sch_tree_lock(sch);
