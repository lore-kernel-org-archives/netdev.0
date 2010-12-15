From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 12/12] cxgb4: NUMA-aware Tx queue allocations
Date: Tue, 14 Dec 2010 23:36:55 -0800
Message-ID: <1292398615-26527-13-git-send-email-dm@chelsio.com>
References: <1292398615-26527-1-git-send-email-dm@chelsio.com>
 <1292398615-26527-2-git-send-email-dm@chelsio.com>
 <1292398615-26527-3-git-send-email-dm@chelsio.com>
 <1292398615-26527-4-git-send-email-dm@chelsio.com>
 <1292398615-26527-5-git-send-email-dm@chelsio.com>
 <1292398615-26527-6-git-send-email-dm@chelsio.com>
 <1292398615-26527-7-git-send-email-dm@chelsio.com>
 <1292398615-26527-8-git-send-email-dm@chelsio.com>
 <1292398615-26527-9-git-send-email-dm@chelsio.com>
 <1292398615-26527-10-git-send-email-dm@chelsio.com>
 <1292398615-26527-11-git-send-email-dm@chelsio.com>
 <1292398615-26527-12-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25317 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259Ab0LOHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:45:19 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBF7jICc004129
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:45:19 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBF7awS7026621
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:36:58 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBF7awuY026620
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 23:36:58 -0800
In-Reply-To: <1292398615-26527-12-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate Tx queue memory on the node indicated by the new
netdev_queue_numa_node_read.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/sge.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index cc0b997..311471b 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -579,6 +579,7 @@ static inline void __refill_fl(struct adapter *adap, struct sge_fl *fl)
  *	@phys: the physical address of the allocated ring
  *	@metadata: address of the array holding the SW state for the ring
  *	@stat_size: extra space in HW ring for status information
+ *	@node: preferred node for memory allocations
  *
  *	Allocates resources for an SGE descriptor ring, such as Tx queues,
  *	free buffer lists, or response queues.  Each SGE ring requires
@@ -590,7 +591,7 @@ static inline void __refill_fl(struct adapter *adap, struct sge_fl *fl)
  */
 static void *alloc_ring(struct device *dev, size_t nelem, size_t elem_size,
 			size_t sw_size, dma_addr_t *phys, void *metadata,
-			size_t stat_size)
+			size_t stat_size, int node)
 {
 	size_t len = nelem * elem_size + stat_size;
 	void *s = NULL;
@@ -599,7 +600,7 @@ static void *alloc_ring(struct device *dev, size_t nelem, size_t elem_size,
 	if (!p)
 		return NULL;
 	if (sw_size) {
-		s = kcalloc(nelem, sw_size, GFP_KERNEL);
+		s = kzalloc_node(nelem * sw_size, GFP_KERNEL, node);
 
 		if (!s) {
 			dma_free_coherent(dev, len, p, *phys);
@@ -1982,7 +1983,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	iq->size = roundup(iq->size, 16);
 
 	iq->desc = alloc_ring(adap->pdev_dev, iq->size, iq->iqe_len, 0,
-			      &iq->phys_addr, NULL, 0);
+			      &iq->phys_addr, NULL, 0, NUMA_NO_NODE);
 	if (!iq->desc)
 		return -ENOMEM;
 
@@ -2008,7 +2009,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		fl->size = roundup(fl->size, 8);
 		fl->desc = alloc_ring(adap->pdev_dev, fl->size, sizeof(__be64),
 				      sizeof(struct rx_sw_desc), &fl->addr,
-				      &fl->sdesc, STAT_LEN);
+				      &fl->sdesc, STAT_LEN, NUMA_NO_NODE);
 		if (!fl->desc)
 			goto fl_nomem;
 
@@ -2095,7 +2096,8 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 
 	txq->q.desc = alloc_ring(adap->pdev_dev, txq->q.size,
 			sizeof(struct tx_desc), sizeof(struct tx_sw_desc),
-			&txq->q.phys_addr, &txq->q.sdesc, STAT_LEN);
+			&txq->q.phys_addr, &txq->q.sdesc, STAT_LEN,
+			netdev_queue_numa_node_read(netdevq));
 	if (!txq->q.desc)
 		return -ENOMEM;
 
@@ -2147,7 +2149,7 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 
 	txq->q.desc = alloc_ring(adap->pdev_dev, nentries,
 				 sizeof(struct tx_desc), 0, &txq->q.phys_addr,
-				 NULL, 0);
+				 NULL, 0, NUMA_NO_NODE);
 	if (!txq->q.desc)
 		return -ENOMEM;
 
@@ -2198,7 +2200,8 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 
 	txq->q.desc = alloc_ring(adap->pdev_dev, txq->q.size,
 			sizeof(struct tx_desc), sizeof(struct tx_sw_desc),
-			&txq->q.phys_addr, &txq->q.sdesc, STAT_LEN);
+			&txq->q.phys_addr, &txq->q.sdesc, STAT_LEN,
+			NUMA_NO_NODE);
 	if (!txq->q.desc)
 		return -ENOMEM;
 
-- 
1.5.4

