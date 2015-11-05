From: =?UTF-8?q?Petr=20=C5=A0tetiar?= <ynezz-knWk7/PSn+s@public.gmane.org>
Subject: [PATCH v2] USB: qmi_wwan: Add quirk for Quectel EC20 Mini PCIe module
Date: Thu,  5 Nov 2015 12:55:01 +0100
Message-ID: <1446724501-18821-1-git-send-email-ynezz@true.cz>
References: <1446720952-15635-1-git-send-email-ynezz@true.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Petr=20=C5=A0tetiar?= <ynezz-knWk7/PSn+s@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1446720952-15635-1-git-send-email-ynezz-knWk7/PSn+s@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This device has same vendor and product IDs as G2K devices, but it has
different number of interfaces(4 vs 5) and also different interface
layout where EC20 has QMI on interface 4 instead of 0.

lsusb output:

	Bus 002 Device 003: ID 05c6:9215 Qualcomm, Inc. Acer Gobi 2000
	Device Descriptor:
	  bLength                18
	  bDescriptorType         1
	  bcdUSB               2.00
	  bDeviceClass            0 (Defined at Interface level)
	  bDeviceSubClass         0
	  bDeviceProtocol         0
	  bMaxPacketSize0        64
	  idVendor           0x05c6 Qualcomm, Inc.
	  idProduct          0x9215 Acer Gobi 2000 Wireless Modem
	  bcdDevice            2.32
	  iManufacturer           1 Quectel
	  iProduct                2 Quectel LTE Module
	  iSerial                 0
	  bNumConfigurations      1
	  Configuration Descriptor:
	    bLength                 9
	    bDescriptorType         2
	    wTotalLength          209
	    bNumInterfaces          5
	    bConfigurationValue     1
	    iConfiguration          0
	    bmAttributes         0xa0
	      (Bus Powered)
	      Remote Wakeup
	    MaxPower              500mA

Signed-off-by: Petr =C5=A0tetiar <ynezz-knWk7/PSn+s@public.gmane.org>
---

Changes since v1:
 * make quectel_ec20_detected return bool (Bj=C3=B8rn)

 drivers/net/usb/qmi_wwan.c |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 2a7c1be..b81a32c 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -822,6 +822,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_GOBI_DEVICE(0x05c6, 0x9245)},	/* Samsung Gobi 2000 Modem device =
(VL176) */
 	{QMI_GOBI_DEVICE(0x03f0, 0x251d)},	/* HP Gobi 2000 Modem device (VP41=
2) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9215)},	/* Acer Gobi 2000 Modem device (VP=
413) */
+	{QMI_FIXED_INTF(0x05c6, 0x9215, 4)},	/* Quectel EC20 Mini PCIe */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9265)},	/* Asus Gobi 2000 Modem device (VR=
305) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9235)},	/* Top Global Gobi 2000 Modem devi=
ce (VR306) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9275)},	/* iRex Technologies Gobi 2000 Mod=
em device (VR307) */
@@ -853,10 +854,24 @@ static const struct usb_device_id products[] =3D =
{
 };
 MODULE_DEVICE_TABLE(usb, products);
=20
+static bool quectel_ec20_detected(struct usb_interface *intf)
+{
+	struct usb_device *dev =3D interface_to_usbdev(intf);
+
+	if (dev->actconfig &&
+	    le16_to_cpu(dev->descriptor.idVendor) =3D=3D 0x05c6 &&
+	    le16_to_cpu(dev->descriptor.idProduct) =3D=3D 0x9215 &&
+	    dev->actconfig->desc.bNumInterfaces =3D=3D 5)
+		return true;
+
+	return false;
+}
+
 static int qmi_wwan_probe(struct usb_interface *intf,
 			  const struct usb_device_id *prod)
 {
 	struct usb_device_id *id =3D (struct usb_device_id *)prod;
+	struct usb_interface_descriptor *desc =3D &intf->cur_altsetting->desc=
;
=20
 	/* Workaround to enable dynamic IDs.  This disables usbnet
 	 * blacklisting functionality.  Which, if required, can be
@@ -868,6 +883,12 @@ static int qmi_wwan_probe(struct usb_interface *in=
tf,
 		id->driver_info =3D (unsigned long)&qmi_wwan_info;
 	}
=20
+	/* Quectel EC20 quirk where we've QMI on interface 4 instead of 0 */
+	if (quectel_ec20_detected(intf) && desc->bInterfaceNumber =3D=3D 0) {
+		dev_dbg(&intf->dev, "Quectel EC20 quirk, skipping interface 0\n");
+		return -ENODEV;
+	}
+
 	return usbnet_probe(intf, id);
 }
=20
--=20
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
