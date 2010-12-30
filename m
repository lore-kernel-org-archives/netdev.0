From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] sfq: fix slot_dequeue_head()
Date: Thu, 30 Dec 2010 16:02:48 +0100
Message-ID: <1293721368.7150.307.camel@edumazet-laptop>
References: <1292998499.4317.13.camel@edumazet-laptop>
	 <20101222073211.GA7001@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:53129 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753908Ab0L3PC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 10:02:58 -0500
Received: by wwi17 with SMTP id 17so11380982wwi.1
        for <netdev@vger.kernel.org>; Thu, 30 Dec 2010 07:02:57 -0800 (PST)
In-Reply-To: <20101222073211.GA7001@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 07:32 +0000, Jarek Poplawski a=
 =C3=A9crit :
> > Also, slot_dequeue_tail() should make sure slot skb chain is correc=
tly
> > terminated, or sfq_dump_class_stats() can access freed skbs.
>=20
> ...and a good hint for code reusing ;-)

Yes, and of course same fix is needed in slot_dequeue_head(), as furthe=
r
testing on my side made it pretty clear.

I was adding possibility to have more packets queued in SFQ (more
packets than max number of flows) and got unexpected crashes.

Reverting to net-next-2.6, I still got crashes. Oops.

[PATCH net-next-2.6] sfq: fix slot_dequeue_head()

slot_dequeue_head() should make sure slot skb chain is correct in both
ways, or we can crash if all possible flows are in use.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_sfq.c |    1 +
 1 files changed, 1 insertion(+)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 6a2f88f..3977e56 100644
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


