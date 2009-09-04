From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 12/29] ioat2,3: convert to a true ring buffer
Date: Thu, 03 Sep 2009 19:31:31 -0700
Message-ID: <20090904023131.32667.66375.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace the current linked list munged into a ring with a native ring
buffer implementation.  The benefit of this approach is reduced overhead
as many parameters can be derived from ring position with simple pointer
comparisons and descriptor allocation/freeing becomes just a
manipulation of head/tail pointers.

It requires a contiguous allocation for the software descriptor
information.

Since this arrangement is significantly different from the ioat1 chain,
move ioat2,3 support into its own file and header.  Common routines are
exported from driver/dma/ioat/dma.[ch].

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/Makefile |    2 
 drivers/dma/ioat/dma.c    |  874 ++++++++++-----------------------------------
 drivers/dma/ioat/dma.h    |   50 ++-
 drivers/dma/ioat/dma_v2.c |  751 +++++++++++++++++++++++++++++++++++++++
 drivers/dma/ioat/dma_v2.h |  131 +++++++
 drivers/dma/ioat/pci.c    |    1 
 6 files changed, 1123 insertions(+), 686 deletions(-)
 create mode 100644 drivers/dma/ioat/dma_v2.c
 create mode 100644 drivers/dma/ioat/dma_v2.h

diff --git a/drivers/dma/ioat/Makefile b/drivers/dma/ioat/Makefile
index 2ce3d3a..205a639 100644
--- a/drivers/dma/ioat/Makefile
+++ b/drivers/dma/ioat/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_INTEL_IOATDMA) += ioatdma.o
-ioatdma-objs := pci.o dma.o dca.o
+ioatdma-objs := pci.o dma.o dma_v2.o dca.o
diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index 2e81e0c..64b4d75 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -38,28 +38,14 @@
 #include "registers.h"
 #include "hw.h"
 
-static int ioat_pending_level = 4;
+int ioat_pending_level = 4;
 module_param(ioat_pending_level, int, 0644);
 MODULE_PARM_DESC(ioat_pending_level,
 		 "high-water mark for pushing ioat descriptors (default: 4)");
 
-static void ioat_dma_chan_reset_part2(struct work_struct *work);
-static void ioat_dma_chan_watchdog(struct work_struct *work);
-
 /* internal functions */
-static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat);
-static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat);
-
-static struct ioat_desc_sw *
-ioat1_dma_get_next_descriptor(struct ioat_dma_chan *ioat);
-static struct ioat_desc_sw *
-ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat);
-
-static inline struct ioat_chan_common *
-ioat_chan_by_index(struct ioatdma_device *device, int index)
-{
-	return device->idx[index];
-}
+static void ioat1_cleanup(struct ioat_dma_chan *ioat);
+static void ioat1_dma_start_null_desc(struct ioat_dma_chan *ioat);
 
 /**
  * ioat_dma_do_interrupt - handler used for single vector interrupt mode
@@ -108,18 +94,38 @@ static irqreturn_t ioat_dma_do_interrupt_msix(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static void ioat_dma_cleanup_tasklet(unsigned long data);
+static void ioat1_cleanup_tasklet(unsigned long data);
+
+/* common channel initialization */
+void ioat_init_channel(struct ioatdma_device *device,
+		       struct ioat_chan_common *chan, int idx,
+		       work_func_t work_fn, void (*tasklet)(unsigned long),
+		       unsigned long tasklet_data)
+{
+	struct dma_device *dma = &device->common;
+
+	chan->device = device;
+	chan->reg_base = device->reg_base + (0x80 * (idx + 1));
+	INIT_DELAYED_WORK(&chan->work, work_fn);
+	spin_lock_init(&chan->cleanup_lock);
+	chan->common.device = dma;
+	list_add_tail(&chan->common.device_node, &dma->channels);
+	device->idx[idx] = chan;
+	tasklet_init(&chan->cleanup_task, tasklet, tasklet_data);
+	tasklet_disable(&chan->cleanup_task);
+}
+
+static void ioat1_reset_part2(struct work_struct *work);
 
 /**
- * ioat_dma_enumerate_channels - find and initialize the device's channels
+ * ioat1_dma_enumerate_channels - find and initialize the device's channels
  * @device: the device to be enumerated
  */
-static int ioat_dma_enumerate_channels(struct ioatdma_device *device)
+static int ioat1_enumerate_channels(struct ioatdma_device *device)
 {
 	u8 xfercap_scale;
 	u32 xfercap;
 	int i;
-	struct ioat_chan_common *chan;
 	struct ioat_dma_chan *ioat;
 	struct device *dev = &device->pdev->dev;
 	struct dma_device *dma = &device->common;
@@ -135,31 +141,20 @@ static int ioat_dma_enumerate_channels(struct ioatdma_device *device)
 #endif
 	for (i = 0; i < dma->chancnt; i++) {
 		ioat = devm_kzalloc(dev, sizeof(*ioat), GFP_KERNEL);
-		if (!ioat) {
-			dma->chancnt = i;
+		if (!ioat)
 			break;
-		}
 
-		chan = &ioat->base;
-		chan->device = device;
-		chan->reg_base = device->reg_base + (0x80 * (i + 1));
+		ioat_init_channel(device, &ioat->base, i,
+				  ioat1_reset_part2,
+				  ioat1_cleanup_tasklet,
+				  (unsigned long) ioat);
 		ioat->xfercap = xfercap;
-		ioat->desccount = 0;
-		INIT_DELAYED_WORK(&chan->work, ioat_dma_chan_reset_part2);
-		spin_lock_init(&chan->cleanup_lock);
 		spin_lock_init(&ioat->desc_lock);
 		INIT_LIST_HEAD(&ioat->free_desc);
 		INIT_LIST_HEAD(&ioat->used_desc);
-		/* This should be made common somewhere in dmaengine.c */
-		chan->common.device = &device->common;
-		list_add_tail(&chan->common.device_node, &dma->channels);
-		device->idx[i] = chan;
-		tasklet_init(&chan->cleanup_task,
-			     ioat_dma_cleanup_tasklet,
-			     (unsigned long) ioat);
-		tasklet_disable(&chan->cleanup_task);
 	}
-	return dma->chancnt;
+	dma->chancnt = i;
+	return i;
 }
 
 /**
@@ -187,35 +182,16 @@ static void ioat1_dma_memcpy_issue_pending(struct dma_chan *chan)
 	}
 }
 
-static inline void
-__ioat2_dma_memcpy_issue_pending(struct ioat_dma_chan *ioat)
-{
-	void __iomem *reg_base = ioat->base.reg_base;
-
-	ioat->pending = 0;
-	writew(ioat->dmacount, reg_base + IOAT_CHAN_DMACOUNT_OFFSET);
-}
-
-static void ioat2_dma_memcpy_issue_pending(struct dma_chan *chan)
-{
-	struct ioat_dma_chan *ioat = to_ioat_chan(chan);
-
-	if (ioat->pending > 0) {
-		spin_lock_bh(&ioat->desc_lock);
-		__ioat2_dma_memcpy_issue_pending(ioat);
-		spin_unlock_bh(&ioat->desc_lock);
-	}
-}
-
-
 /**
- * ioat_dma_chan_reset_part2 - reinit the channel after a reset
+ * ioat1_reset_part2 - reinit the channel after a reset
  */
-static void ioat_dma_chan_reset_part2(struct work_struct *work)
+static void ioat1_reset_part2(struct work_struct *work)
 {
 	struct ioat_chan_common *chan;
 	struct ioat_dma_chan *ioat;
 	struct ioat_desc_sw *desc;
+	int dmacount;
+	bool start_null = false;
 
 	chan = container_of(work, struct ioat_chan_common, work.work);
 	ioat = container_of(chan, struct ioat_dma_chan, base);
@@ -226,26 +202,22 @@ static void ioat_dma_chan_reset_part2(struct work_struct *work)
 	chan->completion_virt->high = 0;
 	ioat->pending = 0;
 
-	/*
-	 * count the descriptors waiting, and be sure to do it
-	 * right for both the CB1 line and the CB2 ring
-	 */
-	ioat->dmacount = 0;
+	/* count the descriptors waiting */
+	dmacount = 0;
 	if (ioat->used_desc.prev) {
 		desc = to_ioat_desc(ioat->used_desc.prev);
 		do {
-			ioat->dmacount++;
+			dmacount++;
 			desc = to_ioat_desc(desc->node.next);
 		} while (&desc->node != ioat->used_desc.next);
 	}
 
-	/*
-	 * write the new starting descriptor address
-	 * this puts channel engine into ARMED state
-	 */
-	desc = to_ioat_desc(ioat->used_desc.prev);
-	switch (chan->device->version) {
-	case IOAT_VER_1_2:
+	if (dmacount) {
+		/*
+		 * write the new starting descriptor address
+		 * this puts channel engine into ARMED state
+		 */
+		desc = to_ioat_desc(ioat->used_desc.prev);
 		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
 		       chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
 		writel(((u64) desc->txd.phys) >> 32,
@@ -253,32 +225,24 @@ static void ioat_dma_chan_reset_part2(struct work_struct *work)
 
 		writeb(IOAT_CHANCMD_START, chan->reg_base
 			+ IOAT_CHANCMD_OFFSET(chan->device->version));
-		break;
-	case IOAT_VER_2_0:
-		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
-		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
-		writel(((u64) desc->txd.phys) >> 32,
-		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
-
-		/* tell the engine to go with what's left to be done */
-		writew(ioat->dmacount,
-		       chan->reg_base + IOAT_CHAN_DMACOUNT_OFFSET);
+	} else
+		start_null = true;
+	spin_unlock_bh(&ioat->desc_lock);
+	spin_unlock_bh(&chan->cleanup_lock);
 
-		break;
-	}
 	dev_err(to_dev(chan),
 		"chan%d reset - %d descs waiting, %d total desc\n",
-		chan_num(chan), ioat->dmacount, ioat->desccount);
+		chan_num(chan), dmacount, ioat->desccount);
 
-	spin_unlock_bh(&ioat->desc_lock);
-	spin_unlock_bh(&chan->cleanup_lock);
+	if (start_null)
+		ioat1_dma_start_null_desc(ioat);
 }
 
 /**
- * ioat_dma_reset_channel - restart a channel
+ * ioat1_reset_channel - restart a channel
  * @ioat: IOAT DMA channel handle
  */
-static void ioat_dma_reset_channel(struct ioat_dma_chan *ioat)
+static void ioat1_reset_channel(struct ioat_dma_chan *ioat)
 {
 	struct ioat_chan_common *chan = &ioat->base;
 	void __iomem *reg_base = chan->reg_base;
@@ -316,9 +280,9 @@ static void ioat_dma_reset_channel(struct ioat_dma_chan *ioat)
 }
 
 /**
- * ioat_dma_chan_watchdog - watch for stuck channels
+ * ioat1_chan_watchdog - watch for stuck channels
  */
-static void ioat_dma_chan_watchdog(struct work_struct *work)
+static void ioat1_chan_watchdog(struct work_struct *work)
 {
 	struct ioatdma_device *device =
 		container_of(work, struct ioatdma_device, work.work);
@@ -339,16 +303,15 @@ static void ioat_dma_chan_watchdog(struct work_struct *work)
 		chan = ioat_chan_by_index(device, i);
 		ioat = container_of(chan, struct ioat_dma_chan, base);
 
-		if (chan->device->version == IOAT_VER_1_2
-			/* have we started processing anything yet */
-		    && chan->last_completion
-			/* have we completed any since last watchdog cycle? */
+		if (/* have we started processing anything yet */
+		    chan->last_completion
+		    /* have we completed any since last watchdog cycle? */
 		    && (chan->last_completion == chan->watchdog_completion)
-			/* has TCP stuck on one cookie since last watchdog? */
+		    /* has TCP stuck on one cookie since last watchdog? */
 		    && (chan->watchdog_tcp_cookie == chan->watchdog_last_tcp_cookie)
 		    && (chan->watchdog_tcp_cookie != chan->completed_cookie)
-			/* is there something in the chain to be processed? */
-			/* CB1 chain always has at least the last one processed */
+		    /* is there something in the chain to be processed? */
+		    /* CB1 chain always has at least the last one processed */
 		    && (ioat->used_desc.prev != ioat->used_desc.next)
 		    && ioat->pending == 0) {
 
@@ -387,34 +350,15 @@ static void ioat_dma_chan_watchdog(struct work_struct *work)
 				chan->completion_virt->low = completion_hw.low;
 				chan->completion_virt->high = completion_hw.high;
 			} else {
-				ioat_dma_reset_channel(ioat);
+				ioat1_reset_channel(ioat);
 				chan->watchdog_completion = 0;
 				chan->last_compl_desc_addr_hw = 0;
 			}
-
-		/*
-		 * for version 2.0 if there are descriptors yet to be processed
-		 * and the last completed hasn't changed since the last watchdog
-		 *      if they haven't hit the pending level
-		 *          issue the pending to push them through
-		 *      else
-		 *          try resetting the channel
-		 */
-		} else if (chan->device->version == IOAT_VER_2_0
-		    && ioat->used_desc.prev
-		    && chan->last_completion
-		    && chan->last_completion == chan->watchdog_completion) {
-
-			if (ioat->pending < ioat_pending_level)
-				ioat2_dma_memcpy_issue_pending(&chan->common);
-			else {
-				ioat_dma_reset_channel(ioat);
-				chan->watchdog_completion = 0;
-			}
 		} else {
 			chan->last_compl_desc_addr_hw = 0;
 			chan->watchdog_completion = chan->last_completion;
 		}
+
 		chan->watchdog_last_tcp_cookie = chan->watchdog_tcp_cookie;
 	}
 
@@ -447,7 +391,6 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	chain_tail->hw->next = first->txd.phys;
 	list_splice_tail_init(&tx->tx_list, &ioat->used_desc);
 
-	ioat->dmacount += desc->tx_cnt;
 	ioat->pending += desc->tx_cnt;
 	if (ioat->pending >= ioat_pending_level)
 		__ioat1_dma_memcpy_issue_pending(ioat);
@@ -456,92 +399,6 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	return cookie;
 }
 
-static dma_cookie_t ioat2_tx_submit(struct dma_async_tx_descriptor *tx)
-{
-	struct ioat_dma_chan *ioat = to_ioat_chan(tx->chan);
-	struct ioat_desc_sw *first = tx_to_ioat_desc(tx);
-	struct ioat_desc_sw *new;
-	struct ioat_dma_descriptor *hw;
-	dma_cookie_t cookie;
-	u32 copy;
-	size_t len;
-	dma_addr_t src, dst;
-	unsigned long orig_flags;
-	unsigned int desc_count = 0;
-
-	/* src and dest and len are stored in the initial descriptor */
-	len = first->len;
-	src = first->src;
-	dst = first->dst;
-	orig_flags = first->txd.flags;
-	new = first;
-
-	/*
-	 * ioat->desc_lock is still in force in version 2 path
-	 * it gets unlocked at end of this function
-	 */
-	do {
-		copy = min_t(size_t, len, ioat->xfercap);
-
-		async_tx_ack(&new->txd);
-
-		hw = new->hw;
-		hw->size = copy;
-		hw->ctl = 0;
-		hw->src_addr = src;
-		hw->dst_addr = dst;
-
-		len -= copy;
-		dst += copy;
-		src += copy;
-		desc_count++;
-	} while (len && (new = ioat2_dma_get_next_descriptor(ioat)));
-
-	if (!new) {
-		dev_err(to_dev(&ioat->base), "tx submit failed\n");
-		spin_unlock_bh(&ioat->desc_lock);
-		return -ENOMEM;
-	}
-
-	hw->ctl_f.compl_write = 1;
-	if (first->txd.callback) {
-		hw->ctl_f.int_en = 1;
-		if (first != new) {
-			/* move callback into to last desc */
-			new->txd.callback = first->txd.callback;
-			new->txd.callback_param
-					= first->txd.callback_param;
-			first->txd.callback = NULL;
-			first->txd.callback_param = NULL;
-		}
-	}
-
-	new->tx_cnt = desc_count;
-	new->txd.flags = orig_flags; /* client is in control of this ack */
-
-	/* store the original values for use in later cleanup */
-	if (new != first) {
-		new->src = first->src;
-		new->dst = first->dst;
-		new->len = first->len;
-	}
-
-	/* cookie incr and addition to used_list must be atomic */
-	cookie = ioat->base.common.cookie;
-	cookie++;
-	if (cookie < 0)
-		cookie = 1;
-	ioat->base.common.cookie = new->txd.cookie = cookie;
-
-	ioat->dmacount += desc_count;
-	ioat->pending += desc_count;
-	if (ioat->pending >= ioat_pending_level)
-		__ioat2_dma_memcpy_issue_pending(ioat);
-	spin_unlock_bh(&ioat->desc_lock);
-
-	return cookie;
-}
-
 /**
  * ioat_dma_alloc_descriptor - allocate and return a sw and hw descriptor pair
  * @ioat: the channel supplying the memory pool for the descriptors
@@ -567,17 +424,9 @@ ioat_dma_alloc_descriptor(struct ioat_dma_chan *ioat, gfp_t flags)
 	}
 
 	memset(desc, 0, sizeof(*desc));
-	dma_async_tx_descriptor_init(&desc_sw->txd, &ioat->base.common);
-	switch (ioatdma_device->version) {
-	case IOAT_VER_1_2:
-		desc_sw->txd.tx_submit = ioat1_tx_submit;
-		break;
-	case IOAT_VER_2_0:
-	case IOAT_VER_3_0:
-		desc_sw->txd.tx_submit = ioat2_tx_submit;
-		break;
-	}
 
+	dma_async_tx_descriptor_init(&desc_sw->txd, &ioat->base.common);
+	desc_sw->txd.tx_submit = ioat1_tx_submit;
 	desc_sw->hw = desc;
 	desc_sw->txd.phys = phys;
 
@@ -587,39 +436,12 @@ ioat_dma_alloc_descriptor(struct ioat_dma_chan *ioat, gfp_t flags)
 static int ioat_initial_desc_count = 256;
 module_param(ioat_initial_desc_count, int, 0644);
 MODULE_PARM_DESC(ioat_initial_desc_count,
-		 "initial descriptors per channel (default: 256)");
-
-/**
- * ioat2_dma_massage_chan_desc - link the descriptors into a circle
- * @ioat: the channel to be massaged
- */
-static void ioat2_dma_massage_chan_desc(struct ioat_dma_chan *ioat)
-{
-	struct ioat_desc_sw *desc, *_desc;
-
-	/* setup used_desc */
-	ioat->used_desc.next = ioat->free_desc.next;
-	ioat->used_desc.prev = NULL;
-
-	/* pull free_desc out of the circle so that every node is a hw
-	 * descriptor, but leave it pointing to the list
-	 */
-	ioat->free_desc.prev->next = ioat->free_desc.next;
-	ioat->free_desc.next->prev = ioat->free_desc.prev;
-
-	/* circle link the hw descriptors */
-	desc = to_ioat_desc(ioat->free_desc.next);
-	desc->hw->next = to_ioat_desc(desc->node.next)->txd.phys;
-	list_for_each_entry_safe(desc, _desc, ioat->free_desc.next, node) {
-		desc->hw->next = to_ioat_desc(desc->node.next)->txd.phys;
-	}
-}
-
+		 "ioat1: initial descriptors per channel (default: 256)");
 /**
- * ioat_dma_alloc_chan_resources - returns the number of allocated descriptors
+ * ioat1_dma_alloc_chan_resources - returns the number of allocated descriptors
  * @chan: the channel to be filled out
  */
-static int ioat_dma_alloc_chan_resources(struct dma_chan *c)
+static int ioat1_dma_alloc_chan_resources(struct dma_chan *c)
 {
 	struct ioat_dma_chan *ioat = to_ioat_chan(c);
 	struct ioat_chan_common *chan = &ioat->base;
@@ -657,8 +479,6 @@ static int ioat_dma_alloc_chan_resources(struct dma_chan *c)
 	spin_lock_bh(&ioat->desc_lock);
 	ioat->desccount = i;
 	list_splice(&tmp_list, &ioat->free_desc);
-	if (chan->device->version != IOAT_VER_1_2)
-		ioat2_dma_massage_chan_desc(ioat);
 	spin_unlock_bh(&ioat->desc_lock);
 
 	/* allocate a completion writeback area */
@@ -674,15 +494,15 @@ static int ioat_dma_alloc_chan_resources(struct dma_chan *c)
 	       chan->reg_base + IOAT_CHANCMP_OFFSET_HIGH);
 
 	tasklet_enable(&chan->cleanup_task);
-	ioat_dma_start_null_desc(ioat);  /* give chain to dma device */
+	ioat1_dma_start_null_desc(ioat);  /* give chain to dma device */
 	return ioat->desccount;
 }
 
 /**
- * ioat_dma_free_chan_resources - release all the descriptors
+ * ioat1_dma_free_chan_resources - release all the descriptors
  * @chan: the channel to be cleaned
  */
-static void ioat_dma_free_chan_resources(struct dma_chan *c)
+static void ioat1_dma_free_chan_resources(struct dma_chan *c)
 {
 	struct ioat_dma_chan *ioat = to_ioat_chan(c);
 	struct ioat_chan_common *chan = &ioat->base;
@@ -697,7 +517,7 @@ static void ioat_dma_free_chan_resources(struct dma_chan *c)
 		return;
 
 	tasklet_disable(&chan->cleanup_task);
-	ioat_dma_memcpy_cleanup(ioat);
+	ioat1_cleanup(ioat);
 
 	/* Delay 100ms after reset to allow internal DMA logic to quiesce
 	 * before removing DMA descriptor resources.
@@ -707,40 +527,20 @@ static void ioat_dma_free_chan_resources(struct dma_chan *c)
 	mdelay(100);
 
 	spin_lock_bh(&ioat->desc_lock);
-	switch (chan->device->version) {
-	case IOAT_VER_1_2:
-		list_for_each_entry_safe(desc, _desc,
-					 &ioat->used_desc, node) {
-			in_use_descs++;
-			list_del(&desc->node);
-			pci_pool_free(ioatdma_device->dma_pool, desc->hw,
-				      desc->txd.phys);
-			kfree(desc);
-		}
-		list_for_each_entry_safe(desc, _desc,
-					 &ioat->free_desc, node) {
-			list_del(&desc->node);
-			pci_pool_free(ioatdma_device->dma_pool, desc->hw,
-				      desc->txd.phys);
-			kfree(desc);
-		}
-		break;
-	case IOAT_VER_2_0:
-	case IOAT_VER_3_0:
-		list_for_each_entry_safe(desc, _desc,
-					 ioat->free_desc.next, node) {
-			list_del(&desc->node);
-			pci_pool_free(ioatdma_device->dma_pool, desc->hw,
-				      desc->txd.phys);
-			kfree(desc);
-		}
-		desc = to_ioat_desc(ioat->free_desc.next);
+	list_for_each_entry_safe(desc, _desc,
+				 &ioat->used_desc, node) {
+		in_use_descs++;
+		list_del(&desc->node);
+		pci_pool_free(ioatdma_device->dma_pool, desc->hw,
+			      desc->txd.phys);
+		kfree(desc);
+	}
+	list_for_each_entry_safe(desc, _desc,
+				 &ioat->free_desc, node) {
+		list_del(&desc->node);
 		pci_pool_free(ioatdma_device->dma_pool, desc->hw,
 			      desc->txd.phys);
 		kfree(desc);
-		INIT_LIST_HEAD(&ioat->free_desc);
-		INIT_LIST_HEAD(&ioat->used_desc);
-		break;
 	}
 	spin_unlock_bh(&ioat->desc_lock);
 
@@ -758,7 +558,6 @@ static void ioat_dma_free_chan_resources(struct dma_chan *c)
 	chan->last_compl_desc_addr_hw = 0;
 	chan->watchdog_tcp_cookie = chan->watchdog_last_tcp_cookie = 0;
 	ioat->pending = 0;
-	ioat->dmacount = 0;
 	ioat->desccount = 0;
 }
 
@@ -791,86 +590,6 @@ ioat1_dma_get_next_descriptor(struct ioat_dma_chan *ioat)
 	return new;
 }
 
-static struct ioat_desc_sw *
-ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat)
-{
-	struct ioat_desc_sw *new;
-
-	/*
-	 * used.prev points to where to start processing
-	 * used.next points to next free descriptor
-	 * if used.prev == NULL, there are none waiting to be processed
-	 * if used.next == used.prev.prev, there is only one free descriptor,
-	 *      and we need to use it to as a noop descriptor before
-	 *      linking in a new set of descriptors, since the device
-	 *      has probably already read the pointer to it
-	 */
-	if (ioat->used_desc.prev &&
-	    ioat->used_desc.next == ioat->used_desc.prev->prev) {
-
-		struct ioat_desc_sw *desc;
-		struct ioat_desc_sw *noop_desc;
-		int i;
-
-		/* set up the noop descriptor */
-		noop_desc = to_ioat_desc(ioat->used_desc.next);
-		/* set size to non-zero value (channel returns error when size is 0) */
-		noop_desc->hw->size = NULL_DESC_BUFFER_SIZE;
-		noop_desc->hw->ctl = 0;
-		noop_desc->hw->ctl_f.null = 1;
-		noop_desc->hw->src_addr = 0;
-		noop_desc->hw->dst_addr = 0;
-
-		ioat->used_desc.next = ioat->used_desc.next->next;
-		ioat->pending++;
-		ioat->dmacount++;
-
-		/* try to get a few more descriptors */
-		for (i = 16; i; i--) {
-			desc = ioat_dma_alloc_descriptor(ioat, GFP_ATOMIC);
-			if (!desc) {
-				dev_err(to_dev(&ioat->base),
-					"alloc failed\n");
-				break;
-			}
-			list_add_tail(&desc->node, ioat->used_desc.next);
-
-			desc->hw->next
-				= to_ioat_desc(desc->node.next)->txd.phys;
-			to_ioat_desc(desc->node.prev)->hw->next
-				= desc->txd.phys;
-			ioat->desccount++;
-		}
-
-		ioat->used_desc.next = noop_desc->node.next;
-	}
-	new = to_ioat_desc(ioat->used_desc.next);
-	prefetch(new);
-	ioat->used_desc.next = new->node.next;
-
-	if (ioat->used_desc.prev == NULL)
-		ioat->used_desc.prev = &new->node;
-
-	prefetch(new->hw);
-	return new;
-}
-
-static struct ioat_desc_sw *
-ioat_dma_get_next_descriptor(struct ioat_dma_chan *ioat)
-{
-	if (!ioat)
-		return NULL;
-
-	switch (ioat->base.device->version) {
-	case IOAT_VER_1_2:
-		return ioat1_dma_get_next_descriptor(ioat);
-	case IOAT_VER_2_0:
-	case IOAT_VER_3_0:
-		return ioat2_dma_get_next_descriptor(ioat);
-	}
-	return NULL;
-}
-
 static struct dma_async_tx_descriptor *
 ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 		      dma_addr_t dma_src, size_t len, unsigned long flags)
@@ -886,7 +605,7 @@ ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 	int tx_cnt = 0;
 
 	spin_lock_bh(&ioat->desc_lock);
-	desc = ioat_dma_get_next_descriptor(ioat);
+	desc = ioat1_dma_get_next_descriptor(ioat);
 	do {
 		if (!desc)
 			break;
@@ -909,7 +628,7 @@ ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 			struct ioat_desc_sw *next;
 
 			async_tx_ack(&desc->txd);
-			next = ioat_dma_get_next_descriptor(ioat);
+			next = ioat1_dma_get_next_descriptor(ioat);
 			hw->next = next ? next->txd.phys : 0;
 			desc = next;
 		} else
@@ -920,8 +639,7 @@ ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 		struct ioat_chan_common *chan = &ioat->base;
 
 		dev_err(to_dev(chan),
-			"chan%d - get_next_desc failed: %d descs waiting, %d total desc\n",
-			chan_num(chan), ioat->dmacount, ioat->desccount);
+			"chan%d - get_next_desc failed\n", chan_num(chan));
 		list_splice(&chain, &ioat->free_desc);
 		spin_unlock_bh(&ioat->desc_lock);
 		return NULL;
@@ -940,94 +658,43 @@ ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 	return &desc->txd;
 }
 
-static struct dma_async_tx_descriptor *
-ioat2_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
-		      dma_addr_t dma_src, size_t len, unsigned long flags)
-{
-	struct ioat_dma_chan *ioat = to_ioat_chan(c);
-	struct ioat_desc_sw *new;
-
-	spin_lock_bh(&ioat->desc_lock);
-	new = ioat2_dma_get_next_descriptor(ioat);
-
-	/*
-	 * leave ioat->desc_lock set in ioat 2 path
-	 * it will get unlocked at end of tx_submit
-	 */
-
-	if (new) {
-		new->len = len;
-		new->dst = dma_dest;
-		new->src = dma_src;
-		new->txd.flags = flags;
-		return &new->txd;
-	} else {
-		struct ioat_chan_common *chan = &ioat->base;
-
-		spin_unlock_bh(&ioat->desc_lock);
-		dev_err(to_dev(chan),
-			"chan%d - get_next_desc failed: %d descs waiting, %d total desc\n",
-			chan_num(chan), ioat->dmacount, ioat->desccount);
-		return NULL;
-	}
-}
-
-static void ioat_dma_cleanup_tasklet(unsigned long data)
+static void ioat1_cleanup_tasklet(unsigned long data)
 {
 	struct ioat_dma_chan *chan = (void *)data;
-	ioat_dma_memcpy_cleanup(chan);
+	ioat1_cleanup(chan);
 	writew(IOAT_CHANCTRL_INT_DISABLE,
 	       chan->base.reg_base + IOAT_CHANCTRL_OFFSET);
 }
 
-static void
-ioat_dma_unmap(struct ioat_chan_common *chan, struct ioat_desc_sw *desc)
+static void ioat_unmap(struct pci_dev *pdev, dma_addr_t addr, size_t len,
+		       int direction, enum dma_ctrl_flags flags, bool dst)
 {
-	if (!(desc->txd.flags & DMA_COMPL_SKIP_DEST_UNMAP)) {
-		if (desc->txd.flags & DMA_COMPL_DEST_UNMAP_SINGLE)
-			pci_unmap_single(chan->device->pdev,
-					 pci_unmap_addr(desc, dst),
-					 pci_unmap_len(desc, len),
-					 PCI_DMA_FROMDEVICE);
-		else
-			pci_unmap_page(chan->device->pdev,
-				       pci_unmap_addr(desc, dst),
-				       pci_unmap_len(desc, len),
-				       PCI_DMA_FROMDEVICE);
-	}
-
-	if (!(desc->txd.flags & DMA_COMPL_SKIP_SRC_UNMAP)) {
-		if (desc->txd.flags & DMA_COMPL_SRC_UNMAP_SINGLE)
-			pci_unmap_single(chan->device->pdev,
-					 pci_unmap_addr(desc, src),
-					 pci_unmap_len(desc, len),
-					 PCI_DMA_TODEVICE);
-		else
-			pci_unmap_page(chan->device->pdev,
-				       pci_unmap_addr(desc, src),
-				       pci_unmap_len(desc, len),
-				       PCI_DMA_TODEVICE);
-	}
+	if ((dst && (flags & DMA_COMPL_DEST_UNMAP_SINGLE)) ||
+	    (!dst && (flags & DMA_COMPL_SRC_UNMAP_SINGLE)))
+		pci_unmap_single(pdev, addr, len, direction);
+	else
+		pci_unmap_page(pdev, addr, len, direction);
 }
 
-/**
- * ioat_dma_memcpy_cleanup - cleanup up finished descriptors
- * @chan: ioat channel to be cleaned up
- */
-static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat)
+
+void ioat_dma_unmap(struct ioat_chan_common *chan, enum dma_ctrl_flags flags,
+		    size_t len, struct ioat_dma_descriptor *hw)
 {
-	struct ioat_chan_common *chan = &ioat->base;
-	unsigned long phys_complete;
-	struct ioat_desc_sw *desc, *_desc;
-	dma_cookie_t cookie = 0;
-	unsigned long desc_phys;
-	struct ioat_desc_sw *latest_desc;
-	struct dma_async_tx_descriptor *tx;
+	struct pci_dev *pdev = chan->device->pdev;
+	size_t offset = len - hw->size;
 
-	prefetch(chan->completion_virt);
+	if (!(flags & DMA_COMPL_SKIP_DEST_UNMAP))
+		ioat_unmap(pdev, hw->dst_addr - offset, len,
+			   PCI_DMA_FROMDEVICE, flags, 1);
 
-	if (!spin_trylock_bh(&chan->cleanup_lock))
-		return;
+	if (!(flags & DMA_COMPL_SKIP_SRC_UNMAP))
+		ioat_unmap(pdev, hw->src_addr - offset, len,
+			   PCI_DMA_TODEVICE, flags, 0);
+}
+
+unsigned long ioat_get_current_completion(struct ioat_chan_common *chan)
+{
+	unsigned long phys_complete;
 
 	/* The completion writeback can happen at any time,
 	   so reads by the driver need to be atomic operations
@@ -1051,18 +718,37 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat)
 		/* TODO do something to salvage the situation */
 	}
 
+	return phys_complete;
+}
+
+/**
+ * ioat1_cleanup - cleanup up finished descriptors
+ * @chan: ioat channel to be cleaned up
+ */
+static void ioat1_cleanup(struct ioat_dma_chan *ioat)
+{
+	struct ioat_chan_common *chan = &ioat->base;
+	unsigned long phys_complete;
+	struct ioat_desc_sw *desc, *_desc;
+	dma_cookie_t cookie = 0;
+	struct dma_async_tx_descriptor *tx;
+
+	prefetch(chan->completion_virt);
+
+	if (!spin_trylock_bh(&chan->cleanup_lock))
+		return;
+
+	phys_complete = ioat_get_current_completion(chan);
 	if (phys_complete == chan->last_completion) {
 		spin_unlock_bh(&chan->cleanup_lock);
 		/*
 		 * perhaps we're stuck so hard that the watchdog can't go off?
 		 * try to catch it after 2 seconds
 		 */
-		if (chan->device->version != IOAT_VER_3_0) {
-			if (time_after(jiffies,
-				       chan->last_completion_time + HZ*WATCHDOG_DELAY)) {
-				ioat_dma_chan_watchdog(&(chan->device->work.work));
-				chan->last_completion_time = jiffies;
-			}
+		if (time_after(jiffies,
+			       chan->last_completion_time + HZ*WATCHDOG_DELAY)) {
+			ioat1_chan_watchdog(&(chan->device->work.work));
+			chan->last_completion_time = jiffies;
 		}
 		return;
 	}
@@ -1074,91 +760,42 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat)
 		return;
 	}
 
-	switch (chan->device->version) {
-	case IOAT_VER_1_2:
-		list_for_each_entry_safe(desc, _desc, &ioat->used_desc, node) {
-			tx = &desc->txd;
-			/*
-			 * Incoming DMA requests may use multiple descriptors,
-			 * due to exceeding xfercap, perhaps. If so, only the
-			 * last one will have a cookie, and require unmapping.
-			 */
-			if (tx->cookie) {
-				cookie = tx->cookie;
-				ioat_dma_unmap(chan, desc);
-				if (tx->callback) {
-					tx->callback(tx->callback_param);
-					tx->callback = NULL;
-				}
+	list_for_each_entry_safe(desc, _desc, &ioat->used_desc, node) {
+		tx = &desc->txd;
+		/*
+		 * Incoming DMA requests may use multiple descriptors,
+		 * due to exceeding xfercap, perhaps. If so, only the
+		 * last one will have a cookie, and require unmapping.
+		 */
+		if (tx->cookie) {
+			cookie = tx->cookie;
+			ioat_dma_unmap(chan, tx->flags, desc->len, desc->hw);
+			if (tx->callback) {
+				tx->callback(tx->callback_param);
+				tx->callback = NULL;
 			}
+		}
 
-			if (tx->phys != phys_complete) {
-				/*
-				 * a completed entry, but not the last, so clean
-				 * up if the client is done with the descriptor
-				 */
-				if (async_tx_test_ack(tx)) {
-					list_move_tail(&desc->node,
-						       &ioat->free_desc);
-				} else
-					tx->cookie = 0;
-			} else {
-				/*
-				 * last used desc. Do not remove, so we can
-				 * append from it, but don't look at it next
-				 * time, either
-				 */
+		if (tx->phys != phys_complete) {
+			/*
+			 * a completed entry, but not the last, so clean
+			 * up if the client is done with the descriptor
+			 */
+			if (async_tx_test_ack(tx))
+				list_move_tail(&desc->node, &ioat->free_desc);
+			else
 				tx->cookie = 0;
+		} else {
+			/*
+			 * last used desc. Do not remove, so we can
+			 * append from it, but don't look at it next
+			 * time, either
+			 */
+			tx->cookie = 0;
 
-				/* TODO check status bits? */
-				break;
-			}
-		}
-		break;
-	case IOAT_VER_2_0:
-	case IOAT_VER_3_0:
-		/* has some other thread has already cleaned up? */
-		if (ioat->used_desc.prev == NULL)
+			/* TODO check status bits? */
 			break;
-
-		/* work backwards to find latest finished desc */
-		desc = to_ioat_desc(ioat->used_desc.next);
-		tx = &desc->txd;
-		latest_desc = NULL;
-		do {
-			desc = to_ioat_desc(desc->node.prev);
-			desc_phys = (unsigned long)tx->phys
-				       & IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
-			if (desc_phys == phys_complete) {
-				latest_desc = desc;
-				break;
-			}
-		} while (&desc->node != ioat->used_desc.prev);
-
-		if (latest_desc != NULL) {
-			/* work forwards to clear finished descriptors */
-			for (desc = to_ioat_desc(ioat->used_desc.prev);
-			     &desc->node != latest_desc->node.next &&
-			     &desc->node != ioat->used_desc.next;
-			     desc = to_ioat_desc(desc->node.next)) {
-				if (tx->cookie) {
-					cookie = tx->cookie;
-					tx->cookie = 0;
-					ioat_dma_unmap(chan, desc);
-					if (tx->callback) {
-						tx->callback(tx->callback_param);
-						tx->callback = NULL;
-					}
-				}
-			}
-
-			/* move used.prev up beyond those that are finished */
-			if (&desc->node == ioat->used_desc.next)
-				ioat->used_desc.prev = NULL;
-			else
-				ioat->used_desc.prev = &desc->node;
 		}
-		break;
 	}
 
 	spin_unlock_bh(&ioat->desc_lock);
@@ -1170,50 +807,21 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat)
 	spin_unlock_bh(&chan->cleanup_lock);
 }
 
-/**
- * ioat_dma_is_complete - poll the status of a IOAT DMA transaction
- * @chan: IOAT DMA channel handle
- * @cookie: DMA transaction identifier
- * @done: if not %NULL, updated with last completed transaction
- * @used: if not %NULL, updated with last used transaction
- */
 static enum dma_status
-ioat_dma_is_complete(struct dma_chan *c, dma_cookie_t cookie,
-		     dma_cookie_t *done, dma_cookie_t *used)
+ioat1_dma_is_complete(struct dma_chan *c, dma_cookie_t cookie,
+		      dma_cookie_t *done, dma_cookie_t *used)
 {
 	struct ioat_dma_chan *ioat = to_ioat_chan(c);
-	struct ioat_chan_common *chan = &ioat->base;
-	dma_cookie_t last_used;
-	dma_cookie_t last_complete;
-	enum dma_status ret;
-
-	last_used = c->cookie;
-	last_complete = chan->completed_cookie;
-	chan->watchdog_tcp_cookie = cookie;
-
-	if (done)
-		*done = last_complete;
-	if (used)
-		*used = last_used;
-
-	ret = dma_async_is_complete(cookie, last_complete, last_used);
-	if (ret == DMA_SUCCESS)
-		return ret;
 
-	ioat_dma_memcpy_cleanup(ioat);
+	if (ioat_is_complete(c, cookie, done, used) == DMA_SUCCESS)
+		return DMA_SUCCESS;
 
-	last_used = c->cookie;
-	last_complete = chan->completed_cookie;
+	ioat1_cleanup(ioat);
 
-	if (done)
-		*done = last_complete;
-	if (used)
-		*used = last_used;
-
-	return dma_async_is_complete(cookie, last_complete, last_used);
+	return ioat_is_complete(c, cookie, done, used);
 }
 
-static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat)
+static void ioat1_dma_start_null_desc(struct ioat_dma_chan *ioat)
 {
 	struct ioat_chan_common *chan = &ioat->base;
 	struct ioat_desc_sw *desc;
@@ -1221,7 +829,7 @@ static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat)
 
 	spin_lock_bh(&ioat->desc_lock);
 
-	desc = ioat_dma_get_next_descriptor(ioat);
+	desc = ioat1_dma_get_next_descriptor(ioat);
 
 	if (!desc) {
 		dev_err(to_dev(chan),
@@ -1240,30 +848,16 @@ static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat)
 	hw->src_addr = 0;
 	hw->dst_addr = 0;
 	async_tx_ack(&desc->txd);
-	switch (chan->device->version) {
-	case IOAT_VER_1_2:
-		hw->next = 0;
-		list_add_tail(&desc->node, &ioat->used_desc);
+	hw->next = 0;
+	list_add_tail(&desc->node, &ioat->used_desc);
 
-		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
-		       chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
-		writel(((u64) desc->txd.phys) >> 32,
-		       chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
-
-		writeb(IOAT_CHANCMD_START, chan->reg_base
-			+ IOAT_CHANCMD_OFFSET(chan->device->version));
-		break;
-	case IOAT_VER_2_0:
-	case IOAT_VER_3_0:
-		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
-		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
-		writel(((u64) desc->txd.phys) >> 32,
-		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
+	writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
+	       chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
+	writel(((u64) desc->txd.phys) >> 32,
+	       chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
 
-		ioat->dmacount++;
-		__ioat2_dma_memcpy_issue_pending(ioat);
-		break;
-	}
+	writeb(IOAT_CHANCMD_START, chan->reg_base
+		+ IOAT_CHANCMD_OFFSET(chan->device->version));
 	spin_unlock_bh(&ioat->desc_lock);
 }
 
@@ -1484,7 +1078,7 @@ static void ioat_disable_interrupts(struct ioatdma_device *device)
 	writeb(0, device->reg_base + IOAT_INTRCTRL_OFFSET);
 }
 
-static int ioat_probe(struct ioatdma_device *device)
+int ioat_probe(struct ioatdma_device *device)
 {
 	int err = -ENODEV;
 	struct dma_device *dma = &device->common;
@@ -1503,17 +1097,15 @@ static int ioat_probe(struct ioatdma_device *device)
 	device->completion_pool = pci_pool_create("completion_pool", pdev,
 						  sizeof(u64), SMP_CACHE_BYTES,
 						  SMP_CACHE_BYTES);
+
 	if (!device->completion_pool) {
 		err = -ENOMEM;
 		goto err_completion_pool;
 	}
 
-	ioat_dma_enumerate_channels(device);
+	device->enumerate_channels(device);
 
 	dma_cap_set(DMA_MEMCPY, dma->cap_mask);
-	dma->device_alloc_chan_resources = ioat_dma_alloc_chan_resources;
-	dma->device_free_chan_resources = ioat_dma_free_chan_resources;
-	dma->device_is_tx_complete = ioat_dma_is_complete;
 	dma->dev = &pdev->dev;
 
 	dev_err(dev, "Intel(R) I/OAT DMA Engine found,"
@@ -1546,7 +1138,7 @@ err_dma_pool:
 	return err;
 }
 
-static int ioat_register(struct ioatdma_device *device)
+int ioat_register(struct ioatdma_device *device)
 {
 	int err = dma_async_device_register(&device->common);
 
@@ -1580,9 +1172,13 @@ int ioat1_dma_probe(struct ioatdma_device *device, int dca)
 	int err;
 
 	device->intr_quirk = ioat1_intr_quirk;
+	device->enumerate_channels = ioat1_enumerate_channels;
 	dma = &device->common;
 	dma->device_prep_dma_memcpy = ioat1_dma_prep_memcpy;
 	dma->device_issue_pending = ioat1_dma_memcpy_issue_pending;
+	dma->device_alloc_chan_resources = ioat1_dma_alloc_chan_resources;
+	dma->device_free_chan_resources = ioat1_dma_free_chan_resources;
+	dma->device_is_tx_complete = ioat1_dma_is_complete;
 
 	err = ioat_probe(device);
 	if (err)
@@ -1594,93 +1190,12 @@ int ioat1_dma_probe(struct ioatdma_device *device, int dca)
 	if (dca)
 		device->dca = ioat_dca_init(pdev, device->reg_base);
 
-	INIT_DELAYED_WORK(&device->work, ioat_dma_chan_watchdog);
-	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
-
-	return err;
-}
-
-int ioat2_dma_probe(struct ioatdma_device *device, int dca)
-{
-	struct pci_dev *pdev = device->pdev;
-	struct dma_device *dma;
-	struct dma_chan *c;
-	struct ioat_chan_common *chan;
-	int err;
-
-	dma = &device->common;
-	dma->device_prep_dma_memcpy = ioat2_dma_prep_memcpy;
-	dma->device_issue_pending = ioat2_dma_memcpy_issue_pending;
-
-	err = ioat_probe(device);
-	if (err)
-		return err;
-	ioat_set_tcp_copy_break(2048);
-
-	list_for_each_entry(c, &dma->channels, device_node) {
-		chan = to_chan_common(c);
-		writel(IOAT_DCACTRL_CMPL_WRITE_ENABLE | IOAT_DMA_DCA_ANY_CPU,
-		       chan->reg_base + IOAT_DCACTRL_OFFSET);
-	}
-
-	err = ioat_register(device);
-	if (err)
-		return err;
-	if (dca)
-		device->dca = ioat2_dca_init(pdev, device->reg_base);
-
-	INIT_DELAYED_WORK(&device->work, ioat_dma_chan_watchdog);
+	INIT_DELAYED_WORK(&device->work, ioat1_chan_watchdog);
 	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
 
 	return err;
 }
 
-int ioat3_dma_probe(struct ioatdma_device *device, int dca)
-{
-	struct pci_dev *pdev = device->pdev;
-	struct dma_device *dma;
-	struct dma_chan *c;
-	struct ioat_chan_common *chan;
-	int err;
-	u16 dev_id;
-
-	dma = &device->common;
-	dma->device_prep_dma_memcpy = ioat2_dma_prep_memcpy;
-	dma->device_issue_pending = ioat2_dma_memcpy_issue_pending;
-
-	/* -= IOAT ver.3 workarounds =- */
-	/* Write CHANERRMSK_INT with 3E07h to mask out the errors
-	 * that can cause stability issues for IOAT ver.3
-	 */
-	pci_write_config_dword(pdev, IOAT_PCI_CHANERRMASK_INT_OFFSET, 0x3e07);
-
-	/* Clear DMAUNCERRSTS Cfg-Reg Parity Error status bit
-	 * (workaround for spurious config parity error after restart)
-	 */
-	pci_read_config_word(pdev, IOAT_PCI_DEVICE_ID_OFFSET, &dev_id);
-	if (dev_id == PCI_DEVICE_ID_INTEL_IOAT_TBG0)
-		pci_write_config_dword(pdev, IOAT_PCI_DMAUNCERRSTS_OFFSET, 0x10);
-
-	err = ioat_probe(device);
-	if (err)
-		return err;
-	ioat_set_tcp_copy_break(262144);
-
-	list_for_each_entry(c, &dma->channels, device_node) {
-		chan = to_chan_common(c);
-		writel(IOAT_DMA_DCA_ANY_CPU,
-		       chan->reg_base + IOAT_DCACTRL_OFFSET);
-	}
-
-	err = ioat_register(device);
-	if (err)
-		return err;
-	if (dca)
-		device->dca = ioat3_dca_init(pdev, device->reg_base);
-
-	return err;
-}
-
 void ioat_dma_remove(struct ioatdma_device *device)
 {
 	struct dma_device *dma = &device->common;
@@ -1697,4 +1212,3 @@ void ioat_dma_remove(struct ioatdma_device *device)
 
 	INIT_LIST_HEAD(&dma->channels);
 }
-
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index 5b31db7..84065df 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -62,6 +62,7 @@
  * @idx: per channel data
  * @dca: direct cache access context
  * @intr_quirk: interrupt setup quirk (for ioat_v1 devices)
+ * @enumerate_channels: hw version specific channel enumeration
  */
 
 struct ioatdma_device {
@@ -76,6 +77,7 @@ struct ioatdma_device {
 	struct ioat_chan_common *idx[4];
 	struct dca_provider *dca;
 	void (*intr_quirk)(struct ioatdma_device *device);
+	int (*enumerate_channels)(struct ioatdma_device *device);
 };
 
 struct ioat_chan_common {
@@ -106,6 +108,7 @@ struct ioat_chan_common {
 	struct tasklet_struct cleanup_task;
 };
 
+
 /**
  * struct ioat_dma_chan - internal representation of a DMA channel
  */
@@ -119,7 +122,6 @@ struct ioat_dma_chan {
 	struct list_head used_desc;
 
 	int pending;
-	u16 dmacount;
 	u16 desccount;
 };
 
@@ -135,6 +137,33 @@ static inline struct ioat_dma_chan *to_ioat_chan(struct dma_chan *c)
 	return container_of(chan, struct ioat_dma_chan, base);
 }
 
+/**
+ * ioat_is_complete - poll the status of an ioat transaction
+ * @c: channel handle
+ * @cookie: transaction identifier
+ * @done: if set, updated with last completed transaction
+ * @used: if set, updated with last used transaction
+ */
+static inline enum dma_status
+ioat_is_complete(struct dma_chan *c, dma_cookie_t cookie,
+		 dma_cookie_t *done, dma_cookie_t *used)
+{
+	struct ioat_chan_common *chan = to_chan_common(c);
+	dma_cookie_t last_used;
+	dma_cookie_t last_complete;
+
+	last_used = c->cookie;
+	last_complete = chan->completed_cookie;
+	chan->watchdog_tcp_cookie = cookie;
+
+	if (done)
+		*done = last_complete;
+	if (used)
+		*used = last_used;
+
+	return dma_async_is_complete(cookie, last_complete, last_used);
+}
+
 /* wrapper around hardware descriptor format + additional software fields */
 
 /**
@@ -162,11 +191,22 @@ static inline void ioat_set_tcp_copy_break(unsigned long copybreak)
 	#endif
 }
 
+static inline struct ioat_chan_common *
+ioat_chan_by_index(struct ioatdma_device *device, int index)
+{
+	return device->idx[index];
+}
+
+int ioat_probe(struct ioatdma_device *device);
+int ioat_register(struct ioatdma_device *device);
 int ioat1_dma_probe(struct ioatdma_device *dev, int dca);
-int ioat2_dma_probe(struct ioatdma_device *dev, int dca);
-int ioat3_dma_probe(struct ioatdma_device *dev, int dca);
 void ioat_dma_remove(struct ioatdma_device *device);
 struct dca_provider *ioat_dca_init(struct pci_dev *pdev, void __iomem *iobase);
-struct dca_provider *ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase);
-struct dca_provider *ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase);
+unsigned long ioat_get_current_completion(struct ioat_chan_common *chan);
+void ioat_init_channel(struct ioatdma_device *device,
+		       struct ioat_chan_common *chan, int idx,
+		       work_func_t work_fn, void (*tasklet)(unsigned long),
+		       unsigned long tasklet_data);
+void ioat_dma_unmap(struct ioat_chan_common *chan, enum dma_ctrl_flags flags,
+		    size_t len, struct ioat_dma_descriptor *hw);
 #endif /* IOATDMA_H */
diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
new file mode 100644
index 0000000..9ac2d7b
--- /dev/null
+++ b/drivers/dma/ioat/dma_v2.c
@@ -0,0 +1,751 @@
+/*
+ * Intel I/OAT DMA Linux driver
+ * Copyright(c) 2004 - 2009 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+/*
+ * This driver supports an Intel I/OAT DMA engine (versions >= 2), which
+ * does asynchronous data movement and checksumming operations.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/interrupt.h>
+#include <linux/dmaengine.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/workqueue.h>
+#include <linux/i7300_idle.h>
+#include "dma.h"
+#include "dma_v2.h"
+#include "registers.h"
+#include "hw.h"
+
+static int ioat_ring_alloc_order = 8;
+module_param(ioat_ring_alloc_order, int, 0644);
+MODULE_PARM_DESC(ioat_ring_alloc_order,
+		 "ioat2+: allocate 2^n descriptors per channel (default: n=8)");
+
+static void __ioat2_issue_pending(struct ioat2_dma_chan *ioat)
+{
+	void * __iomem reg_base = ioat->base.reg_base;
+
+	ioat->pending = 0;
+	ioat->dmacount += ioat2_ring_pending(ioat);
+	ioat->issued = ioat->head;
+	/* make descriptor updates globally visible before notifying channel */
+	wmb();
+	writew(ioat->dmacount, reg_base + IOAT_CHAN_DMACOUNT_OFFSET);
+
+}
+
+static void ioat2_issue_pending(struct dma_chan *chan)
+{
+	struct ioat2_dma_chan *ioat = to_ioat2_chan(chan);
+
+	spin_lock_bh(&ioat->ring_lock);
+	if (ioat->pending == 1)
+		__ioat2_issue_pending(ioat);
+	spin_unlock_bh(&ioat->ring_lock);
+}
+
+/**
+ * ioat2_update_pending - log pending descriptors
+ * @ioat: ioat2+ channel
+ *
+ * set pending to '1' unless pending is already set to '2', pending == 2
+ * indicates that submission is temporarily blocked due to an in-flight
+ * reset.  If we are already above the ioat_pending_level threshold then
+ * just issue pending.
+ *
+ * called with ring_lock held
+ */
+static void ioat2_update_pending(struct ioat2_dma_chan *ioat)
+{
+	if (unlikely(ioat->pending == 2))
+		return;
+	else if (ioat2_ring_pending(ioat) > ioat_pending_level)
+		__ioat2_issue_pending(ioat);
+	else
+		ioat->pending = 1;
+}
+
+static void __ioat2_start_null_desc(struct ioat2_dma_chan *ioat)
+{
+	void __iomem *reg_base = ioat->base.reg_base;
+	struct ioat_ring_ent *desc;
+	struct ioat_dma_descriptor *hw;
+	int idx;
+
+	if (ioat2_ring_space(ioat) < 1) {
+		dev_err(to_dev(&ioat->base),
+			"Unable to start null desc - ring full\n");
+		spin_unlock_bh(&ioat->ring_lock);
+		return;
+	}
+
+	idx = ioat2_desc_alloc(ioat, 1);
+	desc = ioat2_get_ring_ent(ioat, idx);
+
+	hw = desc->hw;
+	hw->ctl = 0;
+	hw->ctl_f.null = 1;
+	hw->ctl_f.int_en = 1;
+	hw->ctl_f.compl_write = 1;
+	/* set size to non-zero value (channel returns error when size is 0) */
+	hw->size = NULL_DESC_BUFFER_SIZE;
+	hw->src_addr = 0;
+	hw->dst_addr = 0;
+	async_tx_ack(&desc->txd);
+	writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
+	       reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
+	writel(((u64) desc->txd.phys) >> 32,
+	       reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
+	__ioat2_issue_pending(ioat);
+}
+
+static void ioat2_start_null_desc(struct ioat2_dma_chan *ioat)
+{
+	spin_lock_bh(&ioat->ring_lock);
+	__ioat2_start_null_desc(ioat);
+	spin_unlock_bh(&ioat->ring_lock);
+}
+
+static void ioat2_cleanup(struct ioat2_dma_chan *ioat);
+
+/**
+ * ioat2_reset_part2 - reinit the channel after a reset
+ */
+static void ioat2_reset_part2(struct work_struct *work)
+{
+	struct ioat_chan_common *chan;
+	struct ioat2_dma_chan *ioat;
+
+	chan = container_of(work, struct ioat_chan_common, work.work);
+	ioat = container_of(chan, struct ioat2_dma_chan, base);
+
+	/* ensure that ->tail points to the stalled descriptor
+	 * (ioat->pending is set to 2 at this point so no new
+	 * descriptors will be issued while we perform this cleanup)
+	 */
+	ioat2_cleanup(ioat);
+
+	spin_lock_bh(&chan->cleanup_lock);
+	spin_lock_bh(&ioat->ring_lock);
+
+	/* set the tail to be re-issued */
+	ioat->issued = ioat->tail;
+	ioat->dmacount = 0;
+
+	if (ioat2_ring_pending(ioat)) {
+		struct ioat_ring_ent *desc;
+
+		desc = ioat2_get_ring_ent(ioat, ioat->tail);
+		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
+		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
+		writel(((u64) desc->txd.phys) >> 32,
+		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
+		__ioat2_issue_pending(ioat);
+	} else
+		__ioat2_start_null_desc(ioat);
+
+	spin_unlock_bh(&ioat->ring_lock);
+	spin_unlock_bh(&chan->cleanup_lock);
+
+	dev_info(to_dev(chan),
+		 "chan%d reset - %d descs waiting, %d total desc\n",
+		 chan_num(chan), ioat->dmacount, 1 << ioat->alloc_order);
+}
+
+/**
+ * ioat2_reset_channel - restart a channel
+ * @ioat: IOAT DMA channel handle
+ */
+static void ioat2_reset_channel(struct ioat2_dma_chan *ioat)
+{
+	u32 chansts, chanerr;
+	struct ioat_chan_common *chan = &ioat->base;
+	u16 active;
+
+	spin_lock_bh(&ioat->ring_lock);
+	active = ioat2_ring_active(ioat);
+	spin_unlock_bh(&ioat->ring_lock);
+	if (!active)
+		return;
+
+	chanerr = readl(chan->reg_base + IOAT_CHANERR_OFFSET);
+	chansts = (chan->completion_virt->low
+					& IOAT_CHANSTS_DMA_TRANSFER_STATUS);
+	if (chanerr) {
+		dev_err(to_dev(chan),
+			"chan%d, CHANSTS = 0x%08x CHANERR = 0x%04x, clearing\n",
+			chan_num(chan), chansts, chanerr);
+		writel(chanerr, chan->reg_base + IOAT_CHANERR_OFFSET);
+	}
+
+	spin_lock_bh(&ioat->ring_lock);
+	ioat->pending = 2;
+	writeb(IOAT_CHANCMD_RESET,
+	       chan->reg_base
+	       + IOAT_CHANCMD_OFFSET(chan->device->version));
+	spin_unlock_bh(&ioat->ring_lock);
+	schedule_delayed_work(&chan->work, RESET_DELAY);
+}
+
+/**
+ * ioat2_chan_watchdog - watch for stuck channels
+ */
+static void ioat2_chan_watchdog(struct work_struct *work)
+{
+	struct ioatdma_device *device =
+		container_of(work, struct ioatdma_device, work.work);
+	struct ioat2_dma_chan *ioat;
+	struct ioat_chan_common *chan;
+	u16 active;
+	int i;
+
+	for (i = 0; i < device->common.chancnt; i++) {
+		chan = ioat_chan_by_index(device, i);
+		ioat = container_of(chan, struct ioat2_dma_chan, base);
+
+		/*
+		 * for version 2.0 if there are descriptors yet to be processed
+		 * and the last completed hasn't changed since the last watchdog
+		 *      if they haven't hit the pending level
+		 *          issue the pending to push them through
+		 *      else
+		 *          try resetting the channel
+		 */
+		spin_lock_bh(&ioat->ring_lock);
+		active = ioat2_ring_active(ioat);
+		spin_unlock_bh(&ioat->ring_lock);
+
+		if (active &&
+		    chan->last_completion &&
+		    chan->last_completion == chan->watchdog_completion) {
+
+			if (ioat->pending == 1)
+				ioat2_issue_pending(&chan->common);
+			else {
+				ioat2_reset_channel(ioat);
+				chan->watchdog_completion = 0;
+			}
+		} else {
+			chan->last_compl_desc_addr_hw = 0;
+			chan->watchdog_completion = chan->last_completion;
+		}
+		chan->watchdog_last_tcp_cookie = chan->watchdog_tcp_cookie;
+	}
+	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
+}
+
+/**
+ * ioat2_cleanup - clean finished descriptors (advance tail pointer)
+ * @chan: ioat channel to be cleaned up
+ */
+static void ioat2_cleanup(struct ioat2_dma_chan *ioat)
+{
+	struct ioat_chan_common *chan = &ioat->base;
+	unsigned long phys_complete;
+	struct ioat_ring_ent *desc;
+	bool seen_current = false;
+	u16 active;
+	int i;
+	struct dma_async_tx_descriptor *tx;
+
+	prefetch(chan->completion_virt);
+
+	spin_lock_bh(&chan->cleanup_lock);
+	phys_complete = ioat_get_current_completion(chan);
+	if (phys_complete == chan->last_completion) {
+		spin_unlock_bh(&chan->cleanup_lock);
+		/*
+		 * perhaps we're stuck so hard that the watchdog can't go off?
+		 * try to catch it after WATCHDOG_DELAY seconds
+		 */
+		if (chan->device->version < IOAT_VER_3_0) {
+			unsigned long tmo;
+
+			tmo = chan->last_completion_time + HZ*WATCHDOG_DELAY;
+			if (time_after(jiffies, tmo)) {
+				ioat2_chan_watchdog(&(chan->device->work.work));
+				chan->last_completion_time = jiffies;
+			}
+		}
+		return;
+	}
+	chan->last_completion_time = jiffies;
+
+	spin_lock_bh(&ioat->ring_lock);
+
+	active = ioat2_ring_active(ioat);
+	for (i = 0; i < active && !seen_current; i++) {
+		prefetch(ioat2_get_ring_ent(ioat, ioat->tail + i + 1));
+		desc = ioat2_get_ring_ent(ioat, ioat->tail + i);
+		tx = &desc->txd;
+		if (tx->cookie) {
+			ioat_dma_unmap(chan, tx->flags, desc->len, desc->hw);
+			chan->completed_cookie = tx->cookie;
+			tx->cookie = 0;
+			if (tx->callback) {
+				tx->callback(tx->callback_param);
+				tx->callback = NULL;
+			}
+		}
+
+		if (tx->phys == phys_complete)
+			seen_current = true;
+	}
+	ioat->tail += i;
+	BUG_ON(!seen_current); /* no active descs have written a completion? */
+	spin_unlock_bh(&ioat->ring_lock);
+
+	chan->last_completion = phys_complete;
+
+	spin_unlock_bh(&chan->cleanup_lock);
+}
+
+static void ioat2_cleanup_tasklet(unsigned long data)
+{
+	struct ioat2_dma_chan *ioat = (void *) data;
+
+	ioat2_cleanup(ioat);
+	writew(IOAT_CHANCTRL_INT_DISABLE,
+	       ioat->base.reg_base + IOAT_CHANCTRL_OFFSET);
+}
+
+/**
+ * ioat2_enumerate_channels - find and initialize the device's channels
+ * @device: the device to be enumerated
+ */
+static int ioat2_enumerate_channels(struct ioatdma_device *device)
+{
+	struct ioat2_dma_chan *ioat;
+	struct device *dev = &device->pdev->dev;
+	struct dma_device *dma = &device->common;
+	u8 xfercap_log;
+	int i;
+
+	INIT_LIST_HEAD(&dma->channels);
+	dma->chancnt = readb(device->reg_base + IOAT_CHANCNT_OFFSET);
+	xfercap_log = readb(device->reg_base + IOAT_XFERCAP_OFFSET);
+	if (xfercap_log == 0)
+		return 0;
+
+	/* FIXME which i/oat version is i7300? */
+#ifdef CONFIG_I7300_IDLE_IOAT_CHANNEL
+	if (i7300_idle_platform_probe(NULL, NULL) == 0)
+		dma->chancnt--;
+#endif
+	for (i = 0; i < dma->chancnt; i++) {
+		ioat = devm_kzalloc(dev, sizeof(*ioat), GFP_KERNEL);
+		if (!ioat)
+			break;
+
+		ioat_init_channel(device, &ioat->base, i,
+				  ioat2_reset_part2,
+				  ioat2_cleanup_tasklet,
+				  (unsigned long) ioat);
+		ioat->xfercap_log = xfercap_log;
+		spin_lock_init(&ioat->ring_lock);
+	}
+	dma->chancnt = i;
+	return i;
+}
+
+static dma_cookie_t ioat2_tx_submit_unlock(struct dma_async_tx_descriptor *tx)
+{
+	struct dma_chan *c = tx->chan;
+	struct ioat2_dma_chan *ioat = to_ioat2_chan(c);
+	dma_cookie_t cookie = c->cookie;
+
+	cookie++;
+	if (cookie < 0)
+		cookie = 1;
+	tx->cookie = cookie;
+	c->cookie = cookie;
+	ioat2_update_pending(ioat);
+	spin_unlock_bh(&ioat->ring_lock);
+
+	return cookie;
+}
+
+static struct ioat_ring_ent *ioat2_alloc_ring_ent(struct dma_chan *chan)
+{
+	struct ioat_dma_descriptor *hw;
+	struct ioat_ring_ent *desc;
+	struct ioatdma_device *dma;
+	dma_addr_t phys;
+
+	dma = to_ioatdma_device(chan->device);
+	hw = pci_pool_alloc(dma->dma_pool, GFP_KERNEL, &phys);
+	if (!hw)
+		return NULL;
+	memset(hw, 0, sizeof(*hw));
+
+	desc = kzalloc(sizeof(*desc), GFP_KERNEL);
+	if (!desc) {
+		pci_pool_free(dma->dma_pool, hw, phys);
+		return NULL;
+	}
+
+	dma_async_tx_descriptor_init(&desc->txd, chan);
+	desc->txd.tx_submit = ioat2_tx_submit_unlock;
+	desc->hw = hw;
+	desc->txd.phys = phys;
+	return desc;
+}
+
+static void ioat2_free_ring_ent(struct ioat_ring_ent *desc, struct dma_chan *chan)
+{
+	struct ioatdma_device *dma;
+
+	dma = to_ioatdma_device(chan->device);
+	pci_pool_free(dma->dma_pool, desc->hw, desc->txd.phys);
+	kfree(desc);
+}
+
+/* ioat2_alloc_chan_resources - allocate/initialize ioat2 descriptor ring
+ * @chan: channel to be initialized
+ */
+static int ioat2_alloc_chan_resources(struct dma_chan *c)
+{
+	struct ioat2_dma_chan *ioat = to_ioat2_chan(c);
+	struct ioat_chan_common *chan = &ioat->base;
+	struct ioat_ring_ent **ring;
+	u16 chanctrl;
+	u32 chanerr;
+	int descs;
+	int i;
+
+	/* have we already been set up? */
+	if (ioat->ring)
+		return 1 << ioat->alloc_order;
+
+	/* Setup register to interrupt and write completion status on error */
+	chanctrl = IOAT_CHANCTRL_ERR_INT_EN | IOAT_CHANCTRL_ANY_ERR_ABORT_EN |
+		   IOAT_CHANCTRL_ERR_COMPLETION_EN;
+	writew(chanctrl, chan->reg_base + IOAT_CHANCTRL_OFFSET);
+
+	chanerr = readl(chan->reg_base + IOAT_CHANERR_OFFSET);
+	if (chanerr) {
+		dev_err(to_dev(chan), "CHANERR = %x, clearing\n", chanerr);
+		writel(chanerr, chan->reg_base + IOAT_CHANERR_OFFSET);
+	}
+
+	/* allocate a completion writeback area */
+	/* doing 2 32bit writes to mmio since 1 64b write doesn't work */
+	chan->completion_virt = pci_pool_alloc(chan->device->completion_pool,
+					       GFP_KERNEL,
+					       &chan->completion_addr);
+	if (!chan->completion_virt)
+		return -ENOMEM;
+
+	memset(chan->completion_virt, 0,
+	       sizeof(*chan->completion_virt));
+	writel(((u64) chan->completion_addr) & 0x00000000FFFFFFFF,
+	       chan->reg_base + IOAT_CHANCMP_OFFSET_LOW);
+	writel(((u64) chan->completion_addr) >> 32,
+	       chan->reg_base + IOAT_CHANCMP_OFFSET_HIGH);
+
+	ioat->alloc_order = ioat_get_alloc_order();
+	descs = 1 << ioat->alloc_order;
+
+	/* allocate the array to hold the software ring */
+	ring = kcalloc(descs, sizeof(*ring), GFP_KERNEL);
+	if (!ring)
+		return -ENOMEM;
+	for (i = 0; i < descs; i++) {
+		ring[i] = ioat2_alloc_ring_ent(c);
+		if (!ring[i]) {
+			while (i--)
+				ioat2_free_ring_ent(ring[i], c);
+			kfree(ring);
+			return -ENOMEM;
+		}
+	}
+
+	/* link descs */
+	for (i = 0; i < descs-1; i++) {
+		struct ioat_ring_ent *next = ring[i+1];
+		struct ioat_dma_descriptor *hw = ring[i]->hw;
+
+		hw->next = next->txd.phys;
+	}
+	ring[i]->hw->next = ring[0]->txd.phys;
+
+	spin_lock_bh(&ioat->ring_lock);
+	ioat->ring = ring;
+	ioat->head = 0;
+	ioat->issued = 0;
+	ioat->tail = 0;
+	ioat->pending = 0;
+	spin_unlock_bh(&ioat->ring_lock);
+
+	tasklet_enable(&chan->cleanup_task);
+	ioat2_start_null_desc(ioat);
+
+	return descs;
+}
+
+/**
+ * ioat2_alloc_and_lock - common descriptor alloc boilerplate for ioat2,3 ops
+ * @idx: gets starting descriptor index on successful allocation
+ * @ioat: ioat2,3 channel (ring) to operate on
+ * @num_descs: allocation length
+ */
+static int ioat2_alloc_and_lock(u16 *idx, struct ioat2_dma_chan *ioat, int num_descs)
+{
+	struct ioat_chan_common *chan = &ioat->base;
+
+	spin_lock_bh(&ioat->ring_lock);
+	if (unlikely(ioat2_ring_space(ioat) < num_descs)) {
+		if (printk_ratelimit())
+			dev_dbg(to_dev(chan),
+				"%s: ring full! num_descs: %d (%x:%x:%x)\n",
+				__func__, num_descs, ioat->head, ioat->tail,
+				ioat->issued);
+		spin_unlock_bh(&ioat->ring_lock);
+
+		/* do direct reclaim in the allocation failure case */
+		ioat2_cleanup(ioat);
+
+		return -ENOMEM;
+	}
+
+	dev_dbg(to_dev(chan), "%s: num_descs: %d (%x:%x:%x)\n",
+		__func__, num_descs, ioat->head, ioat->tail, ioat->issued);
+
+	*idx = ioat2_desc_alloc(ioat, num_descs);
+	return 0;  /* with ioat->ring_lock held */
+}
+
+static struct dma_async_tx_descriptor *
+ioat2_dma_prep_memcpy_lock(struct dma_chan *c, dma_addr_t dma_dest,
+			   dma_addr_t dma_src, size_t len, unsigned long flags)
+{
+	struct ioat2_dma_chan *ioat = to_ioat2_chan(c);
+	struct ioat_dma_descriptor *hw;
+	struct ioat_ring_ent *desc;
+	dma_addr_t dst = dma_dest;
+	dma_addr_t src = dma_src;
+	size_t total_len = len;
+	int num_descs;
+	u16 idx;
+	int i;
+
+	num_descs = ioat2_xferlen_to_descs(ioat, len);
+	if (likely(num_descs) &&
+	    ioat2_alloc_and_lock(&idx, ioat, num_descs) == 0)
+		/* pass */;
+	else
+		return NULL;
+	for (i = 0; i < num_descs; i++) {
+		size_t copy = min_t(size_t, len, 1 << ioat->xfercap_log);
+
+		desc = ioat2_get_ring_ent(ioat, idx + i);
+		hw = desc->hw;
+
+		hw->size = copy;
+		hw->ctl = 0;
+		hw->src_addr = src;
+		hw->dst_addr = dst;
+
+		len -= copy;
+		dst += copy;
+		src += copy;
+	}
+
+	desc->txd.flags = flags;
+	desc->len = total_len;
+	hw->ctl_f.int_en = !!(flags & DMA_PREP_INTERRUPT);
+	hw->ctl_f.compl_write = 1;
+	/* we leave the channel locked to ensure in order submission */
+
+	return &desc->txd;
+}
+
+/**
+ * ioat2_free_chan_resources - release all the descriptors
+ * @chan: the channel to be cleaned
+ */
+static void ioat2_free_chan_resources(struct dma_chan *c)
+{
+	struct ioat2_dma_chan *ioat = to_ioat2_chan(c);
+	struct ioat_chan_common *chan = &ioat->base;
+	struct ioatdma_device *ioatdma_device = chan->device;
+	struct ioat_ring_ent *desc;
+	const u16 total_descs = 1 << ioat->alloc_order;
+	int descs;
+	int i;
+
+	/* Before freeing channel resources first check
+	 * if they have been previously allocated for this channel.
+	 */
+	if (!ioat->ring)
+		return;
+
+	tasklet_disable(&chan->cleanup_task);
+	ioat2_cleanup(ioat);
+
+	/* Delay 100ms after reset to allow internal DMA logic to quiesce
+	 * before removing DMA descriptor resources.
+	 */
+	writeb(IOAT_CHANCMD_RESET,
+	       chan->reg_base + IOAT_CHANCMD_OFFSET(chan->device->version));
+	mdelay(100);
+
+	spin_lock_bh(&ioat->ring_lock);
+	descs = ioat2_ring_space(ioat);
+	for (i = 0; i < descs; i++) {
+		desc = ioat2_get_ring_ent(ioat, ioat->head + i);
+		ioat2_free_ring_ent(desc, c);
+	}
+
+	if (descs < total_descs)
+		dev_err(to_dev(chan), "Freeing %d in use descriptors!\n",
+			total_descs - descs);
+
+	for (i = 0; i < total_descs - descs; i++) {
+		desc = ioat2_get_ring_ent(ioat, ioat->tail + i);
+		ioat2_free_ring_ent(desc, c);
+	}
+
+	kfree(ioat->ring);
+	ioat->ring = NULL;
+	ioat->alloc_order = 0;
+	pci_pool_free(ioatdma_device->completion_pool,
+		      chan->completion_virt,
+		      chan->completion_addr);
+	spin_unlock_bh(&ioat->ring_lock);
+
+	chan->last_completion = 0;
+	chan->completion_addr = 0;
+	ioat->pending = 0;
+	ioat->dmacount = 0;
+	chan->watchdog_completion = 0;
+	chan->last_compl_desc_addr_hw = 0;
+	chan->watchdog_tcp_cookie = 0;
+	chan->watchdog_last_tcp_cookie = 0;
+}
+
+static enum dma_status
+ioat2_is_complete(struct dma_chan *c, dma_cookie_t cookie,
+		     dma_cookie_t *done, dma_cookie_t *used)
+{
+	struct ioat2_dma_chan *ioat = to_ioat2_chan(c);
+
+	if (ioat_is_complete(c, cookie, done, used) == DMA_SUCCESS)
+		return DMA_SUCCESS;
+
+	ioat2_cleanup(ioat);
+
+	return ioat_is_complete(c, cookie, done, used);
+}
+
+int ioat2_dma_probe(struct ioatdma_device *device, int dca)
+{
+	struct pci_dev *pdev = device->pdev;
+	struct dma_device *dma;
+	struct dma_chan *c;
+	struct ioat_chan_common *chan;
+	int err;
+
+	device->enumerate_channels = ioat2_enumerate_channels;
+	dma = &device->common;
+	dma->device_prep_dma_memcpy = ioat2_dma_prep_memcpy_lock;
+	dma->device_issue_pending = ioat2_issue_pending;
+	dma->device_alloc_chan_resources = ioat2_alloc_chan_resources;
+	dma->device_free_chan_resources = ioat2_free_chan_resources;
+	dma->device_is_tx_complete = ioat2_is_complete;
+
+	err = ioat_probe(device);
+	if (err)
+		return err;
+	ioat_set_tcp_copy_break(2048);
+
+	list_for_each_entry(c, &dma->channels, device_node) {
+		chan = to_chan_common(c);
+		writel(IOAT_DCACTRL_CMPL_WRITE_ENABLE | IOAT_DMA_DCA_ANY_CPU,
+		       chan->reg_base + IOAT_DCACTRL_OFFSET);
+	}
+
+	err = ioat_register(device);
+	if (err)
+		return err;
+	if (dca)
+		device->dca = ioat2_dca_init(pdev, device->reg_base);
+
+	INIT_DELAYED_WORK(&device->work, ioat2_chan_watchdog);
+	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
+
+	return err;
+}
+
+int ioat3_dma_probe(struct ioatdma_device *device, int dca)
+{
+	struct pci_dev *pdev = device->pdev;
+	struct dma_device *dma;
+	struct dma_chan *c;
+	struct ioat_chan_common *chan;
+	int err;
+	u16 dev_id;
+
+	device->enumerate_channels = ioat2_enumerate_channels;
+	dma = &device->common;
+	dma->device_prep_dma_memcpy = ioat2_dma_prep_memcpy_lock;
+	dma->device_issue_pending = ioat2_issue_pending;
+	dma->device_alloc_chan_resources = ioat2_alloc_chan_resources;
+	dma->device_free_chan_resources = ioat2_free_chan_resources;
+	dma->device_is_tx_complete = ioat2_is_complete;
+
+	/* -= IOAT ver.3 workarounds =- */
+	/* Write CHANERRMSK_INT with 3E07h to mask out the errors
+	 * that can cause stability issues for IOAT ver.3
+	 */
+	pci_write_config_dword(pdev, IOAT_PCI_CHANERRMASK_INT_OFFSET, 0x3e07);
+
+	/* Clear DMAUNCERRSTS Cfg-Reg Parity Error status bit
+	 * (workaround for spurious config parity error after restart)
+	 */
+	pci_read_config_word(pdev, IOAT_PCI_DEVICE_ID_OFFSET, &dev_id);
+	if (dev_id == PCI_DEVICE_ID_INTEL_IOAT_TBG0)
+		pci_write_config_dword(pdev, IOAT_PCI_DMAUNCERRSTS_OFFSET, 0x10);
+
+	err = ioat_probe(device);
+	if (err)
+		return err;
+	ioat_set_tcp_copy_break(262144);
+
+	list_for_each_entry(c, &dma->channels, device_node) {
+		chan = to_chan_common(c);
+		writel(IOAT_DMA_DCA_ANY_CPU,
+		       chan->reg_base + IOAT_DCACTRL_OFFSET);
+	}
+
+	err = ioat_register(device);
+	if (err)
+		return err;
+	if (dca)
+		device->dca = ioat3_dca_init(pdev, device->reg_base);
+
+	return err;
+}
diff --git a/drivers/dma/ioat/dma_v2.h b/drivers/dma/ioat/dma_v2.h
new file mode 100644
index 0000000..94a553e
--- /dev/null
+++ b/drivers/dma/ioat/dma_v2.h
@@ -0,0 +1,131 @@
+/*
+ * Copyright(c) 2004 - 2009 Intel Corporation. All rights reserved.
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
+#ifndef IOATDMA_V2_H
+#define IOATDMA_V2_H
+
+#include <linux/dmaengine.h>
+#include "dma.h"
+#include "hw.h"
+
+
+extern int ioat_pending_level;
+
+/*
+ * workaround for IOAT ver.3.0 null descriptor issue
+ * (channel returns error when size is 0)
+ */
+#define NULL_DESC_BUFFER_SIZE 1
+
+#define IOAT_MAX_ORDER 16
+#define ioat_get_alloc_order() \
+	(min(ioat_ring_alloc_order, IOAT_MAX_ORDER))
+
+/* struct ioat2_dma_chan - ioat v2 / v3 channel attributes
+ * @base: common ioat channel parameters
+ * @xfercap_log; log2 of channel max transfer length (for fast division)
+ * @head: allocated index
+ * @issued: hardware notification point
+ * @tail: cleanup index
+ * @pending: lock free indicator for issued != head
+ * @dmacount: identical to 'head' except for occasionally resetting to zero
+ * @alloc_order: log2 of the number of allocated descriptors
+ * @ring: software ring buffer implementation of hardware ring
+ * @ring_lock: protects ring attributes
+ */
+struct ioat2_dma_chan {
+	struct ioat_chan_common base;
+	size_t xfercap_log;
+	u16 head;
+	u16 issued;
+	u16 tail;
+	u16 dmacount;
+	u16 alloc_order;
+	int pending;
+	struct ioat_ring_ent **ring;
+	spinlock_t ring_lock;
+};
+
+static inline struct ioat2_dma_chan *to_ioat2_chan(struct dma_chan *c)
+{
+	struct ioat_chan_common *chan = to_chan_common(c);
+
+	return container_of(chan, struct ioat2_dma_chan, base);
+}
+
+static inline u16 ioat2_ring_mask(struct ioat2_dma_chan *ioat)
+{
+	return (1 << ioat->alloc_order) - 1;
+}
+
+/* count of descriptors in flight with the engine */
+static inline u16 ioat2_ring_active(struct ioat2_dma_chan *ioat)
+{
+	return (ioat->head - ioat->tail) & ioat2_ring_mask(ioat);
+}
+
+/* count of descriptors pending submission to hardware */
+static inline u16 ioat2_ring_pending(struct ioat2_dma_chan *ioat)
+{
+	return (ioat->head - ioat->issued) & ioat2_ring_mask(ioat);
+}
+
+static inline u16 ioat2_ring_space(struct ioat2_dma_chan *ioat)
+{
+	u16 num_descs = ioat2_ring_mask(ioat) + 1;
+	u16 active = ioat2_ring_active(ioat);
+
+	BUG_ON(active > num_descs);
+
+	return num_descs - active;
+}
+
+/* assumes caller already checked space */
+static inline u16 ioat2_desc_alloc(struct ioat2_dma_chan *ioat, u16 len)
+{
+	ioat->head += len;
+	return ioat->head - len;
+}
+
+static inline u16 ioat2_xferlen_to_descs(struct ioat2_dma_chan *ioat, size_t len)
+{
+	u16 num_descs = len >> ioat->xfercap_log;
+
+	num_descs += !!(len & ((1 << ioat->xfercap_log) - 1));
+	return num_descs;
+}
+
+struct ioat_ring_ent {
+	struct ioat_dma_descriptor *hw;
+	struct dma_async_tx_descriptor txd;
+	size_t len;
+};
+
+static inline struct ioat_ring_ent *
+ioat2_get_ring_ent(struct ioat2_dma_chan *ioat, u16 idx)
+{
+	return ioat->ring[idx & ioat2_ring_mask(ioat)];
+}
+
+int ioat2_dma_probe(struct ioatdma_device *dev, int dca);
+int ioat3_dma_probe(struct ioatdma_device *dev, int dca);
+struct dca_provider *ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase);
+struct dca_provider *ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase);
+#endif /* IOATDMA_V2_H */
diff --git a/drivers/dma/ioat/pci.c b/drivers/dma/ioat/pci.c
index 55414d8..c4e4322 100644
--- a/drivers/dma/ioat/pci.c
+++ b/drivers/dma/ioat/pci.c
@@ -31,6 +31,7 @@
 #include <linux/interrupt.h>
 #include <linux/dca.h>
 #include "dma.h"
+#include "dma_v2.h"
 #include "registers.h"
 #include "hw.h"
 

