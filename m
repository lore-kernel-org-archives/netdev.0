From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net:fec: fix WARNING caused by lack of calls to
 dma_mapping_error()
Date: Wed, 13 Nov 2013 01:43:09 +0000
Message-ID: <1384306989.3802.71.camel@bwh-desktop.uk.level5networks.com>
References: <1384224889-8316-1-git-send-email-B38611@freescale.com>
	 <1384304453.3802.62.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <b20596@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Fugang Duan <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48869 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab3KMBnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 20:43:13 -0500
In-Reply-To: <1384304453.3802.62.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 01:00 +0000, Ben Hutchings wrote:
> On Tue, 2013-11-12 at 10:54 +0800, Fugang Duan wrote:
> > Enable CONFIG_HAVE_DMA_API_DEBUG, the kernel dump warning:
[...]
> > @@ -1001,6 +1005,9 @@ fec_enet_rx(struct net_device *ndev, int budget)
> >  
> >  		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, data,
> >  				FEC_ENET_TX_FRSIZE, DMA_FROM_DEVICE);
> > +		/* here dma mapping shouldn't be error, just avoid kernel dump */
> > +		if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr))
> > +			netdev_err(ndev, "Rx DMA memory map failed\n");
> 
> This is not handling the error.
[...]

It looks like the same RX DMA buffers are used repeatedly and the driver
copies into an skb.  So fec_enet_rx() should not map or unmap at all; it
should use dma_sync_single_for_cpu().  Then, indeed, no error handling
is required.

But there's still a big problem with this function.  Instead of
remembering the virtual address of each buffer, it passes the DMA
address to __va().  Physical and DMA addresses are *not* the same thing!
They may differ if the device is behind an IOMMU or bounce buffering was
required, or just because there is a fixed offset between the device and
host physical addresses. 

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
