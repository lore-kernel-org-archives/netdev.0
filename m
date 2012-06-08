From: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix
 endless "XactErr" error
Date: Fri, 8 Jun 2012 13:04:51 +0800
Message-ID: <CA+v9cxYvvRVWAUHX=b-P022pFbG1M7S=SZtOo2zfJnhAx5_+sQ@mail.gmail.com>
References: <CA+v9cxYHq4gcy11SDmsuHUhTSdLJM-G0sugYnOjSthbYWA+1Yg@mail.gmail.com>
	<CACVXFVMwhoYyJHAsK0xF0poZxoZv8ENHhquPVAiGnsow5-FH8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVMwhoYyJHAsK0xF0poZxoZv8ENHhquPVAiGnsow5-FH8Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ming, thanks for your comments.

On Fri, Jun 8, 2012 at 11:29 AM, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote=
:
> On Tue, Jun 5, 2012 at 10:12 PM, Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> =
wrote:
>> There prints endless "XactErr" error msg once switch my device to th=
e
>
> The "XactErr" error msg means that there are some transfer error in t=
he bus,
> such as timeout, bad CRC, wrong PID, etc. Generally, -EPROTO is retur=
ned
> to driver if this kind of error happened.
>
Yes, you pointed out the why there printed the error.
However, how can this error(-EPROTO) happen? Actually, maybe it is
caused by malfunction device, bad usb cable, or other issues. In my
case, it is because the endpoint halts.

>> configuration
>> =A0which needs cdc_ether driver, the root cause is the interrupt end=
point halts.
>
> How do you switch your configuration? by writing to
> /sys/.../bConfigurationValue?
>

Maybe.
I were using a third party application to switch the configurations,
so I think it should use this way to do it unless there is other
approach.

> Is the "XactErr" msg printed just after switching to cdc_ether interf=
ace
> by changing configuration?
>

Yes, just as I mentioned in my original email.
And it did not work even I removed the driver and re-installed it.

>> Maybe this is a common issue, so fix it by activating the endpoint
>> once the error occurs.
>>
>> Signed-off-by: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>> =A0drivers/net/usb/usbnet.c =A0 | =A0 33 +++++++++++++++++++++++++++=
++++++
>> =A0include/linux/usb/usbnet.h | =A0 15 ++++++++-------
>> =A02 files changed, 41 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>> index 9f58330..f13922b 100644
>> --- a/drivers/net/usb/usbnet.c
>> +++ b/drivers/net/usb/usbnet.c
>> @@ -537,6 +537,11 @@ static void intr_complete (struct urb *urb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"intr shutdown, c=
ode %d\n", status);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>>
>> + =A0 =A0 =A0 case -EPIPE:
>> + =A0 =A0 =A0 case -EPROTO:
>
> It is good to handle EPIPE error here, but looks it is no sense to
> clear halt for
> bus transfer failure. At least, no clear halt is done for returning -=
EPROTO from
> rx/tx transfer currently.

Just as I said above, there is different issue can cause -EPROTO, at
least, for my case it is because the interrupt endpoint is not active.
If the error occurs, the driver need try to fix it instead of just
printing an error msg.

>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 usbnet_defer_kevent(dev, EVENT_STS_HAL=
T);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> =A0 =A0 =A0 =A0/* NOTE: =A0not throttling like RX/TX, since this end=
point
>> =A0 =A0 =A0 =A0 * already polls infrequently
>> =A0 =A0 =A0 =A0 */
>> @@ -967,6 +972,34 @@ fail_halt:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0}
>>
>> + =A0 =A0 =A0 if (test_bit(EVENT_STS_HALT, &dev->flags)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned pipe;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct usb_endpoint_descriptor *desc;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 desc =3D &dev->status->desc;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pipe =3D usb_rcvintpipe(dev->udev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 desc->bEndpointAddress=
 & USB_ENDPOINT_NUMBER_MASK);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D usb_autopm_get_interface(de=
v->intf);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status < 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail_sts;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D usb_clear_halt(dev->udev, p=
ipe);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_autopm_put_interface(dev->intf);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status < 0 && status !=3D -EPIPE &=
& status !=3D -ESHUTDOWN) {
>> +fail_sts:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev->net,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "can't=
 clear intr halt, status %d\n", status);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(EVENT_STS_HA=
LT, &dev->flags);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(dev->interrupt-=
>transfer_buffer, 0,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->i=
nterrupt->transfer_buffer_length);
>
> The above is not necessary.

Ming, do you mean the above one line, or others ?

>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D usb_submit_=
urb(dev->interrupt, GFP_KERNEL);
>
> Before submitting urb, usb_autopm_get_interface is required to wakeup=
 device.
>

Got it. Will check its context, thanks.

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status !=3D 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_=
err(dev, timer, dev->net,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "intr resubmit --> %d\n", status);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 }
>> +
>> =A0 =A0 =A0 =A0/* tasklet could resubmit itself forever if memory is=
 tight */
>> =A0 =A0 =A0 =A0if (test_bit (EVENT_RX_MEMORY, &dev->flags)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct urb =A0 =A0 =A0*urb =3D NULL;
>> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
>> index 76f4396..c0bcb61 100644
>> --- a/include/linux/usb/usbnet.h
>> +++ b/include/linux/usb/usbnet.h
>> @@ -62,13 +62,14 @@ struct usbnet {
>> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 flags;
>> =A0# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_TX_HALT =A0 =A00
>> =A0# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_RX_HALT =A0 =A01
>> -# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_RX_MEMORY =A02
>> -# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_STS_SPLIT =A03
>> -# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_LINK_RESET 4
>> -# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_RX_PAUSED =A05
>> -# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_WAKING 6
>> -# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_ASLEEP 7
>> -# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_OPEN =A0 8
>> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_STS_HALT =A0 2
>> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_RX_MEMORY =A03
>> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_STS_SPLIT =A04
>> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_LINK_RESET 5
>> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_RX_PAUSED =A06
>> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_WAKING 7
>> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_ASLEEP 8
>> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define EVENT_DEV_OPEN =A0 9
>> =A0};
>>
>> =A0static inline struct usb_driver *driver_of(struct usb_interface *=
intf)
>> --
>> 1.7.9.5
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-usb"=
 in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
> Thanks,
> --
> Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
