From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH 1/6] netback: page pool version 1
Date: Fri, 13 Jan 2012 16:59:04 +0000
Message-ID: <1326473949-22389-2-git-send-email-wei.liu2@citrix.com>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:6373 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260Ab2AMQ7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jan 2012 11:59:32 -0500
In-Reply-To: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/Makefile    |    2 +-
 drivers/net/xen-netback/netback.c   |   93 ++++--------------
 drivers/net/xen-netback/page_pool.c |  183 +++++++++++++++++++++++++++++++++++
 drivers/net/xen-netback/page_pool.h |   61 ++++++++++++
 4 files changed, 266 insertions(+), 73 deletions(-)
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
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 59effac..26af7b7 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -33,6 +33,7 @@
  */
 
 #include "common.h"
+#include "page_pool.h"
 
 #include <linux/kthread.h>
 #include <linux/if_vlan.h>
@@ -65,21 +66,6 @@ struct netbk_rx_meta {
 
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
@@ -89,7 +75,7 @@ struct xen_netbk {
 
 	struct timer_list net_timer;
 
-	struct page *mmap_pages[MAX_PENDING_REQS];
+	idx_t mmap_pages[MAX_PENDING_REQS];
 
 	pending_ring_idx_t pending_prod;
 	pending_ring_idx_t pending_cons;
@@ -160,7 +146,7 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 static inline unsigned long idx_to_pfn(struct xen_netbk *netbk,
 				       u16 idx)
 {
-	return page_to_pfn(netbk->mmap_pages[idx]);
+	return page_to_pfn(to_page(netbk->mmap_pages[idx]));
 }
 
 static inline unsigned long idx_to_kaddr(struct xen_netbk *netbk,
@@ -169,45 +155,6 @@ static inline unsigned long idx_to_kaddr(struct xen_netbk *netbk,
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
@@ -398,8 +345,8 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 	 * These variables are used iff get_page_ext returns true,
 	 * in which case they are guaranteed to be initialized.
 	 */
-	unsigned int uninitialized_var(group), uninitialized_var(idx);
-	int foreign = get_page_ext(page, &group, &idx);
+	unsigned int uninitialized_var(idx);
+	int foreign = is_in_pool(page, &idx);
 	unsigned long bytes;
 
 	/* Data must not cross a page boundary. */
@@ -427,7 +374,7 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		copy_gop = npo->copy + npo->copy_prod++;
 		copy_gop->flags = GNTCOPY_dest_gref;
 		if (foreign) {
-			struct xen_netbk *netbk = &xen_netbk[group];
+			struct xen_netbk *netbk = to_netbk(idx);
 			struct pending_tx_info *src_pend;
 
 			src_pend = &netbk->pending_tx_info[idx];
@@ -906,11 +853,11 @@ static struct page *xen_netbk_alloc_page(struct xen_netbk *netbk,
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
 
@@ -1053,7 +1000,7 @@ static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
 		skb->truesize += txp->size;
 
 		/* Take an extra reference to offset xen_netbk_idx_release */
-		get_page(netbk->mmap_pages[pending_idx]);
+		get_page(to_page(netbk->mmap_pages[pending_idx]));
 		xen_netbk_idx_release(netbk, pending_idx);
 	}
 }
@@ -1482,7 +1429,7 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
 	pending_ring_idx_t index;
 
 	/* Already complete? */
-	if (netbk->mmap_pages[pending_idx] == NULL)
+	if (netbk->mmap_pages[pending_idx] == INVALID_ENTRY)
 		return;
 
 	pending_tx_info = &netbk->pending_tx_info[pending_idx];
@@ -1496,9 +1443,9 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
 
 	xenvif_put(vif);
 
-	netbk->mmap_pages[pending_idx]->mapping = 0;
-	put_page(netbk->mmap_pages[pending_idx]);
-	netbk->mmap_pages[pending_idx] = NULL;
+	page_pool_put(netbk->mmap_pages[pending_idx]);
+
+	netbk->mmap_pages[pending_idx] = INVALID_ENTRY;
 }
 
 static void make_tx_response(struct xenvif *vif,
@@ -1681,19 +1628,21 @@ static int __init netback_init(void)
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
index 0000000..8904869
--- /dev/null
+++ b/drivers/net/xen-netback/page_pool.c
@@ -0,0 +1,183 @@
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
+	unsigned long flag;
+	int idx;
+
+	spin_lock_irqsave(&pool_lock, flag);
+
+	if (free_count == 0) {
+		spin_unlock_irqrestore(&pool_lock, flag);
+		return -ENOSPC;
+	}
+
+	idx = free_head;
+	free_count--;
+	free_head = pool[idx].u.fl;
+	pool[idx].u.fl = INVALID_ENTRY;
+
+	spin_unlock_irqrestore(&pool_lock, flag);
+
+	return idx;
+}
+
+static void put_free_entry(idx_t idx)
+{
+	unsigned long flag;
+
+	spin_lock_irqsave(&pool_lock, flag);
+
+	pool[idx].u.fl = free_head;
+	free_head = idx;
+	free_count++;
+
+	spin_unlock_irqrestore(&pool_lock, flag);
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
diff --git a/drivers/net/xen-netback/page_pool.h b/drivers/net/xen-netback/page_pool.h
new file mode 100644
index 0000000..52a6fc7
--- /dev/null
+++ b/drivers/net/xen-netback/page_pool.h
@@ -0,0 +1,61 @@
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
+struct page      *to_page(int idx);
+struct xen_netbk *to_netbk(int idx);
+
+#endif /* __PAGE_POOL_H__ */
-- 
1.7.2.5
