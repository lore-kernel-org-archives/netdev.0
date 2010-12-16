From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_sfq: add backlog info in
 sfq_dump_class_stats()
Date: Thu, 16 Dec 2010 12:03:04 +0100
Message-ID: <1292497384.2883.89.camel@edumazet-laptop>
References: <20101216081621.GA7338@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35053 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852Ab0LPLDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 06:03:10 -0500
Received: by wyb28 with SMTP id 28so2363852wyb.19
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 03:03:08 -0800 (PST)
In-Reply-To: <20101216081621.GA7338@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 08:16 +0000, Jarek Poplawski a =C3=
=A9crit :
> On 2010-12-15 19:18, Eric Dumazet wrote:
> > We currently return for each active SFQ slot the number of packets =
in
> > queue. We can also give number of bytes accounted for these packets=
=2E
> >=20
> > tc -s class show dev ifb0
> >=20
> > Before patch :
> >=20
> > class sfq 11:3d9 parent 11:=20
> >  (dropped 0, overlimits 0 requeues 0)=20
> >  backlog 0b 3p requeues 0=20
> >  allot 1266=20
> >=20
> > After patch :
> >=20
> > class sfq 11:3e4 parent 11:=20
> >  (dropped 0, overlimits 0 requeues 0)=20
> >  backlog 4380b 3p requeues 0=20
> >  allot 1212=20
> >=20
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  net/sched/sch_sfq.c |    7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> > index 3cf478d..cb331de 100644
> > --- a/net/sched/sch_sfq.c
> > +++ b/net/sched/sch_sfq.c
> > @@ -548,8 +548,13 @@ static int sfq_dump_class_stats(struct Qdisc *=
sch, unsigned long cl,
> >  {
> >  	struct sfq_sched_data *q =3D qdisc_priv(sch);
> >  	sfq_index idx =3D q->ht[cl-1];
> > -	struct gnet_stats_queue qs =3D { .qlen =3D q->qs[idx].qlen };
> > +	struct sk_buff_head *list =3D &q->qs[idx];
> > +	struct gnet_stats_queue qs =3D { .qlen =3D list->qlen };
> >  	struct tc_sfq_xstats xstats =3D { .allot =3D q->allot[idx] };
> > +	struct sk_buff *skb;
> > +
> > +	skb_queue_walk(list, skb)
> > +		qs.backlog +=3D qdisc_pkt_len(skb);
>=20
> I don't think you can walk this list without the qdisc lock.

So after checks, I confirm qdisc lock is held at this point, patch is
valid.

tc_fill_tclass() calls gnet_stats_start_copy_compat() (and locks
qdisc_root_sleeping_lock()), before calling=20
 cl_ops->dump_stats(q, cl, &d)

Thanks !


