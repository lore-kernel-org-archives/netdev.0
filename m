From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2] pkt_sched: fq: fix pacing for small frames
Date: Fri, 15 Nov 2013 08:58:14 -0800
Message-ID: <1384534694.28716.77.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:48583 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab3KOQ6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 11:58:17 -0500
Received: by mail-pb0-f50.google.com with SMTP id xb12so3793981pbc.37
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 08:58:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

=46or performance reasons, sch_fq tried hard to not setup timers for ev=
ery
sent packet, using a quantum based heuristic : A delay is setup only if
the flow exhausted its credit.

Problem is that application limited flows can refill their credit
for every queued packet, and they can evade pacing.

This problem can also be triggered when TCP flows use small MSS values,
as TSO auto sizing builds packets that are smaller than the default fq
quantum (3028 bytes)=20

This patch adds a 40 ms delay to guard flow credit refill.

=46ixes: afe4fd062416 ("pkt_sched: fq: Fair Queue packet scheduler")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 include/uapi/linux/pkt_sched.h |    3 +++
 net/sched/sch_fq.c             |   22 ++++++++++++++++++----
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sc=
hed.h
index 885001b62c83..a806687ad98f 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -768,6 +768,9 @@ enum {
 	TCA_FQ_FLOW_MAX_RATE,	/* per flow max rate */
=20
 	TCA_FQ_BUCKETS_LOG,	/* log2(number of buckets) */
+
+	TCA_FQ_FLOW_REFILL_DELAY,	/* flow credit refill delay in usec */
+
 	__TCA_FQ_MAX
 };
=20
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 26906ab51c52..95d843961907 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -88,6 +88,7 @@ struct fq_sched_data {
 	struct fq_flow	internal;	/* for non classified or high prio packets *=
/
 	u32		quantum;
 	u32		initial_quantum;
+	u32		flow_refill_delay;
 	u32		flow_max_rate;	/* optional max rate per flow */
 	u32		flow_plimit;	/* max packets per flow */
 	struct rb_root	*fq_root;
@@ -114,6 +115,7 @@ static struct fq_flow detached, throttled;
 static void fq_flow_set_detached(struct fq_flow *f)
 {
 	f->next =3D &detached;
+	f->age =3D jiffies;
 }
=20
 static bool fq_flow_is_detached(const struct fq_flow *f)
@@ -366,17 +368,20 @@ static int fq_enqueue(struct sk_buff *skb, struct=
 Qdisc *sch)
 	}
=20
 	f->qlen++;
-	flow_queue_add(f, skb);
 	if (skb_is_retransmit(skb))
 		q->stat_tcp_retrans++;
 	sch->qstats.backlog +=3D qdisc_pkt_len(skb);
 	if (fq_flow_is_detached(f)) {
 		fq_flow_add_tail(&q->new_flows, f);
-		if (q->quantum > f->credit)
-			f->credit =3D q->quantum;
+		if (time_after(jiffies, f->age + q->flow_refill_delay))
+			f->credit =3D max_t(u32, f->credit, q->quantum);
 		q->inactive_flows--;
 		qdisc_unthrottled(sch);
 	}
+
+	/* Note: this overwrites f->age */
+	flow_queue_add(f, skb);
+
 	if (unlikely(f =3D=3D &q->internal)) {
 		q->stat_internal_packets++;
 		qdisc_unthrottled(sch);
@@ -454,7 +459,6 @@ begin:
 			fq_flow_add_tail(&q->old_flows, f);
 		} else {
 			fq_flow_set_detached(f);
-			f->age =3D jiffies;
 			q->inactive_flows++;
 		}
 		goto begin;
@@ -608,6 +612,7 @@ static const struct nla_policy fq_policy[TCA_FQ_MAX=
 + 1] =3D {
 	[TCA_FQ_FLOW_DEFAULT_RATE]	=3D { .type =3D NLA_U32 },
 	[TCA_FQ_FLOW_MAX_RATE]		=3D { .type =3D NLA_U32 },
 	[TCA_FQ_BUCKETS_LOG]		=3D { .type =3D NLA_U32 },
+	[TCA_FQ_FLOW_REFILL_DELAY]	=3D { .type =3D NLA_U32 },
 };
=20
 static int fq_change(struct Qdisc *sch, struct nlattr *opt)
@@ -664,6 +669,12 @@ static int fq_change(struct Qdisc *sch, struct nla=
ttr *opt)
 			err =3D -EINVAL;
 	}
=20
+	if (tb[TCA_FQ_FLOW_REFILL_DELAY]) {
+		u32 usecs_delay =3D nla_get_u32(tb[TCA_FQ_FLOW_REFILL_DELAY]) ;
+
+		q->flow_refill_delay =3D usecs_to_jiffies(usecs_delay);
+	}
+
 	if (!err)
 		err =3D fq_resize(q, fq_log);
=20
@@ -699,6 +710,7 @@ static int fq_init(struct Qdisc *sch, struct nlattr=
 *opt)
 	q->flow_plimit		=3D 100;
 	q->quantum		=3D 2 * psched_mtu(qdisc_dev(sch));
 	q->initial_quantum	=3D 10 * psched_mtu(qdisc_dev(sch));
+	q->flow_refill_delay	=3D msecs_to_jiffies(40);
 	q->flow_max_rate	=3D ~0U;
 	q->rate_enable		=3D 1;
 	q->new_flows.first	=3D NULL;
@@ -733,6 +745,8 @@ static int fq_dump(struct Qdisc *sch, struct sk_buf=
f *skb)
 	    nla_put_u32(skb, TCA_FQ_INITIAL_QUANTUM, q->initial_quantum) ||
 	    nla_put_u32(skb, TCA_FQ_RATE_ENABLE, q->rate_enable) ||
 	    nla_put_u32(skb, TCA_FQ_FLOW_MAX_RATE, q->flow_max_rate) ||
+	    nla_put_u32(skb, TCA_FQ_FLOW_REFILL_DELAY,
+			jiffies_to_usecs(q->flow_refill_delay)) ||
 	    nla_put_u32(skb, TCA_FQ_BUCKETS_LOG, q->fq_trees_log))
 		goto nla_put_failure;
=20
