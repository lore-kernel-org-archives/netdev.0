From: Alan Stern <stern@rowland.harvard.edu>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Tue, 12 Nov 2013 14:00:51 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1311121343060.1200-100000@iolanthe.rowland.org>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7407@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:59910 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752756Ab3KLTAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 14:00:52 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7407@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Nov 2013, David Laight wrote:

> > > If all the fragments are larger than the MBP (assume 16k) then
> > > that would be relatively easy. However that is very dependant
> > > on the source of the data. It might be true for disk data, but
> > > is unlikely to be true for ethernet data.
> > 
> > I don't quite understand your point.  Are you saying that if all the
> > TRBs are very short, you might need more than 64 TRBs to reach a 16-KB
> > boundary?
> 
> Since you don't really want to do all the work twice, the sensible
> way is to add each input fragment to the ring one a time.
> If you need to cross a link TRB and the last MBP boundary is within
> the previous data TRB then you can split the previous data TRB at the
> MBP boundary and continue.
> If the previous TRB is short then you'd need to go back through the
> earlier TRB until you found the one that contains a TRB boundary,
> split it, and write a link TRB in the following slot.

Right.  You could avoid doing a lot of work twice by using two passes.  
In the first pass, keep track of the number of bytes allotted to each
TRB and the MBP boundaries, without doing anything else.  That way,
you'll know where to put a Link TRB without any need for backtracking.  
Then in the second pass, fill in the actual contents of the TRBs.

> If you are within the first MBP then you'd need to replace the first
> TRB of the message with a link TRB.

Unless the first TRB of the message is the first TRB of the ring 
segment.  Then you're in trouble...  Hopefully, real URBs will never be 
that badly fragmented.

> And yes, if the data is really fragmented you might need a lot of
> TRB for even 1k of data.

Until somebody needs more than 16 TRBs for each KB of data, we should 
be okay.

> > > For bulk data the link TRB can be forced at a packet boundary
> > > by splitting the TD up - the receiving end won't know the difference.
> > 
> > That won't work.  What happens if you split a TD up into two pieces and
> > the first piece receives a short packet?  The host controller will
> > automatically move to the start of the second piece.  That's not what
> > we want.
> 
> You can split a bulk TD on a 1k boundary and the target won't know the
> difference.

The target won't know the difference, but the host will.  Here's an
example: Suppose the driver submits two URBs, each for a data-in
transfer of 32 KB.  You split each URB up into two 16-KB TDs; let's 
call them A, B, C, and D (where A and B make up the first URB, and C 
and D make up the second URB).

Now suppose the device terminates the first transfer after only 7200 
bytes, with a short packet.  It then sends a complete 32 KB of data for 
the second transfer.  What will happen in this case?

7200 bytes is somewhere in the middle of TD A.  That TD will terminate 
early.  The host controller will then proceed to TD B.  As a result, 
the next 32 KB of data will be stored in TD B and C -- not in TD C and 
D as it should be.

This example shows why you must not split IN URBs into multiple TDs.

> > > There is no necessity for taking an interrupt from every link segment.
> > 
> > Yes, there is.  The HCD needs to know when the dequeue pointer has
> > moved beyond the end of the ring segment, so that it can start reusing
> > the TRB slots in that segment.
> 
> You already know that because of the interrupts for the data packets
> themselves.

I don't know what you mean by this.  The host controller does not 
generate an interrupt for each data packet.  In generates interrupts 
only for TRBs with the IOC bit set (which is generally the last TRB in 
each TD).

Suppose you have only two ring segments, and a driver submits an URB 
which is so fragmented that it requires more TRBs than you have room 
for in those two segments.  When do you want the interrupts to arrive?  
Answer: At each segment crossing.

> > > I would change the code to use a single segment (for coding simplicity)
> > > and queue bulk URB when there isn't enough ring space.
> > > URB with too many fragments could either be rejected, sent in sections,
> > > or partially linearised (and probably still sent in sections).
> > 
> > Rejecting an URB is not feasible.  Splitting it up into multiple TDs is
> > not acceptable, as explained above.  Sending it in sections (i.e.,
> > queueing only some of the TRBs at any time) would work, provided you
> > got at least two interrupts every time the queue wrapped around (which
> > suggests you might want at least two ring segments).
> 
> Rejecting badly fragmented URB is almost certainly ok. You really don't
> want the hardware overhead of processing a TRB every few bytes.
> This would be especially bad on iommu systems.

I disagree.  Sure, it would be bad.  But if you can handle it, you 
should.

> Before the ring expansion code was added there was an implicit
> limit of (probably) 125 fragments for a URB. Exceeding this limit
> wasn't the reason for adding the ring expansion code.
> 
> And, as I've pointed out, both bulk and isoc URB can be split unless
> they are using too many fragments for a short piece of data.
> 
> The current code refuses to write into a TRB segment until it is
> empty - I think that restriction is only there so that it can
> add another segment when the space runs out.

That's right.  The idea was my suggestion.

Alan Stern
