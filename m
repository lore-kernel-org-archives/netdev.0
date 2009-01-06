From: Wu Fengguang <wfg@linux.intel.com>
Subject: [PATCH] dm9601: handle corrupt mac address
Date: Tue, 6 Jan 2009 14:14:14 +0800
Message-ID: <20090106061414.GA3677@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:51842 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751167AbZAFGOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 01:14:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some cheap devices ship with dangling EEPROM pins!
They always return invalid address ff:ff:ff:ff:ff:ff.

Inherit the auto-generated address in this case,
so that these products can work with zero configuration.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/net/usb/dm9601.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

--- linux-2.6.orig/drivers/net/usb/dm9601.c
+++ linux-2.6/drivers/net/usb/dm9601.c
@@ -413,6 +413,7 @@ static int dm9601_set_mac_address(struct
 static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret;
+	u8 mac[ETH_ALEN];
 
 	ret = usbnet_get_endpoints(dev, intf);
 	if (ret)
@@ -437,12 +438,18 @@ static int dm9601_bind(struct usbnet *de
 	udelay(20);
 
 	/* read MAC */
-	if (dm_read(dev, DM_PHY_ADDR, ETH_ALEN, dev->net->dev_addr) < 0) {
+	if (dm_read(dev, DM_PHY_ADDR, ETH_ALEN, mac) < 0) {
 		printk(KERN_ERR "Error reading MAC address\n");
 		ret = -ENODEV;
 		goto out;
 	}
 
+	/*
+	 * Overwrite the auto-generated address only with good ones.
+	 */
+	if (is_valid_ether_addr(mac))
+		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
+
 	/* power up phy */
 	dm_write_reg(dev, DM_GPR_CTRL, 1);
 	dm_write_reg(dev, DM_GPR_DATA, 0);
