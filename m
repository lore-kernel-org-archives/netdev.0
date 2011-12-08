From: Grant Grundler <grundler@chromium.org>
Subject: Re: 3.0.8 kernel : NULL ptr deref in skb_queue_purge()
Date: Thu, 8 Dec 2011 11:04:48 -0800
Message-ID: <CANEJEGvNePLb9KcMO-sGSN81y6mb_zaHHQVujSbJXcCwh3Xcmw@mail.gmail.com>
References: <CANEJEGtJ3UmFNyui_SaZ6NF5FFVjZ+_UBg1RC2eif5Lu1YKDsQ@mail.gmail.com>
	<20111208180208.GA16883@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:61926 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051Ab1LHTEt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 14:04:49 -0500
Received: by ggnr5 with SMTP id r5so2337707ggn.19
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2011 11:04:48 -0800 (PST)
In-Reply-To: <20111208180208.GA16883@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2011 at 10:02 AM, Greg KH <greg@kroah.com> wrote:
> On Wed, Dec 07, 2011 at 02:40:49PM -0800, Grant Grundler wrote:
>> Hi,
>> I'm testing asix (USB 100BT ethernet adapter with AX88772) driver
>> initialization (and shut down) paths and reproduced a
>> "skb_queue_purge" panic 3 times after a few hundred/thousand
>> iterations of rmmod/modprobe. I'm inclined to believe
>> skb_queue_purge() is a victim and not a culprit here.
>>
>> =C2=A0I don't know if all 3 "spontaneous reboots" I've seen have the=
 same
>> stack trace as the one I have a record for:
>
> Have you tried this on 3.1, and especially, 3.2-rc?

Hi Greg,
I haven't tried any thing later yet.  I would consider it if someone
could point at a change(s) that might be relevant to the symptom.


> =C2=A0A number of asix
> patches have gone into the 3.2-rc series, perhaps they might have
> resolved this problem already?

I'm the one who submitted those changes. :)

asix.c driver I'm testing was pulled directly from davem's net-next
tree and I believe that's what is in 3.2-rc series now.

Those changes only relate to AX88772 and AX88178 bind and reset code.
suspend/resume support is unchanged  - though I suspect ax*_reset
functions get called in resume.

It's possible this code path in asix.c has *always* been broken. I see
two drivesr/net/usbnet USB drivers that do this:

drivers/net/usb/cdc_ether.c  614 .reset_resume =3D usbnet_resume,
drivers/net/usb/cdc_ncm.c  1193 .reset_resume =3D usbnet_resume,

Even though most usbnet drivers don't,  I'm tempted to add this code
and "just try it":

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index e6fed4d..b2de65f 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1666,6 +1666,7 @@ static struct usb_driver asix_driver =3D {
        .probe =3D        usbnet_probe,
        .suspend =3D      usbnet_suspend,
        .resume =3D       usbnet_resume,
+       .reset_resume =3D usbnet_reset_resume,
        .disconnect =3D   usbnet_disconnect,
        .supports_autosuspend =3D 1,
 };



thanks!
grant
