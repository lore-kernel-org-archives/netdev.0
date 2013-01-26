From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: cdc_ncm: use IAD provided by the USB core
Date: Sat, 26 Jan 2013 10:36:59 +0100
Message-ID: <1359193020-12873-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42104 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753011Ab3AZJh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jan 2013 04:37:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9992c2e (net: cdc_ncm: workaround for missing CDC Union)
added code to lookup an IAD for the interface we are probing.
This is redundant.  The USB core has already done the lookup
and saved the result in the USB interface struct.  Use that
instead.

Cc: Greg Suarez <gsuarez@smithmicro.com>
Cc: Alexey Orishko <alexey.orishko@stericsson.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
Hello,

I just realized that my workaround for the missing CDC Union was
unnecessarily complex.  I was not aware of the per-interface
intf_assoc pointer.

Guess this cleanup may come a little too late for 3.8, but that's
up to David to decide of course.  FWIW, the patch touches *only*
code which were added by commit 9992c2e.


Bj=C3=B8rn

 drivers/net/usb/cdc_ncm.c |   28 ++++------------------------
 1 file changed, 4 insertions(+), 24 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index f94711c..9197b2c 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -344,23 +344,6 @@ static const struct ethtool_ops cdc_ncm_ethtool_op=
s =3D {
 	.nway_reset =3D usbnet_nway_reset,
 };
=20
-/* return first slave interface if an IAD matches the given master */
-static struct usb_interface *get_iad_slave(struct usb_device *udev,
-					   struct usb_interface *master) {
-	int i;
-	struct usb_interface_assoc_descriptor *iad;
-	u8 mnum =3D master->cur_altsetting->desc.bInterfaceNumber;
-
-	for (i =3D 0; i < USB_MAXIADS; i++) {
-		iad =3D udev->actconfig->intf_assoc[i];
-		if (!iad)
-			break;
-		if (iad->bFirstInterface =3D=3D mnum && iad->bInterfaceCount =3D=3D =
2)
-			return usb_ifnum_to_if(udev, mnum + 1);
-	}
-	return NULL;
-}
-
 int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf=
, u8 data_altsetting)
 {
 	struct cdc_ncm_ctx *ctx;
@@ -453,13 +436,10 @@ advance:
 	}
=20
 	/* some buggy devices have an IAD but no CDC Union */
-	if (!ctx->union_desc) {
-		dev_dbg(&intf->dev, "missing CDC Union descriptor\n");
-		ctx->data =3D get_iad_slave(dev->udev, intf);
-		if (ctx->data) {
-			ctx->control =3D intf;
-			dev_dbg(&intf->dev, "got slave from IAD\n");
-		}
+	if (!ctx->union_desc && intf->intf_assoc && intf->intf_assoc->bInterf=
aceCount =3D=3D 2) {
+		ctx->control =3D intf;
+		ctx->data =3D usb_ifnum_to_if(dev->udev, intf->cur_altsetting->desc.=
bInterfaceNumber + 1);
+		dev_dbg(&intf->dev, "CDC Union missing - got slave from IAD\n");
 	}
=20
 	/* check if we got everything */
--=20
1.7.10.4
