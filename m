From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 3/5] net/usb/r8152: modify the tx flow
Date: Mon, 28 Oct 2013 19:58:12 +0800
Message-ID: <1382961494-2272-4-git-send-email-hayeswang@realtek.com>
References: <1382961494-2272-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382961494-2272-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let rtl8152_start_xmit() to queue packet only, and tx_bottom() would
send all of the packets. This simplify the code and make sure all the
packet would be sent by the original order.

Support stopping and waking tx queue. The maximum tx queue length
is 60.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 52 ++++++++++---------------------------------------
 1 file changed, 10 insertions(+), 42 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 815d890..a711025 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -276,6 +276,8 @@ enum rtl_register_content {
 
 #define INTR_LINK		0x0004
 
+#define TX_QLEN			60
+
 #define RTL8152_REQT_READ	0xc0
 #define RTL8152_REQT_WRITE	0x40
 #define RTL8152_REQ_GET_REGS	0x05
@@ -1174,6 +1176,9 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 		remain = rx_buf_sz - (int)(tx_agg_align(tx_data) - agg->head);
 	}
 
+	if (netif_queue_stopped(tp->netdev))
+		netif_wake_queue(tp->netdev);
+
 	usb_fill_bulk_urb(agg->urb, tp->udev, usb_sndbulkpipe(tp->udev, 2),
 			  agg->head, (int)(tx_data - (u8 *)agg->head),
 			  (usb_complete_t)write_bulk_callback, agg);
@@ -1389,53 +1394,16 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 					    struct net_device *netdev)
 {
 	struct r8152 *tp = netdev_priv(netdev);
-	struct net_device_stats *stats = rtl8152_get_stats(netdev);
-	unsigned long flags;
-	struct tx_agg *agg = NULL;
-	struct tx_desc *tx_desc;
-	unsigned int len;
-	u8 *tx_data;
-	int res;
 
 	skb_tx_timestamp(skb);
 
-	/* If tx_queue is not empty, it means at least one previous packt */
-	/* is waiting for sending. Don't send current one before it.      */
-	if (skb_queue_empty(&tp->tx_queue))
-		agg = r8152_get_tx_agg(tp);
-
-	if (!agg) {
-		skb_queue_tail(&tp->tx_queue, skb);
-		return NETDEV_TX_OK;
-	}
+	skb_queue_tail(&tp->tx_queue, skb);
 
-	tx_desc = (struct tx_desc *)agg->head;
-	tx_data = agg->head + sizeof(*tx_desc);
-	agg->skb_num = agg->skb_len = 0;
+	if (skb_queue_len(&tp->tx_queue) > TX_QLEN)
+		netif_stop_queue(netdev);
 
-	len = skb->len;
-	r8152_tx_csum(tp, tx_desc, skb);
-	memcpy(tx_data, skb->data, len);
-	dev_kfree_skb_any(skb);
-	agg->skb_num++;
-	agg->skb_len += len;
-	usb_fill_bulk_urb(agg->urb, tp->udev, usb_sndbulkpipe(tp->udev, 2),
-			  agg->head, len + sizeof(*tx_desc),
-			  (usb_complete_t)write_bulk_callback, agg);
-	res = usb_submit_urb(agg->urb, GFP_ATOMIC);
-	if (res) {
-		/* Can we get/handle EPIPE here? */
-		if (res == -ENODEV) {
-			netif_device_detach(tp->netdev);
-		} else {
-			netif_warn(tp, tx_err, netdev,
-				   "failed tx_urb %d\n", res);
-			stats->tx_dropped++;
-			spin_lock_irqsave(&tp->tx_lock, flags);
-			list_add_tail(&agg->list, &tp->tx_free);
-			spin_unlock_irqrestore(&tp->tx_lock, flags);
-		}
-	}
+	if (!list_empty(&tp->tx_free))
+		tasklet_schedule(&tp->tl);
 
 	return NETDEV_TX_OK;
 }
-- 
1.8.3.1
