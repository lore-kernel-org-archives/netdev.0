From: Sathya Perla <sathyap@serverengines.com>
Subject: Re: [PATCH] be2net: fix tx completion polling
Date: Tue, 2 Mar 2010 12:06:15 +0530
Message-ID: <20100302063615.GA6480@serverengines.com>
References: <20100225115516.GA10784@serverengines.com>
 <20100226.041926.36027143.davem@davemloft.net>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:21309 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752155Ab0CBGg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 01:36:28 -0500
Content-Disposition: inline
In-Reply-To: <20100226.041926.36027143.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/02/10 04:19 -0800, David Miller wrote:
> From: Sathya Perla <sathyap@serverengines.com>
> Date: Thu, 25 Feb 2010 17:25:16 +0530
> 
> > In tx/mcc polling, napi_complete() is being incorrectly called
> > before reaping tx completions. This can cause tx compl processing
> > to be scheduled on another cpu concurrently which can result in a panic.
> > This if fixed by calling napi complete() after tx/mcc compl processing
> > but before re-enabling interrupts (via a cq notify).
> > 
> > Pls apply to net-2.6.
> 
> net-2.6 is closed, 2.6.33 has been released.
> 
> > Signed-off-by: Sathya Perla <sathyap@serverengines.com>
> 
> This patch does not apply to net-next-2.6

I've re-done the patch for net-next-2.6: Pls apply; thanks!

In tx/mcc polling, napi_complete() is being incorrectly called
before reaping tx completions. This can cause tx compl processing
to be scheduled on another cpu concurrently which can result in a panic.
This if fixed by calling napi complete() after tx/mcc compl processing
but before re-enabling interrupts (via a cq notify).

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   26 +++++++++++-----------
 drivers/net/benet/be_cmds.h |    2 +-
 drivers/net/benet/be_main.c |   47 +++++++++++++++++++++----------------------
 3 files changed, 37 insertions(+), 38 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index c8a2bac..4b1f805 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -119,10 +119,10 @@ void be_async_mcc_disable(struct be_adapter *adapter)
 	adapter->mcc_obj.rearm_cq = false;
 }
 
-int be_process_mcc(struct be_adapter *adapter)
+int be_process_mcc(struct be_adapter *adapter, int *status)
 {
 	struct be_mcc_compl *compl;
-	int num = 0, status = 0;
+	int num = 0;
 	struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
 
 	spin_lock_bh(&adapter->mcc_cq_lock);
@@ -135,31 +135,31 @@ int be_process_mcc(struct be_adapter *adapter)
 			be_async_link_state_process(adapter,
 				(struct be_async_event_link_state *) compl);
 		} else if (compl->flags & CQE_FLAGS_COMPLETED_MASK) {
-				status = be_mcc_compl_process(adapter, compl);
+				*status = be_mcc_compl_process(adapter, compl);
 				atomic_dec(&mcc_obj->q.used);
 		}
 		be_mcc_compl_use(compl);
 		num++;
 	}
 
-	if (num)
-		be_cq_notify(adapter, mcc_obj->cq.id, mcc_obj->rearm_cq, num);
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
+				mcc_obj->rearm_cq, num);
 
-		if (atomic_read(&adapter->mcc_obj.q.used) == 0)
+		if (atomic_read(&mcc_obj->q.used) == 0)
 			break;
 		udelay(100);
 	}
@@ -167,7 +167,7 @@ static int be_mcc_wait_compl(struct be_adapter *adapter)
 		dev_err(&adapter->pdev->dev, "mccq poll timed out\n");
 		return -1;
 	}
-	return 0;
+	return status;
 }
 
 /* Notify MCC requests and wait for completion */
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 728b0d7..cce61f9 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -920,7 +920,7 @@ extern int be_cmd_get_flow_control(struct be_adapter *adapter,
 extern int be_cmd_query_fw_cfg(struct be_adapter *adapter,
 			u32 *port_num, u32 *cap);
 extern int be_cmd_reset_function(struct be_adapter *adapter);
-extern int be_process_mcc(struct be_adapter *adapter);
+extern int be_process_mcc(struct be_adapter *adapter, int *status);
 extern int be_cmd_set_beacon_state(struct be_adapter *adapter,
 			u8 port_num, u8 beacon, u8 status, u8 state);
 extern int be_cmd_get_beacon_state(struct be_adapter *adapter,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 27ccdd8..a703ed8 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -583,7 +583,7 @@ static void be_set_multicast_list(struct net_device *netdev)
 	}
 
 	be_cmd_multicast_set(adapter, adapter->if_handle, netdev,
-			&adapter->mc_cmd_mem);
+		&adapter->mc_cmd_mem);
 done:
 	return;
 }
@@ -1469,23 +1469,38 @@ int be_poll_rx(struct napi_struct *napi, int budget)
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
@@ -1496,24 +1511,8 @@ void be_process_tx(struct be_adapter *adapter)
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

