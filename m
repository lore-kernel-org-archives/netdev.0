From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 net] xen-netback: use skb to determine number of required guest Rx requests
Date: Thu, 14 Jan 2016 15:18:30 +0000
Message-ID: <1452784710-11923-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:65027 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753712AbcANPSh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2016 10:18:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the MTU or GSO size to determine the number of required guest Rx
requests for an skb was subtly broken since these value may change at
runtime.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/netback.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 1049c34..61b97c3 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -149,20 +149,19 @@ static inline pending_ring_idx_t pending_index(unsigned i)
 	return i & (MAX_PENDING_REQS-1);
 }
 
-static int xenvif_rx_ring_slots_needed(struct xenvif *vif)
-{
-	if (vif->gso_mask)
-		return DIV_ROUND_UP(vif->dev->gso_max_size, XEN_PAGE_SIZE) + 1;
-	else
-		return DIV_ROUND_UP(vif->dev->mtu, XEN_PAGE_SIZE);
-}
-
 static bool xenvif_rx_ring_slots_available(struct xenvif_queue *queue)
 {
 	RING_IDX prod, cons;
+	struct sk_buff *skb;
 	int needed;
 
-	needed = xenvif_rx_ring_slots_needed(queue->vif);
+	skb = skb_peek(&queue->rx_queue);
+	if (!skb)
+		return false;
+
+	needed = DIV_ROUND_UP(skb->len, XEN_PAGE_SIZE);
+	if (skb_is_gso(skb))
+		needed++;
 
 	do {
 		prod = queue->rx.sring->req_prod;
@@ -2005,8 +2004,7 @@ static bool xenvif_rx_queue_ready(struct xenvif_queue *queue)
 
 static bool xenvif_have_rx_work(struct xenvif_queue *queue)
 {
-	return (!skb_queue_empty(&queue->rx_queue)
-		&& xenvif_rx_ring_slots_available(queue))
+	return xenvif_rx_ring_slots_available(queue)
 		|| (queue->vif->stall_timeout &&
 		    (xenvif_rx_queue_stalled(queue)
 		     || xenvif_rx_queue_ready(queue)))
-- 
2.1.4
