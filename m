From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH v3] cxacru: ignore cx82310_eth devices
Date: Wed, 8 Sep 2010 22:52:12 +0200
Message-ID: <201009082252.15865.linux@rainbow-software.org>
References: <201009051901.13851.linux@rainbow-software.org> <201009052212.37015.linux@rainbow-software.org> <20100908.131227.28827971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, simon@fire.lp0.eu, dbrownell@users.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-out1.atlantis.sk ([80.94.52.55]:44385 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754148Ab0IHUwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 16:52:24 -0400
In-Reply-To: <20100908.131227.28827971.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ignore ADSL routers, which can have the same vendor and product IDs
as ADSL modems but should be handled by the cx82310_eth driver.

This intentionally ignores device IDs that aren't currently handled
by cx82310_eth. There may be other device IDs that perhaps shouldn't
be claimed by cxacru.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
Signed-off-by: Simon Arlott <simon@fire.lp0.eu>

--- linux-2.6.36-rc3-orig/drivers/usb/atm/cxacru.c	2010-08-29 17:36:04.000000000 +0200
+++ linux-2.6.36-rc3/drivers/usb/atm/cxacru.c	2010-09-08 22:42:47.000000000 +0200
@@ -1324,8 +1324,23 @@ static struct usbatm_driver cxacru_drive
 	.tx_padding	= 11,
 };
 
-static int cxacru_usb_probe(struct usb_interface *intf, const struct usb_device_id *id)
+static int cxacru_usb_probe(struct usb_interface *intf,
+		const struct usb_device_id *id)
 {
+	struct usb_device *usb_dev = interface_to_usbdev(intf);
+	char buf[15];
+
+	/* avoid ADSL routers (cx82310_eth)
+	 * abort if bDeviceClass is 0xff and iProduct is "USB NET CARD" */
+	if (usb_dev->descriptor.bDeviceClass == USB_CLASS_VENDOR_SPEC
+			&& usb_string(usb_dev, usb_dev->descriptor.iProduct,
+				buf, sizeof(buf)) > 0) {
+		if (!strcmp(buf, "USB NET CARD")) {
+			dev_info(&intf->dev, "ignoring cx82310_eth device\n");
+			return -ENODEV;
+		}
+	}
+
 	return usbatm_usb_probe(intf, id, &cxacru_driver);
 }
 

-- 
Ondrej Zary
