From: Paul Stewart <pstew@chromium.org>
Subject: [PATCHv7] usbnet: Resubmit interrupt URB if device is open
Date: Tue, 26 Apr 2011 09:58:32 -0700
Message-ID: <20110426172059.4C9B320242@glenhelen.mtv.corp.google.com>
References: <201104240836.47491.oliver@neukum.org>
Cc: oliver@neukum.org, stern@rowland.harvard.edu, davem@davemloft.net,
	bhutchings@solarflare.com, linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:9409 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000Ab1DZRVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 13:21:16 -0400
In-Reply-To: <201104240836.47491.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resubmit interrupt URB if device is open.  Use a flag set in
usbnet_open() to determine this state.  Also kill and free
interrupt URB in usbnet_disconnect().

Signed-off-by: Paul Stewart <pstew@chromium.org>
---
 drivers/net/usb/usbnet.c   |   14 +++++++++++++-
 include/linux/usb/usbnet.h |    1 +
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 02d25c7..623d26f 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -643,6 +643,7 @@ static int usbnet_open (struct net_device *net)
 		}
 	}
 
+	set_bit(EVENT_DEV_OPEN, &dev->flags);
 	netif_start_queue (net);
 	if (netif_msg_ifup (dev)) {
 		char	*framing;
@@ -1105,6 +1106,9 @@ void usbnet_disconnect (struct usb_interface *intf)
 	if (dev->driver_info->unbind)
 		dev->driver_info->unbind (dev, intf);
 
+	usb_kill_urb(dev->interrupt);
+	usb_free_urb(dev->interrupt);
+
 	free_netdev(net);
 	usb_put_dev (xdev);
 }
@@ -1285,6 +1289,9 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
 		 * wake the device
 		 */
 		netif_device_attach (dev->net);
+
+		/* Stop interrupt URBs */
+		usb_kill_urb(dev->interrupt);
 	}
 	return 0;
 }
@@ -1294,8 +1301,13 @@ int usbnet_resume (struct usb_interface *intf)
 {
 	struct usbnet		*dev = usb_get_intfdata(intf);
 
-	if (!--dev->suspend_count)
+	if (!--dev->suspend_count) {
+		/* resume interrupt URBs */
+		if (test_bit(EVENT_DEV_OPEN, &dev->flags))
+			usb_submit_urb(dev->interrupt, GFP_NOIO);
+
 		tasklet_schedule (&dev->bh);
+        }
 
 	return 0;
 }
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index ba09fe8..d148cca 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -64,6 +64,7 @@ struct usbnet {
 #		define EVENT_RX_MEMORY	2
 #		define EVENT_STS_SPLIT	3
 #		define EVENT_LINK_RESET	4
+#		define EVENT_DEV_OPEN	5
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
-- 
1.7.3.1

