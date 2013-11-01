From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 10/24] net: cdc_ncm: remove descriptor pointers
Date: Fri,  1 Nov 2013 11:16:47 +0100
Message-ID: <1383301021-16613-11-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49966 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755892Ab3KAKRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:22 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

header_desc was completely unused and union_desc was never used
outside cdc_ncm_bind_common.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c   |   12 ++++++------
 include/linux/usb/cdc_ncm.h |    4 +---
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index b8de8dd..435fcc7 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -372,6 +372,7 @@ static const struct ethtool_ops cdc_ncm_ethtool_ops=
 =3D {
=20
 int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf=
, u8 data_altsetting)
 {
+	const struct usb_cdc_union_desc *union_desc =3D NULL;
 	struct cdc_ncm_ctx *ctx;
 	struct usb_driver *driver;
 	u8 *buf;
@@ -406,16 +407,15 @@ int cdc_ncm_bind_common(struct usbnet *dev, struc=
t usb_interface *intf, u8 data_
=20
 		switch (buf[2]) {
 		case USB_CDC_UNION_TYPE:
-			if (buf[0] < sizeof(*(ctx->union_desc)))
+			if (buf[0] < sizeof(*union_desc))
 				break;
=20
-			ctx->union_desc =3D
-					(const struct usb_cdc_union_desc *)buf;
+			union_desc =3D (const struct usb_cdc_union_desc *)buf;
=20
 			ctx->control =3D usb_ifnum_to_if(dev->udev,
-					ctx->union_desc->bMasterInterface0);
+						       union_desc->bMasterInterface0);
 			ctx->data =3D usb_ifnum_to_if(dev->udev,
-					ctx->union_desc->bSlaveInterface0);
+						    union_desc->bSlaveInterface0);
 			break;
=20
 		case USB_CDC_ETHERNET_TYPE:
@@ -458,7 +458,7 @@ advance:
 	}
=20
 	/* some buggy devices have an IAD but no CDC Union */
-	if (!ctx->union_desc && intf->intf_assoc && intf->intf_assoc->bInterf=
aceCount =3D=3D 2) {
+	if (!union_desc && intf->intf_assoc && intf->intf_assoc->bInterfaceCo=
unt =3D=3D 2) {
 		ctx->control =3D intf;
 		ctx->data =3D usb_ifnum_to_if(dev->udev, intf->cur_altsetting->desc.=
bInterfaceNumber + 1);
 		dev_dbg(&intf->dev, "CDC Union missing - got slave from IAD\n");
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 89b52a0..cad54ad 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -92,9 +92,7 @@ struct cdc_ncm_ctx {
 	struct tasklet_struct bh;
=20
 	const struct usb_cdc_ncm_desc *func_desc;
-	const struct usb_cdc_mbim_desc   *mbim_desc;
-	const struct usb_cdc_header_desc *header_desc;
-	const struct usb_cdc_union_desc *union_desc;
+	const struct usb_cdc_mbim_desc *mbim_desc;
 	const struct usb_cdc_ether_desc *ether_desc;
=20
 	struct usb_interface *control;
--=20
1.7.10.4
