From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Tue, 12 Nov 2013 09:43:52 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73FF@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73FE@saturn3.aculab.com> <Pine.LNX.4.44L0.1311111525480.17105-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Sarah Sharp" <sarah.a.sharp@linux.intel.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: "Alan Stern" <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51903 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752363Ab3KLJrV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 04:47:21 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17568-05 for <netdev@vger.kernel.org>;
 Tue, 12 Nov 2013 09:47:16 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.44L0.1311111525480.17105-100000@netrider.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You're right.  I do wish the spec had been written more clearly.

I've read a lot of hardware specs in my time ...

> > Reading it all again makes me think that a LINK trb is only
> > allowed on the burst boundary (which might be 16k bytes).
> > The only real way to implement that is to ensure that TD never
> > contain LINK TRB.
> 
> That's one way to do it.  Or you could allow a Link TRB at an
> intermediate MBP boundary.

If all the fragments are larger than the MBP (assume 16k) then
that would be relatively easy. However that is very dependant
on the source of the data. It might be true for disk data, but
is unlikely to be true for ethernet data.

For bulk data the link TRB can be forced at a packet boundary
by splitting the TD up - the receiving end won't know the difference.

> It comes down to a question of how often you want the controller to
> issue an interrupt.  If a ring segment is 4 KB (one page), then it can
> hold 256 TRBs.  With scatter-gather transfers, each SG element
> typically refers to something like a 2-page buffer (depends on how
> fragmented the memory is).  Therefore a ring segment will describe
> somewhere around 512 pages of data, i.e., something like 2 MB.  Since
> SuperSpeed is 500 MB/s, you'd end up getting in the vicinity of 250
> interrupts every second just because of ring segment crossings.

250 interrupts/sec is noise. Send/receive 13000 ethernet packets/sec
and then look at the interrupt rate!

There is no necessity for taking an interrupt from every link segment.
OTOH an interrupt is requested for every bulk TD.
I'm sending ethernet data (with TSO) and each TD is just under 64k
mostly made up of 3 or 4 fragments.
The receive side is interrupting for every receive packet.

> Using larger ring segments would help.

The current ring segments contain 64 entries, a strange choice
since they are created with 2 segments.
(The ring expansion code soon doubles that for my ethernet traffic.)

I would change the code to use a single segment (for coding simplicity)
and queue bulk URB when there isn't enough ring space.
URB with too many fragments could either be rejected, sent in sections,
or partially linearised (and probably still sent in sections).

	David
