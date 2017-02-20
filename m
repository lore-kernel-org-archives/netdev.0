From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Focusing the XDP project
Date: Tue, 21 Feb 2017 00:39:49 +0100
Message-ID: <20170221003949.33fac127@redhat.com>
References: <20170220111343.76f77748@redhat.com>
        <CAKgT0Ucqp6+jWkiGxDoEE-UdbnxsdVLxjZZ6uYtNWHSo4fPUVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tom Herbert <tom@herbertland.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@gmail.com>, brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46460 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750835AbdBTXjz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 18:39:55 -0500
In-Reply-To: <CAKgT0Ucqp6+jWkiGxDoEE-UdbnxsdVLxjZZ6uYtNWHSo4fPUVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Feb 2017 12:09:30 -0800
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On Mon, Feb 20, 2017 at 2:13 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> >
> > First thing to bring in order for the XDP project:
> >
> >   RX batching is missing.
> >
> > I don't want to discuss packet page-sizes or multi-port forwarding,
> > before we have established the most fundamental principal that all
> > other solution use; RX batching.  
> 
> That is all well and good, but some of us would like to discuss other
> items as it has a direct impact on our driver implementation and
> future driver design.  Rx batching really seems tangential to the
> whole XDP discussion anyway unless you are talking about rewriting the
> core BPF code and kernel API itself to process multiple frames at a
> time.

If I could change the BPF XDP program to take/process multiple frames
at a time, I would, but this is likely too late ABI wise?  As the BPF
programs are so small, we can simply simulate "bulking" by calling the
BPF prog in a loop (this is sort of already happening with XDP_DROP and
XDP_TX as the code path/size is so small) and it is good-enough.


> That said, if something seems like it would break the concept you have
> for Rx batching please bring it up.  What I would like to see is well
> defined APIs and a usable interface so that I can present XDP to
> management and they will see the use of it and be willing to let me
> dedicate developer heads to enabling it on our drivers.

What I'm afraid of is that you/we start to define APIs for multi-port
XDP forwarding, without supporting batching/bundling, because RX
batching layer is not ready yet.

 
> > Without building in RX batching, from the beginning/now, the XDP
> > architecture have lost.  As adding features and capabilities, will
> > just lead us back to the exact same performance problems as before!  

 
> I would argue you have much bigger issues to deal with.  Here is a short list:
>
> 1. The Tx code is mostly just a toy.  We need support for more
>    functional use cases.

XDP_TX do have real-life usage.

Multi-port TX or forwarding need to be designed right. I would like to
see that we think further than ifindex'es.   Can a simple vport mapping
table, that maps vport to ifindex, also be used for mapping a vport to
a socket?


> 2.  1 page per packet is costly, and blocks use on the intel drivers,
> mlx4 (after Eric's patches), and 64K page architectures.

XDP have opened the door to allow us to change the memory model for the
drivers.  This is needed big time.  The major performance bottleneck
for networking lies in memory management overhead.  Memory management
is a key for all the bypass solutions.

The Intel drivers are blocked, because you have solved the problem
partly (for short lived packets). The solution is brilliant, no doubt,
but IMHO it have its limitations. And I don't get why you insist XDP
should inherit these limitations. The page recycling is tied hard to
the size of the RX ring, that is a problem.  As both Eric and Tariq
realized they needed increase the RX ring size to 4096 to get TCP
performance.  Sharing the page makes in unpredictable when the
cache-line of struct page, will get cache-line-refcnt bounced, which is
a problem for the XDP performance target.


> 3.  Should we support scatter-gather to support 9K jumbo frames
> instead of allocating order 2 pages?

>From the start, we have chosen that enabling result in disabling some
features.  We explicitly choose not to support jumbo frames.
XDP buffers need to be keep as simple as possible.

 
> Focusing on Rx batching seems like bike shedding more than anything
> else.  I would much rather be focused on what the API definitions
> should be for the drivers and the BPF code rather than focus on the
> inner workings of the drivers themselves.  Then at that point we can
> start looking at expanding this out to other drivers and coming up
> with good test cases to test the functionality.  We really need the
> interfaces clearly defines so that we can then look at having those
> pulled into the distros so we have some sort of ABI we can work with
> in customer environments.
> 
> Dropping frames is all well and good, but only so useful.  With the
> addition of DMA_ATTR_SKIP_CPU_SYNC we should be able to do writable
> pages so we could now do encap/decap type workloads.  If we can add
> support for routing pages between interfaces that gets us close to
> being able to OVS style demos.  At that point we can then start
> comparing ourselves to DPDK and FD.io and seeing what we can do to
> improve performance.

I just hope you/we design interfaces with bundling in mind, as the
tricks FD.io uses requires that...  We can likely compete with DPDK
speeds, for toy examples, but for more realistic use-case with larger
code and large tables, FD.io/VPP can beat us, if we don't think in
bundling.

 
> > Today we already have the 64 packets NAPI budget, but we are not
> > taking advantage of this. For XDP as long as eBPF always return
> > XDP_DROP or XDP_TX, then we (falsely) experience the effect of bulking
> > (as code fits within the icache) and see huge perf boosts.  
> 
> This makes a lot of assumptions.  First, the budget is up to 64, it
> isn't always 64.  Second, you say we are "falsely" seeing icache
> improvements, and I would argue that it isn't false as we are
> intentionally bypassing most of the stack to perform the drop early.

By falsely I mean, our toy examples always return XDP_DROP, they don't
test the case where some packets also go to the netstack.  Once a
packet travel to the netstack, it will have flushed the eBPF icache
once it returns, and the eBPF code is reloaded (that was the point).


> That was kind of the point of all this.  Finally, this completely
> discounts GRO/LRO which would take care of aggregating the frames and
> reducing much of this overhead for TCP flows being received over the
> interface.

XDP does not hurt GRO, but bundling packets for GRO processing still
work. XDP does requires to disable HW LRO.  It is a trade off, if you
want LRO don't load a XDP program.


> > The initial principal of bulking/batching packets to amortize per
> > packet costs.  The next step is just as important: Lookup table sizes
> > (FIB) kills performance again. The solution is implementing a smart
> > table lookup scheme that prefetch hash table key-cells and afterwards
> > prefetch data-cells, based on the RX batch of packets.  Notice VPP
> > revolves around similar tricks, and why it beats DPDK, and why it
> > scales with 1Millon routes.  
> 
> This is where things go completely sideways in your argument.  If you
> want to implement some sort of custom FIB lookup library for XDP be my
> guest.  If you are talking about hacking on the kernel I would
> question how this is even related to XDP?  The lookup that is in the
> kernel is designed to provide the best possible lookup under a number
> of different conditions.  It is a "jack of all trades, master of none"
> type of implementation.

I do see your point, that RX bundling can also help the normal
netstack.  You did some amazing work in optimizing the FIB-trie lookup
(thanks for that!).  I guess, we could implement FIB lookup with
prefetching latency hiding based on having a bundle of packets.


> Also, why should we be focused on FIB?  Seems like this is getting
> back into routing territory and what I am looking for is uses well
> beyond just routing.

I'm not focused on FIB at all... I just pointed out that I would to get
an XDP forward arch that support sending packet round via "vports" for
maximum flexibility.


> > I hope I've made it very clear where the focus for XDP should be.
> > This involves implementing what I call RX-stages in the drivers. While
> > doing that we can figure out the most optimal data structure for
> > packet batching.  
> 
> Yes Jesper, your point of view is clear.  This is the same agenda you
> have been pushing for the last several years.  I just don't see how
> this can be made a priority now for a project where it isn't even
> necessarily related.  In order for any of this to work the stack needs
> support for bulk Rx, and we still seem pretty far from that happening.

I'm thinking we can implement this kind of bundling for the XDP use-case
first, as most of this can be contained within the driver.  After we
get experience with what works, we can take the next step and also
support bulking towards the netstack.

 
> >  I know Saeed is already working on RX-stages for mlx5, and I've tested
> > the initial version of his patch, and the results are excellent.  
> 
> That is great!  I look forward to seeing it when they push it to net-next.
> 
> By the way, after looking over the mlx5 driver it seems like there is
> a bug in the logic.  From what I can tell it is using build_skb to
> build frames around the page, but it doesn't bother to take care of
> handling the mappings correctly.  So mlx5 can end up with data
> corruption when the pages are unmapped.  My advice would be to look at
> updating the driver to do something like what I did in ixgbe to make
> use of the DMA_ATTR_SKIP_CPU_SYNC DMA attribute so that it won't
> invalidate any updates made when adding headers or shared info.

I guess, Saeed would need to look at this!

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
