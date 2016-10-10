From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: Re: igb driver can cause cache invalidation of non-owned memory?
Date: Mon, 10 Oct 2016 15:27:47 +0300
Message-ID: <f75cf1e1-d7e8-e044-188a-987f05f321a5@cogentembedded.com>
References: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
 <20161010.050125.1981283393312167625.davem@davemloft.net>
 <10474d19-df1a-3b09-917e-70659be3a56c@cogentembedded.com>
 <20161010.075731.2449861168238706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        cphealy@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161010.075731.2449861168238706.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Hmm...  I'm not about device writing to memory.
> 
> This absolutely is about whether the device wrote into the
> area or not.

Not only.
 
>> Sequence in igb driver is:
>>
>> dma_map(full_page)
>>   <device writes here>
>> sync_to_cpu(half_page);
>> skb_add_rx_frag(skb, half_page);
>> napi_gro_receive(skb);
>>   ...
>> dma_unmap(full_page)
>>
>> What I'm concerned about is - same area is first passed up to network
>> stack, and _later_ dma_unmap()ed.  Is this indeed safe?
> 
> dma_unmap() should never write anything unless the device has
> meanwhile written to that chunk of memory.

dma_unmap() for DMA_FROM_DEVICE never writes whatever to memory,
regardless of what device did.

dma_unmap() for DMA_FROM_DEVICE ensures that data written to memory
by device (if any) is visible to CPU. Cache may contain stale data
for that memory region. To drop that from cache, dma_unmap() for
DMA_FROM_DEVICE does cache invalidation.

static void arm_dma_unmap_page(struct device *dev, dma_addr_t handle,
		size_t size, enum dma_data_direction dir, unsigned long attrs)
{
	if ((attrs & DMA_ATTR_SKIP_CPU_SYNC) == 0)
		__dma_page_dev_to_cpu(pfn_to_page(dma_to_pfn(dev, handle)),
				      handle & ~PAGE_MASK, size, dir);
}

static void __dma_page_dev_to_cpu(struct page *page, unsigned long off,
	size_t size, enum dma_data_direction dir)
{
...
	if (dir != DMA_TO_DEVICE) {
		outer_inv_range(paddr, paddr + size);

		dma_cache_maint_page(page, off, size, dir, dmac_unmap_area);
	}
...
}


> If the device made no intervening writes into the area, dma_unmap()
> should not cause any data to be written to that area, period.

I'm not about writing.

I'm about just the opposite - dropping not-written data from cache.

- napi_gro_receive(skb) passes area to upper layers of the network stack,
- something in those layers - perhaps packet mangling or such - writes
  to the area,
- this write enters cache but does not end into memory immediately,
- at this moment, igb does dma_unmap(),
- write that was in cache but not yet in memory gets lost.


> In your example above, consider the case where the device never
> writes into the memory area after sync_to_cpu().  In that case
> there is nothing that dma_unmap() can possibly write.
> All the data has been synced

Non-synced data is write done by CPU executing upper layers of network stack,


Nikita
