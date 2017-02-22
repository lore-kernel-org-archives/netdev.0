From: Tom Herbert <tom@herbertland.com>
Subject: Re: Focusing the XDP project
Date: Wed, 22 Feb 2017 14:08:30 -0800
Message-ID: <CALx6S365FdNU-iM_ufoytZOoi7JTSjj6TY10O8AJ217JHGyaNA@mail.gmail.com>
References: <20170220111343.76f77748@redhat.com> <CAKgT0Ucqp6+jWkiGxDoEE-UdbnxsdVLxjZZ6uYtNWHSo4fPUVg@mail.gmail.com>
 <cc26e1ce-05ae-6c3d-a323-b6f18e2ad897@mellanox.com> <CALx6S375878KeM0O7BO9sB7B_3p+yO4yxfEhxYdn_=AZvWF-Aw@mail.gmail.com>
 <CALzJLG-323ZOyruHok3=jz526bnw=SoYtYSym8RrA3Z5=g0u9Q@mail.gmail.com>
 <CALx6S37s=Kcy+wEbojVHjiAoLZC_4V5qzMLe=-QXtJYVtwTAew@mail.gmail.com>
 <20170222104328.4b9c6c5d@redhat.com> <CALx6S35qC5+-5ke=d01nkgTnEH1b4GuMcaicKST2BwsC3y5Ghw@mail.gmail.com>
 <20170222224313.2dce0057@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:34966 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932639AbdBVWIc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 17:08:32 -0500
Received: by mail-qk0-f174.google.com with SMTP id u188so16378427qkc.2
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 14:08:32 -0800 (PST)
In-Reply-To: <20170222224313.2dce0057@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 1:43 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Wed, 22 Feb 2017 09:22:53 -0800
> Tom Herbert <tom@herbertland.com> wrote:
>
>> On Wed, Feb 22, 2017 at 1:43 AM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> >
>> > On Tue, 21 Feb 2017 14:54:35 -0800 Tom Herbert <tom@herbertland.com> wrote:
>> >> On Tue, Feb 21, 2017 at 2:29 PM, Saeed Mahameed <saeedm@dev.mellanox.co.il> wrote:
>> > [...]
>> >> > The only complexity XDP is adding to the drivers is the constrains on
>> >> > RX memory management and memory model, calling the XDP program itself
>> >> > and handling the  action is really a simple thing once you have the
>> >> > correct memory model.
>> >
>> > Exactly, that is why I've been looking at introducing a generic
>> > facility for a memory model for drivers.  This should help simply
>> > drivers.  Due to performance needs this need to be a very thin API layer
>> > on top of the page allocator. (That's why I'm working with Mel Gorman
>> > to get more close integration with the page allocator e.g. a bulking
>> > facility).
>> >
>> >> > Who knows! maybe someday XDP will define one unified RX API for all
>> >> > drivers and it even will handle normal stack delivery it self :).
>> >> >
>> >> That's exactly the point and what we need for TXDP. I'm missing why
>> >> doing this is such rocket science other than the fact that all these
>> >> drivers are vastly different and changing the existing API is
>> >> unpleasant. The only functional complexity I see in creating a generic
>> >> batching interface is handling return codes asynchronously. This is
>> >> entirely feasible though...
>> >
>> > I'll be happy as long as we get a batching interface, then we can
>> > incrementally do the optimizations later.
>> >
>> > In the future, I do hope (like Saeed) this RX API will evolve into
>> > delivering (a bulk of) raw-packet-pages into the netstack, this should
>> > simplify drivers, and we can keep the complexity and SKB allocations
>> > out of the drivers.
>> > To start with, we can play with doing this delivering (a bulk of)
>> > raw-packet-pages into Tom's TXDP engine/system?
>> >
>> Hi Jesper,
>>
>> Maybe we can to start to narrow in on what a batching API might look like.
>>
>> Looking at mlx5 (as a model of how XDP is implemented) the main RX
>> loop in ml5e_poll_rx_cq calls the backend handler in one indirect
>> function call. The XDP path goes through mlx5e_handle_rx_cqe,
>> skb_from_cqe, and mlx5e_xdp_handle. The first two deal a lot with
>> building the skbuf. As a prerequisite to RX batching it would be
>> helpful if this could be flatten so that most of the logic is obvious
>> in the main RX loop.
>
> I fully agree here, it would be helpful to flatten out.  The mlx5
> driver is a bit hard to follow in that respect.  Saeed have already
> send me some offlist patches, where some of this code gets
> restructured. In one of the patches the RX-stages does get flatten out
> some more.  We are currently benchmarking this patchset, and depending
> on CPU it is either a small win or a small (7ns) regressing (on the newest
> CPUs).
>
Cool!

>
>> The model of RX batching seems straightforward enough-- pull packets
>> from the ring, save xdp_data information in a vector, periodically
>> call into the stack to handle a batch where argument is the vector of
>> packets and another argument is an output vector that gives return
>> codes (XDP actions), process the each return code for each packet in
>> the driver accordingly.
>
> Yes, exactly.  I did imagine that (maybe), the input vector of packets
> could have a room for the return codes (XDP actions) next to the packet
> pointer?
>
Which ever way is more efficient I suppose. The important point is
that the return code should be only the only thing returned to the
driver.

>
>> Presumably, there is a maximum allowed batch
>> that may or may not be the same as the NAPI budget so the so the
>> batching call needs to be done when the limit is reach and also before
>> exiting NAPI.
>
> In my PoC code that Saeed is working on, we have a smaller batch
> size(10), and prefetch to L2 cache (like DPDK does), based on the
> theory that we don't want to stress the L2 cache usage, and that these
> CPUs usually have a Line Feed Buffer (LFB) that is limited to 10
> outstanding cache-lines.
>
> I don't know if this artifically smaller batch size is the right thing,
> as DPDK always prefetch to L2 cache all 32 packets on RX.  And snabb
> uses batches of 100 packets per "breath".
>
Maybe make it configurable :-)

>
>> For each packet the stack can return an XDP code,
>> XDP_PASS in this case could be interpreted as being consumed by the
>> stack; this would be used in the case the stack creates an skbuff for
>> the packet. The stack on it's part can process the batch how it sees
>> fit, it can process each packet individual in the canonical model, or
>> we can continue processing a batch in a VPP-like fashion.
>
> Agree.
>
>> The batching API could be transparent to the stack or not. In the
>> transparent case, the driver calls what looks like a receive function
>> but the stack may defer processing for batching. A callback function
>> (that can be inlined) is used to process return codes as I mentioned
>> previously. In the non-transparent model, the driver knowingly creates
>> the packet vector and then explicitly calls another function to
>> process the vector. Personally, I lean towards the transparent API,
>> this may be less complexity in drivers and gives the stack more
>> control over the parameters of batching (for instance it may choose
>> some batch size to optimize its processing instead of driver guessing
>> the best size).
>
> I cannot make up my mind on which model... I have to think some more
> about this.  Thanks for bringing this up! :-)  This is something we
> need to think about.
>
>
>> Btw the logic for RX batching is very similar to how we batch packets
>> for RPS (I think you already mention an skb-less RPS and that should
>> hopefully be something would falls out from this design).
>
> Yes, I've mentioned skb-less RPS before, because it seem wasteful for
> RPS to allocate the fat skb on one CPU (and memset zero) force all
> cache-lines hot, just to transfer it to another CPU.
>  The tricky part is how do we transfer, the info from the NIC specific
> descriptor on HW-offload fields? (that we usually update the SKB with,
> before the netstack gets the SKB).
>
> The question is also if XDP should be part of skb-less RPS steering, or
> it should be something more generic in the stack? (after we get a bulk
> of raw-packets delivered to the stack).
>
I'd probably keep them separate for now since the mechanisms have
pretty different goals.

Tom

> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
