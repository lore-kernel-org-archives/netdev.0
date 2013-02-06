From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2 v2] sierra_net: fix issues with SYNC/RESTART messages
 and interrupt pipe setup
Date: Wed, 06 Feb 2013 12:42:56 -0600
Message-ID: <1360176176.11742.16.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1357318096.5370.15.camel@dcbw.foobar.com>
	 <1357318289.5370.19.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1357318289.5370.19.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

As part of the initialization sequence, the driver sends a SYNC message
via the control pipe to the firmware, which appears to request a
firmware restart.  The firmware responds with an indication via the
interrupt pipe set up by usbnet.  If the driver does not receive a
RESTART indication within a certain amount of time, it will periodically
send additional SYNC messages until it receives the RESTART indication.

Unfortunately, the interrupt URB is only submitted while the netdev
is open, which is usually not the case during initialization, and thus
the firmware's RESTART indication is lost.  So the driver continues
sending SYNC messages, and eventually the firmware crashes when it
receives too many.  This leads to a wedged netdev.

To ensure the firmware's RESTART indications can be received by the
driver, request that usbnet keep the interrupt URB active via
FLAG_INTR_ALWAYS.

Second, move the code that sends the SYNC message out of the
bind() hook and after usbnet_probe() to ensure the interrupt URB
is set up before trying to use it.

Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/usb/sierra_net.c | 33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index 18dd425..185ffec 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -427,6 +427,13 @@ static void sierra_net_dosync(struct usbnet *dev)
 
 	dev_dbg(&dev->udev->dev, "%s", __func__);
 
+	/* The SIERRA_NET_HIP_MSYNC_ID command appears to request that the
+	 * firmware restart itself.  After restarting, the modem will respond
+	 * with the SIERRA_NET_HIP_RESTART_ID indication.  The driver continues
+	 * sending MSYNC commands every few seconds until it receives the
+	 * RESTART event from the firmware
+	 */
+
 	/* tell modem we are ready */
 	status = sierra_net_send_sync(dev);
 	if (status < 0)
@@ -709,6 +716,9 @@ static int sierra_net_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* set context index initially to 0 - prepares tx hdr template */
 	sierra_net_set_ctx_index(priv, 0);
 
+	/* prepare sync message template */
+	memcpy(priv->sync_msg, sync_tmplate, sizeof(priv->sync_msg));
+
 	/* decrease the rx_urb_size and max_tx_size to 4k on USB 1.1 */
 	dev->rx_urb_size  = SIERRA_NET_RX_URB_SIZE;
 	if (dev->udev->speed != USB_SPEED_HIGH)
@@ -744,11 +754,6 @@ static int sierra_net_bind(struct usbnet *dev, struct usb_interface *intf)
 		kfree(priv);
 		return -ENODEV;
 	}
-	/* prepare sync message from template */
-	memcpy(priv->sync_msg, sync_tmplate, sizeof(priv->sync_msg));
-
-	/* initiate the sync sequence */
-	sierra_net_dosync(dev);
 
 	return 0;
 }
@@ -905,7 +910,7 @@ static struct sk_buff *sierra_net_tx_fixup(struct usbnet *dev,
 
 static const struct driver_info sierra_net_info_direct_ip = {
 	.description = "Sierra Wireless USB-to-WWAN Modem",
-	.flags = FLAG_WWAN | FLAG_SEND_ZLP,
+	.flags = FLAG_WWAN | FLAG_SEND_ZLP | FLAG_INTR_ALWAYS,
 	.bind = sierra_net_bind,
 	.unbind = sierra_net_unbind,
 	.status = sierra_net_status,
@@ -913,6 +918,20 @@ static const struct driver_info sierra_net_info_direct_ip = {
 	.tx_fixup = sierra_net_tx_fixup,
 };
 
+static int
+sierra_net_probe (struct usb_interface *udev, const struct usb_device_id *prod)
+{
+	int ret;
+
+	ret = usbnet_probe (udev, prod);
+	if (ret == 0) {
+		/* Interrupt URB now set up; initiate sync sequence */
+		sierra_net_dosync(usb_get_intfdata(udev));
+	}
+
+	return ret;
+}
+
 #define DIRECT_IP_DEVICE(vend, prod) \
 	{USB_DEVICE_INTERFACE_NUMBER(vend, prod, 7), \
 	.driver_info = (unsigned long)&sierra_net_info_direct_ip}, \
@@ -935,7 +954,7 @@ MODULE_DEVICE_TABLE(usb, products);
 static struct usb_driver sierra_net_driver = {
 	.name = "sierra_net",
 	.id_table = products,
-	.probe = usbnet_probe,
+	.probe = sierra_net_probe,
 	.disconnect = usbnet_disconnect,
 	.suspend = usbnet_suspend,
 	.resume = usbnet_resume,
-- 
1.7.11.7


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
