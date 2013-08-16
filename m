From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 4/7] r8152: adjust some duplicated code
Date: Fri, 16 Aug 2013 16:09:35 +0800
Message-ID: <1376640578-4258-4-git-send-email-hayeswang@realtek.com>
References: <1376640578-4258-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376640578-4258-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Use r8152_get_tx_agg for getting tx agg list
- Replace submit rx with goto submit

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 55 +++++++++++++++++++++++++------------------------
 1 file changed, 28 insertions(+), 27 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 41b99ce..4dee76b 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1067,6 +1067,24 @@ err1:
 	return -ENOMEM;
 }
 
+static struct tx_agg *r8152_get_tx_agg(struct r8152 *tp)
+{
+	struct tx_agg *agg = NULL;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tp->tx_lock, flags);
+	if (!list_empty(&tp->tx_free)) {
+		struct list_head *cursor;
+
+		cursor = tp->tx_free.next;
+		list_del_init(cursor);
+		agg = list_entry(cursor, struct tx_agg, list);
+	}
+	spin_unlock_irqrestore(&tp->tx_lock, flags);
+
+	return agg;
+}
+
 static void
 r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc, struct sk_buff *skb)
 {
@@ -1139,15 +1157,8 @@ static void rx_bottom(struct r8152 *tp)
 
 		agg = list_entry(cursor, struct rx_agg, list);
 		urb = agg->urb;
-		if (urb->actual_length < ETH_ZLEN) {
-			ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
-			spin_lock_irqsave(&tp->rx_lock, flags);
-			if (ret && ret != -ENODEV) {
-				list_add_tail(&agg->list, next);
-				tasklet_schedule(&tp->tl);
-			}
-			continue;
-		}
+		if (urb->actual_length < ETH_ZLEN)
+			goto submit;
 
 		len_used = 0;
 		rx_desc = agg->head;
@@ -1181,6 +1192,7 @@ static void rx_bottom(struct r8152 *tp)
 			len_used += sizeof(struct rx_desc) + pkt_len;
 		}
 
+submit:
 		ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
 		spin_lock_irqsave(&tp->rx_lock, flags);
 		if (ret && ret != -ENODEV) {
@@ -1205,16 +1217,10 @@ static void tx_bottom(struct r8152 *tp)
 
 next_agg:
 	agg = NULL;
-	spin_lock_irqsave(&tp->tx_lock, flags);
-	if (!skb_queue_empty(&tp->tx_queue) && !list_empty(&tp->tx_free)) {
-		struct list_head *cursor;
-
-		cursor = tp->tx_free.next;
-		list_del_init(cursor);
-		agg = list_entry(cursor, struct tx_agg, list);
-	}
-	spin_unlock_irqrestore(&tp->tx_lock, flags);
+	if (skb_queue_empty(&tp->tx_queue))
+		return;
 
+	agg = r8152_get_tx_agg(tp);
 	if (!agg)
 		return;
 
@@ -1382,15 +1388,10 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	spin_lock_irqsave(&tp->tx_lock, flags);
-	if (!list_empty(&tp->tx_free) && skb_queue_empty(&tp->tx_queue)) {
-		struct list_head *cursor;
-
-		cursor = tp->tx_free.next;
-		list_del_init(cursor);
-		agg = list_entry(cursor, struct tx_agg, list);
-	}
-	spin_unlock_irqrestore(&tp->tx_lock, flags);
+	/* If tx_queue is not empty, it means at least one previous packt */
+	/* is waiting for sending. Don't send current one before it.      */
+	if (skb_queue_empty(&tp->tx_queue))
+		agg = r8152_get_tx_agg(tp);
 
 	if (!agg) {
 		skb_queue_tail(&tp->tx_queue, skb);
-- 
1.8.3.1
