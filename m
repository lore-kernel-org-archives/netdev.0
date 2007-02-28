From: John <linux.kernel@free.fr>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Wed, 28 Feb 2007 17:07:10 +0100
Message-ID: <45E5A8AE.3030606@free.fr>
References: <45E5570E.7050301@free.fr> <200702281455.27720.dada1@cosmosbay.com> <45E59062.6000103@free.fr> <200702281555.10309.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org,
	linux.kernel@free.fr
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g19.free.fr ([212.27.42.30]:43330 "EHLO smtp4-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773AbXB1QHW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 11:07:22 -0500
In-Reply-To: <200702281555.10309.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On Wednesday 28 February 2007 15:23, John wrote:
>> Eric Dumazet wrote:
>>>> John wrote:
>>>>> I know it's possible to have Linux timestamp incoming datagrams as soon
>>>>> as they are received, then for one to retrieve this timestamp later
>>>>> with an ioctl command or a recvmsg call.
>>>> Has it ever been proposed to modify struct skb_timeval to hold
>>>> nanosecond stamps instead of just microsecond stamps? Then make the
>>>> improved precision somehow available to user space.
>>> Most modern NICS are able to delay packet delivery, in order to reduce
>>> number of interrupts and benefit from better cache hits.
>>
>> You are referring to NAPI interrupt mitigation, right?
> 
> Nope; I am referring to hardware features. NAPI is software.
> 
> See ethtool -c eth0
> 
> # ethtool -c eth0
> Coalesce parameters for eth0:
> Adaptive RX: off  TX: off
> stats-block-usecs: 1000000
> sample-interval: 0
> pkt-rate-low: 0
> pkt-rate-high: 0
> 
> rx-usecs: 300
> rx-frames: 60
> rx-usecs-irq: 300
> rx-frames-irq: 60
> 
> tx-usecs: 200
> tx-frames: 53
> tx-usecs-irq: 200
> tx-frames-irq: 53
> 
> You can see on this setup, rx interrupts can be delayed up to 300 us (up to 60
> packets might be delayed)

One can disable interrupt mitigation. Your argument that it introduces 
latency therefore becomes irrelevant.

>> POSIX is moving to nanoseconds interfaces.
>> http://www.opengroup.org/onlinepubs/009695399/functions/clock_settime.html

You snipped too much. I also wrote:

struct timeval and struct timespec take as much space (64 bits).

If the hardware can indeed manage sub-microsecond accuracy, a struct
timeval forces the kernel to discard valuable information.

> The fact that you are able to give nanosecond timestamps inside kernel is not 
> sufficient. It is necessary of course, but not sufficient. This precision is 
> OK to time locally generated events. The moment you ask a 'nanosecond' 
> timestamp, it's usually long before/after the real event.
> 
> If you rely on nanosecond precision on network packets, then something is 
> wrong with your algo. Even rt patches wont make sure your cpu caches are 
> pre-filled, or that the routers/links between your machines are not busy.
> A cache miss cost 40 ns for example. A typical interrupt handler or rx 
> processing can trigger 100 cache misses, or not at all if cache is hot.

Consider an idle Linux 2.6.20-rt8 system, equipped with a single PCI-E 
gigabit Ethernet NIC, running on a modern CPU (e.g. Core 2 Duo E6700). 
All this system does is time stamp 1000 packets per second.

Are you claiming that this platform *cannot* handle most packets within 
less than 1 microsecond of their arrival?

If there are platforms that can achieve sub-microsecond precision, and 
if it is not more expensive to support nanosecond resolution (I said 
resolution not precision), then it makes sense to support nanosecond 
resolution in Linux. Right?

> You said that rt gives highest priority to interrupt handlers :
> If you have several nics, what will happen if you receive packets on both 
> nics, or if the NIC interrupt happens in the same time than timer interrupt ? 
> One timestamp will be wrong for sure.

Again, this is irrelevant. We are discussing whether it would make sense 
to support sub-microsecond resolution. If there is one platform that can 
achieve sub-microsecond precision, there is a need for sub-microsecond 
resolution. As long as we are changing the resolution, we might as well 
use something standard like struct timespec.

> For sure we could timestamp packets with nanosecond resolution, and eventually 
> with MONOTONIC value too, but it will give you (and others) false confidence 
> on the real precision. us timestamps are already wrong...

IMHO, this is not true for all platforms.

Regards.
