From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: Implement read-only protection and COW'ing of
 metrics.
Date: Thu, 16 Dec 2010 20:55:59 +0100
Message-ID: <1292529359.2655.2.camel@edumazet-laptop>
References: <20101215.132113.189700977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f171.google.com ([209.85.215.171]:44036 "EHLO
	mail-ey0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895Ab0LPT4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 14:56:05 -0500
Received: by eyg5 with SMTP id 5so2250116eyg.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 11:56:03 -0800 (PST)
In-Reply-To: <20101215.132113.189700977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 13:21 -0800, David Miller a =C3=
=A9crit :
> Routing metrics are now copy-on-write.
>=20
> Initially a route entry points it's metrics at a read-only location.
> If a routing table entry exists, it will point there.  Else it will
> point at the all zero metric place- holder 'dst_default_metrics'.
>=20
> The writeability state of the metrics is stored in the low bits of th=
e
> metrics pointer, we have two bits left to spare if we want to store
> more states.
>=20
> For the initial implementation, COW is implemented simply via kmalloc=
=2E
> However future enhancements will change this to place the writable
> metrics somewhere else, in order to increase sharing.  Very likely
> this "somewhere else" will be the inetpeer cache.
>=20
> Note also that this means that metrics updates may transiently fail
> if we cannot COW the metrics successfully.
>=20
> But even by itself, this patch should decrease memory usage and
> increase cache locality especially for routing workloads.  In those
> cases the read-only metric copies stay in place and never get written
> to.
>=20
> TCP workloads where metrics get updated, and those rare cases where
> PMTU triggers occur, will take a very slight performance hit.  But
> that hit will be alleviated when the long-term writable metrics
> move to a more sharable location.
>=20
> Since the metrics storage went from a u32 array of RTAX_MAX entries t=
o
> what is essentially a pointer, some retooling of the dst_entry layout
> was necessary.
>=20
> Most importantly, we need to preserve the alignment of the reference
> count so that it doesn't share cache lines with the read-mostly state=
,
> as per Eric Dumazet's alignment assertion checks.
>=20
> The only non-trivial bit here is the move of the 'flags' member into
> the writeable cacheline.  This is OK since we are always accessing th=
e
> flags around the same moment when we made a modification to the
> reference count.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Hi David

> =20
>=20
> @@ -1840,7 +1843,7 @@ static void rt_set_nexthop(struct rtable *rt, s=
truct fib_result *res, u32 itag)
>  		if (FIB_RES_GW(*res) &&
>  		    FIB_RES_NH(*res).nh_scope =3D=3D RT_SCOPE_LINK)
>  			rt->rt_gateway =3D FIB_RES_GW(*res);
> -		dst_import_metrics(dst, fi->fib_metrics);
> +		dst_attach_metrics(dst, fi->fib_metrics, true);

I am a bit concerned about this part.

What prevents fi->fib_metrics to disappear,  if fib is destroyed, since
we dont take a reference ?



