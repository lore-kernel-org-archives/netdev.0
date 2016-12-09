From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 0/4] udp: receive path optimizations
Date: Fri, 09 Dec 2016 08:26:27 -0800
Message-ID: <1481300787.4930.198.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481218739-27089-1-git-send-email-edumazet@google.com>
         <20161208214819.30138d12@redhat.com>
         <1481231595.4930.142.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161209170509.25347c9b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33696 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933932AbcLIQ13 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 11:27:29 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so2750580pgd.0
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 08:27:29 -0800 (PST)
In-Reply-To: <20161209170509.25347c9b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-09 at 17:05 +0100, Jesper Dangaard Brouer wrote:
> On Thu, 08 Dec 2016 13:13:15 -0800
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Thu, 2016-12-08 at 21:48 +0100, Jesper Dangaard Brouer wrote:
> > > On Thu,  8 Dec 2016 09:38:55 -0800
> > > Eric Dumazet <edumazet@google.com> wrote:
> > >   
> > > > This patch series provides about 100 % performance increase under flood.   
> > > 
> > > Could you please explain a bit more about what kind of testing you are
> > > doing that can show 100% performance improvement?
> > > 
> > > I've tested this patchset and my tests show *huge* speeds ups, but
> > > reaping the performance benefit depend heavily on setup and enabling
> > > the right UDP socket settings, and most importantly where the
> > > performance bottleneck is: ksoftirqd(producer) or udp_sink(consumer).  
> > 
> > Right.
> > 
> > So here at Google we do not try (yet) to downgrade our expensive
> > Multiqueue Nics into dumb NICS from last decade by using a single queue
> > on them. Maybe it will happen when we can process 10Mpps per core,
> > but we are not there yet  ;)
> > 
> > So my test is using a NIC, programmed with 8 queues, on a dual-socket
> > machine. (2 physical packages)
> > 
> > 4 queues are handled by 4 cpus on socket0 (NUMA node 0)
> > 4 queues are handled by 4 cpus on socket1 (NUMA node 1)
> 
> Interesting setup, it will be good to catch cache-line bouncing and
> false-sharing, which the streak of recent patches show ;-) (Hopefully
> such setup are avoided for production).

Well, if you have 100Gbit NIC, and 2 NUMA nodes, what do you suggest
exactly, when jobs run on both nodes ?

If you suggest to remove one package, or force jobs to run on Socket0,
just because the NIC is attached to it, it wont be an option.

Most of the traffic is TCP, so RSS comes nicely here to affine traffic
on one RX queue of the NIC.

Now, if for some reason an innocent UDP socket is the target of a flood,
we need to not make all cpus blocked in a spinlock to eventually queue a
packet.

Be assured that high performance UDP servers use kernel bypass, or
SO_REUSEPORT already. My effort is not targeting these special users,
since they already have good performance.

My effort is to provide some isolation, a bit like the effort I did for
SYN flood attacks (Cpus were all spinning on listener spinlock)




> 
> 
> > So I explicitly put my poor single thread UDP application in the worst
> > condition, having skbs produced on two NUMA nodes. 
> 
> On which CPU do you place the single thread UDP application?

No matter in this case. You can either force it to run on a group of
cpu, or let the scheduler choose.

If you let the scheduler choose, then it might help the single tuple
flood attack, since the user thread will be moved on a difference cpu
than the ksoftirqd.

> 
> E.g. do you allow it to run on a CPU that also process ksoftirq?
> My experience is that performance is approx half, if ksoftirq and
> UDP-thread share a CPU (after you fixed the softirq issue).

Well, this is exactly what I said earlier. Your choices about cpu
pinning might help or might hurt in different scenarios.

> 
> 
> > Then my load generator use trafgen, with spoofed UDP source addresses,
> > like a UDP flood would use. Or typical DNS traffic, malicious or not.
> 
> I also like trafgen
>  https://github.com/netoptimizer/network-testing/tree/master/trafgen
> 
> > So I have 8 cpus all trying to queue packets in a single UDP socket.
> > 
> > Of course, a real high performance server would use 8 UDP sockets, and
> > SO_REUSEPORT with nice eBPF filter to spread the packets based on the
> > queue/cpu they arrived.
> 
> Once the ksoftirq and UDP-threads are silo'ed like that, it should
> basically correspond to the benchmarks of my single queue test,
> multiplied by the number of CPUs/UDP-threads.

Well, if one cpu is shared by the producer and consumer then packets are
hot in caches, so trying to avoid cache line misses as I did is not
really helping.

I optimized the case where we do not assume both parties run on the same
cpu. If you leave process scheduler do its job, then your throughput can
be doubled ;)

Now if for some reason you are stuck with a single CPU, this is a very
different problem, and af_packet might be better.


> 
> I think it might be a good idea (for me) to implement such a
> UDP-multi-threaded sink example program (with SO_REUSEPORT and eBPF
> filter) to demonstrate and make sure the stack scales (and every
> time we/I improve single queue performance, the numbers should multiply
> with the scaling). Maybe you already have such an example program?


Well, I do have something using SO_REUSEPORT, but not yet BPF, so not in
a state I can share at this moment.
