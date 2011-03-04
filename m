From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: seqlock optimization
Date: Sat, 05 Mar 2011 00:02:39 +0100
Message-ID: <1299279759.2758.60.camel@edumazet-laptop>
References: <20110304.111705.193726268.davem@davemloft.net>
	 <20110304.124534.71142427.davem@davemloft.net>
	 <1299276839.2758.50.camel@edumazet-laptop>
	 <20110304.144448.115945732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53972 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932774Ab1CDXCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 18:02:45 -0500
Received: by wwb22 with SMTP id 22so3300086wwb.1
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 15:02:44 -0800 (PST)
In-Reply-To: <20110304.144448.115945732.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 mars 2011 =C3=A0 14:44 -0800, David Miller a =C3=A9crit =
:

> Applied, thanks Eric!
>=20
> With this and the following patch applied to my no-routing-cache tree=
,
> output route lookup on my Niagara2 is down to 2966 cycles!  For refer=
ence
> with just the plain routing cache removal, it was as much as 3832 cyc=
les.
>=20
> udpflood is a lot faster too, with plain routing cache removal it ran=
 as:
>=20
> bash$ time ./bin/udpflood -l 10000000 10.2.2.11
> real		     3m9.921s
> user		     0m9.520s
> sys		     3m0.440s
>=20
> But now it's:
>=20
> bash$ time ./bin/udpflood -l 10000000 10.2.2.11
> real	2m45.903s
> user	0m8.640s
> sys	2m37.280s
>=20
> :-)
>=20

Nice indeed :)

> --------------------
> ipv4: Optimize flow initialization in output route lookup.
>=20
> We burn a lot of useless cycles, cpu store buffer traffic, and
> memory operations memset()'ing the on-stack flow used to perform
> output route lookups in __ip_route_output_key().
>=20
> Only the first half of the flow object members even matter for
> output route lookups in this context, specifically:
>=20
> FIB rules matching cares about:
>=20
> 	dst, src, tos, iif, oif, mark
>=20
> FIB trie lookup cares about:
>=20
> 	dst
>=20
> FIB semantic match cares about:
>=20
> 	tos, scope, oif
>=20
> Therefore only initialize these specific members and elide the
> memset entirely.
>=20
> On Niagara2 this kills about ~300 cycles from the output route
> lookup path.
>=20
> Likely, we can take things further, since all callers of output
> route lookups essentially throw away the on-stack flow they use.
> So they don't care if we use it as a scratch-pad to compute the
> final flow key.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/route.c |   18 ++++++++++--------
>  1 files changed, 10 insertions(+), 8 deletions(-)
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 04b8954..e3a5a89 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1670,14 +1670,7 @@ static struct rtable *__mkroute_output(const s=
truct fib_result *res,
>  struct rtable *__ip_route_output_key(struct net *net, const struct f=
lowi *oldflp)
>  {
>  	u32 tos	=3D RT_FL_TOS(oldflp);
> -	struct flowi fl =3D { .fl4_dst =3D oldflp->fl4_dst,
> -			    .fl4_src =3D oldflp->fl4_src,
> -			    .fl4_tos =3D tos & IPTOS_RT_MASK,
> -			    .fl4_scope =3D ((tos & RTO_ONLINK) ?
> -					  RT_SCOPE_LINK : RT_SCOPE_UNIVERSE),
> -			    .mark =3D oldflp->mark,
> -			    .iif =3D net->loopback_dev->ifindex,
> -			    .oif =3D oldflp->oif };
> +	struct flowi fl;
>  	struct fib_result res;
>  	unsigned int flags =3D 0;
>  	struct net_device *dev_out =3D NULL;
> @@ -1688,6 +1681,15 @@ struct rtable *__ip_route_output_key(struct ne=
t *net, const struct flowi *oldflp
>  	res.r		=3D NULL;
>  #endif
> =20
> +	fl.oif =3D oldflp->oif;
> +	fl.iif =3D net->loopback_dev->ifindex;
> +	fl.mark =3D oldflp->mark;
> +	fl.fl4_dst =3D oldflp->fl4_dst;
> +	fl.fl4_src =3D oldflp->fl4_src;
> +	fl.fl4_tos =3D tos & IPTOS_RT_MASK;
> +	fl.fl4_scope =3D ((tos & RTO_ONLINK) ?
> +			RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
> +
>  	rcu_read_lock();
>  	if (oldflp->fl4_src) {
>  		rth =3D ERR_PTR(-EINVAL);

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


