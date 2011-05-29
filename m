From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: ep93xx_eth: drop GFP_DMA from memory allocations
Date: Sun, 29 May 2011 11:38:25 +0100
Message-ID: <20110529103825.GZ24876@n2100.arm.linux.org.uk>
References: <1306659837-23553-1-git-send-email-mika.westerberg@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hsweeten@visionengravers.com,
	ryan@bluewatersys.com, kernel@wantstofly.org,
	linux-arm-kernel@lists.infradead.org
To: Mika Westerberg <mika.westerberg@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:54034 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035Ab1E2Kij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2011 06:38:39 -0400
Content-Disposition: inline
In-Reply-To: <1306659837-23553-1-git-send-email-mika.westerberg@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 29, 2011 at 12:03:57PM +0300, Mika Westerberg wrote:
> diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
> index 5a77001..e495f76 100644
> --- a/drivers/net/arm/ep93xx_eth.c
> +++ b/drivers/net/arm/ep93xx_eth.c
> @@ -494,7 +494,7 @@ static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
>  	int i;
>  
>  	ep->descs = dma_alloc_coherent(NULL, sizeof(struct ep93xx_descs),
> -				&ep->descs_dma_addr, GFP_KERNEL | GFP_DMA);
> +				&ep->descs_dma_addr, GFP_KERNEL);

This one is correct anyway - whether the allocation comes from the DMA
zone or not is something which should be controlled by the DMA mask and
not the driver passing random GFP flags to dma_alloc_coherent.

However, because it is passing a NULL device to dma_alloc_coherent(), it
assumes that it is for an old ISA device, and so will continue to perform
a GFP_DMA allocation.  The solution - pass a struct device and set the
DMA masks correctly.

> @@ -525,7 +525,7 @@ static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
>  		void *page;
>  		dma_addr_t d;
>  
> -		page = (void *)__get_free_page(GFP_KERNEL | GFP_DMA);
> +		page = (void *)__get_free_page(GFP_KERNEL);
>  		if (page == NULL)
>  			goto err;
>  

Wow, just looked at what this driver is doing with the DMA buffer handling,
and I'm wondering how come its soo broken.

So, to summarize what its doing:

1. It allocates buffers for rx and tx.
2. It maps them with dma_map_single().
	This transfers ownership of the buffer to the DMA device.
3. In ep93xx_xmit,
3a. It copies the data into the buffer with skb_copy_and_csum_dev()
	This violates the DMA buffer ownership rules - the CPU should
	not be writing to this buffer while it is (in principle) owned
	by the DMA device.
3b. It then calls dma_sync_single_for_cpu() for the buffer.
	This transfers ownership of the buffer to the CPU, which surely
	is the wrong direction.
4. In ep93xx_rx,
4a. It calls dma_sync_single_for_cpu() for the buffer.
	This at least transfers the DMA buffer ownership to the CPU
	before the CPU reads the buffer
4b. It then uses skb_copy_to_linear_data() to copy the data out.
	At no point does it transfer ownership back to the DMA device.
5. When the driver is removed, it dma_unmap_single()'s the buffer.
	This transfers ownership of the buffer to the CPU.
6. It frees the buffer.

While it may work on ep93xx, it's not respecting the DMA API rules,
and with DMA debugging enabled it will probably encounter quite a few
warnings.
