From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH] cxacru: ignore cx82310_eth devices
Date: Sat, 04 Sep 2010 17:30:20 +0100
Message-ID: <4C82741C.2000106@simon.arlott.org.uk>
References: <201009032317.14954.linux@rainbow-software.org> <4C81735E.3030903@simon.arlott.org.uk> <201009041401.10034.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ondrej Zary <linux@rainbow-software.org>,
	David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009041401.10034.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ignore ADSL routers, which can have the same vendor and product IDs
as ADSL modems but should be handled by the cx82310_eth driver.

This intentionally ignores device IDs that aren't currently handled
by cx82310_eth. There may be other device IDs that perhaps shouldn't
be claimed by cxacru.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
[SA: Moved to cxacru_usb_probe, message level lowered to info]
Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
 drivers/usb/atm/cxacru.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/atm/cxacru.c b/drivers/usb/atm/cxacru.c
index 593fc5e..96fa736 100644
--- a/drivers/usb/atm/cxacru.c
+++ b/drivers/usb/atm/cxacru.c
@@ -1324,8 +1324,22 @@ static struct usbatm_driver cxacru_driver = {
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
+	if (usb_dev->descriptor.bDeviceClass == 0xff
+			&& usb_dev->descriptor.iProduct
+			&& usb_string(usb_dev,
+				usb_dev->descriptor.iProduct, buf, sizeof(buf))
+			&& !strcmp(buf, "USB NET CARD")) {
+		dev_info(&intf->dev, "ignoring cx82310_eth device\n");
+		return -ENODEV;
+	}
+
 	return usbatm_usb_probe(intf, id, &cxacru_driver);
 }
 
-- 
1.7.0.4

-- 
Simon Arlott
