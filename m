From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] net_sched: sch_sfq: fix allot handling
Date: Wed, 15 Dec 2010 17:40:56 +0100
Message-ID: <1292431256.3427.358.camel@edumazet-laptop>
References: <1292421783.3427.232.camel@edumazet-laptop>
	 <4D08E6C2.804@trash.net>  <1292430424.3427.350.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35064 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210Ab0LOQlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 11:41:01 -0500
Received: by wyb28 with SMTP id 28so1641062wyb.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 08:41:00 -0800 (PST)
In-Reply-To: <1292430424.3427.350.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 17:27 +0100, Eric Dumazet a =C3=
=A9crit :

> Hmm, you may be right, thanks a lot for reviewing !
>=20
> I noticed that with normal quantum (1514), my SFQ setup was sending t=
wo
> full frames per flow after my patch, so was about to prepare a new
> version ;)
>=20
> I'll post a v2 shortly.

Indeed, the missing init in sfq_enqueue() is enough to solve the
problem :=20

[PATCH v2] net_sched: sch_sfq: fix allot handling

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
respected.

class sfq 11:2e4 parent 11:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 4p requeues 0=20
 allot -1166=20

class sfq 11:2f7 parent 11:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 3p requeues 0=20
 allot -1166=20

class sfq 11:313 parent 11:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 3p requeues 0=20
 allot -1220=20

class sfq 11:335 parent 11:=20
 (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 4p requeues 0=20
 allot -1166=20


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_sfq.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 3cf478d..065a2a5 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -321,14 +321,13 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sc=
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


