From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 0/5] net: add protocol level recvmmsg support
Date: Mon, 28 Nov 2016 11:52:38 +0100
Message-ID: <1480330358.6718.13.camel@redhat.com>
References: <cover.1480086321.git.pabeni@redhat.com>
         <20161125183711.675fa4a7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50936 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932329AbcK1Kwl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 05:52:41 -0500
In-Reply-To: <20161125183711.675fa4a7@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper,

On Fri, 2016-11-25 at 18:37 +0100, Jesper Dangaard Brouer wrote:
> > The measured performance delta is as follow:
> > 
> > 		before		after
> > 		(Kpps)		(Kpps)
> > 
> > udp flood[1]	570		1800(+215%)
> > max tput[2]	1850		3500(+89%)
> > single queue[3]	1850		1630(-11%)
> > 
> > [1] line rate flood using multiple 64 bytes packets and multiple flows
> 
> Is [1] sending multiple flow in the a single UDP-sink?

Yes, in the test scenario [1] there are multiple UDP flows using 16
different rx queues on the receiver host, and a single user space
reader.

> > [2] like [1], but using the minimum number of flows to saturate the user space
> >  sink, that is 1 flow for the old kernel and 3 for the patched one.
> >  the tput increases since the contention on the rx lock is low.
> > [3] like [1] but using a single flow with both old and new kernel. All the
> >  packets land on the same rx queue and there is a single ksoftirqd instance
> >  running
> 
> It is important to know, if ksoftirqd and the UDP-sink runs on the same CPU?

No pinning is enforced. The scheduler moves the user space process on a
different cpu in respect to the ksoftriqd kernel thread.

> > The regression in the single queue scenario is actually due to the improved
> > performance of the recvmmsg() syscall: the user space process is now
> > significantly faster than the ksoftirqd process so that the latter needs often
> > to wake up the user space process.
> 
> When measuring these things, make sure that we/you measure both the packets
> actually received in the userspace UDP-sink, and also measure packets
> RX processed by ksoftirq (and I often also look at what HW got delivered).
> Some times, when userspace is too slow, the kernel can/will drop packets.
> 
> It is actually quite easily verified with cmdline:
> 
>  nstat > /dev/null && sleep 1  && nstat
> 
> For HW measurements I use the tool ethtool_stats.pl:
>  https://github.com/netoptimizer/network-testing/blob/master/bin/ethtool_stats.pl

We collected the UDP stats for all the three scenarios; we have lot of
drop in test[1] and little, by design, in test[2]. In test [3], with the
patched kernel, the drops are 0: ksoftirqd is way slower than the user
space sink. 

> > Since ksoftirqd is the bottle-neck is such scenario, overall this causes a
> > tput reduction. In a real use case, where the udp sink is performing some
> > actual processing of the received data, such regression is unlikely to really
> > have an effect.
> 
> My experience is that the performance of RX UDP is affected by:
>  * if socket is connected or not (yes, RX side also)
>  * state of /proc/sys/net/ipv4/ip_early_demux
> 
> You don't need to run with all the combinations, but it would be nice
> if you specify what config your have based your measurements on (and
> keep them stable in your runs).
> 
> I've actually implemented the "--connect" option to my udp_sink
> program[1] today, but I've not pushed it yet, if you are interested.

The reported numbers are all gathered with unconnected sockets and early
demux enabled.

We also used connected socket for test[3], with relative little
difference (the tput increased for both unpatched and patched kernel, 
and the difference was roughly the same).

Paolo
