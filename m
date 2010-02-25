From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH] be2net: fix tx completion polling
Date: Thu, 25 Feb 2010 17:25:16 +0530
Message-ID: <20100225115516.GA10784@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:44753 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759173Ab0BYLzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 06:55:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tx/mcc polling, napi_complete() is being incorrectly called
before reaping tx completions. This can cause tx compl processing
to be scheduled on another cpu concurrently which can result in a panic.
This if fixed by calling napi complete() after tx/mcc compl processing
but before re-enabling interrupts (via a cq notify).

Pls apply to net-2.6.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   26 ++++++++++++------------
 drivers/net/benet/be_cmds.h |    2 +-
 drivers/net/benet/be_main.c |   45 +++++++++++++++++++++----------------------
 3 files changed, 36 insertions(+), 37 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 006cb2e..e48797f 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -104,10 +104,10 @@ static struct be_mcc_compl *be_mcc_compl_get(struct be_adapter *adapter)
 	return NULL;
 }
 
-int be_process_mcc(struct be_adapter *adapter)
+int be_process_mcc(struct be_adapter *adapter, int *status)
 {
 	struct be_mcc_compl *compl;
-	int num = 0, status = 0;
+	int num = 0;
 
 	spin_lock_bh(&adapter->mcc_cq_lock);
 	while ((compl = be_mcc_compl_get(adapter))) {
@@ -119,31 +119,31 @@ int be_process_mcc(struct be_adapter *adapter)
 			be_async_link_state_process(adapter,
 				(struct be_async_event_link_state *) compl);
 		} else if (compl->flags & CQE_FLAGS_COMPLETED_MASK) {
-				status = be_mcc_compl_process(adapter, compl);
+				*status = be_mcc_compl_process(adapter, compl);
 				atomic_dec(&adapter->mcc_obj.q.used);
 		}
 		be_mcc_compl_use(compl);
 		num++;
 	}
 
-	if (num)
-		be_cq_notify(adapter, adapter->mcc_obj.cq.id, true, num);
-
 	spin_unlock_bh(&adapter->mcc_cq_lock);
-	return status;
+	return num;
 }
 
 /* Wait till no more pending mcc requests are present */
 static int be_mcc_wait_compl(struct be_adapter *adapter)
 {
 #define mcc_timeout		120000 /* 12s timeout */
-	int i, status;
+	int i, num, status = 0;
+	struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
+
 	for (i = 0; i < mcc_timeout; i++) {
-		status = be_process_mcc(adapter);
-		if (status)
-			return status;
+		num = be_process_mcc(adapter, &status);
+		if (num)
+			be_cq_notify(adapter, mcc_obj->cq.id,
+				true, num);
 
-		if (atomic_read(&adapter->mcc_obj.q.used) == 0)
+		if (atomic_read(&mcc_obj->q.used) == 0)
 			break;
 		udelay(100);
 	}
@@ -151,7 +151,7 @@ static int be_mcc_wait_compl(struct be_adapter *adapter)
 		dev_err(&adapter->pdev->dev, "mccq poll timed out\n");
 		return -1;
 	}
-	return 0;
+	return status;
 }
 
 /* Notify MCC requests and wait for completion */
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 13b33c8..24d9193 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -907,7 +907,7 @@ extern int be_cmd_get_flow_control(struct be_adapter *adapter,
 extern int be_cmd_query_fw_cfg(struct be_adapter *adapter,
 			u32 *port_num, u32 *cap);
 extern int be_cmd_reset_function(struct be_adapter *adapter);
-extern int be_process_mcc(struct be_adapter *adapter);
+extern int be_process_mcc(struct be_adapter *adapter, int *status);
 extern int be_cmd_set_beacon_state(struct be_adapter *adapter,
 			u8 port_num, u8 beacon, u8 status, u8 state);
 extern int be_cmd_get_beacon_state(struct be_adapter *adapter,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 626b76c..5fc46bd 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1428,23 +1428,38 @@ int be_poll_rx(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-void be_process_tx(struct be_adapter *adapter)
+/* As TX and MCC share the same EQ check for both TX and MCC completions.
+ * For TX/MCC we don't honour budget; consume everything
+ */
+static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
 {
+	struct be_eq_obj *tx_eq = container_of(napi, struct be_eq_obj, napi);
+	struct be_adapter *adapter =
+		container_of(tx_eq, struct be_adapter, tx_eq);
 	struct be_queue_info *txq = &adapter->tx_obj.q;
 	struct be_queue_info *tx_cq = &adapter->tx_obj.cq;
 	struct be_eth_tx_compl *txcp;
-	u32 num_cmpl = 0;
+	int tx_compl = 0, mcc_compl, status = 0;
 	u16 end_idx;
 
 	while ((txcp = be_tx_compl_get(tx_cq))) {
 		end_idx = AMAP_GET_BITS(struct amap_eth_tx_compl,
-					wrb_index, txcp);
+				wrb_index, txcp);
 		be_tx_compl_process(adapter, end_idx);
-		num_cmpl++;
+		tx_compl++;
 	}
 
-	if (num_cmpl) {
-		be_cq_notify(adapter, tx_cq->id, true, num_cmpl);
+	mcc_compl = be_process_mcc(adapter, &status);
+
+	napi_complete(napi);
+
+	if (mcc_compl) {
+		struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
+		be_cq_notify(adapter, mcc_obj->cq.id, true, mcc_compl);
+	}
+
+	if (tx_compl) {
+		be_cq_notify(adapter, adapter->tx_obj.cq.id, true, tx_compl);
 
 		/* As Tx wrbs have been freed up, wake up netdev queue if
 		 * it was stopped due to lack of tx wrbs.
@@ -1455,24 +1470,8 @@ void be_process_tx(struct be_adapter *adapter)
 		}
 
 		drvr_stats(adapter)->be_tx_events++;
-		drvr_stats(adapter)->be_tx_compl += num_cmpl;
+		drvr_stats(adapter)->be_tx_compl += tx_compl;
 	}
-}
-
-/* As TX and MCC share the same EQ check for both TX and MCC completions.
- * For TX/MCC we don't honour budget; consume everything
- */
-static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
-{
-	struct be_eq_obj *tx_eq = container_of(napi, struct be_eq_obj, napi);
-	struct be_adapter *adapter =
-		container_of(tx_eq, struct be_adapter, tx_eq);
-
-	napi_complete(napi);
-
-	be_process_tx(adapter);
-
-	be_process_mcc(adapter);
 
 	return 1;
 }
-- 
1.6.3.3

