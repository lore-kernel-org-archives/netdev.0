From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 05/10] ixgbe: fix disabling of Tx laser at probe
Date: Wed,  2 Nov 2011 17:19:56 -0700
Message-ID: <1320279601-1276-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37902 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754479Ab1KCAUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 20:20:07 -0400
In-Reply-To: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

register_netdev() calls ndo_set_features() which may result in HW reset
which in turn will bring the laser back up.

This patch moves ixgbe_laser_tx_disable() below register_netdev()
in ixgbe_probe() to make sure laser is shut off on load.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b7abf43..2e9fd9d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7588,13 +7588,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_eeprom;
 	}
 
-	/* power down the optics for multispeed fiber and 82599 SFP+ fiber */
-	if (hw->mac.ops.disable_tx_laser &&
-	    ((hw->phy.multispeed_fiber) ||
-	     ((hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) &&
-	      (hw->mac.type == ixgbe_mac_82599EB))))
-		hw->mac.ops.disable_tx_laser(hw);
-
 	setup_timer(&adapter->service_timer, &ixgbe_service_timer,
 	            (unsigned long) adapter);
 
@@ -7692,6 +7685,13 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
+	/* power down the optics for multispeed fiber and 82599 SFP+ fiber */
+	if (hw->mac.ops.disable_tx_laser &&
+	    ((hw->phy.multispeed_fiber) ||
+	     ((hw->mac.ops.get_media_type(hw) == ixgbe_media_type_fiber) &&
+	      (hw->mac.type == ixgbe_mac_82599EB))))
+		hw->mac.ops.disable_tx_laser(hw);
+
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
-- 
1.7.6.4
