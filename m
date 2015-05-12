From: Joao Martins <joao.martins@neclab.eu>
Subject: [RFC PATCH 12/13] xen-netfront: implement TX persistent
	grants
Date: Tue, 12 May 2015 19:18:36 +0200
Message-ID: <1431451117-70051-13-git-send-email-joao.martins@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com,
	Joao Martins <joao.martins@neclab.eu>, david.vrabel@citrix.com,
	boris.ostrovsky@oracle.com
To: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

Instead of grant/revoking the buffer related to the skb, it will use
an already granted page and memcpy  to it. The grants will be mapped
by xen-netback and reused overtime, but only unmapped when the vif
disconnects, as opposed to every packet.

This only happens if the backend supports persistent grants since it
would, otherwise, introduce the overhead of a memcpy on top of the
grant map.

Signed-off-by: Joao Martins <joao.martins@neclab.eu>
---
 drivers/net/xen-netfront.c | 45 ++++++++++++++++++++++++++++++---------------
 1 file changed, 30 insertions(+), 15 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 7f44cc7..ae0a13b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -408,6 +408,7 @@ static void xennet_tx_buf_gc(struct netfront_queue *queue)
 	RING_IDX cons, prod;
 	unsigned short id;
 	struct sk_buff *skb;
+	unsigned use_persistent_gnts = queue->info->feature_persistent;
 
 	BUG_ON(!netif_carrier_ok(queue->info->netdev));
 
@@ -425,13 +426,16 @@ static void xennet_tx_buf_gc(struct netfront_queue *queue)
 			id  = txrsp->id;
 			skb = queue->tx_skbs[id].skb;
 
-			release_grant(queue->grant_tx[id].ref,
-				      &queue->gref_tx_head,
-				      queue->info->xbdev->otherend_id,
-				      GNTMAP_readonly);
+			if (!use_persistent_gnts) {
+				release_grant(queue->grant_tx[id].ref,
+					      &queue->gref_tx_head,
+					      queue->info->xbdev->otherend_id,
+					      GNTMAP_readonly);
+
+				queue->grant_tx[id].ref = GRANT_INVALID_REF;
+				queue->grant_tx[id].page = NULL;
+			}
 
-			queue->grant_tx[id].ref = GRANT_INVALID_REF;
-			queue->grant_tx[id].page = NULL;
 			add_id_to_freelist(&queue->tx_skb_freelist, queue->tx_skbs, id);
 			dev_kfree_skb_irq(skb);
 		}
@@ -460,23 +464,31 @@ static struct xen_netif_tx_request *xennet_make_one_txreq(
 {
 	unsigned int id;
 	struct xen_netif_tx_request *tx;
-	grant_ref_t ref;
+	struct grant *gnt;
 
 	len = min_t(unsigned int, PAGE_SIZE - offset, len);
 
 	id = get_id_from_freelist(&queue->tx_skb_freelist, queue->tx_skbs);
 	tx = RING_GET_REQUEST(&queue->tx, queue->tx.req_prod_pvt++);
-	ref = claim_grant(page,
-			  &queue->gref_tx_head,
-			  queue->info->xbdev->otherend_id,
-			  GNTMAP_readonly);
+	gnt = &queue->grant_tx[id];
+
+	if (queue->info->feature_persistent)
+		memcpy(pfn_to_kaddr(page_to_pfn(gnt->page)) + offset,
+		       pfn_to_kaddr(page_to_pfn(page)) + offset,
+		       len);
+	else
+		gnt->page = page;
+
+	if (gnt->ref == GRANT_INVALID_REF)
+		gnt->ref = claim_grant(gnt->page,
+				       &queue->gref_tx_head,
+				       queue->info->xbdev->otherend_id,
+				       GNTMAP_readonly);
 
 	queue->tx_skbs[id].skb = skb;
-	queue->grant_tx[id].page = page;
-	queue->grant_tx[id].ref = ref;
 
 	tx->id = id;
-	tx->gref = ref;
+	tx->gref = gnt->ref;
 	tx->offset = offset;
 	tx->size = len;
 	tx->flags = 0;
@@ -1610,7 +1622,10 @@ static int xennet_init_queue(struct netfront_queue *queue)
 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
 		skb_entry_set_link(&queue->tx_skbs[i], i+1);
 		queue->grant_tx[i].ref = GRANT_INVALID_REF;
-		queue->grant_tx[i].page = NULL;
+		if (queue->info->feature_persistent)
+			queue->grant_tx[i].page = alloc_page(GFP_NOIO);
+		else
+			queue->grant_tx[i].page = NULL;
 	}
 
 	/* Clear out rx_skbs */
-- 
2.1.3
