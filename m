From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Focusing the XDP project
Date: Mon, 20 Feb 2017 12:09:30 -0800
Message-ID: <CAKgT0Ucqp6+jWkiGxDoEE-UdbnxsdVLxjZZ6uYtNWHSo4fPUVg@mail.gmail.com>
References: <20170220111343.76f77748@redhat.com>
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
Received: from mail-it0-f44.google.com ([209.85.214.44]:36525 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752014AbdBTUJd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 15:09:33 -0500
Received: by mail-it0-f44.google.com with SMTP id h10so79939025ith.1
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 12:09:32 -0800 (PST)
In-Reply-To: <20170220111343.76f77748@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 20, 2017 at 2:13 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> First thing to bring in order for the XDP project:
>
>   RX batching is missing.
>
> I don't want to discuss packet page-sizes or multi-port forwarding,
> before we have established the most fundamental principal that all
> other solution use; RX batching.

That is all well and good, but some of us would like to discuss other
items as it has a direct impact on our driver implementation and
future driver design.  Rx batching really seems tangential to the
whole XDP discussion anyway unless you are talking about rewriting the
core BPF code and kernel API itself to process multiple frames at a
time.

That said, if something seems like it would break the concept you have
for Rx batching please bring it up.  What I would like to see is well
defined APIs and a usable interface so that I can present XDP to
management and they will see the use of it and be willing to let me
dedicate developer heads to enabling it on our drivers.

> Without building in RX batching, from the beginning/now, the XDP
> architecture have lost.  As adding features and capabilities, will
> just lead us back to the exact same performance problems as before!

I would argue you have much bigger issues to deal with.  Here is a short list:
1.  The Tx code is mostly just a toy.  We need support for more
functional use cases.
2.  1 page per packet is costly, and blocks use on the intel drivers,
mlx4 (after Eric's patches), and 64K page architectures.
3.  Should we support scatter-gather to support 9K jumbo frames
instead of allocating order 2 pages?

Focusing on Rx batching seems like bike shedding more than anything
else.  I would much rather be focused on what the API definitions
should be for the drivers and the BPF code rather than focus on the
inner workings of the drivers themselves.  Then at that point we can
start looking at expanding this out to other drivers and coming up
with good test cases to test the functionality.  We really need the
interfaces clearly defines so that we can then look at having those
pulled into the distros so we have some sort of ABI we can work with
in customer environments.

Dropping frames is all well and good, but only so useful.  With the
addition of DMA_ATTR_SKIP_CPU_SYNC we should be able to do writable
pages so we could now do encap/decap type workloads.  If we can add
support for routing pages between interfaces that gets us close to
being able to OVS style demos.  At that point we can then start
comparing ourselves to DPDK and FD.io and seeing what we can do to
improve performance.

> Today we already have the 64 packets NAPI budget, but we are not
> taking advantage of this. For XDP as long as eBPF always return
> XDP_DROP or XDP_TX, then we (falsely) experience the effect of bulking
> (as code fits within the icache) and see huge perf boosts.

This makes a lot of assumptions.  First, the budget is up to 64, it
isn't always 64.  Second, you say we are "falsely" seeing icache
improvements, and I would argue that it isn't false as we are
intentionally bypassing most of the stack to perform the drop early.
That was kind of the point of all this.  Finally, this completely
discounts GRO/LRO which would take care of aggregating the frames and
reducing much of this overhead for TCP flows being received over the
interface.

> The initial principal of bulking/batching packets to amortize per
> packet costs.  The next step is just as important: Lookup table sizes
> (FIB) kills performance again. The solution is implementing a smart
> table lookup scheme that prefetch hash table key-cells and afterwards
> prefetch data-cells, based on the RX batch of packets.  Notice VPP
> revolves around similar tricks, and why it beats DPDK, and why it
> scales with 1Millon routes.

This is where things go completely sideways in your argument.  If you
want to implement some sort of custom FIB lookup library for XDP be my
guest.  If you are talking about hacking on the kernel I would
question how this is even related to XDP?  The lookup that is in the
kernel is designed to provide the best possible lookup under a number
of different conditions.  It is a "jack of all trades, master of none"
type of implementation.

Also, why should we be focused on FIB?  Seems like this is getting
back into routing territory and what I am looking for is uses well
beyond just routing.

> I hope I've made it very clear where the focus for XDP should be.
> This involves implementing what I call RX-stages in the drivers. While
> doing that we can figure out the most optimal data structure for
> packet batching.

Yes Jesper, your point of view is clear.  This is the same agenda you
have been pushing for the last several years.  I just don't see how
this can be made a priority now for a project where it isn't even
necessarily related.  In order for any of this to work the stack needs
support for bulk Rx, and we still seem pretty far from that happening.

>  I know Saeed is already working on RX-stages for mlx5, and I've tested
> the initial version of his patch, and the results are excellent.

That is great!  I look forward to seeing it when they push it to net-next.

By the way, after looking over the mlx5 driver it seems like there is
a bug in the logic.  From what I can tell it is using build_skb to
build frames around the page, but it doesn't bother to take care of
handling the mappings correctly.  So mlx5 can end up with data
corruption when the pages are unmapped.  My advice would be to look at
updating the driver to do something like what I did in ixgbe to make
use of the DMA_ATTR_SKIP_CPU_SYNC DMA attribute so that it won't
invalidate any updates made when adding headers or shared info.

- Alex
