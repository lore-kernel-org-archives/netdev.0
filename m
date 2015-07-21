From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Tue, 21 Jul 2015 16:22:09 +0200
Message-ID: <1437488529.3823.16.camel@suse.com>
References: <55AD3A41.2040100@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eugene Shatokhin <eugene.shatokhin-irhHPgl+04UvJsYlp49lxw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55AD3A41.2040100-irhHPgl+04UvJsYlp49lxw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-07-20 at 21:13 +0300, Eugene Shatokhin wrote:
> And here, the code clears EVENT_RX_KILL bit in dev->flags, which may 
> execute concurrently with the above operation:
> #0 clear_bit (bitops.h:113, inlined)
> #1 usbnet_bh (usbnet.c:1475)
>         /* restart RX again after disabling due to high error rate */
>         clear_bit(EVENT_RX_KILL, &dev->flags);
>         
> If clear_bit() is atomic w.r.t. setting dev->flags to 0, this race is 
> not a problem, I guess. Otherwise, it may be.

clear_bit is atomic with respect to other atomic operations.
So how about this:

	Regards
		Oliver

>From 1c4e685b3a9c183e04c46b661830e5c7ed35b513 Mon Sep 17 00:00:00 2001
From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Date: Tue, 21 Jul 2015 16:19:40 +0200
Subject: [PATCH] usbnet: fix race between usbnet_stop() and the BH

Does this do the job?

Signed-off-by: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
---
 drivers/net/usb/usbnet.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3c86b10..77a9a86 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -778,7 +778,7 @@ int usbnet_stop (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	struct driver_info	*info = dev->driver_info;
-	int			retval, pm;
+	int			retval, pm, mpn;
 
 	clear_bit(EVENT_DEV_OPEN, &dev->flags);
 	netif_stop_queue (net);
@@ -813,14 +813,17 @@ int usbnet_stop (struct net_device *net)
 	 * can't flush_scheduled_work() until we drop rtnl (later),
 	 * else workers could deadlock; so make workers a NOP.
 	 */
+	mpn = !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
 	dev->flags = 0;
 	del_timer_sync (&dev->delay);
 	tasklet_kill (&dev->bh);
+	mpn |= !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
+	/* in case the bh reset a flag */
+	dev->flags = 0;
 	if (!pm)
 		usb_autopm_put_interface(dev->intf);
 
-	if (info->manage_power &&
-	    !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags))
+	if (info->manage_power && mpn)
 		info->manage_power(dev, 0);
 	else
 		usb_autopm_put_interface(dev->intf);
-- 
2.1.4



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
