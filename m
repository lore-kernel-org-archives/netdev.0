From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 05/10] net: move destructor_arg to the front of sk_buff.
Date: Wed, 11 Apr 2012 09:05:17 -0700
Message-ID: <4F85ABBD.5000609@intel.com>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>  <1334067984-7706-5-git-send-email-ian.campbell@citrix.com>  <4F847CF9.3090701@intel.com> <1334083265.5300.288.camel@edumazet-glaptop>  <4F8486E7.5050604@intel.com> <1334132428.5300.2685.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14446 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760003Ab2DKQF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 12:05:28 -0400
In-Reply-To: <1334132428.5300.2685.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2012 01:20 AM, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 12:15 -0700, Alexander Duyck wrote:
>
>> Actually now that I think about it my concerns go much further than the
>> memset.  I'm convinced that this is going to cause a pretty significant
>> performance regression on multiple drivers, especially on non x86_64
>> architecture.  What we have right now on most platforms is a
>> skb_shared_info structure in which everything up to and including frag 0
>> is all in one cache line.  This gives us pretty good performance for igb
>> and ixgbe since that is our common case when jumbo frames are not
>> enabled is to split the head and place the data in a page.
> I dont understand this split thing for MTU=1500 frames.
>
> Even using half a page per fragment, each skb :
>
> needs 2 allocations for sk_buff and skb->head, plus one page alloc /
> reference.
>
> skb->truesize = ksize(skb->head) + sizeof(*skb) + PAGE_SIZE/2 = 512 +
> 256 + 2048 = 2816 bytes
The number you provide for head is currently only available for 128 byte
skb allocations.  Anything larger than that will generate a 1K
allocation.  Also after all of these patches the smallest size you can
allocate will be 1K for anything under 504 bytes.

The size advantage is actually more for smaller frames.  In the case of
igb the behaviour is to place anything less than 512 bytes into just the
header and to skip using the page.  As such we get a much more ideal
allocation for small packets. since the truesize is only 1280 in that case.

In the case of ixgbe the advantage is more of a cache miss advantage. 
Ixgbe only receives the data into pages now.  I can prefetch the first
two cache lines of the page into memory while allocating the skb to
receive it.  As such we essentially cut the number of cache misses in
half versus the old approach which had us generating cache misses on the
sk_buff during allocation, and then generating more cache misses again
once we received the buffer and can fill out the sk_buff fields.  A
similar size advantage exists as well, but only for frames 256 bytes or
smaller.

> With non split you have :
>
> 2 allocations for sk_buff and skb->head.
>
> skb->truesize = ksize(skb->head) + sizeof(*skb) = 2048 + 256 = 2304
> bytes
>
> less overhead and less calls to page allocator...
>
> This only can benefit if GRO is on, since aggregation can use fragments
> and a single sk_buff, instead of a frag_list
There is much more than true size involved here.  My main argument is
that if we are going to align this modified skb_shared_info so that it
is aligned on nr_frags we should do it on all architectures, not just
x86_64.

Thanks,

Alex
