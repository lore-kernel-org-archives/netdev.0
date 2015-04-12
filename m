From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] bgmac: fix DMA rx corruption
Date: Sun, 12 Apr 2015 03:31:15 -0700
Message-ID: <1428834675.25985.344.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428833292-15356-1-git-send-email-nbd@openwrt.org>
	 <1428833292-15356-4-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34466 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbbDLKbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 06:31:17 -0400
Received: by iedfl3 with SMTP id fl3so52706750ied.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 03:31:17 -0700 (PDT)
In-Reply-To: <1428833292-15356-4-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-04-12 at 12:08 +0200, Felix Fietkau wrote:
> The driver needs to inform the hardware about the first invalid (not yet
> filled) rx slot, by writing its DMA descriptor pointer offset to the
> BGMAC_DMA_RX_INDEX register.
> 
> This register was set to a value exceeding the rx ring size, effectively
> allowing the hardware constant access to the full ring, regardless of
> which slots are initialized.
> 
> Fix this by updating the register in bgmac_dma_rx_setup_desc.
> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> ---
>  drivers/net/ethernet/broadcom/bgmac.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index e332de8..856ceee 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -380,6 +380,12 @@ static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
>  	dma_desc->addr_high = cpu_to_le32(upper_32_bits(ring->slots[desc_idx].dma_addr));
>  	dma_desc->ctl0 = cpu_to_le32(ctl0);
>  	dma_desc->ctl1 = cpu_to_le32(ctl1);
> +
> +	desc_idx = (desc_idx + 1) % BGMAC_RX_RING_SLOTS;
> +
> +	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
> +			ring->index_base +
> +			desc_idx * sizeof(struct bgmac_dma_desc));
>  }
>  
>  static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
> @@ -394,9 +400,7 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
>  	end_slot &= BGMAC_DMA_RX_STATDPTR;
>  	end_slot /= sizeof(struct bgmac_dma_desc);
>  
> -	ring->end = end_slot;
> -
> -	while (ring->start != ring->end) {
> +	while (ring->start != end_slot) {
>  		struct device *dma_dev = bgmac->core->dma_dev;
>  		struct bgmac_slot_info *slot = &ring->slots[ring->start];
>  		struct bgmac_rx_header *rx = slot->buf + BGMAC_RX_BUF_OFFSET;
> @@ -693,10 +697,6 @@ static void bgmac_dma_init(struct bgmac *bgmac)
>  		for (j = 0; j < ring->num_slots; j++)
>  			bgmac_dma_rx_setup_desc(bgmac, ring, j);
>  

Missing dma_wmb() here  (or legacy wmb() for stable kernels)

> -		bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
> -			    ring->index_base +
> -			    ring->num_slots * sizeof(struct bgmac_dma_desc));
> -


This might be better for performance to perform one single bgmac_write()
at the end of bgmac_dma_rx_read(), and leave this one in place as well,
not for performance since this is slow path, but correctness.

Also I am surprised there is no memory barrier to make sure changes to
dma_desc are committed to memory ?

I would use dma_wmb() before bgmac_write(), like the wmb() done in
bgmac_dma_tx_add()

Thanks
