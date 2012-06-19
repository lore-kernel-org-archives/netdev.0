From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 3/5] net: qmi_wwan: bind to both control and data interface
Date: Tue, 19 Jun 2012 12:42:01 +0200
Message-ID: <1340102523-23990-4-git-send-email-bjorn@mork.no>
References: <1340102523-23990-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, Dan Williams <dcbw@redhat.com>,
	linux-usb@vger.kernel.org,
	"Andrew Bird (Sphere Systems)" <ajb@spheresystems.co.uk>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer@t-online.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43944 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134Ab2FSKmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 06:42:39 -0400
In-Reply-To: <1340102523-23990-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always bind to control interface regardless of whether
it is a shared interface or not.

A QMI/wwan function is required to provide both a control
interface (QMI) and a data interface (wwan).  All devices
supported by this driver do so.  But the vendors may
choose to use different USB descriptor layouts, and some
vendors even allow the same device to present different
layouts.

Most of these devices use a USB descriptor layout with a
single USB interface for both control and data.  But some
split control and data into two interfaces, bound together
by a CDC Union descriptor on the control interface. Before
the cdc-wdm subdriver support was added, this split was
used to let cdc-wdm drive the QMI control interface and
qmi_wwan drive the wwna data interface.

This split driver model has a number of issues:
 - qmi_wwan must match on the data interface descriptor,
   which often are indistiguishable from data interfaces
   belonging to other CDC (like) functions like ACM
 - supporting a single QMI/wwan function requires adding
   the device to two drivers
 - syncronizing the probes among a number of drivers, to
   ensure selecting the correct driver, is difficult unless
   all drivers match on the same interface

This patch resolves these problems by using the same
probing mechanism as cdc-ether for devices with a two-
interface USB descriptor layout.  This makes the driver
behave consistently, supporting both the control and data
part of the QMI/wwan function, regardless of the USB
descriptors.

Cc: Thomas Sch=C3=A4fer <tschaefer@t-online.de>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |  131 +++++++++++++++++++++---------------=
--------
 1 file changed, 63 insertions(+), 68 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 6fcf54d..05571fc 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -1,6 +1,10 @@
 /*
  * Copyright (c) 2012  Bj=C3=B8rn Mork <bjorn@mork.no>
  *
+ * The probing code is heavily inspired by cdc_ether, which is:
+ * Copyright (C) 2003-2005 by David Brownell
+ * Copyright (C) 2006 by Ole Andre Vadla Ravnas (ActiveSync)
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * version 2 as published by the Free Software Foundation.
@@ -15,11 +19,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc-wdm.h>
=20
-/* The name of the CDC Device Management driver */
-#define DM_DRIVER "cdc_wdm"
-
-/*
- * This driver supports wwan (3G/LTE/?) devices using a vendor
+/* This driver supports wwan (3G/LTE/?) devices using a vendor
  * specific management protocol called Qualcomm MSM Interface (QMI) -
  * in addition to the more common AT commands over serial interface
  * management
@@ -31,27 +31,16 @@
  * management protocol is used in place of the standard CDC
  * notifications NOTIFY_NETWORK_CONNECTION and NOTIFY_SPEED_CHANGE
  *
+ * Alternatively, control and data functions can be combined in a
+ * single USB interface.
+ *
  * Handling a protocol like QMI is out of the scope for any driver.
- * It can be exported as a character device using the cdc-wdm driver,
- * which will enable userspace applications ("modem managers") to
- * handle it.  This may be required to use the network interface
- * provided by the driver.
+ * It is exported as a character device using the cdc-wdm driver as
+ * a subdriver, enabling userspace applications ("modem managers") to
+ * handle it.
  *
  * These devices may alternatively/additionally be configured using AT
- * commands on any of the serial interfaces driven by the option drive=
r
- *
- * This driver binds only to the data ("slave") interface to enable
- * the cdc-wdm driver to bind to the control interface.  It still
- * parses the CDC functional descriptors on the control interface to
- *  a) verify that this is indeed a handled interface (CDC Union
- *     header lists it as slave)
- *  b) get MAC address and other ethernet config from the CDC Ethernet
- *     header
- *  c) enable user bind requests against the control interface, which
- *     is the common way to bind to CDC Ethernet Control Model type
- *     interfaces
- *  d) provide a hint to the user about which interface is the
- *     corresponding management interface
+ * commands on a serial interface
  */
=20
 /* driver specific data */
@@ -135,7 +124,6 @@ err:
 static int qmi_wwan_bind(struct usbnet *dev, struct usb_interface *int=
f)
 {
 	int status =3D -1;
-	struct usb_interface *control =3D NULL;
 	u8 *buf =3D intf->cur_altsetting->extra;
 	int len =3D intf->cur_altsetting->extralen;
 	struct usb_interface_descriptor *desc =3D &intf->cur_altsetting->desc=
;
@@ -143,27 +131,14 @@ static int qmi_wwan_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
 	struct usb_cdc_ether_desc *cdc_ether =3D NULL;
 	u32 required =3D 1 << USB_CDC_HEADER_TYPE | 1 << USB_CDC_UNION_TYPE;
 	u32 found =3D 0;
+	struct usb_driver *driver =3D driver_of(intf);
 	struct qmi_wwan_state *info =3D (void *)&dev->data;
=20
 	BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data) < sizeof(struct qmi_=
wwan_state)));
=20
-	atomic_set(&info->pmcount, 0);
-
-	/*
-	 * assume a data interface has no additional descriptors and
-	 * that the control and data interface are numbered
-	 * consecutively - this holds for the Huawei device at least
-	 */
-	if (len =3D=3D 0 && desc->bInterfaceNumber > 0) {
-		control =3D usb_ifnum_to_if(dev->udev, desc->bInterfaceNumber - 1);
-		if (!control)
-			goto err;
-
-		buf =3D control->cur_altsetting->extra;
-		len =3D control->cur_altsetting->extralen;
-		dev_dbg(&intf->dev, "guessing \"control\" =3D> %s, \"data\" =3D> thi=
s\n",
-			dev_name(&control->dev));
-	}
+	/* require a single interrupt status endpoint for subdriver */
+	if (intf->cur_altsetting->desc.bNumEndpoints !=3D 1)
+		goto err;
=20
 	while (len > 3) {
 		struct usb_descriptor_header *h =3D (void *)buf;
@@ -227,10 +202,17 @@ next_desc:
 		goto err;
 	}
=20
-	/* give the user a helpful hint if trying to bind to the wrong interf=
ace */
-	if (cdc_union && desc->bInterfaceNumber =3D=3D cdc_union->bMasterInte=
rface0) {
-		dev_err(&intf->dev, "leaving \"control\" interface for " DM_DRIVER "=
 - try binding to %s instead!\n",
-			dev_name(&usb_ifnum_to_if(dev->udev, cdc_union->bSlaveInterface0)->=
dev));
+	/* verify CDC Union */
+	if (desc->bInterfaceNumber !=3D cdc_union->bMasterInterface0) {
+		dev_err(&intf->dev, "bogus CDC Union: master=3D%u\n", cdc_union->bMa=
sterInterface0);
+		goto err;
+	}
+
+	/* need to save these for unbind */
+	info->control =3D intf;
+	info->data =3D usb_ifnum_to_if(dev->udev,	cdc_union->bSlaveInterface0=
);
+	if (!info->data) {
+		dev_err(&intf->dev, "bogus CDC Union: slave=3D%u\n", cdc_union->bSla=
veInterface0);
 		goto err;
 	}
=20
@@ -240,15 +222,16 @@ next_desc:
 		usbnet_get_ethernet_addr(dev, cdc_ether->iMACAddress);
 	}
=20
-	/* success! point the user to the management interface */
-	if (control)
-		dev_info(&intf->dev, "Use \"" DM_DRIVER "\" for QMI interface %s\n",
-			dev_name(&control->dev));
-
-	/* XXX: add a sysfs symlink somewhere to help management applications=
 find it? */
+	/* claim data interface and set it up */
+	status =3D usb_driver_claim_interface(driver, info->data, dev);
+	if (status < 0)
+		goto err;
=20
-	/* collect bulk endpoints now that we know intf =3D=3D "data" interfa=
ce */
-	status =3D usbnet_get_endpoints(dev, intf);
+	status =3D qmi_wwan_register_subdriver(dev);
+	if (status < 0) {
+		usb_set_intfdata(info->data, NULL);
+		usb_driver_release_interface(driver, info->data);
+	}
=20
 err:
 	return status;
@@ -257,11 +240,7 @@ err:
 /* Some devices combine the "control" and "data" functions into a
  * single interface with all three endpoints: interrupt + bulk in and
  * out
- *
- * Setting up cdc-wdm as a subdriver owning the interrupt endpoint
- * will let it provide userspace access to the encapsulated QMI
- * protocol without interfering with the usbnet operations.
-  */
+ */
 static int qmi_wwan_bind_shared(struct usbnet *dev, struct usb_interfa=
ce *intf)
 {
 	int rv;
@@ -313,14 +292,30 @@ err:
 	return rv;
 }
=20
-static void qmi_wwan_unbind_shared(struct usbnet *dev, struct usb_inte=
rface *intf)
+static void qmi_wwan_unbind(struct usbnet *dev, struct usb_interface *=
intf)
 {
 	struct qmi_wwan_state *info =3D (void *)&dev->data;
+	struct usb_driver *driver =3D driver_of(intf);
+	struct usb_interface *other;
=20
 	if (info->subdriver && info->subdriver->disconnect)
-		info->subdriver->disconnect(intf);
+		info->subdriver->disconnect(info->control);
+
+	/* allow user to unbind using either control or data */
+	if (intf =3D=3D info->control)
+		other =3D info->data;
+	else
+		other =3D info->control;
+
+	/* only if not shared */
+	if (other && intf !=3D other) {
+		usb_set_intfdata(other, NULL);
+		usb_driver_release_interface(driver, other);
+	}
=20
 	info->subdriver =3D NULL;
+	info->data =3D NULL;
+	info->control =3D NULL;
 }
=20
 /* suspend/resume wrappers calling both usbnet and the cdc-wdm
@@ -364,11 +359,11 @@ err:
 	return ret;
 }
=20
-
 static const struct driver_info	qmi_wwan_info =3D {
 	.description	=3D "QMI speaking wwan device",
 	.flags		=3D FLAG_WWAN,
 	.bind		=3D qmi_wwan_bind,
+	.unbind		=3D qmi_wwan_unbind,
 	.manage_power	=3D qmi_wwan_manage_power,
 };
=20
@@ -376,7 +371,7 @@ static const struct driver_info	qmi_wwan_shared =3D=
 {
 	.description	=3D "QMI speaking wwan device with combined interface",
 	.flags		=3D FLAG_WWAN,
 	.bind		=3D qmi_wwan_bind_shared,
-	.unbind		=3D qmi_wwan_unbind_shared,
+	.unbind		=3D qmi_wwan_unbind,
 	.manage_power	=3D qmi_wwan_manage_power,
 };
=20
@@ -384,7 +379,7 @@ static const struct driver_info	qmi_wwan_gobi =3D {
 	.description	=3D "Qualcomm Gobi wwan/QMI device",
 	.flags		=3D FLAG_WWAN,
 	.bind		=3D qmi_wwan_bind_gobi,
-	.unbind		=3D qmi_wwan_unbind_shared,
+	.unbind		=3D qmi_wwan_unbind,
 	.manage_power	=3D qmi_wwan_manage_power,
 };
=20
@@ -393,7 +388,7 @@ static const struct driver_info	qmi_wwan_force_int1=
 =3D {
 	.description	=3D "Qualcomm WWAN/QMI device",
 	.flags		=3D FLAG_WWAN,
 	.bind		=3D qmi_wwan_bind_shared,
-	.unbind		=3D qmi_wwan_unbind_shared,
+	.unbind		=3D qmi_wwan_unbind,
 	.manage_power	=3D qmi_wwan_manage_power,
 	.data		=3D BIT(1), /* interface whitelist bitmap */
 };
@@ -402,7 +397,7 @@ static const struct driver_info	qmi_wwan_force_int4=
 =3D {
 	.description	=3D "Qualcomm WWAN/QMI device",
 	.flags		=3D FLAG_WWAN,
 	.bind		=3D qmi_wwan_bind_shared,
-	.unbind		=3D qmi_wwan_unbind_shared,
+	.unbind		=3D qmi_wwan_unbind,
 	.manage_power	=3D qmi_wwan_manage_power,
 	.data		=3D BIT(4), /* interface whitelist bitmap */
 };
@@ -424,7 +419,7 @@ static const struct driver_info	qmi_wwan_sierra =3D=
 {
 	.description	=3D "Sierra Wireless wwan/QMI device",
 	.flags		=3D FLAG_WWAN,
 	.bind		=3D qmi_wwan_bind_gobi,
-	.unbind		=3D qmi_wwan_unbind_shared,
+	.unbind		=3D qmi_wwan_unbind,
 	.manage_power	=3D qmi_wwan_manage_power,
 	.data		=3D BIT(8) | BIT(19), /* interface whitelist bitmap */
 };
@@ -440,7 +435,7 @@ static const struct usb_device_id products[] =3D {
 		.idVendor           =3D HUAWEI_VENDOR_ID,
 		.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
 		.bInterfaceSubClass =3D 1,
-		.bInterfaceProtocol =3D 8, /* NOTE: This is the *slave* interface of=
 the CDC Union! */
+		.bInterfaceProtocol =3D 9, /* CDC Ethernet *control* interface */
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
 	{	/* Vodafone/Huawei K5005 (12d1:14c8) and similar modems */
@@ -448,7 +443,7 @@ static const struct usb_device_id products[] =3D {
 		.idVendor           =3D HUAWEI_VENDOR_ID,
 		.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
 		.bInterfaceSubClass =3D 1,
-		.bInterfaceProtocol =3D 56, /* NOTE: This is the *slave* interface o=
f the CDC Union! */
+		.bInterfaceProtocol =3D 57, /* CDC Ethernet *control* interface */
 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 	},
 	{	/* Huawei E392, E398 and possibly others in "Windows mode"
--=20
1.7.10
