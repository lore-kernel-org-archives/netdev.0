From: Joao Martins <joao.martins@neclab.eu>
Subject: [RFC PATCH 09/13] xen-netfront: move grant_{ref,
	page} to struct grant
Date: Tue, 12 May 2015 19:18:33 +0200
Message-ID: <1431451117-70051-10-git-send-email-joao.martins@neclab.eu>
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

Refactors a little bit how grants are stored by moving
grant_rx_ref/grant_tx_ref and grant_tx_page to its
own structure, namely struct grant.

Signed-off-by: Joao Martins <joao.martins@neclab.eu>
---
 drivers/net/xen-netfront.c | 56 ++++++++++++++++++++++++++--------------------
 1 file changed, 32 insertions(+), 24 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 3f45afd..8f49ed4 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -87,6 +87,11 @@ struct netfront_cb {
 /* IRQ name is queue name with "-tx" or "-rx" appended */
 #define IRQ_NAME_SIZE (QUEUE_NAME_SIZE + 3)
 
+struct grant {
+	grant_ref_t ref;
+	struct page *page;
+};
+
 struct netfront_stats {
 	u64			packets;
 	u64			bytes;
@@ -129,8 +134,7 @@ struct netfront_queue {
 		unsigned long link;
 	} tx_skbs[NET_TX_RING_SIZE];
 	grant_ref_t gref_tx_head;
-	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE];
-	struct page *grant_tx_page[NET_TX_RING_SIZE];
+	struct grant grant_tx[NET_TX_RING_SIZE];
 	unsigned tx_skb_freelist;
 
 	spinlock_t   rx_lock ____cacheline_aligned_in_smp;
@@ -141,7 +145,7 @@ struct netfront_queue {
 
 	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
 	grant_ref_t gref_rx_head;
-	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
+	struct grant grant_rx[NET_RX_RING_SIZE];
 };
 
 struct netfront_info {
@@ -213,8 +217,9 @@ static grant_ref_t xennet_get_rx_ref(struct netfront_queue *queue,
 					    RING_IDX ri)
 {
 	int i = xennet_rxidx(ri);
-	grant_ref_t ref = queue->grant_rx_ref[i];
-	queue->grant_rx_ref[i] = GRANT_INVALID_REF;
+	grant_ref_t ref = queue->grant_rx[i].ref;
+
+	queue->grant_rx[i].ref = GRANT_INVALID_REF;
 	return ref;
 }
 
@@ -306,7 +311,7 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
 
 		ref = gnttab_claim_grant_reference(&queue->gref_rx_head);
 		BUG_ON((signed short)ref < 0);
-		queue->grant_rx_ref[id] = ref;
+		queue->grant_rx[id].ref = ref;
 
 		pfn = page_to_pfn(skb_frag_page(&skb_shinfo(skb)->frags[0]));
 
@@ -383,17 +388,17 @@ static void xennet_tx_buf_gc(struct netfront_queue *queue)
 			id  = txrsp->id;
 			skb = queue->tx_skbs[id].skb;
 			if (unlikely(gnttab_query_foreign_access(
-				queue->grant_tx_ref[id]) != 0)) {
+				queue->grant_tx[id].ref) != 0)) {
 				pr_alert("%s: warning -- grant still in use by backend domain\n",
 					 __func__);
 				BUG();
 			}
 			gnttab_end_foreign_access_ref(
-				queue->grant_tx_ref[id], GNTMAP_readonly);
+				queue->grant_tx[id].ref, GNTMAP_readonly);
 			gnttab_release_grant_reference(
-				&queue->gref_tx_head, queue->grant_tx_ref[id]);
-			queue->grant_tx_ref[id] = GRANT_INVALID_REF;
-			queue->grant_tx_page[id] = NULL;
+				&queue->gref_tx_head, queue->grant_tx[id].ref);
+			queue->grant_tx[id].ref = GRANT_INVALID_REF;
+			queue->grant_tx[id].page = NULL;
 			add_id_to_freelist(&queue->tx_skb_freelist, queue->tx_skbs, id);
 			dev_kfree_skb_irq(skb);
 		}
@@ -435,8 +440,8 @@ static struct xen_netif_tx_request *xennet_make_one_txreq(
 					page_to_mfn(page), GNTMAP_readonly);
 
 	queue->tx_skbs[id].skb = skb;
-	queue->grant_tx_page[id] = page;
-	queue->grant_tx_ref[id] = ref;
+	queue->grant_tx[id].page = page;
+	queue->grant_tx[id].ref = ref;
 
 	tx->id = id;
 	tx->gref = ref;
@@ -659,7 +664,7 @@ static void xennet_move_rx_slot(struct netfront_queue *queue, struct sk_buff *sk
 
 	BUG_ON(queue->rx_skbs[new]);
 	queue->rx_skbs[new] = skb;
-	queue->grant_rx_ref[new] = ref;
+	queue->grant_rx[new].ref = ref;
 	RING_GET_REQUEST(&queue->rx, queue->rx.req_prod_pvt)->id = new;
 	RING_GET_REQUEST(&queue->rx, queue->rx.req_prod_pvt)->gref = ref;
 	queue->rx.req_prod_pvt++;
@@ -1055,6 +1060,7 @@ static struct rtnl_link_stats64 *xennet_get_stats64(struct net_device *dev,
 static void xennet_release_tx_bufs(struct netfront_queue *queue)
 {
 	struct sk_buff *skb;
+	struct page *page;
 	int i;
 
 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
@@ -1063,12 +1069,13 @@ static void xennet_release_tx_bufs(struct netfront_queue *queue)
 			continue;
 
 		skb = queue->tx_skbs[i].skb;
-		get_page(queue->grant_tx_page[i]);
-		gnttab_end_foreign_access(queue->grant_tx_ref[i],
+		page = queue->grant_tx[i].page;
+		get_page(page);
+		gnttab_end_foreign_access(queue->grant_tx[i].ref,
 					  GNTMAP_readonly,
-					  (unsigned long)page_address(queue->grant_tx_page[i]));
-		queue->grant_tx_page[i] = NULL;
-		queue->grant_tx_ref[i] = GRANT_INVALID_REF;
+					  (unsigned long)page_address(page));
+		queue->grant_tx[i].page = NULL;
+		queue->grant_tx[i].ref = GRANT_INVALID_REF;
 		add_id_to_freelist(&queue->tx_skb_freelist, queue->tx_skbs, i);
 		dev_kfree_skb_irq(skb);
 	}
@@ -1088,7 +1095,7 @@ static void xennet_release_rx_bufs(struct netfront_queue *queue)
 		if (!skb)
 			continue;
 
-		ref = queue->grant_rx_ref[id];
+		ref = queue->grant_rx[id].ref;
 		if (ref == GRANT_INVALID_REF)
 			continue;
 
@@ -1100,7 +1107,7 @@ static void xennet_release_rx_bufs(struct netfront_queue *queue)
 		get_page(page);
 		gnttab_end_foreign_access(ref, 0,
 					  (unsigned long)page_address(page));
-		queue->grant_rx_ref[id] = GRANT_INVALID_REF;
+		queue->grant_rx[id].ref = GRANT_INVALID_REF;
 
 		kfree_skb(skb);
 	}
@@ -1571,14 +1578,15 @@ static int xennet_init_queue(struct netfront_queue *queue)
 	queue->tx_skb_freelist = 0;
 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
 		skb_entry_set_link(&queue->tx_skbs[i], i+1);
-		queue->grant_tx_ref[i] = GRANT_INVALID_REF;
-		queue->grant_tx_page[i] = NULL;
+		queue->grant_tx[i].ref = GRANT_INVALID_REF;
+		queue->grant_tx[i].page = NULL;
 	}
 
 	/* Clear out rx_skbs */
 	for (i = 0; i < NET_RX_RING_SIZE; i++) {
 		queue->rx_skbs[i] = NULL;
-		queue->grant_rx_ref[i] = GRANT_INVALID_REF;
+		queue->grant_rx[i].ref = GRANT_INVALID_REF;
+		queue->grant_rx[i].page = NULL;
 	}
 
 	/* A grant for every tx ring slot */
-- 
2.1.3
