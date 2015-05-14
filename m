From: Julien Grall <julien.grall@citrix.com>
Subject: [RFC 21/23] net/xen-netback: Make it running on 64KB
	page granularity
Date: Thu, 14 May 2015 18:01:01 +0100
Message-ID: <1431622863-28575-22-git-send-email-julien.grall@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, ian.campbell@citrix.com,
	stefano.stabellini@eu.citrix.com, netdev@vger.kernel.org,
	tim@xen.org, linux-kernel@vger.kernel.org,
	Julien Grall <julien.grall@citrix.com>,
	linux-arm-kernel@lists.infradead.org
To: <xen-devel@lists.xenproject.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

The PV network protocol is using 4KB page granularity. The goal of this
patch is to allow a Linux using 64KB page granularity working as a
network backend on a non-modified Xen.

It's only necessary to adapt the ring size and break skb data in small
chunk of 4KB. The rest of the code is relying on the grant table code.

Although only simple workload is working (dhcp request, ping). If I try
to use wget in the guest, it will stall until a tcpdump is started on
the vif interface in DOM0. I wasn't able to find why.

I have not modified XEN_NETBK_RX_SLOTS_MAX because I wasn't sure what
it's used for (I have limited knowledge on the network driver).

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: netdev@vger.kernel.org

---

Improvement such as support of 64KB grant is not taken into
consideration in this patch because we have the requirement to run a
Linux using 64KB pages on a non-modified Xen.
---
 drivers/net/xen-netback/common.h  |  7 ++++---
 drivers/net/xen-netback/netback.c | 27 ++++++++++++++-------------
 2 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 8a495b3..0eda6e9 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -44,6 +44,7 @@
 #include <xen/interface/grant_table.h>
 #include <xen/grant_table.h>
 #include <xen/xenbus.h>
+#include <xen/page.h>
 #include <linux/debugfs.h>
 
 typedef unsigned int pending_ring_idx_t;
@@ -64,8 +65,8 @@ struct pending_tx_info {
 	struct ubuf_info callback_struct;
 };
 
-#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
-#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
+#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, XEN_PAGE_SIZE)
+#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, XEN_PAGE_SIZE)
 
 struct xenvif_rx_meta {
 	int id;
@@ -80,7 +81,7 @@ struct xenvif_rx_meta {
 /* Discriminate from any valid pending_idx value. */
 #define INVALID_PENDING_IDX 0xFFFF
 
-#define MAX_BUFFER_OFFSET PAGE_SIZE
+#define MAX_BUFFER_OFFSET XEN_PAGE_SIZE
 
 #define MAX_PENDING_REQS XEN_NETIF_TX_RING_SIZE
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 9ae1d43..ea5ce84 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -274,7 +274,7 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 {
 	struct gnttab_copy *copy_gop;
 	struct xenvif_rx_meta *meta;
-	unsigned long bytes;
+	unsigned long bytes, off_grant;
 	int gso_type = XEN_NETIF_GSO_TYPE_NONE;
 
 	/* Data must not cross a page boundary. */
@@ -295,7 +295,8 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 		if (npo->copy_off == MAX_BUFFER_OFFSET)
 			meta = get_next_rx_buffer(queue, npo);
 
-		bytes = PAGE_SIZE - offset;
+		off_grant = offset & ~XEN_PAGE_MASK;
+		bytes = XEN_PAGE_SIZE - off_grant;
 		if (bytes > size)
 			bytes = size;
 
@@ -314,9 +315,9 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 		} else {
 			copy_gop->source.domid = DOMID_SELF;
 			copy_gop->source.u.gmfn =
-				virt_to_mfn(page_address(page));
+				virt_to_mfn(page_address(page) + offset);
 		}
-		copy_gop->source.offset = offset;
+		copy_gop->source.offset = off_grant;
 
 		copy_gop->dest.domid = queue->vif->domid;
 		copy_gop->dest.offset = npo->copy_off;
@@ -747,7 +748,7 @@ static int xenvif_count_requests(struct xenvif_queue *queue,
 		first->size -= txp->size;
 		slots++;
 
-		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
+		if (unlikely((txp->offset + txp->size) > XEN_PAGE_SIZE)) {
 			netdev_err(queue->vif->dev, "Cross page boundary, txp->offset: %x, size: %u\n",
 				 txp->offset, txp->size);
 			xenvif_fatal_tx_err(queue->vif);
@@ -1241,11 +1242,11 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 		}
 
 		/* No crossing a page as the payload mustn't fragment. */
-		if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) {
+		if (unlikely((txreq.offset + txreq.size) > XEN_PAGE_SIZE)) {
 			netdev_err(queue->vif->dev,
 				   "txreq.offset: %x, size: %u, end: %lu\n",
 				   txreq.offset, txreq.size,
-				   (txreq.offset&~PAGE_MASK) + txreq.size);
+				   (txreq.offset&~XEN_PAGE_MASK) + txreq.size);
 			xenvif_fatal_tx_err(queue->vif);
 			break;
 		}
@@ -1287,7 +1288,7 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 			virt_to_mfn(skb->data);
 		queue->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
 		queue->tx_copy_ops[*copy_ops].dest.offset =
-			offset_in_page(skb->data);
+			offset_in_page(skb->data) & ~XEN_PAGE_MASK;
 
 		queue->tx_copy_ops[*copy_ops].len = data_len;
 		queue->tx_copy_ops[*copy_ops].flags = GNTCOPY_source_gref;
@@ -1366,8 +1367,8 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
 			return -ENOMEM;
 		}
 
-		if (offset + PAGE_SIZE < skb->len)
-			len = PAGE_SIZE;
+		if (offset + XEN_PAGE_SIZE < skb->len)
+			len = XEN_PAGE_SIZE;
 		else
 			len = skb->len - offset;
 		if (skb_copy_bits(skb, offset, page_address(page), len))
@@ -1396,7 +1397,7 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
 	/* Fill the skb with the new (local) frags. */
 	memcpy(skb_shinfo(skb)->frags, frags, i * sizeof(skb_frag_t));
 	skb_shinfo(skb)->nr_frags = i;
-	skb->truesize += i * PAGE_SIZE;
+	skb->truesize += i * XEN_PAGE_SIZE;
 
 	return 0;
 }
@@ -1780,7 +1781,7 @@ int xenvif_map_frontend_rings(struct xenvif_queue *queue,
 		goto err;
 
 	txs = (struct xen_netif_tx_sring *)addr;
-	BACK_RING_INIT(&queue->tx, txs, PAGE_SIZE);
+	BACK_RING_INIT(&queue->tx, txs, XEN_PAGE_SIZE);
 
 	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(queue->vif),
 				     &rx_ring_ref, 1, &addr);
@@ -1788,7 +1789,7 @@ int xenvif_map_frontend_rings(struct xenvif_queue *queue,
 		goto err;
 
 	rxs = (struct xen_netif_rx_sring *)addr;
-	BACK_RING_INIT(&queue->rx, rxs, PAGE_SIZE);
+	BACK_RING_INIT(&queue->rx, rxs, XEN_PAGE_SIZE);
 
 	return 0;
 
-- 
2.1.4
