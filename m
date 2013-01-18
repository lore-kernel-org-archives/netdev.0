From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Fri, 18 Jan 2013 15:25:47 +0100
Message-ID: <1358519147-10073-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adding support for the MBIM mode in some Sierra Wireless devices.

Some Sierra Wireless firmwares support CDC MBIM but have no CDC
Union funtional descriptor. This violates the MBIM specification,
but we can easily work around the bug by looking at the Interface
Association Descriptor instead.  This is most likely what
Windows uses too, which explains how the firmware bug has gone
unnoticed until now.

This change will not affect any currently supported device
conforming to the NCM or MBIM specifications, as they must have
the CDC Union descriptor.

Cc: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
Cc: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 71b6e92..5c1210f 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -344,6 +344,21 @@ static const struct ethtool_ops cdc_ncm_ethtool_op=
s =3D {
 	.nway_reset =3D usbnet_nway_reset,
 };
=20
+/* return first slave interface if an IAD matches the given master */
+static struct usb_interface *get_iad_slave(struct usb_device *udev,
+					   struct usb_interface *master) {
+	int i;
+	struct usb_interface_assoc_descriptor *iad;
+	u8 mnum =3D master->cur_altsetting->desc.bInterfaceNumber;
+
+	for (i =3D 0; i < USB_MAXIADS; i++) {
+		iad =3D udev->actconfig->intf_assoc[i];
+		if (iad->bFirstInterface =3D=3D mnum && iad->bInterfaceCount =3D=3D =
2)
+			return usb_ifnum_to_if(udev, mnum + 1);
+	}
+	return NULL;
+}
+
 int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf=
, u8 data_altsetting)
 {
 	struct cdc_ncm_ctx *ctx;
@@ -435,6 +450,16 @@ advance:
 		len -=3D temp;
 	}
=20
+	/* some buggy devices have an IAD but no CDC Union */
+	if (!ctx->union_desc) {
+		dev_dbg(&intf->dev, "missing CDC Union descriptor\n");
+		ctx->data =3D get_iad_slave(dev->udev, intf);
+		if (ctx->data) {
+			ctx->control =3D intf;
+			dev_dbg(&intf->dev, "got slave from IAD\n");
+		}
+	}
+
 	/* check if we got everything */
 	if ((ctx->control =3D=3D NULL) || (ctx->data =3D=3D NULL) ||
 	    ((!ctx->mbim_desc) && ((ctx->ether_desc =3D=3D NULL) || (ctx->con=
trol !=3D intf))))
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
