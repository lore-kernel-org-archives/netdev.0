From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Tue, 12 Nov 2013 17:33:55 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B740A@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73FE@saturn3.aculab.com> <Pine.LNX.4.44L0.1311111525480.17105-100000@netrider.rowland.org> <20131112171438.GA4925@xanatos>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Sarah Sharp" <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"Alan Stern" <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <20131112171438.GA4925@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > That's one way to do it.  Or you could allow a Link TRB at an
> > intermediate MBP boundary.
> 
> I like this idea instead.  The xHCI driver should be modified to be able
> to handle link TRBs in the middle of the segments (the cancellation code
> would have to be touched as well).  We would keep a running count
> of the number of bytes left in a TD fragment, as we fill in the TRBs.
> If we find the TD fragment would span a link TRB, we backtrack to the
> end of the last TD fragment, put in a link TRB, and then continue on the
> next segment.

I'd do that as a later change.
It needs a fair amount of other stuff fixing first and the current
code is rather broken - and needs a fix for stable.

> > It comes down to a question of how often you want the controller to
> > issue an interrupt.  If a ring segment is 4 KB (one page), then it can
> > hold 256 TRBs.  With scatter-gather transfers, each SG element
> > typically refers to something like a 2-page buffer (depends on how
> > fragmented the memory is).  Therefore a ring segment will describe
> > somewhere around 512 pages of data, i.e., something like 2 MB.  Since
> > SuperSpeed is 500 MB/s, you'd end up getting in the vicinity of 250
> > interrupts every second just because of ring segment crossings.
> 
> The driver is currently defined to have 64 TRBs per ring segment.  But
> that doesn't matter; we don't get an interrupt when a ring segment is
> crossed.  Instead we set the interrupt-on-completion flag on the last
> TRB of the TD, not on any earlier fragment or link TRB.
> 
> > Using larger ring segments would help.
> 
> Ring segments have to be physically contiguous, so I'm not sure if we
> want to ask for segments that are bigger than a page.  I've already got
> a report from someone else about the ring expansion getting out of
> control, so I would like to figure that out before we talk about using
> even bigger segments.

I'd vote for a single segment containing either 128 or 256 TRBs.
That is less than a single page.

> Finally, it's interesting to note that the USB mass storage driver is
> using scatter gather lists just fine without the driver following the TD
> fragment rules.  Or at least no one has reported any issues.  I wonder
> why it works?

I suspect that breaking the rules just generates two TD.
The mass storage driver is probably almost always presenting
buffer fragments that are page sized and page aligned.
In which case the split is invisible at the target.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
