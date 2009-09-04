From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 20/29] ioat: switch watchdog and reset handler from workqueue
	to timer
Date: Thu, 03 Sep 2009 19:32:11 -0700
Message-ID: <20090904023211.32667.37259.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:25184 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932706AbZIDCcK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 22:32:10 -0400
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support dynamic resizing of the descriptor ring or polling
for a descriptor in the presence of a hung channel the reset handler
needs to make progress while in a non-preemptible context.  The current
workqueue implementation precludes polling channel reset completion
under spin_lock().

This conversion also allows us to return to opportunistic cleanup in the
ioat2 case as the timer implementation guarantees at least one cleanup
after every descriptor is submitted.  This means the worst case
completion latency becomes the timer frequency (for exceptional
circumstances), but with the benefit of avoiding busy waiting when the
lock is contended.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c       |  351 ++++++++++++++++--------------------------
 drivers/dma/ioat/dma.h       |  112 +++++++++++--
 drivers/dma/ioat/dma_v2.c    |  321 +++++++++++++++++---------------------
 drivers/dma/ioat/dma_v2.h    |   10 +
 drivers/dma/ioat/registers.h |   22 +--
 5 files changed, 388 insertions(+), 428 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index f59b6f4..17a518d 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -99,23 +99,26 @@ static void ioat1_cleanup_tasklet(unsigned long data);
 /* common channel initialization */
 void ioat_init_channel(struct ioatdma_device *device,
 		       struct ioat_chan_common *chan, int idx,
-		       work_func_t work_fn, void (*tasklet)(unsigned long),
-		       unsigned long tasklet_data)
+		       void (*timer_fn)(unsigned long),
+		       void (*tasklet)(unsigned long),
+		       unsigned long ioat)
 {
 	struct dma_device *dma = &device->common;
 
 	chan->device = device;
 	chan->reg_base = device->reg_base + (0x80 * (idx + 1));
-	INIT_DELAYED_WORK(&chan->work, work_fn);
 	spin_lock_init(&chan->cleanup_lock);
 	chan->common.device = dma;
 	list_add_tail(&chan->common.device_node, &dma->channels);
 	device->idx[idx] = chan;
-	tasklet_init(&chan->cleanup_task, tasklet, tasklet_data);
+	init_timer(&chan->timer);
+	chan->timer.function = timer_fn;
+	chan->timer.data = ioat;
+	tasklet_init(&chan->cleanup_task, tasklet, ioat);
 	tasklet_disable(&chan->cleanup_task);
 }
 
-static void ioat1_reset_part2(struct work_struct *work);
+static void ioat1_timer_event(unsigned long data);
 
 /**
  * ioat1_dma_enumerate_channels - find and initialize the device's channels
@@ -153,7 +156,7 @@ static int ioat1_enumerate_channels(struct ioatdma_device *device)
 			break;
 
 		ioat_init_channel(device, &ioat->base, i,
-				  ioat1_reset_part2,
+				  ioat1_timer_event,
 				  ioat1_cleanup_tasklet,
 				  (unsigned long) ioat);
 		ioat->xfercap = xfercap;
@@ -193,61 +196,6 @@ static void ioat1_dma_memcpy_issue_pending(struct dma_chan *chan)
 }
 
 /**
- * ioat1_reset_part2 - reinit the channel after a reset
- */
-static void ioat1_reset_part2(struct work_struct *work)
-{
-	struct ioat_chan_common *chan;
-	struct ioat_dma_chan *ioat;
-	struct ioat_desc_sw *desc;
-	int dmacount;
-	bool start_null = false;
-
-	chan = container_of(work, struct ioat_chan_common, work.work);
-	ioat = container_of(chan, struct ioat_dma_chan, base);
-	spin_lock_bh(&chan->cleanup_lock);
-	spin_lock_bh(&ioat->desc_lock);
-
-	*chan->completion = 0;
-	ioat->pending = 0;
-
-	/* count the descriptors waiting */
-	dmacount = 0;
-	if (ioat->used_desc.prev) {
-		desc = to_ioat_desc(ioat->used_desc.prev);
-		do {
-			dmacount++;
-			desc = to_ioat_desc(desc->node.next);
-		} while (&desc->node != ioat->used_desc.next);
-	}
-
-	if (dmacount) {
-		/*
-		 * write the new starting descriptor address
-		 * this puts channel engine into ARMED state
-		 */
-		desc = to_ioat_desc(ioat->used_desc.prev);
-		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
-		       chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
-		writel(((u64) desc->txd.phys) >> 32,
-		       chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
-
-		writeb(IOAT_CHANCMD_START, chan->reg_base
-			+ IOAT_CHANCMD_OFFSET(chan->device->version));
-	} else
-		start_null = true;
-	spin_unlock_bh(&ioat->desc_lock);
-	spin_unlock_bh(&chan->cleanup_lock);
-
-	dev_err(to_dev(chan),
-		"chan%d reset - %d descs waiting, %d total desc\n",
-		chan_num(chan), dmacount, ioat->desccount);
-
-	if (start_null)
-		ioat1_dma_start_null_desc(ioat);
-}
-
-/**
  * ioat1_reset_channel - restart a channel
  * @ioat: IOAT DMA channel handle
  */
@@ -257,12 +205,9 @@ static void ioat1_reset_channel(struct ioat_dma_chan *ioat)
 	void __iomem *reg_base = chan->reg_base;
 	u32 chansts, chanerr;
 
-	if (!ioat->used_desc.prev)
-		return;
-
-	dev_dbg(to_dev(chan), "%s\n", __func__);
+	dev_warn(to_dev(chan), "reset\n");
 	chanerr = readl(reg_base + IOAT_CHANERR_OFFSET);
-	chansts = *chan->completion & IOAT_CHANSTS_DMA_TRANSFER_STATUS;
+	chansts = *chan->completion & IOAT_CHANSTS_STATUS;
 	if (chanerr) {
 		dev_err(to_dev(chan),
 			"chan%d, CHANSTS = 0x%08x CHANERR = 0x%04x, clearing\n",
@@ -278,93 +223,11 @@ static void ioat1_reset_channel(struct ioat_dma_chan *ioat)
 	 * while we're waiting.
 	 */
 
-	spin_lock_bh(&ioat->desc_lock);
 	ioat->pending = INT_MIN;
 	writeb(IOAT_CHANCMD_RESET,
 	       reg_base + IOAT_CHANCMD_OFFSET(chan->device->version));
-	spin_unlock_bh(&ioat->desc_lock);
-
-	/* schedule the 2nd half instead of sleeping a long time */
-	schedule_delayed_work(&chan->work, RESET_DELAY);
-}
-
-/**
- * ioat1_chan_watchdog - watch for stuck channels
- */
-static void ioat1_chan_watchdog(struct work_struct *work)
-{
-	struct ioatdma_device *device =
-		container_of(work, struct ioatdma_device, work.work);
-	struct ioat_dma_chan *ioat;
-	struct ioat_chan_common *chan;
-	int i;
-	u64 completion;
-	u32 completion_low;
-	unsigned long compl_desc_addr_hw;
-
-	for (i = 0; i < device->common.chancnt; i++) {
-		chan = ioat_chan_by_index(device, i);
-		ioat = container_of(chan, struct ioat_dma_chan, base);
-
-		if (/* have we started processing anything yet */
-		    chan->last_completion
-		    /* have we completed any since last watchdog cycle? */
-		    && (chan->last_completion == chan->watchdog_completion)
-		    /* has TCP stuck on one cookie since last watchdog? */
-		    && (chan->watchdog_tcp_cookie == chan->watchdog_last_tcp_cookie)
-		    && (chan->watchdog_tcp_cookie != chan->completed_cookie)
-		    /* is there something in the chain to be processed? */
-		    /* CB1 chain always has at least the last one processed */
-		    && (ioat->used_desc.prev != ioat->used_desc.next)
-		    && ioat->pending == 0) {
-
-			/*
-			 * check CHANSTS register for completed
-			 * descriptor address.
-			 * if it is different than completion writeback,
-			 * it is not zero
-			 * and it has changed since the last watchdog
-			 *     we can assume that channel
-			 *     is still working correctly
-			 *     and the problem is in completion writeback.
-			 *     update completion writeback
-			 *     with actual CHANSTS value
-			 * else
-			 *     try resetting the channel
-			 */
-
-			/* we need to read the low address first as this
-			 * causes the chipset to latch the upper bits
-			 * for the subsequent read
-			 */
-			completion_low = readl(chan->reg_base +
-				IOAT_CHANSTS_OFFSET_LOW(chan->device->version));
-			completion = readl(chan->reg_base +
-				IOAT_CHANSTS_OFFSET_HIGH(chan->device->version));
-			completion <<= 32;
-			completion |= completion_low;
-			compl_desc_addr_hw = completion &
-					IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
-
-			if ((compl_desc_addr_hw != 0)
-			   && (compl_desc_addr_hw != chan->watchdog_completion)
-			   && (compl_desc_addr_hw != chan->last_compl_desc_addr_hw)) {
-				chan->last_compl_desc_addr_hw = compl_desc_addr_hw;
-				*chan->completion = completion;
-			} else {
-				ioat1_reset_channel(ioat);
-				chan->watchdog_completion = 0;
-				chan->last_compl_desc_addr_hw = 0;
-			}
-		} else {
-			chan->last_compl_desc_addr_hw = 0;
-			chan->watchdog_completion = chan->last_completion;
-		}
-
-		chan->watchdog_last_tcp_cookie = chan->watchdog_tcp_cookie;
-	}
-
-	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
+	set_bit(IOAT_RESET_PENDING, &chan->state);
+	mod_timer(&chan->timer, jiffies + RESET_DELAY);
 }
 
 static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
@@ -372,6 +235,7 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	struct dma_chan *c = tx->chan;
 	struct ioat_dma_chan *ioat = to_ioat_chan(c);
 	struct ioat_desc_sw *desc = tx_to_ioat_desc(tx);
+	struct ioat_chan_common *chan = &ioat->base;
 	struct ioat_desc_sw *first;
 	struct ioat_desc_sw *chain_tail;
 	dma_cookie_t cookie;
@@ -396,6 +260,9 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	dump_desc_dbg(ioat, chain_tail);
 	dump_desc_dbg(ioat, first);
 
+	if (!test_and_set_bit(IOAT_COMPLETION_PENDING, &chan->state))
+		mod_timer(&chan->timer, jiffies + COMPLETION_TIMEOUT);
+
 	ioat->pending += desc->hw->tx_cnt;
 	if (ioat->pending >= ioat_pending_level)
 		__ioat1_dma_memcpy_issue_pending(ioat);
@@ -520,6 +387,7 @@ static void ioat1_dma_free_chan_resources(struct dma_chan *c)
 		return;
 
 	tasklet_disable(&chan->cleanup_task);
+	del_timer_sync(&chan->timer);
 	ioat1_cleanup(ioat);
 
 	/* Delay 100ms after reset to allow internal DMA logic to quiesce
@@ -560,9 +428,6 @@ static void ioat1_dma_free_chan_resources(struct dma_chan *c)
 
 	chan->last_completion = 0;
 	chan->completion_dma = 0;
-	chan->watchdog_completion = 0;
-	chan->last_compl_desc_addr_hw = 0;
-	chan->watchdog_tcp_cookie = chan->watchdog_last_tcp_cookie = 0;
 	ioat->pending = 0;
 	ioat->desccount = 0;
 }
@@ -705,15 +570,15 @@ unsigned long ioat_get_current_completion(struct ioat_chan_common *chan)
 	u64 completion;
 
 	completion = *chan->completion;
-	phys_complete = completion & IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
+	phys_complete = ioat_chansts_to_addr(completion);
 
 	dev_dbg(to_dev(chan), "%s: phys_complete: %#llx\n", __func__,
 		(unsigned long long) phys_complete);
 
-	if ((completion & IOAT_CHANSTS_DMA_TRANSFER_STATUS) ==
-				IOAT_CHANSTS_DMA_TRANSFER_STATUS_HALTED) {
+	if (is_ioat_halted(completion)) {
+		u32 chanerr = readl(chan->reg_base + IOAT_CHANERR_OFFSET);
 		dev_err(to_dev(chan), "Channel halted, chanerr = %x\n",
-			readl(chan->reg_base + IOAT_CHANERR_OFFSET));
+			chanerr);
 
 		/* TODO do something to salvage the situation */
 	}
@@ -721,48 +586,31 @@ unsigned long ioat_get_current_completion(struct ioat_chan_common *chan)
 	return phys_complete;
 }
 
-/**
- * ioat1_cleanup - cleanup up finished descriptors
- * @chan: ioat channel to be cleaned up
- */
-static void ioat1_cleanup(struct ioat_dma_chan *ioat)
+bool ioat_cleanup_preamble(struct ioat_chan_common *chan,
+			   unsigned long *phys_complete)
 {
-	struct ioat_chan_common *chan = &ioat->base;
-	unsigned long phys_complete;
-	struct ioat_desc_sw *desc, *_desc;
-	dma_cookie_t cookie = 0;
-	struct dma_async_tx_descriptor *tx;
-
-	prefetch(chan->completion);
-
-	if (!spin_trylock_bh(&chan->cleanup_lock))
-		return;
+	*phys_complete = ioat_get_current_completion(chan);
+	if (*phys_complete == chan->last_completion)
+		return false;
+	clear_bit(IOAT_COMPLETION_ACK, &chan->state);
+	mod_timer(&chan->timer, jiffies + COMPLETION_TIMEOUT);
 
-	phys_complete = ioat_get_current_completion(chan);
-	if (phys_complete == chan->last_completion) {
-		spin_unlock_bh(&chan->cleanup_lock);
-		/*
-		 * perhaps we're stuck so hard that the watchdog can't go off?
-		 * try to catch it after 2 seconds
-		 */
-		if (time_after(jiffies,
-			       chan->last_completion_time + HZ*WATCHDOG_DELAY)) {
-			ioat1_chan_watchdog(&(chan->device->work.work));
-			chan->last_completion_time = jiffies;
-		}
-		return;
-	}
-	chan->last_completion_time = jiffies;
+	return true;
+}
 
-	cookie = 0;
-	if (!spin_trylock_bh(&ioat->desc_lock)) {
-		spin_unlock_bh(&chan->cleanup_lock);
-		return;
-	}
+static void __cleanup(struct ioat_dma_chan *ioat, unsigned long phys_complete)
+{
+	struct ioat_chan_common *chan = &ioat->base;
+	struct list_head *_desc, *n;
+	struct dma_async_tx_descriptor *tx;
 
 	dev_dbg(to_dev(chan), "%s: phys_complete: %lx\n",
 		 __func__, phys_complete);
-	list_for_each_entry_safe(desc, _desc, &ioat->used_desc, node) {
+	list_for_each_safe(_desc, n, &ioat->used_desc) {
+		struct ioat_desc_sw *desc;
+
+		prefetch(n);
+		desc = list_entry(_desc, typeof(*desc), node);
 		tx = &desc->txd;
 		/*
 		 * Incoming DMA requests may use multiple descriptors,
@@ -771,7 +619,8 @@ static void ioat1_cleanup(struct ioat_dma_chan *ioat)
 		 */
 		dump_desc_dbg(ioat, desc);
 		if (tx->cookie) {
-			cookie = tx->cookie;
+			chan->completed_cookie = tx->cookie;
+			tx->cookie = 0;
 			ioat_dma_unmap(chan, tx->flags, desc->len, desc->hw);
 			if (tx->callback) {
 				tx->callback(tx->callback_param);
@@ -786,27 +635,110 @@ static void ioat1_cleanup(struct ioat_dma_chan *ioat)
 			 */
 			if (async_tx_test_ack(tx))
 				list_move_tail(&desc->node, &ioat->free_desc);
-			else
-				tx->cookie = 0;
 		} else {
 			/*
 			 * last used desc. Do not remove, so we can
-			 * append from it, but don't look at it next
-			 * time, either
+			 * append from it.
 			 */
-			tx->cookie = 0;
+
+			/* if nothing else is pending, cancel the
+			 * completion timeout
+			 */
+			if (n == &ioat->used_desc) {
+				dev_dbg(to_dev(chan),
+					"%s cancel completion timeout\n",
+					__func__);
+				clear_bit(IOAT_COMPLETION_PENDING, &chan->state);
+			}
 
 			/* TODO check status bits? */
 			break;
 		}
 	}
 
+	chan->last_completion = phys_complete;
+}
+
+/**
+ * ioat1_cleanup - cleanup up finished descriptors
+ * @chan: ioat channel to be cleaned up
+ *
+ * To prevent lock contention we defer cleanup when the locks are
+ * contended with a terminal timeout that forces cleanup and catches
+ * completion notification errors.
+ */
+static void ioat1_cleanup(struct ioat_dma_chan *ioat)
+{
+	struct ioat_chan_common *chan = &ioat->base;
+	unsigned long phys_complete;
+
+	prefetch(chan->completion);
+
+	if (!spin_trylock_bh(&chan->cleanup_lock))
+		return;
+
+	if (!ioat_cleanup_preamble(chan, &phys_complete)) {
+		spin_unlock_bh(&chan->cleanup_lock);
+		return;
+	}
+
+	if (!spin_trylock_bh(&ioat->desc_lock)) {
+		spin_unlock_bh(&chan->cleanup_lock);
+		return;
+	}
+
+	__cleanup(ioat, phys_complete);
+
 	spin_unlock_bh(&ioat->desc_lock);
+	spin_unlock_bh(&chan->cleanup_lock);
+}
 
-	chan->last_completion = phys_complete;
-	if (cookie != 0)
-		chan->completed_cookie = cookie;
+static void ioat1_timer_event(unsigned long data)
+{
+	struct ioat_dma_chan *ioat = (void *) data;
+	struct ioat_chan_common *chan = &ioat->base;
 
+	dev_dbg(to_dev(chan), "%s: state: %lx\n", __func__, chan->state);
+
+	spin_lock_bh(&chan->cleanup_lock);
+	if (test_and_clear_bit(IOAT_RESET_PENDING, &chan->state)) {
+		struct ioat_desc_sw *desc;
+
+		spin_lock_bh(&ioat->desc_lock);
+
+		/* restart active descriptors */
+		desc = to_ioat_desc(ioat->used_desc.prev);
+		ioat_set_chainaddr(ioat, desc->txd.phys);
+		ioat_start(chan);
+
+		ioat->pending = 0;
+		set_bit(IOAT_COMPLETION_PENDING, &chan->state);
+		mod_timer(&chan->timer, jiffies + COMPLETION_TIMEOUT);
+		spin_unlock_bh(&ioat->desc_lock);
+	} else if (test_bit(IOAT_COMPLETION_PENDING, &chan->state)) {
+		unsigned long phys_complete;
+
+		spin_lock_bh(&ioat->desc_lock);
+		/* if we haven't made progress and we have already
+		 * acknowledged a pending completion once, then be more
+		 * forceful with a restart
+		 */
+		if (ioat_cleanup_preamble(chan, &phys_complete))
+			__cleanup(ioat, phys_complete);
+		else if (test_bit(IOAT_COMPLETION_ACK, &chan->state))
+			ioat1_reset_channel(ioat);
+		else {
+			u64 status = ioat_chansts(chan);
+
+			/* manually update the last completion address */
+			if (ioat_chansts_to_addr(status) != 0)
+				*chan->completion = status;
+
+			set_bit(IOAT_COMPLETION_ACK, &chan->state);
+			mod_timer(&chan->timer, jiffies + COMPLETION_TIMEOUT);
+		}
+		spin_unlock_bh(&ioat->desc_lock);
+	}
 	spin_unlock_bh(&chan->cleanup_lock);
 }
 
@@ -855,13 +787,8 @@ static void ioat1_dma_start_null_desc(struct ioat_dma_chan *ioat)
 	list_add_tail(&desc->node, &ioat->used_desc);
 	dump_desc_dbg(ioat, desc);
 
-	writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
-	       chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
-	writel(((u64) desc->txd.phys) >> 32,
-	       chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
-
-	writeb(IOAT_CHANCMD_START, chan->reg_base
-		+ IOAT_CHANCMD_OFFSET(chan->device->version));
+	ioat_set_chainaddr(ioat, desc->txd.phys);
+	ioat_start(chan);
 	spin_unlock_bh(&ioat->desc_lock);
 }
 
@@ -1194,9 +1121,6 @@ int __devinit ioat1_dma_probe(struct ioatdma_device *device, int dca)
 	if (dca)
 		device->dca = ioat_dca_init(pdev, device->reg_base);
 
-	INIT_DELAYED_WORK(&device->work, ioat1_chan_watchdog);
-	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
-
 	return err;
 }
 
@@ -1204,9 +1128,6 @@ void __devexit ioat_dma_remove(struct ioatdma_device *device)
 {
 	struct dma_device *dma = &device->common;
 
-	if (device->version != IOAT_VER_3_0)
-		cancel_delayed_work(&device->work);
-
 	ioat_disable_interrupts(device);
 
 	dma_async_device_unregister(dma);
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index ec851cf..dbfccac 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -23,6 +23,7 @@
 
 #include <linux/dmaengine.h>
 #include "hw.h"
+#include "registers.h"
 #include <linux/init.h>
 #include <linux/dmapool.h>
 #include <linux/cache.h>
@@ -33,7 +34,6 @@
 
 #define IOAT_LOW_COMPLETION_MASK	0xffffffc0
 #define IOAT_DMA_DCA_ANY_CPU		~0
-#define IOAT_WATCHDOG_PERIOD		(2 * HZ)
 
 #define to_ioatdma_device(dev) container_of(dev, struct ioatdma_device, common)
 #define to_ioat_desc(lh) container_of(lh, struct ioat_desc_sw, node)
@@ -42,9 +42,6 @@
 
 #define chan_num(ch) ((int)((ch)->reg_base - (ch)->device->reg_base) / 0x80)
 
-#define RESET_DELAY  msecs_to_jiffies(100)
-#define WATCHDOG_DELAY  round_jiffies(msecs_to_jiffies(2000))
-
 /*
  * workaround for IOAT ver.3.0 null descriptor issue
  * (channel returns error when size is 0)
@@ -72,7 +69,6 @@ struct ioatdma_device {
 	struct pci_pool *completion_pool;
 	struct dma_device common;
 	u8 version;
-	struct delayed_work work;
 	struct msix_entry msix_entries[4];
 	struct ioat_chan_common *idx[4];
 	struct dca_provider *dca;
@@ -81,24 +77,21 @@ struct ioatdma_device {
 };
 
 struct ioat_chan_common {
+	struct dma_chan common;
 	void __iomem *reg_base;
-
 	unsigned long last_completion;
-	unsigned long last_completion_time;
-
 	spinlock_t cleanup_lock;
 	dma_cookie_t completed_cookie;
-	unsigned long watchdog_completion;
-	int watchdog_tcp_cookie;
-	u32 watchdog_last_tcp_cookie;
-	struct delayed_work work;
-
+	unsigned long state;
+	#define IOAT_COMPLETION_PENDING 0
+	#define IOAT_COMPLETION_ACK 1
+	#define IOAT_RESET_PENDING 2
+	struct timer_list timer;
+	#define COMPLETION_TIMEOUT msecs_to_jiffies(100)
+	#define RESET_DELAY msecs_to_jiffies(100)
 	struct ioatdma_device *device;
-	struct dma_chan common;
-
 	dma_addr_t completion_dma;
 	u64 *completion;
-	unsigned long last_compl_desc_addr_hw;
 	struct tasklet_struct cleanup_task;
 };
 
@@ -148,7 +141,6 @@ ioat_is_complete(struct dma_chan *c, dma_cookie_t cookie,
 
 	last_used = c->cookie;
 	last_complete = chan->completed_cookie;
-	chan->watchdog_tcp_cookie = cookie;
 
 	if (done)
 		*done = last_complete;
@@ -215,6 +207,85 @@ ioat_chan_by_index(struct ioatdma_device *device, int index)
 	return device->idx[index];
 }
 
+static inline u64 ioat_chansts(struct ioat_chan_common *chan)
+{
+	u8 ver = chan->device->version;
+	u64 status;
+	u32 status_lo;
+
+	/* We need to read the low address first as this causes the
+	 * chipset to latch the upper bits for the subsequent read
+	 */
+	status_lo = readl(chan->reg_base + IOAT_CHANSTS_OFFSET_LOW(ver));
+	status = readl(chan->reg_base + IOAT_CHANSTS_OFFSET_HIGH(ver));
+	status <<= 32;
+	status |= status_lo;
+
+	return status;
+}
+
+static inline void ioat_start(struct ioat_chan_common *chan)
+{
+	u8 ver = chan->device->version;
+
+	writeb(IOAT_CHANCMD_START, chan->reg_base + IOAT_CHANCMD_OFFSET(ver));
+}
+
+static inline u64 ioat_chansts_to_addr(u64 status)
+{
+	return status & IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
+}
+
+static inline u32 ioat_chanerr(struct ioat_chan_common *chan)
+{
+	return readl(chan->reg_base + IOAT_CHANERR_OFFSET);
+}
+
+static inline void ioat_suspend(struct ioat_chan_common *chan)
+{
+	u8 ver = chan->device->version;
+
+	writeb(IOAT_CHANCMD_SUSPEND, chan->reg_base + IOAT_CHANCMD_OFFSET(ver));
+}
+
+static inline void ioat_set_chainaddr(struct ioat_dma_chan *ioat, u64 addr)
+{
+	struct ioat_chan_common *chan = &ioat->base;
+
+	writel(addr & 0x00000000FFFFFFFF,
+	       chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
+	writel(addr >> 32,
+	       chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
+}
+
+static inline bool is_ioat_active(unsigned long status)
+{
+	return ((status & IOAT_CHANSTS_STATUS) == IOAT_CHANSTS_ACTIVE);
+}
+
+static inline bool is_ioat_idle(unsigned long status)
+{
+	return ((status & IOAT_CHANSTS_STATUS) == IOAT_CHANSTS_DONE);
+}
+
+static inline bool is_ioat_halted(unsigned long status)
+{
+	return ((status & IOAT_CHANSTS_STATUS) == IOAT_CHANSTS_HALTED);
+}
+
+static inline bool is_ioat_suspended(unsigned long status)
+{
+	return ((status & IOAT_CHANSTS_STATUS) == IOAT_CHANSTS_SUSPENDED);
+}
+
+/* channel was fatally programmed */
+static inline bool is_ioat_bug(unsigned long err)
+{
+	return !!(err & (IOAT_CHANERR_SRC_ADDR_ERR|IOAT_CHANERR_DEST_ADDR_ERR|
+			 IOAT_CHANERR_NEXT_ADDR_ERR|IOAT_CHANERR_CONTROL_ERR|
+			 IOAT_CHANERR_LENGTH_ERR));
+}
+
 int __devinit ioat_probe(struct ioatdma_device *device);
 int __devinit ioat_register(struct ioatdma_device *device);
 int __devinit ioat1_dma_probe(struct ioatdma_device *dev, int dca);
@@ -224,8 +295,11 @@ struct dca_provider * __devinit ioat_dca_init(struct pci_dev *pdev,
 unsigned long ioat_get_current_completion(struct ioat_chan_common *chan);
 void ioat_init_channel(struct ioatdma_device *device,
 		       struct ioat_chan_common *chan, int idx,
-		       work_func_t work_fn, void (*tasklet)(unsigned long),
-		       unsigned long tasklet_data);
+		       void (*timer_fn)(unsigned long),
+		       void (*tasklet)(unsigned long),
+		       unsigned long ioat);
 void ioat_dma_unmap(struct ioat_chan_common *chan, enum dma_ctrl_flags flags,
 		    size_t len, struct ioat_dma_descriptor *hw);
+bool ioat_cleanup_preamble(struct ioat_chan_common *chan,
+			   unsigned long *phys_complete);
 #endif /* IOATDMA_H */
diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index a0def66..a92b797 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -49,7 +49,7 @@ static void __ioat2_issue_pending(struct ioat2_dma_chan *ioat)
 	void * __iomem reg_base = ioat->base.reg_base;
 
 	ioat->pending = 0;
-	ioat->dmacount += ioat2_ring_pending(ioat);
+	ioat->dmacount += ioat2_ring_pending(ioat);;
 	ioat->issued = ioat->head;
 	/* make descriptor updates globally visible before notifying channel */
 	wmb();
@@ -92,7 +92,6 @@ static void ioat2_update_pending(struct ioat2_dma_chan *ioat)
 
 static void __ioat2_start_null_desc(struct ioat2_dma_chan *ioat)
 {
-	void __iomem *reg_base = ioat->base.reg_base;
 	struct ioat_ring_ent *desc;
 	struct ioat_dma_descriptor *hw;
 	int idx;
@@ -119,10 +118,7 @@ static void __ioat2_start_null_desc(struct ioat2_dma_chan *ioat)
 	hw->src_addr = 0;
 	hw->dst_addr = 0;
 	async_tx_ack(&desc->txd);
-	writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
-	       reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
-	writel(((u64) desc->txd.phys) >> 32,
-	       reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
+	ioat2_set_chainaddr(ioat, desc->txd.phys);
 	dump_desc_dbg(ioat, desc);
 	__ioat2_issue_pending(ioat);
 }
@@ -134,177 +130,14 @@ static void ioat2_start_null_desc(struct ioat2_dma_chan *ioat)
 	spin_unlock_bh(&ioat->ring_lock);
 }
 
-static void ioat2_cleanup(struct ioat2_dma_chan *ioat);
-
-/**
- * ioat2_reset_part2 - reinit the channel after a reset
- */
-static void ioat2_reset_part2(struct work_struct *work)
-{
-	struct ioat_chan_common *chan;
-	struct ioat2_dma_chan *ioat;
-
-	chan = container_of(work, struct ioat_chan_common, work.work);
-	ioat = container_of(chan, struct ioat2_dma_chan, base);
-
-	/* ensure that ->tail points to the stalled descriptor
-	 * (ioat->pending is set to 2 at this point so no new
-	 * descriptors will be issued while we perform this cleanup)
-	 */
-	ioat2_cleanup(ioat);
-
-	spin_lock_bh(&chan->cleanup_lock);
-	spin_lock_bh(&ioat->ring_lock);
-
-	/* set the tail to be re-issued */
-	ioat->issued = ioat->tail;
-	ioat->dmacount = 0;
-
-	dev_dbg(to_dev(&ioat->base),
-		"%s: head: %#x tail: %#x issued: %#x count: %#x\n",
-		__func__, ioat->head, ioat->tail, ioat->issued, ioat->dmacount);
-
-	if (ioat2_ring_pending(ioat)) {
-		struct ioat_ring_ent *desc;
-
-		desc = ioat2_get_ring_ent(ioat, ioat->tail);
-		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
-		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
-		writel(((u64) desc->txd.phys) >> 32,
-		       chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
-		__ioat2_issue_pending(ioat);
-	} else
-		__ioat2_start_null_desc(ioat);
-
-	spin_unlock_bh(&ioat->ring_lock);
-	spin_unlock_bh(&chan->cleanup_lock);
-
-	dev_info(to_dev(chan),
-		 "chan%d reset - %d descs waiting, %d total desc\n",
-		 chan_num(chan), ioat->dmacount, 1 << ioat->alloc_order);
-}
-
-/**
- * ioat2_reset_channel - restart a channel
- * @ioat: IOAT DMA channel handle
- */
-static void ioat2_reset_channel(struct ioat2_dma_chan *ioat)
+static void __cleanup(struct ioat2_dma_chan *ioat, unsigned long phys_complete)
 {
-	u32 chansts, chanerr;
 	struct ioat_chan_common *chan = &ioat->base;
-	u16 active;
-
-	spin_lock_bh(&ioat->ring_lock);
-	active = ioat2_ring_active(ioat);
-	spin_unlock_bh(&ioat->ring_lock);
-	if (!active)
-		return;
-
-	chanerr = readl(chan->reg_base + IOAT_CHANERR_OFFSET);
-	chansts = *chan->completion & IOAT_CHANSTS_DMA_TRANSFER_STATUS;
-	if (chanerr) {
-		dev_err(to_dev(chan),
-			"chan%d, CHANSTS = 0x%08x CHANERR = 0x%04x, clearing\n",
-			chan_num(chan), chansts, chanerr);
-		writel(chanerr, chan->reg_base + IOAT_CHANERR_OFFSET);
-	}
-
-	spin_lock_bh(&ioat->ring_lock);
-	ioat->pending = 2;
-	writeb(IOAT_CHANCMD_RESET,
-	       chan->reg_base
-	       + IOAT_CHANCMD_OFFSET(chan->device->version));
-	spin_unlock_bh(&ioat->ring_lock);
-	schedule_delayed_work(&chan->work, RESET_DELAY);
-}
-
-/**
- * ioat2_chan_watchdog - watch for stuck channels
- */
-static void ioat2_chan_watchdog(struct work_struct *work)
-{
-	struct ioatdma_device *device =
-		container_of(work, struct ioatdma_device, work.work);
-	struct ioat2_dma_chan *ioat;
-	struct ioat_chan_common *chan;
-	u16 active;
-	int i;
-
-	dev_dbg(&device->pdev->dev, "%s\n", __func__);
-
-	for (i = 0; i < device->common.chancnt; i++) {
-		chan = ioat_chan_by_index(device, i);
-		ioat = container_of(chan, struct ioat2_dma_chan, base);
-
-		/*
-		 * for version 2.0 if there are descriptors yet to be processed
-		 * and the last completed hasn't changed since the last watchdog
-		 *      if they haven't hit the pending level
-		 *          issue the pending to push them through
-		 *      else
-		 *          try resetting the channel
-		 */
-		spin_lock_bh(&ioat->ring_lock);
-		active = ioat2_ring_active(ioat);
-		spin_unlock_bh(&ioat->ring_lock);
-
-		if (active &&
-		    chan->last_completion &&
-		    chan->last_completion == chan->watchdog_completion) {
-
-			if (ioat->pending == 1)
-				ioat2_issue_pending(&chan->common);
-			else {
-				ioat2_reset_channel(ioat);
-				chan->watchdog_completion = 0;
-			}
-		} else {
-			chan->last_compl_desc_addr_hw = 0;
-			chan->watchdog_completion = chan->last_completion;
-		}
-		chan->watchdog_last_tcp_cookie = chan->watchdog_tcp_cookie;
-	}
-	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
-}
-
-/**
- * ioat2_cleanup - clean finished descriptors (advance tail pointer)
- * @chan: ioat channel to be cleaned up
- */
-static void ioat2_cleanup(struct ioat2_dma_chan *ioat)
-{
-	struct ioat_chan_common *chan = &ioat->base;
-	unsigned long phys_complete;
+	struct dma_async_tx_descriptor *tx;
 	struct ioat_ring_ent *desc;
 	bool seen_current = false;
 	u16 active;
 	int i;
-	struct dma_async_tx_descriptor *tx;
-
-	prefetch(chan->completion);
-
-	spin_lock_bh(&chan->cleanup_lock);
-	phys_complete = ioat_get_current_completion(chan);
-	if (phys_complete == chan->last_completion) {
-		spin_unlock_bh(&chan->cleanup_lock);
-		/*
-		 * perhaps we're stuck so hard that the watchdog can't go off?
-		 * try to catch it after WATCHDOG_DELAY seconds
-		 */
-		if (chan->device->version < IOAT_VER_3_0) {
-			unsigned long tmo;
-
-			tmo = chan->last_completion_time + HZ*WATCHDOG_DELAY;
-			if (time_after(jiffies, tmo)) {
-				ioat2_chan_watchdog(&(chan->device->work.work));
-				chan->last_completion_time = jiffies;
-			}
-		}
-		return;
-	}
-	chan->last_completion_time = jiffies;
-
-	spin_lock_bh(&ioat->ring_lock);
 
 	dev_dbg(to_dev(chan), "%s: head: %#x tail: %#x issued: %#x\n",
 		__func__, ioat->head, ioat->tail, ioat->issued);
@@ -330,10 +163,42 @@ static void ioat2_cleanup(struct ioat2_dma_chan *ioat)
 	}
 	ioat->tail += i;
 	BUG_ON(!seen_current); /* no active descs have written a completion? */
-	spin_unlock_bh(&ioat->ring_lock);
 
 	chan->last_completion = phys_complete;
+	if (ioat->head == ioat->tail) {
+		dev_dbg(to_dev(chan), "%s: cancel completion timeout\n",
+			__func__);
+		clear_bit(IOAT_COMPLETION_PENDING, &chan->state);
+	}
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
 
+	prefetch(chan->completion);
+
+	if (!spin_trylock_bh(&chan->cleanup_lock))
+		return;
+
+	if (!ioat_cleanup_preamble(chan, &phys_complete)) {
+		spin_unlock_bh(&chan->cleanup_lock);
+		return;
+	}
+
+	if (!spin_trylock_bh(&ioat->ring_lock)) {
+		spin_unlock_bh(&chan->cleanup_lock);
+		return;
+	}
+
+	__cleanup(ioat, phys_complete);
+
+	spin_unlock_bh(&ioat->ring_lock);
 	spin_unlock_bh(&chan->cleanup_lock);
 }
 
@@ -345,6 +210,90 @@ static void ioat2_cleanup_tasklet(unsigned long data)
 	writew(IOAT_CHANCTRL_RUN, ioat->base.reg_base + IOAT_CHANCTRL_OFFSET);
 }
 
+static void __restart_chan(struct ioat2_dma_chan *ioat)
+{
+	struct ioat_chan_common *chan = &ioat->base;
+
+	/* set the tail to be re-issued */
+	ioat->issued = ioat->tail;
+	ioat->dmacount = 0;
+	set_bit(IOAT_COMPLETION_PENDING, &chan->state);
+	mod_timer(&chan->timer, jiffies + COMPLETION_TIMEOUT);
+
+	dev_dbg(to_dev(chan),
+		"%s: head: %#x tail: %#x issued: %#x count: %#x\n",
+		__func__, ioat->head, ioat->tail, ioat->issued, ioat->dmacount);
+
+	if (ioat2_ring_pending(ioat)) {
+		struct ioat_ring_ent *desc;
+
+		desc = ioat2_get_ring_ent(ioat, ioat->tail);
+		ioat2_set_chainaddr(ioat, desc->txd.phys);
+		__ioat2_issue_pending(ioat);
+	} else
+		__ioat2_start_null_desc(ioat);
+}
+
+static void ioat2_restart_channel(struct ioat2_dma_chan *ioat)
+{
+	struct ioat_chan_common *chan = &ioat->base;
+	unsigned long phys_complete;
+	u32 status;
+
+	status = ioat_chansts(chan);
+	if (is_ioat_active(status) || is_ioat_idle(status))
+		ioat_suspend(chan);
+	while (is_ioat_active(status) || is_ioat_idle(status)) {
+		status = ioat_chansts(chan);
+		cpu_relax();
+	}
+
+	if (ioat_cleanup_preamble(chan, &phys_complete))
+		__cleanup(ioat, phys_complete);
+
+	__restart_chan(ioat);
+}
+
+static void ioat2_timer_event(unsigned long data)
+{
+	struct ioat2_dma_chan *ioat = (void *) data;
+	struct ioat_chan_common *chan = &ioat->base;
+
+	spin_lock_bh(&chan->cleanup_lock);
+	if (test_bit(IOAT_COMPLETION_PENDING, &chan->state)) {
+		unsigned long phys_complete;
+		u64 status;
+
+		spin_lock_bh(&ioat->ring_lock);
+		status = ioat_chansts(chan);
+
+		/* when halted due to errors check for channel
+		 * programming errors before advancing the completion state
+		 */
+		if (is_ioat_halted(status)) {
+			u32 chanerr;
+
+			chanerr = readl(chan->reg_base + IOAT_CHANERR_OFFSET);
+			BUG_ON(is_ioat_bug(chanerr));
+		}
+
+		/* if we haven't made progress and we have already
+		 * acknowledged a pending completion once, then be more
+		 * forceful with a restart
+		 */
+		if (ioat_cleanup_preamble(chan, &phys_complete))
+			__cleanup(ioat, phys_complete);
+		else if (test_bit(IOAT_COMPLETION_ACK, &chan->state))
+			ioat2_restart_channel(ioat);
+		else {
+			set_bit(IOAT_COMPLETION_ACK, &chan->state);
+			mod_timer(&chan->timer, jiffies + COMPLETION_TIMEOUT);
+		}
+		spin_unlock_bh(&ioat->ring_lock);
+	}
+	spin_unlock_bh(&chan->cleanup_lock);
+}
+
 /**
  * ioat2_enumerate_channels - find and initialize the device's channels
  * @device: the device to be enumerated
@@ -382,7 +331,7 @@ static int ioat2_enumerate_channels(struct ioatdma_device *device)
 			break;
 
 		ioat_init_channel(device, &ioat->base, i,
-				  ioat2_reset_part2,
+				  ioat2_timer_event,
 				  ioat2_cleanup_tasklet,
 				  (unsigned long) ioat);
 		ioat->xfercap_log = xfercap_log;
@@ -396,6 +345,7 @@ static dma_cookie_t ioat2_tx_submit_unlock(struct dma_async_tx_descriptor *tx)
 {
 	struct dma_chan *c = tx->chan;
 	struct ioat2_dma_chan *ioat = to_ioat2_chan(c);
+	struct ioat_chan_common *chan = &ioat->base;
 	dma_cookie_t cookie = c->cookie;
 
 	cookie++;
@@ -405,6 +355,8 @@ static dma_cookie_t ioat2_tx_submit_unlock(struct dma_async_tx_descriptor *tx)
 	c->cookie = cookie;
 	dev_dbg(to_dev(&ioat->base), "%s: cookie: %d\n", __func__, cookie);
 
+	if (!test_and_set_bit(IOAT_COMPLETION_PENDING, &chan->state))
+		mod_timer(&chan->timer, jiffies + COMPLETION_TIMEOUT);
 	ioat2_update_pending(ioat);
 	spin_unlock_bh(&ioat->ring_lock);
 
@@ -544,9 +496,18 @@ static int ioat2_alloc_and_lock(u16 *idx, struct ioat2_dma_chan *ioat, int num_d
 				ioat->issued);
 		spin_unlock_bh(&ioat->ring_lock);
 
-		/* do direct reclaim in the allocation failure case */
-		ioat2_cleanup(ioat);
-
+		/* progress reclaim in the allocation failure case we
+		 * may be called under bh_disabled so we need to trigger
+		 * the timer event directly
+		 */
+		spin_lock_bh(&chan->cleanup_lock);
+		if (jiffies > chan->timer.expires &&
+		    timer_pending(&chan->timer)) {
+			mod_timer(&chan->timer, jiffies + COMPLETION_TIMEOUT);
+			spin_unlock_bh(&chan->cleanup_lock);
+			ioat2_timer_event((unsigned long) ioat);
+		} else
+			spin_unlock_bh(&chan->cleanup_lock);
 		return -ENOMEM;
 	}
 
@@ -625,6 +586,7 @@ static void ioat2_free_chan_resources(struct dma_chan *c)
 		return;
 
 	tasklet_disable(&chan->cleanup_task);
+	del_timer_sync(&chan->timer);
 	ioat2_cleanup(ioat);
 
 	/* Delay 100ms after reset to allow internal DMA logic to quiesce
@@ -664,10 +626,6 @@ static void ioat2_free_chan_resources(struct dma_chan *c)
 	chan->completion_dma = 0;
 	ioat->pending = 0;
 	ioat->dmacount = 0;
-	chan->watchdog_completion = 0;
-	chan->last_compl_desc_addr_hw = 0;
-	chan->watchdog_tcp_cookie = 0;
-	chan->watchdog_last_tcp_cookie = 0;
 }
 
 static enum dma_status
@@ -717,9 +675,6 @@ int __devinit ioat2_dma_probe(struct ioatdma_device *device, int dca)
 	if (dca)
 		device->dca = ioat2_dca_init(pdev, device->reg_base);
 
-	INIT_DELAYED_WORK(&device->work, ioat2_chan_watchdog);
-	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
-
 	return err;
 }
 
diff --git a/drivers/dma/ioat/dma_v2.h b/drivers/dma/ioat/dma_v2.h
index bdde537..73b04a2 100644
--- a/drivers/dma/ioat/dma_v2.h
+++ b/drivers/dma/ioat/dma_v2.h
@@ -127,6 +127,16 @@ ioat2_get_ring_ent(struct ioat2_dma_chan *ioat, u16 idx)
 	return ioat->ring[idx & ioat2_ring_mask(ioat)];
 }
 
+static inline void ioat2_set_chainaddr(struct ioat2_dma_chan *ioat, u64 addr)
+{
+	struct ioat_chan_common *chan = &ioat->base;
+
+	writel(addr & 0x00000000FFFFFFFF,
+	       chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
+	writel(addr >> 32,
+	       chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
+}
+
 int __devinit ioat2_dma_probe(struct ioatdma_device *dev, int dca);
 int __devinit ioat3_dma_probe(struct ioatdma_device *dev, int dca);
 struct dca_provider * __devinit ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase);
diff --git a/drivers/dma/ioat/registers.h b/drivers/dma/ioat/registers.h
index 4380f6f..e4334a1 100644
--- a/drivers/dma/ioat/registers.h
+++ b/drivers/dma/ioat/registers.h
@@ -101,11 +101,11 @@
 #define IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR	(~0x3fULL)
 #define IOAT_CHANSTS_SOFT_ERR			0x10ULL
 #define IOAT_CHANSTS_UNAFFILIATED_ERR		0x8ULL
-#define IOAT_CHANSTS_DMA_TRANSFER_STATUS	0x7ULL
-#define IOAT_CHANSTS_DMA_TRANSFER_STATUS_ACTIVE	0x0
-#define IOAT_CHANSTS_DMA_TRANSFER_STATUS_DONE	0x1
-#define IOAT_CHANSTS_DMA_TRANSFER_STATUS_SUSPENDED	0x2
-#define IOAT_CHANSTS_DMA_TRANSFER_STATUS_HALTED	0x3
+#define IOAT_CHANSTS_STATUS	0x7ULL
+#define IOAT_CHANSTS_ACTIVE	0x0
+#define IOAT_CHANSTS_DONE	0x1
+#define IOAT_CHANSTS_SUSPENDED	0x2
+#define IOAT_CHANSTS_HALTED	0x3
 
 
 
@@ -208,18 +208,18 @@
 #define IOAT_CDAR_OFFSET_HIGH			0x24
 
 #define IOAT_CHANERR_OFFSET			0x28	/* 32-bit Channel Error Register */
-#define IOAT_CHANERR_DMA_TRANSFER_SRC_ADDR_ERR	0x0001
-#define IOAT_CHANERR_DMA_TRANSFER_DEST_ADDR_ERR	0x0002
-#define IOAT_CHANERR_NEXT_DESCRIPTOR_ADDR_ERR	0x0004
-#define IOAT_CHANERR_NEXT_DESCRIPTOR_ALIGNMENT_ERR	0x0008
+#define IOAT_CHANERR_SRC_ADDR_ERR	0x0001
+#define IOAT_CHANERR_DEST_ADDR_ERR	0x0002
+#define IOAT_CHANERR_NEXT_ADDR_ERR	0x0004
+#define IOAT_CHANERR_NEXT_DESC_ALIGN_ERR	0x0008
 #define IOAT_CHANERR_CHAIN_ADDR_VALUE_ERR	0x0010
 #define IOAT_CHANERR_CHANCMD_ERR		0x0020
 #define IOAT_CHANERR_CHIPSET_UNCORRECTABLE_DATA_INTEGRITY_ERR	0x0040
 #define IOAT_CHANERR_DMA_UNCORRECTABLE_DATA_INTEGRITY_ERR	0x0080
 #define IOAT_CHANERR_READ_DATA_ERR		0x0100
 #define IOAT_CHANERR_WRITE_DATA_ERR		0x0200
-#define IOAT_CHANERR_DESCRIPTOR_CONTROL_ERR	0x0400
-#define IOAT_CHANERR_DESCRIPTOR_LENGTH_ERR	0x0800
+#define IOAT_CHANERR_CONTROL_ERR	0x0400
+#define IOAT_CHANERR_LENGTH_ERR	0x0800
 #define IOAT_CHANERR_COMPLETION_ADDR_ERR	0x1000
 #define IOAT_CHANERR_INT_CONFIGURATION_ERR	0x2000
 #define IOAT_CHANERR_SOFT_ERR			0x4000

