From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 03/11] emaclite: enable transmit and receive time
 stamping.
Date: Sun, 19 Jun 2011 13:53:41 +0200
Message-ID: <1308484421.3539.71.camel@edumazet-laptop>
References: <cover.1308481491.git.richard.cochran@omicron.at>
	 <47d1af192e2a51722c2d93b78d9c25de1116e82a.1308481492.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	John Linn <john.linn@xilinx.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51756 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551Ab1FSLxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 07:53:51 -0400
Received: by wyb38 with SMTP id 38so1116796wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 04:53:50 -0700 (PDT)
In-Reply-To: <47d1af192e2a51722c2d93b78d9c25de1116e82a.1308481492.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 19 juin 2011 =C3=A0 13:19 +0200, Richard Cochran a =C3=A9cr=
it :
> This patch enables software (and phy device) time stamping. Since thi=
s
> MAC uses phylib, adding the hooks make hardware time stamping in the =
phy
> possible.
>=20
> Compile tested only.
>=20
> Cc: John Linn <john.linn@xilinx.com>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  drivers/net/xilinx_emaclite.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emacl=
ite.c
> index 372572c..ae029d0 100644
> --- a/drivers/net/xilinx_emaclite.c
> +++ b/drivers/net/xilinx_emaclite.c
> @@ -647,7 +647,8 @@ static void xemaclite_rx_handler(struct net_devic=
e *dev)
>  	dev->stats.rx_packets++;
>  	dev->stats.rx_bytes +=3D len;
> =20
> -	netif_rx(skb);		/* Send the packet upstream */
> +	if (!skb_defer_rx_timestamp(skb))
> +		netif_rx(skb);	/* Send the packet upstream */
>  }
> =20
>  /**
> @@ -1029,15 +1030,19 @@ static int xemaclite_send(struct sk_buff *ori=
g_skb, struct net_device *dev)
>  	spin_lock_irqsave(&lp->reset_lock, flags);
>  	if (xemaclite_send_data(lp, (u8 *) new_skb->data, len) !=3D 0) {
>  		/* If the Emaclite Tx buffer is busy, stop the Tx queue and
> -		 * defer the skb for transmission at a later point when the
> +		 * defer the skb for transmission during the ISR, after the
>  		 * current transmission is complete */
>  		netif_stop_queue(dev);
>  		lp->deferred_skb =3D new_skb;
>  		spin_unlock_irqrestore(&lp->reset_lock, flags);

Since you unlock reset_lock right here, there is no guarantee something
wont eat 'deferred_skb', so you might manipulate a freed skb after this
point.

> +		/* Take the time stamp now, since we can't do this in an ISR. */
> +		skb_tx_timestamp(new_skb);
>  		return 0;
>  	}
>  	spin_unlock_irqrestore(&lp->reset_lock, flags);
> =20
> +	skb_tx_timestamp(new_skb);
> +

this one is ok.

>  	dev->stats.tx_bytes +=3D len;
>  	dev_kfree_skb(new_skb);
> =20



