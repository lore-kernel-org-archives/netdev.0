From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH RESEND] net: convert xen-netfront to hw_features
Date: Thu, 31 Mar 2011 12:13:30 +0100
Message-ID: <1301570010.27123.172.camel@zakaz.uk.xensource.com>
References: <20110331110136.03A1A13A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:12296 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677Ab1CaLNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 07:13:32 -0400
In-Reply-To: <20110331110136.03A1A13A6A@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-31 at 12:01 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Not tested in any way. The original code for offload setting seems br=
oken
> as it resets the features on every netback reconnect.

Thanks, I've got a pending TODO item to test this and propagate similar
changes to netback. I hope to get to it soon...

Is this urgent (for 2.6.39) IYHO? I think it's been broken this way for
a long time now...

Ian.

>=20
> This will set GSO_ROBUST at device creation time (earlier than connec=
t time).
>=20
> RX checksum offload is forced on - so advertise as it is.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
> [I don't know Xen code enough to say this is correct. There is Xen ne=
tback
> driver coming in, that has similar changes to be made. Please match
> them up if you can.]
>=20
>  drivers/net/xen-netfront.c |   57 +++++++++++++++++-----------------=
---------
>  1 files changed, 23 insertions(+), 34 deletions(-)
>=20
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 5c8d9c3..2a71c9f 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1148,6 +1148,8 @@ static const struct net_device_ops xennet_netde=
v_ops =3D {
>  	.ndo_change_mtu	     =3D xennet_change_mtu,
>  	.ndo_set_mac_address =3D eth_mac_addr,
>  	.ndo_validate_addr   =3D eth_validate_addr,
> +	.ndo_fix_features    =3D xennet_fix_features,
> +	.ndo_set_features    =3D xennet_set_features,
>  };
> =20
>  static struct net_device * __devinit xennet_create_dev(struct xenbus=
_device *dev)
> @@ -1209,7 +1211,9 @@ static struct net_device * __devinit xennet_cre=
ate_dev(struct xenbus_device *dev
>  	netdev->netdev_ops	=3D &xennet_netdev_ops;
> =20
>  	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
> -	netdev->features        =3D NETIF_F_IP_CSUM;
> +	netdev->features        =3D NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
> +				  NETIF_F_GSO_ROBUST;
> +	netdev->hw_features	=3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
> =20
>  	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
>  	SET_NETDEV_DEV(netdev, &dev->dev);
> @@ -1510,52 +1514,40 @@ again:
>  	return err;
>  }
> =20
> -static int xennet_set_sg(struct net_device *dev, u32 data)
> +static u32 xennet_fix_features(struct net_device *dev, u32 features)
>  {
> -	if (data) {
> -		struct netfront_info *np =3D netdev_priv(dev);
> -		int val;
> +	struct netfront_info *np =3D netdev_priv(dev);
> +	int val;
> =20
> +	if (features & NETIF_F_SG) {
>  		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend, "feature-sg",
>  				 "%d", &val) < 0)
>  			val =3D 0;
> +
>  		if (!val)
> -			return -ENOSYS;
> -	} else if (dev->mtu > ETH_DATA_LEN)
> -		dev->mtu =3D ETH_DATA_LEN;
> -
> -	return ethtool_op_set_sg(dev, data);
> -}
> -
> -static int xennet_set_tso(struct net_device *dev, u32 data)
> -{
> -	if (data) {
> -		struct netfront_info *np =3D netdev_priv(dev);
> -		int val;
> +			features &=3D ~NETIF_F_SG;
> +	}
> =20
> +	if (features & NETIF_F_TSO) {
>  		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
>  				 "feature-gso-tcpv4", "%d", &val) < 0)
>  			val =3D 0;
> +
>  		if (!val)
> -			return -ENOSYS;
> +			features &=3D ~NETIF_F_TSO;
>  	}
> =20
> -	return ethtool_op_set_tso(dev, data);
> +	return features;
>  }
> =20
> -static void xennet_set_features(struct net_device *dev)
> +static int xennet_set_features(struct net_device *dev, u32 features)
>  {
> -	/* Turn off all GSO bits except ROBUST. */
> -	dev->features &=3D ~NETIF_F_GSO_MASK;
> -	dev->features |=3D NETIF_F_GSO_ROBUST;
> -	xennet_set_sg(dev, 0);
> +	if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN) {
> +		netdev_info(dev, "Reducing MTU because no SG offload");
> +		dev->mtu =3D ETH_DATA_LEN;
> +	}
> =20
> -	/* We need checksum offload to enable scatter/gather and TSO. */
> -	if (!(dev->features & NETIF_F_IP_CSUM))
> -		return;
> -
> -	if (!xennet_set_sg(dev, 1))
> -		xennet_set_tso(dev, 1);
> +	return 0;
>  }
> =20
>  static int xennet_connect(struct net_device *dev)
> @@ -1582,7 +1574,7 @@ static int xennet_connect(struct net_device *de=
v)
>  	if (err)
>  		return err;
> =20
> -	xennet_set_features(dev);
> +	netdev_update_features(dev);
> =20
>  	spin_lock_bh(&np->rx_lock);
>  	spin_lock_irq(&np->tx_lock);
> @@ -1710,9 +1702,6 @@ static void xennet_get_strings(struct net_devic=
e *dev, u32 stringset, u8 * data)
> =20
>  static const struct ethtool_ops xennet_ethtool_ops =3D
>  {
> -	.set_tx_csum =3D ethtool_op_set_tx_csum,
> -	.set_sg =3D xennet_set_sg,
> -	.set_tso =3D xennet_set_tso,
>  	.get_link =3D ethtool_op_get_link,
> =20
>  	.get_sset_count =3D xennet_get_sset_count,


