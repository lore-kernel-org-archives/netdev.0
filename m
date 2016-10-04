From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH v2 net-next 7/7] xen/netback: add fraglist support for to-guest rx
Date: Tue, 4 Oct 2016 10:29:18 +0100
Message-ID: <1475573358-32414-8-git-send-email-paul.durrant@citrix.com>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ross Lagerwall <ross.lagerwall@citrix.com>,
        Paul Durrant <paul.durrant@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53048 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752918AbcJDJtG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 05:49:06 -0400
In-Reply-To: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ross Lagerwall <ross.lagerwall@citrix.com>

This allows full 64K skbuffs (with 1500 mtu ethernet, composed of 45
fragments) to be handled by netback for to-guest rx.

Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
[re-based]
Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
---
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/interface.c |  2 +-
 drivers/net/xen-netback/rx.c        | 38 ++++++++++++++++++++++++++++---------
 2 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 211d542..4af532a 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -467,7 +467,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	dev->netdev_ops	= &xenvif_netdev_ops;
 	dev->hw_features = NETIF_F_SG |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-		NETIF_F_TSO | NETIF_F_TSO6;
+		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_FRAGLIST;
 	dev->features = dev->hw_features | NETIF_F_RXCSUM;
 	dev->ethtool_ops = &xenvif_ethtool_ops;
 
diff --git a/drivers/net/xen-netback/rx.c b/drivers/net/xen-netback/rx.c
index 8c8c5b5..8e9ade6 100644
--- a/drivers/net/xen-netback/rx.c
+++ b/drivers/net/xen-netback/rx.c
@@ -215,7 +215,8 @@ static unsigned int xenvif_gso_type(struct sk_buff *skb)
 struct xenvif_pkt_state {
 	struct sk_buff *skb;
 	size_t remaining_len;
-	int frag; /* frag == -1 => skb->head */
+	struct sk_buff *frag_iter;
+	int frag; /* frag == -1 => frag_iter->head */
 	unsigned int frag_offset;
 	struct xen_netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX - 1];
 	unsigned int extra_count;
@@ -237,6 +238,7 @@ static void xenvif_rx_next_skb(struct xenvif_queue *queue,
 	memset(pkt, 0, sizeof(struct xenvif_pkt_state));
 
 	pkt->skb = skb;
+	pkt->frag_iter = skb;
 	pkt->remaining_len = skb->len;
 	pkt->frag = -1;
 
@@ -293,20 +295,40 @@ static void xenvif_rx_complete(struct xenvif_queue *queue,
 	__skb_queue_tail(queue->rx_copy.completed, pkt->skb);
 }
 
+static void xenvif_rx_next_frag(struct xenvif_pkt_state *pkt)
+{
+	struct sk_buff *frag_iter = pkt->frag_iter;
+	unsigned int nr_frags = skb_shinfo(frag_iter)->nr_frags;
+
+	pkt->frag++;
+	pkt->frag_offset = 0;
+
+	if (pkt->frag >= nr_frags) {
+		if (frag_iter == pkt->skb)
+			pkt->frag_iter = skb_shinfo(frag_iter)->frag_list;
+		else
+			pkt->frag_iter = frag_iter->next;
+
+		pkt->frag = -1;
+	}
+}
+
 static void xenvif_rx_next_chunk(struct xenvif_queue *queue,
 				 struct xenvif_pkt_state *pkt,
 				 unsigned int offset, void **data,
 				 size_t *len)
 {
-	struct sk_buff *skb = pkt->skb;
+	struct sk_buff *frag_iter = pkt->frag_iter;
 	void *frag_data;
 	size_t frag_len, chunk_len;
 
+	BUG_ON(!frag_iter);
+
 	if (pkt->frag == -1) {
-		frag_data = skb->data;
-		frag_len = skb_headlen(skb);
+		frag_data = frag_iter->data;
+		frag_len = skb_headlen(frag_iter);
 	} else {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[pkt->frag];
+		skb_frag_t *frag = &skb_shinfo(frag_iter)->frags[pkt->frag];
 
 		frag_data = skb_frag_address(frag);
 		frag_len = skb_frag_size(frag);
@@ -322,10 +344,8 @@ static void xenvif_rx_next_chunk(struct xenvif_queue *queue,
 	pkt->frag_offset += chunk_len;
 
 	/* Advance to next frag? */
-	if (frag_len == chunk_len) {
-		pkt->frag++;
-		pkt->frag_offset = 0;
-	}
+	if (frag_len == chunk_len)
+		xenvif_rx_next_frag(pkt);
 
 	*data = frag_data;
 	*len = chunk_len;
-- 
2.1.4
