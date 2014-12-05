From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] ixgbevf: fix possible crashes in probe and remove
Date: Fri,  5 Dec 2014 09:52:53 -0800
Message-ID: <1417801973-28793-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Daniel Borkmann <dborkman@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7187 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913AbaLERyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 12:54:01 -0500
In-Reply-To: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch resolves couple of issues in ixgbevf_probe/remove():

1. Fix a case where adapter->state is tested after free_netdev() this is
same as the patch for ixgbe from Daniel Borkmann <dborkman@redhat.com>:
commit b5b2ffc0574e1f27 ("ixgbe: fix use after free adapter->state test in ixgbe_remove/ixgbe_probe")

2. Move pci_set_drvdata() after all the error checks in ixgbevf_probe() and
then add a check in ixgbevf_probe() to avoid running the cleanup functions
twice in cases where probe failed.

CC: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 54f7f9cd..3b0ddf7 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3737,6 +3737,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct ixgbe_hw *hw = NULL;
 	const struct ixgbevf_info *ii = ixgbevf_info_tbl[ent->driver_data];
 	int err, pci_using_dac;
+	bool disable_dev = false;
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -3771,7 +3772,6 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
-	pci_set_drvdata(pdev, netdev);
 	adapter = netdev_priv(netdev);
 
 	adapter->netdev = netdev;
@@ -3860,6 +3860,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_register;
 
+	pci_set_drvdata(pdev, netdev);
 	netif_carrier_off(netdev);
 
 	ixgbevf_init_last_counter_stats(adapter);
@@ -3889,12 +3890,13 @@ err_sw_init:
 	ixgbevf_reset_interrupt_capability(adapter);
 	iounmap(adapter->io_addr);
 err_ioremap:
+	disable_dev = !test_and_set_bit(__IXGBEVF_DISABLED, &adapter->state);
 	free_netdev(netdev);
 err_alloc_etherdev:
 	pci_release_regions(pdev);
 err_pci_reg:
 err_dma:
-	if (!test_and_set_bit(__IXGBEVF_DISABLED, &adapter->state))
+	if (!adapter || disable_dev)
 		pci_disable_device(pdev);
 	return err;
 }
@@ -3911,7 +3913,13 @@ err_dma:
 static void ixgbevf_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	struct ixgbevf_adapter *adapter;
+	bool disable_dev;
+
+	if (!netdev)
+		return;
+
+	adapter = netdev_priv(netdev);
 
 	set_bit(__IXGBEVF_REMOVING, &adapter->state);
 
@@ -3931,9 +3939,10 @@ static void ixgbevf_remove(struct pci_dev *pdev)
 
 	hw_dbg(&adapter->hw, "Remove complete\n");
 
+	disable_dev = !test_and_set_bit(__IXGBEVF_DISABLED, &adapter->state);
 	free_netdev(netdev);
 
-	if (!test_and_set_bit(__IXGBEVF_DISABLED, &adapter->state))
+	if (disable_dev)
 		pci_disable_device(pdev);
 }
 
-- 
1.9.3
