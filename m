From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 net] xen-netback: release pending index before pushing Tx responses
Date: Tue, 24 Feb 2015 11:17:59 +0000
Message-ID: <1424776679-7509-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:26418 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752329AbbBXLSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 06:18:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the pending indexes are released /after/ pushing the Tx response
then a stale pending index may be used if a new Tx request is
immediately pushed by the frontend.  The may cause various WARNINGs or
BUGs if the stale pending index is actually still in use.

Fix this by releasing the pending index before pushing the Tx
response.

The full barrier for the pending ring update is not required since the
the Tx response push already has a suitable write barrier.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/netback.c |   29 +++++++++++++++++++++--------
 1 file changed, 21 insertions(+), 8 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index f7a31d2..c4d68d7 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -655,9 +655,15 @@ static void xenvif_tx_err(struct xenvif_queue *queue,
 	unsigned long flags;
 
 	do {
+		int notify;
+
 		spin_lock_irqsave(&queue->response_lock, flags);
 		make_tx_response(queue, txp, XEN_NETIF_RSP_ERROR);
+		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->tx, notify);
 		spin_unlock_irqrestore(&queue->response_lock, flags);
+		if (notify)
+			notify_remote_via_irq(queue->tx_irq);
+
 		if (cons == end)
 			break;
 		txp = RING_GET_REQUEST(&queue->tx, cons++);
@@ -1649,17 +1655,28 @@ static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
 {
 	struct pending_tx_info *pending_tx_info;
 	pending_ring_idx_t index;
+	int notify;
 	unsigned long flags;
 
 	pending_tx_info = &queue->pending_tx_info[pending_idx];
+
 	spin_lock_irqsave(&queue->response_lock, flags);
+
 	make_tx_response(queue, &pending_tx_info->req, status);
-	index = pending_index(queue->pending_prod);
+
+	/* Release the pending index before pusing the Tx response so
+	 * its available before a new Tx request is pushed by the
+	 * frontend.
+	 */
+	index = pending_index(queue->pending_prod++);
 	queue->pending_ring[index] = pending_idx;
-	/* TX shouldn't use the index before we give it back here */
-	mb();
-	queue->pending_prod++;
+
+	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->tx, notify);
+
 	spin_unlock_irqrestore(&queue->response_lock, flags);
+
+	if (notify)
+		notify_remote_via_irq(queue->tx_irq);
 }
 
 
@@ -1669,7 +1686,6 @@ static void make_tx_response(struct xenvif_queue *queue,
 {
 	RING_IDX i = queue->tx.rsp_prod_pvt;
 	struct xen_netif_tx_response *resp;
-	int notify;
 
 	resp = RING_GET_RESPONSE(&queue->tx, i);
 	resp->id     = txp->id;
@@ -1679,9 +1695,6 @@ static void make_tx_response(struct xenvif_queue *queue,
 		RING_GET_RESPONSE(&queue->tx, ++i)->status = XEN_NETIF_RSP_NULL;
 
 	queue->tx.rsp_prod_pvt = ++i;
-	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->tx, notify);
-	if (notify)
-		notify_remote_via_irq(queue->tx_irq);
 }
 
 static struct xen_netif_rx_response *make_rx_response(struct xenvif_queue *queue,
-- 
1.7.10.4
