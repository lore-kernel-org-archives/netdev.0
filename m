From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 2/10] cxgb3: release page ref on mapping error
Date: Fri, 13 Mar 2009 00:13:49 -0700
Message-ID: <20090313071348.21994.7337.stgit@speedy5>
References: <20090313071343.21994.85719.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27595 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449AbZCMHNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 03:13:51 -0400
In-Reply-To: <20090313071343.21994.85719.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Release page chunk reference in case we fail to map it.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 882beaf..808b8af 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -338,6 +338,18 @@ static inline int should_restart_tx(const struct sge_txq *q)
 	return q->in_use - r < (q->size >> 1);
 }
 
+static void clear_rx_desc(const struct sge_fl *q, struct rx_sw_desc *d)
+{
+	if (q->use_pages) {
+		if (d->pg_chunk.page)
+			put_page(d->pg_chunk.page);
+		d->pg_chunk.page = NULL;
+	} else {
+		kfree_skb(d->skb);
+		d->skb = NULL;
+	}
+}
+
 /**
  *	free_rx_bufs - free the Rx buffers on an SGE free list
  *	@pdev: the PCI device associated with the adapter
@@ -355,14 +367,7 @@ static void free_rx_bufs(struct pci_dev *pdev, struct sge_fl *q)
 
 		pci_unmap_single(pdev, pci_unmap_addr(d, dma_addr),
 				 q->buf_size, PCI_DMA_FROMDEVICE);
-		if (q->use_pages) {
-			if (d->pg_chunk.page)
-				put_page(d->pg_chunk.page);
-			d->pg_chunk.page = NULL;
-		} else {
-			kfree_skb(d->skb);
-			d->skb = NULL;
-		}
+		clear_rx_desc(q, d);
 		if (++cidx == q->size)
 			cidx = 0;
 	}
@@ -475,10 +480,7 @@ nomem:				q->alloc_failed++;
 		err = add_one_rx_buf(buf_start, q->buf_size, d, sd, q->gen,
 				     adap->pdev);
 		if (unlikely(err)) {
-			if (!q->use_pages) {
-				kfree_skb(sd->skb);
-				sd->skb = NULL;
-			}
+			clear_rx_desc(q, sd);
 			break;
 		}
 

