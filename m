From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH v1] usbnet: re-use native hex2bin()
Date: Thu, 22 Jan 2015 23:27:12 +0200
Message-ID: <1421962032-25497-1-git-send-email-andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
To: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw02.mail.saunalahti.fi ([195.197.172.116]:48708 "EHLO
	gw02.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272AbbAVV1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 16:27:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call hex2bin() library function, instead of doing conversion here.

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 drivers/net/usb/usbnet.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3a6770a..449835f 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -160,20 +160,19 @@ EXPORT_SYMBOL_GPL(usbnet_get_endpoints);
 
 int usbnet_get_ethernet_addr(struct usbnet *dev, int iMACAddress)
 {
-	int 		tmp, i;
+	int 		tmp = -1, ret;
 	unsigned char	buf [13];
 
-	tmp = usb_string(dev->udev, iMACAddress, buf, sizeof buf);
-	if (tmp != 12) {
+	ret = usb_string(dev->udev, iMACAddress, buf, sizeof buf);
+	if (ret == 12)
+		tmp = hex2bin(dev->net->dev_addr, buf, 6);
+	if (tmp < 0) {
 		dev_dbg(&dev->udev->dev,
 			"bad MAC string %d fetch, %d\n", iMACAddress, tmp);
-		if (tmp >= 0)
-			tmp = -EINVAL;
-		return tmp;
+		if (ret >= 0)
+			ret = -EINVAL;
+		return ret;
 	}
-	for (i = tmp = 0; i < 6; i++, tmp += 2)
-		dev->net->dev_addr [i] =
-			(hex_to_bin(buf[tmp]) << 4) + hex_to_bin(buf[tmp + 1]);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(usbnet_get_ethernet_addr);
-- 
1.8.3.101.g727a46b
