From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 6/7] r8152: adjust tx_bottom function
Date: Fri, 16 Aug 2013 16:09:37 +0800
Message-ID: <1376640578-4258-6-git-send-email-hayeswang@realtek.com>
References: <1376640578-4258-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:52633 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595Ab3HPIKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 04:10:52 -0400
In-Reply-To: <1376640578-4258-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split some parts of code into another function to simplify
tx_bottom(). Use while loop to replace the goto loop.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 134 ++++++++++++++++++++++++------------------------
 1 file changed, 68 insertions(+), 66 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 0a88f64..825edfe 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1131,6 +1131,51 @@ r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc, struct sk_buff *skb)
 	}
 }
 
+static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
+{
+	u32 remain;
+	u8 *tx_data;
+
+	tx_data = agg->head;
+	agg->skb_num = agg->skb_len = 0;
+	remain = rx_buf_sz - sizeof(struct tx_desc);
+
+	while (remain >= ETH_ZLEN) {
+		struct tx_desc *tx_desc;
+		struct sk_buff *skb;
+		unsigned int len;
+
+		skb = skb_dequeue(&tp->tx_queue);
+		if (!skb)
+			break;
+
+		len = skb->len;
+		if (remain < len) {
+			skb_queue_head(&tp->tx_queue, skb);
+			break;
+		}
+
+		tx_desc = (struct tx_desc *)tx_data;
+		tx_data += sizeof(*tx_desc);
+
+		r8152_tx_csum(tp, tx_desc, skb);
+		memcpy(tx_data, skb->data, len);
+		agg->skb_num++;
+		agg->skb_len += len;
+		dev_kfree_skb_any(skb);
+
+		tx_data = tx_agg_align(tx_data + len);
+		remain = rx_buf_sz - sizeof(*tx_desc) -
+			 (u32)((void *)tx_data - agg->head);
+	}
+
+	usb_fill_bulk_urb(agg->urb, tp->udev, usb_sndbulkpipe(tp->udev, 2),
+			  agg->head, (int)(tx_data - (u8 *)agg->head),
+			  (usb_complete_t)write_bulk_callback, agg);
+
+	return usb_submit_urb(agg->urb, GFP_ATOMIC);
+}
+
 static void rx_bottom(struct r8152 *tp)
 {
 	unsigned long flags;
@@ -1204,82 +1249,39 @@ submit:
 
 static void tx_bottom(struct r8152 *tp)
 {
-	struct net_device_stats *stats;
-	struct net_device *netdev;
-	struct tx_agg *agg;
-	unsigned long flags;
-	u32 remain, total;
-	u8 *tx_data;
 	int res;
 
-	netdev = tp->netdev;
-
-next_agg:
-	agg = NULL;
-	if (skb_queue_empty(&tp->tx_queue))
-		return;
+	do {
+		struct tx_agg *agg;
 
-	agg = r8152_get_tx_agg(tp);
-	if (!agg)
-		return;
-
-	tx_data = agg->head;
-	agg->skb_num = agg->skb_len = 0;
-	remain = rx_buf_sz - sizeof(struct tx_desc);
-	total = 0;
-
-	while (remain >= ETH_ZLEN) {
-		struct tx_desc *tx_desc;
-		struct sk_buff *skb;
-		unsigned int len;
-
-		skb = skb_dequeue(&tp->tx_queue);
-		if (!skb)
+		if (skb_queue_empty(&tp->tx_queue))
 			break;
 
-		len = skb->len;
-		if (remain < len) {
-			skb_queue_head(&tp->tx_queue, skb);
+		agg = r8152_get_tx_agg(tp);
+		if (!agg)
 			break;
-		}
-
-		tx_data = tx_agg_align(tx_data);
-		tx_desc = (struct tx_desc *)tx_data;
-		tx_data += sizeof(*tx_desc);
 
-		r8152_tx_csum(tp, tx_desc, skb);
-		memcpy(tx_data, skb->data, len);
-		agg->skb_num++;
-		agg->skb_len += len;
-		dev_kfree_skb_any(skb);
-
-		tx_data += len;
-		remain = rx_buf_sz - sizeof(*tx_desc) -
-			 (u32)(tx_agg_align(tx_data) - agg->head);
-	}
-
-	usb_fill_bulk_urb(agg->urb, tp->udev, usb_sndbulkpipe(tp->udev, 2),
-			  agg->head, (int)(tx_data - (u8 *)agg->head),
-			  (usb_complete_t)write_bulk_callback, agg);
-	res = usb_submit_urb(agg->urb, GFP_ATOMIC);
+		res = r8152_tx_agg_fill(tp, agg);
+		if (res) {
+			struct net_device_stats *stats;
+			struct net_device *netdev;
+			unsigned long flags;
 
-	stats = rtl8152_get_stats(netdev);
+			netdev = tp->netdev;
+			stats = rtl8152_get_stats(netdev);
 
-	if (res) {
-		/* Can we get/handle EPIPE here? */
-		if (res == -ENODEV) {
-			netif_device_detach(netdev);
-		} else {
-			netif_warn(tp, tx_err, netdev,
-				   "failed tx_urb %d\n", res);
-			stats->tx_dropped += agg->skb_num;
-			spin_lock_irqsave(&tp->tx_lock, flags);
-			list_add_tail(&agg->list, &tp->tx_free);
-			spin_unlock_irqrestore(&tp->tx_lock, flags);
+			if (res == -ENODEV) {
+				netif_device_detach(netdev);
+			} else {
+				netif_warn(tp, tx_err, netdev,
+					   "failed tx_urb %d\n", res);
+				stats->tx_dropped += agg->skb_num;
+				spin_lock_irqsave(&tp->tx_lock, flags);
+				list_add_tail(&agg->list, &tp->tx_free);
+				spin_unlock_irqrestore(&tp->tx_lock, flags);
+			}
 		}
-		return;
-	}
-	goto next_agg;
+	} while (res == 0);
 }
 
 static void bottom_half(unsigned long data)
-- 
1.8.3.1
