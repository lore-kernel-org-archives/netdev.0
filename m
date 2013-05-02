From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 3/3] be2net: Fix to fail probe if MSI-X enable fails for a VF
Date: Thu, 2 May 2013 19:07:08 +0530
Message-ID: <27643d04-d8f9-499d-917e-cc6d9b03c4eb@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:13314 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759582Ab3EBNiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 09:38:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per SPEC, INTx mode is not supported on VFs. So if enable_msix fails,
then just fail probe. Also bail out of be_open if irq_register fails.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 31d5982..47ff540 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2365,7 +2365,7 @@ static uint be_num_rss_want(struct be_adapter *adapter)
 	return num;
 }
 
-static void be_msix_enable(struct be_adapter *adapter)
+static int be_msix_enable(struct be_adapter *adapter)
 {
 #define BE_MIN_MSIX_VECTORS		1
 	int i, status, num_vec, num_roce_vec = 0;
@@ -2390,13 +2390,17 @@ static void be_msix_enable(struct be_adapter *adapter)
 		goto done;
 	} else if (status >= BE_MIN_MSIX_VECTORS) {
 		num_vec = status;
-		if (pci_enable_msix(adapter->pdev, adapter->msix_entries,
-				num_vec) == 0)
+		status = pci_enable_msix(adapter->pdev, adapter->msix_entries,
+					 num_vec);
+		if (!status)
 			goto done;
 	}
 
 	dev_warn(dev, "MSIx enable failed\n");
-	return;
+	/* INTx is not supported in VFs, so fail probe if enable_msix fails */
+	if (!be_physfn(adapter))
+		return status;
+	return 0;
 done:
 	if (be_roce_supported(adapter)) {
 		if (num_vec > num_roce_vec) {
@@ -2410,7 +2414,7 @@ done:
 	} else
 		adapter->num_msix_vec = num_vec;
 	dev_info(dev, "enabled %d MSI-x vector(s)\n", adapter->num_msix_vec);
-	return;
+	return 0;
 }
 
 static inline int be_msix_vec_get(struct be_adapter *adapter,
@@ -2614,7 +2618,9 @@ static int be_open(struct net_device *netdev)
 	if (status)
 		goto err;
 
-	be_irq_register(adapter);
+	status = be_irq_register(adapter);
+	if (status)
+		goto err;
 
 	if (!lancer_chip(adapter))
 		be_intr_set(adapter, true);
@@ -3081,7 +3087,9 @@ static int be_setup(struct be_adapter *adapter)
 	if (status)
 		goto err;
 
-	be_msix_enable(adapter);
+	status = be_msix_enable(adapter);
+	if (status)
+		goto err;
 
 	status = be_evt_queues_create(adapter);
 	if (status)
-- 
1.6.0.2
