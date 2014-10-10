From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in __skb_flow_get_ports
Date: Fri, 10 Oct 2014 07:42:58 -0700
Message-ID: <5437F072.5060502@redhat.com>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>	<20141010035840.21428.359.stgit@ahduyck-workstation.home> <20141010.004708.1975127853551765914.davem@davemloft.net>
Reply-To: alexander.h.duyck@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65463 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950AbaJJOnC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 10:43:02 -0400
In-Reply-To: <20141010.004708.1975127853551765914.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2014 09:47 PM, David Miller wrote:
> From: alexander.duyck@gmail.com
> Date: Thu, 09 Oct 2014 21:03:28 -0700
>
>> From: Alexander Duyck <alexander.h.duyck@redhat.com>
>>
>> This patch addresses a kernel unaligned access bug seen on a sparc64 system
>> with an igb adapter.  Specifically the __skb_flow_get_ports was returning a
>> be32 pointer which was then having the value directly returned.
>>
>> In order to keep the handling of the ports consistent with how we were
>> handling the IPv4 and IPv6 addresses I have instead replaced the assignment
>> with a memcpy to the flow key ports value.  This way it should stay a
>> memcpy on systems that cannot handle unaligned access, and will likely be
>> converted to a 32b assignment on the systems that can support it.
>>
>> Reported-by: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> Guess what the compiler will output for the memcpy()....
>
> 	*(u32 *)dest = *(u32 *)src;
>
> Using memcpy() is never a valid way to avoid misaligned loads and
> stores.

If needed we could convert ports to a __be16 I suppose.

> If the types have a given alignment, the compiler can legitimately
> expand the memcpy() inline with suitably sized loads and stores.

That is what I get for trying to come up with a fix at the end of the 
day.  Although it does leave me scratching my head why the IPv4 and IPv6 
addresses were not causing unaligned accesses or were they triggering 
them as well?

> Please see my other reply in the original thread, we have to use
> the hardware when we can to manage this situation, by configuring
> it to output two garbage bytes before the packet contents when
> DMA'ing into power-of-2 aligned blocks of memory.
>
> Thanks.

The problem is the igb / ixgbe / fm10k hardware doesn't have a means of 
inserting padding from its side.  The whole point of the xxx_get_headlen 
functions was to determine the size needed in order to generate the 
correct memcpy so that we could generate an aligned header.  It sounds 
like we can't do that with this function now because there are multiple 
instances where the data will be accessed unaligned if it isn't aligned 
in the first place.

The way I see it now there are two possible solutions.  The first one 
being to update the flow hash functions to work with unaligned accesses, 
and the second being to split the get_headlen code flow off and for now 
use my original code which already had all the alignment issues 
resolved.  I'm open to suggestions either way, but for now I will try to 
just address the items you have pointed out here with the current patch 
and submit a v2.

Thanks,

Alex
