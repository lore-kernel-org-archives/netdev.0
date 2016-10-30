From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Mon, 31 Oct 2016 00:53:53 +0200
Message-ID: <20161031004709-mutt-send-email-mst@kernel.org>
References: <CAKgT0Ufe3QYtFpmtsL39-nbyy+YEt=gZKU_WUr9Wir+LTYLuEQ@mail.gmail.com>
 <20161027.221027.109834362557507518.davem@davemloft.net>
 <58137533.4030105@gmail.com>
 <20161028.131101.1982236040609043994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.fastabend@gmail.com, alexander.duyck@gmail.com,
        brouer@redhat.com, shrijeet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, shm@cumulusnetworks.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42112 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752236AbcJ3Wx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Oct 2016 18:53:57 -0400
Content-Disposition: inline
In-Reply-To: <20161028.131101.1982236040609043994.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 28, 2016 at 01:11:01PM -0400, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Fri, 28 Oct 2016 08:56:35 -0700
> 
> > On 16-10-27 07:10 PM, David Miller wrote:
> >> From: Alexander Duyck <alexander.duyck@gmail.com>
> >> Date: Thu, 27 Oct 2016 18:43:59 -0700
> >> 
> >>> On Thu, Oct 27, 2016 at 6:35 PM, David Miller <davem@davemloft.net> wrote:
> >>>> From: "Michael S. Tsirkin" <mst@redhat.com>
> >>>> Date: Fri, 28 Oct 2016 01:25:48 +0300
> >>>>
> >>>>> On Thu, Oct 27, 2016 at 05:42:18PM -0400, David Miller wrote:
> >>>>>> From: "Michael S. Tsirkin" <mst@redhat.com>
> >>>>>> Date: Fri, 28 Oct 2016 00:30:35 +0300
> >>>>>>
> >>>>>>> Something I'd like to understand is how does XDP address the
> >>>>>>> problem that 100Byte packets are consuming 4K of memory now.
> >>>>>>
> >>>>>> Via page pools.  We're going to make a generic one, but right now
> >>>>>> each and every driver implements a quick list of pages to allocate
> >>>>>> from (and thus avoid the DMA man/unmap overhead, etc.)
> >>>>>
> >>>>> So to clarify, ATM virtio doesn't attempt to avoid dma map/unmap
> >>>>> so there should be no issue with that even when using sub/page
> >>>>> regions, assuming DMA APIs support sub-page map/unmap correctly.
> >>>>
> >>>> That's not what I said.
> >>>>
> >>>> The page pools are meant to address the performance degradation from
> >>>> going to having one packet per page for the sake of XDP's
> >>>> requirements.
> >>>>
> >>>> You still need to have one packet per page for correct XDP operation
> >>>> whether you do page pools or not, and whether you have DMA mapping
> >>>> (or it's equivalent virutalization operation) or not.
> >>>
> >>> Maybe I am missing something here, but why do you need to limit things
> >>> to one packet per page for correct XDP operation?  Most of the drivers
> >>> out there now are usually storing something closer to at least 2
> >>> packets per page, and with the DMA API fixes I am working on there
> >>> should be no issue with changing the contents inside those pages since
> >>> we won't invalidate or overwrite the data after the DMA buffer has
> >>> been synchronized for use by the CPU.
> >> 
> >> Because with SKB's you can share the page with other packets.
> >> 
> >> With XDP you simply cannot.
> >> 
> >> It's software semantics that are the issue.  SKB frag list pages
> >> are read only, XDP packets are writable.
> >> 
> >> This has nothing to do with "writability" of the pages wrt. DMA
> >> mapping or cpu mappings.
> >> 
> > 
> > Sorry I'm not seeing it either. The current xdp_buff is defined
> > by,
> > 
> >   struct xdp_buff {
> > 	void *data;
> > 	void *data_end;
> >   };
> > 
> > The verifier has an xdp_is_valid_access() check to ensure we don't go
> > past data_end. The page for now at least never leaves the driver. For
> > the work to get xmit to other devices working I'm still not sure I see
> > any issue.
> 
> I guess I can say that the packets must be "writable" until I'm blue
> in the face but I'll say it again, semantically writable pages are a
> requirement.  And if multiple packets share a page this requirement
> is not satisfied.
> 
> Also, we want to do several things in the future:
> 
> 1) Allow push/pop of headers via eBPF code, which needs we need
>    headroom.

I think that with e.g. LRO or a large MTU page per packet
does not guarantee headroom.

> 2) Transparently zero-copy pass packets into userspace, basically
>    the user will have a semi-permanently mapped ring of all the
>    packet pages sitting in the RX queue of the device and the
>    page pool associated with it.  This way we avoid all of the
>    TLB flush/map overhead for the user's mapping of the packets
>    just as we avoid the DMA map/unmap overhead.

Looks like you can share pages between packets as long as
they all come from the same pool so accessible
to the same userspace.

> And that's just the beginninng.
> 
> I'm sure others can come up with more reasons why we have this
> requirement.

I'm still a bit confused :( Is this a requirement of the current code or
to enable future extensions?

-- 
MST
