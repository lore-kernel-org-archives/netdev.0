From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pkt_sched: fq: fix pacing for small frames
Date: Thu, 14 Nov 2013 10:58:16 -0800
Message-ID: <1384455496.28716.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384447843.28716.15.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from mail-yh0-f52.google.com ([209.85.213.52]:35211 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754344Ab3KNS6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 13:58:20 -0500
Received: by mail-yh0-f52.google.com with SMTP id i57so1257517yha.11
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 10:58:19 -0800 (PST)
In-Reply-To: <1384447843.28716.15.camel@edumazet-glaptop2.roam.corp.google.com>
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

We'll send a patch adding ability to tune this threshold for linux-3.14=
,
but this value should be good enough for most workloads.

=46ixes: afe4fd062416 ("pkt_sched: fq: Fair Queue packet scheduler")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/sched/sch_fq.c |   28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index fdc041c57853..46a0cacd7280 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -88,7 +88,7 @@ struct fq_sched_data {
 	struct fq_flow	internal;	/* for non classified or high prio packets *=
/
 	u32		quantum;
 	u32		initial_quantum;
-	u32		flow_default_rate;/* rate per flow : bytes per second */
+	u32		flow_refill_delay;
 	u32		flow_max_rate;	/* optional max rate per flow */
 	u32		flow_plimit;	/* max packets per flow */
 	struct rb_root	*fq_root;
@@ -115,6 +115,7 @@ static struct fq_flow detached, throttled;
 static void fq_flow_set_detached(struct fq_flow *f)
 {
 	f->next =3D &detached;
+	f->age =3D jiffies;
 }
=20
 static bool fq_flow_is_detached(const struct fq_flow *f)
@@ -160,8 +161,12 @@ static void fq_flow_add_tail(struct fq_flow_head *=
head, struct fq_flow *flow)
 }
=20
 /* limit number of collected flows per round */
-#define FQ_GC_MAX 8
-#define FQ_GC_AGE (3*HZ)
+#define FQ_GC_MAX		8
+
+#define FQ_GC_AGE		(3*HZ)
+
+/* Flow credit is refilled after 40ms idle time */
+#define FQ_REFILL_DELAY		msecs_to_jiffies(40)
=20
 static bool fq_gc_candidate(const struct fq_flow *f)
 {
@@ -373,17 +378,22 @@ static int fq_enqueue(struct sk_buff *skb, struct=
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
+
+		if (time_after(jiffies, f->age + q->flow_refill_delay))
+			f->credit =3D max_t(u32, f->credit, q->quantum);
+
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
@@ -461,7 +471,6 @@ begin:
 			fq_flow_add_tail(&q->old_flows, f);
 		} else {
 			fq_flow_set_detached(f);
-			f->age =3D jiffies;
 			q->inactive_flows++;
 		}
 		goto begin;
@@ -655,9 +664,6 @@ static int fq_change(struct Qdisc *sch, struct nlat=
tr *opt)
 	if (tb[TCA_FQ_INITIAL_QUANTUM])
 		q->initial_quantum =3D nla_get_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
=20
-	if (tb[TCA_FQ_FLOW_DEFAULT_RATE])
-		q->flow_default_rate =3D nla_get_u32(tb[TCA_FQ_FLOW_DEFAULT_RATE]);
-
 	if (tb[TCA_FQ_FLOW_MAX_RATE])
 		q->flow_max_rate =3D nla_get_u32(tb[TCA_FQ_FLOW_MAX_RATE]);
=20
@@ -705,7 +711,7 @@ static int fq_init(struct Qdisc *sch, struct nlattr=
 *opt)
 	q->flow_plimit		=3D 100;
 	q->quantum		=3D 2 * psched_mtu(qdisc_dev(sch));
 	q->initial_quantum	=3D 10 * psched_mtu(qdisc_dev(sch));
-	q->flow_default_rate	=3D 0;
+	q->flow_refill_delay	=3D FQ_REFILL_DELAY;
 	q->flow_max_rate	=3D ~0U;
 	q->rate_enable		=3D 1;
 	q->new_flows.first	=3D NULL;
