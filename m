From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 1/2] cxgb4: Allocate dynamic mem. for egress and ingress queue maps
Date: Thu, 26 Mar 2015 10:04:25 +0530
Message-ID: <1427344466-17658-2-git-send-email-hariprasad@chelsio.com>
References: <1427344466-17658-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31082 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750843AbbCZE2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 00:28:49 -0400
In-Reply-To: <1427344466-17658-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

QIDs (egress/ingress) from firmware in FW_*_CMD.alloc command
can be anywhere in the range from EQ(IQFLINT)_START to EQ(IQFLINT)_END.
For eg, in the first load eqid can be from 100 to 300.
In the next load it can be from 301 to 500 (assume eq_start is 100 and eq_end is
1000).

The driver was assuming them to always start from EQ(IQFLINT)_START till
MAX_EGRQ(INGQ). This was causing stack overflow and subsequent crash.

Fixed it by dynamically allocating memory (of qsize (x_END - x_START + 1)) for
these structures.

Based on original work by Santosh Rastapur <santosh@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   12 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   79 +++++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |    7 +-
 3 files changed, 83 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 97842d0..8816c64 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -376,8 +376,6 @@ enum {
 enum {
 	INGQ_EXTRAS = 2,        /* firmware event queue and */
 				/*   forwarded interrupts */
-	MAX_EGRQ = MAX_ETH_QSETS*2 + MAX_OFLD_QSETS*2
-		   + MAX_CTRL_QUEUES + MAX_RDMA_QUEUES + MAX_ISCSI_QUEUES,
 	MAX_INGQ = MAX_ETH_QSETS + MAX_OFLD_QSETS + MAX_RDMA_QUEUES
 		   + MAX_RDMA_CIQS + MAX_ISCSI_QUEUES + INGQ_EXTRAS,
 };
@@ -616,11 +614,13 @@ struct sge {
 	unsigned int idma_qid[2];   /* SGE IDMA Hung Ingress Queue ID */
 
 	unsigned int egr_start;
+	unsigned int egr_sz;
 	unsigned int ingr_start;
-	void *egr_map[MAX_EGRQ];    /* qid->queue egress queue map */
-	struct sge_rspq *ingr_map[MAX_INGQ]; /* qid->queue ingress queue map */
-	DECLARE_BITMAP(starving_fl, MAX_EGRQ);
-	DECLARE_BITMAP(txq_maperr, MAX_EGRQ);
+	unsigned int ingr_sz;
+	void **egr_map;    /* qid->queue egress queue map */
+	struct sge_rspq **ingr_map; /* qid->queue ingress queue map */
+	unsigned long *starving_fl;
+	unsigned long *txq_maperr;
 	struct timer_list rx_timer; /* refills starving FLs */
 	struct timer_list tx_timer; /* checks Tx queues */
 };
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a22cf93..b9b5a7b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -920,7 +920,7 @@ static void quiesce_rx(struct adapter *adap)
 {
 	int i;
 
-	for (i = 0; i < ARRAY_SIZE(adap->sge.ingr_map); i++) {
+	for (i = 0; i < adap->sge.ingr_sz; i++) {
 		struct sge_rspq *q = adap->sge.ingr_map[i];
 
 		if (q && q->handler) {
@@ -941,7 +941,7 @@ static void enable_rx(struct adapter *adap)
 {
 	int i;
 
-	for (i = 0; i < ARRAY_SIZE(adap->sge.ingr_map); i++) {
+	for (i = 0; i < adap->sge.ingr_sz; i++) {
 		struct sge_rspq *q = adap->sge.ingr_map[i];
 
 		if (!q)
@@ -970,8 +970,8 @@ static int setup_sge_queues(struct adapter *adap)
 	int err, msi_idx, i, j;
 	struct sge *s = &adap->sge;
 
-	bitmap_zero(s->starving_fl, MAX_EGRQ);
-	bitmap_zero(s->txq_maperr, MAX_EGRQ);
+	bitmap_zero(s->starving_fl, s->egr_sz);
+	bitmap_zero(s->txq_maperr, s->egr_sz);
 
 	if (adap->flags & USING_MSIX)
 		msi_idx = 1;         /* vector 0 is for non-queue interrupts */
@@ -983,6 +983,19 @@ static int setup_sge_queues(struct adapter *adap)
 		msi_idx = -((int)s->intrq.abs_id + 1);
 	}
 
+	/* NOTE: If you add/delete any Ingress/Egress Queue allocations in here,
+	 * don't forget to update the following which need to be
+	 * synchronized to and changes here.
+	 *
+	 * 1. The calculations of MAX_INGQ in cxgb4.h.
+	 *
+	 * 2. Update enable_msix/name_msix_vecs/request_msix_queue_irqs
+	 *    to accommodate any new/deleted Ingress Queues
+	 *    which need MSI-X Vectors.
+	 *
+	 * 3. Update sge_qinfo_show() to include information on the
+	 *    new/deleted queues.
+	 */
 	err = t4_sge_alloc_rxq(adap, &s->fw_evtq, true, adap->port[0],
 			       msi_idx, NULL, fwevtq_handler);
 	if (err) {
@@ -4733,8 +4746,9 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	if (ret < 0)
 		return ret;
 
-	ret = t4_cfg_pfvf(adap, adap->fn, adap->fn, 0, MAX_EGRQ, 64, MAX_INGQ,
-			  0, 0, 4, 0xf, 0xf, 16, FW_CMD_CAP_PF, FW_CMD_CAP_PF);
+	ret = t4_cfg_pfvf(adap, adap->fn, adap->fn, 0, adap->sge.egr_sz, 64,
+			  MAX_INGQ, 0, 0, 4, 0xf, 0xf, 16, FW_CMD_CAP_PF,
+			  FW_CMD_CAP_PF);
 	if (ret < 0)
 		return ret;
 
@@ -5293,6 +5307,51 @@ static int adap_init0(struct adapter *adap)
 	adap->tids.nftids = val[4] - val[3] + 1;
 	adap->sge.ingr_start = val[5];
 
+	/* qids (ingress/egress) returned from firmware can be anywhere
+	 * in the range from EQ(IQFLINT)_START to EQ(IQFLINT)_END.
+	 * Hence driver needs to allocate memory for this range to
+	 * store the queue info. Get the highest IQFLINT/EQ index returned
+	 * in FW_EQ_*_CMD.alloc command.
+	 */
+	params[0] = FW_PARAM_PFVF(EQ_END);
+	params[1] = FW_PARAM_PFVF(IQFLINT_END);
+	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2, params, val);
+	if (ret < 0)
+		goto bye;
+	adap->sge.egr_sz = val[0] - adap->sge.egr_start + 1;
+	adap->sge.ingr_sz = val[1] - adap->sge.ingr_start + 1;
+
+	adap->sge.egr_map = kcalloc(adap->sge.egr_sz,
+				    sizeof(*adap->sge.egr_map), GFP_KERNEL);
+	if (!adap->sge.egr_map) {
+		ret = -ENOMEM;
+		goto bye;
+	}
+
+	adap->sge.ingr_map = kcalloc(adap->sge.ingr_sz,
+				     sizeof(*adap->sge.ingr_map), GFP_KERNEL);
+	if (!adap->sge.ingr_map) {
+		ret = -ENOMEM;
+		goto bye;
+	}
+
+	/* Allocate the memory for the vaious egress queue bitmaps
+	 * ie starving_fl and txq_maperr.
+	 */
+	adap->sge.starving_fl =	kcalloc(BITS_TO_LONGS(adap->sge.egr_sz),
+					sizeof(long), GFP_KERNEL);
+	if (!adap->sge.starving_fl) {
+		ret = -ENOMEM;
+		goto bye;
+	}
+
+	adap->sge.txq_maperr = kcalloc(BITS_TO_LONGS(adap->sge.egr_sz),
+				       sizeof(long), GFP_KERNEL);
+	if (!adap->sge.txq_maperr) {
+		ret = -ENOMEM;
+		goto bye;
+	}
+
 	params[0] = FW_PARAM_PFVF(CLIP_START);
 	params[1] = FW_PARAM_PFVF(CLIP_END);
 	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2, params, val);
@@ -5501,6 +5560,10 @@ static int adap_init0(struct adapter *adap)
 	 * happened to HW/FW, stop issuing commands.
 	 */
 bye:
+	kfree(adap->sge.egr_map);
+	kfree(adap->sge.ingr_map);
+	kfree(adap->sge.starving_fl);
+	kfree(adap->sge.txq_maperr);
 	if (ret != -ETIMEDOUT && ret != -EIO)
 		t4_fw_bye(adap, adap->mbox);
 	return ret;
@@ -5912,6 +5975,10 @@ static void free_some_resources(struct adapter *adapter)
 
 	t4_free_mem(adapter->l2t);
 	t4_free_mem(adapter->tids.tid_tab);
+	kfree(adapter->sge.egr_map);
+	kfree(adapter->sge.ingr_map);
+	kfree(adapter->sge.starving_fl);
+	kfree(adapter->sge.txq_maperr);
 	disable_msi(adapter);
 
 	for_each_port(adapter, i)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index b4b9f60..b688b32 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2171,7 +2171,7 @@ static void sge_rx_timer_cb(unsigned long data)
 	struct adapter *adap = (struct adapter *)data;
 	struct sge *s = &adap->sge;
 
-	for (i = 0; i < ARRAY_SIZE(s->starving_fl); i++)
+	for (i = 0; i < BITS_TO_LONGS(s->egr_sz); i++)
 		for (m = s->starving_fl[i]; m; m &= m - 1) {
 			struct sge_eth_rxq *rxq;
 			unsigned int id = __ffs(m) + i * BITS_PER_LONG;
@@ -2259,7 +2259,7 @@ static void sge_tx_timer_cb(unsigned long data)
 	struct adapter *adap = (struct adapter *)data;
 	struct sge *s = &adap->sge;
 
-	for (i = 0; i < ARRAY_SIZE(s->txq_maperr); i++)
+	for (i = 0; i < BITS_TO_LONGS(s->egr_sz); i++)
 		for (m = s->txq_maperr[i]; m; m &= m - 1) {
 			unsigned long id = __ffs(m) + i * BITS_PER_LONG;
 			struct sge_ofld_txq *txq = s->egr_map[id];
@@ -2741,7 +2741,8 @@ void t4_free_sge_resources(struct adapter *adap)
 		free_rspq_fl(adap, &adap->sge.intrq, NULL);
 
 	/* clear the reverse egress queue map */
-	memset(adap->sge.egr_map, 0, sizeof(adap->sge.egr_map));
+	memset(adap->sge.egr_map, 0,
+	       adap->sge.egr_sz * sizeof(*adap->sge.egr_map));
 }
 
 void t4_sge_start(struct adapter *adap)
-- 
1.7.1
