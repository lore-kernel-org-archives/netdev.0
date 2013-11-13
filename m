From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Wed, 13 Nov 2013 16:58:39 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B741A@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B740B@saturn3.aculab.com> <Pine.LNX.4.44L0.1311131113090.1424-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Sarah Sharp" <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Alan Stern" <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.44L0.1311131113090.1424-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Alan Stern [mailto:stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org]
> Sent: 13 November 2013 16:21
> To: David Laight
> Cc: Sarah Sharp; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
> 
> On Wed, 13 Nov 2013, David Laight wrote:
> 
> > > > Since you don't really want to do all the work twice, the sensible
> > > > way is to add each input fragment to the ring one a time.
> > > > If you need to cross a link TRB and the last MBP boundary is within
> > > > the previous data TRB then you can split the previous data TRB at the
> > > > MBP boundary and continue.
> > > > If the previous TRB is short then you'd need to go back through the
> > > > earlier TRB until you found the one that contains a TRB boundary,
> > > > split it, and write a link TRB in the following slot.
> > >
> > > Right.  You could avoid doing a lot of work twice by using two passes.
> > > In the first pass, keep track of the number of bytes allotted to each
> > > TRB and the MBP boundaries, without doing anything else.  That way,
> > > you'll know where to put a Link TRB without any need for backtracking.
> > > Then in the second pass, fill in the actual contents of the TRBs.
> >
> > No - you really don't want to process everything twice.
> 
> What I described does not process anything twice.  It calculates the
> byte counts on the first pass and everything else on the second pass.
> 
> > You could remember the TRB and offset of the last MBP boundary.
> 
> Then you really _do_ end up processing the TRB's which follow the last
> MBP boundary twice.  Once when setting up the TD as normal, and then
> again after you realize they need to be moved to a different ring
> segment.

That would only be a few of the TRBs, not all of them.
The cheap option is to work out an upper bound for the number of TRB
and the write a new LINK TRB if there isn't enough space.
That does limit the maximum number of TRB in a URB to half the total
ring (less if it has more than 2 fragments).
 
> > > Unless the first TRB of the message is the first TRB of the ring
> > > segment.  Then you're in trouble...  Hopefully, real URBs will never be
> > > that badly fragmented.
> >
> > I suspect that ones from the network stack might be badly fragmented.
> > The code needs to at least detect and error them.
> 
> I'm not so sure about this.  The network stack works okay with other
> host controller drivers (like ehci-hcd), which have much stricter
> requirements about fragmentation.  They require that the length of each
> SG element except the last one must be a multiple of the maxpacket
> size.  For high-speed bulk transfers, that means a multiple of 512.

Yes, for other host controllers the network cards linearise the skb.
it is only for xhci where where the buffer fragments from the skb
can be given to the usb controller.
This is probably also only enabled (at the moment) for the ASIX Ge card
- which can also do TCP transmit segmentation offload (TSO).
It is effectively a necessity for TSO since it would otherwise
require 64k blocks of contiguous memory (or some horrid code that
involves a misaligned copy).
The SG code in usbnet was only added for 3.12.

> > > > You can split a bulk TD on a 1k boundary and the target won't know the
> > > > difference.
> > >
> > > The target won't know the difference, but the host will.  Here's an
> > > example: Suppose the driver submits two URBs, each for a data-in
> > > transfer of 32 KB.  You split each URB up into two 16-KB TDs; let's
> > > call them A, B, C, and D (where A and B make up the first URB, and C
> > > and D make up the second URB).
> >
> > I was thinking about OUT transfers, IN ones are unlikely to be badly
> > fragmented.
> 
> Maybe not for the network stack, but OUT and IN end up equally
> fragmented for the storage stack.

But the minimum fragment size is (probably) 4k.
For the network stack an OUT transfer might have a lot (and I mean lots)
of fragments (there may be constraints, and linearising the skb is a option).

> > > Suppose you have only two ring segments, and a driver submits an URB
> > > which is so fragmented that it requires more TRBs than you have room
> > > for in those two segments.  When do you want the interrupts to arrive?
> > > Answer: At each segment crossing.
> >
> > You bounce the original request and fix the driver to submit URB
> > with fewer fragments.
> 
> In other words, you want to limit the number of SG elements the driver
> will accept.

Yes, passing the buck to the higher layer.
If the ring was a single segment of 256 slots you'd have to limit the
number of TRB to 128. If the alignment is horrid this could be under 64
fragments (because of the 64k boundary restriction).

What I don't know is whether the code to increase the ring size was added
because a single URB contained too many fragments, or because a lot
of URB were submitted at once - I don't remember anything in the commit
messages about why.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
