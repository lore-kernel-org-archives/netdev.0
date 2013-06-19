From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 09/11] sfc: Prefetch RX skb header area
Date: Wed, 19 Jun 2013 15:36:29 -0700
Message-ID: <1371681389.3252.339.camel@edumazet-glaptop>
References: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
	 <1371680432.1956.116.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:39556 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935252Ab3FSWge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 18:36:34 -0400
Received: by mail-ee0-f47.google.com with SMTP id e49so3451350eek.20
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 15:36:33 -0700 (PDT)
In-Reply-To: <1371680432.1956.116.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 23:20 +0100, Ben Hutchings wrote:
> When we pre-allocate skbs, the sk_buff structures themselves will be
> cache-hot (having just been filled in) but the header area will be
> cache-cold.  The skb cache is small and we're likely to use each skb
> quite soon, so prefetch the start of the header area, where we will
> copy the headers, and the skb_shared_info structure, where we will
> store page fragments.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/ethernet/sfc/rx.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
> index a28f2fe..0dc4a80 100644
> --- a/drivers/net/ethernet/sfc/rx.c
> +++ b/drivers/net/ethernet/sfc/rx.c
> @@ -106,11 +106,17 @@ void efx_rx_config_page_split(struct efx_nic *efx)
>  
>  static void efx_refill_skb_cache(struct efx_rx_queue *rx_queue)
>  {
> +	struct sk_buff *skb;
>  	int i;
> +
>  	for (i = 0; i < SKB_CACHE_SIZE; ++i) {
> -		rx_queue->skb_cache[i] =
> -			netdev_alloc_skb(rx_queue->efx->net_dev,
> -					 EFX_SKB_HEADERS + EFX_PAGE_SKB_ALIGN);
> +		skb = netdev_alloc_skb(rx_queue->efx->net_dev,
> +				       EFX_SKB_HEADERS + EFX_PAGE_SKB_ALIGN);
> +		rx_queue->skb_cache[i] = skb;
> +		if (skb) {
> +			prefetch(skb->data);

This is really suspect.

This part will be dirtied anyway by the NIC once frame is received.

> +			prefetch(skb_shinfo(skb));
> +		}
>  	}
>  	rx_queue->skb_cache_next_unused = 0;
>  }
> 
> 

Quite frankly this cache sounds suspect to me.

Why is it needed only for sfc ?

Have you tried build_skb() instead ?
