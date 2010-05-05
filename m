From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next 2/3] bnx2: Add prefetches to rx path.
Date: Wed, 05 May 2010 07:45:30 +0200
Message-ID: <1273038330.2304.10.camel@edumazet-laptop>
References: <1273036906-29162-1-git-send-email-mchan@broadcom.com>
	 <1273036906-29162-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:55676 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282Ab0EEFpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 01:45:36 -0400
Received: by bwz25 with SMTP id 25so2681453bwz.28
        for <netdev@vger.kernel.org>; Tue, 04 May 2010 22:45:34 -0700 (PDT)
In-Reply-To: <1273036906-29162-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 mai 2010 =C3=A0 22:21 -0700, Michael Chan a =C3=A9crit :
> Add prefetches of the skb and the next rx descriptor to speed up rx p=
ath.
>=20
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> ---
>  drivers/net/bnx2.c |   12 +++++++++---
>  drivers/net/bnx2.h |    1 +
>  2 files changed, 10 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 6ad3184..cdee29b 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -2719,6 +2719,7 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_=
rx_ring_info *rxr, u16 index)
>  	}
> =20
>  	rx_buf->skb =3D skb;
> +	rx_buf->desc =3D (struct l2_fhdr *) skb->data;
>  	dma_unmap_addr_set(rx_buf, mapping, mapping);
> =20
>  	rxbd->rx_bd_haddr_hi =3D (u64) mapping >> 32;
> @@ -2941,6 +2942,7 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_=
rx_ring_info *rxr,
>  	rxr->rx_prod_bseq +=3D bp->rx_buf_use_size;
> =20
>  	prod_rx_buf->skb =3D skb;
> +	prod_rx_buf->desc =3D (struct l2_fhdr *) skb->data;
> =20
>  	if (cons =3D=3D prod)
>  		return;
> @@ -3086,7 +3088,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *=
bnapi, int budget)
>  	while (sw_cons !=3D hw_cons) {
>  		unsigned int len, hdr_len;
>  		u32 status;
> -		struct sw_bd *rx_buf;
> +		struct sw_bd *rx_buf, *next_rx_buf;
>  		struct sk_buff *skb;
>  		dma_addr_t dma_addr;
>  		u16 vtag =3D 0;
> @@ -3097,7 +3099,11 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi =
*bnapi, int budget)
> =20
>  		rx_buf =3D &rxr->rx_buf_ring[sw_ring_cons];
>  		skb =3D rx_buf->skb;
> +		prefetch(skb);

why not a prefetchw() ?

> =20
> +		next_rx_buf =3D
> +			&rxr->rx_buf_ring[RX_RING_IDX(NEXT_RX_BD(sw_cons))];
> +		prefetch(next_rx_buf->desc);

So cpu is allowed to start a memory transaction on next_skb->data, whil=
e
not yes DMA unmapped ?

>  		rx_buf->skb =3D NULL;
> =20
>  		dma_addr =3D dma_unmap_addr(rx_buf, mapping);
> @@ -3106,7 +3112,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *=
bnapi, int budget)
>  			BNX2_RX_OFFSET + BNX2_RX_COPY_THRESH,
>  			PCI_DMA_FROMDEVICE);
> =20
> -		rx_hdr =3D (struct l2_fhdr *) skb->data;
> +		rx_hdr =3D rx_buf->desc;
>  		len =3D rx_hdr->l2_fhdr_pkt_len;
>  		status =3D rx_hdr->l2_fhdr_status;
> =20
> @@ -5764,7 +5770,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback=
_mode)
>  	rx_buf =3D &rxr->rx_buf_ring[rx_start_idx];
>  	rx_skb =3D rx_buf->skb;
> =20
> -	rx_hdr =3D (struct l2_fhdr *) rx_skb->data;
> +	rx_hdr =3D rx_buf->desc;
>  	skb_reserve(rx_skb, BNX2_RX_OFFSET);
> =20
>  	pci_dma_sync_single_for_cpu(bp->pdev,
> diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
> index ab34a5d..dd35bd0 100644
> --- a/drivers/net/bnx2.h
> +++ b/drivers/net/bnx2.h
> @@ -6551,6 +6551,7 @@ struct l2_fhdr {
> =20
>  struct sw_bd {
>  	struct sk_buff		*skb;
> +	struct l2_fhdr		*desc;
>  	DEFINE_DMA_UNMAP_ADDR(mapping);
>  };
> =20

It seems there are two parts in this patch, one caching skb->data in
sw_bd, and prefetches...



