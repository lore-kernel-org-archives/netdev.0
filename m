From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC vlan 03/03]: propagate transmission state
Date: Tue, 09 Jun 2009 18:34:47 +0200
Message-ID: <4A2E8F27.3040202@gmail.com>
References: <20090609161658.6730.59754.sendpatchset@x2.localnet> <20090609161702.6730.72574.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53281 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756095AbZFIQeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 12:34:50 -0400
In-Reply-To: <20090609161702.6730.72574.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> commit b124eaaf852e982c7af9b130ee81cfc293ae30ff
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Tue Jun 9 18:01:11 2009 +0200
>=20
>     vlan: propagate transmission state
>    =20
>     Propagate transmission state to upper layers and maintain error s=
tatistics.
>    =20
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>=20
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 96bad8f..39a8e03 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -292,6 +292,8 @@ static int vlan_dev_hard_start_xmit(struct sk_buf=
f *skb, struct net_device *dev)
>  {
>  	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, 0);
>  	struct vlan_ethhdr *veth =3D (struct vlan_ethhdr *)(skb->data);
> +	unsigned int len;
> +	int err;
> =20
>  	/* Handle non-VLAN frames if they are sent to us, for example by DH=
CP.
>  	 *
> @@ -317,19 +319,25 @@ static int vlan_dev_hard_start_xmit(struct sk_b=
uff *skb, struct net_device *dev)
>  			vlan_dev_info(dev)->cnt_inc_headroom_on_tx++;
>  	}
> =20
> -	txq->tx_packets++;
> -	txq->tx_bytes +=3D skb->len;
> -
>  	skb->dev =3D vlan_dev_info(dev)->real_dev;
> -	dev_queue_xmit(skb);
> -	return NETDEV_TX_OK;
> +	len =3D skb->len;
> +	err =3D dev_queue_xmit(skb);
> +	if (err =3D=3D NET_XMIT_SUCCESS) {
> +		txq->tx_packets++;
> +		txq->tx_bytes +=3D len;
> +	} else
> +		txq->tx_dropped++;
> +
> +	return err;
>  }
> =20
>  static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
>  					    struct net_device *dev)
>  {
>  	struct netdev_queue *txq =3D netdev_get_tx_queue(dev, 0);
> +	unsigned int len;
>  	u16 vlan_tci;
> +	int err;
> =20
>  	vlan_tci =3D vlan_dev_info(dev)->vlan_id;
>  	vlan_tci |=3D vlan_dev_get_egress_qos_mask(dev, skb);
> @@ -339,8 +347,15 @@ static int vlan_dev_hwaccel_hard_start_xmit(stru=
ct sk_buff *skb,
>  	txq->tx_bytes +=3D skb->len;

It seems you forgot to delete previous txq->tx_bytes +=3D skb->len; && =
txq->tx_packets++; ?

> =20
>  	skb->dev =3D vlan_dev_info(dev)->real_dev;
> -	dev_queue_xmit(skb);
> -	return NETDEV_TX_OK;
> +	len =3D skb->len;
> +	err =3D dev_queue_xmit(skb);
> +	if (err =3D=3D NET_XMIT_SUCCESS) {
> +		txq->tx_packets++;
> +		txq->tx_bytes +=3D len;
> +	} else
> +		txq->tx_dropped++;
> +
> +	return err;
>  }
> =20
>  static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
