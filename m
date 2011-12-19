From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next] be2net: Fix INTx processing for Lancer
Date: Mon, 19 Dec 2011 17:23:35 +0530
Message-ID: <607e9a88-8d23-4cca-8aff-07578855b0e8@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:20366 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752891Ab1LSMAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 07:00:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lancer does not have HW registers to indicate the EQ causing the INTx
interrupt. As a result EQE entries of one EQ may be consumed when interrupt
is caused by another EQ. Fix this by arming CQs at the end of NAPI poll
routine to regenerate the EQEs.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b145a49..76f3a98 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1970,6 +1970,7 @@ static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
 	struct be_eq_obj *tx_eq = container_of(napi, struct be_eq_obj, napi);
 	struct be_adapter *adapter =
 		container_of(tx_eq, struct be_adapter, tx_eq);
+	struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
 	struct be_tx_obj *txo;
 	struct be_eth_tx_compl *txcp;
 	int tx_compl, mcc_compl, status = 0;
@@ -2006,12 +2007,19 @@ static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
 	mcc_compl = be_process_mcc(adapter, &status);
 
 	if (mcc_compl) {
-		struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
 		be_cq_notify(adapter, mcc_obj->cq.id, true, mcc_compl);
 	}
 
 	napi_complete(napi);
 
+	/* Arm CQ again to regenerate EQEs for Lancer in INTx mode */
+	if (lancer_chip(adapter) && !msix_enabled(adapter)) {
+		for_all_tx_queues(adapter, txo, i)
+			be_cq_notify(adapter, txo->cq.id, true, 0);
+
+		be_cq_notify(adapter, mcc_obj->cq.id, true, 0);
+	}
+
 	be_eq_notify(adapter, tx_eq->q.id, true, false, 0);
 	adapter->drv_stats.tx_events++;
 	return 1;
-- 
1.6.0.2
