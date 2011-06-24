From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 1/3] be2net: fix netdev_stats_update
Date: Fri, 24 Jun 2011 12:32:00 +0200
Message-ID: <1308911520.2228.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <913f4373-e01f-4aa9-b8c7-d041d70f0945@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43626 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094Ab1FXIcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 04:32:03 -0400
Received: by wwe5 with SMTP id 5so2657609wwe.1
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2011 01:32:01 -0700 (PDT)
In-Reply-To: <913f4373-e01f-4aa9-b8c7-d041d70f0945@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 juin 2011 =C3=A0 13:43 +0530, Sathya Perla a =C3=A9crit =
:
> netdev_stats_update() resets netdev->stats and then accumulates stats=
 from
> various rings. This is wrong as stats readers can sometimes catch zer=
o values.
> Use temporary variables instead for accumulating per-ring values.
>=20
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
>  drivers/net/benet/be_main.c |   29 +++++++++++++++++------------
>  1 files changed, 17 insertions(+), 12 deletions(-)
>=20
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.=
c
> index c4f564c..5ca06b0 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -428,33 +428,38 @@ void netdev_stats_update(struct be_adapter *ada=
pter)
>  	struct net_device_stats *dev_stats =3D &adapter->netdev->stats;
>  	struct be_rx_obj *rxo;
>  	struct be_tx_obj *txo;
> +	unsigned long pkts =3D 0, bytes =3D 0, mcast =3D 0, drops =3D 0;
>  	int i;
> =20
> -	memset(dev_stats, 0, sizeof(*dev_stats));
>  	for_all_rx_queues(adapter, rxo, i) {
> -		dev_stats->rx_packets +=3D rx_stats(rxo)->rx_pkts;
> -		dev_stats->rx_bytes +=3D rx_stats(rxo)->rx_bytes;
> -		dev_stats->multicast +=3D rx_stats(rxo)->rx_mcast_pkts;
> +		pkts +=3D rx_stats(rxo)->rx_pkts;
> +		bytes +=3D rx_stats(rxo)->rx_bytes;
> +		mcast +=3D rx_stats(rxo)->rx_mcast_pkts;
>  		/*  no space in linux buffers: best possible approximation */
>  		if (adapter->generation =3D=3D BE_GEN3) {
>  			if (!(lancer_chip(adapter))) {
> -				struct be_erx_stats_v1 *erx_stats =3D
> +				struct be_erx_stats_v1 *erx =3D
>  					be_erx_stats_from_cmd(adapter);
> -				dev_stats->rx_dropped +=3D
> -				erx_stats->rx_drops_no_fragments[rxo->q.id];
> +				drops +=3D erx->rx_drops_no_fragments[rxo->q.id];
>  			}
>  		} else {
> -			struct be_erx_stats_v0 *erx_stats =3D
> +			struct be_erx_stats_v0 *erx =3D
>  					be_erx_stats_from_cmd(adapter);
> -			dev_stats->rx_dropped +=3D
> -				erx_stats->rx_drops_no_fragments[rxo->q.id];
> +			drops +=3D erx->rx_drops_no_fragments[rxo->q.id];
>  		}
>  	}
> +	dev_stats->rx_packets =3D pkts;
> +	dev_stats->rx_bytes =3D bytes;
> +	dev_stats->multicast =3D mcast;
> +	dev_stats->rx_dropped =3D drops;
> =20
> +	pkts =3D bytes =3D 0;
>  	for_all_tx_queues(adapter, txo, i) {
> -		dev_stats->tx_packets +=3D tx_stats(txo)->be_tx_pkts;
> -		dev_stats->tx_bytes +=3D tx_stats(txo)->be_tx_bytes;
> +		pkts +=3D tx_stats(txo)->be_tx_pkts;
> +		bytes +=3D tx_stats(txo)->be_tx_bytes;
>  	}
> +	dev_stats->tx_packets =3D pkts;
> +	dev_stats->tx_bytes =3D bytes;
> =20
>  	/* bad pkts received */
>  	dev_stats->rx_errors =3D drvs->rx_crc_errors +



Hmm, isnt it a patch I provided 10 days ago ?

I find very strange so few people are able to properly attribute work
today...




