From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3] net: Fix behaviour of unreachable, blackhole and
 prohibit routes
Date: Thu, 3 Sep 2015 08:14:53 -0700
Message-ID: <55E863ED.90903@gmail.com>
References: <1441274722.3360.59.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: nforro@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34774 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756798AbbICPOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 11:14:55 -0400
Received: by padfa1 with SMTP id fa1so7196884pad.1
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2015 08:14:55 -0700 (PDT)
In-Reply-To: <1441274722.3360.59.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2015 03:05 AM, Nikola Forr=C3=B3 wrote:
> Man page of ip-route(8) says following about route types:
>
>    unreachable - these destinations are unreachable.  Packets are dis=
=E2=80=90
>    carded and the ICMP message host unreachable is generated.  The lo=
cal
>    senders get an EHOSTUNREACH error.
>
>    blackhole - these destinations are unreachable.  Packets are dis=E2=
=80=90
>    carded silently.  The local senders get an EINVAL error.
>
>    prohibit - these destinations are unreachable.  Packets are discar=
ded
>    and the ICMP message communication administratively prohibited is
>    generated.  The local senders get an EACCES error.
>
> In the inet6 address family, this was correct, except the local sende=
rs
> got ENETUNREACH error instead of EHOSTUNREACH in case of unreachable =
route.
> In the inet address family, all three route types generated ICMP mess=
age
> net unreachable, and the local senders got ENETUNREACH error.
>
> In both address families all three route types now behave consistentl=
y
> with documentation.
>
> Signed-off-by: Nikola Forr=C3=B3 <nforro@redhat.com>
> ---
>   include/net/ip_fib.h | 22 +++++++++++++++++-----
>   net/ipv4/route.c     |  6 ++++--
>   net/ipv6/route.c     |  4 +++-
>   3 files changed, 24 insertions(+), 8 deletions(-)
>
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 5fa643b..8e7b3e1 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -233,8 +233,11 @@ static inline int fib_lookup(struct net *net, co=
nst struct flowi4 *flp,
>   	rcu_read_lock();
>  =20
>   	tb =3D fib_get_table(net, RT_TABLE_MAIN);
> -	if (tb && !fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF)=
)
> -		err =3D 0;
> +	if (tb) {
> +		err =3D fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF);
> +		if (err =3D=3D -EAGAIN)
> +			err =3D -ENETUNREACH;
> +	}
>  =20
>   	rcu_read_unlock();
>  =20

The likelihood of tb being NULL is next to 0%.  You would probably be=20
better off pulling out the EAGAIN check from the if statement and just=20
placing it before the rcu_read_unlock with the correct indentation.

> @@ -267,11 +270,20 @@ static inline int fib_lookup(struct net *net, s=
truct flowi4 *flp,
>  =20
>   	for (err =3D 0; !err; err =3D -ENETUNREACH) {
>   		tb =3D rcu_dereference_rtnl(net->ipv4.fib_main);
> -		if (tb && !fib_table_lookup(tb, flp, res, flags))
> -			break;
> +		if (tb) {
> +			err =3D fib_table_lookup(tb, flp, res, flags);
> +			if (!err)
> +				break;
> +		}
>  =20
>   		tb =3D rcu_dereference_rtnl(net->ipv4.fib_default);
> -		if (tb && !fib_table_lookup(tb, flp, res, flags))
> +		if (tb) {
> +			err =3D fib_table_lookup(tb, flp, res, flags);
> +			if (!err)
> +				break;
> +		}
> +
> +		if (err && err !=3D -EAGAIN)
>   			break;
>   	}
>  =20

The loop stuff can just be dropped.  This code is now getting a bit too=
=20
tangled up to justify it.  Probably just use some goto labels instead. =
=20
I would probably just initialize err to -ENETUNREACH and drop the check=
=20
for err at the end and just handle the -EAGAIN case.

I would also probably just pull the -EAGAIN check and place it at the=20
end before the unlock and after whatever label it is you add. No point=20
in optimizing for unlikely cases.

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index e681b85..4ce3f87 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2020,6 +2020,7 @@ struct rtable *__ip_route_output_key(struct net=
 *net, struct flowi4 *fl4)
>   	struct fib_result res;
>   	struct rtable *rth;
>   	int orig_oif;
> +	int err =3D ENETUNREACH;
>  =20
>   	res.tclassid	=3D 0;
>   	res.fi		=3D NULL;
> @@ -2123,7 +2124,8 @@ struct rtable *__ip_route_output_key(struct net=
 *net, struct flowi4 *fl4)
>   		goto make_route;
>   	}
>  =20
> -	if (fib_lookup(net, fl4, &res, 0)) {
> +	err =3D fib_lookup(net, fl4, &res, 0);
> +	if (err) {
>   		res.fi =3D NULL;
>   		res.table =3D NULL;
>   		if (fl4->flowi4_oif) {
> @@ -2151,7 +2153,7 @@ struct rtable *__ip_route_output_key(struct net=
 *net, struct flowi4 *fl4)
>   			res.type =3D RTN_UNICAST;
>   			goto make_route;
>   		}
> -		rth =3D ERR_PTR(-ENETUNREACH);
> +		rth =3D ERR_PTR(err);
>   		goto out;
>   	}
>  =20
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index d155864..d33a6a5 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1847,9 +1847,11 @@ int ip6_route_add(struct fib6_config *cfg)
>   			rt->dst.input =3D ip6_pkt_prohibit;
>   			break;
>   		case RTN_THROW:
> +		case RTN_UNREACHABLE:
>   		default:
>   			rt->dst.error =3D (cfg->fc_type =3D=3D RTN_THROW) ? -EAGAIN
> -					: -ENETUNREACH;
> +					: (cfg->fc_type =3D=3D RTN_UNREACHABLE)
> +					? -EHOSTUNREACH : -ENETUNREACH;
>   			rt->dst.output =3D ip6_pkt_discard_out;
>   			rt->dst.input =3D ip6_pkt_discard;
>   			break;
