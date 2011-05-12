From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: future developments of usbnet
Date: Thu, 12 May 2011 10:37:28 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1105121025360.1917-100000@iolanthe.rowland.org>
References: <201105120959.28473.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	<tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201105120959.28473.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 12 May 2011, Oliver Neukum wrote:

> Am Mittwoch, 11. Mai 2011, 19:47:27 schrieb David Miller:
> 
> > Basically once you take you interrupt, and disable device interrupts,
> > the generic net device layer calls your ->poll() routing with a "weight"
> > You should not process more RX packets than this value.
> > 
> > If you have less than "weight" work to do, you should do a napi_complete(),
> > which takes you out of the polling group, and re-enable device interrupts.
> > 
> > So the idea is that you keep getting ->poll()'d until there is no more
> > RX work to do.
> > 
> > The "weight" argument implements fairness amongst competing, actively
> > polling, devices on the same CPU.
> > 
> 
> Thank you, this is very informative. Our problem here is that USB doesn't work
> sanely without interrupts. We can stop IO regarding rx, but we cannot stop
> interrupts if we want to do rx.

The idea behind NAPI can be adapted to the usbnet context.  The basic
idea is that the driver is allowed to accept only a limited number of 
packets, driven by polling from the NAPI core.

Therefore usbnet's poll routine should take the "weight" argument as an
indication of how many outstanding rx URBs are allowed.  Each time the
poll routine is called, it should check to see if any rx URBs have
completed since the previous poll.  If not then there is no network
traffic, so usbnet can take itself out of the poll loop.  Otherwise,
the number of outstanding URBs should be adjusted (by unlinking some or
submitting more -- subject to some fixed maximum limit) to match the
new "weight".

Does that make sense?

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
