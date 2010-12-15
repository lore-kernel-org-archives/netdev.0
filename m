From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3] net_sched: sch_sfq: fix allot handling
Date: Wed, 15 Dec 2010 18:30:27 +0100
Message-ID: <1292434227.3427.377.camel@edumazet-laptop>
References: <1292421783.3427.232.camel@edumazet-laptop>
	 <4D08E6C2.804@trash.net>  <1292430424.3427.350.camel@edumazet-laptop>
	 <1292431256.3427.358.camel@edumazet-laptop>  <4D08F025.5030603@trash.net>
	 <1292432120.3427.366.camel@edumazet-laptop>  <4D08F4F4.3050501@trash.net>
	 <1292432980.3427.369.camel@edumazet-laptop>  <4D08F91C.4070000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48333 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869Ab0LORac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 12:30:32 -0500
Received: by wyb28 with SMTP id 28so1686719wyb.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 09:30:31 -0800 (PST)
In-Reply-To: <4D08F91C.4070000@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 18:21 +0100, Patrick McHardy a=
 =C3=A9crit :
> On 15.12.2010 18:09, Eric Dumazet wrote:
> > Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 18:03 +0100, Patrick McHar=
dy a =C3=A9crit :
> >=20
> >> Right, that's odd. It shouldn't be necessary anymore though since
> >> now we initialize allot in sfq_enqueue() for all new flows and
> >> increase allotment for all active flows once per round in sfq_dequ=
eue().
> >> The above code causes a second increase for the flow following a f=
low
> >> which went inactive.
> >=20
> > Well, we do this in three places. Each time we 'select' a flow as t=
he
> > next packet provider, we increase its allot by quantum.
> >=20
> > We could change this, adding quantum to the current slot when its a=
llot
> > becomes negative (and we select the next slot for next round)
>=20
> Right, I again missed that 'a' refers to the next flow in the second
> condition in sfq_dequeue().
>=20
> I have to run now, will have another look at this tommorrow.

Here is v3 : Now we add a quantum only when current flow consumed all
its allot, not "in advance for next slot". this should use less cpu too=
=2E

Thanks

[PATCH v3] net_sched: sch_sfq: fix allot handling

When deploying SFQ/IFB here at work, I found the allot management was
pretty wrong in sfq, even changing allot from short to int...

We should init allot for each new flow, not using a previous value foun=
d
in slot.

Before patch, I saw bursts of several packets per flow, apparently
denying the default "quantum 1514" limit I had on my SFQ class.

class sfq 11:1 parent 11:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 7p requeues 0=20
 allot 11546=20

class sfq 11:46 parent 11:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 1p requeues 0=20
 allot -23873=20

class sfq 11:78 parent 11:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 5p requeues 0=20
 allot 11393=20

After patch, better fairness among each flow, allot limit being
respected, allot is positive :

class sfq 11:e parent 11:=20
 (dropped 0, overlimits 0 requeues 86)=20
 backlog 0b 3p requeues 86=20
 allot 596=20

class sfq 11:94 parent 11:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 3p requeues 0=20
 allot 1468=20

class sfq 11:a4 parent 11:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 4p requeues 0=20
 allot 650=20

class sfq 11:bb parent 11:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 3p requeues 0=20
 allot 596=20

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_sfq.c |   20 ++++++++------------
 1 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 3cf478d..7150705 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -270,7 +270,6 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		/* It is difficult to believe, but ALL THE SLOTS HAVE LENGTH 1. */
 		d =3D q->next[q->tail];
 		q->next[q->tail] =3D q->next[d];
-		q->allot[q->next[d]] +=3D q->quantum;
 		skb =3D q->qs[d].prev;
 		len =3D qdisc_pkt_len(skb);
 		__skb_unlink(skb, &q->qs[d]);
@@ -321,14 +320,13 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sc=
h)
 	sfq_inc(q, x);
 	if (q->qs[x].qlen =3D=3D 1) {		/* The flow is new */
 		if (q->tail =3D=3D SFQ_DEPTH) {	/* It is the first flow */
-			q->tail =3D x;
 			q->next[x] =3D x;
-			q->allot[x] =3D q->quantum;
 		} else {
 			q->next[x] =3D q->next[q->tail];
 			q->next[q->tail] =3D x;
-			q->tail =3D x;
 		}
+		q->tail =3D x;
+		q->allot[x] =3D q->quantum;
 	}
 	if (++sch->q.qlen <=3D q->limit) {
 		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
@@ -359,13 +357,13 @@ sfq_dequeue(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q =3D qdisc_priv(sch);
 	struct sk_buff *skb;
-	sfq_index a, old_a;
+	sfq_index a, next_a;
=20
 	/* No active slots */
 	if (q->tail =3D=3D SFQ_DEPTH)
 		return NULL;
=20
-	a =3D old_a =3D q->next[q->tail];
+	a =3D q->next[q->tail];
=20
 	/* Grab packet */
 	skb =3D __skb_dequeue(&q->qs[a]);
@@ -376,17 +374,15 @@ sfq_dequeue(struct Qdisc *sch)
 	/* Is the slot empty? */
 	if (q->qs[a].qlen =3D=3D 0) {
 		q->ht[q->hash[a]] =3D SFQ_DEPTH;
-		a =3D q->next[a];
-		if (a =3D=3D old_a) {
+		next_a =3D q->next[a];
+		if (a =3D=3D next_a) {
 			q->tail =3D SFQ_DEPTH;
 			return skb;
 		}
-		q->next[q->tail] =3D a;
-		q->allot[a] +=3D q->quantum;
+		q->next[q->tail] =3D next_a;
 	} else if ((q->allot[a] -=3D qdisc_pkt_len(skb)) <=3D 0) {
-		q->tail =3D a;
-		a =3D q->next[a];
 		q->allot[a] +=3D q->quantum;
+		q->tail =3D a;
 	}
 	return skb;
 }


