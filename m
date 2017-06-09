From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: fix memory leak in init_one()
Date: Fri,  9 Jun 2017 19:26:24 +0530
Message-ID: <1497016584-12034-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:6879 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751536AbdFIN4p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 09:56:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free up mbox_log allocated for PF0 to PF3.

Fixes: 7829451c695e ("cxgb4: Add control net_device for configuring PCIe VF")
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index ff8bcf5..01c9710 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5169,13 +5169,15 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			      &v, &port_vec);
 	if (err < 0) {
 		dev_err(adapter->pdev_dev, "Could not fetch port params\n");
-		goto free_adapter;
+		goto free_mbox_log;
 	}
 
 	adapter->params.nports = hweight32(port_vec);
 	pci_set_drvdata(pdev, adapter);
 	return 0;
 
+free_mbox_log:
+	kfree(adapter->mbox_log);
  free_adapter:
 	kfree(adapter);
  free_pci_region:
@@ -5275,6 +5277,7 @@ static void remove_one(struct pci_dev *pdev)
 			unregister_netdev(adapter->port[0]);
 		iounmap(adapter->regs);
 		kfree(adapter->vfinfo);
+		kfree(adapter->mbox_log);
 		kfree(adapter);
 		pci_disable_sriov(pdev);
 		pci_release_regions(pdev);
@@ -5321,6 +5324,7 @@ static void shutdown_one(struct pci_dev *pdev)
 			unregister_netdev(adapter->port[0]);
 		iounmap(adapter->regs);
 		kfree(adapter->vfinfo);
+		kfree(adapter->mbox_log);
 		kfree(adapter);
 		pci_disable_sriov(pdev);
 		pci_release_regions(pdev);
-- 
2.1.0
