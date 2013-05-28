From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH net-next 1/3] ipv4: properly refresh rtable entries on
 pmtu/redirect events
Date: Tue, 28 May 2013 11:53:57 +0300
Message-ID: <20130528115357.4d9d281e@vostro>
References: <20130527.233844.2081972819091665848.davem@davemloft.net>
	<1369723593-5307-1-git-send-email-timo.teras@iki.fi>
	<alpine.LFD.2.00.1305281117190.1693@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:48701 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933619Ab3E1IwR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 04:52:17 -0400
Received: by mail-ea0-f172.google.com with SMTP id d10so4555842eaj.31
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 01:52:15 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1305281117190.1693@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 May 2013 11:25:55 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

>=20
> 	Hello,
>=20
> On Tue, 28 May 2013, Timo Ter=C3=A4s wrote:
>=20
> > This reverts commit 05ab86c5 (xfrm4: Invalidate all ipv4 routes on
> > IPsec pmtu events). Flushing all cached entries is not needed.
> >=20
> > Instead, invalidate only the related next hop dsts to recheck for
> > the added next hop exception where needed. This also fixes a subtle
> > race due to bumping generation id's before updating the pmtu.
> >=20
> > Cc: Steffen Klassert <steffen.klassert@secunet.com>
> > Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> > ---
>=20
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 550781a..561a378 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -594,11 +594,25 @@ static inline u32 fnhe_hashfun(__be32 daddr)
> >  	return hval & (FNHE_HASH_SIZE - 1);
> >  }
> > =20
> > +static void fill_route_from_fnhe(struct rtable *rt, struct
> > fib_nh_exception *fnhe) +{
> > +	rt->rt_pmtu =3D fnhe->fnhe_pmtu;
> > +	rt->dst.expires =3D fnhe->fnhe_expires;
>=20
> 	The 'if (time_before' ... dst_set_expires() logic from
> rt_bind_exception() is removed, may be it should be moved here,
> i.e. fnhe_pmtu should be ignored if expired.

That code would not help much. The route's rt_pmtu is never reset to
zero after the fnhe expires, so this would not make much difference.
The old rt_pmtu and dst.expires would be left there anyway. All rt
accesses check for expires too.

This was actually intentional on the old code, as non-zero rt_pmtu
implied that we had "next hop exception route" instead of "next hop
route" and affected how the rt was invalidated in pmtu update.

If we want to clear out these fields, then it would make sense to have
rt_bind_exception() to reset these on expiry to the struct
fib_nh_exception directly and keep the direct assignments in
fill_route_from_fnhe().

- Timo
