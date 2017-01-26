From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] Fix 64 bit addressing support for GEM
Date: Thu, 26 Jan 2017 10:00:47 -0800
Message-ID: <6a723b9f-507b-8348-d96c-e34e2261bcd1@gmail.com>
References: <1485442837-26598-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Rafal Ozieblo <rafalo@cadence.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        harinikatakamlinux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34306 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754101AbdAZSDK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:03:10 -0500
In-Reply-To: <1485442837-26598-1-git-send-email-rafalo@cadence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/2017 07:00 AM, Rafal Ozieblo wrote:
> This patch adds support for 32 bit GEM in
> 64 bit system. It checks capability at runtime
> and uses appropriate buffer descriptor.
> 
> Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>
> ---
>  static void *macb_rx_buffer(struct macb *bp, unsigned int index)
> @@ -560,12 +595,32 @@ static void macb_tx_unmap(struct macb *bp, struct macb_tx_skb *tx_skb)
>  	}
>  }
>  
> -static inline void macb_set_addr(struct macb_dma_desc *desc, dma_addr_t addr)
> +static void macb_set_addr(struct macb *bp, struct macb_dma_desc *desc, dma_addr_t addr)
>  {
> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> +	struct macb_dma_desc_64 *desc_64;
> +
> +	if (bp->hw_dma_cap == HW_DMA_CAP_64B) {
> +		desc_64 = macb_64b_desc(bp, desc);
> +		desc_64->addrh = (u32)(addr >> 32);

Are there specific ordering between the low and high halves of the
address that could influence how the hardware sees it? If so, might be
worth a comment about that, also, consider using upper_32_bits() for
assigning addrh.

> +	}
> +#endif
>  	desc->addr = (u32)addr;
> +}
> +
> +static dma_addr_t macb_get_addr(struct macb *bp, struct macb_dma_desc *desc)
> +{
> +	dma_addr_t addr = 0;
>  #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> -	desc->addrh = (u32)(addr >> 32);
> +	struct macb_dma_desc_64 *desc_64;
> +
> +	if (bp->hw_dma_cap == HW_DMA_CAP_64B) {
> +		desc_64 = macb_64b_desc(bp, desc);
> +		addr = ((u64)(desc_64->addrh) << 32);

Same here.

> +	}
>  #endif
> +	addr |= MACB_BF(RX_WADDR, MACB_BFEXT(RX_WADDR, desc->addr));
> +	return addr;
>  }
>  
>  static void macb_tx_error_task(struct work_struct *work)
> @@ -574,7 +629,7 @@ static void macb_tx_error_task(struct work_struct *work)
>  						      tx_error_task);
>  	struct macb		*bp = queue->bp;
>  	struct macb_tx_skb	*tx_skb;
> -	struct macb_dma_desc	*desc;
> +	struct macb_dma_desc *desc;

Unrelated change.

>  	struct sk_buff		*skb;
>  	unsigned int		tail;
>  	unsigned long		flags;
> @@ -649,7 +704,7 @@ static void macb_tx_error_task(struct work_struct *work)
>  
>  	/* Set end of TX queue */
>  	desc = macb_tx_desc(queue, 0);
> -	macb_set_addr(desc, 0);
> +	macb_set_addr(bp, desc, 0);
>  	desc->ctrl = MACB_BIT(TX_USED);
>  
>  	/* Make descriptor updates visible to hardware */
> @@ -658,7 +713,8 @@ static void macb_tx_error_task(struct work_struct *work)
>  	/* Reinitialize the TX desc queue */
>  	queue_writel(queue, TBQP, (u32)(queue->tx_ring_dma));
>  #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> -	queue_writel(queue, TBQPH, (u32)(queue->tx_ring_dma >> 32));
> +	if (bp->hw_dma_cap == HW_DMA_CAP_64B)
> +		queue_writel(queue, TBQPH, (u32)(queue->tx_ring_dma >> 32));

upper_32_bits() here as well.

There are more of these pattern that you may want to fix throughout your
entire submission since it makes it clear what part of the address you
are manipulating.

Thanks!
-- 
Florian
