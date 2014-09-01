From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 10/12] be2net: get rid of TX budget
Date: Mon, 1 Sep 2014 11:54:22 +0530
Message-ID: <1409552664-15990-11-git-send-email-sathya.perla@emulex.com>
References: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:19158 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbaIAGVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 02:21:55 -0400
In-Reply-To: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enforcing a budget on the TX completion processing in NAPI doesn't
benefit performance in anyway. Just get rid of it.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    2 -
 drivers/net/ethernet/emulex/benet/be_main.c |   30 +++++++++-----------------
 2 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 5ccfce7..d952ca2 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -114,7 +114,6 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define MAX_ROCE_EQS		5
 #define MAX_MSIX_VECTORS	32
 #define MIN_MSIX_VECTORS	1
-#define BE_TX_BUDGET		256
 #define BE_NAPI_WEIGHT		64
 #define MAX_RX_POST		BE_NAPI_WEIGHT /* Frags posted at a time */
 #define RX_FRAGS_REFILL_WM	(RX_Q_LEN - MAX_RX_POST)
@@ -200,7 +199,6 @@ struct be_eq_obj {
 
 	u8 idx;			/* array index */
 	u8 msix_idx;
-	u16 tx_budget;
 	u16 spurious_intr;
 	struct napi_struct napi;
 	struct be_adapter *adapter;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 04a8092..53727ad 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2143,7 +2143,6 @@ static int be_evt_queues_create(struct be_adapter *adapter)
 		napi_hash_add(&eqo->napi);
 		aic = &adapter->aic_obj[i];
 		eqo->adapter = adapter;
-		eqo->tx_budget = BE_TX_BUDGET;
 		eqo->idx = i;
 		aic->max_eqd = BE_MAX_EQD;
 		aic->enable = true;
@@ -2459,20 +2458,19 @@ static inline void lancer_update_tx_err(struct be_tx_obj *txo, u32 status)
 	}
 }
 
-static bool be_process_tx(struct be_adapter *adapter, struct be_tx_obj *txo,
-			  int budget, int idx)
+static void be_process_tx(struct be_adapter *adapter, struct be_tx_obj *txo,
+			  int idx)
 {
 	struct be_eth_tx_compl *txcp;
-	int num_wrbs = 0, work_done;
+	int num_wrbs = 0, work_done = 0;
 	u32 compl_status;
+	u16 last_idx;
+
+	while ((txcp = be_tx_compl_get(&txo->cq))) {
+		last_idx = GET_TX_COMPL_BITS(wrb_index, txcp);
+		num_wrbs += be_tx_compl_process(adapter, txo, last_idx);
+		work_done++;
 
-	for (work_done = 0; work_done < budget; work_done++) {
-		txcp = be_tx_compl_get(&txo->cq);
-		if (!txcp)
-			break;
-		num_wrbs += be_tx_compl_process(adapter, txo,
-						GET_TX_COMPL_BITS(wrb_index,
-								  txcp));
 		compl_status = GET_TX_COMPL_BITS(status, txcp);
 		if (compl_status) {
 			if (lancer_chip(adapter))
@@ -2497,7 +2495,6 @@ static bool be_process_tx(struct be_adapter *adapter, struct be_tx_obj *txo,
 		tx_stats(txo)->tx_compl += work_done;
 		u64_stats_update_end(&tx_stats(txo)->sync_compl);
 	}
-	return (work_done < budget); /* Done */
 }
 
 int be_poll(struct napi_struct *napi, int budget)
@@ -2506,17 +2503,12 @@ int be_poll(struct napi_struct *napi, int budget)
 	struct be_adapter *adapter = eqo->adapter;
 	int max_work = 0, work, i, num_evts;
 	struct be_rx_obj *rxo;
-	bool tx_done;
 
 	num_evts = events_get(eqo);
 
 	/* Process all TXQs serviced by this EQ */
-	for (i = eqo->idx; i < adapter->num_tx_qs; i += adapter->num_evt_qs) {
-		tx_done = be_process_tx(adapter, &adapter->tx_obj[i],
-					eqo->tx_budget, i);
-		if (!tx_done)
-			max_work = budget;
-	}
+	for (i = eqo->idx; i < adapter->num_tx_qs; i += adapter->num_evt_qs)
+		be_process_tx(adapter, &adapter->tx_obj[i], i);
 
 	if (be_lock_napi(eqo)) {
 		/* This loop will iterate twice for EQ0 in which
-- 
1.7.1
