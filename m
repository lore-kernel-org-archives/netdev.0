From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/20][BNX2]: Add 40-bit DMA workaround for 5708.
Date: Wed, 02 May 2007 03:06:43 -0400
Message-ID: <46383883.8070209@garzik.org>
References: <1178068414.4820.39.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55972 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754887AbXEBHHc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 03:07:32 -0400
In-Reply-To: <1178068414.4820.39.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> [BNX2]: Add 40-bit DMA workaround for 5708.
> 
> The internal PCIE-to-PCIX bridge of the 5708 has the same 40-bit DMA
> limitation as some of the tg3 chips.  Use the same workaround used in
> tg3.  On 64-bit systems without IOMMU, linearize the SKB if any
> address is > 40-bit.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 6d05397..dba4088 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -4495,6 +4495,93 @@ bnx2_vlan_rx_kill_vid(struct net_device *dev, uint16_t vid)
>  }
>  #endif
>  
> +/* Test for DMA addresses > 40-bit.
> + * Only 64-bit systems without IOMMU require DMA address checking.
> + */
> +static inline int bnx2_40bit_overflow_test(struct bnx2 *bp, dma_addr_t mapping,
> +					   int len)
> +{
> +#if defined(CONFIG_HIGHMEM) && (BITS_PER_LONG == 64)
> +	if (CHIP_NUM(bp) == CHIP_NUM_5708)
> +		return (((u64) mapping + len) > DMA_40BIT_MASK);

If the mapping is at a very high address, adding len might overflow, yes?



> +#if defined(CONFIG_HIGHMEM) && (BITS_PER_LONG == 64)
> +	if (unlikely(would_hit_hwbug)) {
> +		/* If the workaround fails due to memory/mapping
> +		 * failure, silently drop this packet.
> +		 */
> +		if (bnx2_dma_hwbug_workaround(bp, &skb, &prod,
> +					      vlan_tag_flags, mss))
> +			return NETDEV_TX_OK;
> +
> +	}
> +#endif

You need to at least account for the drop, in packets-dropped stat.

/Completely/ silent intentional packet drops are something to be 
avoided.  The user should be given /some/ indication of what is going on.

Second, CONFIG_HIGHMEM is a bad test for IOMMU presence.  I don't think 
you /can/ test for IOMMU presence.  Maybe DaveM knows a way that I do not?



> +	/* 5708 cannot support DMA addresses > 40-bit.
> +	 * On 64-bit systems with IOMMU, use 40-bit dma_mask.
> +	 * On 64-bit systems without IOMMU, use 64-bit dma_mask and
> +	 * do DMA address check in bnx2_start_xmit().
> +	 */
> +	if (CHIP_NUM(bp) == CHIP_NUM_5708) {
> +		persist_dma_mask = dma_mask = DMA_40BIT_MASK;
> +#ifdef CONFIG_HIGHMEM
> +		dma_mask = DMA_64BIT_MASK;
> +#endif
> +	} else
> +		persist_dma_mask = dma_mask = DMA_64BIT_MASK;
> +
> +	/* Configure DMA attributes. */
> +	if (pci_set_dma_mask(pdev, dma_mask) == 0) {
> +		dev->features |= NETIF_F_HIGHDMA;
> +		rc = pci_set_consistent_dma_mask(pdev, persist_dma_mask);
> +		if (rc) {
> +			dev_err(&pdev->dev,
> +				"pci_set_consistent_dma_mask failed, aborting.\n");
> +			goto err_out_unmap;
> +		}
> +	} else if ((rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) != 0) {
> +		dev_err(&pdev->dev, "System does not support DMA, aborting.\n");
> +		goto err_out_unmap;
> +	}
> +

Ditto.  CONFIG_HIGHMEM is not an effective test.

NAK.

