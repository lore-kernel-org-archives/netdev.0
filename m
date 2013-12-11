From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH 4/4] asix: C1 DUB-E100 double rx_urb_size to 4096
Date: Wed, 11 Dec 2013 10:50:28 +0000
Message-ID: <1386759028-3534-5-git-send-email-Dean_Jenkins@mentor.com>
References: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway05.m3-connect.de ([88.79.237.15]:35358 "EHLO
	mail.mentor.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751496Ab3LKK7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 05:59:14 -0500
In-Reply-To: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that for the C1 hardware variant of the D-Link DUB-E100
that the rx_urb_size of 2048 is truncating IP fragmented packets due
to multiple Ethernet frames being present in a single URB.

A simple ping test shows a loss of ping responses
ping 172.17.0.10 -f -c 200 -s 1965
(172.17.0.1 is the IP address of the target)

In the worse case, this test requires a 2049 byte data buffer size
to hold the IN bulk transfer but the URB is 2048 in size so the last byte
of the Ethernet frame is lost and the Ethernet frame is truncated.

This modification resolves "asix_rx_fixup() Bad Header" errors caused by
truncation of the Ethernet frame due to the URB buffer being too small.

Therefore, increase the rx_urb_size to 4096 to accommodate
multiple Ethernet frames being present in a single URB.

Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
---
 drivers/net/usb/asix_devices.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 37de7db..cee3f8c 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -492,7 +492,10 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
 		/* hard_mtu  is still the default - the device does not support
 		   jumbo eth frames */
-		dev->rx_urb_size = 2048;
+		/* Increased to 4K for the C1 DUB-E100 to avoid
+		 * "asix_rx_fixup() Bad Header" errors because the 2K
+		 * urb buffer was too small which caused frame truncation */
+		dev->rx_urb_size = 4096;
 	}
 
 	dev->driver_priv = kzalloc(sizeof(struct asix_common_private), GFP_KERNEL);
-- 
1.7.9.5
