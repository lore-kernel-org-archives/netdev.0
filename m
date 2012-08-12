From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net 1/3] net: qmi_wwan: use fixed interface number matching
Date: Sun, 12 Aug 2012 21:16:30 +0200
Message-ID: <1344798992-10176-2-git-send-email-bjorn@mork.no>
References: <1344798992-10176-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41810 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752356Ab2HLTQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2012 15:16:47 -0400
In-Reply-To: <1344798992-10176-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver support many composite USB devices where the
interface class/subclass/protocol provides no information
about the interface function. Interfaces with different
functions may all use ff/ff/ff, like this example of
a device with three serial interfaces and three QMI/wwan
interfaces:

T:  Bus=3D02 Lev=3D01 Prnt=3D01 Port=3D03 Cnt=3D01 Dev#=3D116 Spd=3D480=
  MxCh=3D 0
D:  Ver=3D 2.00 Cls=3D00(>ifc ) Sub=3D00 Prot=3D00 MxPS=3D64 #Cfgs=3D  =
1
P:  Vendor=3D1199 ProdID=3D68a2 Rev=3D 0.06
S:  Manufacturer=3DSierra Wireless, Incorporated
S:  Product=3DMC7710
S:  SerialNumber=3D3581780xxxxxx
C:* #Ifs=3D 6 Cfg#=3D 1 Atr=3De0 MxPwr=3D  0mA
I:* If#=3D 0 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqcserial
E:  Ad=3D81(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D01(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:* If#=3D 2 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqcserial
E:  Ad=3D82(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D02(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:* If#=3D 3 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqcserial
E:  Ad=3D83(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D84(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D03(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:* If#=3D 8 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqmi_wwan
E:  Ad=3D85(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D86(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D04(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:* If#=3D19 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqmi_wwan
E:  Ad=3D87(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D88(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D05(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms
I:* If#=3D20 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3D(none)
E:  Ad=3D89(I) Atr=3D03(Int.) MxPS=3D  64 Ivl=3D2ms
E:  Ad=3D8a(I) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D0ms
E:  Ad=3D06(O) Atr=3D02(Bulk) MxPS=3D 512 Ivl=3D4ms

Instead of class/subclass/protocol the vendor use fixed
interface numbers for each function, and the Windows
drivers use these numbers to match driver and function.

The driver has had its own interface number whitelisting
code to simulate this functionality.  Replace this with
generic interface number matching now that the USB subsystem
support is there. This
 - removes the need for a driver_info structure per
   interface number,
 - avoids running the probe function for unsupported
   interfaces, and
 - simplifies the code.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |  215 ++++++------------------------------=
--------
 1 file changed, 28 insertions(+), 187 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 2ea126a..c6a5873 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -247,30 +247,12 @@ err:
  */
 static int qmi_wwan_bind_shared(struct usbnet *dev, struct usb_interfa=
ce *intf)
 {
-	int rv;
 	struct qmi_wwan_state *info =3D (void *)&dev->data;
=20
-	/* ZTE makes devices where the interface descriptors and endpoint
-	 * configurations of two or more interfaces are identical, even
-	 * though the functions are completely different.  If set, then
-	 * driver_info->data is a bitmap of acceptable interface numbers
-	 * allowing us to bind to one such interface without binding to
-	 * all of them
-	 */
-	if (dev->driver_info->data &&
-	    !test_bit(intf->cur_altsetting->desc.bInterfaceNumber, &dev->driv=
er_info->data)) {
-		dev_info(&intf->dev, "not on our whitelist - ignored");
-		rv =3D -ENODEV;
-		goto err;
-	}
-
 	/*  control and data is shared */
 	info->control =3D intf;
 	info->data =3D intf;
-	rv =3D qmi_wwan_register_subdriver(dev);
-
-err:
-	return rv;
+	return qmi_wwan_register_subdriver(dev);
 }
=20
 static void qmi_wwan_unbind(struct usbnet *dev, struct usb_interface *=
intf)
@@ -356,86 +338,23 @@ static const struct driver_info	qmi_wwan_shared =3D=
 {
 	.manage_power	=3D qmi_wwan_manage_power,
 };
=20
-static const struct driver_info	qmi_wwan_force_int0 =3D {
-	.description	=3D "Qualcomm WWAN/QMI device",
-	.flags		=3D FLAG_WWAN,
-	.bind		=3D qmi_wwan_bind_shared,
-	.unbind		=3D qmi_wwan_unbind,
-	.manage_power	=3D qmi_wwan_manage_power,
-	.data		=3D BIT(0), /* interface whitelist bitmap */
-};
-
-static const struct driver_info	qmi_wwan_force_int1 =3D {
-	.description	=3D "Qualcomm WWAN/QMI device",
-	.flags		=3D FLAG_WWAN,
-	.bind		=3D qmi_wwan_bind_shared,
-	.unbind		=3D qmi_wwan_unbind,
-	.manage_power	=3D qmi_wwan_manage_power,
-	.data		=3D BIT(1), /* interface whitelist bitmap */
-};
-
-static const struct driver_info qmi_wwan_force_int2 =3D {
-	.description	=3D "Qualcomm WWAN/QMI device",
-	.flags		=3D FLAG_WWAN,
-	.bind		=3D qmi_wwan_bind_shared,
-	.unbind		=3D qmi_wwan_unbind,
-	.manage_power	=3D qmi_wwan_manage_power,
-	.data		=3D BIT(2), /* interface whitelist bitmap */
-};
-
-static const struct driver_info	qmi_wwan_force_int3 =3D {
-	.description	=3D "Qualcomm WWAN/QMI device",
-	.flags		=3D FLAG_WWAN,
-	.bind		=3D qmi_wwan_bind_shared,
-	.unbind		=3D qmi_wwan_unbind,
-	.manage_power	=3D qmi_wwan_manage_power,
-	.data		=3D BIT(3), /* interface whitelist bitmap */
-};
-
-static const struct driver_info	qmi_wwan_force_int4 =3D {
-	.description	=3D "Qualcomm WWAN/QMI device",
-	.flags		=3D FLAG_WWAN,
-	.bind		=3D qmi_wwan_bind_shared,
-	.unbind		=3D qmi_wwan_unbind,
-	.manage_power	=3D qmi_wwan_manage_power,
-	.data		=3D BIT(4), /* interface whitelist bitmap */
-};
-
-/* Sierra Wireless provide equally useless interface descriptors
- * Devices in QMI mode can be switched between two different
- * configurations:
- *   a) USB interface #8 is QMI/wwan
- *   b) USB interfaces #8, #19 and #20 are QMI/wwan
- *
- * Both configurations provide a number of other interfaces (serial++)=
,
- * some of which have the same endpoint configuration as we expect, so
- * a whitelist or blacklist is necessary.
- *
- * FIXME: The below whitelist should include BIT(20).  It does not
- * because I cannot get it to work...
- */
-static const struct driver_info	qmi_wwan_sierra =3D {
-	.description	=3D "Sierra Wireless wwan/QMI device",
-	.flags		=3D FLAG_WWAN,
-	.bind		=3D qmi_wwan_bind_shared,
-	.unbind		=3D qmi_wwan_unbind,
-	.manage_power	=3D qmi_wwan_manage_power,
-	.data		=3D BIT(8) | BIT(19), /* interface whitelist bitmap */
-};
-
 #define HUAWEI_VENDOR_ID	0x12D1
=20
+/* map QMI/wwan function by a fixed interface number */
+#define QMI_FIXED_INTF(vend, prod, num) \
+	USB_DEVICE_INTERFACE_NUMBER(vend, prod, num), \
+	.driver_info =3D (unsigned long)&qmi_wwan_shared
+
 /* Gobi 1000 QMI/wwan interface number is 3 according to qcserial */
 #define QMI_GOBI1K_DEVICE(vend, prod) \
-	USB_DEVICE(vend, prod), \
-	.driver_info =3D (unsigned long)&qmi_wwan_force_int3
+	QMI_FIXED_INTF(vend, prod, 3)
=20
-/* Gobi 2000 and Gobi 3000 QMI/wwan interface number is 0 according to=
 qcserial */
+/* Gobi 2000/3000 QMI/wwan interface number is 0 according to qcserial=
 */
 #define QMI_GOBI_DEVICE(vend, prod) \
-	USB_DEVICE(vend, prod), \
-	.driver_info =3D (unsigned long)&qmi_wwan_force_int0
+	QMI_FIXED_INTF(vend, prod, 0)
=20
 static const struct usb_device_id products[] =3D {
+	/* 1. CDC ECM like devices match on the control interface */
 	{	/* Huawei E392, E398 and possibly others sharing both device id and=
 more... */
 		.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_M=
ATCH_INT_INFO,
 		.idVendor           =3D HUAWEI_VENDOR_ID,
@@ -452,10 +371,9 @@ static const struct usb_device_id products[] =3D {
 		.bInterfaceProtocol =3D 57, /* CDC Ethernet *control* interface */
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
-	{	/* Huawei E392, E398 and possibly others in "Windows mode"
-		 * using a combined control and data interface without any CDC
-		 * functional descriptors
-		 */
+
+	/* 2. Combined interface devices matching on class+protocol */
+	{	/* Huawei E392, E398 and possibly others in "Windows mode" */
 		.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_M=
ATCH_INT_INFO,
 		.idVendor           =3D HUAWEI_VENDOR_ID,
 		.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
@@ -472,98 +390,21 @@ static const struct usb_device_id products[] =3D =
{
 		.bInterfaceProtocol =3D 0xff,
 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
 	},
-	{	/* ZTE MF820D */
-		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
-		.idVendor           =3D 0x19d2,
-		.idProduct          =3D 0x0167,
-		.bInterfaceClass    =3D 0xff,
-		.bInterfaceSubClass =3D 0xff,
-		.bInterfaceProtocol =3D 0xff,
-		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
-	},
-	{	/* ZTE MF821D */
-		.match_flags        =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_M=
ATCH_INT_INFO,
-		.idVendor           =3D 0x19d2,
-		.idProduct          =3D 0x0326,
-		.bInterfaceClass    =3D 0xff,
-		.bInterfaceSubClass =3D 0xff,
-		.bInterfaceProtocol =3D 0xff,
-		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
-	},
-	{	/* ZTE (Vodafone) K3520-Z */
-		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
-		.idVendor           =3D 0x19d2,
-		.idProduct          =3D 0x0055,
-		.bInterfaceClass    =3D 0xff,
-		.bInterfaceSubClass =3D 0xff,
-		.bInterfaceProtocol =3D 0xff,
-		.driver_info        =3D (unsigned long)&qmi_wwan_force_int1,
-	},
-	{	/* ZTE (Vodafone) K3565-Z */
-		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
-		.idVendor           =3D 0x19d2,
-		.idProduct          =3D 0x0063,
-		.bInterfaceClass    =3D 0xff,
-		.bInterfaceSubClass =3D 0xff,
-		.bInterfaceProtocol =3D 0xff,
-		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
-	},
-	{	/* ZTE (Vodafone) K3570-Z */
-		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
-		.idVendor           =3D 0x19d2,
-		.idProduct          =3D 0x1008,
-		.bInterfaceClass    =3D 0xff,
-		.bInterfaceSubClass =3D 0xff,
-		.bInterfaceProtocol =3D 0xff,
-		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
-	},
-	{	/* ZTE (Vodafone) K3571-Z */
-		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
-		.idVendor           =3D 0x19d2,
-		.idProduct          =3D 0x1010,
-		.bInterfaceClass    =3D 0xff,
-		.bInterfaceSubClass =3D 0xff,
-		.bInterfaceProtocol =3D 0xff,
-		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
-	},
-	{	/* ZTE (Vodafone) K3765-Z */
-		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
-		.idVendor           =3D 0x19d2,
-		.idProduct          =3D 0x2002,
-		.bInterfaceClass    =3D 0xff,
-		.bInterfaceSubClass =3D 0xff,
-		.bInterfaceProtocol =3D 0xff,
-		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
-	},
-	{	/* ZTE (Vodafone) K4505-Z */
-		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
-		.idVendor           =3D 0x19d2,
-		.idProduct          =3D 0x0104,
-		.bInterfaceClass    =3D 0xff,
-		.bInterfaceSubClass =3D 0xff,
-		.bInterfaceProtocol =3D 0xff,
-		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
-	},
-	{	/* ZTE MF60 */
-		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
-		.idVendor           =3D 0x19d2,
-		.idProduct          =3D 0x1402,
-		.bInterfaceClass    =3D 0xff,
-		.bInterfaceSubClass =3D 0xff,
-		.bInterfaceProtocol =3D 0xff,
-		.driver_info        =3D (unsigned long)&qmi_wwan_force_int2,
-	},
-	{	/* Sierra Wireless MC77xx in QMI mode */
-		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATC=
H_INT_INFO,
-		.idVendor           =3D 0x1199,
-		.idProduct          =3D 0x68a2,
-		.bInterfaceClass    =3D 0xff,
-		.bInterfaceSubClass =3D 0xff,
-		.bInterfaceProtocol =3D 0xff,
-		.driver_info        =3D (unsigned long)&qmi_wwan_sierra,
-	},
=20
-	/* Gobi 1000 devices */
+	/* 3. Combined interface devices matching on interface number */
+	{QMI_FIXED_INTF(0x19d2, 0x0055, 1)},	/* ZTE (Vodafone) K3520-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x0063, 4)},	/* ZTE (Vodafone) K3565-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x0104, 4)},	/* ZTE (Vodafone) K4505-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x0167, 4)},	/* ZTE MF820D */
+	{QMI_FIXED_INTF(0x19d2, 0x0326, 4)},	/* ZTE MF821D */
+	{QMI_FIXED_INTF(0x19d2, 0x1008, 4)},	/* ZTE (Vodafone) K3570-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x1010, 4)},	/* ZTE (Vodafone) K3571-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x1402, 2)},	/* ZTE MF60 */
+	{QMI_FIXED_INTF(0x19d2, 0x2002, 4)},	/* ZTE (Vodafone) K3765-Z */
+	{QMI_FIXED_INTF(0x1199, 0x68a2, 8)},	/* Sierra Wireless MC7710 in QMI=
 mode */
+	{QMI_FIXED_INTF(0x1199, 0x68a2, 19)},	/* Sierra Wireless MC7710 in QM=
I mode */
+
+	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
 	{QMI_GOBI1K_DEVICE(0x03f0, 0x1f1d)},	/* HP un2400 Gobi Modem Device *=
/
 	{QMI_GOBI1K_DEVICE(0x03f0, 0x371d)},	/* HP un2430 Mobile Broadband Mo=
dule */
@@ -579,7 +420,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9222)},	/* Generic Gobi Modem device */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9009)},	/* Generic Gobi Modem device */
=20
-	/* Gobi 2000 and 3000 devices */
+	/* 5. Gobi 2000 and 3000 devices */
 	{QMI_GOBI_DEVICE(0x413c, 0x8186)},	/* Dell Gobi 2000 Modem device (N0=
218, VU936) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x920b)},	/* Generic Gobi 2000 Modem device =
*/
 	{QMI_GOBI_DEVICE(0x05c6, 0x9225)},	/* Sony Gobi 2000 Modem device (N0=
279, VU730) */
--=20
1.7.10.4
