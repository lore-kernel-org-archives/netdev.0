From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 10/12] bna: TX Queue Depth Fix
Date: Wed, 31 Aug 2011 06:24:30 +0200
Message-ID: <1314764670.2556.23.camel@edumazet-laptop>
References: <1314754068-31978-1-git-send-email-rmody@brocade.com>
	 <1314754068-31978-11-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	adapter_linux_open_src_team@brocade.com,
	Gurunatha Karaje <gkaraje@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33475 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792Ab1HaEYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 00:24:36 -0400
Received: by wyg24 with SMTP id 24so214564wyg.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 21:24:35 -0700 (PDT)
In-Reply-To: <1314754068-31978-11-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 ao=C3=BBt 2011 =C3=A0 18:27 -0700, Rasesh Mody a =C3=A9crit=
 :
> sk_buff unmap_array grows greater than 65536 (x2) with Tx ring of 655=
36.
> Reducing TXQ depth and safe(max) acking of Tx events to 32768 (same a=
s Rx).
> Add defines for TX and RX queue depths.
>=20
> Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>  drivers/net/ethernet/brocade/bna/bnad.h         |    4 ++++
>  drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    8 ++++----
>  2 files changed, 8 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/et=
hernet/brocade/bna/bnad.h
> index 0c9d736..6c42c14 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad.h
> +++ b/drivers/net/ethernet/brocade/bna/bnad.h
> @@ -86,6 +86,10 @@ struct bnad_rx_ctrl {
>  #define BNAD_MAX_Q_DEPTH		0x10000
>  #define BNAD_MIN_Q_DEPTH		0x200
> =20
> +#define BNAD_MAX_RXQ_DEPTH		(BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq)
> +/* keeping MAX TX and RX Q depth equal */
> +#define BNAD_MAX_TXQ_DEPTH		BNAD_MAX_RXQ_DEPTH
> +
>  #define BNAD_JUMBO_MTU			9000
> =20
>  #define BNAD_NETIF_WAKE_THRESHOLD	8
> diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/driver=
s/net/ethernet/brocade/bna/bnad_ethtool.c
> index 96ff700..4842224 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
> +++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
> @@ -418,10 +418,10 @@ bnad_get_ringparam(struct net_device *netdev,
>  {
>  	struct bnad *bnad =3D netdev_priv(netdev);
> =20
> -	ringparam->rx_max_pending =3D BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq;
> +	ringparam->rx_max_pending =3D BNAD_MAX_RXQ_DEPTH;
>  	ringparam->rx_mini_max_pending =3D 0;
>  	ringparam->rx_jumbo_max_pending =3D 0;
> -	ringparam->tx_max_pending =3D BNAD_MAX_Q_DEPTH;
> +	ringparam->tx_max_pending =3D BNAD_MAX_TXQ_DEPTH;
> =20
>  	ringparam->rx_pending =3D bnad->rxq_depth;
>  	ringparam->rx_mini_max_pending =3D 0;
> @@ -445,13 +445,13 @@ bnad_set_ringparam(struct net_device *netdev,
>  	}
> =20
>  	if (ringparam->rx_pending < BNAD_MIN_Q_DEPTH ||
> -	    ringparam->rx_pending > BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq ||
> +	    ringparam->rx_pending > BNAD_MAX_RXQ_DEPTH ||
>  	    !BNA_POWER_OF_2(ringparam->rx_pending)) {
>  		mutex_unlock(&bnad->conf_mutex);
>  		return -EINVAL;
>  	}
>  	if (ringparam->tx_pending < BNAD_MIN_Q_DEPTH ||
> -	    ringparam->tx_pending > BNAD_MAX_Q_DEPTH ||
> +	    ringparam->tx_pending > BNAD_MAX_TXQ_DEPTH ||
>  	    !BNA_POWER_OF_2(ringparam->tx_pending)) {
>  		mutex_unlock(&bnad->conf_mutex);
>  		return -EINVAL;

BNAD_MAX_Q_DEPTH is now defined but not used.

BTW, 32768 slots in a RX queue is insane.
