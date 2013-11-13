From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Wed, 13 Nov 2013 11:27:21 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1311131120540.1424-100000@iolanthe.rowland.org>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B740C@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B740C-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Nov 2013, David Laight wrote:

> > > that doesn't matter; we don't get an interrupt when a ring segment is
> > > crossed.  Instead we set the interrupt-on-completion flag on the last
> > > TRB of the TD, not on any earlier fragment or link TRB.
> > 
> > That's because you don't worry about handling URBs which require too
> > many TRBs (i.e., more than are available).  You just add more ring
> > segments.  Instead, you could re-use segments on the fly.
> > 
> > For example, suppose you have only two ring segments and you get an URB
> > which requires enough TRBs to fill up four segments.  You could fill in
> > the first two segments worth, and get an interrupt when the controller
> > traverses the Link TRB between them.  At that point you store the third
> > set of TRBs in the first segment, which is now vacant.  Similarly, when
> > the second Link TRB is traversed, you fill in the fourth set of TRBs.
> 
> That isn't going to work.

Queuing URBs and processing them in pieces was _your_ suggestion.  I
merely repeated it to Sarah and filled in some detail.

> It might work for very long TD, but for very fragmented ones the interrupt
> rate would be stupid.

Not if the individual SG elements are reasonably large -- say at least 
512 bytes.  They have to be that big if they are to work with ehci-hcd, 
so why not also for xhci-hcd?

>  In any case you'd definitely need enough ring
> segments for the TRB that describe a single 'max packet size' block.

That would be two TRBs (for maxpacket = 1024), meaning you'd need at
least one ring segment.  That's not much of a restriction.

> > > Finally, it's interesting to note that the USB mass storage driver is
> > > using scatter gather lists just fine without the driver following the TD
> > > fragment rules.  Or at least no one has reported any issues.  I wonder
> > > why it works?
> > 
> > I'd guess this is because the hardware is actually a lot more flexible
> > than the "No Link TRBs in the middle of a TD fragment" rule.
> 
> With the hardware I have (Intel i7 Sandy bridge) Link TRB cannot
> be placed at arbitrary boundaries.
> I don't know whether the actual restriction is only to packet boundaries.

That's what I had in mind by "more flexible" above.

> I don't have a USB3 monitor and it would also require a more contrived
> test than I've been doing.

You wouldn't need a monitor to check it, but you would need some 
careful tests.

> > The whole idea of TD fragments makes no sense to begin with.  What
> > point is there in grouping packets into MaxBurst-sized collections?
> 
> It probably saved a few logic gates somewhere, either that or it is
> a bug in some hardware implementation that got documented in the spec
> instead of being fixed :-)

I can believe the guess about it reflecting a bug.  Particularly since 
it is so badly written.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
