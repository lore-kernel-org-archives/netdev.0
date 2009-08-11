From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Tue, 11 Aug 2009 03:32:10 -0400
Message-ID: <20090811033210.6b422ed1.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<4A7C9A14.7070600@inria.fr>
	<20090807175112.a1f57407.billfink@mindspring.com>
	<4A7CCEFC.7020308@myri.com>
	<20090807213557.d0faec23.billfink@mindspring.com>
	<4A7D5CA4.3030307@myri.com>
	<20090808112636.GB18518@localhost.localdomain>
	<4A7DC230.6060206@myri.com>
	<20090808183251.GA23300@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:37799 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752308AbZHKL6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 07:58:15 -0400
In-Reply-To: <20090808183251.GA23300@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 8 Aug 2009, Neil Horman wrote:

> On Sat, Aug 08, 2009 at 02:21:36PM -0400, Andrew Gallatin wrote:
> > Neil Horman wrote:
> >> On Sat, Aug 08, 2009 at 07:08:20AM -0400, Andrew Gallatin wrote:
> >>> Bill Fink wrote:
> >>>> On Fri, 07 Aug 2009, Andrew Gallatin wrote:
> >>>>
> >>>>> Bill Fink wrote:
> >>>>>
> >>>>>> All sysfs local_cpus values are the same (00000000,000000ff),
> >>>>>> so yes they are also wrong.
> >>>>> How were you handling IRQ binding?  If local_cpus is wrong,
> >>>>> the irqbalance will not be able to make good decisions about
> >>>>> where to bind the NICs' IRQs.  Did you try manually binding
> >>>>> each NICs's interrupt to a separate CPU on the correct node?
> >>>> Yes, all the NIC IRQs were bound to a CPU on the local NUMA node,
> >>>> and the nuttcp application had its CPU affinity set to the same
> >>>> CPU with its memory affinity bound to the same local NUMA node.
> >>>> And the irqbalance daemon wasn't running.
> >>> I must be misunderstanding something.  I had thought that
> >>> alloc_pages() on NUMA would wind up doing alloc_pages_current(), which
> >>> would allocate based on default policy which (if not interleaved)
> >>> should allocate from the current NUMA node.  And since restocking the
> >>> RX ring happens from a the driver's NAPI softirq context, then it
> >>> should always be restocking on the same node the memory is destined to
> >>> be consumed on.
> >>>
> >>> Do I just not understand how alloc_pages() works on NUMA?
> >>>
> >>
> >> Thats how alloc_works, but most drivers use netdev_alloc_skb to refill their rx
> >> ring in their napi context.  netdev_alloc_skb specifically allocates an skb from
> >> memory in the node that the actually NIC is local to (rather than the cpu that
> >> the interrupt is running on).  That cuts out cross numa node chatter when the
> >> device is dma-ing a frame from the hardware to the allocated skb.  The offshoot
> >> of that however (especially in 10G cards with lots of rx queues whos interrupts
> >> are spread out through the system) is that the irq affinity for a given irq has
> >> an increased risk of not being on the same node as the skb memory.  The ftrace
> >> module I referenced earlier will help illustrate this, as well as cases where
> >> its causing applications to run on processors that create lots of cross-node
> >> chatter.
> >
> > One thing worth noting is that myri10ge is rather unusual in that
> > it fills its RX rings with pages, then attaches them to skbs  after
> > the receive is done.   Given how (I think) alloc_page() works, I
> > don't understand why correct CPU binding does not have the same
> > benefit as Bill's patch to assign the NUMA node manually.
> >
> > I'm certainly willing to change to myri10ge to use alloc_pages_node()
> > based on NIC locality, if that provides a benefit, but I'd really
> > like to understand why CPU binding is not helping.

I originally tried to just use alloc_pages_node() instead of alloc_pages(),
but it didn't help.  As mentioned in an earlier e-mail, that seems to
be because I discovered that doing:

	find /sys -name numa_node -exec grep . {} /dev/null \;

revealed that the NUMA node associated with _all_ the PCI devices was
always 0, when at least some of them should have been associated with
NUMA node 2, including 6 of the 12 Myricom 10-GigE devices.
 
I discovered today that the NUMA node cpulist/cpumap is also wrong.
A cat of /sys/devices/system/node/node0/cpulist returns "0-7" (with a
cpumask of 00000000,000000ff), while the cpulist for node2 is empty
(with a cpumask of 00000000,00000000).  The distance is correct,
with "10 20" for node 0 and "20 10" for node2.

Since there seems to be an underlying kernel issue here, what would
be the proper place to address the apparently incorrect assignment
of NUMA node information for this system?

Even with my hacked workaround, which basically doubled the receive
side performance without my patch, the performance level was still
subpar from what I would have expected should be possible based on
some other tests I ran, such as the following single and multiple
parallel nuttcp loopback tests.

On Asus P6T6 motherboard with single Intel i7 965 3.2 GHz (overclocked
to 3.4 GHz) quad-core processor (non-NUMA):

Single nuttcp loopback test using CPUs 0 and 1:

[root@i7test1 ~]# nuttcp -xc0/1 192.168.1.10
44948.3125 MB /  10.04 sec = 37554.1394 Mbps 99 %TX 75 %RX 0 retrans 0.04 msRTT

Two parallel nuttcp loopback tests using CPUs 0, 1, 2, and 3:

[root@i7test1 ~]# nuttcp -xc0/1 -p5101 192.168.1.10 & nuttcp -xc2/3 -p5102 192.168.1.10 &
43595.0000 MB /  10.04 sec = 36423.4339 Mbps 99 %TX 82 %RX 0 retrans 0.04 msRTT
43384.5000 MB /  10.04 sec = 36247.5115 Mbps 99 %TX 74 %RX 0 retrans 0.02 msRTT

Aggregate performance:		72.6709 Gbps

On SuperMicro X8DAH+-F motherboard with dual Intel Xeon 5580 3.2 GHz
quad-core processors (NUMA):

Single nuttcp loopback test using CPUs 0 and 2 on NUMA node 0:

[root@xeontest1 ~]# nuttcp -xc0/2 192.168.1.14
39348.0000 MB /  10.04 sec = 32875.4865 Mbps 99 %TX 59 %RX 0 retrans 0.06 msRTT

Two parallel nuttcp loopback tests using CPUs 0, 2, 4, and 6 on NUMA node 0:

[root@xeontest1 ~]# nuttcp -xc0/2 -p5101 192.168.1.14 & nuttcp -xc4/6 -p5102 192.168.1.14 &
36197.0625 MB /  10.04 sec = 30245.0918 Mbps 99 %TX 59 %RX 0 retrans 0.06 msRTT
38153.5000 MB /  10.04 sec = 31876.4556 Mbps 99 %TX 75 %RX 0 retrans 0.04 msRTT

Aggregate performance:		62.1215 Gbps

While the performance using a single Xeon 5580 quad-core processor on
the SuperMicro system was 12.5 % to 14.5 % slower than the single i7 965
quad-core processor on the Asus system, when you use both of the Xeon 5580
quad core processors:

Four parallel nuttcp loopback tests using CPUs 0, 2, 4, and 6 on NUMA node 0,
and CPUs 1, 3, 5, and 7 on NUMA node 2:

[root@xeontest1 ~]# nuttcp -xc0/2 -p5101 192.168.1.14 & nuttcp -xc4/6 -p5102 192.168.1.14 & numactl --membind=2 nuttcp -xc1/3 -p5103 192.168.1.14 & numactl --membind=2 nuttcp -xc5/7 -p5104 192.168.1.14 &
36340.4375 MB /  10.04 sec = 30363.2672 Mbps 99 %TX 71 %RX 0 retrans 0.06 msRTT
36344.1250 MB /  10.04 sec = 30365.1838 Mbps 99 %TX 70 %RX 0 retrans 0.04 msRTT
34134.5625 MB /  10.04 sec = 28519.0180 Mbps 98 %TX 67 %RX 0 retrans 0.06 msRTT
34812.6875 MB /  10.04 sec = 29085.5312 Mbps 99 %TX 66 %RX 0 retrans 0.04 msRTT

Aggregate performance:		118.3330 Gbps

Overall the SuperMicro system outperforms the Asus system by 62.8 %.
Since a test between a pair of the i7 test systems achieved an aggregate
performance of ~70 Gbps, and could probably have achieved 80 Gbps except
for a motherboard restriction, it would seem the dual Xeon system should
be able to achieve at least the same level of aggregate performance.
On the transmit side it excels, achieving 100 Gbps.  But on the receive
side, even with my hacked workaround, it tops out at 56 Gbps.  I would
welcome any further ideas on what might still be limiting the aggregate
receive side performance of the dual Xeon NUMA system.

> Thats hard to say.  If binding the app to a cpu on the same node doesn't help,
> that would suggest to me:
> 
> 1) That the process binding isn't being honored
> 2) The cpu you're binding to isn't actually on the same node
> 3) The node which the skb's are allocated on is not the one you think it is
> 4) The cross numa chatter is improved, but another problem has taken its place
> (like cpu contention between the process and the interrupt handler on the samme
> cpu)
> 5) The problem is something else entirely.
> 
> Either way, I'd suggest applying and running the patch set that I referenced
> previously.  It will give you a good table representation of how skbs for this
> process are being allocated and consumed, and let you confirm or eliminate items
> 1-4 above.

Unfortunately I haven't had a chance to try that yet, as I was away
for the weekend and then there was an emergency at work today.  But
I will hopefully get a chance to try it out shortly.  I had some
initial concerns about just how much trace data would be generated
for a 10-second 10-GigE (or 100-GigE) test, but after doing some
quick calculations for 9000 byte jumbo frames, I guess it's a manageable
amount of data.

						-Thanks

						-Bill
