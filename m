From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 3/8] xen-netback: support multiple extra info segments passed from frontend
Date: Wed, 21 Oct 2015 11:36:20 +0100
Message-ID: <1445423785-4654-4-git-send-email-paul.durrant@citrix.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:21978 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbbJUKhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 06:37:01 -0400
In-Reply-To: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code does not currently allow a frontend to pass multiple extra info
segments to the backend in a tx request. A subsequent patch in this series
needs this functionality so it is added here, without any other
modification, for better bisectability.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h  |  1 +
 drivers/net/xen-netback/netback.c | 27 +++++++++++++++++++--------
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 136ace1..ce40bd7 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -51,6 +51,7 @@ typedef unsigned int pending_ring_idx_t;
 
 struct pending_tx_info {
 	struct xen_netif_tx_request req; /* tx request */
+	unsigned int extra_count; /* Number of extras following the request */
 	/* Callback data for released SKBs. The callback is always
 	 * xenvif_zerocopy_callback, desc contains the pending_idx, which is
 	 * also an index in pending_tx_info array. It is initialized in
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 27c6779..9f0c9f5 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -95,7 +95,8 @@ static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
 
 static void make_tx_response(struct xenvif_queue *queue,
 			     struct xen_netif_tx_request *txp,
-			     s8       st);
+			     s8       st,
+			     unsigned int extra_count);
 static void push_tx_responses(struct xenvif_queue *queue);
 
 static inline int tx_work_todo(struct xenvif_queue *queue);
@@ -646,7 +647,7 @@ static void xenvif_tx_err(struct xenvif_queue *queue,
 
 	do {
 		spin_lock_irqsave(&queue->response_lock, flags);
-		make_tx_response(queue, txp, XEN_NETIF_RSP_ERROR);
+		make_tx_response(queue, txp, XEN_NETIF_RSP_ERROR, 0);
 		push_tx_responses(queue);
 		spin_unlock_irqrestore(&queue->response_lock, flags);
 		if (cons == end)
@@ -1292,7 +1293,8 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 			make_tx_response(queue, &txreq,
 					 (ret == 0) ?
 					 XEN_NETIF_RSP_OKAY :
-					 XEN_NETIF_RSP_ERROR);
+					 XEN_NETIF_RSP_ERROR,
+					 1);
 			push_tx_responses(queue);
 			continue;
 		}
@@ -1303,7 +1305,7 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 			extra = &extras[XEN_NETIF_EXTRA_TYPE_MCAST_DEL - 1];
 			xenvif_mcast_del(queue->vif, extra->u.mcast.addr);
 
-			make_tx_response(queue, &txreq, XEN_NETIF_RSP_OKAY);
+			make_tx_response(queue, &txreq, XEN_NETIF_RSP_OKAY, 1);
 			push_tx_responses(queue);
 			continue;
 		}
@@ -1411,6 +1413,9 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 			       sizeof(txreq));
 		}
 
+		if (extras[XEN_NETIF_EXTRA_TYPE_GSO - 1].type)
+			queue->pending_tx_info[pending_idx].extra_count++;
+
 		queue->pending_cons++;
 
 		gop = xenvif_get_requests(queue, skb, txfrags, gop,
@@ -1749,7 +1754,9 @@ static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
 
 	spin_lock_irqsave(&queue->response_lock, flags);
 
-	make_tx_response(queue, &pending_tx_info->req, status);
+	make_tx_response(queue, &pending_tx_info->req, status,
+			 pending_tx_info->extra_count);
+	memset(pending_tx_info, 0, sizeof(*pending_tx_info));
 
 	/* Release the pending index before pusing the Tx response so
 	 * its available before a new Tx request is pushed by the
@@ -1766,7 +1773,8 @@ static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
 
 static void make_tx_response(struct xenvif_queue *queue,
 			     struct xen_netif_tx_request *txp,
-			     s8       st)
+			     s8       st,
+			     unsigned int extra_count)
 {
 	RING_IDX i = queue->tx.rsp_prod_pvt;
 	struct xen_netif_tx_response *resp;
@@ -1775,8 +1783,11 @@ static void make_tx_response(struct xenvif_queue *queue,
 	resp->id     = txp->id;
 	resp->status = st;
 
-	if (txp->flags & XEN_NETTXF_extra_info)
-		RING_GET_RESPONSE(&queue->tx, ++i)->status = XEN_NETIF_RSP_NULL;
+	WARN_ON(!(txp->flags & XEN_NETTXF_extra_info) != !extra_count);
+
+	while (extra_count-- != 0)
+		RING_GET_RESPONSE(&queue->tx, ++i)->status =
+			XEN_NETIF_RSP_NULL;
 
 	queue->tx.rsp_prod_pvt = ++i;
 }
-- 
2.1.4
