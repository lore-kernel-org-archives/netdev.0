From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 2/3] be2net: refactor be_msix_(un)register()
	code.
Date: Mon, 17 Aug 2009 16:28:26 +0530
Message-ID: <20090817105826.GA10235@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:41177 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751754AbZHQK6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 06:58:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   58 +++++++++++++++++++++++++++---------------
 1 files changed, 37 insertions(+), 21 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 3623460..010175f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1303,6 +1303,12 @@ rx_eq_free:
 	return rc;
 }
 
+/* There are 8 evt ids per func. Retruns the evt id's bit number */
+static inline int be_evt_bit_get(struct be_adapter *adapter, u32 eq_id)
+{
+	return eq_id - 8 * be_pci_func(adapter);
+}
+
 static irqreturn_t be_intx(int irq, void *dev)
 {
 	struct be_adapter *adapter = dev;
@@ -1476,31 +1482,44 @@ static void be_msix_enable(struct be_adapter *adapter)
 
 static inline int be_msix_vec_get(struct be_adapter *adapter, u32 eq_id)
 {
-	return adapter->msix_entries[eq_id - 8 * be_pci_func(adapter)].vector;
+	return adapter->msix_entries[
+			be_evt_bit_get(adapter, eq_id)].vector;
 }
 
-static int be_msix_register(struct be_adapter *adapter)
+static int be_request_irq(struct be_adapter *adapter,
+		struct be_eq_obj *eq_obj,
+		void *handler, char *desc)
 {
 	struct net_device *netdev = adapter->netdev;
-	struct be_eq_obj *tx_eq = &adapter->tx_eq;
-	struct be_eq_obj *rx_eq = &adapter->rx_eq;
-	int status, vec;
+	int vec;
+
+	sprintf(eq_obj->desc, "%s-%s", netdev->name, desc);
+	vec = be_msix_vec_get(adapter, eq_obj->q.id);
+	return request_irq(vec, handler, 0, eq_obj->desc, adapter);
+}
+
+static void be_free_irq(struct be_adapter *adapter, struct be_eq_obj *eq_obj)
+{
+	int vec = be_msix_vec_get(adapter, eq_obj->q.id);
+	free_irq(vec, adapter);
+}
 
-	sprintf(tx_eq->desc, "%s-tx", netdev->name);
-	vec = be_msix_vec_get(adapter, tx_eq->q.id);
-	status = request_irq(vec, be_msix_tx_mcc, 0, tx_eq->desc, adapter);
+static int be_msix_register(struct be_adapter *adapter)
+{
+	int status;
+
+	status = be_request_irq(adapter, &adapter->tx_eq, be_msix_tx_mcc, "tx");
 	if (status)
 		goto err;
 
-	sprintf(rx_eq->desc, "%s-rx", netdev->name);
-	vec = be_msix_vec_get(adapter, rx_eq->q.id);
-	status = request_irq(vec, be_msix_rx, 0, rx_eq->desc, adapter);
-	if (status) { /* Free TX IRQ */
-		vec = be_msix_vec_get(adapter, tx_eq->q.id);
-		free_irq(vec, adapter);
-		goto err;
-	}
+	status = be_request_irq(adapter, &adapter->rx_eq, be_msix_rx, "rx");
+	if (status)
+		goto free_tx_irq;
+
 	return 0;
+
+free_tx_irq:
+	be_free_irq(adapter, &adapter->tx_eq);
 err:
 	dev_warn(&adapter->pdev->dev,
 		"MSIX Request IRQ failed - err %d\n", status);
@@ -1537,7 +1556,6 @@ done:
 static void be_irq_unregister(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int vec;
 
 	if (!adapter->isr_registered)
 		return;
@@ -1549,10 +1567,8 @@ static void be_irq_unregister(struct be_adapter *adapter)
 	}
 
 	/* MSIx */
-	vec = be_msix_vec_get(adapter, adapter->tx_eq.q.id);
-	free_irq(vec, adapter);
-	vec = be_msix_vec_get(adapter, adapter->rx_eq.q.id);
-	free_irq(vec, adapter);
+	be_free_irq(adapter, &adapter->tx_eq);
+	be_free_irq(adapter, &adapter->rx_eq);
 done:
 	adapter->isr_registered = false;
 	return;
-- 
1.6.0.4

