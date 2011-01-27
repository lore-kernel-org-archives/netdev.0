From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: Implement read-only protection and COW'ing of
 metrics.
Date: Thu, 27 Jan 2011 11:01:51 +0100
Message-ID: <1296122511.3027.11.camel@edumazet-laptop>
References: <20101215.132113.189700977.davem@davemloft.net>
	 <1292529359.2655.2.camel@edumazet-laptop>
	 <20101216.115900.183061857.davem@davemloft.net>
	 <20110126.152538.260074157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40272 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab1A0KBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 05:01:55 -0500
Received: by mail-fx0-f46.google.com with SMTP id 20so1945397fxm.19
        for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 02:01:54 -0800 (PST)
In-Reply-To: <20110126.152538.260074157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 janvier 2011 =C3=A0 15:25 -0800, David Miller a =C3=A9cr=
it :
> Eric, thanks again for your feedback.  I've taken a stab at fixing th=
e
> various races, in particular the one you discovered about metrics
> sharing and how this interacts with fib_info releases.
>=20
> What I've choosen to do is two-fold:
>=20
> 1) Update ->_metrics atomically with cmpxchg once a route becomes pub=
licly
>    visible.
>=20
> 2) Remember and grab a reference to the fib_info for shared read-only
>    metrics in rt->fi, then release it once the metrics regerence goes
>    away.
>=20
> It sounds expensive but hear me out :-)
>=20
> First of all, at rt_set_nexthop() time, the atomic we use to grab a
> ref to the fib_info is replacing a 60-byte memcpy() into the dst
> metrics.
>=20
> Next, the ->_metrics atomic to un-COW the metrics at destroy time
> might in fact be overkill.  Especially once writable metrics live in
> the inetpeer cache (that's the next set of patches after this one).
>=20
> Finally, once this change is stabilized we can be a lot smarter about
> what we do at the time an entry is created.  For example, when a rout=
e
> is looked up for a TCP socket, we essentially know we are going to CO=
W
> the route %99.99999 of the time.  So we can pass a hint into TCP's
> route lookups in the flow flags field telling it to pre-COW the route=
=2E
>=20
> TCP pre-COW'ing of metrics will thus save several atomics.
>=20
> Anyways, here is the patch, it is only build tested at this point, bu=
t
> I wanted to get feedback from you about the basic gist of things
> as soon as possible.
>=20
> Thanks!
>=20

Thanks David, I read this (I am a bit busy preparing my travel to
Reunion/Maurice islands). This looks pretty nice. I have one comment :

> =20
> +u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long ol=
d)
> +{
> +	u32 *p =3D kmalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
> +
> +	if (p) {
> +		u32 *old_p =3D __DST_METRICS_PTR(old);
> +		unsigned long prev, new;
> +
> +		memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
> +
> +		new =3D (unsigned long) p;
> +		prev =3D cmpxchg(&dst->_metrics, old, new);
> +
> +		if (prev !=3D old) {
> +			kfree(p);
> +			p =3D __DST_METRICS_PTR(prev);
> +			if (prev & DST_METRICS_READ_ONLY)
> +				p =3D NULL;
> +		}
> +	}
> +	return p;
> +}
> +EXPORT_SYMBOL(dst_cow_metrics_generic);
> +
=2E..

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 3e5b7cc..7fc6301 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -152,6 +152,36 @@ static void ipv4_dst_ifdown(struct dst_entry *ds=
t, struct net_device *dev,
>  {
>  }
> =20
> +static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long ol=
d)
> +{
> +	u32 *p =3D kmalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
> +
> +	if (p) {
> +		u32 *old_p =3D __DST_METRICS_PTR(old);
> +		unsigned long prev, new;
> +
> +		memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
> +
> +		new =3D (unsigned long) p;
> +		prev =3D cmpxchg(&dst->_metrics, old, new);
> +
> +		if (prev !=3D old) {
> +			kfree(p);
> +			p =3D __DST_METRICS_PTR(prev);
> +			if (prev & DST_METRICS_READ_ONLY)
> +				p =3D NULL;
> +		} else {

Hmm, I first asked myself why you dont use dst_cow_metrics_generic() to
perform the generic allocation, but saw following :

> +			struct rtable *rt =3D (struct rtable *) dst;
> +

Since you use cmpxchg() to permut the dst->_metrics, I feel this rt->fi
needs some protection as well. Maybe store fi pointer inside the metric=
s
instead of dst, or else you need a spinlock to perform the whole
transaction (change dst->_metrics & rt->fi) ?

> +			if (rt->fi) {
> +				fib_info_put(rt->fi);
> +				rt->fi =3D NULL;
> +			}
> +		}
> +	}
> +	return p;
> +}
> +


