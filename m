From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH net] bgmac: stop clearing DMA receive control register
 right after it is set
Date: Mon, 31 Oct 2016 20:32:10 +0100
Message-ID: <a2be3a3b-f921-58e5-c24d-3ea1a557f345@hauke-m.de>
References: <1477935123-29638-1-git-send-email-gospo@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Andy Gospodarek <gospo@broadcom.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:42595 "EHLO mail.hauke-m.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933932AbcJaThT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 15:37:19 -0400
In-Reply-To: <1477935123-29638-1-git-send-email-gospo@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/31/2016 06:32 PM, Andy Gospodarek wrote:
> Current bgmac code initializes some DMA settings in the receive control
> register for some hardware and then immediately clears those settings.
> Not clearing those settings results in ~420Mbps *improvement* in
> throughput; this system can now receive frames at line-rate on Broadcom
> 5871x hardware compared to ~520Mbps today.  I also tested a few other
> values but found there to be no discernible difference in CPU
> utilization even if burst size and prefetching values are different.

I think these are the default values from the et driver.

> On the hardware tested there was no need to keep the code that cleared
> all but bits 16-17, but since there is a wide variety of hardware that
> used this driver (I did not look at all hardware docs for hardware using
> this IP block), I find it wise to move this call up and clear bits just
> after reading the default value from the hardware rather than completely
> removing it.
> 
> This is a good candidate for -stable >=3.14 since that is when the code
> that was supposed to improve performance (but did not) was introduced.
> 
> Signed-off-by: Andy Gospodarek <gospo@broadcom.com>
> Fixes: 56ceecde1f29 ("bgmac: initialize the DMA controller of core...")
> Cc: Hauke Mehrtens <hauke@hauke-m.de>

This patch looks correct.

We used this et driver as a documentation when writing the bgmac driver,
or a specification based on some older version:
https://github.com/RMerl/asuswrt-merlin/blob/master/release/src-rt-7.x.main/src/et/sys/etcgmac.c

This is probably the code used for the dma part:
https://github.com/RMerl/asuswrt-merlin/blob/master/release/src-rt-7.x.main/src/shared/hnddma.c#L1276

Acked-by: Hauke Mehrtens <hauke@hauke-m.de>

> ---
>  drivers/net/ethernet/broadcom/bgmac.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index 31ca204..91cbf92 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -307,6 +307,10 @@ static void bgmac_dma_rx_enable(struct bgmac *bgmac,
>  	u32 ctl;
>  
>  	ctl = bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_RX_CTL);
> +
> +	/* preserve ONLY bits 16-17 from current hardware value */
> +	ctl &= BGMAC_DMA_RX_ADDREXT_MASK;
> +
>  	if (bgmac->feature_flags & BGMAC_FEAT_RX_MASK_SETUP) {
>  		ctl &= ~BGMAC_DMA_RX_BL_MASK;
>  		ctl |= BGMAC_DMA_RX_BL_128 << BGMAC_DMA_RX_BL_SHIFT;
> @@ -317,7 +321,6 @@ static void bgmac_dma_rx_enable(struct bgmac *bgmac,
>  		ctl &= ~BGMAC_DMA_RX_PT_MASK;
>  		ctl |= BGMAC_DMA_RX_PT_1 << BGMAC_DMA_RX_PT_SHIFT;
>  	}
> -	ctl &= BGMAC_DMA_RX_ADDREXT_MASK;
>  	ctl |= BGMAC_DMA_RX_ENABLE;
>  	ctl |= BGMAC_DMA_RX_PARITY_DISABLE;
>  	ctl |= BGMAC_DMA_RX_OVERFLOW_CONT;
> 
