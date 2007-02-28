From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Wed, 28 Feb 2007 15:55:10 +0100
Message-ID: <200702281555.10309.dada1@cosmosbay.com>
References: <45E5570E.7050301@free.fr> <200702281455.27720.dada1@cosmosbay.com> <45E59062.6000103@free.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: John <linux.kernel@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:42533 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932931AbXB1OzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 09:55:20 -0500
In-Reply-To: <45E59062.6000103@free.fr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 28 February 2007 15:23, John wrote:
> Eric Dumazet wrote:
> >> John wrote:
> >>> I know it's possible to have Linux timestamp incoming datagrams as soon
> >>> as they are received, then for one to retrieve this timestamp later
> >>> with an ioctl command or a recvmsg call.
> >>
> >> Has it ever been proposed to modify struct skb_timeval to hold
> >> nanosecond stamps instead of just microsecond stamps? Then make the
> >> improved precision somehow available to user space.
> >
> > Most modern NICS are able to delay packet delivery, in order to reduce
> > number of interrupts and benefit from better cache hits.
>
> You are referring to NAPI interrupt mitigation, right?

Nope; I am referring to hardware features. NAPI is software.

See ethtool -c eth0

# ethtool -c eth0
Coalesce parameters for eth0:
Adaptive RX: off  TX: off
stats-block-usecs: 1000000
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 300
rx-frames: 60
rx-usecs-irq: 300
rx-frames-irq: 60

tx-usecs: 200
tx-frames: 53
tx-usecs-irq: 200
tx-frames-irq: 53

You can see on this setup, rx interrupts can be delayed up to 300 us (up to 60 
packets might be delayed)

>
> POSIX is moving to nanoseconds interfaces.
> http://www.opengroup.org/onlinepubs/009695399/functions/clock_settime.html

The fact that you are able to give nanosecond timestamps inside kernel is not 
sufficient. It is necessary of course, but not sufficient. This precision is 
OK to time locally generated events. The moment you ask a 'nanosecond' 
timestamp, it's usually long before/after the real event.

If you rely on nanosecond precision on network packets, then something is 
wrong with your algo. Even rt patches wont make sure your cpu caches are 
pre-filled, or that the routers/links between your machines are not busy.
A cache miss cost 40 ns for example. A typical interrupt handler or rx 
processing can trigger 100 cache misses, or not at all if cache is hot.

You said that rt gives highest priority to interrupt handlers :
If you have several nics, what will happen if you receive packets on both 
nics, or if the NIC interrupt happens in the same time than timer interrupt ? 
One timestamp will be wrong for sure.

For sure we could timestamp packets with nanosecond resolution, and eventually 
with MONOTONIC value too, but it will give you (and others) false confidence 
on the real precision. us timestamps are already wrong...
