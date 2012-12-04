From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2] net/macb: Use non-coherent memory for rx buffers
Date: Tue, 4 Dec 2012 18:16:28 +0100
Message-ID: <50BE2FEC.2070500@atmel.com>
References: <CAGhQ9VwWmP_B17LnAEqDHcL8Yd-s0C-Bf35z3+=vnJmK_NoCSw@mail.gmail.com> <1354536876-6274-1-git-send-email-nicolas.ferre@atmel.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70D5@saturn3.aculab.com> <50BCA746.1020705@atmel.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70D6@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Havard Skinnemoen <havard@skinnemoen.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:1528 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab2LDRQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 12:16:30 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70D6@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2012 03:25 PM, David Laight :
>> On 12/03/2012 01:43 PM, David Laight :
>>>> Allocate regular pages to use as backing for the RX ring and use the
>>>> DMA API to sync the caches. This should give a bit better performance
>>>> since it allows the CPU to do burst transfers from memory. It is also
>>>> a necessary step on the way to reduce the amount of copying done by
>>>> the driver.
>>>
>>> I've not tried to understand the patches, but you have to be
>>> very careful using non-snooped memory for descriptor rings.
>>> No amount of DMA API calls can sort out some of the issues.
>>
>> David,
>>
>> Maybe I have not described the patch properly but the non-coherent
>> memory is not used for descriptor rings. It is used for DMA buffers
>> pointed out by descriptors (that are allocated as coherent memory).
>>
>> As buffers are filled up by the interface DMA and then, afterwards, used
>> by the driver to pass data to the net layer, it seems to me that the use
>> of non-coherent memory is sensible.
> 
> Ah, ok - difficult to actually determine from a fast read of the code.
> So you invalidate (I think that is the right term) all the cache lines
> that are part of each rx buffer before giving it back to the MAC unit.
> (Maybe that first time, and just those cache lines that might have been
> written to after reception - I'd worry about whether the CRC is written
> into the rx buffer!)

If I understand well, you mean that the call to:

		dma_sync_single_range_for_device(&bp->pdev->dev, phys,
				pg_offset, frag_len, DMA_FROM_DEVICE);

in the rx path after having copied the data to skb is not needed?
That is also the conclusion that I found after having thinking about
this again... I will check this.

For the CRC, my driver is not using the CRC offloading feature for the
moment. So no CRC is written by the device.

> I was wondering if the code needs to do per page allocations?
> Perhaps that is necessary to avoid needing a large block of
> contiguous physical memory (and virtual addresses)?

The page management seems interesting for future management of RX
buffers as skb fragments: that will allow to avoid copying received data.

> I know from some experiments done many years ago that a data
> copy in the MAC tx and rx path isn't necessarily as bad as
> people may think - especially if it removes complicated
> 'buffer loaning' schemes and/or iommu setup (or bounce
> buffers due to limited hardware memory addressing).
> 
> The rx copy can usually be made to be a 'whole word' copy
> (ie you copy the two bytes of garbage that (mis)align the
> destination MAC address, and some bytes after the CRC.
> With some hardware I believe it is possible for the cache
> controller to do cache-line aligned copies very quickly!
> (Some very new x86 cpus might be doing this for 'rep movsd'.)

Well, on our side, the "memory bus" resource is precious, so I imagine
that even with an optimized copy, limiting the use of this resource
should be better.

> The copy in the rx path is also better for short packets
> the can end up queued for userspace (although a copy in
> the socket code would solve that one.

Sure, some patches by Haavard that I am working on at the moment are
taking care of copying in any cases the first 62 bytes (+2 bytes
alignment) for each packet so that we cover the case of short packets
and headers...

Thanks for your comments, best regards,
-- 
Nicolas Ferre
