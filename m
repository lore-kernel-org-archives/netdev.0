From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Wed, 13 Nov 2013 09:45:06 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B740C@saturn3.aculab.com>
References: <20131112171438.GA4925@xanatos> <Pine.LNX.4.44L0.1311121401510.1200-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: "Alan Stern" <stern@rowland.harvard.edu>,
	"Sarah Sharp" <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35382 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1758185Ab3KMJph convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 04:45:37 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07504-07 for <netdev@vger.kernel.org>;
 Wed, 13 Nov 2013 09:45:33 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.44L0.1311121401510.1200-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > that doesn't matter; we don't get an interrupt when a ring segment is
> > crossed.  Instead we set the interrupt-on-completion flag on the last
> > TRB of the TD, not on any earlier fragment or link TRB.
> 
> That's because you don't worry about handling URBs which require too
> many TRBs (i.e., more than are available).  You just add more ring
> segments.  Instead, you could re-use segments on the fly.
> 
> For example, suppose you have only two ring segments and you get an URB
> which requires enough TRBs to fill up four segments.  You could fill in
> the first two segments worth, and get an interrupt when the controller
> traverses the Link TRB between them.  At that point you store the third
> set of TRBs in the first segment, which is now vacant.  Similarly, when
> the second Link TRB is traversed, you fill in the fourth set of TRBs.

That isn't going to work.
It might work for very long TD, but for very fragmented ones the interrupt
rate would be stupid. In any case you'd definitely need enough ring
segments for the TRB that describe a single 'max packet size' block.

> > Finally, it's interesting to note that the USB mass storage driver is
> > using scatter gather lists just fine without the driver following the TD
> > fragment rules.  Or at least no one has reported any issues.  I wonder
> > why it works?
> 
> I'd guess this is because the hardware is actually a lot more flexible
> than the "No Link TRBs in the middle of a TD fragment" rule.

With the hardware I have (Intel i7 Sandy bridge) Link TRB cannot
be placed at arbitrary boundaries.
I don't know whether the actual restriction is only to packet boundaries.
I don't have a USB3 monitor and it would also require a more contrived
test than I've been doing.

> The whole idea of TD fragments makes no sense to begin with.  What
> point is there in grouping packets into MaxBurst-sized collections?

It probably saved a few logic gates somewhere, either that or it is
a bug in some hardware implementation that got documented in the spec
instead of being fixed :-)

	David
