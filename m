From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v2 1/9] xen-netback: Introduce TX grant map definitions
Date: Thu, 12 Dec 2013 23:48:09 +0000
Message-ID: <1386892097-15502-2-git-send-email-zoltan.kiss@citrix.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the new definitions necessary for grant mapping.

v2:
- move unmapping to separate thread. The NAPI instance has to be scheduled
  even from thread context, which can cause huge delays
- that causes unfortunately bigger struct xenvif
- store grant handle after checking validity

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

---
 drivers/net/xen-netback/common.h    |   30 ++++++-
 drivers/net/xen-netback/interface.c |    1 +
 drivers/net/xen-netback/netback.c   |  164 +++++++++++++++++++++++++++++++++++
 3 files changed, 194 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index ba30a6d..33cb12c 100644
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
@@ -119,13 +126,26 @@ struct xenvif {
 	pending_ring_idx_t pending_cons;
 	u16 pending_ring[MAX_PENDING_REQS];
 	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
+	grant_handle_t grant_tx_handle[MAX_PENDING_REQS];
 
 	/* Coalescing tx requests before copying makes number of grant
 	 * copy ops greater or equal to number of slots required. In
 	 * worst case a tx request consumes 2 gnttab_copy.
 	 */
 	struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
-
+	struct gnttab_unmap_grant_ref tx_unmap_ops[MAX_PENDING_REQS];
+	struct gnttab_map_grant_ref tx_map_ops[MAX_PENDING_REQS];
+	/* passed to gnttab_[un]map_refs with pages under (un)mapping */
+	struct page *pages_to_map[MAX_PENDING_REQS];
+	struct page *pages_to_unmap[MAX_PENDING_REQS];
+
+	spinlock_t dealloc_lock;
+	spinlock_t response_lock;
+	pending_ring_idx_t dealloc_prod;
+	pending_ring_idx_t dealloc_cons;
+	u16 dealloc_ring[MAX_PENDING_REQS];
+	struct task_struct *dealloc_task;
+	wait_queue_head_t dealloc_wq;
 
 	/* Use kthread for guest RX */
 	struct task_struct *task;
@@ -215,6 +235,8 @@ int xenvif_tx_action(struct xenvif *vif, int budget);
 int xenvif_kthread(void *data);
 void xenvif_kick_thread(struct xenvif *vif);
 
+int xenvif_dealloc_kthread(void *data);
+
 /* Determine whether the needed number of slots (req) are available,
  * and set req_event if not.
  */
@@ -222,6 +244,12 @@ bool xenvif_rx_ring_slots_available(struct xenvif *vif, int needed);
 
 void xenvif_stop_queue(struct xenvif *vif);
 
+/* Callback from stack when TX packet can be released */
+void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success);
+
+/* Unmap a pending page, usually has to be called before xenvif_idx_release */
+void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx);
+
 extern bool separate_tx_rx_irq;
 
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 1dcb960..1c27e9e 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -37,6 +37,7 @@
 
 #include <xen/events.h>
 #include <asm/xen/hypercall.h>
+#include <xen/balloon.h>
 
 #define XENVIF_QUEUE_LENGTH 32
 #define XENVIF_NAPI_WEIGHT  64
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index c1b7a42..3ddc474 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -772,6 +772,20 @@ static struct page *xenvif_alloc_page(struct xenvif *vif,
 	return page;
 }
 
+static inline void xenvif_tx_create_gop(struct xenvif *vif, u16 pending_idx,
+	       struct xen_netif_tx_request *txp,
+	       struct gnttab_map_grant_ref *gop)
+{
+	vif->pages_to_map[gop-vif->tx_map_ops] = vif->mmap_pages[pending_idx];
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
@@ -1593,6 +1607,106 @@ static int xenvif_tx_submit(struct xenvif *vif)
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
+	} while (ubuf);
+	wake_up(&vif->dealloc_wq);
+	spin_unlock_irqrestore(&vif->dealloc_lock, flags);
+}
+
+static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
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
+			pending_idx =
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
+			pending_idx_release[gop-vif->tx_unmap_ops] =
+				pending_idx;
+			vif->pages_to_unmap[gop-vif->tx_unmap_ops] =
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
+			vif->pages_to_unmap,
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
@@ -1659,6 +1773,26 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
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
@@ -1720,6 +1854,14 @@ static inline int tx_work_todo(struct xenvif *vif)
 	return 0;
 }
 
+static inline int tx_dealloc_work_todo(struct xenvif *vif)
+{
+	if (vif->dealloc_cons != vif->dealloc_prod)
+		return 1;
+
+	return 0;
+}
+
 void xenvif_unmap_frontend_rings(struct xenvif *vif)
 {
 	if (vif->tx.sring)
@@ -1808,6 +1950,28 @@ int xenvif_kthread(void *data)
 	return 0;
 }
 
+int xenvif_dealloc_kthread(void *data)
+{
+	struct xenvif *vif = data;
+
+	while (!kthread_should_stop()) {
+		wait_event_interruptible(vif->dealloc_wq,
+					tx_dealloc_work_todo(vif) ||
+					 kthread_should_stop());
+		if (kthread_should_stop())
+			break;
+
+		xenvif_tx_dealloc_action(vif);
+		cond_resched();
+	}
+
+	/* Unmap anything remaining*/
+	if (tx_dealloc_work_todo(vif))
+		xenvif_tx_dealloc_action(vif);
+
+	return 0;
+}
+
 static int __init netback_init(void)
 {
 	int rc = 0;
