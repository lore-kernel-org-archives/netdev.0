From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Fri, 28 Oct 2016 13:35:02 -0700
Message-ID: <CAKgT0UfZJ1wP9f-ZFVqdDUXMw90DKsRp+NDuam9YnHzbD=Tuig@mail.gmail.com>
References: <20161028011739-mutt-send-email-mst@kernel.org>
 <20161027.213512.334468356710231957.davem@davemloft.net> <CAKgT0Ufe3QYtFpmtsL39-nbyy+YEt=gZKU_WUr9Wir+LTYLuEQ@mail.gmail.com>
 <20161027.221027.109834362557507518.davem@davemloft.net> <58137533.4030105@gmail.com>
 <20161028171812.48073f1f@jkicinski-Precision-T1700> <20161028182223.GA53930@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jakub Kicinski <kubakici@wp.pl>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        shrijeet@gmail.com, Tom Herbert <tom@herbertland.com>,
        Netdev <netdev@vger.kernel.org>,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>,
        roopa <roopa@cumulusnetworks.com>, nikolay@cumulusnetworks.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34507 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761888AbcJ1UfE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 16:35:04 -0400
Received: by mail-oi0-f67.google.com with SMTP id 62so1833591oif.1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 13:35:04 -0700 (PDT)
In-Reply-To: <20161028182223.GA53930@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 28, 2016 at 11:22 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Oct 28, 2016 at 05:18:12PM +0100, Jakub Kicinski wrote:
>> On Fri, 28 Oct 2016 08:56:35 -0700, John Fastabend wrote:
>> > On 16-10-27 07:10 PM, David Miller wrote:
>> > > From: Alexander Duyck <alexander.duyck@gmail.com>
>> > > Date: Thu, 27 Oct 2016 18:43:59 -0700
>> > >
>> > >> On Thu, Oct 27, 2016 at 6:35 PM, David Miller <davem@davemloft.net> wrote:
>> > >>> From: "Michael S. Tsirkin" <mst@redhat.com>
>> > >>> Date: Fri, 28 Oct 2016 01:25:48 +0300
>> > >>>
>> > >>>> On Thu, Oct 27, 2016 at 05:42:18PM -0400, David Miller wrote:
>> > >>>>> From: "Michael S. Tsirkin" <mst@redhat.com>
>> > >>>>> Date: Fri, 28 Oct 2016 00:30:35 +0300
>> > >>>>>
>> > >>>>>> Something I'd like to understand is how does XDP address the
>> > >>>>>> problem that 100Byte packets are consuming 4K of memory now.
>> > >>>>>
>> > >>>>> Via page pools.  We're going to make a generic one, but right now
>> > >>>>> each and every driver implements a quick list of pages to allocate
>> > >>>>> from (and thus avoid the DMA man/unmap overhead, etc.)
>> > >>>>
>> > >>>> So to clarify, ATM virtio doesn't attempt to avoid dma map/unmap
>> > >>>> so there should be no issue with that even when using sub/page
>> > >>>> regions, assuming DMA APIs support sub-page map/unmap correctly.
>> > >>>
>> > >>> That's not what I said.
>> > >>>
>> > >>> The page pools are meant to address the performance degradation from
>> > >>> going to having one packet per page for the sake of XDP's
>> > >>> requirements.
>> > >>>
>> > >>> You still need to have one packet per page for correct XDP operation
>> > >>> whether you do page pools or not, and whether you have DMA mapping
>> > >>> (or it's equivalent virutalization operation) or not.
>> > >>
>> > >> Maybe I am missing something here, but why do you need to limit things
>> > >> to one packet per page for correct XDP operation?  Most of the drivers
>> > >> out there now are usually storing something closer to at least 2
>> > >> packets per page, and with the DMA API fixes I am working on there
>> > >> should be no issue with changing the contents inside those pages since
>> > >> we won't invalidate or overwrite the data after the DMA buffer has
>> > >> been synchronized for use by the CPU.
>> > >
>> > > Because with SKB's you can share the page with other packets.
>> > >
>> > > With XDP you simply cannot.
>> > >
>> > > It's software semantics that are the issue.  SKB frag list pages
>> > > are read only, XDP packets are writable.
>> > >
>> > > This has nothing to do with "writability" of the pages wrt. DMA
>> > > mapping or cpu mappings.
>> > >
>> >
>> > Sorry I'm not seeing it either. The current xdp_buff is defined
>> > by,
>> >
>> >   struct xdp_buff {
>> >     void *data;
>> >     void *data_end;
>> >   };
>> >
>> > The verifier has an xdp_is_valid_access() check to ensure we don't go
>> > past data_end. The page for now at least never leaves the driver. For
>> > the work to get xmit to other devices working I'm still not sure I see
>> > any issue.
>>
>> +1
>>
>> Do we want to make the packet-per-page a requirement because it could
>> be useful in the future from architectural standpoint?  I guess there
>> is a trade-off here between having the comfort of people following this
>> requirement today and making driver support for XDP even more complex.
>
> It looks to me that packet per page makes drivers simpler instead of complex.
> ixgbe split-page and mlx* order-3/5 tricks are definitely complex.
> The skb truesize concerns come from the host when data is delivered to user
> space and we need to have precise memory accounting for different applications
> and different users. XDP is all root and imo it's far away from the days when
> multi-user non-root issues start to pop up.

Right but having XDP require 4K pages is going to hurt performance for
user space when we are using sockets.  We cannot justify killing
application performance just because we want to support XDP, and
having to alloc new memory and memcpy out of the buffers isn't going
to work as a viable workaround for this either.

> At the same time XDP doesn't require to use 4k buffer in something like Netronome.
> If xdp bpf program can be offloaded into HW with 1800 byte buffers, great!

So are you saying this is only really meant to be used with a full bpf
hardware offload then?

> For x86 cpu the 4k byte is a natural allocation chunk. Anything lower requires
> delicate dma tricks paired with even more complex slab allocator and atomic recnts.
> All of that can only drive the performance down.
> Comparing to kernel bypass xdp is using 4k pages whereas dpdk has
> to use huge pages, so xdp is saving a ton of memory already!

Do you really think the page pool Jesper is talking about doing is any
different?  Half the reason why I have to implement the DMA API
changes that I am are so that the page pool can unmap a page if the
device decides to cut it from the pool without invalidating the data
written by the CPU.

If anything I think we end up needing to add two more data members to
xdp_buff so that we can define the bounds of the sandbox it gets to
play in.  Otherwise on platforms such as PowerPC, that can use pages
larger than 4K, this is going to quickly get ridiculous.

- Alex
