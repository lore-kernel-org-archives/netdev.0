From: Alex Williamson <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 20/22] sfc: reuse pages to avoid DMA
	mapping/unmapping costs
Date: Wed, 22 May 2013 12:44:14 -0600
Message-ID: <1369248254.2646.118.camel@ul30vt.home>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
	<1363031947.2608.57.camel@bwh-desktop.uk.solarflarecom.com>
	<loom.20130522T180718-104@post.gmane.org>
	<1369244582.2670.32.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Alexey Kardashevskiy <aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nikolay Aleksandrov <naleksan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Daniel Pieczko <dpieczko-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	iommu <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1369244582.2670.32.camel-/LGg1Z1CJKQ+9kgCwbf1HqK4ta4zdZpAajtMo4Cw6ucAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

[adding cc iommu list + aik]

On Wed, 2013-05-22 at 18:43 +0100, Ben Hutchings wrote:
> On Wed, 2013-05-22 at 16:29 +0000, Alex Williamson wrote:
> > Ben Hutchings <bhutchings <at> solarflare.com> writes:
> > 
> > > 
> > > From:  Daniel Pieczko <dpieczko <at> solarflare.com>
> > > 
> > > On POWER systems, DMA mapping/unmapping operations are very expensive.
> > > These changes reduce these costs by trying to reuse DMA mapped pages.
> [...]
> > > When an IOMMU is not present, the recycle ring can be small to reduce
> > > memory usage, since DMA mapping operations are inexpensive.
> > 
> > I'm not sure I agree with the test for whether an IOMMU is present...
> > 
> > > diff --git a/drivers/net/ethernet/sfc/efx.c 
> > b/drivers/net/ethernet/sfc/efx.c
> > > index 1213af5..a70c458 100644
> > > --- a/drivers/net/ethernet/sfc/efx.c
> > > +++ b/drivers/net/ethernet/sfc/efx.c
> > [snip]
> > > +void efx_init_rx_recycle_ring(struct efx_nic *efx,
> > > +			      struct efx_rx_queue *rx_queue)
> > > +{
> > > +	unsigned int bufs_in_recycle_ring, page_ring_size;
> > > +
> > > +	/* Set the RX recycle ring size */
> > > +#ifdef CONFIG_PPC64
> > > +	bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_IOMMU;
> > > +#else
> > > +	if (efx->pci_dev->dev.iommu_group)
> > > +		bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_IOMMU;
> > > +	else
> > > +		bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_NOIOMMU;
> > > +#endif /* CONFIG_PPC64 */
> > 
> > Testing for an iommu_group is more of a test of (is an iommu present && does 
> > it support the iommu api && does it support iommu groups && is the device 
> > isolatable).  That doesn't seem like what we want here (besides, it's kind 
> > of a hacky sidestep to the API which would suggest using iommu_group_get/put 
> > here).
> 
> Since we don't try to use the iommu_group itself, those functions don't
> seem to be appropriate.
> 
> > We could use iommu_present(&pci_bus_type), which reduces the test to (iommu 
> > present && supports iommu api (ie. iommu_ops)).
> 
> That's the test we use OOT for older kernel version.  However I advised
> Daniel, apparently wrongly, that testing iommu_group would now be more
> accurate.
> 
> > Better, but I think you 
> > really care about an iommu present with dma_ops.  I think we can assume that 
> > if an iommu supports iommu_ops, it supports dma_ops, but that still leaves 
> > out iommus that do not support iommu_ops.  Do we care about those?
> 
> Unfortunately the pSeries IOMMU code doesn't support iommu_ops yet, and
> that is precisely the case where DMA map/unmap operations are most
> expensive (that we've seen).

I think that's soon to change, at least for some POWER models, with the
work that Alexey is doing.  Hopefully that work will cover enough
platforms that we could remove the #ifdef here and just use
iommu_present(), even if not ideal.

> > Furthermore, what about cases where an iommu is present, but unused?  For 
> > example, iommu=pt (passthrough).  I'd think the driver would want to behave 
> > as it would in the non-iommu case in that configuration.  Anyway, I don't 
> > think iommu_group is the correct test here.  Thanks,
> 
> Right.  The real question the driver should ask is: 'will DMA-mapping/
> unmapping for this device be significantly slower than DMA-syncing?'  We
> don't yet have a way to ask that; maybe that should be added to the DMA
> API.

Right.  So maybe a better approximation is to ask whether sync has any
overhead.  Couldn't you get the dma_ops for the device (get_dma_ops())
and check whether the sync functions are implemented?  That's still not
perfect though as a bounce buffer iommu may also have no overhead
depending on the dma_mask of the device (or the address being mapped).
Thanks,

Alex
