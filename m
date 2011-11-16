From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v5 4/9] net: introduce and use netdev_features_t for
 device features sets
Date: Wed, 16 Nov 2011 22:30:32 +0000
Message-ID: <1321482632.2709.24.camel@bwh-desktop>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
	 <5d60e779e1f7c316783ea59c194af3e5f57ed6d2.1321404954.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:33453 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab1KPWah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 17:30:37 -0500
In-Reply-To: <5d60e779e1f7c316783ea59c194af3e5f57ed6d2.1321404954.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-16 at 02:29 +0100, Micha=C5=82 Miros=C5=82aw wrote:
[...]
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
[...]
> @@ -3538,7 +3538,7 @@ static int __devinit init_one(struct pci_dev *p=
dev,
>  {
>  	int func, i, err;
>  	struct port_info *pi;
> -	unsigned int highdma =3D 0;
> +	bool highdma =3D false;
>  	struct adapter *adapter =3D NULL;
> =20
>  	printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
> @@ -3564,7 +3564,7 @@ static int __devinit init_one(struct pci_dev *p=
dev,
>  	}
> =20
>  	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
> -		highdma =3D NETIF_F_HIGHDMA;
> +		highdma =3D true;
>  		err =3D pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
>  		if (err) {
>  			dev_err(&pdev->dev, "unable to obtain 64-bit DMA for "
> @@ -3638,7 +3638,9 @@ static int __devinit init_one(struct pci_dev *p=
dev,
>  			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  			NETIF_F_RXCSUM | NETIF_F_RXHASH |
>  			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> -		netdev->features |=3D netdev->hw_features | highdma;
> +		if (highdma)
> +			netdev->hw_features |=3D NETIF_F_HIGHDMA;

This wasn't previously included in hw_features.  Since hidma was being
used as a bitmask in this function, not a boolean, why don't you just
change its type to netdev_features_t for now?

> +		netdev->features |=3D netdev->hw_features;
>  		netdev->vlan_features =3D netdev->features & VLAN_FEAT;
> =20
>  		netdev->priv_flags |=3D IFF_UNICAST_FLT;
[....]
> --- a/drivers/net/ethernet/jme.c
> +++ b/drivers/net/ethernet/jme.c
> @@ -1917,7 +1917,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct =
sk_buff *skb, int idx)
>  	struct jme_ring *txring =3D &(jme->txring[0]);
>  	struct txdesc *txdesc =3D txring->desc, *ctxdesc;
>  	struct jme_buffer_info *txbi =3D txring->bufinf, *ctxbi;
> -	u8 hidma =3D jme->dev->features & NETIF_F_HIGHDMA;
> +	u8 hidma =3D !!(jme->dev->features & NETIF_F_HIGHDMA);

The original here is nasty!  But you can change the type to bool and
then there is no need for the '!!'.

[...]
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -1579,10 +1579,10 @@ mv643xx_eth_set_ringparam(struct net_device *=
dev, struct ethtool_ringparam *er)
> =20
>=20
>  static int
> -mv643xx_eth_set_features(struct net_device *dev, u32 features)
> +mv643xx_eth_set_features(struct net_device *dev, netdev_features_t f=
eatures)
>  {
>  	struct mv643xx_eth_private *mp =3D netdev_priv(dev);
> -	u32 rx_csum =3D features & NETIF_F_RXCSUM;
> +	int rx_csum =3D !!(features & NETIF_F_RXCSUM);

Again, change the type to bool.

[...]
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
[...]=20
> -static int sky2_set_features(struct net_device *dev, u32 features)
> +static int sky2_set_features(struct net_device *dev, netdev_features=
_t features)
>  {
>  	struct sky2_port *sky2 =3D netdev_priv(dev);
> -	u32 changed =3D dev->features ^ features;
> +	netdev_features_t changed =3D dev->features ^ features;
> =20
>  	if (changed & NETIF_F_RXCSUM) {
> -		u32 on =3D features & NETIF_F_RXCSUM;
> +		int on =3D !!(features & NETIF_F_RXCSUM);

Same here.

[...]
> --- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> +++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> @@ -1491,7 +1491,7 @@ myri10ge_clean_rx_done(struct myri10ge_slice_st=
ate *ss, int budget)
>  	 * access to avoid theoretical race condition with functions that
>  	 * change NETIF_F_LRO flag at runtime.
>  	 */
> -	bool lro_enabled =3D ACCESS_ONCE(mgp->dev->features) & NETIF_F_LRO;
> +	bool lro_enabled =3D !!(ACCESS_ONCE(mgp->dev->features) & NETIF_F_L=
RO);

No change required here.

[...]
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -203,7 +203,7 @@ static void xennet_sysfs_delif(struct net_device =
*netdev);
> =20
>  static int xennet_can_sg(struct net_device *dev)
>  {
> -	return dev->features & NETIF_F_SG;
> +	return !!(dev->features & NETIF_F_SG);
>  }
[...]

You could change the return type to bool.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
