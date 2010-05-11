From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 1/2] ioat: convert to circ_buf
Date: Tue, 11 May 2010 11:51:36 -0700
Message-ID: <20100511185135.6139.67069.stgit@localhost.localdomain>
References: <20100511184949.6139.96826.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dan.j.williams@intel.com>
To: linux-kernel@vger.kernel.org, linux-raid@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7130 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757279Ab0EKSzi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 14:55:38 -0400
In-Reply-To: <20100511184949.6139.96826.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the common power-of-2 circular buffer macros.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 drivers/dma/ioat/dma_v2.c |    2 +-
 drivers/dma/ioat/dma_v2.h |   18 +++++++-----------
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index b5ae56c..b6699a3 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -553,7 +553,7 @@ bool reshape_ring(struct ioat2_dma_chan *ioat, int order)
 	 */
 	struct ioat_chan_common *chan = &ioat->base;
 	struct dma_chan *c = &chan->common;
-	const u16 curr_size = ioat2_ring_mask(ioat) + 1;
+	const u16 curr_size = ioat2_ring_size(ioat);
 	const u16 active = ioat2_ring_active(ioat);
 	const u16 new_size = 1 << order;
 	struct ioat_ring_ent **ring;
diff --git a/drivers/dma/ioat/dma_v2.h b/drivers/dma/ioat/dma_v2.h
index ef2871f..d7b64f1 100644
--- a/drivers/dma/ioat/dma_v2.h
+++ b/drivers/dma/ioat/dma_v2.h
@@ -22,6 +22,7 @@
 #define IOATDMA_V2_H
 
 #include <linux/dmaengine.h>
+#include <linux/circ_buf.h>
 #include "dma.h"
 #include "hw.h"
 
@@ -71,31 +72,26 @@ static inline struct ioat2_dma_chan *to_ioat2_chan(struct dma_chan *c)
 	return container_of(chan, struct ioat2_dma_chan, base);
 }
 
-static inline u16 ioat2_ring_mask(struct ioat2_dma_chan *ioat)
+static inline u16 ioat2_ring_size(struct ioat2_dma_chan *ioat)
 {
-	return (1 << ioat->alloc_order) - 1;
+	return 1 << ioat->alloc_order;
 }
 
 /* count of descriptors in flight with the engine */
 static inline u16 ioat2_ring_active(struct ioat2_dma_chan *ioat)
 {
-	return (ioat->head - ioat->tail) & ioat2_ring_mask(ioat);
+	return CIRC_CNT(ioat->head, ioat->tail, ioat2_ring_size(ioat));
 }
 
 /* count of descriptors pending submission to hardware */
 static inline u16 ioat2_ring_pending(struct ioat2_dma_chan *ioat)
 {
-	return (ioat->head - ioat->issued) & ioat2_ring_mask(ioat);
+	return CIRC_CNT(ioat->head, ioat->issued, ioat2_ring_size(ioat));
 }
 
 static inline u16 ioat2_ring_space(struct ioat2_dma_chan *ioat)
 {
-	u16 num_descs = ioat2_ring_mask(ioat) + 1;
-	u16 active = ioat2_ring_active(ioat);
-
-	BUG_ON(active > num_descs);
-
-	return num_descs - active;
+	return ioat2_ring_size(ioat) - ioat2_ring_active(ioat);
 }
 
 /* assumes caller already checked space */
@@ -151,7 +147,7 @@ struct ioat_ring_ent {
 static inline struct ioat_ring_ent *
 ioat2_get_ring_ent(struct ioat2_dma_chan *ioat, u16 idx)
 {
-	return ioat->ring[idx & ioat2_ring_mask(ioat)];
+	return ioat->ring[idx & (ioat2_ring_size(ioat) - 1)];
 }
 
 static inline void ioat2_set_chainaddr(struct ioat2_dma_chan *ioat, u64 addr)

