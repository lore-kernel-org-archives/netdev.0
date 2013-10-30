From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v2 1/3] r8152: fix tx/rx memory overflow
Date: Wed, 30 Oct 2013 15:13:38 +0800
Message-ID: <1383117220-893-2-git-send-email-hayeswang@realtek.com>
References: <1383033377-1178-1-git-send-email-hayeswang@realtek.com>
 <1383117220-893-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383117220-893-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The tx/rx would access the memory which is out of the desired range.
Modify the method of checking the end of the memory to avoid it.

For r8152_tx_agg_fill(), the variable remain may become negative.
However, the declaration is unsigned, so the while loop wouldn't
break when reach the end of the desied memory. Although change the
declaration from unsigned to signed is enough to fix it, I also
modify the checking method for safe. Replace

		remain = rx_buf_sz - sizeof(*tx_desc) -
			 (u32)((void *)tx_data - agg->head);

with

		remain = rx_buf_sz - (int)(tx_agg_align(tx_data) - agg->head);

to make sure the variable remain is always positive. Then, the
overflow wouldn't happen.

For rx_bottom(), the rx_desc should not be used to calculate the
packet length before making sure the rx_desc is in the desired range.
Change the checking to two parts. First, check the descriptor is in
the memory. The other, using the descriptor to find out the packet
length and check if the packet is in the memory.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 30 +++++++++++++++++-------------
 1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f3fce41..5dbfe50 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -24,7 +24,7 @@
 #include <linux/ipv6.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.01.0 (2013/08/12)"
+#define DRIVER_VERSION "v1.02.0 (2013/10/28)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152 Based USB 2.0 Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -1136,14 +1136,14 @@ r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc, struct sk_buff *skb)
 
 static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 {
-	u32 remain;
+	int remain;
 	u8 *tx_data;
 
 	tx_data = agg->head;
 	agg->skb_num = agg->skb_len = 0;
-	remain = rx_buf_sz - sizeof(struct tx_desc);
+	remain = rx_buf_sz;
 
-	while (remain >= ETH_ZLEN) {
+	while (remain >= ETH_ZLEN + sizeof(struct tx_desc)) {
 		struct tx_desc *tx_desc;
 		struct sk_buff *skb;
 		unsigned int len;
@@ -1152,12 +1152,14 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 		if (!skb)
 			break;
 
+		remain -= sizeof(*tx_desc);
 		len = skb->len;
 		if (remain < len) {
 			skb_queue_head(&tp->tx_queue, skb);
 			break;
 		}
 
+		tx_data = tx_agg_align(tx_data);
 		tx_desc = (struct tx_desc *)tx_data;
 		tx_data += sizeof(*tx_desc);
 
@@ -1167,9 +1169,8 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 		agg->skb_len += len;
 		dev_kfree_skb_any(skb);
 
-		tx_data = tx_agg_align(tx_data + len);
-		remain = rx_buf_sz - sizeof(*tx_desc) -
-			 (u32)((void *)tx_data - agg->head);
+		tx_data += len;
+		remain = rx_buf_sz - (int)(tx_agg_align(tx_data) - agg->head);
 	}
 
 	usb_fill_bulk_urb(agg->urb, tp->udev, usb_sndbulkpipe(tp->udev, 2),
@@ -1188,7 +1189,6 @@ static void rx_bottom(struct r8152 *tp)
 	list_for_each_safe(cursor, next, &tp->rx_done) {
 		struct rx_desc *rx_desc;
 		struct rx_agg *agg;
-		unsigned pkt_len;
 		int len_used = 0;
 		struct urb *urb;
 		u8 *rx_data;
@@ -1204,17 +1204,22 @@ static void rx_bottom(struct r8152 *tp)
 
 		rx_desc = agg->head;
 		rx_data = agg->head;
-		pkt_len = le32_to_cpu(rx_desc->opts1) & RX_LEN_MASK;
-		len_used += sizeof(struct rx_desc) + pkt_len;
+		len_used += sizeof(struct rx_desc);
 
-		while (urb->actual_length >= len_used) {
+		while (urb->actual_length > len_used) {
 			struct net_device *netdev = tp->netdev;
 			struct net_device_stats *stats;
+			unsigned pkt_len;
 			struct sk_buff *skb;
 
+			pkt_len = le32_to_cpu(rx_desc->opts1) & RX_LEN_MASK;
 			if (pkt_len < ETH_ZLEN)
 				break;
 
+			len_used += pkt_len;
+			if (urb->actual_length < len_used)
+				break;
+
 			stats = rtl8152_get_stats(netdev);
 
 			pkt_len -= 4; /* CRC */
@@ -1234,9 +1239,8 @@ static void rx_bottom(struct r8152 *tp)
 
 			rx_data = rx_agg_align(rx_data + pkt_len + 4);
 			rx_desc = (struct rx_desc *)rx_data;
-			pkt_len = le32_to_cpu(rx_desc->opts1) & RX_LEN_MASK;
 			len_used = (int)(rx_data - (u8 *)agg->head);
-			len_used += sizeof(struct rx_desc) + pkt_len;
+			len_used += sizeof(struct rx_desc);
 		}
 
 submit:
-- 
1.8.3.1
