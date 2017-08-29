From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Tue, 29 Aug 2017 15:02:53 -0400
Message-ID: <20170829190253.GA77682@C02RW35GFVH8.dhcp.broadcom.net>
References: <CACKFLinJ0N7b8Xhq4ZoHdB80uXp_MU_vVyzZa7Dq11XrXsvDbw@mail.gmail.com>
 <20170823102937.79a9c4ed@redhat.com>
 <CACKFLinGuaDLxYRd=vC99DL5n0mf0rDbPRaDg4ctev=DEAhRSQ@mail.gmail.com>
 <20170825144513.1ee9fbb1@redhat.com>
 <59A03DF5.7070806@gmail.com>
 <CACKFLin-sZEkkCxE2iZRHjgG=K36OJ65B-xrEYVCCSQqhYsH-g@mail.gmail.com>
 <20170828160237.GA70910@C02RW35GFVH8.dhcp.broadcom.net>
 <CAKgT0UeZ5Wn+8qY8kbBef5weORwGAXjq6Qp7jtB1bscmjY_oYw@mail.gmail.com>
 <20170829152601.02fdb8a3@redhat.com>
 <CAKgT0Uebz0dX9wotygOo59UTKt-bQ29Oyd6=MkJYE0a+y2dR2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Michael Chan <michael.chan@broadcom.com>,
        John Fastabend <john.fastabend@gmail.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        "borkmann@iogearbox.net" <borkmann@iogearbox.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:37964 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdH2TDA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 15:03:00 -0400
Received: by mail-qt0-f181.google.com with SMTP id w42so18709545qtg.5
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 12:03:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAKgT0Uebz0dX9wotygOo59UTKt-bQ29Oyd6=MkJYE0a+y2dR2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 09:23:49AM -0700, Alexander Duyck wrote:
> On Tue, Aug 29, 2017 at 6:26 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> >
> > On Mon, 28 Aug 2017 09:11:25 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:
> >
> >> My advice would be to not over complicate this. My big concern with
> >> all this buffer recycling is what happens the first time somebody
> >> introduces something like mirroring? Are you going to copy the data to
> >> a new page which would be quite expensive or just have to introduce
> >> reference counts? You are going to have to deal with stuff like
> >> reference counts eventually so you might as well bite that bullet now.
> >> My advice would be to not bother with optimizing for performance right
> >> now and instead focus on just getting functionality. The approach we
> >> took in ixgbe for the transmit path should work for almost any other
> >> driver since all you are looking at is having to free the page
> >> reference which takes care of reference counting already.
> >
> > This return API is not about optimizing performance right now.  It is
> > actually about allowing us to change the underlying memory model per RX
> > queue for XDP.
> 
>  I would disagree. To me this is a obvious case of premature optimization.
> 

I'm with Jesper on this.  Though it may seem to you that this is an
optimization that is not a goal.

> > If a RX-ring is use for both SKBs and XDP, then the refcnt model is
> > still enforced.  Although a driver using the 1-packet-per-page model,
> > should be able to reuse refcnt==1 pages when returned from XDP.
> 
> Isn't this the case for all Rx on XDP enabled rings. Last I knew there
> was an option to pass packets up via an SKB if XDP_PASS is returned.
> Are you saying we need to do a special allocation path if an XDP
> program doesn't make use of XDP_PASS?

I am not proposing that a special allocation path is needed depending on the
return code from the XDP program.  I'm proposing that in a case where
the return code is XDP_REDIRECT (or really anytime the ndo_xdp_xmit
operation is called), that there should be:

(1) notification back to the driver/resource/etc that allocated the page
that resources are no longer in use.

or 

(2) common alloc/free framework used by drivers that operate on
xdp->data so that framework takes care of refcounting, etc.

My preference is (1) since it provides drivers the most flexibility in
the event that some hardware resource (rx ring buffer pointer) or
software resource (page or other chunk of memory) can be freed.

> > If a RX-ring is _ONLY_ used for XDP, then the driver have freedom to
> > implement another memory model, with the return-API.  We need to
> > experiment with the most optimal memory model.  The 1-packet-per-page
> > model is actually not the fastest, because of PCI-e bottlenecks.  With
> > HW support for packing descriptors and packets over the PCI-e bus, much
> > higher rates can be achieved.  Mellanox mlx5-Lx already have the needed HW
> > support.  And companies like NetCope also have 100G HW that does
> > similar tricks, and they even have a whitepaper[1][2] how they are
> > faster than DPDK with their NDP (Netcope Data Plane) API.
> >
> > We do need the ability/flexibility to change the RX memory model, to
> > take advantage of this new NIC hardware.
> 
> Looking over the white paper I see nothing that prevents us from using
> the same memory model we do with the Intel NICs. If anything I think
> the Intel drivers in "legacy-rx" mode could support something like
> this now, even if the hardware doesn't simply because we can get away
> with keeping the memory pseudo-pinned. My bigger concern is that we
> keep coming back to this idea that we need to have the network stack
> taking care of the 1 page per packet recycling when I really think it
> has no business being there. We either need to look at implementing
> this in the way we did in the Intel drivers where we use the reference
> counts or implement our own memory handling API like SLUB or something
> similar based on compound page destructors. I would much rather see us
> focus on getting this going with an agnostic memory model where we
> don't have to make the stack aware of where the memory came from or
> where it has to be returned to.
> 
> > [1] https://www.netcope.com/en/resources/improving-dpdk-performance
> > [2] https://www.netcope.com/en/company/press-center/press-releases/read-new-netcope-whitepaper-on-dpdk-acceleration
> 
> My only concern with something like this is the fact that it is
> optimized for a setup where the data is left in place and nothing
> extra is added. Trying to work with something like this gets more
> expensive when you have to deal with the full stack as you have to
> copy out the headers and still deal with all the skb metadata. I fully
> agree with the basic premise that writing in large blocks provides
> significant gains in throughput, specifically with small packets. The
> only gotcha you would have to deal with is SKB allocation and data
> copying overhead to make room and fill in metadata for the frame and
> any extra headers needed.
> 
> - Alex
