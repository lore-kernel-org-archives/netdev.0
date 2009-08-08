From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Sat, 8 Aug 2009 14:32:51 -0400
Message-ID: <20090808183251.GA23300@localhost.localdomain>
References: <20090807170600.9a2eff2e.billfink@mindspring.com> <4A7C9A14.7070600@inria.fr> <20090807175112.a1f57407.billfink@mindspring.com> <4A7CCEFC.7020308@myri.com> <20090807213557.d0faec23.billfink@mindspring.com> <4A7D5CA4.3030307@myri.com> <20090808112636.GB18518@localhost.localdomain> <4A7DC230.6060206@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50984 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbZHHSc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2009 14:32:57 -0400
Content-Disposition: inline
In-Reply-To: <4A7DC230.6060206@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 08, 2009 at 02:21:36PM -0400, Andrew Gallatin wrote:
> Neil Horman wrote:
>> On Sat, Aug 08, 2009 at 07:08:20AM -0400, Andrew Gallatin wrote:
>>> Bill Fink wrote:
>>>> On Fri, 07 Aug 2009, Andrew Gallatin wrote:
>>>>
>>>>> Bill Fink wrote:
>>>>>
>>>>>> All sysfs local_cpus values are the same (00000000,000000ff),
>>>>>> so yes they are also wrong.
>>>>> How were you handling IRQ binding?  If local_cpus is wrong,
>>>>> the irqbalance will not be able to make good decisions about
>>>>> where to bind the NICs' IRQs.  Did you try manually binding
>>>>> each NICs's interrupt to a separate CPU on the correct node?
>>>> Yes, all the NIC IRQs were bound to a CPU on the local NUMA node,
>>>> and the nuttcp application had its CPU affinity set to the same
>>>> CPU with its memory affinity bound to the same local NUMA node.
>>>> And the irqbalance daemon wasn't running.
>>> I must be misunderstanding something.  I had thought that
>>> alloc_pages() on NUMA would wind up doing alloc_pages_current(), which
>>> would allocate based on default policy which (if not interleaved)
>>> should allocate from the current NUMA node.  And since restocking the
>>> RX ring happens from a the driver's NAPI softirq context, then it
>>> should always be restocking on the same node the memory is destined to
>>> be consumed on.
>>>
>>> Do I just not understand how alloc_pages() works on NUMA?
>>>
>>
>> Thats how alloc_works, but most drivers use netdev_alloc_skb to refill their rx
>> ring in their napi context.  netdev_alloc_skb specifically allocates an skb from
>> memory in the node that the actually NIC is local to (rather than the cpu that
>> the interrupt is running on).  That cuts out cross numa node chatter when the
>> device is dma-ing a frame from the hardware to the allocated skb.  The offshoot
>> of that however (especially in 10G cards with lots of rx queues whos interrupts
>> are spread out through the system) is that the irq affinity for a given irq has
>> an increased risk of not being on the same node as the skb memory.  The ftrace
>> module I referenced earlier will help illustrate this, as well as cases where
>> its causing applications to run on processors that create lots of cross-node
>> chatter.
>
> One thing worth noting is that myri10ge is rather unusual in that
> it fills its RX rings with pages, then attaches them to skbs  after
> the receive is done.   Given how (I think) alloc_page() works, I
> don't understand why correct CPU binding does not have the same
> benefit as Bill's patch to assign the NUMA node manually.
>
> I'm certainly willing to change to myri10ge to use alloc_pages_node()
> based on NIC locality, if that provides a benefit, but I'd really
> like to understand why CPU binding is not helping.
>
Thats hard to say.  If binding the app to a cpu on the same node doesn't help,
that would suggest to me:

1) That the process binding isn't being honored
2) The cpu you're binding to isn't actually on the same node
3) The node which the skb's are allocated on is not the one you think it is
4) The cross numa chatter is improved, but another problem has taken its place
(like cpu contention between the process and the interrupt handler on the samme
cpu)
5) The problem is something else entirely.

Either way, I'd suggest applying and running the patch set that I referenced
previously.  It will give you a good table representation of how skbs for this
process are being allocated and consumed, and let you confirm or eliminate items
1-4 above.

Neil

> Drew
>
