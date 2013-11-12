From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Tue, 12 Nov 2013 11:08:34 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1311121051090.1200-100000@iolanthe.rowland.org>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73FF@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73FF-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Nov 2013, David Laight wrote:

> > You're right.  I do wish the spec had been written more clearly.
> 
> I've read a lot of hardware specs in my time ...
> 
> > > Reading it all again makes me think that a LINK trb is only
> > > allowed on the burst boundary (which might be 16k bytes).
> > > The only real way to implement that is to ensure that TD never
> > > contain LINK TRB.
> > 
> > That's one way to do it.  Or you could allow a Link TRB at an
> > intermediate MBP boundary.
> 
> If all the fragments are larger than the MBP (assume 16k) then
> that would be relatively easy. However that is very dependant
> on the source of the data. It might be true for disk data, but
> is unlikely to be true for ethernet data.

I don't quite understand your point.  Are you saying that if all the 
TRBs are very short, you might need more than 64 TRBs to reach a 16-KB 
boundary?

> For bulk data the link TRB can be forced at a packet boundary
> by splitting the TD up - the receiving end won't know the difference.

That won't work.  What happens if you split a TD up into two pieces and 
the first piece receives a short packet?  The host controller will 
automatically move to the start of the second piece.  That's not what 
we want.

> > It comes down to a question of how often you want the controller to
> > issue an interrupt.  If a ring segment is 4 KB (one page), then it can
> > hold 256 TRBs.  With scatter-gather transfers, each SG element
> > typically refers to something like a 2-page buffer (depends on how
> > fragmented the memory is).  Therefore a ring segment will describe
> > somewhere around 512 pages of data, i.e., something like 2 MB.  Since
> > SuperSpeed is 500 MB/s, you'd end up getting in the vicinity of 250
> > interrupts every second just because of ring segment crossings.
> 
> 250 interrupts/sec is noise. Send/receive 13000 ethernet packets/sec
> and then look at the interrupt rate!
> 
> There is no necessity for taking an interrupt from every link segment.

Yes, there is.  The HCD needs to know when the dequeue pointer has
moved beyond the end of the ring segment, so that it can start reusing
the TRB slots in that segment.

Suppose you have queued a bulk URB because there weren't enough free 
TRB slots.  How else would you know when the occupied slots became 
available?

> The current ring segments contain 64 entries, a strange choice
> since they are created with 2 segments.
> (The ring expansion code soon doubles that for my ethernet traffic.)
> 
> I would change the code to use a single segment (for coding simplicity)
> and queue bulk URB when there isn't enough ring space.
> URB with too many fragments could either be rejected, sent in sections,
> or partially linearised (and probably still sent in sections).

Rejecting an URB is not feasible.  Splitting it up into multiple TDs is
not acceptable, as explained above.  Sending it in sections (i.e.,
queueing only some of the TRBs at any time) would work, provided you
got at least two interrupts every time the queue wrapped around (which
suggests you might want at least two ring segments).

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
