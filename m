From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Wed, 11 Aug 2010 23:47:29 +0100
Message-ID: <20100811224729.GD827@n2100.arm.linux.org.uk>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com> <4C627479.4060400@parrot.com> <AANLkTinU2JEkeYJHo4tA+kD9Pd_F3YcUTbK9w6igc7s8@mail.gmail.com> <4C62C7B3.2030706@nvidia.com> <20100811203505.GA463@n2100.arm.linux.org.uk> <4C632217.9000608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gary King <GKing@nvidia.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linux-usb <linux-usb@vger.kernel.org>, netdev@vger.kernel.org,
	Greg KH <greg@kroah.com>
To: Martin Fuzzey <mfuzzey@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:41303 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757480Ab0HKWrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 18:47:47 -0400
Content-Disposition: inline
In-Reply-To: <4C632217.9000608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 12, 2010 at 12:20:07AM +0200, Martin Fuzzey wrote:
> [Gary, you forgot to copy -usb and netdev so adding them again to try to
> keep this thread joined up]
> 
> Russell King - ARM Linux wrote:
> > On Wed, Aug 11, 2010 at 08:54:27AM -0700, Gary King wrote:
> >   
> >> I sent a patch to the list about 2 weeks ago that added support to
> >> DMA bounce to bounce for misaligned buffers. We have a similar
> >> problem with URB alignment for usbnet on Tegra's HCD:
> >> http://lists.arm.linux.org.uk/lurker/message/20100729.005746.b43fa1d9.en.html
>
> Nice to know someone else has the same problem :)
> What is the Tegra hcd?
> I can't find it in the kernel sources.
> 
> > We don't want to add support for this to DMA bounce.  DMA bounce is already
> > a pain in the backside and causes its own set of problems - please let it
> > die a long slow but quite death.
> >
> > If you want to see the kind of pain dmabounce causes, look at this long
> > standing and as yet unsolved bug:
> >
> >   http://bugzilla.kernel.org/show_bug.cgi?id=7760
>
> Well I don't know the dmabounce code but why is using it likely to cause
> OOM problems (at least why more so than copying the buffer in the HCD or
> the usb core).

The problem in that bug appears to be that there's soo much pressure on
the first 64MB of memory that we run out of sufficiently large blocks
of memory to be able to satisfy the requirements to do DMA bouncing via
the dmabounce code.  I don't think anyone got to the bottom of why the
DMA zone was exhausted first before the DMA32 zone ran out of pages.

However, as something using dma_map_single/dma_map_page has to return a
contiguous buffer, we do need to use high order allocations for them - a
driver on the other hand can make a decision about whether its possible
to break up the buffer into smaller (and therefore easier to allocate)
buffers.

> In both cases there will be two copies of the buffer in
> memory which could I agree be a problem in memory constrained systems.
> But if we _do_ want to accept unaligned buffers from usb drivers I can't
> see  a way round that.

One thing we have done in the past (eg, SMC91x network driver on PXA) is
to PIO the first couple of bytes to the device, and DMA the remainder -
the DMA can't do non-word aligned start addresses.  This gives us the
benefit of being able to deal with buffers containing IP packets without
copying them, while preserving the performance of using DMA.
