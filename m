From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 14/29] ioat: add some dev_dbg() calls
Date: Thu, 03 Sep 2009 19:31:41 -0700
Message-ID: <20090904023141.32667.4293.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59511 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932493AbZIDCbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 22:31:40 -0400
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide some output for debugging the driver.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c    |   29 ++++++++++++++++++++++++++---
 drivers/dma/ioat/dma.h    |   28 ++++++++++++++++++++++++++++
 drivers/dma/ioat/dma_v2.c |   25 ++++++++++++++++++++++++-
 drivers/dma/ioat/dma_v2.h |    3 +++
 4 files changed, 81 insertions(+), 4 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index 696d4de..edf4f5e 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -134,6 +134,7 @@ static int ioat1_enumerate_channels(struct ioatdma_device *device)
 	dma->chancnt = readb(device->reg_base + IOAT_CHANCNT_OFFSET);
 	xfercap_scale = readb(device->reg_base + IOAT_XFERCAP_OFFSET);
 	xfercap = (xfercap_scale == 0 ? -1 : (1UL << xfercap_scale));
+	dev_dbg(dev, "%s: xfercap = %d\n", __func__, xfercap);
 
 #ifdef  CONFIG_I7300_IDLE_IOAT_CHANNEL
 	if (i7300_idle_platform_probe(NULL, NULL, 1) == 0)
@@ -167,6 +168,8 @@ __ioat1_dma_memcpy_issue_pending(struct ioat_dma_chan *ioat)
 {
 	void __iomem *reg_base = ioat->base.reg_base;
 
+	dev_dbg(to_dev(&ioat->base), "%s: pending: %d\n",
+		__func__, ioat->pending);
 	ioat->pending = 0;
 	writeb(IOAT_CHANCMD_APPEND, reg_base + IOAT1_CHANCMD_OFFSET);
 }
@@ -251,6 +254,7 @@ static void ioat1_reset_channel(struct ioat_dma_chan *ioat)
 	if (!ioat->used_desc.prev)
 		return;
 
+	dev_dbg(to_dev(chan), "%s\n", __func__);
 	chanerr = readl(reg_base + IOAT_CHANERR_OFFSET);
 	chansts = (chan->completion_virt->low
 					& IOAT_CHANSTS_DMA_TRANSFER_STATUS);
@@ -382,6 +386,7 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 		cookie = 1;
 	c->cookie = cookie;
 	tx->cookie = cookie;
+	dev_dbg(to_dev(&ioat->base), "%s: cookie: %d\n", __func__, cookie);
 
 	/* write address into NextDescriptor field of last desc in chain */
 	first = to_ioat_desc(tx->tx_list.next);
@@ -390,6 +395,8 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	wmb();
 	chain_tail->hw->next = first->txd.phys;
 	list_splice_tail_init(&tx->tx_list, &ioat->used_desc);
+	dump_desc_dbg(ioat, chain_tail);
+	dump_desc_dbg(ioat, first);
 
 	ioat->pending += desc->tx_cnt;
 	if (ioat->pending >= ioat_pending_level)
@@ -429,6 +436,7 @@ ioat_dma_alloc_descriptor(struct ioat_dma_chan *ioat, gfp_t flags)
 	desc_sw->txd.tx_submit = ioat1_tx_submit;
 	desc_sw->hw = desc;
 	desc_sw->txd.phys = phys;
+	set_desc_id(desc_sw, -1);
 
 	return desc_sw;
 }
@@ -474,6 +482,7 @@ static int ioat1_dma_alloc_chan_resources(struct dma_chan *c)
 			dev_err(to_dev(chan), "Only %d initial descriptors\n", i);
 			break;
 		}
+		set_desc_id(desc, i);
 		list_add_tail(&desc->node, &tmp_list);
 	}
 	spin_lock_bh(&ioat->desc_lock);
@@ -495,6 +504,8 @@ static int ioat1_dma_alloc_chan_resources(struct dma_chan *c)
 
 	tasklet_enable(&chan->cleanup_task);
 	ioat1_dma_start_null_desc(ioat);  /* give chain to dma device */
+	dev_dbg(to_dev(chan), "%s: allocated %d descriptors\n",
+		__func__, ioat->desccount);
 	return ioat->desccount;
 }
 
@@ -527,8 +538,10 @@ static void ioat1_dma_free_chan_resources(struct dma_chan *c)
 	mdelay(100);
 
 	spin_lock_bh(&ioat->desc_lock);
-	list_for_each_entry_safe(desc, _desc,
-				 &ioat->used_desc, node) {
+	list_for_each_entry_safe(desc, _desc, &ioat->used_desc, node) {
+		dev_dbg(to_dev(chan), "%s: freeing %d from used list\n",
+			__func__, desc_id(desc));
+		dump_desc_dbg(ioat, desc);
 		in_use_descs++;
 		list_del(&desc->node);
 		pci_pool_free(ioatdma_device->dma_pool, desc->hw,
@@ -585,7 +598,8 @@ ioat1_dma_get_next_descriptor(struct ioat_dma_chan *ioat)
 			return NULL;
 		}
 	}
-
+	dev_dbg(to_dev(&ioat->base), "%s: allocated: %d\n",
+		__func__, desc_id(new));
 	prefetch(new->hw);
 	return new;
 }
@@ -630,6 +644,7 @@ ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 			async_tx_ack(&desc->txd);
 			next = ioat1_dma_get_next_descriptor(ioat);
 			hw->next = next ? next->txd.phys : 0;
+			dump_desc_dbg(ioat, desc);
 			desc = next;
 		} else
 			hw->next = 0;
@@ -652,6 +667,7 @@ ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 	list_splice(&chain, &desc->txd.tx_list);
 	hw->ctl_f.int_en = !!(flags & DMA_PREP_INTERRUPT);
 	hw->ctl_f.compl_write = 1;
+	dump_desc_dbg(ioat, desc);
 
 	return &desc->txd;
 }
@@ -707,6 +723,9 @@ unsigned long ioat_get_current_completion(struct ioat_chan_common *chan)
 	phys_complete = chan->completion_virt->low & IOAT_LOW_COMPLETION_MASK;
 #endif
 
+	dev_dbg(to_dev(chan), "%s: phys_complete: %#llx\n", __func__,
+		(unsigned long long) phys_complete);
+
 	if ((chan->completion_virt->full
 		& IOAT_CHANSTS_DMA_TRANSFER_STATUS) ==
 				IOAT_CHANSTS_DMA_TRANSFER_STATUS_HALTED) {
@@ -758,6 +777,8 @@ static void ioat1_cleanup(struct ioat_dma_chan *ioat)
 		return;
 	}
 
+	dev_dbg(to_dev(chan), "%s: phys_complete: %lx\n",
+		 __func__, phys_complete);
 	list_for_each_entry_safe(desc, _desc, &ioat->used_desc, node) {
 		tx = &desc->txd;
 		/*
@@ -765,6 +786,7 @@ static void ioat1_cleanup(struct ioat_dma_chan *ioat)
 		 * due to exceeding xfercap, perhaps. If so, only the
 		 * last one will have a cookie, and require unmapping.
 		 */
+		dump_desc_dbg(ioat, desc);
 		if (tx->cookie) {
 			cookie = tx->cookie;
 			ioat_dma_unmap(chan, tx->flags, desc->len, desc->hw);
@@ -848,6 +870,7 @@ static void ioat1_dma_start_null_desc(struct ioat_dma_chan *ioat)
 	async_tx_ack(&desc->txd);
 	hw->next = 0;
 	list_add_tail(&desc->node, &ioat->used_desc);
+	dump_desc_dbg(ioat, desc);
 
 	writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
 	       chan->reg_base + IOAT1_CHAINADDR_OFFSET_LOW);
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index fa15e77..9f9edc2 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -173,6 +173,7 @@ ioat_is_complete(struct dma_chan *c, dma_cookie_t cookie,
  *     or attached to a transaction list (async_tx.tx_list)
  * @tx_cnt: number of descriptors required to complete the transaction
  * @txd: the generic software descriptor for all engines
+ * @id: identifier for debug
  */
 struct ioat_desc_sw {
 	struct ioat_dma_descriptor *hw;
@@ -180,8 +181,35 @@ struct ioat_desc_sw {
 	int tx_cnt;
 	size_t len;
 	struct dma_async_tx_descriptor txd;
+	#ifdef DEBUG
+	int id;
+	#endif
 };
 
+#ifdef DEBUG
+#define set_desc_id(desc, i) ((desc)->id = (i))
+#define desc_id(desc) ((desc)->id)
+#else
+#define set_desc_id(desc, i)
+#define desc_id(desc) (0)
+#endif
+
+static inline void
+__dump_desc_dbg(struct ioat_chan_common *chan, struct ioat_dma_descriptor *hw,
+		struct dma_async_tx_descriptor *tx, int id)
+{
+	struct device *dev = to_dev(chan);
+
+	dev_dbg(dev, "desc[%d]: (%#llx->%#llx) cookie: %d flags: %#x"
+		" ctl: %#x (op: %d int_en: %d compl: %d)\n", id,
+		(unsigned long long) tx->phys,
+		(unsigned long long) hw->next, tx->cookie, tx->flags,
+		hw->ctl, hw->ctl_f.op, hw->ctl_f.int_en, hw->ctl_f.compl_write);
+}
+
+#define dump_desc_dbg(c, d) \
+	({ if (d) __dump_desc_dbg(&c->base, d->hw, &d->txd, desc_id(d)); 0; })
+
 static inline void ioat_set_tcp_copy_break(unsigned long copybreak)
 {
 	#ifdef CONFIG_NET_DMA
diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index 9ac2d7b..eecda23 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -54,7 +54,9 @@ static void __ioat2_issue_pending(struct ioat2_dma_chan *ioat)
 	/* make descriptor updates globally visible before notifying channel */
 	wmb();
 	writew(ioat->dmacount, reg_base + IOAT_CHAN_DMACOUNT_OFFSET);
-
+	dev_dbg(to_dev(&ioat->base),
+		"%s: head: %#x tail: %#x issued: %#x count: %#x\n",
+		__func__, ioat->head, ioat->tail, ioat->issued, ioat->dmacount);
 }
 
 static void ioat2_issue_pending(struct dma_chan *chan)
@@ -102,6 +104,8 @@ static void __ioat2_start_null_desc(struct ioat2_dma_chan *ioat)
 		return;
 	}
 
+	dev_dbg(to_dev(&ioat->base), "%s: head: %#x tail: %#x issued: %#x\n",
+		__func__, ioat->head, ioat->tail, ioat->issued);
 	idx = ioat2_desc_alloc(ioat, 1);
 	desc = ioat2_get_ring_ent(ioat, idx);
 
@@ -119,6 +123,7 @@ static void __ioat2_start_null_desc(struct ioat2_dma_chan *ioat)
 	       reg_base + IOAT2_CHAINADDR_OFFSET_LOW);
 	writel(((u64) desc->txd.phys) >> 32,
 	       reg_base + IOAT2_CHAINADDR_OFFSET_HIGH);
+	dump_desc_dbg(ioat, desc);
 	__ioat2_issue_pending(ioat);
 }
 
@@ -155,6 +160,10 @@ static void ioat2_reset_part2(struct work_struct *work)
 	ioat->issued = ioat->tail;
 	ioat->dmacount = 0;
 
+	dev_dbg(to_dev(&ioat->base),
+		"%s: head: %#x tail: %#x issued: %#x count: %#x\n",
+		__func__, ioat->head, ioat->tail, ioat->issued, ioat->dmacount);
+
 	if (ioat2_ring_pending(ioat)) {
 		struct ioat_ring_ent *desc;
 
@@ -222,6 +231,8 @@ static void ioat2_chan_watchdog(struct work_struct *work)
 	u16 active;
 	int i;
 
+	dev_dbg(&device->pdev->dev, "%s\n", __func__);
+
 	for (i = 0; i < device->common.chancnt; i++) {
 		chan = ioat_chan_by_index(device, i);
 		ioat = container_of(chan, struct ioat2_dma_chan, base);
@@ -296,11 +307,15 @@ static void ioat2_cleanup(struct ioat2_dma_chan *ioat)
 
 	spin_lock_bh(&ioat->ring_lock);
 
+	dev_dbg(to_dev(chan), "%s: head: %#x tail: %#x issued: %#x\n",
+		__func__, ioat->head, ioat->tail, ioat->issued);
+
 	active = ioat2_ring_active(ioat);
 	for (i = 0; i < active && !seen_current; i++) {
 		prefetch(ioat2_get_ring_ent(ioat, ioat->tail + i + 1));
 		desc = ioat2_get_ring_ent(ioat, ioat->tail + i);
 		tx = &desc->txd;
+		dump_desc_dbg(ioat, desc);
 		if (tx->cookie) {
 			ioat_dma_unmap(chan, tx->flags, desc->len, desc->hw);
 			chan->completed_cookie = tx->cookie;
@@ -349,6 +364,7 @@ static int ioat2_enumerate_channels(struct ioatdma_device *device)
 	xfercap_log = readb(device->reg_base + IOAT_XFERCAP_OFFSET);
 	if (xfercap_log == 0)
 		return 0;
+	dev_dbg(dev, "%s: xfercap = %d\n", __func__, 1 << xfercap_log);
 
 	/* FIXME which i/oat version is i7300? */
 #ifdef CONFIG_I7300_IDLE_IOAT_CHANNEL
@@ -382,6 +398,8 @@ static dma_cookie_t ioat2_tx_submit_unlock(struct dma_async_tx_descriptor *tx)
 		cookie = 1;
 	tx->cookie = cookie;
 	c->cookie = cookie;
+	dev_dbg(to_dev(&ioat->base), "%s: cookie: %d\n", __func__, cookie);
+
 	ioat2_update_pending(ioat);
 	spin_unlock_bh(&ioat->ring_lock);
 
@@ -481,6 +499,7 @@ static int ioat2_alloc_chan_resources(struct dma_chan *c)
 			kfree(ring);
 			return -ENOMEM;
 		}
+		set_desc_id(ring[i], i);
 	}
 
 	/* link descs */
@@ -572,12 +591,14 @@ ioat2_dma_prep_memcpy_lock(struct dma_chan *c, dma_addr_t dma_dest,
 		len -= copy;
 		dst += copy;
 		src += copy;
+		dump_desc_dbg(ioat, desc);
 	}
 
 	desc->txd.flags = flags;
 	desc->len = total_len;
 	hw->ctl_f.int_en = !!(flags & DMA_PREP_INTERRUPT);
 	hw->ctl_f.compl_write = 1;
+	dump_desc_dbg(ioat, desc);
 	/* we leave the channel locked to ensure in order submission */
 
 	return &desc->txd;
@@ -615,6 +636,7 @@ static void ioat2_free_chan_resources(struct dma_chan *c)
 
 	spin_lock_bh(&ioat->ring_lock);
 	descs = ioat2_ring_space(ioat);
+	dev_dbg(to_dev(chan), "freeing %d idle descriptors\n", descs);
 	for (i = 0; i < descs; i++) {
 		desc = ioat2_get_ring_ent(ioat, ioat->head + i);
 		ioat2_free_ring_ent(desc, c);
@@ -626,6 +648,7 @@ static void ioat2_free_chan_resources(struct dma_chan *c)
 
 	for (i = 0; i < total_descs - descs; i++) {
 		desc = ioat2_get_ring_ent(ioat, ioat->tail + i);
+		dump_desc_dbg(ioat, desc);
 		ioat2_free_ring_ent(desc, c);
 	}
 
diff --git a/drivers/dma/ioat/dma_v2.h b/drivers/dma/ioat/dma_v2.h
index 94a553e..c72ccb5 100644
--- a/drivers/dma/ioat/dma_v2.h
+++ b/drivers/dma/ioat/dma_v2.h
@@ -116,6 +116,9 @@ struct ioat_ring_ent {
 	struct ioat_dma_descriptor *hw;
 	struct dma_async_tx_descriptor txd;
 	size_t len;
+	#ifdef DEBUG
+	int id;
+	#endif
 };
 
 static inline struct ioat_ring_ent *

