From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH] usbnet: improve/fix status interrupt endpoint interval
Date: Wed, 5 Jun 2013 09:22:25 +0800
Message-ID: <CACVXFVOYMGjGLmyGy=pQwkcuFshLmdNcLZKfqUDazge45GMBPA@mail.gmail.com>
References: <20130604182830.GA13186@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	OndrejZary <linux@rainbow-software.org>
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:50833 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117Ab3FEBW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 21:22:29 -0400
In-Reply-To: <20130604182830.GA13186@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 5, 2013 at 2:28 AM, Andreas Mohr <andi@lisas.de> wrote:
>
> From 307685fe8e6dfc8181e30167b9c31479332cb22f Mon Sep 17 00:00:00 2001
> From: Andreas Mohr <andim2@users.sourceforge.net>
> Date: Sun, 2 Jun 2013 20:37:05 +0200
> Subject: [PATCH] usbnet: improve/fix status interrupt endpoint interval
>  tweaking.
>
> - failed to take super-speed into account
> - <= full-speed seems to have wrong value (specified as frames [ms],
>   thus 3 is not suitable to achieve 8ms)

The above change is correct.

>   Value 8 now managed to reduce powertop wakeups from ~ 540 to ~ 155

It means that your device only returns current link status instead of link
change. IMO, it isn't a good behaviour for the device.

In fact, you still can increase the period only for your device, for example,
128ms/256ms/512ms should be accepted.

> - add detailed docs and question marks about current practice

But the doc need to be fixed.

> ---
>  drivers/net/usb/usbnet.c |   17 ++++++++++++++++-
>  1 file changed, 16 insertions(+), 1 deletion(-)
>
>
> Found this with MCS7830 on a full-speed USB 1.1 port (Inspiron 8000).
> Good to have a rusty notebook with noisy PSU coils, else it would
> have taken a lot longer to nail it ;)
> Tested on -rc4, checkpath.pl:d.
>
> Signed-off-by: Andreas Mohr <andim2@users.sourceforge.net>
>
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 06ee82f..b6e9569 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -231,8 +231,23 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
>         maxp = usb_maxpacket (dev->udev, pipe, 0);
>
>         /* avoid 1 msec chatter:  min 8 msec poll rate */
> +       /* High/SuperSpeed expresses intervals in microframes
> +        * (in logarithmic encoding, PRIOR to encoding in URB)
> +        * rather than frames.
> +        * Thus, for >= HighSpeed: == X [microframes] * 125us [-> 8ms],
> +        * <= FullSpeed: == X [ms] [-> 8ms].
> +        * Finally, it's questionable whether we'll even get away unscathed
> +        * with doing such rate tweaking at all:
> +        * bInterval value is declared as being a hard demand by a device

It isn't a hard demand, which only means the poll interval by which HC
sends IN token to device.

> +        * in order to guarantee having its I/O needs serviced properly...
> +        * if we don't do this, then... [overruns], [fire], [apocalypse]?

Not so serious, if one packet is ready, the late poll from HC may still
get the packet since device can buffer the packet, but if it is too late,
the successor packet might be missed by device.

For usbnet, generally speaking, the interrupt pipe is for polling the
link change, which is a very low frequency event, so you don't need to
worry about missing events if the interval is increased.

> +        * If this turns out to be problematic, such policy should be moved
> +        * to individual drivers (indicate flag to [dis]allow rate tweaking
> +        * as tolerated by specific devices).

Yes, we can add quirk for such kind device by increasing polling
interval.

> +        */
>         period = max ((int) dev->status->desc.bInterval,
> -               (dev->udev->speed == USB_SPEED_HIGH) ? 7 : 3);
> +               ((dev->udev->speed == USB_SPEED_HIGH) ||
> +                (dev->udev->speed == USB_SPEED_SUPER)) ? 7 : 8);

For the above change, please feel free to add my ack:

              Acked-by: Ming Lei <ming.lei@canonical.com>


Thanks,
--
Ming Lei
