From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 01/11] ixgbe: Support using build_skb in the case that
 jumbo frames are disabled
Date: Fri, 12 Apr 2013 16:50:05 -0700
Message-ID: <51689DAD.50308@intel.com>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1365765866-15741-2-git-send-email-jeffrey.t.kirsher@intel.com> <1365805319.2791.18.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:42961 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753737Ab3DLXuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 19:50:07 -0400
In-Reply-To: <1365805319.2791.18.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2013 03:21 PM, Ben Hutchings wrote:
> On Fri, 2013-04-12 at 04:24 -0700, Jeff Kirsher wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This change makes it so that we can enable the use of build_skb for cases
>> where jumbo frames are disabled.  The advantage to this is that we do not have
>> to perform a memcpy to populate the header and as a result we see a
>> significant performance improvement.
> I thought about doing this in sfc, but:
>
> [...]
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> [...] 
>> +	/* build an skb to go around the page buffer */
>> +	skb = build_skb(page_addr, truesize);
>> +	if (unlikely(!skb)) {
>> +		rx_ring->rx_stats.alloc_rx_buff_failed++;
>> +		return NULL;
>> +	}
>> +
>> +	/* we are reusing so sync this buffer for CPU use */
>> +	dma_sync_single_range_for_cpu(rx_ring->dev,
>> +				      rx_buffer->dma,
>> +				      rx_buffer->page_offset,
>> +				      ixgbe_rx_bufsz(rx_ring),
>> +				      DMA_FROM_DEVICE);
>> +
>> +	/* update pointers within the skb to store the data */
>> +	skb_reserve(skb, NET_IP_ALIGN + NET_SKB_PAD);
>> +	__skb_put(skb, size);
>> +
>> +	if (ixgbe_can_reuse_rx_page(rx_ring, rx_buffer, page, truesize)) {
>> +		/* hand second half of page back to the ring */
>> +		ixgbe_reuse_rx_page(rx_ring, rx_buffer);
> [...]
>
> Suppose this branch is taken, and then:
> 1. skb is forwarded to another device
> 2. Packet headers are modified and it's put into a queue
> 3. Second packet is received into the other half of this page
> 4. Page cannot be reused, so is DMA-unmapped
> 5. The DMA mapping was non-coherent, so unmap copies or invalidates
> cache
>
> The headers added in step 2 get trashed in step 5, don't they?
>
> Ben.

You're right.  I think they do.  It kind of sucks since this was a
pretty good performance improvement.

This patch should not be applied, and I think I have to submit a patch
to revert a similar patch that has already been applied for igb and is
in the net tree.

Thanks,

Alex
