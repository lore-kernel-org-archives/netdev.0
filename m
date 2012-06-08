From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix
 endless "XactErr" error
Date: Fri, 8 Jun 2012 23:54:57 +0800
Message-ID: <CA+v9cxZkWSeT_Qs+amOxRoW9Fmpgp6HY3Uj0dBGTOAqrbkQ5Hg@mail.gmail.com>
References: <CA+v9cxYHq4gcy11SDmsuHUhTSdLJM-G0sugYnOjSthbYWA+1Yg@mail.gmail.com>
	<CACVXFVMwhoYyJHAsK0xF0poZxoZv8ENHhquPVAiGnsow5-FH8Q@mail.gmail.com>
	<CA+v9cxYvvRVWAUHX=b-P022pFbG1M7S=SZtOo2zfJnhAx5_+sQ@mail.gmail.com>
	<CACVXFVPj-4J2_UuOQ9NCW7wV_SLG50a-pEYqhd7K9sXuGmDmoQ@mail.gmail.com>
	<CA+v9cxbogzS7sVChqkRMgDUcs=aJgNDRH8ydoQ-_htfS2t52gQ@mail.gmail.com>
	<CACVXFVN0Y0p+WXUhJco6EKCdjx6Wg-guJLe79Bmj2K9KQGKToA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:42775 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932605Ab2FHPzC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 11:55:02 -0400
In-Reply-To: <CACVXFVN0Y0p+WXUhJco6EKCdjx6Wg-guJLe79Bmj2K9KQGKToA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 8, 2012 at 9:56 PM, Ming Lei <tom.leiming@gmail.com> wrote:
> On Fri, Jun 8, 2012 at 2:24 PM, Huajun Li <huajun.li.lee@gmail.com> w=
rote:
>> On Fri, Jun 8, 2012 at 1:22 PM, Ming Lei <tom.leiming@gmail.com> wro=
te:
>>> If so, looks mistaken value is returned from the host controller dr=
iver,
>>> but not sure if your device is buggy. What is your host controller?
>>>
>> Nothing related to HC.
>> I tried to find out the endpoint state, but found it was halt. I thi=
nk
>> this is the root cause.
>
> I mean that your HCD should not return -EPROTO if only the interrupt
> endpoint's HALT feature is set, and it should return -EPIPE.
>
>>
>>> Also suppose your device is buggy, and the correct solution should
>>> be addding quirk for the driver to clear halt before the 1st submit=
 status
>>> urb.
>>>
>> I ever worked out a patch just as you said and it could work.
>> However, if this can be fixed by common framework just like usbnet.c=
,
>> and there is no sideeffect, then why not.
>
> There is side effect, at least sending out the command of
> clear feature(HALT) is mistaken in logic if =A0-EPROTO is returned fo=
r
> the endpoint.
>
>>>
>>> I just have tried to switch configuration by sysfs interface on the=
 g_multi
>>> and don't trigger the error.
>>>
>> The driver is common one, but not just for a specific device.
>
> The problem is that your device is a specific buggy device, and the i=
nterrupt
> endpoint shouldn't be set HALT after SetConfiguration(), see 9.4.5 of=
 USB 2.0
> spec.
>
> So it is reasonable to add a quirk to fix the problem for the device,=
 that has
> document benefits, also considered that the device is a very specific=
 case.
>

If add a quirk to fix this issue, it need copy usbnet_cdc_bind() and
write a new xxx_cdc_bind() just to let it clear the halt. What's your
proposal?

BTW, the device can work well if I modprobe  cdc_ether driver after
changed the configuration.

>>
>>>>
>>>>> Is the "XactErr" msg printed just after switching to cdc_ether in=
terface
>>>>> by changing configuration?
>>>>>
>>>>
>>>> Yes, just as I mentioned in my original email.
>>>> And it did not work even I removed the driver and re-installed it.
>>>>
>>>>>> Maybe this is a common issue, so fix it by activating the endpoi=
nt
>>>>>> once the error occurs.
>>>>>>
>>>>>> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
>>>>>> ---
>>>>>> =A0drivers/net/usb/usbnet.c =A0 | =A0 33 +++++++++++++++++++++++=
++++++++++
>>>>>> =A0include/linux/usb/usbnet.h | =A0 15 ++++++++-------
>>>>>> =A02 files changed, 41 insertions(+), 7 deletions(-)
>>>>>>
>>>>>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>>>>>> index 9f58330..f13922b 100644
>>>>>> --- a/drivers/net/usb/usbnet.c
>>>>>> +++ b/drivers/net/usb/usbnet.c
>>>>>> @@ -537,6 +537,11 @@ static void intr_complete (struct urb *urb)
>>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"intr shutdow=
n, code %d\n", status);
>>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>>>>>>
>>>>>> + =A0 =A0 =A0 case -EPIPE:
>>>>>> + =A0 =A0 =A0 case -EPROTO:
>>>>>
>>>>> It is good to handle EPIPE error here, but looks it is no sense t=
o
>>>>> clear halt for
>>>>> bus transfer failure. At least, no clear halt is done for returni=
ng -EPROTO from
>>>>> rx/tx transfer currently.
>>>>
>>>> Just as I said above, there is different issue can cause -EPROTO, =
at
>>>> least, for my case it is because the interrupt endpoint is not act=
ive.
>>>> If the error occurs, the driver need try to fix it instead of just
>>>> printing an error msg.
>>>
>>> One problem in your patch is that if the =A0-EPROTO is caused by ba=
d cable
>>> or interference, clean halt may not be sent to device successfully,=
 and will
>>> cause -EPROTO further.
>>
>> What's your opinion to handle "-EPROTO" error in usbnet.c?
>> Please check usbnet.c again, when "-EPROTO" occurs, it just pints
>> error msg and re-submit the interrupt URB, and then causes endless
>> "EactErr" error msg.
>
> Yes, it should be bug, but clear feature(HALT) is not correct for the=
 situation.
>
>>
>> At least, this patch lets the driver try to fix the error before
>> resubmit the URB.
>>
>>>
>>>>
>>>>>
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 usbnet_defer_kevent(dev, EVENT_STS=
_HALT);
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>>>>> +
>>>>>> =A0 =A0 =A0 =A0/* NOTE: =A0not throttling like RX/TX, since this=
 endpoint
>>>>>> =A0 =A0 =A0 =A0 * already polls infrequently
>>>>>> =A0 =A0 =A0 =A0 */
>>>>>> @@ -967,6 +972,34 @@ fail_halt:
>>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>>>>> =A0 =A0 =A0 =A0}
>>>>>>
>>>>>> + =A0 =A0 =A0 if (test_bit(EVENT_STS_HALT, &dev->flags)) {
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned pipe;
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct usb_endpoint_descriptor *de=
sc;
>>>>>> +
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 desc =3D &dev->status->desc;
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pipe =3D usb_rcvintpipe(dev->udev,
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 desc->bEndpointAdd=
ress & USB_ENDPOINT_NUMBER_MASK);
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D usb_autopm_get_interfac=
e(dev->intf);
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status < 0)
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail_sts;
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D usb_clear_halt(dev->ude=
v, pipe);
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_autopm_put_interface(dev->intf=
);
>>>>>> +
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status < 0 && status !=3D -EPI=
PE && status !=3D -ESHUTDOWN) {
>>>>>> +fail_sts:
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev->ne=
t,
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "c=
an't clear intr halt, status %d\n", status);
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(EVENT_ST=
S_HALT, &dev->flags);
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(dev->interr=
upt->transfer_buffer, 0,
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 de=
v->interrupt->transfer_buffer_length);
>>>>>
>>>>> The above is not necessary.
>>>>
>>>> Ming, do you mean the above one line, or others ?
>>>
>>> Yes, it is the above line.
>>>
>>
>> Then not sure whether the buffer will be tainted without this line.
>
> It isn't necessary, =A0the buffer should include valid data if URB->s=
tatus
> returns zero.
>

That's great, thanks.

>
> Thanks,
> --
> Ming Lei
