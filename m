From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 05/24] e1000e: convert short duration msleep() to usleep_range()
Date: Wed, 13 Apr 2011 18:02:01 -0700
Message-ID: <1302742940-22141-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21314 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892Ab1DNBC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:29 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

With durations less than 20ms, the jiffies or legacy timer backed msleep()
may sleep ~20ms which might not be what the caller expects.  Instead, it
is recommended to use the hrtimers backed usleep_range().  For more, see
Documentation/timers/timers-howto.txt.  Issues reported by checkpatch.

In addition, remove unnecessary sleep in e1000e_write_nvm_spi().

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/82571.c   |   10 +++++-----
 drivers/net/e1000e/es2lan.c  |    4 ++--
 drivers/net/e1000e/ethtool.c |   20 ++++++++++----------
 drivers/net/e1000e/ich8lan.c |   12 ++++++------
 drivers/net/e1000e/lib.c     |   10 ++++------
 drivers/net/e1000e/netdev.c  |    8 ++++----
 drivers/net/e1000e/phy.c     |    4 ++--
 7 files changed, 33 insertions(+), 35 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 89a6903..9fedbca 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -594,7 +594,7 @@ static s32 e1000_get_hw_semaphore_82573(struct e1000_hw *hw)
 
 		extcnf_ctrl |= E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
 
-		msleep(2);
+		usleep_range(2000, 4000);
 		i++;
 	} while (i < MDIO_OWNERSHIP_TIMEOUT);
 
@@ -816,7 +816,7 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 
 	/* Check for pending operations. */
 	for (i = 0; i < E1000_FLASH_UPDATES; i++) {
-		msleep(1);
+		usleep_range(1000, 2000);
 		if ((er32(EECD) & E1000_EECD_FLUPD) == 0)
 			break;
 	}
@@ -840,7 +840,7 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 	ew32(EECD, eecd);
 
 	for (i = 0; i < E1000_FLASH_UPDATES; i++) {
-		msleep(1);
+		usleep_range(1000, 2000);
 		if ((er32(EECD) & E1000_EECD_FLUPD) == 0)
 			break;
 	}
@@ -930,7 +930,7 @@ static s32 e1000_get_cfg_done_82571(struct e1000_hw *hw)
 		if (er32(EEMNGCTL) &
 		    E1000_NVM_CFG_DONE_PORT_0)
 			break;
-		msleep(1);
+		usleep_range(1000, 2000);
 		timeout--;
 	}
 	if (!timeout) {
@@ -1037,7 +1037,7 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	ew32(TCTL, E1000_TCTL_PSP);
 	e1e_flush();
 
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	/*
 	 * Must acquire the MDIO ownership before MAC reset.
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 2fefa82..0279695 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -612,7 +612,7 @@ static s32 e1000_get_cfg_done_80003es2lan(struct e1000_hw *hw)
 	while (timeout) {
 		if (er32(EEMNGCTL) & mask)
 			break;
-		msleep(1);
+		usleep_range(1000, 2000);
 		timeout--;
 	}
 	if (!timeout) {
@@ -802,7 +802,7 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 	ew32(TCTL, E1000_TCTL_PSP);
 	e1e_flush();
 
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	ctrl = er32(CTRL);
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 07f09e9..5b4cf90 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -253,7 +253,7 @@ static int e1000_set_settings(struct net_device *netdev,
 	}
 
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
-		msleep(1);
+		usleep_range(1000, 2000);
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		hw->mac.autoneg = 1;
@@ -317,7 +317,7 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 	adapter->fc_autoneg = pause->autoneg;
 
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
-		msleep(1);
+		usleep_range(1000, 2000);
 
 	if (adapter->fc_autoneg == AUTONEG_ENABLE) {
 		hw->fc.requested_mode = e1000_fc_default;
@@ -673,7 +673,7 @@ static int e1000_set_ringparam(struct net_device *netdev,
 		return -EINVAL;
 
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
-		msleep(1);
+		usleep_range(1000, 2000);
 
 	if (netif_running(adapter->netdev))
 		e1000e_down(adapter);
@@ -952,7 +952,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	/* Test each interrupt */
 	for (i = 0; i < 10; i++) {
@@ -984,7 +984,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			adapter->test_icr = 0;
 			ew32(IMC, mask);
 			ew32(ICS, mask);
-			msleep(10);
+			usleep_range(10000, 20000);
 
 			if (adapter->test_icr & mask) {
 				*data = 3;
@@ -1002,7 +1002,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		adapter->test_icr = 0;
 		ew32(IMS, mask);
 		ew32(ICS, mask);
-		msleep(10);
+		usleep_range(10000, 20000);
 
 		if (!(adapter->test_icr & mask)) {
 			*data = 4;
@@ -1020,7 +1020,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			adapter->test_icr = 0;
 			ew32(IMC, ~mask & 0x00007FFF);
 			ew32(ICS, ~mask & 0x00007FFF);
-			msleep(10);
+			usleep_range(10000, 20000);
 
 			if (adapter->test_icr) {
 				*data = 5;
@@ -1031,7 +1031,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	/* Unhook test interrupt handler */
 	free_irq(irq, netdev);
@@ -1406,7 +1406,7 @@ static int e1000_set_82571_fiber_loopback(struct e1000_adapter *adapter)
 	 */
 #define E1000_SERDES_LB_ON 0x410
 	ew32(SCTL, E1000_SERDES_LB_ON);
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	return 0;
 }
@@ -1501,7 +1501,7 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 		    hw->phy.media_type == e1000_media_type_internal_serdes) {
 #define E1000_SERDES_LB_OFF 0x400
 			ew32(SCTL, E1000_SERDES_LB_OFF);
-			msleep(10);
+			usleep_range(10000, 20000);
 			break;
 		}
 		/* Fall Through */
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index ce1dbfd..06ff884 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -338,7 +338,7 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	/* Ungate automatic PHY configuration on non-managed 82579 */
 	if ((hw->mac.type == e1000_pch2lan) &&
 	    !(fwsm & E1000_ICH_FWSM_FW_VALID)) {
-		msleep(10);
+		usleep_range(10000, 20000);
 		e1000_gate_hw_phy_config_ich8lan(hw, false);
 	}
 
@@ -427,7 +427,7 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 	phy->id = 0;
 	while ((e1000_phy_unknown == e1000e_get_phy_type_from_id(phy->id)) &&
 	       (i++ < 100)) {
-		msleep(1);
+		usleep_range(1000, 2000);
 		ret_val = e1000e_get_phy_id(hw);
 		if (ret_val)
 			return ret_val;
@@ -1704,7 +1704,7 @@ static s32 e1000_post_phy_reset_ich8lan(struct e1000_hw *hw)
 		goto out;
 
 	/* Allow time for h/w to get to quiescent state after reset */
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	/* Perform any necessary post-reset workarounds */
 	switch (hw->mac.type) {
@@ -1737,7 +1737,7 @@ static s32 e1000_post_phy_reset_ich8lan(struct e1000_hw *hw)
 	if (hw->mac.type == e1000_pch2lan) {
 		/* Ungate automatic PHY configuration on non-managed 82579 */
 		if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
-			msleep(10);
+			usleep_range(10000, 20000);
 			e1000_gate_hw_phy_config_ich8lan(hw, false);
 		}
 
@@ -2532,7 +2532,7 @@ release:
 	 */
 	if (!ret_val) {
 		e1000e_reload_nvm(hw);
-		msleep(10);
+		usleep_range(10000, 20000);
 	}
 
 out:
@@ -3009,7 +3009,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	ew32(TCTL, E1000_TCTL_PSP);
 	e1e_flush();
 
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	/* Workaround for ICH8 bit corruption issue in FIFO memory */
 	if (hw->mac.type == e1000_ich8lan) {
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 96921de..30ef8fa 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -868,7 +868,7 @@ static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
 	 * milliseconds even if the other end is doing it in SW).
 	 */
 	for (i = 0; i < FIBER_LINK_UP_LIMIT; i++) {
-		msleep(10);
+		usleep_range(10000, 20000);
 		status = er32(STATUS);
 		if (status & E1000_STATUS_LU)
 			break;
@@ -930,7 +930,7 @@ s32 e1000e_setup_fiber_serdes_link(struct e1000_hw *hw)
 
 	ew32(CTRL, ctrl);
 	e1e_flush();
-	msleep(1);
+	usleep_range(1000, 2000);
 
 	/*
 	 * For these adapters, the SW definable pin 1 is set when the optics
@@ -1385,7 +1385,7 @@ s32 e1000e_get_auto_rd_done(struct e1000_hw *hw)
 	while (i < AUTO_READ_DONE_TIMEOUT) {
 		if (er32(EECD) & E1000_EECD_AUTO_RD)
 			break;
-		msleep(1);
+		usleep_range(1000, 2000);
 		i++;
 	}
 
@@ -2087,8 +2087,6 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	if (ret_val)
 		return ret_val;
 
-	msleep(10);
-
 	while (widx < words) {
 		u8 write_opcode = NVM_WRITE_OPCODE_SPI;
 
@@ -2132,7 +2130,7 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		}
 	}
 
-	msleep(10);
+	usleep_range(10000, 20000);
 	nvm->ops.release(hw);
 	return 0;
 }
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 506a0a0..909c8de 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2902,7 +2902,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	rctl = er32(RCTL);
 	ew32(RCTL, rctl & ~E1000_RCTL_EN);
 	e1e_flush();
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	if (adapter->flags2 & FLAG2_DMA_BURST) {
 		/*
@@ -3383,7 +3383,7 @@ void e1000e_down(struct e1000_adapter *adapter)
 	ew32(TCTL, tctl);
 	/* flush both disables and wait for them to finish */
 	e1e_flush();
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	napi_disable(&adapter->napi);
 	e1000_irq_disable(adapter);
@@ -3418,7 +3418,7 @@ void e1000e_reinit_locked(struct e1000_adapter *adapter)
 {
 	might_sleep();
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
-		msleep(1);
+		usleep_range(1000, 2000);
 	e1000e_down(adapter);
 	e1000e_up(adapter);
 	clear_bit(__E1000_RESETTING, &adapter->state);
@@ -5028,7 +5028,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	}
 
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
-		msleep(1);
+		usleep_range(1000, 2000);
 	/* e1000e_down -> e1000e_reset dependent on max_frame_size & mtu */
 	adapter->max_frame_size = max_frame;
 	e_info("changing MTU from %d to %d\n", netdev->mtu, new_mtu);
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 6ae31fc..484774c 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -2372,7 +2372,7 @@ s32 e1000e_determine_phy_address(struct e1000_hw *hw)
 				ret_val = 0;
 				goto out;
 			}
-			msleep(1);
+			usleep_range(1000, 2000);
 			i++;
 		} while (i < 10);
 	}
@@ -2740,7 +2740,7 @@ void e1000_power_down_phy_copper(struct e1000_hw *hw)
 	e1e_rphy(hw, PHY_CONTROL, &mii_reg);
 	mii_reg |= MII_CR_POWER_DOWN;
 	e1e_wphy(hw, PHY_CONTROL, mii_reg);
-	msleep(1);
+	usleep_range(1000, 2000);
 }
 
 /**
-- 
1.7.4.2

