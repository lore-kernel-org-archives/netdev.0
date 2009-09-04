From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 19/29] ioat1: trim ioat_dma_desc_sw
Date: Thu, 03 Sep 2009 19:32:06 -0700
Message-ID: <20090904023206.32667.35974.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63501 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932738AbZIDCcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 22:32:04 -0400
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save 4 bytes per software descriptor by transmitting tx_cnt in an unused
portion of the hardware descriptor.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c |    4 ++--
 drivers/dma/ioat/dma.h |    2 --
 drivers/dma/ioat/hw.h  |    6 +++++-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index abc96c4..f59b6f4 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -396,7 +396,7 @@ static dma_cookie_t ioat1_tx_submit(struct dma_async_tx_descriptor *tx)
 	dump_desc_dbg(ioat, chain_tail);
 	dump_desc_dbg(ioat, first);
 
-	ioat->pending += desc->tx_cnt;
+	ioat->pending += desc->hw->tx_cnt;
 	if (ioat->pending >= ioat_pending_level)
 		__ioat1_dma_memcpy_issue_pending(ioat);
 	spin_unlock_bh(&ioat->desc_lock);
@@ -655,11 +655,11 @@ ioat1_dma_prep_memcpy(struct dma_chan *c, dma_addr_t dma_dest,
 	spin_unlock_bh(&ioat->desc_lock);
 
 	desc->txd.flags = flags;
-	desc->tx_cnt = tx_cnt;
 	desc->len = total_len;
 	list_splice(&chain, &desc->txd.tx_list);
 	hw->ctl_f.int_en = !!(flags & DMA_PREP_INTERRUPT);
 	hw->ctl_f.compl_write = 1;
+	hw->tx_cnt = tx_cnt;
 	dump_desc_dbg(ioat, desc);
 
 	return &desc->txd;
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index e47083b..ec851cf 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -165,14 +165,12 @@ ioat_is_complete(struct dma_chan *c, dma_cookie_t cookie,
  * @hw: hardware DMA descriptor
  * @node: this descriptor will either be on the free list,
  *     or attached to a transaction list (async_tx.tx_list)
- * @tx_cnt: number of descriptors required to complete the transaction
  * @txd: the generic software descriptor for all engines
  * @id: identifier for debug
  */
 struct ioat_desc_sw {
 	struct ioat_dma_descriptor *hw;
 	struct list_head node;
-	int tx_cnt;
 	size_t len;
 	struct dma_async_tx_descriptor txd;
 	#ifdef DEBUG
diff --git a/drivers/dma/ioat/hw.h b/drivers/dma/ioat/hw.h
index e13f3ed..7481fb1 100644
--- a/drivers/dma/ioat/hw.h
+++ b/drivers/dma/ioat/hw.h
@@ -63,7 +63,11 @@ struct ioat_dma_descriptor {
 	uint64_t	next;
 	uint64_t	rsv1;
 	uint64_t	rsv2;
-	uint64_t	user1;
+	/* store some driver data in an unused portion of the descriptor */
+	union {
+		uint64_t	user1;
+		uint64_t	tx_cnt;
+	};
 	uint64_t	user2;
 };
 #endif

