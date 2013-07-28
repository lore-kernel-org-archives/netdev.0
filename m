From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/12] e1000e: do not resume device from RPM suspend to read PHY status registers
Date: Sun, 28 Jul 2013 04:41:15 -0700
Message-ID: <1375011676-30739-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50676 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512Ab3G1Llc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 07:41:32 -0400
In-Reply-To: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When the device is runtime suspended (e.g. when there is no link), do not
wake it from D3 to read the PHY status; just set the values to typical
power-on defaults as is done when runtime PM is not enabled and there is no
link.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 650e569..e6d2c0f 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4684,11 +4684,11 @@ static void e1000_phy_read_status(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_phy_regs *phy = &adapter->phy_regs;
 
-	if ((er32(STATUS) & E1000_STATUS_LU) &&
+	if (!pm_runtime_suspended((&adapter->pdev->dev)->parent) &&
+	    (er32(STATUS) & E1000_STATUS_LU) &&
 	    (adapter->hw.phy.media_type == e1000_media_type_copper)) {
 		int ret_val;
 
-		pm_runtime_get_sync(&adapter->pdev->dev);
 		ret_val = e1e_rphy(hw, MII_BMCR, &phy->bmcr);
 		ret_val |= e1e_rphy(hw, MII_BMSR, &phy->bmsr);
 		ret_val |= e1e_rphy(hw, MII_ADVERTISE, &phy->advertise);
@@ -4699,7 +4699,6 @@ static void e1000_phy_read_status(struct e1000_adapter *adapter)
 		ret_val |= e1e_rphy(hw, MII_ESTATUS, &phy->estatus);
 		if (ret_val)
 			e_warn("Error reading PHY register\n");
-		pm_runtime_put_sync(&adapter->pdev->dev);
 	} else {
 		/* Do not read PHY registers if link is not up
 		 * Set values to typical power-on defaults
-- 
1.7.11.7
