From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Tue, 18 Aug 2009 03:07:18 -0400
Message-ID: <20090818030718.aef199f4.billfink@mindspring.com>
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
	<F169D4F5E1F1974DBFAFABF47F60C10A36523146@orsmsx507.amr.corp.intel.com>
	<20090812003824.26c9c8fb.billfink@mindspring.com>
	<20090814163155.968872fe.billfink@mindspring.com>
	<20090817095302.0c41ef68@jbarnes-g45>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:50885
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752667AbZHRHH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 03:07:26 -0400
In-Reply-To: <20090817095302.0c41ef68@jbarnes-g45>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Aug 2009 09:53:02 -0700, Jesse Barnes wrote:

> On Fri, 14 Aug 2009 16:31:55 -0400
> Bill Fink <billfink@mindspring.com> wrote:
> 
> Hm, yeah it probably should have the full CPU mask...
> 
> > Also, is it just not possible on this type of Intel Xeon system to
> > properly associate the PCI devices with the nearest NUMA node?
> 
> All the PCI devices hang off the root complex, which is the same
> distance to each node of memory (at least that's my understanding for
> current platforms).

I admit to being confused then.  The basic system architecture
of the SuperMicro system is:

      Memory----CPU1----QPI----CPU2----Memory
                  |              |
                  |              |
                 QPI            QPI
                  |              |
                  |              |
                5520----QPI----5520
                ||||           ||||
                ||||           ||||
                ||||           ||||
                PCIe           PCIe

It doesn't appear that a given PCIe device is equidistant to the
two nodes of memory.  It's one QPI hop to the "local" (same side)
node, and two QPI hops to the "remote" (far side) node.  But then
I don't know what a root complex is, and how it fits into the
system architecture above.

> > In any event, the patch didn't help (or hurt).  The transmit
> > performance remained at ~100 Gbps while the receive performance
> > remained at 55 Gbps.
> 
> Maybe the other Jesse has some ideas here.

Any and all ideas welcome.  I even considered the idea that maybe
instead of transferring 9000 bytes of payload, perhaps it was
transferring the next higher power of 2, namely 16384, since
bc told me that 9000/16384*100 was 54.9316.  But I tried a test
today with an MTU of 8000 and it didn't make any difference.

BTW here's a diff of an "lspci -vvvxxxx" on the better receive side
performing Asus system (<) versus on the SuperMicro system (>) for
one of the Myricom 10-GigE interfaces:

[root@xeontest1 ~]# diff -bw /tmp/foo2 /tmp/foo3
1c1
< 06:00.0 Ethernet controller: MYRICOM Inc. Myri-10G Dual-Protocol NIC (rev 01)
---
> 04:00.0 Ethernet controller: MYRICOM Inc. Myri-10G Dual-Protocol NIC (rev 01)
3c3
<         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
---
>       Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx+

I don't know what the ParErr- versus ParErr+ means.

5,9c5,9
<         Latency: 0, Cache Line Size: 64 bytes
<         Interrupt: pin A routed to IRQ 2277
<         Region 0: Memory at da000000 (64-bit, prefetchable) [size=16M]
<         Region 2: Memory at fa900000 (64-bit, non-prefetchable) [size=1M]
<         Expansion ROM at fa880000 [disabled] [size=512K]
---
>       Latency: 0, Cache Line Size: 256 bytes
>       Interrupt: pin A routed to IRQ 121
>       Region 0: Memory at f3000000 (64-bit, prefetchable) [size=16M]
>       Region 2: Memory at fa300000 (64-bit, non-prefetchable) [size=1M]
>       Expansion ROM at fa280000 [disabled] [size=512K]
11c11
<                 Address: 00000000fee0400c  Data: 4183
---
>               Address: 00000000fee00000  Data: 40cc
45c45
<         Capabilities: [1a8] Device Serial Number b6-be-46-ff-ff-dd-60-00
---
>       Capabilities: [1a8] Device Serial Number 88-be-46-ff-ff-dd-60-00

I don't see much difference other than a larger Cache Line Size
on the SuperMicro system.

47,48c47,48
< 00: c1 14 08 00 06 05 10 00 01 00 00 02 10 00 00 00
< 10: 0c 00 00 da 00 00 00 00 04 00 90 fa 00 00 00 00
---
> 00: c1 14 08 00 46 05 10 00 01 00 00 02 40 00 00 00
> 10: 0c 00 00 f3 00 00 00 00 04 00 30 fa 00 00 00 00
50,52c50,52
< 30: 00 00 88 fa 44 00 00 00 00 00 00 00 0b 01 00 00
< 40: 00 00 00 00 05 54 81 00 0c 40 e0 fe 00 00 00 00
< 50: 83 41 00 00 01 5c 03 00 00 20 00 64 10 a0 02 00
---
> 30: 00 00 28 fa 44 00 00 00 00 00 00 00 0e 01 00 00
> 40: 00 00 00 00 05 54 81 00 00 00 e0 fe 00 00 00 00
> 50: cc 40 00 00 01 5c 03 00 00 20 00 64 10 a0 02 00
73c73
< 1a0: 00 00 00 00 00 00 00 00 03 00 01 00 b6 be 46 ff
---
> 1a0: 00 00 00 00 00 00 00 00 03 00 01 00 88 be 46 ff

And here's part of the dmesg output on the Asus system:

myri10ge: Version 1.4.3-1.358
myri10ge 0000:06:00.0: PCI INT A -> GSI 35 (level, low) -> IRQ 35
myri10ge 0000:06:00.0: setting latency timer to 64
mtrr: type mismatch for da000000,1000000 old: write-back new: write-combining
firmware: requesting myri10ge_eth_z8e.dat
myri10ge 0000:06:00.0: Not enabling ECRC on non-root port 0000:05:02.0
firmware: requesting myri10ge_eth_z8e.dat
myri10ge 0000:06:00.0: MSI IRQ 2282, tx bndry 4096, fw myri10ge_eth_z8e.dat, WC
Disabled

And on the SuperMicro system:

myri10ge: Version 1.4.4-1.401
  alloc irq_desc for 35 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
myri10ge 0000:04:00.0: PCI INT A -> GSI 35 (level, low) -> IRQ 35
myri10ge 0000:04:00.0: setting latency timer to 64
myri10ge 0000:04:00.0: firmware: requesting myri10ge_eth_z8e.dat
myri10ge 0000:04:00.0: Not enabling ECRC on non-root port 0000:03:02.0
myri10ge 0000:04:00.0: firmware: requesting myri10ge_eth_z8e.dat
  alloc irq_desc for 112 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0
myri10ge 0000:04:00.0: irq 112 for MSI/MSI-X
myri10ge 0000:04:00.0: MSI IRQ 112, tx bndry 4096, fw myri10ge_eth_z8e.dat, WC E
nabled
  alloc irq_desc for 24 on cpu 0 node 0
  alloc kstat_irqs on cpu 0 node 0

Interestingly, the "WC Enabled" is only indicated on the first two
10-GigE interfaces and disabled on the other ten.  For the Asus system
it indicates "WC Disabled" on all the interfaces, but also has that
earlier bit about "old: write-back new: write-combining", which doesn't
appear on the SuperMicro system (although that is using a slightly
newer version of the myri10ge driver).

						-Thanks

						-Bill
