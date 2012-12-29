From: Andrew Vagin <avagin@parallels.com>
Subject: Re: Slow speed of tcp connections in a network namespace
Date: Sun, 30 Dec 2012 01:15:09 +0400
Message-ID: <20121229211508.GB4350@paralelels.com>
References: <20121229092417.GA4038@paralelels.com>
 <1356789203.21409.3923.camel@edumazet-glaptop>
 <20121229145030.GA7959@paralelels.com>
 <1356802828.21409.4623.camel@edumazet-glaptop>
 <1356807516.4102.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <vvs@parallels.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:33586 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149Ab2L2VPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 16:15:44 -0500
Content-Disposition: inline
In-Reply-To: <1356807516.4102.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 29, 2012 at 07:58:36PM +0100, Eric Dumazet wrote:
> Le samedi 29 d=C3=A9cembre 2012 =C3=A0 09:40 -0800, Eric Dumazet a =C3=
=A9crit :
>=20
> >=20
> > Please post your new tcpdump then ;)
> >=20
> > also post "netstat -s" from root and test ns after your wgets
>=20
> Also try following bnx2 patch.
>=20
> It should help GRO / TCP coalesce
>=20
> bnx2 should be the last driver not using skb head_frag
>=20

This patch breaks nothing. I don't know what kind of profit I should ge=
t
with it:).

=46YI:
I forgot to say, that I disable gro before collecting tcpdump, because
in this case tcpdump from veth and from eth0 can be compared easier.

>=20
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ether=
net/broadcom/bnx2.c
> index a1adfaf..08a2d40 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -2726,6 +2726,14 @@ bnx2_free_rx_page(struct bnx2 *bp, struct bnx2=
_rx_ring_info *rxr, u16 index)
>  	rx_pg->page =3D NULL;
>  }
> =20
> +static void bnx2_frag_free(const struct bnx2 *bp, void *data)
> +{
> +	if (bp->rx_frag_size)
> +		put_page(virt_to_head_page(data));
> +	else
> +		kfree(data);
> +}
> +
>  static inline int
>  bnx2_alloc_rx_data(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u=
16 index, gfp_t gfp)
>  {
> @@ -2735,7 +2743,10 @@ bnx2_alloc_rx_data(struct bnx2 *bp, struct bnx=
2_rx_ring_info *rxr, u16 index, gf
>  	struct bnx2_rx_bd *rxbd =3D
>  		&rxr->rx_desc_ring[BNX2_RX_RING(index)][BNX2_RX_IDX(index)];
> =20
> -	data =3D kmalloc(bp->rx_buf_size, gfp);
> +	if (bp->rx_frag_size)
> +		data =3D netdev_alloc_frag(bp->rx_frag_size);
> +	else
> +		data =3D kmalloc(bp->rx_buf_size, gfp);
>  	if (!data)
>  		return -ENOMEM;
> =20
> @@ -2744,7 +2755,7 @@ bnx2_alloc_rx_data(struct bnx2 *bp, struct bnx2=
_rx_ring_info *rxr, u16 index, gf
>  				 bp->rx_buf_use_size,
>  				 PCI_DMA_FROMDEVICE);
>  	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
> -		kfree(data);
> +		bnx2_frag_free(bp, data);
>  		return -EIO;
>  	}
> =20
> @@ -3014,9 +3025,9 @@ error:
> =20
>  	dma_unmap_single(&bp->pdev->dev, dma_addr, bp->rx_buf_use_size,
>  			 PCI_DMA_FROMDEVICE);
> -	skb =3D build_skb(data, 0);
> +	skb =3D build_skb(data, bp->rx_frag_size);
>  	if (!skb) {
> -		kfree(data);
> +		bnx2_frag_free(bp, data);
>  		goto error;
>  	}
>  	skb_reserve(skb, ((u8 *)get_l2_fhdr(data) - data) + BNX2_RX_OFFSET)=
;
> @@ -5358,6 +5369,10 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 siz=
e)
>  	/* hw alignment + build_skb() overhead*/
>  	bp->rx_buf_size =3D SKB_DATA_ALIGN(bp->rx_buf_use_size + BNX2_RX_AL=
IGN) +
>  		NET_SKB_PAD + SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> +	if (bp->rx_buf_size <=3D PAGE_SIZE)
> +		bp->rx_frag_size =3D bp->rx_buf_size;
> +	else
> +		bp->rx_frag_size =3D 0;
>  	bp->rx_jumbo_thresh =3D rx_size - BNX2_RX_OFFSET;
>  	bp->rx_ring_size =3D size;
>  	bp->rx_max_ring =3D bnx2_find_max_ring(size, BNX2_MAX_RX_RINGS);
> @@ -5436,7 +5451,7 @@ bnx2_free_rx_skbs(struct bnx2 *bp)
> =20
>  			rx_buf->data =3D NULL;
> =20
> -			kfree(data);
> +			bnx2_frag_free(bp, data);
>  		}
>  		for (j =3D 0; j < bp->rx_max_pg_ring_idx; j++)
>  			bnx2_free_rx_page(bp, rxr, j);
> diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ether=
net/broadcom/bnx2.h
> index 172efbe..11f5dee 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.h
> +++ b/drivers/net/ethernet/broadcom/bnx2.h
> @@ -6804,6 +6804,7 @@ struct bnx2 {
> =20
>  	u32			rx_buf_use_size;	/* useable size */
>  	u32			rx_buf_size;		/* with alignment */
> +	u32			rx_frag_size; /* 0 if kmalloced(), or rx_buf_size */
>  	u32			rx_copy_thresh;
>  	u32			rx_jumbo_thresh;
>  	u32			rx_max_ring_idx;
>=20
>=20
