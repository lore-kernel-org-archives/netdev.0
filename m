From: Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/5] usb: cdc-ncm: Set altsetting only when network interface is opened
Date: Wed, 15 Feb 2012 14:47:38 +0000
Message-ID: <1329317261-3406-3-git-send-email-toby.gray@realvnc.com>
References: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
To: Toby Gray <tg-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>, Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1329317261-3406-1-git-send-email-toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

CDC NCM devices have two alternate settings for the data interface,
one without any endpoints and one with endpoints. Selecting the
alternate setting with endpoints is used to signal to the function
that the host is interested in the network connectivity and has
finished setting NCM operational parameters.

Some NCM devices fail to send the NetworkConnection status if the host
is not trying to read from the control interrupt endpoint in the first
few seconds after the data interface alternate setting is selected.

This change moves the selection of the data interface alternate
setting to when the network interface is opened.

Signed-off-by: Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   36 ++++++++++++++++++++++++++++--------
 1 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 3df51ee..e1b2d5d 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -411,14 +411,14 @@ max_dgram_err:
 }
 
 static void
-cdc_ncm_find_endpoints(struct cdc_ncm_ctx *ctx, struct usb_interface *intf)
+cdc_ncm_find_endpoints(struct cdc_ncm_ctx *ctx, struct usb_host_interface *intf)
 {
 	struct usb_host_endpoint *e;
 	u8 ep;
 
-	for (ep = 0; ep < intf->cur_altsetting->desc.bNumEndpoints; ep++) {
+	for (ep = 0; ep < intf->desc.bNumEndpoints; ep++) {
 
-		e = intf->cur_altsetting->endpoint + ep;
+		e = intf->endpoint + ep;
 		switch (e->desc.bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) {
 		case USB_ENDPOINT_XFER_INT:
 			if (usb_endpoint_dir_in(&e->desc)) {
@@ -467,6 +467,7 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct cdc_ncm_ctx *ctx;
 	struct usb_driver *driver;
+	struct usb_host_interface *data_altsetting;
 	u8 *buf;
 	int len;
 	int temp;
@@ -564,13 +565,14 @@ advance:
 	if (cdc_ncm_setup(ctx))
 		goto error2;
 
-	/* configure data interface */
-	temp = usb_set_interface(dev->udev, iface_no, CDC_NCM_ALTSETTING_DATA);
-	if (temp)
+	/* find the data interface altsetting */
+	data_altsetting =
+		usb_altnum_to_altsetting(ctx->data, CDC_NCM_ALTSETTING_DATA);
+	if (data_altsetting == NULL)
 		goto error2;
 
-	cdc_ncm_find_endpoints(ctx, ctx->data);
-	cdc_ncm_find_endpoints(ctx, ctx->control);
+	cdc_ncm_find_endpoints(ctx, data_altsetting);
+	cdc_ncm_find_endpoints(ctx, ctx->control->cur_altsetting);
 
 	if ((ctx->in_ep == NULL) || (ctx->out_ep == NULL) ||
 	    (ctx->status_ep == NULL))
@@ -1082,6 +1084,23 @@ error:
 	return 0;
 }
 
+static int cdc_ncm_reset(struct usbnet *dev)
+{
+	struct cdc_ncm_ctx *ctx;
+	int temp;
+	u8 iface_no;
+
+	ctx = (struct cdc_ncm_ctx *)dev->data[0];
+	iface_no = ctx->data->cur_altsetting->desc.bInterfaceNumber;
+
+	/* configure data interface */
+	temp = usb_set_interface(dev->udev, iface_no, CDC_NCM_ALTSETTING_DATA);
+	if (temp)
+		return temp;
+
+	return 0;
+}
+
 static void
 cdc_ncm_speed_change(struct cdc_ncm_ctx *ctx,
 		     struct usb_cdc_speed_change *data)
@@ -1214,6 +1233,7 @@ static const struct driver_info cdc_ncm_info = {
 	.status = cdc_ncm_status,
 	.rx_fixup = cdc_ncm_rx_fixup,
 	.tx_fixup = cdc_ncm_tx_fixup,
+	.reset = cdc_ncm_reset,
 };
 
 static struct usb_driver cdc_ncm_driver = {
-- 
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
