From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] ixgbe: set device if before calling get_invariants
Date: Sat,  5 Nov 2016 00:54:16 -0700
Message-ID: <1478332461-43147-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:25789 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753873AbcKEHy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 5 Nov 2016 03:54:27 -0400
In-Reply-To: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Fix an issue where set_phy_power was NULL for X550 copper devices
because get_invariants was called before hw->device_id was set.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9a62b55..a582bea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5624,7 +5624,8 @@ static void ixgbe_init_dcb(struct ixgbe_adapter *adapter)
  * Fields are initialized based on PCI device information and
  * OS network device settings (MTU size).
  **/
-static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
+static int ixgbe_sw_init(struct ixgbe_adapter *adapter,
+			 const struct ixgbe_info *ii)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
@@ -5640,6 +5641,9 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	hw->subsystem_vendor_id = pdev->subsystem_vendor;
 	hw->subsystem_device_id = pdev->subsystem_device;
 
+	/* get_invariants needs the device IDs */
+	ii->get_invariants(hw);
+
 	/* Set common capability flags and settings */
 	rss = min_t(int, ixgbe_max_rss_indices(adapter), num_online_cpus());
 	adapter->ring_feature[RING_F_RSS].limit = rss;
@@ -9532,10 +9536,8 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw->phy.mdio.mdio_read = ixgbe_mdio_read;
 	hw->phy.mdio.mdio_write = ixgbe_mdio_write;
 
-	ii->get_invariants(hw);
-
 	/* setup the private structure */
-	err = ixgbe_sw_init(adapter);
+	err = ixgbe_sw_init(adapter, ii);
 	if (err)
 		goto err_sw_init;
 
-- 
2.7.4
