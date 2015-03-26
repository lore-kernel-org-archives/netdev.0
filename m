From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/3] be2net: setup xps queue mapping
Date: Thu, 26 Mar 2015 03:05:09 -0400
Message-ID: <1427353510-24790-3-git-send-email-sathya.perla@emulex.com>
References: <1427353510-24790-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:33044 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbbCZHBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 03:01:08 -0400
In-Reply-To: <1427353510-24790-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets up xps queue mapping on load, so that TX traffic is
steered to the queue whose irqs are being processed by the current cpu.
This helps in avoiding TX lock contention.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3541207..5ff7fba 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2454,8 +2454,9 @@ static void be_tx_queues_destroy(struct be_adapter *adapter)
 
 static int be_tx_qs_create(struct be_adapter *adapter)
 {
-	struct be_queue_info *cq, *eq;
+	struct be_queue_info *cq;
 	struct be_tx_obj *txo;
+	struct be_eq_obj *eqo;
 	int status, i;
 
 	adapter->num_tx_qs = min(adapter->num_evt_qs, be_max_txqs(adapter));
@@ -2473,8 +2474,8 @@ static int be_tx_qs_create(struct be_adapter *adapter)
 		/* If num_evt_qs is less than num_tx_qs, then more than
 		 * one txq share an eq
 		 */
-		eq = &adapter->eq_obj[i % adapter->num_evt_qs].q;
-		status = be_cmd_cq_create(adapter, cq, eq, false, 3);
+		eqo = &adapter->eq_obj[i % adapter->num_evt_qs];
+		status = be_cmd_cq_create(adapter, cq, &eqo->q, false, 3);
 		if (status)
 			return status;
 
@@ -2486,6 +2487,9 @@ static int be_tx_qs_create(struct be_adapter *adapter)
 		status = be_cmd_txq_create(adapter, txo);
 		if (status)
 			return status;
+
+		netif_set_xps_queue(adapter->netdev, eqo->affinity_mask,
+				    eqo->idx);
 	}
 
 	dev_info(&adapter->pdev->dev, "created %d TX queue(s)\n",
-- 
2.2.0
