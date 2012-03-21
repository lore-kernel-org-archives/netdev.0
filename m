From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Thu, 22 Mar 2012 00:22:59 +0800
Message-ID: <CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1203211201560.1369-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2012 at 12:12 AM, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org=
> wrote:
> On Wed, 21 Mar 2012, Ming Lei wrote:
>
>> On Wed, Mar 21, 2012 at 10:35 PM, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLg@public.gmane.org=
edu> wrote:
>> > On Wed, 21 Mar 2012, Ming Lei wrote:
>> >
>> >> Looks it is a general issue about usb_hcd_unlink_urb.
>> >>
>> >> Alan, how about increasing URB reference count before calling unl=
ink1
>> >> inside usb_hcd_unlink_urb to fix this kind of problem?
>> >
>> > No, that won't fix the problem. =A0The URB could complete and be
>> > deallocated even before usb_hcd_unlink_urb() is called, so nothing=
 that
>> > function can do will prevent the error.
>>
>> IMO, driver should not call usb_hcd_unlink_urb after urb is freed fr=
om
>> the driver,
>> but this problem is that URB may be freed during usb_hcd_unlink_urb.
>
> Drivers don't call usb_hcd_unlink_urb; they call usb_unlink_urb. =A0T=
his
> sort of thing can happen:
>
> =A0 =A0 =A0 =A0Driver =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Interrupt ha=
ndler
> =A0 =A0 =A0 =A0------ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0------------=
-----
> =A0 =A0 =A0 =A0call usb_unlink_urb
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0URB co=
mpletion interrupt occurs
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 call =
usb_hcd_giveback_urb
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0co=
mpletion routine calls usb_free_urb
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0UR=
B is deallocated
> =A0 =A0 =A0 =A0 call usb_hcd_unlink_urb
> =A0 =A0 =A0 =A0 =A0try to increment URB's refcount
> =A0 =A0 =A0 =A0 =A0oops because URB is gone

Got it, thanks for your detailed explanation.

>> In fact, it is allowed that usb_free_urb is called inside .complete =
handler,
>> at least as said in Documentation/URB.txt:
>>
>> =A0 =A0 =A0 =A0 =A0"You may free an urb that you've submitted,..."
>>
>> So looks reasonable to increase the URB reference count before calli=
ng
>> unlink1(), just like that done inside usb_hcd_flush_endpoint(). =A0A=
nd I
>> think it is a general solution for avoiding this kind of problem.
>
> It will not solve the problem illustrated above. =A0The driver must a=
void
> freeing the URB before usb_unlink_urb returns. =A0In this case,
> increasing the refcount around the unlink call would work.

Yes, it is the right fix.

>> > It is the caller's responsibility to make sure that the URB does n=
ot
>> > get freed before usb_unlink_urb() or usb_kill_urb() returns. =A0We
>> > probably should mention this in the kerneldoc...
>>
>> If so, looks it is a bit contrary with Documentation/URB.txt, also
>> this may add extra constraint(maybe unnecessary) to the driver.
>
> It's not contradictory. =A0You may indeed free an URB that you have
> submitted, so long as you don't free it while usb_unlink_urb (or
> related routines like usb_kill_urb) is running.

Maybe it should be documented.

So looks the correct fix should be below:

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 4b8b52c..e36a821 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -588,7 +588,7 @@ static int unlink_urbs (struct usbnet *dev, struct
sk_buff_head *q)

 		entry =3D (struct skb_data *) skb->cb;
 		urb =3D entry->urb;
-
+		usb_get_urb(urb);
 		spin_unlock_irqrestore(&q->lock, flags);
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
@@ -597,6 +597,7 @@ static int unlink_urbs (struct usbnet *dev, struct
sk_buff_head *q)
 			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
 			count++;
+		usb_put_urb(urb);
 		spin_lock_irqsave(&q->lock, flags);
 	}
 	spin_unlock_irqrestore (&q->lock, flags);
@@ -1028,7 +1029,6 @@ static void tx_complete (struct urb *urb)
 	}

 	usb_autopm_put_interface_async(dev->intf);
-	urb->dev =3D NULL;
 	entry->state =3D tx_done;
 	defer_bh(dev, skb, &dev->txq);
 }



Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
