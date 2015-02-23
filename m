From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 7/9] be2net: refactor adapter resource initialzation sequence into be_resume()
Date: Mon, 23 Feb 2015 04:20:14 -0500
Message-ID: <1424683216-29611-8-git-send-email-sathya.perla@emulex.com>
References: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:32982 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbbBWJRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:17:17 -0500
In-Reply-To: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Most of the adapter initialisation sequences performed in be_resume(),
be_eeh_resume() and be_err_recover() are same. Renamed be_resume() to
be_pci_resume() and moved the common code to a new routine be_resume() to
avoid code duplication.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 56 +++++++++++------------------
 1 file changed, 21 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4a29ff1..80a0aab 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4941,28 +4941,39 @@ static int be_func_init(struct be_adapter *adapter)
 	return 0;
 }
 
-static int be_err_recover(struct be_adapter *adapter)
+static int be_resume(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	struct device *dev = &adapter->pdev->dev;
 	int status;
 
 	status = be_func_init(adapter);
 	if (status)
-		goto err;
+		return status;
 
 	status = be_setup(adapter);
 	if (status)
-		goto err;
+		return status;
 
 	if (netif_running(netdev)) {
 		status = be_open(netdev);
 		if (status)
-			goto err;
+			return status;
 	}
 
 	netif_device_attach(netdev);
 
+	return 0;
+}
+
+static int be_err_recover(struct be_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+	int status;
+
+	status = be_resume(adapter);
+	if (status)
+		goto err;
+
 	dev_info(dev, "Adapter recovery successful\n");
 	return 0;
 err:
@@ -5412,13 +5423,10 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 	return 0;
 }
 
-static int be_resume(struct pci_dev *pdev)
+static int be_pci_resume(struct pci_dev *pdev)
 {
-	int status = 0;
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
-	struct net_device *netdev =  adapter->netdev;
-
-	netif_device_detach(netdev);
+	int status = 0;
 
 	status = pci_enable_device(pdev);
 	if (status)
@@ -5427,19 +5435,10 @@ static int be_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
-	status = be_func_init(adapter);
+	status = be_resume(adapter);
 	if (status)
 		return status;
 
-	be_setup(adapter);
-	if (netif_running(netdev)) {
-		rtnl_lock();
-		be_open(netdev);
-		rtnl_unlock();
-	}
-
-	netif_device_attach(netdev);
-
 	be_schedule_err_detection(adapter);
 
 	if (adapter->wol_en)
@@ -5539,28 +5538,15 @@ static void be_eeh_resume(struct pci_dev *pdev)
 {
 	int status = 0;
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
-	struct net_device *netdev =  adapter->netdev;
 
 	dev_info(&adapter->pdev->dev, "EEH resume\n");
 
 	pci_save_state(pdev);
 
-	status = be_func_init(adapter);
+	status = be_resume(adapter);
 	if (status)
 		goto err;
 
-	status = be_setup(adapter);
-	if (status)
-		goto err;
-
-	if (netif_running(netdev)) {
-		status = be_open(netdev);
-		if (status)
-			goto err;
-	}
-
-	netif_device_attach(netdev);
-
 	be_schedule_err_detection(adapter);
 	return;
 err:
@@ -5579,7 +5565,7 @@ static struct pci_driver be_driver = {
 	.probe = be_probe,
 	.remove = be_remove,
 	.suspend = be_suspend,
-	.resume = be_resume,
+	.resume = be_pci_resume,
 	.shutdown = be_shutdown,
 	.err_handler = &be_eeh_handlers
 };
-- 
2.2.0
