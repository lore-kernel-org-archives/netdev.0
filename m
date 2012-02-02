From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V4 08/13] xenbus_client: extend interface to support mapping / unmapping of multi page ring.
Date: Thu, 2 Feb 2012 16:49:18 +0000
Message-ID: <1328201363-13915-9-git-send-email-wei.liu2@citrix.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:18042 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755523Ab2BBQtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 11:49:42 -0500
In-Reply-To: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/xen/xenbus/xenbus_client.c |  282 +++++++++++++++++++++++++-----------
 include/xen/xenbus.h               |   15 ++-
 2 files changed, 206 insertions(+), 91 deletions(-)

diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenbus_client.c
index 566d2ad..d73b9c6 100644
--- a/drivers/xen/xenbus/xenbus_client.c
+++ b/drivers/xen/xenbus/xenbus_client.c
@@ -53,14 +53,16 @@ struct xenbus_map_node {
 		struct vm_struct *area; /* PV */
 		struct page *page;     /* HVM */
 	};
-	grant_handle_t handle;
+	grant_handle_t handle[XENBUS_MAX_RING_PAGES];
+	unsigned int   nr_handles;
 };
 
 static DEFINE_SPINLOCK(xenbus_valloc_lock);
 static LIST_HEAD(xenbus_valloc_pages);
 
 struct xenbus_ring_ops {
-	int (*map)(struct xenbus_device *dev, int gnt, void **vaddr);
+	int (*map)(struct xenbus_device *dev, int gnt[], int nr_gnts,
+		   void **vaddr);
 	int (*unmap)(struct xenbus_device *dev, void *vaddr);
 };
 
@@ -356,17 +358,38 @@ static void xenbus_switch_fatal(struct xenbus_device *dev, int depth, int err,
 /**
  * xenbus_grant_ring
  * @dev: xenbus device
- * @ring_mfn: mfn of ring to grant
-
- * Grant access to the given @ring_mfn to the peer of the given device.  Return
- * 0 on success, or -errno on error.  On error, the device will switch to
- * XenbusStateClosing, and the error will be saved in the store.
+ * @vaddr: starting virtual address of the ring
+ * @nr_pages: number of page to be granted
+ * @grefs: grant reference array to be filled in
+ * Grant access to the given @vaddr to the peer of the given device.
+ * Then fill in @grefs with grant references.  Return 0 on success, or
+ * -errno on error.  On error, the device will switch to
+ * XenbusStateClosing, and the first error will be saved in the store.
  */
-int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn)
+int xenbus_grant_ring(struct xenbus_device *dev, void *vaddr,
+		      int nr_pages, int grefs[])
 {
-	int err = gnttab_grant_foreign_access(dev->otherend_id, ring_mfn, 0);
-	if (err < 0)
-		xenbus_dev_fatal(dev, err, "granting access to ring page");
+	int i;
+	int err;
+
+	for (i = 0; i < nr_pages; i++) {
+		unsigned long addr = (unsigned long)vaddr +
+			(PAGE_SIZE * i);
+		err = gnttab_grant_foreign_access(dev->otherend_id,
+						  virt_to_mfn(addr), 0);
+		if (err < 0) {
+			xenbus_dev_fatal(dev, err,
+					 "granting access to ring page");
+			goto fail;
+		}
+		grefs[i] = err;
+	}
+
+	return 0;
+
+fail:
+	for ( ; i >= 0; i--)
+		gnttab_end_foreign_access_ref(grefs[i], 0);
 	return err;
 }
 EXPORT_SYMBOL_GPL(xenbus_grant_ring);
@@ -447,7 +470,8 @@ EXPORT_SYMBOL_GPL(xenbus_free_evtchn);
 /**
  * xenbus_map_ring_valloc
  * @dev: xenbus device
- * @gnt_ref: grant reference
+ * @gnt_ref: grant reference array
+ * @nr_grefs: number of grant reference
  * @vaddr: pointer to address to be filled out by mapping
  *
  * Based on Rusty Russell's skeleton driver's map_page.
@@ -458,52 +482,74 @@ EXPORT_SYMBOL_GPL(xenbus_free_evtchn);
  * or -ENOMEM on error. If an error is returned, device will switch to
  * XenbusStateClosing and the error message will be saved in XenStore.
  */
-int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref, void **vaddr)
+int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref[],
+			   int nr_grefs, void **vaddr)
 {
-	return ring_ops->map(dev, gnt_ref, vaddr);
+	return ring_ops->map(dev, gnt_ref, nr_grefs, vaddr);
 }
 EXPORT_SYMBOL_GPL(xenbus_map_ring_valloc);
 
+static int __xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev,
+					struct xenbus_map_node *node);
+
 static int xenbus_map_ring_valloc_pv(struct xenbus_device *dev,
-				     int gnt_ref, void **vaddr)
+				     int gnt_ref[], int nr_grefs, void **vaddr)
 {
-	struct gnttab_map_grant_ref op = {
-		.flags = GNTMAP_host_map | GNTMAP_contains_pte,
-		.ref   = gnt_ref,
-		.dom   = dev->otherend_id,
-	};
+	struct gnttab_map_grant_ref op[XENBUS_MAX_RING_PAGES];
 	struct xenbus_map_node *node;
 	struct vm_struct *area;
-	pte_t *pte;
+	pte_t *pte[XENBUS_MAX_RING_PAGES];
+	int i;
+	int err = 0;
 
 	*vaddr = NULL;
 
+	if (nr_grefs > XENBUS_MAX_RING_PAGES)
+		return -EINVAL;
+
 	node = kzalloc(sizeof(*node), GFP_KERNEL);
 	if (!node)
 		return -ENOMEM;
 
-	area = alloc_vm_area(PAGE_SIZE, &pte);
+	area = alloc_vm_area(PAGE_SIZE * nr_grefs, pte);
 	if (!area) {
 		kfree(node);
 		return -ENOMEM;
 	}
 
-	op.host_addr = arbitrary_virt_to_machine(pte).maddr;
+	for (i = 0; i < nr_grefs; i++) {
+		op[i].flags = GNTMAP_host_map | GNTMAP_contains_pte,
+		op[i].ref   = gnt_ref[i],
+		op[i].dom   = dev->otherend_id,
+		op[i].host_addr = arbitrary_virt_to_machine(pte[i]).maddr;
+	};
 
-	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
+	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, op, nr_grefs))
 		BUG();
 
-	if (op.status != GNTST_okay) {
-		free_vm_area(area);
-		kfree(node);
-		xenbus_dev_fatal(dev, op.status,
+	node->nr_handles = nr_grefs;
+	node->area = area;
+
+	for (i = 0; i < nr_grefs; i++) {
+		if (op[i].status != GNTST_okay) {
+			err = op[i].status;
+			node->handle[i] = INVALID_GRANT_HANDLE;
+			continue;
+		}
+		node->handle[i] = op[i].handle;
+	}
+
+	if (err != 0) {
+		for (i = 0; i < nr_grefs; i++)
+			xenbus_dev_fatal(dev, op[i].status,
 				 "mapping in shared page %d from domain %d",
-				 gnt_ref, dev->otherend_id);
-		return op.status;
+				 gnt_ref[i], dev->otherend_id);
+
+		__xenbus_unmap_ring_vfree_pv(dev, node);
+
+		return err;
 	}
 
-	node->handle = op.handle;
-	node->area = area;
 
 	spin_lock(&xenbus_valloc_lock);
 	list_add(&node->next, &xenbus_valloc_pages);
@@ -514,28 +560,34 @@ static int xenbus_map_ring_valloc_pv(struct xenbus_device *dev,
 }
 
 static int xenbus_map_ring_valloc_hvm(struct xenbus_device *dev,
-				      int gnt_ref, void **vaddr)
+				      int gnt_ref[], int nr_grefs, void **vaddr)
 {
 	struct xenbus_map_node *node;
 	int err;
 	void *addr;
 
+	if (nr_grefs > XENBUS_MAX_RING_PAGES)
+		return -EINVAL;
+
 	*vaddr = NULL;
 
 	node = kzalloc(sizeof(*node), GFP_KERNEL);
 	if (!node)
 		return -ENOMEM;
 
-	err = alloc_xenballooned_pages(1, &node->page, false /* lowmem */);
+	err = alloc_xenballooned_pages(nr_grefs, &node->page,
+				       false /* lowmem */);
 	if (err)
 		goto out_err;
 
 	addr = pfn_to_kaddr(page_to_pfn(node->page));
 
-	err = xenbus_map_ring(dev, gnt_ref, &node->handle, addr);
+	err = xenbus_map_ring(dev, gnt_ref, nr_grefs, node->handle, addr);
 	if (err)
 		goto out_err;
 
+	node->nr_handles = nr_grefs;
+
 	spin_lock(&xenbus_valloc_lock);
 	list_add(&node->next, &xenbus_valloc_pages);
 	spin_unlock(&xenbus_valloc_lock);
@@ -544,7 +596,7 @@ static int xenbus_map_ring_valloc_hvm(struct xenbus_device *dev,
 	return 0;
 
  out_err:
-	free_xenballooned_pages(1, &node->page);
+	free_xenballooned_pages(nr_grefs, &node->page);
 	kfree(node);
 	return err;
 }
@@ -553,36 +605,52 @@ static int xenbus_map_ring_valloc_hvm(struct xenbus_device *dev,
 /**
  * xenbus_map_ring
  * @dev: xenbus device
- * @gnt_ref: grant reference
- * @handle: pointer to grant handle to be filled
+ * @gnt_ref: grant reference array
+ * @nr_grefs: number of grant reference
+ * @handle: pointer to grant handle array to be filled, mind the size
  * @vaddr: address to be mapped to
  *
- * Map a page of memory into this domain from another domain's grant table.
+ * Map pages of memory into this domain from another domain's grant table.
  * xenbus_map_ring does not allocate the virtual address space (you must do
- * this yourself!). It only maps in the page to the specified address.
+ * this yourself!). It only maps in the pages to the specified address.
  * Returns 0 on success, and GNTST_* (see xen/include/interface/grant_table.h)
  * or -ENOMEM on error. If an error is returned, device will switch to
- * XenbusStateClosing and the error message will be saved in XenStore.
+ * XenbusStateClosing and the last error message will be saved in XenStore.
  */
-int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref,
-		    grant_handle_t *handle, void *vaddr)
+int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref[], int nr_grefs,
+		    grant_handle_t handle[], void *vaddr)
 {
-	struct gnttab_map_grant_ref op;
-
-	gnttab_set_map_op(&op, (phys_addr_t)vaddr, GNTMAP_host_map, gnt_ref,
-			  dev->otherend_id);
+	struct gnttab_map_grant_ref op[XENBUS_MAX_RING_PAGES];
+	int i;
+	int err = GNTST_okay;	/* 0 */
+
+	for (i = 0; i < nr_grefs; i++) {
+		unsigned long addr = (unsigned long)vaddr +
+			(PAGE_SIZE * i);
+		gnttab_set_map_op(&op[i], (phys_addr_t)addr,
+				  GNTMAP_host_map, gnt_ref[i],
+				  dev->otherend_id);
+	}
 
-	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
+	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, op, nr_grefs))
 		BUG();
 
-	if (op.status != GNTST_okay) {
-		xenbus_dev_fatal(dev, op.status,
+
+	for (i = 0; i < nr_grefs; i++) {
+		if (op[i].status != GNTST_okay) {
+			err = op[i].status;
+			xenbus_dev_fatal(dev, err,
 				 "mapping in shared page %d from domain %d",
-				 gnt_ref, dev->otherend_id);
-	} else
-		*handle = op.handle;
+				 gnt_ref[i], dev->otherend_id);
+			handle[i] = INVALID_GRANT_HANDLE;
+		} else
+			handle[i] = op[i].handle;
+	}
+
+	if (err != GNTST_okay)
+		xenbus_unmap_ring(dev, handle, nr_grefs, vaddr);
 
-	return op.status;
+	return err;
 }
 EXPORT_SYMBOL_GPL(xenbus_map_ring);
 
@@ -605,13 +673,53 @@ int xenbus_unmap_ring_vfree(struct xenbus_device *dev, void *vaddr)
 }
 EXPORT_SYMBOL_GPL(xenbus_unmap_ring_vfree);
 
+static int __xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev,
+					struct xenbus_map_node *node)
+{
+	struct gnttab_unmap_grant_ref op[XENBUS_MAX_RING_PAGES];
+	unsigned int level;
+	int i, j;
+	int err = GNTST_okay;
+
+	j = 0;
+	for (i = 0; i < node->nr_handles; i++) {
+		unsigned long vaddr = (unsigned long)node->area->addr +
+			(PAGE_SIZE * i);
+		if (node->handle[i] != INVALID_GRANT_HANDLE) {
+			memset(&op[j], 0, sizeof(op[0]));
+			op[j].host_addr = arbitrary_virt_to_machine(
+				lookup_address(vaddr, &level)).maddr;
+			op[j].handle = node->handle[i];
+			j++;
+			node->handle[i] = INVALID_GRANT_HANDLE;
+		}
+	}
+
+	if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, op, j))
+		BUG();
+
+	node->nr_handles = 0;
+
+	for (i = 0; i < j; i++) {
+		if (op[i].status != GNTST_okay) {
+			err = op[i].status;
+			xenbus_dev_error(dev, err,
+				 "unmapping page %d at handle %d error %d",
+				 i, op[i].handle, err);
+		}
+	}
+
+	if (err == GNTST_okay)
+		free_vm_area(node->area);
+
+	kfree(node);
+
+	return err;
+}
+
 static int xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev, void *vaddr)
 {
 	struct xenbus_map_node *node;
-	struct gnttab_unmap_grant_ref op = {
-		.host_addr = (unsigned long)vaddr,
-	};
-	unsigned int level;
 
 	spin_lock(&xenbus_valloc_lock);
 	list_for_each_entry(node, &xenbus_valloc_pages, next) {
@@ -630,29 +738,14 @@ static int xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev, void *vaddr)
 		return GNTST_bad_virt_addr;
 	}
 
-	op.handle = node->handle;
-	op.host_addr = arbitrary_virt_to_machine(
-		lookup_address((unsigned long)vaddr, &level)).maddr;
-
-	if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op, 1))
-		BUG();
-
-	if (op.status == GNTST_okay)
-		free_vm_area(node->area);
-	else
-		xenbus_dev_error(dev, op.status,
-				 "unmapping page at handle %d error %d",
-				 node->handle, op.status);
-
-	kfree(node);
-	return op.status;
+	return __xenbus_unmap_ring_vfree_pv(dev, node);
 }
 
 static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)
 {
 	int rv;
 	struct xenbus_map_node *node;
-	void *addr;
+	void *addr = NULL;
 
 	spin_lock(&xenbus_valloc_lock);
 	list_for_each_entry(node, &xenbus_valloc_pages, next) {
@@ -672,10 +765,10 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)
 		return GNTST_bad_virt_addr;
 	}
 
-	rv = xenbus_unmap_ring(dev, node->handle, addr);
+	rv = xenbus_unmap_ring(dev, node->handle, node->nr_handles, addr);
 
 	if (!rv)
-		free_xenballooned_pages(1, &node->page);
+		free_xenballooned_pages(node->nr_handles, &node->page);
 	else
 		WARN(1, "Leaking %p\n", vaddr);
 
@@ -687,6 +780,7 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)
  * xenbus_unmap_ring
  * @dev: xenbus device
  * @handle: grant handle
+ * @nr_handles: number of grant handle
  * @vaddr: addr to unmap
  *
  * Unmap a page of memory in this domain that was imported from another domain.
@@ -694,21 +788,37 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)
  * (see xen/include/interface/grant_table.h).
  */
 int xenbus_unmap_ring(struct xenbus_device *dev,
-		      grant_handle_t handle, void *vaddr)
+		      grant_handle_t handle[], int nr_handles,
+		      void *vaddr)
 {
-	struct gnttab_unmap_grant_ref op;
-
-	gnttab_set_unmap_op(&op, (phys_addr_t)vaddr, GNTMAP_host_map, handle);
+	struct gnttab_unmap_grant_ref op[XENBUS_MAX_RING_PAGES];
+	int i, j;
+	int err = GNTST_okay;
+
+	j = 0;
+	for (i = 0; i < nr_handles; i++) {
+		unsigned long addr = (unsigned long)vaddr +
+			(PAGE_SIZE * i);
+		if (handle[i] != INVALID_GRANT_HANDLE) {
+			gnttab_set_unmap_op(&op[j++], (phys_addr_t)addr,
+					    GNTMAP_host_map, handle[i]);
+			handle[i] = INVALID_GRANT_HANDLE;
+		}
+	}
 
-	if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op, 1))
+	if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, op, j))
 		BUG();
 
-	if (op.status != GNTST_okay)
-		xenbus_dev_error(dev, op.status,
+	for (i = 0; i < j; i++) {
+		if (op[i].status != GNTST_okay) {
+			err = op[i].status;
+			xenbus_dev_error(dev, err,
 				 "unmapping page at handle %d error %d",
-				 handle, op.status);
+				 handle[i], err);
+		}
+	}
 
-	return op.status;
+	return err;
 }
 EXPORT_SYMBOL_GPL(xenbus_unmap_ring);
 
diff --git a/include/xen/xenbus.h b/include/xen/xenbus.h
index e8c599b..284647f 100644
--- a/include/xen/xenbus.h
+++ b/include/xen/xenbus.h
@@ -46,6 +46,10 @@
 #include <xen/interface/io/xenbus.h>
 #include <xen/interface/io/xs_wire.h>
 
+#define XENBUS_MAX_RING_PAGE_ORDER 2
+#define XENBUS_MAX_RING_PAGES      4
+#define INVALID_GRANT_HANDLE       (~0U)
+
 /* Register callback to watch this node. */
 struct xenbus_watch
 {
@@ -195,15 +199,16 @@ int xenbus_watch_pathfmt(struct xenbus_device *dev, struct xenbus_watch *watch,
 			 const char *pathfmt, ...);
 
 int xenbus_switch_state(struct xenbus_device *dev, enum xenbus_state new_state);
-int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn);
+int xenbus_grant_ring(struct xenbus_device *dev, void *vaddr,
+		      int nr_pages, int grefs[]);
 int xenbus_map_ring_valloc(struct xenbus_device *dev,
-			   int gnt_ref, void **vaddr);
-int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref,
-			   grant_handle_t *handle, void *vaddr);
+			   int gnt_ref[], int nr_grefs, void **vaddr);
+int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref[], int nr_grefs,
+			   grant_handle_t handle[], void *vaddr);
 
 int xenbus_unmap_ring_vfree(struct xenbus_device *dev, void *vaddr);
 int xenbus_unmap_ring(struct xenbus_device *dev,
-		      grant_handle_t handle, void *vaddr);
+		      grant_handle_t handle[], int nr_handles, void *vaddr);
 
 int xenbus_alloc_evtchn(struct xenbus_device *dev, int *port);
 int xenbus_bind_evtchn(struct xenbus_device *dev, int remote_port, int *port);
-- 
1.7.2.5
