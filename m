From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload
 burst.
Date: Tue, 19 Nov 2013 14:58:22 -0800
Message-ID: <20131119225822.GA9611@xanatos>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B740B@saturn3.aculab.com>
 <Pine.LNX.4.44L0.1311131113090.1424-100000@iolanthe.rowland.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B741A@saturn3.aculab.com>
 <1384565904.29151.66.camel@bwh-desktop.uk.level5networks.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7428@saturn3.aculab.com>
 <1384787003.10077.34.camel@deadeye.wl.decadent.org.uk>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7430@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38913 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753291Ab3KSW6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 17:58:23 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7430@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 18, 2013 at 03:41:00PM -0000, David Laight wrote:
> 
> 
> > -----Original Message-----
> > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> > Sent: 18 November 2013 15:03
> > To: David Laight
> > Cc: Alan Stern; Sarah Sharp; netdev@vger.kernel.org; linux-usb@vger.kernel.org
> > Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
> > 
> > On Mon, 2013-11-18 at 09:48 +0000, David Laight wrote:
> > > > > But the minimum fragment size is (probably) 4k.
> > > > > For the network stack an OUT transfer might have a lot (and I mean lots)
> > > > > of fragments (there may be constraints, and linearising the skb is a option).
> > > > [...]
> > > >
> > > > The maximum number of fragments in the skb is going to be 17 (including
> > > > the 'head' area).  (I'm ignoring NETIF_F_FRAGLIST which is not normally
> > > > supported by physical device drivers.)
> > > >
> > > > I don't know how many fragments that can end up as, at the USB level.
> > >
> > > If you assume that every fragment crosses a 64k boundary that would be 34.
> > > OTOH I've not seen a fragment of a 64k TSO send crossing a 32k
> > > boundary, and I think the 'head' area is constrained to be part of
> > > a single (4k or larger) page.
> > 
> > I don't know that it's possible at the moment, but I wouldn't recommend
> > relying on that.
> 
> The xhci (USB3) hardware supports SG, but a non-obvious alignment restriction
> applies at the end of a ring segment. In effect this means that the number of
> fragments mustn't exceed the size of the ring segment.
> It would make the xchi driver simpler if excessively fragmented requests
> could just be bounced.
> Since ring entries are 16 bytes there isn't much reason to not use a 4k
> 'page' for a ring and have (almost) 256 ring slots.
> (The code currently uses multiple ring segments with 63 usable slots.)
> 
> Looks like skb are constrained enough that a sensible limit can be applied.
> 
> The other likely generator of fragmented requests is the mass storage code.
> Most likely for dd(1) with a large block size.

The xHCI driver can limit the number of sg-list entries through
hcd->self.sg_tablesize.  It's currently set to ~0, which is "however
many entries you want.  You could set that to the number of TRBs in a
segment (minus one for the link TRB).

The usb-storage and uas drivers currently use sg_tablesize.  Could the
network stack be taught to use sg_tablesize as well?

(Also, usb-storage aligns the block sizes to 512K, which explains why
we've never had an issue with TD fragments with that driver.)

Sarah Sharp
