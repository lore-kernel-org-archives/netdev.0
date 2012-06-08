From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix
 endless "XactErr" error
Date: Fri, 8 Jun 2012 13:22:30 +0800
Message-ID: <CACVXFVPj-4J2_UuOQ9NCW7wV_SLG50a-pEYqhd7K9sXuGmDmoQ@mail.gmail.com>
References: <CA+v9cxYHq4gcy11SDmsuHUhTSdLJM-G0sugYnOjSthbYWA+1Yg@mail.gmail.com>
	<CACVXFVMwhoYyJHAsK0xF0poZxoZv8ENHhquPVAiGnsow5-FH8Q@mail.gmail.com>
	<CA+v9cxYvvRVWAUHX=b-P022pFbG1M7S=SZtOo2zfJnhAx5_+sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Huajun Li <huajun.li.lee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:55149 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761452Ab2FHFWa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 01:22:30 -0400
In-Reply-To: <CA+v9cxYvvRVWAUHX=b-P022pFbG1M7S=SZtOo2zfJnhAx5_+sQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 8, 2012 at 1:04 PM, Huajun Li <huajun.li.lee@gmail.com> wro=
te:
> Ming, thanks for your comments.

Welcome, :-)

>
> On Fri, Jun 8, 2012 at 11:29 AM, Ming Lei <tom.leiming@gmail.com> wro=
te:
>> On Tue, Jun 5, 2012 at 10:12 PM, Huajun Li <huajun.li.lee@gmail.com>=
 wrote:
>>> There prints endless "XactErr" error msg once switch my device to t=
he
>>
>> The "XactErr" error msg means that there are some transfer error in =
the bus,
>> such as timeout, bad CRC, wrong PID, etc. Generally, -EPROTO is retu=
rned
>> to driver if this kind of error happened.
>>
> Yes, you pointed out the why there printed the error.
> However, how can this error(-EPROTO) happen? Actually, maybe it is
> caused by malfunction device, bad usb cable, or other issues. In my
> case, it is because the endpoint halts.

If so, looks mistaken value is returned from the host controller driver=
,
but not sure if your device is buggy. What is your host controller?

Also suppose your device is buggy, and the correct solution should
be addding quirk for the driver to clear halt before the 1st submit sta=
tus
urb.

>
>>> configuration
>>> =A0which needs cdc_ether driver, the root cause is the interrupt en=
dpoint halts.
>>
>> How do you switch your configuration? by writing to
>> /sys/.../bConfigurationValue?
>>
>
> Maybe.
> I were using a third party application to switch the configurations,
> so I think it should use this way to do it unless there is other
> approach.

I just have tried to switch configuration by sysfs interface on the g_m=
ulti
and don't trigger the error.

>
>> Is the "XactErr" msg printed just after switching to cdc_ether inter=
face
>> by changing configuration?
>>
>
> Yes, just as I mentioned in my original email.
> And it did not work even I removed the driver and re-installed it.
>
>>> Maybe this is a common issue, so fix it by activating the endpoint
>>> once the error occurs.
>>>
>>> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
>>> ---
>>> =A0drivers/net/usb/usbnet.c =A0 | =A0 33 ++++++++++++++++++++++++++=
+++++++
>>> =A0include/linux/usb/usbnet.h | =A0 15 ++++++++-------
>>> =A02 files changed, 41 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>>> index 9f58330..f13922b 100644
>>> --- a/drivers/net/usb/usbnet.c
>>> +++ b/drivers/net/usb/usbnet.c
>>> @@ -537,6 +537,11 @@ static void intr_complete (struct urb *urb)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"intr shutdown, =
code %d\n", status);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>>>
>>> + =A0 =A0 =A0 case -EPIPE:
>>> + =A0 =A0 =A0 case -EPROTO:
>>
>> It is good to handle EPIPE error here, but looks it is no sense to
>> clear halt for
>> bus transfer failure. At least, no clear halt is done for returning =
-EPROTO from
>> rx/tx transfer currently.
>
> Just as I said above, there is different issue can cause -EPROTO, at
> least, for my case it is because the interrupt endpoint is not active=
=2E
> If the error occurs, the driver need try to fix it instead of just
> printing an error msg.

One problem in your patch is that if the  -EPROTO is caused by bad cabl=
e
or interference, clean halt may not be sent to device successfully, and=
 will
cause -EPROTO further.

>
>>
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 usbnet_defer_kevent(dev, EVENT_STS_HA=
LT);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>> +
>>> =A0 =A0 =A0 =A0/* NOTE: =A0not throttling like RX/TX, since this en=
dpoint
>>> =A0 =A0 =A0 =A0 * already polls infrequently
>>> =A0 =A0 =A0 =A0 */
>>> @@ -967,6 +972,34 @@ fail_halt:
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>> =A0 =A0 =A0 =A0}
>>>
>>> + =A0 =A0 =A0 if (test_bit(EVENT_STS_HALT, &dev->flags)) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned pipe;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct usb_endpoint_descriptor *desc;
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 desc =3D &dev->status->desc;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pipe =3D usb_rcvintpipe(dev->udev,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 desc->bEndpointAddres=
s & USB_ENDPOINT_NUMBER_MASK);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D usb_autopm_get_interface(d=
ev->intf);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status < 0)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail_sts;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D usb_clear_halt(dev->udev, =
pipe);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_autopm_put_interface(dev->intf);
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status < 0 && status !=3D -EPIPE =
&& status !=3D -ESHUTDOWN) {
>>> +fail_sts:
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev->net,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "can'=
t clear intr halt, status %d\n", status);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(EVENT_STS_H=
ALT, &dev->flags);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(dev->interrupt=
->transfer_buffer, 0,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->=
interrupt->transfer_buffer_length);
>>
>> The above is not necessary.
>
> Ming, do you mean the above one line, or others ?

Yes, it is the above line.



Thanks,
--=20
Ming Lei
