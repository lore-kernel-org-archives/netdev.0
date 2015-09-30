From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH v5 18/22] net/xen-netback: Make it running on
	64KB page granularity
Date: Wed, 30 Sep 2015 11:45:33 +0100
Message-ID: <1443609937-25278-19-git-send-email-julien.grall@citrix.com>
References: <1443609937-25278-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, ian.campbell@citrix.com,
	stefano.stabellini@eu.citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Julien
	Grall <julien.grall@citrix.com>, linux-arm-kernel@lists.infradead.org
To: <xen-devel@lists.xenproject.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1443609937-25278-1-git-send-email-julien.grall@citrix.com>
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

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Reviewed-by: Wei Liu <wei.liu2@citrix.com>

---
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org

Improvement such as support of 64KB grant is not taken into
consideration in this patch because we have the requirement to run a
Linux using 64KB pages on a non-modified Xen.

Note that I haven't add a comment why the offset is 0 after the first
iteration. See [1] for more details.

[1] https://lkml.org/lkml/2015/8/10/456

    Wei, I have kept your reviewed-by because the conflict during rebase
    with with 1d5d48523900a4b0f25d6b52f1a93c84bd671186
    "xen-netback: require fewer guest Rx slots when not using GSO" was
    trivial to resolve. It's basically drop XEN_NETBK_RX_SLOTS_MAX and
    replace the new PAGE_SIZE by XEN_PAGE_SIZE. Let me know if it's not
    okay.

    Changes in v5:
        - Add Wei's reviewed-by
        - Fix conflict with 1d5d48523900a4b0f25d6b52f1a93c84bd671186

    Changes in v4:
        - Add a comment to explain how we compute MAX_XEN_SKB_FRAGS

    Changes in v3:
        - Fix errors reported by checkpatch.pl
        - s/mfn/gfn/ based on the new naming
        - gnttab_foreach_grant has been renamed to gnttab_forach_grant_in_range
        - The grant callback doesn't allow anymore to use less data. An
        helpers has been added in netback to handle this.

    Changes in v2:
        - Correctly set MAX_GRANT_COPY_OPS and XEN_NETBK_RX_SLOTS_MAX
        - Don't use XEN_PAGE_SIZE in handle_frag_list as we coalesce
        fragment into a new skb
        - Use gnntab_foreach_grant to split a Linux page into grant
---
 drivers/net/xen-netback/common.h  |  16 ++--
 drivers/net/xen-netback/netback.c | 157 ++++++++++++++++++++++++--------------
 2 files changed, 111 insertions(+), 62 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index a7bf747..0333ab0 100644
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
@@ -80,16 +81,21 @@ struct xenvif_rx_meta {
 /* Discriminate from any valid pending_idx value. */
 #define INVALID_PENDING_IDX 0xFFFF
 
-#define MAX_BUFFER_OFFSET PAGE_SIZE
+#define MAX_BUFFER_OFFSET XEN_PAGE_SIZE
 
 #define MAX_PENDING_REQS XEN_NETIF_TX_RING_SIZE
 
+/* The maximum number of frags is derived from the size of a grant (same
+ * as a Xen page size for now).
+ */
+#define MAX_XEN_SKB_FRAGS (65536 / XEN_PAGE_SIZE + 1)
+
 /* It's possible for an skb to have a maximal number of frags
  * but still be less than MAX_BUFFER_OFFSET in size. Thus the
- * worst-case number of copy operations is MAX_SKB_FRAGS per
+ * worst-case number of copy operations is MAX_XEN_SKB_FRAGS per
  * ring slot.
  */
-#define MAX_GRANT_COPY_OPS (MAX_SKB_FRAGS * XEN_NETIF_RX_RING_SIZE)
+#define MAX_GRANT_COPY_OPS (MAX_XEN_SKB_FRAGS * XEN_NETIF_RX_RING_SIZE)
 
 #define NETBACK_INVALID_HANDLE -1
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index c4e6c02..e481f37 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -152,9 +152,9 @@ static inline pending_ring_idx_t pending_index(unsigned i)
 static int xenvif_rx_ring_slots_needed(struct xenvif *vif)
 {
 	if (vif->gso_mask)
-		return DIV_ROUND_UP(vif->dev->gso_max_size, PAGE_SIZE) + 1;
+		return DIV_ROUND_UP(vif->dev->gso_max_size, XEN_PAGE_SIZE) + 1;
 	else
-		return DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
+		return DIV_ROUND_UP(vif->dev->mtu, XEN_PAGE_SIZE);
 }
 
 static bool xenvif_rx_ring_slots_available(struct xenvif_queue *queue)
@@ -274,6 +274,80 @@ static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif_queue *queue,
 	return meta;
 }
 
+struct gop_frag_copy {
+	struct xenvif_queue *queue;
+	struct netrx_pending_operations *npo;
+	struct xenvif_rx_meta *meta;
+	int head;
+	int gso_type;
+
+	struct page *page;
+};
+
+static void xenvif_setup_copy_gop(unsigned long gfn,
+				  unsigned int offset,
+				  unsigned int *len,
+				  struct gop_frag_copy *info)
+{
+	struct gnttab_copy *copy_gop;
+	struct xen_page_foreign *foreign;
+	/* Convenient aliases */
+	struct xenvif_queue *queue = info->queue;
+	struct netrx_pending_operations *npo = info->npo;
+	struct page *page = info->page;
+
+	BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
+
+	if (npo->copy_off == MAX_BUFFER_OFFSET)
+		info->meta = get_next_rx_buffer(queue, npo);
+
+	if (npo->copy_off + *len > MAX_BUFFER_OFFSET)
+		*len = MAX_BUFFER_OFFSET - npo->copy_off;
+
+	copy_gop = npo->copy + npo->copy_prod++;
+	copy_gop->flags = GNTCOPY_dest_gref;
+	copy_gop->len = *len;
+
+	foreign = xen_page_foreign(page);
+	if (foreign) {
+		copy_gop->source.domid = foreign->domid;
+		copy_gop->source.u.ref = foreign->gref;
+		copy_gop->flags |= GNTCOPY_source_gref;
+	} else {
+		copy_gop->source.domid = DOMID_SELF;
+		copy_gop->source.u.gmfn = gfn;
+	}
+	copy_gop->source.offset = offset;
+
+	copy_gop->dest.domid = queue->vif->domid;
+	copy_gop->dest.offset = npo->copy_off;
+	copy_gop->dest.u.ref = npo->copy_gref;
+
+	npo->copy_off += *len;
+	info->meta->size += *len;
+
+	/* Leave a gap for the GSO descriptor. */
+	if (info->head && ((1 << info->gso_type) & queue->vif->gso_mask))
+		queue->rx.req_cons++;
+
+	info->head = 0; /* There must be something in this buffer now */
+}
+
+static void xenvif_gop_frag_copy_grant(unsigned long gfn,
+				       unsigned offset,
+				       unsigned int len,
+				       void *data)
+{
+	unsigned int bytes;
+
+	while (len) {
+		bytes = len;
+		xenvif_setup_copy_gop(gfn, offset, &bytes, data);
+		offset += bytes;
+		len -= bytes;
+	}
+}
+
 /*
  * Set up the grant operations for this fragment. If it's a flipping
  * interface, we also set up the unmap request from here.
@@ -283,83 +357,52 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 				 struct page *page, unsigned long size,
 				 unsigned long offset, int *head)
 {
-	struct gnttab_copy *copy_gop;
-	struct xenvif_rx_meta *meta;
+	struct gop_frag_copy info = {
+		.queue = queue,
+		.npo = npo,
+		.head = *head,
+		.gso_type = XEN_NETIF_GSO_TYPE_NONE,
+	};
 	unsigned long bytes;
-	int gso_type = XEN_NETIF_GSO_TYPE_NONE;
 
 	if (skb_is_gso(skb)) {
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
+			info.gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
 		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
+			info.gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
 	}
 
 	/* Data must not cross a page boundary. */
 	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
 
-	meta = npo->meta + npo->meta_prod - 1;
+	info.meta = npo->meta + npo->meta_prod - 1;
 
 	/* Skip unused frames from start of page */
 	page += offset >> PAGE_SHIFT;
 	offset &= ~PAGE_MASK;
 
 	while (size > 0) {
-		struct xen_page_foreign *foreign;
-
 		BUG_ON(offset >= PAGE_SIZE);
-		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
-
-		if (npo->copy_off == MAX_BUFFER_OFFSET)
-			meta = get_next_rx_buffer(queue, npo);
 
 		bytes = PAGE_SIZE - offset;
 		if (bytes > size)
 			bytes = size;
 
-		if (npo->copy_off + bytes > MAX_BUFFER_OFFSET)
-			bytes = MAX_BUFFER_OFFSET - npo->copy_off;
-
-		copy_gop = npo->copy + npo->copy_prod++;
-		copy_gop->flags = GNTCOPY_dest_gref;
-		copy_gop->len = bytes;
-
-		foreign = xen_page_foreign(page);
-		if (foreign) {
-			copy_gop->source.domid = foreign->domid;
-			copy_gop->source.u.ref = foreign->gref;
-			copy_gop->flags |= GNTCOPY_source_gref;
-		} else {
-			copy_gop->source.domid = DOMID_SELF;
-			copy_gop->source.u.gmfn =
-				virt_to_gfn(page_address(page));
-		}
-		copy_gop->source.offset = offset;
-
-		copy_gop->dest.domid = queue->vif->domid;
-		copy_gop->dest.offset = npo->copy_off;
-		copy_gop->dest.u.ref = npo->copy_gref;
-
-		npo->copy_off += bytes;
-		meta->size += bytes;
-
-		offset += bytes;
+		info.page = page;
+		gnttab_foreach_grant_in_range(page, offset, bytes,
+					      xenvif_gop_frag_copy_grant,
+					      &info);
 		size -= bytes;
+		offset = 0;
 
-		/* Next frame */
-		if (offset == PAGE_SIZE && size) {
+		/* Next page */
+		if (size) {
 			BUG_ON(!PageCompound(page));
 			page++;
-			offset = 0;
 		}
-
-		/* Leave a gap for the GSO descriptor. */
-		if (*head && ((1 << gso_type) & queue->vif->gso_mask))
-			queue->rx.req_cons++;
-
-		*head = 0; /* There must be something in this buffer now. */
-
 	}
+
+	*head = info.head;
 }
 
 /*
@@ -758,7 +801,7 @@ static int xenvif_count_requests(struct xenvif_queue *queue,
 		first->size -= txp->size;
 		slots++;
 
-		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
+		if (unlikely((txp->offset + txp->size) > XEN_PAGE_SIZE)) {
 			netdev_err(queue->vif->dev, "Cross page boundary, txp->offset: %u, size: %u\n",
 				 txp->offset, txp->size);
 			xenvif_fatal_tx_err(queue->vif);
@@ -1339,11 +1382,11 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 		}
 
 		/* No crossing a page as the payload mustn't fragment. */
-		if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) {
+		if (unlikely((txreq.offset + txreq.size) > XEN_PAGE_SIZE)) {
 			netdev_err(queue->vif->dev,
 				   "txreq.offset: %u, size: %u, end: %lu\n",
 				   txreq.offset, txreq.size,
-				   (unsigned long)(txreq.offset&~PAGE_MASK) + txreq.size);
+				   (unsigned long)(txreq.offset&~XEN_PAGE_MASK) + txreq.size);
 			xenvif_fatal_tx_err(queue->vif);
 			break;
 		}
@@ -1409,7 +1452,7 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 			virt_to_gfn(skb->data);
 		queue->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
 		queue->tx_copy_ops[*copy_ops].dest.offset =
-			offset_in_page(skb->data);
+			offset_in_page(skb->data) & ~XEN_PAGE_MASK;
 
 		queue->tx_copy_ops[*copy_ops].len = data_len;
 		queue->tx_copy_ops[*copy_ops].flags = GNTCOPY_source_gref;
@@ -1894,7 +1937,7 @@ int xenvif_map_frontend_rings(struct xenvif_queue *queue,
 		goto err;
 
 	txs = (struct xen_netif_tx_sring *)addr;
-	BACK_RING_INIT(&queue->tx, txs, PAGE_SIZE);
+	BACK_RING_INIT(&queue->tx, txs, XEN_PAGE_SIZE);
 
 	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(queue->vif),
 				     &rx_ring_ref, 1, &addr);
@@ -1902,7 +1945,7 @@ int xenvif_map_frontend_rings(struct xenvif_queue *queue,
 		goto err;
 
 	rxs = (struct xen_netif_rx_sring *)addr;
-	BACK_RING_INIT(&queue->rx, rxs, PAGE_SIZE);
+	BACK_RING_INIT(&queue->rx, rxs, XEN_PAGE_SIZE);
 
 	return 0;
 
-- 
2.1.4
