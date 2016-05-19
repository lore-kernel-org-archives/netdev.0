From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Thu, 19 May 2016 05:35:20 -0700
Message-ID: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35179 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbcESMfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 08:35:23 -0400
Received: by mail-pa0-f68.google.com with SMTP id rw9so7790506pab.2
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 05:35:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Large tc dumps (tc -s {qdisc|class} sh dev ethX) done by Google BwE host
agent [1] are problematic at scale :
    
For each qdisc/class found in the dump, we currently lock the root qdisc
spinlock in order to get stats. Sampling stats every 5 seconds from
thousands of HTB classes is a challenge when the root qdisc spinlock is
under high pressure.

These stats are using u64 or u32 fields, so reading integral values
should not prevent writers from doing concurrent updates if the kernel
arch is a 64bit one.

Being able to atomically fetch all counters like packets and bytes sent
at the expense of interfering in fast path (queue and dequeue packets)
is simply not worth the pain, as the values are generally stale after 1
usec.

These lock acquisitions slow down the fast path by 10 to 20 %

An audit of existing qdiscs showed that sch_fq_codel is the only qdisc
that might need the qdisc lock in fq_codel_dump_stats() and
fq_codel_dump_class_stats()

gnet_dump_force_lock() call is added there and could be added to other
qdisc stat handlers if needed.

[1]
http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/43838.pdf

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Kevin Athey <kda@google.com>
Cc: Xiaotian Pei <xiaotian@google.com>
---
 include/net/sch_generic.h |   23 +++++++++++++++++++++++
 net/core/gen_stats.c      |   16 ++++++++++------
 net/sched/sch_api.c       |    4 ++--
 net/sched/sch_fq_codel.c  |   13 +++++++++----
 net/sched/sch_mqprio.c    |    6 ++++--
 5 files changed, 48 insertions(+), 14 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a1fd76c22a59..87f39fafb770 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -321,6 +321,29 @@ static inline spinlock_t *qdisc_root_sleeping_lock(const struct Qdisc *qdisc)
 	return qdisc_lock(root);
 }
 
+static inline spinlock_t *qdisc_stats_lock(const struct Qdisc *qdisc)
+{
+	ASSERT_RTNL();
+#if defined(CONFIG_64BIT) && !defined(CONFIG_LOCKDEP)
+	/* With u32/u64 bytes counter, there is no real issue on 64bit arches */
+	return NULL;
+#else
+	return qdisc_lock(qdisc_root_sleeping(qdisc));
+#endif
+}
+
+/* Some qdisc dump_stat() methods might need to run while qdisc lock is held.
+ * They can call gnet_dump_force_lock() in case qdisc_stats_lock()
+ * returned NULL and qdisc spinlock was not acquired.
+ */
+static inline void gnet_dump_force_lock(struct Qdisc *sch, struct gnet_dump *d)
+{
+	if (!d->lock) {
+		d->lock = qdisc_root_sleeping_lock(sch);
+		spin_lock_bh(d->lock);
+	}
+}
+
 static inline struct net_device *qdisc_dev(const struct Qdisc *qdisc)
 {
 	return qdisc->dev_queue->dev;
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index f96ee8b9478d..c5469d0377c8 100644
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
 
@@ -328,8 +330,9 @@ gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
 	return 0;
 
 err_out:
+	if (d->lock)
+		spin_unlock_bh(d->lock);
 	d->xstats_len = 0;
-	spin_unlock_bh(d->lock);
 	return -1;
 }
 EXPORT_SYMBOL(gnet_stats_copy_app);
@@ -363,10 +366,11 @@ gnet_stats_finish_copy(struct gnet_dump *d)
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
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 64f71a2155f3..466fe32f2862 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1365,7 +1365,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 		goto nla_put_failure;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTATS,
-					 qdisc_root_sleeping_lock(q), &d,
+					 qdisc_stats_lock(q), &d,
 					 TCA_PAD) < 0)
 		goto nla_put_failure;
 
@@ -1680,7 +1680,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 		goto nla_put_failure;
 
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTATS,
-					 qdisc_root_sleeping_lock(q), &d,
+					 qdisc_stats_lock(q), &d,
 					 TCA_PAD) < 0)
 		goto nla_put_failure;
 
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 6883a8971562..9e887df9650b 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -566,6 +566,7 @@ static int fq_codel_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 	st.qdisc_stats.memory_usage  = q->memory_usage;
 	st.qdisc_stats.drop_overmemory = q->drop_overmemory;
 
+	gnet_dump_force_lock(sch, d);
 	list_for_each(pos, &q->new_flows)
 		st.qdisc_stats.new_flows_len++;
 
@@ -624,7 +625,7 @@ static int fq_codel_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 	if (idx < q->flows_cnt) {
 		const struct fq_codel_flow *flow = &q->flows[idx];
-		const struct sk_buff *skb = flow->head;
+		const struct sk_buff *skb;
 
 		memset(&xstats, 0, sizeof(xstats));
 		xstats.type = TCA_FQ_CODEL_XSTATS_CLASS;
@@ -642,9 +643,13 @@ static int fq_codel_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 				codel_time_to_us(delta) :
 				-codel_time_to_us(-delta);
 		}
-		while (skb) {
-			qs.qlen++;
-			skb = skb->next;
+		if (flow->head) {
+			gnet_dump_force_lock(sch, d);
+			skb = flow->head;
+			while (skb) {
+				qs.qlen++;
+				skb = skb->next;
+			}
 		}
 		qs.backlog = q->backlogs[idx];
 		qs.drops = flow->dropped;
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index b8002ce3d010..15d0210f5747 100644
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
@@ -359,7 +360,8 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 			spin_unlock_bh(qdisc_lock(qdisc));
 		}
 		/* Reclaim root sleeping lock before completing stats */
-		spin_lock_bh(d->lock);
+		if (d->lock)
+			spin_lock_bh(d->lock);
 		if (gnet_stats_copy_basic(d, NULL, &bstats) < 0 ||
 		    gnet_stats_copy_queue(d, NULL, &qstats, qlen) < 0)
 			return -1;
