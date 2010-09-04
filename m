From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: rps: add the shortcut for one rps_cpus
Date: Sat, 04 Sep 2010 13:01:11 +0200
Message-ID: <1283598071.3402.21.camel@edumazet-laptop>
References: <1283591557-31921-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52866 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab0IDLBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 07:01:17 -0400
Received: by fxm13 with SMTP id 13so1745494fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Sep 2010 04:01:16 -0700 (PDT)
In-Reply-To: <1283591557-31921-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 septembre 2010 =C3=A0 17:12 +0800, Changli Gao a =C3=A9cri=
t :
> When there is only one rps_cpus, skb_get_rxhash() can be eliminated.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/core/dev.c |   14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d8c43e7..2bf740c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2345,7 +2345,7 @@ static int get_rps_cpu(struct net_device *dev, =
struct sk_buff *skb,
>  		       struct rps_dev_flow **rflowp)
>  {
>  	struct netdev_rx_queue *rxqueue;
> -	struct rps_map *map;
> +	struct rps_map *map =3D NULL;
>  	struct rps_dev_flow_table *flow_table;
>  	struct rps_sock_flow_table *sock_flow_table;
>  	int cpu =3D -1;
> @@ -2363,8 +2363,17 @@ static int get_rps_cpu(struct net_device *dev,=
 struct sk_buff *skb,
>  	} else
>  		rxqueue =3D dev->_rx;
> =20
> -	if (!rxqueue->rps_map && !rxqueue->rps_flow_table)
> +	if (rxqueue->rps_map) {
> +		map =3D rcu_dereference(rxqueue->rps_map);
> +		if (map && map->len =3D=3D 1) {
> +			tcpu =3D map->cpus[0];
> +			if (cpu_online(tcpu))
> +				cpu =3D tcpu;
> +			goto done;
> +		}
> +	} else if (!rxqueue->rps_flow_table) {
>  		goto done;
> +	}
> =20
>  	skb_reset_network_header(skb);
>  	if (!skb_get_rxhash(skb))
> @@ -2409,7 +2418,6 @@ static int get_rps_cpu(struct net_device *dev, =
struct sk_buff *skb,
>  		}
>  	}
> =20
> -	map =3D rcu_dereference(rxqueue->rps_map);
>  	if (map) {
>  		tcpu =3D map->cpus[((u64) skb->rxhash * map->len) >> 32];
> =20
> --

You are 'optimizing' a very unusual case and slow down 99% of normal
uses.

Normal way to handle this, is to use irq affinity and deliver interrupt=
s
directly to the target cpu.=20



