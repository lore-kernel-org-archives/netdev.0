From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP exception table
Date: Thu, 29 Aug 2013 10:32:55 +0200
Message-ID: <87fvts28y0.fsf@nemi.mork.no>
References: <20130828171812.7097dc8334046b464486d4a3@gmail.com>
	<20130828.200111.1548126886406334118.davem@davemloft.net>
	<20130828184022.9a5b54e8df63aaf8c82bf9b5@gmail.com>
	<20130829.003352.1187611479213752660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: robmatic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130829.003352.1187611479213752660.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
	Miller's message of "Thu, 29 Aug 2013 00:33:52 -0400 (EDT)")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: Rob Gardner <robmatic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Wed, 28 Aug 2013 18:40:22 -0600
>
>> The exception list means "usb_device_id entries for specific devices
>> that are known to need the workaround." There are just two such entr=
ies.
>> There isn't even a separate list. So maybe we just have a nomenclatu=
re
>> problem, and we could simply be calling this a "white list" instead =
of
>> "exception list". The other possible meaning of whitelist (all devic=
es
>> that *don't* need the workaround) is unthinkable, as that would be a=
 huge
>> list and much more prone to be unmanageable than what we've got now.
>
> Ok I misunderstood.  I thought we were discoving that all chips which
> have been thoroughly investigated end up needing the workaround.
>
> I guess it's only a specific family of these chips which seem to all
> have the problem?

This driver is a class driver, which means that it deals with a number
of completely independent chip designs from different vendors.  We have
so far seen and tested chips from ST-Ericsson, Qualcomm and Mediatek
with this driver.  Given that Microsoft requires MBIM, we are likely to
see implementations on all available 3G/LTE chips (if there are any
others?)

Only devices with Qualcomm chips have the bug in question, and so far w=
e
have only observed it in modules made by Sierra Wireless. The firmware
in these modules has a base part made by Qualcomm and an application
part made by Sierra Wireless.  We do not know which part of the firmwar=
e
is responsible for the bug, but we do know that the Qualcomm base
firmware used by these modules support MBIM framing.  Based on this, I
am guessing that the chip vendor Qualcomm is responsible for the bug. I=
f
correct, then the bug is likely to appear in products from many
different module vendors.  It would not be the first time we saw that..=
=2E

I do have a Huawei MBIM device with a Qualcomm chip, but this module
does not have the Qualcomm firmware with MBIM support. The MBIM
implementation is therefore assumed to be made by Huawei and running as
a firmware application on the device.  This device does not have the bu=
g.

Now, if we could just identify devices running a Qualcomm base firmware
with MBIM support then we could enable the workaround for all those. Bu=
t
the driver does not have any way to identify them.  It must base its
decision on the USB descriptors, in practice only device ID and product
ID. A module vendor can use chips from different sources (Huawei does
this), and as Rob says: Laptop vendors will often have modules made wit=
h
their own vendor ID. Most laptop vendors will also use modules from
different vendors.  HP, as a current example, is known to use modules
both from Sierra Wireless (need the workaround) and Ericsson (does not
want the workaround).

This makes any sort of vendor matching difficult, and we end up with
device specific blacklisting or whitelisting as the only option.  If it
had been only the two devices we have now, or even only a few tens of
devices, this would not have been a big deal.  But I do expect that the
length of this exception list will be comparable to the list of devices
supported by the qmi_wwan driver, i.e. hundreds.  And, like that driver=
,
the list will probably never be complete. Given the difficulties
detecting the need for the workaround, the list is probably going to be
extremely incomplete. Only a small percentage of end users with affecte=
d
devices will be able to provide the necessary information.

=46or the question of the workaround impact on devices without bug: The=
y
will work fine, and the effect will not be user noticable AFAICS.  But
it will have a negative impact on the device, most likely causing highe=
r
power consumption. Alexey has explained this much better than I can, as
I do not fully understand the device firmware design and requirements:
http://www.spinics.net/lists/linux-usb/msg78078.html

Quoting part of his explanation (talking about the *device* CPU and
INT - we do not care about the host):

  If host decides to send ZLP after full NTB, CPU must handle
  additional INT per every full NTB instead of doing useful work.
  For FTP transfer with constantly full NTBs you get twice amount of
  Interrupts.

I do agree that this is unfortunate. And hurting standard compliant
devices to work around a standard violating bug in other devices does
not feel right.  But I do not see any other option.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
