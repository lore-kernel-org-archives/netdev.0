From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 4/4] bgmac: fix DMA rx corruption
Date: Sun, 12 Apr 2015 11:09:42 -0700
Message-ID: <1428862182.25985.354.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428848565-94187-1-git-send-email-nbd@openwrt.org>
	 <1428848565-94187-4-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:32997 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbbDLSJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 14:09:45 -0400
Received: by iebmp1 with SMTP id mp1so50015376ieb.0
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 11:09:44 -0700 (PDT)
In-Reply-To: <1428848565-94187-4-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-04-12 at 16:22 +0200, Felix Fietkau wrote:
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
>  drivers/net/ethernet/broadcom/bgmac.c | 27 ++++++++++++++++++---------
>  1 file changed, 18 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index e332de8..67993d7 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -362,6 +362,16 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
>  	return 0;
>  }
>  
> +static void bgmac_dma_rx_update_index(struct bgmac *bgmac,
> +				      struct bgmac_dma_ring *ring)
> +{
> +	dma_wmb();
> +
> +	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
> +		    ring->index_base +
> +		    ring->end * sizeof(struct bgmac_dma_desc));
> +}
> +
>  static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
>  				    struct bgmac_dma_ring *ring, int desc_idx)
>  {
> @@ -380,6 +390,8 @@ static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
>  	dma_desc->addr_high = cpu_to_le32(upper_32_bits(ring->slots[desc_idx].dma_addr));
>  	dma_desc->ctl0 = cpu_to_le32(ctl0);
>  	dma_desc->ctl1 = cpu_to_le32(ctl1);
> +
> +	ring->end = (desc_idx + 1) % BGMAC_RX_RING_SLOTS;

Given the fact that previous driver kind of worked, have you tried not
doing the modulo at all here ?

ring->end = desc_idx + 1;

It looks like the hardware accepted setting BGMAC_DMA_RX_INDEX to
ring->index_base + ring->num_slots * sizeof(struct bgmac_dma_desc)

So apparently the presence of BGMAC_DESC_CTL0_EOT in last rx desc was
enough to avoid any problem with this.

Thanks
