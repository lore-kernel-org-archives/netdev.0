From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] ixgbe: ethtool ixgbe_diag_test cleanup
Date: Wed, 23 Jan 2013 14:44:37 -0800
Message-ID: <1358981090-5794-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52933 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752391Ab3AWWpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 17:45:17 -0500
In-Reply-To: <1358981090-5794-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch cleans up the ethtool diagnostics test by ensuring that the tests
work properly regardless of what state the adapter was in. The SRIOV VF check is
done at the beginning, forgoing the link test. The if_running -> dev_close is
moved before the link test, as well as a call to enable the Tx laser. This
ensures that the link test will return valid results even when adapter was
previously down. Also, a call to disable the Tx laser is added if the device
was down before the start. This ensures consistent behavior of the Tx laser
before and after the diagnostic checks. The end result is consistent behavior
regardless of device state.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 38 ++++++++++++++++--------
 1 file changed, 26 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 3268584..21bc72e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1837,19 +1837,11 @@ static void ixgbe_diag_test(struct net_device *netdev,
                             struct ethtool_test *eth_test, u64 *data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 	bool if_running = netif_running(netdev);
 
 	set_bit(__IXGBE_TESTING, &adapter->state);
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
-		/* Offline tests */
-
-		e_info(hw, "offline testing starting\n");
-
-		/* Link test performed before hardware reset so autoneg doesn't
-		 * interfere with test result */
-		if (ixgbe_link_test(adapter, &data[4]))
-			eth_test->flags |= ETH_TEST_FL_FAILED;
-
 		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
 			int i;
 			for (i = 0; i < adapter->num_vfs; i++) {
@@ -1870,12 +1862,24 @@ static void ixgbe_diag_test(struct net_device *netdev,
 			}
 		}
 
+		/* Offline tests */
+		e_info(hw, "offline testing starting\n");
+
 		if (if_running)
 			/* indicate we're in test mode */
 			dev_close(netdev);
-		else
-			ixgbe_reset(adapter);
 
+		/* bringing adapter down disables SFP+ optics */
+		if (hw->mac.ops.enable_tx_laser)
+			hw->mac.ops.enable_tx_laser(hw);
+
+		/* Link test performed before hardware reset so autoneg doesn't
+		 * interfere with test result
+		 */
+		if (ixgbe_link_test(adapter, &data[4]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		ixgbe_reset(adapter);
 		e_info(hw, "register testing starting\n");
 		if (ixgbe_reg_test(adapter, &data[0]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1908,16 +1912,22 @@ static void ixgbe_diag_test(struct net_device *netdev,
 skip_loopback:
 		ixgbe_reset(adapter);
 
+		/* clear testing bit and return adapter to previous state */
 		clear_bit(__IXGBE_TESTING, &adapter->state);
 		if (if_running)
 			dev_open(netdev);
 	} else {
 		e_info(hw, "online testing starting\n");
+
+		/* if adapter is down, SFP+ optics will be disabled */
+		if (!if_running && hw->mac.ops.enable_tx_laser)
+			hw->mac.ops.enable_tx_laser(hw);
+
 		/* Online tests */
 		if (ixgbe_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		/* Online tests aren't run; pass by default */
+		/* Offline tests aren't run; pass by default */
 		data[0] = 0;
 		data[1] = 0;
 		data[2] = 0;
@@ -1925,6 +1935,10 @@ skip_loopback:
 
 		clear_bit(__IXGBE_TESTING, &adapter->state);
 	}
+
+	/* if adapter was down, ensure SFP+ optics are disabled again */
+	if (!if_running && hw->mac.ops.disable_tx_laser)
+		hw->mac.ops.disable_tx_laser(hw);
 skip_ol_tests:
 	msleep_interruptible(4 * 1000);
 }
-- 
1.7.11.7
