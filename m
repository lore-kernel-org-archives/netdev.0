From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4vf: Turn off SGE RX/TX Callback Timers and interrupts in PCI shutdown routine
Date: Tue,  5 Aug 2014 15:41:28 +0530
Message-ID: <1407233488-17030-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:59173
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933078AbaHEKFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 06:05:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to turn off  SGE RX/TX Callback Timers & interrupt in cxgb4vf PCI Shutdown
routine in order to prevent crashes during reboot/poweroff when traffic is
running.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   29 ++++++++++---------
 1 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index f002af1..d8d28e8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2876,24 +2876,24 @@ static void cxgb4vf_pci_shutdown(struct pci_dev *pdev)
 	if (!adapter)
 		return;
 
-	/*
-	 * Disable all Virtual Interfaces.  This will shut down the
+	/* Disable all Virtual Interfaces.  This will shut down the
 	 * delivery of all ingress packets into the chip for these
 	 * Virtual Interfaces.
 	 */
-	for_each_port(adapter, pidx) {
-		struct net_device *netdev;
-		struct port_info *pi;
-
-		if (!test_bit(pidx, &adapter->registered_device_map))
-			continue;
-
-		netdev = adapter->port[pidx];
-		if (!netdev)
-			continue;
+	for_each_port(adapter, pidx)
+		if (test_bit(pidx, &adapter->registered_device_map))
+			unregister_netdev(adapter->port[pidx]);
 
-		pi = netdev_priv(netdev);
-		t4vf_enable_vi(adapter, pi->viid, false, false);
+	/* Free up all Queues which will prevent further DMA and
+	 * Interrupts allowing various internal pathways to drain.
+	 */
+	t4vf_sge_stop(adapter);
+	if (adapter->flags & USING_MSIX) {
+		pci_disable_msix(adapter->pdev);
+		adapter->flags &= ~USING_MSIX;
+	} else if (adapter->flags & USING_MSI) {
+		pci_disable_msi(adapter->pdev);
+		adapter->flags &= ~USING_MSI;
 	}
 
 	/*
@@ -2901,6 +2901,7 @@ static void cxgb4vf_pci_shutdown(struct pci_dev *pdev)
 	 * Interrupts allowing various internal pathways to drain.
 	 */
 	t4vf_free_sge_resources(adapter);
+	pci_set_drvdata(pdev, NULL);
 }
 
 /*
-- 
1.7.1
