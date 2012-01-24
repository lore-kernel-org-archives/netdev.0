From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Remove bogus checks of rt_gateway being zero.
Date: Wed, 25 Jan 2012 00:15:46 +0100
Message-ID: <1327446946.14373.2.camel@edumazet-laptop>
References: <20120124.180937.1535236308212704084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50064 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab2AXXPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 18:15:51 -0500
Received: by wgbed3 with SMTP id ed3so4589490wgb.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 15:15:49 -0800 (PST)
In-Reply-To: <20120124.180937.1535236308212704084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 janvier 2012 =C3=A0 18:09 -0500, David Miller a =C3=A9crit =
:
> It can never actually happen.  rt_gateway is either the fully resolve=
d
> flow lookup key's destination address, or the non-zero FIB entry gate=
way
> address.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>=20
> Applied to net-next
>=20
>  net/ipv4/ip_gre.c |    8 +++-----
>  net/ipv4/ipip.c   |    2 --
>  2 files changed, 3 insertions(+), 7 deletions(-)
>=20
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 2b53a1f..fc21335 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -724,11 +724,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_b=
uff *skb, struct net_device *dev
>  			goto tx_error;
>  		}
> =20
> -		if (skb->protocol =3D=3D htons(ETH_P_IP)) {
> +		if (skb->protocol =3D=3D htons(ETH_P_IP))
>  			rt =3D skb_rtable(skb);
> -			if ((dst =3D rt->rt_gateway) =3D=3D 0)
> -				goto tx_error_icmp;
> -		}
>  #if IS_ENABLED(CONFIG_IPV6)
>  		else if (skb->protocol =3D=3D htons(ETH_P_IPV6)) {
>  			struct neighbour *neigh =3D dst_get_neighbour_noref(skb_dst(skb))=
;
> @@ -910,9 +907,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_b=
uff *skb, struct net_device *dev
>  	__IPTUNNEL_XMIT(tstats, &dev->stats);
>  	return NETDEV_TX_OK;
> =20
> +#if IS_ENABLED(CONFIG_IPV6)
>  tx_error_icmp:
>  	dst_link_failure(skb);
> -
> +#endif
>  tx_error:
>  	dev->stats.tx_errors++;
>  	dev_kfree_skb(skb);
> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
> index 413ed1b..be2cbd1 100644
> --- a/net/ipv4/ipip.c
> +++ b/net/ipv4/ipip.c
> @@ -454,8 +454,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buf=
f *skb, struct net_device *dev)
>  			dev->stats.tx_fifo_errors++;
>  			goto tx_error;
>  		}
> -		if ((dst =3D rt->rt_gateway) =3D=3D 0)
> -			goto tx_error_icmp;
>  	}
> =20
>  	rt =3D ip_route_output_ports(dev_net(dev), &fl4, NULL,

Hmm...

So dst wont be initialized ?
