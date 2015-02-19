From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] enic: implement frag allocator
Date: Thu, 19 Feb 2015 14:25:31 -0500 (EST)
Message-ID: <20150219.142531.1581772172061951693.davem@davemloft.net>
References: <1423659558-32523-1-git-send-email-_govind@gmx.com>
	<1423659558-32523-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com, ssujith@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbbBSTZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 14:25:34 -0500
In-Reply-To: <1423659558-32523-2-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed, 11 Feb 2015 18:29:17 +0530

> This patch implements frag allocator for rq buffer. This is based on
> __alloc_page_frag & __page_frag_refill implementation in net/core/skbuff.c
> 
> In addition to frag allocation from order(3) page in __alloc_page_frag,
> we also maintain dma address of the page. While allocating a frag for rx buffer
> we return va + offset for virtual address of the frag, and pa + offset for
> dma address of the frag. This reduces the number of calls to dma_map()
> by 1/3 for 9k mtu and by 1/20 for 1500 mtu.
> 
> __alloc_page_frag is limited to max buffer size of PAGE_SIZE, i.e 4096 in most
> of the cases. So 9k buffer allocation goes through kmalloc which return
> page of order 2, 16k. We waste 7k bytes for every 9k buffer.
> 
> we maintain dma_count variable which is incremented when we allocate a frag.
> enic_unmap_dma will decrement the dma_count and unmap it when there is no user
> of that page in rx ring.
> 
> This reduces the memory utilization for 9k mtu by 33%.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

This is a nice optimization, but this is definitely useful for other drivers
rather than just your's.  And there isn't anything that really keeps this from
being put somewhere generically.

> +#define ENIC_ALLOC_ORDER	PAGE_ALLOC_COSTLY_ORDER

You talk about order(3) but then use PAGE_ALLOC_COSTLY_ORDER, which in
theory could change in the future.

But, in any event, there is no reason not to use NETDEV_FRAG_PAGE_MAX_ORDER,
just like __alloc_page_frag() does.

> +struct enic_alloc_cache {
> +	struct page_frag	frag;
> +	unsigned int		pagecnt_bias;
> +	int			dma_count;
> +	void			*va;
> +	dma_addr_t		pa;
> +};

Make this a generic structure, perhaps named something like
"netdev_dma_alloc_cache".

'pa' is not a good name for a DMA address, because it is not (necessarily)
a physical address.  It could be a virtual address translated by an IOMMU.
"dma_addr" is probably therefore a better member name.

In the generic version the driver will have to pass in a pointer to the
"netdev_dma_alloc_cache".  I would suggest having this embedded in the
driver per-queue structure rather than being allocated dynamically.

Then you can provide a netdev_dma_alloc_cache_init() the driver can
call which initializes this embedded object.

> +	ec->pa = pci_map_single(enic->pdev, ec->va, ec->frag.size,
> +				PCI_DMA_FROMDEVICE);

Next, these need to be converted to dma_*() calls, and the interface
for netdev_dma_alloc_cache() will need to have a "struct device *"
argument for these calls.

> @@ -199,6 +200,18 @@ void vnic_rq_clean(struct vnic_rq *rq,
>  		rq->ring.desc_avail++;
>  	}
>  
> +	if (rq->ec) {
> +		struct enic *enic = vnic_dev_priv(rq->vdev);
> +		struct enic_alloc_cache *ec = rq->ec;
> +
> +		WARN_ON(ec->dma_count);
> +		pci_unmap_single(enic->pdev, ec->pa, ec->frag.size,
> +				 PCI_DMA_FROMDEVICE);
> +		atomic_sub(ec->pagecnt_bias - 1, &ec->frag.page->_count);
> +		__free_pages(ec->frag.page, get_order(ec->frag.size));
> +		kfree(ec);
> +		rq->ec = NULL;
> +	}
>  	/* Use current fetch_index as the ring starting point */
>  	fetch_index = ioread32(&rq->ctrl->fetch_index);
>  

Finally, you'll need to define a "netdev_dma_alloc_cache_destroy()"
function which you'll call from here.
