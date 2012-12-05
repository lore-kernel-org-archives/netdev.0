From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2] net/macb: Use non-coherent memory for rx buffers
Date: Wed, 5 Dec 2012 16:12:39 +0100
Message-ID: <50BF6467.5060701@atmel.com>
References: <CAGhQ9VwWmP_B17LnAEqDHcL8Yd-s0C-Bf35z3+=vnJmK_NoCSw@mail.gmail.com> <1354536876-6274-1-git-send-email-nicolas.ferre@atmel.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70D5@saturn3.aculab.com> <50BCA746.1020705@atmel.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70D6@saturn3.aculab.com> <50BE2FEC.2070500@atmel.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70D9@saturn3.aculab.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70D9@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/05/2012 10:35 AM, David Laight :
>> If I understand well, you mean that the call to:
>>
>> 		dma_sync_single_range_for_device(&bp->pdev->dev, phys,
>> 				pg_offset, frag_len, DMA_FROM_DEVICE);
>>
>> in the rx path after having copied the data to skb is not needed?
>> That is also the conclusion that I found after having thinking about
>> this again... I will check this.
> 
> You need to make sure that the memory isn't in the data cache
> when you give the rx buffer back to the MAC.
> (and ensure the cpu doesn't read it until the rx is complete.)
> I've NFI what that dma_sync call does - you need to invalidate
> the cache lines.

The invalidate of cache lines is done by
dma_sync_single_range_for_device(, DMA_FROM_DEVICE) so I need to keep it.

>> For the CRC, my driver is not using the CRC offloading feature for the
>> moment. So no CRC is written by the device.
> 
> I was thinking it would matter if the MAC wrote the CRC into the
> buffer (even though it was excluded from the length).
> It doesn't - you only need to worry about data you've read.
> 
>>> I was wondering if the code needs to do per page allocations?
>>> Perhaps that is necessary to avoid needing a large block of
>>> contiguous physical memory (and virtual addresses)?
>>
>> The page management seems interesting for future management of RX
>> buffers as skb fragments: that will allow to avoid copying received data.
> 
> Dunno - the complexities of such buffer loaning schemes often
> exceed the gain of avoiding the data copy.
> Using buffers allocated to the skb is a bit different - since
> you completely forget about the memory once you pass the skb
> upstream.
> 
> Some quick sums indicate you might want to allocate 8k memory
> blocks and split into 5 buffers.

Well, for the 10/100 MACB interface, I am stuck with 128 Bytes buffers!
So this use of pages seems sensible.
On the other hand, it is true that I may have to reconsider the GEM
memory management (it one is able to cover 128-10KB rx DMA buffers)...

Best regards,
-- 
Nicolas Ferre
