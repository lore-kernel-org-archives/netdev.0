From: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC PATCH 1/2] dmaengine: add base support for the async_tx api
Date: Fri, 01 Jun 2007 17:17:54 -0700
Message-ID: <20070602001754.1707.7808.stgit@dwillia2-linux.ch.intel.com>
References: <20070602001527.1707.58092.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	christopher.leech@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28855 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758189AbXFBARz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 20:17:55 -0400
In-Reply-To: <20070602001527.1707.58092.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for the async_tx (dmaengine client) API this patch:
1/ introduces struct dma_async_tx_descriptor as a common field for all
   dmaengine software descriptors.  The primary role of this structure
   is to enable callbacks at transaction completion time, and support
   transaction chains that span multiple channels
2/ converts the device_memcpy_* methods into separate prep, set
   src/dest, and submit stages
3/ adds support for capabilities beyond memcpy (xor, memset, xor zero
   sum, completion interrupts).  place holders for future capabilities
   are also included
4/ converts ioatdma to the new semantics

Changelog:
* drop dma mapping methods, suggested by Chris Leech
* fix ioat_dma_dependency_added, also caught by Andrew Morton
* fix dma_sync_wait, change from Andrew Morton
* uninline large functions, change from Andrew Morton
* add tx->callback = NULL to dmaengine calls to interoperate with async_tx
  calls
* hookup ioat_tx_submit
* convert channel capabilities to a 'cpumask_t like' bitmap

Cc: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 drivers/dma/dmaengine.c   |  182 +++++++++++++++++++++++++++++++++
 drivers/dma/ioatdma.c     |  248 ++++++++++++++++++++-------------------------
 drivers/dma/ioatdma.h     |    8 +
 include/linux/dmaengine.h |  245 ++++++++++++++++++++++++++++----------------
 4 files changed, 454 insertions(+), 229 deletions(-)

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 322ee29..8a49103 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -59,6 +59,7 @@
 
 #include <linux/init.h>
 #include <linux/module.h>
+#include <linux/mm.h>
 #include <linux/device.h>
 #include <linux/dmaengine.h>
 #include <linux/hardirq.h>
@@ -66,6 +67,7 @@
 #include <linux/percpu.h>
 #include <linux/rcupdate.h>
 #include <linux/mutex.h>
+#include <linux/jiffies.h>
 
 static DEFINE_MUTEX(dma_list_mutex);
 static LIST_HEAD(dma_device_list);
@@ -165,6 +167,24 @@ static struct dma_chan *dma_client_chan_alloc(struct dma_client *client)
 	return NULL;
 }
 
+enum dma_status dma_sync_wait(struct dma_chan *chan, dma_cookie_t cookie)
+{
+	enum dma_status status;
+	unsigned long dma_sync_wait_timeout = jiffies + msecs_to_jiffies(5000);
+
+	dma_async_issue_pending(chan);
+	do {
+		status = dma_async_is_tx_complete(chan, cookie, NULL, NULL);
+		if (time_after_eq(jiffies, dma_sync_wait_timeout)) {
+			printk(KERN_ERR "dma_sync_wait_timeout!\n");
+			return DMA_ERROR;
+		}
+	} while (status == DMA_IN_PROGRESS);
+
+	return status;
+}
+EXPORT_SYMBOL(dma_sync_wait);
+
 /**
  * dma_chan_cleanup - release a DMA channel's resources
  * @kref: kernel reference structure that contains the DMA channel device
@@ -322,6 +342,28 @@ int dma_async_device_register(struct dma_device *device)
 	if (!device)
 		return -ENODEV;
 
+	/* validate device routines */
+	BUG_ON(dma_has_cap(DMA_MEMCPY, device->cap_mask) &&
+		!device->device_prep_dma_memcpy);
+	BUG_ON(dma_has_cap(DMA_XOR, device->cap_mask) &&
+		!device->device_prep_dma_xor);
+	BUG_ON(dma_has_cap(DMA_ZERO_SUM, device->cap_mask) &&
+		!device->device_prep_dma_zero_sum);
+	BUG_ON(dma_has_cap(DMA_MEMSET, device->cap_mask) &&
+		!device->device_prep_dma_memset);
+	BUG_ON(dma_has_cap(DMA_ZERO_SUM, device->cap_mask) &&
+		!device->device_prep_dma_interrupt);
+
+	BUG_ON(!device->device_alloc_chan_resources);
+	BUG_ON(!device->device_free_chan_resources);
+	BUG_ON(!device->device_tx_submit);
+	BUG_ON(!device->device_set_dest);
+	BUG_ON(!device->device_set_src);
+	BUG_ON(!device->device_dependency_added);
+	BUG_ON(!device->device_is_tx_complete);
+	BUG_ON(!device->device_issue_pending);
+	BUG_ON(!device->dev);
+
 	init_completion(&device->done);
 	kref_init(&device->refcount);
 	device->dev_id = id++;
@@ -397,6 +439,146 @@ void dma_async_device_unregister(struct dma_device *device)
 }
 EXPORT_SYMBOL(dma_async_device_unregister);
 
+/**
+ * dma_async_memcpy_buf_to_buf - offloaded copy between virtual addresses
+ * @chan: DMA channel to offload copy to
+ * @dest: destination address (virtual)
+ * @src: source address (virtual)
+ * @len: length
+ *
+ * Both @dest and @src must be mappable to a bus address according to the
+ * DMA mapping API rules for streaming mappings.
+ * Both @dest and @src must stay memory resident (kernel memory or locked
+ * user space pages).
+ */
+dma_cookie_t dma_async_memcpy_buf_to_buf(struct dma_chan *chan,
+        void *dest, void *src, size_t len)
+{
+	struct dma_device *dev = chan->device;
+	struct dma_async_tx_descriptor *tx;
+	dma_addr_t addr;
+	dma_cookie_t cookie;
+	int cpu;
+
+	tx = dev->device_prep_dma_memcpy(chan, len, 0);
+	if (!tx)
+		return -ENOMEM;
+
+	tx->ack = 1;
+	tx->callback = NULL;
+	addr = dma_map_single(dev->dev, src, len, DMA_TO_DEVICE);
+	dev->device_set_src(addr, tx, 0);
+	addr = dma_map_single(dev->dev, dest, len, DMA_FROM_DEVICE);
+	dev->device_set_dest(addr, tx, 0);
+	cookie = dev->device_tx_submit(tx);
+
+	cpu = get_cpu();
+	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
+	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
+	put_cpu();
+
+	return cookie;
+}
+EXPORT_SYMBOL(dma_async_memcpy_buf_to_buf);
+
+/**
+ * dma_async_memcpy_buf_to_pg - offloaded copy from address to page
+ * @chan: DMA channel to offload copy to
+ * @page: destination page
+ * @offset: offset in page to copy to
+ * @kdata: source address (virtual)
+ * @len: length
+ *
+ * Both @page/@offset and @kdata must be mappable to a bus address according
+ * to the DMA mapping API rules for streaming mappings.
+ * Both @page/@offset and @kdata must stay memory resident (kernel memory or
+ * locked user space pages)
+ */
+dma_cookie_t dma_async_memcpy_buf_to_pg(struct dma_chan *chan,
+        struct page *page, unsigned int offset, void *kdata, size_t len)
+{
+	struct dma_device *dev = chan->device;
+	struct dma_async_tx_descriptor *tx;
+	dma_addr_t addr;
+	dma_cookie_t cookie;
+	int cpu;
+
+	tx = dev->device_prep_dma_memcpy(chan, len, 0);
+	if (!tx)
+		return -ENOMEM;
+
+	tx->ack = 1;
+	tx->callback = NULL;
+	addr = dma_map_single(dev->dev, kdata, len, DMA_TO_DEVICE);
+	dev->device_set_src(addr, tx, 0);
+	addr = dma_map_page(dev->dev, page, offset, len, DMA_FROM_DEVICE);
+	dev->device_set_dest(addr, tx, 0);
+	cookie = dev->device_tx_submit(tx);
+
+	cpu = get_cpu();
+	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
+	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
+	put_cpu();
+
+	return cookie;
+}
+EXPORT_SYMBOL(dma_async_memcpy_buf_to_pg);
+
+/**
+ * dma_async_memcpy_pg_to_pg - offloaded copy from page to page
+ * @chan: DMA channel to offload copy to
+ * @dest_pg: destination page
+ * @dest_off: offset in page to copy to
+ * @src_pg: source page
+ * @src_off: offset in page to copy from
+ * @len: length
+ *
+ * Both @dest_page/@dest_off and @src_page/@src_off must be mappable to a bus
+ * address according to the DMA mapping API rules for streaming mappings.
+ * Both @dest_page/@dest_off and @src_page/@src_off must stay memory resident
+ * (kernel memory or locked user space pages).
+ */
+dma_cookie_t dma_async_memcpy_pg_to_pg(struct dma_chan *chan,
+        struct page *dest_pg, unsigned int dest_off, struct page *src_pg,
+        unsigned int src_off, size_t len)
+{
+	struct dma_device *dev = chan->device;
+	struct dma_async_tx_descriptor *tx;
+	dma_addr_t addr;
+	dma_cookie_t cookie;
+	int cpu;
+
+	tx = dev->device_prep_dma_memcpy(chan, len, 0);
+	if (!tx)
+		return -ENOMEM;
+
+	tx->ack = 1;
+	tx->callback = NULL;
+	addr = dma_map_page(dev->dev, src_pg, src_off, len, DMA_TO_DEVICE);
+	dev->device_set_src(addr, tx, 0);
+	addr = dma_map_page(dev->dev, dest_pg, dest_off, len, DMA_FROM_DEVICE);
+	dev->device_set_dest(addr, tx, 0);
+	cookie = dev->device_tx_submit(tx);
+
+	cpu = get_cpu();
+	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
+	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
+	put_cpu();
+
+	return cookie;
+}
+EXPORT_SYMBOL(dma_async_memcpy_pg_to_pg);
+
+void dma_async_tx_descriptor_init(struct dma_async_tx_descriptor *tx,
+	struct dma_chan *chan)
+{
+	tx->chan = chan;
+	spin_lock_init(&tx->lock);
+	INIT_LIST_HEAD(&tx->depend_node);
+	INIT_LIST_HEAD(&tx->depend_list);
+}
+EXPORT_SYMBOL(dma_async_tx_descriptor_init);
+
 static int __init dma_bus_init(void)
 {
 	mutex_init(&dma_list_mutex);
diff --git a/drivers/dma/ioatdma.c b/drivers/dma/ioatdma.c
index 8e87261..343013d 100644
--- a/drivers/dma/ioatdma.c
+++ b/drivers/dma/ioatdma.c
@@ -39,6 +39,7 @@
 #define to_ioat_chan(chan) container_of(chan, struct ioat_dma_chan, common)
 #define to_ioat_device(dev) container_of(dev, struct ioat_device, common)
 #define to_ioat_desc(lh) container_of(lh, struct ioat_desc_sw, node)
+#define tx_to_ioat_desc(tx) container_of(tx, struct ioat_desc_sw, async_tx)
 
 /* internal functions */
 static int __devinit ioat_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
@@ -99,6 +100,8 @@ static struct ioat_desc_sw *ioat_dma_alloc_descriptor(
 	}
 
 	memset(desc, 0, sizeof(*desc));
+	dma_async_tx_descriptor_init(&desc_sw->async_tx, &ioat_chan->common);
+	INIT_LIST_HEAD(&desc_sw->group_list);
 	desc_sw->hw = desc;
 	desc_sw->phys = phys;
 
@@ -215,45 +218,25 @@ static void ioat_dma_free_chan_resources(struct dma_chan *chan)
 	ioatdma_chan_write16(ioat_chan, IOAT_CHANCTRL_OFFSET, chanctrl);
 }
 
-/**
- * do_ioat_dma_memcpy - actual function that initiates a IOAT DMA transaction
- * @ioat_chan: IOAT DMA channel handle
- * @dest: DMA destination address
- * @src: DMA source address
- * @len: transaction length in bytes
- */
-
-static dma_cookie_t do_ioat_dma_memcpy(struct ioat_dma_chan *ioat_chan,
-                                       dma_addr_t dest,
-                                       dma_addr_t src,
-                                       size_t len)
+static struct dma_async_tx_descriptor *
+ioat_dma_prep_memcpy(struct dma_chan *chan, size_t len, int int_en)
 {
-	struct ioat_desc_sw *first;
-	struct ioat_desc_sw *prev;
-	struct ioat_desc_sw *new;
-	dma_cookie_t cookie;
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_desc_sw *first, *prev, *new;
 	LIST_HEAD(new_chain);
 	u32 copy;
 	size_t orig_len;
-	dma_addr_t orig_src, orig_dst;
-	unsigned int desc_count = 0;
-	unsigned int append = 0;
-
-	if (!ioat_chan || !dest || !src)
-		return -EFAULT;
+	int desc_count = 0;
 
 	if (!len)
-		return ioat_chan->common.cookie;
+		return NULL;
 
 	orig_len = len;
-	orig_src = src;
-	orig_dst = dest;
 
 	first = NULL;
 	prev = NULL;
 
 	spin_lock_bh(&ioat_chan->desc_lock);
-
 	while (len) {
 		if (!list_empty(&ioat_chan->free_desc)) {
 			new = to_ioat_desc(ioat_chan->free_desc.next);
@@ -270,9 +253,8 @@ static dma_cookie_t do_ioat_dma_memcpy(struct ioat_dma_chan *ioat_chan,
 
 		new->hw->size = copy;
 		new->hw->ctl = 0;
-		new->hw->src_addr = src;
-		new->hw->dst_addr = dest;
-		new->cookie = 0;
+		new->async_tx.cookie = 0;
+		new->async_tx.ack = 1;
 
 		/* chain together the physical address list for the HW */
 		if (!first)
@@ -281,129 +263,90 @@ static dma_cookie_t do_ioat_dma_memcpy(struct ioat_dma_chan *ioat_chan,
 			prev->hw->next = (u64) new->phys;
 
 		prev = new;
-
 		len  -= copy;
-		dest += copy;
-		src  += copy;
-
 		list_add_tail(&new->node, &new_chain);
 		desc_count++;
 	}
-	new->hw->ctl = IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
-	new->hw->next = 0;
 
-	/* cookie incr and addition to used_list must be atomic */
+	list_splice(&new_chain, &new->group_list);
 
-	cookie = ioat_chan->common.cookie;
-	cookie++;
-	if (cookie < 0)
-		cookie = 1;
-	ioat_chan->common.cookie = new->cookie = cookie;
+	new->hw->ctl = IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
+	new->hw->next = 0;
+	new->group_count = desc_count;
+	new->async_tx.ack = 0; /* client is in control of this ack */
+	new->async_tx.cookie = -EBUSY;
+	new->async_tx.type = DMA_MEMCPY;
 
-	pci_unmap_addr_set(new, src, orig_src);
-	pci_unmap_addr_set(new, dst, orig_dst);
 	pci_unmap_len_set(new, src_len, orig_len);
 	pci_unmap_len_set(new, dst_len, orig_len);
-
-	/* write address into NextDescriptor field of last desc in chain */
-	to_ioat_desc(ioat_chan->used_desc.prev)->hw->next = first->phys;
-	list_splice_init(&new_chain, ioat_chan->used_desc.prev);
-
-	ioat_chan->pending += desc_count;
-	if (ioat_chan->pending >= 20) {
-		append = 1;
-		ioat_chan->pending = 0;
-	}
-
 	spin_unlock_bh(&ioat_chan->desc_lock);
 
-	if (append)
-		ioatdma_chan_write8(ioat_chan,
-		                    IOAT_CHANCMD_OFFSET,
-		                    IOAT_CHANCMD_APPEND);
-	return cookie;
+	return new ? &new->async_tx : NULL;
 }
 
-/**
- * ioat_dma_memcpy_buf_to_buf - wrapper that takes src & dest bufs
- * @chan: IOAT DMA channel handle
- * @dest: DMA destination address
- * @src: DMA source address
- * @len: transaction length in bytes
- */
-
-static dma_cookie_t ioat_dma_memcpy_buf_to_buf(struct dma_chan *chan,
-                                               void *dest,
-                                               void *src,
-                                               size_t len)
+static void
+ioat_set_src(dma_addr_t addr, struct dma_async_tx_descriptor *tx, int index)
 {
-	dma_addr_t dest_addr;
-	dma_addr_t src_addr;
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_desc_sw *iter, *desc = tx_to_ioat_desc(tx);
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(tx->chan);
 
-	dest_addr = pci_map_single(ioat_chan->device->pdev,
-		dest, len, PCI_DMA_FROMDEVICE);
-	src_addr = pci_map_single(ioat_chan->device->pdev,
-		src, len, PCI_DMA_TODEVICE);
+	pci_unmap_addr_set(desc, src, addr);
 
-	return do_ioat_dma_memcpy(ioat_chan, dest_addr, src_addr, len);
-}
+	list_for_each_entry(iter, &desc->group_list, node) {
+		iter->hw->src_addr = addr;
+		addr += ioat_chan->xfercap;
+	}
 
-/**
- * ioat_dma_memcpy_buf_to_pg - wrapper, copying from a buf to a page
- * @chan: IOAT DMA channel handle
- * @page: pointer to the page to copy to
- * @offset: offset into that page
- * @src: DMA source address
- * @len: transaction length in bytes
- */
+}
 
-static dma_cookie_t ioat_dma_memcpy_buf_to_pg(struct dma_chan *chan,
-                                              struct page *page,
-                                              unsigned int offset,
-                                              void *src,
-                                              size_t len)
+static void
+ioat_set_dest(dma_addr_t addr, struct dma_async_tx_descriptor *tx, int index)
 {
-	dma_addr_t dest_addr;
-	dma_addr_t src_addr;
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_desc_sw *iter, *desc = tx_to_ioat_desc(tx);
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(tx->chan);
 
-	dest_addr = pci_map_page(ioat_chan->device->pdev,
-		page, offset, len, PCI_DMA_FROMDEVICE);
-	src_addr = pci_map_single(ioat_chan->device->pdev,
-		src, len, PCI_DMA_TODEVICE);
+	pci_unmap_addr_set(desc, dst, addr);
 
-	return do_ioat_dma_memcpy(ioat_chan, dest_addr, src_addr, len);
+	list_for_each_entry(iter, &desc->group_list, node) {
+		iter->hw->dst_addr = addr;
+		addr += ioat_chan->xfercap;
+	}
 }
 
-/**
- * ioat_dma_memcpy_pg_to_pg - wrapper, copying between two pages
- * @chan: IOAT DMA channel handle
- * @dest_pg: pointer to the page to copy to
- * @dest_off: offset into that page
- * @src_pg: pointer to the page to copy from
- * @src_off: offset into that page
- * @len: transaction length in bytes. This is guaranteed not to make a copy
- *	 across a page boundary.
- */
-
-static dma_cookie_t ioat_dma_memcpy_pg_to_pg(struct dma_chan *chan,
-                                             struct page *dest_pg,
-                                             unsigned int dest_off,
-                                             struct page *src_pg,
-                                             unsigned int src_off,
-                                             size_t len)
+static dma_cookie_t
+ioat_tx_submit(struct dma_async_tx_descriptor *tx)
 {
-	dma_addr_t dest_addr;
-	dma_addr_t src_addr;
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(tx->chan);
+	struct ioat_desc_sw *desc = tx_to_ioat_desc(tx);
+	struct ioat_desc_sw *group_start = list_entry(desc->group_list.next,
+		struct ioat_desc_sw, node);
+	int append = 0;
+	dma_cookie_t cookie;
+
+	spin_lock_bh(&ioat_chan->desc_lock);
+	/* cookie incr and addition to used_list must be atomic */
+	cookie = ioat_chan->common.cookie;
+	cookie++;
+	if (cookie < 0)
+		cookie = 1;
+	ioat_chan->common.cookie = desc->async_tx.cookie = cookie;
 
-	dest_addr = pci_map_page(ioat_chan->device->pdev,
-		dest_pg, dest_off, len, PCI_DMA_FROMDEVICE);
-	src_addr = pci_map_page(ioat_chan->device->pdev,
-		src_pg, src_off, len, PCI_DMA_TODEVICE);
+	/* write address into NextDescriptor field of last desc in chain */
+	to_ioat_desc(ioat_chan->used_desc.prev)->hw->next = group_start->phys;
+	list_splice_init(&desc->group_list, ioat_chan->used_desc.prev);
+
+	ioat_chan->pending += desc->group_count;
+	if (ioat_chan->pending >= 20) {
+		append = 1;
+		ioat_chan->pending = 0;
+	}
+	spin_unlock_bh(&ioat_chan->desc_lock);
 
-	return do_ioat_dma_memcpy(ioat_chan, dest_addr, src_addr, len);
+	if (append)
+		ioatdma_chan_write8(ioat_chan,
+		                    IOAT_CHANCMD_OFFSET,
+		                    IOAT_CHANCMD_APPEND);
+	return cookie;
 }
 
 /**
@@ -467,8 +410,8 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *chan)
 		 * exceeding xfercap, perhaps. If so, only the last one will
 		 * have a cookie, and require unmapping.
 		 */
-		if (desc->cookie) {
-			cookie = desc->cookie;
+		if (desc->async_tx.cookie) {
+			cookie = desc->async_tx.cookie;
 
 			/* yes we are unmapping both _page and _single alloc'd
 			   regions with unmap_page. Is this *really* that bad?
@@ -484,13 +427,18 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *chan)
 		}
 
 		if (desc->phys != phys_complete) {
-			/* a completed entry, but not the last, so cleanup */
-			list_del(&desc->node);
-			list_add_tail(&desc->node, &chan->free_desc);
+			/* a completed entry, but not the last, so cleanup
+			 * if the client is done with the descriptor
+			 */
+			if (desc->async_tx.ack) {
+				list_del(&desc->node);
+				list_add_tail(&desc->node, &chan->free_desc);
+			} else
+				desc->async_tx.cookie = 0;
 		} else {
 			/* last used desc. Do not remove, so we can append from
 			   it, but don't look at it next time, either */
-			desc->cookie = 0;
+			desc->async_tx.cookie = 0;
 
 			/* TODO check status bits? */
 			break;
@@ -506,6 +454,17 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *chan)
 	spin_unlock(&chan->cleanup_lock);
 }
 
+static void ioat_dma_dependency_added(struct dma_chan *chan)
+{
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	spin_lock_bh(&ioat_chan->desc_lock);
+	if (ioat_chan->pending == 0) {
+		spin_unlock_bh(&ioat_chan->desc_lock);
+		ioat_dma_memcpy_cleanup(ioat_chan);
+	} else
+		spin_unlock_bh(&ioat_chan->desc_lock);
+}
+
 /**
  * ioat_dma_is_complete - poll the status of a IOAT DMA transaction
  * @chan: IOAT DMA channel handle
@@ -607,6 +566,7 @@ static void ioat_start_null_desc(struct ioat_dma_chan *ioat_chan)
 
 	desc->hw->ctl = IOAT_DMA_DESCRIPTOR_NUL;
 	desc->hw->next = 0;
+	desc->async_tx.ack = 1;
 
 	list_add_tail(&desc->node, &ioat_chan->used_desc);
 	spin_unlock_bh(&ioat_chan->desc_lock);
@@ -633,6 +593,8 @@ static int ioat_self_test(struct ioat_device *device)
 	u8 *src;
 	u8 *dest;
 	struct dma_chan *dma_chan;
+	struct dma_async_tx_descriptor *tx;
+	dma_addr_t addr;
 	dma_cookie_t cookie;
 	int err = 0;
 
@@ -658,7 +620,13 @@ static int ioat_self_test(struct ioat_device *device)
 		goto out;
 	}
 
-	cookie = ioat_dma_memcpy_buf_to_buf(dma_chan, dest, src, IOAT_TEST_SIZE);
+	tx = ioat_dma_prep_memcpy(dma_chan, IOAT_TEST_SIZE, 0);
+	async_tx_ack(tx);
+	addr = dma_map_single(dma_chan->device->dev, src, IOAT_TEST_SIZE, DMA_TO_DEVICE);
+	ioat_set_src(addr, tx, 0);
+	addr = dma_map_single(dma_chan->device->dev, dest, IOAT_TEST_SIZE, DMA_FROM_DEVICE);
+	ioat_set_dest(addr, tx, 0);
+	cookie = ioat_tx_submit(tx);
 	ioat_dma_memcpy_issue_pending(dma_chan);
 	msleep(1);
 
@@ -754,13 +722,17 @@ static int __devinit ioat_probe(struct pci_dev *pdev,
 	INIT_LIST_HEAD(&device->common.channels);
 	enumerate_dma_channels(device);
 
+	dma_cap_set(DMA_MEMCPY, device->common.cap_mask);
 	device->common.device_alloc_chan_resources = ioat_dma_alloc_chan_resources;
 	device->common.device_free_chan_resources = ioat_dma_free_chan_resources;
-	device->common.device_memcpy_buf_to_buf = ioat_dma_memcpy_buf_to_buf;
-	device->common.device_memcpy_buf_to_pg = ioat_dma_memcpy_buf_to_pg;
-	device->common.device_memcpy_pg_to_pg = ioat_dma_memcpy_pg_to_pg;
-	device->common.device_memcpy_complete = ioat_dma_is_complete;
-	device->common.device_memcpy_issue_pending = ioat_dma_memcpy_issue_pending;
+	device->common.device_prep_dma_memcpy = ioat_dma_prep_memcpy;
+	device->common.device_set_src = ioat_set_src;
+	device->common.device_set_dest = ioat_set_dest;
+	device->common.device_is_tx_complete = ioat_dma_is_complete;
+	device->common.device_issue_pending = ioat_dma_memcpy_issue_pending;
+	device->common.device_dependency_added = ioat_dma_dependency_added;
+	device->common.device_tx_submit = ioat_tx_submit;
+	device->common.dev = &pdev->dev;
 	printk(KERN_INFO "Intel(R) I/OAT DMA Engine found, %d channels\n",
 		device->common.chancnt);
 
diff --git a/drivers/dma/ioatdma.h b/drivers/dma/ioatdma.h
index 62b26a9..fed259a 100644
--- a/drivers/dma/ioatdma.h
+++ b/drivers/dma/ioatdma.h
@@ -105,15 +105,20 @@ struct ioat_dma_chan {
 /**
  * struct ioat_desc_sw - wrapper around hardware descriptor
  * @hw: hardware DMA descriptor
+ * @async_tx:
  * @node:
+ * @group_list:
+ * @group_cnt:
  * @cookie:
  * @phys:
  */
 
 struct ioat_desc_sw {
 	struct ioat_dma_descriptor *hw;
+	struct dma_async_tx_descriptor async_tx;
 	struct list_head node;
-	dma_cookie_t cookie;
+	struct list_head group_list;
+	int group_count;
 	dma_addr_t phys;
 	DECLARE_PCI_UNMAP_ADDR(src)
 	DECLARE_PCI_UNMAP_LEN(src_len)
@@ -122,4 +127,3 @@ struct ioat_desc_sw {
 };
 
 #endif /* IOATDMA_H */
-
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index c94d8f1..c62d63d 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -21,13 +21,12 @@
 #ifndef DMAENGINE_H
 #define DMAENGINE_H
 
-#ifdef CONFIG_DMA_ENGINE
-
 #include <linux/device.h>
 #include <linux/uio.h>
 #include <linux/kref.h>
 #include <linux/completion.h>
 #include <linux/rcupdate.h>
+#include <linux/dma-mapping.h>
 
 /**
  * enum dma_event - resource PNP/power managment events
@@ -65,6 +64,46 @@ enum dma_status {
 };
 
 /**
+ * enum dma_transaction_type - DMA transaction types/indexes
+ */
+enum dma_transaction_type {
+	DMA_MEMCPY,
+	DMA_XOR,
+	DMA_PQ_XOR,
+	DMA_DUAL_XOR,
+	DMA_PQ_UPDATE,
+	DMA_ZERO_SUM,
+	DMA_PQ_ZERO_SUM,
+	DMA_MEMSET,
+	DMA_MEMCPY_CRC32C,
+	DMA_INTERRUPT, /* when updating, make this the last entry and 
+			* update the DMA_TX_ARRAY_INIT macro
+			*/
+};
+
+/* last transaction type for creation of the capabilities mask */
+#define DMA_TX_TYPE_END (DMA_INTERRUPT + 1)
+
+/* helper macro for clients defining transaction arrays */
+#define DMA_TX_ARRAY_INIT(x)	\
+	[DMA_MEMCPY] = x,	\
+	[DMA_XOR] = x,		\
+	[DMA_PQ_XOR] = x,	\
+	[DMA_DUAL_XOR] = x,	\
+	[DMA_PQ_UPDATE] = x,	\
+	[DMA_ZERO_SUM] = x,	\
+	[DMA_PQ_ZERO_SUM] = x,	\
+	[DMA_MEMSET] = x,	\
+	[DMA_MEMCPY_CRC32C] = x,\
+	[DMA_INTERRUPT] = x,
+
+/**
+ * dma_cap_mask_t - capabilities bitmap modeled after cpumask_t.
+ * See linux/cpumask.h
+ */
+typedef struct { DECLARE_BITMAP(bits, DMA_TX_TYPE_END); } dma_cap_mask_t;
+
+/**
  * struct dma_chan_percpu - the per-CPU part of struct dma_chan
  * @refcount: local_t used for open-coded "bigref" counting
  * @memcpy_count: transaction counter
@@ -157,48 +196,101 @@ struct dma_client {
 	struct list_head	global_node;
 };
 
+typedef void (*dma_async_tx_callback)(void *dma_async_param);
+/**
+ * struct dma_async_tx_descriptor - async transaction descriptor
+ * @cookie: tracking cookie for this transaction, set to -EBUSY if
+ *	this tx is sitting on a dependency list
+ * @ack: the descriptor can not be reused until the client acknowledges
+ *	receipt, i.e. has has a chance to establish any dependency chains
+ * @type: allows backend implementations to key off the tx_type
+ * @callback: routine to call after this operation is complete
+ * @callback_param: general parameter to pass to the callback routine
+ * @chan: target channel for this operation
+ * @depend_list: at completion this list of transactions are submitted
+ * @depend_node: allow this transaction to be executed after another
+ *	transaction has completed
+ * @parent: pointer to the next level up in the dependency chain
+ * @lock: protect the dependency list
+ */
+struct dma_async_tx_descriptor {
+	dma_cookie_t cookie;
+	int ack;
+	enum dma_transaction_type type;
+	dma_async_tx_callback callback;
+	void *callback_param;
+	struct dma_chan *chan;
+	struct list_head depend_list;
+	struct list_head depend_node;
+	struct dma_async_tx_descriptor *parent;
+	spinlock_t lock;
+};
+
 /**
  * struct dma_device - info on the entity supplying DMA services
  * @chancnt: how many DMA channels are supported
  * @channels: the list of struct dma_chan
  * @global_node: list_head for global dma_device_list
+ * @cap_mask: one or more dma_capability flags
+ * @max_xor: maximum number of xor sources, 0 if no capability
  * @refcount: reference count
  * @done: IO completion struct
  * @dev_id: unique device ID
+ * @dev: struct device reference for dma mapping api
  * @device_alloc_chan_resources: allocate resources and return the
  *	number of allocated descriptors
  * @device_free_chan_resources: release DMA channel's resources
- * @device_memcpy_buf_to_buf: memcpy buf pointer to buf pointer
- * @device_memcpy_buf_to_pg: memcpy buf pointer to struct page
- * @device_memcpy_pg_to_pg: memcpy struct page/offset to struct page/offset
- * @device_memcpy_complete: poll the status of an IOAT DMA transaction
- * @device_memcpy_issue_pending: push appended descriptors to hardware
+ * @device_prep_dma_memcpy: prepares a memcpy operation
+ * @device_prep_dma_xor: prepares a xor operation
+ * @device_prep_dma_zero_sum: prepares a zero_sum operation
+ * @device_prep_dma_memset: prepares a memset operation
+ * @device_prep_dma_interrupt: prepares an end of chain interrupt operation
+ * @device_tx_submit: execute an operation
+ * @device_set_dest: set a destination address in a hardware descriptor
+ * @device_set_src: set a source address in a hardware descriptor
+ * @device_dependency_added: async_tx notifies the channel about new deps
+ * @device_issue_pending: push pending transactions to hardware
  */
 struct dma_device {
 
 	unsigned int chancnt;
 	struct list_head channels;
 	struct list_head global_node;
+	dma_cap_mask_t  cap_mask;
+	int max_xor;
 
 	struct kref refcount;
 	struct completion done;
 
 	int dev_id;
+	struct device *dev;
 
 	int (*device_alloc_chan_resources)(struct dma_chan *chan);
 	void (*device_free_chan_resources)(struct dma_chan *chan);
-	dma_cookie_t (*device_memcpy_buf_to_buf)(struct dma_chan *chan,
-			void *dest, void *src, size_t len);
-	dma_cookie_t (*device_memcpy_buf_to_pg)(struct dma_chan *chan,
-			struct page *page, unsigned int offset, void *kdata,
-			size_t len);
-	dma_cookie_t (*device_memcpy_pg_to_pg)(struct dma_chan *chan,
-			struct page *dest_pg, unsigned int dest_off,
-			struct page *src_pg, unsigned int src_off, size_t len);
-	enum dma_status (*device_memcpy_complete)(struct dma_chan *chan,
+
+	struct dma_async_tx_descriptor *(*device_prep_dma_memcpy)(
+		struct dma_chan *chan, size_t len, int int_en);
+	struct dma_async_tx_descriptor *(*device_prep_dma_xor)(
+		struct dma_chan *chan, unsigned int src_cnt, size_t len,
+		int int_en);
+	struct dma_async_tx_descriptor *(*device_prep_dma_zero_sum)(
+		struct dma_chan *chan, unsigned int src_cnt, size_t len,
+		u32 *result, int int_en);
+	struct dma_async_tx_descriptor *(*device_prep_dma_memset)(
+		struct dma_chan *chan, int value, size_t len, int int_en);
+	struct dma_async_tx_descriptor *(*device_prep_dma_interrupt)(
+		struct dma_chan *chan);
+
+	dma_cookie_t (*device_tx_submit)(struct dma_async_tx_descriptor *tx);
+	void (*device_set_dest)(dma_addr_t addr,
+		struct dma_async_tx_descriptor *tx, int index);
+	void (*device_set_src)(dma_addr_t addr,
+		struct dma_async_tx_descriptor *tx, int index);
+	void (*device_dependency_added)(struct dma_chan *chan);
+	enum dma_status (*device_is_tx_complete)(struct dma_chan *chan,
 			dma_cookie_t cookie, dma_cookie_t *last,
 			dma_cookie_t *used);
-	void (*device_memcpy_issue_pending)(struct dma_chan *chan);
+	void (*device_issue_pending)(struct dma_chan *chan);
 };
 
 /* --- public DMA engine API --- */
@@ -207,96 +299,68 @@ struct dma_client *dma_async_client_register(dma_event_callback event_callback);
 void dma_async_client_unregister(struct dma_client *client);
 void dma_async_client_chan_request(struct dma_client *client,
 		unsigned int number);
-
-/**
- * dma_async_memcpy_buf_to_buf - offloaded copy between virtual addresses
- * @chan: DMA channel to offload copy to
- * @dest: destination address (virtual)
- * @src: source address (virtual)
- * @len: length
- *
- * Both @dest and @src must be mappable to a bus address according to the
- * DMA mapping API rules for streaming mappings.
- * Both @dest and @src must stay memory resident (kernel memory or locked
- * user space pages).
- */
-static inline dma_cookie_t dma_async_memcpy_buf_to_buf(struct dma_chan *chan,
-	void *dest, void *src, size_t len)
+dma_cookie_t dma_async_memcpy_buf_to_buf(struct dma_chan *chan,
+        void *dest, void *src, size_t len);
+dma_cookie_t dma_async_memcpy_buf_to_pg(struct dma_chan *chan,
+        struct page *page, unsigned int offset, void *kdata, size_t len);
+dma_cookie_t dma_async_memcpy_pg_to_pg(struct dma_chan *chan,
+        struct page *dest_pg, unsigned int dest_off, struct page *src_pg,
+        unsigned int src_off, size_t len);
+void dma_async_tx_descriptor_init(struct dma_async_tx_descriptor *tx,
+	struct dma_chan *chan);
+
+
+static inline void
+async_tx_ack(struct dma_async_tx_descriptor *tx)
 {
-	int cpu = get_cpu();
-	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
-	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
-	put_cpu();
-
-	return chan->device->device_memcpy_buf_to_buf(chan, dest, src, len);
+	tx->ack = 1;
 }
 
-/**
- * dma_async_memcpy_buf_to_pg - offloaded copy from address to page
- * @chan: DMA channel to offload copy to
- * @page: destination page
- * @offset: offset in page to copy to
- * @kdata: source address (virtual)
- * @len: length
- *
- * Both @page/@offset and @kdata must be mappable to a bus address according
- * to the DMA mapping API rules for streaming mappings.
- * Both @page/@offset and @kdata must stay memory resident (kernel memory or
- * locked user space pages)
- */
-static inline dma_cookie_t dma_async_memcpy_buf_to_pg(struct dma_chan *chan,
-	struct page *page, unsigned int offset, void *kdata, size_t len)
+#define first_dma_cap(mask) __first_dma_cap(&(mask))
+static inline int __first_dma_cap(const dma_cap_mask_t *srcp)
 {
-	int cpu = get_cpu();
-	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
-	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
-	put_cpu();
+	return min_t(int, DMA_TX_TYPE_END, find_first_bit(srcp->bits, DMA_TX_TYPE_END));
+}
 
-	return chan->device->device_memcpy_buf_to_pg(chan, page, offset,
-	                                             kdata, len);
+#define next_dma_cap(n, mask) __next_dma_cap((n), &(mask))
+static inline int __next_dma_cap(int n, const dma_cap_mask_t *srcp)
+{
+	return min_t(int, DMA_TX_TYPE_END, find_next_bit(srcp->bits, DMA_TX_TYPE_END, n+1));
 }
 
-/**
- * dma_async_memcpy_pg_to_pg - offloaded copy from page to page
- * @chan: DMA channel to offload copy to
- * @dest_pg: destination page
- * @dest_off: offset in page to copy to
- * @src_pg: source page
- * @src_off: offset in page to copy from
- * @len: length
- *
- * Both @dest_page/@dest_off and @src_page/@src_off must be mappable to a bus
- * address according to the DMA mapping API rules for streaming mappings.
- * Both @dest_page/@dest_off and @src_page/@src_off must stay memory resident
- * (kernel memory or locked user space pages).
- */
-static inline dma_cookie_t dma_async_memcpy_pg_to_pg(struct dma_chan *chan,
-	struct page *dest_pg, unsigned int dest_off, struct page *src_pg,
-	unsigned int src_off, size_t len)
+#define dma_cap_set(tx, mask) __dma_cap_set((tx), &(mask))
+static inline void __dma_cap_set(enum dma_transaction_type tx_type, dma_cap_mask_t *dstp)
 {
-	int cpu = get_cpu();
-	per_cpu_ptr(chan->local, cpu)->bytes_transferred += len;
-	per_cpu_ptr(chan->local, cpu)->memcpy_count++;
-	put_cpu();
+	set_bit(tx_type, dstp->bits);
+}
 
-	return chan->device->device_memcpy_pg_to_pg(chan, dest_pg, dest_off,
-	                                            src_pg, src_off, len);
+#define dma_has_cap(tx, mask) __dma_has_cap((tx), &(mask))
+static inline int __dma_has_cap(enum dma_transaction_type tx_type, dma_cap_mask_t *srcp)
+{
+	return test_bit(tx_type, srcp->bits);
 }
 
+#define for_each_dma_cap_mask(cap, mask) \
+	for ((cap) = first_dma_cap(mask);	\
+		(cap) < DMA_TX_TYPE_END;	\
+		(cap) = next_dma_cap((cap), (mask)))
+
 /**
- * dma_async_memcpy_issue_pending - flush pending copies to HW
+ * dma_async_issue_pending - flush pending transactions to HW
  * @chan: target DMA channel
  *
  * This allows drivers to push copies to HW in batches,
  * reducing MMIO writes where possible.
  */
-static inline void dma_async_memcpy_issue_pending(struct dma_chan *chan)
+static inline void dma_async_issue_pending(struct dma_chan *chan)
 {
-	return chan->device->device_memcpy_issue_pending(chan);
+	return chan->device->device_issue_pending(chan);
 }
 
+#define dma_async_memcpy_issue_pending(chan) dma_async_issue_pending(chan)
+
 /**
- * dma_async_memcpy_complete - poll for transaction completion
+ * dma_async_is_tx_complete - poll for transaction completion
  * @chan: DMA channel
  * @cookie: transaction identifier to check status of
  * @last: returns last completed cookie, can be NULL
@@ -306,12 +370,15 @@ static inline void dma_async_memcpy_issue_pending(struct dma_chan *chan)
  * internal state and can be used with dma_async_is_complete() to check
  * the status of multiple cookies without re-checking hardware state.
  */
-static inline enum dma_status dma_async_memcpy_complete(struct dma_chan *chan,
+static inline enum dma_status dma_async_is_tx_complete(struct dma_chan *chan,
 	dma_cookie_t cookie, dma_cookie_t *last, dma_cookie_t *used)
 {
-	return chan->device->device_memcpy_complete(chan, cookie, last, used);
+	return chan->device->device_is_tx_complete(chan, cookie, last, used);
 }
 
+#define dma_async_memcpy_complete(chan, cookie, last, used)\
+	dma_async_is_tx_complete(chan, cookie, last, used)
+
 /**
  * dma_async_is_complete - test a cookie against chan state
  * @cookie: transaction identifier to test status of
@@ -334,6 +401,7 @@ static inline enum dma_status dma_async_is_complete(dma_cookie_t cookie,
 	return DMA_IN_PROGRESS;
 }
 
+enum dma_status dma_sync_wait(struct dma_chan *chan, dma_cookie_t cookie);
 
 /* --- DMA device --- */
 
@@ -362,5 +430,4 @@ dma_cookie_t dma_memcpy_pg_to_iovec(struct dma_chan *chan, struct iovec *iov,
 	struct dma_pinned_list *pinned_list, struct page *page,
 	unsigned int offset, size_t len);
 
-#endif /* CONFIG_DMA_ENGINE */
 #endif /* DMAENGINE_H */
