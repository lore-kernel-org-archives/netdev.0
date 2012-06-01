From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] mcs7830: Implement link state detection
Date: Fri, 1 Jun 2012 22:29:08 +0200
Message-ID: <201206012229.11530.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-1-out2.atlantis.sk ([80.94.52.71]:45616 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759259Ab2FAU3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 16:29:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add .status callback that detects link state changes.
Tested with MCS7832CV-AA chip (9710:7830, identified as rev.C by the driver).
Fixes https://bugzilla.kernel.org/show_bug.cgi?id=28532

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -629,11 +629,31 @@ static int mcs7830_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	return skb->len > 0;
 }
 
+static void mcs7830_status(struct usbnet *dev, struct urb *urb)
+{
+	u8 *buf = urb->transfer_buffer;
+	bool link;
+
+	if (urb->actual_length < 16)
+		return;
+
+	link = !(buf[1] & 0x20);
+	if (netif_carrier_ok(dev->net) != link) {
+		if (link) {
+			netif_carrier_on(dev->net);
+			usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+		} else
+			netif_carrier_off(dev->net);
+		netdev_dbg(dev->net, "Link Status is: %d\n", link);
+	}
+}
+
 static const struct driver_info moschip_info = {
 	.description	= "MOSCHIP 7830/7832/7730 usb-NET adapter",
 	.bind		= mcs7830_bind,
 	.rx_fixup	= mcs7830_rx_fixup,
-	.flags		= FLAG_ETHER,
+	.flags		= FLAG_ETHER | FLAG_LINK_INTR,
+	.status		= mcs7830_status,
 	.in		= 1,
 	.out		= 2,
 };
@@ -642,7 +662,8 @@ static const struct driver_info sitecom_info = {
 	.description    = "Sitecom LN-30 usb-NET adapter",
 	.bind		= mcs7830_bind,
 	.rx_fixup	= mcs7830_rx_fixup,
-	.flags		= FLAG_ETHER,
+	.flags		= FLAG_ETHER | FLAG_LINK_INTR,
+	.status		= mcs7830_status,
 	.in		= 1,
 	.out		= 2,
 };

-- 
Ondrej Zary
