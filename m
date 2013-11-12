From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Tue, 12 Nov 2013 16:50:35 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7407@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73FF@saturn3.aculab.com> <Pine.LNX.4.44L0.1311121051090.1200-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Sarah Sharp" <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Alan Stern" <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.44L0.1311121051090.1200-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > If all the fragments are larger than the MBP (assume 16k) then
> > that would be relatively easy. However that is very dependant
> > on the source of the data. It might be true for disk data, but
> > is unlikely to be true for ethernet data.
> 
> I don't quite understand your point.  Are you saying that if all the
> TRBs are very short, you might need more than 64 TRBs to reach a 16-KB
> boundary?

Since you don't really want to do all the work twice, the sensible
way is to add each input fragment to the ring one a time.
If you need to cross a link TRB and the last MBP boundary is within
the previous data TRB then you can split the previous data TRB at the
MBP boundary and continue.
If the previous TRB is short then you'd need to go back through the
earlier TRB until you found the one that contains a TRB boundary,
split it, and write a link TRB in the following slot.
If you are within the first MBP then you'd need to replace the first
TRB of the message with a link TRB.

And yes, if the data is really fragmented you might need a lot of
TRB for even 1k of data.

> > For bulk data the link TRB can be forced at a packet boundary
> > by splitting the TD up - the receiving end won't know the difference.
> 
> That won't work.  What happens if you split a TD up into two pieces and
> the first piece receives a short packet?  The host controller will
> automatically move to the start of the second piece.  That's not what
> we want.

You can split a bulk TD on a 1k boundary and the target won't know the
difference.

> > There is no necessity for taking an interrupt from every link segment.
> 
> Yes, there is.  The HCD needs to know when the dequeue pointer has
> moved beyond the end of the ring segment, so that it can start reusing
> the TRB slots in that segment.

You already know that because of the interrupts for the data packets
themselves.

> > I would change the code to use a single segment (for coding simplicity)
> > and queue bulk URB when there isn't enough ring space.
> > URB with too many fragments could either be rejected, sent in sections,
> > or partially linearised (and probably still sent in sections).
> 
> Rejecting an URB is not feasible.  Splitting it up into multiple TDs is
> not acceptable, as explained above.  Sending it in sections (i.e.,
> queueing only some of the TRBs at any time) would work, provided you
> got at least two interrupts every time the queue wrapped around (which
> suggests you might want at least two ring segments).

Rejecting badly fragmented URB is almost certainly ok. You really don't
want the hardware overhead of processing a TRB every few bytes.
This would be especially bad on iommu systems.
Before the ring expansion code was added there was an implicit
limit of (probably) 125 fragments for a URB. Exceeding this limit
wasn't the reason for adding the ring expansion code.

And, as I've pointed out, both bulk and isoc URB can be split unless
they are using too many fragments for a short piece of data.

The current code refuses to write into a TRB segment until it is
empty - I think that restriction is only there so that it can
add another segment when the space runs out.

	David





--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
