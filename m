From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 11/11] usbnet: handle link change
Date: Thu, 11 Apr 2013 22:52:29 +0800
Message-ID: <CACVXFVNtitJfsKMORPyduEztQHiN1cWcVXWep=ScUNLRwv9W=w@mail.gmail.com>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
	<1365691240-816-12-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:44554 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934726Ab3DKOwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:52:32 -0400
In-Reply-To: <1365691240-816-12-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 10:40 PM, Ming Lei <ming.lei@canonical.com> wrote:
> The link change is detected via the interrupt pipe, and bulk
> pipes are responsible for transfering packets, so it is reasonable
> to stop bulk transfer after link is reported as off.
>
> Two adavantages may be obtained with stopping bulk transfer
> after link becomes off:
>
> - USB bus bandwidth is saved(USB bus is shared bus except for
> USB3.0), for example, lots of 'IN' token packets and 'NYET'
> handshake packets is transfered on 2.0 bus.
>
> - probabaly power might be saved for usb host controller since
> cancelling bulk transfer may disable the asynchronous schedule of
> host controller.
>
> With this patch, when link becomes off, about ~10% performance
> boost can be found on bulk transfer of anther usb device which
> is attached to same bus with the usbnet device, see below
> test on next-20130410:
>
> - read from usb mass storage(Sandisk Extreme USB 3.0) on pandaboard
> with below command after unplugging ethernet cable:
>
>         dd if=/dev/sda iflag=direct of=/dev/null bs=1M count=500

Sorry, the above should be:

        dd if=/dev/sda iflag=direct of=/dev/null bs=1M count=800

>
> - without the patch
> 1, 838860800 bytes (839 MB) copied, 36.2216 s, 23.2 MB/s
> 2, 838860800 bytes (839 MB) copied, 35.8368 s, 23.4 MB/s
> 3, 838860800 bytes (839 MB) copied, 35.823 s, 23.4 MB/s
> 4, 838860800 bytes (839 MB) copied, 35.937 s, 23.3 MB/s
> 5, 838860800 bytes (839 MB) copied, 35.7365 s, 23.5 MB/s
> average: 23.6MB/s
>
> - with the patch
> 1, 838860800 bytes (839 MB) copied, 32.3817 s, 25.9 MB/s
> 2, 838860800 bytes (839 MB) copied, 31.7389 s, 26.4 MB/s
> 3, 838860800 bytes (839 MB) copied, 32.438 s, 25.9 MB/s
> 4, 838860800 bytes (839 MB) copied, 32.5492 s, 25.8 MB/s
> 5, 838860800 bytes (839 MB) copied, 31.6178 s, 26.5 MB/s
> average: 26.1MB/s
>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>  drivers/net/usb/usbnet.c   |   30 ++++++++++++++++++++++++++++++
>  include/linux/usb/usbnet.h |    1 +
>  2 files changed, 31 insertions(+)
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 34e4252..1e5a9b7 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -938,6 +938,27 @@ static const struct ethtool_ops usbnet_ethtool_ops = {
>
>  /*-------------------------------------------------------------------------*/
>
> +static void __handle_link_change(struct usbnet *dev)
> +{
> +       if (!test_bit(EVENT_DEV_OPEN, &dev->flags))
> +               return;
> +
> +       if (!netif_carrier_ok(dev->net)) {
> +               /* kill URBs for reading packets to save bus bandwidth */
> +               unlink_urbs(dev, &dev->rxq);
> +
> +               /*
> +                * tx_timeout will unlink URBs for sending packets and
> +                * tx queue is stopped by netcore after link becomes off
> +                */
> +       } else {
> +               /* submitting URBs for reading packets */
> +               tasklet_schedule(&dev->bh);
> +       }
> +
> +       clear_bit(EVENT_LINK_CHANGE, &dev->flags);
> +}
> +
>  /* work that cannot be done in interrupt context uses keventd.
>   *
>   * NOTE:  with 2.5 we could do more of this using completion callbacks,
> @@ -1035,8 +1056,14 @@ skip_reset:
>                 } else {
>                         usb_autopm_put_interface(dev->intf);
>                 }
> +
> +               /* handle link change from link resetting */
> +               __handle_link_change(dev);
>         }
>
> +       if (test_bit (EVENT_LINK_CHANGE, &dev->flags))
> +               __handle_link_change(dev);
> +
>         if (dev->flags)
>                 netdev_dbg(dev->net, "kevent done, flags = 0x%lx\n", dev->flags);
>  }
> @@ -1286,6 +1313,7 @@ static void usbnet_bh (unsigned long param)
>         // or are we maybe short a few urbs?
>         } else if (netif_running (dev->net) &&
>                    netif_device_present (dev->net) &&
> +                  netif_carrier_ok(dev->net) &&
>                    !timer_pending (&dev->delay) &&
>                    !test_bit (EVENT_RX_HALT, &dev->flags)) {
>                 int     temp = dev->rxq.qlen;
> @@ -1663,6 +1691,8 @@ void usbnet_link_change(struct usbnet *dev, bool link, bool need_reset)
>
>         if (need_reset && link)
>                 usbnet_defer_kevent(dev, EVENT_LINK_RESET);
> +       else
> +               usbnet_defer_kevent(dev, EVENT_LINK_CHANGE);
>  }
>  EXPORT_SYMBOL(usbnet_link_change);
>
> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> index eb021b8..da46327 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -72,6 +72,7 @@ struct usbnet {
>  #              define EVENT_DEVICE_REPORT_IDLE 8
>  #              define EVENT_NO_RUNTIME_PM      9
>  #              define EVENT_RX_KILL    10
> +#              define EVENT_LINK_CHANGE        11
>  };
>
>  static inline struct usb_driver *driver_of(struct usb_interface *intf)
> --
> 1.7.9.5
>
