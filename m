From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 03/10] ixgbe: Drop the TX work limit and instead just
 leave it to budget
Date: Mon, 22 Aug 2011 15:57:51 -0700
Message-ID: <4E52DEEF.40504@intel.com>
References: <4E528437.5060302@intel.com>	<1314031612.2803.7.camel@bwh-desktop>	<4E52920F.7060603@intel.com> <20110822.135644.683110224886588181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60680 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751530Ab1HVXAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Aug 2011 19:00:48 -0400
In-Reply-To: <20110822.135644.683110224886588181.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2011 01:56 PM, David Miller wrote:
> From: Alexander Duyck<alexander.h.duyck@intel.com>
> Date: Mon, 22 Aug 2011 10:29:51 -0700
>
>> The only problem I was seeing with that was that in certain cases it
>> seemed like the TX cleanup could consume enough CPU time to cause
>> pretty significant delays in processing the RX cleanup.  This in turn
>> was causing single queue bi-directional routing tests to come out
>> pretty unbalanced since what seemed to happen is that one CPUs RX work
>> would overwhelm the other CPU with the TX processing resulting in an
>> unbalanced flow that was something like a 60/40 split between the
>> upstream and downstream throughput.
> But the problem is that now you're applying the budget to two operations
> that have much differing costs.  Freeing up a TX ring packet is probably
> on the order of 1/10th the cost of processing an incoming RX ring frame.
>
> I've advocated to not apply the budget at all to TX ring processing.
I fully understand that the TX path is much cheaper than the RX path.  
One step I have taken in all of this code is that the TX path only 
counts SKBs cleaned, it doesn't count descriptors.  So a single 
descriptor 60byte transmit will cost the same as a 64K 18 descriptor 
TSO.  All I am really counting is the number of times I have called 
dev_kfree_skb_any();
> I can see your delimma with respect to RX ring processing being delayed,
> but if that's really happening you can consider whether the TX ring is
> simply too large.
The problem was occurring even without large rings.  I was seeing issues 
with rings just 256 descriptors in size.  The problem seemed to be that 
the TX cleanup being a multiple of budget was allowing one CPU to 
overwhelm the other and the fact that the TX was essentially unbounded 
was just allowing the issue to feedback on itself.

In the routing test case I was actually seeing significant advantages to 
this approach as we were essentially cleaning just the right number of 
buffers to make room for the next set of transmits when the RX cleanup 
came though.  In addition since the RX and TX workload was balanced it 
kept both locked into polling while the CPU was saturated instead of 
allowing the TX to become interrupt driven.  In addition since the TX 
was working on the same budget as the RX the number of SKBs freed up in 
the TX path would match the number consumed when being reallocated on 
the RX path.

> In any event can you try something like dampening the cost applied to
> budget for TX work (1/2, 1/4, etc.)?  Because as far as I can tell, if
> you are really hitting the budget limit on TX then you won't be doing
> any RX work on that device until a future NAPI round that depletes the
> TX ring work without going over the budget.
The problem seemed to be present as long as I allowed the TX budget to 
be a multiple of the RX budget.  The easiest way to keep things balanced 
and avoid allowing the TX from one CPU to overwhelm the RX on another 
was just to keep the budgets equal.

I'm a bit confused by this last comment.  The full budget is used for TX 
and RX, it isn't divided.  I do a budget worth of TX cleanup and a 
budget worth of RX cleanup within the ixgbe_poll routine, and if either 
of them consume their full budget then I return the budget value as the 
work done.

If you are referring to the case where two devices are sharing the CPU 
then I would suspect this might lead to faster consumption of the 
netdev_budget, but other than that I don't see any starvation issues for 
RX or TX.

Thanks,

Alex
