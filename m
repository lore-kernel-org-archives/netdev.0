From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V4 06/13] netback: melt xen_netbk into xenvif
Date: Thu, 2 Feb 2012 16:49:16 +0000
Message-ID: <1328201363-13915-7-git-send-email-wei.liu2@citrix.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:18042 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755433Ab2BBQti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 11:49:38 -0500
In-Reply-To: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the 1:1 model, there is no need to keep xen_netbk and xenvif
separated.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |   35 +++---
 drivers/net/xen-netback/interface.c |   36 +++---
 drivers/net/xen-netback/netback.c   |  219 +++++++++++++----------------------
 drivers/net/xen-netback/page_pool.c |   10 +-
 drivers/net/xen-netback/page_pool.h |   13 ++-
 5 files changed, 124 insertions(+), 189 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 65df480..ea91bb6 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -46,6 +46,7 @@
 #include <xen/xenbus.h>
 
 #define DRV_NAME "netback: "
+#include "page_pool.h"
 
 struct netbk_rx_meta {
 	int id;
@@ -53,28 +54,21 @@ struct netbk_rx_meta {
 	int gso_size;
 };
 
-#define MAX_PENDING_REQS 256
-
 /* Discriminate from any valid pending_idx value. */
 #define INVALID_PENDING_IDX 0xFFFF
 
 #define MAX_BUFFER_OFFSET PAGE_SIZE
 
-struct pending_tx_info {
-	struct xen_netif_tx_request req;
-};
-typedef unsigned int pending_ring_idx_t;
+#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
+#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
 
-struct xen_netbk;
+#define MAX_PENDING_REQS 256
 
 struct xenvif {
 	/* Unique identifier for this interface. */
 	domid_t          domid;
 	unsigned int     handle;
 
-	/* Reference to netback processing backend. */
-	struct xen_netbk *netbk;
-
 	/* Use NAPI for guest TX */
 	struct napi_struct napi;
 	/* Use kthread for guest RX */
@@ -117,6 +111,16 @@ struct xenvif {
 
 	/* Miscellaneous private stuff. */
 	struct net_device *dev;
+
+	struct sk_buff_head rx_queue;
+	struct sk_buff_head tx_queue;
+
+	idx_t mmap_pages[MAX_PENDING_REQS];
+
+	pending_ring_idx_t pending_prod;
+	pending_ring_idx_t pending_cons;
+
+	u16 pending_ring[MAX_PENDING_REQS];
 };
 
 static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
@@ -124,9 +128,6 @@ static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
 	return to_xenbus_device(vif->dev->dev.parent);
 }
 
-#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
-#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
-
 struct xenvif *xenvif_alloc(struct device *parent,
 			    domid_t domid,
 			    unsigned int handle);
@@ -161,12 +162,8 @@ void xenvif_notify_tx_completion(struct xenvif *vif);
 /* Returns number of ring slots required to send an skb to the frontend */
 unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb);
 
-/* Allocate and free xen_netbk structure */
-struct xen_netbk *xen_netbk_alloc_netbk(struct xenvif *vif);
-void xen_netbk_free_netbk(struct xen_netbk *netbk);
-
-int xen_netbk_tx_action(struct xen_netbk *netbk, int budget);
-void xen_netbk_rx_action(struct xen_netbk *netbk);
+int xen_netbk_tx_action(struct xenvif *vif, int budget);
+void xen_netbk_rx_action(struct xenvif *vif);
 
 int xen_netbk_kthread(void *data);
 
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 1d9688a..9b7d596 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -55,9 +55,6 @@ static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
 {
 	struct xenvif *vif = dev_id;
 
-	if (vif->netbk == NULL)
-		return IRQ_NONE;
-
 	if (xenvif_rx_schedulable(vif))
 		netif_wake_queue(vif->dev);
 
@@ -72,7 +69,7 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
 	struct xenvif *vif = container_of(napi, struct xenvif, napi);
 	int work_done;
 
-	work_done = xen_netbk_tx_action(vif->netbk, budget);
+	work_done = xen_netbk_tx_action(vif, budget);
 
 	if (work_done < budget) {
 		int more_to_do = 0;
@@ -96,7 +93,8 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	BUG_ON(skb->dev != dev);
 
-	if (vif->netbk == NULL)
+	/* Drop the packet if vif is not ready */
+	if (vif->task == NULL)
 		goto drop;
 
 	/* Drop the packet if the target domain has no receive buffers. */
@@ -253,6 +251,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	int err;
 	struct net_device *dev;
 	struct xenvif *vif;
+	int i;
 	char name[IFNAMSIZ] = {};
 
 	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
@@ -267,7 +266,6 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif = netdev_priv(dev);
 	vif->domid  = domid;
 	vif->handle = handle;
-	vif->netbk = NULL;
 
 	vif->can_sg = 1;
 	vif->csum = 1;
@@ -286,6 +284,17 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 
 	dev->tx_queue_len = XENVIF_QUEUE_LENGTH;
 
+	skb_queue_head_init(&vif->rx_queue);
+	skb_queue_head_init(&vif->tx_queue);
+
+	vif->pending_cons = 0;
+	vif->pending_prod = MAX_PENDING_REQS;
+	for (i = 0; i < MAX_PENDING_REQS; i++)
+		vif->pending_ring[i] = i;
+
+	for (i = 0; i < MAX_PENDING_REQS; i++)
+		vif->mmap_pages[i] = INVALID_ENTRY;
+
 	/*
 	 * Initialise a dummy MAC address. We choose the numerically
 	 * largest non-broadcast address to prevent the address getting
@@ -333,14 +342,6 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	vif->irq = err;
 	disable_irq(vif->irq);
 
-	vif->netbk = xen_netbk_alloc_netbk(vif);
-	if (!vif->netbk) {
-		pr_warn("Could not allocate xen_netbk\n");
-		err = -ENOMEM;
-		goto err_unbind;
-	}
-
-
 	init_waitqueue_head(&vif->wq);
 	vif->task = kthread_create(xen_netbk_kthread,
 				   (void *)vif,
@@ -348,7 +349,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	if (IS_ERR(vif->task)) {
 		pr_warn("Could not create kthread\n");
 		err = PTR_ERR(vif->task);
-		goto err_free_netbk;
+		goto err_unbind;
 	}
 
 	rtnl_lock();
@@ -363,8 +364,6 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	wake_up_process(vif->task);
 
 	return 0;
-err_free_netbk:
-	xen_netbk_free_netbk(vif->netbk);
 err_unbind:
 	unbind_from_irqhandler(vif->irq, vif);
 err_unmap:
@@ -390,9 +389,6 @@ void xenvif_disconnect(struct xenvif *vif)
 	if (vif->task)
 		kthread_stop(vif->task);
 
-	if (vif->netbk)
-		xen_netbk_free_netbk(vif->netbk);
-
 	netif_napi_del(&vif->napi);
 
 	del_timer_sync(&vif->credit_timeout);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 5584853..ef9cfbe 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -60,28 +60,13 @@ DEFINE_PER_CPU(struct gnttab_copy *, tx_copy_ops);
 DEFINE_PER_CPU(struct gnttab_copy *, grant_copy_op);
 DEFINE_PER_CPU(struct netbk_rx_meta *, meta);
 
-
-struct xen_netbk {
-	struct sk_buff_head rx_queue;
-	struct sk_buff_head tx_queue;
-
-	idx_t mmap_pages[MAX_PENDING_REQS];
-
-	pending_ring_idx_t pending_prod;
-	pending_ring_idx_t pending_cons;
-
-	struct xenvif *vif;
-
-	u16 pending_ring[MAX_PENDING_REQS];
-};
-
-static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx);
+static void xen_netbk_idx_release(struct xenvif *vif, u16 pending_idx);
 static void make_tx_response(struct xenvif *vif,
 			     struct xen_netif_tx_request *txp,
 			     s8       st);
 
-static inline int tx_work_todo(struct xen_netbk *netbk);
-static inline int rx_work_todo(struct xen_netbk *netbk);
+static inline int tx_work_todo(struct xenvif *vif);
+static inline int rx_work_todo(struct xenvif *vif);
 
 static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 					     u16      id,
@@ -90,16 +75,16 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 					     u16      size,
 					     u16      flags);
 
-static inline unsigned long idx_to_pfn(struct xen_netbk *netbk,
+static inline unsigned long idx_to_pfn(struct xenvif *vif,
 				       u16 idx)
 {
-	return page_to_pfn(to_page(netbk->mmap_pages[idx]));
+	return page_to_pfn(to_page(vif->mmap_pages[idx]));
 }
 
-static inline unsigned long idx_to_kaddr(struct xen_netbk *netbk,
+static inline unsigned long idx_to_kaddr(struct xenvif *vif,
 					 u16 idx)
 {
-	return (unsigned long)pfn_to_kaddr(idx_to_pfn(netbk, idx));
+	return (unsigned long)pfn_to_kaddr(idx_to_pfn(vif, idx));
 }
 
 /*
@@ -127,10 +112,10 @@ static inline pending_ring_idx_t pending_index(unsigned i)
 	return i & (MAX_PENDING_REQS-1);
 }
 
-static inline pending_ring_idx_t nr_pending_reqs(struct xen_netbk *netbk)
+static inline pending_ring_idx_t nr_pending_reqs(struct xenvif *vif)
 {
 	return MAX_PENDING_REQS -
-		netbk->pending_prod + netbk->pending_cons;
+		vif->pending_prod + vif->pending_cons;
 }
 
 static int max_required_rx_slots(struct xenvif *vif)
@@ -317,9 +302,9 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		copy_gop->flags = GNTCOPY_dest_gref;
 		if (foreign) {
 			struct pending_tx_info *src_pend = to_txinfo(idx);
-			struct xen_netbk *rnetbk = to_netbk(idx);
+			struct xenvif *rvif = to_vif(idx);
 
-			copy_gop->source.domid = rnetbk->vif->domid;
+			copy_gop->source.domid = rvif->domid;
 			copy_gop->source.u.ref = src_pend->req.gref;
 			copy_gop->flags |= GNTCOPY_source_gref;
 		} else {
@@ -477,16 +462,13 @@ struct skb_cb_overlay {
 	int meta_slots_used;
 };
 
-static void xen_netbk_kick_thread(struct xen_netbk *netbk)
+static void xen_netbk_kick_thread(struct xenvif *vif)
 {
-	struct xenvif *vif = netbk->vif;
-
 	wake_up(&vif->wq);
 }
 
-void xen_netbk_rx_action(struct xen_netbk *netbk)
+void xen_netbk_rx_action(struct xenvif *vif)
 {
-	struct xenvif *vif = NULL;
 	s8 status;
 	u16 flags;
 	struct xen_netif_rx_response *resp;
@@ -516,7 +498,7 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 			pr_alert("CPU %x scratch space is not usable,"
 				 " not doing any TX work for vif%u.%u\n",
 				 smp_processor_id(),
-				 netbk->vif->domid, netbk->vif->handle);
+				 vif->domid, vif->handle);
 			unusable_count = 0;
 		}
 		return;
@@ -526,7 +508,7 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 
 	count = 0;
 
-	while ((skb = skb_dequeue(&netbk->rx_queue)) != NULL) {
+	while ((skb = skb_dequeue(&vif->rx_queue)) != NULL) {
 		vif = netdev_priv(skb->dev);
 		nr_frags = skb_shinfo(skb)->nr_frags;
 
@@ -558,8 +540,6 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 	while ((skb = __skb_dequeue(&rxq)) != NULL) {
 		sco = (struct skb_cb_overlay *)skb->cb;
 
-		vif = netdev_priv(skb->dev);
-
 		if (m[npo.meta_cons].gso_size && vif->gso_prefix) {
 			resp = RING_GET_RESPONSE(&vif->rx,
 						vif->rx.rsp_prod_pvt++);
@@ -631,8 +611,8 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 	if (need_to_notify)
 		notify_remote_via_irq(vif->irq);
 
-	if (!skb_queue_empty(&netbk->rx_queue))
-		xen_netbk_kick_thread(netbk);
+	if (!skb_queue_empty(&vif->rx_queue))
+		xen_netbk_kick_thread(vif);
 
 	put_cpu_var(grant_copy_op);
 	put_cpu_var(meta);
@@ -640,11 +620,9 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
 
 void xen_netbk_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
 {
-	struct xen_netbk *netbk = vif->netbk;
-
-	skb_queue_tail(&netbk->rx_queue, skb);
+	skb_queue_tail(&vif->rx_queue, skb);
 
-	xen_netbk_kick_thread(netbk);
+	xen_netbk_kick_thread(vif);
 }
 
 void xen_netbk_check_rx_xenvif(struct xenvif *vif)
@@ -742,21 +720,20 @@ static int netbk_count_requests(struct xenvif *vif,
 	return frags;
 }
 
-static struct page *xen_netbk_alloc_page(struct xen_netbk *netbk,
+static struct page *xen_netbk_alloc_page(struct xenvif *vif,
 					 struct sk_buff *skb,
 					 u16 pending_idx)
 {
 	struct page *page;
 	int idx;
-	page = page_pool_get(netbk, &idx);
+	page = page_pool_get(vif, &idx);
 	if (!page)
 		return NULL;
-	netbk->mmap_pages[pending_idx] = idx;
+	vif->mmap_pages[pending_idx] = idx;
 	return page;
 }
 
-static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
-						  struct xenvif *vif,
+static struct gnttab_copy *xen_netbk_get_requests(struct xenvif *vif,
 						  struct sk_buff *skb,
 						  struct xen_netif_tx_request *txp,
 						  struct gnttab_copy *gop)
@@ -775,13 +752,13 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 		int idx;
 		struct pending_tx_info *pending_tx_info;
 
-		index = pending_index(netbk->pending_cons++);
-		pending_idx = netbk->pending_ring[index];
-		page = xen_netbk_alloc_page(netbk, skb, pending_idx);
+		index = pending_index(vif->pending_cons++);
+		pending_idx = vif->pending_ring[index];
+		page = xen_netbk_alloc_page(vif, skb, pending_idx);
 		if (!page)
 			return NULL;
 
-		idx = netbk->mmap_pages[pending_idx];
+		idx = vif->mmap_pages[pending_idx];
 		pending_tx_info = to_txinfo(idx);
 
 		gop->source.u.ref = txp->gref;
@@ -805,7 +782,7 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 	return gop;
 }
 
-static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
+static int xen_netbk_tx_check_gop(struct xenvif *vif,
 				  struct sk_buff *skb,
 				  struct gnttab_copy **gopp)
 {
@@ -813,8 +790,6 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 	u16 pending_idx = *((u16 *)skb->data);
 	struct pending_tx_info *pending_tx_info;
 	int idx;
-	struct xenvif *vif = netbk->vif;
-
 	struct xen_netif_tx_request *txp;
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	int nr_frags = shinfo->nr_frags;
@@ -824,12 +799,12 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 	err = gop->status;
 	if (unlikely(err)) {
 		pending_ring_idx_t index;
-		index = pending_index(netbk->pending_prod++);
-		idx = netbk->mmap_pages[index];
+		index = pending_index(vif->pending_prod++);
+		idx = vif->mmap_pages[index];
 		pending_tx_info = to_txinfo(idx);
 		txp = &pending_tx_info->req;
 		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
-		netbk->pending_ring[index] = pending_idx;
+		vif->pending_ring[index] = pending_idx;
 	}
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
@@ -846,16 +821,16 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 		if (likely(!newerr)) {
 			/* Had a previous error? Invalidate this fragment. */
 			if (unlikely(err))
-				xen_netbk_idx_release(netbk, pending_idx);
+				xen_netbk_idx_release(vif, pending_idx);
 			continue;
 		}
 
 		/* Error on this fragment: respond to client with an error. */
-		idx = netbk->mmap_pages[pending_idx];
+		idx = vif->mmap_pages[pending_idx];
 		txp = &to_txinfo(idx)->req;
 		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
-		index = pending_index(netbk->pending_prod++);
-		netbk->pending_ring[index] = pending_idx;
+		index = pending_index(vif->pending_prod++);
+		vif->pending_ring[index] = pending_idx;
 
 		/* Not the first error? Preceding frags already invalidated. */
 		if (err)
@@ -863,10 +838,10 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 
 		/* First error: invalidate header and preceding fragments. */
 		pending_idx = *((u16 *)skb->data);
-		xen_netbk_idx_release(netbk, pending_idx);
+		xen_netbk_idx_release(vif, pending_idx);
 		for (j = start; j < i; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
-			xen_netbk_idx_release(netbk, pending_idx);
+			xen_netbk_idx_release(vif, pending_idx);
 		}
 
 		/* Remember the error: invalidate all subsequent fragments. */
@@ -877,7 +852,7 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 	return err;
 }
 
-static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
+static void xen_netbk_fill_frags(struct xenvif *vif, struct sk_buff *skb)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	int nr_frags = shinfo->nr_frags;
@@ -893,11 +868,11 @@ static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
 
 		pending_idx = frag_get_pending_idx(frag);
 
-		idx = netbk->mmap_pages[pending_idx];
+		idx = vif->mmap_pages[pending_idx];
 		pending_tx_info = to_txinfo(idx);
 
 		txp = &pending_tx_info->req;
-		page = virt_to_page(idx_to_kaddr(netbk, pending_idx));
+		page = virt_to_page(idx_to_kaddr(vif, pending_idx));
 		__skb_fill_page_desc(skb, i, page, txp->offset, txp->size);
 		skb->len += txp->size;
 		skb->data_len += txp->size;
@@ -905,7 +880,7 @@ static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
 
 		/* Take an extra reference to offset xen_netbk_idx_release */
 		get_page(page);
-		xen_netbk_idx_release(netbk, pending_idx);
+		xen_netbk_idx_release(vif, pending_idx);
 	}
 }
 
@@ -1066,15 +1041,14 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
 	return false;
 }
 
-static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
+static unsigned xen_netbk_tx_build_gops(struct xenvif *vif,
 					struct gnttab_copy *tco)
 {
 	struct gnttab_copy *gop = tco, *request_gop;
 	struct sk_buff *skb;
 	int ret;
-	struct xenvif *vif = netbk->vif;
 
-	while ((nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) {
+	while ((nr_pending_reqs(vif) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) {
 		struct xen_netif_tx_request txreq;
 		struct xen_netif_tx_request txfrags[MAX_SKB_FRAGS];
 		struct page *page;
@@ -1142,8 +1116,8 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 			break;
 		}
 
-		index = pending_index(netbk->pending_cons);
-		pending_idx = netbk->pending_ring[index];
+		index = pending_index(vif->pending_cons);
+		pending_idx = vif->pending_ring[index];
 
 		data_len = (txreq.size > PKT_PROT_LEN &&
 			    ret < MAX_SKB_FRAGS) ?
@@ -1173,7 +1147,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 		}
 
 		/* XXX could copy straight to head */
-		page = xen_netbk_alloc_page(netbk, skb, pending_idx);
+		page = xen_netbk_alloc_page(vif, skb, pending_idx);
 		if (!page) {
 			kfree_skb(skb);
 			netbk_tx_err(vif, &txreq, idx);
@@ -1193,7 +1167,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 
 		gop++;
 
-		pool_idx = netbk->mmap_pages[pending_idx];
+		pool_idx = vif->mmap_pages[pending_idx];
 		pending_tx_info = to_txinfo(pool_idx);
 
 		memcpy(&pending_tx_info->req,
@@ -1213,11 +1187,11 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 					     INVALID_PENDING_IDX);
 		}
 
-		__skb_queue_tail(&netbk->tx_queue, skb);
+		__skb_queue_tail(&vif->tx_queue, skb);
 
-		netbk->pending_cons++;
+		vif->pending_cons++;
 
-		request_gop = xen_netbk_get_requests(netbk, vif,
+		request_gop = xen_netbk_get_requests(vif,
 						     skb, txfrags, gop);
 		if (request_gop == NULL) {
 			kfree_skb(skb);
@@ -1235,17 +1209,16 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk,
 	return gop - tco;
 }
 
-static int xen_netbk_tx_submit(struct xen_netbk *netbk,
-				struct gnttab_copy *tco,
-				int budget)
+static int xen_netbk_tx_submit(struct xenvif *vif,
+			       struct gnttab_copy *tco,
+			       int budget)
 {
 	struct gnttab_copy *gop = tco;
 	struct sk_buff *skb;
-	struct xenvif *vif = netbk->vif;
 	int work_done = 0;
 
 	while ((work_done < budget) &&
-	       (skb = __skb_dequeue(&netbk->tx_queue)) != NULL) {
+	       (skb = __skb_dequeue(&vif->tx_queue)) != NULL) {
 		struct xen_netif_tx_request *txp;
 		u16 pending_idx;
 		unsigned data_len;
@@ -1254,13 +1227,13 @@ static int xen_netbk_tx_submit(struct xen_netbk *netbk,
 
 		pending_idx = *((u16 *)skb->data);
 
-		idx = netbk->mmap_pages[pending_idx];
+		idx = vif->mmap_pages[pending_idx];
 		pending_tx_info = to_txinfo(idx);
 
 		txp = &pending_tx_info->req;
 
 		/* Check the remap error code. */
-		if (unlikely(xen_netbk_tx_check_gop(netbk, skb, &gop))) {
+		if (unlikely(xen_netbk_tx_check_gop(vif, skb, &gop))) {
 			netdev_dbg(vif->dev, "netback grant failed.\n");
 			skb_shinfo(skb)->nr_frags = 0;
 			kfree_skb(skb);
@@ -1269,7 +1242,7 @@ static int xen_netbk_tx_submit(struct xen_netbk *netbk,
 
 		data_len = skb->len;
 		memcpy(skb->data,
-		       (void *)(idx_to_kaddr(netbk, pending_idx)|txp->offset),
+		       (void *)(idx_to_kaddr(vif, pending_idx)|txp->offset),
 		       data_len);
 		if (data_len < txp->size) {
 			/* Append the packet payload as a fragment. */
@@ -1277,7 +1250,7 @@ static int xen_netbk_tx_submit(struct xen_netbk *netbk,
 			txp->size -= data_len;
 		} else {
 			/* Schedule a response immediately. */
-			xen_netbk_idx_release(netbk, pending_idx);
+			xen_netbk_idx_release(vif, pending_idx);
 		}
 
 		if (txp->flags & XEN_NETTXF_csum_blank)
@@ -1285,7 +1258,7 @@ static int xen_netbk_tx_submit(struct xen_netbk *netbk,
 		else if (txp->flags & XEN_NETTXF_data_validated)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-		xen_netbk_fill_frags(netbk, skb);
+		xen_netbk_fill_frags(vif, skb);
 
 		/*
 		 * If the initial fragment was < PKT_PROT_LEN then
@@ -1319,7 +1292,7 @@ static int xen_netbk_tx_submit(struct xen_netbk *netbk,
 }
 
 /* Called after netfront has transmitted */
-int xen_netbk_tx_action(struct xen_netbk *netbk, int budget)
+int xen_netbk_tx_action(struct xenvif *vif, int budget)
 {
 	unsigned nr_gops;
 	int ret;
@@ -1327,7 +1300,7 @@ int xen_netbk_tx_action(struct xen_netbk *netbk, int budget)
 	struct gnttab_copy *tco;
 	static int unusable_count;
 
-	if (unlikely(!tx_work_todo(netbk)))
+	if (unlikely(!tx_work_todo(vif)))
 		return 0;
 
 	tco = get_cpu_var(tx_copy_ops);
@@ -1340,13 +1313,13 @@ int xen_netbk_tx_action(struct xen_netbk *netbk, int budget)
 				 " is not usable,"
 				 " not doing any RX work for vif%u.%u\n",
 				 smp_processor_id(),
-				 netbk->vif->domid, netbk->vif->handle);
+				 vif->domid, vif->handle);
 			unusable_count = 0;
 		}
 		return -ENOMEM;
 	}
 
-	nr_gops = xen_netbk_tx_build_gops(netbk, tco);
+	nr_gops = xen_netbk_tx_build_gops(vif, tco);
 
 	if (nr_gops == 0) {
 		put_cpu_var(tx_copy_ops);
@@ -1357,35 +1330,34 @@ int xen_netbk_tx_action(struct xen_netbk *netbk, int budget)
 					tco, nr_gops);
 	BUG_ON(ret);
 
-	work_done = xen_netbk_tx_submit(netbk, tco, budget);
+	work_done = xen_netbk_tx_submit(vif, tco, budget);
 
 	put_cpu_var(tx_copy_ops);
 
 	return work_done;
 }
 
-static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
+static void xen_netbk_idx_release(struct xenvif *vif, u16 pending_idx)
 {
-	struct xenvif *vif = netbk->vif;
 	struct pending_tx_info *pending_tx_info;
 	pending_ring_idx_t index;
 	int idx;
 
 	/* Already complete? */
-	if (netbk->mmap_pages[pending_idx] == INVALID_ENTRY)
+	if (vif->mmap_pages[pending_idx] == INVALID_ENTRY)
 		return;
 
-	idx = netbk->mmap_pages[pending_idx];
+	idx = vif->mmap_pages[pending_idx];
 	pending_tx_info = to_txinfo(idx);
 
 	make_tx_response(vif, &pending_tx_info->req, XEN_NETIF_RSP_OKAY);
 
-	index = pending_index(netbk->pending_prod++);
-	netbk->pending_ring[index] = pending_idx;
+	index = pending_index(vif->pending_prod++);
+	vif->pending_ring[index] = pending_idx;
 
-	page_pool_put(netbk->mmap_pages[pending_idx]);
+	page_pool_put(vif->mmap_pages[pending_idx]);
 
-	netbk->mmap_pages[pending_idx] = INVALID_ENTRY;
+	vif->mmap_pages[pending_idx] = INVALID_ENTRY;
 }
 
 static void make_tx_response(struct xenvif *vif,
@@ -1432,15 +1404,15 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 	return resp;
 }
 
-static inline int rx_work_todo(struct xen_netbk *netbk)
+static inline int rx_work_todo(struct xenvif *vif)
 {
-	return !skb_queue_empty(&netbk->rx_queue);
+	return !skb_queue_empty(&vif->rx_queue);
 }
 
-static inline int tx_work_todo(struct xen_netbk *netbk)
+static inline int tx_work_todo(struct xenvif *vif)
 {
-	if (likely(RING_HAS_UNCONSUMED_REQUESTS(&netbk->vif->tx)) &&
-	    (nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS)
+	if (likely(RING_HAS_UNCONSUMED_REQUESTS(&vif->tx)) &&
+	    (nr_pending_reqs(vif) + MAX_SKB_FRAGS) < MAX_PENDING_REQS)
 		return 1;
 
 	return 0;
@@ -1491,54 +1463,21 @@ err:
 	return err;
 }
 
-struct xen_netbk *xen_netbk_alloc_netbk(struct xenvif *vif)
-{
-	int i;
-	struct xen_netbk *netbk;
-
-	netbk = vzalloc(sizeof(struct xen_netbk));
-	if (!netbk) {
-		pr_alert(DRV_NAME "%s: out of memory\n", __func__);
-		return NULL;
-	}
-
-	netbk->vif = vif;
-
-	skb_queue_head_init(&netbk->rx_queue);
-	skb_queue_head_init(&netbk->tx_queue);
-
-	netbk->pending_cons = 0;
-	netbk->pending_prod = MAX_PENDING_REQS;
-	for (i = 0; i < MAX_PENDING_REQS; i++)
-		netbk->pending_ring[i] = i;
-
-	for (i = 0; i < MAX_PENDING_REQS; i++)
-		netbk->mmap_pages[i] = INVALID_ENTRY;
-
-	return netbk;
-}
-
-void xen_netbk_free_netbk(struct xen_netbk *netbk)
-{
-	vfree(netbk);
-}
-
 int xen_netbk_kthread(void *data)
 {
 	struct xenvif *vif = data;
-	struct xen_netbk *netbk = vif->netbk;
 
 	while (!kthread_should_stop()) {
 		wait_event_interruptible(vif->wq,
-					 rx_work_todo(netbk) ||
+					 rx_work_todo(vif) ||
 					 kthread_should_stop());
 		cond_resched();
 
 		if (kthread_should_stop())
 			break;
 
-		if (rx_work_todo(netbk))
-			xen_netbk_rx_action(netbk);
+		if (rx_work_todo(vif))
+			xen_netbk_rx_action(vif);
 	}
 
 	return 0;
diff --git a/drivers/net/xen-netback/page_pool.c b/drivers/net/xen-netback/page_pool.c
index 294f48b..ce00a93 100644
--- a/drivers/net/xen-netback/page_pool.c
+++ b/drivers/net/xen-netback/page_pool.c
@@ -102,7 +102,7 @@ int is_in_pool(struct page *page, int *pidx)
 	return get_page_ext(page, pidx);
 }
 
-struct page *page_pool_get(struct xen_netbk *netbk, int *pidx)
+struct page *page_pool_get(struct xenvif *vif, int *pidx)
 {
 	int idx;
 	struct page *page;
@@ -118,7 +118,7 @@ struct page *page_pool_get(struct xen_netbk *netbk, int *pidx)
 	}
 
 	set_page_ext(page, idx);
-	pool[idx].u.netbk = netbk;
+	pool[idx].u.vif = vif;
 	pool[idx].page = page;
 
 	*pidx = idx;
@@ -131,7 +131,7 @@ void page_pool_put(int idx)
 	struct page *page = pool[idx].page;
 
 	pool[idx].page = NULL;
-	pool[idx].u.netbk = NULL;
+	pool[idx].u.vif = NULL;
 	page->mapping = 0;
 	put_page(page);
 	put_free_entry(idx);
@@ -174,9 +174,9 @@ struct page *to_page(int idx)
 	return pool[idx].page;
 }
 
-struct xen_netbk *to_netbk(int idx)
+struct xenvif *to_vif(int idx)
 {
-	return pool[idx].u.netbk;
+	return pool[idx].u.vif;
 }
 
 struct pending_tx_info *to_txinfo(int idx)
diff --git a/drivers/net/xen-netback/page_pool.h b/drivers/net/xen-netback/page_pool.h
index 572b037..efae17c 100644
--- a/drivers/net/xen-netback/page_pool.h
+++ b/drivers/net/xen-netback/page_pool.h
@@ -27,7 +27,10 @@
 #ifndef __PAGE_POOL_H__
 #define __PAGE_POOL_H__
 
-#include "common.h"
+struct pending_tx_info {
+	struct xen_netif_tx_request req;
+};
+typedef unsigned int pending_ring_idx_t;
 
 typedef uint32_t idx_t;
 
@@ -38,8 +41,8 @@ struct page_pool_entry {
 	struct page *page;
 	struct pending_tx_info tx_info;
 	union {
-		struct xen_netbk *netbk;
-		idx_t             fl;
+		struct xenvif *vif;
+		idx_t          fl;
 	} u;
 };
 
@@ -52,12 +55,12 @@ int  page_pool_init(void);
 void page_pool_destroy(void);
 
 
-struct page *page_pool_get(struct xen_netbk *netbk, int *pidx);
+struct page *page_pool_get(struct xenvif *vif, int *pidx);
 void         page_pool_put(int idx);
 int          is_in_pool(struct page *page, int *pidx);
 
 struct page            *to_page(int idx);
-struct xen_netbk       *to_netbk(int idx);
+struct xenvif          *to_vif(int idx);
 struct pending_tx_info *to_txinfo(int idx);
 
 #endif /* __PAGE_POOL_H__ */
-- 
1.7.2.5
