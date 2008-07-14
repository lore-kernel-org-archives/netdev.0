From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 1/2] I/OAT: Add watchdog/reset functionality to ioatdma driver
Date: Mon, 14 Jul 2008 15:28:25 +0200
Message-ID: <20080714132807.26941.23293.stgit@linux.site>
References: <20080714132645.26941.64737.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8269 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753454AbYGNNiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 09:38:21 -0400
In-Reply-To: <20080714132645.26941.64737.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to occasional DMA channel hangs observed for I/OAT versions 1.2 and 2.0
a watchdog has been introduced to check every 2 seconds
if all channels progress normally.
If stuck channel is detected, driver resets it.
The reset is done in two parts. The second part is scheduled 
by the first one to reinitialize the channel after the restart.

Sleep time in self_test has been increased to 10ms
since in some cases 1ms appeared not to be enough.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
---

 drivers/dma/ioat_dma.c |  258 +++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/dma/ioatdma.h  |   10 ++
 2 files changed, 261 insertions(+), 7 deletions(-)

diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index 318e8a2..9c0b90a 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -32,6 +32,7 @@ #include <linux/interrupt.h>
 #include <linux/dmaengine.h>
 #include <linux/delay.h>
 #include <linux/dma-mapping.h>
+#include <linux/workqueue.h>
 #include "ioatdma.h"
 #include "ioatdma_registers.h"
 #include "ioatdma_hw.h"
@@ -41,11 +42,17 @@ #define to_ioatdma_device(dev) container
 #define to_ioat_desc(lh) container_of(lh, struct ioat_desc_sw, node)
 #define tx_to_ioat_desc(tx) container_of(tx, struct ioat_desc_sw, async_tx)
 
+#define chan_num(ch) ((int)((ch)->reg_base - (ch)->device->reg_base) / 0x80)
 static int ioat_pending_level = 4;
 module_param(ioat_pending_level, int, 0644);
 MODULE_PARM_DESC(ioat_pending_level,
 		 "high-water mark for pushing ioat descriptors (default: 4)");
 
+#define RESET_DELAY  msecs_to_jiffies(100)
+#define WATCHDOG_DELAY  round_jiffies(msecs_to_jiffies(2000))
+static void ioat_dma_chan_reset_part2(struct work_struct *work);
+static void ioat_dma_chan_watchdog(struct work_struct *work);
+
 /* internal functions */
 static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat_chan);
 static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *ioat_chan);
@@ -137,6 +144,7 @@ static int ioat_dma_enumerate_channels(s
 		ioat_chan->reg_base = device->reg_base + (0x80 * (i + 1));
 		ioat_chan->xfercap = xfercap;
 		ioat_chan->desccount = 0;
+		INIT_DELAYED_WORK(&ioat_chan->work, ioat_dma_chan_reset_part2);
 		if (ioat_chan->device->version != IOAT_VER_1_2) {
 			writel(IOAT_DCACTRL_CMPL_WRITE_ENABLE
 					| IOAT_DMA_DCA_ANY_CPU,
@@ -175,7 +183,7 @@ static void ioat1_dma_memcpy_issue_pendi
 {
 	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
 
-	if (ioat_chan->pending != 0) {
+	if (ioat_chan->pending > 0) {
 		spin_lock_bh(&ioat_chan->desc_lock);
 		__ioat1_dma_memcpy_issue_pending(ioat_chan);
 		spin_unlock_bh(&ioat_chan->desc_lock);
@@ -194,13 +202,218 @@ static void ioat2_dma_memcpy_issue_pendi
 {
 	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
 
-	if (ioat_chan->pending != 0) {
+	if (ioat_chan->pending > 0) {
 		spin_lock_bh(&ioat_chan->desc_lock);
 		__ioat2_dma_memcpy_issue_pending(ioat_chan);
 		spin_unlock_bh(&ioat_chan->desc_lock);
 	}
 }
 
+
+/**
+ * ioat_dma_chan_reset_part2 - reinit the channel after a reset
+ */
+static void ioat_dma_chan_reset_part2(struct work_struct *work) 
+{
+	struct ioat_dma_chan *ioat_chan = container_of(work, struct ioat_dma_chan, work.work);
+	struct ioat_desc_sw *desc;
+
+	spin_lock_bh(&ioat_chan->cleanup_lock);
+	spin_lock_bh(&ioat_chan->desc_lock);
+
+	ioat_chan->completion_virt->low = 0;
+	ioat_chan->completion_virt->high = 0;
+	ioat_chan->pending = 0;
+
+	/*
+	 * count the descriptors waiting, and be sure to do it
+	 * right for both the CB1 line and the CB2 ring
+	 */
+	ioat_chan->dmacount = 0;
+	if (ioat_chan->used_desc.prev) {
+		desc = to_ioat_desc(ioat_chan->used_desc.prev);
+		do {
+			ioat_chan->dmacount++;
+			desc = to_ioat_desc(desc->node.next);
+		} while (&desc->node != ioat_chan->used_desc.next);
+	}
+
+	/*
+	 * write the new starting descriptor address
+	 * this puts channel engine into ARMED state
+	 */
+	desc = to_ioat_desc(ioat_chan->used_desc.prev);
+	switch (ioat_chan->device->version) {
+	case IOAT_VER_1_2:
+		writel(((u64) desc->async_tx.phys) & 0x00000000FFFFFFFF,
+		       ioat_chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
+		writel(((u64) desc->async_tx.phys) >> 32,
+		       ioat_chan->reg_base + IOAT1_CHAINADDR_OFFSET_HIGH);
+
+		writeb(IOAT_CHANCMD_START, ioat_chan->reg_base
+			+ IOAT_CHANCMD_OFFSET(ioat_chan->device->version));
+		break;
+	case IOAT_VER_2_0:
+		writel(((u64) desc->async_tx.phys) & 0x00000000FFFFFFFF,
+		       ioat_chan->reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
+		writel(((u64) desc->async_tx.phys) >> 32,
+		       ioat_chan->reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
+
+		/* tell the engine to go with what's left to be done */
+		writew(ioat_chan->dmacount,
+		       ioat_chan->reg_base + IOAT_CHAN_DMACOUNT_OFFSET);
+
+		break;
+	}
+	dev_err(&ioat_chan->device->pdev->dev,
+		"chan%d reset - %d descs waiting, %d total desc\n",
+		chan_num(ioat_chan), ioat_chan->dmacount, ioat_chan->desccount);
+
+	spin_unlock_bh(&ioat_chan->desc_lock);
+	spin_unlock_bh(&ioat_chan->cleanup_lock);
+}
+
+/**
+ * ioat_dma_reset_channel - restart a channel
+ * @ioat_chan: IOAT DMA channel handle
+ */
+static void ioat_dma_reset_channel(struct ioat_dma_chan *ioat_chan)
+{
+	u32 chansts, chanerr;
+
+	if (!ioat_chan->used_desc.prev)
+		return;
+
+	chanerr = readl(ioat_chan->reg_base + IOAT_CHANERR_OFFSET);
+	chansts = (ioat_chan->completion_virt->low
+					& IOAT_CHANSTS_DMA_TRANSFER_STATUS);
+	if (chanerr) {
+		dev_err(&ioat_chan->device->pdev->dev,
+			"chan%d, CHANSTS = 0x%08x CHANERR = 0x%04x, clearing\n",
+			chan_num(ioat_chan), chansts, chanerr);
+		writel(chanerr, ioat_chan->reg_base + IOAT_CHANERR_OFFSET);
+	}
+
+	/*
+	 * whack it upside the head with a reset
+	 * and wait for things to settle out.
+	 * force the pending count to a really big negative
+	 * to make sure no one forces an issue_pending
+	 * while we're waiting.
+	 */
+
+	spin_lock_bh(&ioat_chan->desc_lock);
+	ioat_chan->pending = INT_MIN;
+	writeb(IOAT_CHANCMD_RESET,
+	       ioat_chan->reg_base
+	       + IOAT_CHANCMD_OFFSET(ioat_chan->device->version));
+	spin_unlock_bh(&ioat_chan->desc_lock);
+
+	/* schedule the 2nd half instead of sleeping a long time */
+	schedule_delayed_work(&ioat_chan->work, RESET_DELAY);
+}
+
+/**
+ * ioat_dma_chan_watchdog - watch for stuck channels
+ */
+static void ioat_dma_chan_watchdog(struct work_struct *work)
+{
+	struct ioatdma_device *device = container_of(work, struct ioatdma_device, work.work);
+	struct ioat_dma_chan *ioat_chan;
+	int i;
+
+	union {
+		u64 full;
+		struct {
+			u32 low;
+			u32 high;
+		};
+	} completion_hw;
+	unsigned long compl_desc_addr_hw;
+
+	for (i = 0; i < device->common.chancnt; i++) {
+		ioat_chan = ioat_lookup_chan_by_index(device, i);
+
+		if (ioat_chan->device->version == IOAT_VER_1_2
+			/* have we started processing anything yet */
+		    && ioat_chan->last_completion
+			/* have we completed any since last watchdog cycle? */
+		    && (ioat_chan->last_completion == ioat_chan->watchdog_completion)
+			/* has TCP stuck on one cookie since last watchdog? */
+		    && (ioat_chan->watchdog_tcp_cookie == ioat_chan->watchdog_last_tcp_cookie)
+		    && (ioat_chan->watchdog_tcp_cookie != ioat_chan->completed_cookie)
+			/* is there something in the chain to be processed? */
+			/* CB1 chain always has at least the last one processed */
+		    && (ioat_chan->used_desc.prev != ioat_chan->used_desc.next)
+		    && ioat_chan->pending == 0) {
+
+			/*
+			 * check CHANSTS register for completed descriptor address
+			 * if it is different than completion writeback, it is not zero 
+			 * and it has changed since the last watchdog
+			 *     we can assume that channel is still working correctly 
+			 *     and the problem is in completion writeback.
+			 *     update completion writeback with actual CHANSTS value
+			 * else
+			 *     try resetting the channel
+			 */
+
+			completion_hw.low = readl(ioat_chan->reg_base + 
+				IOAT_CHANSTS_OFFSET_LOW(ioat_chan->device->version));
+			completion_hw.high = readl(ioat_chan->reg_base + 
+				IOAT_CHANSTS_OFFSET_HIGH(ioat_chan->device->version));
+#if (BITS_PER_LONG == 64)
+			compl_desc_addr_hw =
+				completion_hw.full
+				& IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
+#else
+			compl_desc_addr_hw =
+				completion_hw.low & IOAT_LOW_COMPLETION_MASK;
+#endif
+
+			if((compl_desc_addr_hw != 0)
+			   && (compl_desc_addr_hw != ioat_chan->watchdog_completion)
+			   && (compl_desc_addr_hw != ioat_chan->last_compl_desc_addr_hw)) {
+				ioat_chan->last_compl_desc_addr_hw = compl_desc_addr_hw;
+				ioat_chan->completion_virt->low = completion_hw.low;
+				ioat_chan->completion_virt->high = completion_hw.high;
+			} else {
+				ioat_dma_reset_channel(ioat_chan);
+				ioat_chan->watchdog_completion = 0;
+				ioat_chan->last_compl_desc_addr_hw = 0;
+			}
+
+		/*
+		 * for version 2.0 if there are descriptors yet to be processed
+		 * and the last completed hasn't changed since the last watchdog
+		 *      if they haven't hit the pending level
+		 *          issue the pending to push them through
+		 *      else
+		 *          try resetting the channel
+		 */
+		} else if (ioat_chan->device->version == IOAT_VER_2_0
+		    && ioat_chan->used_desc.prev
+		    && ioat_chan->last_completion
+		    && ioat_chan->last_completion == ioat_chan->watchdog_completion) {
+
+			if (ioat_chan->pending < ioat_pending_level)
+				ioat2_dma_memcpy_issue_pending(&ioat_chan->common);
+			else {
+				ioat_dma_reset_channel(ioat_chan);
+				ioat_chan->watchdog_completion = 0;
+			}
+		} else {
+			ioat_chan->last_compl_desc_addr_hw = 0;
+			ioat_chan->watchdog_completion
+					= ioat_chan->last_completion;
+		}
+
+		ioat_chan->watchdog_last_tcp_cookie = ioat_chan->watchdog_tcp_cookie;
+	}
+
+	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
+}
+
 static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 {
 	struct ioat_dma_chan *ioat_chan = to_ioat_chan(tx->chan);
@@ -585,6 +798,9 @@ static void ioat_dma_free_chan_resources
 	ioat_chan->last_completion = ioat_chan->completion_addr = 0;
 	ioat_chan->pending = 0;
 	ioat_chan->dmacount = 0;
+	ioat_chan->watchdog_completion = 0;
+	ioat_chan->last_compl_desc_addr_hw = 0;
+	ioat_chan->watchdog_tcp_cookie = ioat_chan->watchdog_last_tcp_cookie = 0;
 }
 
 /**
@@ -716,8 +932,12 @@ static struct dma_async_tx_descriptor *i
 		new->src = dma_src;
 		new->async_tx.flags = flags;
 		return &new->async_tx;
-	} else
+	} else {
+		dev_err(&ioat_chan->device->pdev->dev,
+			"chan%d - get_next_desc failed: %d descs waiting, %d total desc\n",
+			chan_num(ioat_chan), ioat_chan->dmacount, ioat_chan->desccount);
 		return NULL;
+	}
 }
 
 static struct dma_async_tx_descriptor *ioat2_dma_prep_memcpy(
@@ -744,8 +964,13 @@ static struct dma_async_tx_descriptor *i
 		new->src = dma_src;
 		new->async_tx.flags = flags;
 		return &new->async_tx;
-	} else
+	} else {
+		spin_unlock_bh(&ioat_chan->desc_lock);
+		dev_err(&ioat_chan->device->pdev->dev,
+			"chan%d - get_next_desc failed: %d descs waiting, %d total desc\n",
+			chan_num(ioat_chan), ioat_chan->dmacount, ioat_chan->desccount);
 		return NULL;
+	}
 }
 
 static void ioat_dma_cleanup_tasklet(unsigned long data)
@@ -799,11 +1024,25 @@ #endif
 
 	if (phys_complete == ioat_chan->last_completion) {
 		spin_unlock_bh(&ioat_chan->cleanup_lock);
+		/*
+		 * perhaps we're stuck so hard that the watchdog can't go off?
+		 * try to catch it after 2 seconds
+		 */
+		if (time_after(jiffies, 
+			       ioat_chan->last_completion_time + HZ*WATCHDOG_DELAY)) {
+			ioat_dma_chan_watchdog(&(ioat_chan->device->work.work));
+			ioat_chan->last_completion_time = jiffies;
+		}
 		return;
 	}
+	ioat_chan->last_completion_time = jiffies;
 
 	cookie = 0;
-	spin_lock_bh(&ioat_chan->desc_lock);
+	if (!spin_trylock_bh(&ioat_chan->desc_lock)) {
+		spin_unlock_bh(&ioat_chan->cleanup_lock);
+		return;
+	}
+
 	switch (ioat_chan->device->version) {
 	case IOAT_VER_1_2:
 		list_for_each_entry_safe(desc, _desc,
@@ -943,6 +1182,7 @@ static enum dma_status ioat_dma_is_compl
 
 	last_used = chan->cookie;
 	last_complete = ioat_chan->completed_cookie;
+	ioat_chan->watchdog_tcp_cookie = cookie;
 
 	if (done)
 		*done = last_complete;
@@ -1080,7 +1320,7 @@ static int ioat_dma_self_test(struct ioa
 		goto free_resources;
 	}
 	device->common.device_issue_pending(dma_chan);
-	msleep(1);
+	msleep(10);
 
 	if (device->common.device_is_tx_complete(dma_chan, cookie, NULL, NULL)
 					!= DMA_SUCCESS) {
@@ -1333,6 +1573,10 @@ struct ioatdma_device *ioat_dma_probe(st
 
 	dma_async_device_register(&device->common);
 
+	INIT_DELAYED_WORK(&device->work, ioat_dma_chan_watchdog);
+	schedule_delayed_work(&device->work,
+			      WATCHDOG_DELAY);
+
 	return device;
 
 err_self_test:
@@ -1365,6 +1609,8 @@ void ioat_dma_remove(struct ioatdma_devi
 	pci_release_regions(device->pdev);
 	pci_disable_device(device->pdev);
 
+	cancel_delayed_work(&device->work);
+
 	list_for_each_entry_safe(chan, _chan,
 				 &device->common.channels, device_node) {
 		ioat_chan = to_ioat_chan(chan);
diff --git a/drivers/dma/ioatdma.h b/drivers/dma/ioatdma.h
index f2c7fed..c6ec933 100644
--- a/drivers/dma/ioatdma.h
+++ b/drivers/dma/ioatdma.h
@@ -28,7 +28,7 @@ #include <linux/dmapool.h>
 #include <linux/cache.h>
 #include <linux/pci_ids.h>
 
-#define IOAT_DMA_VERSION  "2.04"
+#define IOAT_DMA_VERSION  "2.18"
 
 enum ioat_interrupt {
 	none = 0,
@@ -40,6 +40,7 @@ enum ioat_interrupt {
 
 #define IOAT_LOW_COMPLETION_MASK	0xffffffc0
 #define IOAT_DMA_DCA_ANY_CPU		~0
+#define IOAT_WATCHDOG_PERIOD		(2 * HZ)
 
 
 /**
@@ -62,6 +63,7 @@ struct ioatdma_device {
 	struct dma_device common;
 	u8 version;
 	enum ioat_interrupt irq_mode;
+	struct delayed_work work;
 	struct msix_entry msix_entries[4];
 	struct ioat_dma_chan *idx[4];
 };
@@ -75,6 +77,7 @@ struct ioat_dma_chan {
 
 	dma_cookie_t completed_cookie;
 	unsigned long last_completion;
+	unsigned long last_completion_time;
 
 	size_t xfercap;	/* XFERCAP register value expanded out */
 
@@ -82,6 +85,10 @@ struct ioat_dma_chan {
 	spinlock_t desc_lock;
 	struct list_head free_desc;
 	struct list_head used_desc;
+	unsigned long watchdog_completion;
+	int watchdog_tcp_cookie;
+	u32 watchdog_last_tcp_cookie;
+	struct delayed_work work;
 
 	int pending;
 	int dmacount;
@@ -98,6 +105,7 @@ struct ioat_dma_chan {
 			u32 high;
 		};
 	} *completion_virt;
+	unsigned long last_compl_desc_addr_hw;
 	struct tasklet_struct cleanup_task;
 };
 

