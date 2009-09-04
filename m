From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 09/29] ioat1: move descriptor allocation from submit to prep
Date: Thu, 03 Sep 2009 19:31:15 -0700
Message-ID: <20090904023115.32667.49396.stgit@dwillia2-linux.ch.intel.com>
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

The async_tx api assumes that after a successful ->prep a subsequent
->submit will not fail due to a lack of resources.

This also fixes a bug in the allocation failure case.  Previously the
descriptors allocated prior to the allocation failure would not be
returned to the free list.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c |  154 ++++++++++++++++++++----------------------------
 1 files changed, 65 insertions(+), 89 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index 4840d48..c4333be 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -420,95 +420,29 @@ static void ioat_dma_chan_watchdog(struct work_struct *work)
 static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 {
 	struct ioat_dma_chan *ioat_chan = to_ioat_chan(tx->chan);
-	struct ioat_desc_sw *first = tx_to_ioat_desc(tx);
-	struct ioat_desc_sw *prev, *new;
-	struct ioat_dma_descriptor *hw;
+	struct ioat_desc_sw *desc = tx_to_ioat_desc(tx);
+	struct ioat_desc_sw *first;
+	struct ioat_desc_sw *chain_tail;
 	dma_cookie_t cookie;
-	LIST_HEAD(new_chain);
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
 
 	spin_lock_bh(&ioat_chan->desc_lock);
-	prev = to_ioat_desc(ioat_chan->used_desc.prev);
-	prefetch(prev->hw);
-	do {
-		copy = min_t(size_t, len, ioat_chan->xfercap);
-
-		async_tx_ack(&new->txd);
-
-		hw = new->hw;
-		hw->size = copy;
-		hw->ctl = 0;
-		hw->src_addr = src;
-		hw->dst_addr = dst;
-		hw->next = 0;
-
-		/* chain together the physical address list for the HW */
-		wmb();
-		prev->hw->next = (u64) new->txd.phys;
-
-		len -= copy;
-		dst += copy;
-		src += copy;
-
-		list_add_tail(&new->node, &new_chain);
-		desc_count++;
-		prev = new;
-	} while (len && (new = ioat1_dma_get_next_descriptor(ioat_chan)));
-
-	if (!new) {
-		dev_err(to_dev(ioat_chan), "tx submit failed\n");
-		spin_unlock_bh(&ioat_chan->desc_lock);
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
 	/* cookie incr and addition to used_list must be atomic */
 	cookie = ioat_chan->common.cookie;
 	cookie++;
 	if (cookie < 0)
 		cookie = 1;
-	ioat_chan->common.cookie = new->txd.cookie = cookie;
+	ioat_chan->common.cookie = tx->cookie = cookie;
 
 	/* write address into NextDescriptor field of last desc in chain */
-	to_ioat_desc(ioat_chan->used_desc.prev)->hw->next =
-							first->txd.phys;
-	list_splice_tail(&new_chain, &ioat_chan->used_desc);
-
-	ioat_chan->dmacount += desc_count;
-	ioat_chan->pending += desc_count;
+	first = to_ioat_desc(tx->tx_list.next);
+	chain_tail = to_ioat_desc(ioat_chan->used_desc.prev);
+	/* make descriptor updates globally visible before chaining */
+	wmb();
+	chain_tail->hw->next = first->txd.phys;
+	list_splice_tail_init(&tx->tx_list, &ioat_chan->used_desc);
+
+	ioat_chan->dmacount += desc->tx_cnt;
+	ioat_chan->pending += desc->tx_cnt;
 	if (ioat_chan->pending >= ioat_pending_level)
 		__ioat1_dma_memcpy_issue_pending(ioat_chan);
 	spin_unlock_bh(&ioat_chan->desc_lock);
@@ -937,24 +871,66 @@ ioat1_dma_prep_memcpy(struct dma_chan *chan, dma_addr_t dma_dest,
 		      dma_addr_t dma_src, size_t len, unsigned long flags)
 {
 	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
-	struct ioat_desc_sw *new;
+	struct ioat_desc_sw *desc;
+	size_t copy;
+	LIST_HEAD(chain);
+	dma_addr_t src = dma_src;
+	dma_addr_t dest = dma_dest;
+	size_t total_len = len;
+	struct ioat_dma_descriptor *hw = NULL;
+	int tx_cnt = 0;
 
 	spin_lock_bh(&ioat_chan->desc_lock);
-	new = ioat_dma_get_next_descriptor(ioat_chan);
-	spin_unlock_bh(&ioat_chan->desc_lock);
+	desc = ioat_dma_get_next_descriptor(ioat_chan);
+	do {
+		if (!desc)
+			break;
 
-	if (new) {
-		new->len = len;
-		new->dst = dma_dest;
-		new->src = dma_src;
-		new->txd.flags = flags;
-		return &new->txd;
-	} else {
+		tx_cnt++;
+		copy = min_t(size_t, len, ioat_chan->xfercap);
+
+		hw = desc->hw;
+		hw->size = copy;
+		hw->ctl = 0;
+		hw->src_addr = src;
+		hw->dst_addr = dest;
+
+		list_add_tail(&desc->node, &chain);
+
+		len -= copy;
+		dest += copy;
+		src += copy;
+		if (len) {
+			struct ioat_desc_sw *next;
+
+			async_tx_ack(&desc->txd);
+			next = ioat_dma_get_next_descriptor(ioat_chan);
+			hw->next = next ? next->txd.phys : 0;
+			desc = next;
+		} else
+			hw->next = 0;
+	} while (len);
+
+	if (!desc) {
 		dev_err(to_dev(ioat_chan),
 			"chan%d - get_next_desc failed: %d descs waiting, %d total desc\n",
 			chan_num(ioat_chan), ioat_chan->dmacount, ioat_chan->desccount);
+		list_splice(&chain, &ioat_chan->free_desc);
+		spin_unlock_bh(&ioat_chan->desc_lock);
 		return NULL;
 	}
+	spin_unlock_bh(&ioat_chan->desc_lock);
+
+	desc->txd.flags = flags;
+	desc->tx_cnt = tx_cnt;
+	desc->src = dma_src;
+	desc->dst = dma_dest;
+	desc->len = total_len;
+	list_splice(&chain, &desc->txd.tx_list);
+	hw->ctl_f.int_en = !!(flags & DMA_PREP_INTERRUPT);
+	hw->ctl_f.compl_write = 1;
+
+	return &desc->txd;
 }
 
 static struct dma_async_tx_descriptor *

