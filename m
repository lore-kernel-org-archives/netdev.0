From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next-2.6] sch_sfq: allow big packets and be fair
Date: Wed, 29 Dec 2010 08:53:33 +0100
Message-ID: <1293609213.2691.3.camel@edumazet-laptop>
References: <20101221113920.GB8813@ff.dom.local>
	 <20101221121706.GC8813@ff.dom.local>
	 <1292936699.2720.23.camel@edumazet-laptop>
	 <20101228.134655.112609314.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37034 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787Ab0L2Hxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 02:53:40 -0500
Received: by wwa36 with SMTP id 36so10467562wwa.1
        for <netdev@vger.kernel.org>; Tue, 28 Dec 2010 23:53:38 -0800 (PST)
In-Reply-To: <20101228.134655.112609314.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 d=C3=A9cembre 2010 =C3=A0 13:46 -0800, David Miller a =C3=A9=
crit :
> Eric this doesn't apply cleanly, since the code in sfq_dump_class_sta=
ts()
> is a bit different in net-next-2.6
>=20
> Please respin this and resubmit.

Sure, here is the version for latest net-next

Thanks

[PATCH v3 net-next-2.6] sch_sfq: allow big packets and be fair

SFQ is currently 'limited' to small packets, because it uses a 15bit
allotment number per flow. Introduce a scale by 8, so that we can handl=
e
full size TSO/GRO packets.

Use appropriate handling to make sure allot is positive before a new
packet is dequeued, so that fairness is respected.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
---
v3: respin after commit ee09b3c1cf (fix sfq class stats handling)
v2: Use a scale of 8 as Jarek suggested, instead of 18bit fields

 net/sched/sch_sfq.c |   26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 0ce421d..79c8967 100644
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
+/* We use 16 bits to store allot, and want to handle packets up to 64K
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
@@ -395,7 +400,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			q->tail->next =3D x;
 		}
 		q->tail =3D slot;
-		slot->allot =3D q->quantum;
+		slot->allot =3D q->scaled_quantum;
 	}
 	if (++sch->q.qlen <=3D q->limit) {
 		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
@@ -431,8 +436,14 @@ sfq_dequeue(struct Qdisc *sch)
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
@@ -447,9 +458,8 @@ sfq_dequeue(struct Qdisc *sch)
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
@@ -485,6 +495,7 @@ static int sfq_change(struct Qdisc *sch, struct nla=
ttr *opt)
=20
 	sch_tree_lock(sch);
 	q->quantum =3D ctl->quantum ? : psched_mtu(qdisc_dev(sch));
+	q->scaled_quantum =3D SFQ_ALLOT_SIZE(q->quantum);
 	q->perturb_period =3D ctl->perturb_period * HZ;
 	if (ctl->limit)
 		q->limit =3D min_t(u32, ctl->limit, SFQ_DEPTH - 1);
@@ -525,6 +536,7 @@ static int sfq_init(struct Qdisc *sch, struct nlatt=
r *opt)
 	q->tail =3D NULL;
 	if (opt =3D=3D NULL) {
 		q->quantum =3D psched_mtu(qdisc_dev(sch));
+		q->scaled_quantum =3D SFQ_ALLOT_SIZE(q->quantum);
 		q->perturb_period =3D 0;
 		q->perturbation =3D net_random();
 	} else {
@@ -617,7 +629,7 @@ static int sfq_dump_class_stats(struct Qdisc *sch, =
unsigned long cl,
 	if (idx !=3D SFQ_EMPTY_SLOT) {
 		const struct sfq_slot *slot =3D &q->slots[idx];
=20
-		xstats.allot =3D slot->allot;
+		xstats.allot =3D slot->allot << SFQ_ALLOT_SHIFT;
 		qs.qlen =3D slot->qlen;
 		slot_queue_walk(slot, skb)
 			qs.backlog +=3D qdisc_pkt_len(skb);


