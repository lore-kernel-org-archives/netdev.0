From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 18/24] ixgbe: cleanup short msleep's (<20ms) to use usleep_range
Date: Wed, 13 Apr 2011 18:02:14 -0700
Message-ID: <1302742940-22141-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13789 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758198Ab1DNBCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:37 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Since msleep might not sleep for the desired amount when less
than 20ms use usleep_range.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c   |    2 +-
 drivers/net/ixgbe/ixgbe_82599.c   |   14 +++++++++-----
 drivers/net/ixgbe/ixgbe_common.c  |   14 +++++++++-----
 drivers/net/ixgbe/ixgbe_dcb_nl.c  |    2 +-
 drivers/net/ixgbe/ixgbe_ethtool.c |   14 +++++++-------
 drivers/net/ixgbe/ixgbe_main.c    |    8 ++++----
 drivers/net/ixgbe/ixgbe_phy.c     |    4 ++--
 drivers/net/ixgbe/ixgbe_x540.c    |    6 +++---
 8 files changed, 36 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index a93275f..af4054a 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1083,7 +1083,7 @@ static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_offset,
 			sfp_stat = sfp_stat & IXGBE_I2C_EEPROM_STATUS_MASK;
 			if (sfp_stat != IXGBE_I2C_EEPROM_STATUS_IN_PROGRESS)
 				break;
-			msleep(10);
+			usleep_range(10000, 20000);
 		}
 
 		if (sfp_stat != IXGBE_I2C_EEPROM_STATUS_PASS) {
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index d195278..e39380c 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -130,8 +130,12 @@ static s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 
 		/* Release the semaphore */
 		ixgbe_release_swfw_sync(hw, IXGBE_GSSR_MAC_CSR_SM);
-		/* Delay obtaining semaphore again to allow FW access */
-		msleep(hw->eeprom.semaphore_delay);
+		/*
+		 * Delay obtaining semaphore again to allow FW access,
+		 * semaphore_delay is in ms usleep_range needs us.
+		 */
+		usleep_range(hw->eeprom.semaphore_delay * 1000,
+			     hw->eeprom.semaphore_delay * 2000);
 
 		/* Now restart DSP by setting Restart_AN and clearing LMS */
 		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, ((IXGBE_READ_REG(hw,
@@ -140,7 +144,7 @@ static s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 
 		/* Wait for AN to leave state 0 */
 		for (i = 0; i < 10; i++) {
-			msleep(4);
+			usleep_range(4000, 8000);
 			reg_anlp1 = IXGBE_READ_REG(hw, IXGBE_ANLP1);
 			if (reg_anlp1 & IXGBE_ANLP1_AN_STATE_MASK)
 				break;
@@ -1178,7 +1182,7 @@ s32 ixgbe_init_fdir_signature_82599(struct ixgbe_hw *hw, u32 pballoc)
 		if (IXGBE_READ_REG(hw, IXGBE_FDIRCTRL) &
 		                   IXGBE_FDIRCTRL_INIT_DONE)
 			break;
-		msleep(1);
+		usleep_range(1000, 2000);
 	}
 	if (i >= IXGBE_FDIR_INIT_DONE_POLL)
 		hw_dbg(hw, "Flow Director Signature poll time exceeded!\n");
@@ -1273,7 +1277,7 @@ s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc)
 		if (IXGBE_READ_REG(hw, IXGBE_FDIRCTRL) &
 		                   IXGBE_FDIRCTRL_INIT_DONE)
 			break;
-		msleep(1);
+		usleep_range(1000, 2000);
 	}
 	if (i >= IXGBE_FDIR_INIT_DONE_POLL)
 		hw_dbg(hw, "Flow Director Perfect poll time exceeded!\n");
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 1b8b3cd..a67cba5 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -503,7 +503,7 @@ s32 ixgbe_stop_adapter_generic(struct ixgbe_hw *hw)
 	reg_val &= ~(IXGBE_RXCTRL_RXEN);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, reg_val);
 	IXGBE_WRITE_FLUSH(hw);
-	msleep(2);
+	usleep_range(2000, 4000);
 
 	/* Clear interrupt mask to stop from interrupts being generated */
 	IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_IRQ_CLEAR_MASK);
@@ -1151,8 +1151,12 @@ static void ixgbe_release_eeprom(struct ixgbe_hw *hw)
 
 	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
 
-	/* Delay before attempt to obtain semaphore again to allow FW access */
-	msleep(hw->eeprom.semaphore_delay);
+	/*
+	 * Delay before attempt to obtain semaphore again to allow FW
+	 * access. semaphore_delay is in ms we need us for usleep_range
+	 */
+	usleep_range(hw->eeprom.semaphore_delay * 1000,
+		     hw->eeprom.semaphore_delay * 2000);
 }
 
 /**
@@ -2228,7 +2232,7 @@ s32 ixgbe_acquire_swfw_sync(struct ixgbe_hw *hw, u16 mask)
 		 * thread currently using resource (swmask)
 		 */
 		ixgbe_release_eeprom_semaphore(hw);
-		msleep(5);
+		usleep_range(5000, 10000);
 		timeout--;
 	}
 
@@ -2302,7 +2306,7 @@ s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index)
 		autoc_reg |= IXGBE_AUTOC_AN_RESTART;
 		autoc_reg |= IXGBE_AUTOC_FLU;
 		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
-		msleep(10);
+		usleep_range(10000, 20000);
 	}
 
 	led_reg &= ~IXGBE_LED_MODE_MASK(index);
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 7b59f64..5e7ed22 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -376,7 +376,7 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 	 */
 	if (adapter->dcb_set_bitmap & BIT_APP_UPCHG) {
 		while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
-			msleep(1);
+			usleep_range(1000, 2000);
 
 		ixgbe_fcoe_setapp(adapter, up);
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 76380a2..5005a36 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -931,7 +931,7 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 	}
 
 	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
-		msleep(1);
+		usleep_range(1000, 2000);
 
 	if (!netif_running(adapter->netdev)) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
@@ -1417,7 +1417,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFFFFFF);
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	/* Test each interrupt */
 	for (; i < 10; i++) {
@@ -1437,7 +1437,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 			                ~mask & 0x00007FFF);
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS,
 			                ~mask & 0x00007FFF);
-			msleep(10);
+			usleep_range(10000, 20000);
 
 			if (adapter->test_icr & mask) {
 				*data = 3;
@@ -1454,7 +1454,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 		adapter->test_icr = 0;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, mask);
-		msleep(10);
+		usleep_range(10000, 20000);
 
 		if (!(adapter->test_icr &mask)) {
 			*data = 4;
@@ -1474,7 +1474,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 			                ~mask & 0x00007FFF);
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS,
 			                ~mask & 0x00007FFF);
-			msleep(10);
+			usleep_range(10000, 20000);
 
 			if (adapter->test_icr) {
 				*data = 5;
@@ -1485,7 +1485,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFFFFFF);
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	/* Unhook test interrupt handler */
 	free_irq(irq, netdev);
@@ -1613,7 +1613,7 @@ static int ixgbe_setup_loopback_test(struct ixgbe_adapter *adapter)
 	reg_data |= IXGBE_AUTOC_LMS_10G_LINK_NO_AN | IXGBE_AUTOC_FLU;
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_AUTOC, reg_data);
 	IXGBE_WRITE_FLUSH(&adapter->hw);
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	/* Disable Atlas Tx lanes; re-enabled in reset path */
 	if (hw->mac.type == ixgbe_mac_82598EB) {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3148e21..5cd2cd3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2731,7 +2731,7 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 
 	/* poll to verify queue is enabled */
 	do {
-		msleep(1);
+		usleep_range(1000, 2000);
 		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(reg_idx));
 	} while (--wait_loop && !(txdctl & IXGBE_TXDCTL_ENABLE));
 	if (!wait_loop)
@@ -3023,7 +3023,7 @@ static void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
 		return;
 
 	do {
-		msleep(1);
+		usleep_range(1000, 2000);
 		rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(reg_idx));
 	} while (--wait_loop && !(rxdctl & IXGBE_RXDCTL_ENABLE));
 
@@ -3945,7 +3945,7 @@ void ixgbe_reinit_locked(struct ixgbe_adapter *adapter)
 {
 	WARN_ON(in_interrupt());
 	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
-		msleep(1);
+		usleep_range(1000, 2000);
 	ixgbe_down(adapter);
 	/*
 	 * If SR-IOV enabled then wait a bit before bringing the adapter
@@ -4150,7 +4150,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		/* this call also flushes the previous write */
 		ixgbe_disable_rx_queue(adapter, adapter->rx_ring[i]);
 
-	msleep(10);
+	usleep_range(10000, 20000);
 
 	netif_tx_stop_all_queues(netdev);
 
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index df5b8aa..31cc29e 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -753,7 +753,7 @@ s32 ixgbe_reset_phy_nl(struct ixgbe_hw *hw)
 		                     &phy_data);
 		if ((phy_data & MDIO_CTRL1_RESET) == 0)
 			break;
-		msleep(10);
+		usleep_range(10000, 20000);
 	}
 
 	if ((phy_data & MDIO_CTRL1_RESET) != 0) {
@@ -782,7 +782,7 @@ s32 ixgbe_reset_phy_nl(struct ixgbe_hw *hw)
 		case IXGBE_DELAY_NL:
 			data_offset++;
 			hw_dbg(hw, "DELAY: %d MS\n", edata);
-			msleep(edata);
+			usleep_range(edata * 1000, edata * 2000);
 			break;
 		case IXGBE_DATA_NL:
 			hw_dbg(hw, "DATA:\n");
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 295c170..8aa1dc1 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -563,7 +563,7 @@ static s32 ixgbe_acquire_swfw_sync_X540(struct ixgbe_hw *hw, u16 mask)
 			 * resource (swmask)
 			 */
 			ixgbe_release_swfw_sync_semaphore(hw);
-			msleep(5);
+			usleep_range(5000, 10000);
 		}
 	}
 
@@ -585,7 +585,7 @@ static s32 ixgbe_acquire_swfw_sync_X540(struct ixgbe_hw *hw, u16 mask)
 		}
 	}
 
-	msleep(5);
+	usleep_range(5000, 10000);
 	return 0;
 }
 
@@ -609,7 +609,7 @@ static void ixgbe_release_swfw_sync_X540(struct ixgbe_hw *hw, u16 mask)
 	IXGBE_WRITE_REG(hw, IXGBE_SWFW_SYNC, swfw_sync);
 
 	ixgbe_release_swfw_sync_semaphore(hw);
-	msleep(5);
+	usleep_range(5000, 10000);
 }
 
 /**
-- 
1.7.4.2

