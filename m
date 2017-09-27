From: Aleksander Morgado <aleksander@aleksander.es>
Subject: [PATCH] rndis_host: support Novatel Verizon USB730L
Date: Wed, 27 Sep 2017 23:31:03 +0200
Message-ID: <20170927213103.11987-1-aleksander@aleksander.es>
Cc: davem@davemloft.net, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org,
        Aleksander Morgado <aleksander@aleksander.es>
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33006 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751969AbdI0VbN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 17:31:13 -0400
Received: by mail-wr0-f195.google.com with SMTP id 97so807457wrb.0
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 14:31:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Treat the ef/04/01 interface class/subclass/protocol combination used
by the Novatel Verizon USB730L (1410:9030) as a possible RNDIS
interface.

 T:  Bus=01 Lev=02 Prnt=02 Port=01 Cnt=02 Dev#= 17 Spd=480 MxCh= 0
 D:  Ver= 2.00 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=64 #Cfgs=  3
 P:  Vendor=1410 ProdID=9030 Rev=03.10
 S:  Manufacturer=Novatel Wireless
 S:  Product=MiFi USB730L
 S:  SerialNumber=0123456789ABCDEF
 C:  #Ifs= 3 Cfg#= 1 Atr=80 MxPwr=500mA
 I:  If#= 0 Alt= 0 #EPs= 1 Cls=ef(misc ) Sub=04 Prot=01 Driver=rndis_host
 I:  If#= 1 Alt= 0 #EPs= 2 Cls=0a(data ) Sub=00 Prot=00 Driver=rndis_host
 I:  If#= 2 Alt= 0 #EPs= 1 Cls=03(HID  ) Sub=00 Prot=00 Driver=usbhid

Once the network interface is brought up, the user just needs to run a
DHCP client to get IP address and routing setup.

As a side note, other Novatel Verizon USB730L models with the same
vid:pid end up exposing a standard ECM interface which doesn't require
any other kernel update to make it work.

Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>
---

Hey,

I'm not sure if binding this logic to a specific vid:pid (1410:9030) would be more appropriate here, or if it's ok to just bind class/subclass/protocol (as in the activesync case).
Let me know what you think.

---
 drivers/net/usb/cdc_ether.c  | 11 ++++++++++-
 drivers/net/usb/rndis_host.c |  4 ++++
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 8ab281b478f2..2df0bcc6d30b 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -54,11 +54,19 @@ static int is_wireless_rndis(struct usb_interface_descriptor *desc)
 		desc->bInterfaceProtocol == 3);
 }

+static int is_novatel_rndis(struct usb_interface_descriptor *desc)
+{
+	return (desc->bInterfaceClass == USB_CLASS_MISC &&
+		desc->bInterfaceSubClass == 4 &&
+		desc->bInterfaceProtocol == 1);
+}
+
 #else

 #define is_rndis(desc)		0
 #define is_activesync(desc)	0
 #define is_wireless_rndis(desc)	0
+#define is_novatel_rndis(desc)	0

 #endif

@@ -150,7 +158,8 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 	 */
 	rndis = (is_rndis(&intf->cur_altsetting->desc) ||
 		 is_activesync(&intf->cur_altsetting->desc) ||
-		 is_wireless_rndis(&intf->cur_altsetting->desc));
+		 is_wireless_rndis(&intf->cur_altsetting->desc) ||
+		 is_novatel_rndis(&intf->cur_altsetting->desc));

 	memset(info, 0, sizeof(*info));
 	info->control = intf;
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index a151f267aebb..b807c91abe1d 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -632,6 +632,10 @@ static const struct usb_device_id	products [] = {
 	/* RNDIS for tethering */
 	USB_INTERFACE_INFO(USB_CLASS_WIRELESS_CONTROLLER, 1, 3),
 	.driver_info = (unsigned long) &rndis_info,
+}, {
+	/* Novatel Verizon USB730L */
+	USB_INTERFACE_INFO(USB_CLASS_MISC, 4, 1),
+	.driver_info = (unsigned long) &rndis_info,
 },
 	{ },		// END
 };
