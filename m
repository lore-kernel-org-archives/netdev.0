From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next-2.6] sch_sfq: allow big packets and be fair
Date: Tue, 21 Dec 2010 14:04:59 +0100
Message-ID: <1292936699.2720.23.camel@edumazet-laptop>
References: <20101221101506.GA8149@ff.dom.local>
	 <1292929037.2720.12.camel@edumazet-laptop>
	 <20101221113920.GB8813@ff.dom.local>  <20101221121706.GC8813@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45576 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776Ab0LUNFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 08:05:04 -0500
Received: by wyb28 with SMTP id 28so3920768wyb.19
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 05:05:03 -0800 (PST)
In-Reply-To: <20101221121706.GC8813@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 d=C3=A9cembre 2010 =C3=A0 12:17 +0000, Jarek Poplawski a =C3=
=A9crit :

> Oops! You're right yet ;-) This skipping shouldn't happen with quantu=
m
> bigger than max packet size, so this patch is OK.

Thanks Jarek, here is a v2 with the scale you suggested.

[PATCH v2 net-next-2.6] sch_sfq: allow big packets and be fair

SFQ is currently 'limited' to small packets, because it uses a 15bit
allotment number per flow. Introduce a scale by 8, so that we can handl=
e
full size TSO/GRO packets.

Use appropriate handling to make sure allot is positive before a new
packet is dequeued, so that fairness is respected.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jarek Poplawski <jarkao2@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
---
v2: Use a scale of 8 as Jarek suggested, instead of 18bit fields

 net/sched/sch_sfq.c |   28 +++++++++++++++++++++-------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index c474b4b..f3a9fd7 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -67,7 +67,7 @@
=20
 	IMPLEMENTATION:
 	This implementation limits maximal queue length to 128;
-	maximal mtu to 2^15-1; max 128 flows, number of hash buckets to 1024.
+	max mtu to 2^18-1; max 128 flows, number of hash buckets to 1024.
 	The only goal of this restrictions was that all data
 	fit into one 4K page on 32bit arches.
=20
@@ -77,6 +77,11 @@
 #define SFQ_SLOTS		128 /* max number of flows */
 #define SFQ_EMPTY_SLOT		255
 #define SFQ_HASH_DIVISOR	1024
+/* We use 15+1 bits to store allot, and want to handle packets up to 6=
4K
+ * Scale allot by 8 (1<<3) so that no overflow occurs.
+ */
+#define SFQ_ALLOT_SHIFT		3
+#define SFQ_ALLOT_SIZE(X)	DIV_ROUND_UP(X, 1 << SFQ_ALLOT_SHIFT)
=20
 /* This type should contain at least SFQ_DEPTH + SFQ_SLOTS values */
 typedef unsigned char sfq_index;
@@ -115,7 +120,7 @@ struct sfq_sched_data
 	struct timer_list perturb_timer;
 	u32		perturbation;
 	sfq_index	cur_depth;	/* depth of longest slot */
-
+	unsigned short  scaled_quantum; /* SFQ_ALLOT_SIZE(quantum) */
 	struct sfq_slot *tail;		/* current slot in round */
 	sfq_index	ht[SFQ_HASH_DIVISOR];	/* Hash table */
 	struct sfq_slot	slots[SFQ_SLOTS];
@@ -394,7 +399,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			q->tail->next =3D x;
 		}
 		q->tail =3D slot;
-		slot->allot =3D q->quantum;
+		slot->allot =3D q->scaled_quantum;
 	}
 	if (++sch->q.qlen <=3D q->limit) {
 		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
@@ -430,8 +435,14 @@ sfq_dequeue(struct Qdisc *sch)
 	if (q->tail =3D=3D NULL)
 		return NULL;
=20
+next_slot:
 	a =3D q->tail->next;
 	slot =3D &q->slots[a];
+	if (slot->allot <=3D 0) {
+		q->tail =3D slot;
+		slot->allot +=3D q->scaled_quantum;
+		goto next_slot;
+	}
 	skb =3D slot_dequeue_head(slot);
 	sfq_dec(q, a);
 	sch->q.qlen--;
@@ -446,9 +457,8 @@ sfq_dequeue(struct Qdisc *sch)
 			return skb;
 		}
 		q->tail->next =3D next_a;
-	} else if ((slot->allot -=3D qdisc_pkt_len(skb)) <=3D 0) {
-		q->tail =3D slot;
-		slot->allot +=3D q->quantum;
+	} else {
+		slot->allot -=3D SFQ_ALLOT_SIZE(qdisc_pkt_len(skb));
 	}
 	return skb;
 }
@@ -484,6 +494,7 @@ static int sfq_change(struct Qdisc *sch, struct nla=
ttr *opt)
=20
 	sch_tree_lock(sch);
 	q->quantum =3D ctl->quantum ? : psched_mtu(qdisc_dev(sch));
+	q->scaled_quantum =3D SFQ_ALLOT_SIZE(q->quantum);
 	q->perturb_period =3D ctl->perturb_period * HZ;
 	if (ctl->limit)
 		q->limit =3D min_t(u32, ctl->limit, SFQ_DEPTH - 1);
@@ -524,6 +535,7 @@ static int sfq_init(struct Qdisc *sch, struct nlatt=
r *opt)
 	q->tail =3D NULL;
 	if (opt =3D=3D NULL) {
 		q->quantum =3D psched_mtu(qdisc_dev(sch));
+		q->scaled_quantum =3D SFQ_ALLOT_SIZE(q->quantum);
 		q->perturb_period =3D 0;
 		q->perturbation =3D net_random();
 	} else {
@@ -610,7 +622,9 @@ static int sfq_dump_class_stats(struct Qdisc *sch, =
unsigned long cl,
 	struct sfq_sched_data *q =3D qdisc_priv(sch);
 	const struct sfq_slot *slot =3D &q->slots[q->ht[cl - 1]];
 	struct gnet_stats_queue qs =3D { .qlen =3D slot->qlen };
-	struct tc_sfq_xstats xstats =3D { .allot =3D slot->allot };
+	struct tc_sfq_xstats xstats =3D {
+		.allot =3D slot->allot << SFQ_ALLOT_SHIFT
+	};
 	struct sk_buff *skb;
=20
 	slot_queue_walk(slot, skb)


