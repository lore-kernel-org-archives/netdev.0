From: Jonas Sjoquist <jonas.sjoquist@ericsson.com>
Subject: [PATCH/RFC Resubmission] cdc_ether: Identify MBM devices by GUID
 in MDLM descriptor
Date: Fri, 23 Apr 2010 13:07:45 +0200
Message-ID: <4BD17F81.4070301@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <oneukum@suse.de>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:46975 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590Ab0DWLHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 07:07:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jonas Sj=F6quist <jonas.sjoquist@ericsson.com>

This patch removes vid/pid for Ericsson MBM devices from the whitelist =
set of
devices. The MBM devices are instead identified by GUID.

In order for cdc_ether to handle these devices the GUID in the MDLM des=
criptor
is tested. All MBM devices currently handled by cdc_ether as well as fu=
ture
CDC Ethernet MBM devices can be identified by the GUID.

This is the same solution used in Carl Nordbeck's mbm driver,
http://kerneltrap.org/mailarchive/linux-usb/2008/11/17/4141384/thread

I post this as RFC to get feedback on however cdc_ether is the correct =
place to
do the binding, or if it should be done in a separate driver, e.g. zaur=
us.

Signed-off-by: Jonas Sj=F6quist <jonas.sjoquist@ericsson.com>
---
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index c8cdb7f..811b2dc 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -64,6 +64,11 @@ static int is_wireless_rndis(struct usb_interface_de=
scriptor *desc)
=20
 #endif
=20
+static const u8 mbm_guid[16] =3D {
+	0xa3, 0x17, 0xa8, 0x8b, 0x04, 0x5e, 0x4f, 0x01,
+	0xa6, 0x07, 0xc0, 0xff, 0xcb, 0x7e, 0x39, 0x2a,
+};
+
 /*
  * probes control interface, claims data interface, collects the bulk
  * endpoints, activates data interface (if needed), maybe sets MTU.
@@ -79,6 +84,8 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struc=
t usb_interface *intf)
 	int				status;
 	int				rndis;
 	struct usb_driver		*driver =3D driver_of(intf);
+	struct usb_cdc_mdlm_desc	*desc =3D NULL;
+	struct usb_cdc_mdlm_detail_desc *detail =3D NULL;
=20
 	if (sizeof dev->data < sizeof *info)
 		return -EDOM;
@@ -229,6 +236,34 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, st=
ruct usb_interface *intf)
 			 * side link address we were given.
 			 */
 			break;
+		case USB_CDC_MDLM_TYPE:
+			if (desc) {
+				dev_dbg(&intf->dev, "extra MDLM descriptor\n");
+				goto bad_desc;
+			}
+
+			desc =3D (void *)buf;
+
+			if (desc->bLength !=3D sizeof(*desc))
+				goto bad_desc;
+
+			if (memcmp(&desc->bGUID, mbm_guid, 16))
+				goto bad_desc;
+			break;
+		case USB_CDC_MDLM_DETAIL_TYPE:
+			if (detail) {
+				dev_dbg(&intf->dev, "extra MDLM detail descriptor\n");
+				goto bad_desc;
+			}
+
+			detail =3D (void *)buf;
+
+			if (detail->bGuidDescriptorType =3D=3D 0) {
+				if (detail->bLength < (sizeof(*detail) + 1))
+					goto bad_desc;
+			} else
+				goto bad_desc;
+			break;
 		}
 next_desc:
 		len -=3D buf [0];	/* bLength */
@@ -542,80 +577,10 @@ static const struct usb_device_id	products [] =3D=
 {
 			USB_CDC_PROTO_NONE),
 	.driver_info =3D (unsigned long) &cdc_info,
 }, {
-	/* Ericsson F3507g */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1900, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Ericsson F3507g ver. 2 */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1902, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Ericsson F3607gw */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1904, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Ericsson F3607gw ver 2 */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1905, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Ericsson F3607gw ver 3 */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1906, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Ericsson F3307 */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x190a, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Ericsson F3307 ver 2 */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1909, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Ericsson C3607w */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1049, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Ericsson C3607w ver 2 */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x190b, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Toshiba F3507g */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x130b, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Toshiba F3607gw */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x130c, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Toshiba F3607gw ver 2 */
-	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x1311, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Dell F3507g */
-	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8147, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Dell F3607gw */
-	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8183, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
-}, {
-	/* Dell F3607gw ver 2 */
-	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8184, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info =3D (unsigned long) &mbm_info,
+	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_MDLM,
+			USB_CDC_PROTO_NONE),
+	.driver_info =3D (unsigned long)&mbm_info,
+
 },
 	{ },		// END
 };

