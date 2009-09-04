From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 15/29] ioat: cleanup completion status reads
Date: Thu, 03 Sep 2009 19:31:46 -0700
Message-ID: <20090904023146.32667.48008.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932893AbZIDCgv@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cleanup path makes an effort to only perform an atomic read of the
64-bit completion address.  However in the 32-bit case it does not
matter if we read the upper-32 and lower-32 non-atomically because the
upper-32 will always be zero.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c       |   78 ++++++++++++++++--------------------------
 drivers/dma/ioat/dma.h       |   10 +----
 drivers/dma/ioat/dma_v2.c    |   25 ++++++-------
 drivers/dma/ioat/registers.h |    8 ++--
 4 files changed, 46 insertions(+), 75 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index edf4f5e..08417ad 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -201,8 +201,7 @@ static void ioat1_reset_part2(struct work_struct *work)
 	spin_lock_bh(&chan->cleanup_lock);
 	spin_lock_bh(&ioat->desc_lock);
 
-	chan->completion_virt->low = 0;
-	chan->completion_virt->high = 0;
+	*chan->completion = 0;
 	ioat->pending = 0;
 
 	/* count the descriptors waiting */
@@ -256,8 +255,7 @@ static void ioat1_reset_channel(struct ioat_dma_chan *ioat)
 
 	dev_dbg(to_dev(chan), "%s\n", __func__);
 	chanerr = readl(reg_base + IOAT_CHANERR_OFFSET);
-	chansts = (chan->completion_virt->low
-					& IOAT_CHANSTS_DMA_TRANSFER_STATUS);
+	chansts = *chan->completion & IOAT_CHANSTS_DMA_TRANSFER_STATUS;
 	if (chanerr) {
 		dev_err(to_dev(chan),
 			"chan%d, CHANSTS = 0x%08x CHANERR = 0x%04x, clearing\n",
@@ -293,14 +291,8 @@ static void ioat1_chan_watchdog(struct work_struct *work)
 	struct ioat_dma_chan *ioat;
 	struct ioat_chan_common *chan;
 	int i;
-
-	union {
-		u64 full;
-		struct {
-			u32 low;
-			u32 high;
-		};
-	} completion_hw;
+	u64 completion;
+	u32 completion_low;
 	unsigned long compl_desc_addr_hw;
 
 	for (i = 0; i < device->common.chancnt; i++) {
@@ -334,25 +326,24 @@ static void ioat1_chan_watchdog(struct work_struct *work)
 			 *     try resetting the channel
 			 */
 
-			completion_hw.low = readl(chan->reg_base +
+			/* we need to read the low address first as this
+			 * causes the chipset to latch the upper bits
+			 * for the subsequent read
+			 */
+			completion_low = readl(chan->reg_base +
 				IOAT_CHANSTS_OFFSET_LOW(chan->device->version));
-			completion_hw.high = readl(chan->reg_base +
+			completion = readl(chan->reg_base +
 				IOAT_CHANSTS_OFFSET_HIGH(chan->device->version));
-#if (BITS_PER_LONG == 64)
-			compl_desc_addr_hw =
-				completion_hw.full
-				& IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
-#else
-			compl_desc_addr_hw =
-				completion_hw.low & IOAT_LOW_COMPLETION_MASK;
-#endif
+			completion <<= 32;
+			completion |= completion_low;
+			compl_desc_addr_hw = completion &
+					IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
 
 			if ((compl_desc_addr_hw != 0)
 			   && (compl_desc_addr_hw != chan->watchdog_completion)
 			   && (compl_desc_addr_hw != chan->last_compl_desc_addr_hw)) {
 				chan->last_compl_desc_addr_hw = compl_desc_addr_hw;
-				chan->completion_virt->low = completion_hw.low;
-				chan->completion_virt->high = completion_hw.high;
+				*chan->completion = completion;
 			} else {
 				ioat1_reset_channel(ioat);
 				chan->watchdog_completion = 0;
@@ -492,14 +483,12 @@ static int ioat1_dma_alloc_chan_resources(struct dma_chan *c)
 
 	/* allocate a completion writeback area */
 	/* doing 2 32bit writes to mmio since 1 64b write doesn't work */
-	chan->completion_virt = pci_pool_alloc(chan->device->completion_pool,
-					       GFP_KERNEL,
-					       &chan->completion_addr);
-	memset(chan->completion_virt, 0,
-	       sizeof(*chan->completion_virt));
-	writel(((u64) chan->completion_addr) & 0x00000000FFFFFFFF,
+	chan->completion = pci_pool_alloc(chan->device->completion_pool,
+					  GFP_KERNEL, &chan->completion_dma);
+	memset(chan->completion, 0, sizeof(*chan->completion));
+	writel(((u64) chan->completion_dma) & 0x00000000FFFFFFFF,
 	       chan->reg_base + IOAT_CHANCMP_OFFSET_LOW);
-	writel(((u64) chan->completion_addr) >> 32,
+	writel(((u64) chan->completion_dma) >> 32,
 	       chan->reg_base + IOAT_CHANCMP_OFFSET_HIGH);
 
 	tasklet_enable(&chan->cleanup_task);
@@ -558,15 +547,16 @@ static void ioat1_dma_free_chan_resources(struct dma_chan *c)
 	spin_unlock_bh(&ioat->desc_lock);
 
 	pci_pool_free(ioatdma_device->completion_pool,
-		      chan->completion_virt,
-		      chan->completion_addr);
+		      chan->completion,
+		      chan->completion_dma);
 
 	/* one is ok since we left it on there on purpose */
 	if (in_use_descs > 1)
 		dev_err(to_dev(chan), "Freeing %d in use descriptors!\n",
 			in_use_descs - 1);
 
-	chan->last_completion = chan->completion_addr = 0;
+	chan->last_completion = 0;
+	chan->completion_dma = 0;
 	chan->watchdog_completion = 0;
 	chan->last_compl_desc_addr_hw = 0;
 	chan->watchdog_tcp_cookie = chan->watchdog_last_tcp_cookie = 0;
@@ -709,25 +699,15 @@ void ioat_dma_unmap(struct ioat_chan_common *chan, enum dma_ctrl_flags flags,
 unsigned long ioat_get_current_completion(struct ioat_chan_common *chan)
 {
 	unsigned long phys_complete;
+	u64 completion;
 
-	/* The completion writeback can happen at any time,
-	   so reads by the driver need to be atomic operations
-	   The descriptor physical addresses are limited to 32-bits
-	   when the CPU can only do a 32-bit mov */
-
-#if (BITS_PER_LONG == 64)
-	phys_complete =
-		chan->completion_virt->full
-		& IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
-#else
-	phys_complete = chan->completion_virt->low & IOAT_LOW_COMPLETION_MASK;
-#endif
+	completion = *chan->completion;
+	phys_complete = completion & IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
 
 	dev_dbg(to_dev(chan), "%s: phys_complete: %#llx\n", __func__,
 		(unsigned long long) phys_complete);
 
-	if ((chan->completion_virt->full
-		& IOAT_CHANSTS_DMA_TRANSFER_STATUS) ==
+	if ((completion & IOAT_CHANSTS_DMA_TRANSFER_STATUS) ==
 				IOAT_CHANSTS_DMA_TRANSFER_STATUS_HALTED) {
 		dev_err(to_dev(chan), "Channel halted, chanerr = %x\n",
 			readl(chan->reg_base + IOAT_CHANERR_OFFSET));
@@ -750,7 +730,7 @@ static void ioat1_cleanup(struct ioat_dma_chan *ioat)
 	dma_cookie_t cookie = 0;
 	struct dma_async_tx_descriptor *tx;
 
-	prefetch(chan->completion_virt);
+	prefetch(chan->completion);
 
 	if (!spin_trylock_bh(&chan->cleanup_lock))
 		return;
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index 9f9edc2..5fd6e2d 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -96,14 +96,8 @@ struct ioat_chan_common {
 	struct ioatdma_device *device;
 	struct dma_chan common;
 
-	dma_addr_t completion_addr;
-	union {
-		u64 full; /* HW completion writeback */
-		struct {
-			u32 low;
-			u32 high;
-		};
-	} *completion_virt;
+	dma_addr_t completion_dma;
+	u64 *completion;
 	unsigned long last_compl_desc_addr_hw;
 	struct tasklet_struct cleanup_task;
 };
diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index eecda23..9bd3d14 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -201,8 +201,7 @@ static void ioat2_reset_channel(struct ioat2_dma_chan *ioat)
 		return;
 
 	chanerr = readl(chan->reg_base + IOAT_CHANERR_OFFSET);
-	chansts = (chan->completion_virt->low
-					& IOAT_CHANSTS_DMA_TRANSFER_STATUS);
+	chansts = *chan->completion & IOAT_CHANSTS_DMA_TRANSFER_STATUS;
 	if (chanerr) {
 		dev_err(to_dev(chan),
 			"chan%d, CHANSTS = 0x%08x CHANERR = 0x%04x, clearing\n",
@@ -282,7 +281,7 @@ static void ioat2_cleanup(struct ioat2_dma_chan *ioat)
 	int i;
 	struct dma_async_tx_descriptor *tx;
 
-	prefetch(chan->completion_virt);
+	prefetch(chan->completion);
 
 	spin_lock_bh(&chan->cleanup_lock);
 	phys_complete = ioat_get_current_completion(chan);
@@ -471,17 +470,15 @@ static int ioat2_alloc_chan_resources(struct dma_chan *c)
 
 	/* allocate a completion writeback area */
 	/* doing 2 32bit writes to mmio since 1 64b write doesn't work */
-	chan->completion_virt = pci_pool_alloc(chan->device->completion_pool,
-					       GFP_KERNEL,
-					       &chan->completion_addr);
-	if (!chan->completion_virt)
+	chan->completion = pci_pool_alloc(chan->device->completion_pool,
+					  GFP_KERNEL, &chan->completion_dma);
+	if (!chan->completion)
 		return -ENOMEM;
 
-	memset(chan->completion_virt, 0,
-	       sizeof(*chan->completion_virt));
-	writel(((u64) chan->completion_addr) & 0x00000000FFFFFFFF,
+	memset(chan->completion, 0, sizeof(*chan->completion));
+	writel(((u64) chan->completion_dma) & 0x00000000FFFFFFFF,
 	       chan->reg_base + IOAT_CHANCMP_OFFSET_LOW);
-	writel(((u64) chan->completion_addr) >> 32,
+	writel(((u64) chan->completion_dma) >> 32,
 	       chan->reg_base + IOAT_CHANCMP_OFFSET_HIGH);
 
 	ioat->alloc_order = ioat_get_alloc_order();
@@ -656,12 +653,12 @@ static void ioat2_free_chan_resources(struct dma_chan *c)
 	ioat->ring = NULL;
 	ioat->alloc_order = 0;
 	pci_pool_free(ioatdma_device->completion_pool,
-		      chan->completion_virt,
-		      chan->completion_addr);
+		      chan->completion,
+		      chan->completion_dma);
 	spin_unlock_bh(&ioat->ring_lock);
 
 	chan->last_completion = 0;
-	chan->completion_addr = 0;
+	chan->completion_dma = 0;
 	ioat->pending = 0;
 	ioat->dmacount = 0;
 	chan->watchdog_completion = 0;
diff --git a/drivers/dma/ioat/registers.h b/drivers/dma/ioat/registers.h
index 49bc277..a83c733 100644
--- a/drivers/dma/ioat/registers.h
+++ b/drivers/dma/ioat/registers.h
@@ -94,10 +94,10 @@
 #define IOAT2_CHANSTS_OFFSET_HIGH	0x0C
 #define IOAT_CHANSTS_OFFSET_HIGH(ver)		((ver) < IOAT_VER_2_0 \
 						? IOAT1_CHANSTS_OFFSET_HIGH : IOAT2_CHANSTS_OFFSET_HIGH)
-#define IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR	~0x3F
-#define IOAT_CHANSTS_SOFT_ERR			0x0000000000000010
-#define IOAT_CHANSTS_UNAFFILIATED_ERR		0x0000000000000008
-#define IOAT_CHANSTS_DMA_TRANSFER_STATUS	0x0000000000000007
+#define IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR	(~0x3fULL)
+#define IOAT_CHANSTS_SOFT_ERR			0x10ULL
+#define IOAT_CHANSTS_UNAFFILIATED_ERR		0x8ULL
+#define IOAT_CHANSTS_DMA_TRANSFER_STATUS	0x7ULL
 #define IOAT_CHANSTS_DMA_TRANSFER_STATUS_ACTIVE	0x0
 #define IOAT_CHANSTS_DMA_TRANSFER_STATUS_DONE	0x1
 #define IOAT_CHANSTS_DMA_TRANSFER_STATUS_SUSPENDED	0x2
