From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BQL + Basic Latency under load results - 100Mbit, GSO/TSO off,
 pfifo_fast vs SFQ vs QFQ
Date: Mon, 02 Jan 2012 05:33:31 +0100
Message-ID: <1325478811.2526.10.camel@edumazet-laptop>
References: <CAA93jw6r45zBn4p76R9-2UNdp=OM+uiYqPKcKnjqBReR_oh1BA@mail.gmail.com>
	 <CAA93jw5JjVBQOFL=td55rOpXbUYc=uT_rjeY04O137g_-tBJHw@mail.gmail.com>
	 <CAA93jw7bLnHtVnZGN5wVPQZc46XT_B--cY1ocUbnm1AS=J_YHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jg@freedesktop.org, Stephen Hemminger <shemminger@vyatta.com>,
	Juliusz Chroboczek <jch@pps.jussieu.fr>,
	Kathleen Nichols <nichols@pollere.com>,
	netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64450 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab2ABEdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2012 23:33:37 -0500
Received: by wgbdr13 with SMTP id dr13so26233696wgb.1
        for <netdev@vger.kernel.org>; Sun, 01 Jan 2012 20:33:36 -0800 (PST)
In-Reply-To: <CAA93jw7bLnHtVnZGN5wVPQZc46XT_B--cY1ocUbnm1AS=J_YHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 janvier 2012 =C3=A0 00:17 +0100, Dave Taht a =C3=A9crit :
> QFQ wins even bigger vs SFQ at 50 iperfs
>=20
> http://www.teklibre.com/~d/bloat/pfifo_sfq_vs_qfq_linear50.png
>=20
> And I think it's going to win even bigger at 10 Mbit.
>=20

Happy new year !

This makes no sense to me for such a low amount of flows, SFQ should
perform the same than QFQ :)

You dont find out why it is so.



Please try following patch :

[PATCH net-next] sch_sfq: dont put new flow at the end of flows

SFQ enqueue algo puts a new flow _behind_ all pre-existing flows in the
circular list. In fact this is probably an old SFQ implementation bug.

100 Mbits =3D ~8333 full frames per second, or ~8 frames per ms.

With 50 flows, it means your "new flow" will have to wait 50 packets
being sent before its own packet. Thats the ~6ms.

We certainly can change SFQ to give a priority advantage to new flows,
so that next dequeued packet is taken from a new flow, not an old one.

Reported-by: Dave Taht <dave.taht@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index c23b957..f7f62a5 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -366,11 +366,11 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sc=
h)
 	if (slot->qlen =3D=3D 1) {		/* The flow is new */
 		if (q->tail =3D=3D NULL) {	/* It is the first flow */
 			slot->next =3D x;
+			q->tail =3D slot;
 		} else {
 			slot->next =3D q->tail->next;
 			q->tail->next =3D x;
 		}
-		q->tail =3D slot;
 		slot->allot =3D q->scaled_quantum;
 	}
 	if (++sch->q.qlen <=3D q->limit)
