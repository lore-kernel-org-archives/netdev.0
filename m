From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Tue, 11 Aug 2009 07:02:54 -0400
Message-ID: <20090811110254.GA26516@hmsreliant.think-freely.org>
References: <20090807170600.9a2eff2e.billfink@mindspring.com> <4A7C9A14.7070600@inria.fr> <20090807175112.a1f57407.billfink@mindspring.com> <4A7CCEFC.7020308@myri.com> <20090807213557.d0faec23.billfink@mindspring.com> <4A7D5CA4.3030307@myri.com> <20090808112636.GB18518@localhost.localdomain> <4A7DC230.6060206@myri.com> <20090808183251.GA23300@localhost.localdomain> <20090811033210.6b422ed1.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59573 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbZHKLxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 07:53:14 -0400
Content-Disposition: inline
In-Reply-To: <20090811033210.6b422ed1.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2009 at 03:32:10AM -0400, Bill Fink wrote:
> On Sat, 8 Aug 2009, Neil Horman wrote:
> 
> > On Sat, Aug 08, 2009 at 02:21:36PM -0400, Andrew Gallatin wrote:
> > > Neil Horman wrote:
> > >> On Sat, Aug 08, 2009 at 07:08:20AM -0400, Andrew Gallatin wrote:
> > >>> Bill Fink wrote:
> > >>>> On Fri, 07 Aug 2009, Andrew Gallatin wrote:
> > >>>>
> > >>>>> Bill Fink wrote:
> > >>>>>
> > >>>>>> All sysfs local_cpus values are the same (00000000,000000ff),
> > >>>>>> so yes they are also wrong.
> > >>>>> How were you handling IRQ binding?  If local_cpus is wrong,
> > >>>>> the irqbalance will not be able to make good decisions about
> > >>>>> where to bind the NICs' IRQs.  Did you try manually binding
> > >>>>> each NICs's interrupt to a separate CPU on the correct node?
> > >>>> Yes, all the NIC IRQs were bound to a CPU on the local NUMA node,
> > >>>> and the nuttcp application had its CPU affinity set to the same
> > >>>> CPU with its memory affinity bound to the same local NUMA node.
> > >>>> And the irqbalance daemon wasn't running.
> > >>> I must be misunderstanding something.  I had thought that
> > >>> alloc_pages() on NUMA would wind up doing alloc_pages_current(), which
> > >>> would allocate based on default policy which (if not interleaved)
> > >>> should allocate from the current NUMA node.  And since restocking the
> > >>> RX ring happens from a the driver's NAPI softirq context, then it
> > >>> should always be restocking on the same node the memory is destined to
> > >>> be consumed on.
> > >>>
> > >>> Do I just not understand how alloc_pages() works on NUMA?
> > >>>
> > >>
> > >> Thats how alloc_works, but most drivers use netdev_alloc_skb to refill their rx
> > >> ring in their napi context.  netdev_alloc_skb specifically allocates an skb from
> > >> memory in the node that the actually NIC is local to (rather than the cpu that
> > >> the interrupt is running on).  That cuts out cross numa node chatter when the
> > >> device is dma-ing a frame from the hardware to the allocated skb.  The offshoot
> > >> of that however (especially in 10G cards with lots of rx queues whos interrupts
> > >> are spread out through the system) is that the irq affinity for a given irq has
> > >> an increased risk of not being on the same node as the skb memory.  The ftrace
> > >> module I referenced earlier will help illustrate this, as well as cases where
> > >> its causing applications to run on processors that create lots of cross-node
> > >> chatter.
> > >
> > > One thing worth noting is that myri10ge is rather unusual in that
> > > it fills its RX rings with pages, then attaches them to skbs  after
> > > the receive is done.   Given how (I think) alloc_page() works, I
> > > don't understand why correct CPU binding does not have the same
> > > benefit as Bill's patch to assign the NUMA node manually.
> > >
> > > I'm certainly willing to change to myri10ge to use alloc_pages_node()
> > > based on NIC locality, if that provides a benefit, but I'd really
> > > like to understand why CPU binding is not helping.
> 
> I originally tried to just use alloc_pages_node() instead of alloc_pages(),
> but it didn't help.  As mentioned in an earlier e-mail, that seems to
> be because I discovered that doing:
> 
> 	find /sys -name numa_node -exec grep . {} /dev/null \;
> 
> revealed that the NUMA node associated with _all_ the PCI devices was
> always 0, when at least some of them should have been associated with
> NUMA node 2, including 6 of the 12 Myricom 10-GigE devices.
>  
> I discovered today that the NUMA node cpulist/cpumap is also wrong.
> A cat of /sys/devices/system/node/node0/cpulist returns "0-7" (with a
> cpumask of 00000000,000000ff), while the cpulist for node2 is empty
> (with a cpumask of 00000000,00000000).  The distance is correct,
> with "10 20" for node 0 and "20 10" for node2.
> 
> Since there seems to be an underlying kernel issue here, what would
> be the proper place to address the apparently incorrect assignment
> of NUMA node information for this system?
> 

Well, its possible that there is a kernel bug, but those tables that you're
reading are parsed IIRC directly from the systems SRAT table in acpi space.  I'm
not sure of a way to read those directly from user space, but IIRC if you turn
on apic debugging they will get dumped out.  It sounds as though perhaps your
SRAT table is incorrectly reporting the location of your devices.  You may also
want to look at dumping out your smbios via dmidecode to see where that places
all your 10G nic cards.

Neil

> 
