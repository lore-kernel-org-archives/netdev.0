From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] ixgbe: fix crash on rmmod after probe fail
Date: Fri,  5 Dec 2014 09:52:51 -0800
Message-ID: <1417801973-28793-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7187 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878AbaLERyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 12:54:00 -0500
In-Reply-To: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The driver has logic to free up used data in case any of the checks in
ixgbe_probe() fail, however there is a similar set of cleanups that can
occur on driver unload in ixgbe_remove() which can cause the rmmod command
to crash.

This patch aims to fix the logic by moving pci_set_drvdata() after all error
checks and then adds a check in ixgbe_remove() to skip it altogether if
adapter comes up empty.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 027c135..82d4187 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8206,7 +8206,6 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	adapter = netdev_priv(netdev);
-	pci_set_drvdata(pdev, adapter);
 
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
@@ -8486,6 +8485,8 @@ skip_sriov:
 	if (err)
 		goto err_register;
 
+	pci_set_drvdata(pdev, adapter);
+
 	/* power down the optics for 82599 SFP+ fiber */
 	if (hw->mac.ops.disable_tx_laser)
 		hw->mac.ops.disable_tx_laser(hw);
@@ -8565,9 +8566,14 @@ err_dma:
 static void ixgbe_remove(struct pci_dev *pdev)
 {
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
-	struct net_device *netdev = adapter->netdev;
+	struct net_device *netdev;
 	bool disable_dev;
 
+	/* if !adapter then we already cleaned up in probe */
+	if (!adapter)
+		return;
+
+	netdev  = adapter->netdev;
 	ixgbe_dbg_adapter_exit(adapter);
 
 	set_bit(__IXGBE_REMOVING, &adapter->state);
-- 
1.9.3
