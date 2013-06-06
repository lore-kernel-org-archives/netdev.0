From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net_sched: add 64bit rate estimators
Date: Thu, 06 Jun 2013 08:43:22 -0700
Message-ID: <1370533402.24311.353.camel@edumazet-glaptop>
References: <1370408447.24311.241.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33250 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033Ab3FFPnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 11:43:24 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so1814990pab.22
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 08:43:24 -0700 (PDT)
In-Reply-To: <1370408447.24311.241.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

struct gnet_stats_rate_est contains u32 fields, so the bytes per second
field can wrap at 34360Mbit.

Add a new gnet_stats_rate_est64 structure to get 64bit bps/pps fields,
and switch the kernel to use this structure natively.

This structure is dumped to user space as a new attribute :

TCA_STATS_RATE_EST64

Old tc command will now display the capped bps (to 34360Mbit), instead
of wrapped values, and updated tc command will display correct
information.

Old tc command output, after patch :

eric:~# tc -s -d qd sh dev lo
qdisc pfifo 8001: root refcnt 2 limit 1000p
 Sent 80868245400 bytes 1978837 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 34360Mbit 189696pps backlog 0b 0p requeues 0 

This patch carefully reorganizes "struct Qdisc" layout to get optimal
performance on SMP.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---
 include/net/act_api.h              |    2 +-
 include/net/gen_stats.h            |   10 +++++-----
 include/net/netfilter/xt_rateest.h |    2 +-
 include/net/sch_generic.h          |   13 +++++++------
 include/uapi/linux/gen_stats.h     |   11 +++++++++++
 net/core/gen_estimator.c           |   12 ++++++------
 net/core/gen_stats.c               |   22 +++++++++++++++++-----
 net/netfilter/xt_rateest.c         |    2 +-
 net/sched/sch_cbq.c                |    2 +-
 net/sched/sch_drr.c                |    2 +-
 net/sched/sch_hfsc.c               |    2 +-
 net/sched/sch_htb.c                |    2 +-
 net/sched/sch_qfq.c                |    2 +-
 13 files changed, 54 insertions(+), 30 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 06ef7e9..b8ffac7 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -18,7 +18,7 @@ struct tcf_common {
 	struct tcf_t			tcfc_tm;
 	struct gnet_stats_basic_packed	tcfc_bstats;
 	struct gnet_stats_queue		tcfc_qstats;
-	struct gnet_stats_rate_est	tcfc_rate_est;
+	struct gnet_stats_rate_est64	tcfc_rate_est;
 	spinlock_t			tcfc_lock;
 	struct rcu_head			tcfc_rcu;
 };
diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index a79b6cf..cf8439b 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -30,7 +30,7 @@ extern int gnet_stats_copy_basic(struct gnet_dump *d,
 				 struct gnet_stats_basic_packed *b);
 extern int gnet_stats_copy_rate_est(struct gnet_dump *d,
 				    const struct gnet_stats_basic_packed *b,
-				    struct gnet_stats_rate_est *r);
+				    struct gnet_stats_rate_est64 *r);
 extern int gnet_stats_copy_queue(struct gnet_dump *d,
 				 struct gnet_stats_queue *q);
 extern int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
@@ -38,13 +38,13 @@ extern int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
 extern int gnet_stats_finish_copy(struct gnet_dump *d);
 
 extern int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
-			     struct gnet_stats_rate_est *rate_est,
+			     struct gnet_stats_rate_est64 *rate_est,
 			     spinlock_t *stats_lock, struct nlattr *opt);
 extern void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
-			       struct gnet_stats_rate_est *rate_est);
+			       struct gnet_stats_rate_est64 *rate_est);
 extern int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
-				 struct gnet_stats_rate_est *rate_est,
+				 struct gnet_stats_rate_est64 *rate_est,
 				 spinlock_t *stats_lock, struct nlattr *opt);
 extern bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
-				 const struct gnet_stats_rate_est *rate_est);
+				 const struct gnet_stats_rate_est64 *rate_est);
 #endif
diff --git a/include/net/netfilter/xt_rateest.h b/include/net/netfilter/xt_rateest.h
index 5a2978d..495c71f 100644
--- a/include/net/netfilter/xt_rateest.h
+++ b/include/net/netfilter/xt_rateest.h
@@ -6,7 +6,7 @@ struct xt_rateest {
 	struct gnet_stats_basic_packed	bstats;
 	spinlock_t			lock;
 	/* keep rstats and lock on same cache line to speedup xt_rateest_mt() */
-	struct gnet_stats_rate_est	rstats;
+	struct gnet_stats_rate_est64	rstats;
 
 	/* following fields not accessed in hot path */
 	struct hlist_node		list;
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e7f4e21..df56760 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -58,14 +58,12 @@ struct Qdisc {
 				      * multiqueue device.
 				      */
 #define TCQ_F_WARN_NONWC	(1 << 16)
-	int			padded;
+	u32			limit;
 	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
 	struct list_head	list;
 	u32			handle;
 	u32			parent;
-	atomic_t		refcnt;
-	struct gnet_stats_rate_est	rate_est;
 	int			(*reshape_fail)(struct sk_buff *skb,
 					struct Qdisc *q);
 
@@ -76,8 +74,9 @@ struct Qdisc {
 	 */
 	struct Qdisc		*__parent;
 	struct netdev_queue	*dev_queue;
-	struct Qdisc		*next_sched;
 
+	struct gnet_stats_rate_est64	rate_est;
+	struct Qdisc		*next_sched;
 	struct sk_buff		*gso_skb;
 	/*
 	 * For performance sake on SMP, we put highly modified fields at the end
@@ -88,8 +87,10 @@ struct Qdisc {
 	unsigned int		__state;
 	struct gnet_stats_queue	qstats;
 	struct rcu_head		rcu_head;
-	spinlock_t		busylock;
-	u32			limit;
+	int			padded;
+	atomic_t		refcnt;
+
+	spinlock_t		busylock ____cacheline_aligned_in_smp;
 };
 
 static inline bool qdisc_is_running(const struct Qdisc *qdisc)
diff --git a/include/uapi/linux/gen_stats.h b/include/uapi/linux/gen_stats.h
index 552c8a0..6487317 100644
--- a/include/uapi/linux/gen_stats.h
+++ b/include/uapi/linux/gen_stats.h
@@ -9,6 +9,7 @@ enum {
 	TCA_STATS_RATE_EST,
 	TCA_STATS_QUEUE,
 	TCA_STATS_APP,
+	TCA_STATS_RATE_EST64,
 	__TCA_STATS_MAX,
 };
 #define TCA_STATS_MAX (__TCA_STATS_MAX - 1)
@@ -38,6 +39,16 @@ struct gnet_stats_rate_est {
 };
 
 /**
+ * struct gnet_stats_rate_est64 - rate estimator
+ * @bps: current byte rate
+ * @pps: current packet rate
+ */
+struct gnet_stats_rate_est64 {
+	__u64	bps;
+	__u64	pps;
+};
+
+/**
  * struct gnet_stats_queue - queuing statistics
  * @qlen: queue length
  * @backlog: backlog size of queue
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index d9d198a..6b5b6e7 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -82,7 +82,7 @@ struct gen_estimator
 {
 	struct list_head	list;
 	struct gnet_stats_basic_packed	*bstats;
-	struct gnet_stats_rate_est	*rate_est;
+	struct gnet_stats_rate_est64	*rate_est;
 	spinlock_t		*stats_lock;
 	int			ewma_log;
 	u64			last_bytes;
@@ -167,7 +167,7 @@ static void gen_add_node(struct gen_estimator *est)
 
 static
 struct gen_estimator *gen_find_node(const struct gnet_stats_basic_packed *bstats,
-				    const struct gnet_stats_rate_est *rate_est)
+				    const struct gnet_stats_rate_est64 *rate_est)
 {
 	struct rb_node *p = est_root.rb_node;
 
@@ -203,7 +203,7 @@ struct gen_estimator *gen_find_node(const struct gnet_stats_basic_packed *bstats
  *
  */
 int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
-		      struct gnet_stats_rate_est *rate_est,
+		      struct gnet_stats_rate_est64 *rate_est,
 		      spinlock_t *stats_lock,
 		      struct nlattr *opt)
 {
@@ -258,7 +258,7 @@ EXPORT_SYMBOL(gen_new_estimator);
  * Note : Caller should respect an RCU grace period before freeing stats_lock
  */
 void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
-			struct gnet_stats_rate_est *rate_est)
+			struct gnet_stats_rate_est64 *rate_est)
 {
 	struct gen_estimator *e;
 
@@ -290,7 +290,7 @@ EXPORT_SYMBOL(gen_kill_estimator);
  * Returns 0 on success or a negative error code.
  */
 int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
-			  struct gnet_stats_rate_est *rate_est,
+			  struct gnet_stats_rate_est64 *rate_est,
 			  spinlock_t *stats_lock, struct nlattr *opt)
 {
 	gen_kill_estimator(bstats, rate_est);
@@ -306,7 +306,7 @@ EXPORT_SYMBOL(gen_replace_estimator);
  * Returns true if estimator is active, and false if not.
  */
 bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
-			  const struct gnet_stats_rate_est *rate_est)
+			  const struct gnet_stats_rate_est64 *rate_est)
 {
 	bool res;
 
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index ddedf21..9d3d9e7 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -143,18 +143,30 @@ EXPORT_SYMBOL(gnet_stats_copy_basic);
 int
 gnet_stats_copy_rate_est(struct gnet_dump *d,
 			 const struct gnet_stats_basic_packed *b,
-			 struct gnet_stats_rate_est *r)
+			 struct gnet_stats_rate_est64 *r)
 {
+	struct gnet_stats_rate_est est;
+	int res;
+
 	if (b && !gen_estimator_active(b, r))
 		return 0;
 
+	est.bps = min_t(u64, UINT_MAX, r->bps);
+	/* we have some time before reaching 2^32 packets per second */
+	est.pps = r->pps;
+
 	if (d->compat_tc_stats) {
-		d->tc_stats.bps = r->bps;
-		d->tc_stats.pps = r->pps;
+		d->tc_stats.bps = est.bps;
+		d->tc_stats.pps = est.pps;
 	}
 
-	if (d->tail)
-		return gnet_stats_copy(d, TCA_STATS_RATE_EST, r, sizeof(*r));
+	if (d->tail) {
+		res = gnet_stats_copy(d, TCA_STATS_RATE_EST, &est, sizeof(est));
+		if (res < 0 || est.bps == r->bps)
+			return res;
+		/* emit 64bit stats only if needed */
+		return gnet_stats_copy(d, TCA_STATS_RATE_EST64, r, sizeof(*r));
+	}
 
 	return 0;
 }
diff --git a/net/netfilter/xt_rateest.c b/net/netfilter/xt_rateest.c
index ed0db15..7720b03 100644
--- a/net/netfilter/xt_rateest.c
+++ b/net/netfilter/xt_rateest.c
@@ -18,7 +18,7 @@ static bool
 xt_rateest_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_rateest_match_info *info = par->matchinfo;
-	struct gnet_stats_rate_est *r;
+	struct gnet_stats_rate_est64 *r;
 	u_int32_t bps1, bps2, pps1, pps2;
 	bool ret = true;
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 1bc210f..71a5688 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -130,7 +130,7 @@ struct cbq_class {
 	psched_time_t		penalized;
 	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est rate_est;
+	struct gnet_stats_rate_est64 rate_est;
 	struct tc_cbq_xstats	xstats;
 
 	struct tcf_proto	*filter_list;
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 759b308..8302717 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -25,7 +25,7 @@ struct drr_class {
 
 	struct gnet_stats_basic_packed		bstats;
 	struct gnet_stats_queue		qstats;
-	struct gnet_stats_rate_est	rate_est;
+	struct gnet_stats_rate_est64	rate_est;
 	struct list_head		alist;
 	struct Qdisc			*qdisc;
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 9facea0..c407561 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -114,7 +114,7 @@ struct hfsc_class {
 
 	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est rate_est;
+	struct gnet_stats_rate_est64 rate_est;
 	unsigned int	level;		/* class level in hierarchy */
 	struct tcf_proto *filter_list;	/* filter list */
 	unsigned int	filter_cnt;	/* filter count */
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index adaedd7..162fb80 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -78,7 +78,7 @@ struct htb_class {
 	/* general class parameters */
 	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est rate_est;
+	struct gnet_stats_rate_est64 rate_est;
 	struct tc_htb_xstats xstats;	/* our special stats */
 	int refcnt;		/* usage count of this class */
 
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index d51852b..7c195d9 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -138,7 +138,7 @@ struct qfq_class {
 
 	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est rate_est;
+	struct gnet_stats_rate_est64 rate_est;
 	struct Qdisc *qdisc;
 	struct list_head alist;		/* Link for active-classes list. */
 	struct qfq_aggregate *agg;	/* Parent aggregate. */
