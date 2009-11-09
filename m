From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] check the return value of ndo_select_queue()
Date: Mon, 09 Nov 2009 10:50:41 +0100
Message-ID: <4AF7E5F1.6080608@gmail.com>
References: <4AF7E221.2040901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46101 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767AbZKIJuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 04:50:40 -0500
In-Reply-To: <4AF7E221.2040901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =A8=A6crit :
> check the return value of ndo_select_queue()
>=20
> Check the return value of ndo_select_queue(). If the value isn't smal=
ler
> than the real_num_tx_queues, print a warning message, and reset it to=
 zero.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
> net/core/dev.c | 11 +++++++++--
> 1 file changed, 9 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b8f74cf..0a6bf2e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1794,10 +1794,17 @@ static struct netdev_queue *dev_pick_tx(struc=
t net_device *dev,
>  	const struct net_device_ops *ops =3D dev->netdev_ops;
>  	u16 queue_index =3D 0;
> =20
> -	if (ops->ndo_select_queue)
> +	if (ops->ndo_select_queue) {
>  		queue_index =3D ops->ndo_select_queue(dev, skb);
> -	else if (dev->real_num_tx_queues > 1)
> +		if (queue_index >=3D dev->real_num_tx_queues) {
> +			WARN(1, "%s selects TX queue %d, "
> +			     "but real number of TX queues is %d\n",
> +			     dev->name, queue_index, dev->real_num_tx_queues);
> +			queue_index =3D 0;
> +		}
> +	} else if (dev->real_num_tx_queues > 1) {
>  		queue_index =3D skb_tx_hash(dev, skb);
> +	}
> =20
>  	skb_set_queue_mapping(skb, queue_index);
>  	return netdev_get_tx_queue(dev, queue_index);

Yes, but this is a _very_ unlikely condition (a bug IMHO), so you could=
 use :

if (unlikely(queue_index >=3D dev->real_num_tx_queues)) {
	...
}

(This unlikely() clause is implied in WARN... macros)

