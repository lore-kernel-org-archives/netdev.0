From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 4/4] net: sched: enable per cpu qstats
Date: Fri, 26 Sep 2014 11:37:35 -0700
Message-ID: <20140926183734.2621.23713.stgit@nitbit.x32>
References: <20140926183621.2621.72538.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:52373 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111AbaIZSh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 14:37:56 -0400
Received: by mail-ob0-f181.google.com with SMTP id wo20so9988651obc.26
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 11:37:55 -0700 (PDT)
In-Reply-To: <20140926183621.2621.72538.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After previous patches to simplify qstats the qstats can be
made per cpu with a packed union in Qdisc struct.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/gen_stats.h   |    3 ++
 include/net/sch_generic.h |   12 +++++++++-
 net/core/gen_stats.c      |   55 +++++++++++++++++++++++++++++++++++++++------
 net/sched/act_api.c       |    2 +-
 net/sched/sch_api.c       |   12 ++++++++--
 net/sched/sch_atm.c       |    2 +-
 net/sched/sch_cbq.c       |    2 +-
 net/sched/sch_drr.c       |    2 +-
 net/sched/sch_fq_codel.c  |    2 +-
 net/sched/sch_hfsc.c      |    2 +-
 net/sched/sch_htb.c       |    2 +-
 net/sched/sch_mq.c        |    2 +-
 net/sched/sch_mqprio.c    |    5 ++--
 net/sched/sch_multiq.c    |    2 +-
 net/sched/sch_prio.c      |    2 +-
 net/sched/sch_qfq.c       |    3 ++
 net/sched/sch_sfq.c       |    2 +-
 17 files changed, 87 insertions(+), 25 deletions(-)

diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index de9b3dd..cbafa37 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -41,7 +41,8 @@ int gnet_stats_copy_rate_est(struct gnet_dump *d,
 			     const struct gnet_stats_basic_packed *b,
 			     struct gnet_stats_rate_est64 *r);
 int gnet_stats_copy_queue(struct gnet_dump *d,
-			  struct gnet_stats_queue *q, __u32 len);
+			  struct gnet_stats_queue __percpu *cpu_q,
+			  struct gnet_stats_queue *q, __u32 qlen);
 int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
 
 int gnet_stats_finish_copy(struct gnet_dump *d);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 5609844..4d14c70 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -90,7 +90,10 @@ struct Qdisc {
 		struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	} __packed;
 	unsigned int		__state;
-	struct gnet_stats_queue	qstats;
+	union {
+		struct gnet_stats_queue	qstats;
+		struct gnet_stats_queue	__percpu *cpu_qstats;
+	} __packed;
 	struct rcu_head		rcu_head;
 	int			padded;
 	atomic_t		refcnt;
@@ -544,6 +547,13 @@ static inline void qdisc_qstats_drop(struct Qdisc *sch)
 	sch->qstats.drops++;
 }
 
+static inline void qdisc_qstats_drop_cpu(struct Qdisc *sch)
+{
+	struct gnet_stats_queue *qstats = this_cpu_ptr(sch->cpu_qstats);
+
+	qstats->drops++;
+}
+
 static inline void qdisc_qstats_overlimit(struct Qdisc *sch)
 {
 	sch->qstats.overlimits++;
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index ad3ecb6..14681b9 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -215,33 +215,74 @@ gnet_stats_copy_rate_est(struct gnet_dump *d,
 }
 EXPORT_SYMBOL(gnet_stats_copy_rate_est);
 
+static void
+__gnet_stats_copy_queue_cpu(struct gnet_stats_queue *qstats,
+			    const struct gnet_stats_queue __percpu *q)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		const struct gnet_stats_queue *qcpu = per_cpu_ptr(q, i);
+
+		qstats->qlen = 0;
+		qstats->backlog += qcpu->backlog;
+		qstats->drops += qcpu->drops;
+		qstats->requeues += qcpu->requeues;
+		qstats->overlimits += qcpu->overlimits;
+	}
+}
+
+static void __gnet_stats_copy_queue(struct gnet_stats_queue *qstats,
+				    const struct gnet_stats_queue __percpu *cpu,
+				    const struct gnet_stats_queue *q,
+				    __u32 qlen)
+{
+	if (cpu) {
+		__gnet_stats_copy_queue_cpu(qstats, cpu);
+	} else {
+		qstats->qlen = q->qlen;
+		qstats->backlog = q->backlog;
+		qstats->drops = q->drops;
+		qstats->requeues = q->requeues;
+		qstats->overlimits = q->overlimits;
+	}
+
+	qstats->qlen = qlen;
+}
+
 /**
  * gnet_stats_copy_queue - copy queue statistics into statistics TLV
  * @d: dumping handle
+ * @cpu_q: per cpu queue statistics
  * @q: queue statistics
  * @qlen: queue length statistics
  *
  * Appends the queue statistics to the top level TLV created by
- * gnet_stats_start_copy().
+ * gnet_stats_start_copy(). Using per cpu queue statistics if
+ * they are available.
  *
  * Returns 0 on success or -1 with the statistic lock released
  * if the room in the socket buffer was not sufficient.
  */
 int
 gnet_stats_copy_queue(struct gnet_dump *d,
+		      struct gnet_stats_queue __percpu *cpu_q,
 		      struct gnet_stats_queue *q, __u32 qlen)
 {
-	q->qlen = qlen;
+	struct gnet_stats_queue qstats = {0};
+
+	__gnet_stats_copy_queue(&qstats, cpu_q, q, qlen);
 
 	if (d->compat_tc_stats) {
-		d->tc_stats.drops = q->drops;
-		d->tc_stats.qlen = q->qlen;
-		d->tc_stats.backlog = q->backlog;
-		d->tc_stats.overlimits = q->overlimits;
+		d->tc_stats.drops = qstats.drops;
+		d->tc_stats.qlen = qstats.qlen;
+		d->tc_stats.backlog = qstats.backlog;
+		d->tc_stats.overlimits = qstats.overlimits;
 	}
 
 	if (d->tail)
-		return gnet_stats_copy(d, TCA_STATS_QUEUE, q, sizeof(*q));
+		return gnet_stats_copy(d, TCA_STATS_QUEUE,
+				       &qstats, sizeof(qstats));
 
 	return 0;
 }
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 2e13409..3d43e49 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -623,7 +623,7 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 	if (gnet_stats_copy_basic(&d, NULL, &p->tcfc_bstats) < 0 ||
 	    gnet_stats_copy_rate_est(&d, &p->tcfc_bstats,
 				     &p->tcfc_rate_est) < 0 ||
-	    gnet_stats_copy_queue(&d,
+	    gnet_stats_copy_queue(&d, NULL,
 				  &p->tcfc_qstats,
 				  p->tcfc_qstats.qlen) < 0)
 		goto errout;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ca00ea8..aa83295 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -947,6 +947,10 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				alloc_percpu(struct gnet_stats_basic_cpu);
 			if (!sch->cpu_bstats)
 				goto err_out4;
+
+			sch->cpu_qstats = alloc_percpu(struct gnet_stats_queue);
+			if (!sch->cpu_qstats)
+				goto err_out4;
 		}
 
 		if (tca[TCA_STAB]) {
@@ -995,6 +999,7 @@ err_out:
 
 err_out4:
 	free_percpu(sch->cpu_bstats);
+	free_percpu(sch->cpu_qstats);
 	/*
 	 * Any broken qdiscs that would require a ops->reset() here?
 	 * The qdisc was never in action so it shouldn't be necessary.
@@ -1313,6 +1318,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 			 u32 portid, u32 seq, u16 flags, int event)
 {
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats = NULL;
+	struct gnet_stats_queue __percpu *cpu_qstats = NULL;
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
@@ -1349,12 +1355,14 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
 		goto nla_put_failure;
 
-	if (qdisc_is_percpu_stats(q))
+	if (qdisc_is_percpu_stats(q)) {
 		cpu_bstats = q->cpu_bstats;
+		cpu_qstats = q->cpu_qstats;
+	}
 
 	if (gnet_stats_copy_basic(&d, cpu_bstats, &q->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(&d, &q->bstats, &q->rate_est) < 0 ||
-	    gnet_stats_copy_queue(&d, &q->qstats, qlen) < 0)
+	    gnet_stats_copy_queue(&d, cpu_qstats, &q->qstats, qlen) < 0)
 		goto nla_put_failure;
 
 	if (gnet_stats_finish_copy(&d) < 0)
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index c145eb6..e3e2cc5 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -638,7 +638,7 @@ atm_tc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
 
 	if (gnet_stats_copy_basic(d, NULL, &flow->bstats) < 0 ||
-	    gnet_stats_copy_queue(d, &flow->qstats, flow->q->q.qlen) < 0)
+	    gnet_stats_copy_queue(d, NULL, &flow->qstats, flow->q->q.qlen) < 0)
 		return -1;
 
 	return 0;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index c610081..beeb75f 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1602,7 +1602,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 
 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qstats, cl->q->q.qlen) < 0)
+	    gnet_stats_copy_queue(d, NULL, &cl->qstats, cl->q->q.qlen) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &cl->xstats, sizeof(cl->xstats));
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 5835a93..3387060 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -284,7 +284,7 @@ static int drr_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 
 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qdisc->qstats, qlen) < 0)
+	    gnet_stats_copy_queue(d, NULL, &cl->qdisc->qstats, qlen) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 6a42112..301c352 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -550,7 +550,7 @@ static int fq_codel_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		qs.backlog = q->backlogs[idx];
 		qs.drops = flow->dropped;
 	}
-	if (gnet_stats_copy_queue(d, &qs, 0) < 0)
+	if (gnet_stats_copy_queue(d, NULL, &qs, 0) < 0)
 		return -1;
 	if (idx < q->flows_cnt)
 		return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index d364acb..e6c7416 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1378,7 +1378,7 @@ hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 
 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qstats, cl->qdisc->q.qlen) < 0)
+	    gnet_stats_copy_queue(d, NULL, &cl->qstats, cl->qdisc->q.qlen) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 3a691fd..f1acb0f 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1147,7 +1147,7 @@ htb_dump_class_stats(struct Qdisc *sch, unsigned long arg, struct gnet_dump *d)
 
 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, NULL, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qstats, qlen) < 0)
+	    gnet_stats_copy_queue(d, NULL, &cl->qstats, qlen) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &cl->xstats, sizeof(cl->xstats));
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 6416a69..f3cbaec 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -200,7 +200,7 @@ static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	sch = dev_queue->qdisc_sleeping;
 	if (gnet_stats_copy_basic(d, NULL, &sch->bstats) < 0 ||
-	    gnet_stats_copy_queue(d, &sch->qstats, sch->q.qlen) < 0)
+	    gnet_stats_copy_queue(d, NULL, &sch->qstats, sch->q.qlen) < 0)
 		return -1;
 	return 0;
 }
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 03dbeb5..3811a74 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -356,14 +356,15 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		/* Reclaim root sleeping lock before completing stats */
 		spin_lock_bh(d->lock);
 		if (gnet_stats_copy_basic(d, NULL, &bstats) < 0 ||
-		    gnet_stats_copy_queue(d, &qstats, qlen) < 0)
+		    gnet_stats_copy_queue(d, NULL, &qstats, qlen) < 0)
 			return -1;
 	} else {
 		struct netdev_queue *dev_queue = mqprio_queue_get(sch, cl);
 
 		sch = dev_queue->qdisc_sleeping;
 		if (gnet_stats_copy_basic(d, NULL, &sch->bstats) < 0 ||
-		    gnet_stats_copy_queue(d, &sch->qstats, sch->q.qlen) < 0)
+		    gnet_stats_copy_queue(d, NULL,
+					  &sch->qstats, sch->q.qlen) < 0)
 			return -1;
 	}
 	return 0;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 53357b3..42dd218 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -361,7 +361,7 @@ static int multiq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	cl_q = q->queues[cl - 1];
 	if (gnet_stats_copy_basic(d, NULL, &cl_q->bstats) < 0 ||
-	    gnet_stats_copy_queue(d, &cl_q->qstats, cl_q->q.qlen) < 0)
+	    gnet_stats_copy_queue(d, NULL, &cl_q->qstats, cl_q->q.qlen) < 0)
 		return -1;
 
 	return 0;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 4644f55..8e5cd34 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -325,7 +325,7 @@ static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	cl_q = q->queues[cl - 1];
 	if (gnet_stats_copy_basic(d, NULL, &cl_q->bstats) < 0 ||
-	    gnet_stats_copy_queue(d, &cl_q->qstats, cl_q->q.qlen) < 0)
+	    gnet_stats_copy_queue(d, NULL, &cl_q->qstats, cl_q->q.qlen) < 0)
 		return -1;
 
 	return 0;
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 66df9d9..3ec7e88 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -670,7 +670,8 @@ static int qfq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 
 	if (gnet_stats_copy_basic(d, NULL, &cl->bstats) < 0 ||
 	    gnet_stats_copy_rate_est(d, &cl->bstats, &cl->rate_est) < 0 ||
-	    gnet_stats_copy_queue(d, &cl->qdisc->qstats, cl->qdisc->q.qlen) < 0)
+	    gnet_stats_copy_queue(d, NULL,
+				  &cl->qdisc->qstats, cl->qdisc->q.qlen) < 0)
 		return -1;
 
 	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 4805651..5814c46 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -871,7 +871,7 @@ static int sfq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		qs.qlen = slot->qlen;
 		qs.backlog = slot->backlog;
 	}
-	if (gnet_stats_copy_queue(d, &qs, qs.qlen) < 0)
+	if (gnet_stats_copy_queue(d, NULL, &qs, qs.qlen) < 0)
 		return -1;
 	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
 }
