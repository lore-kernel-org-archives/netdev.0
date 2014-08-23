From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: use ktime_get_ns() and ktime_get_real_ns()
 helpers
Date: Fri, 22 Aug 2014 18:32:09 -0700
Message-ID: <1408757529.5604.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:54215 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbaHWBcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 21:32:12 -0400
Received: by mail-pa0-f50.google.com with SMTP id et14so17491012pad.23
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 18:32:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ktime_get_ns() replaces ktime_to_ns(ktime_get())

ktime_get_real_ns() replaces ktime_to_ns(ktime_get_real())

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/codel.h                     |    2 +-
 include/net/pkt_sched.h                 |    2 +-
 net/core/secure_seq.c                   |    6 +++---
 net/netfilter/nf_conntrack_core.c       |    2 +-
 net/netfilter/nf_conntrack_netlink.c    |    2 +-
 net/netfilter/nf_conntrack_standalone.c |    2 +-
 net/sched/act_police.c                  |    4 ++--
 net/sched/sch_fq.c                      |    4 ++--
 net/sched/sch_htb.c                     |    6 +++---
 net/sched/sch_tbf.c                     |    6 +++---
 10 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/net/codel.h b/include/net/codel.h
index fe0eab32ce76..aeee28081245 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -66,7 +66,7 @@ typedef s32 codel_tdiff_t;
 
 static inline codel_time_t codel_get_time(void)
 {
-	u64 ns = ktime_to_ns(ktime_get());
+	u64 ns = ktime_get_ns();
 
 	return ns >> CODEL_SHIFT;
 }
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index ec030cd76616..8bbe626e9ece 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -50,7 +50,7 @@ typedef long	psched_tdiff_t;
 
 static inline psched_time_t psched_get_time(void)
 {
-	return PSCHED_NS2TICKS(ktime_to_ns(ktime_get()));
+	return PSCHED_NS2TICKS(ktime_get_ns());
 }
 
 static inline psched_tdiff_t
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index ba71212f0251..51dd3193a33e 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -35,7 +35,7 @@ static u32 seq_scale(u32 seq)
 	 *	overlaps less than one time per MSL (2 minutes).
 	 *	Choosing a clock of 64 ns period is OK. (period of 274 s)
 	 */
-	return seq + (ktime_to_ns(ktime_get_real()) >> 6);
+	return seq + (ktime_get_real_ns() >> 6);
 }
 #endif
 
@@ -135,7 +135,7 @@ u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 	md5_transform(hash, net_secret);
 
 	seq = hash[0] | (((u64)hash[1]) << 32);
-	seq += ktime_to_ns(ktime_get_real());
+	seq += ktime_get_real_ns();
 	seq &= (1ull << 48) - 1;
 
 	return seq;
@@ -163,7 +163,7 @@ u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
 	md5_transform(hash, secret);
 
 	seq = hash[0] | (((u64)hash[1]) << 32);
-	seq += ktime_to_ns(ktime_get_real());
+	seq += ktime_get_real_ns();
 	seq &= (1ull << 48) - 1;
 
 	return seq;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index de88c4ab5146..0b634e7f1652 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -358,7 +358,7 @@ bool nf_ct_delete(struct nf_conn *ct, u32 portid, int report)
 
 	tstamp = nf_conn_tstamp_find(ct);
 	if (tstamp && tstamp->stop == 0)
-		tstamp->stop = ktime_to_ns(ktime_get_real());
+		tstamp->stop = ktime_get_real_ns();
 
 	if (nf_ct_is_dying(ct))
 		goto delete;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 355a5c4ef763..1bd9ed9e62f6 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1737,7 +1737,7 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 	}
 	tstamp = nf_conn_tstamp_find(ct);
 	if (tstamp)
-		tstamp->start = ktime_to_ns(ktime_get_real());
+		tstamp->start = ktime_get_real_ns();
 
 	err = nf_conntrack_hash_check_insert(ct);
 	if (err < 0)
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index f641751dba9d..cf65a1e040dd 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -101,7 +101,7 @@ static void *ct_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct ct_iter_state *st = seq->private;
 
-	st->time_now = ktime_to_ns(ktime_get_real());
+	st->time_now = ktime_get_real_ns();
 	rcu_read_lock();
 	return ct_get_idx(seq, *pos);
 }
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 0566e4606a4a..f32bcb094915 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -231,7 +231,7 @@ override:
 	if (ret != ACT_P_CREATED)
 		return ret;
 
-	police->tcfp_t_c = ktime_to_ns(ktime_get());
+	police->tcfp_t_c = ktime_get_ns();
 	police->tcf_index = parm->index ? parm->index :
 		tcf_hash_new_index(hinfo);
 	h = tcf_hash(police->tcf_index, POL_TAB_MASK);
@@ -279,7 +279,7 @@ static int tcf_act_police(struct sk_buff *skb, const struct tc_action *a,
 			return police->tcfp_result;
 		}
 
-		now = ktime_to_ns(ktime_get());
+		now = ktime_get_ns();
 		toks = min_t(s64, now - police->tcfp_t_c,
 			     police->tcfp_burst);
 		if (police->peak_present) {
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index ba32c2b005d0..e12f997e1b4c 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -416,7 +416,7 @@ static void fq_check_throttled(struct fq_sched_data *q, u64 now)
 static struct sk_buff *fq_dequeue(struct Qdisc *sch)
 {
 	struct fq_sched_data *q = qdisc_priv(sch);
-	u64 now = ktime_to_ns(ktime_get());
+	u64 now = ktime_get_ns();
 	struct fq_flow_head *head;
 	struct sk_buff *skb;
 	struct fq_flow *f;
@@ -787,7 +787,7 @@ nla_put_failure:
 static int fq_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
 {
 	struct fq_sched_data *q = qdisc_priv(sch);
-	u64 now = ktime_to_ns(ktime_get());
+	u64 now = ktime_get_ns();
 	struct tc_fq_qd_stats st = {
 		.gc_flows		= q->stat_gc_flows,
 		.highprio_packets	= q->stat_internal_packets,
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 9f949abcacef..aea942ce6008 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -895,7 +895,7 @@ ok:
 
 	if (!sch->q.qlen)
 		goto fin;
-	q->now = ktime_to_ns(ktime_get());
+	q->now = ktime_get_ns();
 	start_at = jiffies;
 
 	next_event = q->now + 5LLU * NSEC_PER_SEC;
@@ -1225,7 +1225,7 @@ static void htb_parent_to_leaf(struct htb_sched *q, struct htb_class *cl,
 	parent->un.leaf.q = new_q ? new_q : &noop_qdisc;
 	parent->tokens = parent->buffer;
 	parent->ctokens = parent->cbuffer;
-	parent->t_c = ktime_to_ns(ktime_get());
+	parent->t_c = ktime_get_ns();
 	parent->cmode = HTB_CAN_SEND;
 }
 
@@ -1455,7 +1455,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		cl->tokens = PSCHED_TICKS2NS(hopt->buffer);
 		cl->ctokens = PSCHED_TICKS2NS(hopt->cbuffer);
 		cl->mbuffer = 60ULL * NSEC_PER_SEC;	/* 1min */
-		cl->t_c = ktime_to_ns(ktime_get());
+		cl->t_c = ktime_get_ns();
 		cl->cmode = HTB_CAN_SEND;
 
 		/* attach to the hash list and parent's family */
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 18ff63433709..0c39b754083b 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -239,7 +239,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 		s64 ptoks = 0;
 		unsigned int len = qdisc_pkt_len(skb);
 
-		now = ktime_to_ns(ktime_get());
+		now = ktime_get_ns();
 		toks = min_t(s64, now - q->t_c, q->buffer);
 
 		if (tbf_peak_present(q)) {
@@ -292,7 +292,7 @@ static void tbf_reset(struct Qdisc *sch)
 
 	qdisc_reset(q->qdisc);
 	sch->q.qlen = 0;
-	q->t_c = ktime_to_ns(ktime_get());
+	q->t_c = ktime_get_ns();
 	q->tokens = q->buffer;
 	q->ptokens = q->mtu;
 	qdisc_watchdog_cancel(&q->watchdog);
@@ -431,7 +431,7 @@ static int tbf_init(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	q->t_c = ktime_to_ns(ktime_get());
+	q->t_c = ktime_get_ns();
 	qdisc_watchdog_init(&q->watchdog, sch);
 	q->qdisc = &noop_qdisc;
 
