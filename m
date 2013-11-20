From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v5 2/4] r8152: modify the tx flow
Date: Wed, 20 Nov 2013 17:30:55 +0800
Message-ID: <1384939857-13519-3-git-send-email-hayeswang@realtek.com>
References: <1384502279-9959-1-git-send-email-hayeswang@realtek.com>
 <1384939857-13519-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:50253 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab3KTJbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 04:31:11 -0500
In-Reply-To: <1384939857-13519-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the code for sending the packet in the rtl8152_start_xmit().
Let rtl8152_start_xmit() to queue the packet only, and schedule a
tasklet to send the queued packets. This simplify the code and make
sure all the packet would be sent by the original order.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 46 +++-------------------------------------------
 1 file changed, 3 insertions(+), 43 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 428600d..8a786b6 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1388,53 +1388,13 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
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
-
-	tx_desc = (struct tx_desc *)agg->head;
-	tx_data = agg->head + sizeof(*tx_desc);
-	agg->skb_num = agg->skb_len = 0;
+	skb_queue_tail(&tp->tx_queue, skb);
 
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
