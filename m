From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 8/9] be2net: refactor adapter resource cleanup sequence into be_cleanup()
Date: Mon, 23 Feb 2015 04:20:15 -0500
Message-ID: <1424683216-29611-9-git-send-email-sathya.perla@emulex.com>
References: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:5932 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641AbbBWJRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:17:23 -0500
In-Reply-To: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Most of the resource cleanup sequences performed in be_suspend(),
be_eeh_err_detected() and be_err_detection_task() are same. Moved the
common code to a new routine be_cleanup() to avoid code duplication.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 40 ++++++++++++-----------------
 1 file changed, 16 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 80a0aab..7aa1a4d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4941,6 +4941,19 @@ static int be_func_init(struct be_adapter *adapter)
 	return 0;
 }
 
+static void be_cleanup(struct be_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	rtnl_lock();
+	netif_device_detach(netdev);
+	if (netif_running(netdev))
+		be_close(netdev);
+	rtnl_unlock();
+
+	be_clear(adapter);
+}
+
 static int be_resume(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -4990,19 +5003,12 @@ static void be_err_detection_task(struct work_struct *work)
 	struct be_adapter *adapter =
 				container_of(work, struct be_adapter,
 					     be_err_detection_work.work);
-	struct net_device *netdev = adapter->netdev;
 	int status = 0;
 
 	be_detect_error(adapter);
 
 	if (adapter->hw_error) {
-		rtnl_lock();
-		netif_device_detach(netdev);
-		if (netif_running(netdev))
-			be_close(netdev);
-		rtnl_unlock();
-
-		be_clear(adapter);
+		be_cleanup(adapter);
 
 		/* As of now error recovery support is in Lancer only */
 		if (lancer_chip(adapter))
@@ -5401,7 +5407,6 @@ do_none:
 static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
-	struct net_device *netdev =  adapter->netdev;
 
 	if (adapter->wol_en)
 		be_setup_wol(adapter, true);
@@ -5409,13 +5414,7 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 	be_intr_set(adapter, false);
 	be_cancel_err_detection(adapter);
 
-	netif_device_detach(netdev);
-	if (netif_running(netdev)) {
-		rtnl_lock();
-		be_close(netdev);
-		rtnl_unlock();
-	}
-	be_clear(adapter);
+	be_cleanup(adapter);
 
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
@@ -5472,7 +5471,6 @@ static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
 					    pci_channel_state_t state)
 {
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
-	struct net_device *netdev =  adapter->netdev;
 
 	dev_err(&adapter->pdev->dev, "EEH error detected\n");
 
@@ -5481,13 +5479,7 @@ static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
 
 		be_cancel_err_detection(adapter);
 
-		rtnl_lock();
-		netif_device_detach(netdev);
-		if (netif_running(netdev))
-			be_close(netdev);
-		rtnl_unlock();
-
-		be_clear(adapter);
+		be_cleanup(adapter);
 	}
 
 	if (state == pci_channel_io_perm_failure)
-- 
2.2.0
