From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Wed, 21 Mar 2012 23:02:18 +0800
Message-ID: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
References: <CACVXFVPK9vj8oqjr1SFr2MgoQn-2XoDqyb95oW+7LCHT7020Ow@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211031490.1369-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1203211031490.1369-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 21, 2012 at 10:35 PM, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org=
> wrote:
> On Wed, 21 Mar 2012, Ming Lei wrote:
>
>> Looks it is a general issue about usb_hcd_unlink_urb.
>>
>> Alan, how about increasing URB reference count before calling unlink=
1
>> inside usb_hcd_unlink_urb to fix this kind of problem?
>
> No, that won't fix the problem. =A0The URB could complete and be
> deallocated even before usb_hcd_unlink_urb() is called, so nothing th=
at
> function can do will prevent the error.

IMO, driver should not call usb_hcd_unlink_urb after urb is freed from
the driver,
but this problem is that URB may be freed during usb_hcd_unlink_urb.

In fact, it is allowed that usb_free_urb is called inside .complete han=
dler,
at least as said in Documentation/URB.txt:

         "You may free an urb that you've submitted,..."

So looks reasonable to increase the URB reference count before calling
unlink1(), just like that done inside usb_hcd_flush_endpoint().  And I
think it is a general solution for avoiding this kind of problem.

>
> It is the caller's responsibility to make sure that the URB does not
> get freed before usb_unlink_urb() or usb_kill_urb() returns. =A0We
> probably should mention this in the kerneldoc...

If so, looks it is a bit contrary with Documentation/URB.txt, also
this may add extra constraint(maybe unnecessary) to the driver.


Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
