From: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch] usbnet: fix 100% CPU use on suspended device
Date: Mon, 26 Jul 2010 10:47:16 -0400
Message-ID: <AANLkTin_pduYCHVv_q4DSfSoQ7o4kFo43X8t1rXJ+7fa@mail.gmail.com>
References: <AANLkTik=b3ps_iMOC=mjDs2quLwBPUKbiqn0nKU3EbB1@mail.gmail.com>
	<Pine.LNX.4.44L0.1007261033090.1550-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1007261033090.1550-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 26, 2010 at 10:36 AM, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org=
> wrote:
> On Mon, 26 Jul 2010, Elly Jones wrote:
>
>> On Mon, Jul 26, 2010 at 12:57 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>=
 wrote:
>> > From: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> > Date: Wed, 21 Jul 2010 14:51:48 -0400
>> >
>> >> Subject: [patch] usbnet: fix 100% CPU use on suspended device
>> >> From: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> >>
>> >> This patch causes the usbnet module not to attempt to submit URBs=
 to the device
>> >> if the device is not ready to accept them. This fixes a misbehavi=
or trigged by
>> >> the Qualcomm Gobi driver (released under GPL through their Code A=
urora
>> >> initiative) which causes the usbnet core to consume 100% of CPU a=
ttempting and
>> >> failing to submit URBs. This patch is against Linus's 2.6 repo co=
mmit
>> >> a9f7f2e74ae0e6a801a2433dc8e9124d73da0cb4.
>> >> Signed-off-by: Elizabeth Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> >
>> > If the Qualcomm Gobi driver is the only one where this happens, ma=
ybe the
>> > real problem is in that driver.
>>
>> The member in question (dev->udev->can_submit) is documented as 'URB=
s
>> may be submitted'. The existing code doesn't honor that flag. It is
>> somewhat puzzling that (so far) only the Gobi driver seems to use th=
at
>> flag, but I don't think the bug lies in their driver here.
>
> That flag is not intended for use by drivers but by the USB core. =A0=
(It
> gets cleared only when the device is suspended.) =A0usbnet and Gobi
> shouldn't need to look at it.

Aha!

>> > I'm not applying this until a USB person looks more deeply into th=
is.
>>
>> Alright. Can you suggest a particular USB person to bother?
>>
>> >> ---
>> >> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>> >> index 81c76ad..df7e72e 100644
>> >> --- a/drivers/net/usb/usbnet.c
>> >> +++ b/drivers/net/usb/usbnet.c
>> >> @@ -1172,6 +1172,7 @@ static void usbnet_bh (unsigned long param)
>> >> =A0 =A0 =A0 // or are we maybe short a few urbs?
>> >> =A0 =A0 =A0 } else if (netif_running (dev->net) &&
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_device_present (dev->net=
) &&
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->udev->can_submit &&
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!timer_pending (&dev->delay) &=
&
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!test_bit (EVENT_RX_HALT, &dev=
->flags)) {
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 int =A0 =A0 temp =3D dev->rxq.qlen;
>
> This isn't right. =A0The problem should be fixed some other way. =A0U=
nder
> what circumstances are URBs submitted incorrectly?

When the device is autosuspended. What is the proper thing for a
device to do here?

> Alan Stern

-- Elly
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
