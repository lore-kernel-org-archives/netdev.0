From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Mon, 21 Jan 2013 15:47:13 +0100
Message-ID: <87mww2y4ni.fsf@nemi.mork.no>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no>
	<22276933.xSGyXJfOvq@linux-5eaq.site> <871udiur74.fsf@nemi.mork.no>
	<CAL_Kpj1B=_+eN3Y0n3d9_r4JoeHD2LQFSU+b+taCZL0G4icu6A@mail.gmail.com>
	<87r4ley6g9.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: Alexey Orishko <alexey.orishko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38740 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755970Ab3AUOrf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 09:47:35 -0500
In-Reply-To: <87r4ley6g9.fsf@nemi.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Mon, 21
	Jan 2013 15:08:22 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> I have another issue with the Sierra firmware which I hope you can he=
lp
> me with: The MC7710 device requires at ZLP even if we send
> dwNtbOutMaxSize sized NTBs. This is a problem because the current cod=
e
> explicitly prevents this.

If anyone found this more than normally confused, then that is
correct...

What the NCM code does is that it sends a *short* packet whenever the
usbnet would normally have done so, except if the NTP length >=3D
dwNtbOutMaxSize.

The problem is that we do not set=20

	urb->transfer_flags |=3D URB_ZERO_PACKET;

either in this special case, resulting in neither a short nor a zero
length packet being sent.  I believe this is what the Sierra firmware
chokes at. This seems to fix the issue, and is IMHO correct:

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 42f51c7..3a5673a 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -366,7 +366,7 @@ err:
=20
 static const struct driver_info cdc_mbim_info =3D {
        .description =3D "CDC MBIM",
-       .flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
+       .flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN | FLA=
G_SEND_ZLP,
        .bind =3D cdc_mbim_bind,
        .unbind =3D cdc_mbim_unbind,
        .manage_power =3D cdc_mbim_manage_power,



But I wonder if this isn't really a generic problem in usbnet.  The
=46LAG_MULTI_PACKET test here seems completely bogus:

	if (length % dev->maxpacket =3D=3D 0) {
		if (!(info->flags & FLAG_SEND_ZLP)) {
			if (!(info->flags & FLAG_MULTI_PACKET)) {
				urb->transfer_buffer_length++;
				if (skb_tailroom(skb)) {
					skb->data[skb->len] =3D 0;
					__skb_put(skb, 1);
				}
			}
		} else
			urb->transfer_flags |=3D URB_ZERO_PACKET;
	}

Either the FLAG_MULTI_PACKET minidriver will have already padded the
buffer so that we do not hit (length % dev->maxpacket =3D=3D 0), or we
should choose one of the alternatives: ZLP or padding.

Minidrivers not wanting the short packets (like cdc_ncm) must set
=46LAG_SEND_ZLP.


Bj=C3=B8rn
