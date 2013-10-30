From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next RFC 1/5] xen-netback: Introduce TX grant map definitions
Date: Wed, 30 Oct 2013 00:50:16 +0000
Message-ID: <1383094220-14775-2-git-send-email-zoltan.kiss@citrix.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the new definitions necessary for grant mapping.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

---
 drivers/net/xen-netback/common.h    |   22 ++++++
 drivers/net/xen-netback/interface.c |    1 +
 drivers/net/xen-netback/netback.c   |  134 +++++++++++++++++++++++++++++++++++
 3 files changed, 157 insertions(+)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 55b8dec..36a3fda 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -79,6 +79,11 @@ struct pending_tx_info {
 				  * if it is head of one or more tx
 				  * reqs
 				  */
+	/* callback data for released SKBs. The	callback is always
+	 * xenvif_zerocopy_callback, ctx points to the next fragment, desc
+	 * contains the pending_idx
+	 */
+	struct ubuf_info callback_struct;
 };
 
 #define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
@@ -101,6 +106,8 @@ struct xenvif_rx_meta {
 
 #define MAX_PENDING_REQS 256
 
+#define NETBACK_INVALID_HANDLE -1
+
 struct xenvif {
 	/* Unique identifier for this interface. */
 	domid_t          domid;
@@ -119,13 +126,22 @@ struct xenvif {
 	pending_ring_idx_t pending_cons;
 	u16 pending_ring[MAX_PENDING_REQS];
 	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
+	grant_handle_t grant_tx_handle[MAX_PENDING_REQS];
 
 	/* Coalescing tx requests before copying makes number of grant
 	 * copy ops greater or equal to number of slots required. In
 	 * worst case a tx request consumes 2 gnttab_copy.
 	 */
 	struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
+	struct gnttab_unmap_grant_ref tx_unmap_ops[MAX_PENDING_REQS];
+	struct gnttab_map_grant_ref tx_map_ops[MAX_PENDING_REQS];
+	/* passed to gnttab_[un]map_refs with pages under (un)mapping */
+	struct page *pages_to_gnt[MAX_PENDING_REQS];
 
+	spinlock_t dealloc_lock;
+	pending_ring_idx_t dealloc_prod;
+	pending_ring_idx_t dealloc_cons;
+	u16 dealloc_ring[MAX_PENDING_REQS];
 
 	/* Use kthread for guest RX */
 	struct task_struct *task;
@@ -226,6 +242,12 @@ void xenvif_rx_action(struct xenvif *vif);
 
 int xenvif_kthread(void *data);
 
+/* Callback from stack when TX packet can be released */
+void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success);
+
+/* Unmap a pending page, usually has to be called before xenvif_idx_release */
+void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx);
+
 extern bool separate_tx_rx_irq;
 
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index e4aa267..f5c3c57 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -37,6 +37,7 @@
 
 #include <xen/events.h>
 #include <asm/xen/hypercall.h>
+#include <xen/balloon.h>
 
 #define XENVIF_QUEUE_LENGTH 32
 #define XENVIF_NAPI_WEIGHT  64
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 828fdab..10470dc 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -869,6 +869,20 @@ static struct page *xenvif_alloc_page(struct xenvif *vif,
 	return page;
 }
 
+static inline void xenvif_tx_create_gop(struct xenvif *vif, u16 pending_idx,
+	       struct xen_netif_tx_request *txp,
+	       struct gnttab_map_grant_ref *gop)
+{
+	vif->pages_to_gnt[gop-vif->tx_map_ops] = vif->mmap_pages[pending_idx];
+	gnttab_set_map_op(gop, idx_to_kaddr(vif, pending_idx),
+			  GNTMAP_host_map | GNTMAP_readonly,
+			  txp->gref, vif->domid);
+
+	memcpy(&vif->pending_tx_info[pending_idx].req, txp,
+	       sizeof(*txp));
+
+}
+
 static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
 					       struct sk_buff *skb,
 					       struct xen_netif_tx_request *txp,
@@ -1652,6 +1666,106 @@ static int xenvif_tx_submit(struct xenvif *vif, int budget)
 	return work_done;
 }
 
+void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
+{
+	unsigned long flags;
+	pending_ring_idx_t index;
+	u16 pending_idx = ubuf->desc;
+	struct pending_tx_info *temp =
+		container_of(ubuf, struct pending_tx_info, callback_struct);
+	struct xenvif *vif =
+		container_of(temp - pending_idx, struct xenvif,
+			pending_tx_info[0]);
+
+	spin_lock_irqsave(&vif->dealloc_lock, flags);
+	do {
+		pending_idx = ubuf->desc;
+		ubuf = (struct ubuf_info *) ubuf->ctx;
+		index = pending_index(vif->dealloc_prod);
+		vif->dealloc_ring[index] = pending_idx;
+		/* Sync with xenvif_tx_action_dealloc:
+		 * insert idx then incr producer.
+		 */
+		smp_wmb();
+		vif->dealloc_prod++;
+		napi_schedule(&vif->napi);
+	} while (ubuf);
+	spin_unlock_irqrestore(&vif->dealloc_lock, flags);
+}
+
+static inline void xenvif_tx_action_dealloc(struct xenvif *vif)
+{
+	struct gnttab_unmap_grant_ref *gop;
+	pending_ring_idx_t dc, dp;
+	u16 pending_idx, pending_idx_release[MAX_PENDING_REQS];
+	unsigned int i = 0;
+
+	dc = vif->dealloc_cons;
+	gop = vif->tx_unmap_ops;
+
+	/* Free up any grants we have finished using */
+	do {
+		dp = vif->dealloc_prod;
+
+		/* Ensure we see all indices enqueued by netif_idx_release(). */
+		smp_rmb();
+
+		while (dc != dp) {
+
+			pending_idx_release[gop-vif->tx_unmap_ops] =
+				pending_idx =
+				vif->dealloc_ring[pending_index(dc++)];
+
+			/* Already unmapped? */
+			if (vif->grant_tx_handle[pending_idx] ==
+				NETBACK_INVALID_HANDLE) {
+				netdev_err(vif->dev,
+					"Trying to unmap invalid handle! "
+					"pending_idx: %x\n", pending_idx);
+				continue;
+			}
+
+			vif->pages_to_gnt[gop-vif->tx_unmap_ops] =
+				vif->mmap_pages[pending_idx];
+			gnttab_set_unmap_op(gop,
+					idx_to_kaddr(vif, pending_idx),
+					GNTMAP_host_map,
+					vif->grant_tx_handle[pending_idx]);
+			vif->grant_tx_handle[pending_idx] =
+				NETBACK_INVALID_HANDLE;
+			++gop;
+		}
+
+	} while (dp != vif->dealloc_prod);
+
+	vif->dealloc_cons = dc;
+
+	if (gop - vif->tx_unmap_ops > 0) {
+		int ret;
+		ret = gnttab_unmap_refs(vif->tx_unmap_ops,
+			NULL,
+			vif->pages_to_gnt,
+			gop - vif->tx_unmap_ops);
+		if (ret) {
+			netdev_err(vif->dev, "Unmap fail: nr_ops %x ret %d\n",
+				gop - vif->tx_unmap_ops, ret);
+			for (i = 0; i < gop - vif->tx_unmap_ops; ++i) {
+				netdev_err(vif->dev,
+					" host_addr: %llx handle: %x status: %d\n",
+					gop[i].host_addr,
+					gop[i].handle,
+					gop[i].status);
+			}
+			BUG();
+		}
+	}
+
+	for (i = 0; i < gop - vif->tx_unmap_ops; ++i)
+		xenvif_idx_release(vif, pending_idx_release[i],
+				XEN_NETIF_RSP_OKAY);
+}
+
+
 /* Called after netfront has transmitted */
 int xenvif_tx_action(struct xenvif *vif, int budget)
 {
@@ -1718,6 +1832,26 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
 	vif->mmap_pages[pending_idx] = NULL;
 }
 
+void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
+{
+	int ret;
+	if (vif->grant_tx_handle[pending_idx] == NETBACK_INVALID_HANDLE) {
+		netdev_err(vif->dev,
+				"Trying to unmap invalid handle! pending_idx: %x\n",
+				pending_idx);
+		return;
+	}
+	gnttab_set_unmap_op(&vif->tx_unmap_ops[0],
+			idx_to_kaddr(vif, pending_idx),
+			GNTMAP_host_map,
+			vif->grant_tx_handle[pending_idx]);
+	ret = gnttab_unmap_refs(vif->tx_unmap_ops,
+			NULL,
+			&vif->mmap_pages[pending_idx],
+			1);
+	BUG_ON(ret);
+	vif->grant_tx_handle[pending_idx] = NETBACK_INVALID_HANDLE;
+}
 
 static void make_tx_response(struct xenvif *vif,
 			     struct xen_netif_tx_request *txp,
