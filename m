From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] cxacru: ignore cx82310_eth devices
Date: Sun, 5 Sep 2010 22:12:33 +0200
Message-ID: <201009052212.37015.linux@rainbow-software.org>
References: <201009032317.14954.linux@rainbow-software.org> <201009051901.13851.linux@rainbow-software.org> <20100905191412.GA10835@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Simon Arlott <simon@fire.lp0.eu>,
	David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100905191412.GA10835@kroah.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ignore ADSL routers, which can have the same vendor and product IDs
as ADSL modems but should be handled by the cx82310_eth driver.

This intentionally ignores device IDs that aren't currently handled
by cx82310_eth. There may be other device IDs that perhaps shouldn't
be claimed by cxacru.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- linux-2.6.36-rc3-orig/drivers/usb/atm/cxacru.c	2010-08-29 17:36:04.000000000 +0200
+++ linux-2.6.36-rc3/drivers/usb/atm/cxacru.c	2010-09-05 18:54:56.000000000 +0200
@@ -1324,8 +1324,22 @@ static struct usbatm_driver cxacru_drive
 	.tx_padding	= 11,
 };
 
-static int cxacru_usb_probe(struct usb_interface *intf, const struct usb_device_id *id)
-{
+static int cxacru_usb_probe(struct usb_interface *intf,
+		const struct usb_device_id *id) {
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
