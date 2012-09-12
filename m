From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net-next 1/2] ipv6: force RTF_NONEXTHOP for SIT device
Date: Wed, 12 Sep 2012 13:53:13 -0700
Message-ID: <CANP3RGcpM+an8u5-cxz-VqKFFN0Oj4zsrcQ3YXz=a4_4J6XLzQ@mail.gmail.com>
References: <1347451266.13103.882.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Lorenzo Colitti <lorenzo@google.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:62078 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186Ab2ILUxO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 16:53:14 -0400
Received: by iahk25 with SMTP id k25so1622277iah.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 13:53:13 -0700 (PDT)
In-Reply-To: <1347451266.13103.882.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 12, 2012 at 5:01 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> We have special handling of SIT devices in addrconf_prefix_route()
> to avoid using a neighbour for each destination.
>
> If routing entry is :
>
> ip -6 route add 2001:db8::/64 dev sit1
>
> Then the kernel will create a new route for every new address
> under 2001:db8::/64 that we send a packet to (potentially, 2^64
> routes).
>
> Under load, we immediately get the infamous "Neighbour table overflow=
"
> message and machine eventually crash.
>
> This does not happen if we specify a next-hop explicitly, like so:
>
> ip -6 route add 2001:db8::/64 via fe80:: dev sit1
>
> We can avoid this hassle doing the SIT test in ip6_route_add() instea=
d
> of addrconf_prefix_route().
>
> This permits ip6_pol_route() to clone route instead of calling
> rt6_alloc_cow() and allocate a neighbour
>
> Reported-by: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---
>  net/ipv6/addrconf.c |   10 ----------
>  net/ipv6/route.c    |    9 +++++++++
>  2 files changed, 9 insertions(+), 10 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 1237d5d..c6837d2 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1679,16 +1679,6 @@ addrconf_prefix_route(struct in6_addr *pfx, in=
t plen, struct net_device *dev,
>         };
>
>         cfg.fc_dst =3D *pfx;
> -
> -       /* Prevent useless cloning on PtP SIT.
> -          This thing is done here expecting that the whole
> -          class of non-broadcast devices need not cloning.
> -        */
> -#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
> -       if (dev->type =3D=3D ARPHRD_SIT && (dev->flags & IFF_POINTOPO=
INT))
> -               cfg.fc_flags |=3D RTF_NONEXTHOP;
> -#endif
> -
>         ip6_route_add(&cfg);
>  }
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 399613b..d4ba3fc 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1540,6 +1540,15 @@ int ip6_route_add(struct fib6_config *cfg)
>         } else
>                 rt->rt6i_prefsrc.plen =3D 0;
>
> +       /* Prevent useless cloning on PtP SIT.
> +        *  This thing is done here expecting that the whole
> +        *  class of non-broadcast devices need not cloning.
> +        */
> +#if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
> +       if (dev && dev->type =3D=3D ARPHRD_SIT && (dev->flags & IFF_P=
OINTOPOINT))
> +               cfg->fc_flags |=3D RTF_NONEXTHOP;
> +#endif
> +
>         if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
>                 err =3D rt6_bind_neighbour(rt, dev);
>                 if (err)
>
>

Acked-by: Maciej =C5=BBenczykowski <maze@google.com>
