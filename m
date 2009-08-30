From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] sched: Fix resource limiting in pfifo_fast
Date: Sun, 30 Aug 2009 13:52:09 +0530
Message-ID: <OF26BB78B8.E88DD15A-ON65257622.002D8788-65257622.002DF984@in.ibm.com>
References: <20090830062344.6380.16713.sendpatchset@localhost.localdomain> <4A9A223D.1060406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:48061 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbZH3IWR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:22:17 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7U8MHNm020123
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 13:52:17 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7U8MG8u2220154
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 13:52:16 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7U8MGa6016437
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 18:22:16 +1000
In-Reply-To: <4A9A223D.1060406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had thought of this reason before submitting. But I felt that if we a=
re
filling up the qdisc due to some problem at driver/device, then the iss=
ue
should be handled at a different level (increase tx_queue_len, let
packets drop and TCP handle it, etc).

So I am not sure if it is intentionally designed this way, or whether i=
t
needs fixing to reflect a maximum limit.

Thanks,

- KK

> Eric Dumazet <eric.dumazet@gmail.com>
> Re: [RFC PATCH] sched: Fix resource limiting in pfifo_fast
>
> Krishna Kumar a =E9crit :
> > From: Krishna Kumar <krkumar2@in.ibm.com>
> >
> > pfifo_fast_enqueue has this check:
> >         if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
> >
> > which allows each band to enqueue upto tx_queue_len skbs for a
> > total of 3*tx_queue_len skbs. I am not sure if this was the
> > intention of limiting in qdisc.
>
> Yes I noticed that and said to myself :
> This was to let high priority packets have their own limit,
> independent on fact that low priority packets filled their queue.
>
> >
> > Patch compiled and 32 simultaneous netperf testing ran fine. Also:
> > # tc -s qdisc show dev eth2
> > qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1=
 1 1
1
> >  Sent 16835026752 bytes 373116 pkt (dropped 0, overlimits 0 requeue=
s
25)
> >  rate 0bit 0pps backlog 0b 0p requeues 25
> >
> > (I am taking next week off, so sorry for any delay in responding)
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > ---
> >
> >  net/sched/sch_generic.c |    8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> >
> > diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
> > --- org/net/sched/sch_generic.c   2009-08-30 11:18:23.000000000 +05=
30
> > +++ new/net/sched/sch_generic.c   2009-08-30 11:21:50.000000000 +05=
30
> > @@ -432,11 +432,11 @@ static inline struct sk_buff_head *band2
> >
> >  static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc*
qdisc)
> >  {
> > -   int band =3D prio2band[skb->priority & TC_PRIO_MAX];
> > -   struct pfifo_fast_priv *priv =3D qdisc_priv(qdisc);
> > -   struct sk_buff_head *list =3D band2list(priv, band);
> > +   if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) =
{
> > +      int band =3D prio2band[skb->priority & TC_PRIO_MAX];
> > +      struct pfifo_fast_priv *priv =3D qdisc_priv(qdisc);
> > +      struct sk_buff_head *list =3D band2list(priv, band);
> >
> > -   if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
> >        priv->bitmap |=3D (1 << band);
> >        qdisc->q.qlen++;
> >        return __qdisc_enqueue_tail(skb, qdisc, list);
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

