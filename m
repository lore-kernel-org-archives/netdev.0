From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: [PATCH v2] CDC NCM: release interfaces fix in unbind()
Date: Tue, 17 May 2011 21:59:04 +0200
Message-ID: <1305662344-28355-1-git-send-email-alexey.orishko@stericsson.com>
Cc: linux-usb@vger.kernel.org, gregkh@suse.de,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net, oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:59643 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932184Ab1EQT7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 15:59:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes:
- claim slave/data interface during bind() and release in
 unbind() unconditionally
- in case of error during bind(), release claimed data
 interface in the same function
- remove obsolited "*_claimed" entries from driver context

Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>
---
 drivers/net/usb/cdc_ncm.c |   66 +++++++++++---------------------------------
 1 files changed, 17 insertions(+), 49 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4ab557d..7fa00d7 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -54,7 +54,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
-#define	DRIVER_VERSION				"06-May-2011"
+#define	DRIVER_VERSION				"17-May-2011"
 
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
@@ -134,8 +134,6 @@ struct cdc_ncm_ctx {
 	u16 tx_ndp_modulus;
 	u16 tx_seq;
 	u16 connected;
-	u8 data_claimed;
-	u8 control_claimed;
 };
 
 static void cdc_ncm_tx_timeout(unsigned long arg);
@@ -460,17 +458,6 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
 
 	del_timer_sync(&ctx->tx_timer);
 
-	if (ctx->data_claimed) {
-		usb_set_intfdata(ctx->data, NULL);
-		usb_driver_release_interface(driver_of(ctx->intf), ctx->data);
-	}
-
-	if (ctx->control_claimed) {
-		usb_set_intfdata(ctx->control, NULL);
-		usb_driver_release_interface(driver_of(ctx->intf),
-								ctx->control);
-	}
-
 	if (ctx->tx_rem_skb != NULL) {
 		dev_kfree_skb_any(ctx->tx_rem_skb);
 		ctx->tx_rem_skb = NULL;
@@ -495,7 +482,7 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
 	if (ctx == NULL)
-		goto error;
+		return -ENODEV;
 
 	memset(ctx, 0, sizeof(*ctx));
 
@@ -572,42 +559,32 @@ advance:
 		goto error;
 
 	/* claim interfaces, if any */
-	if (ctx->data != intf) {
-		temp = usb_driver_claim_interface(driver, ctx->data, dev);
-		if (temp)
-			goto error;
-		ctx->data_claimed = 1;
-	}
-
-	if (ctx->control != intf) {
-		temp = usb_driver_claim_interface(driver, ctx->control, dev);
-		if (temp)
-			goto error;
-		ctx->control_claimed = 1;
-	}
+	temp = usb_driver_claim_interface(driver, ctx->data, dev);
+	if (temp)
+		goto error;
 
 	iface_no = ctx->data->cur_altsetting->desc.bInterfaceNumber;
 
 	/* reset data interface */
 	temp = usb_set_interface(dev->udev, iface_no, 0);
 	if (temp)
-		goto error;
+		goto error2;
 
 	/* initialize data interface */
 	if (cdc_ncm_setup(ctx))
-		goto error;
+		goto error2;
 
 	/* configure data interface */
 	temp = usb_set_interface(dev->udev, iface_no, 1);
 	if (temp)
-		goto error;
+		goto error2;
 
 	cdc_ncm_find_endpoints(ctx, ctx->data);
 	cdc_ncm_find_endpoints(ctx, ctx->control);
 
 	if ((ctx->in_ep == NULL) || (ctx->out_ep == NULL) ||
 	    (ctx->status_ep == NULL))
-		goto error;
+		goto error2;
 
 	dev->net->ethtool_ops = &cdc_ncm_ethtool_ops;
 
@@ -617,7 +594,7 @@ advance:
 
 	temp = usbnet_get_ethernet_addr(dev, ctx->ether_desc->iMACAddress);
 	if (temp)
-		goto error;
+		goto error2;
 
 	dev_info(&dev->udev->dev, "MAC-Address: "
 				"0x%02x:0x%02x:0x%02x:0x%02x:0x%02x:0x%02x\n",
@@ -642,6 +619,10 @@ advance:
 	ctx->tx_speed = ctx->rx_speed = 0;
 	return 0;
 
+error2:
+	usb_set_intfdata(ctx->control, NULL);
+	usb_set_intfdata(ctx->data, NULL);
+	usb_driver_release_interface(driver, ctx->data);
 error:
 	cdc_ncm_free((struct cdc_ncm_ctx *)dev->data[0]);
 	dev->data[0] = 0;
@@ -652,27 +633,14 @@ error:
 static void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)dev->data[0];
-	struct usb_driver *driver;
+	struct usb_driver *driver = driver_of(intf);
 
 	if (ctx == NULL)
 		return;		/* no setup */
 
-	driver = driver_of(intf);
-
-	usb_set_intfdata(ctx->data, NULL);
 	usb_set_intfdata(ctx->control, NULL);
-	usb_set_intfdata(ctx->intf, NULL);
-
-	/* release interfaces, if any */
-	if (ctx->data_claimed) {
-		usb_driver_release_interface(driver, ctx->data);
-		ctx->data_claimed = 0;
-	}
-
-	if (ctx->control_claimed) {
-		usb_driver_release_interface(driver, ctx->control);
-		ctx->control_claimed = 0;
-	}
+	usb_set_intfdata(ctx->data, NULL);
+	usb_driver_release_interface(driver, ctx->data);
 
 	cdc_ncm_free(ctx);
 }
-- 
1.7.4.3

