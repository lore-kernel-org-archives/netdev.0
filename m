From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3 01/16] netback: page pool version 1
Date: Mon, 30 Jan 2012 14:45:19 +0000
Message-ID: <1327934734-8908-2-git-send-email-wei.liu2@citrix.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, ian.campbell@citrix.com,
	konrad.wilk@oracle.com
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

A global page pool. Since we are moving to 1:1 model netback, it is
better to limit total RAM consumed by all the vifs.

With this patch, each vif gets page from the pool and puts the page
back when it is finished with the page.

This pool is only meant to access via exported interfaces. Internals
are subject to change when we discover new requirements for the pool.

Current exported interfaces include:

page_pool_init: pool init
page_pool_destroy: pool destruction
page_pool_get: get a page from pool
page_pool_put: put page back to pool
is_in_pool: tell whether a page belongs to the pool

Current implementation has following defects:
 - Global locking
 - No starve prevention mechanism / reservation logic

Global locking tends to cause contention on the pool. No reservation
logic may cause vif to starve. A possible solution to these two
problems will be each vif maintains its local cache and claims a
portion of the pool. However the implementation will be tricky when
coming to pool management, so let's worry about that later.

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/Makefile    |    2 +-
 drivers/net/xen-netback/common.h    |    6 +
 drivers/net/xen-netback/netback.c   |  158 ++++++++++++------------------
 drivers/net/xen-netback/page_pool.c |  185 +++++++++++++++++++++++++++++++++++
 drivers/net/xen-netback/page_pool.h |   63 ++++++++++++
 5 files changed, 317 insertions(+), 97 deletions(-)
 create mode 100644 drivers/net/xen-netback/page_pool.c
 create mode 100644 drivers/net/xen-netback/page_pool.h

diff --git a/drivers/net/xen-netback/Makefile b/drivers/net/xen-netback/Makefile
index e346e81..dc4b8b1 100644
--- a/drivers/net/xen-netback/Makefile
+++ b/drivers/net/xen-netback/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_XEN_NETDEV_BACKEND) := xen-netback.o
 
-xen-netback-y := netback.o xenbus.o interface.o
+xen-netback-y := netback.o xenbus.o interface.o page_pool.o
diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 94b79c3..288b2f3 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -45,6 +45,12 @@
 #include <xen/grant_table.h>
 #include <xen/xenbus.h>
 
+struct pending_tx_info {
+	struct xen_netif_tx_request req;
+	struct xenvif *vif;
+};
+typedef unsigned int pending_ring_idx_t;
+
 struct xen_netbk;
 
 struct xenvif {
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 59effac..d11205f 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -33,6 +33,7 @@
  */
 
 #include "common.h"
+#include "page_pool.h"
 
 #include <linux/kthread.h>
 #include <linux/if_vlan.h>
@@ -46,12 +47,6 @@
 #include <asm/xen/hypercall.h>
 #include <asm/xen/page.h>
 
-struct pending_tx_info {
-	struct xen_netif_tx_request req;
-	struct xenvif *vif;
-};
-typedef unsigned int pending_ring_idx_t;
-
 struct netbk_rx_meta {
 	int id;
 	int size;
@@ -65,21 +60,6 @@ struct netbk_rx_meta {
 
 #define MAX_BUFFER_OFFSET PAGE_SIZE
 
-/* extra field used in struct page */
-union page_ext {
-	struct {
-#if BITS_PER_LONG < 64
-#define IDX_WIDTH   8
-#define GROUP_WIDTH (BITS_PER_LONG - IDX_WIDTH)
-		unsigned int group:GROUP_WIDTH;
-		unsigned int idx:IDX_WIDTH;
-#else
-		unsigned int group, idx;
-#endif
-	} e;
-	void *mapping;
-};
-
 struct xen_netbk {
 	wait_queue_head_t wq;
 	struct task_struct *task;
@@ -89,7 +69,7 @@ struct xen_netbk {
 
 	struct timer_list net_timer;
 
-	struct page *mmap_pages[MAX_PENDING_REQS];
+	idx_t mmap_pages[MAX_PENDING_REQS];
 
 	pending_ring_idx_t pending_prod;
 	pending_ring_idx_t pending_cons;
@@ -100,7 +80,6 @@ struct xen_netbk {
 
 	atomic_t netfront_count;
 
-	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
 	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
 
 	u16 pending_ring[MAX_PENDING_REQS];
@@ -160,7 +139,7 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 static inline unsigned long idx_to_pfn(struct xen_netbk *netbk,
 				       u16 idx)
 {
-	return page_to_pfn(netbk->mmap_pages[idx]);
+	return page_to_pfn(to_page(netbk->mmap_pages[idx]));
 }
 
 static inline unsigned long idx_to_kaddr(struct xen_netbk *netbk,
@@ -169,45 +148,6 @@ static inline unsigned long idx_to_kaddr(struct xen_netbk *netbk,
 	return (unsigned long)pfn_to_kaddr(idx_to_pfn(netbk, idx));
 }
 
-/* extra field used in struct page */
-static inline void set_page_ext(struct page *pg, struct xen_netbk *netbk,
-				unsigned int idx)
-{
-	unsigned int group = netbk - xen_netbk;
-	union page_ext ext = { .e = { .group = group + 1, .idx = idx } };
-
-	BUILD_BUG_ON(sizeof(ext) > sizeof(ext.mapping));
-	pg->mapping = ext.mapping;
-}
-
-static int get_page_ext(struct page *pg,
-			unsigned int *pgroup, unsigned int *pidx)
-{
-	union page_ext ext = { .mapping = pg->mapping };
-	struct xen_netbk *netbk;
-	unsigned int group, idx;
-
-	group = ext.e.group - 1;
-
-	if (group < 0 || group >= xen_netbk_group_nr)
-		return 0;
-
-	netbk = &xen_netbk[group];
-
-	idx = ext.e.idx;
-
-	if ((idx < 0) || (idx >= MAX_PENDING_REQS))
-		return 0;
-
-	if (netbk->mmap_pages[idx] != pg)
-		return 0;
-
-	*pgroup = group;
-	*pidx = idx;
-
-	return 1;
-}
-
 /*
  * This is the amount of packet we copy rather than map, so that the
  * guest can't fiddle with the contents of the headers while we do
@@ -398,8 +338,8 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 	 * These variables are used iff get_page_ext returns true,
 	 * in which case they are guaranteed to be initialized.
 	 */
-	unsigned int uninitialized_var(group), uninitialized_var(idx);
-	int foreign = get_page_ext(page, &group, &idx);
+	unsigned int uninitialized_var(idx);
+	int foreign = is_in_pool(page, &idx);
 	unsigned long bytes;
 
 	/* Data must not cross a page boundary. */
@@ -427,10 +367,7 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		copy_gop = npo->copy + npo->copy_prod++;
 		copy_gop->flags = GNTCOPY_dest_gref;
 		if (foreign) {
-			struct xen_netbk *netbk = &xen_netbk[group];
-			struct pending_tx_info *src_pend;
-
-			src_pend = &netbk->pending_tx_info[idx];
+			struct pending_tx_info *src_pend = to_txinfo(idx);
 
 			copy_gop->source.domid = src_pend->vif->domid;
 			copy_gop->source.u.ref = src_pend->req.gref;
@@ -906,11 +843,11 @@ static struct page *xen_netbk_alloc_page(struct xen_netbk *netbk,
 					 u16 pending_idx)
 {
 	struct page *page;
-	page = alloc_page(GFP_KERNEL|__GFP_COLD);
+	int idx;
+	page = page_pool_get(netbk, &idx);
 	if (!page)
 		return NULL;
-	set_page_ext(page, netbk, pending_idx);
-	netbk->mmap_pages[pending_idx] = page;
+	netbk->mmap_pages[pending_idx] = idx;
 	return page;
 }
 
@@ -931,8 +868,8 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 	for (i = start; i < shinfo->nr_frags; i++, txp++) {
 		struct page *page;
 		pending_ring_idx_t index;
-		struct pending_tx_info *pending_tx_info =
-			netbk->pending_tx_info;
+		int idx;
+		struct pending_tx_info *pending_tx_info;
 
 		index = pending_index(netbk->pending_cons++);
 		pending_idx = netbk->pending_ring[index];
@@ -940,6 +877,9 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 		if (!page)
 			return NULL;
 
+		idx = netbk->mmap_pages[pending_idx];
+		pending_tx_info = to_txinfo(idx);
+
 		gop->source.u.ref = txp->gref;
 		gop->source.domid = vif->domid;
 		gop->source.offset = txp->offset;
@@ -953,9 +893,9 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 
 		gop++;
 
-		memcpy(&pending_tx_info[pending_idx].req, txp, sizeof(*txp));
+		memcpy(&pending_tx_info->req, txp, sizeof(*txp));
 		xenvif_get(vif);
-		pending_tx_info[pending_idx].vif = vif;
+		pending_tx_info->vif = vif;
 		frag_set_pending_idx(&frags[i], pending_idx);
 	}
 
@@ -968,8 +908,9 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 {
 	struct gnttab_copy *gop = *gopp;
 	u16 pending_idx = *((u16 *)skb->data);
-	struct pending_tx_info *pending_tx_info = netbk->pending_tx_info;
-	struct xenvif *vif = pending_tx_info[pending_idx].vif;
+	struct pending_tx_info *pending_tx_info;
+	int idx;
+	struct xenvif *vif = NULL;
 	struct xen_netif_tx_request *txp;
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	int nr_frags = shinfo->nr_frags;
@@ -980,7 +921,10 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 	if (unlikely(err)) {
 		pending_ring_idx_t index;
 		index = pending_index(netbk->pending_prod++);
-		txp = &pending_tx_info[pending_idx].req;
+		idx = netbk->mmap_pages[index];
+		pending_tx_info = to_txinfo(idx);
+		txp = &pending_tx_info->req;
+		vif = pending_tx_info->vif;
 		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
 		netbk->pending_ring[index] = pending_idx;
 		xenvif_put(vif);
@@ -1005,7 +949,9 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 		}
 
 		/* Error on this fragment: respond to client with an error. */
-		txp = &netbk->pending_tx_info[pending_idx].req;
+		idx = netbk->mmap_pages[pending_idx];
+		txp = &to_txinfo(idx)->req;
+		vif = to_txinfo(idx)->vif;
 		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
 		index = pending_index(netbk->pending_prod++);
 		netbk->pending_ring[index] = pending_idx;
@@ -1042,10 +988,15 @@ static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
 		struct xen_netif_tx_request *txp;
 		struct page *page;
 		u16 pending_idx;
+		int idx;
+		struct pending_tx_info *pending_tx_info;
 
 		pending_idx = frag_get_pending_idx(frag);
 
-		txp = &netbk->pending_tx_info[pending_idx].req;
+		idx = netbk->mmap_pages[pending_idx];
+		pending_tx_info = to_txinfo(idx);
+
+		txp = &pending_tx_info->req;
 		page = virt_to_page(idx_to_kaddr(netbk, pending_idx));
 		__skb_fill_page_desc(skb, i, page, txp->offset, txp->size);
 		skb->len += txp->size;
@@ -1053,7 +1004,7 @@ static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
 		skb->truesize += txp->size;
 
 		/* Take an extra reference to offset xen_netbk_idx_release */
-		get_page(netbk->mmap_pages[pending_idx]);
+		get_page(page);
 		xen_netbk_idx_release(netbk, pending_idx);
 	}
 }
@@ -1233,6 +1184,8 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		int work_to_do;
 		unsigned int data_len;
 		pending_ring_idx_t index;
+		int pool_idx;
+		struct pending_tx_info *pending_tx_info;
 
 		/* Get a netif from the list with work to do. */
 		vif = poll_net_schedule_list(netbk);
@@ -1347,9 +1300,12 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 
 		gop++;
 
-		memcpy(&netbk->pending_tx_info[pending_idx].req,
+		pool_idx = netbk->mmap_pages[pending_idx];
+		pending_tx_info = to_txinfo(pool_idx);
+
+		memcpy(&pending_tx_info->req,
 		       &txreq, sizeof(txreq));
-		netbk->pending_tx_info[pending_idx].vif = vif;
+		pending_tx_info->vif = vif;
 		*((u16 *)skb->data) = pending_idx;
 
 		__skb_put(skb, data_len);
@@ -1397,10 +1353,16 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk)
 		struct xenvif *vif;
 		u16 pending_idx;
 		unsigned data_len;
+		int idx;
+		struct pending_tx_info *pending_tx_info;
 
 		pending_idx = *((u16 *)skb->data);
-		vif = netbk->pending_tx_info[pending_idx].vif;
-		txp = &netbk->pending_tx_info[pending_idx].req;
+
+		idx = netbk->mmap_pages[pending_idx];
+		pending_tx_info = to_txinfo(idx);
+
+		vif = pending_tx_info->vif;
+		txp = &pending_tx_info->req;
 
 		/* Check the remap error code. */
 		if (unlikely(xen_netbk_tx_check_gop(netbk, skb, &gop))) {
@@ -1480,12 +1442,14 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
 	struct xenvif *vif;
 	struct pending_tx_info *pending_tx_info;
 	pending_ring_idx_t index;
+	int idx;
 
 	/* Already complete? */
-	if (netbk->mmap_pages[pending_idx] == NULL)
+	if (netbk->mmap_pages[pending_idx] == INVALID_ENTRY)
 		return;
 
-	pending_tx_info = &netbk->pending_tx_info[pending_idx];
+	idx = netbk->mmap_pages[pending_idx];
+	pending_tx_info = to_txinfo(idx);
 
 	vif = pending_tx_info->vif;
 
@@ -1496,9 +1460,9 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
 
 	xenvif_put(vif);
 
-	netbk->mmap_pages[pending_idx]->mapping = 0;
-	put_page(netbk->mmap_pages[pending_idx]);
-	netbk->mmap_pages[pending_idx] = NULL;
+	page_pool_put(netbk->mmap_pages[pending_idx]);
+
+	netbk->mmap_pages[pending_idx] = INVALID_ENTRY;
 }
 
 static void make_tx_response(struct xenvif *vif,
@@ -1681,19 +1645,21 @@ static int __init netback_init(void)
 		wake_up_process(netbk->task);
 	}
 
-	rc = xenvif_xenbus_init();
+	rc = page_pool_init();
 	if (rc)
 		goto failed_init;
 
+	rc = xenvif_xenbus_init();
+	if (rc)
+		goto pool_failed_init;
+
 	return 0;
 
+pool_failed_init:
+	page_pool_destroy();
 failed_init:
 	while (--group >= 0) {
 		struct xen_netbk *netbk = &xen_netbk[group];
-		for (i = 0; i < MAX_PENDING_REQS; i++) {
-			if (netbk->mmap_pages[i])
-				__free_page(netbk->mmap_pages[i]);
-		}
 		del_timer(&netbk->net_timer);
 		kthread_stop(netbk->task);
 	}
diff --git a/drivers/net/xen-netback/page_pool.c b/drivers/net/xen-netback/page_pool.c
new file mode 100644
index 0000000..294f48b
--- /dev/null
+++ b/drivers/net/xen-netback/page_pool.c
@@ -0,0 +1,185 @@
+/*
+ * Global page pool for netback.
+ *
+ * Wei Liu <wei.liu2@citrix.com>
+ * Copyright (c) Citrix Systems
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#include "common.h"
+#include "page_pool.h"
+#include <asm/xen/page.h>
+
+static idx_t free_head;
+static int free_count;
+static unsigned long pool_size;
+static DEFINE_SPINLOCK(pool_lock);
+static struct page_pool_entry *pool;
+
+static int get_free_entry(void)
+{
+	int idx;
+
+	spin_lock(&pool_lock);
+
+	if (free_count == 0) {
+		spin_unlock(&pool_lock);
+		return -ENOSPC;
+	}
+
+	idx = free_head;
+	free_count--;
+	free_head = pool[idx].u.fl;
+	pool[idx].u.fl = INVALID_ENTRY;
+
+	spin_unlock(&pool_lock);
+
+	return idx;
+}
+
+static void put_free_entry(idx_t idx)
+{
+	spin_lock(&pool_lock);
+
+	pool[idx].u.fl = free_head;
+	free_head = idx;
+	free_count++;
+
+	spin_unlock(&pool_lock);
+}
+
+static inline void set_page_ext(struct page *pg, unsigned int idx)
+{
+	union page_ext ext = { .idx = idx };
+
+	BUILD_BUG_ON(sizeof(ext) > sizeof(ext.mapping));
+	pg->mapping = ext.mapping;
+}
+
+static int get_page_ext(struct page *pg, unsigned int *pidx)
+{
+	union page_ext ext = { .mapping = pg->mapping };
+	int idx;
+
+	idx = ext.idx;
+
+	if ((idx < 0) || (idx >= pool_size))
+		return 0;
+
+	if (pool[idx].page != pg)
+		return 0;
+
+	*pidx = idx;
+
+	return 1;
+}
+
+int is_in_pool(struct page *page, int *pidx)
+{
+	return get_page_ext(page, pidx);
+}
+
+struct page *page_pool_get(struct xen_netbk *netbk, int *pidx)
+{
+	int idx;
+	struct page *page;
+
+	idx = get_free_entry();
+	if (idx < 0)
+		return NULL;
+	page = alloc_page(GFP_ATOMIC);
+
+	if (page == NULL) {
+		put_free_entry(idx);
+		return NULL;
+	}
+
+	set_page_ext(page, idx);
+	pool[idx].u.netbk = netbk;
+	pool[idx].page = page;
+
+	*pidx = idx;
+
+	return page;
+}
+
+void page_pool_put(int idx)
+{
+	struct page *page = pool[idx].page;
+
+	pool[idx].page = NULL;
+	pool[idx].u.netbk = NULL;
+	page->mapping = 0;
+	put_page(page);
+	put_free_entry(idx);
+}
+
+int page_pool_init()
+{
+	int cpus = 0;
+	int i;
+
+	cpus = num_online_cpus();
+	pool_size = cpus * ENTRIES_PER_CPU;
+
+	pool = vzalloc(sizeof(struct page_pool_entry) * pool_size);
+
+	if (!pool)
+		return -ENOMEM;
+
+	for (i = 0; i < pool_size - 1; i++)
+		pool[i].u.fl = i+1;
+	pool[pool_size-1].u.fl = INVALID_ENTRY;
+	free_count = pool_size;
+	free_head = 0;
+
+	return 0;
+}
+
+void page_pool_destroy()
+{
+	int i;
+	for (i = 0; i < pool_size; i++)
+		if (pool[i].page)
+			put_page(pool[i].page);
+
+	vfree(pool);
+}
+
+struct page *to_page(int idx)
+{
+	return pool[idx].page;
+}
+
+struct xen_netbk *to_netbk(int idx)
+{
+	return pool[idx].u.netbk;
+}
+
+struct pending_tx_info *to_txinfo(int idx)
+{
+	return &pool[idx].tx_info;
+}
diff --git a/drivers/net/xen-netback/page_pool.h b/drivers/net/xen-netback/page_pool.h
new file mode 100644
index 0000000..572b037
--- /dev/null
+++ b/drivers/net/xen-netback/page_pool.h
@@ -0,0 +1,63 @@
+/*
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef __PAGE_POOL_H__
+#define __PAGE_POOL_H__
+
+#include "common.h"
+
+typedef uint32_t idx_t;
+
+#define ENTRIES_PER_CPU (1024)
+#define INVALID_ENTRY 0xffffffff
+
+struct page_pool_entry {
+	struct page *page;
+	struct pending_tx_info tx_info;
+	union {
+		struct xen_netbk *netbk;
+		idx_t             fl;
+	} u;
+};
+
+union page_ext {
+	idx_t idx;
+	void *mapping;
+};
+
+int  page_pool_init(void);
+void page_pool_destroy(void);
+
+
+struct page *page_pool_get(struct xen_netbk *netbk, int *pidx);
+void         page_pool_put(int idx);
+int          is_in_pool(struct page *page, int *pidx);
+
+struct page            *to_page(int idx);
+struct xen_netbk       *to_netbk(int idx);
+struct pending_tx_info *to_txinfo(int idx);
+
+#endif /* __PAGE_POOL_H__ */
-- 
1.7.2.5
