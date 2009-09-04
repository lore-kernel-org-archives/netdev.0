From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 21/29] ioat2,3: dynamically resize descriptor ring
Date: Thu, 03 Sep 2009 19:32:16 -0700
Message-ID: <20090904023216.32667.55942.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932783AbZIDCcZ@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Increment the allocation order of the descriptor ring every time we run
out of descriptors up to a maximum of allocation order specified by the
module parameter 'ioat_max_alloc_order'.  After each idle period
decrement the allocation order to a minimum order of
'ioat_ring_alloc_order' (i.e. the default ring size, tunable as a module
parameter).

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.h    |    1 
 drivers/dma/ioat/dma_v2.c |  215 +++++++++++++++++++++++++++++++++++++++------
 drivers/dma/ioat/dma_v2.h |    2 
 3 files changed, 187 insertions(+), 31 deletions(-)

diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index dbfccac..d9d6a7e 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -88,6 +88,7 @@ struct ioat_chan_common {
 	#define IOAT_RESET_PENDING 2
 	struct timer_list timer;
 	#define COMPLETION_TIMEOUT msecs_to_jiffies(100)
+	#define IDLE_TIMEOUT msecs_to_jiffies(2000)
 	#define RESET_DELAY msecs_to_jiffies(100)
 	struct ioatdma_device *device;
 	dma_addr_t completion_dma;
diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index a92b797..9ea1a47 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -43,6 +43,10 @@ static int ioat_ring_alloc_order = 8;
 module_param(ioat_ring_alloc_order, int, 0644);
 MODULE_PARM_DESC(ioat_ring_alloc_order,
 		 "ioat2+: allocate 2^n descriptors per channel (default: n=8)");
+static int ioat_ring_max_alloc_order = IOAT_MAX_ORDER;
+module_param(ioat_ring_max_alloc_order, int, 0644);
+MODULE_PARM_DESC(ioat_ring_max_alloc_order,
+		 "ioat2+: upper limit for dynamic ring resizing (default: n=16)");
 
 static void __ioat2_issue_pending(struct ioat2_dma_chan *ioat)
 {
@@ -169,6 +173,7 @@ static void __cleanup(struct ioat2_dma_chan *ioat, unsigned long phys_complete)
 		dev_dbg(to_dev(chan), "%s: cancel completion timeout\n",
 			__func__);
 		clear_bit(IOAT_COMPLETION_PENDING, &chan->state);
+		mod_timer(&chan->timer, jiffies + IDLE_TIMEOUT);
 	}
 }
 
@@ -254,6 +259,8 @@ static void ioat2_restart_channel(struct ioat2_dma_chan *ioat)
 	__restart_chan(ioat);
 }
 
+static bool reshape_ring(struct ioat2_dma_chan *ioat, int order);
+
 static void ioat2_timer_event(unsigned long data)
 {
 	struct ioat2_dma_chan *ioat = (void *) data;
@@ -290,6 +297,23 @@ static void ioat2_timer_event(unsigned long data)
 			mod_timer(&chan->timer, jiffies + COMPLETION_TIMEOUT);
 		}
 		spin_unlock_bh(&ioat->ring_lock);
+	} else {
+		u16 active;
+
+		/* if the ring is idle, empty, and oversized try to step
+		 * down the size
+		 */
+		spin_lock_bh(&ioat->ring_lock);
+		active = ioat2_ring_active(ioat);
+		if (active == 0 && ioat->alloc_order > ioat_get_alloc_order())
+			reshape_ring(ioat, ioat->alloc_order-1);
+		spin_unlock_bh(&ioat->ring_lock);
+
+		/* keep shrinking until we get back to our minimum
+		 * default size
+		 */
+		if (ioat->alloc_order > ioat_get_alloc_order())
+			mod_timer(&chan->timer, jiffies + IDLE_TIMEOUT);
 	}
 	spin_unlock_bh(&chan->cleanup_lock);
 }
@@ -363,7 +387,7 @@ static dma_cookie_t ioat2_tx_submit_unlock(struct dma_async_tx_descriptor *tx)
 	return cookie;
 }
 
-static struct ioat_ring_ent *ioat2_alloc_ring_ent(struct dma_chan *chan)
+static struct ioat_ring_ent *ioat2_alloc_ring_ent(struct dma_chan *chan, gfp_t flags)
 {
 	struct ioat_dma_descriptor *hw;
 	struct ioat_ring_ent *desc;
@@ -371,12 +395,12 @@ static struct ioat_ring_ent *ioat2_alloc_ring_ent(struct dma_chan *chan)
 	dma_addr_t phys;
 
 	dma = to_ioatdma_device(chan->device);
-	hw = pci_pool_alloc(dma->dma_pool, GFP_KERNEL, &phys);
+	hw = pci_pool_alloc(dma->dma_pool, flags, &phys);
 	if (!hw)
 		return NULL;
 	memset(hw, 0, sizeof(*hw));
 
-	desc = kzalloc(sizeof(*desc), GFP_KERNEL);
+	desc = kzalloc(sizeof(*desc), flags);
 	if (!desc) {
 		pci_pool_free(dma->dma_pool, hw, phys);
 		return NULL;
@@ -398,6 +422,42 @@ static void ioat2_free_ring_ent(struct ioat_ring_ent *desc, struct dma_chan *cha
 	kfree(desc);
 }
 
+static struct ioat_ring_ent **ioat2_alloc_ring(struct dma_chan *c, int order, gfp_t flags)
+{
+	struct ioat_ring_ent **ring;
+	int descs = 1 << order;
+	int i;
+
+	if (order > ioat_get_max_alloc_order())
+		return NULL;
+
+	/* allocate the array to hold the software ring */
+	ring = kcalloc(descs, sizeof(*ring), flags);
+	if (!ring)
+		return NULL;
+	for (i = 0; i < descs; i++) {
+		ring[i] = ioat2_alloc_ring_ent(c, flags);
+		if (!ring[i]) {
+			while (i--)
+				ioat2_free_ring_ent(ring[i], c);
+			kfree(ring);
+			return NULL;
+		}
+		set_desc_id(ring[i], i);
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
+	return ring;
+}
+
 /* ioat2_alloc_chan_resources - allocate/initialize ioat2 descriptor ring
  * @chan: channel to be initialized
  */
@@ -407,8 +467,7 @@ static int ioat2_alloc_chan_resources(struct dma_chan *c)
 	struct ioat_chan_common *chan = &ioat->base;
 	struct ioat_ring_ent **ring;
 	u32 chanerr;
-	int descs;
-	int i;
+	int order;
 
 	/* have we already been set up? */
 	if (ioat->ring)
@@ -436,32 +495,10 @@ static int ioat2_alloc_chan_resources(struct dma_chan *c)
 	writel(((u64) chan->completion_dma) >> 32,
 	       chan->reg_base + IOAT_CHANCMP_OFFSET_HIGH);
 
-	ioat->alloc_order = ioat_get_alloc_order();
-	descs = 1 << ioat->alloc_order;
-
-	/* allocate the array to hold the software ring */
-	ring = kcalloc(descs, sizeof(*ring), GFP_KERNEL);
+	order = ioat_get_alloc_order();
+	ring = ioat2_alloc_ring(c, order, GFP_KERNEL);
 	if (!ring)
 		return -ENOMEM;
-	for (i = 0; i < descs; i++) {
-		ring[i] = ioat2_alloc_ring_ent(c);
-		if (!ring[i]) {
-			while (i--)
-				ioat2_free_ring_ent(ring[i], c);
-			kfree(ring);
-			return -ENOMEM;
-		}
-		set_desc_id(ring[i], i);
-	}
-
-	/* link descs */
-	for (i = 0; i < descs-1; i++) {
-		struct ioat_ring_ent *next = ring[i+1];
-		struct ioat_dma_descriptor *hw = ring[i]->hw;
-
-		hw->next = next->txd.phys;
-	}
-	ring[i]->hw->next = ring[0]->txd.phys;
 
 	spin_lock_bh(&ioat->ring_lock);
 	ioat->ring = ring;
@@ -469,12 +506,120 @@ static int ioat2_alloc_chan_resources(struct dma_chan *c)
 	ioat->issued = 0;
 	ioat->tail = 0;
 	ioat->pending = 0;
+	ioat->alloc_order = order;
 	spin_unlock_bh(&ioat->ring_lock);
 
 	tasklet_enable(&chan->cleanup_task);
 	ioat2_start_null_desc(ioat);
 
-	return descs;
+	return 1 << ioat->alloc_order;
+}
+
+static bool reshape_ring(struct ioat2_dma_chan *ioat, int order)
+{
+	/* reshape differs from normal ring allocation in that we want
+	 * to allocate a new software ring while only
+	 * extending/truncating the hardware ring
+	 */
+	struct ioat_chan_common *chan = &ioat->base;
+	struct dma_chan *c = &chan->common;
+	const u16 curr_size = ioat2_ring_mask(ioat) + 1;
+	const u16 active = ioat2_ring_active(ioat);
+	const u16 new_size = 1 << order;
+	struct ioat_ring_ent **ring;
+	u16 i;
+
+	if (order > ioat_get_max_alloc_order())
+		return false;
+
+	/* double check that we have at least 1 free descriptor */
+	if (active == curr_size)
+		return false;
+
+	/* when shrinking, verify that we can hold the current active
+	 * set in the new ring
+	 */
+	if (active >= new_size)
+		return false;
+
+	/* allocate the array to hold the software ring */
+	ring = kcalloc(new_size, sizeof(*ring), GFP_NOWAIT);
+	if (!ring)
+		return false;
+
+	/* allocate/trim descriptors as needed */
+	if (new_size > curr_size) {
+		/* copy current descriptors to the new ring */
+		for (i = 0; i < curr_size; i++) {
+			u16 curr_idx = (ioat->tail+i) & (curr_size-1);
+			u16 new_idx = (ioat->tail+i) & (new_size-1);
+
+			ring[new_idx] = ioat->ring[curr_idx];
+			set_desc_id(ring[new_idx], new_idx);
+		}
+
+		/* add new descriptors to the ring */
+		for (i = curr_size; i < new_size; i++) {
+			u16 new_idx = (ioat->tail+i) & (new_size-1);
+
+			ring[new_idx] = ioat2_alloc_ring_ent(c, GFP_NOWAIT);
+			if (!ring[new_idx]) {
+				while (i--) {
+					u16 new_idx = (ioat->tail+i) & (new_size-1);
+
+					ioat2_free_ring_ent(ring[new_idx], c);
+				}
+				kfree(ring);
+				return false;
+			}
+			set_desc_id(ring[new_idx], new_idx);
+		}
+
+		/* hw link new descriptors */
+		for (i = curr_size-1; i < new_size; i++) {
+			u16 new_idx = (ioat->tail+i) & (new_size-1);
+			struct ioat_ring_ent *next = ring[(new_idx+1) & (new_size-1)];
+			struct ioat_dma_descriptor *hw = ring[new_idx]->hw;
+
+			hw->next = next->txd.phys;
+		}
+	} else {
+		struct ioat_dma_descriptor *hw;
+		struct ioat_ring_ent *next;
+
+		/* copy current descriptors to the new ring, dropping the
+		 * removed descriptors
+		 */
+		for (i = 0; i < new_size; i++) {
+			u16 curr_idx = (ioat->tail+i) & (curr_size-1);
+			u16 new_idx = (ioat->tail+i) & (new_size-1);
+
+			ring[new_idx] = ioat->ring[curr_idx];
+			set_desc_id(ring[new_idx], new_idx);
+		}
+
+		/* free deleted descriptors */
+		for (i = new_size; i < curr_size; i++) {
+			struct ioat_ring_ent *ent;
+
+			ent = ioat2_get_ring_ent(ioat, ioat->tail+i);
+			ioat2_free_ring_ent(ent, c);
+		}
+
+		/* fix up hardware ring */
+		hw = ring[(ioat->tail+new_size-1) & (new_size-1)]->hw;
+		next = ring[(ioat->tail+new_size) & (new_size-1)];
+		hw->next = next->txd.phys;
+	}
+
+	dev_dbg(to_dev(chan), "%s: allocated %d descriptors\n",
+		__func__, new_size);
+
+	kfree(ioat->ring);
+	ioat->ring = ring;
+	ioat->alloc_order = order;
+
+	return true;
 }
 
 /**
@@ -488,7 +633,15 @@ static int ioat2_alloc_and_lock(u16 *idx, struct ioat2_dma_chan *ioat, int num_d
 	struct ioat_chan_common *chan = &ioat->base;
 
 	spin_lock_bh(&ioat->ring_lock);
-	if (unlikely(ioat2_ring_space(ioat) < num_descs)) {
+	/* never allow the last descriptor to be consumed, we need at
+	 * least one free at all times to allow for on-the-fly ring
+	 * resizing.
+	 */
+	while (unlikely(ioat2_ring_space(ioat) <= num_descs)) {
+		if (reshape_ring(ioat, ioat->alloc_order + 1) &&
+		    ioat2_ring_space(ioat) > num_descs)
+				break;
+
 		if (printk_ratelimit())
 			dev_dbg(to_dev(chan),
 				"%s: ring full! num_descs: %d (%x:%x:%x)\n",
diff --git a/drivers/dma/ioat/dma_v2.h b/drivers/dma/ioat/dma_v2.h
index 73b04a2..9baa3d6 100644
--- a/drivers/dma/ioat/dma_v2.h
+++ b/drivers/dma/ioat/dma_v2.h
@@ -37,6 +37,8 @@ extern int ioat_pending_level;
 #define IOAT_MAX_ORDER 16
 #define ioat_get_alloc_order() \
 	(min(ioat_ring_alloc_order, IOAT_MAX_ORDER))
+#define ioat_get_max_alloc_order() \
+	(min(ioat_ring_max_alloc_order, IOAT_MAX_ORDER))
 
 /* struct ioat2_dma_chan - ioat v2 / v3 channel attributes
  * @base: common ioat channel parameters
