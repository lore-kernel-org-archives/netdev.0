From: Jakub =?UTF-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Subject: Re: [PATCH 4/4] bgmac: fix DMA rx corruption
Date: Sun, 12 Apr 2015 12:31:34 +0200
Message-ID: <20150412123134.3e1c4fea@north>
References: <1428833292-15356-1-git-send-email-nbd@openwrt.org>
	<1428833292-15356-4-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:28285 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbbDLKiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Apr 2015 06:38:16 -0400
In-Reply-To: <1428833292-15356-4-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Apr 2015 12:08:12 +0200, Felix Fietkau wrote:
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

Newb question if I may: why is no mem barrier necessary in this case?
