From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] usbnet: fix usb_autopm_get_interface failure(v1)
Date: Mon, 1 Nov 2010 17:04:35 +0200
Message-ID: <AANLkTim_NRFV0ELzpOE6K539Wfxsw8j1eW-3TXLCrgOZ@mail.gmail.com>
References: <1288620349-9769-1-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, oliver@neukum.org, davem@davemloft.net,
	David Brownell <dbrownell@users.sourceforge.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Ben Hutchings <ben@decadent.org.uk>,
	Joe Perches <joe@perches.com>, stable@kernel.org
To: tom.leiming@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51901 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab0KAPEg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 11:04:36 -0400
Received: by iwn10 with SMTP id 10so7130207iwn.19
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 08:04:36 -0700 (PDT)
In-Reply-To: <1288620349-9769-1-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 1, 2010 at 4:05 PM,  <tom.leiming@gmail.com> wrote:
> From: Ming Lei <tom.leiming@gmail.com>
>
> Since usbnet already took usb runtime pm, we have to
> enable runtime pm for usb interface of usbnet, otherwise
> usb_autopm_get_interface may return failure and cause
> 'ifconfig usb0 up' failed if USB_SUSPEND(RUNTIME_PM) is
> enabled.
>
> Cc: David Brownell <dbrownell@users.sourceforge.net>
> Cc: Greg Kroah-Hartman <gregkh@suse.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Ben Hutchings <ben@decadent.org.uk>
> Cc: Joe Perches <joe@perches.com>
> Cc: Oliver Neukum <oliver@neukum.org>
> Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
> Cc: stable@kernel.org
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>
> ---
> v1: include header file
>
> ---
> =C2=A0drivers/net/usb/usbnet.c | =C2=A0 11 +++++++++++
> =C2=A01 files changed, 11 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index ca7fc9d..06b1dee 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -45,6 +45,7 @@
> =C2=A0#include <linux/usb/usbnet.h>
> =C2=A0#include <linux/slab.h>
> =C2=A0#include <linux/kernel.h>
> +#include <linux/pm_runtime.h>
>
> =C2=A0#define DRIVER_VERSION =C2=A0 =C2=A0 =C2=A0 =C2=A0 "22-Aug-2005=
"
>
> @@ -1273,6 +1274,16 @@ usbnet_probe (struct usb_interface *udev, cons=
t struct usb_device_id *prod)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct usb_device =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 *xdev;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 status;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const char =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*name;
> + =C2=A0 =C2=A0 =C2=A0 struct usb_driver =C2=A0 =C2=A0 =C2=A0 *driver=
 =3D to_usb_driver(udev->dev.driver);
> +
> + =C2=A0 =C2=A0 =C2=A0 /*usbnet already took usb runtime pm, so have =
to enable the feature
> + =C2=A0 =C2=A0 =C2=A0 * for usb interface, otherwise usb_autopm_get_=
interface may return
> + =C2=A0 =C2=A0 =C2=A0 * failure if USB_SUSPEND(RUNTIME_PM) is enable=
d.
> + =C2=A0 =C2=A0 =C2=A0 * */
Just minor: multiline comments doesn't follow the required style.

> + =C2=A0 =C2=A0 =C2=A0 if (!driver->supports_autosuspend) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 driver->supports_a=
utosuspend =3D 1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pm_runtime_enable(=
&udev->dev);
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0name =3D udev->dev.driver->name;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0info =3D (struct driver_info *) prod->driv=
er_info;
> --
> 1.7.3
>
>



--=20
With Best Regards,
Andy Shevchenko
