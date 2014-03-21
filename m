From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/16] ixgbevf: Additional adapter removal checks
Date: Fri, 21 Mar 2014 05:10:00 -0700
Message-ID: <1395403806-29302-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20076 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965506AbaCUMKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:14 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Additional checks are needed for a detected removal not to cause
problems. Some involve simply avoiding a lot of stuff that can't
do anything good, and also cases where the phony return value can
cause problems. In addition, down the adapter when the removal is
sensed.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 22 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 13 +++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index c769a8d..b2d0023 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -535,6 +535,10 @@ static bool reg_pattern_test(struct ixgbevf_adapter *adapter, u64 *data,
 {
 	u32 pat, val, before;
 
+	if (IXGBE_REMOVED(adapter->hw.hw_addr)) {
+		*data = 1;
+		return true;
+	}
 	for (pat = 0; pat < ARRAY_SIZE(register_test_patterns); pat++) {
 		before = ixgbe_read_reg(&adapter->hw, reg);
 		ixgbe_write_reg(&adapter->hw, reg,
@@ -559,6 +563,10 @@ static bool reg_set_and_check(struct ixgbevf_adapter *adapter, u64 *data,
 {
 	u32 val, before;
 
+	if (IXGBE_REMOVED(adapter->hw.hw_addr)) {
+		*data = 1;
+		return true;
+	}
 	before = ixgbe_read_reg(&adapter->hw, reg);
 	ixgbe_write_reg(&adapter->hw, reg, write & mask);
 	val = ixgbe_read_reg(&adapter->hw, reg);
@@ -578,6 +586,12 @@ static int ixgbevf_reg_test(struct ixgbevf_adapter *adapter, u64 *data)
 	const struct ixgbevf_reg_test *test;
 	u32 i;
 
+	if (IXGBE_REMOVED(adapter->hw.hw_addr)) {
+		dev_err(&adapter->pdev->dev,
+			"Adapter removed - register test blocked\n");
+		*data = 1;
+		return 1;
+	}
 	test = reg_test_vf;
 
 	/*
@@ -641,6 +655,14 @@ static void ixgbevf_diag_test(struct net_device *netdev,
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	bool if_running = netif_running(netdev);
 
+	if (IXGBE_REMOVED(adapter->hw.hw_addr)) {
+		dev_err(&adapter->pdev->dev,
+			"Adapter removed - test blocked\n");
+		data[0] = 1;
+		data[1] = 1;
+		eth_test->flags |= ETH_TEST_FL_FAILED;
+		return;
+	}
 	set_bit(__IXGBEVF_TESTING, &adapter->state);
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
 		/* Offline tests */
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 37c4ebe..a50e892 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -107,6 +107,7 @@ static void ixgbevf_remove_adapter(struct ixgbe_hw *hw)
 		return;
 	hw->hw_addr = NULL;
 	dev_err(&adapter->pdev->dev, "Adapter removed\n");
+	schedule_work(&adapter->watchdog_task);
 }
 
 static void ixgbevf_check_remove(struct ixgbe_hw *hw, u32 reg)
@@ -1301,6 +1302,8 @@ static void ixgbevf_disable_rx_queue(struct ixgbevf_adapter *adapter,
 	u32 rxdctl;
 	u8 reg_idx = ring->reg_idx;
 
+	if (IXGBE_REMOVED(hw->hw_addr))
+		return;
 	rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(reg_idx));
 	rxdctl &= ~IXGBE_RXDCTL_ENABLE;
 
@@ -1326,6 +1329,8 @@ static void ixgbevf_rx_desc_queue_enable(struct ixgbevf_adapter *adapter,
 	u32 rxdctl;
 	u8 reg_idx = ring->reg_idx;
 
+	if (IXGBE_REMOVED(hw->hw_addr))
+		return;
 	do {
 		usleep_range(1000, 2000);
 		rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(reg_idx));
@@ -2399,6 +2404,14 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 	bool link_up = adapter->link_up;
 	s32 need_reset;
 
+	if (IXGBE_REMOVED(hw->hw_addr)) {
+		if (!test_bit(__IXGBEVF_DOWN, &adapter->state)) {
+			rtnl_lock();
+			ixgbevf_down(adapter);
+			rtnl_unlock();
+		}
+		return;
+	}
 	ixgbevf_queue_reset_subtask(adapter);
 
 	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
-- 
1.8.3.1
