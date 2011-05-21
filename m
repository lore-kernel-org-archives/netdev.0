From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3] CDC NCM: release interfaces fix in unbind()
Date: Sat, 21 May 2011 02:42:16 +0200
Message-ID: <1305938536-5343-1-git-send-email-alexey.orishko@stericsson.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Changes:
- claim slave/data interface during bind() and release
 interfaces in unbind() unconditionally
- in case of error during bind(), release claimed data
 interface in the same function
- remove obsolited "*_claimed" entries from driver context

Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   72 +++++++++++++++------------------------------
 1 files changed, 24 insertions(+), 48 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4ab557d..5ab2634 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -54,7 +54,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
-#define	DRIVER_VERSION				"06-May-2011"
+#define	DRIVER_VERSION				"21-May-2011"
 
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
 
@@ -568,46 +555,36 @@ advance:
 
 	/* check if we got everything */
 	if ((ctx->control == NULL) || (ctx->data == NULL) ||
-	    (ctx->ether_desc == NULL))
+	    (ctx->ether_desc == NULL) || (ctx->control != intf))
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
@@ -642,36 +619,35 @@ advance:
 	ctx->tx_speed = ctx->rx_speed = 0;
 	return 0;
 
+error2:
+	usb_set_intfdata(ctx->control, NULL);
+	usb_set_intfdata(ctx->data, NULL);
+	usb_driver_release_interface(driver, ctx->data);
 error:
 	cdc_ncm_free((struct cdc_ncm_ctx *)dev->data[0]);
 	dev->data[0] = 0;
-	dev_info(&dev->udev->dev, "Descriptor failure\n");
+	dev_info(&dev->udev->dev, "bind() failure\n");
 	return -ENODEV;
 }
 
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
-	usb_set_intfdata(ctx->control, NULL);
-	usb_set_intfdata(ctx->intf, NULL);
