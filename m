From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] mv643xx_eth: hook up skb recycling
Date: Wed, 03 Sep 2008 16:25:34 +0200
Message-ID: <48BE9E5E.2010702@cosmosbay.com>
References: <1220450101-21317-1-git-send-email-buytenh@wantstofly.org> <1220450101-21317-3-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.113]:48126 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691AbYICO3e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 10:29:34 -0400
In-Reply-To: <1220450101-21317-3-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek a =E9crit :
> This increases the maximum loss-free packet forwarding rate in
> routing workloads by typically about 25%.
>=20
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
>


Interesting...

>  	refilled =3D 0;
>  	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size)=
 {
>  		struct sk_buff *skb;
>  		int unaligned;
>  		int rx;
> =20
> -		skb =3D dev_alloc_skb(skb_size + dma_get_cache_alignment() - 1);
> +		skb =3D __skb_dequeue(&mp->rx_recycle);

Here you take one skb at the head of queue

> +		if (skb =3D=3D NULL)
> +			skb =3D dev_alloc_skb(mp->skb_size +
> +					    dma_get_cache_alignment() - 1);
> +
>  		if (skb =3D=3D NULL) {
>  			mp->work_rx_oom |=3D 1 << rxq->index;
>  			goto oom;
> @@ -600,8 +591,8 @@ static int rxq_refill(struct rx_queue *rxq, int b=
udget)
>  			rxq->rx_used_desc =3D 0;
> =20
>  		rxq->rx_desc_area[rx].buf_ptr =3D dma_map_single(NULL, skb->data,
> -						skb_size, DMA_FROM_DEVICE);
> -		rxq->rx_desc_area[rx].buf_size =3D skb_size;
> +						mp->skb_size, DMA_FROM_DEVICE);
> +		rxq->rx_desc_area[rx].buf_size =3D mp->skb_size;
>  		rxq->rx_skb[rx] =3D skb;
>  		wmb();
>  		rxq->rx_desc_area[rx].cmd_sts =3D BUFFER_OWNED_BY_DMA |
> @@ -905,8 +896,13 @@ static int txq_reclaim(struct tx_queue *txq, int=
 budget, int force)
>  		else
>  			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
> =20
> -		if (skb)
> -			dev_kfree_skb(skb);
> +		if (skb !=3D NULL) {
> +			if (skb_queue_len(&mp->rx_recycle) < 1000 &&
> +			    skb_recycle_check(skb, mp->skb_size))
> +				__skb_queue_tail(&mp->rx_recycle, skb);
> +			else
> +				dev_kfree_skb(skb);
> +		}

Here you put a skb at the head of queue. So you use a FIFO mode.

To have best performance (cpu cache hot), you might try to use a LIFO m=
ode (use __skb_queue_head()) ?

Could you give us your actual bench results (number of packets received=
 per second, number of transmited packets per second),=20
and your machine setup.

Thank you



