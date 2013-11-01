From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 23/24] net: cdc_ncm: improve bind error debug messages
Date: Fri,  1 Nov 2013 11:17:00 +0100
Message-ID: <1383301021-16613-24-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make it a bit easier for users to figure out what goes
wrong when bind fails.

Cc: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   36 ++++++++++++++++++++++++++----------
 1 file changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index f168bc8..4531f38 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -371,8 +371,10 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct=
 usb_interface *intf, u8 data_
 			union_desc =3D (const struct usb_cdc_union_desc *)buf;
 			/* the master must be the interface we are probing */
 			if (intf->cur_altsetting->desc.bInterfaceNumber !=3D
-			    union_desc->bMasterInterface0)
+			    union_desc->bMasterInterface0) {
+				dev_dbg(&intf->dev, "bogus CDC Union\n");
 				goto error;
+			}
 			ctx->data =3D usb_ifnum_to_if(dev->udev,
 						    union_desc->bSlaveInterface0);
 			break;
@@ -416,45 +418,59 @@ advance:
 	}
=20
 	/* check if we got everything */
-	if (!ctx->data || (!ctx->mbim_desc && !ctx->ether_desc))
+	if (!ctx->data || (!ctx->mbim_desc && !ctx->ether_desc)) {
+		dev_dbg(&intf->dev, "CDC descriptors missing\n");
 		goto error;
+	}
=20
 	/* claim data interface, if different from control */
 	if (ctx->data !=3D ctx->control) {
 		temp =3D usb_driver_claim_interface(driver, ctx->data, dev);
-		if (temp)
+		if (temp) {
+			dev_dbg(&intf->dev, "failed to claim data intf\n");
 			goto error;
+		}
 	}
=20
 	iface_no =3D ctx->data->cur_altsetting->desc.bInterfaceNumber;
=20
 	/* reset data interface */
 	temp =3D usb_set_interface(dev->udev, iface_no, 0);
-	if (temp)
+	if (temp) {
+		dev_dbg(&intf->dev, "set interface failed\n");
 		goto error2;
+	}
=20
 	/* configure data interface */
 	temp =3D usb_set_interface(dev->udev, iface_no, data_altsetting);
-	if (temp)
+	if (temp) {
+		dev_dbg(&intf->dev, "set interface failed\n");
 		goto error2;
+	}
=20
 	cdc_ncm_find_endpoints(dev, ctx->data);
 	cdc_ncm_find_endpoints(dev, ctx->control);
-	if (!dev->in || !dev->out || !dev->status)
+	if (!dev->in || !dev->out || !dev->status) {
+		dev_dbg(&intf->dev, "failed to collect endpoints\n");
 		goto error2;
+	}
=20
 	/* initialize data interface */
-	if (cdc_ncm_setup(dev))
+	if (cdc_ncm_setup(dev))	{
+		dev_dbg(&intf->dev, "cdc_ncm_setup() failed\n");
 		goto error2;
+	}
=20
 	usb_set_intfdata(ctx->data, dev);
 	usb_set_intfdata(ctx->control, dev);
=20
 	if (ctx->ether_desc) {
 		temp =3D usbnet_get_ethernet_addr(dev, ctx->ether_desc->iMACAddress)=
;
-		if (temp)
+		if (temp) {
+			dev_dbg(&intf->dev, "failed to get mac address\n");
 			goto error2;
-		dev_info(&dev->udev->dev, "MAC-Address: %pM\n", dev->net->dev_addr);
+		}
+		dev_info(&intf->dev, "MAC-Address: %pM\n", dev->net->dev_addr);
 	}
=20
 	/* usbnet use these values for sizing tx/rx queues */
@@ -471,7 +487,7 @@ error2:
 error:
 	cdc_ncm_free((struct cdc_ncm_ctx *)dev->data[0]);
 	dev->data[0] =3D 0;
-	dev_info(&dev->udev->dev, "bind() failure\n");
+	dev_info(&intf->dev, "bind() failure\n");
 	return -ENODEV;
 }
 EXPORT_SYMBOL_GPL(cdc_ncm_bind_common);
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
