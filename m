From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 6/7] be2net: Disarm CQ and EQ to disable interrupt in Lancer
Date: Mon, 7 Mar 2011 18:39:17 +0530
Message-ID: <a90f0081-4b33-4200-918f-e806c5fac42a@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:52339 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752091Ab1CGNKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 08:10:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For Lancer disable interrupts in close by disarming CQs and EQs.
Change the order of calls in be_close to achieve the correct result.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Subramanian Seetharaman <subbu.seetharaman@emulex.com>
---
 drivers/net/benet/be_main.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 68b9d17..a7fd833 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2088,6 +2088,18 @@ static int be_close(struct net_device *netdev)
 	if (!lancer_chip(adapter))
 		be_intr_set(adapter, false);
 
+	for_all_rx_queues(adapter, rxo, i)
+		napi_disable(&rxo->rx_eq.napi);
+
+	napi_disable(&tx_eq->napi);
+
+	if (lancer_chip(adapter)) {
+		be_cq_notify(adapter, adapter->tx_obj.cq.id, false, 0);
+		be_cq_notify(adapter, adapter->mcc_obj.cq.id, false, 0);
+		for_all_rx_queues(adapter, rxo, i)
+			 be_cq_notify(adapter, rxo->cq.id, false, 0);
+	}
+
 	if (adapter->msix_enabled) {
 		vec = be_msix_vec_get(adapter, tx_eq);
 		synchronize_irq(vec);
@@ -2101,11 +2113,6 @@ static int be_close(struct net_device *netdev)
 	}
 	be_irq_unregister(adapter);
 
-	for_all_rx_queues(adapter, rxo, i)
-		napi_disable(&rxo->rx_eq.napi);
-
-	napi_disable(&tx_eq->napi);
-
 	/* Wait for all pending tx completions to arrive so that
 	 * all tx skbs are freed.
 	 */
-- 
1.6.0.2

