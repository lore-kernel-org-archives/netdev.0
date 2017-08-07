From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH V1 2/3] asix: Ensure asix_rx_fixup_info members are all reset
Date: Mon, 7 Aug 2017 09:50:15 +0100
Message-ID: <1502095816-3255-3-git-send-email-Dean_Jenkins@mentor.com>
References: <1502095816-3255-1-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
        Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:36326 "EHLO
        relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752468AbdHGIuj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:50:39 -0400
In-Reply-To: <1502095816-3255-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a risk that the members of the structure asix_rx_fixup_info
become unsynchronised leading to the possibility of a malfunction.

For example, rx->split_head was not being set to false after an
error was detected so potentially could cause a malformed 32-bit
Data header word to be formed.

Therefore add function reset_asix_rx_fixup_info() to reset all the
members of asix_rx_fixup_info so that future processing will start
with known initial conditions.

Also, if (skb->len != offset) becomes true then call
reset_asix_rx_fixup_info() so that the processing of the next URB
starts with known initial conditions. Without the call, the check
does nothing which potentially could lead to a malfunction
when the next URB is processed.

In addition, for robustness, call reset_asix_rx_fixup_info() before
every error path's "return 0". This ensures that the next URB is
processed from known initial conditions.

Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
---
 drivers/net/usb/asix_common.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 6983b6b..fda74f3 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -75,6 +75,27 @@ void asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			       value, index, data, size);
 }
 
+static void reset_asix_rx_fixup_info(struct asix_rx_fixup_info *rx)
+{
+	/* Reset the variables that have a lifetime outside of
+	 * asix_rx_fixup_internal() so that future processing starts from a
+	 * known set of initial conditions.
+	 */
+
+	if (rx->ax_skb) {
+		/* Discard any incomplete Ethernet frame in the netdev buffer */
+		kfree_skb(rx->ax_skb);
+		rx->ax_skb = NULL;
+	}
+
+	/* Assume the Data header 32-bit word is at the start of the current
+	 * or next URB socket buffer so reset all the state variables.
+	 */
+	rx->remaining = 0;
+	rx->split_head = false;
+	rx->header = 0;
+}
+
 int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 			   struct asix_rx_fixup_info *rx)
 {
@@ -99,15 +120,7 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 		if (size != ((~rx->header >> 16) & 0x7ff)) {
 			netdev_err(dev->net, "asix_rx_fixup() Data Header synchronisation was lost, remaining %d\n",
 				   rx->remaining);
-			if (rx->ax_skb) {
-				kfree_skb(rx->ax_skb);
-				rx->ax_skb = NULL;
-				/* Discard the incomplete netdev Ethernet frame
-				 * and assume the Data header is at the start of
-				 * the current URB socket buffer.
-				 */
-			}
-			rx->remaining = 0;
+			reset_asix_rx_fixup_info(rx);
 		}
 	}
 
@@ -139,11 +152,13 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 			if (size != ((~rx->header >> 16) & 0x7ff)) {
 				netdev_err(dev->net, "asix_rx_fixup() Bad Header Length 0x%x, offset %d\n",
 					   rx->header, offset);
+				reset_asix_rx_fixup_info(rx);
 				return 0;
 			}
 			if (size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) {
 				netdev_dbg(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
 					   size);
+				reset_asix_rx_fixup_info(rx);
 				return 0;
 			}
 
@@ -180,6 +195,7 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 	if (skb->len != offset) {
 		netdev_err(dev->net, "asix_rx_fixup() Bad SKB Length %d, %d\n",
 			   skb->len, offset);
+		reset_asix_rx_fixup_info(rx);
 		return 0;
 	}
 
-- 
2.7.4
