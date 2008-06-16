From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: NAPI, rx_no_buffer_count, e1000, r8169 and other actors
Date: Mon, 16 Jun 2008 07:05:07 +0300
Message-ID: <20080616032830.M5762@visp.net.lb>
References: <20080615200013.M67401@visp.net.lb> <20080615234620.GC2835@solarflare.com> <20080615195918.210fe19f@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:56665 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbYFPEFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 00:05:17 -0400
In-Reply-To: <20080615195918.210fe19f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Jun 2008 19:59:18 -0700, Stephen Hemminger wrote
> On Mon, 16 Jun 2008 00:46:22 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > Denys Fedoryshchenko wrote:
> > > Hi
> > > 
> > > Since i am using PC routers for my network, and i reach significant numbers
> > > (for me significant) i start noticing minor problems. So all this talk about
> > > networking performance in my case.
> > > 
> > > For example.
> > > Sun server, AMD based (two CPU -  AMD Opteron(tm) Processor 248).
> > > e1000 connected over PCI-X ([    4.919249] e1000: 0000:01:01.0: e1000_probe:
> > > (PCI-X:100MHz:64-bit) 00:14:4f:20:89:f4)
> > > 
> > > All traffic processed over eth0, 5 VLAN, 1 second average around 110-200Mbps
> > 
> > Currently TX checksum offload does not work for VLAN devices, which may
> > be a serious performance hit if there is a lot of traffic routed between
> > VLANs.  This should change in 2.6.27 for some drivers, which I think will
> > include e1000.

Probably it is valid for weak CPU's, or in my case really a lot of traffic.

> > 
> > > of traffic. Host running also conntrack (max 1000000 entries, when
packetloss
> > > happen - around 256k entries). Around 1300 routes (FIB_TRIE) running.
What is
> > > worrying me, that ok, i win time by increasing rx descriptors from 256 to
> > > 4096, but how much time i win? if it "cracks" on 100 Mbps RX, it means by
> > > interpolating descriptors increase from 256 to 4096 (4 times), i cannot
> > > process more than 400Mbps RX?
> 
> You are CPU limited because of the overhead of firewalling. When 
> this happens packets get backlogged.

I tried to increase net.core.netdev_max_backlog, it doesn't help, and it
doesn't change anything at all.
But it looks like: if i have 200Mbps RX, with average packet 500 bytes, i have
50Kpps rate. RX descriptor is 256 packets, each 1ms passed 50 packets. If poll
just more than late then 5ms, i miss packets. Or if it doesn't complete all
packets in one softirq cycle.
Probably i understand something (or everything) wrong.

But firewalling must be not a big deal, since i am not using anything "heavy"
like L7 filtering. But i will try to optimize rules, like i did once with u32
hash... so most of packets will not pass "long chain". And, there is around 29
rules on filter, 63 in NAT, 20 in mangle, it's not much i guess.

> 
> > Increasing the RX descriptor ring size should give the driver and stack
> > more time to catch up after handling some packets that take unusually
> > long.  It may also allow you to increase interrupt moderation, which
> > will reduce the per-packet cost.
> 
> No if the receive side is CPU limited, you just end up eating more memory.
> A bigger queue may actually make performance worse (less cache hits).
Thats very good idea. 
e1000 / AMD - cache size      : 1024 KB
and both Core 2 Duo routers - 4096 KB (shared?)

> 
> > > The CPU is not so busy after all... maybe there is a way to change some
> > > parameter to force NAPI poll interface more often?
> > 
> > NAPI polling is not time-based, except indirectly though interrupt
> > moderation.
> 
> How are you measuring CPU? You need to do something like measure the 
> available cycles left for applications. Don't believe top or other 
> measures that may not reflect I/O overhead and bus usage.

Probably mpstat gives correct results? I never use top, other that to find
clear CPU hog userspace app.

Router-Dora ~ # mpstat 1
Linux 2.6.26-rc6-git2-build-0029 (Router-Dora)  06/16/08

06:31:19     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal  
%idle    intr/s
06:31:20     all    0.00    0.00    0.00    0.00    1.51    8.04    0.00  
90.45  13570.30
06:31:21     all    0.00    0.00    0.00    0.00    2.49    9.95    0.00  
87.56  13986.00
06:31:22     all    0.00    0.00    0.50    0.00    2.49    9.45    0.00  
87.56  14364.00


> 
> > > I tried nice, changing realtime priority to FIFO, changing kernel to
> > > preemptible... no luck, except increasing descriptors.
> > > 
> > > Router-Dora ~ # mpstat -P ALL 1
> > > Linux 2.6.26-rc6-git2-build-0029 (Router-Dora)  06/15/08
> > > 
> > > 22:51:02     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal  
> > > %idle    intr/s
> > > 22:51:03     all    1.00    0.00    0.00    0.00    2.50   29.00    0.00  
> > > 67.50  12927.00
> > > 22:51:03       0    2.00    0.00    0.00    0.00    4.00   59.00    0.00  
> > > 35.00  11935.00
> > > 22:51:03       1    0.00    0.00    0.00    0.00    0.00    0.00    0.00 
> > > 100.00    993.00
> > > 22:51:03       2    0.00    0.00    0.00    0.00    0.00    0.00    0.00   
> > > 0.00      0.00
> >  
> > You might do better with a NIC that supports MSI-X.  This allows the use of
> > two RX queues with their own IRQs, each handled by a different processor.
> > As it is, one CPU is completely idle.  However, I don't know how well the
> > other work of routing scales to multiple processors.
> 
> Routing and firewalling should scale well. The deadlock is probably going
> to be some hot lock like the transmit lock.

I tried to change tx queue length. If i make it too much small, it will just
drop packets _silently_. Will not be shown on netstat -s, nor ifconfig stats.
That what i reported before.

> 
> > [...]
> > > I have another host running, Core 2 Duo, e1000e+3 x e100, also
conntrack, same
> > > kernel configuration and similar amount of traffic, higher load (ifb +
plenty
> > > of shapers running) - almost no errors on default settings.
> > > Linux 2.6.26-rc6-git2-build-0029 (Kup)  06/16/08
> > > 
> > > 07:00:27     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal  
> > > %idle    intr/s
> > > 07:00:28     all    0.00    0.00    0.50    0.00    4.00   31.50    0.00  
> > > 64.00  32835.00
> > > 07:00:29     all    0.00    0.00    0.50    0.00    2.50   29.00    0.00  
> > > 68.00  33164.36
> > > 
> > > Third host r8169 (PCI! This is important, seems i am running out of PCI
> > > capacity),
> > 
> > Gigabit Ethernet on plain old PCI is not ideal.  If each card has a
> > separate route to the south bridge then you might be able to get a fair
> > fraction of a gigabit between them though.

I think in this case r8169 is routed over PCI-PCIExpress bridge, other card is
PCIExpress, nothing else on PCI, other than IDE controller which not used at
all). Yes, it is bad, but still must be 133 Mbyte/s (1064 Mbit/s). Yes i know
there is overhead, but probably i can expect 500-800 Mbps total bandwidth limit?

> > 
> > > 400Mbit/s rx+tx summary load, e1000e interface also - around
> > > 200Mbps load. What is worrying me - interrupts rate, it seems generated by
> > > realtek card... is there any way to drop it down? 
> > [...]
> > 
> > ethtool -C lets you change interrupt moderation.  I don't know anything
> > about this driver or NIC's capabilities but it does seem to be in the
> > cheapest GbE cards so I wouldn't expect outstanding performance.
> > 
> > Ben.
Well, realtek 8169 doesn't support changing ring, and doesn't support changing
coalesce parameters. By the way e1000 also doesn't support -C, but e1000e
does. Is it new way of forcing people to buy newer adapters? :-)

> >
> 
> The bigger issues is available memory bandwidth. Different processors
> and busses have different overheads. PCI is much worse than PCI-
> express, and CPU's with integrated memory controllers do much better 
> than CPU's with separate memory controller (like Core 2).
Yes, but in my case Core 2 do heavier job much better, probably because of
larger cache or some voodoo magic.

The biggest issue, in this country it is not possible to find PCI-Express
network adapter. Even Realtek 8169. It is just impossible, that WHOLE country
have very limited stock of PCI-Express adapters, just few PCI-Express R8169
month ago was laying on the shelf of local Apple dealer, and i remember too
late about them.

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

