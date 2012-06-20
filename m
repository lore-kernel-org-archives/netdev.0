From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Wed, 20 Jun 2012 10:14:57 -0700
Message-ID: <4FE20511.4000206@intel.com>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com> <1340170590.4604.784.camel@edumazet-glaptop> <4FE1FABF.6040309@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23068 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752158Ab2FTRO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 13:14:58 -0400
In-Reply-To: <4FE1FABF.6040309@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2012 09:30 AM, Alexander Duyck wrote:
> On 06/19/2012 10:36 PM, Eric Dumazet wrote:
>> On Tue, 2012-06-19 at 17:43 -0700, Alexander Duyck wrote:
>>> This patch is meant to help improve system performance when
>>> netdev_alloc_frag is used in scenarios in which buffers are short lived.
>>> This is accomplished by allowing the page offset to be reset in the event
>>> that the page count is 1.  I also reordered the direction in which we give
>>> out sections of the page so that we start at the end of the page and end at
>>> the start.  The main motivation being that I preferred to have offset
>>> represent the amount of page remaining to be used.
>>>
>>> My primary test case was using ixgbe in combination with TCP.  With this
>>> patch applied I saw CPU utilization drop from 3.4% to 3.0% for a single
>>> thread of netperf receiving a TCP stream via ixgbe.
>>>
>>> I also tested several scenarios in which the page reuse would not be
>>> possible such as UDP flows and routing.  In both of these scenarios I saw
>>> no noticeable performance degradation compared to the kernel without this
>>> patch.
>>>
>>> Cc: Eric Dumazet <edumazet@google.com>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>>> ---
>>>
>>>  net/core/skbuff.c |   15 +++++++++++----
>>>  1 files changed, 11 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>>> index 5b21522..eb3853c 100644
>>> --- a/net/core/skbuff.c
>>> +++ b/net/core/skbuff.c
>>> @@ -317,15 +317,22 @@ void *netdev_alloc_frag(unsigned int fragsz)
>>>  	if (unlikely(!nc->page)) {
>>>  refill:
>>>  		nc->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
>>> -		nc->offset = 0;
>>>  	}
>>>  	if (likely(nc->page)) {
>>> -		if (nc->offset + fragsz > PAGE_SIZE) {
>>> +		unsigned int offset = PAGE_SIZE;
>>> +
>>> +		if (page_count(nc->page) != 1)
>>> +			offset = nc->offset;
>>> +
>>> +		if (offset < fragsz) {
>>>  			put_page(nc->page);
>>>  			goto refill;
>>>  		}
>>> -		data = page_address(nc->page) + nc->offset;
>>> -		nc->offset += fragsz;
>>> +
>>> +		offset -= fragsz;
>>> +		nc->offset = offset;
>>> +
>>> +		data = page_address(nc->page) + offset;
>>>  		get_page(nc->page);
>>>  	}
>>>  	local_irq_restore(flags);
>>>
>> I tested this idea one month ago and got not convincing results, because
>> the branch was taken half of the time.
>>
>> The cases where page can be reused is probably specific to ixgbe because
>> it uses a different allocator for the frags themselves.
>> netdev_alloc_frag() is only used to allocate the skb head.
> Actually it is pretty much anywhere a copy-break type setup exists.  I
> think ixgbe and a few other drivers have this type of setup where
> netdev_alloc_skb is called and the data is just copied into the buffer. 
> My thought was if that I can improve this one case without hurting the
> other cases I should just go ahead and submit it since it is a net win
> performance wise.
>
> I think one of the biggest advantages of this for ixgbe is that it
> allows the buffer to become cache warm so that writing the shared info
> and copying the header contents becomes very cheap compared to accessing
> a cache cold page.
>
>> For typical nics, we allocate frags to populate the RX ring _way_ before
>> packet is received by the NIC.
>>
>> Then, I played with using order-2 pages instead of order-0 ones if
>> PAGE_SIZE < 8192.
>>
>> No clear win either, but you might try this too.
> The biggest issue I see with an order-2 page is that it means the memory
> is going to take much longer to cycle out of a shared page.  As a result
> changes like the one I just came up with would likely have little to no
> benefit because we would run out of room in the frags list before we
> could start reusing a fresh page.
>
> Thanks,
>
> Alex
>
Actually I think I just realized what the difference is.  I was looking
at things with LRO disabled.  With LRO enabled our hardware RSC feature
kind of defeats the whole point of the GRO or TCP coalescing anyway
since it will stuff 16 fragments into a single packet before we even
hand the packet off to the stack.

Thanks,

Alex
