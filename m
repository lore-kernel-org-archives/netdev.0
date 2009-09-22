From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: fix transmission where ZLP is expected
Date: Tue, 22 Sep 2009 15:00:27 +0100
Message-ID: <1253628027-2704-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Vlad Lyalikov <vlad.lyalikov@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:48626 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753659AbZIVOKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 10:10:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usbnet framework assumes USB hardware doesn't handle zero length
packets, but SMSC LAN95xx requires these to be sent for correct
operation.

This patch fixes an easily reproducible tx lockup when sending a frame
that results in exactly 512 bytes in a USB transmission (e.g. a UDP
frame with 458 data bytes, due to IP headers and our USB headers).  It
adds an extra flag to usbnet for the hardware driver to indicate that
it can handle and requires the zero length packets.

This patch should not affect other usbnet users, please also consider
for -stable.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |    2 +-
 drivers/net/usb/usbnet.c   |    2 +-
 include/linux/usb/usbnet.h |    1 +
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 938fb35..6e9410f 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1227,7 +1227,7 @@ static const struct driver_info smsc95xx_info = {
 	.rx_fixup	= smsc95xx_rx_fixup,
 	.tx_fixup	= smsc95xx_tx_fixup,
 	.status		= smsc95xx_status,
-	.flags		= FLAG_ETHER,
+	.flags		= FLAG_ETHER | FLAG_SEND_ZLP,
 };
 
 static const struct usb_device_id products[] = {
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 24b36f7..ca5ca5a 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1049,7 +1049,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	 * NOTE:  strictly conforming cdc-ether devices should expect
 	 * the ZLP here, but ignore the one-byte packet.
 	 */
-	if ((length % dev->maxpacket) == 0) {
+	if (!(info->flags & FLAG_SEND_ZLP) && (length % dev->maxpacket) == 0) {
 		urb->transfer_buffer_length++;
 		if (skb_tailroom(skb)) {
 			skb->data[skb->len] = 0;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index bb69e25..f814730 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -89,6 +89,7 @@ struct driver_info {
 #define FLAG_FRAMING_AX 0x0040		/* AX88772/178 packets */
 #define FLAG_WLAN	0x0080		/* use "wlan%d" names */
 #define FLAG_AVOID_UNLINK_URBS 0x0100	/* don't unlink urbs at usbnet_stop() */
+#define FLAG_SEND_ZLP	0x0200		/* hw requires ZLPs are sent */
 
 
 	/* init device ... can sleep, or cause probe() failure */
-- 
1.6.2.5

