From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Subject: [PATCH net-next 3/4] be2net: Minor code cleanup in tx completion process
Date: Sun, 15 Feb 2015 13:15:26 +0530
Message-ID: <1423986327-10069-4-git-send-email-sriharsha.basavapatna@emulex.com>
References: <1423986327-10069-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:21190 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382AbbBOHxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 02:53:48 -0500
In-Reply-To: <1423986327-10069-1-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- To avoid multiple accesses to CQE, extract compl_status and end_idx from
  be_tx_compl_get().

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  7 +++++
 drivers/net/ethernet/emulex/benet/be_main.c | 47 +++++++++++++++--------------
 2 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index bc7f3d6..ad33bf1 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -238,10 +238,17 @@ struct be_tx_stats {
 	struct u64_stats_sync sync_compl;
 };
 
+/* Structure to hold some data of interest obtained from a TX CQE */
+struct be_tx_compl_info {
+	u8 status;		/* Completion status */
+	u16 end_index;		/* Completed TXQ Index */
+};
+
 struct be_tx_obj {
 	u32 db_offset;
 	struct be_queue_info q;
 	struct be_queue_info cq;
+	struct be_tx_compl_info txcp;
 	/* Remember the skbs that were transmitted */
 	struct sk_buff *sent_skb_list[TX_Q_LEN];
 	struct be_tx_stats stats;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2f17937..b37b099 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2065,18 +2065,23 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp, u32 frags_needed)
 	}
 }
 
-static struct be_eth_tx_compl *be_tx_compl_get(struct be_queue_info *tx_cq)
+static struct be_tx_compl_info *be_tx_compl_get(struct be_tx_obj *txo)
 {
-	struct be_eth_tx_compl *txcp = queue_tail_node(tx_cq);
+	struct be_queue_info *tx_cq = &txo->cq;
+	struct be_tx_compl_info *txcp = &txo->txcp;
+	struct be_eth_tx_compl *compl = queue_tail_node(tx_cq);
 
-	if (txcp->dw[offsetof(struct amap_eth_tx_compl, valid) / 32] == 0)
+	if (compl->dw[offsetof(struct amap_eth_tx_compl, valid) / 32] == 0)
 		return NULL;
 
+	/* Ensure load ordering of valid bit dword and other dwords below */
 	rmb();
-	be_dws_le_to_cpu(txcp, sizeof(*txcp));
+	be_dws_le_to_cpu(compl, sizeof(*compl));
 
-	txcp->dw[offsetof(struct amap_eth_tx_compl, valid) / 32] = 0;
+	txcp->status = GET_TX_COMPL_BITS(status, compl);
+	txcp->end_index = GET_TX_COMPL_BITS(wrb_index, compl);
 
+	compl->dw[offsetof(struct amap_eth_tx_compl, valid) / 32] = 0;
 	queue_tail_inc(tx_cq);
 	return txcp;
 }
@@ -2197,9 +2202,9 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 {
 	u16 end_idx, notified_idx, cmpl = 0, timeo = 0, num_wrbs = 0;
 	struct device *dev = &adapter->pdev->dev;
-	struct be_tx_obj *txo;
+	struct be_tx_compl_info *txcp;
 	struct be_queue_info *txq;
-	struct be_eth_tx_compl *txcp;
+	struct be_tx_obj *txo;
 	int i, pending_txqs;
 
 	/* Stop polling for compls when HW has been silent for 10ms */
@@ -2210,10 +2215,10 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 			cmpl = 0;
 			num_wrbs = 0;
 			txq = &txo->q;
-			while ((txcp = be_tx_compl_get(&txo->cq))) {
-				end_idx = GET_TX_COMPL_BITS(wrb_index, txcp);
-				num_wrbs += be_tx_compl_process(adapter, txo,
-								end_idx);
+			while ((txcp = be_tx_compl_get(txo))) {
+				num_wrbs +=
+					be_tx_compl_process(adapter, txo,
+							    txcp->end_index);
 				cmpl++;
 			}
 			if (cmpl) {
@@ -2572,7 +2577,7 @@ loop_continue:
 	return work_done;
 }
 
-static inline void be_update_tx_err(struct be_tx_obj *txo, u32 status)
+static inline void be_update_tx_err(struct be_tx_obj *txo, u8 status)
 {
 	switch (status) {
 	case BE_TX_COMP_HDR_PARSE_ERR:
@@ -2587,7 +2592,7 @@ static inline void be_update_tx_err(struct be_tx_obj *txo, u32 status)
 	}
 }
 
-static inline void lancer_update_tx_err(struct be_tx_obj *txo, u32 status)
+static inline void lancer_update_tx_err(struct be_tx_obj *txo, u8 status)
 {
 	switch (status) {
 	case LANCER_TX_COMP_LSO_ERR:
@@ -2612,22 +2617,18 @@ static inline void lancer_update_tx_err(struct be_tx_obj *txo, u32 status)
 static void be_process_tx(struct be_adapter *adapter, struct be_tx_obj *txo,
 			  int idx)
 {
-	struct be_eth_tx_compl *txcp;
 	int num_wrbs = 0, work_done = 0;
-	u32 compl_status;
-	u16 last_idx;
+	struct be_tx_compl_info *txcp;
 
-	while ((txcp = be_tx_compl_get(&txo->cq))) {
-		last_idx = GET_TX_COMPL_BITS(wrb_index, txcp);
-		num_wrbs += be_tx_compl_process(adapter, txo, last_idx);
+	while ((txcp = be_tx_compl_get(txo))) {
+		num_wrbs += be_tx_compl_process(adapter, txo, txcp->end_index);
 		work_done++;
 
-		compl_status = GET_TX_COMPL_BITS(status, txcp);
-		if (compl_status) {
+		if (txcp->status) {
 			if (lancer_chip(adapter))
-				lancer_update_tx_err(txo, compl_status);
+				lancer_update_tx_err(txo, txcp->status);
 			else
-				be_update_tx_err(txo, compl_status);
+				be_update_tx_err(txo, txcp->status);
 		}
 	}
 
-- 
2.2.0.65.g9abc44b
