From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net] net: qmi_wwan: fix Gobi device probing
Date: Thu, 21 Jun 2012 14:45:58 +0200
Message-ID: <1340282758-18085-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, H.Siebmanns-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ignoring interfaces with additional descriptors is not a reliable
method for locating the correct interface on Gobi devices.  There
is at least one device where this method fails:
https://bbs.archlinux.org/viewtopic.php?id=3D143506

The result is that the AT command port (interface #2) is hidden
from qcserial, preventing traditional serial modem usage:

[   15.562552] qmi_wwan 4-1.6:1.0: cdc-wdm0: USB WDM device
[   15.562691] qmi_wwan 4-1.6:1.0: wwan0: register 'qmi_wwan' at usb-00=
00:00:1d.0-1.6, Qualcomm Gobi wwan/QMI device, 1e:df:3c:3a:4e:3b
[   15.563383] qmi_wwan: probe of 4-1.6:1.1 failed with error -22
[   15.564189] qmi_wwan 4-1.6:1.2: cdc-wdm1: USB WDM device
[   15.564302] qmi_wwan 4-1.6:1.2: wwan1: register 'qmi_wwan' at usb-00=
00:00:1d.0-1.6, Qualcomm Gobi wwan/QMI device, 1e:df:3c:3a:4e:3b
[   15.564328] qmi_wwan: probe of 4-1.6:1.3 failed with error -22
[   15.569376] qcserial 4-1.6:1.1: Qualcomm USB modem converter detecte=
d
[   15.569440] usb 4-1.6: Qualcomm USB modem converter now attached to =
ttyUSB0
[   15.570372] qcserial 4-1.6:1.3: Qualcomm USB modem converter detecte=
d
[   15.570430] usb 4-1.6: Qualcomm USB modem converter now attached to =
ttyUSB1

Use static interface numbers taken from the interface map in
qcserial for all Gobi devices instead:

	Gobi 1K USB layout:
	0: serial port (doesn't respond)
	1: serial port (doesn't respond)
	2: AT-capable modem port
	3: QMI/net

	Gobi 2K+ USB layout:
	0: QMI/net
	1: DM/DIAG (use libqcdm from ModemManager for communication)
	2: AT-capable modem port
	3: NMEA

This should be more reliable over all, and will also prevent the
noisy "probe failed" messages.  The whitelisting logic is expected
to be replaced by direct interface number matching in 3.6.

Reported-by: Heinrich Siebmanns (Harvey) <H.Siebmanns-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.4: 0000188 USB: qmi_wwan: Make forced=
 int 4 whitelist generic
Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.4: f7142e6 USB: qmi_wwan: Add ZTE (Vo=
dafone) K3520-Z
Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.4
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c |   83 +++++++++++++++++++++---------------=
--------
 1 file changed, 40 insertions(+), 43 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 3b20678..3767a12 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -257,29 +257,6 @@ err:
 	return rv;
 }
=20
-/* Gobi devices uses identical class/protocol codes for all interfaces=
 regardless
- * of function. Some of these are CDC ACM like and have the exact same=
 endpoints
- * we are looking for. This leaves two possible strategies for identif=
ying the
- * correct interface:
- *   a) hardcoding interface number, or
- *   b) use the fact that the wwan interface is the only one lacking a=
dditional
- *      (CDC functional) descriptors
- *
- * Let's see if we can get away with the generic b) solution.
- */
-static int qmi_wwan_bind_gobi(struct usbnet *dev, struct usb_interface=
 *intf)
-{
-	int rv =3D -EINVAL;
-
-	/* ignore any interface with additional descriptors */
-	if (intf->cur_altsetting->extralen)
-		goto err;
-
-	rv =3D qmi_wwan_bind_shared(dev, intf);
-err:
-	return rv;
-}
-
 static void qmi_wwan_unbind_shared(struct usbnet *dev, struct usb_inte=
rface *intf)
 {
 	struct usb_driver *subdriver =3D (void *)dev->data[0];
@@ -347,15 +324,15 @@ static const struct driver_info	qmi_wwan_shared =3D=
 {
 	.manage_power	=3D qmi_wwan_manage_power,
 };
=20
-static const struct driver_info	qmi_wwan_gobi =3D {
-	.description	=3D "Qualcomm Gobi wwan/QMI device",
+static const struct driver_info	qmi_wwan_force_int0 =3D {
+	.description	=3D "Qualcomm WWAN/QMI device",
 	.flags		=3D FLAG_WWAN,
-	.bind		=3D qmi_wwan_bind_gobi,
+	.bind		=3D qmi_wwan_bind_shared,
 	.unbind		=3D qmi_wwan_unbind_shared,
 	.manage_power	=3D qmi_wwan_manage_power,
+	.data		=3D BIT(0), /* interface whitelist bitmap */
 };
=20
-/* ZTE suck at making USB descriptors */
 static const struct driver_info	qmi_wwan_force_int1 =3D {
 	.description	=3D "Qualcomm WWAN/QMI device",
 	.flags		=3D FLAG_WWAN,
@@ -365,6 +342,15 @@ static const struct driver_info	qmi_wwan_force_int=
1 =3D {
 	.data		=3D BIT(1), /* interface whitelist bitmap */
 };
=20
+static const struct driver_info	qmi_wwan_force_int3 =3D {
+	.description	=3D "Qualcomm WWAN/QMI device",
+	.flags		=3D FLAG_WWAN,
+	.bind		=3D qmi_wwan_bind_shared,
+	.unbind		=3D qmi_wwan_unbind_shared,
+	.manage_power	=3D qmi_wwan_manage_power,
+	.data		=3D BIT(3), /* interface whitelist bitmap */
+};
+
 static const struct driver_info	qmi_wwan_force_int4 =3D {
 	.description	=3D "Qualcomm WWAN/QMI device",
 	.flags		=3D FLAG_WWAN,
@@ -390,16 +376,23 @@ static const struct driver_info	qmi_wwan_force_in=
t4 =3D {
 static const struct driver_info	qmi_wwan_sierra =3D {
 	.description	=3D "Sierra Wireless wwan/QMI device",
 	.flags		=3D FLAG_WWAN,
-	.bind		=3D qmi_wwan_bind_gobi,
+	.bind		=3D qmi_wwan_bind_shared,
 	.unbind		=3D qmi_wwan_unbind_shared,
 	.manage_power	=3D qmi_wwan_manage_power,
 	.data		=3D BIT(8) | BIT(19), /* interface whitelist bitmap */
 };
=20
 #define HUAWEI_VENDOR_ID	0x12D1
+
+/* Gobi 1000 QMI/wwan interface number is 3 according to qcserial */
+#define QMI_GOBI1K_DEVICE(vend, prod) \
+	USB_DEVICE(vend, prod), \
+	.driver_info =3D (unsigned long)&qmi_wwan_force_int3
+
+/* Gobi 2000 and Gobi 3000 QMI/wwan interface number is 0 according to=
 qcserial */
 #define QMI_GOBI_DEVICE(vend, prod) \
 	USB_DEVICE(vend, prod), \
-	.driver_info =3D (unsigned long)&qmi_wwan_gobi
+	.driver_info =3D (unsigned long)&qmi_wwan_force_int0
=20
 static const struct usb_device_id products[] =3D {
 	{	/* Huawei E392, E398 and possibly others sharing both device id and=
 more... */
@@ -510,20 +503,24 @@ static const struct usb_device_id products[] =3D =
{
 		.bInterfaceProtocol =3D 0xff,
 		.driver_info        =3D (unsigned long)&qmi_wwan_sierra,
 	},
-	{QMI_GOBI_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
-	{QMI_GOBI_DEVICE(0x03f0, 0x1f1d)},	/* HP un2400 Gobi Modem Device */
-	{QMI_GOBI_DEVICE(0x03f0, 0x371d)},	/* HP un2430 Mobile Broadband Modu=
le */
-	{QMI_GOBI_DEVICE(0x04da, 0x250d)},	/* Panasonic Gobi Modem device */
-	{QMI_GOBI_DEVICE(0x413c, 0x8172)},	/* Dell Gobi Modem device */
-	{QMI_GOBI_DEVICE(0x1410, 0xa001)},	/* Novatel Gobi Modem device */
-	{QMI_GOBI_DEVICE(0x0b05, 0x1776)},	/* Asus Gobi Modem device */
-	{QMI_GOBI_DEVICE(0x19d2, 0xfff3)},	/* ONDA Gobi Modem device */
-	{QMI_GOBI_DEVICE(0x05c6, 0x9001)},	/* Generic Gobi Modem device */
-	{QMI_GOBI_DEVICE(0x05c6, 0x9002)},	/* Generic Gobi Modem device */
-	{QMI_GOBI_DEVICE(0x05c6, 0x9202)},	/* Generic Gobi Modem device */
-	{QMI_GOBI_DEVICE(0x05c6, 0x9203)},	/* Generic Gobi Modem device */
-	{QMI_GOBI_DEVICE(0x05c6, 0x9222)},	/* Generic Gobi Modem device */
-	{QMI_GOBI_DEVICE(0x05c6, 0x9009)},	/* Generic Gobi Modem device */
+
+	/* Gobi 1000 devices */
+	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
+	{QMI_GOBI1K_DEVICE(0x03f0, 0x1f1d)},	/* HP un2400 Gobi Modem Device *=
/
+	{QMI_GOBI1K_DEVICE(0x03f0, 0x371d)},	/* HP un2430 Mobile Broadband Mo=
dule */
+	{QMI_GOBI1K_DEVICE(0x04da, 0x250d)},	/* Panasonic Gobi Modem device *=
/
+	{QMI_GOBI1K_DEVICE(0x413c, 0x8172)},	/* Dell Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x1410, 0xa001)},	/* Novatel Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x0b05, 0x1776)},	/* Asus Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x19d2, 0xfff3)},	/* ONDA Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x05c6, 0x9001)},	/* Generic Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x05c6, 0x9002)},	/* Generic Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x05c6, 0x9202)},	/* Generic Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x05c6, 0x9203)},	/* Generic Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x05c6, 0x9222)},	/* Generic Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x05c6, 0x9009)},	/* Generic Gobi Modem device */
+
+	/* Gobi 2000 and 3000 devices */
 	{QMI_GOBI_DEVICE(0x413c, 0x8186)},	/* Dell Gobi 2000 Modem device (N0=
218, VU936) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x920b)},	/* Generic Gobi 2000 Modem device =
*/
 	{QMI_GOBI_DEVICE(0x05c6, 0x9225)},	/* Sony Gobi 2000 Modem device (N0=
279, VU730) */
--=20
1.7.10

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
