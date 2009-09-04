From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 11/29] ioat: prepare the code for ioat[12]_dma_chan split
Date: Thu, 03 Sep 2009 19:31:26 -0700
Message-ID: <20090904023125.32667.71714.stgit@dwillia2-linux.ch.intel.com>
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

Prepare the code for the conversion of the ioat2 linked-list-ring into a
native ring buffer.  After this conversion ioat2 channels will share
less of the ioat1 infrastructure, but there will still be places where
sharing is possible.  struct ioat_chan_common is created to house the
channel attributes that will remain common between ioat1 and ioat2
channels.

For every routine that accesses both common and hardware specific fields
the old unified 'ioat_chan' pointer is split into an 'ioat' and  'chan'
pointer.  Where 'chan' references common fields and 'ioat' the
hardware/version specific.

[ Impact: pure structure member movement/variable renames, no logic changes ]

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c |  711 ++++++++++++++++++++++++------------------------
 drivers/dma/ioat/dma.h |   49 ++-
 2 files changed, 390 insertions(+), 370 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index cc5c557..2e81e0c 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -47,15 +47,15 @@ static void ioat_dma_chan_reset_part2(struct work_struct *work);
 static void ioat_dma_chan_watchdog(struct work_struct *work);
 
 /* internal functions */
-static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat_chan);
-static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan);
+static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat);
+static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat);
 
 static struct ioat_desc_sw *
-ioat1_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan);
+ioat1_dma_get_next_descriptor(struct ioat_dma_chan *ioat);
 static struct ioat_desc_sw *
-ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan);
+ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat);
 
-static inline struct ioat_dma_chan *
+static inline struct ioat_chan_common *
 ioat_chan_by_index(struct ioatdma_device *device, int index)
 {
 	return device->idx[index];
@@ -69,7 +69,7 @@ ioat_chan_by_index(struct ioatdma_device *device, int index)
 static irqreturn_t ioat_dma_do_interrupt(int irq, void *data)
 {
 	struct ioatdma_device *instance = data;
-	struct ioat_dma_chan *ioat_chan;
+	struct ioat_chan_common *chan;
 	unsigned long attnstatus;
 	int bit;
 	u8 intrctrl;
@@ -86,8 +86,8 @@ static irqreturn_t ioat_dma_do_interrupt(int irq, void *data)
 
 	attnstatus = readl(instance->reg_base + IOAT_ATTNSTATUS_OFFSET);
 	for_each_bit(bit, &attnstatus, BITS_PER_LONG) {
-		ioat_chan = ioat_chan_by_index(instance, bit);
-		tasklet_schedule(&ioat_chan->cleanup_task);
+		chan = ioat_chan_by_index(instance, bit);
+		tasklet_schedule(&chan->cleanup_task);
 	}
 
 	writeb(intrctrl, instance->reg_base + IOAT_INTRCTRL_OFFSET);
@@ -101,9 +101,9 @@ static irqreturn_t ioat_dma_do_interrupt(int irq, void *data)
  */
 static irqreturn_t ioat_dma_do_interrupt_msix(int irq, void *data)
 {
-	struct ioat_dma_chan *ioat_chan = data;
+	struct ioat_chan_common *chan = data;
 
-	tasklet_schedule(&ioat_chan->cleanup_task);
+	tasklet_schedule(&chan->cleanup_task);
 
 	return IRQ_HANDLED;
 }
@@ -119,7 +119,8 @@ static int ioat_dma_enumerate_channels(struct ioatdma_device *device)
 	u8 xfercap_scale;
 	u32 xfercap;
 	int i;
-	struct ioat_dma_chan *ioat_chan;
+	struct ioat_chan_common *chan;
+	struct ioat_dma_chan *ioat;
 	struct device *dev = &device->pdev->dev;
 	struct dma_device *dma = &device->common;
 
@@ -133,29 +134,30 @@ static int ioat_dma_enumerate_channels(struct ioatdma_device *device)
 		dma->chancnt--;
 #endif
 	for (i = 0; i < dma->chancnt; i++) {
-		ioat_chan = devm_kzalloc(dev, sizeof(*ioat_chan), GFP_KERNEL);
-		if (!ioat_chan) {
+		ioat = devm_kzalloc(dev, sizeof(*ioat), GFP_KERNEL);
+		if (!ioat) {
 			dma->chancnt = i;
 			break;
 		}
 
-		ioat_chan->device = device;
-		ioat_chan->reg_base = device->reg_base + (0x80 * (i + 1));
-		ioat_chan->xfercap = xfercap;
-		ioat_chan->desccount = 0;
-		INIT_DELAYED_WORK(&ioat_chan->work, ioat_dma_chan_reset_part2);
-		spin_lock_init(&ioat_chan->cleanup_lock);
-		spin_lock_init(&ioat_chan->desc_lock);
-		INIT_LIST_HEAD(&ioat_chan->free_desc);
-		INIT_LIST_HEAD(&ioat_chan->used_desc);
+		chan = &ioat->base;
+		chan->device = device;
+		chan->reg_base = device->reg_base + (0x80 * (i + 1));
+		ioat->xfercap = xfercap;
+		ioat->desccount = 0;
+		INIT_DELAYED_WORK(&chan->work, ioat_dma_chan_reset_part2);
+		spin_lock_init(&chan->cleanup_lock);
+		spin_lock_init(&ioat->desc_lock);
+		INIT_LIST_HEAD(&ioat->free_desc);
+		INIT_LIST_HEAD(&ioat->used_desc);
 		/* This should be made common somewhere in dmaengine.c */
-		ioat_chan->common.device = &device->common;
-		list_add_tail(&ioat_chan->common.device_node, &dma->channels);
-		device->idx[i] = ioat_chan;
-		tasklet_init(&ioat_chan->cleanup_task,
+		chan->common.device = &device->common;
+		list_add_tail(&chan->common.device_node, &dma->channels);
+		device->idx[i] = chan;
+		tasklet_init(&chan->cleanup_task,
 			     ioat_dma_cleanup_tasklet,
-			     (unsigned long) ioat_chan);
-		tasklet_disable(&ioat_chan->cleanup_task);
+			     (unsigned long) ioat);
+		tasklet_disable(&chan->cleanup_task);
 	}
 	return dma->chancnt;
 }
@@ -166,39 +168,42 @@ static int ioat_dma_enumerate_channels(struct ioatdma_device *device)
  * @chan: DMA channel handle
  */
 static inline void
-__ioat1_dma_memcpy_issue_pending(struct ioat_dma_chan *ioat_chan)
+__ioat1_dma_memcpy_issue_pending(struct ioat_dma_chan *ioat)
 {
-	ioat_chan->pending = 0;
-	writeb(IOAT_CHANCMD_APPEND, ioat_chan->reg_base + IOAT1_CHANCMD_OFFSET);
+	void __iomem *reg_base = ioat->base.reg_base;
+
+	ioat->pending = 0;
+	writeb(IOAT_CHANCMD_APPEND, reg_base + IOAT1_CHANCMD_OFFSET);
 }
 
 static void ioat1_dma_memcpy_issue_pending(struct dma_chan *chan)
 {
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_dma_chan *ioat = to_ioat_chan(chan);
 
-	if (ioat_chan->pending > 0) {
-		spin_lock_bh(&ioat_chan->desc_lock);
-		__ioat1_dma_memcpy_issue_pending(ioat_chan);
-		spin_unlock_bh(&ioat_chan->desc_lock);
+	if (ioat->pending > 0) {
+		spin_lock_bh(&ioat->desc_lock);
+		__ioat1_dma_memcpy_issue_pending(ioat);
+		spin_unlock_bh(&ioat->desc_lock);
 	}
 }
 
 static inline void
-__ioat2_dma_memcpy_issue_pending(struct ioat_dma_chan *ioat_chan)
+__ioat2_dma_memcpy_issue_pending(struct ioat_dma_chan *ioat)
 {
-	ioat_chan->pending = 0;
-	writew(ioat_chan->dmacount,
-	       ioat_chan->reg_base + IOAT_CHAN_DMACOUNT_OFFSET);
+	void __iomem *reg_base = ioat->base.reg_base;
+
+	ioat->pending = 0;
+	writew(ioat->dmacount, reg_base + IOAT_CHAN_DMACOUNT_OFFSET);
 }
 
 static void ioat2_dma_memcpy_issue_pending(struct dma_chan *chan)
 {
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_dma_chan *ioat = to_ioat_chan(chan);
 
-	if (ioat_chan->pending > 0) {
-		spin_lock_bh(&ioat_chan->desc_lock);
-		__ioat2_dma_memcpy_issue_pending(ioat_chan);
-		spin_unlock_bh(&ioat_chan->desc_lock);
+	if (ioat->pending > 0) {
+		spin_lock_bh(&ioat->desc_lock);
+		__ioat2_dma_memcpy_issue_pending(ioat);
+		spin_unlock_bh(&ioat->desc_lock);
 	}
 }
 
@@ -208,84 +213,88 @@ static void ioat2_dma_memcpy_issue_pending(struct dma_chan *chan)
  */
 static void ioat_dma_chan_reset_part2(struct work_struct *work)
 {
-	struct ioat_dma_chan *ioat_chan =
-		container_of(work, struct ioat_dma_chan, work.work);
+	struct ioat_chan_common *chan;
+	struct ioat_dma_chan *ioat;
 	struct ioat_desc_sw *desc;
 
-	spin_lock_bh(&ioat_chan->cleanup_lock);
-	spin_lock_bh(&ioat_chan->desc_lock);
+	chan = container_of(work, struct ioat_chan_common, work.work);
+	ioat = container_of(chan, struct ioat_dma_chan, base);
+	spin_lock_bh(&chan->cleanup_lock);
+	spin_lock_bh(&ioat->desc_lock);
 
-	ioat_chan->completion_virt->low = 0;
-	ioat_chan->completion_virt->high = 0;
-	ioat_chan->pending = 0;
+	chan->completion_virt->low = 0;
+	chan->completion_virt->high = 0;
+	ioat->pending = 0;
 
 	/*
 	 * count the descriptors waiting, and be sure to do it
 	 * right for both the CB1 line and the CB2 ring
 	 */
-	ioat_chan->dmacount = 0;
-	if (ioat_chan->used_desc.prev) {
-		desc = to_ioat_desc(ioat_chan->used_desc.prev);
+	ioat->dmacount = 0;
+	if (ioat->used_desc.prev) {
+		desc = to_ioat_desc(ioat->used_desc.prev);
 		do {
-			ioat_chan->dmacount++;
+			ioat->dmacount++;
 			desc = to_ioat_desc(desc->node.next);
-		} while (&desc->node != ioat_chan->used_desc.next);
+		} while (&desc->node != ioat->used_desc.next);
 	}
 
 	/*
 	 * write the new starting descriptor address
 	 * this puts channel engine into ARMED state
 	 */
-	desc = to_ioat_desc(ioat_chan->used_desc.prev);
-	switch (ioat_chan->device->version) {
+	desc = to_ioat_desc(ioat->used_desc.prev);
+	switch (chan->device->version) {
 	case IOAT_VER_1_2:
 		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
-		       ioat_chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
+		       chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
 		writel(((u64) desc->txd.phys) >> 32,
-		       ioat_chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
+		       chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
 
-		writeb(IOAT_CHANCMD_START, ioat_chan->reg_base
-			+ IOAT_CHANCMD_OFFSET(ioat_chan->device->version));
+		writeb(IOAT_CHANCMD_START, chan->reg_base
+			+ IOAT_CHANCMD_OFFSET(chan->device->version));
 		break;
 	case IOAT_VER_2_0:
 		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
-		       ioat_chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
+		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
 		writel(((u64) desc->txd.phys) >> 32,
-		       ioat_chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
+		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
 
 		/* tell the engine to go with what's left to be done */
-		writew(ioat_chan->dmacount,
-		       ioat_chan->reg_base + IOAT_CHAN_DMACOUNT_OFFSET);
+		writew(ioat->dmacount,
+		       chan->reg_base + IOAT_CHAN_DMACOUNT_OFFSET);
 
 		break;
 	}
-	dev_err(to_dev(ioat_chan),
+	dev_err(to_dev(chan),
 		"chan%d reset - %d descs waiting, %d total desc\n",
-		chan_num(ioat_chan), ioat_chan->dmacount, ioat_chan->desccount);
+		chan_num(chan), ioat->dmacount, ioat->desccount);
 
-	spin_unlock_bh(&ioat_chan->desc_lock);
-	spin_unlock_bh(&ioat_chan->cleanup_lock);
+	spin_unlock_bh(&ioat->desc_lock);
+	spin_unlock_bh(&chan->cleanup_lock);
 }
 
 /**
  * ioat_dma_reset_channel - restart a channel
- * @ioat_chan: IOAT DMA channel handle
+ * @ioat: IOAT DMA channel handle
  */
-static void ioat_dma_reset_channel(struct ioat_dma_chan *ioat_chan)
+static void ioat_dma_reset_channel(struct ioat_dma_chan *ioat)
 {
+	struct ioat_chan_common *chan = &ioat->base;
+	void __iomem *reg_base = chan->reg_base;
 	u32 chansts, chanerr;
 
-	if (!ioat_chan->used_desc.prev)
+	if (!ioat->used_desc.prev)
 		return;
 
-	chanerr = readl(ioat_chan->reg_base + IOAT_CHANERR_OFFSET);
-	chansts = (ioat_chan->completion_virt->low
+	chanerr = readl(reg_base + IOAT_CHANERR_OFFSET);
+	chansts = (chan->completion_virt->low
 					& IOAT_CHANSTS_DMA_TRANSFER_STATUS);
 	if (chanerr) {
-		dev_err(to_dev(ioat_chan),
+		dev_err(to_dev(chan),
 			"chan%d, CHANSTS = 0x%08x CHANERR = 0x%04x, clearing\n",
-			chan_num(ioat_chan), chansts, chanerr);
-		writel(chanerr, ioat_chan->reg_base + IOAT_CHANERR_OFFSET);
+			chan_num(chan), chansts, chanerr);
+		writel(chanerr, reg_base + IOAT_CHANERR_OFFSET);
 	}
 
 	/*
@@ -296,15 +305,14 @@ static void ioat_dma_reset_channel(struct ioat_dma_chan *ioat_chan)
 	 * while we're waiting.
 	 */
 
-	spin_lock_bh(&ioat_chan->desc_lock);
-	ioat_chan->pending = INT_MIN;
+	spin_lock_bh(&ioat->desc_lock);
+	ioat->pending = INT_MIN;
 	writeb(IOAT_CHANCMD_RESET,
-	       ioat_chan->reg_base
-	       + IOAT_CHANCMD_OFFSET(ioat_chan->device->version));
-	spin_unlock_bh(&ioat_chan->desc_lock);
+	       reg_base + IOAT_CHANCMD_OFFSET(chan->device->version));
+	spin_unlock_bh(&ioat->desc_lock);
 
 	/* schedule the 2nd half instead of sleeping a long time */
-	schedule_delayed_work(&ioat_chan->work, RESET_DELAY);
+	schedule_delayed_work(&chan->work, RESET_DELAY);
 }
 
 /**
@@ -314,7 +322,8 @@ static void ioat_dma_chan_watchdog(struct work_struct *work)
 {
 	struct ioatdma_device *device =
 		container_of(work, struct ioatdma_device, work.work);
-	struct ioat_dma_chan *ioat_chan;
+	struct ioat_dma_chan *ioat;
+	struct ioat_chan_common *chan;
 	int i;
 
 	union {
@@ -327,23 +336,21 @@ static void ioat_dma_chan_watchdog(struct work_struct *work)
 	unsigned long compl_desc_addr_hw;
 
 	for (i = 0; i < device->common.chancnt; i++) {
-		ioat_chan = ioat_chan_by_index(device, i);
+		chan = ioat_chan_by_index(device, i);
+		ioat = container_of(chan, struct ioat_dma_chan, base);
 
-		if (ioat_chan->device->version == IOAT_VER_1_2
+		if (chan->device->version == IOAT_VER_1_2
 			/* have we started processing anything yet */
-		    && ioat_chan->last_completion
+		    && chan->last_completion
 			/* have we completed any since last watchdog cycle? */
-		    && (ioat_chan->last_completion ==
-				ioat_chan->watchdog_completion)
+		    && (chan->last_completion == chan->watchdog_completion)
 			/* has TCP stuck on one cookie since last watchdog? */
-		    && (ioat_chan->watchdog_tcp_cookie ==
-				ioat_chan->watchdog_last_tcp_cookie)
-		    && (ioat_chan->watchdog_tcp_cookie !=
-				ioat_chan->completed_cookie)
+		    && (chan->watchdog_tcp_cookie == chan->watchdog_last_tcp_cookie)
+		    && (chan->watchdog_tcp_cookie != chan->completed_cookie)
 			/* is there something in the chain to be processed? */
 			/* CB1 chain always has at least the last one processed */
-		    && (ioat_chan->used_desc.prev != ioat_chan->used_desc.next)
-		    && ioat_chan->pending == 0) {
+		    && (ioat->used_desc.prev != ioat->used_desc.next)
+		    && ioat->pending == 0) {
 
 			/*
 			 * check CHANSTS register for completed
@@ -360,10 +367,10 @@ static void ioat_dma_chan_watchdog(struct work_struct *work)
 			 *     try resetting the channel
 			 */
 
-			completion_hw.low = readl(ioat_chan->reg_base +
-				IOAT_CHANSTS_OFFSET_LOW(ioat_chan->device->version));
-			completion_hw.high = readl(ioat_chan->reg_base +
-				IOAT_CHANSTS_OFFSET_HIGH(ioat_chan->device->version));
+			completion_hw.low = readl(chan->reg_base +
+				IOAT_CHANSTS_OFFSET_LOW(chan->device->version));
+			completion_hw.high = readl(chan->reg_base +
+				IOAT_CHANSTS_OFFSET_HIGH(chan->device->version));
 #if (BITS_PER_LONG == 64)
 			compl_desc_addr_hw =
 				completion_hw.full
@@ -374,15 +381,15 @@ static void ioat_dma_chan_watchdog(struct work_struct *work)
 #endif
 
 			if ((compl_desc_addr_hw != 0)
-			   && (compl_desc_addr_hw != ioat_chan->watchdog_completion)
-			   && (compl_desc_addr_hw != ioat_chan->last_compl_desc_addr_hw)) {
-				ioat_chan->last_compl_desc_addr_hw = compl_desc_addr_hw;
-				ioat_chan->completion_virt->low = completion_hw.low;
-				ioat_chan->completion_virt->high = completion_hw.high;
+			   && (compl_desc_addr_hw != chan->watchdog_completion)
+			   && (compl_desc_addr_hw != chan->last_compl_desc_addr_hw)) {
+				chan->last_compl_desc_addr_hw = compl_desc_addr_hw;
+				chan->completion_virt->low = completion_hw.low;
+				chan->completion_virt->high = completion_hw.high;
 			} else {
-				ioat_dma_reset_channel(ioat_chan);
-				ioat_chan->watchdog_completion = 0;
-				ioat_chan->last_compl_desc_addr_hw = 0;
+				ioat_dma_reset_channel(ioat);
+				chan->watchdog_completion = 0;
+				chan->last_compl_desc_addr_hw = 0;
 			}
 
 		/*
@@ -393,25 +400,22 @@ static void ioat_dma_chan_watchdog(struct work_struct *work)
 		 *      else
 		 *          try resetting the channel
 		 */
-		} else if (ioat_chan->device->version == IOAT_VER_2_0
-		    && ioat_chan->used_desc.prev
-		    && ioat_chan->last_completion
-		    && ioat_chan->last_completion == ioat_chan->watchdog_completion) {
+		} else if (chan->device->version == IOAT_VER_2_0
+		    && ioat->used_desc.prev
+		    && chan->last_completion
+		    && chan->last_completion == chan->watchdog_completion) {
 
-			if (ioat_chan->pending < ioat_pending_level)
-				ioat2_dma_memcpy_issue_pending(&ioat_chan->common);
+			if (ioat->pending < ioat_pending_level)
+				ioat2_dma_memcpy_issue_pending(&chan->common);
 			else {
-				ioat_dma_reset_channel(ioat_chan);
-				ioat_chan->watchdog_completion = 0;
+				ioat_dma_reset_channel(ioat);
+				chan->watchdog_completion = 0;
 			}
 		} else {
-			ioat_chan->last_compl_desc_addr_hw = 0;
-			ioat_chan->watchdog_completion
-					= ioat_chan->last_completion;
+			chan->last_compl_desc_addr_hw = 0;
+			chan->watchdog_completion = chan->last_completion;
 		}
-
-		ioat_chan->watchdog_last_tcp_cookie =
-			ioat_chan->watchdog_tcp_cookie;
+		chan->watchdog_last_tcp_cookie = chan->watchdog_tcp_cookie;
 	}
 
 	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
@@ -419,40 +423,42 @@ static void ioat_dma_chan_watchdog(struct work_struct *work)
 
 static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 {
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(tx->chan);
+	struct dma_chan *c = tx->chan;
+	struct ioat_dma_chan *ioat = to_ioat_chan(c);
 	struct ioat_desc_sw *desc = tx_to_ioat_desc(tx);
 	struct ioat_desc_sw *first;
 	struct ioat_desc_sw *chain_tail;
 	dma_cookie_t cookie;
 
-	spin_lock_bh(&ioat_chan->desc_lock);
+	spin_lock_bh(&ioat->desc_lock);
 	/* cookie incr and addition to used_list must be atomic */
-	cookie = ioat_chan->common.cookie;
+	cookie = c->cookie;
 	cookie++;
 	if (cookie < 0)
 		cookie = 1;
-	ioat_chan->common.cookie = tx->cookie = cookie;
+	c->cookie = cookie;
+	tx->cookie = cookie;
 
 	/* write address into NextDescriptor field of last desc in chain */
 	first = to_ioat_desc(tx->tx_list.next);
-	chain_tail = to_ioat_desc(ioat_chan->used_desc.prev);
+	chain_tail = to_ioat_desc(ioat->used_desc.prev);
 	/* make descriptor updates globally visible before chaining */
 	wmb();
 	chain_tail->hw->next = first->txd.phys;
-	list_splice_tail_init(&tx->tx_list, &ioat_chan->used_desc);
+	list_splice_tail_init(&tx->tx_list, &ioat->used_desc);
 
-	ioat_chan->dmacount += desc->tx_cnt;
-	ioat_chan->pending += desc->tx_cnt;
-	if (ioat_chan->pending >= ioat_pending_level)
-		__ioat1_dma_memcpy_issue_pending(ioat_chan);
-	spin_unlock_bh(&ioat_chan->desc_lock);
+	ioat->dmacount += desc->tx_cnt;
+	ioat->pending += desc->tx_cnt;
+	if (ioat->pending >= ioat_pending_level)
+		__ioat1_dma_memcpy_issue_pending(ioat);
+	spin_unlock_bh(&ioat->desc_lock);
 
 	return cookie;
 }
 
 static dma_cookie_t ioat2_tx_submit(struct dma_async_tx_descriptor *tx)
 {
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(tx->chan);
+	struct ioat_dma_chan *ioat = to_ioat_chan(tx->chan);
 	struct ioat_desc_sw *first = tx_to_ioat_desc(tx);
 	struct ioat_desc_sw *new;
 	struct ioat_dma_descriptor *hw;
@@ -471,11 +477,11 @@ static dma_cookie_t ioat2_tx_submit(struct dma_async_tx_descriptor *tx)
 	new = first;
 
 	/*
-	 * ioat_chan->desc_lock is still in force in version 2 path
+	 * ioat->desc_lock is still in force in version 2 path
 	 * it gets unlocked at end of this function
 	 */
 	do {
-		copy = min_t(size_t, len, ioat_chan->xfercap);
+		copy = min_t(size_t, len, ioat->xfercap);
 
 		async_tx_ack(&new->txd);
 
@@ -489,11 +495,11 @@ static dma_cookie_t ioat2_tx_submit(struct dma_async_tx_descriptor *tx)
 		dst += copy;
 		src += copy;
 		desc_count++;
-	} while (len && (new = ioat2_dma_get_next_descriptor(ioat_chan)));
+	} while (len && (new = ioat2_dma_get_next_descriptor(ioat)));
 
 	if (!new) {
-		dev_err(to_dev(ioat_chan), "tx submit failed\n");
-		spin_unlock_bh(&ioat_chan->desc_lock);
+		dev_err(to_dev(&ioat->base), "tx submit failed\n");
+		spin_unlock_bh(&ioat->desc_lock);
 		return -ENOMEM;
 	}
 
@@ -521,35 +527,35 @@ static dma_cookie_t ioat2_tx_submit(struct dma_async_tx_descriptor *tx)
 	}
 
 	/* cookie incr and addition to used_list must be atomic */
-	cookie = ioat_chan->common.cookie;
+	cookie = ioat->base.common.cookie;
 	cookie++;
 	if (cookie < 0)
 		cookie = 1;
-	ioat_chan->common.cookie = new->txd.cookie = cookie;
+	ioat->base.common.cookie = new->txd.cookie = cookie;
 
-	ioat_chan->dmacount += desc_count;
-	ioat_chan->pending += desc_count;
-	if (ioat_chan->pending >= ioat_pending_level)
-		__ioat2_dma_memcpy_issue_pending(ioat_chan);
-	spin_unlock_bh(&ioat_chan->desc_lock);
+	ioat->dmacount += desc_count;
+	ioat->pending += desc_count;
+	if (ioat->pending >= ioat_pending_level)
+		__ioat2_dma_memcpy_issue_pending(ioat);
+	spin_unlock_bh(&ioat->desc_lock);
 
 	return cookie;
 }
 
 /**
  * ioat_dma_alloc_descriptor - allocate and return a sw and hw descriptor pair
- * @ioat_chan: the channel supplying the memory pool for the descriptors
+ * @ioat: the channel supplying the memory pool for the descriptors
  * @flags: allocation flags
  */
 static struct ioat_desc_sw *
-ioat_dma_alloc_descriptor(struct ioat_dma_chan *ioat_chan, gfp_t flags)
+ioat_dma_alloc_descriptor(struct ioat_dma_chan *ioat, gfp_t flags)
 {
 	struct ioat_dma_descriptor *desc;
 	struct ioat_desc_sw *desc_sw;
 	struct ioatdma_device *ioatdma_device;
 	dma_addr_t phys;
 
-	ioatdma_device = to_ioatdma_device(ioat_chan->common.device);
+	ioatdma_device = ioat->base.device;
 	desc = pci_pool_alloc(ioatdma_device->dma_pool, flags, &phys);
 	if (unlikely(!desc))
 		return NULL;
@@ -561,8 +567,8 @@ ioat_dma_alloc_descriptor(struct ioat_dma_chan *ioat_chan, gfp_t flags)
 	}
 
 	memset(desc, 0, sizeof(*desc));
-	dma_async_tx_descriptor_init(&desc_sw->txd, &ioat_chan->common);
-	switch (ioat_chan->device->version) {
+	dma_async_tx_descriptor_init(&desc_sw->txd, &ioat->base.common);
+	switch (ioatdma_device->version) {
 	case IOAT_VER_1_2:
 		desc_sw->txd.tx_submit = ioat1_tx_submit;
 		break;
@@ -585,26 +591,26 @@ MODULE_PARM_DESC(ioat_initial_desc_count,
 
 /**
  * ioat2_dma_massage_chan_desc - link the descriptors into a circle
- * @ioat_chan: the channel to be massaged
+ * @ioat: the channel to be massaged
  */
-static void ioat2_dma_massage_chan_desc(struct ioat_dma_chan *ioat_chan)
+static void ioat2_dma_massage_chan_desc(struct ioat_dma_chan *ioat)
 {
 	struct ioat_desc_sw *desc, *_desc;
 
 	/* setup used_desc */
-	ioat_chan->used_desc.next = ioat_chan->free_desc.next;
-	ioat_chan->used_desc.prev = NULL;
+	ioat->used_desc.next = ioat->free_desc.next;
+	ioat->used_desc.prev = NULL;
 
 	/* pull free_desc out of the circle so that every node is a hw
 	 * descriptor, but leave it pointing to the list
 	 */
-	ioat_chan->free_desc.prev->next = ioat_chan->free_desc.next;
-	ioat_chan->free_desc.next->prev = ioat_chan->free_desc.prev;
+	ioat->free_desc.prev->next = ioat->free_desc.next;
+	ioat->free_desc.next->prev = ioat->free_desc.prev;
 
 	/* circle link the hw descriptors */
-	desc = to_ioat_desc(ioat_chan->free_desc.next);
+	desc = to_ioat_desc(ioat->free_desc.next);
 	desc->hw->next = to_ioat_desc(desc->node.next)->txd.phys;
-	list_for_each_entry_safe(desc, _desc, ioat_chan->free_desc.next, node) {
+	list_for_each_entry_safe(desc, _desc, ioat->free_desc.next, node) {
 		desc->hw->next = to_ioat_desc(desc->node.next)->txd.phys;
 	}
 }
@@ -613,9 +619,10 @@ static void ioat2_dma_massage_chan_desc(struct ioat_dma_chan *ioat_chan)
  * ioat_dma_alloc_chan_resources - returns the number of allocated descriptors
  * @chan: the channel to be filled out
  */
-static int ioat_dma_alloc_chan_resources(struct dma_chan *chan)
+static int ioat_dma_alloc_chan_resources(struct dma_chan *c)
 {
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_dma_chan *ioat = to_ioat_chan(c);
+	struct ioat_chan_common *chan = &ioat->base;
 	struct ioat_desc_sw *desc;
 	u16 chanctrl;
 	u32 chanerr;
@@ -623,89 +630,87 @@ static int ioat_dma_alloc_chan_resources(struct dma_chan *chan)
 	LIST_HEAD(tmp_list);
 
 	/* have we already been set up? */
-	if (!list_empty(&ioat_chan->free_desc))
-		return ioat_chan->desccount;
+	if (!list_empty(&ioat->free_desc))
+		return ioat->desccount;
 
 	/* Setup register to interrupt and write completion status on error */
 	chanctrl = IOAT_CHANCTRL_ERR_INT_EN |
 		IOAT_CHANCTRL_ANY_ERR_ABORT_EN |
 		IOAT_CHANCTRL_ERR_COMPLETION_EN;
-	writew(chanctrl, ioat_chan->reg_base + IOAT_CHANCTRL_OFFSET);
+	writew(chanctrl, chan->reg_base + IOAT_CHANCTRL_OFFSET);
 
-	chanerr = readl(ioat_chan->reg_base + IOAT_CHANERR_OFFSET);
+	chanerr = readl(chan->reg_base + IOAT_CHANERR_OFFSET);
 	if (chanerr) {
-		dev_err(to_dev(ioat_chan), "CHANERR = %x, clearing\n", chanerr);
-		writel(chanerr, ioat_chan->reg_base + IOAT_CHANERR_OFFSET);
+		dev_err(to_dev(chan), "CHANERR = %x, clearing\n", chanerr);
+		writel(chanerr, chan->reg_base + IOAT_CHANERR_OFFSET);
 	}
 
 	/* Allocate descriptors */
 	for (i = 0; i < ioat_initial_desc_count; i++) {
-		desc = ioat_dma_alloc_descriptor(ioat_chan, GFP_KERNEL);
+		desc = ioat_dma_alloc_descriptor(ioat, GFP_KERNEL);
 		if (!desc) {
-			dev_err(to_dev(ioat_chan),
-				"Only %d initial descriptors\n", i);
+			dev_err(to_dev(chan), "Only %d initial descriptors\n", i);
 			break;
 		}
 		list_add_tail(&desc->node, &tmp_list);
 	}
-	spin_lock_bh(&ioat_chan->desc_lock);
-	ioat_chan->desccount = i;
-	list_splice(&tmp_list, &ioat_chan->free_desc);
-	if (ioat_chan->device->version != IOAT_VER_1_2)
-		ioat2_dma_massage_chan_desc(ioat_chan);
-	spin_unlock_bh(&ioat_chan->desc_lock);
+	spin_lock_bh(&ioat->desc_lock);
+	ioat->desccount = i;
+	list_splice(&tmp_list, &ioat->free_desc);
+	if (chan->device->version != IOAT_VER_1_2)
+		ioat2_dma_massage_chan_desc(ioat);
+	spin_unlock_bh(&ioat->desc_lock);
 
 	/* allocate a completion writeback area */
 	/* doing 2 32bit writes to mmio since 1 64b write doesn't work */
-	ioat_chan->completion_virt =
-		pci_pool_alloc(ioat_chan->device->completion_pool,
-			       GFP_KERNEL,
-			       &ioat_chan->completion_addr);
-	memset(ioat_chan->completion_virt, 0,
-	       sizeof(*ioat_chan->completion_virt));
-	writel(((u64) ioat_chan->completion_addr) & 0x00000000FFFFFFFF,
-	       ioat_chan->reg_base + IOAT_CHANCMP_OFFSET_LOW);
-	writel(((u64) ioat_chan->completion_addr) >> 32,
-	       ioat_chan->reg_base + IOAT_CHANCMP_OFFSET_HIGH);
-
-	tasklet_enable(&ioat_chan->cleanup_task);
-	ioat_dma_start_null_desc(ioat_chan);  /* give chain to dma device */
-	return ioat_chan->desccount;
+	chan->completion_virt = pci_pool_alloc(chan->device->completion_pool,
+					       GFP_KERNEL,
+					       &chan->completion_addr);
+	memset(chan->completion_virt, 0,
+	       sizeof(*chan->completion_virt));
+	writel(((u64) chan->completion_addr) & 0x00000000FFFFFFFF,
+	       chan->reg_base + IOAT_CHANCMP_OFFSET_LOW);
+	writel(((u64) chan->completion_addr) >> 32,
+	       chan->reg_base + IOAT_CHANCMP_OFFSET_HIGH);
+
+	tasklet_enable(&chan->cleanup_task);
+	ioat_dma_start_null_desc(ioat);  /* give chain to dma device */
+	return ioat->desccount;
 }
 
 /**
  * ioat_dma_free_chan_resources - release all the descriptors
  * @chan: the channel to be cleaned
  */
-static void ioat_dma_free_chan_resources(struct dma_chan *chan)
+static void ioat_dma_free_chan_resources(struct dma_chan *c)
 {
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
-	struct ioatdma_device *ioatdma_device = to_ioatdma_device(chan->device);
+	struct ioat_dma_chan *ioat = to_ioat_chan(c);
+	struct ioat_chan_common *chan = &ioat->base;
+	struct ioatdma_device *ioatdma_device = chan->device;
 	struct ioat_desc_sw *desc, *_desc;
 	int in_use_descs = 0;
 
 	/* Before freeing channel resources first check
 	 * if they have been previously allocated for this channel.
 	 */
-	if (ioat_chan->desccount == 0)
+	if (ioat->desccount == 0)
 		return;
 
-	tasklet_disable(&ioat_chan->cleanup_task);
-	ioat_dma_memcpy_cleanup(ioat_chan);
+	tasklet_disable(&chan->cleanup_task);
+	ioat_dma_memcpy_cleanup(ioat);
 
 	/* Delay 100ms after reset to allow internal DMA logic to quiesce
 	 * before removing DMA descriptor resources.
 	 */
 	writeb(IOAT_CHANCMD_RESET,
-	       ioat_chan->reg_base
-			+ IOAT_CHANCMD_OFFSET(ioat_chan->device->version));
+	       chan->reg_base + IOAT_CHANCMD_OFFSET(chan->device->version));
 	mdelay(100);
 
-	spin_lock_bh(&ioat_chan->desc_lock);
-	switch (ioat_chan->device->version) {
+	spin_lock_bh(&ioat->desc_lock);
+	switch (chan->device->version) {
 	case IOAT_VER_1_2:
 		list_for_each_entry_safe(desc, _desc,
-					 &ioat_chan->used_desc, node) {
+					 &ioat->used_desc, node) {
 			in_use_descs++;
 			list_del(&desc->node);
 			pci_pool_free(ioatdma_device->dma_pool, desc->hw,
@@ -713,7 +718,7 @@ static void ioat_dma_free_chan_resources(struct dma_chan *chan)
 			kfree(desc);
 		}
 		list_for_each_entry_safe(desc, _desc,
-					 &ioat_chan->free_desc, node) {
+					 &ioat->free_desc, node) {
 			list_del(&desc->node);
 			pci_pool_free(ioatdma_device->dma_pool, desc->hw,
 				      desc->txd.phys);
@@ -723,62 +728,61 @@ static void ioat_dma_free_chan_resources(struct dma_chan *chan)
 	case IOAT_VER_2_0:
 	case IOAT_VER_3_0:
 		list_for_each_entry_safe(desc, _desc,
-					 ioat_chan->free_desc.next, node) {
+					 ioat->free_desc.next, node) {
 			list_del(&desc->node);
 			pci_pool_free(ioatdma_device->dma_pool, desc->hw,
 				      desc->txd.phys);
 			kfree(desc);
 		}
-		desc = to_ioat_desc(ioat_chan->free_desc.next);
+		desc = to_ioat_desc(ioat->free_desc.next);
 		pci_pool_free(ioatdma_device->dma_pool, desc->hw,
 			      desc->txd.phys);
 		kfree(desc);
-		INIT_LIST_HEAD(&ioat_chan->free_desc);
-		INIT_LIST_HEAD(&ioat_chan->used_desc);
+		INIT_LIST_HEAD(&ioat->free_desc);
+		INIT_LIST_HEAD(&ioat->used_desc);
 		break;
 	}
-	spin_unlock_bh(&ioat_chan->desc_lock);
+	spin_unlock_bh(&ioat->desc_lock);
 
 	pci_pool_free(ioatdma_device->completion_pool,
-		      ioat_chan->completion_virt,
-		      ioat_chan->completion_addr);
+		      chan->completion_virt,
+		      chan->completion_addr);
 
 	/* one is ok since we left it on there on purpose */
 	if (in_use_descs > 1)
-		dev_err(to_dev(ioat_chan), "Freeing %d in use descriptors!\n",
+		dev_err(to_dev(chan), "Freeing %d in use descriptors!\n",
 			in_use_descs - 1);
 
-	ioat_chan->last_completion = ioat_chan->completion_addr = 0;
-	ioat_chan->pending = 0;
-	ioat_chan->dmacount = 0;
-	ioat_chan->desccount = 0;
-	ioat_chan->watchdog_completion = 0;
-	ioat_chan->last_compl_desc_addr_hw = 0;
-	ioat_chan->watchdog_tcp_cookie =
-		ioat_chan->watchdog_last_tcp_cookie = 0;
+	chan->last_completion = chan->completion_addr = 0;
+	chan->watchdog_completion = 0;
+	chan->last_compl_desc_addr_hw = 0;
+	chan->watchdog_tcp_cookie = chan->watchdog_last_tcp_cookie = 0;
+	ioat->pending = 0;
+	ioat->dmacount = 0;
+	ioat->desccount = 0;
 }
 
 /**
- * ioat_dma_get_next_descriptor - return the next available descriptor
- * @ioat_chan: IOAT DMA channel handle
+ * ioat1_dma_get_next_descriptor - return the next available descriptor
+ * @ioat: IOAT DMA channel handle
  *
  * Gets the next descriptor from the chain, and must be called with the
  * channel's desc_lock held.  Allocates more descriptors if the channel
  * has run out.
  */
 static struct ioat_desc_sw *
-ioat1_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan)
+ioat1_dma_get_next_descriptor(struct ioat_dma_chan *ioat)
 {
 	struct ioat_desc_sw *new;
 
-	if (!list_empty(&ioat_chan->free_desc)) {
-		new = to_ioat_desc(ioat_chan->free_desc.next);
+	if (!list_empty(&ioat->free_desc)) {
+		new = to_ioat_desc(ioat->free_desc.next);
 		list_del(&new->node);
 	} else {
 		/* try to get another desc */
-		new = ioat_dma_alloc_descriptor(ioat_chan, GFP_ATOMIC);
+		new = ioat_dma_alloc_descriptor(ioat, GFP_ATOMIC);
 		if (!new) {
-			dev_err(to_dev(ioat_chan), "alloc failed\n");
+			dev_err(to_dev(&ioat->base), "alloc failed\n");
 			return NULL;
 		}
 	}
@@ -788,7 +792,7 @@ ioat1_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan)
 }
 
 static struct ioat_desc_sw *
-ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan)
+ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat)
 {
 	struct ioat_desc_sw *new;
 
@@ -801,15 +805,15 @@ ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan)
 	 *      linking in a new set of descriptors, since the device
 	 *      has probably already read the pointer to it
 	 */
-	if (ioat_chan->used_desc.prev &&
-	    ioat_chan->used_desc.next == ioat_chan->used_desc.prev->prev) {
+	if (ioat->used_desc.prev &&
+	    ioat->used_desc.next == ioat->used_desc.prev->prev) {
 
 		struct ioat_desc_sw *desc;
 		struct ioat_desc_sw *noop_desc;
 		int i;
 
 		/* set up the noop descriptor */
-		noop_desc = to_ioat_desc(ioat_chan->used_desc.next);
+		noop_desc = to_ioat_desc(ioat->used_desc.next);
 		/* set size to non-zero value (channel returns error when size is 0) */
 		noop_desc->hw->size = NULL_DESC_BUFFER_SIZE;
 		noop_desc->hw->ctl = 0;
@@ -817,60 +821,61 @@ ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan)
 		noop_desc->hw->src_addr = 0;
 		noop_desc->hw->dst_addr = 0;
 
-		ioat_chan->used_desc.next = ioat_chan->used_desc.next->next;
-		ioat_chan->pending++;
-		ioat_chan->dmacount++;
+		ioat->used_desc.next = ioat->used_desc.next->next;
+		ioat->pending++;
+		ioat->dmacount++;
 
 		/* try to get a few more descriptors */
 		for (i = 16; i; i--) {
-			desc = ioat_dma_alloc_descriptor(ioat_chan, GFP_ATOMIC);
+			desc = ioat_dma_alloc_descriptor(ioat, GFP_ATOMIC);
 			if (!desc) {
-				dev_err(to_dev(ioat_chan), "alloc failed\n");
+				dev_err(to_dev(&ioat->base),
+					"alloc failed\n");
 				break;
 			}
-			list_add_tail(&desc->node, ioat_chan->used_desc.next);
+			list_add_tail(&desc->node, ioat->used_desc.next);
 
 			desc->hw->next
 				= to_ioat_desc(desc->node.next)->txd.phys;
 			to_ioat_desc(desc->node.prev)->hw->next
 				= desc->txd.phys;
-			ioat_chan->desccount++;
+			ioat->desccount++;
 		}
 
-		ioat_chan->used_desc.next = noop_desc->node.next;
+		ioat->used_desc.next = noop_desc->node.next;
 	}
-	new = to_ioat_desc(ioat_chan->used_desc.next);
+	new = to_ioat_desc(ioat->used_desc.next);
 	prefetch(new);
-	ioat_chan->used_desc.next = new->node.next;
+	ioat->used_desc.next = new->node.next;
 
-	if (ioat_chan->used_desc.prev == NULL)
-		ioat_chan->used_desc.prev = &new->node;
+	if (ioat->used_desc.prev == NULL)
+		ioat->used_desc.prev = &new->node;
 
 	prefetch(new->hw);
 	return new;
 }
 
 static struct ioat_desc_sw *
-ioat_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan)
+ioat_dma_get_next_descriptor(struct ioat_dma_chan *ioat)
 {
-	if (!ioat_chan)
+	if (!ioat)
 		return NULL;
 
-	switch (ioat_chan->device->version) {
+	switch (ioat->base.device->version) {
 	case IOAT_VER_1_2:
-		return ioat1_dma_get_next_descriptor(ioat_chan);
+		return ioat1_dma_get_next_descriptor(ioat);
 	case IOAT_VER_2_0:
 	case IOAT_VER_3_0:
-		return ioat2_dma_get_next_descriptor(ioat_chan);
+		return ioat2_dma_get_next_descriptor(ioat);
 	}
 	return NULL;
 }
 
 static struct dma_async_tx_descriptor *
-ioat1_dma_prep_memcpy(struct dma_chan *chan, dma_addr_t dma_dest,
+ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 		      dma_addr_t dma_src, size_t len, unsigned long flags)
 {
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_dma_chan *ioat = to_ioat_chan(c);
 	struct ioat_desc_sw *desc;
 	size_t copy;
 	LIST_HEAD(chain);
@@ -880,14 +885,14 @@ ioat1_dma_prep_memcpy(struct dma_chan *chan, dma_addr_t dma_dest,
 	struct ioat_dma_descriptor *hw = NULL;
 	int tx_cnt = 0;
 
-	spin_lock_bh(&ioat_chan->desc_lock);
-	desc = ioat_dma_get_next_descriptor(ioat_chan);
+	spin_lock_bh(&ioat->desc_lock);
+	desc = ioat_dma_get_next_descriptor(ioat);
 	do {
 		if (!desc)
 			break;
 
 		tx_cnt++;
-		copy = min_t(size_t, len, ioat_chan->xfercap);
+		copy = min_t(size_t, len, ioat->xfercap);
 
 		hw = desc->hw;
 		hw->size = copy;
@@ -904,7 +909,7 @@ ioat1_dma_prep_memcpy(struct dma_chan *chan, dma_addr_t dma_dest,
 			struct ioat_desc_sw *next;
 
 			async_tx_ack(&desc->txd);
-			next = ioat_dma_get_next_descriptor(ioat_chan);
+			next = ioat_dma_get_next_descriptor(ioat);
 			hw->next = next ? next->txd.phys : 0;
 			desc = next;
 		} else
@@ -912,14 +917,16 @@ ioat1_dma_prep_memcpy(struct dma_chan *chan, dma_addr_t dma_dest,
 	} while (len);
 
 	if (!desc) {
-		dev_err(to_dev(ioat_chan),
+		struct ioat_chan_common *chan = &ioat->base;
+
+		dev_err(to_dev(chan),
 			"chan%d - get_next_desc failed: %d descs waiting, %d total desc\n",
-			chan_num(ioat_chan), ioat_chan->dmacount, ioat_chan->desccount);
-		list_splice(&chain, &ioat_chan->free_desc);
-		spin_unlock_bh(&ioat_chan->desc_lock);
+			chan_num(chan), ioat->dmacount, ioat->desccount);
+		list_splice(&chain, &ioat->free_desc);
+		spin_unlock_bh(&ioat->desc_lock);
 		return NULL;
 	}
-	spin_unlock_bh(&ioat_chan->desc_lock);
+	spin_unlock_bh(&ioat->desc_lock);
 
 	desc->txd.flags = flags;
 	desc->tx_cnt = tx_cnt;
@@ -934,17 +941,17 @@ ioat1_dma_prep_memcpy(struct dma_chan *chan, dma_addr_t dma_dest,
 }
 
 static struct dma_async_tx_descriptor *
-ioat2_dma_prep_memcpy(struct dma_chan *chan, dma_addr_t dma_dest,
+ioat2_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 		      dma_addr_t dma_src, size_t len, unsigned long flags)
 {
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_dma_chan *ioat = to_ioat_chan(c);
 	struct ioat_desc_sw *new;
 
-	spin_lock_bh(&ioat_chan->desc_lock);
-	new = ioat2_dma_get_next_descriptor(ioat_chan);
+	spin_lock_bh(&ioat->desc_lock);
+	new = ioat2_dma_get_next_descriptor(ioat);
 
 	/*
-	 * leave ioat_chan->desc_lock set in ioat 2 path
+	 * leave ioat->desc_lock set in ioat 2 path
 	 * it will get unlocked at end of tx_submit
 	 */
 
@@ -955,10 +962,12 @@ ioat2_dma_prep_memcpy(struct dma_chan *chan, dma_addr_t dma_dest,
 		new->txd.flags = flags;
 		return &new->txd;
 	} else {
-		spin_unlock_bh(&ioat_chan->desc_lock);
-		dev_err(to_dev(ioat_chan),
+		struct ioat_chan_common *chan = &ioat->base;
+
+		spin_unlock_bh(&ioat->desc_lock);
+		dev_err(to_dev(chan),
 			"chan%d - get_next_desc failed: %d descs waiting, %d total desc\n",
-			chan_num(ioat_chan), ioat_chan->dmacount, ioat_chan->desccount);
+			chan_num(chan), ioat->dmacount, ioat->desccount);
 		return NULL;
 	}
 }
@@ -968,20 +977,20 @@ static void ioat_dma_cleanup_tasklet(unsigned long data)
 	struct ioat_dma_chan *chan = (void *)data;
 	ioat_dma_memcpy_cleanup(chan);
 	writew(IOAT_CHANCTRL_INT_DISABLE,
-	       chan->reg_base + IOAT_CHANCTRL_OFFSET);
+	       chan->base.reg_base + IOAT_CHANCTRL_OFFSET);
 }
 
 static void
-ioat_dma_unmap(struct ioat_dma_chan *ioat_chan, struct ioat_desc_sw *desc)
+ioat_dma_unmap(struct ioat_chan_common *chan, struct ioat_desc_sw *desc)
 {
 	if (!(desc->txd.flags & DMA_COMPL_SKIP_DEST_UNMAP)) {
 		if (desc->txd.flags & DMA_COMPL_DEST_UNMAP_SINGLE)
-			pci_unmap_single(ioat_chan->device->pdev,
+			pci_unmap_single(chan->device->pdev,
 					 pci_unmap_addr(desc, dst),
 					 pci_unmap_len(desc, len),
 					 PCI_DMA_FROMDEVICE);
 		else
-			pci_unmap_page(ioat_chan->device->pdev,
+			pci_unmap_page(chan->device->pdev,
 				       pci_unmap_addr(desc, dst),
 				       pci_unmap_len(desc, len),
 				       PCI_DMA_FROMDEVICE);
@@ -989,12 +998,12 @@ ioat_dma_unmap(struct ioat_dma_chan *ioat_chan, struct ioat_desc_sw *desc)
 
 	if (!(desc->txd.flags & DMA_COMPL_SKIP_SRC_UNMAP)) {
 		if (desc->txd.flags & DMA_COMPL_SRC_UNMAP_SINGLE)
-			pci_unmap_single(ioat_chan->device->pdev,
+			pci_unmap_single(chan->device->pdev,
 					 pci_unmap_addr(desc, src),
 					 pci_unmap_len(desc, len),
 					 PCI_DMA_TODEVICE);
 		else
-			pci_unmap_page(ioat_chan->device->pdev,
+			pci_unmap_page(chan->device->pdev,
 				       pci_unmap_addr(desc, src),
 				       pci_unmap_len(desc, len),
 				       PCI_DMA_TODEVICE);
@@ -1005,8 +1014,9 @@ ioat_dma_unmap(struct ioat_dma_chan *ioat_chan, struct ioat_desc_sw *desc)
  * ioat_dma_memcpy_cleanup - cleanup up finished descriptors
  * @chan: ioat channel to be cleaned up
  */
-static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
+static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat)
 {
+	struct ioat_chan_common *chan = &ioat->base;
 	unsigned long phys_complete;
 	struct ioat_desc_sw *desc, *_desc;
 	dma_cookie_t cookie = 0;
@@ -1014,9 +1024,9 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 	struct ioat_desc_sw *latest_desc;
 	struct dma_async_tx_descriptor *tx;
 
-	prefetch(ioat_chan->completion_virt);
+	prefetch(chan->completion_virt);
 
-	if (!spin_trylock_bh(&ioat_chan->cleanup_lock))
+	if (!spin_trylock_bh(&chan->cleanup_lock))
 		return;
 
 	/* The completion writeback can happen at any time,
@@ -1026,49 +1036,47 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 
 #if (BITS_PER_LONG == 64)
 	phys_complete =
-		ioat_chan->completion_virt->full
+		chan->completion_virt->full
 		& IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
 #else
-	phys_complete =
-		ioat_chan->completion_virt->low & IOAT_LOW_COMPLETION_MASK;
+	phys_complete = chan->completion_virt->low & IOAT_LOW_COMPLETION_MASK;
 #endif
 
-	if ((ioat_chan->completion_virt->full
+	if ((chan->completion_virt->full
 		& IOAT_CHANSTS_DMA_TRANSFER_STATUS) ==
 				IOAT_CHANSTS_DMA_TRANSFER_STATUS_HALTED) {
-		dev_err(to_dev(ioat_chan), "Channel halted, chanerr = %x\n",
-			readl(ioat_chan->reg_base + IOAT_CHANERR_OFFSET));
+		dev_err(to_dev(chan), "Channel halted, chanerr = %x\n",
+			readl(chan->reg_base + IOAT_CHANERR_OFFSET));
 
 		/* TODO do something to salvage the situation */
 	}
 
-	if (phys_complete == ioat_chan->last_completion) {
-		spin_unlock_bh(&ioat_chan->cleanup_lock);
+	if (phys_complete == chan->last_completion) {
+		spin_unlock_bh(&chan->cleanup_lock);
 		/*
 		 * perhaps we're stuck so hard that the watchdog can't go off?
 		 * try to catch it after 2 seconds
 		 */
-		if (ioat_chan->device->version != IOAT_VER_3_0) {
+		if (chan->device->version != IOAT_VER_3_0) {
 			if (time_after(jiffies,
-				       ioat_chan->last_completion_time + HZ*WATCHDOG_DELAY)) {
-				ioat_dma_chan_watchdog(&(ioat_chan->device->work.work));
-				ioat_chan->last_completion_time = jiffies;
+				       chan->last_completion_time + HZ*WATCHDOG_DELAY)) {
+				ioat_dma_chan_watchdog(&(chan->device->work.work));
+				chan->last_completion_time = jiffies;
 			}
 		}
 		return;
 	}
-	ioat_chan->last_completion_time = jiffies;
+	chan->last_completion_time = jiffies;
 
 	cookie = 0;
-	if (!spin_trylock_bh(&ioat_chan->desc_lock)) {
-		spin_unlock_bh(&ioat_chan->cleanup_lock);
+	if (!spin_trylock_bh(&ioat->desc_lock)) {
+		spin_unlock_bh(&chan->cleanup_lock);
 		return;
 	}
 
-	switch (ioat_chan->device->version) {
+	switch (chan->device->version) {
 	case IOAT_VER_1_2:
-		list_for_each_entry_safe(desc, _desc,
-					 &ioat_chan->used_desc, node) {
+		list_for_each_entry_safe(desc, _desc, &ioat->used_desc, node) {
 			tx = &desc->txd;
 			/*
 			 * Incoming DMA requests may use multiple descriptors,
@@ -1077,7 +1085,7 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 			 */
 			if (tx->cookie) {
 				cookie = tx->cookie;
-				ioat_dma_unmap(ioat_chan, desc);
+				ioat_dma_unmap(chan, desc);
 				if (tx->callback) {
 					tx->callback(tx->callback_param);
 					tx->callback = NULL;
@@ -1091,7 +1099,7 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 				 */
 				if (async_tx_test_ack(tx)) {
 					list_move_tail(&desc->node,
-						       &ioat_chan->free_desc);
+						       &ioat->free_desc);
 				} else
 					tx->cookie = 0;
 			} else {
@@ -1110,11 +1118,11 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 	case IOAT_VER_2_0:
 	case IOAT_VER_3_0:
 		/* has some other thread has already cleaned up? */
-		if (ioat_chan->used_desc.prev == NULL)
+		if (ioat->used_desc.prev == NULL)
 			break;
 
 		/* work backwards to find latest finished desc */
-		desc = to_ioat_desc(ioat_chan->used_desc.next);
+		desc = to_ioat_desc(ioat->used_desc.next);
 		tx = &desc->txd;
 		latest_desc = NULL;
 		do {
@@ -1125,18 +1133,18 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 				latest_desc = desc;
 				break;
 			}
-		} while (&desc->node != ioat_chan->used_desc.prev);
+		} while (&desc->node != ioat->used_desc.prev);
 
 		if (latest_desc != NULL) {
 			/* work forwards to clear finished descriptors */
-			for (desc = to_ioat_desc(ioat_chan->used_desc.prev);
+			for (desc = to_ioat_desc(ioat->used_desc.prev);
 			     &desc->node != latest_desc->node.next &&
-			     &desc->node != ioat_chan->used_desc.next;
+			     &desc->node != ioat->used_desc.next;
 			     desc = to_ioat_desc(desc->node.next)) {
 				if (tx->cookie) {
 					cookie = tx->cookie;
 					tx->cookie = 0;
-					ioat_dma_unmap(ioat_chan, desc);
+					ioat_dma_unmap(chan, desc);
 					if (tx->callback) {
 						tx->callback(tx->callback_param);
 						tx->callback = NULL;
@@ -1145,21 +1153,21 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
 			}
 
 			/* move used.prev up beyond those that are finished */
-			if (&desc->node == ioat_chan->used_desc.next)
-				ioat_chan->used_desc.prev = NULL;
+			if (&desc->node == ioat->used_desc.next)
+				ioat->used_desc.prev = NULL;
 			else
-				ioat_chan->used_desc.prev = &desc->node;
+				ioat->used_desc.prev = &desc->node;
 		}
 		break;
 	}
 
-	spin_unlock_bh(&ioat_chan->desc_lock);
+	spin_unlock_bh(&ioat->desc_lock);
 
-	ioat_chan->last_completion = phys_complete;
+	chan->last_completion = phys_complete;
 	if (cookie != 0)
-		ioat_chan->completed_cookie = cookie;
+		chan->completed_cookie = cookie;
 
-	spin_unlock_bh(&ioat_chan->cleanup_lock);
+	spin_unlock_bh(&chan->cleanup_lock);
 }
 
 /**
@@ -1170,17 +1178,18 @@ static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan)
  * @used: if not %NULL, updated with last used transaction
  */
 static enum dma_status
-ioat_dma_is_complete(struct dma_chan *chan, dma_cookie_t cookie,
+ioat_dma_is_complete(struct dma_chan *c, dma_cookie_t cookie,
 		     dma_cookie_t *done, dma_cookie_t *used)
 {
-	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	struct ioat_dma_chan *ioat = to_ioat_chan(c);
+	struct ioat_chan_common *chan = &ioat->base;
 	dma_cookie_t last_used;
 	dma_cookie_t last_complete;
 	enum dma_status ret;
 
-	last_used = chan->cookie;
-	last_complete = ioat_chan->completed_cookie;
-	ioat_chan->watchdog_tcp_cookie = cookie;
+	last_used = c->cookie;
+	last_complete = chan->completed_cookie;
+	chan->watchdog_tcp_cookie = cookie;
 
 	if (done)
 		*done = last_complete;
@@ -1191,10 +1200,10 @@ ioat_dma_is_complete(struct dma_chan *chan, dma_cookie_t cookie,
 	if (ret == DMA_SUCCESS)
 		return ret;
 
-	ioat_dma_memcpy_cleanup(ioat_chan);
+	ioat_dma_memcpy_cleanup(ioat);
 
-	last_used = chan->cookie;
-	last_complete = ioat_chan->completed_cookie;
+	last_used = c->cookie;
+	last_complete = chan->completed_cookie;
 
 	if (done)
 		*done = last_complete;
@@ -1204,19 +1213,20 @@ ioat_dma_is_complete(struct dma_chan *chan, dma_cookie_t cookie,
 	return dma_async_is_complete(cookie, last_complete, last_used);
 }
 
-static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat_chan)
+static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat)
 {
+	struct ioat_chan_common *chan = &ioat->base;
 	struct ioat_desc_sw *desc;
 	struct ioat_dma_descriptor *hw;
 
-	spin_lock_bh(&ioat_chan->desc_lock);
+	spin_lock_bh(&ioat->desc_lock);
 
-	desc = ioat_dma_get_next_descriptor(ioat_chan);
+	desc = ioat_dma_get_next_descriptor(ioat);
 
 	if (!desc) {
-		dev_err(to_dev(ioat_chan),
+		dev_err(to_dev(chan),
 			"Unable to start null desc - get next desc failed\n");
-		spin_unlock_bh(&ioat_chan->desc_lock);
+		spin_unlock_bh(&ioat->desc_lock);
 		return;
 	}
 
@@ -1230,31 +1240,31 @@ static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat_chan)
 	hw->src_addr = 0;
 	hw->dst_addr = 0;
 	async_tx_ack(&desc->txd);
-	switch (ioat_chan->device->version) {
+	switch (chan->device->version) {
 	case IOAT_VER_1_2:
 		hw->next = 0;
-		list_add_tail(&desc->node, &ioat_chan->used_desc);
+		list_add_tail(&desc->node, &ioat->used_desc);
 
 		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
-		       ioat_chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
+		       chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
 		writel(((u64) desc->txd.phys) >> 32,
-		       ioat_chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
+		       chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
 
-		writeb(IOAT_CHANCMD_START, ioat_chan->reg_base
-			+ IOAT_CHANCMD_OFFSET(ioat_chan->device->version));
+		writeb(IOAT_CHANCMD_START, chan->reg_base
+			+ IOAT_CHANCMD_OFFSET(chan->device->version));
 		break;
 	case IOAT_VER_2_0:
 	case IOAT_VER_3_0:
 		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
-		       ioat_chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
+		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
 		writel(((u64) desc->txd.phys) >> 32,
-		       ioat_chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
+		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
 
-		ioat_chan->dmacount++;
-		__ioat2_dma_memcpy_issue_pending(ioat_chan);
+		ioat->dmacount++;
+		__ioat2_dma_memcpy_issue_pending(ioat);
 		break;
 	}
-	spin_unlock_bh(&ioat_chan->desc_lock);
+	spin_unlock_bh(&ioat->desc_lock);
 }
 
 /*
@@ -1371,7 +1381,7 @@ MODULE_PARM_DESC(ioat_interrupt_style,
  */
 static int ioat_dma_setup_interrupts(struct ioatdma_device *device)
 {
-	struct ioat_dma_chan *ioat_chan;
+	struct ioat_chan_common *chan;
 	struct pci_dev *pdev = device->pdev;
 	struct device *dev = &pdev->dev;
 	struct msix_entry *msix;
@@ -1404,15 +1414,15 @@ msix:
 
 	for (i = 0; i < msixcnt; i++) {
 		msix = &device->msix_entries[i];
-		ioat_chan = ioat_chan_by_index(device, i);
+		chan = ioat_chan_by_index(device, i);
 		err = devm_request_irq(dev, msix->vector,
 				       ioat_dma_do_interrupt_msix, 0,
-				       "ioat-msix", ioat_chan);
+				       "ioat-msix", chan);
 		if (err) {
 			for (j = 0; j < i; j++) {
 				msix = &device->msix_entries[j];
-				ioat_chan = ioat_chan_by_index(device, j);
-				devm_free_irq(dev, msix->vector, ioat_chan);
+				chan = ioat_chan_by_index(device, j);
+				devm_free_irq(dev, msix->vector, chan);
 			}
 			goto msix_single_vector;
 		}
@@ -1594,8 +1604,8 @@ int ioat2_dma_probe(struct ioatdma_device *device, int dca)
 {
 	struct pci_dev *pdev = device->pdev;
 	struct dma_device *dma;
-	struct dma_chan *chan;
-	struct ioat_dma_chan *ioat_chan;
+	struct dma_chan *c;
+	struct ioat_chan_common *chan;
 	int err;
 
 	dma = &device->common;
@@ -1607,10 +1617,10 @@ int ioat2_dma_probe(struct ioatdma_device *device, int dca)
 		return err;
 	ioat_set_tcp_copy_break(2048);
 
-	list_for_each_entry(chan, &dma->channels, device_node) {
-		ioat_chan = to_ioat_chan(chan);
+	list_for_each_entry(c, &dma->channels, device_node) {
+		chan = to_chan_common(c);
 		writel(IOAT_DCACTRL_CMPL_WRITE_ENABLE | IOAT_DMA_DCA_ANY_CPU,
-		       ioat_chan->reg_base + IOAT_DCACTRL_OFFSET);
+		       chan->reg_base + IOAT_DCACTRL_OFFSET);
 	}
 
 	err = ioat_register(device);
@@ -1629,8 +1639,8 @@ int ioat3_dma_probe(struct ioatdma_device *device, int dca)
 {
 	struct pci_dev *pdev = device->pdev;
 	struct dma_device *dma;
-	struct dma_chan *chan;
-	struct ioat_dma_chan *ioat_chan;
+	struct dma_chan *c;
+	struct ioat_chan_common *chan;
 	int err;
 	u16 dev_id;
 
@@ -1656,10 +1666,10 @@ int ioat3_dma_probe(struct ioatdma_device *device, int dca)
 		return err;
 	ioat_set_tcp_copy_break(262144);
 
-	list_for_each_entry(chan, &dma->channels, device_node) {
-		ioat_chan = to_ioat_chan(chan);
+	list_for_each_entry(c, &dma->channels, device_node) {
+		chan = to_chan_common(c);
 		writel(IOAT_DMA_DCA_ANY_CPU,
-		       ioat_chan->reg_base + IOAT_DCACTRL_OFFSET);
+		       chan->reg_base + IOAT_DCACTRL_OFFSET);
 	}
 
 	err = ioat_register(device);
@@ -1673,8 +1683,6 @@ int ioat3_dma_probe(struct ioatdma_device *device, int dca)
 
 void ioat_dma_remove(struct ioatdma_device *device)
 {
-	struct dma_chan *chan, *_chan;
-	struct ioat_dma_chan *ioat_chan;
 	struct dma_device *dma = &device->common;
 
 	if (device->version != IOAT_VER_3_0)
@@ -1687,9 +1695,6 @@ void ioat_dma_remove(struct ioatdma_device *device)
 	pci_pool_destroy(device->dma_pool);
 	pci_pool_destroy(device->completion_pool);
 
-	list_for_each_entry_safe(chan, _chan, &dma->channels, device_node) {
-		ioat_chan = to_ioat_chan(chan);
-		list_del(&chan->device_node);
-	}
+	INIT_LIST_HEAD(&dma->channels);
 }
 
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index 9f0c853..5b31db7 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -35,7 +35,6 @@
 #define IOAT_DMA_DCA_ANY_CPU		~0
 #define IOAT_WATCHDOG_PERIOD		(2 * HZ)
 
-#define to_ioat_chan(chan) container_of(chan, struct ioat_dma_chan, common)
 #define to_ioatdma_device(dev) container_of(dev, struct ioatdma_device, common)
 #define to_ioat_desc(lh) container_of(lh, struct ioat_desc_sw, node)
 #define tx_to_ioat_desc(tx) container_of(tx, struct ioat_desc_sw, txd)
@@ -74,37 +73,24 @@ struct ioatdma_device {
 	u8 version;
 	struct delayed_work work;
 	struct msix_entry msix_entries[4];
-	struct ioat_dma_chan *idx[4];
+	struct ioat_chan_common *idx[4];
 	struct dca_provider *dca;
 	void (*intr_quirk)(struct ioatdma_device *device);
 };
 
-/**
- * struct ioat_dma_chan - internal representation of a DMA channel
- */
-struct ioat_dma_chan {
-
+struct ioat_chan_common {
 	void __iomem *reg_base;
 
-	dma_cookie_t completed_cookie;
 	unsigned long last_completion;
 	unsigned long last_completion_time;
 
-	size_t xfercap;	/* XFERCAP register value expanded out */
-
 	spinlock_t cleanup_lock;
-	spinlock_t desc_lock;
-	struct list_head free_desc;
-	struct list_head used_desc;
+	dma_cookie_t completed_cookie;
 	unsigned long watchdog_completion;
 	int watchdog_tcp_cookie;
 	u32 watchdog_last_tcp_cookie;
 	struct delayed_work work;
 
-	int pending;
-	u16 dmacount;
-	u16 desccount;
-
 	struct ioatdma_device *device;
 	struct dma_chan common;
 
@@ -120,6 +106,35 @@ struct ioat_dma_chan {
 	struct tasklet_struct cleanup_task;
 };
 
+/**
+ * struct ioat_dma_chan - internal representation of a DMA channel
+ */
+struct ioat_dma_chan {
+	struct ioat_chan_common base;
+
+	size_t xfercap;	/* XFERCAP register value expanded out */
+
+	spinlock_t desc_lock;
+	struct list_head free_desc;
+	struct list_head used_desc;
+
+	int pending;
+	u16 dmacount;
+	u16 desccount;
+};
+
+static inline struct ioat_chan_common *to_chan_common(struct dma_chan *c)
+{
+	return container_of(c, struct ioat_chan_common, common);
+}
+
+static inline struct ioat_dma_chan *to_ioat_chan(struct dma_chan *c)
+{
+	struct ioat_chan_common *chan = to_chan_common(c);
+
+	return container_of(chan, struct ioat_dma_chan, base);
+}
+
 /* wrapper around hardware descriptor format + additional software fields */
 
 /**

