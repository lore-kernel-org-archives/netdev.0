From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] net: Fix behavior of unreachable, blackhole and prohibit
 routes
Date: Tue, 1 Sep 2015 10:53:20 -0700
Message-ID: <55E5E610.501@gmail.com>
References: <1441102392.3250.9.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: nforro@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35658 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbIARxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 13:53:22 -0400
Received: by pacfv12 with SMTP id fv12so2849238pac.2
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 10:53:21 -0700 (PDT)
In-Reply-To: <1441102392.3250.9.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2015 03:13 AM, Nikola Forr=C3=B3 wrote:
> Man page of ip-route(8) says the following about route types:
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
> In both address families all three route types now behave consistent
> with documentation.

Generally updating kernel code to match user-space documentation isn't=20
always the best way to go.  The question I would have is if there are=20
any other user-space applications out there that might be expecting thi=
s=20
behaviour now?

Also your changes don't seem to match up with what you have described.=20
You are returning the error code from fib_table_lookup, but=20
fib_table_lookup can return -EAGAIN if there is no matching entry found=
=2E=20
  I don't see you describing how you would deal with that case.  You=20
might try testing your code after deleting the default route to see wha=
t=20
behaviour it is you get.

> Signed-off-by: Nikola Forr=C3=B3 <nforro@redhat.com>
> ---
>   include/net/ip_fib.h | 19 ++++++++++++++-----
>   net/ipv4/route.c     |  6 ++++--
>   net/ipv6/route.c     |  4 +++-
>   3 files changed, 21 insertions(+), 8 deletions(-)
>
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 5fa643b..8d174a7 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -233,8 +233,8 @@ static inline int fib_lookup(struct net *net, con=
st struct flowi4 *flp,
>   	rcu_read_lock();
>
>   	tb =3D fib_get_table(net, RT_TABLE_MAIN);
> -	if (tb && !fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF)=
)
> -		err =3D 0;
> +	if (tb)
> +		err =3D fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF);
>
>   	rcu_read_unlock();
>
> @@ -267,11 +267,20 @@ static inline int fib_lookup(struct net *net, s=
truct flowi4 *flp,
>
>   	for (err =3D 0; !err; err =3D -ENETUNREACH) {
>   		tb =3D rcu_dereference_rtnl(net->ipv4.fib_main);
> -		if (tb && !fib_table_lookup(tb, flp, res, flags))
> -			break;
> +		if (tb) {
> +			err =3D fib_table_lookup(tb, flp, res, flags);
> +			if (!err)
> +				break;
> +		}
>
>   		tb =3D rcu_dereference_rtnl(net->ipv4.fib_default);
> -		if (tb && !fib_table_lookup(tb, flp, res, flags))
> +		if (tb) {
> +			err =3D fib_table_lookup(tb, flp, res, flags);
> +			if (!err)
> +				break;
> +		}
> +
> +		if (err)
>   			break;
>   	}
>

Without a default route set these functions are going to return -EAGAIN=
=20
when it should probably be returning -ENETUNREACH.

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
>
>   	res.tclassid	=3D 0;
>   	res.fi		=3D NULL;
> @@ -2123,7 +2124,8 @@ struct rtable *__ip_route_output_key(struct net=
 *net, struct flowi4 *fl4)
>   		goto make_route;
>   	}
>
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
>

This bit appears to overlook the fact that fib_rules_lookup could also=20
be the function used to return the error via a call to fib_lookup.  In=20
which case that also throws -ESRCH into the mix for return error codes.

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
>
