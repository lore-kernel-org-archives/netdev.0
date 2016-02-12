From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v1 7/8] xen-netback: pass toeplitz hash value to the frontend
Date: Fri, 12 Feb 2016 10:13:24 +0000
Message-ID: <1455272005-17144-8-git-send-email-paul.durrant@citrix.com>
References: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:63792 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751992AbcBLKVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 05:21:44 -0500
In-Reply-To: <1455272005-17144-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My recent patch to include/xen/interface/io/netif.h defines a new extra
info type that can be used to pass toeplitz hash values between backend
and VM frontend.

This patch adds code to xen-netback to pass hash values calculated for
receive-side packets to the VM frontend.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h  |  1 +
 drivers/net/xen-netback/netback.c | 76 ++++++++++++++++++++++++++++++++-------
 2 files changed, 65 insertions(+), 12 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 6687702..469dcf0 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -243,6 +243,7 @@ struct xenvif {
 	u8 ip_csum:1;
 	u8 ipv6_csum:1;
 	u8 multicast_control:1;
+	u8 hash_extra:1;
 
 	/* Is this interface disabled? True when backend discovers
 	 * frontend is rogue.
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 41ec7e9..57c91fe 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -163,6 +163,8 @@ static bool xenvif_rx_ring_slots_available(struct xenvif_queue *queue)
 	needed = DIV_ROUND_UP(skb->len, XEN_PAGE_SIZE);
 	if (skb_is_gso(skb))
 		needed++;
+	if (queue->vif->hash_extra)
+		needed++;
 
 	do {
 		prod = queue->rx.sring->req_prod;
@@ -280,6 +282,8 @@ struct gop_frag_copy {
 	struct xenvif_rx_meta *meta;
 	int head;
 	int gso_type;
+	int protocol;
+	int hash_type;
 
 	struct page *page;
 };
@@ -326,8 +330,19 @@ static void xenvif_setup_copy_gop(unsigned long gfn,
 	npo->copy_off += *len;
 	info->meta->size += *len;
 
+	if (!info->head)
+		return;
+
 	/* Leave a gap for the GSO descriptor. */
-	if (info->head && ((1 << info->gso_type) & queue->vif->gso_mask))
+	if ((1 << info->gso_type) & queue->vif->gso_mask)
+		queue->rx.req_cons++;
+
+	/* Leave a gap for the hash extra segment. */
+	if (queue->vif->hash_extra &&
+	    (info->hash_type == PKT_HASH_TYPE_L4 ||
+	     info->hash_type == PKT_HASH_TYPE_L3) &&
+	    (info->protocol == htons(ETH_P_IP) ||
+	     info->protocol == htons(ETH_P_IPV6)))
 		queue->rx.req_cons++;
 
 	info->head = 0; /* There must be something in this buffer now */
@@ -362,6 +377,8 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 		.npo = npo,
 		.head = *head,
 		.gso_type = XEN_NETIF_GSO_TYPE_NONE,
+		.protocol = skb->protocol,
+		.hash_type = skb_hash_type(skb),
 	};
 	unsigned long bytes;
 
@@ -550,6 +567,7 @@ void xenvif_kick_thread(struct xenvif_queue *queue)
 
 static void xenvif_rx_action(struct xenvif_queue *queue)
 {
+	struct xenvif *vif = queue->vif;
 	s8 status;
 	u16 flags;
 	struct xen_netif_rx_response *resp;
@@ -567,6 +585,8 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 
 	skb_queue_head_init(&rxq);
 
+	vif->hash_extra = !!vif->toeplitz.flags;
+
 	while (xenvif_rx_ring_slots_available(queue)
 	       && (skb = xenvif_rx_dequeue(queue)) != NULL) {
 		queue->last_rx_time = jiffies;
@@ -585,9 +605,10 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 	gnttab_batch_copy(queue->grant_copy_op, npo.copy_prod);
 
 	while ((skb = __skb_dequeue(&rxq)) != NULL) {
+		struct xen_netif_extra_info *extra = NULL;
 
 		if ((1 << queue->meta[npo.meta_cons].gso_type) &
-		    queue->vif->gso_prefix_mask) {
+		    vif->gso_prefix_mask) {
 			resp = RING_GET_RESPONSE(&queue->rx,
 						 queue->rx.rsp_prod_pvt++);
 
@@ -605,7 +626,7 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 		queue->stats.tx_bytes += skb->len;
 		queue->stats.tx_packets++;
 
-		status = xenvif_check_gop(queue->vif,
+		status = xenvif_check_gop(vif,
 					  XENVIF_RX_CB(skb)->meta_slots_used,
 					  &npo);
 
@@ -627,21 +648,52 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 					flags);
 
 		if ((1 << queue->meta[npo.meta_cons].gso_type) &
-		    queue->vif->gso_mask) {
-			struct xen_netif_extra_info *gso =
-				(struct xen_netif_extra_info *)
+		    vif->gso_mask) {
+			extra = (struct xen_netif_extra_info *)
 				RING_GET_RESPONSE(&queue->rx,
 						  queue->rx.rsp_prod_pvt++);
 
 			resp->flags |= XEN_NETRXF_extra_info;
 
-			gso->u.gso.type = queue->meta[npo.meta_cons].gso_type;
-			gso->u.gso.size = queue->meta[npo.meta_cons].gso_size;
-			gso->u.gso.pad = 0;
-			gso->u.gso.features = 0;
+			extra->u.gso.type = queue->meta[npo.meta_cons].gso_type;
+			extra->u.gso.size = queue->meta[npo.meta_cons].gso_size;
+			extra->u.gso.pad = 0;
+			extra->u.gso.features = 0;
+
+			extra->type = XEN_NETIF_EXTRA_TYPE_GSO;
+			extra->flags = 0;
+		}
+
+		if (vif->hash_extra &&
+		    (skb_hash_type(skb) == PKT_HASH_TYPE_L4 ||
+		     skb_hash_type(skb) == PKT_HASH_TYPE_L3) &&
+		    (skb->protocol == htons(ETH_P_IP) ||
+		     skb->protocol == htons(ETH_P_IPV6))) {
+			if (resp->flags & XEN_NETRXF_extra_info)
+				extra->flags |= XEN_NETIF_EXTRA_FLAG_MORE;
+			else
+				resp->flags |= XEN_NETRXF_extra_info;
+
+			extra = (struct xen_netif_extra_info *)
+				RING_GET_RESPONSE(&queue->rx,
+						  queue->rx.rsp_prod_pvt++);
 
-			gso->type = XEN_NETIF_EXTRA_TYPE_GSO;
-			gso->flags = 0;
+			if (skb_hash_type(skb) == PKT_HASH_TYPE_L4)
+				extra->u.toeplitz.type =
+					skb->protocol == htons(ETH_P_IP) ?
+					_XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4_TCP :
+					_XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6_TCP;
+			else if (skb_hash_type(skb) == PKT_HASH_TYPE_L3)
+				extra->u.toeplitz.type =
+					skb->protocol == htons(ETH_P_IP) ?
+					_XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV4 :
+					_XEN_NETIF_CTRL_TOEPLITZ_HASH_IPV6;
+
+			*(uint32_t *)extra->u.toeplitz.value =
+				skb_get_hash_raw(skb);
+
+			extra->type = XEN_NETIF_EXTRA_TYPE_TOEPLITZ;
+			extra->flags = 0;
 		}
 
 		xenvif_add_frag_responses(queue, status,
-- 
2.1.4
