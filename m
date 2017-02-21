From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: Focusing the XDP project
Date: Wed, 22 Feb 2017 01:08:49 +0200
Message-ID: <CALzJLG-YSkNu4cEAbbQM0yq1LEk=bms=+++tP_hjbpmTxcK4Rg@mail.gmail.com>
References: <20170220111343.76f77748@redhat.com> <CAKgT0Ucqp6+jWkiGxDoEE-UdbnxsdVLxjZZ6uYtNWHSo4fPUVg@mail.gmail.com>
 <cc26e1ce-05ae-6c3d-a323-b6f18e2ad897@mellanox.com> <CAKgT0Ud539SXwtv8vbAYp+BJuRH=+Xn-6WOGw__DpSdseYJPfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:33102 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752422AbdBUXJL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 18:09:11 -0500
Received: by mail-qt0-f172.google.com with SMTP id b16so75373123qte.0
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 15:09:10 -0800 (PST)
In-Reply-To: <CAKgT0Ud539SXwtv8vbAYp+BJuRH=+Xn-6WOGw__DpSdseYJPfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 1:40 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Mon, Feb 20, 2017 at 2:57 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>>
>>
>> On 02/20/2017 10:09 PM, Alexander Duyck wrote:
>>> On Mon, Feb 20, 2017 at 2:13 AM, Jesper Dangaard Brouer
>>> <brouer@redhat.com> wrote:
>>>>
>>>> First thing to bring in order for the XDP project:
>>>>
>>>>   RX batching is missing.
>>>>
>>>> I don't want to discuss packet page-sizes or multi-port forwarding,
>>>> before we have established the most fundamental principal that all
>>>> other solution use; RX batching.
>>>
>>> That is all well and good, but some of us would like to discuss other
>>> items as it has a direct impact on our driver implementation and
>>> future driver design.  Rx batching really seems tangential to the
>>> whole XDP discussion anyway unless you are talking about rewriting the
>>> core BPF code and kernel API itself to process multiple frames at a
>>> time.
>>>
>>> That said, if something seems like it would break the concept you have
>>> for Rx batching please bring it up.  What I would like to see is well
>>> defined APIs and a usable interface so that I can present XDP to
>>> management and they will see the use of it and be willing to let me
>>> dedicate developer heads to enabling it on our drivers.
>>>
>>>> Without building in RX batching, from the beginning/now, the XDP
>>>> architecture have lost.  As adding features and capabilities, will
>>>> just lead us back to the exact same performance problems as before!
>>>
>>> I would argue you have much bigger issues to deal with.  Here is a short list:
>>> 1.  The Tx code is mostly just a toy.  We need support for more
>>> functional use cases.
>>> 2.  1 page per packet is costly, and blocks use on the intel drivers,
>>> mlx4 (after Eric's patches), and 64K page architectures.
>>> 3.  Should we support scatter-gather to support 9K jumbo frames
>>> instead of allocating order 2 pages?
>>>
>>> Focusing on Rx batching seems like bike shedding more than anything
>>> else.  I would much rather be focused on what the API definitions
>>> should be for the drivers and the BPF code rather than focus on the
>>> inner workings of the drivers themselves.  Then at that point we can
>>> start looking at expanding this out to other drivers and coming up
>>> with good test cases to test the functionality.  We really need the
>>> interfaces clearly defines so that we can then look at having those
>>> pulled into the distros so we have some sort of ABI we can work with
>>> in customer environments.
>>>
>>> Dropping frames is all well and good, but only so useful.  With the
>>> addition of DMA_ATTR_SKIP_CPU_SYNC we should be able to do writable
>>> pages so we could now do encap/decap type workloads.  If we can add
>>> support for routing pages between interfaces that gets us close to
>>> being able to OVS style demos.  At that point we can then start
>>> comparing ourselves to DPDK and FD.io and seeing what we can do to
>>> improve performance.
>>>
>>
>> Well, although I think Jesper is a little bit exaggerating ;) I guess he has a point
>> and i am on his side on this discussion. you see, if we define the APIs and ABIs now
>> and they turn out to be a bottleneck for the whole XDP arch performance, at that
>> point it will be too late to compare XDP to DPDK and other kernel bypass solutions.
>
> Yes, but at the same time we cannot hold due to decision paralysis.
> We should be moving forward, not holding waiting on things that may or
> may not get done.

I am not saying we should wait, i am saying we should work in all
frontiers, but keep in mind that the whole idea of XDP is max
performance with minimal kernel/stack overhead.

>
>> What we need to do is to bring XDP to a state where it performs at least the same as other
>> kernel bypass solutions. I know that the DPDK team here at mellanox spent years working
>> on DPDK performance, squeezing every bit out of the code/dcache/icache/cpu you name it..
>> We simply need to do the same for XDP to prove it worthy and can deliver the required
>> rates. Only then, when we have the performance baseline numbers, we can start expanding XDP features
>> and defining new use cases and a uniform API, while making sure the performance is kept at it max.
>
> The problem is performance without features is useless.  I can make a

XDP without performance is useless :).

> driver that received and drops all packets that goes really fast, but
> it isn't too terribly useful and nobody will use it.  I don't want us
> locking in on one use case and spending all of our time optimizing for
> that when there is a good chance that nobody cares.  For example the
> FIB argument Jesper was making is likely completely useless to most
> people who will want to use XDP.  While there are some that may want a
> router implemented in XDP it is much more likely that they will want
> to do VM to VM switching via something more like OVS.
>
> My argument is that we need to figure out what features we need, then
> we can focus on performance.  I would much rather deliver a feature
> and then improve the performance, than show the performance and not be
> able to meet that after adding a feature.  It is all a matter of
> setting expectations.
>

I think the use cases and the features list are already clear, XDP
should be simple, fast and flexible to implement most of the use cases
you mentioned above (firewall, routing, injecting, inspecting,
encap,decap) you name it :), and it should be up to the program the
user defines, really.
It shouldn't be different form the current kernel solutions and even
the stack itself (at least this is what i think of XDP), others might
disagree.

i know we are not quite there yet, but remember if XDP is not as fast
as other competitors, what is the point of doing it at all ?


>> Yes, there is a down side to this, that currently most of the optimizations and implementations we can do
>> are inside the device driver and they are driver dependent, but once we have a clear image
>> on how things should work, we can pause and think on how to generalize the approaches
>> to all device drivers.
>
> I'm fine with the optimizations being in the device driver, however
> feature implementations are another matter.  Historically once
> something is in a driver it takes a long time if ever for it to be
> generalized out of the driver.  More often than not the driver vendors
> prefer to leave their code as-is for a competitive advantage.
> Historically the way we deal with this as a community is that if an
> interface is likely to be used by more than one device it has to start
> out generalized.

point taken, but How do you generalized something that isn't fully cooked yet ?

>
>>>> Today we already have the 64 packets NAPI budget, but we are not
>>>> taking advantage of this. For XDP as long as eBPF always return
>>>> XDP_DROP or XDP_TX, then we (falsely) experience the effect of bulking
>>>> (as code fits within the icache) and see huge perf boosts.
>>>
>>> This makes a lot of assumptions.  First, the budget is up to 64, it
>>> isn't always 64.  Second, you say we are "falsely" seeing icache
>>> improvements, and I would argue that it isn't false as we are
>>> intentionally bypassing most of the stack to perform the drop early.
>>> That was kind of the point of all this.  Finally, this completely
>>> discounts GRO/LRO which would take care of aggregating the frames and
>>> reducing much of this overhead for TCP flows being received over the
>>> interface.
>>>
>>>> The initial principal of bulking/batching packets to amortize per
>>>> packet costs.  The next step is just as important: Lookup table sizes
>>>> (FIB) kills performance again. The solution is implementing a smart
>>>> table lookup scheme that prefetch hash table key-cells and afterwards
>>>> prefetch data-cells, based on the RX batch of packets.  Notice VPP
>>>> revolves around similar tricks, and why it beats DPDK, and why it
>>>> scales with 1Millon routes.
>>>
>>> This is where things go completely sideways in your argument.  If you
>>> want to implement some sort of custom FIB lookup library for XDP be my
>>> guest.  If you are talking about hacking on the kernel I would
>>> question how this is even related to XDP?  The lookup that is in the
>>> kernel is designed to provide the best possible lookup under a number
>>> of different conditions.  It is a "jack of all trades, master of none"
>>> type of implementation.
>>>
>>> Also, why should we be focused on FIB?  Seems like this is getting
>>> back into routing territory and what I am looking for is uses well
>>> beyond just routing.
>>>
>>>> I hope I've made it very clear where the focus for XDP should be.
>>>> This involves implementing what I call RX-stages in the drivers. While
>>>> doing that we can figure out the most optimal data structure for
>>>> packet batching.
>>>
>>> Yes Jesper, your point of view is clear.  This is the same agenda you
>>> have been pushing for the last several years.  I just don't see how
>>> this can be made a priority now for a project where it isn't even
>>> necessarily related.  In order for any of this to work the stack needs
>>> support for bulk Rx, and we still seem pretty far from that happening.
>>>
>>>>  I know Saeed is already working on RX-stages for mlx5, and I've tested
>>>> the initial version of his patch, and the results are excellent.
>>>
>>> That is great!  I look forward to seeing it when they push it to net-next.
>>>
>>> By the way, after looking over the mlx5 driver it seems like there is
>>> a bug in the logic.  From what I can tell it is using build_skb to
>>> build frames around the page, but it doesn't bother to take care of
>>> handling the mappings correctly.  So mlx5 can end up with data
>>> corruption when the pages are unmapped.  My advice would be to look at
>>> updating the driver to do something like what I did in ixgbe to make
>>> use of the DMA_ATTR_SKIP_CPU_SYNC DMA attribute so that it won't
>>> invalidate any updates made when adding headers or shared info.
>>>
>>
>> hmmm, are you talking about the mlx5 rx page cache ? will take a look at the ixgbe code for sure
>> but we didn't experience any issue of the sort, can you shed more light on the issue ?
>>
>> Thanks,
>> -Saeed.
>
> Basically the issue is that there are some architectures where
> dma_unmap_page will invalidate the page and cause any data written to
> it from the CPU side to be invalidated.  On x86 the only way to
> recreate this is to use the kernel parameter "swiotlb=force".
> Basically when a page was mapped you couldn't unmap it without running
> the risk of invalidating any data you had written to it.  I added a
> DMA attribute called DMA_ATTR_SKIP_CPU_SYNC which is meant to prevent
> that from taking place on unmap.  It also ends up being a performance
> gain on architectures that do this since it avoids looping through
> cache lines invalidating them on unmap.
>
> Hope that helps.
>

Thanks!! will take a look tomorrow.

> - Alex
