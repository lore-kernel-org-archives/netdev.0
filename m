From: Matt Redfearn <matt.redfearn@imgtec.com>
Subject: Re: [PATCH] net: stmmac: Meet alignment requirements for DMA
Date: Tue, 26 Sep 2017 14:57:39 +0100
Message-ID: <587dc9a8-b974-e222-95b4-93c2a8f2aba2@imgtec.com>
References: <1506078833-14002-1-git-send-email-matt.redfearn@imgtec.com>
 <20170922.182639.272534775457081015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexandre.torgue@st.com>,
        <peppe.cavallaro@st.com>, <linux-kernel@vger.kernel.org>,
        Linux MIPS Mailing List <linux-mips@linux-mips.org>,
        Paul Burton <paul.burton@imgtec.com>,
        James Hogan <james.hogan@imgtec.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922.182639.272534775457081015.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Thanks for your feedback.


On 23/09/17 02:26, David Miller wrote:
> From: Matt Redfearn <matt.redfearn@imgtec.com>
> Date: Fri, 22 Sep 2017 12:13:53 +0100
>
>> According to Documentation/DMA-API.txt:
>>   Warnings:  Memory coherency operates at a granularity called the cache
>>   line width.  In order for memory mapped by this API to operate
>>   correctly, the mapped region must begin exactly on a cache line
>>   boundary and end exactly on one (to prevent two separately mapped
>>   regions from sharing a single cache line).  Since the cache line size
>>   may not be known at compile time, the API will not enforce this
>>   requirement.  Therefore, it is recommended that driver writers who
>>   don't take special care to determine the cache line size at run time
>>   only map virtual regions that begin and end on page boundaries (which
>>   are guaranteed also to be cache line boundaries).
> This is rediculious.  You're misreading what this document is trying
> to explain.

To be clear, is your interpretation of the documentation that drivers do 
not have to ensure cacheline alignment?

As I read that documentation of the DMA API, it puts the onus on device 
drivers to ensure that they operate on cacheline aligned & sized blocks 
of memory. It states "the mapped region must begin exactly on a cache 
line boundary". We know that skb->data is not cacheline aligned, since 
it is skb_headroom() bytes into the skb buffer, and the value of 
skb_headroom is not a multiple of cachelines. To give an example, on the 
Creator Ci40 platform (a 32bit MIPS platform), I have the following values:
skb_headroom(skb) = 130 bytes
sbb->head = 0x8ed9b800 (32byte cacheline aligned)
skb->data = 0x8ed9b882 (not cacheline aligned)

Since the MIPS architecture requires software cache management, 
performing a dma_map_single(TO_DEVICE) will writeback and invalidate the 
cachelines for the required region. To comply with (our interpretation 
of) the DMA API documentation, the MIPS implementation expects a 
cacheline aligned & sized buffer, so that it can writeback a set of 
complete cachelines. Indeed a recent patch 
(https://patchwork.linux-mips.org/patch/14624/) causes the MIPS dma 
mapping code to emit warnings if the buffer it is requested to sync is 
not cachline aligned. This driver, as is, fails this test and causes 
thousands of warnings to be emitted.

The situation for dma_map_single(FROM_DEVICE) is potentially worse, 
since it will perform a cache invalidate of all lines for the buffer. If 
the buffer is not cacheline aligned, this will throw away any adjacent 
data in the same cacheline. The dma_map implementation has no way to 
know if data adjacent to the buffer it is requested to sync is valuable 
or not, and it will simply be thrown away by the cache invalidate.

If I am somehow misinterpreting the DMA API documentation, and drivers 
are NOT required to ensure that buffers to be synced are cacheline 
aligned, then there is only one way that the MIPS implementation can 
ensure that it writeback / invalidates cachelines containing only the 
requested data buffer, and that would be to use bounce buffers. Clearly 
that will be devastating for performance as every outgoing packet will 
need to be copied from it's unaligned location to a guaranteed aligned 
location, and written back from there. Similarly incoming packets would 
have to somehow be initially located in a cacheline aligned location 
before being copied into the non-cacheline aligned location supplied by 
the driver.

> As long as you use the dma_{map,unamp}_single() and sync to/from
> deivce interfaces properly, the cacheline issues will be handled properly
> and the cpu and the device will see proper uptodate memory contents.

I interpret the DMA API document (and the MIPS arch dma code operates 
this way) as stating that the driver must ensure that buffers passed to 
it are cacheline aligned, and cacheline sized, to prevent cache 
management throwing away adjacent data in the same cacheline.

That is what this patch is for, to change the buffer address passed to 
the DMA API to skb->head, which is (as far as I know) guaranteed to be 
cacheline aligned.

>
> It is completely rediculious to require every driver to stash away two
> sets of pointer for every packet, and to DMA map the headroom of the SKB
> which is wasteful.
>
> I'm not applying this, fix this problem properly, thanks.

An alternative, slightly less invasive change, may be to subtract 
NET_IP_ALIGN from the dma buffer address, so that the buffer for which a 
sync is requested is cacheline aligned (is that guaranteed?). Would that 
change be more acceptable?

Thanks,
Matt
