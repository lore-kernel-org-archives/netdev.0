From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 4/7] xen-netback: immediately wake tx queue when guest rx queue has space
Date: Mon, 3 Oct 2016 08:31:09 +0100
Message-ID: <1475479872-23717-5-git-send-email-paul.durrant@citrix.com>
References: <1475479872-23717-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
        Paul Durrant <paul.durrant@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:41213 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750839AbcJCHuy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 03:50:54 -0400
In-Reply-To: <1475479872-23717-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>

When an skb is removed from the guest rx queue, immediately wake the
tx queue, instead of after processing them.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
[re-based]
Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
---
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/rx.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/xen-netback/rx.c b/drivers/net/xen-netback/rx.c
index b0ce4c6..9548709 100644
--- a/drivers/net/xen-netback/rx.c
+++ b/drivers/net/xen-netback/rx.c
@@ -92,27 +92,21 @@ static struct sk_buff *xenvif_rx_dequeue(struct xenvif_queue *queue)
 	spin_lock_irq(&queue->rx_queue.lock);
 
 	skb = __skb_dequeue(&queue->rx_queue);
-	if (skb)
+	if (skb) {
 		queue->rx_queue_len -= skb->len;
+		if (queue->rx_queue_len < queue->rx_queue_max) {
+			struct netdev_queue *txq;
+
+			txq = netdev_get_tx_queue(queue->vif->dev, queue->id);
+			netif_tx_wake_queue(txq);
+		}
+	}
 
 	spin_unlock_irq(&queue->rx_queue.lock);
 
 	return skb;
 }
 
-static void xenvif_rx_queue_maybe_wake(struct xenvif_queue *queue)
-{
-	spin_lock_irq(&queue->rx_queue.lock);
-
-	if (queue->rx_queue_len < queue->rx_queue_max) {
-		struct net_device *dev = queue->vif->dev;
-
-		netif_tx_wake_queue(netdev_get_tx_queue(dev, queue->id));
-	}
-
-	spin_unlock_irq(&queue->rx_queue.lock);
-}
-
 static void xenvif_rx_queue_purge(struct xenvif_queue *queue)
 {
 	struct sk_buff *skb;
@@ -585,8 +579,6 @@ int xenvif_kthread_guest_rx(void *data)
 		 */
 		xenvif_rx_queue_drop_expired(queue);
 
-		xenvif_rx_queue_maybe_wake(queue);
-
 		cond_resched();
 	}
 
-- 
2.1.4
