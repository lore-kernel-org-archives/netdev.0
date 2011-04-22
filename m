From: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCHv5] usbnet: Resubmit interrupt URB once if halted
Date: Fri, 22 Apr 2011 08:59:15 -0700
Message-ID: <BANLkTi=xBJuSFNPO3hkKu+N2tNspw=FZNQ@mail.gmail.com>
References: <20110422152451.3C5A9202ED@glenhelen.mtv.corp.google.com>
	<Pine.LNX.4.44L0.1104221129530.1877-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1104221129530.1877-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 22, 2011 at 8:47 AM, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>=
 wrote:
> On Tue, 19 Apr 2011, Paul Stewart wrote:
>
>> Resubmit interrupt URB if device is open. =A0Use a flag set in
>> usbnet_open() to determine this state. =A0Also kill and free
>> interrupt URB in usbnet_disconnect().
>
> Generally good, but a couple of things are questionable...
>
>> Signed-off-by: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>> ---
>> =A0drivers/net/usb/usbnet.c =A0 | =A0 14 ++++++++++++++
>> =A0include/linux/usb/usbnet.h | =A0 =A01 +
>> =A02 files changed, 15 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>> index 02d25c7..c7cf4af 100644
>> --- a/drivers/net/usb/usbnet.c
>> +++ b/drivers/net/usb/usbnet.c
>> @@ -643,6 +643,7 @@ static int usbnet_open (struct net_device *net)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>>
>> + =A0 =A0 set_bit(EVENT_DEV_OPEN, &dev->flags);
>> =A0 =A0 =A0 netif_start_queue (net);
>> =A0 =A0 =A0 if (netif_msg_ifup (dev)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 char =A0 =A0*framing;
>
> You forgot to clear this flag in usbnet_stop().

Actually, I didn't.  Note that flags are set to 0 in usbnet_stop().

>
> By the way, there is FLAG_AVOID_UNLINK_URBS defined in usbnet.h and
> used in usbnet_stop(). =A0Is it meant to apply to the interrupt URB a=
s
> well as the others?

I don't know who to ask about that.  Whether or not the flag is set,
in practice the interrupt URB still seems to be killed by some other
facility, so regardless of that request, they may lose anyway.

>> @@ -1105,6 +1106,11 @@ void usbnet_disconnect (struct usb_interface =
*intf)
>> =A0 =A0 =A0 if (dev->driver_info->unbind)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->driver_info->unbind (dev, intf);
>>
>> + =A0 =A0 if (dev->interrupt) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 usb_kill_urb(dev->interrupt);
>> + =A0 =A0 =A0 =A0 =A0 =A0 usb_free_urb(dev->interrupt);
>> + =A0 =A0 }
>> +
>
> usb_kill_urb and usb_free_urb include their own tests for urb =3D=3D =
NULL;
> you don't need to test it here or below.

Okay.

>
>> =A0 =A0 =A0 free_netdev(net);
>> =A0 =A0 =A0 usb_put_dev (xdev);
>> =A0}
>> @@ -1285,6 +1291,10 @@ int usbnet_suspend (struct usb_interface *int=
f, pm_message_t message)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* wake the device
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_device_attach (dev->net);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Stop interrupt URBs */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (dev->interrupt)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_kill_urb(dev->interrup=
t);
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 return 0;
>> =A0}
>
> There is a subtle question here: When is the best time to kill the
> interrupt URB? =A0Without knowing any of the details, I'd guess that =
the
> interrupt URB reports asynchronous events and the driver could run in=
to
> trouble if one of those events occurred while everything else was
> turned off. =A0This suggests that the interrupt URB should be killed =
as
> soon as possible rather than as late as possible. =A0But maybe it doe=
sn't
> matter; it all depends on the design of the driver.

I'm not sure I can answer this question either.  As it stands, nobody
was killing them before.  Just trying to make it better.

>
>> @@ -1297,6 +1307,10 @@ int usbnet_resume (struct usb_interface *intf=
)
>> =A0 =A0 =A0 if (!--dev->suspend_count)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 tasklet_schedule (&dev->bh);
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* resume interrupt URBs */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (dev->interrupt && test_bit(EVENT_DEV_O=
PEN, &dev->flags))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_submit_urb(dev->interr=
upt, GFP_NOIO);
>> +
>> =A0 =A0 =A0 return 0;
>> =A0}
>
> Alan Stern
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
