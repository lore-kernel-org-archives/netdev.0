From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH] net: cxgb4{,vf}: convert to hw_features
Date: Fri, 15 Apr 2011 12:00:47 -0700
Message-ID: <4DA895DF.1090809@chelsio.com>
References: <20110415145050.6A43913A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Casey Leedom <leedom@chelsio.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9201 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127Ab1DOTA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 15:00:56 -0400
In-Reply-To: <20110415145050.6A43913A6A@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw wrote:

> +#define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
>  #define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
>  		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
> =20
> @@ -3665,14 +3627,14 @@ static int __devinit init_one(struct pci_dev =
*pdev,
>  		pi =3D netdev_priv(netdev);
>  		pi->adapter =3D adapter;
>  		pi->xact_addr_filt =3D -1;
> -		pi->rx_offload =3D RX_CSO;
>  		pi->port_id =3D i;
>  		netdev->irq =3D pdev->irq;
> =20
> -		netdev->features |=3D NETIF_F_SG | TSO_FLAGS;
> -		netdev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> -		netdev->features |=3D NETIF_F_GRO | NETIF_F_RXHASH | highdma;
> -		netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> +		netdev->hw_features =3D NETIF_F_SG | TSO_FLAGS |
> +			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +			NETIF_F_RXCSUM | NETIF_F_RXHASH |
> +			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> +		netdev->features |=3D netdev->hw_features | highdma;
>  		netdev->vlan_features =3D netdev->features & VLAN_FEAT;

Here vlan_features does not include NETIF_F_RXCSUM but the cxgb4vf bits=
=20
below do include it.  I looked at some other drivers and saw again some=
=20
include it and some don't.  The core VLAN code handles NETIF_F_RXCSUM o=
n its=20
own.  Is there some rule for whether drivers should set it in their=20
vlan_features or not?

> diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
> index 311471b..e8f6f8e 100644
> --- a/drivers/net/cxgb4/sge.c
> +++ b/drivers/net/cxgb4/sge.c
> @@ -1587,7 +1587,7 @@ int t4_ethrx_handler(struct sge_rspq *q, const =
__be64 *rsp,
>  	pi =3D netdev_priv(skb->dev);
>  	rxq->stats.pkts++;
> =20
> -	if (csum_ok && (pi->rx_offload & RX_CSO) &&
> +	if (csum_ok && (q->netdev->features & NETIF_F_RXCSUM) &&
>  	    (pkt->l2info & htonl(RXF_UDP | RXF_TCP))) {
>  		if (!pkt->ip_frag) {
>  			skb->ip_summed =3D CHECKSUM_UNNECESSARY;

With this change variable 'pi' can be removed but I can do this cleanup=
=20
after this patch goes in.

> diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf=
/cxgb4vf_main.c
> index c662679..04a5c2d 100644
> --- a/drivers/net/cxgb4vf/cxgb4vf_main.c
> +++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
> @@ -2638,14 +2597,13 @@ static int __devinit cxgb4vf_pci_probe(struct=
 pci_dev *pdev,
>  		 * it.
>  		 */
>  		pi->xact_addr_filt =3D -1;
> -		pi->rx_offload =3D RX_CSO;
>  		netif_carrier_off(netdev);
>  		netdev->irq =3D pdev->irq;
> =20
> -		netdev->features =3D (NETIF_F_SG | TSO_FLAGS |
> -				    NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> -				    NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
> -				    NETIF_F_GRO);
> +		netdev->hw_features =3D NETIF_F_SG | TSO_FLAGS | NETIF_F_RXCSUM |
> +			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> +		netdev->features =3D netdev->hw_features;
>  		if (pci_using_dac)
>  			netdev->features |=3D NETIF_F_HIGHDMA;
>  		netdev->vlan_features =3D

cxgb4vf does not implement toggling of NETIF_F_HW_VLAN_RX so I think th=
e=20
flag should be set in features but not hw_features or maybe the driver =
needs=20
to handle it in fix_features?
