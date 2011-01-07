From: jeffrey.t.kirsher@intel.com
Subject: [net-next 05/12] e1000e: power off PHY after reset when interface is down
Date: Thu,  6 Jan 2011 16:29:52 -0800
Message-ID: <1294360199-9860-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gosp@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:33065 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753939Ab1AGAat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:30:49 -0500
To: davem@davemloft.net
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Some Phys supported by the driver do not remain powered off across a reset
of the device when the interface is down, e.g. on 82571, but not on 82574.
This patch powers down (only when WoL is disabled) the PHY after a reset if
the interface is down and the ethtool diagnostics are not currently running.

The ethtool diagnostic function required a minor re-factor as a result, and
the e1000_[get|put]_hw_control() functions are renamed since they are no
longer static to netdev.c as they are needed by the ethtool diagnostics.
A couple minor whitespace issues were cleaned up, too.

Reported-by: Arthur Jones <ajones@riverbed.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/e1000.h   |    2 +
 drivers/net/e1000e/ethtool.c |   40 ++++++++++++++++++++++-------------
 drivers/net/e1000e/netdev.c  |   46 +++++++++++++++++++++++------------------
 3 files changed, 53 insertions(+), 35 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 4b3802a..5255be7 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -497,6 +497,8 @@ extern void e1000e_free_tx_resources(struct e1000_adapter *adapter);
 extern void e1000e_update_stats(struct e1000_adapter *adapter);
 extern void e1000e_set_interrupt_capability(struct e1000_adapter *adapter);
 extern void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter);
+extern void e1000e_get_hw_control(struct e1000_adapter *adapter);
+extern void e1000e_release_hw_control(struct e1000_adapter *adapter);
 extern void e1000e_disable_aspm(struct pci_dev *pdev, u16 state);
 
 extern unsigned int copybreak;
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index c942cca..f8ed03d 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1708,6 +1708,19 @@ static void e1000_diag_test(struct net_device *netdev,
 	bool if_running = netif_running(netdev);
 
 	set_bit(__E1000_TESTING, &adapter->state);
+
+	if (!if_running) {
+		/* Get control of and reset hardware */
+		if (adapter->flags & FLAG_HAS_AMT)
+			e1000e_get_hw_control(adapter);
+
+		e1000e_power_up_phy(adapter);
+
+		adapter->hw.phy.autoneg_wait_to_complete = 1;
+		e1000e_reset(adapter);
+		adapter->hw.phy.autoneg_wait_to_complete = 0;
+	}
+
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
 		/* Offline tests */
 
@@ -1721,8 +1734,6 @@ static void e1000_diag_test(struct net_device *netdev,
 		if (if_running)
 			/* indicate we're in test mode */
 			dev_close(netdev);
-		else
-			e1000e_reset(adapter);
 
 		if (e1000_reg_test(adapter, &data[0]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1736,8 +1747,6 @@ static void e1000_diag_test(struct net_device *netdev,
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		e1000e_reset(adapter);
-		/* make sure the phy is powered up */
-		e1000e_power_up_phy(adapter);
 		if (e1000_loopback_test(adapter, &data[3]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
@@ -1759,28 +1768,29 @@ static void e1000_diag_test(struct net_device *netdev,
 		if (if_running)
 			dev_open(netdev);
 	} else {
-		if (!if_running && (adapter->flags & FLAG_HAS_AMT)) {
-			clear_bit(__E1000_TESTING, &adapter->state);
-			dev_open(netdev);
-			set_bit(__E1000_TESTING, &adapter->state);
-		}
+		/* Online tests */
 
 		e_info("online testing starting\n");
-		/* Online tests */
-		if (e1000_link_test(adapter, &data[4]))
-			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		/* Online tests aren't run; pass by default */
+		/* register, eeprom, intr and loopback tests not run online */
 		data[0] = 0;
 		data[1] = 0;
 		data[2] = 0;
 		data[3] = 0;
 
-		if (!if_running && (adapter->flags & FLAG_HAS_AMT))
-			dev_close(netdev);
+		if (e1000_link_test(adapter, &data[4]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		clear_bit(__E1000_TESTING, &adapter->state);
 	}
+
+	if (!if_running) {
+		e1000e_reset(adapter);
+
+		if (adapter->flags & FLAG_HAS_AMT)
+			e1000e_release_hw_control(adapter);
+	}
+
 	msleep_interruptible(4 * 1000);
 }
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 98729a6..fa5b604 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1980,15 +1980,15 @@ static void e1000_irq_enable(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000_get_hw_control - get control of the h/w from f/w
+ * e1000e_get_hw_control - get control of the h/w from f/w
  * @adapter: address of board private structure
  *
- * e1000_get_hw_control sets {CTRL_EXT|SWSM}:DRV_LOAD bit.
+ * e1000e_get_hw_control sets {CTRL_EXT|SWSM}:DRV_LOAD bit.
  * For ASF and Pass Through versions of f/w this means that
  * the driver is loaded. For AMT version (only with 82573)
  * of the f/w this means that the network i/f is open.
  **/
-static void e1000_get_hw_control(struct e1000_adapter *adapter)
+void e1000e_get_hw_control(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl_ext;
@@ -2005,16 +2005,16 @@ static void e1000_get_hw_control(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000_release_hw_control - release control of the h/w to f/w
+ * e1000e_release_hw_control - release control of the h/w to f/w
  * @adapter: address of board private structure
  *
- * e1000_release_hw_control resets {CTRL_EXT|SWSM}:DRV_LOAD bit.
+ * e1000e_release_hw_control resets {CTRL_EXT|SWSM}:DRV_LOAD bit.
  * For ASF and Pass Through versions of f/w this means that the
  * driver is no longer loaded. For AMT version (only with 82573) i
  * of the f/w this means that the network i/f is closed.
  *
  **/
-static void e1000_release_hw_control(struct e1000_adapter *adapter)
+void e1000e_release_hw_control(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl_ext;
@@ -2445,7 +2445,7 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
 	    (vid == adapter->mng_vlan_id)) {
 		/* release control to f/w */
-		e1000_release_hw_control(adapter);
+		e1000e_release_hw_control(adapter);
 		return;
 	}
 
@@ -3187,7 +3187,6 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		ew32(PBA, pba);
 	}
 
-
 	/*
 	 * flow control settings
 	 *
@@ -3275,7 +3274,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	 * that the network interface is in control
 	 */
 	if (adapter->flags & FLAG_HAS_AMT)
-		e1000_get_hw_control(adapter);
+		e1000e_get_hw_control(adapter);
 
 	ew32(WUC, 0);
 
@@ -3288,6 +3287,13 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	ew32(VET, ETH_P_8021Q);
 
 	e1000e_reset_adaptive(hw);
+
+	if (!netif_running(adapter->netdev) &&
+	    !test_bit(__E1000_TESTING, &adapter->state)) {
+		e1000_power_down_phy(adapter);
+		return;
+	}
+
 	e1000_get_phy_info(hw);
 
 	if ((adapter->flags & FLAG_HAS_SMART_POWER_DOWN) &&
@@ -3573,7 +3579,7 @@ static int e1000_open(struct net_device *netdev)
 	 * interface is now open and reset the part to a known state.
 	 */
 	if (adapter->flags & FLAG_HAS_AMT) {
-		e1000_get_hw_control(adapter);
+		e1000e_get_hw_control(adapter);
 		e1000e_reset(adapter);
 	}
 
@@ -3637,7 +3643,7 @@ static int e1000_open(struct net_device *netdev)
 	return 0;
 
 err_req_irq:
-	e1000_release_hw_control(adapter);
+	e1000e_release_hw_control(adapter);
 	e1000_power_down_phy(adapter);
 	e1000e_free_rx_resources(adapter);
 err_setup_rx:
@@ -3692,8 +3698,9 @@ static int e1000_close(struct net_device *netdev)
 	 * If AMT is enabled, let the firmware know that the network
 	 * interface is now closed
 	 */
-	if (adapter->flags & FLAG_HAS_AMT)
-		e1000_release_hw_control(adapter);
+	if ((adapter->flags & FLAG_HAS_AMT) &&
+	    !test_bit(__E1000_TESTING, &adapter->state))
+		e1000e_release_hw_control(adapter);
 
 	if ((adapter->flags & FLAG_HAS_ERT) ||
 	    (adapter->hw.mac.type == e1000_pch2lan))
@@ -5212,7 +5219,7 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake,
 	 * Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant.
 	 */
-	e1000_release_hw_control(adapter);
+	e1000e_release_hw_control(adapter);
 
 	pci_disable_device(pdev);
 
@@ -5369,7 +5376,7 @@ static int __e1000_resume(struct pci_dev *pdev)
 	 * under the control of the driver.
 	 */
 	if (!(adapter->flags & FLAG_HAS_AMT))
-		e1000_get_hw_control(adapter);
+		e1000e_get_hw_control(adapter);
 
 	return 0;
 }
@@ -5616,7 +5623,7 @@ static void e1000_io_resume(struct pci_dev *pdev)
 	 * under the control of the driver.
 	 */
 	if (!(adapter->flags & FLAG_HAS_AMT))
-		e1000_get_hw_control(adapter);
+		e1000e_get_hw_control(adapter);
 
 }
 
@@ -5966,7 +5973,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	 * under the control of the driver.
 	 */
 	if (!(adapter->flags & FLAG_HAS_AMT))
-		e1000_get_hw_control(adapter);
+		e1000e_get_hw_control(adapter);
 
 	strncpy(netdev->name, "eth%d", sizeof(netdev->name) - 1);
 	err = register_netdev(netdev);
@@ -5985,12 +5992,11 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 err_register:
 	if (!(adapter->flags & FLAG_HAS_AMT))
-		e1000_release_hw_control(adapter);
+		e1000e_release_hw_control(adapter);
 err_eeprom:
 	if (!e1000_check_reset_block(&adapter->hw))
 		e1000_phy_hw_reset(&adapter->hw);
 err_hw_init:
-
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 err_sw_init:
@@ -6056,7 +6062,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	 * Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant.
 	 */
-	e1000_release_hw_control(adapter);
+	e1000e_release_hw_control(adapter);
 
 	e1000e_reset_interrupt_capability(adapter);
 	kfree(adapter->tx_ring);
-- 
1.7.3.4

