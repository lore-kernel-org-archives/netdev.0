From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next] be2net: fix INTx ISR for interrupt behaviour on BE2
Date: Wed, 28 Nov 2012 11:20:02 +0530
Message-ID: <d856540b-bacc-45e3-a7cc-49e7febafb95@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:56487 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062Ab2K1FrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 00:47:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On BE2 chip, an interrupt may be raised even when EQ is in un-armed state.
As a result be_intx()::events_get() and be_poll:events_get() can race and
notify an EQ wrongly.

Fix this by counting events only in be_poll(). Commit 0b545a629 fixes
the same issue in the MSI-x path.

But, on Lancer, INTx can be de-asserted only by notifying num evts. This
is not an issue as the above BE2 behavior doesn't exist/has never been
seen on Lancer.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   54 +++++++++++---------------
 1 files changed, 23 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index adef536..0661e93 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1675,24 +1675,6 @@ static inline int events_get(struct be_eq_obj *eqo)
 	return num;
 }
 
-static int event_handle(struct be_eq_obj *eqo)
-{
-	bool rearm = false;
-	int num = events_get(eqo);
-
-	/* Deal with any spurious interrupts that come without events */
-	if (!num)
-		rearm = true;
-
-	if (num || msix_enabled(eqo->adapter))
-		be_eq_notify(eqo->adapter, eqo->q.id, rearm, true, num);
-
-	if (num)
-		napi_schedule(&eqo->napi);
-
-	return num;
-}
-
 /* Leaves the EQ is disarmed state */
 static void be_eq_clean(struct be_eq_obj *eqo)
 {
@@ -2014,15 +1996,23 @@ static int be_rx_cqs_create(struct be_adapter *adapter)
 
 static irqreturn_t be_intx(int irq, void *dev)
 {
-	struct be_adapter *adapter = dev;
-	int num_evts;
+	struct be_eq_obj *eqo = dev;
+	struct be_adapter *adapter = eqo->adapter;
+	int num_evts = 0;
 
-	/* With INTx only one EQ is used */
-	num_evts = event_handle(&adapter->eq_obj[0]);
-	if (num_evts)
-		return IRQ_HANDLED;
-	else
-		return IRQ_NONE;
+	/* On Lancer, clear-intr bit of the EQ DB does not work.
+	 * INTx is de-asserted only on notifying num evts.
+	 */
+	if (lancer_chip(adapter))
+		num_evts = events_get(eqo);
+
+	/* The EQ-notify may not de-assert INTx rightaway, causing
+	 * the ISR to be invoked again. So, return HANDLED even when
+	 * num_evts is zero.
+	 */
+	be_eq_notify(adapter, eqo->q.id, false, true, num_evts);
+	napi_schedule(&eqo->napi);
+	return IRQ_HANDLED;
 }
 
 static irqreturn_t be_msix(int irq, void *dev)
@@ -2342,10 +2332,10 @@ static int be_irq_register(struct be_adapter *adapter)
 			return status;
 	}
 
-	/* INTx */
+	/* INTx: only the first EQ is used */
 	netdev->irq = adapter->pdev->irq;
 	status = request_irq(netdev->irq, be_intx, IRQF_SHARED, netdev->name,
-			adapter);
+			     &adapter->eq_obj[0]);
 	if (status) {
 		dev_err(&adapter->pdev->dev,
 			"INTx request IRQ failed - err %d\n", status);
@@ -2367,7 +2357,7 @@ static void be_irq_unregister(struct be_adapter *adapter)
 
 	/* INTx */
 	if (!msix_enabled(adapter)) {
-		free_irq(netdev->irq, adapter);
+		free_irq(netdev->irq, &adapter->eq_obj[0]);
 		goto done;
 	}
 
@@ -3023,8 +3013,10 @@ static void be_netpoll(struct net_device *netdev)
 	struct be_eq_obj *eqo;
 	int i;
 
-	for_all_evt_queues(adapter, eqo, i)
-		event_handle(eqo);
+	for_all_evt_queues(adapter, eqo, i) {
+		be_eq_notify(eqo->adapter, eqo->q.id, false, true, 0);
+		napi_schedule(&eqo->napi);
+	}
 
 	return;
 }
-- 
1.7.1
