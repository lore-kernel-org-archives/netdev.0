From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 04/29] ioat: cleanup some long deref chains and 80 column
	collisions
Date: Thu, 03 Sep 2009 19:30:50 -0700
Message-ID: <20090904023050.32667.67628.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52512 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932582AbZIDCat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 22:30:49 -0400
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* reduce device->common. to dma-> in ioat_dma_{probe,remove,selftest}
* ioat_lookup_chan_by_index to ioat_chan_by_index
* multi-line function definitions
* ioat_desc_sw.async_tx to ioat_desc_sw.txd
* desc->txd. to tx-> in cleanup routine

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c |  304 ++++++++++++++++++++++--------------------------
 drivers/dma/ioat/dma.h |    7 +
 2 files changed, 144 insertions(+), 167 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index 65f8b74..462dae6 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -55,9 +55,8 @@ ioat1_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan);
 static struct ioat_desc_sw *
 ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan);
 
-static inline struct ioat_dma_chan *ioat_lookup_chan_by_index(
-						struct ioatdma_device *device,
-						int index)
+static inline struct ioat_dma_chan *
+ioat_chan_by_index(struct ioatdma_device *device, int index)
 {
 	return device->idx[index];
 }
@@ -87,7 +86,7 @@ static irqreturn_t ioat_dma_do_interrupt(int irq, void *data)
 
 	attnstatus = readl(instance->reg_base + IOAT_ATTNSTATUS_OFFSET);
 	for_each_bit(bit, &attnstatus, BITS_PER_LONG) {
-		ioat_chan = ioat_lookup_chan_by_index(instance, bit);
+		ioat_chan = ioat_chan_by_index(instance, bit);
 		tasklet_schedule(&ioat_chan->cleanup_task);
 	}
 
@@ -205,8 +204,8 @@ static int ioat_dma_enumerate_channels(struct ioatdma_device *device)
  *                                 descriptors to hw
  * @chan: DMA channel handle
  */
-static inline void __ioat1_dma_memcpy_issue_pending(
-						struct ioat_dma_chan *ioat_chan)
+static inline void
+__ioat1_dma_memcpy_issue_pending(struct ioat_dma_chan *ioat_chan)
 {
 	ioat_chan->pending = 0;
 	writeb(IOAT_CHANCMD_APPEND, ioat_chan->reg_base + IOAT1_CHANCMD_OFFSET);
@@ -223,8 +222,8 @@ static void ioat1_dma_memcpy_issue_pending(struct dma_chan *chan)
 	}
 }
 
-static inline void __ioat2_dma_memcpy_issue_pending(
-						struct ioat_dma_chan *ioat_chan)
+static inline void
+__ioat2_dma_memcpy_issue_pending(struct ioat_dma_chan *ioat_chan)
 {
 	ioat_chan->pending = 0;
 	writew(ioat_chan->dmacount,
@@ -279,18 +278,18 @@ static void ioat_dma_chan_reset_part2(struct work_struct *work)
 	desc = to_ioat_desc(ioat_chan->used_desc.prev);
 	switch (ioat_chan->device->version) {
 	case IOAT_VER_1_2:
-		writel(((u64) desc->async_tx.phys) & 0x00000000FFFFFFFF,
+		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
 		       ioat_chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
-		writel(((u64) desc->async_tx.phys) >> 32,
+		writel(((u64) desc->txd.phys) >> 32,
 		       ioat_chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
 
 		writeb(IOAT_CHANCMD_START, ioat_chan->reg_base
 			+ IOAT_CHANCMD_OFFSET(ioat_chan->device->version));
 		break;
 	case IOAT_VER_2_0:
-		writel(((u64) desc->async_tx.phys) & 0x00000000FFFFFFFF,
+		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
 		       ioat_chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
-		writel(((u64) desc->async_tx.phys) >> 32,
+		writel(((u64) desc->txd.phys) >> 32,
 		       ioat_chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
 
 		/* tell the engine to go with what's left to be done */
@@ -299,7 +298,7 @@ static void ioat_dma_chan_reset_part2(struct work_struct *work)
 
 		break;
 	}
-	dev_err(&ioat_chan->device->pdev->dev,
+	dev_err(to_dev(ioat_chan),
 		"chan%d reset - %d descs waiting, %d total desc\n",
 		chan_num(ioat_chan), ioat_chan->dmacount, ioat_chan->desccount);
 
@@ -322,7 +321,7 @@ static void ioat_dma_reset_channel(struct ioat_dma_chan *ioat_chan)
 	chansts = (ioat_chan->completion_virt->low
 					& IOAT_CHANSTS_DMA_TRANSFER_STATUS);
 	if (chanerr) {
-		dev_err(&ioat_chan->device->pdev->dev,
+		dev_err(to_dev(ioat_chan),
 			"chan%d, CHANSTS = 0x%08x CHANERR = 0x%04x, clearing\n",
 			chan_num(ioat_chan), chansts, chanerr);
 		writel(chanerr, ioat_chan->reg_base + IOAT_CHANERR_OFFSET);
@@ -367,7 +366,7 @@ static void ioat_dma_chan_watchdog(struct work_struct *work)
 	unsigned long compl_desc_addr_hw;
 
 	for (i = 0; i < device->common.chancnt; i++) {
-		ioat_chan = ioat_lookup_chan_by_index(device, i);
+		ioat_chan = ioat_chan_by_index(device, i);
 
 		if (ioat_chan->device->version == IOAT_VER_1_2
 			/* have we started processing anything yet */
@@ -475,7 +474,7 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	len = first->len;
 	src = first->src;
 	dst = first->dst;
-	orig_flags = first->async_tx.flags;
+	orig_flags = first->txd.flags;
 	new = first;
 
 	spin_lock_bh(&ioat_chan->desc_lock);
@@ -484,7 +483,7 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	do {
 		copy = min_t(size_t, len, ioat_chan->xfercap);
 
-		async_tx_ack(&new->async_tx);
+		async_tx_ack(&new->txd);
 
 		hw = new->hw;
 		hw->size = copy;
@@ -495,7 +494,7 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 
 		/* chain together the physical address list for the HW */
 		wmb();
-		prev->hw->next = (u64) new->async_tx.phys;
+		prev->hw->next = (u64) new->txd.phys;
 
 		len -= copy;
 		dst += copy;
@@ -507,27 +506,26 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	} while (len && (new = ioat1_dma_get_next_descriptor(ioat_chan)));
 
 	if (!new) {
-		dev_err(&ioat_chan->device->pdev->dev,
-			"tx submit failed\n");
+		dev_err(to_dev(ioat_chan), "tx submit failed\n");
 		spin_unlock_bh(&ioat_chan->desc_lock);
 		return -ENOMEM;
 	}
 
 	hw->ctl = IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
-	if (first->async_tx.callback) {
+	if (first->txd.callback) {
 		hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_INT_GN;
 		if (first != new) {
 			/* move callback into to last desc */
-			new->async_tx.callback = first->async_tx.callback;
-			new->async_tx.callback_param
-					= first->async_tx.callback_param;
-			first->async_tx.callback = NULL;
-			first->async_tx.callback_param = NULL;
+			new->txd.callback = first->txd.callback;
+			new->txd.callback_param
+					= first->txd.callback_param;
+			first->txd.callback = NULL;
+			first->txd.callback_param = NULL;
 		}
 	}
 
 	new->tx_cnt = desc_count;
-	new->async_tx.flags = orig_flags; /* client is in control of this ack */
+	new->txd.flags = orig_flags; /* client is in control of this ack */
 
 	/* store the original values for use in later cleanup */
 	if (new != first) {
@@ -541,11 +539,11 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	cookie++;
 	if (cookie < 0)
 		cookie = 1;
-	ioat_chan->common.cookie = new->async_tx.cookie = cookie;
+	ioat_chan->common.cookie = new->txd.cookie = cookie;
 
 	/* write address into NextDescriptor field of last desc in chain */
 	to_ioat_desc(ioat_chan->used_desc.prev)->hw->next =
-							first->async_tx.phys;
+							first->txd.phys;
 	list_splice_tail(&new_chain, &ioat_chan->used_desc);
 
 	ioat_chan->dmacount += desc_count;
@@ -574,7 +572,7 @@ static dma_cookie_t ioat2_tx_submit(struct dma_async_tx_descriptor *tx)
 	len = first->len;
 	src = first->src;
 	dst = first->dst;
-	orig_flags = first->async_tx.flags;
+	orig_flags = first->txd.flags;
 	new = first;
 
 	/*
@@ -584,7 +582,7 @@ static dma_cookie_t ioat2_tx_submit(struct dma_async_tx_descriptor *tx)
 	do {
 		copy = min_t(size_t, len, ioat_chan->xfercap);
 
-		async_tx_ack(&new->async_tx);
+		async_tx_ack(&new->txd);
 
 		hw = new->hw;
 		hw->size = copy;
@@ -599,27 +597,26 @@ static dma_cookie_t ioat2_tx_submit(struct dma_async_tx_descriptor *tx)
 	} while (len && (new = ioat2_dma_get_next_descriptor(ioat_chan)));
 
 	if (!new) {
-		dev_err(&ioat_chan->device->pdev->dev,
-			"tx submit failed\n");
+		dev_err(to_dev(ioat_chan), "tx submit failed\n");
 		spin_unlock_bh(&ioat_chan->desc_lock);
 		return -ENOMEM;
 	}
 
 	hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
-	if (first->async_tx.callback) {
+	if (first->txd.callback) {
 		hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_INT_GN;
 		if (first != new) {
 			/* move callback into to last desc */
-			new->async_tx.callback = first->async_tx.callback;
-			new->async_tx.callback_param
-					= first->async_tx.callback_param;
-			first->async_tx.callback = NULL;
-			first->async_tx.callback_param = NULL;
+			new->txd.callback = first->txd.callback;
+			new->txd.callback_param
+					= first->txd.callback_param;
+			first->txd.callback = NULL;
+			first->txd.callback_param = NULL;
 		}
 	}
 
 	new->tx_cnt = desc_count;
-	new->async_tx.flags = orig_flags; /* client is in control of this ack */
+	new->txd.flags = orig_flags; /* client is in control of this ack */
 
 	/* store the original values for use in later cleanup */
 	if (new != first) {
@@ -633,7 +630,7 @@ static dma_cookie_t ioat2_tx_submit(struct dma_async_tx_descriptor *tx)
 	cookie++;
 	if (cookie < 0)
 		cookie = 1;
-	ioat_chan->common.cookie = new->async_tx.cookie = cookie;
+	ioat_chan->common.cookie = new->txd.cookie = cookie;
 
 	ioat_chan->dmacount += desc_count;
 	ioat_chan->pending += desc_count;
@@ -649,9 +646,8 @@ static dma_cookie_t ioat2_tx_submit(struct dma_async_tx_descriptor *tx)
  * @ioat_chan: the channel supplying the memory pool for the descriptors
  * @flags: allocation flags
  */
-static struct ioat_desc_sw *ioat_dma_alloc_descriptor(
-					struct ioat_dma_chan *ioat_chan,
-					gfp_t flags)
+static struct ioat_desc_sw *
+ioat_dma_alloc_descriptor(struct ioat_dma_chan *ioat_chan, gfp_t flags)
 {
 	struct ioat_dma_descriptor *desc;
 	struct ioat_desc_sw *desc_sw;
@@ -670,19 +666,19 @@ static struct ioat_desc_sw *ioat_dma_alloc_descriptor(
 	}
 
 	memset(desc, 0, sizeof(*desc));
-	dma_async_tx_descriptor_init(&desc_sw->async_tx, &ioat_chan->common);
+	dma_async_tx_descriptor_init(&desc_sw->txd, &ioat_chan->common);
 	switch (ioat_chan->device->version) {
 	case IOAT_VER_1_2:
-		desc_sw->async_tx.tx_submit = ioat1_tx_submit;
+		desc_sw->txd.tx_submit = ioat1_tx_submit;
 		break;
 	case IOAT_VER_2_0:
 	case IOAT_VER_3_0:
-		desc_sw->async_tx.tx_submit = ioat2_tx_submit;
+		desc_sw->txd.tx_submit = ioat2_tx_submit;
 		break;
 	}
 
 	desc_sw->hw = desc;
-	desc_sw->async_tx.phys = phys;
+	desc_sw->txd.phys = phys;
 
 	return desc_sw;
 }
@@ -712,9 +708,9 @@ static void ioat2_dma_massage_chan_desc(struct ioat_dma_chan *ioat_chan)
 
 	/* circle link the hw descriptors */
 	desc = to_ioat_desc(ioat_chan->free_desc.next);
-	desc->hw->next = to_ioat_desc(desc->node.next)->async_tx.phys;
+	desc->hw->next = to_ioat_desc(desc->node.next)->txd.phys;
 	list_for_each_entry_safe(desc, _desc, ioat_chan->free_desc.next, node) {
-		desc->hw->next = to_ioat_desc(desc->node.next)->async_tx.phys;
+		desc->hw->next = to_ioat_desc(desc->node.next)->txd.phys;
 	}
 }
 
@@ -743,8 +739,7 @@ static int ioat_dma_alloc_chan_resources(struct dma_chan *chan)
 
 	chanerr = readl(ioat_chan->reg_base + IOAT_CHANERR_OFFSET);
 	if (chanerr) {
-		dev_err(&ioat_chan->device->pdev->dev,
-			"CHANERR = %x, clearing\n", chanerr);
+		dev_err(to_dev(ioat_chan), "CHANERR = %x, clearing\n", chanerr);
 		writel(chanerr, ioat_chan->reg_base + IOAT_CHANERR_OFFSET);
 	}
 
@@ -752,7 +747,7 @@ static int ioat_dma_alloc_chan_resources(struct dma_chan *chan)
 	for (i = 0; i < ioat_initial_desc_count; i++) {
 		desc = ioat_dma_alloc_descriptor(ioat_chan, GFP_KERNEL);
 		if (!desc) {
-			dev_err(&ioat_chan->device->pdev->dev,
+			dev_err(to_dev(ioat_chan),
 				"Only %d initial descriptors\n", i);
 			break;
 		}
@@ -819,14 +814,14 @@ static void ioat_dma_free_chan_resources(struct dma_chan *chan)
 			in_use_descs++;
 			list_del(&desc->node);
 			pci_pool_free(ioatdma_device->dma_pool, desc->hw,
-				      desc->async_tx.phys);
+				      desc->txd.phys);
 			kfree(desc);
 		}
 		list_for_each_entry_safe(desc, _desc,
 					 &ioat_chan->free_desc, node) {
 			list_del(&desc->node);
 			pci_pool_free(ioatdma_device->dma_pool, desc->hw,
-				      desc->async_tx.phys);
+				      desc->txd.phys);
 			kfree(desc);
 		}
 		break;
@@ -836,12 +831,12 @@ static void ioat_dma_free_chan_resources(struct dma_chan *chan)
 					 ioat_chan->free_desc.next, node) {
 			list_del(&desc->node);
 			pci_pool_free(ioatdma_device->dma_pool, desc->hw,
-				      desc->async_tx.phys);
+				      desc->txd.phys);
 			kfree(desc);
 		}
 		desc = to_ioat_desc(ioat_chan->free_desc.next);
 		pci_pool_free(ioatdma_device->dma_pool, desc->hw,
-			      desc->async_tx.phys);
+			      desc->txd.phys);
 		kfree(desc);
 		INIT_LIST_HEAD(&ioat_chan->free_desc);
 		INIT_LIST_HEAD(&ioat_chan->used_desc);
@@ -855,8 +850,7 @@ static void ioat_dma_free_chan_resources(struct dma_chan *chan)
 
 	/* one is ok since we left it on there on purpose */
 	if (in_use_descs > 1)
-		dev_err(&ioat_chan->device->pdev->dev,
-			"Freeing %d in use descriptors!\n",
+		dev_err(to_dev(ioat_chan), "Freeing %d in use descriptors!\n",
 			in_use_descs - 1);
 
 	ioat_chan->last_completion = ioat_chan->completion_addr = 0;
@@ -889,8 +883,7 @@ ioat1_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan)
 		/* try to get another desc */
 		new = ioat_dma_alloc_descriptor(ioat_chan, GFP_ATOMIC);
 		if (!new) {
-			dev_err(&ioat_chan->device->pdev->dev,
-				"alloc failed\n");
+			dev_err(to_dev(ioat_chan), "alloc failed\n");
 			return NULL;
 		}
 	}
@@ -936,16 +929,15 @@ ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan)
 		for (i = 16; i; i--) {
 			desc = ioat_dma_alloc_descriptor(ioat_chan, GFP_ATOMIC);
 			if (!desc) {
-				dev_err(&ioat_chan->device->pdev->dev,
-					"alloc failed\n");
+				dev_err(to_dev(ioat_chan), "alloc failed\n");
 				break;
 			}
 			list_add_tail(&desc->node, ioat_chan->used_desc.next);
 
 			desc->hw->next
-				= to_ioat_desc(desc->node.next)->async_tx.phys;
+				= to_ioat_desc(desc->node.next)->txd.phys;
 			to_ioat_desc(desc->node.prev)->hw->next
-				= desc->async_tx.phys;
+				= desc->txd.phys;
 			ioat_chan->desccount++;
 		}
 
@@ -962,8 +954,8 @@ ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan)
 	return new;
 }
 
-static struct ioat_desc_sw *ioat_dma_get_next_descriptor(
-						struct ioat_dma_chan *ioat_chan)
+static struct ioat_desc_sw *
+ioat_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan)
 {
 	if (!ioat_chan)
 		return NULL;
@@ -978,12 +970,9 @@ static struct ioat_desc_sw *ioat_dma_get_next_descriptor(
 	return NULL;
 }
 
-static struct dma_async_tx_descriptor *ioat1_dma_prep_memcpy(
-						struct dma_chan *chan,
-						dma_addr_t dma_dest,
-						dma_addr_t dma_src,
-						size_t len,
-						unsigned long flags)
+static struct dma_async_tx_descriptor *
+ioat1_dma_prep_memcpy(struct dma_chan *chan, dma_addr_t dma_dest,
+		      dma_addr_t dma_src, size_t len, unsigned long flags)
 {
 	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
 	struct ioat_desc_sw *new;
@@ -996,22 +985,19 @@ static struct dma_async_tx_descriptor *ioat1_dma_prep_memcpy(
 		new->len = len;
 		new->dst = dma_dest;
 		new->src = dma_src;
-		new->async_tx.flags = flags;
-		return &new->async_tx;
+		new->txd.flags = flags;
+		return &new->txd;
 	} else {
-		dev_err(&ioat_chan->device->pdev->dev,
+		dev_err(to_dev(ioat_chan),
 			"chan%d - get_next_desc failed: %d descs waiting, %d total desc\n",
 			chan_num(ioat_chan), ioat_chan->dmacount, ioat_chan->desccount);
 		return NULL;
 	}
 }
 
-static struct dma_async_tx_descriptor *ioat2_dma_prep_memcpy(
-						struct dma_chan *chan,
-						dma_addr_t dma_dest,
-						dma_addr_t dma_src,
-						size_t len,
-						unsigned long flags)
+static struct dma_async_tx_descriptor *
+ioat2_dma_prep_memcpy(struct dma_chan *chan, dma_addr_t dma_dest,
+		      dma_addr_t dma_src, size_t len, unsigned long flags)
 {
 	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
 	struct ioat_desc_sw *new;
@@ -1028,11 +1014,11 @@ static struct dma_async_tx_descriptor *ioat2_dma_prep_memcpy(
 		new->len = len;
 		new->dst = dma_dest;
 		new->src = dma_src;
-		new->async_tx.flags = flags;
-		return &new->async_tx;
+		new->txd.flags = flags;
+		return &new->txd;
 	} else {
 		spin_unlock_bh(&ioat_chan->desc_lock);
-		dev_err(&ioat_chan->device->pdev->dev,
+		dev_err(to_dev(ioat_chan),
 			"chan%d - get_next_desc failed: %d descs waiting, %d total desc\n",
 			chan_num(ioat_chan), ioat_chan->dmacount, ioat_chan->desccount);
 		return NULL;
@@ -1050,8 +1036,8 @@ static void ioat_dma_cleanup_tasklet(unsigned long data)
 static void
 ioat_dma_unmap(struct ioat_dma_chan *ioat_chan, struct ioat_desc_sw *desc)
 {
-	if (!(desc->async_tx.flags & DMA_COMPL_SKIP_DEST_UNMAP)) {
-		if (desc->async_tx.flags & DMA_COMPL_DEST_UNMAP_SINGLE)
+	if (!(desc->txd.flags & DMA_COMPL_SKIP_DEST_UNMAP)) {
+		if (desc->txd.flags & DMA_COMPL_DEST_UNMAP_SINGLE)
 			pci_unmap_single(ioat_chan->device->pdev,
 					 pci_unmap_addr(desc, dst),
 					 pci_unmap_len(desc, len),
@@ -1063,8 +1049,8 @@ ioat_dma_unmap(struct ioat_dma_chan *ioat_chan, struct ioat_desc_sw *desc)
 				       PCI_DMA_FROMDEVICE);
 	}
 
-	if (!(desc->async_tx.flags & DMA_COMPL_SKIP_SRC_UNMAP)) {
-		if (desc->async_tx.flags & DMA_COMPL_SRC_UNMAP_SINGLE)
+	if (!(desc->txd.flags & DMA_COMPL_SKIP_SRC_UNMAP)) {
+		if (desc->txd.flags & DMA_COMPL_SRC_UNMAP_SINGLE)
 			pci_unmap_single(ioat_chan->device->pdev,
 					 pci_unmap_addr(desc, src),
 					 pci_unmap_len(desc, len),
@@ -1088,6 +1074,7 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 	dma_cookie_t cookie = 0;
 	unsigned long desc_phys;
 	struct ioat_desc_sw *latest_desc;
+	struct dma_async_tx_descriptor *tx;
 
 	prefetch(ioat_chan->completion_virt);
 
@@ -1111,8 +1098,7 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 	if ((ioat_chan->completion_virt->full
 		& IOAT_CHANSTS_DMA_TRANSFER_STATUS) ==
 				IOAT_CHANSTS_DMA_TRANSFER_STATUS_HALTED) {
-		dev_err(&ioat_chan->device->pdev->dev,
-			"Channel halted, chanerr = %x\n",
+		dev_err(to_dev(ioat_chan), "Channel halted, chanerr = %x\n",
 			readl(ioat_chan->reg_base + IOAT_CHANERR_OFFSET));
 
 		/* TODO do something to salvage the situation */
@@ -1145,38 +1131,38 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 	case IOAT_VER_1_2:
 		list_for_each_entry_safe(desc, _desc,
 					 &ioat_chan->used_desc, node) {
-
+			tx = &desc->txd;
 			/*
 			 * Incoming DMA requests may use multiple descriptors,
 			 * due to exceeding xfercap, perhaps. If so, only the
 			 * last one will have a cookie, and require unmapping.
 			 */
-			if (desc->async_tx.cookie) {
-				cookie = desc->async_tx.cookie;
+			if (tx->cookie) {
+				cookie = tx->cookie;
 				ioat_dma_unmap(ioat_chan, desc);
-				if (desc->async_tx.callback) {
-					desc->async_tx.callback(desc->async_tx.callback_param);
-					desc->async_tx.callback = NULL;
+				if (tx->callback) {
+					tx->callback(tx->callback_param);
+					tx->callback = NULL;
 				}
 			}
 
-			if (desc->async_tx.phys != phys_complete) {
+			if (tx->phys != phys_complete) {
 				/*
 				 * a completed entry, but not the last, so clean
 				 * up if the client is done with the descriptor
 				 */
-				if (async_tx_test_ack(&desc->async_tx)) {
+				if (async_tx_test_ack(tx)) {
 					list_move_tail(&desc->node,
 						       &ioat_chan->free_desc);
 				} else
-					desc->async_tx.cookie = 0;
+					tx->cookie = 0;
 			} else {
 				/*
 				 * last used desc. Do not remove, so we can
 				 * append from it, but don't look at it next
 				 * time, either
 				 */
-				desc->async_tx.cookie = 0;
+				tx->cookie = 0;
 
 				/* TODO check status bits? */
 				break;
@@ -1191,10 +1177,11 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 
 		/* work backwards to find latest finished desc */
 		desc = to_ioat_desc(ioat_chan->used_desc.next);
+		tx = &desc->txd;
 		latest_desc = NULL;
 		do {
 			desc = to_ioat_desc(desc->node.prev);
-			desc_phys = (unsigned long)desc->async_tx.phys
+			desc_phys = (unsigned long)tx->phys
 				       & IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
 			if (desc_phys == phys_complete) {
 				latest_desc = desc;
@@ -1203,19 +1190,18 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 		} while (&desc->node != ioat_chan->used_desc.prev);
 
 		if (latest_desc != NULL) {
-
 			/* work forwards to clear finished descriptors */
 			for (desc = to_ioat_desc(ioat_chan->used_desc.prev);
 			     &desc->node != latest_desc->node.next &&
 			     &desc->node != ioat_chan->used_desc.next;
 			     desc = to_ioat_desc(desc->node.next)) {
-				if (desc->async_tx.cookie) {
-					cookie = desc->async_tx.cookie;
-					desc->async_tx.cookie = 0;
+				if (tx->cookie) {
+					cookie = tx->cookie;
+					tx->cookie = 0;
 					ioat_dma_unmap(ioat_chan, desc);
-					if (desc->async_tx.callback) {
-						desc->async_tx.callback(desc->async_tx.callback_param);
-						desc->async_tx.callback = NULL;
+					if (tx->callback) {
+						tx->callback(tx->callback_param);
+						tx->callback = NULL;
 					}
 				}
 			}
@@ -1245,10 +1231,9 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
  * @done: if not %NULL, updated with last completed transaction
  * @used: if not %NULL, updated with last used transaction
  */
-static enum dma_status ioat_dma_is_complete(struct dma_chan *chan,
-					    dma_cookie_t cookie,
-					    dma_cookie_t *done,
-					    dma_cookie_t *used)
+static enum dma_status
+ioat_dma_is_complete(struct dma_chan *chan, dma_cookie_t cookie,
+		     dma_cookie_t *done, dma_cookie_t *used)
 {
 	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
 	dma_cookie_t last_used;
@@ -1290,7 +1275,7 @@ static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat_chan)
 	desc = ioat_dma_get_next_descriptor(ioat_chan);
 
 	if (!desc) {
-		dev_err(&ioat_chan->device->pdev->dev,
+		dev_err(to_dev(ioat_chan),
 			"Unable to start null desc - get next desc failed\n");
 		spin_unlock_bh(&ioat_chan->desc_lock);
 		return;
@@ -1303,15 +1288,15 @@ static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat_chan)
 	desc->hw->size = NULL_DESC_BUFFER_SIZE;
 	desc->hw->src_addr = 0;
 	desc->hw->dst_addr = 0;
-	async_tx_ack(&desc->async_tx);
+	async_tx_ack(&desc->txd);
 	switch (ioat_chan->device->version) {
 	case IOAT_VER_1_2:
 		desc->hw->next = 0;
 		list_add_tail(&desc->node, &ioat_chan->used_desc);
 
-		writel(((u64) desc->async_tx.phys) & 0x00000000FFFFFFFF,
+		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
 		       ioat_chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
-		writel(((u64) desc->async_tx.phys) >> 32,
+		writel(((u64) desc->txd.phys) >> 32,
 		       ioat_chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
 
 		writeb(IOAT_CHANCMD_START, ioat_chan->reg_base
@@ -1319,9 +1304,9 @@ static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat_chan)
 		break;
 	case IOAT_VER_2_0:
 	case IOAT_VER_3_0:
-		writel(((u64) desc->async_tx.phys) & 0x00000000FFFFFFFF,
+		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
 		       ioat_chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
-		writel(((u64) desc->async_tx.phys) >> 32,
+		writel(((u64) desc->txd.phys) >> 32,
 		       ioat_chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
 
 		ioat_chan->dmacount++;
@@ -1352,6 +1337,8 @@ static int ioat_dma_self_test(struct ioatdma_device *device)
 	int i;
 	u8 *src;
 	u8 *dest;
+	struct dma_device *dma = &device->common;
+	struct device *dev = &device->pdev->dev;
 	struct dma_chan *dma_chan;
 	struct dma_async_tx_descriptor *tx;
 	dma_addr_t dma_dest, dma_src;
@@ -1375,26 +1362,21 @@ static int ioat_dma_self_test(struct ioatdma_device *device)
 		src[i] = (u8)i;
 
 	/* Start copy, using first DMA channel */
-	dma_chan = container_of(device->common.channels.next,
-				struct dma_chan,
+	dma_chan = container_of(dma->channels.next, struct dma_chan,
 				device_node);
-	if (device->common.device_alloc_chan_resources(dma_chan) < 1) {
-		dev_err(&device->pdev->dev,
-			"selftest cannot allocate chan resource\n");
+	if (dma->device_alloc_chan_resources(dma_chan) < 1) {
+		dev_err(dev, "selftest cannot allocate chan resource\n");
 		err = -ENODEV;
 		goto out;
 	}
 
-	dma_src = dma_map_single(dma_chan->device->dev, src, IOAT_TEST_SIZE,
-				 DMA_TO_DEVICE);
-	dma_dest = dma_map_single(dma_chan->device->dev, dest, IOAT_TEST_SIZE,
-				  DMA_FROM_DEVICE);
+	dma_src = dma_map_single(dev, src, IOAT_TEST_SIZE, DMA_TO_DEVICE);
+	dma_dest = dma_map_single(dev, dest, IOAT_TEST_SIZE, DMA_FROM_DEVICE);
 	flags = DMA_COMPL_SRC_UNMAP_SINGLE | DMA_COMPL_DEST_UNMAP_SINGLE;
 	tx = device->common.device_prep_dma_memcpy(dma_chan, dma_dest, dma_src,
 						   IOAT_TEST_SIZE, flags);
 	if (!tx) {
-		dev_err(&device->pdev->dev,
-			"Self-test prep failed, disabling\n");
+		dev_err(dev, "Self-test prep failed, disabling\n");
 		err = -ENODEV;
 		goto free_resources;
 	}
@@ -1405,32 +1387,29 @@ static int ioat_dma_self_test(struct ioatdma_device *device)
 	tx->callback_param = &cmp;
 	cookie = tx->tx_submit(tx);
 	if (cookie < 0) {
-		dev_err(&device->pdev->dev,
-			"Self-test setup failed, disabling\n");
+		dev_err(dev, "Self-test setup failed, disabling\n");
 		err = -ENODEV;
 		goto free_resources;
 	}
-	device->common.device_issue_pending(dma_chan);
+	dma->device_issue_pending(dma_chan);
 
 	tmo = wait_for_completion_timeout(&cmp, msecs_to_jiffies(3000));
 
 	if (tmo == 0 ||
-	    device->common.device_is_tx_complete(dma_chan, cookie, NULL, NULL)
+	    dma->device_is_tx_complete(dma_chan, cookie, NULL, NULL)
 					!= DMA_SUCCESS) {
-		dev_err(&device->pdev->dev,
-			"Self-test copy timed out, disabling\n");
+		dev_err(dev, "Self-test copy timed out, disabling\n");
 		err = -ENODEV;
 		goto free_resources;
 	}
 	if (memcmp(src, dest, IOAT_TEST_SIZE)) {
-		dev_err(&device->pdev->dev,
-			"Self-test copy failed compare, disabling\n");
+		dev_err(dev, "Self-test copy failed compare, disabling\n");
 		err = -ENODEV;
 		goto free_resources;
 	}
 
 free_resources:
-	device->common.device_free_chan_resources(dma_chan);
+	dma->device_free_chan_resources(dma_chan);
 out:
 	kfree(src);
 	kfree(dest);
@@ -1483,15 +1462,14 @@ msix:
 
 	for (i = 0; i < msixcnt; i++) {
 		msix = &device->msix_entries[i];
-		ioat_chan = ioat_lookup_chan_by_index(device, i);
+		ioat_chan = ioat_chan_by_index(device, i);
 		err = devm_request_irq(dev, msix->vector,
 				       ioat_dma_do_interrupt_msix, 0,
 				       "ioat-msix", ioat_chan);
 		if (err) {
 			for (j = 0; j < i; j++) {
 				msix = &device->msix_entries[j];
-				ioat_chan =
-					ioat_lookup_chan_by_index(device, j);
+				ioat_chan = ioat_chan_by_index(device, j);
 				devm_free_irq(dev, msix->vector, ioat_chan);
 			}
 			goto msix_single_vector;
@@ -1561,12 +1539,13 @@ static void ioat_disable_interrupts(struct ioatdma_device *device)
 	writeb(0, device->reg_base + IOAT_INTRCTRL_OFFSET);
 }
 
-struct ioatdma_device *ioat_dma_probe(struct pci_dev *pdev,
-				      void __iomem *iobase)
+struct ioatdma_device *
+ioat_dma_probe(struct pci_dev *pdev, void __iomem *iobase)
 {
 	int err;
 	struct device *dev = &pdev->dev;
 	struct ioatdma_device *device;
+	struct dma_device *dma;
 
 	device = devm_kzalloc(dev, sizeof(*device), GFP_KERNEL);
 	if (!device)
@@ -1574,6 +1553,7 @@ struct ioatdma_device *ioat_dma_probe(struct pci_dev *pdev,
 	device->pdev = pdev;
 	device->reg_base = iobase;
 	device->version = readb(device->reg_base + IOAT_VER_OFFSET);
+	dma = &device->common;
 
 	/* DMA coherent memory pool for DMA descriptor allocations */
 	device->dma_pool = pci_pool_create("dma_desc_pool", pdev,
@@ -1592,36 +1572,32 @@ struct ioatdma_device *ioat_dma_probe(struct pci_dev *pdev,
 		goto err_completion_pool;
 	}
 
-	INIT_LIST_HEAD(&device->common.channels);
+	INIT_LIST_HEAD(&dma->channels);
 	ioat_dma_enumerate_channels(device);
 
-	device->common.device_alloc_chan_resources =
-						ioat_dma_alloc_chan_resources;
-	device->common.device_free_chan_resources =
-						ioat_dma_free_chan_resources;
-	device->common.dev = &pdev->dev;
+	dma->device_alloc_chan_resources = ioat_dma_alloc_chan_resources;
+	dma->device_free_chan_resources = ioat_dma_free_chan_resources;
+	dma->dev = &pdev->dev;
 
-	dma_cap_set(DMA_MEMCPY, device->common.cap_mask);
-	device->common.device_is_tx_complete = ioat_dma_is_complete;
+	dma_cap_set(DMA_MEMCPY, dma->cap_mask);
+	dma->device_is_tx_complete = ioat_dma_is_complete;
 	switch (device->version) {
 	case IOAT_VER_1_2:
-		device->common.device_prep_dma_memcpy = ioat1_dma_prep_memcpy;
-		device->common.device_issue_pending =
-						ioat1_dma_memcpy_issue_pending;
+		dma->device_prep_dma_memcpy = ioat1_dma_prep_memcpy;
+		dma->device_issue_pending = ioat1_dma_memcpy_issue_pending;
 		break;
 	case IOAT_VER_2_0:
 	case IOAT_VER_3_0:
-		device->common.device_prep_dma_memcpy = ioat2_dma_prep_memcpy;
-		device->common.device_issue_pending =
-						ioat2_dma_memcpy_issue_pending;
+		dma->device_prep_dma_memcpy = ioat2_dma_prep_memcpy;
+		dma->device_issue_pending = ioat2_dma_memcpy_issue_pending;
 		break;
 	}
 
 	dev_err(dev, "Intel(R) I/OAT DMA Engine found,"
 		" %d channels, device version 0x%02x, driver version %s\n",
-		device->common.chancnt, device->version, IOAT_DMA_VERSION);
+		dma->chancnt, device->version, IOAT_DMA_VERSION);
 
-	if (!device->common.chancnt) {
+	if (!dma->chancnt) {
 		dev_err(dev, "Intel(R) I/OAT DMA Engine problem found: "
 			"zero channels detected\n");
 		goto err_setup_interrupts;
@@ -1635,7 +1611,7 @@ struct ioatdma_device *ioat_dma_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_self_test;
 
-	err = dma_async_device_register(&device->common);
+	err = dma_async_device_register(dma);
 	if (err)
 		goto err_self_test;
 
@@ -1663,19 +1639,19 @@ void ioat_dma_remove(struct ioatdma_device *device)
 {
 	struct dma_chan *chan, *_chan;
 	struct ioat_dma_chan *ioat_chan;
+	struct dma_device *dma = &device->common;
 
 	if (device->version != IOAT_VER_3_0)
 		cancel_delayed_work(&device->work);
 
 	ioat_disable_interrupts(device);
 
-	dma_async_device_unregister(&device->common);
+	dma_async_device_unregister(dma);
 
 	pci_pool_destroy(device->dma_pool);
 	pci_pool_destroy(device->completion_pool);
 
-	list_for_each_entry_safe(chan, _chan,
-				 &device->common.channels, device_node) {
+	list_for_each_entry_safe(chan, _chan, &dma->channels, device_node) {
 		ioat_chan = to_ioat_chan(chan);
 		list_del(&chan->device_node);
 	}
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index 5e8d7cf..c5eabae 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -38,7 +38,8 @@
 #define to_ioat_chan(chan) container_of(chan, struct ioat_dma_chan, common)
 #define to_ioatdma_device(dev) container_of(dev, struct ioatdma_device, common)
 #define to_ioat_desc(lh) container_of(lh, struct ioat_desc_sw, node)
-#define tx_to_ioat_desc(tx) container_of(tx, struct ioat_desc_sw, async_tx)
+#define tx_to_ioat_desc(tx) container_of(tx, struct ioat_desc_sw, txd)
+#define to_dev(ioat_chan) (&(ioat_chan)->device->pdev->dev)
 
 #define chan_num(ch) ((int)((ch)->reg_base - (ch)->device->reg_base) / 0x80)
 
@@ -123,7 +124,7 @@ struct ioat_dma_chan {
  * @node: this descriptor will either be on the free list,
  *     or attached to a transaction list (async_tx.tx_list)
  * @tx_cnt: number of descriptors required to complete the transaction
- * @async_tx: the generic software descriptor for all engines
+ * @txd: the generic software descriptor for all engines
  */
 struct ioat_desc_sw {
 	struct ioat_dma_descriptor *hw;
@@ -132,7 +133,7 @@ struct ioat_desc_sw {
 	size_t len;
 	dma_addr_t src;
 	dma_addr_t dst;
-	struct dma_async_tx_descriptor async_tx;
+	struct dma_async_tx_descriptor txd;
 };
 
 static inline void ioat_set_tcp_copy_break(struct ioatdma_device *dev)

