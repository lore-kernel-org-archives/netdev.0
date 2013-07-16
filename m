From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/9] sfc: Increase size of RX SKB header area
Date: Tue, 16 Jul 2013 10:33:55 -0700
Message-ID: <1373996035.6097.5.camel@edumazet-glaptop>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
	 <1372104801.1896.32.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:34925 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932872Ab3GPRd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 13:33:58 -0400
Received: by mail-oa0-f50.google.com with SMTP id k7so1218558oag.23
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 10:33:58 -0700 (PDT)
In-Reply-To: <1372104801.1896.32.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-24 at 21:13 +0100, Ben Hutchings wrote:
> From: Jon Cooper <jcooper@solarflare.com>
> 
> This allows the SKB to hold the headers without reallocation more often.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/ethernet/sfc/rx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
> index b915e09..6efff3d 100644
> --- a/drivers/net/ethernet/sfc/rx.c
> +++ b/drivers/net/ethernet/sfc/rx.c
> @@ -36,7 +36,7 @@
>  #define EFX_RECYCLE_RING_SIZE_NOIOMMU (2 * EFX_RX_PREFERRED_BATCH)
>  
>  /* Size of buffer allocated for skb header area. */
> -#define EFX_SKB_HEADERS  64u
> +#define EFX_SKB_HEADERS  128u
>  
>  /* This is the percentage fill level below which new RX descriptors
>   * will be added to the RX descriptor ring.
> 

This patch brings performance decrease for tunnels, because it pulls
into skb->head 128 bytes worth of data.

This includes TCP payload, so GRO or TCP coalescing code is less
effective. Each MSS spans 2 memory areas (small part on skb->head,
remaining on the fragment) : GRO packets have only 8 MSS worth of data,
instead of 16.

The fix would be to allocate 128 bytes in skb->head to prevent future
reallocations of skb->head, but pull 64 bytes only.
