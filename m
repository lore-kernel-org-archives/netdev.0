From: Ming Lei <ming.lei@canonical.com>
Subject: Re: Dealing nicely with PM failure
Date: Sat, 15 Dec 2012 22:33:03 +0800
Message-ID: <CACVXFVOY=sKu3cEDiO8K+0Yd_Ruk=Wjpz-v1CqcueJZzXaXkyQ@mail.gmail.com>
References: <3581886.3cmiB2PA1J@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Glendinning <steve@shawell.net>, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:54815 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab2LOOdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2012 09:33:06 -0500
Received: from mail-ee0-f46.google.com ([74.125.83.46])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TjsnY-0001N7-0j
	for netdev@vger.kernel.org; Sat, 15 Dec 2012 14:33:04 +0000
Received: by mail-ee0-f46.google.com with SMTP id e53so2459381eek.19
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2012 06:33:03 -0800 (PST)
In-Reply-To: <3581886.3cmiB2PA1J@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2012 at 10:56 PM, Oliver Neukum <oneukum@suse.de> wrote:
> Hi,
>
> this question about the smsc devices gave me an idea.
> How about this?

It is a good idea to handle remote wakeup failure, but I am wondering
if it is suitable to apply it on current smsc problem because we know
in advance if these devices can support auto suspend.

>
> From f1bdff89eea4c10102f867f9f22cb2b60519e425 Mon Sep 17 00:00:00 2001
> From: Oliver Neukum <oliver@neukum.org>
> Date: Fri, 14 Dec 2012 15:51:36 +0100
> Subject: [PATCH] usbnet: handle PM failure gracefully
>
> If a device fails to do remote wakeup, this is no reason
> to abort an open totally. This patch just continues without
> runtime PM.
>
> Signed-off-by: Oliver Neukum <oneukum@suse.de>
> ---
>  drivers/net/usb/usbnet.c   |   17 +++++++++--------
>  include/linux/usb/usbnet.h |    1 +
>  2 files changed, 10 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index c04110b..2010eef 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -719,7 +719,8 @@ int usbnet_stop (struct net_device *net)
>         dev->flags = 0;
>         del_timer_sync (&dev->delay);
>         tasklet_kill (&dev->bh);
> -       if (info->manage_power)
> +       if (info->manage_power &&
> +           !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags))
>                 info->manage_power(dev, 0);
>         else
>                 usb_autopm_put_interface(dev->intf);
> @@ -793,15 +794,15 @@ int usbnet_open (struct net_device *net)
>         // delay posting reads until we're fully open
>         tasklet_schedule (&dev->bh);
>         if (info->manage_power) {
> -               retval = info->manage_power(dev, 1);
> -               if (retval < 0)
> -                       goto done_manage_power_error;
> -               usb_autopm_put_interface(dev->intf);
> +               int r;
> +
> +               r = info->manage_power(dev, 1);
> +               if (r < 0)
> +                       set_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
> +               else
> +                       usb_autopm_put_interface(dev->intf);
>         }
>         return retval;
> -
> -done_manage_power_error:
> -       clear_bit(EVENT_DEV_OPEN, &dev->flags);
>  done:
>         usb_autopm_put_interface(dev->intf);
>  done_nopm:
> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> index 9bbeabf..288b32a 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -69,6 +69,7 @@ struct usbnet {
>  #              define EVENT_DEV_ASLEEP 6
>  #              define EVENT_DEV_OPEN   7
>  #              define EVENT_DEVICE_REPORT_IDLE 8
> +#              define EVENT_NO_RUNTIME_PM      9
>  };
>
>  static inline struct usb_driver *driver_of(struct usb_interface *intf)
> --
> 1.7.7
>
>

Thanks,
--
Ming Lei
