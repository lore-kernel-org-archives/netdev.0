From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 25/29] iop-adma: implement a private tx_list
Date: Thu, 03 Sep 2009 19:32:37 -0700
Message-ID: <20090904023237.32667.25377.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop iop-adma's use of tx_list from struct dma_async_tx_descriptor in
preparation for removal of this field.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/arm/include/asm/hardware/iop_adma.h |    2 ++
 drivers/dma/iop-adma.c                   |    9 +++++----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/arch/arm/include/asm/hardware/iop_adma.h b/arch/arm/include/asm/hardware/iop_adma.h
index 385c6e8..95dc133 100644
--- a/arch/arm/include/asm/hardware/iop_adma.h
+++ b/arch/arm/include/asm/hardware/iop_adma.h
@@ -86,6 +86,7 @@ struct iop_adma_chan {
  * @idx: pool index
  * @unmap_src_cnt: number of xor sources
  * @unmap_len: transaction bytecount
+ * @tx_list: list of descriptors that are associated with one operation
  * @async_tx: support for the async_tx api
  * @group_list: list of slots that make up a multi-descriptor transaction
  *	for example transfer lengths larger than the supported hw max
@@ -102,6 +103,7 @@ struct iop_adma_desc_slot {
 	u16 idx;
 	u16 unmap_src_cnt;
 	size_t unmap_len;
+	struct list_head tx_list;
 	struct dma_async_tx_descriptor async_tx;
 	union {
 		u32 *xor_check_result;
diff --git a/drivers/dma/iop-adma.c b/drivers/dma/iop-adma.c
index 2f05226..9f6c16f 100644
--- a/drivers/dma/iop-adma.c
+++ b/drivers/dma/iop-adma.c
@@ -370,7 +370,7 @@ retry:
 			}
 			alloc_tail->group_head = alloc_start;
 			alloc_tail->async_tx.cookie = -EBUSY;
-			list_splice(&chain, &alloc_tail->async_tx.tx_list);
+			list_splice(&chain, &alloc_tail->tx_list);
 			iop_chan->last_used = last_used;
 			iop_desc_clear_next_desc(alloc_start);
 			iop_desc_clear_next_desc(alloc_tail);
@@ -429,7 +429,7 @@ iop_adma_tx_submit(struct dma_async_tx_descriptor *tx)
 
 	old_chain_tail = list_entry(iop_chan->chain.prev,
 		struct iop_adma_desc_slot, chain_node);
-	list_splice_init(&sw_desc->async_tx.tx_list,
+	list_splice_init(&sw_desc->tx_list,
 			 &old_chain_tail->chain_node);
 
 	/* fix up the hardware chain */
@@ -496,6 +496,7 @@ static int iop_adma_alloc_chan_resources(struct dma_chan *chan)
 
 		dma_async_tx_descriptor_init(&slot->async_tx, chan);
 		slot->async_tx.tx_submit = iop_adma_tx_submit;
+		INIT_LIST_HEAD(&slot->tx_list);
 		INIT_LIST_HEAD(&slot->chain_node);
 		INIT_LIST_HEAD(&slot->slot_node);
 		hw_desc = (char *) iop_chan->device->dma_desc_pool;
@@ -1296,7 +1297,7 @@ static void iop_chan_start_null_memcpy(struct iop_adma_chan *iop_chan)
 	if (sw_desc) {
 		grp_start = sw_desc->group_head;
 
-		list_splice_init(&sw_desc->async_tx.tx_list, &iop_chan->chain);
+		list_splice_init(&sw_desc->tx_list, &iop_chan->chain);
 		async_tx_ack(&sw_desc->async_tx);
 		iop_desc_init_memcpy(grp_start, 0);
 		iop_desc_set_byte_count(grp_start, iop_chan, 0);
@@ -1352,7 +1353,7 @@ static void iop_chan_start_null_xor(struct iop_adma_chan *iop_chan)
 	sw_desc = iop_adma_alloc_slots(iop_chan, slot_cnt, slots_per_op);
 	if (sw_desc) {
 		grp_start = sw_desc->group_head;
-		list_splice_init(&sw_desc->async_tx.tx_list, &iop_chan->chain);
+		list_splice_init(&sw_desc->tx_list, &iop_chan->chain);
 		async_tx_ack(&sw_desc->async_tx);
 		iop_desc_init_null_xor(grp_start, 2, 0);
 		iop_desc_set_byte_count(grp_start, iop_chan, 0);

