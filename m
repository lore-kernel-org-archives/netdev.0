From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 11/24] net: cdc_ncm: only the control intf can be probed
Date: Fri,  1 Nov 2013 11:16:48 +0100
Message-ID: <1383301021-16613-12-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49961 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755886Ab3KAKRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:22 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The probed interface must be the master/control interface of the
function.  Make this explicit and simplify redundant tests.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 435fcc7..5aa3e60 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -394,6 +394,9 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct =
usb_interface *intf, u8 data_
 	/* store ctx pointer in device data field */
 	dev->data[0] =3D (unsigned long)ctx;
=20
+	/* only the control interface can be successfully probed */
+	ctx->control =3D intf;
+
 	/* get some pointers */
 	driver =3D driver_of(intf);
 	buf =3D intf->cur_altsetting->extra;
@@ -411,9 +414,10 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct=
 usb_interface *intf, u8 data_
 				break;
=20
 			union_desc =3D (const struct usb_cdc_union_desc *)buf;
-
-			ctx->control =3D usb_ifnum_to_if(dev->udev,
-						       union_desc->bMasterInterface0);
+			/* the master must be the interface we are probing */
+			if (intf->cur_altsetting->desc.bInterfaceNumber !=3D
+			    union_desc->bMasterInterface0)
+				goto error;
 			ctx->data =3D usb_ifnum_to_if(dev->udev,
 						    union_desc->bSlaveInterface0);
 			break;
@@ -459,14 +463,12 @@ advance:
=20
 	/* some buggy devices have an IAD but no CDC Union */
 	if (!union_desc && intf->intf_assoc && intf->intf_assoc->bInterfaceCo=
unt =3D=3D 2) {
-		ctx->control =3D intf;
 		ctx->data =3D usb_ifnum_to_if(dev->udev, intf->cur_altsetting->desc.=
bInterfaceNumber + 1);
 		dev_dbg(&intf->dev, "CDC Union missing - got slave from IAD\n");
 	}
=20
 	/* check if we got everything */
-	if ((ctx->control =3D=3D NULL) || (ctx->data =3D=3D NULL) ||
-	    ((!ctx->mbim_desc) && ((ctx->ether_desc =3D=3D NULL) || (ctx->con=
trol !=3D intf))))
+	if (!ctx->data || (!ctx->mbim_desc && !ctx->ether_desc))
 		goto error;
=20
 	/* claim data interface, if different from control */
--=20
1.7.10.4
