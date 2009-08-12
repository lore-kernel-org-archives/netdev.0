From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 12 Aug 2009 00:30:49 -0400
Message-ID: <20090812003049.185cd52a.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<4A7C9A14.7070600@inria.fr>
	<20090807175112.a1f57407.billfink@mindspring.com>
	<4A7CCEFC.7020308@myri.com>
	<20090807213557.d0faec23.billfink@mindspring.com>
	<4A7D5CA4.3030307@myri.com>
	<20090808112636.GB18518@localhost.localdomain>
	<4A7DC230.6060206@myri.com>
	<20090808183251.GA23300@localhost.localdomain>
	<20090811033210.6b422ed1.billfink@mindspring.com>
	<87ws5af0km.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:51995
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751362AbZHLEa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 00:30:57 -0400
In-Reply-To: <87ws5af0km.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Aug 2009, Andi Kleen wrote:

> Bill Fink <billfink@mindspring.com> writes:
> >
> > I originally tried to just use alloc_pages_node() instead of alloc_pages(),
> > but it didn't help.  As mentioned in an earlier e-mail, that seems to
> > be because I discovered that doing:
> >
> > 	find /sys -name numa_node -exec grep . {} /dev/null \;
> >
> > revealed that the NUMA node associated with _all_ the PCI devices was
> > always 0, when at least some of them should have been associated with
> > NUMA node 2, including 6 of the 12 Myricom 10-GigE devices.
> 
> > I discovered today that the NUMA node cpulist/cpumap is also wrong.
> > A cat of /sys/devices/system/node/node0/cpulist returns "0-7" (with a
> > cpumask of 00000000,000000ff), while the cpulist for node2 is empty
> > (with a cpumask of 00000000,00000000).  The distance is correct,
> > with "10 20" for node 0 and "20 10" for node2.
> 
> When the CPU nodes are not correct the device nodes are unlikely
> to correct either. In fact your system likely has no node 1 configured, 
> right?

That was right.  There was no node 1, only nodes 0 and 2.

> This information comes from the BIOS. So either your BIOS is broken
> or you simply didn't enable NUMA mode in the BIOS, but configured
> memory interleaving.
> 
> If you post dmesg output somewhere I can take a look.

I did have NUMA enabled, and memory was configured as independent
rather than interleaved.

Based on all the discussions, it seemed a good possibility that the
BIOS was broken.  Today a colleague checked the SuperMicro site, and
discovered and installed a newer version of the BIOS.  Things seem
better now, but not totally correct.

There are now NUMA nodes 0 and 1 instead of 0 and 2, and the CPUs
for node 0 are 0 through 3 while the CPUs for node 1 are 4 through 7
(previously the even CPUs were on the first Xeon 5580 processor while
the odd CPUs were on the second processor).

[root@xeontest1 ~]# numastat
                           node0           node1
numa_hit                28087735        27195340
numa_miss                      0               0
numa_foreign                   0               0
interleave_hit             12065           11978
local_node              28081559        27182572
other_node                  6176           12768

[root@xeontest1 ~]# grep 'physical id' /proc/cpuinfo
physical id     : 0
physical id     : 0
physical id     : 0
physical id     : 0
physical id     : 1
physical id     : 1
physical id     : 1
physical id     : 1

[root@xeontest1 ~]# cat /sys/devices/system/node/node0/cpulist
0-3
[root@xeontest1 ~]# cat /sys/devices/system/node/node1/cpulist
4-7

But _all_ the PCI devices are still just on node 0.

[root@xeontest1 ~]# find /sys -name numa_node -exec grep . {} /dev/null \;

shows numa_node is always 0.

[root@xeontest1 ~]# find /sys -name local_cpulist -exec grep . {} /dev/null \;

shows local_cpulist is always 0-3.

I now can get basically the same level of aggregate receive side
performance (55 Gbps) without my patch that I could previously get
only with my hacked workaround in the myri10ge driver.  But this
still seems significantly subpar to what I believe it should be
capable of.

BTW when I first booted the test system after upgrading the BIOS,
I got a kernel oops because it was still using my hacked myri10ge
driver, and apparently it didn't like that I was specifying to
use a then nonexistent node 2 (I was checking for success of the
alloc_pages_node() call and falling back to the original alloc_pages()
call on failure).  Or it could have been on the __alloc_skb() call
where I had a similar hack for the skb allocation.

Are you still interested in me posting the dmesg output?

						-Thanks

						-Bill
