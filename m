From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 05/11] fec_mpc52xx: enable transmit and receive time
 stamping.
Date: Sun, 19 Jun 2011 13:56:11 +0200
Message-ID: <1308484571.3539.73.camel@edumazet-laptop>
References: <cover.1308481491.git.richard.cochran@omicron.at>
	 <69af31599bdb8e8af02028ae37b9c84dd1436741.1308481492.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54703 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644Ab1FSL4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 07:56:20 -0400
Received: by wyb38 with SMTP id 38so1117409wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 04:56:18 -0700 (PDT)
In-Reply-To: <69af31599bdb8e8af02028ae37b9c84dd1436741.1308481492.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 19 juin 2011 =C3=A0 13:20 +0200, Richard Cochran a =C3=A9cr=
it :
> This patch enables software (and phy device) time stamping. Software
> time stamping using the SO_TIMESTAMPING API was tested and found to b=
e
> working on the LITE5200B board.
>=20
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  drivers/net/fec_mpc52xx.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
> index 9f81b1a..102bdbc 100644
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -337,6 +337,7 @@ static int mpc52xx_fec_start_xmit(struct sk_buff =
*skb, struct net_device *dev)
> =20
>  	bcom_submit_next_buffer(priv->tx_dmatsk, skb);
>  	spin_unlock_irqrestore(&priv->lock, flags);

same problem here : You should call skb_tx_timestamp() before the lock
release, or an interrupt might already freed this skb.

> +	skb_tx_timestamp(skb);
> =20
>  	if (bcom_queue_full(priv->tx_dmatsk)) {
>  		netif_stop_queue(dev);
> @@ -434,7 +435,8 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int i=
rq, void *dev_id)
>  		length =3D status & BCOM_FEC_RX_BD_LEN_MASK;
>  		skb_put(rskb, length - 4);	/* length without CRC32 */
>  		rskb->protocol =3D eth_type_trans(rskb, dev);
> -		netif_rx(rskb);
> +		if (!skb_defer_rx_timestamp(skb))
> +			netif_rx(rskb);
> =20
>  		spin_lock(&priv->lock);
>  	}


