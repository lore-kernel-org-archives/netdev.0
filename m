From: Ingo van Lil <inguin@gmx.de>
Subject: [PATCH] Fix tx transfer padding for full-speed USB
Date: Fri, 20 Apr 2012 12:00:21 +0200
Message-ID: <1334916021-9124-1-git-send-email-inguin@gmx.de>
Cc: Ingo van Lil <inguin@gmx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:58757 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753670Ab2DTKAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 06:00:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The asix.c USB Ethernet driver avoids ending a tx transfer with a zero-
length packet by appending a four-byte padding to transfers whose length
is a multiple of maxpacket. However, the hard-coded 512 byte maxpacket
length is valid for high-speed USB only; full-speed USB uses 64 byte
packets.

Signed-off-by: Ingo van Lil <inguin@gmx.de>
---
 drivers/net/usb/asix.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 5ee032c..aeb2702 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -355,7 +355,7 @@ static struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 	u32 packet_len;
 	u32 padbytes = 0xffff0000;
 
-	padlen = ((skb->len + 4) % 512) ? 0 : 4;
+	padlen = ((skb->len + 4) % dev->maxpacket) ? 0 : 4;
 
 	if ((!skb_cloned(skb)) &&
 	    ((headroom + tailroom) >= (4 + padlen))) {
@@ -377,7 +377,7 @@ static struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 	cpu_to_le32s(&packet_len);
 	skb_copy_to_linear_data(skb, &packet_len, sizeof(packet_len));
 
-	if ((skb->len % 512) == 0) {
+	if (padlen) {
 		cpu_to_le32s(&padbytes);
 		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
 		skb_put(skb, sizeof(padbytes));
-- 
1.7.7.6
