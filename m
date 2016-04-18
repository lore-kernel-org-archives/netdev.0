From: Sinan Kaya <okaya@codeaurora.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 09:49:10 -0400
Message-ID: <5714E5D6.7050600@codeaurora.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418121247.GA25387@infradead.org>
 <0c6a430c5f0ec64f51d7c594ef9751dd@codeaurora.org>
 <20160418131058.GA25421@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, timur@codeaurora.org,
	cov@codeaurora.org, Yishai Hadas <yishaih@mellanox.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42984 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbcDRNtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 09:49:19 -0400
In-Reply-To: <20160418131058.GA25421@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/2016 9:10 AM, Christoph Hellwig wrote:
> On Mon, Apr 18, 2016 at 09:06:18AM -0400, okaya@codeaurora.org wrote:
>> On 2016-04-18 08:12, Christoph Hellwig wrote:
>>> On Sat, Apr 16, 2016 at 06:23:32PM -0400, Sinan Kaya wrote:
>>>> Current code is assuming that the address returned by dma_alloc_coherent
>>>> is a logical address. This is not true on ARM/ARM64 systems.
>>>
>>> Can you explain what you mean with a 'logical address' and what actual
>>> issue you're trying to solve?
>>
Here is a good description of logical address vs. virtual address.

https://www.quora.com/What-is-the-Kernel-logical-and-virtual-addresses-What-is-the-difference-between-them-What-is-the-type-of-addresses-listed-in-the-System-map


>> Vmap call is failing on arm64 systems because dma alloc api already returns
>> an address mapped with vmap.
> 
> Please state your problem clearly.  What I'm reverse engineering from
> your posts is:  because dma_alloc_coherent uses vmap-like mappings on
> arm64 (all, some systems?) 

All arm64 systems. 

>a driver using a lot of them might run into
> limits of the vmap pool size.
> 
> Is this correct?
> 
No, the driver is plain broken without this patch. It causes a kernel panic 
during driver probe.

This is the definition of vmap API.

https://www.kernel.org/doc/htmldocs/kernel-api/API-vmap.html

VMAP allows you to make several pages look contiguous to the CPU. 
It can only be used against logical addresses returned from kmalloc 
or alloc_page. 

You cannot take several virtually mapped addresses returned by dma_alloc_coherent
and try to make them virtually contiguous again. 

The code happens to work on other architectures by pure luck. AFAIK, dma_alloc_coherent
returns logical addresses on Intel systems until it runs out of DMA memory. After 
that intel arch will also start returning virtually mapped addresses and this code
will also fail. ARM64 on the other hand always returns a virtually mapped address.

The goal of this code is to allocate a bunch of page sized memory and make it look
contiguous. It is just using the wrong API. The correct API is either kmalloc or
alloc_page map it with dma_map_page not dma_alloc_coherent.

The proper usage of dma_map_page requires code to call dma_sync API in correct
places to be compatible with noncoherent systems. This code is already assuming
coherency. It would be a nice to have dma_sync APIs in right places. There is no
harm in calling dma_sync API for coherent systems as they are no-ops in DMA mapping
layer whereas it is a cache flush for non-coherent systems.

>>
>> Please see arch/arm64/mm directory.
> ---end quoted text---
> 

I hope it is clear now. The previous email was the most I could type on my phone.

-- 
Sinan Kaya
Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
