From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH 2/4] asix: Tidy-up asix_rx_fixup_internal() logic
Date: Wed, 11 Dec 2013 10:50:26 +0000
Message-ID: <1386759028-3534-3-git-send-email-Dean_Jenkins@mentor.com>
References: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway05.m3-connect.de ([88.79.237.15]:51949 "EHLO
	mail.mentor.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751506Ab3LKK7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 05:59:14 -0500
In-Reply-To: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tidy-up the Data header 32-bit word synchronisation logic in
asix_rx_fixup_internal() by removing redundant logic tests.

Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
---
 drivers/net/usb/asix_common.c |   45 +++++++++++++++++++----------------------
 1 file changed, 21 insertions(+), 24 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 2a5b2f8..1d44c1e 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -62,21 +62,19 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 		unsigned char *data;
 
 		if (!rx->remaining) {
-			if ((skb->len - offset == sizeof(u16)) ||
-			    rx->split_head) {
-				if(!rx->split_head) {
-					rx->header = get_unaligned_le16(
-							skb->data + offset);
-					rx->split_head = true;
-					offset += sizeof(u16);
-					break;
-				} else {
-					rx->header |= (get_unaligned_le16(
-							skb->data + offset)
-							<< 16);
-					rx->split_head = false;
-					offset += sizeof(u16);
-				}
+			if (skb->len - offset == sizeof(u16)) {
+				rx->header = get_unaligned_le16(
+						skb->data + offset);
+				rx->split_head = true;
+				offset += sizeof(u16);
+				break;
+			}
+
+			if (rx->split_head == true) {
+				rx->header |= (get_unaligned_le16(
+						skb->data + offset) << 16);
+				rx->split_head = false;
+				offset += sizeof(u16);
 			} else {
 				rx->header = get_unaligned_le32(skb->data +
 								offset);
@@ -93,16 +91,15 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 			rx->ax_skb = netdev_alloc_skb_ip_align(dev->net, size);
 			if (!rx->ax_skb)
 				return 0;
-			rx->remaining = size;
-		}
 
-		if (rx->remaining > dev->net->mtu + ETH_HLEN + VLAN_HLEN) {
-			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
-				   rx->remaining);
-			kfree_skb(rx->ax_skb);
-			rx->ax_skb = NULL;
-			rx->remaining = 0;
-			return 0;
+			if (size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) {
+				netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
+					   size);
+				kfree_skb(rx->ax_skb);
+				rx->ax_skb = NULL;
+				return 0;
+			}
+			rx->remaining = size;
 		}
 
 		if (rx->remaining > skb->len - offset) {
-- 
1.7.9.5
