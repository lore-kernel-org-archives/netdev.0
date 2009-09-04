From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 26/29] ioat: implement a private tx_list
Date: Thu, 03 Sep 2009 19:32:42 -0700
Message-ID: <20090904023242.32667.27473.stgit@dwillia2-linux.ch.intel.com>
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

Drop ioatdma's use of tx_list from struct dma_async_tx_descriptor in
preparation for removal of this field.

Cc: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c |    7 ++++---
 drivers/dma/ioat/dma.h |    3 ++-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index 17a518d..21527b8 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -251,12 +251,12 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	dev_dbg(to_dev(&ioat->base), "%s: cookie: %d\n", __func__, cookie);
 
 	/* write address into NextDescriptor field of last desc in chain */
-	first = to_ioat_desc(tx->tx_list.next);
+	first = to_ioat_desc(desc->tx_list.next);
 	chain_tail = to_ioat_desc(ioat->used_desc.prev);
 	/* make descriptor updates globally visible before chaining */
 	wmb();
 	chain_tail->hw->next = first->txd.phys;
-	list_splice_tail_init(&tx->tx_list, &ioat->used_desc);
+	list_splice_tail_init(&desc->tx_list, &ioat->used_desc);
 	dump_desc_dbg(ioat, chain_tail);
 	dump_desc_dbg(ioat, first);
 
@@ -297,6 +297,7 @@ ioat_dma_alloc_descriptor(struct ioat_dma_chan *ioat, gfp_t flags)
 
 	memset(desc, 0, sizeof(*desc));
 
+	INIT_LIST_HEAD(&desc_sw->tx_list);
 	dma_async_tx_descriptor_init(&desc_sw->txd, &ioat->base.common);
 	desc_sw->txd.tx_submit = ioat1_tx_submit;
 	desc_sw->hw = desc;
@@ -521,7 +522,7 @@ ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 
 	desc->txd.flags = flags;
 	desc->len = total_len;
-	list_splice(&chain, &desc->txd.tx_list);
+	list_splice(&chain, &desc->tx_list);
 	hw->ctl_f.int_en = !!(flags & DMA_PREP_INTERRUPT);
 	hw->ctl_f.compl_write = 1;
 	hw->tx_cnt = tx_cnt;
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index d9d6a7e..8966fa5 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -157,7 +157,7 @@ ioat_is_complete(struct dma_chan *c, dma_cookie_t cookie,
  * struct ioat_desc_sw - wrapper around hardware descriptor
  * @hw: hardware DMA descriptor
  * @node: this descriptor will either be on the free list,
- *     or attached to a transaction list (async_tx.tx_list)
+ *     or attached to a transaction list (tx_list)
  * @txd: the generic software descriptor for all engines
  * @id: identifier for debug
  */
@@ -165,6 +165,7 @@ struct ioat_desc_sw {
 	struct ioat_dma_descriptor *hw;
 	struct list_head node;
 	size_t len;
+	struct list_head tx_list;
 	struct dma_async_tx_descriptor txd;
 	#ifdef DEBUG
 	int id;

