From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH 2/5] net: Use sk_tx_queue_mapping for connected
 sockets
Date: Thu, 15 Oct 2009 11:41:52 +0200
Message-ID: <4AD6EE60.6040009@gmail.com>
References: <20091015055602.30145.65852.sendpatchset@localhost.localdomain> <20091015055702.30145.41799.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35853 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbZJOJmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 05:42:38 -0400
In-Reply-To: <20091015055702.30145.41799.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar a =E9crit :
> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> For connected sockets, the first run of dev_pick_tx saves the
> calculated txq in sk_tx_queue_mapping. This is not saved if
> either skb rx was recorded, or if the device has a queue select
> handler. Next iterations of dev_pick_tx uses the cached value of
> sk_tx_queue_mapping.
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  net/core/dev.c |   24 ++++++++++++++++++------
>  1 file changed, 18 insertions(+), 6 deletions(-)
>=20
> diff -ruNp org/net/core/dev.c new/net/core/dev.c
> --- org/net/core/dev.c	2009-10-14 17:59:40.000000000 +0530
> +++ new/net/core/dev.c	2009-10-14 18:00:04.000000000 +0530
> @@ -1791,13 +1791,25 @@ EXPORT_SYMBOL(skb_tx_hash);
>  static struct netdev_queue *dev_pick_tx(struct net_device *dev,
>  					struct sk_buff *skb)
>  {
> -	const struct net_device_ops *ops =3D dev->netdev_ops;
> -	u16 queue_index =3D 0;
> +	u16 queue_index;
> +	struct sock *sk =3D skb->sk;
> +
> +	if (sk_tx_queue_recorded(sk)) {
> +		queue_index =3D sk_get_tx_queue(sk);
> +	} else {
> +		const struct net_device_ops *ops =3D dev->netdev_ops;
> =20
> -	if (ops->ndo_select_queue)
> -		queue_index =3D ops->ndo_select_queue(dev, skb);
> -	else if (dev->real_num_tx_queues > 1)
> -		queue_index =3D skb_tx_hash(dev, skb);
> +		if (ops->ndo_select_queue) {
> +			queue_index =3D ops->ndo_select_queue(dev, skb);
> +		} else {
> +			queue_index =3D 0;
> +			if (dev->real_num_tx_queues > 1)
> +				queue_index =3D skb_tx_hash(dev, skb);
> +
> +			if (sk && sk->sk_dst_cache)
> +				sk_record_tx_queue(sk, queue_index);
> +		}
> +	}
> =20
>  	skb_set_queue_mapping(skb, queue_index);
>  	return netdev_get_tx_queue(dev, queue_index);
>=20
>=20

Hmm, why not cache ops->ndo_select_queue(dev, skb) choice too ?

		if (ops->ndo_select_queue)
			queue_index =3D ops->ndo_select_queue(dev, skb);
		else {
			queue_index =3D 0;
			if (dev->real_num_tx_queues > 1)
				queue_index =3D skb_tx_hash(dev, skb);
		}
		if (sk && sk->sk_dst_cache)
			sk_record_tx_queue(sk, queue_index);

Or should ndo_select_queue() method take care of calling sk_record_tx_q=
ueue() itself ?
