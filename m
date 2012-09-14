From: Andres Lagar-Cavilla <andres@lagarcavilla.org>
Subject: [PATCH] Xen backend support for paged out grant targets V4.
Date: Fri, 14 Sep 2012 10:26:59 -0400
Message-ID: <1347632819-13684-1-git-send-email-andres@lagarcavilla.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andres Lagar-Cavilla <andres@lagarcavilla.org>
To: xen-devel@xen.lists.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since Xen-4.2, hvm domains may have portions of their memory paged out. When a
foreign domain (such as dom0) attempts to map these frames, the map will
initially fail. The hypervisor returns a suitable errno, and kicks an
asynchronous page-in operation carried out by a helper. The foreign domain is
expected to retry the mapping operation until it eventually succeeds. The
foreign domain is not put to sleep because itself could be the one running the
pager assist (typical scenario for dom0).

This patch adds support for this mechanism for backend drivers using grant
mapping and copying operations. Specifically, this covers the blkback and
gntdev drivers (which map foregin grants), and the netback driver (which copies
foreign grants).

* Add a retry method for grants that fail with GNTST_eagain (i.e. because the
  target foregin frame is paged out).
* Insert hooks with appropriate wrappers in the aforementioned drivers.

The retry loop is only invoked if the grant operation status is GNTST_eagain.
It guarantees to leave a new status code different from GNTST_eagain. Any other
status code results in identical code execution as before.

The retry loop performs 256 attempts with increasing time intervals through a
32 second period. It uses msleep to yield while waiting for the next retry.

V2 after feedback from David Vrabel:
* Explicit MAX_DELAY instead of wrap-around delay into zero
* Abstract GNTST_eagain check into core grant table code for netback module.

V3 after feedback from Ian Campbell:
* Add placeholder in array of grant table error descriptions for unrelated
  error code we jump over.
* Eliminate single map and retry macro in favor of a generic batch flavor.
* Some renaming.
* Bury most implementation in grant_table.c, cleaner interface.

V4 rebased on top of sync of Xen grant table interface headers.

Signed-off-by: Andres Lagar-Cavilla <andres@lagarcavilla.org>
---
 drivers/net/xen-netback/netback.c  |   11 ++------
 drivers/xen/grant-table.c          |   53 ++++++++++++++++++++++++++++++++++++
 drivers/xen/xenbus/xenbus_client.c |    6 ++--
 include/xen/grant_table.h          |   12 ++++++++
 4 files changed, 70 insertions(+), 12 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 682633b..05593d8 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -635,9 +635,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 		return;
 
 	BUG_ON(npo.copy_prod > ARRAY_SIZE(netbk->grant_copy_op));
-	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, &netbk->grant_copy_op,
-					npo.copy_prod);
-	BUG_ON(ret != 0);
+	gnttab_batch_copy(netbk->grant_copy_op, npo.copy_prod);
 
 	while ((skb = __skb_dequeue(&rxq)) != NULL) {
 		sco = (struct skb_cb_overlay *)skb->cb;
@@ -1460,18 +1458,15 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk)
 static void xen_netbk_tx_action(struct xen_netbk *netbk)
 {
 	unsigned nr_gops;
-	int ret;
 
 	nr_gops = xen_netbk_tx_build_gops(netbk);
 
 	if (nr_gops == 0)
 		return;
-	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy,
-					netbk->tx_copy_ops, nr_gops);
-	BUG_ON(ret);
 
-	xen_netbk_tx_submit(netbk);
+	gnttab_batch_copy(netbk->tx_copy_ops, nr_gops);
 
+	xen_netbk_tx_submit(netbk);
 }
 
 static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
index eea81cf..f5681c8 100644
--- a/drivers/xen/grant-table.c
+++ b/drivers/xen/grant-table.c
@@ -38,6 +38,7 @@
 #include <linux/vmalloc.h>
 #include <linux/uaccess.h>
 #include <linux/io.h>
+#include <linux/delay.h>
 #include <linux/hardirq.h>
 
 #include <xen/xen.h>
@@ -823,6 +824,52 @@ unsigned int gnttab_max_grant_frames(void)
 }
 EXPORT_SYMBOL_GPL(gnttab_max_grant_frames);
 
+/* Handling of paged out grant targets (GNTST_eagain) */
+#define MAX_DELAY 256
+static inline void
+gnttab_retry_eagain_gop(unsigned int cmd, void *gop, int16_t *status,
+						const char *func)
+{
+	unsigned delay = 1;
+
+	do {
+		BUG_ON(HYPERVISOR_grant_table_op(cmd, gop, 1));
+		if (*status == GNTST_eagain)
+			msleep(delay++);
+	} while ((*status == GNTST_eagain) && (delay < MAX_DELAY));
+
+	if (delay >= MAX_DELAY) {
+		printk(KERN_ERR "%s: %s eagain grant\n", func, current->comm);
+		*status = GNTST_bad_page;
+	}
+}
+
+void gnttab_batch_map(struct gnttab_map_grant_ref *batch, unsigned count)
+{
+	struct gnttab_map_grant_ref *op;
+
+	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, batch, count))
+		BUG();
+	for (op = batch; op < batch + count; op++)
+		if (op->status == GNTST_eagain)
+			gnttab_retry_eagain_gop(GNTTABOP_map_grant_ref, op,
+									&op->status, __func__);
+}
+EXPORT_SYMBOL_GPL(gnttab_batch_map);
+
+void gnttab_batch_copy(struct gnttab_copy *batch, unsigned count)
+{
+	struct gnttab_copy *op;
+
+	if (HYPERVISOR_grant_table_op(GNTTABOP_copy, batch, count))
+		BUG();
+	for (op = batch; op < batch + count; op++)
+		if (op->status == GNTST_eagain)
+			gnttab_retry_eagain_gop(GNTTABOP_copy, op, &op->status,
+									__func__);
+}
+EXPORT_SYMBOL_GPL(gnttab_batch_copy);
+
 int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
 		    struct gnttab_map_grant_ref *kmap_ops,
 		    struct page **pages, unsigned int count)
@@ -836,6 +883,12 @@ int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
 	if (ret)
 		return ret;
 
+	/* Retry eagain maps */
+	for (i = 0; i < count; i++)
+		if (map_ops[i].status == GNTST_eagain)
+			gnttab_retry_eagain_gop(GNTTABOP_map_grant_ref, map_ops + i,
+                                    &map_ops[i].status, __func__);
+
 	if (xen_feature(XENFEAT_auto_translated_physmap))
 		return ret;
 
diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenbus_client.c
index b3e146e..bcf3ba4 100644
--- a/drivers/xen/xenbus/xenbus_client.c
+++ b/drivers/xen/xenbus/xenbus_client.c
@@ -490,8 +490,7 @@ static int xenbus_map_ring_valloc_pv(struct xenbus_device *dev,
 
 	op.host_addr = arbitrary_virt_to_machine(pte).maddr;
 
-	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
-		BUG();
+	gnttab_batch_map(&op, 1);
 
 	if (op.status != GNTST_okay) {
 		free_vm_area(area);
@@ -572,8 +571,7 @@ int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref,
 	gnttab_set_map_op(&op, (unsigned long)vaddr, GNTMAP_host_map, gnt_ref,
 			  dev->otherend_id);
 
-	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
-		BUG();
+	gnttab_batch_map(&op, 1);
 
 	if (op.status != GNTST_okay) {
 		xenbus_dev_fatal(dev, op.status,
diff --git a/include/xen/grant_table.h b/include/xen/grant_table.h
index 11e27c3..da9386e 100644
--- a/include/xen/grant_table.h
+++ b/include/xen/grant_table.h
@@ -189,4 +189,16 @@ int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
 int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
 		      struct page **pages, unsigned int count, bool clear_pte);
 
+/* Perform a batch of grant map/copy operations. Retry every batch slot
+ * for which the hypervisor returns GNTST_eagain. This is typically due 
+ * to paged out target frames.
+ *
+ * Will retry for 1, 2, ... 255 ms, i.e. 256 times during 32 seconds.
+ *
+ * Return value in each iand every status field of the batch guaranteed
+ * to not be GNTST_eagain. 
+ */
+void gnttab_batch_map(struct gnttab_map_grant_ref *batch, unsigned count);
+void gnttab_batch_copy(struct gnttab_copy *batch, unsigned count);
+
 #endif /* __ASM_GNTTAB_H__ */
-- 
1.7.9.5
