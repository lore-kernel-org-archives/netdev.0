From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 15 Nov 2012 10:33:18 -0800
Message-ID: <50A5356E.8030901@hp.com>
References: <1347868144.26523.71.camel@edumazet-glaptop> <CAAM7YAm+XJKTxJStLMoo4RRV85oogN5wCHfXorkEiUHKqNKHDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: "Yan, Zheng " <yanzheng@21cn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:44894 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423636Ab2KOSdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 13:33:20 -0500
In-Reply-To: <CAAM7YAm+XJKTxJStLMoo4RRV85oogN5wCHfXorkEiUHKqNKHDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2012 11:52 PM, Yan, Zheng wrote:
> This commit makes one of our test case on core 2 machine drop in
> performance by about 60%. The test case runs 2048 instances of
> netperf 64k stream test at the same time.

I'm impressed that 2048 concurrent netperf TCP_STREAM tests ran to 
completion in the first place :)

> Analysis showed using order-3 pages causes more LLC misses, most new
> LLC misses happen when the senders copy data to the socket buffer.

> If revert to use single page, the sender side only trigger a few LLC
>  misses, most LLC misses happen on the receiver size. It means most
> pages allocated by the senders are cache hot. But when using order-3
> pages, 2048 * 32k = 64M, 64M is much larger than LLC size. Should
> this regression be worried? or our test case is too unpractical?

Even before the page change I would have expected the buffers that 
netperf itself uses would have exceeded the LLC.  If you were not using 
test-specific -s and -S options to set an explicit socket buffer size, I 
believe that under Linux (most of the time) the default SO_SNDBUF size 
will be 86KB.  Coupled with your statement that the send size was 64K it 
means the send ring being used by netperf will be 2, 64KB buffers, which 
would then be 256MB across 2048 concurrent netperfs.  Even if we go with 
"only the one send buffer in play at a time matters" that is still 128 
MB of space up in netperf itself even before one gets to the stack.

Still, sharing the analysis tool output might be helpful.

By the way the "default" size of the buffer netperf posts in recv() 
calls will depend on the initial value of SO_RCVBUF after the data 
socket is created and had any -s or -S option values applied to it.

I cannot say that the scripts distributed with netperf are consistently 
good about doing it themselves, but I would suggest for the "canonical" 
bulk streak test something like:

netperf -t TCP_STREAM -H <dest> -l 60 -- -s 1M -S 1M -m 64K -M 64K

as that will reduce the number of variables.  Those -s and -S values 
though will probably call for tweaking sysctl settings or they will be 
clipped by net.core.rmem_max and net.core.wmem_max.  At a minimum I 
would suggest having the -m and -M option.  I might also tack-on a "-o 
all" at the end, but that is a matter of preference - it will cause a 
great deal of output...

Eric Dumazet later says:
> Number of in flight bytes do not depend on the order of the pages, but
> sizes of TCP buffers (receiver, sender)

And unless you happened to use explicit -s and -S options, there is even 
more variability in how much may be inflight.  If you do not add those 
you can at least get netperf to report what the socket buffer sizes 
became by the end of the test:

netperf -t TCP_STREAM ... -- ... -o lss_size_end,rsr_size_end

for "local socket send size" and "remote socket receive size" respectively.

> If the sender is faster (because of this commit), but receiver is slow
> to drain the receive queues, then you can have a situation where the
> consumed memory on receiver is higher and the receiver might be actually
> slower.

Netperf can be told to report the number of receive calls and the bytes 
per receive - either by tacking-on a global "-v 2" or by requesting them 
explicitly via omni output selection.  Presumably, if the receiving 
netserver processes are not keeping-up as well, that should manifest as 
the bytes per receive being larger in the "after" case than the "before" 
case.

netperf ... -- ... -o 
remote_recv_size,remote_recv_calls,remote_bytes_per_recv

happy benchmarking,

rick jones
