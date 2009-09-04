From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 27/29] mv_xor: implement a private tx_list
Date: Thu, 03 Sep 2009 19:32:47 -0700
Message-ID: <20090904023247.32667.94318.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, Saeed Bishara <saeed@marvell.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop mv_xor's use of tx_list from struct dma_async_tx_descriptor in
preparation for removal of this field.

Cc: Saeed Bishara <saeed@marvell.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/mv_xor.c |    7 ++++---
 drivers/dma/mv_xor.h |    4 ++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/dma/mv_xor.c b/drivers/dma/mv_xor.c
index ddab94f..d7277ac 100644
--- a/drivers/dma/mv_xor.c
+++ b/drivers/dma/mv_xor.c
@@ -517,7 +517,7 @@ retry:
 			}
 			alloc_tail->group_head = alloc_start;
 			alloc_tail->async_tx.cookie = -EBUSY;
-			list_splice(&chain, &alloc_tail->async_tx.tx_list);
+			list_splice(&chain, &alloc_tail->tx_list);
 			mv_chan->last_used = last_used;
 			mv_desc_clear_next_desc(alloc_start);
 			mv_desc_clear_next_desc(alloc_tail);
@@ -565,14 +565,14 @@ mv_xor_tx_submit(struct dma_async_tx_descriptor *tx)
 	cookie = mv_desc_assign_cookie(mv_chan, sw_desc);
 
 	if (list_empty(&mv_chan->chain))
-		list_splice_init(&sw_desc->async_tx.tx_list, &mv_chan->chain);
+		list_splice_init(&sw_desc->tx_list, &mv_chan->chain);
 	else {
 		new_hw_chain = 0;
 
 		old_chain_tail = list_entry(mv_chan->chain.prev,
 					    struct mv_xor_desc_slot,
 					    chain_node);
-		list_splice_init(&grp_start->async_tx.tx_list,
+		list_splice_init(&grp_start->tx_list,
 				 &old_chain_tail->chain_node);
 
 		if (!mv_can_chain(grp_start))
@@ -632,6 +632,7 @@ static int mv_xor_alloc_chan_resources(struct dma_chan *chan)
 		slot->async_tx.tx_submit = mv_xor_tx_submit;
 		INIT_LIST_HEAD(&slot->chain_node);
 		INIT_LIST_HEAD(&slot->slot_node);
+		INIT_LIST_HEAD(&slot->tx_list);
 		hw_desc = (char *) mv_chan->device->dma_desc_pool;
 		slot->async_tx.phys =
 			(dma_addr_t) &hw_desc[idx * MV_XOR_SLOT_SIZE];
diff --git a/drivers/dma/mv_xor.h b/drivers/dma/mv_xor.h
index 06cafe1..977b592 100644
--- a/drivers/dma/mv_xor.h
+++ b/drivers/dma/mv_xor.h
@@ -126,9 +126,8 @@ struct mv_xor_chan {
  * @idx: pool index
  * @unmap_src_cnt: number of xor sources
  * @unmap_len: transaction bytecount
+ * @tx_list: list of slots that make up a multi-descriptor transaction
  * @async_tx: support for the async_tx api
- * @group_list: list of slots that make up a multi-descriptor transaction
- *	for example transfer lengths larger than the supported hw max
  * @xor_check_result: result of zero sum
  * @crc32_result: result crc calculation
  */
@@ -145,6 +144,7 @@ struct mv_xor_desc_slot {
 	u16			unmap_src_cnt;
 	u32			value;
 	size_t			unmap_len;
+	struct list_head	tx_list;
 	struct dma_async_tx_descriptor	async_tx;
 	union {
 		u32		*xor_check_result;

