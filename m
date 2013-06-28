From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: cdc_ether: allow combined control and data interface
Date: Fri, 28 Jun 2013 17:17:08 +0200
Message-ID: <1372432629-17245-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42805 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751393Ab3F1PRV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 11:17:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Icera based Huawei modems handled by this driver are not
completely CDC ECM compliant, using the same USB interface for both
control and data. The CDC functional descriptors include a Union
naming this interface as both master and slave, so it is supportable
by relaxing the descriptor parsing in case these interfaces are
identical.

This has been tested on a Huawei K3806 and verified to add support
for that device.

Reported-and-tested-by: Enrico Mioso <mrkiko.rs@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ether.c |   24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 04ee044..7d88fef 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -215,6 +215,10 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, st=
ruct usb_interface *intf)
 					goto bad_desc;
 			}
=20
+			/* some devices merge these - skip class check */
+			if (info->control =3D=3D info->data)
+				goto next_desc;
+
 			/* a data interface altsetting does the real i/o */
 			d =3D &info->data->cur_altsetting->desc;
 			if (d->bInterfaceClass !=3D USB_CLASS_CDC_DATA) {
@@ -304,19 +308,23 @@ next_desc:
 	/* claim data interface and set it up ... with side effects.
 	 * network traffic can't flow until an altsetting is enabled.
 	 */
-	status =3D usb_driver_claim_interface(driver, info->data, dev);
-	if (status < 0)
-		return status;
+	if (info->data !=3D info->control) {
+		status =3D usb_driver_claim_interface(driver, info->data, dev);
+		if (status < 0)
+			return status;
+	}
 	status =3D usbnet_get_endpoints(dev, info->data);
 	if (status < 0) {
 		/* ensure immediate exit from usbnet_disconnect */
 		usb_set_intfdata(info->data, NULL);
-		usb_driver_release_interface(driver, info->data);
+		if (info->data !=3D info->control)
+			usb_driver_release_interface(driver, info->data);
 		return status;
 	}
=20
 	/* status endpoint: optional for CDC Ethernet, not RNDIS (or ACM) */
-	dev->status =3D NULL;
+	if (info->data !=3D info->control)
+		dev->status =3D NULL;
 	if (info->control->cur_altsetting->desc.bNumEndpoints =3D=3D 1) {
 		struct usb_endpoint_descriptor	*desc;
=20
@@ -353,7 +361,8 @@ void usbnet_cdc_unbind(struct usbnet *dev, struct u=
sb_interface *intf)
 	if (intf =3D=3D info->control && info->data) {
 		/* ensure immediate exit from usbnet_disconnect */
 		usb_set_intfdata(info->data, NULL);
-		usb_driver_release_interface(driver, info->data);
+		if (info->data !=3D info->control)
+			usb_driver_release_interface(driver, info->data);
 		info->data =3D NULL;
 	}
=20
@@ -361,7 +370,8 @@ void usbnet_cdc_unbind(struct usbnet *dev, struct u=
sb_interface *intf)
 	else if (intf =3D=3D info->data && info->control) {
 		/* ensure immediate exit from usbnet_disconnect */
 		usb_set_intfdata(info->control, NULL);
-		usb_driver_release_interface(driver, info->control);
+		if (info->data !=3D info->control)
+			usb_driver_release_interface(driver, info->control);
 		info->control =3D NULL;
 	}
 }
--=20
1.7.10.4
