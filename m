From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] net: sched: do not acquire qdisc spinlock in qdisc/class stats dump
Date: Mon,  6 Jun 2016 09:37:16 -0700
Message-ID: <1465231036-10674-3-git-send-email-edumazet@google.com>
References: <1465231036-10674-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35772 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410AbcFFQh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 12:37:26 -0400
Received: by mail-pa0-f42.google.com with SMTP id xk1so36899580pac.2
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 09:37:25 -0700 (PDT)
In-Reply-To: <1465231036-10674-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Large tc dumps (tc -s {qdisc|class} sh dev ethX) done by Google BwE host
agent [1] are problematic at scale :

For each qdisc/class found in the dump, we currently lock the root qdisc
spinlock in order to get stats. Sampling stats every 5 seconds from
thousands of HTB classes is a challenge when the root qdisc spinlock is
under high pressure. Not only the dumps take time, they also slow
down the fast path (queue/dequeue packets) by 10 % to 20 % in some cases.

An audit of existing qdiscs showed that sch_fq_codel is the only qdisc
that might need the qdisc lock in fq_codel_dump_stats() and
fq_codel_dump_class_stats()

In v2 of this patch, I now use the Qdisc running seqcount to provide
consistent reads of packets/bytes counters, regardless of 32/64 bit arches.

I also changed rate estimators to use the same infrastructure
so that they no longer need to lock root qdisc lock.

[1]
http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/43838.pdf

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Kevin Athey <kda@google.com>
Cc: Xiaotian Pei <xiaotian@google.com>
---
 Documentation/networking/gen_stats.txt |  2 +-
 include/net/gen_stats.h                | 12 ++++++++----
 include/net/sch_generic.h              |  8 ++++++++
 net/core/gen_estimator.c               | 24 ++++++++++++++++--------
 net/core/gen_stats.c                   | 34 +++++++++++++++++++++++-----------
 net/netfilter/xt_RATEEST.c             |  2 +-
 net/sched/act_api.c                    |  4 ++--
 net/sched/act_police.c                 |  3 ++-
 net/sched/sch_api.c                    | 21 +++++++++++----------
 net/sched/sch_atm.c                    |  3 ++-
 net/sched/sch_cbq.c                    |  9 ++++++---
 net/sched/sch_drr.c                    |  9 ++++++---
 net/sched/sch_fq_codel.c               | 15 +++++++++++----
 net/sched/sch_hfsc.c                   | 10 +++++-----
 net/sched/sch_htb.c                    | 11 ++++++-----
 net/sched/sch_mq.c                     |  2 +-
 net/sched/sch_mqprio.c                 | 11 +++++++----
 net/sched/sch_multiq.c                 |  3 ++-
 net/sched/sch_prio.c                   |  3 ++-
 net/sched/sch_qfq.c                    |  9 ++++++---
 20 files changed, 126 insertions(+), 69 deletions(-)

diff --git a/Documentation/networking/gen_stats.txt b/Documentation/networking/gen_stats.txt
index ff630a87b511..179b18ce45ff 100644
--- a/Documentation/networking/gen_stats.txt
+++ b/Documentation/networking/gen_stats.txt
@@ -21,7 +21,7 @@ struct mystruct {
 	...
 };
 
-Update statistics:
+Update statistics, in dequeue() methods only, (while owning qdisc->running)
 mystruct->tstats.packet++;
 mystruct->qstats.backlog += skb->pkt_len;
 
diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index 610cd397890e..231e121cc7d9 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -33,10 +33,12 @@ int gnet_stats_start_copy_compat(struct sk_buff *skb, int type,
 				 spinlock_t *lock, struct gnet_dump *d,
 				 int padattr);
 
-int gnet_stats_copy_basic(struct gnet_dump *d,
+int gnet_stats_copy_basic(const seqcount_t *running,
+			  struct gnet_dump *d,
 			  struct gnet_stats_basic_cpu __percpu *cpu,
 			  struct gnet_stats_basic_packed *b);
-void __gnet_stats_copy_basic(struct gnet_stats_basic_packed *bstats,
+void __gnet_stats_copy_basic(const seqcount_t *running,
+			     struct gnet_stats_basic_packed *bstats,
 			     struct gnet_stats_basic_cpu __percpu *cpu,
 			     struct gnet_stats_basic_packed *b);
 int gnet_stats_copy_rate_est(struct gnet_dump *d,
@@ -52,13 +54,15 @@ int gnet_stats_finish_copy(struct gnet_dump *d);
 int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 		      struct gnet_stats_basic_cpu __percpu *cpu_bstats,
 		      struct gnet_stats_rate_est64 *rate_est,
-		      spinlock_t *stats_lock, struct nlattr *opt);
+		      spinlock_t *stats_lock,
+		      seqcount_t *running, struct nlattr *opt);
 void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
 			struct gnet_stats_rate_est64 *rate_est);
 int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
 			  struct gnet_stats_basic_cpu __percpu *cpu_bstats,
 			  struct gnet_stats_rate_est64 *rate_est,
-			  spinlock_t *stats_lock, struct nlattr *opt);
+			  spinlock_t *stats_lock,
+			  seqcount_t *running, struct nlattr *opt);
 bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
 			  const struct gnet_stats_rate_est64 *rate_est);
 #endif
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index bff8d895ef8a..c4f5749342ec 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -314,6 +314,14 @@ static inline spinlock_t *qdisc_root_sleeping_lock(const struct Qdisc *qdisc)
 	return qdisc_lock(root);
 }
 
+static inline seqcount_t *qdisc_root_sleeping_running(const struct Qdisc *qdisc)
+{
+	struct Qdisc *root = qdisc_root_sleeping(qdisc);
+
+	ASSERT_RTNL();
+	return &root->running;
+}
+
 static inline struct net_device *qdisc_dev(const struct Qdisc *qdisc)
 {
 	return qdisc->dev_queue->dev;
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 4573d81093fe..cad8e791f28e 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -84,6 +84,7 @@ struct gen_estimator
 	struct gnet_stats_basic_packed	*bstats;
 	struct gnet_stats_rate_est64	*rate_est;
 	spinlock_t		*stats_lock;
+	seqcount_t		*running;
 	int			ewma_log;
 	u32			last_packets;
 	unsigned long		avpps;
@@ -121,26 +122,28 @@ static void est_timer(unsigned long arg)
 		unsigned long rate;
 		u64 brate;
 
-		spin_lock(e->stats_lock);
+		if (e->stats_lock)
+			spin_lock(e->stats_lock);
 		read_lock(&est_lock);
 		if (e->bstats == NULL)
 			goto skip;
 
-		__gnet_stats_copy_basic(&b, e->cpu_bstats, e->bstats);
+		__gnet_stats_copy_basic(e->running, &b, e->cpu_bstats, e->bstats);
 
 		brate = (b.bytes - e->last_bytes)<<(7 - idx);
 		e->last_bytes = b.bytes;
 		e->avbps += (brate >> e->ewma_log) - (e->avbps >> e->ewma_log);
-		e->rate_est->bps = (e->avbps+0xF)>>5;
+		WRITE_ONCE(e->rate_est->bps, (e->avbps + 0xF) >> 5);
 
 		rate = b.packets - e->last_packets;
 		rate <<= (7 - idx);
 		e->last_packets = b.packets;
 		e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
-		e->rate_est->pps = (e->avpps + 0xF) >> 5;
+		WRITE_ONCE(e->rate_est->pps, (e->avpps + 0xF) >> 5);
 skip:
 		read_unlock(&est_lock);
-		spin_unlock(e->stats_lock);
+		if (e->stats_lock)
+			spin_unlock(e->stats_lock);
 	}
 
 	if (!list_empty(&elist[idx].list))
@@ -194,6 +197,7 @@ struct gen_estimator *gen_find_node(const struct gnet_stats_basic_packed *bstats
  * @cpu_bstats: bstats per cpu
  * @rate_est: rate estimator statistics
  * @stats_lock: statistics lock
+ * @running: qdisc running seqcount
  * @opt: rate estimator configuration TLV
  *
  * Creates a new rate estimator with &bstats as source and &rate_est
@@ -209,6 +213,7 @@ int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 		      struct gnet_stats_basic_cpu __percpu *cpu_bstats,
 		      struct gnet_stats_rate_est64 *rate_est,
 		      spinlock_t *stats_lock,
+		      seqcount_t *running,
 		      struct nlattr *opt)
 {
 	struct gen_estimator *est;
@@ -226,12 +231,13 @@ int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 	if (est == NULL)
 		return -ENOBUFS;
 
-	__gnet_stats_copy_basic(&b, cpu_bstats, bstats);
+	__gnet_stats_copy_basic(running, &b, cpu_bstats, bstats);
 
 	idx = parm->interval + 2;
 	est->bstats = bstats;
 	est->rate_est = rate_est;
 	est->stats_lock = stats_lock;
+	est->running  = running;
 	est->ewma_log = parm->ewma_log;
 	est->last_bytes = b.bytes;
 	est->avbps = rate_est->bps<<5;
@@ -291,6 +297,7 @@ EXPORT_SYMBOL(gen_kill_estimator);
  * @cpu_bstats: bstats per cpu
  * @rate_est: rate estimator statistics
  * @stats_lock: statistics lock
+ * @running: qdisc running seqcount (might be NULL)
  * @opt: rate estimator configuration TLV
  *
  * Replaces the configuration of a rate estimator by calling
@@ -301,10 +308,11 @@ EXPORT_SYMBOL(gen_kill_estimator);
 int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
 			  struct gnet_stats_basic_cpu __percpu *cpu_bstats,
 			  struct gnet_stats_rate_est64 *rate_est,
-			  spinlock_t *stats_lock, struct nlattr *opt)
+			  spinlock_t *stats_lock,
+			  seqcount_t *running, struct nlattr *opt)
 {
 	gen_kill_estimator(bstats, rate_est);
-	return gen_new_estimator(bstats, cpu_bstats, rate_est, stats_lock, opt);
+	return gen_new_estimator(bstats, cpu_bstats, rate_est, stats_lock, running, opt);
 }
 EXPORT_SYMBOL(gen_replace_estimator);
 
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index f96ee8b9478d..d9c210caff32 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -32,10 +32,11 @@ gnet_stats_copy(struct gnet_dump *d, int type, void *buf, int size, int padattr)
 	return 0;
 
 nla_put_failure:
+	if (d->lock)
+		spin_unlock_bh(d->lock);
 	kfree(d->xstats);
 	d->xstats = NULL;
 	d->xstats_len = 0;
-	spin_unlock_bh(d->lock);
 	return -1;
 }
 
@@ -65,15 +66,16 @@ gnet_stats_start_copy_compat(struct sk_buff *skb, int type, int tc_stats_type,
 {
 	memset(d, 0, sizeof(*d));
 
-	spin_lock_bh(lock);
-	d->lock = lock;
 	if (type)
 		d->tail = (struct nlattr *)skb_tail_pointer(skb);
 	d->skb = skb;
 	d->compat_tc_stats = tc_stats_type;
 	d->compat_xstats = xstats_type;
 	d->padattr = padattr;
-
+	if (lock) {
+		d->lock = lock;
+		spin_lock_bh(lock);
+	}
 	if (d->tail)
 		return gnet_stats_copy(d, type, NULL, 0, padattr);
 
@@ -126,16 +128,23 @@ __gnet_stats_copy_basic_cpu(struct gnet_stats_basic_packed *bstats,
 }
 
 void
-__gnet_stats_copy_basic(struct gnet_stats_basic_packed *bstats,
+__gnet_stats_copy_basic(const seqcount_t *running,
+			struct gnet_stats_basic_packed *bstats,
 			struct gnet_stats_basic_cpu __percpu *cpu,
 			struct gnet_stats_basic_packed *b)
 {
+	unsigned int seq;
+
 	if (cpu) {
 		__gnet_stats_copy_basic_cpu(bstats, cpu);
-	} else {
+		return;
+	}
+	do {
+		if (running)
+			seq = read_seqcount_begin(running);
 		bstats->bytes = b->bytes;
 		bstats->packets = b->packets;
-	}
+	} while (running && read_seqcount_retry(running, seq));
 }
 EXPORT_SYMBOL(__gnet_stats_copy_basic);
 
@@ -152,13 +161,14 @@ EXPORT_SYMBOL(__gnet_stats_copy_basic);
  * if the room in the socket buffer was not sufficient.
  */
 int
-gnet_stats_copy_basic(struct gnet_dump *d,
+gnet_stats_copy_basic(const seqcount_t *running,
+		      struct gnet_dump *d,
 		      struct gnet_stats_basic_cpu __percpu *cpu,
 		      struct gnet_stats_basic_packed *b)
 {
 	struct gnet_stats_basic_packed bstats = {0};
 
-	__gnet_stats_copy_basic(&bstats, cpu, b);
+	__gnet_stats_copy_basic(running, &bstats, cpu, b);
 
 	if (d->compat_tc_stats) {
 		d->tc_stats.bytes = bstats.bytes;
@@ -328,8 +338,9 @@ gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
 	return 0;
 
 err_out:
+	if (d->lock)
+		spin_unlock_bh(d->lock);
 	d->xstats_len = 0;
-	spin_unlock_bh(d->lock);
 	return -1;
 }
 EXPORT_SYMBOL(gnet_stats_copy_app);
@@ -363,10 +374,11 @@ gnet_stats_finish_copy(struct gnet_dump *d)
 			return -1;
 	}
 
+	if (d->lock)
+		spin_unlock_bh(d->lock);
 	kfree(d->xstats);
 	d->xstats = NULL;
 	d->xstats_len = 0;
-	spin_unlock_bh(d->lock);
 	return 0;
 }
 EXPORT_SYMBOL(gnet_stats_finish_copy);
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 604df6fae6fc..515131f9e021 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -137,7 +137,7 @@ static int xt_rateest_tg_checkentry(const struct xt_tgchk_param *par)
 	cfg.est.ewma_log	= info->ewma_log;
 
 	ret = gen_new_estimator(&est->bstats, NULL, &est->rstats,
-				&est->lock, &cfg.opt);
+				&est->lock, NULL, &cfg.opt);
 	if (ret < 0)
 		goto err2;
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 336774a535c3..ceaa34735724 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -286,7 +286,7 @@ err2:
 	if (est) {
 		err = gen_new_estimator(&p->tcfc_bstats, p->cpu_bstats,
 					&p->tcfc_rate_est,
-					&p->tcfc_lock, est);
+					&p->tcfc_lock, NULL, est);
 		if (err) {
 			free_percpu(p->cpu_qstats);
 			goto err2;
@@ -670,7 +670,7 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 	if (err < 0)
 		goto errout;
 
-	if (gnet_stats_copy_basic(&d, p->cpu_bstats, &p->tcfc_bstats) < 0 ||
+	if (gnet_stats_copy_basic(NULL, &d, p->cpu_bstats, &p->tcfc_bstats) < 0 ||
 	    gnet_stats_copy_rate_est(&d, &p->tcfc_bstats,
 				     &p->tcfc_rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, p->cpu_qstats,
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index b884dae692a1..f43ea99840ed 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -185,7 +185,8 @@ override:
 	if (est) {
 		err = gen_replace_estimator(&police->tcf_bstats, NULL,
 					    &police->tcf_rate_est,
-					    &police->tcf_lock, est);
+					    &police->tcf_lock,
+					    NULL, est);
 		if (err)
 			goto failure_unlock;
 	} else if (tb[TCA_POLICE_AVRATE] &&
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ddf047df5361..d4a8bbfcc953 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -982,7 +982,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			rcu_assign_pointer(sch->stab, stab);
 		}
 		if (tca[TCA_RATE]) {
-			spinlock_t *root_lock;
+			seqcount_t *running;
 
 			err = -EOPNOTSUPP;
 			if (sch->flags & TCQ_F_MQROOT)
@@ -991,14 +991,15 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			if ((sch->parent != TC_H_ROOT) &&
 			    !(sch->flags & TCQ_F_INGRESS) &&
 			    (!p || !(p->flags & TCQ_F_MQROOT)))
-				root_lock = qdisc_root_sleeping_lock(sch);
+				running = qdisc_root_sleeping_running(sch);
 			else
-				root_lock = qdisc_lock(sch);
+				running = &sch->running;
 
 			err = gen_new_estimator(&sch->bstats,
 						sch->cpu_bstats,
 						&sch->rate_est,
-						root_lock,
+						NULL,
+						running,
 						tca[TCA_RATE]);
 			if (err)
 				goto err_out4;
@@ -1061,7 +1062,8 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 		gen_replace_estimator(&sch->bstats,
 				      sch->cpu_bstats,
 				      &sch->rate_est,
-				      qdisc_root_sleeping_lock(sch),
+				      NULL,
+				      qdisc_root_sleeping_running(sch),
 				      tca[TCA_RATE]);
 	}
 out:
@@ -1369,8 +1371,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		goto nla_put_failure;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTATS,
-					 qdisc_root_sleeping_lock(q), &d,
-					 TCA_PAD) < 0)
+					 NULL, &d, TCA_PAD) < 0)
 		goto nla_put_failure;
 
 	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
@@ -1381,7 +1382,8 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		cpu_qstats = q->cpu_qstats;
 	}
 
-	if (gnet_stats_copy_basic(&d, cpu_bstats, &q->bstats) < 0 ||
+	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(q),
+				  &d, cpu_bstats, &q->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(&d, &q->bstats, &q->rate_est) < 0 ||
 	    gnet_stats_copy_queue(&d, cpu_qstats, &q->qstats, qlen) < 0)
 		goto nla_put_failure;
@@ -1684,8 +1686,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 		goto nla_put_failure;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTATS,
-					 qdisc_root_sleeping_lock(q), &d,
-					 TCA_PAD) < 0)
+					 NULL, &d, TCA_PAD) < 0)
 		goto nla_put_failure;
 
 	if (cl_ops->dump_stats && cl_ops->dump_stats(q, cl, &d) < 0)
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 1911af3ca7c0..34f8f79e56d5 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -637,7 +637,8 @@ atm_tc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 {
 	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
 
-	if (gnet_stats_copy_basic(d, NULL, &flow->bstats) < 0 ||
+	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
+				  d, NULL, &flow->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &flow->qstats, flow->q->q.qlen) < 0)
 		return -1;
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index baafddf229ce..1b8128fb845d 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1600,7 +1600,8 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	if (cl->undertime != PSCHED_PASTPERFECT)
 		cl->xstats.undertime = cl->undertime - q->now;
 
-	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
+	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
+				  d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &cl->qstats, cl->q->q.qlen) < 0)
 		return -1;
@@ -1755,7 +1756,8 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 		if (tca[TCA_RATE]) {
 			err = gen_replace_estimator(&cl->bstats, NULL,
 						    &cl->rate_est,
-						    qdisc_root_sleeping_lock(sch),
+						    NULL,
+						    qdisc_root_sleeping_running(sch),
 						    tca[TCA_RATE]);
 			if (err) {
 				qdisc_put_rtab(rtab);
@@ -1848,7 +1850,8 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 
 	if (tca[TCA_RATE]) {
 		err = gen_new_estimator(&cl->bstats, NULL, &cl->rate_est,
-					qdisc_root_sleeping_lock(sch),
+					NULL,
+					qdisc_root_sleeping_running(sch),
 					tca[TCA_RATE]);
 		if (err) {
 			kfree(cl);
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index a63e879e8975..1b7e1a27773d 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -91,7 +91,8 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		if (tca[TCA_RATE]) {
 			err = gen_replace_estimator(&cl->bstats, NULL,
 						    &cl->rate_est,
-						    qdisc_root_sleeping_lock(sch),
+						    NULL,
+						    qdisc_root_sleeping_running(sch),
 						    tca[TCA_RATE]);
 			if (err)
 				return err;
@@ -119,7 +120,8 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (tca[TCA_RATE]) {
 		err = gen_replace_estimator(&cl->bstats, NULL, &cl->rate_est,
-					    qdisc_root_sleeping_lock(sch),
+					    NULL,
+					    qdisc_root_sleeping_running(sch),
 					    tca[TCA_RATE]);
 		if (err) {
 			qdisc_destroy(cl->qdisc);
@@ -279,7 +281,8 @@ static int drr_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	if (qlen)
 		xstats.deficit = cl->deficit;
 
-	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
+	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
+				  d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &cl->qdisc->qstats, qlen) < 0)
 		return -1;
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 6883a8971562..1daa54237f4e 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -566,11 +566,13 @@ static int fq_codel_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 	st.qdisc_stats.memory_usage  = q->memory_usage;
 	st.qdisc_stats.drop_overmemory = q->drop_overmemory;
 
+	sch_tree_lock(sch);
 	list_for_each(pos, &q->new_flows)
 		st.qdisc_stats.new_flows_len++;
 
 	list_for_each(pos, &q->old_flows)
 		st.qdisc_stats.old_flows_len++;
+	sch_tree_unlock(sch);
 
 	return gnet_stats_copy_app(d, &st, sizeof(st));
 }
@@ -624,7 +626,7 @@ static int fq_codel_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	if (idx < q->flows_cnt) {
 		const struct fq_codel_flow *flow = &q->flows[idx];
-		const struct sk_buff *skb = flow->head;
+		const struct sk_buff *skb;
 
 		memset(&xstats, 0, sizeof(xstats));
 		xstats.type = TCA_FQ_CODEL_XSTATS_CLASS;
@@ -642,9 +644,14 @@ static int fq_codel_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 				codel_time_to_us(delta) :
 				-codel_time_to_us(-delta);
 		}
-		while (skb) {
-			qs.qlen++;
-			skb = skb->next;
+		if (flow->head) {
+			sch_tree_lock(sch);
+			skb = flow->head;
+			while (skb) {
+				qs.qlen++;
+				skb = skb->next;
+			}
+			sch_tree_unlock(sch);
 		}
 		qs.backlog = q->backlogs[idx];
 		qs.drops = flow->dropped;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index d783d7cc3348..74813dd49053 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1015,11 +1015,10 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		cur_time = psched_get_time();
 
 		if (tca[TCA_RATE]) {
-			spinlock_t *lock = qdisc_root_sleeping_lock(sch);
-
 			err = gen_replace_estimator(&cl->bstats, NULL,
 						    &cl->rate_est,
-						    lock,
+						    NULL,
+						    qdisc_root_sleeping_running(sch),
 						    tca[TCA_RATE]);
 			if (err)
 				return err;
@@ -1068,7 +1067,8 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (tca[TCA_RATE]) {
 		err = gen_new_estimator(&cl->bstats, NULL, &cl->rate_est,
-					qdisc_root_sleeping_lock(sch),
+					NULL,
+					qdisc_root_sleeping_running(sch),
 					tca[TCA_RATE]);
 		if (err) {
 			kfree(cl);
@@ -1373,7 +1373,7 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	xstats.work    = cl->cl_total;
 	xstats.rtwork  = cl->cl_cumul;
 
-	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
+	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch), d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &cl->qstats, cl->qdisc->q.qlen) < 0)
 		return -1;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d4b4218af6b1..2b057649f24b 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1141,7 +1141,8 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 	cl->xstats.tokens = PSCHED_NS2TICKS(cl->tokens);
 	cl->xstats.ctokens = PSCHED_NS2TICKS(cl->ctokens);
 
-	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
+	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
+				  d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &cl->qstats, qlen) < 0)
 		return -1;
@@ -1395,7 +1396,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		if (htb_rate_est || tca[TCA_RATE]) {
 			err = gen_new_estimator(&cl->bstats, NULL,
 						&cl->rate_est,
-						qdisc_root_sleeping_lock(sch),
+						NULL,
+						qdisc_root_sleeping_running(sch),
 						tca[TCA_RATE] ? : &est.nla);
 			if (err) {
 				kfree(cl);
@@ -1457,11 +1459,10 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			parent->children++;
 	} else {
 		if (tca[TCA_RATE]) {
-			spinlock_t *lock = qdisc_root_sleeping_lock(sch);
-
 			err = gen_replace_estimator(&cl->bstats, NULL,
 						    &cl->rate_est,
-						    lock,
+						    NULL,
+						    qdisc_root_sleeping_running(sch),
 						    tca[TCA_RATE]);
 			if (err)
 				return err;
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 56a77b878eb3..b9439827c172 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -199,7 +199,7 @@ static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct netdev_queue *dev_queue = mq_queue_get(sch, cl);
 
 	sch = dev_queue->qdisc_sleeping;
-	if (gnet_stats_copy_basic(d, NULL, &sch->bstats) < 0 ||
+	if (gnet_stats_copy_basic(&sch->running, d, NULL, &sch->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &sch->qstats, sch->q.qlen) < 0)
 		return -1;
 	return 0;
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index b8002ce3d010..549c66359924 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -342,7 +342,8 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		 * hold here is the look on dev_queue->qdisc_sleeping
 		 * also acquired below.
 		 */
-		spin_unlock_bh(d->lock);
+		if (d->lock)
+			spin_unlock_bh(d->lock);
 
 		for (i = tc.offset; i < tc.offset + tc.count; i++) {
 			struct netdev_queue *q = netdev_get_tx_queue(dev, i);
@@ -359,15 +360,17 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 			spin_unlock_bh(qdisc_lock(qdisc));
 		}
 		/* Reclaim root sleeping lock before completing stats */
-		spin_lock_bh(d->lock);
-		if (gnet_stats_copy_basic(d, NULL, &bstats) < 0 ||
+		if (d->lock)
+			spin_lock_bh(d->lock);
+		if (gnet_stats_copy_basic(NULL, d, NULL, &bstats) < 0 ||
 		    gnet_stats_copy_queue(d, NULL, &qstats, qlen) < 0)
 			return -1;
 	} else {
 		struct netdev_queue *dev_queue = mqprio_queue_get(sch, cl);
 
 		sch = dev_queue->qdisc_sleeping;
-		if (gnet_stats_copy_basic(d, NULL, &sch->bstats) < 0 ||
+		if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
+					  d, NULL, &sch->bstats) < 0 ||
 		    gnet_stats_copy_queue(d, NULL,
 					  &sch->qstats, sch->q.qlen) < 0)
 			return -1;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index bcdd54bb101c..21e69d2e8347 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -356,7 +356,8 @@ static int multiq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct Qdisc *cl_q;
 
 	cl_q = q->queues[cl - 1];
-	if (gnet_stats_copy_basic(d, NULL, &cl_q->bstats) < 0 ||
+	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
+				  d, NULL, &cl_q->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &cl_q->qstats, cl_q->q.qlen) < 0)
 		return -1;
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index fee1b15506b2..06eca7060683 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -319,7 +319,8 @@ static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	struct Qdisc *cl_q;
 
 	cl_q = q->queues[cl - 1];
-	if (gnet_stats_copy_basic(d, NULL, &cl_q->bstats) < 0 ||
+	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
+				  d, NULL, &cl_q->bstats) < 0 ||
 	    gnet_stats_copy_queue(d, NULL, &cl_q->qstats, cl_q->q.qlen) < 0)
 		return -1;
 
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 8d2d8d953432..85d41979d825 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -460,7 +460,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		if (tca[TCA_RATE]) {
 			err = gen_replace_estimator(&cl->bstats, NULL,
 						    &cl->rate_est,
-						    qdisc_root_sleeping_lock(sch),
+						    NULL,
+						    qdisc_root_sleeping_running(sch),
 						    tca[TCA_RATE]);
 			if (err)
 				return err;
@@ -486,7 +487,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (tca[TCA_RATE]) {
 		err = gen_new_estimator(&cl->bstats, NULL,
 					&cl->rate_est,
-					qdisc_root_sleeping_lock(sch),
+					NULL,
+					qdisc_root_sleeping_running(sch),
 					tca[TCA_RATE]);
 		if (err)
 			goto destroy_class;
@@ -663,7 +665,8 @@ static int qfq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	xstats.weight = cl->agg->class_weight;
 	xstats.lmax = cl->agg->lmax;
 
-	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
+	if (gnet_stats_copy_basic(qdisc_root_sleeping_running(sch),
+				  d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
 	    gnet_stats_copy_queue(d, NULL,
 				  &cl->qdisc->qstats, cl->qdisc->q.qlen) < 0)
-- 
2.8.0.rc3.226.g39d4020
