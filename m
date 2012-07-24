From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cdc-ncm: tag Ericsson WWAN devices (eg F5521gw) with
 FLAG_WWAN
Date: Tue, 24 Jul 2012 13:43:22 -0500
Message-ID: <1343155402.29196.7.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tag Ericsson NCM devices as WWAN modems, since they almost certainly all
are.  This way userspace clients know that the device requires further
setup on the AT-capable serial ports before connectivity is available.

Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---

NOTE: it seems unlikely that all NCM devices are WWAN modems, but it
also seems unlikely that Ericsson will produce a plain USB Ethernet
adapter using CDC-NCM.

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4b9513f..1931587 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -138,20 +138,7 @@ struct cdc_ncm_ctx {
 static void cdc_ncm_txpath_bh(unsigned long param);
 static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
 static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_timer);
-static const struct driver_info cdc_ncm_info;
 static struct usb_driver cdc_ncm_driver;
-static const struct ethtool_ops cdc_ncm_ethtool_ops;
-
-static const struct usb_device_id cdc_devs[] = {
-	{ USB_INTERFACE_INFO(USB_CLASS_COMM,
-		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
-		.driver_info = (unsigned long)&cdc_ncm_info,
-	},
-	{
-	},
-};
-
-MODULE_DEVICE_TABLE(usb, cdc_devs);
 
 static void
 cdc_ncm_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
@@ -454,6 +441,16 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
 	kfree(ctx);
 }
 
+static const struct ethtool_ops cdc_ncm_ethtool_ops = {
+	.get_drvinfo = cdc_ncm_get_drvinfo,
+	.get_link = usbnet_get_link,
+	.get_msglevel = usbnet_get_msglevel,
+	.set_msglevel = usbnet_set_msglevel,
+	.get_settings = usbnet_get_settings,
+	.set_settings = usbnet_set_settings,
+	.nway_reset = usbnet_nway_reset,
+};
+
 static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct cdc_ncm_ctx *ctx;
@@ -1203,6 +1200,41 @@ static const struct driver_info cdc_ncm_info = {
 	.tx_fixup = cdc_ncm_tx_fixup,
 };
 
+/* Same as cdc_ncm_info, but with FLAG_WWAN */
+static const struct driver_info wwan_info = {
+	.description = "Mobile Broadband Network Device",
+	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
+			| FLAG_WWAN,
+	.bind = cdc_ncm_bind,
+	.unbind = cdc_ncm_unbind,
+	.check_connect = cdc_ncm_check_connect,
+	.manage_power = cdc_ncm_manage_power,
+	.status = cdc_ncm_status,
+	.rx_fixup = cdc_ncm_rx_fixup,
+	.tx_fixup = cdc_ncm_tx_fixup,
+};
+
+static const struct usb_device_id cdc_devs[] = {
+	/* Ericsson MBM devices like F5521gw */
+	{ .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
+		| USB_DEVICE_ID_MATCH_VENDOR,
+	  .idVendor = 0x0bdb,
+	  .bInterfaceClass = USB_CLASS_COMM,
+	  .bInterfaceSubClass = USB_CDC_SUBCLASS_NCM,
+	  .bInterfaceProtocol = USB_CDC_PROTO_NONE,
+	  .driver_info = (unsigned long) &wwan_info,
+	},
+
+	/* Generic CDC-NCM devices */
+	{ USB_INTERFACE_INFO(USB_CLASS_COMM,
+		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
+		.driver_info = (unsigned long)&cdc_ncm_info,
+	},
+	{
+	},
+};
+MODULE_DEVICE_TABLE(usb, cdc_devs);
+
 static struct usb_driver cdc_ncm_driver = {
 	.name = "cdc_ncm",
 	.id_table = cdc_devs,
@@ -1215,16 +1247,6 @@ static struct usb_driver cdc_ncm_driver = {
 	.disable_hub_initiated_lpm = 1,
 };
 
-static const struct ethtool_ops cdc_ncm_ethtool_ops = {
-	.get_drvinfo = cdc_ncm_get_drvinfo,
-	.get_link = usbnet_get_link,
-	.get_msglevel = usbnet_get_msglevel,
-	.set_msglevel = usbnet_set_msglevel,
-	.get_settings = usbnet_get_settings,
-	.set_settings = usbnet_set_settings,
-	.nway_reset = usbnet_nway_reset,
-};
