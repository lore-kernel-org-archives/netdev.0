From: Andrew Grover <andrew.grover@intel.com>
Subject: [PATCH 2a/2] [IOAT] Driver for the I/OAT engine part 2a
Date: Thu, 20 Apr 2006 14:06:51 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0604201403300.23021-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:15511 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751319AbWDTVGw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 17:06:52 -0400
Received: from orsfmr100.jf.intel.com (orsfmr100.jf.intel.com [10.7.209.16])
	by orsfmr004.jf.intel.com (8.12.10/8.12.10/d: major-outer.mc,v 1.1 2004/09/17 17:50:56 root Exp $) with ESMTP id k3KL6qiN026394
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 21:06:52 GMT
Received: from nwlxmail01.jf.intel.com (nwlxmail01.jf.intel.com [10.7.171.40])
	by orsfmr100.jf.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id k3KL6p2u025162
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 21:06:51 GMT
Received: from isotope.jf.intel.com (isotope.jf.intel.com [10.23.35.8])
	by nwlxmail01.jf.intel.com (8.12.10/8.12.9/MailSET/Hub) with ESMTP id k3KL6phF022269
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 14:06:51 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

patch 2 got blocked due to size, here is the diff in 2 parts. -- Andy


Adds a new ioatdma driver, ioatdma.c

Signed-off-by: Chris Leech <christopher.leech@intel.com>

---

 drivers/dma/ioatdma.c           |  805 +++++++++++++++++++++++++++++++++++++++

diff --git a/drivers/dma/ioatdma.c b/drivers/dma/ioatdma.c
new file mode 100644
index 0000000..ffe47dd
--- /dev/null
+++ b/drivers/dma/ioatdma.c
@@ -0,0 +1,805 @@
+/*
+ * Copyright(c) 2004 - 2006 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called COPYING.
+ */
+
+/*
+ * This driver supports an Intel I/OAT DMA engine, which does asynchronous
+ * copy operations.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/interrupt.h>
+#include <linux/dmaengine.h>
+#include <linux/delay.h>
+#include "ioatdma.h"
+#include "ioatdma_io.h"
+#include "ioatdma_registers.h"
+#include "ioatdma_hw.h"
+
+#define to_ioat_chan(chan) container_of(chan, struct ioat_dma_chan, common)
+#define to_ioat_device(dev) container_of(dev, struct ioat_device, common)
+#define to_ioat_desc(lh) container_of(lh, struct ioat_desc_sw, node)
+
+/* internal functions */
+static int __devinit ioat_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
+static void __devexit ioat_remove(struct pci_dev *pdev);
+
+static int enumerate_dma_channels(struct ioat_device *device)
+{
+	u8 xfercap_scale;
+	u32 xfercap;
+	int i;
+	struct ioat_dma_chan *ioat_chan;
+
+	device->common.chancnt = ioatdma_read8(device, IOAT_CHANCNT_OFFSET);
+	xfercap_scale = ioatdma_read8(device, IOAT_XFERCAP_OFFSET);
+	xfercap = (xfercap_scale == 0 ? -1 : (1UL << xfercap_scale));
+
+	for (i = 0; i < device->common.chancnt; i++) {
+		ioat_chan = kzalloc(sizeof(*ioat_chan), GFP_KERNEL);
+		if (!ioat_chan) {
+			device->common.chancnt = i;
+			break;
+		}
+
+		ioat_chan->device = device;
+		ioat_chan->reg_base = device->reg_base + (0x80 * (i + 1));
+		ioat_chan->xfercap = xfercap;
+		spin_lock_init(&ioat_chan->cleanup_lock);
+		spin_lock_init(&ioat_chan->desc_lock);
+		INIT_LIST_HEAD(&ioat_chan->free_desc);
+		INIT_LIST_HEAD(&ioat_chan->used_desc);
+		/* This should be made common somewhere in dmaengine.c */
+		ioat_chan->common.device = &device->common;
+		ioat_chan->common.client = NULL;
+		list_add_tail(&ioat_chan->common.device_node,
+		              &device->common.channels);
+	}
+	return device->common.chancnt;
+}
+
+static struct ioat_desc_sw *ioat_dma_alloc_descriptor(struct ioat_dma_chan *ioat_chan, int flags)
+{
+	struct ioat_dma_descriptor *desc;
+	struct ioat_desc_sw *desc_sw;
+	struct ioat_device *ioat_device;
+	dma_addr_t phys;
+
+	ioat_device = to_ioat_device(ioat_chan->common.device);
+	desc = pci_pool_alloc(ioat_device->dma_pool, flags, &phys);
+	if (unlikely(!desc))
+		return NULL;
+
+	desc_sw = kzalloc(sizeof(*desc_sw), flags);
+	if (unlikely(!desc_sw)) {
+		pci_pool_free(ioat_device->dma_pool, desc, phys);
+		return NULL;
+	}
+
+	memset(desc, 0, sizeof(*desc));
+	desc_sw->hw = desc;
+	desc_sw->phys = phys;
+
+	return desc_sw;
+}
+
+#define INITIAL_IOAT_DESC_COUNT 128
+
+static void ioat_start_null_desc(struct ioat_dma_chan *ioat_chan);
+
+/* returns the actual number of allocated descriptors */
+static int ioat_dma_alloc_chan_resources(struct dma_chan *chan)
+{
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_desc_sw *desc = NULL;
+	u16 chanctrl;
+	u32 chanerr;
+	int i;
+
+	/*
+	 * In-use bit automatically set by reading chanctrl
+	 * If 0, we got it, if 1, someone else did
+	 */
+	chanctrl = ioatdma_chan_read16(ioat_chan, IOAT_CHANCTRL_OFFSET);
+	if (chanctrl & IOAT_CHANCTRL_CHANNEL_IN_USE)
+		return -EBUSY;
+
+        /* Setup register to interrupt and write completion status on error */
+	chanctrl = IOAT_CHANCTRL_CHANNEL_IN_USE |
+		IOAT_CHANCTRL_ERR_INT_EN |
+		IOAT_CHANCTRL_ANY_ERR_ABORT_EN |
+		IOAT_CHANCTRL_ERR_COMPLETION_EN;
+        ioatdma_chan_write16(ioat_chan, IOAT_CHANCTRL_OFFSET, chanctrl);
+
+	chanerr = ioatdma_chan_read32(ioat_chan, IOAT_CHANERR_OFFSET);
+	if (chanerr) {
+		printk("IOAT: CHANERR = %x, clearing\n", chanerr);
+		ioatdma_chan_write32(ioat_chan, IOAT_CHANERR_OFFSET, chanerr);
+	}
+
+	/* Allocate descriptors */
+	spin_lock_bh(&ioat_chan->desc_lock);
+	for (i = 0; i < INITIAL_IOAT_DESC_COUNT; i++) {
+		desc = ioat_dma_alloc_descriptor(ioat_chan, GFP_KERNEL);
+		if (!desc) {
+			printk(KERN_ERR "IOAT: Only %d initial descriptors\n", i);
+			break;
+		}
+		list_add_tail(&desc->node, &ioat_chan->free_desc);
+	}
+	spin_unlock_bh(&ioat_chan->desc_lock);
+
+	/* allocate a completion writeback area */
+	/* doing 2 32bit writes to mmio since 1 64b write doesn't work */
+	ioat_chan->completion_virt =
+		pci_pool_alloc(ioat_chan->device->completion_pool,
+		               GFP_KERNEL,
+		               &ioat_chan->completion_addr);
+	memset(ioat_chan->completion_virt, 0,
+	       sizeof(*ioat_chan->completion_virt));
+	ioatdma_chan_write32(ioat_chan, IOAT_CHANCMP_OFFSET_LOW,
+	               ((u64) ioat_chan->completion_addr) & 0x00000000FFFFFFFF);
+	ioatdma_chan_write32(ioat_chan, IOAT_CHANCMP_OFFSET_HIGH,
+	               ((u64) ioat_chan->completion_addr) >> 32);
+
+	ioat_start_null_desc(ioat_chan);
+	return i;
+}
+
+static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan);
+
+static void ioat_dma_free_chan_resources(struct dma_chan *chan)
+{
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_device *ioat_device = to_ioat_device(chan->device);
+	struct ioat_desc_sw *desc, *_desc;
+	u16 chanctrl;
+	int in_use_descs = 0;
+
+	ioat_dma_memcpy_cleanup(ioat_chan);
+
+	ioatdma_chan_write8(ioat_chan, IOAT_CHANCMD_OFFSET, IOAT_CHANCMD_RESET);
+
+	spin_lock_bh(&ioat_chan->desc_lock);
+	list_for_each_entry_safe(desc, _desc, &ioat_chan->used_desc, node) {
+		in_use_descs++;
+		list_del(&desc->node);
+		pci_pool_free(ioat_device->dma_pool, desc->hw, desc->phys);
+		kfree(desc);
+	}
+	list_for_each_entry_safe(desc, _desc, &ioat_chan->free_desc, node) {
+		list_del(&desc->node);
+		pci_pool_free(ioat_device->dma_pool, desc->hw, desc->phys);
+		kfree(desc);
+	}
+	spin_unlock_bh(&ioat_chan->desc_lock);
+
+	pci_pool_free(ioat_device->completion_pool,
+	              ioat_chan->completion_virt,
+	              ioat_chan->completion_addr);
+
+	/* one is ok since we left it on there on purpose */
+	if (in_use_descs > 1)
+		printk(KERN_ERR "IOAT: Freeing %d in use descriptors!\n",
+			in_use_descs - 1);
+
+	ioat_chan->last_completion = ioat_chan->completion_addr = 0;
+
+	/* Tell hw the chan is free */
+	chanctrl = ioatdma_chan_read16(ioat_chan, IOAT_CHANCTRL_OFFSET);
+	chanctrl &= ~IOAT_CHANCTRL_CHANNEL_IN_USE;
+	ioatdma_chan_write16(ioat_chan, IOAT_CHANCTRL_OFFSET, chanctrl);
+}
+
+/**
+ * do_ioat_dma_memcpy - actual function that initiates a IOAT DMA transaction
+ * @chan: IOAT DMA channel handle
+ * @dest: DMA destination address
+ * @src: DMA source address
+ * @len: transaction length in bytes
+ */
+
+static dma_cookie_t do_ioat_dma_memcpy(struct ioat_dma_chan *ioat_chan, dma_addr_t dest, dma_addr_t src, size_t len)
+{
+	struct ioat_desc_sw *first;
+	struct ioat_desc_sw *prev;
+	struct ioat_desc_sw *new;
+	dma_cookie_t cookie;
+	LIST_HEAD(new_chain);
+	u32 copy;
+	size_t orig_len;
+	dma_addr_t orig_src, orig_dst;
+	unsigned int desc_count = 0;
+	unsigned int append = 0;
+
+	if (!ioat_chan || !dest || !src)
+		return -EFAULT;
+
+	if (!len)
+		return ioat_chan->common.cookie;
+
+	orig_len = len;
+	orig_src = src;
+	orig_dst = dest;
+
+	first = NULL;
+	prev = NULL;
+
+	spin_lock_bh(&ioat_chan->desc_lock);
+
+	while (len) {
+		if (!list_empty(&ioat_chan->free_desc)) {
+			new = to_ioat_desc(ioat_chan->free_desc.next);
+			list_del(&new->node);
+		} else {
+			/* try to get another desc */
+			new = ioat_dma_alloc_descriptor(ioat_chan, GFP_ATOMIC);
+			/* will this ever happen? */
+			/* TODO add upper limit on these */
+			BUG_ON(!new);
+		}
+
+		copy = min((u32) len, ioat_chan->xfercap);
+
+		new->hw->size = copy;
+		new->hw->ctl = 0;
+		new->hw->src_addr = src;
+		new->hw->dst_addr = dest;
+		new->cookie = 0;
+
+		/* chain together the physical address list for the HW */
+		if (!first)
+			first = new;
+		else
+			prev->hw->next = (u64) new->phys;
+
+		prev = new;
+
+		len  -= copy;
+		dest += copy;
+		src  += copy;
+
+		list_add_tail(&new->node, &new_chain);
+		desc_count++;
+	}
+	new->hw->ctl = IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
+	new->hw->next = 0;
+
+	/* cookie incr and addition to used_list must be atomic */
+
+	cookie = ioat_chan->common.cookie;
+	cookie++;
+	if (cookie < 0)
+		cookie = 1;
+	ioat_chan->common.cookie = new->cookie = cookie;
+
+	pci_unmap_addr_set(new, src, orig_src);
+	pci_unmap_addr_set(new, dst, orig_dst);
+	pci_unmap_len_set(new, src_len, orig_len);
+	pci_unmap_len_set(new, dst_len, orig_len);
+
+	/* write address into NextDescriptor field of last desc in chain */
+	to_ioat_desc(ioat_chan->used_desc.prev)->hw->next = first->phys;
+	list_splice_init(&new_chain, ioat_chan->used_desc.prev);
+
+	ioat_chan->pending += desc_count;
+	if (ioat_chan->pending >= 20) {
+		append = 1;
+		ioat_chan->pending = 0;
+	}
+
+	spin_unlock_bh(&ioat_chan->desc_lock);
+
+	if (append)
+		ioatdma_chan_write8(ioat_chan,
+		                    IOAT_CHANCMD_OFFSET,
+		                    IOAT_CHANCMD_APPEND);
+	return cookie;
+}
+
+/**
+ * ioat_dma_memcpy_buf_to_buf - wrapper that takes src & dest bufs
+ * @chan: IOAT DMA channel handle
+ * @dest: DMA destination address
+ * @src: DMA source address
+ * @len: transaction length in bytes
+ */
+
+static dma_cookie_t ioat_dma_memcpy_buf_to_buf(struct dma_chan *chan, void *dest, void *src, size_t len)
+{
+	dma_addr_t dest_addr;
+	dma_addr_t src_addr;
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+
+	dest_addr = pci_map_single(ioat_chan->device->pdev,
+		dest, len, PCI_DMA_FROMDEVICE);
+	src_addr = pci_map_single(ioat_chan->device->pdev,
+		src, len, PCI_DMA_TODEVICE);
+
+	return do_ioat_dma_memcpy(ioat_chan, dest_addr, src_addr, len);
+}
+
+/**
+ * ioat_dma_memcpy_buf_to_pg - wrapper, copying from a buf to a page
+ * @chan: IOAT DMA channel handle
+ * @page: pointer to the page to copy to
+ * @offset: offset into that page
+ * @src: DMA source address
+ * @len: transaction length in bytes
+ */
+
+static dma_cookie_t ioat_dma_memcpy_buf_to_pg(struct dma_chan *chan, struct page *page, unsigned int offset, void *src, size_t len)
+{
+	dma_addr_t dest_addr;
+	dma_addr_t src_addr;
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+
+	dest_addr = pci_map_page(ioat_chan->device->pdev,
+		page, offset, len, PCI_DMA_FROMDEVICE);
+	src_addr = pci_map_single(ioat_chan->device->pdev,
+		src, len, PCI_DMA_TODEVICE);
+
+	return do_ioat_dma_memcpy(ioat_chan, dest_addr, src_addr, len);
+}
+
+/**
+ * ioat_dma_memcpy_pg_to_pg - wrapper, copying between two pages
+ * @chan: IOAT DMA channel handle
+ * @dest_pg: pointer to the page to copy to
+ * @dest_off: offset into that page
+ * @src_pg: pointer to the page to copy from
+ * @src_off: offset into that page
+ * @len: transaction length in bytes. This is guaranteed to not make a copy
+ *	 across a page boundary.
+ */
+
+static dma_cookie_t ioat_dma_memcpy_pg_to_pg(struct dma_chan *chan, struct page *dest_pg, unsigned int dest_off, struct page *src_pg, unsigned int src_off, size_t len)
+{
+	dma_addr_t dest_addr;
+	dma_addr_t src_addr;
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+
+	dest_addr = pci_map_page(ioat_chan->device->pdev,
+		dest_pg, dest_off, len, PCI_DMA_FROMDEVICE);
+	src_addr = pci_map_page(ioat_chan->device->pdev,
+		src_pg, src_off, len, PCI_DMA_TODEVICE);
+
+	return do_ioat_dma_memcpy(ioat_chan, dest_addr, src_addr, len);
+}


