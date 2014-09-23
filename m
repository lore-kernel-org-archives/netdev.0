From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv6 net-next 1/3] sunvnet: upgrade to VIO protocol version
 1.6
Date: Tue, 23 Sep 2014 12:49:27 -0400
Message-ID: <5421A497.9060903@oracle.com>
References: <541A2316.5010603@oracle.com>	<2AB76E42-C12D-47C5-8476-0D0C611691A5@oracle.com>	<541AD838.50700@oracle.com> <20140923.122420.1216927815526255624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Raghuram.Kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18568 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755515AbaIWQtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 12:49:32 -0400
In-Reply-To: <20140923.122420.1216927815526255624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/23/2014 12:24 PM, David Miller wrote:
> From: David L Stevens <david.stevens@oracle.com>
> Date: Thu, 18 Sep 2014 09:03:52 -0400
> 
>> So, if this is actually too much memory, I was more inclined to reduce the ring
>> size rather than either add complicating code to handle active-ring reallocation
>> that would typically be run once per boot, or another alternative of adding
>> module parameters to specify the buffer size TSO/GSO will need 64K to perform
>> well, regardless of the device MTU.
> 
> The only reason we are having this discussion is because of how we
> handle TX packets.
> 
> I think we really should directly map the SKBs in vnet_start_xmit()
> instead of having these preallocate TX buffers.
> 
> The only thing to accomodate is the VNET_PACKET_SKIP, but that
> shouldn't be hard at all.
> 
> And I am rather certain that an LDC map call will be cheaper than
> copying the entire packet.
> 
> Then the MTU will have no material impact on per-vnet_port memory
> costs, and bulk sending performance should also increase.
> 

Actually, that's exactly what I've been working on for the last few
days. I hope to post this soon. Currently, I allow for misaligned
packets by reallocating the skbs with the proper alignment, skip and
length restrictions, so the code can handle either, but still copies
most of the time. Once I have all the kinks worked out there, I was
planning to possibly make *all* skb allocations on LDOMs and/or SPARC64 fit
those requirements, since they are compatible with the existing alignments
and would allow using the HV copy in any case.

> David I know you've worked hard on this patch set, but I'm going to
> defer on this series for now.  There are several implementation level
> issues that are still seemingly up in the air.

	Yes, sorry if it wasn't clear in my response to Raghuram, but I
agree to the extent that we shouldn't attach large-buffer allocations to
something scaling at O(n^2), which is why I started on this other patch.

> I'm almost completely sold on your PMTU scheme, however if we do
> direct mapping of SKBs in vnet_start_xmit() then the performance
> characteristics with larger MTUs might be different.

	Yes; the good news is that without the fixed-size buffers,
memory use is only for the pending traffic, greatly improving scalability.
The bad news is that the allocs and frees will have a performance cost,
which I'm hoping will be balanced or bettered by removing the copy.
	Anyway, I'll repost when I have all this ready.

						+-DLS
