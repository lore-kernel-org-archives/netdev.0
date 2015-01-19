From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring access
 in user space
Date: Mon, 19 Jan 2015 16:45:16 -0500
Message-ID: <20150119214516.GG21790@hmsreliant.think-freely.org>
References: <20150113043509.29985.33515.stgit@nitbit.x32>
 <20150114.153509.1264618607573705890.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org,
	danny.zhou@intel.com, dborkman@redhat.com, john.ronciak@intel.com,
	hannes@stressinduktion.org, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43217 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbbASVp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 16:45:29 -0500
Content-Disposition: inline
In-Reply-To: <20150114.153509.1264618607573705890.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 03:35:09PM -0500, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Mon, 12 Jan 2015 20:35:11 -0800
> 
> > +		if ((region.direction != DMA_BIDIRECTIONAL) &&
> > +		    (region.direction != DMA_TO_DEVICE) &&
> > +		    (region.direction != DMA_FROM_DEVICE))
> > +			return -EFAULT;
>  ...
> > +		if ((umem->nmap == npages) &&
> > +		    (0 != dma_map_sg(dev->dev.parent, umem->sglist,
> > +				     umem->nmap, region.direction))) {
> > +			region.iova = sg_dma_address(umem->sglist) + offset;
> 
> I am having trouble seeing how this can work.
> 
> dma_map_{single,sg}() mappings need synchronization after a DMA
> transfer takes place.
> 
> For example if the DMA occurs to the device, then that region can
> be cached in the PCI controller's internal caches and thus future
> cpu writes into that memory region will not be seen, until a
> dma_sync_*() is invoked.
> 
> That isn't going to happen when the device transmit queue is
> being completely managed in userspace.
> 
> And this takes us back to the issue of protection, I don't think
> it is addressed properly yet.
> 
> CAP_NET_ADMIN privileges do not mean "can crap all over memory"
> yet with this feature that can still happen.
> 
> If we are dealing with a device which cannot provide strict protection
> to only the process's locked local pages, you have to do something
> to implement that protection.
> 
> And you have _exactly_ one option to do that, abstracting the page
> addresses and eating a system call to trigger the sends, so that you
> can read from the user's (fake) descriptors and write into the real
> descriptors (translating the DMA addresses along the way) and
> triggering the TX doorbell.
> 
> I am not going to consider seriously an implementation that says "yeah
> sometimes the user can crap onto other people's memory", this isn't
> MS-DOS, it's a system where proper memory protections are mandatory
> rather than optional.
> 

Another stupid question - If we can't provide protection from the device to
ensure memory coherency, can we mitigate the problem by creating an iommu group
for the device?

I'd mentioned to john the possibility of using the existing dfwd offload
operations to do the allocation of queues so that we could reuse that code instead
of having to create a set of new queue allocation routines.  What if, instead of
the dfwd queue allocation methods, we used sriov functionality here?  I.e.,
plumb a virtual function, and set it in its own iommu group, but instead of
passing it off to a guest, we just let the host use it?  That gives us the
opportunity to tear down the iommu mappings should the process exit, so if the
physical pages get re-allocated while DMA is in flight, we can just take the
iommu exception and avoid the memory corruption.

Its not perfect, in that we're still not syncing when we should be, but I think
it would be safe at least.

Thoughts?

Neil
