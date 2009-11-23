From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 4/5] be2net: Fix cleanup path in be_probe()
Date: Mon, 23 Nov 2009 13:32:26 +0530
Message-ID: <20091123080226.GA7812@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:44474 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753013AbZKWIC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 03:02:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disabling msix was missing when probe fails after enabling msix.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 9d894c8..4a04d58 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1476,6 +1476,14 @@ static void be_worker(struct work_struct *work)
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
 }
 
+static void be_msix_disable(struct be_adapter *adapter)
+{
+	if (adapter->msix_enabled) {
+		pci_disable_msix(adapter->pdev);
+		adapter->msix_enabled = false;
+	}
+}
+
 static void be_msix_enable(struct be_adapter *adapter)
 {
 	int i, status;
@@ -2096,6 +2104,7 @@ static int be_stats_init(struct be_adapter *adapter)
 static void __devexit be_remove(struct pci_dev *pdev)
 {
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
+
 	if (!adapter)
 		return;
 
@@ -2107,10 +2116,7 @@ static void __devexit be_remove(struct pci_dev *pdev)
 
 	be_ctrl_cleanup(adapter);
 
-	if (adapter->msix_enabled) {
-		pci_disable_msix(adapter->pdev);
-		adapter->msix_enabled = false;
-	}
+	be_msix_disable(adapter);
 
 	pci_set_drvdata(pdev, NULL);
 	pci_release_regions(pdev);
@@ -2230,7 +2236,9 @@ stats_clean:
 ctrl_clean:
 	be_ctrl_cleanup(adapter);
 free_netdev:
+	be_msix_disable(adapter);
 	free_netdev(adapter->netdev);
+	pci_set_drvdata(pdev, NULL);
 rel_reg:
 	pci_release_regions(pdev);
 disable_dev:
-- 
1.6.5.2

