From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 1/2] be2net: fix be_close() to ensure all events are ack'ed
Date: Tue, 18 Dec 2012 11:08:50 +0530
Message-ID: <f1923deb-9df8-4c1e-97be-944fd119e2ce@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:18598 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741Ab2LRFgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 00:36:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In be_close(), be_eq_clean() must be called after all RX/TX/MCC queues
have been cleaned to ensure that any events caused while cleaning up
completions are notified/acked. Not clearing all events can cause
upredictable behaviour when RX rings are re-created in the subsequent
be_open().

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    5 +++++
 drivers/net/ethernet/emulex/benet/be_main.c |   21 ++++++++++++---------
 2 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index f2875aa..8a250c3 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -298,7 +298,12 @@ void be_async_mcc_enable(struct be_adapter *adapter)
 
 void be_async_mcc_disable(struct be_adapter *adapter)
 {
+	spin_lock_bh(&adapter->mcc_cq_lock);
+
 	adapter->mcc_obj.rearm_cq = false;
+	be_cq_notify(adapter, adapter->mcc_obj.cq.id, false, 0);
+
+	spin_unlock_bh(&adapter->mcc_cq_lock);
 }
 
 int be_process_mcc(struct be_adapter *adapter)
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f95612b..bf50e73 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2398,13 +2398,22 @@ static int be_close(struct net_device *netdev)
 
 	be_roce_dev_close(adapter);
 
-	be_async_mcc_disable(adapter);
-
 	if (!lancer_chip(adapter))
 		be_intr_set(adapter, false);
 
-	for_all_evt_queues(adapter, eqo, i) {
+	for_all_evt_queues(adapter, eqo, i)
 		napi_disable(&eqo->napi);
+
+	be_async_mcc_disable(adapter);
+
+	/* Wait for all pending tx completions to arrive so that
+	 * all tx skbs are freed.
+	 */
+	be_tx_compl_clean(adapter);
+
+	be_rx_qs_destroy(adapter);
+
+	for_all_evt_queues(adapter, eqo, i) {
 		if (msix_enabled(adapter))
 			synchronize_irq(be_msix_vec_get(adapter, eqo));
 		else
@@ -2414,12 +2423,6 @@ static int be_close(struct net_device *netdev)
 
 	be_irq_unregister(adapter);
 
-	/* Wait for all pending tx completions to arrive so that
-	 * all tx skbs are freed.
-	 */
-	be_tx_compl_clean(adapter);
-
-	be_rx_qs_destroy(adapter);
 	return 0;
 }
 
-- 
1.7.1
