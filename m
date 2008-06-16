From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: NAPI, rx_no_buffer_count, e1000, r8169 and other actors
Date: Sun, 15 Jun 2008 19:59:18 -0700
Message-ID: <20080615195918.210fe19f@extreme>
References: <20080615200013.M67401@visp.net.lb>
	<20080615234620.GC2835@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35279 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851AbYFPC7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jun 2008 22:59:20 -0400
In-Reply-To: <20080615234620.GC2835@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jun 2008 00:46:22 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> Denys Fedoryshchenko wrote:
> > Hi
> > 
> > Since i am using PC routers for my network, and i reach significant numbers
> > (for me significant) i start noticing minor problems. So all this talk about
> > networking performance in my case.
> > 
> > For example.
> > Sun server, AMD based (two CPU -  AMD Opteron(tm) Processor 248).
> > e1000 connected over PCI-X ([    4.919249] e1000: 0000:01:01.0: e1000_probe:
> > (PCI-X:100MHz:64-bit) 00:14:4f:20:89:f4)
> > 
> > All traffic processed over eth0, 5 VLAN, 1 second average around 110-200Mbps
> 
> Currently TX checksum offload does not work for VLAN devices, which may
> be a serious performance hit if there is a lot of traffic routed between
> VLANs.  This should change in 2.6.27 for some drivers, which I think will
> include e1000.
> 
> > of traffic. Host running also conntrack (max 1000000 entries, when packetloss
> > happen - around 256k entries). Around 1300 routes (FIB_TRIE) running. What is
> > worrying me, that ok, i win time by increasing rx descriptors from 256 to
> > 4096, but how much time i win? if it "cracks" on 100 Mbps RX, it means by
> > interpolating descriptors increase from 256 to 4096 (4 times), i cannot
> > process more than 400Mbps RX?

You are CPU limited because of the overhead of firewalling. When this happens
packets get backlogged.

> Increasing the RX descriptor ring size should give the driver and stack
> more time to catch up after handling some packets that take unusually
> long.  It may also allow you to increase interrupt moderation, which
> will reduce the per-packet cost.

No if the receive side is CPU limited, you just end up eating more memory.
A bigger queue may actually make performance worse (less cache hits).

> > The CPU is not so busy after all... maybe there is a way to change some
> > parameter to force NAPI poll interface more often?
> 
> NAPI polling is not time-based, except indirectly though interrupt
> moderation.

How are you measuring CPU? You need to do something like measure the available
cycles left for applications. Don't believe top or other measures that may
not reflect I/O overhead and bus usage. 

> > I tried nice, changing realtime priority to FIFO, changing kernel to
> > preemptible... no luck, except increasing descriptors.
> > 
> > Router-Dora ~ # mpstat -P ALL 1
> > Linux 2.6.26-rc6-git2-build-0029 (Router-Dora)  06/15/08
> > 
> > 22:51:02     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal  
> > %idle    intr/s
> > 22:51:03     all    1.00    0.00    0.00    0.00    2.50   29.00    0.00  
> > 67.50  12927.00
> > 22:51:03       0    2.00    0.00    0.00    0.00    4.00   59.00    0.00  
> > 35.00  11935.00
> > 22:51:03       1    0.00    0.00    0.00    0.00    0.00    0.00    0.00 
> > 100.00    993.00
> > 22:51:03       2    0.00    0.00    0.00    0.00    0.00    0.00    0.00   
> > 0.00      0.00
>  
> You might do better with a NIC that supports MSI-X.  This allows the use of
> two RX queues with their own IRQs, each handled by a different processor.
> As it is, one CPU is completely idle.  However, I don't know how well the
> other work of routing scales to multiple processors.


Routing and firewalling should scale well. The deadlock is probably going
to be some hot lock like the transmit lock.

> [...]
> > I have another host running, Core 2 Duo, e1000e+3 x e100, also conntrack, same
> > kernel configuration and similar amount of traffic, higher load (ifb + plenty
> > of shapers running) - almost no errors on default settings.
> > Linux 2.6.26-rc6-git2-build-0029 (Kup)  06/16/08
> > 
> > 07:00:27     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal  
> > %idle    intr/s
> > 07:00:28     all    0.00    0.00    0.50    0.00    4.00   31.50    0.00  
> > 64.00  32835.00
> > 07:00:29     all    0.00    0.00    0.50    0.00    2.50   29.00    0.00  
> > 68.00  33164.36
> > 
> > Third host r8169 (PCI! This is important, seems i am running out of PCI
> > capacity),
> 
> Gigabit Ethernet on plain old PCI is not ideal.  If each card has a
> separate route to the south bridge then you might be able to get a fair
> fraction of a gigabit between them though.
> 
> > 400Mbit/s rx+tx summary load, e1000e interface also - around
> > 200Mbps load. What is worrying me - interrupts rate, it seems generated by
> > realtek card... is there any way to drop it down? 
> [...]
> 
> ethtool -C lets you change interrupt moderation.  I don't know anything
> about this driver or NIC's capabilities but it does seem to be in the
> cheapest GbE cards so I wouldn't expect outstanding performance.
> 
> Ben.
> 

The bigger issues is available memory bandwidth. Different processors
and busses have different overheads. PCI is much worse than PCI-express,
and CPU's with integrated memory controllers do much better than CPU's
with separate memory controller (like Core 2).

