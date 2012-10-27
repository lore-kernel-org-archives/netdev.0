From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] ixgbe: clean up the condition for turning on/off the laser
Date: Fri, 26 Oct 2012 17:08:30 -0700
Message-ID: <1351296518-31174-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351296518-31174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27325 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934318Ab2J0AIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 20:08:43 -0400
In-Reply-To: <1351296518-31174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch simplifies the check for calling en/disable_tx_laser() function
pointer. The pointer is only set on parts that can use it.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 31 +++++++--------------------
 1 file changed, 8 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 97bab45..ceab142 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4087,11 +4087,8 @@ static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	else
 		ixgbe_configure_msi_and_legacy(adapter);
 
-	/* enable the optics for both mult-speed fiber and 82599 SFP+ fiber */
-	if (hw->mac.ops.enable_tx_laser &&
-	    ((hw->phy.multispeed_fiber) ||
-	     ((hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) &&
-	      (hw->mac.type == ixgbe_mac_82599EB))))
+	/* enable the optics for 82599 SFP+ fiber */
+	if (hw->mac.ops.enable_tx_laser)
 		hw->mac.ops.enable_tx_laser(hw);
 
 	clear_bit(__IXGBE_DOWN, &adapter->state);
@@ -4413,11 +4410,8 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbe_reset(adapter);
 
-	/* power down the optics for multispeed fiber and 82599 SFP+ fiber */
-	if (hw->mac.ops.disable_tx_laser &&
-	    ((hw->phy.multispeed_fiber) ||
-	     ((hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) &&
-	      (hw->mac.type == ixgbe_mac_82599EB))))
+	/* power down the optics for 82599 SFP+ fiber */
+	if (hw->mac.ops.disable_tx_laser)
 		hw->mac.ops.disable_tx_laser(hw);
 
 	ixgbe_clean_all_tx_rings(adapter);
@@ -5050,14 +5044,8 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	if (wufc) {
 		ixgbe_set_rx_mode(netdev);
 
-		/*
-		 * enable the optics for both mult-speed fiber and
-		 * 82599 SFP+ fiber as we can WoL.
-		 */
-		if (hw->mac.ops.enable_tx_laser &&
-		    (hw->phy.multispeed_fiber ||
-		    (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber &&
-		     hw->mac.type == ixgbe_mac_82599EB)))
+		/* enable the optics for 82599 SFP+ fiber as we can WoL */
+		if (hw->mac.ops.enable_tx_laser)
 			hw->mac.ops.enable_tx_laser(hw);
 
 		/* turn on all-multi mode if wake on multicast is enabled */
@@ -7468,11 +7456,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-	/* power down the optics for multispeed fiber and 82599 SFP+ fiber */
-	if (hw->mac.ops.disable_tx_laser &&
-	    ((hw->phy.multispeed_fiber) ||
-	     ((hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) &&
-	      (hw->mac.type == ixgbe_mac_82599EB))))
+	/* power down the optics for 82599 SFP+ fiber */
+	if (hw->mac.ops.disable_tx_laser)
 		hw->mac.ops.disable_tx_laser(hw);
 
 	/* carrier off reporting is important to ethtool even BEFORE open */
-- 
1.7.11.7
