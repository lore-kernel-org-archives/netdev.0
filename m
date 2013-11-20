From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Wed, 20 Nov 2013 17:02:54 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B743B@saturn3.aculab.com>
References: <20131119225822.GA9611@xanatos> <Pine.LNX.4.44L0.1311192204140.6891-100000@netrider.rowland.org> <AE90C24D6B3A694183C094C60CF0A2F6026B7437@saturn3.aculab.com> <20131120160605.GB9611@xanatos>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Alan Stern" <stern@rowland.harvard.edu>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: "Sarah Sharp" <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40751 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754393Ab3KTREP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 12:04:15 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21978-06 for <netdev@vger.kernel.org>;
 Wed, 20 Nov 2013 17:04:12 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131120160605.GB9611@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Sarah Sharp [mailto:sarah.a.sharp@linux.intel.com]
> On Wed, Nov 20, 2013 at 09:36:11AM -0000, David Laight wrote:
> > > From: Alan Stern [mailto:stern@rowland.harvard.edu]
> > > On Tue, 19 Nov 2013, Sarah Sharp wrote:
> > >
> > > > The xHCI driver can limit the number of sg-list entries through
> > > > hcd->self.sg_tablesize.  It's currently set to ~0, which is "however
> > > > many entries you want.  You could set that to the number of TRBs in a
> > > > segment (minus one for the link TRB).
> > > >
...
> 
> Ok, so the networking layer should be fine.  However, with the current
> patch, if the mass storage driver sends down a scatter-gather list
> that's bigger than a ring segment, or needs to be split up so it doesn't
> cross 64K boundaries, then the URB submission will fail.  We don't want
> that to happen.
> 
> At the very least, we should limit hcd->self.sg_tablesize in
> drivers/usb/host/xhci.c to 63 (TRBS_PER_SEGMENT - 1).  But we could
> still potentially run into the 64K boundary issue in one or maybe all of
> those entries.  Would it be crazy to limit the number of entries to half
> that (31)?  It may impact performance, but it ensures that SCSI reads
> and writes don't randomly fail.  We can always increase the ring segment
> size in a later patch.

Unless there is a limit on the overall length of the transfer you'll always lose.
An aligned 4MB transfer in a contiguous memory buffer requires 64 TRBs.
So won't fit in a ring segment.

Although I'd guess that such transfers are unusual.
If you bet that crossing a 64k boundaries is unusual then 32 is probably
a sane limit.

Fragments over 16k can easily be split between ring segments - so a more
complex check could allow for that - but it won't be quick to write.

	David
