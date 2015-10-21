From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 6/8] xen-netback: pass an L4 or L3 skb hash value to the frontend
Date: Wed, 21 Oct 2015 11:36:23 +0100
Message-ID: <1445423785-4654-7-git-send-email-paul.durrant@citrix.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:45975 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174AbbJUKhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 06:37:06 -0400
In-Reply-To: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the frontend indicates it's capable (see netif.h for details) and an
skb has an L4 or L3 hash value then pass the value to the frontend in
a xen_netif_extra_info segment.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h  |  1 +
 drivers/net/xen-netback/netback.c | 85 +++++++++++++++++++++++++++++++--------
 drivers/net/xen-netback/xenbus.c  |  5 +++
 3 files changed, 75 insertions(+), 16 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index ce40bd7..1bce5a5 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -229,6 +229,7 @@ struct xenvif {
 	u8 ip_csum:1;
 	u8 ipv6_csum:1;
 	u8 multicast_control:1;
+	u8 hash_extra:1;
 
 	/* Is this interface disabled? True when backend discovers
 	 * frontend is rogue.
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 3799b5a..68994f9 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -152,10 +152,17 @@ static inline pending_ring_idx_t pending_index(unsigned i)
 
 static int xenvif_rx_ring_slots_needed(struct xenvif *vif)
 {
-	if (vif->gso_mask)
-		return DIV_ROUND_UP(vif->dev->gso_max_size, PAGE_SIZE) + 1;
+	int needed;
+
+	if (vif->gso_mask || vif->gso_prefix_mask)
+		needed = DIV_ROUND_UP(vif->dev->gso_max_size, PAGE_SIZE) + 1;
 	else
-		return DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
+		needed = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
+
+	if (vif->hash_extra)
+		needed++;
+
+	return needed;
 }
 
 static bool xenvif_rx_ring_slots_available(struct xenvif_queue *queue)
@@ -304,12 +311,23 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
 
 		if (npo->copy_off == MAX_BUFFER_OFFSET) {
-			/* Leave a gap for the GSO descriptor. */
-			if (*head && ((1 << gso_type) & vif->gso_mask))
-				queue->rx.req_cons++;
+			if (*head) {
+				*head = 0;
+
+				/* Leave a gap for the GSO descriptor. */
+				if ((1 << gso_type) & vif->gso_mask)
+					queue->rx.req_cons++;
+
+				/* Leave a gap for the hash extra
+				 * segment.
+				 */
+				if (vif->hash_extra &&
+				    (skb->protocol == htons(ETH_P_IP) ||
+				     skb->protocol == htons(ETH_P_IPV6)))
+					queue->rx.req_cons++;
+			}
 
 			meta = get_next_rx_buffer(queue, npo);
-			*head = 0;
 		}
 
 		bytes = PAGE_SIZE - offset;
@@ -521,6 +539,7 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 	while ((skb = __skb_dequeue(&rxq)) != NULL) {
 		struct xenvif *vif = queue->vif;
 		int gso_type = XEN_NETIF_GSO_TYPE_NONE;
+		struct xen_netif_extra_info *extra = NULL;
 
 		if (skb_is_gso(skb)) {
 			if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
@@ -569,20 +588,54 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 					flags);
 
 		if ((1 << gso_type) & vif->gso_mask) {
-			struct xen_netif_extra_info *gso =
-				(struct xen_netif_extra_info *)
+			resp->flags |= XEN_NETRXF_extra_info;
+
+			extra = (struct xen_netif_extra_info *)
 				RING_GET_RESPONSE(&queue->rx,
 						  queue->rx.rsp_prod_pvt++);
 
-			resp->flags |= XEN_NETRXF_extra_info;
+			extra->u.gso.type = gso_type;
+			extra->u.gso.size = skb_shinfo(skb)->gso_size;
+			extra->u.gso.pad = 0;
+			extra->u.gso.features = 0;
+
+			extra->type = XEN_NETIF_EXTRA_TYPE_GSO;
+			extra->flags = 0;
+		}
+
+		if (vif->hash_extra &&
+		    (skb->protocol == htons(ETH_P_IP) ||
+		     skb->protocol == htons(ETH_P_IPV6))) {
+			if (resp->flags & XEN_NETRXF_extra_info)
+				extra->flags |= XEN_NETIF_EXTRA_FLAG_MORE;
+			else
+				resp->flags |= XEN_NETRXF_extra_info;
 
-			gso->u.gso.type = gso_type;
-			gso->u.gso.size = skb_shinfo(skb)->gso_size;
-			gso->u.gso.pad = 0;
-			gso->u.gso.features = 0;
+			extra = (struct xen_netif_extra_info *)
+				RING_GET_RESPONSE(&queue->rx,
+						  queue->rx.rsp_prod_pvt++);
+
+			if (skb_hash_type(skb) == PKT_HASH_TYPE_L4) {
+				extra->u.hash.type =
+					skb->protocol == htons(ETH_P_IP) ?
+					XEN_NETIF_HASH_TYPE_TCPV4 :
+					XEN_NETIF_HASH_TYPE_TCPV6;
+				*(uint32_t *)extra->u.hash.value =
+					skb_get_hash_raw(skb);
+			} else if (skb_hash_type(skb) == PKT_HASH_TYPE_L3) {
+				extra->u.hash.type =
+					skb->protocol == htons(ETH_P_IP) ?
+					XEN_NETIF_HASH_TYPE_IPV4 :
+					XEN_NETIF_HASH_TYPE_IPV6;
+				*(uint32_t *)extra->u.hash.value =
+					skb_get_hash_raw(skb);
+			} else {
+				extra->u.hash.type = XEN_NETIF_HASH_TYPE_NONE;
+				*(uint32_t *)extra->u.hash.value = 0;
+			}
 
-			gso->type = XEN_NETIF_EXTRA_TYPE_GSO;
-			gso->flags = 0;
+			extra->type = XEN_NETIF_EXTRA_TYPE_HASH;
+			extra->flags = 0;
 		}
 
 		xenvif_add_frag_responses(queue, status,
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 2fa8a16..a31bcee 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -1037,6 +1037,11 @@ static int read_xenbus_vif_flags(struct backend_info *be)
 		val = 0;
 	vif->multicast_control = !!val;
 
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-hash",
+			 "%d", &val) < 0)
+		val = 0;
+	vif->hash_extra = !!val;
+
 	return 0;
 }
 
-- 
2.1.4
