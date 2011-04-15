From: Jon Mason <jon.mason@myri.com>
Subject: Re: [PATCH] net: myri10ge: convert to hw_features
Date: Fri, 15 Apr 2011 13:29:22 -0500
Message-ID: <20110415182922.GA2458@myri.com>
References: <20110415145050.0D65C13A66@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2006 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751926Ab1DOTEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 15:04:23 -0400
Content-Disposition: inline
In-Reply-To: <20110415145050.0D65C13A66@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2011 at 04:50:50PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>  drivers/net/myri10ge/myri10ge.c |   66 +++++++----------------------=
---------
>  1 files changed, 12 insertions(+), 54 deletions(-)
>=20
> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/m=
yri10ge.c
> index 1446de5..a48eb92 100644
> --- a/drivers/net/myri10ge/myri10ge.c
> +++ b/drivers/net/myri10ge/myri10ge.c
> @@ -205,7 +205,6 @@ struct myri10ge_priv {
>  	int tx_boundary;	/* boundary transmits cannot cross */
>  	int num_slices;
>  	int running;		/* running?             */
> -	int csum_flag;		/* rx_csums?            */

Get rid of MXGEFW_FLAGS_CKSUM in drivers/net/myri10ge/myri10ge_mcp.h,
as this was the only thing using it.

>  	int small_bytes;
>  	int big_bytes;
>  	int max_intr_slots;
> @@ -1386,7 +1385,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *s=
s, int len, __wsum csum,
>  	skb->protocol =3D eth_type_trans(skb, dev);
>  	skb_record_rx_queue(skb, ss - &mgp->ss[0]);
> =20
> -	if (mgp->csum_flag) {
> +	if (dev->features & NETIF_F_RXCSUM) {
>  		if ((skb->protocol =3D=3D htons(ETH_P_IP)) ||
>  		    (skb->protocol =3D=3D htons(ETH_P_IPV6))) {
>  			skb->csum =3D csum;
> @@ -1757,43 +1756,6 @@ myri10ge_get_ringparam(struct net_device *netd=
ev,
>  	ring->tx_pending =3D ring->tx_max_pending;
>  }
> =20
> -static u32 myri10ge_get_rx_csum(struct net_device *netdev)
> -{
> -	struct myri10ge_priv *mgp =3D netdev_priv(netdev);
> -
> -	if (mgp->csum_flag)
> -		return 1;
> -	else
> -		return 0;
> -}
> -
> -static int myri10ge_set_rx_csum(struct net_device *netdev, u32 csum_=
enabled)
> -{
> -	struct myri10ge_priv *mgp =3D netdev_priv(netdev);
> -	int err =3D 0;
> -
> -	if (csum_enabled)
> -		mgp->csum_flag =3D MXGEFW_FLAGS_CKSUM;
> -	else {
> -		netdev->features &=3D ~NETIF_F_LRO;
> -		mgp->csum_flag =3D 0;
> -
> -	}
> -	return err;
> -}
> -
> -static int myri10ge_set_tso(struct net_device *netdev, u32 tso_enabl=
ed)
> -{
> -	struct myri10ge_priv *mgp =3D netdev_priv(netdev);
> -	u32 flags =3D mgp->features & (NETIF_F_TSO6 | NETIF_F_TSO);
> -
> -	if (tso_enabled)
> -		netdev->features |=3D flags;
> -	else
> -		netdev->features &=3D ~flags;
> -	return 0;
> -}

ethtool_op_set_tso does not support TSO6.  This would remove the
enable/disable of that feature.

> -
>  static const char myri10ge_gstrings_main_stats[][ETH_GSTRING_LEN] =3D=
 {
>  	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
>  	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
> @@ -1944,11 +1906,6 @@ static u32 myri10ge_get_msglevel(struct net_de=
vice *netdev)
>  	return mgp->msg_enable;
>  }
> =20
> -static int myri10ge_set_flags(struct net_device *netdev, u32 value)
> -{
> -	return ethtool_op_set_flags(netdev, value, ETH_FLAG_LRO);
> -}
> -
>  static const struct ethtool_ops myri10ge_ethtool_ops =3D {
>  	.get_settings =3D myri10ge_get_settings,
>  	.get_drvinfo =3D myri10ge_get_drvinfo,
> @@ -1957,19 +1914,12 @@ static const struct ethtool_ops myri10ge_etht=
ool_ops =3D {
>  	.get_pauseparam =3D myri10ge_get_pauseparam,
>  	.set_pauseparam =3D myri10ge_set_pauseparam,
>  	.get_ringparam =3D myri10ge_get_ringparam,
> -	.get_rx_csum =3D myri10ge_get_rx_csum,
> -	.set_rx_csum =3D myri10ge_set_rx_csum,
> -	.set_tx_csum =3D ethtool_op_set_tx_hw_csum,
> -	.set_sg =3D ethtool_op_set_sg,
> -	.set_tso =3D myri10ge_set_tso,
>  	.get_link =3D ethtool_op_get_link,
>  	.get_strings =3D myri10ge_get_strings,
>  	.get_sset_count =3D myri10ge_get_sset_count,
>  	.get_ethtool_stats =3D myri10ge_get_ethtool_stats,
>  	.set_msglevel =3D myri10ge_set_msglevel,
>  	.get_msglevel =3D myri10ge_get_msglevel,
> -	.get_flags =3D ethtool_op_get_flags,
> -	.set_flags =3D myri10ge_set_flags
>  };
> =20
>  static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
> @@ -3136,6 +3086,14 @@ static int myri10ge_set_mac_address(struct net=
_device *dev, void *addr)
>  	return 0;
>  }
> =20
> +static u32 myri10ge_fix_features(struct net_device *dev, u32 feature=
s)
> +{
> +	if (!(features & NETIF_F_RXCSUM))
> +		features &=3D ~NETIF_F_LRO;
> +
> +	return features;
> +}
> +
>  static int myri10ge_change_mtu(struct net_device *dev, int new_mtu)
>  {
>  	struct myri10ge_priv *mgp =3D netdev_priv(dev);
> @@ -3834,6 +3792,7 @@ static const struct net_device_ops myri10ge_net=
dev_ops =3D {
>  	.ndo_get_stats		=3D myri10ge_get_stats,
>  	.ndo_validate_addr	=3D eth_validate_addr,
>  	.ndo_change_mtu		=3D myri10ge_change_mtu,
> +	.ndo_fix_features	=3D myri10ge_fix_features,
>  	.ndo_set_multicast_list =3D myri10ge_set_multicast_list,
>  	.ndo_set_mac_address	=3D myri10ge_set_mac_address,
>  };
> @@ -3860,7 +3819,6 @@ static int myri10ge_probe(struct pci_dev *pdev,=
 const struct pci_device_id *ent)
>  	mgp =3D netdev_priv(netdev);
>  	mgp->dev =3D netdev;
>  	mgp->pdev =3D pdev;
> -	mgp->csum_flag =3D MXGEFW_FLAGS_CKSUM;
>  	mgp->pause =3D myri10ge_flow_control;
>  	mgp->intr_coal_delay =3D myri10ge_intr_coal_delay;
>  	mgp->msg_enable =3D netif_msg_init(myri10ge_debug, MYRI10GE_MSG_DEF=
AULT);
> @@ -3976,11 +3934,11 @@ static int myri10ge_probe(struct pci_dev *pde=
v, const struct pci_device_id *ent)
>  	netdev->netdev_ops =3D &myri10ge_netdev_ops;
>  	netdev->mtu =3D myri10ge_initial_mtu;
>  	netdev->base_addr =3D mgp->iomem_base;
> -	netdev->features =3D mgp->features;
> +	netdev->hw_features =3D mgp->features | NETIF_F_LRO | NETIF_F_RXCSU=
M;
> +	netdev->features =3D netdev->hw_features;
> =20
>  	if (dac_enabled)
>  		netdev->features |=3D NETIF_F_HIGHDMA;
> -	netdev->features |=3D NETIF_F_LRO;
> =20
>  	netdev->vlan_features |=3D mgp->features;
>  	if (mgp->fw_ver_tiny < 37)
> --=20
> 1.7.2.5
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
