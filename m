From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v4 05/10] net/fec: add dual fec support for mx28
Date: Thu, 13 Jan 2011 22:06:00 +0100
Message-ID: <20110113210600.GY24920@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-6-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, gerg@snapgear.com, baruch@tkos.co.il,
	eric@eukrea.com, bryan.wu@canonical.com, r64343@freescale.com,
	B32542@freescale.com, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de, jamie@jamieiles.com,
	jamie@shareable.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55291 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064Ab1AMVGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 16:06:18 -0500
Content-Disposition: inline
In-Reply-To: <1294297998-26930-6-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello again,

On Thu, Jan 06, 2011 at 03:13:13PM +0800, Shawn Guo wrote:
>  static netdev_tx_t
>  fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct fec_enet_private *fep =3D netdev_priv(dev);
> +	const struct platform_device_id *id_entry =3D
> +				platform_get_device_id(fep->pdev);
>  	struct bufdesc *bdp;
>  	void *bufaddr;
>  	unsigned short	status;
> @@ -256,6 +288,14 @@ fec_enet_start_xmit(struct sk_buff *skb, struct =
net_device *dev)
>  		bufaddr =3D fep->tx_bounce[index];
>  	}
> =20
> +	/*
> +	 * Some design made an incorrect assumption on endian mode of
> +	 * the system that it's running on. As the result, driver has to
> +	 * swap every frame going to and coming from the controller.
> +	 */
> +	if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
> +		swap_buffer(bufaddr, skb->len);
> +
Is that save here?  bufaddr either points to a bounce buffer (which
should be OK definitely) or skb->data.  Or asked differently:  Is the
skb here owned by the driver such that it is allowed to write to it?
Does the driver eventually need to restore the original data?

Just before this if, there is some bounce buffer handling.  If it is no=
t
OK to modify skb->data, the call to swap_buffer can easily be moved in
there.

>  	/* Save skb pointer */
>  	fep->tx_skbuff[fep->skb_cur] =3D skb;
> =20
> @@ -424,6 +464,8 @@ static void
>  fec_enet_rx(struct net_device *dev)
>  {
>  	struct	fec_enet_private *fep =3D netdev_priv(dev);
> +	const struct platform_device_id *id_entry =3D
> +				platform_get_device_id(fep->pdev);
>  	struct bufdesc *bdp;
>  	unsigned short status;
>  	struct	sk_buff	*skb;
> @@ -487,6 +529,9 @@ fec_enet_rx(struct net_device *dev)
>  	        dma_unmap_single(NULL, bdp->cbd_bufaddr, bdp->cbd_datlen,
>          			DMA_FROM_DEVICE);
> =20
> +		if (id_entry->driver_data & FEC_QUIRK_SWAP_FRAME)
> +			swap_buffer(data, pkt_len);
> +
Here I guess it's OK, the hardware just wrote to the buffer, so the skb
cannot be shared to anything else and the write is all right.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
