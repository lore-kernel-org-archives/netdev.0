From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  04/10] ixgbe: fix link test when connected to 1Gbps link partner
Date: Wed, 28 Aug 2013 03:33:42 -0700
Message-ID: <1377686028-30747-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34607 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762Ab3H1Kdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 06:33:55 -0400
In-Reply-To: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch is a partial reverse of:
commit dfcc4615f09c33454bc553567f7c7506cae60cb9

Specifically forcing the laser before the link check can lead to
inconsistent results because it does not guarantee that the link will be
negotiated correctly. Such is the case when dual speed SFP+ module is
connected to a gigabit link partner.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 26 ++++++++----------------
 1 file changed, 9 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index db0dbf6..57465d8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1885,11 +1885,11 @@ static void ixgbe_diag_test(struct net_device *netdev,
                             struct ethtool_test *eth_test, u64 *data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
 	bool if_running = netif_running(netdev);
 
 	set_bit(__IXGBE_TESTING, &adapter->state);
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
+		struct ixgbe_hw *hw = &adapter->hw;
 		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
 			int i;
 			for (i = 0; i < adapter->num_vfs; i++) {
@@ -1913,21 +1913,18 @@ static void ixgbe_diag_test(struct net_device *netdev,
 		/* Offline tests */
 		e_info(hw, "offline testing starting\n");
 
-		if (if_running)
-			/* indicate we're in test mode */
-			dev_close(netdev);
-
-		/* bringing adapter down disables SFP+ optics */
-		if (hw->mac.ops.enable_tx_laser)
-			hw->mac.ops.enable_tx_laser(hw);
-
 		/* Link test performed before hardware reset so autoneg doesn't
 		 * interfere with test result
 		 */
 		if (ixgbe_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		ixgbe_reset(adapter);
+		if (if_running)
+			/* indicate we're in test mode */
+			dev_close(netdev);
+		else
+			ixgbe_reset(adapter);
+
 		e_info(hw, "register testing starting\n");
 		if (ixgbe_reg_test(adapter, &data[0]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1964,13 +1961,11 @@ skip_loopback:
 		clear_bit(__IXGBE_TESTING, &adapter->state);
 		if (if_running)
 			dev_open(netdev);
+		else if (hw->mac.ops.disable_tx_laser)
+			hw->mac.ops.disable_tx_laser(hw);
 	} else {
 		e_info(hw, "online testing starting\n");
 
-		/* if adapter is down, SFP+ optics will be disabled */
-		if (!if_running && hw->mac.ops.enable_tx_laser)
-			hw->mac.ops.enable_tx_laser(hw);
-
 		/* Online tests */
 		if (ixgbe_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1984,9 +1979,6 @@ skip_loopback:
 		clear_bit(__IXGBE_TESTING, &adapter->state);
 	}
 
-	/* if adapter was down, ensure SFP+ optics are disabled again */
-	if (!if_running && hw->mac.ops.disable_tx_laser)
-		hw->mac.ops.disable_tx_laser(hw);
 skip_ol_tests:
 	msleep_interruptible(4 * 1000);
 }
-- 
1.8.3.1
