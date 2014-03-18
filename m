From: Grant Grundler <grundler@google.com>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Tue, 18 Mar 2014 13:51:52 -0700
Message-ID: <CANEJEGuaVPNZKFiXY9CywFuqghgiQqV_sii7TE3STCNvXLQ3pQ@mail.gmail.com>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	<CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	<CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	<1394529263.16128.6.camel@linux-fkkt.site>
	<CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
	<CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
	<1395093343.3961.2.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Julius Werner <jwerner@chromium.org>,
	netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:55679 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757723AbaCRUwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 16:52:04 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so7885387iec.32
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 13:52:04 -0700 (PDT)
In-Reply-To: <1395093343.3961.2.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 2:55 PM, Oliver Neukum <oneukum@suse.de> wrote:
> I am hping for the reporter of the original bug to test it.

Oliver,
on a haswell system running ChromeOS-3.8 kernel, this patch as-is
resulted in a "Bad Spinlock Magic" error and subsequent pagefault.
I believe the sequence was:
   usbnet_open -> tasklet_schedule(dev->bh) -> usbnet_bh -> wake_up
(&dev->wait) -> panic

I tried adding the following change on top of your patch but believe
the plumbing still isn't quite correct since the USB device (eth0) is
reporting a link but no TX or RX of traffic:
 @@ -805,6 +807,9 @@ int usbnet_open (struct net_device *net)
                goto done;
        }

+       /* usbnet_bh() expects the spinlock to be initialized. */
+       init_waitqueue_head(&dev->wait);
+
        /* hard_mtu or rx_urb_size may change in reset() */
        usbnet_update_max_qlen(dev);

I suspect this hunk of your patch is now causing different problems at
init time:
@@ -1438,10 +1440,8 @@ static void usbnet_bh (unsigned long param)
        clear_bit(EVENT_RX_KILL, &dev->flags);

        // waiting for all pending urbs to complete?
-       if (dev->wait) {
-               if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0) {
-                       wake_up (dev->wait);
-               }
+       if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0) {
+               wake_up (&dev->wait);

        // or are we maybe short a few urbs?
        } else if (netif_running (dev->net) &&

Please advise on what you'd like me to try next.

cheers,
grant
