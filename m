From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/7] r8152: replace spin_lock_irqsave and spin_unlock_irqrestore
Date: Fri, 7 Mar 2014 11:04:34 +0800
Message-ID: <1394161480-2918-2-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1394161480-2918-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394161480-2918-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use spin_lock and spin_unlock in interrupt context.

The ndo_start_xmit would not be called in interrupt context, so
replace the relative spin_lock_irqsave and spin_unlock_irqrestore
with spin_lock_bh and spin_unlock_bh.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 28 ++++++++++++----------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index b8eee36..8ecb41b 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -963,7 +963,6 @@ static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
 static void read_bulk_callback(struct urb *urb)
 {
 	struct net_device *netdev;
-	unsigned long flags;
 	int status = urb->status;
 	struct rx_agg *agg;
 	struct r8152 *tp;
@@ -997,9 +996,9 @@ static void read_bulk_callback(struct urb *urb)
 		if (urb->actual_length < ETH_ZLEN)
 			break;
 
-		spin_lock_irqsave(&tp->rx_lock, flags);
+		spin_lock(&tp->rx_lock);
 		list_add_tail(&agg->list, &tp->rx_done);
-		spin_unlock_irqrestore(&tp->rx_lock, flags);
+		spin_unlock(&tp->rx_lock);
 		tasklet_schedule(&tp->tl);
 		return;
 	case -ESHUTDOWN:
@@ -1022,9 +1021,9 @@ static void read_bulk_callback(struct urb *urb)
 	if (result == -ENODEV) {
 		netif_device_detach(tp->netdev);
 	} else if (result) {
-		spin_lock_irqsave(&tp->rx_lock, flags);
+		spin_lock(&tp->rx_lock);
 		list_add_tail(&agg->list, &tp->rx_done);
-		spin_unlock_irqrestore(&tp->rx_lock, flags);
+		spin_unlock(&tp->rx_lock);
 		tasklet_schedule(&tp->tl);
 	}
 }
@@ -1033,7 +1032,6 @@ static void write_bulk_callback(struct urb *urb)
 {
 	struct net_device_stats *stats;
 	struct net_device *netdev;
-	unsigned long flags;
 	struct tx_agg *agg;
 	struct r8152 *tp;
 	int status = urb->status;
@@ -1057,9 +1055,9 @@ static void write_bulk_callback(struct urb *urb)
 		stats->tx_bytes += agg->skb_len;
 	}
 
-	spin_lock_irqsave(&tp->tx_lock, flags);
+	spin_lock(&tp->tx_lock);
 	list_add_tail(&agg->list, &tp->tx_free);
-	spin_unlock_irqrestore(&tp->tx_lock, flags);
+	spin_unlock(&tp->tx_lock);
 
 	usb_autopm_put_interface_async(tp->intf);
 
@@ -1330,14 +1328,13 @@ r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc, struct sk_buff *skb)
 static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 {
 	struct sk_buff_head skb_head, *tx_queue = &tp->tx_queue;
-	unsigned long flags;
 	int remain, ret;
 	u8 *tx_data;
 
 	__skb_queue_head_init(&skb_head);
-	spin_lock_irqsave(&tx_queue->lock, flags);
+	spin_lock_bh(&tx_queue->lock);
 	skb_queue_splice_init(tx_queue, &skb_head);
-	spin_unlock_irqrestore(&tx_queue->lock, flags);
+	spin_unlock_bh(&tx_queue->lock);
 
 	tx_data = agg->head;
 	agg->skb_num = agg->skb_len = 0;
@@ -1374,9 +1371,9 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 	}
 
 	if (!skb_queue_empty(&skb_head)) {
-		spin_lock_irqsave(&tx_queue->lock, flags);
+		spin_lock_bh(&tx_queue->lock);
 		skb_queue_splice(&skb_head, tx_queue);
-		spin_unlock_irqrestore(&tx_queue->lock, flags);
+		spin_unlock_bh(&tx_queue->lock);
 	}
 
 	netif_tx_lock_bh(tp->netdev);
@@ -1551,16 +1548,15 @@ static void rtl_drop_queued_tx(struct r8152 *tp)
 {
 	struct net_device_stats *stats = &tp->netdev->stats;
 	struct sk_buff_head skb_head, *tx_queue = &tp->tx_queue;
-	unsigned long flags;
 	struct sk_buff *skb;
 
 	if (skb_queue_empty(tx_queue))
 		return;
 
 	__skb_queue_head_init(&skb_head);
-	spin_lock_irqsave(&tx_queue->lock, flags);
+	spin_lock_bh(&tx_queue->lock);
 	skb_queue_splice_init(tx_queue, &skb_head);
-	spin_unlock_irqrestore(&tx_queue->lock, flags);
+	spin_unlock_bh(&tx_queue->lock);
 
 	while ((skb = __skb_dequeue(&skb_head))) {
 		dev_kfree_skb(skb);
-- 
1.8.4.2
