From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 13/15] net: sched: make bstats per cpu and estimator RCU
 safe
Date: Wed, 30 Apr 2014 09:40:24 -0700
Message-ID: <20140430164023.9021.15326.stgit@nitbit.x32>
References: <20140430163250.9021.21199.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:32968 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422650AbaD3Qko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 12:40:44 -0400
Received: by mail-oa0-f43.google.com with SMTP id eb12so2258398oac.30
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 09:40:44 -0700 (PDT)
In-Reply-To: <20140430163250.9021.21199.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to run qdisc's without locking statistics and estimators
need to be handled correctly.

To resolve bstats make the statistics per cpu. And because this is
only needed for qdiscs that are running without locks which is not
the case for most qdiscs in the near future only create percpu
stats when qdiscs set the TCQ_F_LLQDISC flag.

Next because estimators use the bstats to calculate packets per
second and bytes per second the estimator code paths are updated
to use the per cpu statistics.

After this if qdiscs use the _percpu routines to update stats
and set the TCQ_F_LLQDISC they can be made safe to run without
locking. Any qdisc that sets the flag needs to ensure that the
data structures it owns are safe to run without locks and
additionally currently all the skb list routines run without
locking so those would need to be updated in a future patch.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/gen_stats.h    |   16 ++++++++++++
 include/net/sch_generic.h  |   40 +++++++++++++++++++++++++++--
 net/core/gen_estimator.c   |   60 ++++++++++++++++++++++++++++++++++----------
 net/core/gen_stats.c       |   46 +++++++++++++++++++++++++++++++++-
 net/netfilter/xt_RATEEST.c |    4 +--
 net/sched/act_api.c        |    9 ++++---
 net/sched/act_police.c     |    4 +--
 net/sched/sch_api.c        |   51 ++++++++++++++++++++++++++++++++-----
 net/sched/sch_cbq.c        |    9 ++++---
 net/sched/sch_drr.c        |    9 ++++---
 net/sched/sch_generic.c    |   12 ++++++++-
 net/sched/sch_hfsc.c       |   15 +++++++----
 net/sched/sch_htb.c        |   14 +++++++---
 net/sched/sch_ingress.c    |    2 +
 net/sched/sch_mq.c         |   10 ++++---
 net/sched/sch_mqprio.c     |   14 ++++++----
 net/sched/sch_multiq.c     |    2 +
 net/sched/sch_prio.c       |    2 +
 net/sched/sch_qfq.c        |   12 +++++----
 19 files changed, 259 insertions(+), 72 deletions(-)

diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index ea4271d..dec4312 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -6,6 +6,11 @@
 #include <linux/rtnetlink.h>
 #include <linux/pkt_sched.h>
 
+struct gnet_stats_basic_cpu {
+	struct gnet_stats_basic_packed bstats;
+	struct u64_stats_sync syncp;
+};
+
 struct gnet_dump {
 	spinlock_t *      lock;
 	struct sk_buff *  skb;
@@ -26,10 +31,17 @@ int gnet_stats_start_copy_compat(struct sk_buff *skb, int type,
 				 int tc_stats_type, int xstats_type,
 				 spinlock_t *lock, struct gnet_dump *d);
 
+int gnet_stats_copy_basic_cpu(struct gnet_dump *d,
+			      struct gnet_stats_basic_cpu *b);
+void __gnet_stats_copy_basic_cpu(struct gnet_stats_basic_packed *bstats,
+				 struct gnet_stats_basic_cpu *b);
 int gnet_stats_copy_basic(struct gnet_dump *d,
 			  struct gnet_stats_basic_packed *b);
+void __gnet_stats_copy_basic(struct gnet_stats_basic_packed *bstats,
+			     struct gnet_stats_basic_packed *b);
 int gnet_stats_copy_rate_est(struct gnet_dump *d,
 			     const struct gnet_stats_basic_packed *b,
+			     const struct gnet_stats_basic_cpu *cpu_b,
 			     struct gnet_stats_rate_est64 *r);
 int gnet_stats_copy_queue(struct gnet_dump *d, struct gnet_stats_queue *q);
 int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
@@ -37,13 +49,17 @@ int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
 int gnet_stats_finish_copy(struct gnet_dump *d);
 
 int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
+		      struct gnet_stats_basic_cpu *cpu_bstats,
 		      struct gnet_stats_rate_est64 *rate_est,
 		      spinlock_t *stats_lock, struct nlattr *opt);
 void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
+			struct gnet_stats_basic_cpu *cpu_bstats,
 			struct gnet_stats_rate_est64 *rate_est);
 int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
+			  struct gnet_stats_basic_cpu *cpu_bstats,
 			  struct gnet_stats_rate_est64 *rate_est,
 			  spinlock_t *stats_lock, struct nlattr *opt);
 bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
+			  const struct gnet_stats_basic_cpu *cpu_bstats,
 			  const struct gnet_stats_rate_est64 *rate_est);
 #endif
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 20553c7..1a55e19 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -6,6 +6,7 @@
 #include <linux/rcupdate.h>
 #include <linux/pkt_sched.h>
 #include <linux/pkt_cls.h>
+#include <linux/percpu.h>
 #include <net/gen_stats.h>
 #include <net/rtnetlink.h>
 
@@ -57,6 +58,9 @@ struct Qdisc {
 				      * Its true for MQ/MQPRIO slaves, or non
 				      * multiqueue device.
 				      */
+#define TCQ_F_LLQDISC		0x20 /* lockless qdiscs can run without using
+				      * the qdisc lock to serialize skbs.
+				      */
 #define TCQ_F_WARN_NONWC	(1 << 16)
 	u32			limit;
 	const struct Qdisc_ops	*ops;
@@ -83,7 +87,10 @@ struct Qdisc {
 	 */
 	unsigned long		state;
 	struct sk_buff_head	q;
-	struct gnet_stats_basic_packed bstats;
+	union {
+		struct gnet_stats_basic_packed bstats;
+		struct gnet_stats_basic_cpu __percpu *cpu_bstats;
+	} bstats_qdisc;
 	unsigned int		__state;
 	struct gnet_stats_queue	qstats;
 	struct rcu_head		rcu_head;
@@ -494,7 +501,6 @@ static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
 	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
 }
 
-
 static inline void bstats_update(struct gnet_stats_basic_packed *bstats,
 				 const struct sk_buff *skb)
 {
@@ -502,10 +508,38 @@ static inline void bstats_update(struct gnet_stats_basic_packed *bstats,
 	bstats->packets += skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 1;
 }
 
+static inline void qdisc_bstats_update_cpu(struct Qdisc *sch,
+					   const struct sk_buff *skb)
+{
+	struct gnet_stats_basic_cpu *bstats =
+				this_cpu_ptr(sch->bstats_qdisc.cpu_bstats);
+
+	u64_stats_update_begin(&bstats->syncp);
+	bstats_update(&bstats->bstats, skb);
+	u64_stats_update_end(&bstats->syncp);
+}
+
 static inline void qdisc_bstats_update(struct Qdisc *sch,
 				       const struct sk_buff *skb)
 {
-	bstats_update(&sch->bstats, skb);
+	bstats_update(&sch->bstats_qdisc.bstats, skb);
+}
+
+static inline bool qdisc_is_lockless(struct Qdisc *q)
+{
+	return q->flags & TCQ_F_LLQDISC;
+}
+
+static inline int
+qdisc_bstats_copy_qdisc(struct gnet_dump *d, struct Qdisc *q)
+{
+	int err;
+
+	if (qdisc_is_lockless(q))
+		err = gnet_stats_copy_basic_cpu(d, q->bstats_qdisc.cpu_bstats);
+	else
+		err = gnet_stats_copy_basic(d, &q->bstats_qdisc.bstats);
+	return err;
 }
 
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 6b5b6e7..4f963e7 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -91,6 +91,8 @@ struct gen_estimator
 	u32			avpps;
 	struct rcu_head		e_rcu;
 	struct rb_node		node;
+	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
+	struct rcu_head		head;
 };
 
 struct gen_estimator_head
@@ -122,11 +124,21 @@ static void est_timer(unsigned long arg)
 
 		spin_lock(e->stats_lock);
 		read_lock(&est_lock);
-		if (e->bstats == NULL)
+
+		if (e->bstats == NULL && e->cpu_bstats == NULL)
 			goto skip;
 
-		nbytes = e->bstats->bytes;
-		npackets = e->bstats->packets;
+		if (e->cpu_bstats) {
+			struct gnet_stats_basic_packed b = {0};
+
+			__gnet_stats_copy_basic_cpu(&b, e->cpu_bstats);
+			nbytes = b.bytes;
+			npackets = b.packets;
+		} else {
+			nbytes = e->bstats->bytes;
+			npackets = e->bstats->packets;
+		}
+
 		brate = (nbytes - e->last_bytes)<<(7 - idx);
 		e->last_bytes = nbytes;
 		e->avbps += (brate >> e->ewma_log) - (e->avbps >> e->ewma_log);
@@ -146,6 +158,11 @@ skip:
 	rcu_read_unlock();
 }
 
+static void *gen_get_bstats(struct gen_estimator *est)
+{
+	return est->cpu_bstats ? (void *)est->cpu_bstats : (void *)est->bstats;
+}
+
 static void gen_add_node(struct gen_estimator *est)
 {
 	struct rb_node **p = &est_root.rb_node, *parent = NULL;
@@ -156,7 +173,7 @@ static void gen_add_node(struct gen_estimator *est)
 		parent = *p;
 		e = rb_entry(parent, struct gen_estimator, node);
 
-		if (est->bstats > e->bstats)
+		if (gen_get_bstats(est)  > gen_get_bstats(e))
 			p = &parent->rb_right;
 		else
 			p = &parent->rb_left;
@@ -167,18 +184,20 @@ static void gen_add_node(struct gen_estimator *est)
 
 static
 struct gen_estimator *gen_find_node(const struct gnet_stats_basic_packed *bstats,
+				    const struct gnet_stats_basic_cpu *cpu_bstats,
 				    const struct gnet_stats_rate_est64 *rate_est)
 {
 	struct rb_node *p = est_root.rb_node;
+	void *b = bstats ? (void *)bstats : (void *)cpu_bstats;
 
 	while (p) {
 		struct gen_estimator *e;
 
 		e = rb_entry(p, struct gen_estimator, node);
 
-		if (bstats > e->bstats)
+		if (b > gen_get_bstats(e))
 			p = p->rb_right;
-		else if (bstats < e->bstats || rate_est != e->rate_est)
+		else if (b < gen_get_bstats(e) || rate_est != e->rate_est)
 			p = p->rb_left;
 		else
 			return e;
@@ -203,6 +222,7 @@ struct gen_estimator *gen_find_node(const struct gnet_stats_basic_packed *bstats
  *
  */
 int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
+		      struct gnet_stats_basic_cpu *cpu_bstats,
 		      struct gnet_stats_rate_est64 *rate_est,
 		      spinlock_t *stats_lock,
 		      struct nlattr *opt)
@@ -221,14 +241,24 @@ int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 	if (est == NULL)
 		return -ENOBUFS;
 
+	if (cpu_bstats) {
+		struct gnet_stats_basic_packed b = {0};
+
+		est->cpu_bstats = cpu_bstats;
+		__gnet_stats_copy_basic_cpu(&b, cpu_bstats);
+		est->last_bytes = b.bytes;
+		est->last_packets = b.packets;
+	} else {
+		est->bstats = bstats;
+		est->last_bytes = bstats->bytes;
+		est->last_packets = bstats->packets;
+	}
+
 	idx = parm->interval + 2;
-	est->bstats = bstats;
 	est->rate_est = rate_est;
 	est->stats_lock = stats_lock;
 	est->ewma_log = parm->ewma_log;
-	est->last_bytes = bstats->bytes;
 	est->avbps = rate_est->bps<<5;
-	est->last_packets = bstats->packets;
 	est->avpps = rate_est->pps<<10;
 
 	spin_lock_bh(&est_tree_lock);
@@ -258,14 +288,14 @@ EXPORT_SYMBOL(gen_new_estimator);
  * Note : Caller should respect an RCU grace period before freeing stats_lock
  */
 void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
+			struct gnet_stats_basic_cpu *cpu_bstats,
 			struct gnet_stats_rate_est64 *rate_est)
 {
 	struct gen_estimator *e;
 
 	spin_lock_bh(&est_tree_lock);
-	while ((e = gen_find_node(bstats, rate_est))) {
+	while ((e = gen_find_node(bstats, cpu_bstats, rate_est))) {
 		rb_erase(&e->node, &est_root);
-
 		write_lock(&est_lock);
 		e->bstats = NULL;
 		write_unlock(&est_lock);
@@ -290,11 +320,12 @@ EXPORT_SYMBOL(gen_kill_estimator);
  * Returns 0 on success or a negative error code.
  */
 int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
+			  struct gnet_stats_basic_cpu *cpu_bstats,
 			  struct gnet_stats_rate_est64 *rate_est,
 			  spinlock_t *stats_lock, struct nlattr *opt)
 {
-	gen_kill_estimator(bstats, rate_est);
-	return gen_new_estimator(bstats, rate_est, stats_lock, opt);
+	gen_kill_estimator(bstats, cpu_bstats, rate_est);
+	return gen_new_estimator(bstats, cpu_bstats, rate_est, stats_lock, opt);
 }
 EXPORT_SYMBOL(gen_replace_estimator);
 
@@ -306,6 +337,7 @@ EXPORT_SYMBOL(gen_replace_estimator);
  * Returns true if estimator is active, and false if not.
  */
 bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
+			  const struct gnet_stats_basic_cpu *cpu_bstats,
 			  const struct gnet_stats_rate_est64 *rate_est)
 {
 	bool res;
@@ -313,7 +345,7 @@ bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
 	ASSERT_RTNL();
 
 	spin_lock_bh(&est_tree_lock);
-	res = gen_find_node(bstats, rate_est) != NULL;
+	res = gen_find_node(bstats, cpu_bstats, rate_est) != NULL;
 	spin_unlock_bh(&est_tree_lock);
 
 	return res;
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 9d3d9e7..b51146a 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -128,6 +128,49 @@ gnet_stats_copy_basic(struct gnet_dump *d, struct gnet_stats_basic_packed *b)
 }
 EXPORT_SYMBOL(gnet_stats_copy_basic);
 
+void
+__gnet_stats_copy_basic(struct gnet_stats_basic_packed *bstats,
+			struct gnet_stats_basic_packed *b)
+{
+	bstats->bytes = b->bytes;
+	bstats->packets = b->packets;
+}
+EXPORT_SYMBOL(__gnet_stats_copy_basic);
+
+void
+__gnet_stats_copy_basic_cpu(struct gnet_stats_basic_packed *bstats,
+			    struct gnet_stats_basic_cpu *b)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct gnet_stats_basic_cpu *bcpu = per_cpu_ptr(b, i);
+		unsigned int start;
+		__u64 bytes;
+		__u32 packets;
+
+		do {
+			start = u64_stats_fetch_begin_irq(&bcpu->syncp);
+			bytes = bcpu->bstats.bytes;
+			packets = bcpu->bstats.packets;
+		} while (u64_stats_fetch_retry_irq(&bcpu->syncp, start));
+
+		bstats->bytes += bcpu->bstats.bytes;
+		bstats->packets += bcpu->bstats.packets;
+	}
+}
+EXPORT_SYMBOL(__gnet_stats_copy_basic_cpu);
+
+int
+gnet_stats_copy_basic_cpu(struct gnet_dump *d, struct gnet_stats_basic_cpu *b)
+{
+	struct gnet_stats_basic_packed bstats = {0};
+
+	__gnet_stats_copy_basic_cpu(&bstats, b);
+	return gnet_stats_copy_basic(d, &bstats);
+}
+EXPORT_SYMBOL(gnet_stats_copy_basic_cpu);
+
 /**
  * gnet_stats_copy_rate_est - copy rate estimator statistics into statistics TLV
  * @d: dumping handle
@@ -143,12 +186,13 @@ EXPORT_SYMBOL(gnet_stats_copy_basic);
 int
 gnet_stats_copy_rate_est(struct gnet_dump *d,
 			 const struct gnet_stats_basic_packed *b,
+			 const struct gnet_stats_basic_cpu *cpu_b,
 			 struct gnet_stats_rate_est64 *r)
 {
 	struct gnet_stats_rate_est est;
 	int res;
 
-	if (b && !gen_estimator_active(b, r))
+	if ((b || cpu_b) && !gen_estimator_active(b, cpu_b, r))
 		return 0;
 
 	est.bps = min_t(u64, UINT_MAX, r->bps);
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 370adf6..02e2532 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -64,7 +64,7 @@ void xt_rateest_put(struct xt_rateest *est)
 	mutex_lock(&xt_rateest_mutex);
 	if (--est->refcnt == 0) {
 		hlist_del(&est->list);
-		gen_kill_estimator(&est->bstats, &est->rstats);
+		gen_kill_estimator(&est->bstats, NULL, &est->rstats);
 		/*
 		 * gen_estimator est_timer() might access est->lock or bstats,
 		 * wait a RCU grace period before freeing 'est'
@@ -136,7 +136,7 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 	cfg.est.interval	= info->interval;
 	cfg.est.ewma_log	= info->ewma_log;
 
-	ret = gen_new_estimator(&est->bstats, &est->rstats,
+	ret = gen_new_estimator(&est->bstats, NULL, &est->rstats,
 				&est->lock, &cfg.opt);
 	if (ret < 0)
 		goto err2;
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index d73a546..0be3945 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -35,7 +35,7 @@ void tcf_hash_destroy(struct tc_action *a)
 	spin_lock_bh(&hinfo->lock);
 	hlist_del(&p->tcfc_head);
 	spin_unlock_bh(&hinfo->lock);
-	gen_kill_estimator(&p->tcfc_bstats,
+	gen_kill_estimator(&p->tcfc_bstats, NULL,
 			   &p->tcfc_rate_est);
 	/*
 	 * gen_estimator est_timer() might access p->tcfc_lock
@@ -228,7 +228,7 @@ void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est)
 {
 	struct tcf_common *pc = a->priv;
 	if (est)
-		gen_kill_estimator(&pc->tcfc_bstats,
+		gen_kill_estimator(&pc->tcfc_bstats, NULL,
 				   &pc->tcfc_rate_est);
 	kfree_rcu(pc, tcfc_rcu);
 }
@@ -252,7 +252,8 @@ int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
 	p->tcfc_tm.install = jiffies;
 	p->tcfc_tm.lastuse = jiffies;
 	if (est) {
-		int err = gen_new_estimator(&p->tcfc_bstats, &p->tcfc_rate_est,
+		int err = gen_new_estimator(&p->tcfc_bstats, NULL,
+					    &p->tcfc_rate_est,
 					    &p->tcfc_lock, est);
 		if (err) {
 			kfree(p);
@@ -620,7 +621,7 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 		goto errout;
 
 	if (gnet_stats_copy_basic(&d, &p->tcfc_bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &p->tcfc_bstats,
+	    gnet_stats_copy_rate_est(&d, &p->tcfc_bstats, NULL,
 				     &p->tcfc_rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, &p->tcfc_qstats) < 0)
 		goto errout;
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 0566e46..18e6c83 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -178,14 +178,14 @@ override:
 
 	spin_lock_bh(&police->tcf_lock);
 	if (est) {
-		err = gen_replace_estimator(&police->tcf_bstats,
+		err = gen_replace_estimator(&police->tcf_bstats, NULL,
 					    &police->tcf_rate_est,
 					    &police->tcf_lock, est);
 		if (err)
 			goto failure_unlock;
 	} else if (tb[TCA_POLICE_AVRATE] &&
 		   (ret == ACT_P_CREATED ||
-		    !gen_estimator_active(&police->tcf_bstats,
+		    !gen_estimator_active(&police->tcf_bstats, NULL,
 					  &police->tcf_rate_est))) {
 		err = -EINVAL;
 		goto failure_unlock;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 30cc267..bf14313 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -942,6 +942,13 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 	sch->handle = handle;
 
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS])) == 0) {
+		if (qdisc_is_lockless(sch)) {
+			sch->bstats_qdisc.cpu_bstats =
+				alloc_percpu(struct gnet_stats_basic_cpu);
+			if (!sch->bstats_qdisc.cpu_bstats)
+				goto err_out4;
+		}
+
 		if (tca[TCA_STAB]) {
 			stab = qdisc_get_stab(tca[TCA_STAB]);
 			if (IS_ERR(stab)) {
@@ -964,8 +971,18 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			else
 				root_lock = qdisc_lock(sch);
 
-			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
-						root_lock, tca[TCA_RATE]);
+			if (qdisc_is_lockless(sch))
+				err = gen_new_estimator(NULL,
+							sch->bstats_qdisc.cpu_bstats,
+							&sch->rate_est,
+							root_lock,
+							tca[TCA_RATE]);
+			else
+				err = gen_new_estimator(&sch->bstats_qdisc.bstats,
+							NULL,
+							&sch->rate_est,
+							root_lock,
+							tca[TCA_RATE]);
 			if (err)
 				goto err_out4;
 		}
@@ -1022,9 +1039,11 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 		   because change can't be undone. */
 		if (sch->flags & TCQ_F_MQROOT)
 			goto out;
-		gen_replace_estimator(&sch->bstats, &sch->rate_est,
-					    qdisc_root_sleeping_lock(sch),
-					    tca[TCA_RATE]);
+		gen_replace_estimator(&sch->bstats_qdisc.bstats,
+				      sch->bstats_qdisc.cpu_bstats,
+				      &sch->rate_est,
+				      qdisc_root_sleeping_lock(sch),
+				      tca[TCA_RATE]);
 	}
 out:
 	return 0;
@@ -1303,6 +1322,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	unsigned char *b = skb_tail_pointer(skb);
 	struct gnet_dump d;
 	struct qdisc_size_table *stab;
+	int err;
 
 	cond_resched();
 	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
@@ -1333,10 +1353,25 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
 		goto nla_put_failure;
 
-	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(&d, &q->bstats, &q->rate_est) < 0 ||
+	if (qdisc_is_lockless(q)) {
+		err = gnet_stats_copy_basic_cpu(&d, q->bstats_qdisc.cpu_bstats);
+		if (err < 0)
+			goto nla_put_failure;
+		err = gnet_stats_copy_rate_est(&d, NULL,
+					       q->bstats_qdisc.cpu_bstats,
+					       &q->rate_est);
+	} else {
+		err = gnet_stats_copy_basic(&d, &q->bstats_qdisc.bstats);
+		if (err < 0)
+			goto nla_put_failure;
+		err = gnet_stats_copy_rate_est(&d,
+					       &q->bstats_qdisc.bstats, NULL,
+					       &q->rate_est);
+	}
+
+	if (err < 0 ||
 	    gnet_stats_copy_queue(&d, &q->qstats) < 0)
-		goto nla_put_failure;
+			goto nla_put_failure;
 
 	if (gnet_stats_finish_copy(&d) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index d0a6e60..9ecab38 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1623,7 +1623,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 		cl->xstats.undertime = cl->undertime - q->now;
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->bstats, NULL, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
@@ -1695,7 +1695,7 @@ static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->bstats, NULL, &cl->rate_est);
 	if (cl != &q->link)
 		kfree(cl);
 }
@@ -1786,7 +1786,8 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 		}
 
 		if (tca[TCA_RATE]) {
-			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+			err = gen_replace_estimator(&cl->bstats, NULL,
+						    &cl->rate_est,
 						    qdisc_root_sleeping_lock(sch),
 						    tca[TCA_RATE]);
 			if (err) {
@@ -1879,7 +1880,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 		goto failure;
 
 	if (tca[TCA_RATE]) {
-		err = gen_new_estimator(&cl->bstats, &cl->rate_est,
+		err = gen_new_estimator(&cl->bstats, NULL, &cl->rate_est,
 					qdisc_root_sleeping_lock(sch),
 					tca[TCA_RATE]);
 		if (err) {
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 899026f..b58971a 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -88,7 +88,8 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (cl != NULL) {
 		if (tca[TCA_RATE]) {
-			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+			err = gen_replace_estimator(&cl->bstats, NULL,
+						    &cl->rate_est,
 						    qdisc_root_sleeping_lock(sch),
 						    tca[TCA_RATE]);
 			if (err)
@@ -116,7 +117,7 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		cl->qdisc = &noop_qdisc;
 
 	if (tca[TCA_RATE]) {
-		err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+		err = gen_replace_estimator(&cl->bstats, NULL, &cl->rate_est,
 					    qdisc_root_sleeping_lock(sch),
 					    tca[TCA_RATE]);
 		if (err) {
@@ -138,7 +139,7 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 static void drr_destroy_class(struct Qdisc *sch, struct drr_class *cl)
 {
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->bstats, NULL, &cl->rate_est);
 	qdisc_destroy(cl->qdisc);
 	kfree(cl);
 }
@@ -282,7 +283,7 @@ static int drr_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	}
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->bstats, NULL, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qdisc->qstats) < 0)
 		return -1;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index cd34a49..27033d0 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -627,6 +627,9 @@ static void qdisc_rcu_free(struct rcu_head *head)
 {
 	struct Qdisc *qdisc = container_of(head, struct Qdisc, rcu_head);
 
+	if (qdisc_is_lockless(qdisc))
+		free_percpu(qdisc->bstats_qdisc.cpu_bstats);
+
 	kfree((char *) qdisc - qdisc->padded);
 }
 
@@ -643,7 +646,13 @@ void qdisc_destroy(struct Qdisc *qdisc)
 
 	qdisc_put_stab(rtnl_dereference(qdisc->stab));
 #endif
-	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
+	if (qdisc_is_lockless(qdisc))
+		gen_kill_estimator(NULL, qdisc->bstats_qdisc.cpu_bstats,
+				   &qdisc->rate_est);
+	else
+		gen_kill_estimator(&qdisc->bstats_qdisc.bstats, NULL,
+				   &qdisc->rate_est);
+
 	if (ops->reset)
 		ops->reset(qdisc);
 	if (ops->destroy)
@@ -653,6 +662,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	dev_put(qdisc_dev(qdisc));
 
 	kfree_skb(qdisc->gso_skb);
+
 	/*
 	 * gen_estimator est_timer() might access qdisc->q.lock,
 	 * wait a RCU grace period before freeing qdisc.
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 95689d3..d8f928c 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1014,9 +1014,12 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		cur_time = psched_get_time();
 
 		if (tca[TCA_RATE]) {
-			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      qdisc_root_sleeping_lock(sch),
-					      tca[TCA_RATE]);
+			spinlock_t *lock = qdisc_root_sleeping_lock(sch);
+
+			err = gen_replace_estimator(&cl->bstats, NULL,
+						    &cl->rate_est,
+						    lock,
+						    tca[TCA_RATE]);
 			if (err)
 				return err;
 		}
@@ -1063,7 +1066,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		return -ENOBUFS;
 
 	if (tca[TCA_RATE]) {
-		err = gen_new_estimator(&cl->bstats, &cl->rate_est,
+		err = gen_new_estimator(&cl->bstats, NULL, &cl->rate_est,
 					qdisc_root_sleeping_lock(sch),
 					tca[TCA_RATE]);
 		if (err) {
@@ -1115,7 +1118,7 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 	fl = rtnl_dereference(cl->filter_list);
 	tcf_destroy_chain(&fl);
 	qdisc_destroy(cl->qdisc);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->bstats, NULL, &cl->rate_est);
 	if (cl != &q->root)
 		kfree(cl);
 }
@@ -1377,7 +1380,7 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	xstats.rtwork  = cl->cl_cumul;
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->bstats, NULL, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2c2a6aa..2bbed9c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1145,7 +1145,7 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 	cl->xstats.ctokens = PSCHED_NS2TICKS(cl->ctokens);
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, NULL, NULL, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
 
@@ -1237,7 +1237,7 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 		WARN_ON(!cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
 	}
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->bstats, NULL, &cl->rate_est);
 	fl = rtnl_dereference(cl->filter_list);
 	tcf_destroy_chain(&fl);
 	kfree(cl);
@@ -1409,7 +1409,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			goto failure;
 
 		if (htb_rate_est || tca[TCA_RATE]) {
-			err = gen_new_estimator(&cl->bstats, &cl->rate_est,
+			err = gen_new_estimator(&cl->bstats, NULL,
+						&cl->rate_est,
 						qdisc_root_sleeping_lock(sch),
 						tca[TCA_RATE] ? : &est.nla);
 			if (err) {
@@ -1471,8 +1472,11 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			parent->children++;
 	} else {
 		if (tca[TCA_RATE]) {
-			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
-						    qdisc_root_sleeping_lock(sch),
+			spinlock_t *lock = qdisc_root_sleeping_lock(sch);
+
+			err = gen_replace_estimator(&cl->bstats, NULL,
+						    &cl->rate_est,
+						    lock,
 						    tca[TCA_RATE]);
 			if (err)
 				return err;
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index be10333d..5700c27 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -64,7 +64,7 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	result = tc_classify(skb, fl, &res);
 
-	qdisc_bstats_update(sch, skb);
+	qdisc_bstats_update_cpu(sch, skb);
 	switch (result) {
 	case TC_ACT_SHOT:
 		result = TC_ACT_SHOT;
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index a8b2864..e96a41f 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -98,20 +98,22 @@ static void mq_attach(struct Qdisc *sch)
 
 static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
+	struct gnet_stats_basic_packed *bstats = &sch->bstats_qdisc.bstats;
 	struct net_device *dev = qdisc_dev(sch);
 	struct Qdisc *qdisc;
 	unsigned int ntx;
 
 	sch->q.qlen = 0;
-	memset(&sch->bstats, 0, sizeof(sch->bstats));
+	memset(bstats, 0, sizeof(sch->bstats_qdisc));
 	memset(&sch->qstats, 0, sizeof(sch->qstats));
 
 	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
 		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
 		spin_lock_bh(qdisc_lock(qdisc));
 		sch->q.qlen		+= qdisc->q.qlen;
-		sch->bstats.bytes	+= qdisc->bstats.bytes;
-		sch->bstats.packets	+= qdisc->bstats.packets;
+
+		bstats->bytes		+= qdisc->bstats_qdisc.bstats.bytes;
+		bstats->packets		+= qdisc->bstats_qdisc.bstats.packets;
 		sch->qstats.qlen	+= qdisc->qstats.qlen;
 		sch->qstats.backlog	+= qdisc->qstats.backlog;
 		sch->qstats.drops	+= qdisc->qstats.drops;
@@ -201,7 +203,7 @@ static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	sch = dev_queue->qdisc_sleeping;
 	sch->qstats.qlen = sch->q.qlen;
-	if (gnet_stats_copy_basic(d, &sch->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, &sch->bstats_qdisc.bstats) < 0 ||
 	    gnet_stats_copy_queue(d, &sch->qstats) < 0)
 		return -1;
 	return 0;
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 37e7d25..10f5d4a 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -219,6 +219,7 @@ static int mqprio_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
 
 static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
+	struct gnet_stats_basic_packed *bstats = &sch->bstats_qdisc.bstats;
 	struct net_device *dev = qdisc_dev(sch);
 	struct mqprio_sched *priv = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
@@ -227,15 +228,16 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	unsigned int i;
 
 	sch->q.qlen = 0;
-	memset(&sch->bstats, 0, sizeof(sch->bstats));
+	memset(bstats, 0, sizeof(sch->bstats_qdisc.bstats));
 	memset(&sch->qstats, 0, sizeof(sch->qstats));
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
+
 		qdisc = rtnl_dereference(netdev_get_tx_queue(dev, i)->qdisc);
 		spin_lock_bh(qdisc_lock(qdisc));
 		sch->q.qlen		+= qdisc->q.qlen;
-		sch->bstats.bytes	+= qdisc->bstats.bytes;
-		sch->bstats.packets	+= qdisc->bstats.packets;
+		bstats->bytes		+= qdisc->bstats_qdisc.bstats.bytes;
+		bstats->packets		+= qdisc->bstats_qdisc.bstats.packets;
 		sch->qstats.qlen	+= qdisc->qstats.qlen;
 		sch->qstats.backlog	+= qdisc->qstats.backlog;
 		sch->qstats.drops	+= qdisc->qstats.drops;
@@ -344,8 +346,8 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 			qdisc = rtnl_dereference(q->qdisc);
 			spin_lock_bh(qdisc_lock(qdisc));
-			bstats.bytes      += qdisc->bstats.bytes;
-			bstats.packets    += qdisc->bstats.packets;
+			bstats.bytes      += qdisc->bstats_qdisc.bstats.bytes;
+			bstats.packets    += qdisc->bstats_qdisc.bstats.packets;
 			qstats.qlen       += qdisc->qstats.qlen;
 			qstats.backlog    += qdisc->qstats.backlog;
 			qstats.drops      += qdisc->qstats.drops;
@@ -363,7 +365,7 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 		sch = dev_queue->qdisc_sleeping;
 		sch->qstats.qlen = sch->q.qlen;
-		if (gnet_stats_copy_basic(d, &sch->bstats) < 0 ||
+		if (gnet_stats_copy_basic(d, &sch->bstats_qdisc.bstats) < 0 ||
 		    gnet_stats_copy_queue(d, &sch->qstats) < 0)
 			return -1;
 	}
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 169d637..73e8b2b 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -362,7 +362,7 @@ static int multiq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	cl_q = q->queues[cl - 1];
 	cl_q->qstats.qlen = cl_q->q.qlen;
-	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, &cl_q->bstats_qdisc.bstats) < 0 ||
 	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
 		return -1;
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 43aa35d..1ae5d5b 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -326,7 +326,7 @@ static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	cl_q = q->queues[cl - 1];
 	cl_q->qstats.qlen = cl_q->q.qlen;
-	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, &cl_q->bstats_qdisc.bstats) < 0 ||
 	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
 		return -1;
 
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index cee5618..1cc4978 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -459,7 +459,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (cl != NULL) { /* modify existing class */
 		if (tca[TCA_RATE]) {
-			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+			err = gen_replace_estimator(&cl->bstats, NULL,
+						    &cl->rate_est,
 						    qdisc_root_sleeping_lock(sch),
 						    tca[TCA_RATE]);
 			if (err)
@@ -484,7 +485,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		cl->qdisc = &noop_qdisc;
 
 	if (tca[TCA_RATE]) {
-		err = gen_new_estimator(&cl->bstats, &cl->rate_est,
+		err = gen_new_estimator(&cl->bstats, NULL,
+					&cl->rate_est,
 					qdisc_root_sleeping_lock(sch),
 					tca[TCA_RATE]);
 		if (err)
@@ -505,7 +507,7 @@ set_change_agg:
 		new_agg = kzalloc(sizeof(*new_agg), GFP_KERNEL);
 		if (new_agg == NULL) {
 			err = -ENOBUFS;
-			gen_kill_estimator(&cl->bstats, &cl->rate_est);
+			gen_kill_estimator(&cl->bstats, NULL, &cl->rate_est);
 			goto destroy_class;
 		}
 		sch_tree_lock(sch);
@@ -530,7 +532,7 @@ static void qfq_destroy_class(struct Qdisc *sch, struct qfq_class *cl)
 	struct qfq_sched *q = qdisc_priv(sch);
 
 	qfq_rm_from_agg(q, cl);
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	gen_kill_estimator(&cl->bstats, NULL, &cl->rate_est);
 	qdisc_destroy(cl->qdisc);
 	kfree(cl);
 }
@@ -667,7 +669,7 @@ static int qfq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	xstats.lmax = cl->agg->lmax;
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
-	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->bstats, NULL, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qdisc->qstats) < 0)
 		return -1;
 
