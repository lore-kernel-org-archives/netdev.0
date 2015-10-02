From: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v1 1/5] asix: Rename remaining and size for clarity
Date: Fri, 2 Oct 2015 14:29:04 +0100
Message-ID: <1443792548-2025-2-git-send-email-Dean_Jenkins@mentor.com>
References: <1443792548-2025-1-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <bjorn-yOkvZcmFvRU@public.gmane.org>, <linux-AegXhGwVzVhoAEGGzP886w@public.gmane.org>,
	Mark Craske <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
	Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443792548-2025-1-git-send-email-Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Mark Craske <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/usb/asix.h        |    2 +-
 drivers/net/usb/asix_common.c |   41 +++++++++++++++++++++--------------------
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
index 5d049d0..a2d3ea6 100644
--- a/drivers/net/usb/asix.h
+++ b/drivers/net/usb/asix.h
@@ -168,7 +168,7 @@ struct asix_data {
 struct asix_rx_fixup_info {
 	struct sk_buff *ax_skb;
 	u32 header;
-	u16 size;
+	u16 remaining;
 	bool split_head;
 };
 
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 75d6f26..2bd5bdd 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -54,12 +54,13 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
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
@@ -81,42 +82,42 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 				offset += sizeof(u32);
 			}
 
-			/* get the packet length */
-			rx->size = (u16) (rx->header & 0x7ff);
-			if (rx->size != ((~rx->header >> 16) & 0x7ff)) {
+			/* take frame length from Data header 32-bit word */
+			size = (u16)(rx->header & 0x7ff);
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

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
