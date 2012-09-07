From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 2/2] net: qmi_wwan: use a single bind function for all device types
Date: Fri,  7 Sep 2012 19:36:07 +0200
Message-ID: <1347039367-12399-3-git-send-email-bjorn@mork.no>
References: <1347039367-12399-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42937 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503Ab2IGRgW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2012 13:36:22 -0400
In-Reply-To: <1347039367-12399-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactoring the bind code lets us use a common driver_info struct
for all supported devices, simplifying the code a bit.  The
real advantage is that devices using the CDC ECM interface
layout now also can be added dynamically using the new_id sysfs
interface.  This simplifies testing of new devices.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |   45 ++++++++++++++++--------------------=
--------
 1 file changed, 16 insertions(+), 29 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 516653f..8492333 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -139,10 +139,18 @@ static int qmi_wwan_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
=20
 	BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data) < sizeof(struct qmi_=
wwan_state)));
=20
-	/* require a single interrupt status endpoint for subdriver */
+	/* control and data is shared? */
+	if (intf->cur_altsetting->desc.bNumEndpoints =3D=3D 3) {
+		info->control =3D intf;
+		info->data =3D intf;
+		goto shared;
+	}
+
+	/* else require a single interrupt status endpoint on control intf */
 	if (intf->cur_altsetting->desc.bNumEndpoints !=3D 1)
 		goto err;
=20
+	/* and a number of CDC descriptors */
 	while (len > 3) {
 		struct usb_descriptor_header *h =3D (void *)buf;
=20
@@ -231,8 +239,9 @@ next_desc:
 	if (status < 0)
 		goto err;
=20
+shared:
 	status =3D qmi_wwan_register_subdriver(dev);
-	if (status < 0) {
+	if (status < 0 && info->control !=3D info->data) {
 		usb_set_intfdata(info->data, NULL);
 		usb_driver_release_interface(driver, info->data);
 	}
@@ -241,20 +250,6 @@ err:
 	return status;
 }
=20
-/* Some devices combine the "control" and "data" functions into a
- * single interface with all three endpoints: interrupt + bulk in and
- * out
- */
-static int qmi_wwan_bind_shared(struct usbnet *dev, struct usb_interfa=
ce *intf)
-{
-	struct qmi_wwan_state *info =3D (void *)&dev->data;
-
-	/*  control and data is shared */
-	info->control =3D intf;
-	info->data =3D intf;
-	return qmi_wwan_register_subdriver(dev);
-}
-
 static void qmi_wwan_unbind(struct usbnet *dev, struct usb_interface *=
intf)
 {
 	struct qmi_wwan_state *info =3D (void *)&dev->data;
@@ -330,20 +325,12 @@ static const struct driver_info	qmi_wwan_info =3D=
 {
 	.manage_power	=3D qmi_wwan_manage_power,
 };
=20
-static const struct driver_info	qmi_wwan_shared =3D {
-	.description	=3D "WWAN/QMI device",
-	.flags		=3D FLAG_WWAN,
-	.bind		=3D qmi_wwan_bind_shared,
-	.unbind		=3D qmi_wwan_unbind,
-	.manage_power	=3D qmi_wwan_manage_power,
-};
-
 #define HUAWEI_VENDOR_ID	0x12D1
=20
 /* map QMI/wwan function by a fixed interface number */
 #define QMI_FIXED_INTF(vend, prod, num) \
 	USB_DEVICE_INTERFACE_NUMBER(vend, prod, num), \
-	.driver_info =3D (unsigned long)&qmi_wwan_shared
+	.driver_info =3D (unsigned long)&qmi_wwan_info
=20
 /* Gobi 1000 QMI/wwan interface number is 3 according to qcserial */
 #define QMI_GOBI1K_DEVICE(vend, prod) \
@@ -367,15 +354,15 @@ static const struct usb_device_id products[] =3D =
{
 	/* 2. Combined interface devices matching on class+protocol */
 	{	/* Huawei E392, E398 and possibly others in "Windows mode" */
 		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPE=
C, 1, 17),
-		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
+		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
 	{	/* Pantech UML290 */
 		USB_DEVICE_AND_INTERFACE_INFO(0x106c, 0x3718, USB_CLASS_VENDOR_SPEC,=
 0xf0, 0xff),
-		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
+		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
 	{	/* Pantech UML290 - newer firmware */
 		USB_DEVICE_AND_INTERFACE_INFO(0x106c, 0x3718, USB_CLASS_VENDOR_SPEC,=
 0xf1, 0xff),
-		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
+		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
=20
 	/* 3. Combined interface devices matching on interface number */
@@ -457,7 +444,7 @@ static int qmi_wwan_probe(struct usb_interface *int=
f, const struct usb_device_id
 	 */
 	if (!id->driver_info) {
 		dev_dbg(&intf->dev, "setting defaults for dynamic device id\n");
-		id->driver_info =3D (unsigned long)&qmi_wwan_shared;
+		id->driver_info =3D (unsigned long)&qmi_wwan_info;
 	}
=20
 	return usbnet_probe(intf, id);
--=20
1.7.10.4
