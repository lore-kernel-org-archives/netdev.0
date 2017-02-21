From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Focusing the XDP project
Date: Mon, 20 Feb 2017 16:39:54 -0800
Message-ID: <CAKgT0UduFz7Ji=Ew_sYg72Pw+7yfiNWRAuDv21hDmF1PH8v46A@mail.gmail.com>
References: <20170220111343.76f77748@redhat.com> <CAKgT0Ucqp6+jWkiGxDoEE-UdbnxsdVLxjZZ6uYtNWHSo4fPUVg@mail.gmail.com>
 <20170221003949.33fac127@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tom Herbert <tom@herbertland.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:37602 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750922AbdBUAj4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 19:39:56 -0500
Received: by mail-it0-f49.google.com with SMTP id 203so27935211ith.0
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 16:39:56 -0800 (PST)
In-Reply-To: <20170221003949.33fac127@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 20, 2017 at 3:39 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Mon, 20 Feb 2017 12:09:30 -0800
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> On Mon, Feb 20, 2017 at 2:13 AM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> >
>> > First thing to bring in order for the XDP project:
>> >
>> >   RX batching is missing.
>> >
>> > I don't want to discuss packet page-sizes or multi-port forwarding,
>> > before we have established the most fundamental principal that all
>> > other solution use; RX batching.
>>
>> That is all well and good, but some of us would like to discuss other
>> items as it has a direct impact on our driver implementation and
>> future driver design.  Rx batching really seems tangential to the
>> whole XDP discussion anyway unless you are talking about rewriting the
>> core BPF code and kernel API itself to process multiple frames at a
>> time.
>
> If I could change the BPF XDP program to take/process multiple frames
> at a time, I would, but this is likely too late ABI wise?  As the BPF
> programs are so small, we can simply simulate "bulking" by calling the
> BPF prog in a loop (this is sort of already happening with XDP_DROP and
> XDP_TX as the code path/size is so small) and it is good-enough.
>
>
>> That said, if something seems like it would break the concept you have
>> for Rx batching please bring it up.  What I would like to see is well
>> defined APIs and a usable interface so that I can present XDP to
>> management and they will see the use of it and be willing to let me
>> dedicate developer heads to enabling it on our drivers.
>
> What I'm afraid of is that you/we start to define APIs for multi-port
> XDP forwarding, without supporting batching/bundling, because RX
> batching layer is not ready yet.
>
>
>> > Without building in RX batching, from the beginning/now, the XDP
>> > architecture have lost.  As adding features and capabilities, will
>> > just lead us back to the exact same performance problems as before!
>
>
>> I would argue you have much bigger issues to deal with.  Here is a short list:
>>
>> 1. The Tx code is mostly just a toy.  We need support for more
>>    functional use cases.
>
> XDP_TX do have real-life usage.

Benchmarks don't count.  I don't see how echoing a frame back out on
the port it came in on will have much of an effect other than
confusing a switch.  You need to be able to change values in the
frame, I suppose you can do it on mlx5 but technically you are
violating the DMA API if you do.

> Multi-port TX or forwarding need to be designed right. I would like to
> see that we think further than ifindex'es.   Can a simple vport mapping
> table, that maps vport to ifindex, also be used for mapping a vport to
> a socket?

I'd say you might be getting ahead of yourself.  For a Tx we should be
using a device, for a socket that is another matter entirely.  I would
consider them two very different things and not eligible for using the
same interface.

>> 2.  1 page per packet is costly, and blocks use on the intel drivers,
>> mlx4 (after Eric's patches), and 64K page architectures.
>
> XDP have opened the door to allow us to change the memory model for the
> drivers.  This is needed big time.  The major performance bottleneck
> for networking lies in memory management overhead.  Memory management
> is a key for all the bypass solutions.

Changing the memory model isn't that big of a deal.  Honestly the
Intel drivers took care of this long ago with our page recycling
setup.  I think the DMA API bits I just added push this one step
further by allowing us to avoid the skb->head allocations.  The only
real issue we have to deal with is the sk_buff struct itself since
that thing is an oversized beast.

Also last I knew the bulk allocation stuff still showed little boost
for anything other than the routing use case.  I just don't want to
spend our time working on optimizing code for a use case that ends up
penalizing us when users try to make use of the kernel for actual work
like handling TCP sockets.

> The Intel drivers are blocked, because you have solved the problem
> partly (for short lived packets). The solution is brilliant, no doubt,
> but IMHO it have its limitations. And I don't get why you insist XDP
> should inherit these limitations. The page recycling is tied hard to
> the size of the RX ring, that is a problem.  As both Eric and Tariq
> realized they needed increase the RX ring size to 4096 to get TCP
> performance.  Sharing the page makes in unpredictable when the
> cache-line of struct page, will get cache-line-refcnt bounced, which is
> a problem for the XDP performance target.

I'm not insisting XDP be locked down to supporting the Intel approach.
All I am saying is don't lock us into having to use your approach.
>From what I can tell there is no hard requirement so as long as that
is the case don't try to enforce it as though there is.  Once your
page allocation API is in the kernel we can then revisit this and see
if we want to do it differently.

As far as the cache size, the upper limit using the Intel approach is
the size of the ring.  Historically we have seen very good reuse with
this at just the 512 descriptor size.  One of the reasons I
implemented it the way I did is because on PowerPC and x86 systems the
IOMMU can come into play on every map/unmap call and we took a heavy
penalty for that.  After implementing the page recycling the IOMMU
penalty on Rx was nearly completely wiped out.  At this point the only
real issue in regards to the IOMMU and mapping/unmapping is related to
Tx for us.

>> 3.  Should we support scatter-gather to support 9K jumbo frames
>> instead of allocating order 2 pages?
>
> From the start, we have chosen that enabling result in disabling some
> features.  We explicitly choose not to support jumbo frames.
> XDP buffers need to be keep as simple as possible.

That's fine if we never want this to be anything more than a proof of
concept.  However we should consider that some systems can't afford to
allocate 16K of memory per descriptor for receive.

>> Focusing on Rx batching seems like bike shedding more than anything
>> else.  I would much rather be focused on what the API definitions
>> should be for the drivers and the BPF code rather than focus on the
>> inner workings of the drivers themselves.  Then at that point we can
>> start looking at expanding this out to other drivers and coming up
>> with good test cases to test the functionality.  We really need the
>> interfaces clearly defines so that we can then look at having those
>> pulled into the distros so we have some sort of ABI we can work with
>> in customer environments.
>>
>> Dropping frames is all well and good, but only so useful.  With the
>> addition of DMA_ATTR_SKIP_CPU_SYNC we should be able to do writable
>> pages so we could now do encap/decap type workloads.  If we can add
>> support for routing pages between interfaces that gets us close to
>> being able to OVS style demos.  At that point we can then start
>> comparing ourselves to DPDK and FD.io and seeing what we can do to
>> improve performance.
>
> I just hope you/we design interfaces with bundling in mind, as the
> tricks FD.io uses requires that...  We can likely compete with DPDK
> speeds, for toy examples, but for more realistic use-case with larger
> code and large tables, FD.io/VPP can beat us, if we don't think in
> bundling.

Think about this the other way.  What if we go and implement almost no
features and show all this great performance.  Then when we finally
get around to implementing features we lose all the performance
because we didn't take into account the needs of the features.  I
don't want to just write marketing code, I want code that actually
does something useful.

>> > Today we already have the 64 packets NAPI budget, but we are not
>> > taking advantage of this. For XDP as long as eBPF always return
>> > XDP_DROP or XDP_TX, then we (falsely) experience the effect of bulking
>> > (as code fits within the icache) and see huge perf boosts.
>>
>> This makes a lot of assumptions.  First, the budget is up to 64, it
>> isn't always 64.  Second, you say we are "falsely" seeing icache
>> improvements, and I would argue that it isn't false as we are
>> intentionally bypassing most of the stack to perform the drop early.
>
> By falsely I mean, our toy examples always return XDP_DROP, they don't
> test the case where some packets also go to the netstack.  Once a
> packet travel to the netstack, it will have flushed the eBPF icache
> once it returns, and the eBPF code is reloaded (that was the point).

I fail to see how that is a problem of XDP.  I think you are confusing
XDP and your driver refactor ideas.  We could implement bulk Rx and
never touch a line of XDP code.

With that said, I get your concerns for XDP_TX and needing to bulk the
traffic somehow to get xmit_more type performance, but don't conflate
that with Rx bulking.

>> That was kind of the point of all this.  Finally, this completely
>> discounts GRO/LRO which would take care of aggregating the frames and
>> reducing much of this overhead for TCP flows being received over the
>> interface.
>
> XDP does not hurt GRO, but bundling packets for GRO processing still
> work. XDP does requires to disable HW LRO.  It is a trade off, if you
> want LRO don't load a XDP program.

Right, but the reason for having to disable LRO is the same reason why
you can't really handle jumbo frames very well.  I think we need to
look at implementing scatter-gather as a feature to address that.

>> > The initial principal of bulking/batching packets to amortize per
>> > packet costs.  The next step is just as important: Lookup table sizes
>> > (FIB) kills performance again. The solution is implementing a smart
>> > table lookup scheme that prefetch hash table key-cells and afterwards
>> > prefetch data-cells, based on the RX batch of packets.  Notice VPP
>> > revolves around similar tricks, and why it beats DPDK, and why it
>> > scales with 1Millon routes.
>>
>> This is where things go completely sideways in your argument.  If you
>> want to implement some sort of custom FIB lookup library for XDP be my
>> guest.  If you are talking about hacking on the kernel I would
>> question how this is even related to XDP?  The lookup that is in the
>> kernel is designed to provide the best possible lookup under a number
>> of different conditions.  It is a "jack of all trades, master of none"
>> type of implementation.
>
> I do see your point, that RX bundling can also help the normal
> netstack.  You did some amazing work in optimizing the FIB-trie lookup
> (thanks for that!).  I guess, we could implement FIB lookup with
> prefetching latency hiding based on having a bundle of packets.

Really this would be low priority in my opinion.  There are a few
users out there that might care like Project Calico users but for now
I'm not planning on reworking the FIB code any time soon.

>> Also, why should we be focused on FIB?  Seems like this is getting
>> back into routing territory and what I am looking for is uses well
>> beyond just routing.
>
> I'm not focused on FIB at all... I just pointed out that I would to get
> an XDP forward arch that support sending packet round via "vports" for
> maximum flexibility.

Okay.

>> > I hope I've made it very clear where the focus for XDP should be.
>> > This involves implementing what I call RX-stages in the drivers. While
>> > doing that we can figure out the most optimal data structure for
>> > packet batching.
>>
>> Yes Jesper, your point of view is clear.  This is the same agenda you
>> have been pushing for the last several years.  I just don't see how
>> this can be made a priority now for a project where it isn't even
>> necessarily related.  In order for any of this to work the stack needs
>> support for bulk Rx, and we still seem pretty far from that happening.
>
> I'm thinking we can implement this kind of bundling for the XDP use-case
> first, as most of this can be contained within the driver.  After we
> get experience with what works, we can take the next step and also
> support bulking towards the netstack.

Like you said, for the Tx and drop use cases you essentially already
have the effect of bulking.  You would be better off focusing on the
network stack and how to get bulk frames out of the driver and into
there before you start trying to make XDP do the bulking for you.

>> >  I know Saeed is already working on RX-stages for mlx5, and I've tested
>> > the initial version of his patch, and the results are excellent.
>>
>> That is great!  I look forward to seeing it when they push it to net-next.
>>
>> By the way, after looking over the mlx5 driver it seems like there is
>> a bug in the logic.  From what I can tell it is using build_skb to
>> build frames around the page, but it doesn't bother to take care of
>> handling the mappings correctly.  So mlx5 can end up with data
>> corruption when the pages are unmapped.  My advice would be to look at
>> updating the driver to do something like what I did in ixgbe to make
>> use of the DMA_ATTR_SKIP_CPU_SYNC DMA attribute so that it won't
>> invalidate any updates made when adding headers or shared info.
>
> I guess, Saeed would need to look at this!

Already gave him a few pointers where to look.

- Alex
