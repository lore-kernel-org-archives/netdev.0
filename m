From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Wed, 13 Nov 2013 09:28:58 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B740B@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7407@saturn3.aculab.com> <Pine.LNX.4.44L0.1311121343060.1200-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Sarah Sharp" <sarah.a.sharp@linux.intel.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: "Alan Stern" <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35130 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1758670Ab3KMJaS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 04:30:18 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06251-03 for <netdev@vger.kernel.org>;
 Wed, 13 Nov 2013 09:30:15 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.44L0.1311121343060.1200-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Since you don't really want to do all the work twice, the sensible
> > way is to add each input fragment to the ring one a time.
> > If you need to cross a link TRB and the last MBP boundary is within
> > the previous data TRB then you can split the previous data TRB at the
> > MBP boundary and continue.
> > If the previous TRB is short then you'd need to go back through the
> > earlier TRB until you found the one that contains a TRB boundary,
> > split it, and write a link TRB in the following slot.
> 
> Right.  You could avoid doing a lot of work twice by using two passes.
> In the first pass, keep track of the number of bytes allotted to each
> TRB and the MBP boundaries, without doing anything else.  That way,
> you'll know where to put a Link TRB without any need for backtracking.
> Then in the second pass, fill in the actual contents of the TRBs.

No - you really don't want to process everything twice.
You could remember the TRB and offset of the last MBP boundary.
 
> > If you are within the first MBP then you'd need to replace the first
> > TRB of the message with a link TRB.
> 
> Unless the first TRB of the message is the first TRB of the ring
> segment.  Then you're in trouble...  Hopefully, real URBs will never be
> that badly fragmented.

I suspect that ones from the network stack might be badly fragmented.
The code needs to at least detect and error them.
I don't think linux skb can be as fragmented as I've seen network
buffers on other systems - 1 byte per buffer chained together to
a maximal sized ethernet packet.
 
> > > > For bulk data the link TRB can be forced at a packet boundary
> > > > by splitting the TD up - the receiving end won't know the difference.
> > >
> > > That won't work.  What happens if you split a TD up into two pieces and
> > > the first piece receives a short packet?  The host controller will
> > > automatically move to the start of the second piece.  That's not what
> > > we want.
> >
> > You can split a bulk TD on a 1k boundary and the target won't know the
> > difference.
> 
> The target won't know the difference, but the host will.  Here's an
> example: Suppose the driver submits two URBs, each for a data-in
> transfer of 32 KB.  You split each URB up into two 16-KB TDs; let's
> call them A, B, C, and D (where A and B make up the first URB, and C
> and D make up the second URB).

I was thinking about OUT transfers, IN ones are unlikely to be badly
fragmented.

> > > > There is no necessity for taking an interrupt from every link segment.
> > >
> > > Yes, there is.  The HCD needs to know when the dequeue pointer has
> > > moved beyond the end of the ring segment, so that it can start reusing
> > > the TRB slots in that segment.
> >
> > You already know that because of the interrupts for the data packets
> > themselves.
> 
> I don't know what you mean by this.  The host controller does not
> generate an interrupt for each data packet.  In generates interrupts
> only for TRBs with the IOC bit set (which is generally the last TRB in
> each TD).
> 
> Suppose you have only two ring segments, and a driver submits an URB
> which is so fragmented that it requires more TRBs than you have room
> for in those two segments.  When do you want the interrupts to arrive?
> Answer: At each segment crossing.

You bounce the original request and fix the driver to submit URB
with fewer fragments.

> > > > I would change the code to use a single segment (for coding simplicity)
> > > > and queue bulk URB when there isn't enough ring space.
> > > > URB with too many fragments could either be rejected, sent in sections,
> > > > or partially linearised (and probably still sent in sections).
> > >
> > > Rejecting an URB is not feasible.  Splitting it up into multiple TDs is
> > > not acceptable, as explained above.  Sending it in sections (i.e.,
> > > queueing only some of the TRBs at any time) would work, provided you
> > > got at least two interrupts every time the queue wrapped around (which
> > > suggests you might want at least two ring segments).
> >
> > Rejecting badly fragmented URB is almost certainly ok. You really don't
> > want the hardware overhead of processing a TRB every few bytes.
> > This would be especially bad on iommu systems.
> 
> I disagree.  Sure, it would be bad.  But if you can handle it, you
> should.

You have to draw the line somewhere.

	David
