From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] qmi_wwan/cdc_ether: move Novatel 551 and E362 to qmi_wwan
Date: Wed, 24 Oct 2012 17:10:34 -0500
Message-ID: <1351116634.16726.6.camel@dcbw.foobar.com>
References: <1351103134.6544.25.camel@dcbw.foobar.com>
	 <1351103720.6544.34.camel@dcbw.foobar.com> <87objr659w.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Aleksander Morgado <aleksander@gnu.org>, linux-usb@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20086 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161238Ab2JXWHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 18:07:33 -0400
In-Reply-To: <87objr659w.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These devices provide QMI and ethernet functionality via a standard CDC
ethernet descriptor.  But when driven by cdc_ether, the QMI
functionality is unavailable because only cdc_ether can claim the USB
interface.  Thus blacklist the devices in cdc_ether and add their IDs to
qmi_wwan, which enables both QMI and ethernet simultaneously.

Signed-off-by: Dan Williams <dcbw@redhat.com>
Cc: stable@vger.kernel.org
---
Greg: CC-ed to linux-usb@ for visibility but should probably go through davem


diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index a03de71..d012982 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -592,6 +592,32 @@ static const struct usb_device_id	products [] = {
 	.driver_info		= 0,
 },
 
+/* Novatel USB551L and MC551 - handled by qmi_wwan */
+{
+	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
+		 | USB_DEVICE_ID_MATCH_PRODUCT
+		 | USB_DEVICE_ID_MATCH_INT_INFO,
+	.idVendor               = NOVATEL_VENDOR_ID,
+	.idProduct		= 0xB001,
+	.bInterfaceClass	= USB_CLASS_COMM,
+	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
+	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	.driver_info = 0,
+},
+
+/* Novatel E362 - handled by qmi_wwan */
+{
+	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
+		 | USB_DEVICE_ID_MATCH_PRODUCT
+		 | USB_DEVICE_ID_MATCH_INT_INFO,
+	.idVendor               = NOVATEL_VENDOR_ID,
+	.idProduct		= 0x9010,
+	.bInterfaceClass	= USB_CLASS_COMM,
+	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
+	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
+	.driver_info = 0,
+},
+
 /*
  * WHITELIST!!!
  *
@@ -604,21 +630,6 @@ static const struct usb_device_id	products [] = {
  * because of bugs/quirks in a given product (like Zaurus, above).
  */
 {
-	/* Novatel USB551L */
-	/* This match must come *before* the generic CDC-ETHER match so that
-	 * we get FLAG_WWAN set on the device, since it's descriptors are
-	 * generic CDC-ETHER.
-	 */
-	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
-		 | USB_DEVICE_ID_MATCH_PRODUCT
-		 | USB_DEVICE_ID_MATCH_INT_INFO,
-	.idVendor               = NOVATEL_VENDOR_ID,
-	.idProduct		= 0xB001,
-	.bInterfaceClass	= USB_CLASS_COMM,
-	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
-	.bInterfaceProtocol	= USB_CDC_PROTO_NONE,
-	.driver_info = (unsigned long)&wwan_info,
-}, {
 	/* ZTE (Vodafone) K3805-Z */
 	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
 		 | USB_DEVICE_ID_MATCH_PRODUCT
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 6883c37..05fd4a1 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -369,6 +369,20 @@ static const struct usb_device_id products[] = {
 		USB_VENDOR_AND_INTERFACE_INFO(0x106c, USB_CLASS_VENDOR_SPEC, 0xf1, 0xff),
 		.driver_info        = (unsigned long)&qmi_wwan_info,
 	},
+	{	/* Novatel USB551L and MC551 */
+		USB_DEVICE_AND_INTERFACE_INFO(0x1410, 0xb001,
+		                              USB_CLASS_COMM,
+		                              USB_CDC_SUBCLASS_ETHERNET,
+		                              USB_CDC_PROTO_NONE),
+		.driver_info        = (unsigned long)&qmi_wwan_info,
+	},
+	{	/* Novatel E362 */
+		USB_DEVICE_AND_INTERFACE_INFO(0x1410, 0x9010,
+		                              USB_CLASS_COMM,
+		                              USB_CDC_SUBCLASS_ETHERNET,
+		                              USB_CDC_PROTO_NONE),
+		.driver_info        = (unsigned long)&qmi_wwan_info,
+	},
 
 	/* 3. Combined interface devices matching on interface number */
 	{QMI_FIXED_INTF(0x19d2, 0x0002, 1)},
