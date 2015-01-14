From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring
 access in user space
Date: Wed, 14 Jan 2015 15:35:09 -0500 (EST)
Message-ID: <20150114.153509.1264618607573705890.davem@davemloft.net>
References: <20150113043509.29985.33515.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danny.zhou@intel.com,
	nhorman@tuxdriver.com, dborkman@redhat.com, john.ronciak@intel.com,
	hannes@stressinduktion.org, brouer@redhat.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbbANUfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 15:35:12 -0500
In-Reply-To: <20150113043509.29985.33515.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 12 Jan 2015 20:35:11 -0800

> +		if ((region.direction != DMA_BIDIRECTIONAL) &&
> +		    (region.direction != DMA_TO_DEVICE) &&
> +		    (region.direction != DMA_FROM_DEVICE))
> +			return -EFAULT;
 ...
> +		if ((umem->nmap == npages) &&
> +		    (0 != dma_map_sg(dev->dev.parent, umem->sglist,
> +				     umem->nmap, region.direction))) {
> +			region.iova = sg_dma_address(umem->sglist) + offset;

I am having trouble seeing how this can work.

dma_map_{single,sg}() mappings need synchronization after a DMA
transfer takes place.

For example if the DMA occurs to the device, then that region can
be cached in the PCI controller's internal caches and thus future
cpu writes into that memory region will not be seen, until a
dma_sync_*() is invoked.

That isn't going to happen when the device transmit queue is
being completely managed in userspace.

And this takes us back to the issue of protection, I don't think
it is addressed properly yet.

CAP_NET_ADMIN privileges do not mean "can crap all over memory"
yet with this feature that can still happen.

If we are dealing with a device which cannot provide strict protection
to only the process's locked local pages, you have to do something
to implement that protection.

And you have _exactly_ one option to do that, abstracting the page
addresses and eating a system call to trigger the sends, so that you
can read from the user's (fake) descriptors and write into the real
descriptors (translating the DMA addresses along the way) and
triggering the TX doorbell.

I am not going to consider seriously an implementation that says "yeah
sometimes the user can crap onto other people's memory", this isn't
MS-DOS, it's a system where proper memory protections are mandatory
rather than optional.
