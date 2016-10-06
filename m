From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net] xen-netback: make sure that hashes are not send to unaware frontends
Date: Thu, 6 Oct 2016 15:47:10 +0100
Message-ID: <1475765230-11936-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:59846 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750895AbcJFPHb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Oct 2016 11:07:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case when a frontend only negotiates a single queue with xen-
netback it is possible for a skbuff with a s/w hash to result in a
hash extra_info segment being sent to the frontend even when no hash
algorithm has been configured. (The ndo_select_queue() entry point makes
sure the hash is not set if no algorithm is configured, but this entry
point is not called when there is only a single queue). This can result
in a frontend that isunable to handle extra_info segments being given
such a segment, causing it to crash.

This patch fixes the problem by gating whether the extra_info is sent
not only on the presence of a s/w hash, but also on whether the hash
algorithm has been configured.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/interface.c | 13 ++-----------
 drivers/net/xen-netback/netback.c   | 23 ++++++++++++++---------
 2 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index fb50c6d..1034139 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -149,17 +149,8 @@ static u16 xenvif_select_queue(struct net_device *dev, struct sk_buff *skb,
 	struct xenvif *vif = netdev_priv(dev);
 	unsigned int size = vif->hash.size;
 
-	if (vif->hash.alg == XEN_NETIF_CTRL_HASH_ALGORITHM_NONE) {
-		u16 index = fallback(dev, skb) % dev->real_num_tx_queues;
-
-		/* Make sure there is no hash information in the socket
-		 * buffer otherwise it would be incorrectly forwarded
-		 * to the frontend.
-		 */
-		skb_clear_hash(skb);
-
-		return index;
-	}
+	if (vif->hash.alg == XEN_NETIF_CTRL_HASH_ALGORITHM_NONE)
+		return fallback(dev, skb) % dev->real_num_tx_queues;
 
 	xenvif_set_skb_hash(vif, skb);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 3d0c989..2cd4a8e 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -168,6 +168,10 @@ static bool xenvif_rx_ring_slots_available(struct xenvif_queue *queue)
 	needed = DIV_ROUND_UP(skb->len, XEN_PAGE_SIZE);
 	if (skb_is_gso(skb))
 		needed++;
+	/* Assume the frontend is capable of handling the hash
+	 * extra_info at this point. This will only ever lead to an
+	 * accurate value or over-estimation.
+	 */
 	if (skb->sw_hash)
 		needed++;
 
@@ -378,9 +382,8 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 		.npo = npo,
 		.head = *head,
 		.gso_type = XEN_NETIF_GSO_TYPE_NONE,
-		/* xenvif_set_skb_hash() will have either set a s/w
-		 * hash or cleared the hash depending on
-		 * whether the the frontend wants a hash for this skb.
+		/* xenvif_rx_action() will have cleared any hash if
+		 * the frontend is not capable of handling it.
 		 */
 		.hash_present = skb->sw_hash,
 	};
@@ -593,6 +596,14 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 	       && (skb = xenvif_rx_dequeue(queue)) != NULL) {
 		queue->last_rx_time = jiffies;
 
+		/* If there is no hash algorithm configured make sure
+		 * there is no hash information in the socket buffer
+		 * otherwise it would be incorrectly forwarded to the
+		 * frontend.
+		 */
+		if (vif->hash.alg == XEN_NETIF_CTRL_HASH_ALGORITHM_NONE)
+			skb_clear_hash(skb);
+
 		XENVIF_RX_CB(skb)->meta_slots_used = xenvif_gop_skb(skb, &npo, queue);
 
 		__skb_queue_tail(&rxq, skb);
@@ -667,12 +678,6 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 		}
 
 		if (skb->sw_hash) {
-			/* Since the skb got here via xenvif_select_queue()
-			 * we know that the hash has been re-calculated
-			 * according to a configuration set by the frontend
-			 * and therefore we know that it is legitimate to
-			 * pass it to the frontend.
-			 */
 			if (resp->flags & XEN_NETRXF_extra_info)
 				extra->flags |= XEN_NETIF_EXTRA_FLAG_MORE;
 			else
-- 
2.1.4
