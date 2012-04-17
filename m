From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: qmi_wwan: support Sierra Wireless MC77xx devices in QMI mode
Date: Tue, 17 Apr 2012 21:38:23 +0200
Message-ID: <1334691503-31787-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39389 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763Ab2DQTia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 15:38:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MC77xx devices can operate in two modes: "Direct IP" or "QMI",
switchable using a password protected AT command.  Both product ID
and USB interface configuration will change when switched.

The "sierra_net" driver supports the "Direct IP" mode.  This driver
supports the "QMI" mode.

There are also multiple possible USB interface configurations in each
mode, some providing more than one wwan interface.  Like many other
devices made for Windows, different interface types are identified
using a static interface number.  We define a Sierra specific
interface whitelist to support this.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |   30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 0fcc075..8ffc733 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -486,6 +486,27 @@ static const struct driver_info	qmi_wwan_force_int=
4 =3D {
 	.data		=3D BIT(4), /* interface whitelist bitmap */
 };
=20
+/* Sierra Wireless provide equally useless interface descriptors
+ * Devices in QMI mode can be switched between two different
+ * configurations:
+ *   a) USB interface #8 is QMI/wwan
+ *   b) USB interfaces #8, #19 and #20 are QMI/wwan
+ *
+ * Both configurations provide a number of other interfaces (serial++)=
,
+ * some of which have the same endpoint configuration as we expect, so
+ * a whitelist or blacklist is necessary.
+ *
+ * FIXME: The below whitelist should include BIT(20).  It does not
+ * because I cannot get it to work...
+ */
+static const struct driver_info	qmi_wwan_sierra =3D {
+	.description	=3D "Sierra Wireless wwan/QMI device",
+	.flags		=3D FLAG_WWAN,
+	.bind		=3D qmi_wwan_bind_gobi,
+	.unbind		=3D qmi_wwan_unbind_shared,
+	.manage_power	=3D qmi_wwan_manage_power,
+	.data		=3D BIT(8) | BIT(19), /* interface whitelist bitmap */
+};
=20
 #define HUAWEI_VENDOR_ID	0x12D1
 #define QMI_GOBI_DEVICE(vend, prod) \
@@ -566,6 +587,15 @@ static const struct usb_device_id products[] =3D {
 		.bInterfaceProtocol =3D 0xff,
 		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
 	},
+	{	/* Sierra Wireless MC77xx in QMI mode */
+		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
+		.idVendor           =3D 0x1199,
+		.idProduct          =3D 0x68a2,
+		.bInterfaceClass    =3D 0xff,
+		.bInterfaceSubClass =3D 0xff,
+		.bInterfaceProtocol =3D 0xff,
+		.driver_info        =3D (unsigned long)&qmi_wwan_sierra,
+	},
 	{QMI_GOBI_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
 	{QMI_GOBI_DEVICE(0x03f0, 0x1f1d)},	/* HP un2400 Gobi Modem Device */
 	{QMI_GOBI_DEVICE(0x03f0, 0x371d)},	/* HP un2430 Mobile Broadband Modu=
le */
--=20
1.7.9.5
