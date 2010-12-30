From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] sfq: fix slot_dequeue_head()
Date: Thu, 30 Dec 2010 22:31:09 +0100
Message-ID: <1293744669.2973.12.camel@edumazet-laptop>
References: <1292998499.4317.13.camel@edumazet-laptop>
	 <20101222073211.GA7001@ff.dom.local>
	 <1293721368.7150.307.camel@edumazet-laptop>
	 <20101230174918.GA2018@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49445 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131Ab0L3VbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 16:31:15 -0500
Received: by wyb28 with SMTP id 28so11332100wyb.19
        for <netdev@vger.kernel.org>; Thu, 30 Dec 2010 13:31:13 -0800 (PST)
In-Reply-To: <20101230174918.GA2018@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 30 d=C3=A9cembre 2010 =C3=A0 18:49 +0100, Jarek Poplawski a =C3=
=A9crit :

> Nice scenario ;-) Of course, it's easy to guess I looked for somethin=
g
> like this after your previous fix and missed that :-| Btw, it looks
> like slot_queue_init() could go back to sfq_init() now.
>=20

Indeed, I tested following combined patch and all is good.

Thanks Jarek !

[PATCH v2 net-next-2.6] sfq: fix slot_dequeue_head()

slot_dequeue_head() should make sure slot skb chain is correct in both
ways, or we can crash if all possible flows are in use.

Jarek pointed out slot_queue_init() can now be done in sfq_init() once,
instead each time a flow is setup.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_sfq.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 6a2f88f..02fa1dd 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -292,6 +292,7 @@ static inline struct sk_buff *slot_dequeue_head(str=
uct sfq_slot *slot)
 	struct sk_buff *skb =3D slot->skblist_next;
=20
 	slot->skblist_next =3D skb->next;
+	skb->next->prev =3D (struct sk_buff *)slot;
 	skb->next =3D skb->prev =3D NULL;
 	return skb;
 }
@@ -375,7 +376,6 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		q->ht[hash] =3D x;
 		slot =3D &q->slots[x];
 		slot->hash =3D hash;
-		slot_queue_init(slot);
 	}
=20
 	/* If selected queue has length q->limit, do simple tail drop,
@@ -533,8 +533,10 @@ static int sfq_init(struct Qdisc *sch, struct nlat=
tr *opt)
 			return err;
 	}
=20
-	for (i =3D 0; i < SFQ_SLOTS; i++)
+	for (i =3D 0; i < SFQ_SLOTS; i++) {
+		slot_queue_init(&q->slots[i]);
 		sfq_link(q, i);
+	}
 	return 0;
 }
=20


