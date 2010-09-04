From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] [RFC] cxacru: ignore ADSL routers
Date: Sat, 4 Sep 2010 14:01:07 +0200
Message-ID: <201009041401.10034.linux@rainbow-software.org>
References: <201009032317.14954.linux@rainbow-software.org> <4C81735E.3030903@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-out1.atlantis.sk ([80.94.52.55]:37509 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751963Ab0IDMBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 08:01:16 -0400
In-Reply-To: <4C81735E.3030903@simon.arlott.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ignore ADSL routers, which can have the same vendor and product IDs as ADSL
modems but should be driven by cx82310_eth driver.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- linux-2.6.35-rc2/drivers/usb/atm/cxacru.c	2010-06-06 05:43:24.000000000 +0200
+++ linux-2.6.35-rc3/drivers/usb/atm/cxacru.c	2010-09-04 11:54:35.000000000 +0200
@@ -1129,6 +1129,17 @@ static int cxacru_bind(struct usbatm_dat
 	struct cxacru_data *instance;
 	struct usb_device *usb_dev = interface_to_usbdev(intf);
 	int ret;
+	char buf[15];
+
+	/* avoid ADSL routers - abort if bDeviceClass is 0xff and iProduct is "USB NET CARD" */
+	if (usb_dev->descriptor.bDeviceClass == 0xff &&
+	    usb_dev->descriptor.iProduct &&
+	    usb_string(usb_dev, usb_dev->descriptor.iProduct, buf, sizeof(buf)) &&
+	    !strcmp(buf, "USB NET CARD")) {
+		usb_err(usbatm_instance,
+			"probably an ADSL router, use cx82310_eth driver instead\n");
+		return -ENODEV;
+	}
 
 	/* instance init */
 	instance = kzalloc(sizeof(*instance), GFP_KERNEL);


-- 
Ondrej Zary
