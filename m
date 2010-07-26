From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [patch] usbnet: fix 100% CPU use on suspended device
Date: Mon, 26 Jul 2010 10:36:46 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1007261033090.1550-100000@iolanthe.rowland.org>
References: <AANLkTik=b3ps_iMOC=mjDs2quLwBPUKbiqn0nKU3EbB1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:60946 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753760Ab0GZOgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 10:36:47 -0400
In-Reply-To: <AANLkTik=b3ps_iMOC=mjDs2quLwBPUKbiqn0nKU3EbB1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Jul 2010, Elly Jones wrote:

> On Mon, Jul 26, 2010 at 12:57 AM, David Miller <davem@davemloft.net> =
wrote:
> > From: Elly Jones <ellyjones@google.com>
> > Date: Wed, 21 Jul 2010 14:51:48 -0400
> >
> >> Subject: [patch] usbnet: fix 100% CPU use on suspended device
> >> From: Elly Jones <ellyjones@google.com>
> >>
> >> This patch causes the usbnet module not to attempt to submit URBs =
to the device
> >> if the device is not ready to accept them. This fixes a misbehavio=
r trigged by
> >> the Qualcomm Gobi driver (released under GPL through their Code Au=
rora
> >> initiative) which causes the usbnet core to consume 100% of CPU at=
tempting and
> >> failing to submit URBs. This patch is against Linus's 2.6 repo com=
mit
> >> a9f7f2e74ae0e6a801a2433dc8e9124d73da0cb4.
> >> Signed-off-by: Elizabeth Jones <ellyjones@google.com>
> >
> > If the Qualcomm Gobi driver is the only one where this happens, may=
be the
> > real problem is in that driver.
>=20
> The member in question (dev->udev->can_submit) is documented as 'URBs
> may be submitted'. The existing code doesn't honor that flag. It is
> somewhat puzzling that (so far) only the Gobi driver seems to use tha=
t
> flag, but I don't think the bug lies in their driver here.

That flag is not intended for use by drivers but by the USB core.  (It
gets cleared only when the device is suspended.)  usbnet and Gobi
shouldn't need to look at it.

> > I'm not applying this until a USB person looks more deeply into thi=
s.
>=20
> Alright. Can you suggest a particular USB person to bother?
>=20
> >> ---
> >> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> >> index 81c76ad..df7e72e 100644
> >> --- a/drivers/net/usb/usbnet.c
> >> +++ b/drivers/net/usb/usbnet.c
> >> @@ -1172,6 +1172,7 @@ static void usbnet_bh (unsigned long param)
> >> =A0 =A0 =A0 // or are we maybe short a few urbs?
> >> =A0 =A0 =A0 } else if (netif_running (dev->net) &&
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_device_present (dev->net)=
 &&
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->udev->can_submit &&
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!timer_pending (&dev->delay) &&
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!test_bit (EVENT_RX_HALT, &dev-=
>flags)) {
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 int =A0 =A0 temp =3D dev->rxq.qlen;

This isn't right.  The problem should be fixed some other way.  Under
what circumstances are URBs submitted incorrectly?

Alan Stern

