From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 20/22] sfc: reuse pages to avoid DMA
 mapping/unmapping costs
Date: Wed, 22 May 2013 18:43:02 +0100
Message-ID: <1369244582.2670.32.camel@bwh-desktop.uk.level5networks.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
	 <1363031947.2608.57.camel@bwh-desktop.uk.solarflarecom.com>
	 <loom.20130522T180718-104@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Daniel Pieczko <dpieczko@solarflare.com>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Alex Williamson <alex.williamson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:12844 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049Ab3EVRnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 13:43:07 -0400
In-Reply-To: <loom.20130522T180718-104@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 16:29 +0000, Alex Williamson wrote:
> Ben Hutchings <bhutchings <at> solarflare.com> writes:
> 
> > 
> > From:  Daniel Pieczko <dpieczko <at> solarflare.com>
> > 
> > On POWER systems, DMA mapping/unmapping operations are very expensive.
> > These changes reduce these costs by trying to reuse DMA mapped pages.
[...]
> > When an IOMMU is not present, the recycle ring can be small to reduce
> > memory usage, since DMA mapping operations are inexpensive.
> 
> I'm not sure I agree with the test for whether an IOMMU is present...
> 
> > diff --git a/drivers/net/ethernet/sfc/efx.c 
> b/drivers/net/ethernet/sfc/efx.c
> > index 1213af5..a70c458 100644
> > --- a/drivers/net/ethernet/sfc/efx.c
> > +++ b/drivers/net/ethernet/sfc/efx.c
> [snip]
> > +void efx_init_rx_recycle_ring(struct efx_nic *efx,
> > +			      struct efx_rx_queue *rx_queue)
> > +{
> > +	unsigned int bufs_in_recycle_ring, page_ring_size;
> > +
> > +	/* Set the RX recycle ring size */
> > +#ifdef CONFIG_PPC64
> > +	bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_IOMMU;
> > +#else
> > +	if (efx->pci_dev->dev.iommu_group)
> > +		bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_IOMMU;
> > +	else
> > +		bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_NOIOMMU;
> > +#endif /* CONFIG_PPC64 */
> 
> Testing for an iommu_group is more of a test of (is an iommu present && does 
> it support the iommu api && does it support iommu groups && is the device 
> isolatable).  That doesn't seem like what we want here (besides, it's kind 
> of a hacky sidestep to the API which would suggest using iommu_group_get/put 
> here).

Since we don't try to use the iommu_group itself, those functions don't
seem to be appropriate.

> We could use iommu_present(&pci_bus_type), which reduces the test to (iommu 
> present && supports iommu api (ie. iommu_ops)).

That's the test we use OOT for older kernel version.  However I advised
Daniel, apparently wrongly, that testing iommu_group would now be more
accurate.

> Better, but I think you 
> really care about an iommu present with dma_ops.  I think we can assume that 
> if an iommu supports iommu_ops, it supports dma_ops, but that still leaves 
> out iommus that do not support iommu_ops.  Do we care about those?

Unfortunately the pSeries IOMMU code doesn't support iommu_ops yet, and
that is precisely the case where DMA map/unmap operations are most
expensive (that we've seen).

> Furthermore, what about cases where an iommu is present, but unused?  For 
> example, iommu=pt (passthrough).  I'd think the driver would want to behave 
> as it would in the non-iommu case in that configuration.  Anyway, I don't 
> think iommu_group is the correct test here.  Thanks,

Right.  The real question the driver should ask is: 'will DMA-mapping/
unmapping for this device be significantly slower than DMA-syncing?'  We
don't yet have a way to ask that; maybe that should be added to the DMA
API.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
