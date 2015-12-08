From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 6/7] cxgb4: Add FL DMA mapping error and low counter
Date: Tue,  8 Dec 2015 10:09:16 +0530
Message-ID: <1449549557-16023-7-git-send-email-hariprasad@chelsio.com>
References: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:33164 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932618AbbLHEiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 23:38:21 -0500
In-Reply-To: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Free List DMA Mapping Errors to SGE Queue info for
Free Lists. Add Free List "Low" counter to count the number of times we
see the number of pointers that we _think_ the hardware sees in the
Free List below the Egress Threshold.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         | 2 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 6 ++++++
 drivers/net/ethernet/chelsio/cxgb4/sge.c           | 3 +++
 3 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index d4076e8..e01e722 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -483,6 +483,8 @@ struct sge_fl {                     /* SGE free-buffer queue state */
 	unsigned int pidx;          /* producer index */
 	unsigned long alloc_failed; /* # of times buffer allocation failed */
 	unsigned long large_alloc_failed;
+	unsigned long mapping_err;  /* # of RX Buffer DMA Mapping failures */
+	unsigned long low;          /* # of times momentarily starving */
 	unsigned long starving;
 	/* RO fields */
 	unsigned int cntxt_id;      /* SGE context id for the free list */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 4269944..0d579b1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -2325,6 +2325,8 @@ do { \
 		TL("TxMapErr:", mapping_err);
 		RL("FLAllocErr:", fl.alloc_failed);
 		RL("FLLrgAlcErr:", fl.large_alloc_failed);
+		RL("FLMapErr:", fl.mapping_err);
+		RL("FLLow:", fl.low);
 		RL("FLStarving:", fl.starving);
 
 	} else if (iscsi_idx < iscsi_entries) {
@@ -2359,6 +2361,8 @@ do { \
 		RL("RxNoMem:", stats.nomem);
 		RL("FLAllocErr:", fl.alloc_failed);
 		RL("FLLrgAlcErr:", fl.large_alloc_failed);
+		RL("FLMapErr:", fl.mapping_err);
+		RL("FLLow:", fl.low);
 		RL("FLStarving:", fl.starving);
 
 	} else if (rdma_idx < rdma_entries) {
@@ -2388,6 +2392,8 @@ do { \
 		RL("RxNoMem:", stats.nomem);
 		RL("FLAllocErr:", fl.alloc_failed);
 		RL("FLLrgAlcErr:", fl.large_alloc_failed);
+		RL("FLMapErr:", fl.mapping_err);
+		RL("FLLow:", fl.low);
 		RL("FLStarving:", fl.starving);
 
 	} else if (ciq_idx < ciq_entries) {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index c72fe1e..8d35ce3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -613,6 +613,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 				       PCI_DMA_FROMDEVICE);
 		if (unlikely(dma_mapping_error(adap->pdev_dev, mapping))) {
 			__free_pages(pg, s->fl_pg_order);
+			q->mapping_err++;
 			goto out;   /* do not try small pages for this error */
 		}
 		mapping |= RX_LARGE_PG_BUF;
@@ -642,6 +643,7 @@ alloc_small_pages:
 				       PCI_DMA_FROMDEVICE);
 		if (unlikely(dma_mapping_error(adap->pdev_dev, mapping))) {
 			put_page(pg);
+			q->mapping_err++;
 			goto out;
 		}
 		*d++ = cpu_to_be64(mapping);
@@ -663,6 +665,7 @@ out:	cred = q->avail - cred;
 
 	if (unlikely(fl_starving(adap, q))) {
 		smp_wmb();
+		q->low++;
 		set_bit(q->cntxt_id - adap->sge.egr_start,
 			adap->sge.starving_fl);
 	}
-- 
2.3.4
