From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next 0/4] udp: receive path optimizations
Date: Fri, 9 Dec 2016 17:05:09 +0100
Message-ID: <20161209170509.25347c9b@redhat.com>
References: <1481218739-27089-1-git-send-email-edumazet@google.com>
        <20161208214819.30138d12@redhat.com>
        <1481231595.4930.142.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36036 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932995AbcLIQFN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Dec 2016 11:05:13 -0500
In-Reply-To: <1481231595.4930.142.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 Dec 2016 13:13:15 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2016-12-08 at 21:48 +0100, Jesper Dangaard Brouer wrote:
> > On Thu,  8 Dec 2016 09:38:55 -0800
> > Eric Dumazet <edumazet@google.com> wrote:
> >   
> > > This patch series provides about 100 % performance increase under flood.   
> > 
> > Could you please explain a bit more about what kind of testing you are
> > doing that can show 100% performance improvement?
> > 
> > I've tested this patchset and my tests show *huge* speeds ups, but
> > reaping the performance benefit depend heavily on setup and enabling
> > the right UDP socket settings, and most importantly where the
> > performance bottleneck is: ksoftirqd(producer) or udp_sink(consumer).  
> 
> Right.
> 
> So here at Google we do not try (yet) to downgrade our expensive
> Multiqueue Nics into dumb NICS from last decade by using a single queue
> on them. Maybe it will happen when we can process 10Mpps per core,
> but we are not there yet  ;)
> 
> So my test is using a NIC, programmed with 8 queues, on a dual-socket
> machine. (2 physical packages)
> 
> 4 queues are handled by 4 cpus on socket0 (NUMA node 0)
> 4 queues are handled by 4 cpus on socket1 (NUMA node 1)

Interesting setup, it will be good to catch cache-line bouncing and
false-sharing, which the streak of recent patches show ;-) (Hopefully
such setup are avoided for production).


> So I explicitly put my poor single thread UDP application in the worst
> condition, having skbs produced on two NUMA nodes. 

On which CPU do you place the single thread UDP application?

E.g. do you allow it to run on a CPU that also process ksoftirq?
My experience is that performance is approx half, if ksoftirq and
UDP-thread share a CPU (after you fixed the softirq issue).


> Then my load generator use trafgen, with spoofed UDP source addresses,
> like a UDP flood would use. Or typical DNS traffic, malicious or not.

I also like trafgen
 https://github.com/netoptimizer/network-testing/tree/master/trafgen

> So I have 8 cpus all trying to queue packets in a single UDP socket.
> 
> Of course, a real high performance server would use 8 UDP sockets, and
> SO_REUSEPORT with nice eBPF filter to spread the packets based on the
> queue/cpu they arrived.

Once the ksoftirq and UDP-threads are silo'ed like that, it should
basically correspond to the benchmarks of my single queue test,
multiplied by the number of CPUs/UDP-threads.

I think it might be a good idea (for me) to implement such a
UDP-multi-threaded sink example program (with SO_REUSEPORT and eBPF
filter) to demonstrate and make sure the stack scales (and every
time we/I improve single queue performance, the numbers should multiply
with the scaling). Maybe you already have such an example program?


> In the case you have one cpu that you need to share between ksoftirq and
> all user threads, then your test results depend on process scheduler
> decisions more than anything we can code in network land.

Yes, also my experience, the scheduler have large influence.
 
> It is actually easy for user space to get more than 50% of the cycles,
> and 'starve' ksoftirqd.

FYI, Paolo recently added an option for parsing of pktgen payload in
the udp_sink.c program, this way we can simulate the app doing something.

I've started testing with 4 CPUs doing ksoftirq, multiple flows
(pktgen_sample04_many_flows.sh) and then increasing adding udp_sink
--reuse-port programs, on other 4 CPUs, and it looks like it scales
nicely :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
