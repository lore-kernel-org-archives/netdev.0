From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 0/5] net: add protocol level recvmmsg support
Date: Fri, 25 Nov 2016 18:37:11 +0100
Message-ID: <20161125183711.675fa4a7@redhat.com>
References: <cover.1480086321.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>, brouer@redhat.com
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60890 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932411AbcKYRiD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 12:38:03 -0500
In-Reply-To: <cover.1480086321.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Nov 2016 16:39:51 +0100
Paolo Abeni <pabeni@redhat.com> wrote:

> The goal of recvmmsg() is to amortize the syscall overhead on a possible
> long messages batch, but for most networking protocols, e.g. udp the
> syscall overhead is negligible compared to the protocol specific operations
> like dequeuing.

Sounds good. I'm excited to see work in this area! :-)
 
[...]
> The udp version of recvmmsg() tries to bulk-dequeue skbs from the receive queue,
> each burst acquires the lock once to extract as many skbs from the receive
> queue as possible, up to the number needed to reach the specified maximum.
> rmem_alloc and fwd memory are touched once per burst.

Sounds good.
 
> When the protocol-level recvmmsg() is not available or it does not support the
> specified flags, the code falls-back to the current generic implementation.
> 
> This series introduces some behavior changes for the recvmmsg() syscall (only
> for udp):
> - the timeout argument now works as expected
> - recvmmsg() does not stop anymore when getting the first error, instead
>   it keeps processing the current burst and then handle the error code as
>   in the generic implementation.
> 
> The measured performance delta is as follow:
> 
> 		before		after
> 		(Kpps)		(Kpps)
> 
> udp flood[1]	570		1800(+215%)
> max tput[2]	1850		3500(+89%)
> single queue[3]	1850		1630(-11%)
> 
> [1] line rate flood using multiple 64 bytes packets and multiple flows

Is [1] sending multiple flow in the a single UDP-sink?


> [2] like [1], but using the minimum number of flows to saturate the user space
>  sink, that is 1 flow for the old kernel and 3 for the patched one.
>  the tput increases since the contention on the rx lock is low.
> [3] like [1] but using a single flow with both old and new kernel. All the
>  packets land on the same rx queue and there is a single ksoftirqd instance
>  running

It is important to know, if ksoftirqd and the UDP-sink runs on the same CPU?


> The regression in the single queue scenario is actually due to the improved
> performance of the recvmmsg() syscall: the user space process is now
> significantly faster than the ksoftirqd process so that the latter needs often
> to wake up the user space process.

When measuring these things, make sure that we/you measure both the packets
actually received in the userspace UDP-sink, and also measure packets
RX processed by ksoftirq (and I often also look at what HW got delivered).
Some times, when userspace is too slow, the kernel can/will drop packets.

It is actually quite easily verified with cmdline:

 nstat > /dev/null && sleep 1  && nstat

For HW measurements I use the tool ethtool_stats.pl:
 https://github.com/netoptimizer/network-testing/blob/master/bin/ethtool_stats.pl


> Since ksoftirqd is the bottle-neck is such scenario, overall this causes a
> tput reduction. In a real use case, where the udp sink is performing some
> actual processing of the received data, such regression is unlikely to really
> have an effect.

My experience is that the performance of RX UDP is affected by:
 * if socket is connected or not (yes, RX side also)
 * state of /proc/sys/net/ipv4/ip_early_demux

You don't need to run with all the combinations, but it would be nice
if you specify what config your have based your measurements on (and
keep them stable in your runs).

I've actually implemented the "--connect" option to my udp_sink
program[1] today, but I've not pushed it yet, if you are interested.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[1] 
