From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: Implement read-only protection and COW'ing of
 metrics.
Date: Thu, 27 Jan 2011 11:20:12 +0100
Message-ID: <1296123612.3027.15.camel@edumazet-laptop>
References: <20101215.132113.189700977.davem@davemloft.net>
	 <1292529359.2655.2.camel@edumazet-laptop>
	 <20101216.115900.183061857.davem@davemloft.net>
	 <20110126.152538.260074157.davem@davemloft.net>
	 <1296122511.3027.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38491 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846Ab1A0KUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 05:20:18 -0500
Received: by bwz15 with SMTP id 15so2046404bwz.19
        for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 02:20:16 -0800 (PST)
In-Reply-To: <1296122511.3027.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 27 janvier 2011 =C3=A0 11:01 +0100, Eric Dumazet a =C3=A9crit =
:
> Le mercredi 26 janvier 2011 =C3=A0 15:25 -0800, David Miller a =C3=A9=
crit :
> > Eric, thanks again for your feedback.  I've taken a stab at fixing =
the
> > various races, in particular the one you discovered about metrics
> > sharing and how this interacts with fib_info releases.
> >=20
> > What I've choosen to do is two-fold:
> >=20
> > 1) Update ->_metrics atomically with cmpxchg once a route becomes p=
ublicly
> >    visible.
> >=20
> > 2) Remember and grab a reference to the fib_info for shared read-on=
ly
> >    metrics in rt->fi, then release it once the metrics regerence go=
es
> >    away.
> >=20
> > It sounds expensive but hear me out :-)
> >=20
> > First of all, at rt_set_nexthop() time, the atomic we use to grab a
> > ref to the fib_info is replacing a 60-byte memcpy() into the dst
> > metrics.
> >=20
> > Next, the ->_metrics atomic to un-COW the metrics at destroy time
> > might in fact be overkill.  Especially once writable metrics live i=
n
> > the inetpeer cache (that's the next set of patches after this one).
> >=20
> > Finally, once this change is stabilized we can be a lot smarter abo=
ut
> > what we do at the time an entry is created.  For example, when a ro=
ute
> > is looked up for a TCP socket, we essentially know we are going to =
COW
> > the route %99.99999 of the time.  So we can pass a hint into TCP's
> > route lookups in the flow flags field telling it to pre-COW the rou=
te.
> >=20
> > TCP pre-COW'ing of metrics will thus save several atomics.
> >=20
> > Anyways, here is the patch, it is only build tested at this point, =
but
> > I wanted to get feedback from you about the basic gist of things
> > as soon as possible.
> >=20
> > Thanks!
> >=20
>=20
> Thanks David, I read this (I am a bit busy preparing my travel to
> Reunion/Maurice islands). This looks pretty nice. I have one comment =
:
>=20
> > =20
> > +u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long =
old)
> > +{
> > +	u32 *p =3D kmalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
> > +
> > +	if (p) {
> > +		u32 *old_p =3D __DST_METRICS_PTR(old);
> > +		unsigned long prev, new;
> > +
> > +		memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
> > +
> > +		new =3D (unsigned long) p;
> > +		prev =3D cmpxchg(&dst->_metrics, old, new);
> > +
> > +		if (prev !=3D old) {
> > +			kfree(p);
> > +			p =3D __DST_METRICS_PTR(prev);
> > +			if (prev & DST_METRICS_READ_ONLY)
> > +				p =3D NULL;
> > +		}
> > +	}
> > +	return p;
> > +}
> > +EXPORT_SYMBOL(dst_cow_metrics_generic);
> > +
> ...
>=20
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 3e5b7cc..7fc6301 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -152,6 +152,36 @@ static void ipv4_dst_ifdown(struct dst_entry *=
dst, struct net_device *dev,
> >  {
> >  }
> > =20
> > +static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long =
old)
> > +{
> > +	u32 *p =3D kmalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
> > +
> > +	if (p) {
> > +		u32 *old_p =3D __DST_METRICS_PTR(old);
> > +		unsigned long prev, new;
> > +
> > +		memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
> > +
> > +		new =3D (unsigned long) p;
> > +		prev =3D cmpxchg(&dst->_metrics, old, new);
> > +
> > +		if (prev !=3D old) {
> > +			kfree(p);
> > +			p =3D __DST_METRICS_PTR(prev);
> > +			if (prev & DST_METRICS_READ_ONLY)
> > +				p =3D NULL;
> > +		} else {
>=20
> Hmm, I first asked myself why you dont use dst_cow_metrics_generic() =
to
> perform the generic allocation, but saw following :
>=20
> > +			struct rtable *rt =3D (struct rtable *) dst;
> > +
>=20
> Since you use cmpxchg() to permut the dst->_metrics, I feel this rt->=
fi
> needs some protection as well. Maybe store fi pointer inside the metr=
ics
> instead of dst, or else you need a spinlock to perform the whole
> transaction (change dst->_metrics & rt->fi) ?
>=20
> > +			if (rt->fi) {
> > +				fib_info_put(rt->fi);
> > +				rt->fi =3D NULL;
> > +			}
> > +		}
> > +	}
> > +	return p;
> > +}
> > +
>=20


Hmm, reading again, I realize the rt->fi was set only when installing
the readonly metrics, so ignore my previous mail.

Thanks !


