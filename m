From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 1/4] net: sched: make bstats per cpu and estimator
 RCU safe
Date: Fri, 26 Sep 2014 11:13:48 -0700
Message-ID: <20140926181346.28430.19380.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34423 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754703AbaIZSOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 14:14:35 -0400
Received: by mail-oi0-f43.google.com with SMTP id v63so9156312oia.30
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 11:14:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>

In order to run qdisc's without locking statistics and estimators
need to be handled correctly.

To resolve bstats make the statistics per cpu. And because this is
only needed for qdiscs that are running without locks which is not
the case for most qdiscs in the near future only create percpu
stats when qdiscs set the TCQ_F_CPUSTATS flag.

Next because estimators use the bstats to calculate packets per
second and bytes per second the estimator code paths are updated
to use the per cpu statistics.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/gen_stats.h    |   11 +++++++++
 include/net/sch_generic.h  |   22 +++++++++++++++++-
 net/core/gen_estimator.c   |   29 +++++++++++++++---------
 net/core/gen_stats.c       |   53 ++++++++++++++++++++++++++++++++++++++++----
 net/netfilter/xt_RATEEST.c |    2 +-
 net/sched/act_api.c        |    5 ++--
 net/sched/act_police.c     |    2 +-
 net/sched/sch_api.c        |   29 +++++++++++++++++++-----
 net/sched/sch_atm.c        |    2 +-
 net/sched/sch_cbq.c        |    7 +++---
 net/sched/sch_drr.c        |    7 +++---
 net/sched/sch_generic.c    |    3 ++
 net/sched/sch_hfsc.c       |   13 +++++++----
 net/sched/sch_htb.c        |   12 +++++++---
 net/sched/sch_mq.c         |    6 ++---
 net/sched/sch_mqprio.c     |    8 +++----
 net/sched/sch_multiq.c     |    2 +-
 net/sched/sch_prio.c       |    2 +-
 net/sched/sch_qfq.c        |    8 ++++---
 19 files changed, 168 insertions(+), 55 deletions(-)

diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index ea4271d..ce3c128 100644
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
@@ -27,7 +32,11 @@ int gnet_stats_start_copy_compat(struct sk_buff *skb, int type,
 				 spinlock_t *lock, struct gnet_dump *d);
 
 int gnet_stats_copy_basic(struct gnet_dump *d,
+			  struct gnet_stats_basic_cpu __percpu *cpu,
 			  struct gnet_stats_basic_packed *b);
+void __gnet_stats_copy_basic(struct gnet_stats_basic_packed *bstats,
+			     struct gnet_stats_basic_cpu __percpu *cpu,
+			     struct gnet_stats_basic_packed *b);
 int gnet_stats_copy_rate_est(struct gnet_dump *d,
 			     const struct gnet_stats_basic_packed *b,
 			     struct gnet_stats_rate_est64 *r);
@@ -37,11 +46,13 @@ int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
 int gnet_stats_finish_copy(struct gnet_dump *d);
 
 int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
+		      struct gnet_stats_basic_cpu __percpu *cpu_bstats,
 		      struct gnet_stats_rate_est64 *rate_est,
 		      spinlock_t *stats_lock, struct nlattr *opt);
 void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
 			struct gnet_stats_rate_est64 *rate_est);
 int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
+			  struct gnet_stats_basic_cpu __percpu *cpu_bstats,
 			  struct gnet_stats_rate_est64 *rate_est,
 			  spinlock_t *stats_lock, struct nlattr *opt);
 bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e65b8e0..4b93511 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -6,6 +6,7 @@
 #include <linux/rcupdate.h>
 #include <linux/pkt_sched.h>
 #include <linux/pkt_cls.h>
+#include <linux/percpu.h>
 #include <net/gen_stats.h>
 #include <net/rtnetlink.h>
 
@@ -58,6 +59,7 @@ struct Qdisc {
 				      * multiqueue device.
 				      */
 #define TCQ_F_WARN_NONWC	(1 << 16)
+#define TCQ_F_CPUSTATS		0x20 /* run using percpu statistics */
 	u32			limit;
 	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
@@ -83,7 +85,10 @@ struct Qdisc {
 	 */
 	unsigned long		state;
 	struct sk_buff_head	q;
-	struct gnet_stats_basic_packed bstats;
+	union {
+		struct gnet_stats_basic_packed bstats;
+		struct gnet_stats_basic_cpu __percpu *cpu_bstats;
+	} __packed;
 	unsigned int		__state;
 	struct gnet_stats_queue	qstats;
 	struct rcu_head		rcu_head;
@@ -487,6 +492,10 @@ static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
 	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
 }
 
+static inline bool qdisc_is_percpu_stats(const struct Qdisc *q)
+{
+	return q->flags & TCQ_F_CPUSTATS;
+}
 
 static inline void bstats_update(struct gnet_stats_basic_packed *bstats,
 				 const struct sk_buff *skb)
@@ -495,6 +504,17 @@ static inline void bstats_update(struct gnet_stats_basic_packed *bstats,
 	bstats->packets += skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 1;
 }
 
+static inline void qdisc_bstats_update_cpu(struct Qdisc *sch,
+					   const struct sk_buff *skb)
+{
+	struct gnet_stats_basic_cpu *bstats =
+				this_cpu_ptr(sch->cpu_bstats);
+
+	u64_stats_update_begin(&bstats->syncp);
+	bstats_update(&bstats->bstats, skb);
+	u64_stats_update_end(&bstats->syncp);
+}
+
 static inline void qdisc_bstats_update(struct Qdisc *sch,
 				       const struct sk_buff *skb)
 {
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 9d33dff..9dfb88a 100644
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
@@ -115,9 +117,8 @@ static void est_timer(unsigned long arg)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(e, &elist[idx].list, list) {
-		u64 nbytes;
+		struct gnet_stats_basic_packed b = {0};
 		u64 brate;
-		u32 npackets;
 		u32 rate;
 
 		spin_lock(e->stats_lock);
@@ -125,15 +126,15 @@ static void est_timer(unsigned long arg)
 		if (e->bstats == NULL)
 			goto skip;
 
-		nbytes = e->bstats->bytes;
-		npackets = e->bstats->packets;
-		brate = (nbytes - e->last_bytes)<<(7 - idx);
-		e->last_bytes = nbytes;
+		__gnet_stats_copy_basic(&b, e->cpu_bstats, e->bstats);
+
+		brate = (b.bytes - e->last_bytes)<<(7 - idx);
+		e->last_bytes = b.bytes;
 		e->avbps += (brate >> e->ewma_log) - (e->avbps >> e->ewma_log);
 		e->rate_est->bps = (e->avbps+0xF)>>5;
 
-		rate = (npackets - e->last_packets)<<(12 - idx);
-		e->last_packets = npackets;
+		rate = (b.packets - e->last_packets)<<(12 - idx);
+		e->last_packets = b.packets;
 		e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
 		e->rate_est->pps = (e->avpps+0x1FF)>>10;
 skip:
@@ -203,12 +204,14 @@ struct gen_estimator *gen_find_node(const struct gnet_stats_basic_packed *bstats
  *
  */
 int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
+		      struct gnet_stats_basic_cpu __percpu *cpu_bstats,
 		      struct gnet_stats_rate_est64 *rate_est,
 		      spinlock_t *stats_lock,
 		      struct nlattr *opt)
 {
 	struct gen_estimator *est;
 	struct gnet_estimator *parm = nla_data(opt);
+	struct gnet_stats_basic_packed b = {0};
 	int idx;
 
 	if (nla_len(opt) < sizeof(*parm))
@@ -221,15 +224,18 @@ int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 	if (est == NULL)
 		return -ENOBUFS;
 
+	__gnet_stats_copy_basic(&b, cpu_bstats, bstats);
+
 	idx = parm->interval + 2;
 	est->bstats = bstats;
 	est->rate_est = rate_est;
 	est->stats_lock = stats_lock;
 	est->ewma_log = parm->ewma_log;
-	est->last_bytes = bstats->bytes;
+	est->last_bytes = b.bytes;
 	est->avbps = rate_est->bps<<5;
-	est->last_packets = bstats->packets;
+	est->last_packets = b.packets;
 	est->avpps = rate_est->pps<<10;
+	est->cpu_bstats = cpu_bstats;
 
 	spin_lock_bh(&est_tree_lock);
 	if (!elist[idx].timer.function) {
@@ -290,11 +296,12 @@ EXPORT_SYMBOL(gen_kill_estimator);
  * Returns 0 on success or a negative error code.
  */
 int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
+			  struct gnet_stats_basic_cpu __percpu *cpu_bstats,
 			  struct gnet_stats_rate_est64 *rate_est,
 			  spinlock_t *stats_lock, struct nlattr *opt)
 {
 	gen_kill_estimator(bstats, rate_est);
-	return gen_new_estimator(bstats, rate_est, stats_lock, opt);
+	return gen_new_estimator(bstats, cpu_bstats, rate_est, stats_lock, opt);
 }
 EXPORT_SYMBOL(gen_replace_estimator);
 
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 2ddbce4..5ff8e80 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -97,6 +97,43 @@ gnet_stats_start_copy(struct sk_buff *skb, int type, spinlock_t *lock,
 }
 EXPORT_SYMBOL(gnet_stats_start_copy);
 
+static void
+__gnet_stats_copy_basic_cpu(struct gnet_stats_basic_packed *bstats,
+			    struct gnet_stats_basic_cpu __percpu *cpu)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct gnet_stats_basic_cpu *bcpu = per_cpu_ptr(cpu, i);
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
+
+void
+__gnet_stats_copy_basic(struct gnet_stats_basic_packed *bstats,
+			struct gnet_stats_basic_cpu __percpu *cpu,
+			struct gnet_stats_basic_packed *b)
+{
+	if (cpu) {
+		__gnet_stats_copy_basic_cpu(bstats, cpu);
+	} else {
+		bstats->bytes = b->bytes;
+		bstats->packets = b->packets;
+	}
+}
+EXPORT_SYMBOL(__gnet_stats_copy_basic);
+
 /**
  * gnet_stats_copy_basic - copy basic statistics into statistic TLV
  * @d: dumping handle
@@ -109,19 +146,25 @@ EXPORT_SYMBOL(gnet_stats_start_copy);
  * if the room in the socket buffer was not sufficient.
  */
 int
-gnet_stats_copy_basic(struct gnet_dump *d, struct gnet_stats_basic_packed *b)
+gnet_stats_copy_basic(struct gnet_dump *d,
+		      struct gnet_stats_basic_cpu __percpu *cpu,
+		      struct gnet_stats_basic_packed *b)
 {
+	struct gnet_stats_basic_packed bstats = {0};
+
+	__gnet_stats_copy_basic(&bstats, cpu, b);
+
 	if (d->compat_tc_stats) {
-		d->tc_stats.bytes = b->bytes;
-		d->tc_stats.packets = b->packets;
+		d->tc_stats.bytes = bstats.bytes;
+		d->tc_stats.packets = bstats.packets;
 	}
 
 	if (d->tail) {
 		struct gnet_stats_basic sb;
 
 		memset(&sb, 0, sizeof(sb));
-		sb.bytes = b->bytes;
-		sb.packets = b->packets;
+		sb.bytes = bstats.bytes;
+		sb.packets = bstats.packets;
 		return gnet_stats_copy(d, TCA_STATS_BASIC, &sb, sizeof(sb));
 	}
 	return 0;
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 370adf6..604df6f 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -136,7 +136,7 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 	cfg.est.interval	= info->interval;
 	cfg.est.ewma_log	= info->ewma_log;
 
-	ret = gen_new_estimator(&est->bstats, &est->rstats,
+	ret = gen_new_estimator(&est->bstats, NULL, &est->rstats,
 				&est->lock, &cfg.opt);
 	if (ret < 0)
 		goto err2;
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 648778a..eca4cf9 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
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
@@ -619,7 +620,7 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 	if (err < 0)
 		goto errout;
 
-	if (gnet_stats_copy_basic(&d, &p->tcfc_bstats) < 0 ||
+	if (gnet_stats_copy_basic(&d, NULL, &p->tcfc_bstats) < 0 ||
 	    gnet_stats_copy_rate_est(&d, &p->tcfc_bstats,
 				     &p->tcfc_rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, &p->tcfc_qstats) < 0)
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index f32bcb0..69791ca 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -178,7 +178,7 @@ override:
 
 	spin_lock_bh(&police->tcf_lock);
 	if (est) {
-		err = gen_replace_estimator(&police->tcf_bstats,
+		err = gen_replace_estimator(&police->tcf_bstats, NULL,
 					    &police->tcf_rate_est,
 					    &police->tcf_lock, est);
 		if (err)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 15e7bee..a95e3b4 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -942,6 +942,13 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 	sch->handle = handle;
 
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS])) == 0) {
+		if (qdisc_is_percpu_stats(sch)) {
+			sch->cpu_bstats =
+				alloc_percpu(struct gnet_stats_basic_cpu);
+			if (!sch->cpu_bstats)
+				goto err_out4;
+		}
+
 		if (tca[TCA_STAB]) {
 			stab = qdisc_get_stab(tca[TCA_STAB]);
 			if (IS_ERR(stab)) {
@@ -964,8 +971,11 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			else
 				root_lock = qdisc_lock(sch);
 
-			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
-						root_lock, tca[TCA_RATE]);
+			err = gen_new_estimator(&sch->bstats,
+						sch->cpu_bstats,
+						&sch->rate_est,
+						root_lock,
+						tca[TCA_RATE]);
 			if (err)
 				goto err_out4;
 		}
@@ -984,6 +994,7 @@ err_out:
 	return NULL;
 
 err_out4:
+	free_percpu(sch->cpu_bstats);
 	/*
 	 * Any broken qdiscs that would require a ops->reset() here?
 	 * The qdisc was never in action so it shouldn't be necessary.
@@ -1022,9 +1033,11 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 		   because change can't be undone. */
 		if (sch->flags & TCQ_F_MQROOT)
 			goto out;
-		gen_replace_estimator(&sch->bstats, &sch->rate_est,
-					    qdisc_root_sleeping_lock(sch),
-					    tca[TCA_RATE]);
+		gen_replace_estimator(&sch->bstats,
+				      sch->cpu_bstats,
+				      &sch->rate_est,
+				      qdisc_root_sleeping_lock(sch),
+				      tca[TCA_RATE]);
 	}
 out:
 	return 0;
@@ -1299,6 +1312,7 @@ graft:
 static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 			 u32 portid, u32 seq, u16 flags, int event)
 {
+	struct gnet_stats_basic_cpu __percpu *cpu_bstats = NULL;
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
@@ -1334,7 +1348,10 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
 		goto nla_put_failure;
 
-	if (gnet_stats_copy_basic(&d, &q->bstats) < 0 ||
+	if (qdisc_is_percpu_stats(q))
+		cpu_bstats = q->cpu_bstats;
+
+	if (gnet_stats_copy_basic(&d, cpu_bstats, &q->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(&d, &q->bstats, &q->rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, &q->qstats) < 0)
 		goto nla_put_failure;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index c398f9c..0101766 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -639,7 +639,7 @@ atm_tc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 
 	flow->qstats.qlen = flow->q->q.qlen;
 
-	if (gnet_stats_copy_basic(d, &flow->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, NULL, &flow->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, &flow->qstats) < 0)
 		return -1;
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index d2cd981..22a3a02 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1601,7 +1601,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	if (cl->undertime != PSCHED_PASTPERFECT)
 		cl->xstats.undertime = cl->undertime - q->now;
 
-	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
@@ -1759,7 +1759,8 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 		}
 
 		if (tca[TCA_RATE]) {
-			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
+			err = gen_replace_estimator(&cl->bstats, NULL,
+						    &cl->rate_est,
 						    qdisc_root_sleeping_lock(sch),
 						    tca[TCA_RATE]);
 			if (err) {
@@ -1852,7 +1853,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 		goto failure;
 
 	if (tca[TCA_RATE]) {
-		err = gen_new_estimator(&cl->bstats, &cl->rate_est,
+		err = gen_new_estimator(&cl->bstats, NULL, &cl->rate_est,
 					qdisc_root_sleeping_lock(sch),
 					tca[TCA_RATE]);
 		if (err) {
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index d8b5ccf..7a6243c 100644
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
@@ -282,7 +283,7 @@ static int drr_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 		cl->qdisc->qstats.qlen = cl->qdisc->q.qlen;
 	}
 
-	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qdisc->qstats) < 0)
 		return -1;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 11b28f6..7c8e5d7 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -632,6 +632,9 @@ static void qdisc_rcu_free(struct rcu_head *head)
 {
 	struct Qdisc *qdisc = container_of(head, struct Qdisc, rcu_head);
 
+	if (qdisc_is_percpu_stats(qdisc))
+		free_percpu(qdisc->cpu_bstats);
+
 	kfree((char *) qdisc - qdisc->padded);
 }
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 04b0de4..209b966 100644
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
@@ -1374,7 +1377,7 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	xstats.work    = cl->cl_total;
 	xstats.rtwork  = cl->cl_cumul;
 
-	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 063e953..0256dee 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1144,7 +1144,7 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 	cl->xstats.tokens = PSCHED_NS2TICKS(cl->tokens);
 	cl->xstats.ctokens = PSCHED_NS2TICKS(cl->ctokens);
 
-	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
 		return -1;
@@ -1402,7 +1402,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			goto failure;
 
 		if (htb_rate_est || tca[TCA_RATE]) {
-			err = gen_new_estimator(&cl->bstats, &cl->rate_est,
+			err = gen_new_estimator(&cl->bstats, NULL,
+						&cl->rate_est,
 						qdisc_root_sleeping_lock(sch),
 						tca[TCA_RATE] ? : &est.nla);
 			if (err) {
@@ -1464,8 +1465,11 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
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
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index a8b2864..8080eaa 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -110,8 +110,8 @@ static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
 		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
 		spin_lock_bh(qdisc_lock(qdisc));
 		sch->q.qlen		+= qdisc->q.qlen;
-		sch->bstats.bytes	+= qdisc->bstats.bytes;
-		sch->bstats.packets	+= qdisc->bstats.packets;
+		sch->bstats->bytes	+= qdisc->bstats.bytes;
+		sch->bstats->packets	+= qdisc->bstats.packets;
 		sch->qstats.qlen	+= qdisc->qstats.qlen;
 		sch->qstats.backlog	+= qdisc->qstats.backlog;
 		sch->qstats.drops	+= qdisc->qstats.drops;
@@ -201,7 +201,7 @@ static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	sch = dev_queue->qdisc_sleeping;
 	sch->qstats.qlen = sch->q.qlen;
-	if (gnet_stats_copy_basic(d, &sch->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, NULL, &sch->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, &sch->qstats) < 0)
 		return -1;
 	return 0;
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 37e7d25..2f0ecd7 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -234,8 +234,8 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 		qdisc = rtnl_dereference(netdev_get_tx_queue(dev, i)->qdisc);
 		spin_lock_bh(qdisc_lock(qdisc));
 		sch->q.qlen		+= qdisc->q.qlen;
-		sch->bstats.bytes	+= qdisc->bstats.bytes;
-		sch->bstats.packets	+= qdisc->bstats.packets;
+		sch->bstats->bytes	+= qdisc->bstats.bytes;
+		sch->bstats->packets	+= qdisc->bstats.packets;
 		sch->qstats.qlen	+= qdisc->qstats.qlen;
 		sch->qstats.backlog	+= qdisc->qstats.backlog;
 		sch->qstats.drops	+= qdisc->qstats.drops;
@@ -355,7 +355,7 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		}
 		/* Reclaim root sleeping lock before completing stats */
 		spin_lock_bh(d->lock);
-		if (gnet_stats_copy_basic(d, &bstats) < 0 ||
+		if (gnet_stats_copy_basic(d, NULL, &bstats) < 0 ||
 		    gnet_stats_copy_queue(d, &qstats) < 0)
 			return -1;
 	} else {
@@ -363,7 +363,7 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 		sch = dev_queue->qdisc_sleeping;
 		sch->qstats.qlen = sch->q.qlen;
-		if (gnet_stats_copy_basic(d, &sch->bstats) < 0 ||
+		if (gnet_stats_copy_basic(d, NULL, &sch->bstats) < 0 ||
 		    gnet_stats_copy_queue(d, &sch->qstats) < 0)
 			return -1;
 	}
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index c0466c1..4adbf7f 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -361,7 +361,7 @@ static int multiq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	cl_q = q->queues[cl - 1];
 	cl_q->qstats.qlen = cl_q->q.qlen;
-	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, NULL, &cl_q->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
 		return -1;
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 03ef99e..68a8f25 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -325,7 +325,7 @@ static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	cl_q = q->queues[cl - 1];
 	cl_q->qstats.qlen = cl_q->q.qlen;
-	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, NULL, &cl_q->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
 		return -1;
 
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 602ea01..d59f857 100644
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
@@ -667,7 +669,7 @@ static int qfq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	xstats.weight = cl->agg->class_weight;
 	xstats.lmax = cl->agg->lmax;
 
-	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
+	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, &cl->qdisc->qstats) < 0)
 		return -1;
