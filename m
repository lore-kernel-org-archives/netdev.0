From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ECN + pfifo_fast borked? (Was Re: [Bloat] shaper team forming
 up)
Date: Tue, 15 Mar 2011 07:15:49 +0100
Message-ID: <1300169749.2649.142.camel@edumazet-laptop>
References: <87wrk1a4gx.fsf@cruithne.co.teklibre.org>
	 <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com>
	 <1300134277.2649.19.camel@edumazet-laptop>
	 <1300164166.2649.70.camel@edumazet-laptop>
	 <87ipvlosvz.fsf_-_@cruithne.co.teklibre.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jonathan Morton <chromatix99@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Dave =?ISO-8859-1?Q?T=E4ht?= <d@taht.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40821 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909Ab1COGPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 02:15:53 -0400
Received: by fxm17 with SMTP id 17so245780fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 23:15:52 -0700 (PDT)
In-Reply-To: <87ipvlosvz.fsf_-_@cruithne.co.teklibre.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 23:27 -0600, Dave T=C3=A4ht a =C3=A9crit :

> Well, that makes 3 of us that think it's wrong. Can we get more?=20
>=20
> (I'll run through the math again in the morning)
>=20
> It's most often not actually "enablement" but "assertion", when for
> example an ECN bit is put on an ACK packet (by an application, or qdi=
sc)
> , it drops that ACK packet into the 2 queue - leaving all the other
> non-ECN asserted packets in that flow to flow out ahead of it.
>=20

There are two ECN bits, not one.
The low order bit is not taken into account by skb->priority mapping.
The high order bit cannot be changed during flow lifetime.
(So : no OOO (Out Of Order) problems on say TCP flows)

> Or so dan siemon & I & now you, think. It's late and I really want to=
 recheck
> the math and the shifts in the morning. However, if true... this woul=
d
> explain much ECN related weirdness precisely where it has been hard t=
o
> measure, on heavily loaded systems.
>=20
> >
> > Thanks
> >
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 6ed6603..fabfe81 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -171,7 +171,7 @@ static struct dst_ops ipv4_dst_ops =3D {
> > =20
> >  const __u8 ip_tos2prio[16] =3D {
> >  	TC_PRIO_BESTEFFORT,
> > -	ECN_OR_COST(FILLER),
> > +	ECN_OR_COST(BESTEFFORT),
> >  	TC_PRIO_BESTEFFORT,
> >  	ECN_OR_COST(BESTEFFORT),
> >  	TC_PRIO_BULK,
> >
>=20
> I think this is a good short term fix, but it will mildly upset peopl=
e
> that actually still use minimum cost and don't use ECN. That said,=20
> RFC1349 has been obsolete for a decade now, and ECN enabled servers a=
re
> at 12% penetration according to MIT.
>=20

If minimum cost was asked by people, their packets had chance being
dropped. Why should they be upset ?
ECN should be favored anyway in 2011, now everybody is ready.

> Still, long term, doing a sch_pfifo_dscp that would be fully complian=
t
> with the relevant modern RFCs and eventually making that the standard
> would be good.
>=20

sch_pfifo_fast is not the place we perform the TOS -> priority mapping.

Its done in another layer.

That is of litle effect, given TOS values are meaningfull only inside a
domain. Nobody can force everyone to use same semantics on the Internet=
,
even with a standard RFC. I doubt people using linux machines at home
really need DSCP at all.

What we could do instead is to favor a bit ECN enabled connections,
using 4 bands instead of 3 for pfifo_fast (linux default qdisc, probabl=
y
the most used qdisc)

band 0 : high priority packets (like now)
band 1 : (old band 1, ECN capable flows)
band 2 : (old band 1, no ECN flows)
band 3 : low priority packets (old band 2)

Note : pfifo_fast is mostly used on end hosts, not on routers (where
admins setup non default qdiscs), and typical end hosts never experimen=
t
packet drops on their qdiscs, because they are now plugged to Gigabit
LANS, and device queuelength is so big.



