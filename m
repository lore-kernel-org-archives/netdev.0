From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 08/29] ioat: define descriptor control bit-field
Date: Thu, 03 Sep 2009 19:31:10 -0700
Message-ID: <20090904023110.32667.71782.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932663AbZIDCbO@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This cleans up a mess of and'ing and or'ing bit definitions, and allows
simple assignments from the specified dma_ctrl_flags parameter.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c |   28 ++++++++++++++++------------
 drivers/dma/ioat/hw.h  |   38 ++++++++++++++++++--------------------
 2 files changed, 34 insertions(+), 32 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index b750804..4840d48 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -472,9 +472,9 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 		return -ENOMEM;
 	}
 
-	hw->ctl = IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
+	hw->ctl_f.compl_write = 1;
 	if (first->txd.callback) {
-		hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_INT_GN;
+		hw->ctl_f.int_en = 1;
 		if (first != new) {
 			/* move callback into to last desc */
 			new->txd.callback = first->txd.callback;
@@ -563,9 +563,9 @@ static dma_cookie_t ioat2_tx_submit(struct dma_async_tx_descriptor *tx)
 		return -ENOMEM;
 	}
 
-	hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
+	hw->ctl_f.compl_write = 1;
 	if (first->txd.callback) {
-		hw->ctl |= IOAT_DMA_DESCRIPTOR_CTL_INT_GN;
+		hw->ctl_f.int_en = 1;
 		if (first != new) {
 			/* move callback into to last desc */
 			new->txd.callback = first->txd.callback;
@@ -878,7 +878,8 @@ ioat2_dma_get_next_descriptor(struct ioat_dma_chan *ioat_chan)
 		noop_desc = to_ioat_desc(ioat_chan->used_desc.next);
 		/* set size to non-zero value (channel returns error when size is 0) */
 		noop_desc->hw->size = NULL_DESC_BUFFER_SIZE;
-		noop_desc->hw->ctl = IOAT_DMA_DESCRIPTOR_NUL;
+		noop_desc->hw->ctl = 0;
+		noop_desc->hw->ctl_f.null = 1;
 		noop_desc->hw->src_addr = 0;
 		noop_desc->hw->dst_addr = 0;
 
@@ -1230,6 +1231,7 @@ ioat_dma_is_complete(struct dma_chan *chan, dma_cookie_t cookie,
 static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat_chan)
 {
 	struct ioat_desc_sw *desc;
+	struct ioat_dma_descriptor *hw;
 
 	spin_lock_bh(&ioat_chan->desc_lock);
 
@@ -1242,17 +1244,19 @@ static void ioat_dma_start_null_desc(struct ioat_dma_chan *ioat_chan)
 		return;
 	}
 
-	desc->hw->ctl = IOAT_DMA_DESCRIPTOR_NUL
-				| IOAT_DMA_DESCRIPTOR_CTL_INT_GN
-				| IOAT_DMA_DESCRIPTOR_CTL_CP_STS;
+	hw = desc->hw;
+	hw->ctl = 0;
+	hw->ctl_f.null = 1;
+	hw->ctl_f.int_en = 1;
+	hw->ctl_f.compl_write = 1;
 	/* set size to non-zero value (channel returns error when size is 0) */
-	desc->hw->size = NULL_DESC_BUFFER_SIZE;
-	desc->hw->src_addr = 0;
-	desc->hw->dst_addr = 0;
+	hw->size = NULL_DESC_BUFFER_SIZE;
+	hw->src_addr = 0;
+	hw->dst_addr = 0;
 	async_tx_ack(&desc->txd);
 	switch (ioat_chan->device->version) {
 	case IOAT_VER_1_2:
-		desc->hw->next = 0;
+		hw->next = 0;
 		list_add_tail(&desc->node, &ioat_chan->used_desc);
 
 		writel(((u64) desc->txd.phys) & 0x00000000FFFFFFFF,
diff --git a/drivers/dma/ioat/hw.h b/drivers/dma/ioat/hw.h
index 1438fa5..e13f3ed 100644
--- a/drivers/dma/ioat/hw.h
+++ b/drivers/dma/ioat/hw.h
@@ -40,7 +40,24 @@
 
 struct ioat_dma_descriptor {
 	uint32_t	size;
-	uint32_t	ctl;
+	union {
+		uint32_t ctl;
+		struct {
+			unsigned int int_en:1;
+			unsigned int src_snoop_dis:1;
+			unsigned int dest_snoop_dis:1;
+			unsigned int compl_write:1;
+			unsigned int fence:1;
+			unsigned int null:1;
+			unsigned int src_brk:1;
+			unsigned int dest_brk:1;
+			unsigned int bundle:1;
+			unsigned int dest_dca:1;
+			unsigned int hint:1;
+			unsigned int rsvd2:13;
+			unsigned int op:8;
+		} ctl_f;
+	};
 	uint64_t	src_addr;
 	uint64_t	dst_addr;
 	uint64_t	next;
@@ -49,23 +66,4 @@ struct ioat_dma_descriptor {
 	uint64_t	user1;
 	uint64_t	user2;
 };
-
-#define IOAT_DMA_DESCRIPTOR_CTL_INT_GN	0x00000001
-#define IOAT_DMA_DESCRIPTOR_CTL_SRC_SN	0x00000002
-#define IOAT_DMA_DESCRIPTOR_CTL_DST_SN	0x00000004
-#define IOAT_DMA_DESCRIPTOR_CTL_CP_STS	0x00000008
-#define IOAT_DMA_DESCRIPTOR_CTL_FRAME	0x00000010
-#define IOAT_DMA_DESCRIPTOR_NUL		0x00000020
-#define IOAT_DMA_DESCRIPTOR_CTL_SP_BRK	0x00000040
-#define IOAT_DMA_DESCRIPTOR_CTL_DP_BRK	0x00000080
-#define IOAT_DMA_DESCRIPTOR_CTL_BNDL	0x00000100
-#define IOAT_DMA_DESCRIPTOR_CTL_DCA	0x00000200
-#define IOAT_DMA_DESCRIPTOR_CTL_BUFHINT	0x00000400
-
-#define IOAT_DMA_DESCRIPTOR_CTL_OPCODE_CONTEXT	0xFF000000
-#define IOAT_DMA_DESCRIPTOR_CTL_OPCODE_DMA	0x00000000
-
-#define IOAT_DMA_DESCRIPTOR_CTL_CONTEXT_DCA	0x00000001
-#define IOAT_DMA_DESCRIPTOR_CTL_OPCODE_MASK	0xFF000000
-
 #endif
