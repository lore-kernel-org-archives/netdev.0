From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/1] net: macb: remove BUG_ON() and reset the queue to
 handle RX errors
Date: Thu, 24 Mar 2016 16:42:57 +0100
Message-ID: <56F40B01.2050000@atmel.com>
References: <1458830232-6159-1-git-send-email-cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>, <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:33230 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754728AbcCXPm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 11:42:57 -0400
In-Reply-To: <1458830232-6159-1-git-send-email-cyrille.pitchen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/03/2016 15:37, Cyrille Pitchen a =E9crit :
> This patch removes two BUG_ON() used to notify about RX queue corrupt=
ions
> on macb (not gem) hardware without actually handling the error.
>=20
> The new code skips corrupted frames but still processes faultless fra=
mes.
> Then it resets the RX queue before restarting the reception from a cl=
ean
> state.
>=20
> This patch is a rework of an older patch proposed by Neil Armstrong:
> http://patchwork.ozlabs.org/patch/371525/
>=20
> Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>

Thanks for this rework of Neil's patch that was standing for a long tim=
e
in my backlog ;-).

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Bye,

> ---
>  drivers/net/ethernet/cadence/macb.c | 59 +++++++++++++++++++++++++++=
+++-------
>  1 file changed, 49 insertions(+), 10 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 6619178ed77b..39447a337149 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -917,7 +917,10 @@ static int macb_rx_frame(struct macb *bp, unsign=
ed int first_frag,
>  		unsigned int frag_len =3D bp->rx_buffer_size;
> =20
>  		if (offset + frag_len > len) {
> -			BUG_ON(frag !=3D last_frag);
> +			if (unlikely(frag !=3D last_frag)) {
> +				dev_kfree_skb_any(skb);
> +				return -1;
> +			}
>  			frag_len =3D len - offset;
>  		}
>  		skb_copy_to_linear_data_offset(skb, offset,
> @@ -945,11 +948,26 @@ static int macb_rx_frame(struct macb *bp, unsig=
ned int first_frag,
>  	return 0;
>  }
> =20
> +static inline void macb_init_rx_ring(struct macb *bp)
> +{
> +	int i;
> +	dma_addr_t addr;
> +
> +	addr =3D bp->rx_buffers_dma;
> +	for (i =3D 0; i < RX_RING_SIZE; i++) {
> +		bp->rx_ring[i].addr =3D addr;
> +		bp->rx_ring[i].ctrl =3D 0;
> +		addr +=3D bp->rx_buffer_size;
> +	}
> +	bp->rx_ring[RX_RING_SIZE - 1].addr |=3D MACB_BIT(RX_WRAP);
> +}
> +
>  static int macb_rx(struct macb *bp, int budget)
>  {
>  	int received =3D 0;
>  	unsigned int tail;
>  	int first_frag =3D -1;
> +	int reset_rx_queue =3D 0;
> =20
>  	for (tail =3D bp->rx_tail; budget > 0; tail++) {
>  		struct macb_dma_desc *desc =3D macb_rx_desc(bp, tail);
> @@ -972,10 +990,18 @@ static int macb_rx(struct macb *bp, int budget)
> =20
>  		if (ctrl & MACB_BIT(RX_EOF)) {
>  			int dropped;
> -			BUG_ON(first_frag =3D=3D -1);
> +
> +			if (unlikely(first_frag =3D=3D -1)) {
> +				reset_rx_queue =3D 1;
> +				continue;
> +			}
> =20
>  			dropped =3D macb_rx_frame(bp, first_frag, tail);
>  			first_frag =3D -1;
> +			if (unlikely(dropped < 0)) {
> +				reset_rx_queue =3D 1;
> +				continue;
> +			}
>  			if (!dropped) {
>  				received++;
>  				budget--;
> @@ -983,6 +1009,26 @@ static int macb_rx(struct macb *bp, int budget)
>  		}
>  	}
> =20
> +	if (unlikely(reset_rx_queue)) {
> +		unsigned long flags;
> +		u32 ctrl;
> +
> +		netdev_err(bp->dev, "RX queue corruption: reset it\n");
> +
> +		spin_lock_irqsave(&bp->lock, flags);
> +
> +		ctrl =3D macb_readl(bp, NCR);
> +		macb_writel(bp, NCR, ctrl & ~MACB_BIT(RE));
> +
> +		macb_init_rx_ring(bp);
> +		macb_writel(bp, RBQP, bp->rx_ring_dma);
> +
> +		macb_writel(bp, NCR, ctrl | MACB_BIT(RE));
> +
> +		spin_unlock_irqrestore(&bp->lock, flags);
> +		return received;
> +	}
> +
>  	if (first_frag !=3D -1)
>  		bp->rx_tail =3D first_frag;
>  	else
> @@ -1523,15 +1569,8 @@ static void gem_init_rings(struct macb *bp)
>  static void macb_init_rings(struct macb *bp)
>  {
>  	int i;
> -	dma_addr_t addr;
> =20
> -	addr =3D bp->rx_buffers_dma;
> -	for (i =3D 0; i < RX_RING_SIZE; i++) {
> -		bp->rx_ring[i].addr =3D addr;
> -		bp->rx_ring[i].ctrl =3D 0;
> -		addr +=3D bp->rx_buffer_size;
> -	}
> -	bp->rx_ring[RX_RING_SIZE - 1].addr |=3D MACB_BIT(RX_WRAP);
> +	macb_init_rx_ring(bp);
> =20
>  	for (i =3D 0; i < TX_RING_SIZE; i++) {
>  		bp->queues[0].tx_ring[i].addr =3D 0;
>=20


--=20
Nicolas Ferre
