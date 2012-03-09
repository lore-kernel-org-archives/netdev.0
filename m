From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH RESEND v3 2/2] net: qmi_wwan: add Gobi and Pantech UML290 device IDs
Date: Fri,  9 Mar 2012 12:35:06 +0100
Message-ID: <1331292906-7467-3-git-send-email-bjorn@mork.no>
References: <20120308185324.GA13836@kroah.com>
 <1331292906-7467-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39282 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab2CILfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2012 06:35:50 -0500
In-Reply-To: <1331292906-7467-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding the Pantech UML290 and all non-QDL Gobi device IDs from the
qcserial driver now that we have support for shared net/QMI USB
interfaces.  Most of these are not yet tested with this driver, but
should be mostly identical to tested devices, except for device IDs.

Gobi devices provide several different interfaces (serial/net/other)
using the exact same class, subclass and protocol values.  This driver
will only support the net/QMI function while there are other drivers
supporting other device functions. The net/QMI interface number may
also differ from device to device.  It has been noted that all the
other interfaces have additional functional descriptors, so we use that
to detect the interface supported by this driver.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
Previously sent as patch number 5/5.

 drivers/net/usb/qmi_wwan.c |   82 ++++++++++++++++++++++++++++++++++++=
+++++++-
 1 files changed, 81 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index a61c7a1..e14479d 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -243,6 +243,29 @@ err:
 	return rv;
 }
=20
+/* Gobi devices uses identical class/protocol codes for all interfaces=
 regardless
+ * of function. Some of these are CDC ACM like and have the exact same=
 endpoints
+ * we are looking for. This leaves two possible strategies for identif=
ying the
+ * correct interface:
+ *   a) hardcoding interface number, or
+ *   b) use the fact that the wwan interface is the only one lacking a=
dditional
+ *      (CDC functional) descriptors
+ *
+ * Let's see if we can get away with the generic b) solution.
+ */
+static int qmi_wwan_bind_gobi(struct usbnet *dev, struct usb_interface=
 *intf)
+{
+	int rv =3D -EINVAL;
+
+	/* ignore any interface with additional descriptors */
+	if (intf->cur_altsetting->extralen)
+		goto err;
+
+	rv =3D qmi_wwan_bind_shared(dev, intf);
+err:
+	return rv;
+}
+
 static void qmi_wwan_unbind_shared(struct usbnet *dev, struct usb_inte=
rface *intf)
 {
 	struct usb_driver *subdriver =3D (void *)dev->data[0];
@@ -310,7 +333,18 @@ static const struct driver_info	qmi_wwan_shared =3D=
 {
 	.manage_power	=3D qmi_wwan_manage_power,
 };
=20
+static const struct driver_info	qmi_wwan_gobi =3D {
+	.description	=3D "Qualcomm Gobi wwan/QMI device",
+	.flags		=3D FLAG_WWAN,
+	.bind		=3D qmi_wwan_bind_gobi,
+	.unbind		=3D qmi_wwan_unbind_shared,
+	.manage_power	=3D qmi_wwan_manage_power,
+};
+
 #define HUAWEI_VENDOR_ID	0x12D1
+#define QMI_GOBI_DEVICE(vend, prod) \
+	USB_DEVICE(vend, prod), \
+	.driver_info =3D (unsigned long)&qmi_wwan_gobi
=20
 static const struct usb_device_id products[] =3D {
 	{	/* Huawei E392, E398 and possibly others sharing both device id and=
 more... */
@@ -332,7 +366,53 @@ static const struct usb_device_id products[] =3D {
 		.bInterfaceProtocol =3D 17,
 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
 	},
-	{ }	/* END */
+	{	/* Pantech UML290 */
+		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
+		.idVendor           =3D 0x106c,
+		.idProduct          =3D 0x3718,
+		.bInterfaceClass    =3D 0xff,
+		.bInterfaceSubClass =3D 0xf0,
+		.bInterfaceProtocol =3D 0xff,
+		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
+	},
+	{QMI_GOBI_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
+	{QMI_GOBI_DEVICE(0x03f0, 0x1f1d)},	/* HP un2400 Gobi Modem Device */
+	{QMI_GOBI_DEVICE(0x03f0, 0x371d)},	/* HP un2430 Mobile Broadband Modu=
le */
+	{QMI_GOBI_DEVICE(0x04da, 0x250d)},	/* Panasonic Gobi Modem device */
+	{QMI_GOBI_DEVICE(0x413c, 0x8172)},	/* Dell Gobi Modem device */
+	{QMI_GOBI_DEVICE(0x1410, 0xa001)},	/* Novatel Gobi Modem device */
+	{QMI_GOBI_DEVICE(0x0b05, 0x1776)},	/* Asus Gobi Modem device */
+	{QMI_GOBI_DEVICE(0x19d2, 0xfff3)},	/* ONDA Gobi Modem device */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9001)},	/* Generic Gobi Modem device */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9002)},	/* Generic Gobi Modem device */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9202)},	/* Generic Gobi Modem device */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9203)},	/* Generic Gobi Modem device */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9222)},	/* Generic Gobi Modem device */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9009)},	/* Generic Gobi Modem device */
+	{QMI_GOBI_DEVICE(0x413c, 0x8186)},	/* Dell Gobi 2000 Modem device (N0=
218, VU936) */
+	{QMI_GOBI_DEVICE(0x05c6, 0x920b)},	/* Generic Gobi 2000 Modem device =
*/
+	{QMI_GOBI_DEVICE(0x05c6, 0x9225)},	/* Sony Gobi 2000 Modem device (N0=
279, VU730) */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9245)},	/* Samsung Gobi 2000 Modem device =
(VL176) */
+	{QMI_GOBI_DEVICE(0x03f0, 0x251d)},	/* HP Gobi 2000 Modem device (VP41=
2) */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9215)},	/* Acer Gobi 2000 Modem device (VP=
413) */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9265)},	/* Asus Gobi 2000 Modem device (VR=
305) */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9235)},	/* Top Global Gobi 2000 Modem devi=
ce (VR306) */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9275)},	/* iRex Technologies Gobi 2000 Mod=
em device (VR307) */
+	{QMI_GOBI_DEVICE(0x1199, 0x9001)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
+	{QMI_GOBI_DEVICE(0x1199, 0x9002)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
+	{QMI_GOBI_DEVICE(0x1199, 0x9003)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
+	{QMI_GOBI_DEVICE(0x1199, 0x9004)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
+	{QMI_GOBI_DEVICE(0x1199, 0x9005)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
+	{QMI_GOBI_DEVICE(0x1199, 0x9006)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
+	{QMI_GOBI_DEVICE(0x1199, 0x9007)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
+	{QMI_GOBI_DEVICE(0x1199, 0x9008)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
+	{QMI_GOBI_DEVICE(0x1199, 0x9009)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
+	{QMI_GOBI_DEVICE(0x1199, 0x900a)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
+	{QMI_GOBI_DEVICE(0x1199, 0x9011)},	/* Sierra Wireless Gobi 2000 Modem=
 device (MC8305) */
+	{QMI_GOBI_DEVICE(0x16d8, 0x8002)},	/* CMDTech Gobi 2000 Modem device =
(VU922) */
+	{QMI_GOBI_DEVICE(0x05c6, 0x9205)},	/* Gobi 2000 Modem device */
+	{QMI_GOBI_DEVICE(0x1199, 0x9013)},	/* Sierra Wireless Gobi 3000 Modem=
 device (MC8355) */
+	{ }					/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);
=20
--=20
1.7.9.1
