From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 03/10] ixgbe: Drop the TX work limit and instead just
 leave it to budget
Date: Tue, 23 Aug 2011 13:52:18 -0700
Message-ID: <4E541302.2050007@intel.com>
References: <4E52920F.7060603@intel.com>	<20110822.135644.683110224886588181.davem@davemloft.net>	<4E52DEEF.40504@intel.com>	<20110822.164027.1830363266993513959.davem@davemloft.net> <CAKgT0UeUCyNRbfvkGKdyi17K6T-fSHukMGYwyJu2xOmAiBDZNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:47334 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534Ab1HWUz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Aug 2011 16:55:28 -0400
In-Reply-To: <CAKgT0UeUCyNRbfvkGKdyi17K6T-fSHukMGYwyJu2xOmAiBDZNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2011 09:04 PM, Alexander Duyck wrote:
> On Mon, Aug 22, 2011 at 4:40 PM, David Miller<davem@davemloft.net>  wrote:
>> From: Alexander Duyck<alexander.h.duyck@intel.com>
>> Date: Mon, 22 Aug 2011 15:57:51 -0700
>>> The problem seemed to be present as long as I allowed the TX budget to
>>> be a multiple of the RX budget.  The easiest way to keep things
>>> balanced and avoid allowing the TX from one CPU to overwhelm the RX on
>>> another was just to keep the budgets equal.
>> You're executing 10 or 20 cpu cycles after every 64 TX reclaims,
>> that's the only effect of these changes.  That's not even long enough
>> for a cache line to transfer between two cpus.
> It sounds like I may not have been seeing this due to the type of
> workload I was focusing on.  I'll try generating some data with pktgen
> and netperf tomorrow to see how this holds up under small packet
> transmit only traffic since those are the cases most likely to get
> into the state you mention.
>
> Also I would appreciate it if you had any suggestions on other
> workloads I might need to focus on in order to determine the impact of
> this change.
>
> Thanks,
>
> Alex

I found a reason to rewrite this.  Basically this modification has a 
negative impact in the case of multiple ports on a single CPU all 
routing to the same port on the same CPU.  It ends up making it so that 
the transmit throughput is only (total CPU packets per second)/(number 
of ports receiving on cpu).  So on a system that can receive at 1.4Mpps 
on a single core we end up seeing only a little over 350Kpps of transmit 
when 4 ports are all receiving packets on the system.

I'll look at rewriting this.  I'll probably leave the work limit 
controlling things but lower it to a more reasonable value such as 1/2 
to 1/4 of the ring size.

Thanks,

Alex
