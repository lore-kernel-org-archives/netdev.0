From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Fri, 22 Jan 2016 06:33:40 -0800
Message-ID: <1453473220.1223.394.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160115142223.1e92be75@redhat.com>
	 <20160115.154721.458450438918273509.davem@davemloft.net>
	 <20160118112703.6eac71ca@redhat.com>
	 <20160118.112455.212265265553435873.davem@davemloft.net>
	 <CAJ3xEMiOAdu7ghRoc6ZEMG78Z9xyh1M=5Egc3ydh+97bT3_9fw@mail.gmail.com>
	 <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	 <20160121132304.12ff9d23@redhat.com>
	 <CALx6S368Hxc_VpL5=Rq5Ybpe-JzQr-3X9hUOoNU6yvY_1ao7PA@mail.gmail.com>
	 <1453398516.1223.376.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160122133341.0f174115@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34376 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbcAVOdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 09:33:43 -0500
Received: by mail-pf0-f170.google.com with SMTP id q63so44464670pfb.1
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 06:33:43 -0800 (PST)
In-Reply-To: <20160122133341.0f174115@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-22 at 13:33 +0100, Jesper Dangaard Brouer wrote:
> On Thu, 21 Jan 2016 09:48:36 -0800
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Thu, 2016-01-21 at 08:38 -0800, Tom Herbert wrote:
> > 
> > > Sure, but the receive path is parallelized.  
> > 
> > This is true for multiqueue processing, assuming you can dedicate many
> > cores to process RX.
> > 
> > >  Improving parallelism has
> > > continuously shown to have much more impact than attempting to
> > > optimize for cache misses. The primary goal is not to drive 100Gbps
> > > with 64 packets from a single CPU. It is one benchmark of many we
> > > should look at to measure efficiency of the data path, but I've yet to
> > > see any real workload that requires that...
> > > 
> > > Regardless of anything, we need to load packet headers into CPU cache
> > > to do protocol processing. I'm not sure I see how trying to defer that
> > > as long as possible helps except in cases where the packet is crossing
> > > CPU cache boundaries and can eliminate cache misses completely (not
> > > just move them around from one function to another).  
> > 
> > Note that some user space use multiple core (or hyper threads) to
> > implement a pipeline, using a single RX queue.
> > 
> > One thread can handle one stage (device RX drain) and prefetch data into
> > shared L1/L2 (and/or shared L3 for pipelines with more than 2 threads)
> > 
> > The second thread process packets with headers already in L1/L2
> 
> I agree. I've heard experiences where DPDK users use 2 core for RX, and
> 1 core for TX, and achieve 10G wirespeed (14Mpps) real IPv4 forwarding
> with full Internet routing table look up.
> 
> One of the ideas behind my alf_queue, is that it can be used for
> efficiently distributing object (pointers) between threads.
> 1. because it only transfers the pointers (not touching object), and
> 2. because it enqueue/dequeue multiple objects with a single locked cmpxchg.
> Thus, lower in the message passing cost between threads.
> 
> 
> > This way, the ~100 ns (or even more if you also consider skb
> > allocations) penalty to bring packet headers do not hurt PPS.
> 
> I've studied the allocation cost in great detail, thus let me share my
> numbers, 100 ns is too high:
> 
> Total cost of alloc+free for 256 byte objects (on CPU i7-4790K @ 4.00GHz).
> The cycles count should be comparable with other CPUs, but that nanosec
> measurement is affected by the very high clock freq of this CPU.
> 
> Kmem_cache fastpath "recycle" case:
>  SLUB => 44 cycles(tsc) 11.205 ns
>  SLAB => 96 cycles(tsc) 24.119 ns.
> 
> The problem is that real use-cases in the network stack, almost always
> hit the slowpath in kmem_cache allocators.
> 
> Kmem_cache "slowpath" case:
>  SLUB => 117 cycles(tsc) 29.276 ns
>  SLAB => 101 cycles(tsc) 25.342 ns
> 
> I've addressed this "slowpath" problem in the SLUB and SLAB allocators,
> by introducing a bulk API, which amortize the needed sync-mechanisms.
> 
> Kmem_cache using bulk API:
>  SLUB => 37 cycles(tsc) 9.280 ns
>  SLAB => 20 cycles(tsc) 5.035 ns


Your numbers are nice, but the reality of most applications is they run
on hosts with ~72 hyperthreads, soon to be ~128 ht.

(Two physical sockets, with their corresponding memory)

The perf numbers show about 100 ns penalty per cache line miss, when all
these threads perform real work and applications are properly tuned,
because it is very rare the working set is all in caches.

In the following real case, we can see these numbers.

$ perf guncore -M miss_lat_rem,miss_lat_loc
#------------------------------------------------------------------------------------
#                Socket0                  |                Socket1                  |
#------------------------------------------------------------------------------------
# Load Miss Latency  | Load Miss Latency  | Load Miss Latency  | Load Miss Latency  |
#     Remote RAM     |     Local RAM      |     Remote RAM     |     Local RAM      |
#                  ns|                  ns|                  ns|                  ns|
#------------------------------------------------------------------------------------
               162.25               130.61               173.74               116.80
               162.40               130.41               173.33               116.59
               163.11               132.28               175.90               117.09
               163.36               132.86               176.69               117.45
               161.92               130.32               173.20               117.35
               163.46               130.99               174.80               117.42
               163.54               130.55               174.09               117.26
               163.29               129.75               173.84               117.36
               162.38               130.31               173.44               117.18
               163.00               130.81               174.47               117.24
