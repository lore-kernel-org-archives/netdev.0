From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pkt_sched: fq: change classification of control packets
Date: Thu, 14 Nov 2013 08:50:43 -0800
Message-ID: <1384447843.28716.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35177 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755788Ab3KNQuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 11:50:46 -0500
Received: by mail-pa0-f48.google.com with SMTP id bj1so2297645pad.7
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 08:50:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Initial sch_fq implementation copied code from pfifo_fast to classify
a packet as a high prio packet.

This clashes with setups using PRIO with say 7 bands, as one of the
band could be incorrectly (mis)classified by FQ.

Packets would be queued in the 'internal' queue, and no pacing ever
happen for this special queue.

=46ixes: afe4fd062416 ("pkt_sched: fq: Fair Queue packet scheduler")
Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/sched/sch_fq.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index fdc041c..d4fa38e 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -209,21 +209,15 @@ static void fq_gc(struct fq_sched_data *q,
 	}
 }
=20
-static const u8 prio2band[TC_PRIO_MAX + 1] =3D {
-	1, 2, 2, 2, 1, 2, 0, 0 , 1, 1, 1, 1, 1, 1, 1, 1
-};
-
 static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sche=
d_data *q)
 {
 	struct rb_node **p, *parent;
 	struct sock *sk =3D skb->sk;
 	struct rb_root *root;
 	struct fq_flow *f;
-	int band;
=20
 	/* warning: no starvation prevention... */
-	band =3D prio2band[skb->priority & TC_PRIO_MAX];
-	if (unlikely(band =3D=3D 0))
+	if (unlikely((skb->priority & TC_PRIO_MAX) =3D=3D TC_PRIO_CONTROL))
 		return &q->internal;
=20
 	if (unlikely(!sk)) {
