From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/4] net: macb: Add support for PTP timestamps in DMA
 descriptors
Date: Fri, 14 Apr 2017 09:43:25 +0200
Message-ID: <20170414074325.GA1660@localhost.localdomain>
References: <1492090439-11793-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
        Andrei.Pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org
To: Rafal Ozieblo <rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1492090439-11793-1-git-send-email-rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2017 at 02:33:59PM +0100, Rafal Ozieblo wrote:
> @@ -1921,9 +1972,13 @@ static void macb_configure_dma(struct macb *bp)
>  			dmacfg &= ~GEM_BIT(TXCOEN);
>  
>  #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> -		if (bp->hw_dma_cap == HW_DMA_CAP_64B)
> +		if (bp->hw_dma_cap & HW_DMA_CAP_64B)
>  			dmacfg |= GEM_BIT(ADDR64);
>  #endif
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +		if (bp->hw_dma_cap & HW_DMA_CAP_PTP)
> +			dmacfg |= GEM_BIT(RXEXT) | GEM_BIT(TXEXT);
> +#endif
>  		netdev_dbg(bp->dev, "Cadence configure DMA with 0x%08x\n",
>  			   dmacfg);
>  		gem_writel(bp, DMACFG, dmacfg);
> @@ -1971,14 +2026,15 @@ static void macb_init_hw(struct macb *bp)
>  	/* Initialize TX and RX buffers */
>  	macb_writel(bp, RBQP, lower_32_bits(bp->rx_ring_dma));
>  #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> -	if (bp->hw_dma_cap == HW_DMA_CAP_64B)
> +	if (bp->hw_dma_cap & HW_DMA_CAP_64B)
>  		macb_writel(bp, RBQPH, upper_32_bits(bp->rx_ring_dma));
>  #endif
>  	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
>  		queue_writel(queue, TBQP, lower_32_bits(queue->tx_ring_dma));
>  #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> -		if (bp->hw_dma_cap == HW_DMA_CAP_64B)
> -			queue_writel(queue, TBQPH, upper_32_bits(queue->tx_ring_dma));
> +		if (bp->hw_dma_cap & HW_DMA_CAP_64B)
> +			queue_writel(queue, TBQPH,
> +					upper_32_bits(queue->tx_ring_dma));

Align arg3 with arg1 please.

>  #endif
>  
>  		/* Enable interrupts */
> @@ -2579,6 +2635,18 @@ static void macb_configure_caps(struct macb *bp,
>  		dcfg = gem_readl(bp, DCFG2);
>  		if ((dcfg & (GEM_BIT(RX_PKT_BUFF) | GEM_BIT(TX_PKT_BUFF))) == 0)
>  			bp->caps |= MACB_CAPS_FIFO_MODE;
> +		/* if HWSTAMP is configure and gem has the capability */

This comment is redundant.  We can see that clearly in the code already.

> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +		bp->ptp_hw_support = false;

No need to clear this again.  (The struct was cleared after
allocation, right?)

> +		if (gem_has_ptp(bp)) {

Why not drop the #idef:

		if (IS_ENABLED(CONFIG_MACB_USE_HWSTAMP) && gem_has_ptp(bp)) ...

> +			if (!GEM_BFEXT(TSU, gem_readl(bp, DCFG5)))
> +				pr_err("GEM doesn't support hardware ptp.\n");
> +			else {
> +				pr_emerg("rozieblo: ptp_hw_support = true");

pr_emerg?

> +				bp->ptp_hw_support = true;
> +			}

Proper if/else CodingStyle please.

> +		}
> +#endif
>  	}
>  
>  	dev_dbg(&bp->pdev->dev, "Cadence caps 0x%08x\n", bp->caps);

> @@ -2716,7 +2784,7 @@ static int macb_init(struct platform_device *pdev)
>  			queue->IMR  = GEM_IMR(hw_q - 1);
>  			queue->TBQP = GEM_TBQP(hw_q - 1);
>  #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> -			if (bp->hw_dma_cap == HW_DMA_CAP_64B)
> +			if (bp->hw_dma_cap & HW_DMA_CAP_64B)
>  				queue->TBQPH = GEM_TBQPH(hw_q - 1);
>  #endif
>  		} else {
> @@ -2727,7 +2795,7 @@ static int macb_init(struct platform_device *pdev)
>  			queue->IMR  = MACB_IMR;
>  			queue->TBQP = MACB_TBQP;
>  #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> -			if (bp->hw_dma_cap == HW_DMA_CAP_64B)
> +			if (bp->hw_dma_cap & HW_DMA_CAP_64B)
>  				queue->TBQPH = MACB_TBQPH;
>  #endif
>  		}

> @@ -3307,19 +3375,24 @@ static int macb_probe(struct platform_device *pdev)
>  		bp->wol |= MACB_WOL_HAS_MAGIC_PACKET;
>  	device_init_wakeup(&pdev->dev, bp->wol & MACB_WOL_HAS_MAGIC_PACKET);
>  
> -#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> -	if (GEM_BFEXT(DAW64, gem_readl(bp, DCFG6))) {
> -		dma_set_mask(&pdev->dev, DMA_BIT_MASK(44));
> -		bp->hw_dma_cap = HW_DMA_CAP_64B;
> -	} else
> -		bp->hw_dma_cap = HW_DMA_CAP_32B;
> -#endif
> -
>  	spin_lock_init(&bp->lock);
>  
>  	/* setup capabilities */
>  	macb_configure_caps(bp, macb_config);
>  
> +#ifdef MACB_EXT_DESC
> +	bp->hw_dma_cap = HW_DMA_CAP_32B;
> +#endif
> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> +	if (GEM_BFEXT(DAW64, gem_readl(bp, DCFG6))) {
> +		dma_set_mask(&pdev->dev, DMA_BIT_MASK(44));
> +		bp->hw_dma_cap |= HW_DMA_CAP_64B;
> +	}
> +#endif
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +	if (bp->ptp_hw_support)
> +		bp->hw_dma_cap |= HW_DMA_CAP_PTP;

So bp->ptp_hw_support is a waste of storage.  You can test for
(!GEM_BFEXT(TSU, gem_readl(bp, DCFG5))) directly here, or return a
flag from macb_configure_caps(), or set the hw_dma_cap flag in that
function, ...

> +#endif
>  	platform_set_drvdata(pdev, dev);
>  
>  	dev->irq = platform_get_irq(pdev, 0);

> @@ -954,8 +972,12 @@ struct macb {
>  	u32			wol;
>  
>  	struct macb_ptp_info	*ptp_info;	/* macb-ptp interface */
> -#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
> -	enum macb_hw_dma_cap hw_dma_cap;
> +#ifdef MACB_EXT_DESC
> +	uint8_t hw_dma_cap;
> +#endif
> +
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +	bool ptp_hw_support;

Remove this, please.

Thanks,
Richard

>  #endif
>  };
>  
> -- 
> 2.4.5
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
