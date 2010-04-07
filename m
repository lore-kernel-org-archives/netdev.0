From: Elina Pasheva <epasheva@sierrawireless.com>
Subject: [PATCH 1/1] NET: usb: Adding URB_ZERO_PACKET flag to usbnet.c
Date: Tue, 6 Apr 2010 17:23:07 -0700
Message-ID: <1270599787.8900.8.camel@Linuxdev4-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: <epasheva@sierrawireless.com>, <rfiler@sierrawireless.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: <dbrownell@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from carmd-sa02.sierrawireless.com ([208.81.121.46]:49373 "EHLO
	carmd-sa02.sierrawireless.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932229Ab0DGAXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 20:23:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 1/1] NET: usb: Adding URB_ZERO_PACKET flag to usbnet.c
From: Elina Pasheva <epasheva@sierrawireless.com>
This patch adds setting of the urb transfer flag URB_ZERO_PACKET  before
submitting an urb for drivers that have requested it (by advertising flag
FLAG_SEND_ZLP).
The modification is in usbnet.c function usbnet_start_xmit().
This patch only adds the zero length flag.
A subsequent patch will address the buggy code we found when devices do not
advertise FLAG_SEND_ZLP in which case there is a possibility of transferring
packets with non-deterministic length.

This patch has been tested on kernel-2.6.34-rc3.
This patch has been checked against net-2.6 tree.
Signed-off-by: Elina Pasheva <epasheva@sierrawireless.com>
Signed-off-by: Rory Filer <rfiler@sierrawireless.com>
---

 drivers/net/usb/usbnet.c |   15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

--- a/drivers/net/usb/usbnet.c	2010-04-06 10:52:54.000000000 -0700
+++ b/drivers/net/usb/usbnet.c	2010-04-06 16:54:44.000000000 -0700
@@ -1068,12 +1068,15 @@ netdev_tx_t usbnet_start_xmit (struct sk
 	 * NOTE:  strictly conforming cdc-ether devices should expect
 	 * the ZLP here, but ignore the one-byte packet.
 	 */
-	if (!(info->flags & FLAG_SEND_ZLP) && (length % dev->maxpacket) == 0) {
-		urb->transfer_buffer_length++;
-		if (skb_tailroom(skb)) {
-			skb->data[skb->len] = 0;
-			__skb_put(skb, 1);
-		}
+	if (length % dev->maxpacket == 0) {
+		if (!(info->flags & FLAG_SEND_ZLP)) {
+			urb->transfer_buffer_length++;
+			if (skb_tailroom(skb)) {
+				skb->data[skb->len] = 0;
+				__skb_put(skb, 1);
+			}
+		} else
+			urb->transfer_flags |= URB_ZERO_PACKET;
 	}
 
 	spin_lock_irqsave(&dev->txq.lock, flags);



