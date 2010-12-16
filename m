From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 08:18:22 +0100
Message-ID: <1292483902.2603.62.camel@edumazet-laptop>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41343 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab0LPHS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 02:18:28 -0500
Received: by wwa36 with SMTP id 36so2116235wwa.1
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 23:18:26 -0800 (PST)
In-Reply-To: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 13:57 +0800, Changli Gao a =C3=A9=
crit :
> In dev_queue_xmit_nit(), we have to clone skbs as we need to mangle s=
kbs,
> however, we don't need to clone skbs for all the packet_types.
>=20
> Except for the first packet_type, we increase skb->users instead of
> skb_clone().
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/core/dev.c |   30 ++++++++++++++++++++----------
>  1 file changed, 20 insertions(+), 10 deletions(-)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index bf5ced5..888cb74 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1496,6 +1496,14 @@ int dev_forward_skb(struct net_device *dev, st=
ruct sk_buff *skb)
>  }
>  EXPORT_SYMBOL_GPL(dev_forward_skb);
> =20
> +static inline int deliver_skb(struct sk_buff *skb,
> +			      struct packet_type *pt_prev,
> +			      struct net_device *orig_dev)
> +{
> +	atomic_inc(&skb->users);
> +	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
> +}
> +
>  /*
>   *	Support routine. Sends outgoing frames to any network
>   *	taps currently in use.
> @@ -1504,6 +1512,8 @@ EXPORT_SYMBOL_GPL(dev_forward_skb);
>  static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_devic=
e *dev)
>  {
>  	struct packet_type *ptype;
> +	struct sk_buff *skb2 =3D NULL;
> +	struct packet_type *pt_prev =3D NULL;
> =20
>  #ifdef CONFIG_NET_CLS_ACT
>  	if (!(skb->tstamp.tv64 && (G_TC_FROM(skb->tc_verd) & AT_INGRESS)))
> @@ -1520,7 +1530,13 @@ static void dev_queue_xmit_nit(struct sk_buff =
*skb, struct net_device *dev)
>  		if ((ptype->dev =3D=3D dev || !ptype->dev) &&
>  		    (ptype->af_packet_priv =3D=3D NULL ||
>  		     (struct sock *)ptype->af_packet_priv !=3D skb->sk)) {
> -			struct sk_buff *skb2 =3D skb_clone(skb, GFP_ATOMIC);
> +			if (pt_prev) {
> +				deliver_skb(skb2, pt_prev, skb->dev);
> +				pt_prev =3D ptype;
> +				continue;
> +			}
> +
> +			skb2 =3D skb_clone(skb, GFP_ATOMIC);
>  			if (!skb2)
>  				break;
> =20
> @@ -1542,9 +1558,11 @@ static void dev_queue_xmit_nit(struct sk_buff =
*skb, struct net_device *dev)
> =20
>  			skb2->transport_header =3D skb2->network_header;
>  			skb2->pkt_type =3D PACKET_OUTGOING;
> -			ptype->func(skb2, skb->dev, ptype, skb->dev);
> +			pt_prev =3D ptype;
>  		}
>  	}
> +	if (pt_prev)
> +		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
>  	rcu_read_unlock();
>  }
> =20
> @@ -2788,14 +2806,6 @@ static void net_tx_action(struct softirq_actio=
n *h)
>  	}
>  }
> =20
> -static inline int deliver_skb(struct sk_buff *skb,
> -			      struct packet_type *pt_prev,
> -			      struct net_device *orig_dev)
> -{
> -	atomic_inc(&skb->users);
> -	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
> -}
> -
>  #if (defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)) && \
>      (defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE))
>  /* This hook is defined here for ATM LANE */

You beat me, but I was thinking of a different way, adding a new
pt_prev->xmit_func(), handling all the details (no need for atomic ops
on skb users if packet is not delivered at all).

By the way, your patch is not 100% safe/OK, because af_packet rcv()
handler writes on skb (skb_pull() and all)



