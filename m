From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 net] xen-netback: notify immediately after pushing Tx response.
Date: Wed, 11 Mar 2015 15:27:59 +0000
Message-ID: <1426087679-13927-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16224 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602AbbCKP2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 11:28:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a performance regression introduced by
7fbb9d8415d4a51cf542e87cf3a717a9f7e6aedc (xen-netback: release pending
index before pushing Tx responses)

Moving the notify outside of the spin locks means it can be delayed a
long time (if the dealloc thread is descheduled or there is an
interrupt or softirq).

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/netback.c |   23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index c4d68d7..7f8a466 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -96,6 +96,7 @@ static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
 static void make_tx_response(struct xenvif_queue *queue,
 			     struct xen_netif_tx_request *txp,
 			     s8       st);
+static void push_tx_responses(struct xenvif_queue *queue);
 
 static inline int tx_work_todo(struct xenvif_queue *queue);
 
@@ -655,15 +656,10 @@ static void xenvif_tx_err(struct xenvif_queue *queue,
 	unsigned long flags;
 
 	do {
-		int notify;
-
 		spin_lock_irqsave(&queue->response_lock, flags);
 		make_tx_response(queue, txp, XEN_NETIF_RSP_ERROR);
-		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->tx, notify);
+		push_tx_responses(queue);
 		spin_unlock_irqrestore(&queue->response_lock, flags);
-		if (notify)
-			notify_remote_via_irq(queue->tx_irq);
-
 		if (cons == end)
 			break;
 		txp = RING_GET_REQUEST(&queue->tx, cons++);
@@ -1655,7 +1651,6 @@ static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
 {
 	struct pending_tx_info *pending_tx_info;
 	pending_ring_idx_t index;
-	int notify;
 	unsigned long flags;
 
 	pending_tx_info = &queue->pending_tx_info[pending_idx];
@@ -1671,12 +1666,9 @@ static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
 	index = pending_index(queue->pending_prod++);
 	queue->pending_ring[index] = pending_idx;
 
-	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->tx, notify);
+	push_tx_responses(queue);
 
 	spin_unlock_irqrestore(&queue->response_lock, flags);
-
-	if (notify)
-		notify_remote_via_irq(queue->tx_irq);
 }
 
 
@@ -1697,6 +1689,15 @@ static void make_tx_response(struct xenvif_queue *queue,
 	queue->tx.rsp_prod_pvt = ++i;
 }
 
+static void push_tx_responses(struct xenvif_queue *queue)
+{
+	int notify;
+
+	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->tx, notify);
+	if (notify)
+		notify_remote_via_irq(queue->tx_irq);
+}
+
 static struct xen_netif_rx_response *make_rx_response(struct xenvif_queue *queue,
 					     u16      id,
 					     s8       st,
-- 
1.7.10.4
