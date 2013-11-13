From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net:fec: fix WARNING caused by lack of calls to
 dma_mapping_error()
Date: Wed, 13 Nov 2013 03:02:51 +0000
Message-ID: <1384311771.3802.104.camel@bwh-desktop.uk.level5networks.com>
References: <1384224889-8316-1-git-send-email-B38611@freescale.com>
	 <1384304453.3802.62.camel@bwh-desktop.uk.level5networks.com>
	 <1384306989.3802.71.camel@bwh-desktop.uk.level5networks.com>
	 <9848F2DB572E5649BA045B288BE08FBE0180475F@039-SN2MPN1-021.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Frank Li <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fugang Duan <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46174 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544Ab3KMDCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 22:02:55 -0500
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE0180475F@039-SN2MPN1-021.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 02:10 +0000, Fugang Duan wrote:
> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> Data: Wednesday, November 13, 2013 9:43 AM
> 
> >To: Duan Fugang-B38611
> >Cc: Li Frank-B20596; davem@davemloft.net; netdev@vger.kernel.org
> >Subject: Re: [PATCH] net:fec: fix WARNING caused by lack of calls to
> >dma_mapping_error()
> >
> >On Wed, 2013-11-13 at 01:00 +0000, Ben Hutchings wrote:
> >> On Tue, 2013-11-12 at 10:54 +0800, Fugang Duan wrote:
> >> > Enable CONFIG_HAVE_DMA_API_DEBUG, the kernel dump warning:
> >[...]
> >> > @@ -1001,6 +1005,9 @@ fec_enet_rx(struct net_device *ndev, int
> >> > budget)
> >> >
> >> >  		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, data,
> >> >  				FEC_ENET_TX_FRSIZE, DMA_FROM_DEVICE);
> >> > +		/* here dma mapping shouldn't be error, just avoid kernel dump */
> >> > +		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr))
> >> > +			netdev_err(ndev, "Rx DMA memory map failed\n");
> >>
> >> This is not handling the error.
> >[...]
> >
> >It looks like the same RX DMA buffers are used repeatedly and the driver copies
> >into an skb.  So fec_enet_rx() should not map or unmap at all; it should use
> >dma_sync_single_for_cpu().  Then, indeed, no error handling is required.
> >
> Yes, there don't need to use dma_unmap_single()/dma_map_single() since
> the fec_enet_alloc_buffers() have mapped the virtual address.
> I will change it. Thanks.
> 
> >But there's still a big problem with this function.  Instead of remembering the
> >virtual address of each buffer, it passes the DMA address to __va().  Physical
> >and DMA addresses are *not* the same thing!
> >They may differ if the device is behind an IOMMU or bounce buffering was
> >required, or just because there is a fixed offset between the device and host
> >physical addresses.
> >
> Yes, I agree that physical and DMA addresses are not the same thing.
> But for imx serial platforms, there have no IOMMU, no offset between
> device and host physical address(this happen on FPGA platforms in
> mostly), so there have no problem.

Then DMA mapping also can't fail and your error checks are unnecessary.
But no doubt there will be a later chip that uses some version of FEC
and *does* require non-trivial DMA mapping.  The Cortex A15 core can run
Xen which will break this assumption...

> I agree it is not common for other platforms like IOMMU...
> Since it is another problem, I will submit another patch to fix the
> problem.

That seems reasonable.

Aside from the DMA debug option, the kernel parameter 'swiotlb=force' is
a good way to test that a driver is using the DMA mapping API correctly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
