From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/7] r8152: up the priority of the transmission
Date: Fri, 7 Mar 2014 11:04:36 +0800
Message-ID: <1394161480-2918-4-git-send-email-hayeswang@realtek.com>
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

move the tx_bottom() from delayed_work to tasklet. It makes the rx
and tx balanced. If the device is in runtime suspend when getting
the tx packet, wakeup the device before trasmitting.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 45 +++++++++++++++++++++++++++------------------
 1 file changed, 27 insertions(+), 18 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 00b3192..f1eaa18 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -447,6 +447,7 @@ enum rtl8152_flags {
 	RTL8152_LINK_CHG,
 	SELECTIVE_SUSPEND,
 	PHY_RESET,
+	SCHEDULE_TASKLET,
 };
 
 /* Define these values to match your device */
@@ -1071,7 +1072,7 @@ static void write_bulk_callback(struct urb *urb)
 		return;
 
 	if (!skb_queue_empty(&tp->tx_queue))
-		schedule_delayed_work(&tp->schedule, 0);
+		tasklet_schedule(&tp->tl);
 }
 
 static void intr_callback(struct urb *urb)
@@ -1335,9 +1336,9 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 	u8 *tx_data;
 
 	__skb_queue_head_init(&skb_head);
-	spin_lock_bh(&tx_queue->lock);
+	spin_lock(&tx_queue->lock);
 	skb_queue_splice_init(tx_queue, &skb_head);
-	spin_unlock_bh(&tx_queue->lock);
+	spin_unlock(&tx_queue->lock);
 
 	tx_data = agg->head;
 	agg->skb_num = agg->skb_len = 0;
@@ -1374,20 +1375,20 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 	}
 
 	if (!skb_queue_empty(&skb_head)) {
-		spin_lock_bh(&tx_queue->lock);
+		spin_lock(&tx_queue->lock);
 		skb_queue_splice(&skb_head, tx_queue);
-		spin_unlock_bh(&tx_queue->lock);
+		spin_unlock(&tx_queue->lock);
 	}
 
-	netif_tx_lock_bh(tp->netdev);
+	netif_tx_lock(tp->netdev);
 
 	if (netif_queue_stopped(tp->netdev) &&
 	    skb_queue_len(&tp->tx_queue) < tp->tx_qlen)
 		netif_wake_queue(tp->netdev);
 
-	netif_tx_unlock_bh(tp->netdev);
+	netif_tx_unlock(tp->netdev);
 
-	ret = usb_autopm_get_interface(tp->intf);
+	ret = usb_autopm_get_interface_async(tp->intf);
 	if (ret < 0)
 		goto out_tx_fill;
 
@@ -1395,9 +1396,9 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 			  agg->head, (int)(tx_data - (u8 *)agg->head),
 			  (usb_complete_t)write_bulk_callback, agg);
 
-	ret = usb_submit_urb(agg->urb, GFP_KERNEL);
+	ret = usb_submit_urb(agg->urb, GFP_ATOMIC);
 	if (ret < 0)
-		usb_autopm_put_interface(tp->intf);
+		usb_autopm_put_interface_async(tp->intf);
 
 out_tx_fill:
 	return ret;
@@ -1535,6 +1536,7 @@ static void bottom_half(unsigned long data)
 		return;
 
 	rx_bottom(tp);
+	tx_bottom(tp);
 }
 
 static
@@ -1630,7 +1632,7 @@ static void _rtl8152_set_rx_mode(struct net_device *netdev)
 }
 
 static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
-					    struct net_device *netdev)
+					struct net_device *netdev)
 {
 	struct r8152 *tp = netdev_priv(netdev);
 
@@ -1638,13 +1640,17 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 
 	skb_queue_tail(&tp->tx_queue, skb);
 
-	if (list_empty(&tp->tx_free) &&
-	    skb_queue_len(&tp->tx_queue) > tp->tx_qlen)
+	if (!list_empty(&tp->tx_free)) {
+		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
+			set_bit(SCHEDULE_TASKLET, &tp->flags);
+			schedule_delayed_work(&tp->schedule, 0);
+		} else {
+			usb_mark_last_busy(tp->udev);
+			tasklet_schedule(&tp->tl);
+		}
+	} else if (skb_queue_len(&tp->tx_queue) > tp->tx_qlen)
 		netif_stop_queue(netdev);
 
-	if (!list_empty(&tp->tx_free))
-		schedule_delayed_work(&tp->schedule, 0);
-
 	return NETDEV_TX_OK;
 }
 
@@ -2523,8 +2529,11 @@ static void rtl_work_func_t(struct work_struct *work)
 	if (test_bit(RTL8152_SET_RX_MODE, &tp->flags))
 		_rtl8152_set_rx_mode(tp->netdev);
 
-	if (tp->speed & LINK_STATUS)
-		tx_bottom(tp);
+	if (test_bit(SCHEDULE_TASKLET, &tp->flags) &&
+	    (tp->speed & LINK_STATUS)) {
+		clear_bit(SCHEDULE_TASKLET, &tp->flags);
+		tasklet_schedule(&tp->tl);
+	}
 
 	if (test_bit(PHY_RESET, &tp->flags))
 		rtl_phy_reset(tp);
-- 
1.8.4.2
