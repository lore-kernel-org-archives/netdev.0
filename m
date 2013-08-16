From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/7] r8152: replace lockflags with flags
Date: Fri, 16 Aug 2013 16:09:34 +0800
Message-ID: <1376640578-4258-3-git-send-email-hayeswang@realtek.com>
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

Replace lockflags with flags.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 48 ++++++++++++++++++++++++------------------------
 1 file changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index a18f02d..41b99ce 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -769,7 +769,7 @@ static struct net_device_stats *rtl8152_get_stats(struct net_device *dev)
 static void read_bulk_callback(struct urb *urb)
 {
 	struct net_device *netdev;
-	unsigned long lockflags;
+	unsigned long flags;
 	int status = urb->status;
 	struct rx_agg *agg;
 	struct r8152 *tp;
@@ -798,9 +798,9 @@ static void read_bulk_callback(struct urb *urb)
 		if (urb->actual_length < ETH_ZLEN)
 			break;
 
-		spin_lock_irqsave(&tp->rx_lock, lockflags);
+		spin_lock_irqsave(&tp->rx_lock, flags);
 		list_add_tail(&agg->list, &tp->rx_done);
-		spin_unlock_irqrestore(&tp->rx_lock, lockflags);
+		spin_unlock_irqrestore(&tp->rx_lock, flags);
 		tasklet_schedule(&tp->tl);
 		return;
 	case -ESHUTDOWN:
@@ -821,9 +821,9 @@ static void read_bulk_callback(struct urb *urb)
 	if (result == -ENODEV) {
 		netif_device_detach(tp->netdev);
 	} else if (result) {
-		spin_lock_irqsave(&tp->rx_lock, lockflags);
+		spin_lock_irqsave(&tp->rx_lock, flags);
 		list_add_tail(&agg->list, &tp->rx_done);
-		spin_unlock_irqrestore(&tp->rx_lock, lockflags);
+		spin_unlock_irqrestore(&tp->rx_lock, flags);
 		tasklet_schedule(&tp->tl);
 	}
 }
@@ -831,7 +831,7 @@ static void read_bulk_callback(struct urb *urb)
 static void write_bulk_callback(struct urb *urb)
 {
 	struct net_device_stats *stats;
-	unsigned long lockflags;
+	unsigned long flags;
 	struct tx_agg *agg;
 	struct r8152 *tp;
 	int status = urb->status;
@@ -853,9 +853,9 @@ static void write_bulk_callback(struct urb *urb)
 		stats->tx_bytes += agg->skb_len;
 	}
 
-	spin_lock_irqsave(&tp->tx_lock, lockflags);
+	spin_lock_irqsave(&tp->tx_lock, flags);
 	list_add_tail(&agg->list, &tp->tx_free);
-	spin_unlock_irqrestore(&tp->tx_lock, lockflags);
+	spin_unlock_irqrestore(&tp->tx_lock, flags);
 
 	if (!netif_carrier_ok(tp->netdev))
 		return;
@@ -1119,7 +1119,7 @@ static void rx_bottom(struct r8152 *tp)
 	struct net_device *netdev;
 	struct rx_agg *agg;
 	struct rx_desc *rx_desc;
-	unsigned long lockflags;
+	unsigned long flags;
 	struct list_head *cursor, *next;
 	struct sk_buff *skb;
 	struct urb *urb;
@@ -1132,16 +1132,16 @@ static void rx_bottom(struct r8152 *tp)
 
 	stats = rtl8152_get_stats(netdev);
 
-	spin_lock_irqsave(&tp->rx_lock, lockflags);
+	spin_lock_irqsave(&tp->rx_lock, flags);
 	list_for_each_safe(cursor, next, &tp->rx_done) {
 		list_del_init(cursor);
-		spin_unlock_irqrestore(&tp->rx_lock, lockflags);
+		spin_unlock_irqrestore(&tp->rx_lock, flags);
 
 		agg = list_entry(cursor, struct rx_agg, list);
 		urb = agg->urb;
 		if (urb->actual_length < ETH_ZLEN) {
 			ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
-			spin_lock_irqsave(&tp->rx_lock, lockflags);
+			spin_lock_irqsave(&tp->rx_lock, flags);
 			if (ret && ret != -ENODEV) {
 				list_add_tail(&agg->list, next);
 				tasklet_schedule(&tp->tl);
@@ -1182,13 +1182,13 @@ static void rx_bottom(struct r8152 *tp)
 		}
 
 		ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
-		spin_lock_irqsave(&tp->rx_lock, lockflags);
+		spin_lock_irqsave(&tp->rx_lock, flags);
 		if (ret && ret != -ENODEV) {
 			list_add_tail(&agg->list, next);
 			tasklet_schedule(&tp->tl);
 		}
 	}
-	spin_unlock_irqrestore(&tp->rx_lock, lockflags);
+	spin_unlock_irqrestore(&tp->rx_lock, flags);
 }
 
 static void tx_bottom(struct r8152 *tp)
@@ -1196,7 +1196,7 @@ static void tx_bottom(struct r8152 *tp)
 	struct net_device_stats *stats;
 	struct net_device *netdev;
 	struct tx_agg *agg;
-	unsigned long lockflags;
+	unsigned long flags;
 	u32 remain, total;
 	u8 *tx_data;
 	int res;
@@ -1205,7 +1205,7 @@ static void tx_bottom(struct r8152 *tp)
 
 next_agg:
 	agg = NULL;
-	spin_lock_irqsave(&tp->tx_lock, lockflags);
+	spin_lock_irqsave(&tp->tx_lock, flags);
 	if (!skb_queue_empty(&tp->tx_queue) && !list_empty(&tp->tx_free)) {
 		struct list_head *cursor;
 
@@ -1213,7 +1213,7 @@ next_agg:
 		list_del_init(cursor);
 		agg = list_entry(cursor, struct tx_agg, list);
 	}
-	spin_unlock_irqrestore(&tp->tx_lock, lockflags);
+	spin_unlock_irqrestore(&tp->tx_lock, flags);
 
 	if (!agg)
 		return;
@@ -1268,9 +1268,9 @@ next_agg:
 			netif_warn(tp, tx_err, netdev,
 				   "failed tx_urb %d\n", res);
 			stats->tx_dropped += agg->skb_num;
-			spin_lock_irqsave(&tp->tx_lock, lockflags);
+			spin_lock_irqsave(&tp->tx_lock, flags);
 			list_add_tail(&agg->list, &tp->tx_free);
-			spin_unlock_irqrestore(&tp->tx_lock, lockflags);
+			spin_unlock_irqrestore(&tp->tx_lock, flags);
 		}
 		return;
 	}
@@ -1373,7 +1373,7 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 {
 	struct r8152 *tp = netdev_priv(netdev);
 	struct net_device_stats *stats = rtl8152_get_stats(netdev);
-	unsigned long lockflags;
+	unsigned long flags;
 	struct tx_agg *agg = NULL;
 	struct tx_desc *tx_desc;
 	unsigned int len;
@@ -1382,7 +1382,7 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	spin_lock_irqsave(&tp->tx_lock, lockflags);
+	spin_lock_irqsave(&tp->tx_lock, flags);
 	if (!list_empty(&tp->tx_free) && skb_queue_empty(&tp->tx_queue)) {
 		struct list_head *cursor;
 
@@ -1390,7 +1390,7 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 		list_del_init(cursor);
 		agg = list_entry(cursor, struct tx_agg, list);
 	}
-	spin_unlock_irqrestore(&tp->tx_lock, lockflags);
+	spin_unlock_irqrestore(&tp->tx_lock, flags);
 
 	if (!agg) {
 		skb_queue_tail(&tp->tx_queue, skb);
@@ -1419,9 +1419,9 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 			netif_warn(tp, tx_err, netdev,
 				   "failed tx_urb %d\n", res);
 			stats->tx_dropped++;
-			spin_lock_irqsave(&tp->tx_lock, lockflags);
+			spin_lock_irqsave(&tp->tx_lock, flags);
 			list_add_tail(&agg->list, &tp->tx_free);
-			spin_unlock_irqrestore(&tp->tx_lock, lockflags);
+			spin_unlock_irqrestore(&tp->tx_lock, flags);
 		}
 	}
 
-- 
1.8.3.1
