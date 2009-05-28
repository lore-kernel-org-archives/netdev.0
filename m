From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 1/2] cxgb3: fix dma mapping regression
Date: Thu, 28 May 2009 14:23:02 -0700
Message-ID: <20090528212302.28149.46684.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932303AbZE1VXR@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Commit 5e68b772e6efd189d6aca76f6872fb75d51ace60
  cxgb3: map entire Rx page, feed map+offset to Rx ring.

introduced a regression on platforms defining DECLARE_PCI_UNMAP_ADDR()
and related macros as no-ops.

Rx descriptors are fed with the a page buffer bus address + page chunk offset.
The page buffer bus address is set and retrieved through
pci_unamp_addr_set(), pci_unmap_addr().
These functions being meaningless on x86 (if CONFIG_DMA_API_DEBUG is not set).
The HW ends up with a bogus bus address.

This patch saves the page buffer bus address for all plaftorms.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h |    4 ++--
 drivers/net/cxgb3/sge.c     |   11 +++++------
 2 files changed, 7 insertions(+), 8 deletions(-)


diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 714df2b..c888e97 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -85,8 +85,8 @@ struct fl_pg_chunk {
 	struct page *page;
 	void *va;
 	unsigned int offset;
-	u64 *p_cnt;
-	DECLARE_PCI_UNMAP_ADDR(mapping);
+	unsigned long *p_cnt;
+	dma_addr_t mapping;
 };
 
 struct rx_desc;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 26d3587..b3ee2bc 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -355,7 +355,7 @@ static void clear_rx_desc(struct pci_dev *pdev, const struct sge_fl *q,
 		(*d->pg_chunk.p_cnt)--;
 		if (!*d->pg_chunk.p_cnt)
 			pci_unmap_page(pdev,
-				       pci_unmap_addr(&d->pg_chunk, mapping),
+				       d->pg_chunk.mapping,
 				       q->alloc_size, PCI_DMA_FROMDEVICE);
 
 		put_page(d->pg_chunk.page);
@@ -454,7 +454,7 @@ static int alloc_pg_chunk(struct adapter *adapter, struct sge_fl *q,
 		q->pg_chunk.offset = 0;
 		mapping = pci_map_page(adapter->pdev, q->pg_chunk.page,
 				       0, q->alloc_size, PCI_DMA_FROMDEVICE);
-		pci_unmap_addr_set(&q->pg_chunk, mapping, mapping);
+		q->pg_chunk.mapping = mapping;
 	}
 	sd->pg_chunk = q->pg_chunk;
 
@@ -511,8 +511,7 @@ static int refill_fl(struct adapter *adap, struct sge_fl *q, int n, gfp_t gfp)
 nomem:				q->alloc_failed++;
 				break;
 			}
-			mapping = pci_unmap_addr(&sd->pg_chunk, mapping) +
-						 sd->pg_chunk.offset;
+			mapping = sd->pg_chunk.mapping + sd->pg_chunk.offset;
 			pci_unmap_addr_set(sd, dma_addr, mapping);
 
 			add_one_rx_chunk(mapping, d, q->gen);
@@ -881,7 +880,7 @@ recycle:
 	(*sd->pg_chunk.p_cnt)--;
 	if (!*sd->pg_chunk.p_cnt)
 		pci_unmap_page(adap->pdev,
-			       pci_unmap_addr(&sd->pg_chunk, mapping),
+			       sd->pg_chunk.mapping,
 			       fl->alloc_size,
 			       PCI_DMA_FROMDEVICE);
 	if (!skb) {
@@ -2096,7 +2095,7 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 	(*sd->pg_chunk.p_cnt)--;
 	if (!*sd->pg_chunk.p_cnt)
 		pci_unmap_page(adap->pdev,
-			       pci_unmap_addr(&sd->pg_chunk, mapping),
+			       sd->pg_chunk.mapping,
 			       fl->alloc_size,
 			       PCI_DMA_FROMDEVICE);
 
