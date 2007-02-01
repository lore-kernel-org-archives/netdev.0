From: Rick Jones <rick.jones2@hp.com>
Subject: "meaningful" spinlock contention when bound to non-intr CPU?
Date: Thu, 01 Feb 2007 11:43:05 -0800
Message-ID: <45C242C9.1010601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:51494 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422969AbXBATnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 14:43:08 -0500
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel11.hp.com (Postfix) with ESMTP id 26E0A36A7D
	for <netdev@vger.kernel.org>; Thu,  1 Feb 2007 11:43:05 -0800 (PST)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id LAA09443
	for <netdev@vger.kernel.org>; Thu, 1 Feb 2007 11:43:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For various nefarious porpoises relating to comparing and contrasting a 
single 10G NIC with N 1G ports and hopefully finding interesting 
processor cache (mis)behaviour in the stack, I got my hands on a pair of 
8 core systems with plenty of RAM and I/O slots.  (rx6600 with 1.6 GHz 
dual-core Itanium2, aka Montecito)

A 2.6.10-rc5 kernel onto each system thanks to pointers from Dan Frazier.

Into each went a quartet of dual-port 1G NICs driven by e1000 
7.3.15-k2-NAPI and I connected them back to back.  I tweaked 
smp_affinity to have each port's interrupts go to a separate core.

Netperf2 configured with --enable-burst.

When I run eight concurrent netperf TCP_RR tests, each doing 24 
concurrent single-byte transactions (test-specific -b 24), TCP_NODELAY 
set, (test-specific -D) and bind each netserver/netperf to the same CPU 
as is taking the interrupts of the NIC handling that connection (global 
-T) I see things looking pretty good.  Decent aggregate transactions per 
second, and nothing in the CPU profiles to suggest spinlock contention.

Happiness and joy.  An N CPU system behaving (at this level at least) 
like N, 1 CPU systems.

When I then decide to bind the netperf/netservers to CPU(s) other than 
the ones taking the interrupts from the NIC(s) the aggregate 
transactions per second drops by roughly 40/135 or ~30%.  I was indeed 
expecting a delta - no idea if that is in the realm of "to be expected" 
- but decided to go ahead and look at the profiles.

The profiles (either via q-syscollect or caliper) show upwards of 3% of 
the CPU consumed by spinlock contention (ie time spent in 
ia64_spinlock_contention). (I'm guessing some of the rest of the perf 
drop comes from those "interesting" cache behaviours still to be sought)

With some help from Lee Schermerhorn and Alan Brunelle I got a lockmeter 
kernel going, and it is suggesting that the greatest spinlock contention 
comes from the routines:

SPINLOCKS         HOLD            WAIT
   UTIL  CON    MEAN(  MAX )   MEAN(  MAX )(% CPU)     TOTAL NOWAIT SPIN 
RJECT  NAME

   7.4%  2.8%  0.1us( 143us)  3.3us( 147us)( 1.4%)  75262432 97.2%  2.8% 
    0%  lock_sock_nested+0x30
  29.5%  6.6%  0.5us( 148us)  0.9us( 143us)(0.49%)  37622512 93.4%  6.6% 
    0%  tcp_v4_rcv+0xb30
   3.0%  5.6%  0.1us( 142us)  0.9us( 143us)(0.14%)  13911325 94.4%  5.6% 
    0%  release_sock+0x120
   9.6% 0.75%  0.1us( 144us)  0.7us( 139us)(0.08%)  75262432 99.2% 0.75% 
    0%  release_sock+0x30

I suppose it stands to some reason that there would be contention 
associated with the socket since there will be two things going for the 
socket (a netperf/netserver and an interrupt/upthestack) each running on 
separate CPUs.  Some of it looks like it _may_ be inevitable? - 
waking-up the user who will now  be racing to grab the socket before the 
stack releases it? (I may have been mis-interpreting some of the code I 
was checking)

Still, does this look like something worth persuing?  In a past life/OS 
when one was able to eliminate one percentage point of spinlock 
contention, two percentage points of improvement ensued.

rick jones

