From: Andrew Vagin <avagin@parallels.com>
Subject: Re: Slow speed of tcp connections in a network namespace
Date: Sat, 29 Dec 2012 18:50:31 +0400
Message-ID: <20121229145030.GA7959@paralelels.com>
References: <20121229092417.GA4038@paralelels.com>
 <1356789203.21409.3923.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <vvs@parallels.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:42981 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952Ab2L2OvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 09:51:12 -0500
Content-Disposition: inline
In-Reply-To: <1356789203.21409.3923.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 29, 2012 at 05:53:23AM -0800, Eric Dumazet wrote:
> > 3.8-rc1 is used for experiments.
> >=20
> > Do you have any ideas where is a problem?
>=20
> veth has absolutely no offload features
>=20
> It needs some care...
>=20
> At the very miminum, let TCP coalesce do its job by allowing SG
>=20
> CC Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> for insights.
>=20
> Please try following patch :

Hello Eric,

Thanks for your feedback.

With this patch the results is a bit better (~4MB/s), but it's much les=
s
than in the root netns.

>=20
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 95814d9..9fefeb3 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -259,6 +259,10 @@ static const struct net_device_ops veth_netdev_o=
ps =3D {
>  	.ndo_set_mac_address =3D eth_mac_addr,
>  };
> =20
> +#define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO |=
	\
> +		       NETIF_F_HW_CSUM | NETIF_F_HIGHDMA |		\
> +		       NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX)
> +
>  static void veth_setup(struct net_device *dev)
>  {
>  	ether_setup(dev);
> @@ -269,9 +273,10 @@ static void veth_setup(struct net_device *dev)
>  	dev->netdev_ops =3D &veth_netdev_ops;
>  	dev->ethtool_ops =3D &veth_ethtool_ops;
>  	dev->features |=3D NETIF_F_LLTX;
> +	dev->features |=3D VETH_FEATURES;
>  	dev->destructor =3D veth_dev_free;
> =20
> -	dev->hw_features =3D NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
> +	dev->hw_features =3D VETH_FEATURES;
>  }
> =20
>  /*
>=20
>=20
