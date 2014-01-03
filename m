From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/11] ixgbe: Additional adapter removal checks
Date: Thu,  2 Jan 2014 21:18:26 -0800
Message-ID: <1388726310-2996-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48918 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbaACFSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 00:18:38 -0500
In-Reply-To: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Additional checks are needed for a detected removal not to cause
problems. Some involve simply avoiding a lot of stuff that can't
do anything good, and also cases where the phony return value can
cause problems. In addition, down the adapter when the removal is
sensed.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 22 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 16 ++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 412cb1a..0899b1d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1342,6 +1342,10 @@ static bool reg_pattern_test(struct ixgbe_adapter *adapter, u64 *data, int reg,
 	static const u32 test_pattern[] = {
 		0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
 
+	if (IXGBE_REMOVED(adapter->hw.hw_addr)) {
+		*data = 1;
+		return 1;
+	}
 	for (pat = 0; pat < ARRAY_SIZE(test_pattern); pat++) {
 		before = IXGBE_READ_REG(&adapter->hw, reg);
 		IXGBE_WRITE_REG(&adapter->hw, reg, test_pattern[pat] & write);
@@ -1364,6 +1368,10 @@ static bool reg_set_and_check(struct ixgbe_adapter *adapter, u64 *data, int reg,
 {
 	u32 val, before;
 
+	if (IXGBE_REMOVED(adapter->hw.hw_addr)) {
+		*data = 1;
+		return 1;
+	}
 	before = IXGBE_READ_REG(&adapter->hw, reg);
 	IXGBE_WRITE_REG(&adapter->hw, reg, write & mask);
 	val = IXGBE_READ_REG(&adapter->hw, reg);
@@ -1384,6 +1392,11 @@ static int ixgbe_reg_test(struct ixgbe_adapter *adapter, u64 *data)
 	u32 value, before, after;
 	u32 i, toggle;
 
+	if (IXGBE_REMOVED(adapter->hw.hw_addr)) {
+		e_err(drv, "Adapter removed - register test blocked\n");
+		*data = 1;
+		return 1;
+	}
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82598EB:
 		toggle = 0x7FFFF3FF;
@@ -1950,6 +1963,15 @@ static void ixgbe_diag_test(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	bool if_running = netif_running(netdev);
 
+	if (IXGBE_REMOVED(adapter->hw.hw_addr)) {
+		e_err(hw, "Adapter removed - test blocked\n");
+		data[0] = 1;
+		data[1] = 1;
+		data[2] = 1;
+		data[3] = 1;
+		eth_test->flags |= ETH_TEST_FL_FAILED;
+		return;
+	}
 	set_bit(__IXGBE_TESTING, &adapter->state);
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
 		struct ixgbe_hw *hw = &adapter->hw;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 22e51d1..4801390 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -292,6 +292,7 @@ static void ixgbe_remove_adapter(struct ixgbe_hw *hw)
 		return;
 	hw->hw_addr = NULL;
 	e_dev_err("Adapter removed\n");
+	ixgbe_service_event_schedule(adapter);
 }
 
 void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg)
@@ -3343,6 +3344,8 @@ static void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
 	u32 rxdctl;
 	u8 reg_idx = ring->reg_idx;
 
+	if (IXGBE_REMOVED(hw->hw_addr))
+		return;
 	/* RXDCTL.EN will return 0 on 82598 if link is down, so skip it */
 	if (hw->mac.type == ixgbe_mac_82598EB &&
 	    !(IXGBE_READ_REG(hw, IXGBE_LINKS) & IXGBE_LINKS_UP))
@@ -3367,6 +3370,8 @@ void ixgbe_disable_rx_queue(struct ixgbe_adapter *adapter,
 	u32 rxdctl;
 	u8 reg_idx = ring->reg_idx;
 
+	if (IXGBE_REMOVED(hw->hw_addr))
+		return;
 	rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(reg_idx));
 	rxdctl &= ~IXGBE_RXDCTL_ENABLE;
 
@@ -4695,6 +4700,8 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	int err;
 
+	if (IXGBE_REMOVED(hw->hw_addr))
+		return;
 	/* lock SFP init bit to prevent race conditions with the watchdog */
 	while (test_and_set_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
 		usleep_range(1000, 2000);
@@ -6405,6 +6412,15 @@ static void ixgbe_service_task(struct work_struct *work)
 	struct ixgbe_adapter *adapter = container_of(work,
 						     struct ixgbe_adapter,
 						     service_task);
+	if (IXGBE_REMOVED(adapter->hw.hw_addr)) {
+		if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+			rtnl_lock();
+			ixgbe_down(adapter);
+			rtnl_unlock();
+		}
+		ixgbe_service_event_complete(adapter);
+		return;
+	}
 	ixgbe_reset_subtask(adapter);
 	ixgbe_sfp_detection_subtask(adapter);
 	ixgbe_sfp_link_config_subtask(adapter);
-- 
1.8.3.1
