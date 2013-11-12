From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Tue, 12 Nov 2013 14:22:57 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1311121401510.1200-100000@iolanthe.rowland.org>
References: <20131112171438.GA4925@xanatos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Laight <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:59921 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754734Ab3KLTW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 14:22:57 -0500
In-Reply-To: <20131112171438.GA4925@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Nov 2013, Sarah Sharp wrote:

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

A TRB is 16 bytes, right?  So a page can hold 256 TRBs.  Why use only 
64 per segment?

> that doesn't matter; we don't get an interrupt when a ring segment is
> crossed.  Instead we set the interrupt-on-completion flag on the last
> TRB of the TD, not on any earlier fragment or link TRB.

That's because you don't worry about handling URBs which require too 
many TRBs (i.e., more than are available).  You just add more ring 
segments.  Instead, you could re-use segments on the fly.

For example, suppose you have only two ring segments and you get an URB
which requires enough TRBs to fill up four segments.  You could fill in
the first two segments worth, and get an interrupt when the controller
traverses the Link TRB between them.  At that point you store the third
set of TRBs in the first segment, which is now vacant.  Similarly, when
the second Link TRB is traversed, you fill in the fourth set of TRBs.

> > Using larger ring segments would help.
> 
> Ring segments have to be physically contiguous, so I'm not sure if we
> want to ask for segments that are bigger than a page.  I've already got
> a report from someone else about the ring expansion getting out of
> control, so I would like to figure that out before we talk about using
> even bigger segments.

Maybe you can get away with fewer segments, if they are bigger.

> Finally, it's interesting to note that the USB mass storage driver is
> using scatter gather lists just fine without the driver following the TD
> fragment rules.  Or at least no one has reported any issues.  I wonder
> why it works?

I'd guess this is because the hardware is actually a lot more flexible
than the "No Link TRBs in the middle of a TD fragment" rule.

The whole idea of TD fragments makes no sense to begin with.  What
point is there in grouping packets into MaxBurst-sized collections?  
The hardware does not have to finish one burst before beginning the
next one.  For example, suppose the MaxBurst size is 8.  The host
starts by bursting packets 1-8.  When it receives the ACK for packet 4,
the host could then burst packets 9-12.  It doesn't have to wait for
the ACK to packet 8.  (Unless I have misunderstood the USB-3 spec.)

If the host does this, the burst boundaries won't occur on MBP 
boundaries, and hence won't occur on TD fragment boundaries.  The 
fragment boundaries will be essentially meaningless.

Alan Stern
