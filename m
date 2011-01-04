From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net_sched: mark packet staying on queue too long
Date: Tue, 04 Jan 2011 19:20:15 +0100
Message-ID: <1294165215.3579.133.camel@edumazet-laptop>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
	 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	 <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu>
	 <1294003631.2535.253.camel@edumazet-laptop>
	 <20110103095842.7677130d@nehalam>
	 <Pine.LNX.4.64.1101041506300.2576@ask.diku.dk>
	 <1294153329.3579.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, hadi@cyberus.ca,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48190 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab1ADSUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 13:20:21 -0500
Received: by wyb28 with SMTP id 28so14566566wyb.19
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 10:20:19 -0800 (PST)
In-Reply-To: <1294153329.3579.99.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 janvier 2011 =C3=A0 16:02 +0100, Eric Dumazet a =C3=A9crit =
:

> I'd like to try kind of a SFQRED implementation, ie :
>=20
> classify flows, then instead of using plain pfifo queues (currently d=
one
> in SFQ), use N pseudo RED queues.
>=20
> RED is a bit complex because it tries to make the probability estimat=
ion
> given queue backlog average. It has to use expensive time services (o=
n
> some machines at least, if TSC not available)
>=20
> My idea was to take into account the delay packets stay in its queue,=
 so
> that no extra state is needed : Only take a timestamp when packet is
> enqueued, compute delta when dequeued, get=20
>=20
> Px =3D delta * Prob_per_time_unit;
> and drop/mark packet with Px probability.
>=20
> Ram usage of SFQRED would be the same than SFQ, and cost roughly the
> same (because we could use jiffies based time sampling, (and HZ=3D100=
0 for
> a ms unit)).
>=20
>=20

Here is the POC patch I am currently testing, with a probability to
"early drop" a packet of one percent per ms (HZ=3D1000 here), only if
packet stayed at least 4 ms on queue.

Of course, this only apply where SFQ is used, with known SFQ limits :)

The term "early drop" is a lie. RED really early mark/drop a packet at
enqueue() time, while I do it at dequeue() time [since I need to comput=
e
the delay]. But effect is the same on sent packets. This might use a bi=
t
more memory, but no more than current SFQ [and only if flows dont react
to mark/drops]

insmod net/sched/sch_sfq.ko red_delay=3D4

By the way, I do think we should lower SFQ_DEPTH a bit and increase
SFQ_SLOTS by same amount. Allowing 127 packets per flow seems not
necessary in most situations SFQ might be used.

 net/sched/sch_sfq.c |   37 +++++++++++++++++++++++++++++++++----
 1 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index d54ac94..4f958e3 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -24,6 +24,8 @@
 #include <net/ip.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/inet_ecn.h>
+#include <linux/moduleparam.h>
=20
=20
 /*	Stochastic Fairness Queuing algorithm.
@@ -86,6 +88,10 @@
 /* This type should contain at least SFQ_DEPTH + SFQ_SLOTS values */
 typedef unsigned char sfq_index;
=20
+static int red_delay; /* default : no RED handling */
+module_param(red_delay, int, 0);
+MODULE_PARM_DESC(red_delay, "mark/drop packets if they stay in queue l=
onger than red_delay ticks");
+
 /*
  * We dont use pointers to save space.
  * Small indexes [0 ... SFQ_SLOTS - 1] are 'pointers' to slots[] array
@@ -391,6 +397,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
=20
 	sch->qstats.backlog +=3D qdisc_pkt_len(skb);
 	slot_queue_add(slot, skb);
+	qdisc_skb_cb(skb)->timestamp =3D jiffies;
 	sfq_inc(q, x);
 	if (slot->qlen =3D=3D 1) {		/* The flow is new */
 		if (q->tail =3D=3D NULL) {	/* It is the first flow */
@@ -402,11 +409,8 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch=
)
 		q->tail =3D slot;
 		slot->allot =3D q->scaled_quantum;
 	}
-	if (++sch->q.qlen <=3D q->limit) {
-		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
-		sch->bstats.packets++;
+	if (++sch->q.qlen <=3D q->limit)
 		return NET_XMIT_SUCCESS;
-	}
=20
 	sfq_drop(sch);
 	return NET_XMIT_CN;
@@ -432,6 +436,7 @@ sfq_dequeue(struct Qdisc *sch)
 	sfq_index a, next_a;
 	struct sfq_slot *slot;
=20
+restart:
 	/* No active slots */
 	if (q->tail =3D=3D NULL)
 		return NULL;
@@ -455,12 +460,36 @@ next_slot:
 		next_a =3D slot->next;
 		if (a =3D=3D next_a) {
 			q->tail =3D NULL; /* no more active slots */
+			/* last packet queued, dont even try to apply RED */
 			return skb;
 		}
 		q->tail->next =3D next_a;
 	} else {
 		slot->allot -=3D SFQ_ALLOT_SIZE(qdisc_pkt_len(skb));
 	}
+	if (red_delay) {
+		long delay =3D jiffies - qdisc_skb_cb(skb)->timestamp;
+
+		if (delay >=3D red_delay) {
+			long Px =3D delay * (0xFFFFFF / 100); /* 1 percent per jiffy */
+			if ((net_random() & 0xFFFFFF) < Px) {
+				if (INET_ECN_set_ce(skb)) {
+					/* no ecnmark counter yet :) */
+					sch->qstats.overlimits++;
+				} else {
+					/* penalize this flow : we drop the=20
+					 * packet while we changed slot->allot
+					 */
+					kfree_skb(skb);
+					/* no early_drop counter yet :) */
+					sch->qstats.drops++;
+					goto restart;
+				}
+			}
+		}
+	}
+	sch->bstats.bytes +=3D qdisc_pkt_len(skb);
+	sch->bstats.packets++;
 	return skb;
 }
=20


