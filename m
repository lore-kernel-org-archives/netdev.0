From: Julien Grall <julien.grall@citrix.com>
Subject: [RFC 20/23] net/xen-netfront: Make it running on 64KB page granularity
Date: Thu, 14 May 2015 18:01:00 +0100
Message-ID: <1431622863-28575-21-git-send-email-julien.grall@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	<tim@xen.org>, Julien Grall <julien.grall@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>, <netdev@vger.kernel.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:64027 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353AbbENRSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 13:18:22 -0400
In-Reply-To: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PV network protocol is using 4KB page granularity. The goal of this
patch is to allow a Linux using 64KB page granularity using network
device on a non-modified Xen.

It's only necessary to adapt the ring size and break skb data in small
chunk of 4KB. The rest of the code is relying on the grant table code.

Note that we allocate a Linux page for each rx skb but only the first
4KB is used. We may improve the memory usage by extending the size of
the rx skb.

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: netdev@vger.kernel.org

---

Improvement such as support of 64KB grant is not taken into
consideration in this patch because we have the requirement to run a Linux
using 64KB pages on a non-modified Xen.

Tested with workload such as ping, ssh, wget, git... I would happy if
someone give details how to test all the path.
---
 drivers/net/xen-netfront.c | 43 ++++++++++++++++++++++++++-----------------
 1 file changed, 26 insertions(+), 17 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 6a0e329..32a1cb2 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -74,8 +74,8 @@ struct netfront_cb {
 
 #define GRANT_INVALID_REF	0
 
-#define NET_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
-#define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
+#define NET_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, XEN_PAGE_SIZE)
+#define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, XEN_PAGE_SIZE)
 
 /* Minimum number of Rx slots (includes slot for GSO metadata). */
 #define NET_RX_SLOTS_MIN (XEN_NETIF_NR_SLOTS_MIN + 1)
@@ -267,7 +267,7 @@ static struct sk_buff *xennet_alloc_one_rx_buffer(struct netfront_queue *queue)
 		kfree_skb(skb);
 		return NULL;
 	}
-	skb_add_rx_frag(skb, 0, page, 0, 0, PAGE_SIZE);
+	skb_add_rx_frag(skb, 0, page, 0, 0, XEN_PAGE_SIZE);
 
 	/* Align ip header to a 16 bytes boundary */
 	skb_reserve(skb, NET_IP_ALIGN);
@@ -291,7 +291,7 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
 		struct sk_buff *skb;
 		unsigned short id;
 		grant_ref_t ref;
-		unsigned long pfn;
+		unsigned long mfn;
 		struct xen_netif_rx_request *req;
 
 		skb = xennet_alloc_one_rx_buffer(queue);
@@ -307,12 +307,12 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
 		BUG_ON((signed short)ref < 0);
 		queue->grant_rx_ref[id] = ref;
 
-		pfn = page_to_pfn(skb_frag_page(&skb_shinfo(skb)->frags[0]));
+		mfn = page_to_mfn(skb_frag_page(&skb_shinfo(skb)->frags[0]), 0);
 
 		req = RING_GET_REQUEST(&queue->rx, req_prod);
 		gnttab_grant_foreign_access_ref(ref,
 						queue->info->xbdev->otherend_id,
-						pfn_to_mfn(pfn),
+						mfn,
 						0);
 
 		req->id = id;
@@ -422,8 +422,10 @@ static struct xen_netif_tx_request *xennet_make_one_txreq(
 	unsigned int id;
 	struct xen_netif_tx_request *tx;
 	grant_ref_t ref;
+	unsigned int off_grant;
 
-	len = min_t(unsigned int, PAGE_SIZE - offset, len);
+	off_grant = offset & ~XEN_PAGE_MASK;
+	len = min_t(unsigned int, XEN_PAGE_SIZE - off_grant, len);
 
 	id = get_id_from_freelist(&queue->tx_skb_freelist, queue->tx_skbs);
 	tx = RING_GET_REQUEST(&queue->tx, queue->tx.req_prod_pvt++);
@@ -431,7 +433,8 @@ static struct xen_netif_tx_request *xennet_make_one_txreq(
 	BUG_ON((signed short)ref < 0);
 
 	gnttab_grant_foreign_access_ref(ref, queue->info->xbdev->otherend_id,
-					page_to_mfn(page, 0), GNTMAP_readonly);
+					page_to_mfn(page, offset),
+					GNTMAP_readonly);
 
 	queue->tx_skbs[id].skb = skb;
 	queue->grant_tx_page[id] = page;
@@ -439,7 +442,7 @@ static struct xen_netif_tx_request *xennet_make_one_txreq(
 
 	tx->id = id;
 	tx->gref = ref;
-	tx->offset = offset;
+	tx->offset = off_grant;
 	tx->size = len;
 	tx->flags = 0;
 
@@ -459,8 +462,11 @@ static struct xen_netif_tx_request *xennet_make_txreqs(
 		tx->flags |= XEN_NETTXF_more_data;
 		tx = xennet_make_one_txreq(queue, skb_get(skb),
 					   page, offset, len);
-		page++;
-		offset = 0;
+		offset += tx->size;
+		if (offset == PAGE_SIZE) {
+			page++;
+			offset = 0;
+		}
 		len -= tx->size;
 	}
 
@@ -567,8 +573,11 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* First request for the linear area. */
 	first_tx = tx = xennet_make_one_txreq(queue, skb,
 					      page, offset, len);
-	page++;
-	offset = 0;
+	offset += tx->size;
+	if ( offset == PAGE_SIZE ) {
+		page++;
+		offset = 0;
+	}
 	len -= tx->size;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
@@ -730,7 +739,7 @@ static int xennet_get_responses(struct netfront_queue *queue,
 
 	for (;;) {
 		if (unlikely(rx->status < 0 ||
-			     rx->offset + rx->status > PAGE_SIZE)) {
+			     rx->offset + rx->status > XEN_PAGE_SIZE)) {
 			if (net_ratelimit())
 				dev_warn(dev, "rx->offset: %x, size: %d\n",
 					 rx->offset, rx->status);
@@ -839,7 +848,7 @@ static RING_IDX xennet_fill_frags(struct netfront_queue *queue,
 		BUG_ON(shinfo->nr_frags >= MAX_SKB_FRAGS);
 
 		skb_add_rx_frag(skb, shinfo->nr_frags, skb_frag_page(nfrag),
-				rx->offset, rx->status, PAGE_SIZE);
+				rx->offset, rx->status, XEN_PAGE_SIZE);
 
 		skb_shinfo(nskb)->nr_frags = 0;
 		kfree_skb(nskb);
@@ -1497,7 +1506,7 @@ static int setup_netfront(struct xenbus_device *dev,
 		goto fail;
 	}
 	SHARED_RING_INIT(txs);
-	FRONT_RING_INIT(&queue->tx, txs, PAGE_SIZE);
+	FRONT_RING_INIT(&queue->tx, txs, XEN_PAGE_SIZE);
 
 	err = xenbus_grant_ring(dev, txs, 1, &gref);
 	if (err < 0)
@@ -1511,7 +1520,7 @@ static int setup_netfront(struct xenbus_device *dev,
 		goto alloc_rx_ring_fail;
 	}
 	SHARED_RING_INIT(rxs);
-	FRONT_RING_INIT(&queue->rx, rxs, PAGE_SIZE);
+	FRONT_RING_INIT(&queue->rx, rxs, XEN_PAGE_SIZE);
 
 	err = xenbus_grant_ring(dev, rxs, 1, &gref);
 	if (err < 0)
-- 
2.1.4
