From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH 1/4] asix: Rename remaining and size for clarity
Date: Wed, 11 Dec 2013 10:50:25 +0000
Message-ID: <1386759028-3534-2-git-send-email-Dean_Jenkins@mentor.com>
References: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway05.m3-connect.de ([88.79.237.15]:55415 "EHLO
	mail.mentor.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751482Ab3LKK7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 05:59:14 -0500
In-Reply-To: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Data header synchronisation is easier to understand
if the variables "remaining" and "size" are renamed.

Therefore, the lifetime of the "remaining" variable exists
outside of asix_rx_fixup_internal() and is used to indicate
any remaining pending bytes of the Ethernet frame that need
to be obtained from the next socket buffer. This allows an
Ethernet frame to span across multiple socket buffers.

"size" is now local to asix_rx_fixup_internal() and contains
the size read from the Data header 32-bit word.

Add "copy_length" to hold the number of the Ethernet frame
bytes (maybe a part of a full frame) that are to be copied
out of the socket buffer.

Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
---
 drivers/net/usb/asix.h        |    2 +-
 drivers/net/usb/asix_common.c |   41 +++++++++++++++++++++--------------------
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index 346c032..17a9b83 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -170,7 +170,7 @@ struct asix_data {
 struct asix_rx_fixup_info {
 	struct sk_buff *ax_skb;
 	u32 header;
-	u16 size;
+	u16 remaining;
 	bool split_head;
 };
 
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 577c72d..2a5b2f8 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -55,12 +55,13 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 			   struct asix_rx_fixup_info *rx)
 {
 	int offset = 0;
+	u16 size;
 
 	while (offset + sizeof(u16) <= skb->len) {
-		u16 remaining = 0;
+		u16 copy_length;
 		unsigned char *data;
 
-		if (!rx->size) {
+		if (!rx->remaining) {
 			if ((skb->len - offset == sizeof(u16)) ||
 			    rx->split_head) {
 				if(!rx->split_head) {
@@ -82,42 +83,42 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 				offset += sizeof(u32);
 			}
 
-			/* get the packet length */
-			rx->size = (u16) (rx->header & 0x7ff);
-			if (rx->size != ((~rx->header >> 16) & 0x7ff)) {
+			/* take frame length from Data header 32-bit word */
+			size = (u16) (rx->header & 0x7ff);
+			if (size != ((~rx->header >> 16) & 0x7ff)) {
 				netdev_err(dev->net, "asix_rx_fixup() Bad Header Length 0x%x, offset %d\n",
 					   rx->header, offset);
-				rx->size = 0;
 				return 0;
 			}
-			rx->ax_skb = netdev_alloc_skb_ip_align(dev->net,
-							       rx->size);
+			rx->ax_skb = netdev_alloc_skb_ip_align(dev->net, size);
 			if (!rx->ax_skb)
 				return 0;
+			rx->remaining = size;
 		}
 
-		if (rx->size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) {
+		if (rx->remaining > dev->net->mtu + ETH_HLEN + VLAN_HLEN) {
 			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
-				   rx->size);
+				   rx->remaining);
 			kfree_skb(rx->ax_skb);
 			rx->ax_skb = NULL;
-			rx->size = 0U;
-
+			rx->remaining = 0;
 			return 0;
 		}
 
-		if (rx->size > skb->len - offset) {
-			remaining = rx->size - (skb->len - offset);
-			rx->size = skb->len - offset;
+		if (rx->remaining > skb->len - offset) {
+			copy_length = skb->len - offset;
+			rx->remaining -= copy_length;
+		} else {
+			copy_length = rx->remaining;
+			rx->remaining = 0;
 		}
 
-		data = skb_put(rx->ax_skb, rx->size);
-		memcpy(data, skb->data + offset, rx->size);
-		if (!remaining)
+		data = skb_put(rx->ax_skb, copy_length);
+		memcpy(data, skb->data + offset, copy_length);
+		if (!rx->remaining)
 			usbnet_skb_return(dev, rx->ax_skb);
 
-		offset += (rx->size + 1) & 0xfffe;
-		rx->size = remaining;
+		offset += (copy_length + 1) & 0xfffe;
 	}
 
 	if (skb->len != offset) {
-- 
1.7.9.5
