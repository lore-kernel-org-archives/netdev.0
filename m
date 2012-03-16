From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH usb-next 2/2] net: qmi_wwan: add support for ZTE MF820D
Date: Fri, 16 Mar 2012 15:41:27 +0100
Message-ID: <1331908887-14068-3-git-send-email-bjorn@mork.no>
References: <1331908887-14068-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org
To: linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:47919 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965379Ab2CPOmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2012 10:42:09 -0400
In-Reply-To: <1331908887-14068-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ZTE have yet to discover the magic of USB descriptors.  These
devices use ff/ff/ff for class/subclass/protocol regardless of
function, except for usb-storage.  Use an interface number
whitelist to force the driver to bind only to the QMI/wwan
interface.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
Hello Greg and David,

is it possible to get this into the queue for 3.4 via usb-next as
well? It was supposed to be a simple pid/vid addition, but the
ZTE descriptor stupidity requires us to match on USB interface
numbers.


Bj=C3=B8rn


 drivers/net/usb/qmi_wwan.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index e14479d..aac68f5 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -214,6 +214,20 @@ static int qmi_wwan_bind_shared(struct usbnet *dev=
, struct usb_interface *intf)
 	struct usb_driver *subdriver =3D NULL;
 	atomic_t *pmcount =3D (void *)&dev->data[1];
=20
+	/* ZTE makes devices where the interface descriptors and endpoint
+	 * configurations of two or more interfaces are identical, even
+	 * though the functions are completely different.  If set, then
+	 * driver_info->data is a bitmap of acceptable interface numbers
+	 * allowing us to bind to one such interface without binding to
+	 * all of them
+	 */
+	if (dev->driver_info->data &&
+	    !test_bit(intf->cur_altsetting->desc.bInterfaceNumber, &dev->driv=
er_info->data)) {
+		dev_info(&intf->dev, "not on our whitelist - ignored");
+		rv =3D -ENODEV;
+		goto err;
+	}
+
 	atomic_set(pmcount, 0);
=20
 	/* collect all three endpoints */
@@ -341,6 +355,17 @@ static const struct driver_info	qmi_wwan_gobi =3D =
{
 	.manage_power	=3D qmi_wwan_manage_power,
 };
=20
+/* ZTE suck at making USB descriptors */
+static const struct driver_info	qmi_wwan_force_int4 =3D {
+	.description	=3D "Qualcomm Gobi wwan/QMI device",
+	.flags		=3D FLAG_WWAN,
+	.bind		=3D qmi_wwan_bind_gobi,
+	.unbind		=3D qmi_wwan_unbind_shared,
+	.manage_power	=3D qmi_wwan_manage_power,
+	.data		=3D BIT(4), /* interface whitelist bitmap */
+};
+
+
 #define HUAWEI_VENDOR_ID	0x12D1
 #define QMI_GOBI_DEVICE(vend, prod) \
 	USB_DEVICE(vend, prod), \
@@ -375,6 +400,15 @@ static const struct usb_device_id products[] =3D {
 		.bInterfaceProtocol =3D 0xff,
 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
 	},
+	{	/* ZTE MF820D */
+		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
+		.idVendor           =3D 0x19d2,
+		.idProduct          =3D 0x0167,
+		.bInterfaceClass    =3D 0xff,
+		.bInterfaceSubClass =3D 0xff,
+		.bInterfaceProtocol =3D 0xff,
+		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
+	},
 	{QMI_GOBI_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
 	{QMI_GOBI_DEVICE(0x03f0, 0x1f1d)},	/* HP un2400 Gobi Modem Device */
 	{QMI_GOBI_DEVICE(0x03f0, 0x371d)},	/* HP un2430 Mobile Broadband Modu=
le */
--=20
1.7.2.5
