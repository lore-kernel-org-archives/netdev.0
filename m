From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] ipv6: force RTF_NONEXTHOP for SIT device
Date: Thu, 13 Sep 2012 04:59:53 +0200
Message-ID: <1347505193.13103.1340.camel@edumazet-glaptop>
References: <1347451266.13103.882.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Lorenzo Colitti <lorenzo@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34025 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749Ab2IMC76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 22:59:58 -0400
Received: by wgbdr13 with SMTP id dr13so2071958wgb.1
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 19:59:57 -0700 (PDT)
In-Reply-To: <1347451266.13103.882.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-12 at 14:01 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> We have special handling of SIT devices in addrconf_prefix_route()
> to avoid using a neighbour for each destination.
>=20
> If routing entry is :
>=20
> ip -6 route add 2001:db8::/64 dev sit1
>=20
> Then the kernel will create a new route for every new address
> under 2001:db8::/64 that we send a packet to (potentially, 2^64
> routes).
>=20
> Under load, we immediately get the infamous "Neighbour table overflow=
"
> message and machine eventually crash.
>=20
> This does not happen if we specify a next-hop explicitly, like so:
>=20
> ip -6 route add 2001:db8::/64 via fe80:: dev sit1
>=20
> We can avoid this hassle doing the SIT test in ip6_route_add() instea=
d
> of addrconf_prefix_route().
>=20
> This permits ip6_pol_route() to clone route instead of calling
> rt6_alloc_cow() and allocate a neighbour
>=20
> Reported-by: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---
>  net/ipv6/addrconf.c |   10 ----------
>  net/ipv6/route.c    |    9 +++++++++
>  2 files changed, 9 insertions(+), 10 deletions(-)
>=20
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 1237d5d..c6837d2 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1679,16 +1679,6 @@ addrconf_prefix_route(struct in6_addr *pfx, in=
t plen, struct net_device *dev,
>  	};
> =20
>  	cfg.fc_dst =3D *pfx;
> -
> -	/* Prevent useless cloning on PtP SIT.
> -	   This thing is done here expecting that the whole
> -	   class of non-broadcast devices need not cloning.
> -	 */
> -#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
> -	if (dev->type =3D=3D ARPHRD_SIT && (dev->flags & IFF_POINTOPOINT))
> -		cfg.fc_flags |=3D RTF_NONEXTHOP;
> -#endif
> -
>  	ip6_route_add(&cfg);
>  }
> =20
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 399613b..d4ba3fc 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1540,6 +1540,15 @@ int ip6_route_add(struct fib6_config *cfg)
>  	} else
>  		rt->rt6i_prefsrc.plen =3D 0;
> =20
> +	/* Prevent useless cloning on PtP SIT.
> +	 *  This thing is done here expecting that the whole
> +	 *  class of non-broadcast devices need not cloning.
> +	 */
> +#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
> +	if (dev && dev->type =3D=3D ARPHRD_SIT && (dev->flags & IFF_POINTOP=
OINT))
> +		cfg->fc_flags |=3D RTF_NONEXTHOP;
> +#endif
> +
>  	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
>  		err =3D rt6_bind_neighbour(rt, dev);
>  		if (err)
>=20

Please hold this patch, I'll send a v2, based on excellent feedback fro=
m
Lorenzo.

Idea is to just do :

	if (dev->flags & (IFF_POINTOPOINT | IFF_LOOPBACK))
		cfg->fc_flags |=3D RFT_NONEXTHOP;

(no mention of SIT anymore, and a change in the title patch)
