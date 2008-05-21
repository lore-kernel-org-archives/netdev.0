From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 1/3 2.6.27] cxgb3 - Fix dma mapping error path
Date: Tue, 20 May 2008 18:57:31 -0700
Message-ID: <20080521015731.6200.32718.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:12691 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259AbYEUB5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 21:57:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Take potential dma mapping errors in account.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |   53 ++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 41 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 796eb30..0741deb 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -376,13 +376,16 @@ static void free_rx_bufs(struct pci_dev *pdev, struct sge_fl *q)
  *	Add a buffer of the given length to the supplied HW and SW Rx
  *	descriptors.
  */
-static inline void add_one_rx_buf(void *va, unsigned int len,
-				  struct rx_desc *d, struct rx_sw_desc *sd,
-				  unsigned int gen, struct pci_dev *pdev)
+static inline int add_one_rx_buf(void *va, unsigned int len,
+				 struct rx_desc *d, struct rx_sw_desc *sd,
+				 unsigned int gen, struct pci_dev *pdev)
 {
 	dma_addr_t mapping;
 
 	mapping = pci_map_single(pdev, va, len, PCI_DMA_FROMDEVICE);
+	if (unlikely(pci_dma_mapping_error(mapping)))
+		return -ENOMEM;
+
 	pci_unmap_addr_set(sd, dma_addr, mapping);
 
 	d->addr_lo = cpu_to_be32(mapping);
@@ -390,6 +393,7 @@ static inline void add_one_rx_buf(void *va, unsigned int len,
 	wmb();
 	d->len_gen = cpu_to_be32(V_FLD_GEN1(gen));
 	d->gen2 = cpu_to_be32(V_FLD_GEN2(gen));
+	return 0;
 }
 
 static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp)
@@ -424,13 +428,16 @@ static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp)
  *	allocated with the supplied gfp flags.  The caller must assure that
  *	@n does not exceed the queue's capacity.
  */
-static void refill_fl(struct adapter *adap, struct sge_fl *q, int n, gfp_t gfp)
+static int refill_fl(struct adapter *adap, struct sge_fl *q, int n, gfp_t gfp)
 {
 	void *buf_start;
 	struct rx_sw_desc *sd = &q->sdesc[q->pidx];
 	struct rx_desc *d = &q->desc[q->pidx];
+	unsigned int count = 0;
 
 	while (n--) {
+		int err;
+
 		if (q->use_pages) {
 			if (unlikely(alloc_pg_chunk(q, sd, gfp))) {
 nomem:				q->alloc_failed++;
@@ -447,8 +454,16 @@ nomem:				q->alloc_failed++;
 			buf_start = skb->data;
 		}
 
-		add_one_rx_buf(buf_start, q->buf_size, d, sd, q->gen,
-			       adap->pdev);
+		err = add_one_rx_buf(buf_start, q->buf_size, d, sd, q->gen,
+				     adap->pdev);
+		if (unlikely(err)) {
+			if (!q->use_pages) {
+				kfree_skb(sd->skb);
+				sd->skb = NULL;
+			}
+			break;
+		}
+
 		d++;
 		sd++;
 		if (++q->pidx == q->size) {
@@ -458,9 +473,13 @@ nomem:				q->alloc_failed++;
 			d = q->desc;
 		}
 		q->credits++;
+		count++;
 	}
 	wmb();
-	t3_write_reg(adap, A_SG_KDOORBELL, V_EGRCNTX(q->cntxt_id));
+	if (likely(count))
+		t3_write_reg(adap, A_SG_KDOORBELL, V_EGRCNTX(q->cntxt_id));
+
+	return count;
 }
 
 static inline void __refill_fl(struct adapter *adap, struct sge_fl *fl)
@@ -2618,7 +2637,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		      int irq_vec_idx, const struct qset_params *p,
 		      int ntxq, struct net_device *dev)
 {
-	int i, ret = -ENOMEM;
+	int i, avail, ret = -ENOMEM;
 	struct sge_qset *q = &adapter->sge.qs[id];
 
 	init_qset_cntxt(q, id);
@@ -2741,9 +2760,19 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->adap = adapter;
 	q->netdev = dev;
 	t3_update_qset_coalesce(q, p);
+	avail = refill_fl(adapter, &q->fl[0], q->fl[0].size, GFP_KERNEL);
+	if (!avail) {
+		CH_ALERT(adapter, "free list queue 0 initialization failed\n");
+		goto err;
+	}
+	if (avail < q->fl[0].size)
+		CH_WARN(adapter, "free list queue 0 enabled with %d credits\n",
+			avail);
 
-	refill_fl(adapter, &q->fl[0], q->fl[0].size, GFP_KERNEL);
-	refill_fl(adapter, &q->fl[1], q->fl[1].size, GFP_KERNEL);
+	avail = refill_fl(adapter, &q->fl[1], q->fl[1].size, GFP_KERNEL);
+	if (avail < q->fl[1].size)
+		CH_WARN(adapter, "free list queue 1 enabled with %d credits\n",
+			avail);
 	refill_rspq(adapter, &q->rspq, q->rspq.size - 1);
 
 	t3_write_reg(adapter, A_SG_GTS, V_RSPQ(q->rspq.cntxt_id) |
@@ -2752,9 +2781,9 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	mod_timer(&q->tx_reclaim_timer, jiffies + TX_RECLAIM_PERIOD);
 	return 0;
 
-      err_unlock:
+err_unlock:
 	spin_unlock_irq(&adapter->sge.reg_lock);
-      err:
+err:
 	t3_free_qset(adapter, q);
 	return ret;
 }
