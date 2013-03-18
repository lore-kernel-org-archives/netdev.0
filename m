From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 1/2] be2net: enable interrupts in be_probe() (RoCE and other ULPs need them)
Date: Mon, 18 Mar 2013 12:34:12 +0530
Message-ID: <a0b78c32-3f54-4339-9fb1-1aea0de8764a@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	"Sathya Perla" <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:54103 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3CRHFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 03:05:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the NIC PCI function may be used by other protocols, the chip interrupts
must be enabled in be_probe() itself rather than be_open().

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b8e5019..dae7172 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -157,6 +157,10 @@ static void be_intr_set(struct be_adapter *adapter, bool enable)
 {
 	u32 reg, enabled;
 
+	/* On lancer interrupts can't be controlled via this register */
+	if (lancer_chip(adapter))
+		return;
+
 	if (adapter->eeh_error)
 		return;
 
@@ -2435,9 +2439,6 @@ static int be_close(struct net_device *netdev)
 
 	be_roce_dev_close(adapter);
 
-	if (!lancer_chip(adapter))
-		be_intr_set(adapter, false);
-
 	for_all_evt_queues(adapter, eqo, i)
 		napi_disable(&eqo->napi);
 
@@ -2525,9 +2526,6 @@ static int be_open(struct net_device *netdev)
 
 	be_irq_register(adapter);
 
-	if (!lancer_chip(adapter))
-		be_intr_set(adapter, true);
-
 	for_all_rx_queues(adapter, rxo, i)
 		be_cq_notify(adapter, rxo->cq.id, true, 0);
 
@@ -3853,6 +3851,7 @@ static void be_remove(struct pci_dev *pdev)
 		return;
 
 	be_roce_dev_remove(adapter);
+	be_intr_set(adapter, false);
 
 	cancel_delayed_work_sync(&adapter->func_recovery_work);
 
@@ -4142,11 +4141,11 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 			goto ctrl_clean;
 	}
 
-	/* The INTR bit may be set in the card when probed by a kdump kernel
-	 * after a crash.
-	 */
-	if (!lancer_chip(adapter))
-		be_intr_set(adapter, false);
+	/* Wait for interrupts to quiesce after an FLR */
+	msleep(100);
+
+	/* Allow interrupts for other ULPs running on NIC function */
+	be_intr_set(adapter, true);
 
 	status = be_stats_init(adapter);
 	if (status)
-- 
1.5.6.1
