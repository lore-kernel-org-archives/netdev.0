From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Wed, 21 Mar 2012 12:12:16 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Mar 2012, Ming Lei wrote:

> On Wed, Mar 21, 2012 at 10:35 PM, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLrNAH6kLmebB@public.gmane.org=
du> wrote:
> > On Wed, 21 Mar 2012, Ming Lei wrote:
> >
> >> Looks it is a general issue about usb_hcd_unlink_urb.
> >>
> >> Alan, how about increasing URB reference count before calling unli=
nk1
> >> inside usb_hcd_unlink_urb to fix this kind of problem?
> >
> > No, that won't fix the problem. =A0The URB could complete and be
> > deallocated even before usb_hcd_unlink_urb() is called, so nothing =
that
> > function can do will prevent the error.
>=20
> IMO, driver should not call usb_hcd_unlink_urb after urb is freed fro=
m
> the driver,
> but this problem is that URB may be freed during usb_hcd_unlink_urb.

Drivers don't call usb_hcd_unlink_urb; they call usb_unlink_urb.  This=20
sort of thing can happen:

	Driver			Interrupt handler
	------			-----------------
	call usb_unlink_urb
				URB completion interrupt occurs
				 call usb_hcd_giveback_urb
				  completion routine calls usb_free_urb
				  URB is deallocated
	 call usb_hcd_unlink_urb
	  try to increment URB's refcount
	  oops because URB is gone

> In fact, it is allowed that usb_free_urb is called inside .complete h=
andler,
> at least as said in Documentation/URB.txt:
>=20
>          "You may free an urb that you've submitted,..."
>=20
> So looks reasonable to increase the URB reference count before callin=
g
> unlink1(), just like that done inside usb_hcd_flush_endpoint().  And =
I
> think it is a general solution for avoiding this kind of problem.

It will not solve the problem illustrated above.  The driver must avoid
freeing the URB before usb_unlink_urb returns.  In this case,
increasing the refcount around the unlink call would work.

> > It is the caller's responsibility to make sure that the URB does no=
t
> > get freed before usb_unlink_urb() or usb_kill_urb() returns. =A0We
> > probably should mention this in the kerneldoc...
>=20
> If so, looks it is a bit contrary with Documentation/URB.txt, also
> this may add extra constraint(maybe unnecessary) to the driver.

It's not contradictory.  You may indeed free an URB that you have=20
submitted, so long as you don't free it while usb_unlink_urb (or=20
related routines like usb_kill_urb) is running.

The extra constraint on the driver is indeed necessary.  However the=20
driver can avoid complications by using anchors.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
