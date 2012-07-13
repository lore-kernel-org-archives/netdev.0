From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 1/2] net: Add new network device function to allow
 for MMIO batching
Date: Fri, 13 Jul 2012 08:37:16 -0700
Message-ID: <500040AC.3070800@intel.com>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>  <20120712002603.27846.23752.stgit@gitlad.jf.intel.com>  <1342077259.3265.8232.camel@edumazet-glaptop>  <4FFEEF99.7030707@intel.com> <1342165129.3265.8320.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, therbert@google.com,
	alexander.duyck@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13794 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933270Ab2GMPhS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 11:37:18 -0400
In-Reply-To: <1342165129.3265.8320.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2012 12:38 AM, Eric Dumazet wrote:
> On Thu, 2012-07-12 at 08:39 -0700, Alexander Duyck wrote:
>
>> The problem is in both of the cases where I have seen the issue the
>> qdisc is actually empty.
>>
> You mean a router workload, with links of same bandwidth.
> (BQL doesnt trigger)
>
> Frankly what percentage of linux powered machines act as high perf
> routers ?
Actually I was seeing this issue with the sending application on the
same CPU as the Tx cleanup.  The problem was the CPU would stall and
consume cycles instead of putting work into placing more packets on the
queue. 

>> In the case of pktgen it does not use the qdisc layer at all.  It just
>> directly calls ndo_start_xmit.
> pktgen is in kernel, adding a complete() call in it is certainly ok,
> if we can avoid kernel bloat.
>
> I mean, pktgen represents less than 0.000001 % of real workloads.
I realize that, but it does provide a valid means of stress testing an
interface and demonstrating that the MMIO writes are causing significant
stalls and bus utilization.

>> In the standard networking case we never fill the qdisc because the MMIO
>> write stalls the entire CPU so the application never gets a chance to
>> get ahead of the hardware.  From what I can tell the only case in which
>> the qdisc_run solution would work is if the ndo_start_xmit was called on
>> a different CPU from the application that is doing the transmitting.
> Hey, I can tell that qdisc is not empty on many workloads.
> But BQL and TSO mean we only send one or two packets per qdisc run.
>
> I understand this MMIO batching helps routers workloads, or workloads
> using many small packets.
>
> But on other workloads, this adds a significant latency source
> (NET_TX_SOFTIRQ)
>
> It would be good to instrument the extra delay on a single UDP send.
>
> (entering do_softirq() path is not a few instructions...)
These kind of issues are one of the reasons why this feature is disabled
by default.  You have to explicitly enable it by setting the
dispatch_limit to something other than 0.

I suppose I could just make it a part of the Tx cleanup itself since I
am only doing a trylock instead of waiting and taking the full lock.  I
am open to any other suggestions for alternatives other than NET_TX_SOFTIRQ.

Thanks,

Alex
