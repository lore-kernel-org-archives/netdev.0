From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Fri, 8 Nov 2013 17:39:22 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73F4@saturn3.aculab.com>
References: <20131108001838.GB11529@xanatos> <Pine.LNX.4.44L0.1311081119510.1162-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Alan Stern" <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	"Sarah Sharp" <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.44L0.1311081119510.1162-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Alan Stern [mailto:stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org]
> Sent: 08 November 2013 16:46
> To: Sarah Sharp
> Cc: David Laight; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
> 
> On Thu, 7 Nov 2013, Sarah Sharp wrote:
> 
> > On Thu, Nov 07, 2013 at 05:20:49PM -0000, David Laight wrote:
> > >
> > > Section 4.11.7.1 of rev 1.0 of the xhci specification states that a link TRB
> > > can only occur at a boundary between underlying USB frames (512 bytes for 480M).
> >
> > Which version of the spec are you looking at?  I'm looking at the
> > updated version from 08/2012 and I don't see any such requirement.
> >
> > I do see that section says "A TD Fragment shall not span Transfer Ring
> > Segments" where a TD fragment is defined as exact multiples of Max Burst
> > Size * Max Packet Size bytes for the endpoint.  Is that what you mean
> > about USB frames?
> 
> ...
> 
> > The driver would also have to make sure that TD fragments didn't have
> > link TRBs in them.  That's an issue, since the spec decidedly unclear
> > about what exactly comprises a TD fragment.  Is the xHC host greedy, and
> > will lump all multiples into one TD fragment?  Or will it assume the TD
> > fragment has ended once it consumes one multiple of Max Burst Size * Max
> > Packet Size bytes?
> >
> > This ambiguity means it's basically impossible to figure out whether a
> > TD with a link TRB in the middle is constructed properly.  The xHCI spec
> > architect didn't have a good solution to this problem, so I punted and
> > never implemented TD fragments.  If this is really an issue, it's going
> > to be pretty complex to solve.
> 
> This is something I wanted to ask you about also.
> 
> The whole idea of TD fragments is exceedingly cloudy.  The definition
> doesn't make sense, and the spec doesn't say what the actual hardware
> restrictions are, i.e., what is the underlying reality that the TD
> fragment concept wants to express.

I think that a TD fragment boundary exists whenever a TRB/dma boundary
lines up with the packet boundary.

> Even if you do your best to ignore the whole idea, there still appear
> to be certain restrictions you need to obey.  In addition to the
> question of where Link TRBs are allowed, you also have to worry about
> TDs whose size isn't a multiple of the Max Burst Payload (MBP) size =
> MaxBurstSize * MaxPacketSize.

I'm not certain what MaxBurstSize and MaxPacketSize are, but the important
number is the MBP. I'm fairly sure that is the value returned by
GET_MAX_PACKET() - 1024 for USB3 bulk endpoints.

> According to my version of the spec (Rev 1.0, dated 5/21/2010), if a TD
> is larger than the MBP and its length isn't a multiple of the MBP, then
> the last MBP boundary in the TD must also be a TRB boundary.  This
> follows from two statements in section 4.11.7.1:
> 
> 	If the TD Transfer Size is an even multiple of the MBP then all
> 	TD Fragments shall define exact multiples of MBP data bytes.
> 	If not, then only the last TD Fragment shall define less than
> 	MBP data (or the Residue) bytes.

No, that doesn't stop there being only 1 TD fragment.
(I think it means exact multiple of the MBP.)

> So if a TD is longer than MBP then it must contain at least two TD
> fragments, and the last fragment must consist of the last Residue
> bytes (i.e., the bytes beyond the last MBP boundary).
> 
> 	Each TD Fragment is comprised of one or more TRBs.
> 
> Hence the last MBP boundary in the TD, which marks the beginning of the
> last TD fragment, must also be a TRB boundary.
> 
> I have no idea whether violating this restriction will cause trouble
> for real hardware.

Violating the one for LINK TRBs is definitely a problem.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
