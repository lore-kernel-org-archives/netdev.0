From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 04/24] net: cdc_ncm: remove redundant endpoint pointers
Date: Fri,  1 Nov 2013 11:16:41 +0100
Message-ID: <1383301021-16613-5-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49973 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755921Ab3KAKRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:22 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to duplicate stuff already in the common usbnet
struct.  We still need to keep our special find_endpoints
function because we need explicit control over the selected
altsetting.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c   |   38 +++++++++++++++++++----------------=
---
 include/linux/usb/cdc_ncm.h |    3 ---
 2 files changed, 19 insertions(+), 22 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index bfab879..a989bd5 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -292,9 +292,9 @@ max_dgram_err:
 }
=20
 static void
-cdc_ncm_find_endpoints(struct cdc_ncm_ctx *ctx, struct usb_interface *=
intf)
+cdc_ncm_find_endpoints(struct usbnet *dev, struct usb_interface *intf)
 {
-	struct usb_host_endpoint *e;
+	struct usb_host_endpoint *e, *in =3D NULL, *out =3D NULL;
 	u8 ep;
=20
 	for (ep =3D 0; ep < intf->cur_altsetting->desc.bNumEndpoints; ep++) {
@@ -303,18 +303,18 @@ cdc_ncm_find_endpoints(struct cdc_ncm_ctx *ctx, s=
truct usb_interface *intf)
 		switch (e->desc.bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) {
 		case USB_ENDPOINT_XFER_INT:
 			if (usb_endpoint_dir_in(&e->desc)) {
-				if (ctx->status_ep =3D=3D NULL)
-					ctx->status_ep =3D e;
+				if (!dev->status)
+					dev->status =3D e;
 			}
 			break;
=20
 		case USB_ENDPOINT_XFER_BULK:
 			if (usb_endpoint_dir_in(&e->desc)) {
-				if (ctx->in_ep =3D=3D NULL)
-					ctx->in_ep =3D e;
+				if (!in)
+					in =3D e;
 			} else {
-				if (ctx->out_ep =3D=3D NULL)
-					ctx->out_ep =3D e;
+				if (!out)
+					out =3D e;
 			}
 			break;
=20
@@ -322,6 +322,14 @@ cdc_ncm_find_endpoints(struct cdc_ncm_ctx *ctx, st=
ruct usb_interface *intf)
 			break;
 		}
 	}
+	if (in && !dev->in)
+		dev->in =3D usb_rcvbulkpipe(dev->udev,
+					  in->desc.bEndpointAddress &
+					  USB_ENDPOINT_NUMBER_MASK);
+	if (out && !dev->out)
+		dev->out =3D usb_sndbulkpipe(dev->udev,
+					   out->desc.bEndpointAddress &
+					   USB_ENDPOINT_NUMBER_MASK);
 }
=20
 static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
@@ -477,11 +485,9 @@ advance:
 	if (temp)
 		goto error2;
=20
-	cdc_ncm_find_endpoints(ctx, ctx->data);
-	cdc_ncm_find_endpoints(ctx, ctx->control);
-
-	if ((ctx->in_ep =3D=3D NULL) || (ctx->out_ep =3D=3D NULL) ||
-	    (ctx->status_ep =3D=3D NULL))
+	cdc_ncm_find_endpoints(dev, ctx->data);
+	cdc_ncm_find_endpoints(dev, ctx->control);
+	if (!dev->in || !dev->out || !dev->status)
 		goto error2;
=20
 	dev->net->ethtool_ops =3D &cdc_ncm_ethtool_ops;
@@ -496,12 +502,6 @@ advance:
 		dev_info(&dev->udev->dev, "MAC-Address: %pM\n", dev->net->dev_addr);
 	}
=20
-
-	dev->in =3D usb_rcvbulkpipe(dev->udev,
-		ctx->in_ep->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
-	dev->out =3D usb_sndbulkpipe(dev->udev,
-		ctx->out_ep->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
-	dev->status =3D ctx->status_ep;
 	dev->rx_urb_size =3D ctx->rx_max;
=20
 	/* cdc_ncm_setup will override dwNtbOutMaxSize if it is
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index c14e00f..36e1e15 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -100,9 +100,6 @@ struct cdc_ncm_ctx {
=20
 	struct net_device *netdev;
 	struct usb_device *udev;
-	struct usb_host_endpoint *in_ep;
-	struct usb_host_endpoint *out_ep;
-	struct usb_host_endpoint *status_ep;
 	struct usb_interface *control;
 	struct usb_interface *data;
=20
--=20
1.7.10.4
