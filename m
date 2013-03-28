From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2 v3] sierra_net: keep status interrupt URB active
Date: Thu, 28 Mar 2013 11:32:07 -0500
Message-ID: <1364488327.1877.22.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1357318096.5370.15.camel@dcbw.foobar.com>
	 <1364488207.1877.20.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1364488207.1877.20.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The driver and firmware sync up through SYNC messages, and the
firmware's affirmative reply to these SYNC messages appears to be the
"Reset" indication received via the status interrupt endpoint.  Thus the
driver needs the status interrupt endpoint always active so that the
Reset indication can be received even if the netdev is closed, which is
the case right after device insertion.

Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index 79ab243..c707225 100644
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
@@ -705,6 +712,9 @@ static int sierra_net_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* set context index initially to 0 - prepares tx hdr template */
 	sierra_net_set_ctx_index(priv, 0);
 
+	/* prepare sync message template */
+	memcpy(priv->sync_msg, sync_tmplate, sizeof(priv->sync_msg));
+
 	/* decrease the rx_urb_size and max_tx_size to 4k on USB 1.1 */
 	dev->rx_urb_size  = SIERRA_NET_RX_URB_SIZE;
 	if (dev->udev->speed != USB_SPEED_HIGH)
@@ -740,11 +750,6 @@ static int sierra_net_bind(struct usbnet *dev, struct usb_interface *intf)
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
@@ -767,8 +772,9 @@ static void sierra_net_unbind(struct usbnet *dev, struct usb_interface *intf)
 		netdev_err(dev->net,
 			"usb_control_msg failed, status %d\n", status);
 
-	sierra_net_set_private(dev, NULL);
+	usbnet_status_stop(dev);
 
+	sierra_net_set_private(dev, NULL);
 	kfree(priv);
 }
 
@@ -909,6 +915,24 @@ static const struct driver_info sierra_net_info_direct_ip = {
 	.tx_fixup = sierra_net_tx_fixup,
 };
 
+static int
+sierra_net_probe (struct usb_interface *udev, const struct usb_device_id *prod)
+{
+	int ret;
+
+	ret = usbnet_probe(udev, prod);
+	if (ret == 0) {
+		struct usbnet *dev = usb_get_intfdata(udev);
+
+		ret = usbnet_status_start(dev, GFP_KERNEL);
+		if (ret == 0) {
+			/* Interrupt URB now set up; initiate sync sequence */
+			sierra_net_dosync(dev);
+		}
+	}
+	return ret;
+}
+
 #define DIRECT_IP_DEVICE(vend, prod) \
 	{USB_DEVICE_INTERFACE_NUMBER(vend, prod, 7), \
 	.driver_info = (unsigned long)&sierra_net_info_direct_ip}, \
@@ -931,7 +955,7 @@ MODULE_DEVICE_TABLE(usb, products);
 static struct usb_driver sierra_net_driver = {
 	.name = "sierra_net",
 	.id_table = products,
-	.probe = usbnet_probe,
+	.probe = sierra_net_probe,
 	.disconnect = usbnet_disconnect,
 	.suspend = usbnet_suspend,
 	.resume = usbnet_resume,


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
