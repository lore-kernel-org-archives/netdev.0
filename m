From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 05/14] r8152: reduce the frequency of spin_lock
Date: Tue, 18 Feb 2014 21:49:02 +0800
Message-ID: <1392731351-25502-6-git-send-email-hayeswang@realtek.com>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace getting one item from a list with getting the whole list one time.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 47 ++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 38 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3847c35..2a778fa 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1299,9 +1299,16 @@ r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc, struct sk_buff *skb)
 
 static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 {
+	struct sk_buff_head skb_head, *tx_queue = &tp->tx_queue;
+	unsigned long flags;
 	int remain;
 	u8 *tx_data;
 
+	__skb_queue_head_init(&skb_head);
+	spin_lock_irqsave(&tx_queue->lock, flags);
+	skb_queue_splice_init(tx_queue, &skb_head);
+	spin_unlock_irqrestore(&tx_queue->lock, flags);
+
 	tx_data = agg->head;
 	agg->skb_num = agg->skb_len = 0;
 	remain = rx_buf_sz;
@@ -1311,14 +1318,14 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 		struct sk_buff *skb;
 		unsigned int len;
 
-		skb = skb_dequeue(&tp->tx_queue);
+		skb = __skb_dequeue(&skb_head);
 		if (!skb)
 			break;
 
 		remain -= sizeof(*tx_desc);
 		len = skb->len;
 		if (remain < len) {
-			skb_queue_head(&tp->tx_queue, skb);
+			__skb_queue_head(&skb_head, skb);
 			break;
 		}
 
@@ -1336,6 +1343,12 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 		remain = rx_buf_sz - (int)(tx_agg_align(tx_data) - agg->head);
 	}
 
+	if (!skb_queue_empty(&skb_head)) {
+		spin_lock_irqsave(&tx_queue->lock, flags);
+		skb_queue_splice(&skb_head, tx_queue);
+		spin_unlock_irqrestore(&tx_queue->lock, flags);
+	}
+
 	netif_tx_lock(tp->netdev);
 
 	if (netif_queue_stopped(tp->netdev) &&
@@ -1354,10 +1367,17 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 static void rx_bottom(struct r8152 *tp)
 {
 	unsigned long flags;
-	struct list_head *cursor, *next;
+	struct list_head *cursor, *next, rx_queue;
 
+	if (list_empty(&tp->rx_done))
+		return;
+
+	INIT_LIST_HEAD(&rx_queue);
 	spin_lock_irqsave(&tp->rx_lock, flags);
-	list_for_each_safe(cursor, next, &tp->rx_done) {
+	list_splice_init(&tp->rx_done, &rx_queue);
+	spin_unlock_irqrestore(&tp->rx_lock, flags);
+
+	list_for_each_safe(cursor, next, &rx_queue) {
 		struct rx_desc *rx_desc;
 		struct rx_agg *agg;
 		int len_used = 0;
@@ -1366,7 +1386,6 @@ static void rx_bottom(struct r8152 *tp)
 		int ret;
 
 		list_del_init(cursor);
-		spin_unlock_irqrestore(&tp->rx_lock, flags);
 
 		agg = list_entry(cursor, struct rx_agg, list);
 		urb = agg->urb;
@@ -1416,13 +1435,13 @@ static void rx_bottom(struct r8152 *tp)
 
 submit:
 		ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
-		spin_lock_irqsave(&tp->rx_lock, flags);
 		if (ret && ret != -ENODEV) {
-			list_add_tail(&agg->list, next);
+			spin_lock_irqsave(&tp->rx_lock, flags);
+			list_add_tail(&agg->list, &tp->rx_done);
+			spin_unlock_irqrestore(&tp->rx_lock, flags);
 			tasklet_schedule(&tp->tl);
 		}
 	}
-	spin_unlock_irqrestore(&tp->rx_lock, flags);
 }
 
 static void tx_bottom(struct r8152 *tp)
@@ -1496,9 +1515,19 @@ int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags)
 static void rtl_drop_queued_tx(struct r8152 *tp)
 {
 	struct net_device_stats *stats = &tp->netdev->stats;
+	struct sk_buff_head skb_head, *tx_queue = &tp->tx_queue;
+	unsigned long flags;
 	struct sk_buff *skb;
 
-	while ((skb = skb_dequeue(&tp->tx_queue))) {
+	if (skb_queue_empty(tx_queue))
+		return;
+
+	__skb_queue_head_init(&skb_head);
+	spin_lock_irqsave(&tx_queue->lock, flags);
+	skb_queue_splice_init(tx_queue, &skb_head);
+	spin_unlock_irqrestore(&tx_queue->lock, flags);
+
+	while ((skb = __skb_dequeue(&skb_head))) {
 		dev_kfree_skb(skb);
 		stats->tx_dropped++;
 	}
-- 
1.8.4.2
