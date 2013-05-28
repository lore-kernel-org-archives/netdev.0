From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH net-next 2/3] ipv4: rate limit updating of next hop
 exceptions with same pmtu
Date: Tue, 28 May 2013 13:07:57 +0300
Message-ID: <20130528130757.4bf59c6b@vostro>
References: <20130527.233844.2081972819091665848.davem@davemloft.net>
	<1369723593-5307-1-git-send-email-timo.teras@iki.fi>
	<1369723593-5307-2-git-send-email-timo.teras@iki.fi>
	<alpine.LFD.2.00.1305281127340.1693@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:39675 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689Ab3E1KGR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 06:06:17 -0400
Received: by mail-ea0-f174.google.com with SMTP id z7so4314666eaf.19
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 03:06:15 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1305281127340.1693@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 May 2013 11:45:51 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> On Tue, 28 May 2013, Timo Ter=C3=A4s wrote:
>=20
> > The tunnel devices call update_pmtu for each packet sent, this
> > causes contention on the fnhe_lock. Ignore the pmtu update if pmtu
> > is not actually changed, and there is still plenty of time before
> > the entry expires.
> >=20
> > Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> > ---
> >  net/ipv4/route.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> >=20
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 561a378..a4082be 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -947,6 +947,10 @@ static void __ip_rt_update_pmtu(struct rtable
> > *rt, struct flowi4 *fl4, u32 mtu) if (mtu < ip_rt_min_pmtu)
> >  		mtu =3D ip_rt_min_pmtu;
> > =20
> > +	if (rt->rt_pmtu =3D=3D mtu &&
> > +	    time_before(jiffies, dst->expires -
> > ip_rt_mtu_expires / 2))
> > +		return;
> > +
>=20
> 	Can we also add logic in this patch in
> update_or_create_fnhe, so that we avoid invalidation for cached
> routes when only pmtu expiration is updated (same pmtu), i.e.:
>=20
> +	if (gw || pmtu !=3D fnhe->fnhe_pmtu) {
> +		/* Exception created; mark the cached routes for the
> nexthop
> +		...
> +	}
>=20
> 	BTW, I now see that previous patch should
> call for_each_possible_cpu for the both cases, not
> only when fnhe is created but also on update:

Why would this be needed?

The idea is that if there is no next hop exception, everyone is using
the next hop's dsts. If there is a next hop exception hashed, they will
be using those routes in the exception entry.

When the exception is created, we need to invalidate the nexthop's
routes, to force relookup of these dst's if should go to the exception.
Basically it flushes the nexthop's 'default' dst.

But if we have a valid exception, and we are just updating it. Everyone
is already using the right dst. The update_or_create_fnhe() updates all
exception's dst's that are effected. Since the set of hosts to which
that exception applies is the same, I don't see why we would need to
invalidate the nexthop's 'default' dst.

- Timo
