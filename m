From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Wed, 2 Nov 2016 15:01:00 +0100
Message-ID: <20161102150100.6d32f281@redhat.com>
References: <CAKgT0Ufe3QYtFpmtsL39-nbyy+YEt=gZKU_WUr9Wir+LTYLuEQ@mail.gmail.com>
        <20161027.221027.109834362557507518.davem@davemloft.net>
        <58137533.4030105@gmail.com>
        <20161028.131101.1982236040609043994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, alexander.duyck@gmail.com,
        mst@redhat.com, shrijeet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, shm@cumulusnetworks.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39674 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751795AbcKBOBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Nov 2016 10:01:09 -0400
In-Reply-To: <20161028.131101.1982236040609043994.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Oct 2016 13:11:01 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

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
> 
> 2) Transparently zero-copy pass packets into userspace, basically
>    the user will have a semi-permanently mapped ring of all the
>    packet pages sitting in the RX queue of the device and the
>    page pool associated with it.  This way we avoid all of the
>    TLB flush/map overhead for the user's mapping of the packets
>    just as we avoid the DMA map/unmap overhead.
> 
> And that's just the beginninng.
> 
> I'm sure others can come up with more reasons why we have this
> requirement.

I've tried to update the XDP documentation about the "Page per packet"
requirement[1], fell free to correct below text:

Page per packet
===============

On RX many NIC drivers splitup a memory page, to share it for multiple
packets, in-order to conserve memory.  Doing so complicates handling
and accounting of these memory pages, which affects performance.
Particularly the extra atomic refcnt handling needed for the page can
hurt performance.

XDP defines upfront a memory model where there is only one packet per
page.  This simplifies page handling and open up for future
extensions.

This requirement also (upfront) result in choosing not to support
things like, jumpo-frames, LRO and generally packets split over
multiple pages.

In the future, this strict memory model might be relaxed, but for now
it is a strict requirement.  With a more flexible
:ref:`ref_prog_negotiation` is might be possible to negotiate another
memory model. Given some specific XDP use-case might not require this
strict memory model.



Online here:
 [1] http://prototype-kernel.readthedocs.io/en/latest/networking/XDP/design/requirements.html#page-per-packet

Commit:
 https://github.com/netoptimizer/prototype-kernel/commit/27ece059011e6d5c8a1cb4bdb2ab361cd7faa6dd

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
