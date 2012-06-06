From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] e1000e: test for valid check_reset_block function pointer
Date: Tue,  5 Jun 2012 21:08:53 -0700
Message-ID: <1338955735-8967-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1338955735-8967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49278 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753318Ab2FFEI7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 00:08:59 -0400
In-Reply-To: <1338955735-8967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

commit 44abd5c12767a8c567dc4e45fd9aec3b13ca85e0 introduced NULL pointer
dereferences when attempting to access the check_reset_block function
pointer on 8257x and 80003es2lan non-copper devices.

This fix should be applied back through 3.4.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c |    6 ++++--
 drivers/net/ethernet/intel/e1000e/mac.c     |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c  |    4 ++--
 drivers/net/ethernet/intel/e1000e/phy.c     |    8 +++++---
 4 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index d863075..905e214 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -258,7 +258,8 @@ static int e1000_set_settings(struct net_device *netdev,
 	 * When SoL/IDER sessions are active, autoneg/speed/duplex
 	 * cannot be changed
 	 */
-	if (hw->phy.ops.check_reset_block(hw)) {
+	if (hw->phy.ops.check_reset_block &&
+	    hw->phy.ops.check_reset_block(hw)) {
 		e_err("Cannot change link characteristics when SoL/IDER is active.\n");
 		return -EINVAL;
 	}
@@ -1615,7 +1616,8 @@ static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 	 * PHY loopback cannot be performed if SoL/IDER
 	 * sessions are active
 	 */
-	if (hw->phy.ops.check_reset_block(hw)) {
+	if (hw->phy.ops.check_reset_block &&
+	    hw->phy.ops.check_reset_block(hw)) {
 		e_err("Cannot do PHY loopback test when SoL/IDER is active.\n");
 		*data = 0;
 		goto out;
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index 026e8b3..a134399 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -709,7 +709,7 @@ s32 e1000e_setup_link_generic(struct e1000_hw *hw)
 	 * In the case of the phy reset being blocked, we already have a link.
 	 * We do not need to set it up again.
 	 */
-	if (hw->phy.ops.check_reset_block(hw))
+	if (hw->phy.ops.check_reset_block && hw->phy.ops.check_reset_block(hw))
 		return 0;
 
 	/*
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a4b0435..31d37a2 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6237,7 +6237,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		adapter->hw.phy.ms_type = e1000_ms_hw_default;
 	}
 
-	if (hw->phy.ops.check_reset_block(hw))
+	if (hw->phy.ops.check_reset_block && hw->phy.ops.check_reset_block(hw))
 		e_info("PHY reset is blocked due to SOL/IDER session.\n");
 
 	/* Set initial default active device features */
@@ -6404,7 +6404,7 @@ err_register:
 	if (!(adapter->flags & FLAG_HAS_AMT))
 		e1000e_release_hw_control(adapter);
 err_eeprom:
-	if (!hw->phy.ops.check_reset_block(hw))
+	if (hw->phy.ops.check_reset_block && !hw->phy.ops.check_reset_block(hw))
 		e1000_phy_hw_reset(&adapter->hw);
 err_hw_init:
 	kfree(adapter->tx_ring);
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 0334d01..b860d4f 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -2155,9 +2155,11 @@ s32 e1000e_phy_hw_reset_generic(struct e1000_hw *hw)
 	s32 ret_val;
 	u32 ctrl;
 
-	ret_val = phy->ops.check_reset_block(hw);
-	if (ret_val)
-		return 0;
+	if (phy->ops.check_reset_block) {
+		ret_val = phy->ops.check_reset_block(hw);
+		if (ret_val)
+			return 0;
+	}
 
 	ret_val = phy->ops.acquire(hw);
 	if (ret_val)
-- 
1.7.10.2
