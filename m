From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 2/8] xen-netback: remove GSO information from xenvif_rx_meta
Date: Wed, 21 Oct 2015 11:36:19 +0100
Message-ID: <1445423785-4654-3-git-send-email-paul.durrant@citrix.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:4864 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752215AbbJUKhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 06:37:01 -0400
In-Reply-To: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in net_rx_action() that builds rx responses has direct access
to the skb so there is no need to copy this information into the meta
structure.

This patch removes the extraneous fields, saves space in the array and
removes many lines of code.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h  |  2 --
 drivers/net/xen-netback/netback.c | 75 +++++++++++++++------------------------
 2 files changed, 29 insertions(+), 48 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index a7bf747..136ace1 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -70,8 +70,6 @@ struct pending_tx_info {
 struct xenvif_rx_meta {
 	int id;
 	int size;
-	int gso_type;
-	int gso_size;
 };
 
 #define GSO_BIT(type) \
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index ec98d43..27c6779 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -263,8 +263,6 @@ static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif_queue *queue,
 	req = RING_GET_REQUEST(&queue->rx, queue->rx.req_cons++);
 
 	meta = npo->meta + npo->meta_prod++;
-	meta->gso_type = XEN_NETIF_GSO_TYPE_NONE;
-	meta->gso_size = 0;
 	meta->size = 0;
 	meta->id = req->id;
 
@@ -281,12 +279,13 @@ static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif_queue *queue,
 static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb,
 				 struct netrx_pending_operations *npo,
 				 struct page *page, unsigned long size,
-				 unsigned long offset, int *head)
+				 unsigned long offset, int *head,
+				 int gso_type)
 {
+	struct xenvif *vif = queue->vif;
 	struct gnttab_copy *copy_gop;
 	struct xenvif_rx_meta *meta;
 	unsigned long bytes;
-	int gso_type = XEN_NETIF_GSO_TYPE_NONE;
 
 	/* Data must not cross a page boundary. */
 	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
@@ -303,8 +302,14 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 		BUG_ON(offset >= PAGE_SIZE);
 		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
 
-		if (npo->copy_off == MAX_BUFFER_OFFSET)
+		if (npo->copy_off == MAX_BUFFER_OFFSET) {
+			/* Leave a gap for the GSO descriptor. */
+			if (*head && ((1 << gso_type) & vif->gso_mask))
+				queue->rx.req_cons++;
+
 			meta = get_next_rx_buffer(queue, npo);
+			*head = 0;
+		}
 
 		bytes = PAGE_SIZE - offset;
 		if (bytes > size)
@@ -345,20 +350,6 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 			page++;
 			offset = 0;
 		}
-
-		/* Leave a gap for the GSO descriptor. */
-		if (skb_is_gso(skb)) {
-			if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-				gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
-			else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-				gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
-		}
-
-		if (*head && ((1 << gso_type) & queue->vif->gso_mask))
-			queue->rx.req_cons++;
-
-		*head = 0; /* There must be something in this buffer now. */
-
 	}
 }
 
@@ -402,27 +393,11 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	if ((1 << gso_type) & vif->gso_prefix_mask) {
 		req = RING_GET_REQUEST(&queue->rx, queue->rx.req_cons++);
 		meta = npo->meta + npo->meta_prod++;
-		meta->gso_type = gso_type;
-		meta->gso_size = skb_shinfo(skb)->gso_size;
 		meta->size = 0;
 		meta->id = req->id;
 	}
 
-	req = RING_GET_REQUEST(&queue->rx, queue->rx.req_cons++);
-	meta = npo->meta + npo->meta_prod++;
-
-	if ((1 << gso_type) & vif->gso_mask) {
-		meta->gso_type = gso_type;
-		meta->gso_size = skb_shinfo(skb)->gso_size;
-	} else {
-		meta->gso_type = XEN_NETIF_GSO_TYPE_NONE;
-		meta->gso_size = 0;
-	}
-
-	meta->size = 0;
-	meta->id = req->id;
-	npo->copy_off = 0;
-	npo->copy_gref = req->gref;
+	get_next_rx_buffer(queue, npo);
 
 	data = skb->data;
 	while (data < skb_tail_pointer(skb)) {
@@ -433,7 +408,8 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 			len = skb_tail_pointer(skb) - data;
 
 		xenvif_gop_frag_copy(queue, skb, npo,
-				     virt_to_page(data), len, offset, &head);
+				     virt_to_page(data), len, offset, &head,
+				     gso_type);
 		data += len;
 	}
 
@@ -442,7 +418,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
 				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
 				     skb_shinfo(skb)->frags[i].page_offset,
-				     &head);
+				     &head, gso_type);
 	}
 
 	return npo->meta_prod - old_meta_prod;
@@ -542,15 +518,23 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 	gnttab_batch_copy(queue->grant_copy_op, npo.copy_prod);
 
 	while ((skb = __skb_dequeue(&rxq)) != NULL) {
+		struct xenvif *vif = queue->vif;
+		int gso_type = XEN_NETIF_GSO_TYPE_NONE;
+
+		if (skb_is_gso(skb)) {
+			if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+				gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
+			else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+				gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
+		}
 
-		if ((1 << queue->meta[npo.meta_cons].gso_type) &
-		    queue->vif->gso_prefix_mask) {
+		if ((1 << gso_type) & vif->gso_prefix_mask) {
 			resp = RING_GET_RESPONSE(&queue->rx,
 						 queue->rx.rsp_prod_pvt++);
 
 			resp->flags = XEN_NETRXF_gso_prefix | XEN_NETRXF_more_data;
 
-			resp->offset = queue->meta[npo.meta_cons].gso_size;
+			resp->offset = skb_shinfo(skb)->gso_size;
 			resp->id = queue->meta[npo.meta_cons].id;
 			resp->status = XENVIF_RX_CB(skb)->meta_slots_used;
 
@@ -562,7 +546,7 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 		queue->stats.tx_bytes += skb->len;
 		queue->stats.tx_packets++;
 
-		status = xenvif_check_gop(queue->vif,
+		status = xenvif_check_gop(vif,
 					  XENVIF_RX_CB(skb)->meta_slots_used,
 					  &npo);
 
@@ -583,8 +567,7 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 					queue->meta[npo.meta_cons].size,
 					flags);
 
-		if ((1 << queue->meta[npo.meta_cons].gso_type) &
-		    queue->vif->gso_mask) {
+		if ((1 << gso_type) & vif->gso_mask) {
 			struct xen_netif_extra_info *gso =
 				(struct xen_netif_extra_info *)
 				RING_GET_RESPONSE(&queue->rx,
@@ -592,8 +575,8 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 
 			resp->flags |= XEN_NETRXF_extra_info;
 
-			gso->u.gso.type = queue->meta[npo.meta_cons].gso_type;
-			gso->u.gso.size = queue->meta[npo.meta_cons].gso_size;
+			gso->u.gso.type = gso_type;
+			gso->u.gso.size = skb_shinfo(skb)->gso_size;
 			gso->u.gso.pad = 0;
 			gso->u.gso.features = 0;
 
-- 
2.1.4
