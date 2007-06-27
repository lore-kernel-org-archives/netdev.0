From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] usbnet: Zero padding byte if there is tail room in skb
Date: Wed, 27 Jun 2007 08:48:15 +0200
Message-ID: <87y7i5evv4.fsf@p4.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: david-b@pacbell.net
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp40.mobistarmail.be ([193.252.23.61]:50164 "EHLO
	smtp40.mobistarmail.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758597AbXF0Gr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 02:47:57 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf4017.mobistarmail.be (SMTP Server) with ESMTP id 2C42B70000A4
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 08:47:56 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Usbnet adds a padding byte if a 0 byte USB packet would be sent. Zero
padding byte if there is tail room in skb.

Signed-of-by: Peter Korsgaard <jacmet@sunsite.dk>
Acked-by: David Brownell <dbrownell@users.sourceforge.net>

---
 drivers/net/usb/usbnet.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: linux-2.6.22-rc6/drivers/net/usb/usbnet.c
===================================================================
--- linux-2.6.22-rc6.orig/drivers/net/usb/usbnet.c
+++ linux-2.6.22-rc6/drivers/net/usb/usbnet.c
@@ -953,11 +953,14 @@
 	/* don't assume the hardware handles USB_ZERO_PACKET
 	 * NOTE:  strictly conforming cdc-ether devices should expect
 	 * the ZLP here, but ignore the one-byte packet.
-	 *
-	 * FIXME zero that byte, if it doesn't require a new skb.
 	 */
-	if ((length % dev->maxpacket) == 0)
+	if ((length % dev->maxpacket) == 0) {
 		urb->transfer_buffer_length++;
+		if (skb_tailroom(skb)) {
+			skb->data[skb->len] = 0;
+			__skb_put(skb, 1);
+		}
+	}
 
 	spin_lock_irqsave (&dev->txq.lock, flags);

-- 
Bye, Peter Korsgaard

