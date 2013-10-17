From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: transmit lockup using smsc95xx ethernet on usb3
Date: Thu, 17 Oct 2013 14:07:35 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1310171402200.2436-100000@iolanthe.rowland.org>
References: <20131017174329.GB6256@xanatos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Xenia Ragiadakou <burzalodowa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131017174329.GB6256@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Oct 2013, Sarah Sharp wrote:

> > Given the difficulty (or rather the infrequency) of reproducing the
> > problem I'd like to sort out the failing code path before changing
> > kernels so that I can then verify that a more recent kernel fixes it.
> 
> The problem is that -ESHUTDOWN usually means there's a driver or host
> controller issue.  Numerous bug fixes have gone in since 3.4 to avoid
> such host controller issues.  It would be a waste of time for me to
> attempt debug your issue, only to discover it had been fixed in a more
> recent kernel.  So I would really rather you test on a stable kernel,
> see if the issue still occurs, and then we can work from a known good
> base to figure out where the problem is.

-ESHUTDOWN really indicates either that the system believes the device
has been disconnected from the USB bus or that the host controller 
itself has stopped working.

> > To clarify the fail trace below is from an xhci controller, but
> > I'm pretty sure we've seen a tx lockup when using ohci.
> 
> Then it might not be an xHCI host specific issue.

Undoubtedly not.

> > The usbmon trace when the tx locks up starts with:
> > 
> > > > Two Bo 'fail -71', 6 succeed, one fails -32 the rest fail -104.
> > > >    done:9871:6913:60 ffff88020ea16a80 293818155 C Bo:3:003:2 -71 EPROTO 512 > 
> > > >    done:9872:6927:59 ffff88020ea16f00 293818235 C Bo:3:003:2 -71 EPROTO 0

Those -71 errors indicate a low-level problem.  It generally means that
the device has stopped sending packets.  Perhaps its firmware has
crashed, or perhaps it has disconnected itself electrically from the 
bus.

> > Last successful ethernet transmit
> > ffff88020c4870c0 701760986 C Bo:3:018:2 0 1090 >
> > ffff88020c4870c0 701760992 S Bo:3:018:2 -115 1090
> >                   = 3a340000 3a440000 22003200 00224d98
> >                     d8460002 1f0057d7 08004500 042879ca
> > Interrupt - I think from the root hub.
> > ffff88020c8570c0 701761038 C Ii:3:001:1 0:2048 1 = 02
> > ffff88020c8570c0 701761042 S Ii:3:001:1 -115:2048 4 <
> > ffff88020ea16840 701761046 C Ii:3:018:3 -71:1 0  EPROTO
> > ffff88020ea16840 701761047 S Ii:3:018:3 -115:1 16 <
> > ffff88020c53c480 701761051 C Bi:3:018:1 -71 0
> > ffff88020c487180 701761054 C Bo:3:018:2 -71 1024 >
> > ffff880210570240 701761063 S Ci:3:001:0 s a3 00 0000 0001 0004 4 <
> > ffff880210570240 701761071 C Ci:3:001:0 0 4 = 00010100

These last two lines show the host controller telling the system that
the device has disconnected.  Once that happens, any future
communication with the device is hopeless.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
