From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: cdc_ncm: add Huawei devices
Date: Tue, 13 Nov 2012 14:19:43 +0100
Message-ID: <1352812783-741-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alexey ORISHKO <alexey.orishko@stericsson.com>,
	Tommy Cheng <tommy7765@yahoo.com>,
	Olof Ermis <olof.ermis@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:45719 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753250Ab2KMNUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 08:20:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of Huawei 3G and LTE modems implement a CDC NCM function,
including the necessary functional descriptors, but using a non
standard interface layout and class/subclass/protocol codes.

These devices can be handled by this driver with only a minor
change to the probing logic, allowing a single combined control
and data interface.  This works because the devices
- include a CDC Union descriptor labelling the combined
  interface as both master and slave, and
- have an alternate setting #1 for the bulk endpoints on the
  combined interface.

The 3G/LTE network connection is managed by vendor specific AT
commands on a serial function in the same composite device.
Handling the managment function is out of the scope of this
driver.  It will be handled by an appropriate USB serial
driver.

Reported-and-Tested-by: Olof Ermis <olof.ermis@gmail.com>
Reported-and-Tested-by: Tommy Cheng <tommy7765@yahoo.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
Hello David,

This patch had to touch more than just the device id table to
deal with the combined NCM interface on these devices.  The
changes will not affect any currently supported devices because
(ctx->data !=3D ctx->control) always is true for those.

I am therefore requesting that this patch is put in the stable
queue like other device additons.

I guess it may be too late for v3.7, but FWIW I have verified
that the patch applies cleanly to both the current net-next/master
and to net/master, and will not cause merge conflicts either way.
I have also verified that it applies cleanly to the v3.6.6 stable
release.


Bj=C3=B8rn

 drivers/net/usb/cdc_ncm.c |   22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4cd582a..74fab1a 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -540,10 +540,12 @@ advance:
 	    (ctx->ether_desc =3D=3D NULL) || (ctx->control !=3D intf))
 		goto error;
=20
-	/* claim interfaces, if any */
-	temp =3D usb_driver_claim_interface(driver, ctx->data, dev);
-	if (temp)
-		goto error;
+	/* claim data interface, if different from control */
+	if (ctx->data !=3D ctx->control) {
+		temp =3D usb_driver_claim_interface(driver, ctx->data, dev);
+		if (temp)
+			goto error;
+	}
=20
 	iface_no =3D ctx->data->cur_altsetting->desc.bInterfaceNumber;
=20
@@ -623,6 +625,10 @@ static void cdc_ncm_unbind(struct usbnet *dev, str=
uct usb_interface *intf)
=20
 	tasklet_kill(&ctx->bh);
=20
+	/* handle devices with combined control and data interface */
+	if (ctx->control =3D=3D ctx->data)
+		ctx->data =3D NULL;
+
 	/* disconnect master --> disconnect slave */
 	if (intf =3D=3D ctx->control && ctx->data) {
 		usb_set_intfdata(ctx->data, NULL);
@@ -1245,6 +1251,14 @@ static const struct usb_device_id cdc_devs[] =3D=
 {
 	  .driver_info =3D (unsigned long) &wwan_info,
 	},
=20
+	/* Huawei NCM devices disguised as vendor specific */
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x16),
+	  .driver_info =3D (unsigned long)&wwan_info,
+	},
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x46),
+	  .driver_info =3D (unsigned long)&wwan_info,
+	},
+
 	/* Generic CDC-NCM devices */
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM,
 		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
--=20
1.7.10.4
