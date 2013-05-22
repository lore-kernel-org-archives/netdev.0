From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH net-next 20/22] sfc: reuse pages to avoid DMA mapping/unmapping costs
Date: Wed, 22 May 2013 16:29:09 +0000 (UTC)
Message-ID: <loom.20130522T180718-104@post.gmane.org>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com> <1363031947.2608.57.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:49736 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756238Ab3EVQfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 12:35:11 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UfC0F-0007Vv-8U
	for netdev@vger.kernel.org; Wed, 22 May 2013 18:35:03 +0200
Received: from c-98-245-149-74.hsd1.co.comcast.net ([98.245.149.74])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 18:35:03 +0200
Received: from alex.williamson by c-98-245-149-74.hsd1.co.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 18:35:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings <at> solarflare.com> writes:

> 
> From:  Daniel Pieczko <dpieczko <at> solarflare.com>
> 
> On POWER systems, DMA mapping/unmapping operations are very expensive.
> These changes reduce these costs by trying to reuse DMA mapped pages.
> 
> After all the buffers associated with a page have been processed and
> passed up, the page is placed into a ring (if there is room).  For
> each page that is required for a refill operation, a page in the ring
> is examined to determine if its page count has fallen to 1, ie. the
> kernel has released its reference to these packets.  If this is the
> case, the page can be immediately added back into the RX descriptor
> ring, without having to re-map it for DMA.
> 
> If the kernel is still holding a reference to this page, it is removed
> from the ring and unmapped for DMA.  Then a new page, which can
> immediately be used by RX buffers in the descriptor ring, is allocated
> and DMA mapped.
> 
> The time a page needs to spend in the recycle ring before the kernel
> has released its page references is based on the number of buffers
> that use this page.  As large pages can hold more RX buffers, the RX
> recycle ring can be shorter.  This reduces memory usage on POWER
> systems, while maintaining the performance gain achieved by recycling
> pages, following the driver change to pack more than two RX buffers
> into large pages.
> 
> When an IOMMU is not present, the recycle ring can be small to reduce
> memory usage, since DMA mapping operations are inexpensive.

I'm not sure I agree with the test for whether an IOMMU is present...

> diff --git a/drivers/net/ethernet/sfc/efx.c 
b/drivers/net/ethernet/sfc/efx.c
> index 1213af5..a70c458 100644
> --- a/drivers/net/ethernet/sfc/efx.c
> +++ b/drivers/net/ethernet/sfc/efx.c
[snip]
> +void efx_init_rx_recycle_ring(struct efx_nic *efx,
> +			      struct efx_rx_queue *rx_queue)
> +{
> +	unsigned int bufs_in_recycle_ring, page_ring_size;
> +
> +	/* Set the RX recycle ring size */
> +#ifdef CONFIG_PPC64
> +	bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_IOMMU;
> +#else
> +	if (efx->pci_dev->dev.iommu_group)
> +		bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_IOMMU;
> +	else
> +		bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_NOIOMMU;
> +#endif /* CONFIG_PPC64 */

Testing for an iommu_group is more of a test of (is an iommu present && does 
it support the iommu api && does it support iommu groups && is the device 
isolatable).  That doesn't seem like what we want here (besides, it's kind 
of a hacky sidestep to the API which would suggest using iommu_group_get/put 
here).

We could use iommu_present(&pci_bus_type), which reduces the test to (iommu 
present && supports iommu api (ie. iommu_ops)).  Better, but I think you 
really care about an iommu present with dma_ops.  I think we can assume that 
if an iommu supports iommu_ops, it supports dma_ops, but that still leaves 
out iommus that do not support iommu_ops.  Do we care about those?

Furthermore, what about cases where an iommu is present, but unused?  For 
example, iommu=pt (passthrough).  I'd think the driver would want to behave 
as it would in the non-iommu case in that configuration.  Anyway, I don't 
think iommu_group is the correct test here.  Thanks,

Alex
