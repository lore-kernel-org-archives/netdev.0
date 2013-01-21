From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net 1/3] net: cdc_ncm: workaround for missing CDC Union
Date: Mon, 21 Jan 2013 16:50:38 +0100
Message-ID: <1358783440-11459-2-git-send-email-bjorn@mork.no>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>,
	Oliver Neukum <oneukum@suse.de>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39570 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612Ab3AUPvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 10:51:42 -0500
In-Reply-To: <1358783440-11459-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Cc: Greg Suarez <gsuarez@smithmicro.com>
Cc: Alexey Orishko <alexey.orishko@stericsson.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |   27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 71b6e92..4041159 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -344,6 +344,23 @@ static const struct ethtool_ops cdc_ncm_ethtool_op=
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
+		if (!iad)
+			break;
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
@@ -435,6 +452,16 @@ advance:
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
