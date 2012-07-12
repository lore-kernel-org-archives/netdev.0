From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 2/2] net: Update alloc frag to reduce get/put page usage
 and recycle pages
Date: Wed, 11 Jul 2012 19:02:39 -0700
Message-ID: <4FFE303F.8070902@gmail.com>
References: <20120712001804.26542.2889.stgit@gitlad.jf.intel.com>  <20120712001810.26542.61967.stgit@gitlad.jf.intel.com> <1342052967.3265.8210.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:50387 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab2GLCCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 22:02:44 -0400
Received: by gglu4 with SMTP id u4so1938914ggl.19
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 19:02:44 -0700 (PDT)
In-Reply-To: <1342052967.3265.8210.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/11/2012 5:29 PM, Eric Dumazet wrote:
> On Wed, 2012-07-11 at 17:18 -0700, Alexander Duyck wrote:
>> This patch does several things.
>>
>> First it reorders the netdev_alloc_frag code so that only one conditional
>> check is needed in most cases instead of 2.
>>
>> Second it incorporates the atomic_set and atomic_sub_return logic from an
>> earlier proposed patch by Eric Dumazet allowing for a reduction in the
>> get_page/put_page overhead when dealing with frags.
>>
>> Finally it also incorporates the page reuse code so that if the page count
>> is dropped to 0 we can just reinitialize the page and reuse it.
>>
>> Cc: Eric Dumazet<edumazet@google.com>
>> Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>> ---
>
> Hmm, I was working on a version using order-3 pages if available.
>
> (or more exactly 32768 bytes chunks)
>
> I am not sure how your version can help with typical 1500 allocations
> (2 skbs per page)
>
>
The gain will be minimal if any with the 1500 byte allocations, however 
there shouldn't be a performance degradation.

I was thinking more of the ixgbe case where we are working with only 256 
byte allocations and can recycle pages in the case of GRO or TCP.  For 
ixgbe the advantages are significant since we drop a number of the 
get_page calls and get the advantage of the page recycling.  So for 
example with GRO enabled we should only have to allocate 1 page for 
headers every 16 buffers, and the 6 slots we use in that page have a 
good likelihood of being warm in the cache since we just keep looping on 
the same page.

Thanks,

Alex
