From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 01/13] e1000: drop dead pcie code from e1000
Date: Fri, 25 Sep 2009 15:16:14 -0700
Message-ID: <20090925221613.26715.66796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:55150
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752470AbZIYWQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:16:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

this patch is the first in a series of clean up patches for e1000 to drop
unused code, and update the driver to kernel spec, and then, to update the
driver to have all available bug fixes.

Call it the e1000 weight loss plan.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h         |    3 
 drivers/net/e1000/e1000_ethtool.c |  198 --
 drivers/net/e1000/e1000_hw.c      | 3281 +------------------------------------
 drivers/net/e1000/e1000_hw.h      |  341 ----
 drivers/net/e1000/e1000_main.c    |  683 +-------
 drivers/net/e1000/e1000_param.c   |   22 
 6 files changed, 193 insertions(+), 4335 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 1a4f89c..42e2b7e 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -149,7 +149,6 @@ do {									\
 
 #define AUTO_ALL_MODES            0
 #define E1000_EEPROM_82544_APM    0x0004
-#define E1000_EEPROM_ICH8_APME    0x0004
 #define E1000_EEPROM_APME         0x0400
 
 #ifndef E1000_MASTER_SLAVE
@@ -293,7 +292,6 @@ struct e1000_adapter {
 
 	u64 hw_csum_err;
 	u64 hw_csum_good;
-	u64 rx_hdr_split;
 	u32 alloc_rx_buff_failed;
 	u32 rx_int_delay;
 	u32 rx_abs_int_delay;
@@ -317,7 +315,6 @@ struct e1000_adapter {
 	struct e1000_rx_ring test_rx_ring;
 
 	int msg_enable;
-	bool have_msi;
 
 	/* to not mess up cache alignment, always add to the bottom */
 	bool tso_force;
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 27f996a..f2e756f 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -82,7 +82,6 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "rx_long_byte_count", E1000_STAT(stats.gorcl) },
 	{ "rx_csum_offload_good", E1000_STAT(hw_csum_good) },
 	{ "rx_csum_offload_errors", E1000_STAT(hw_csum_err) },
-	{ "rx_header_split", E1000_STAT(rx_hdr_split) },
 	{ "alloc_rx_buff_failed", E1000_STAT(alloc_rx_buff_failed) },
 	{ "tx_smbus", E1000_STAT(stats.mgptc) },
 	{ "rx_smbus", E1000_STAT(stats.mgprc) },
@@ -114,8 +113,6 @@ static int e1000_get_settings(struct net_device *netdev,
 		                   SUPPORTED_1000baseT_Full|
 		                   SUPPORTED_Autoneg |
 		                   SUPPORTED_TP);
-		if (hw->phy_type == e1000_phy_ife)
-			ecmd->supported &= ~SUPPORTED_1000baseT_Full;
 		ecmd->advertising = ADVERTISED_TP;
 
 		if (hw->autoneg == 1) {
@@ -178,14 +175,6 @@ static int e1000_set_settings(struct net_device *netdev,
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
-	/* When SoL/IDER sessions are active, autoneg/speed/duplex
-	 * cannot be changed */
-	if (e1000_check_phy_reset_block(hw)) {
-		DPRINTK(DRV, ERR, "Cannot change link characteristics "
-		        "when SoL/IDER is active.\n");
-		return -EINVAL;
-	}
-
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
 		msleep(1);
 
@@ -330,10 +319,7 @@ static int e1000_set_tso(struct net_device *netdev, u32 data)
 	else
 		netdev->features &= ~NETIF_F_TSO;
 
-	if (data && (adapter->hw.mac_type > e1000_82547_rev_2))
-		netdev->features |= NETIF_F_TSO6;
-	else
-		netdev->features &= ~NETIF_F_TSO6;
+	netdev->features &= ~NETIF_F_TSO6;
 
 	DPRINTK(PROBE, INFO, "TSO is %s\n", data ? "Enabled" : "Disabled");
 	adapter->tso_force = true;
@@ -441,7 +427,6 @@ static void e1000_get_regs(struct net_device *netdev, struct ethtool_regs *regs,
 	regs_buff[24] = (u32)phy_data;  /* phy local receiver status */
 	regs_buff[25] = regs_buff[24];  /* phy remote receiver status */
 	if (hw->mac_type >= e1000_82540 &&
-	    hw->mac_type < e1000_82571 &&
 	    hw->media_type == e1000_media_type_copper) {
 		regs_buff[26] = er32(MANC);
 	}
@@ -554,10 +539,8 @@ static int e1000_set_eeprom(struct net_device *netdev,
 	ret_val = e1000_write_eeprom(hw, first_word,
 				     last_word - first_word + 1, eeprom_buff);
 
-	/* Update the checksum over the first part of the EEPROM if needed
-	 * and flush shadow RAM for 82573 conrollers */
-	if ((ret_val == 0) && ((first_word <= EEPROM_CHECKSUM_REG) ||
-				(hw->mac_type == e1000_82573)))
+	/* Update the checksum over the first part of the EEPROM if needed */
+	if ((ret_val == 0) && (first_word <= EEPROM_CHECKSUM_REG))
 		e1000_update_eeprom_checksum(hw);
 
 	kfree(eeprom_buff);
@@ -568,31 +551,12 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 			      struct ethtool_drvinfo *drvinfo)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
 	char firmware_version[32];
-	u16 eeprom_data;
 
 	strncpy(drvinfo->driver,  e1000_driver_name, 32);
 	strncpy(drvinfo->version, e1000_driver_version, 32);
 
-	/* EEPROM image version # is reported as firmware version # for
-	 * 8257{1|2|3} controllers */
-	e1000_read_eeprom(hw, 5, 1, &eeprom_data);
-	switch (hw->mac_type) {
-	case e1000_82571:
-	case e1000_82572:
-	case e1000_82573:
-	case e1000_80003es2lan:
-	case e1000_ich8lan:
-		sprintf(firmware_version, "%d.%d-%d",
-			(eeprom_data & 0xF000) >> 12,
-			(eeprom_data & 0x0FF0) >> 4,
-			eeprom_data & 0x000F);
-		break;
-	default:
-		sprintf(firmware_version, "N/A");
-	}
-
+	sprintf(firmware_version, "N/A");
 	strncpy(drvinfo->fw_version, firmware_version, 32);
 	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
 	drvinfo->regdump_len = e1000_get_regs_len(netdev);
@@ -781,21 +745,9 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	/* The status register is Read Only, so a write should fail.
 	 * Some bits that get toggled are ignored.
 	 */
-	switch (hw->mac_type) {
+
 	/* there are several bits on newer hardware that are r/w */
-	case e1000_82571:
-	case e1000_82572:
-	case e1000_80003es2lan:
-		toggle = 0x7FFFF3FF;
-		break;
-	case e1000_82573:
-	case e1000_ich8lan:
-		toggle = 0x7FFFF033;
-		break;
-	default:
-		toggle = 0xFFFFF833;
-		break;
-	}
+	toggle = 0xFFFFF833;
 
 	before = er32(STATUS);
 	value = (er32(STATUS) & toggle);
@@ -810,12 +762,10 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	/* restore previous status */
 	ew32(STATUS, before);
 
-	if (hw->mac_type != e1000_ich8lan) {
-		REG_PATTERN_TEST(FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
-		REG_PATTERN_TEST(FCAH, 0x0000FFFF, 0xFFFFFFFF);
-		REG_PATTERN_TEST(FCT, 0x0000FFFF, 0xFFFFFFFF);
-		REG_PATTERN_TEST(VET, 0x0000FFFF, 0xFFFFFFFF);
-	}
+	REG_PATTERN_TEST(FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
+	REG_PATTERN_TEST(FCAH, 0x0000FFFF, 0xFFFFFFFF);
+	REG_PATTERN_TEST(FCT, 0x0000FFFF, 0xFFFFFFFF);
+	REG_PATTERN_TEST(VET, 0x0000FFFF, 0xFFFFFFFF);
 
 	REG_PATTERN_TEST(RDTR, 0x0000FFFF, 0xFFFFFFFF);
 	REG_PATTERN_TEST(RDBAH, 0xFFFFFFFF, 0xFFFFFFFF);
@@ -830,8 +780,7 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 
 	REG_SET_AND_CHECK(RCTL, 0xFFFFFFFF, 0x00000000);
 
-	before = (hw->mac_type == e1000_ich8lan ?
-	          0x06C3B33E : 0x06DFB3FE);
+	before = 0x06DFB3FE;
 	REG_SET_AND_CHECK(RCTL, before, 0x003FFFFB);
 	REG_SET_AND_CHECK(TCTL, 0xFFFFFFFF, 0x00000000);
 
@@ -839,12 +788,10 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 
 		REG_SET_AND_CHECK(RCTL, before, 0xFFFFFFFF);
 		REG_PATTERN_TEST(RDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
-		if (hw->mac_type != e1000_ich8lan)
-			REG_PATTERN_TEST(TXCW, 0xC000FFFF, 0x0000FFFF);
+		REG_PATTERN_TEST(TXCW, 0xC000FFFF, 0x0000FFFF);
 		REG_PATTERN_TEST(TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
 		REG_PATTERN_TEST(TIDV, 0x0000FFFF, 0x0000FFFF);
-		value = (hw->mac_type == e1000_ich8lan ?
-		         E1000_RAR_ENTRIES_ICH8LAN : E1000_RAR_ENTRIES);
+		value = E1000_RAR_ENTRIES;
 		for (i = 0; i < value; i++) {
 			REG_PATTERN_TEST(RA + (((i << 1) + 1) << 2), 0x8003FFFF,
 			                 0xFFFFFFFF);
@@ -859,8 +806,7 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 
 	}
 
-	value = (hw->mac_type == e1000_ich8lan ?
-			E1000_MC_TBL_SIZE_ICH8LAN : E1000_MC_TBL_SIZE);
+	value = E1000_MC_TBL_SIZE;
 	for (i = 0; i < value; i++)
 		REG_PATTERN_TEST(MTA + (i << 2), 0xFFFFFFFF, 0xFFFFFFFF);
 
@@ -933,9 +879,6 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 	/* Test each interrupt */
 	for (; i < 10; i++) {
 
-		if (hw->mac_type == e1000_ich8lan && i == 8)
-			continue;
-
 		/* Interrupt to test */
 		mask = 1 << i;
 
@@ -1289,35 +1232,20 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 		e1000_write_phy_reg(hw, PHY_CTRL, 0x9140);
 		/* autoneg off */
 		e1000_write_phy_reg(hw, PHY_CTRL, 0x8140);
-	} else if (hw->phy_type == e1000_phy_gg82563)
-		e1000_write_phy_reg(hw,
-		                    GG82563_PHY_KMRN_MODE_CTRL,
-		                    0x1CC);
+	}
 
 	ctrl_reg = er32(CTRL);
 
-	if (hw->phy_type == e1000_phy_ife) {
-		/* force 100, set loopback */
-		e1000_write_phy_reg(hw, PHY_CTRL, 0x6100);
+	/* force 1000, set loopback */
+	e1000_write_phy_reg(hw, PHY_CTRL, 0x4140);
 
-		/* Now set up the MAC to the same speed/duplex as the PHY. */
-		ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
-		ctrl_reg |= (E1000_CTRL_FRCSPD | /* Set the Force Speed Bit */
-			     E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
-			     E1000_CTRL_SPD_100 |/* Force Speed to 100 */
-			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
-	} else {
-		/* force 1000, set loopback */
-		e1000_write_phy_reg(hw, PHY_CTRL, 0x4140);
-
-		/* Now set up the MAC to the same speed/duplex as the PHY. */
-		ctrl_reg = er32(CTRL);
-		ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
-		ctrl_reg |= (E1000_CTRL_FRCSPD | /* Set the Force Speed Bit */
-			     E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
-			     E1000_CTRL_SPD_1000 |/* Force Speed to 1000 */
-			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
-	}
+	/* Now set up the MAC to the same speed/duplex as the PHY. */
+	ctrl_reg = er32(CTRL);
+	ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
+	ctrl_reg |= (E1000_CTRL_FRCSPD | /* Set the Force Speed Bit */
+			E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
+			E1000_CTRL_SPD_1000 |/* Force Speed to 1000 */
+			E1000_CTRL_FD);	 /* Force Duplex to FULL */
 
 	if (hw->media_type == e1000_media_type_copper &&
 	   hw->phy_type == e1000_phy_m88)
@@ -1373,14 +1301,8 @@ static int e1000_set_phy_loopback(struct e1000_adapter *adapter)
 	case e1000_82541_rev_2:
 	case e1000_82547:
 	case e1000_82547_rev_2:
-	case e1000_82571:
-	case e1000_82572:
-	case e1000_82573:
-	case e1000_80003es2lan:
-	case e1000_ich8lan:
 		return e1000_integrated_phy_loopback(adapter);
 		break;
-
 	default:
 		/* Default PHY loopback work is to read the MII
 		 * control register and assert bit 14 (loopback mode).
@@ -1409,14 +1331,6 @@ static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
 		case e1000_82546_rev_3:
 			return e1000_set_phy_loopback(adapter);
 			break;
-		case e1000_82571:
-		case e1000_82572:
-#define E1000_SERDES_LB_ON 0x410
-			e1000_set_phy_loopback(adapter);
-			ew32(SCTL, E1000_SERDES_LB_ON);
-			msleep(10);
-			return 0;
-			break;
 		default:
 			rctl = er32(RCTL);
 			rctl |= E1000_RCTL_LBM_TCVR;
@@ -1440,26 +1354,12 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 	ew32(RCTL, rctl);
 
 	switch (hw->mac_type) {
-	case e1000_82571:
-	case e1000_82572:
-		if (hw->media_type == e1000_media_type_fiber ||
-		    hw->media_type == e1000_media_type_internal_serdes) {
-#define E1000_SERDES_LB_OFF 0x400
-			ew32(SCTL, E1000_SERDES_LB_OFF);
-			msleep(10);
-			break;
-		}
-		/* Fall Through */
 	case e1000_82545:
 	case e1000_82546:
 	case e1000_82545_rev_3:
 	case e1000_82546_rev_3:
 	default:
 		hw->autoneg = true;
-		if (hw->phy_type == e1000_phy_gg82563)
-			e1000_write_phy_reg(hw,
-					    GG82563_PHY_KMRN_MODE_CTRL,
-					    0x180);
 		e1000_read_phy_reg(hw, PHY_CTRL, &phy_reg);
 		if (phy_reg & MII_CR_LOOPBACK) {
 			phy_reg &= ~MII_CR_LOOPBACK;
@@ -1560,17 +1460,6 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 
 static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 {
-	struct e1000_hw *hw = &adapter->hw;
-
-	/* PHY loopback cannot be performed if SoL/IDER
-	 * sessions are active */
-	if (e1000_check_phy_reset_block(hw)) {
-		DPRINTK(DRV, ERR, "Cannot do PHY loopback test "
-		        "when SoL/IDER is active.\n");
-		*data = 0;
-		goto out;
-	}
-
 	*data = e1000_setup_desc_rings(adapter);
 	if (*data)
 		goto out;
@@ -1716,15 +1605,11 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter,
 	case E1000_DEV_ID_82545EM_COPPER:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER:
 	case E1000_DEV_ID_82546GB_PCIE:
-	case E1000_DEV_ID_82571EB_SERDES_QUAD:
 		/* these don't support WoL at all */
 		wol->supported = 0;
 		break;
 	case E1000_DEV_ID_82546EB_FIBER:
 	case E1000_DEV_ID_82546GB_FIBER:
-	case E1000_DEV_ID_82571EB_FIBER:
-	case E1000_DEV_ID_82571EB_SERDES:
-	case E1000_DEV_ID_82571EB_COPPER:
 		/* Wake events not supported on port B */
 		if (er32(STATUS) & E1000_STATUS_FUNC_1) {
 			wol->supported = 0;
@@ -1733,10 +1618,6 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter,
 		/* return success for non excluded adapter ports */
 		retval = 0;
 		break;
-	case E1000_DEV_ID_82571EB_QUAD_COPPER:
-	case E1000_DEV_ID_82571EB_QUAD_FIBER:
-	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
-	case E1000_DEV_ID_82571PT_QUAD_COPPER:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		/* quad port adapters only support WoL on port A */
 		if (!adapter->quad_port_a) {
@@ -1872,30 +1753,15 @@ static int e1000_phys_id(struct net_device *netdev, u32 data)
 	if (!data)
 		data = INT_MAX;
 
-	if (hw->mac_type < e1000_82571) {
-		if (!adapter->blink_timer.function) {
-			init_timer(&adapter->blink_timer);
-			adapter->blink_timer.function = e1000_led_blink_callback;
-			adapter->blink_timer.data = (unsigned long)adapter;
-		}
-		e1000_setup_led(hw);
-		mod_timer(&adapter->blink_timer, jiffies);
-		msleep_interruptible(data * 1000);
-		del_timer_sync(&adapter->blink_timer);
-	} else if (hw->phy_type == e1000_phy_ife) {
-		if (!adapter->blink_timer.function) {
-			init_timer(&adapter->blink_timer);
-			adapter->blink_timer.function = e1000_led_blink_callback;
-			adapter->blink_timer.data = (unsigned long)adapter;
-		}
-		mod_timer(&adapter->blink_timer, jiffies);
-		msleep_interruptible(data * 1000);
-		del_timer_sync(&adapter->blink_timer);
-		e1000_write_phy_reg(&(adapter->hw), IFE_PHY_SPECIAL_CONTROL_LED, 0);
-	} else {
-		e1000_blink_led_start(hw);
-		msleep_interruptible(data * 1000);
+	if (!adapter->blink_timer.function) {
+		init_timer(&adapter->blink_timer);
+		adapter->blink_timer.function = e1000_led_blink_callback;
+		adapter->blink_timer.data = (unsigned long)adapter;
 	}
+	e1000_setup_led(hw);
+	mod_timer(&adapter->blink_timer, jiffies);
+	msleep_interruptible(data * 1000);
+	del_timer_sync(&adapter->blink_timer);
 
 	e1000_led_off(hw);
 	clear_bit(E1000_LED_ON, &adapter->led_status);
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 45ac225..74aa599 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -35,49 +35,23 @@
 
 static s32 e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask);
 static void e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask);
-static s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 *data);
-static s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 data);
-static s32 e1000_get_software_semaphore(struct e1000_hw *hw);
-static void e1000_release_software_semaphore(struct e1000_hw *hw);
 
-static u8 e1000_arc_subsystem_valid(struct e1000_hw *hw);
 static s32 e1000_check_downshift(struct e1000_hw *hw);
 static s32 e1000_check_polarity(struct e1000_hw *hw,
 				e1000_rev_polarity *polarity);
 static void e1000_clear_hw_cntrs(struct e1000_hw *hw);
 static void e1000_clear_vfta(struct e1000_hw *hw);
-static s32 e1000_commit_shadow_ram(struct e1000_hw *hw);
 static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw,
 					      bool link_up);
 static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw);
 static s32 e1000_detect_gig_phy(struct e1000_hw *hw);
-static s32 e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank);
 static s32 e1000_get_auto_rd_done(struct e1000_hw *hw);
 static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length,
 				  u16 *max_length);
 static s32 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw);
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
-static s32 e1000_get_software_flag(struct e1000_hw *hw);
-static s32 e1000_ich8_cycle_init(struct e1000_hw *hw);
-static s32 e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout);
 static s32 e1000_id_led_init(struct e1000_hw *hw);
-static s32 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
-						 u32 cnf_base_addr,
-						 u32 cnf_size);
-static s32 e1000_init_lcd_from_nvm(struct e1000_hw *hw);
 static void e1000_init_rx_addrs(struct e1000_hw *hw);
-static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
-static bool e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
-static s32 e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
-static s32 e1000_mng_enable_host_if(struct e1000_hw *hw);
-static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer, u16 length,
-				   u16 offset, u8 *sum);
-static s32 e1000_mng_write_cmd_header(struct e1000_hw* hw,
-				      struct e1000_host_mng_command_header
-				      *hdr);
-static s32 e1000_mng_write_commit(struct e1000_hw *hw);
-static s32 e1000_phy_ife_get_info(struct e1000_hw *hw,
-				  struct e1000_phy_info *phy_info);
 static s32 e1000_phy_igp_get_info(struct e1000_hw *hw,
 				  struct e1000_phy_info *phy_info);
 static s32 e1000_read_eeprom_eerd(struct e1000_hw *hw, u16 offset, u16 words,
@@ -88,24 +62,7 @@ static s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
 static s32 e1000_phy_m88_get_info(struct e1000_hw *hw,
 				  struct e1000_phy_info *phy_info);
 static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw);
-static s32 e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8 *data);
-static s32 e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index,
-					u8 byte);
-static s32 e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte);
-static s32 e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data);
-static s32 e1000_read_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
-				u16 *data);
-static s32 e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
-				 u16 data);
-static s32 e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
-				  u16 *data);
-static s32 e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
-				   u16 *data);
-static void e1000_release_software_flag(struct e1000_hw *hw);
 static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
-static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
-static s32 e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop);
-static void e1000_set_pci_express_master_disable(struct e1000_hw *hw);
 static s32 e1000_wait_autoneg(struct e1000_hw *hw);
 static void e1000_write_reg_io(struct e1000_hw *hw, u32 offset, u32 value);
 static s32 e1000_set_phy_type(struct e1000_hw *hw);
@@ -140,10 +97,6 @@ static void e1000_standby_eeprom(struct e1000_hw *hw);
 static s32 e1000_set_vco_speed(struct e1000_hw *hw);
 static s32 e1000_polarity_reversal_workaround(struct e1000_hw *hw);
 static s32 e1000_set_phy_mode(struct e1000_hw *hw);
-static s32 e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer);
-static u8 e1000_calculate_mng_checksum(char *buffer, u32 length);
-static s32 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex);
-static s32 e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
 static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 
@@ -159,17 +112,6 @@ u16 e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] =
       100, 100, 100, 100, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110, 110,
       110, 110, 110, 110, 110, 110, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120};
 
-static const
-u16 e1000_igp_2_cable_length_table[IGP02E1000_AGC_LENGTH_TABLE_SIZE] =
-    { 0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21,
-      0, 0, 0, 3, 6, 10, 13, 16, 19, 23, 26, 29, 32, 35, 38, 41,
-      6, 10, 14, 18, 22, 26, 30, 33, 37, 41, 44, 48, 51, 54, 58, 61,
-      21, 26, 31, 35, 40, 44, 49, 53, 57, 61, 65, 68, 72, 75, 79, 82,
-      40, 45, 51, 56, 61, 66, 70, 75, 79, 83, 87, 91, 94, 98, 101, 104,
-      60, 66, 72, 77, 82, 87, 92, 96, 100, 104, 108, 111, 114, 117, 119, 121,
-      83, 89, 95, 100, 105, 109, 113, 116, 119, 122, 124,
-      104, 109, 114, 118, 121, 124};
-
 static DEFINE_SPINLOCK(e1000_eeprom_lock);
 
 /******************************************************************************
@@ -199,20 +141,6 @@ static s32 e1000_set_phy_type(struct e1000_hw *hw)
             hw->phy_type = e1000_phy_igp;
             break;
         }
-    case IGP03E1000_E_PHY_ID:
-        hw->phy_type = e1000_phy_igp_3;
-        break;
-    case IFE_E_PHY_ID:
-    case IFE_PLUS_E_PHY_ID:
-    case IFE_C_E_PHY_ID:
-        hw->phy_type = e1000_phy_ife;
-        break;
-    case GG82563_E_PHY_ID:
-        if (hw->mac_type == e1000_80003es2lan) {
-            hw->phy_type = e1000_phy_gg82563;
-            break;
-        }
-        /* Fall Through */
     default:
         /* Should never have loaded on this device */
         hw->phy_type = e1000_phy_undefined;
@@ -397,61 +325,12 @@ s32 e1000_set_mac_type(struct e1000_hw *hw)
 	case E1000_DEV_ID_82547GI:
 		hw->mac_type = e1000_82547_rev_2;
 		break;
-	case E1000_DEV_ID_82571EB_COPPER:
-	case E1000_DEV_ID_82571EB_FIBER:
-	case E1000_DEV_ID_82571EB_SERDES:
-	case E1000_DEV_ID_82571EB_SERDES_DUAL:
-	case E1000_DEV_ID_82571EB_SERDES_QUAD:
-	case E1000_DEV_ID_82571EB_QUAD_COPPER:
-	case E1000_DEV_ID_82571PT_QUAD_COPPER:
-	case E1000_DEV_ID_82571EB_QUAD_FIBER:
-	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
-		hw->mac_type = e1000_82571;
-		break;
-	case E1000_DEV_ID_82572EI_COPPER:
-	case E1000_DEV_ID_82572EI_FIBER:
-	case E1000_DEV_ID_82572EI_SERDES:
-	case E1000_DEV_ID_82572EI:
-		hw->mac_type = e1000_82572;
-		break;
-	case E1000_DEV_ID_82573E:
-	case E1000_DEV_ID_82573E_IAMT:
-	case E1000_DEV_ID_82573L:
-		hw->mac_type = e1000_82573;
-		break;
-	case E1000_DEV_ID_80003ES2LAN_COPPER_SPT:
-	case E1000_DEV_ID_80003ES2LAN_SERDES_SPT:
-	case E1000_DEV_ID_80003ES2LAN_COPPER_DPT:
-	case E1000_DEV_ID_80003ES2LAN_SERDES_DPT:
-		hw->mac_type = e1000_80003es2lan;
-		break;
-	case E1000_DEV_ID_ICH8_IGP_M_AMT:
-	case E1000_DEV_ID_ICH8_IGP_AMT:
-	case E1000_DEV_ID_ICH8_IGP_C:
-	case E1000_DEV_ID_ICH8_IFE:
-	case E1000_DEV_ID_ICH8_IFE_GT:
-	case E1000_DEV_ID_ICH8_IFE_G:
-	case E1000_DEV_ID_ICH8_IGP_M:
-		hw->mac_type = e1000_ich8lan;
-		break;
 	default:
 		/* Should never have loaded on this device */
 		return -E1000_ERR_MAC_TYPE;
 	}
 
 	switch (hw->mac_type) {
-	case e1000_ich8lan:
-		hw->swfwhw_semaphore_present = true;
-		hw->asf_firmware_present = true;
-		break;
-	case e1000_80003es2lan:
-		hw->swfw_sync_present = true;
-		/* fall through */
-	case e1000_82571:
-	case e1000_82572:
-	case e1000_82573:
-		hw->eeprom_semaphore_present = true;
-		/* fall through */
 	case e1000_82541:
 	case e1000_82547:
 	case e1000_82541_rev_2:
@@ -468,16 +347,6 @@ s32 e1000_set_mac_type(struct e1000_hw *hw)
 	if (hw->mac_type == e1000_82543)
 		hw->bad_tx_carr_stats_fd = true;
 
-	/* capable of receiving management packets to the host */
-	if (hw->mac_type >= e1000_82571)
-		hw->has_manc2h = true;
-
-	/* In rare occasions, ESB2 systems would end up started without
-	 * the RX unit being turned on.
-	 */
-	if (hw->mac_type == e1000_80003es2lan)
-		hw->rx_needs_kicking = true;
-
 	if (hw->mac_type > e1000_82544)
 		hw->has_smbus = true;
 
@@ -503,11 +372,6 @@ void e1000_set_media_type(struct e1000_hw *hw)
     switch (hw->device_id) {
     case E1000_DEV_ID_82545GM_SERDES:
     case E1000_DEV_ID_82546GB_SERDES:
-    case E1000_DEV_ID_82571EB_SERDES:
-    case E1000_DEV_ID_82571EB_SERDES_DUAL:
-    case E1000_DEV_ID_82571EB_SERDES_QUAD:
-    case E1000_DEV_ID_82572EI_SERDES:
-    case E1000_DEV_ID_80003ES2LAN_SERDES_DPT:
         hw->media_type = e1000_media_type_internal_serdes;
         break;
     default:
@@ -516,13 +380,6 @@ void e1000_set_media_type(struct e1000_hw *hw)
         case e1000_82542_rev2_1:
             hw->media_type = e1000_media_type_fiber;
             break;
-        case e1000_ich8lan:
-        case e1000_82573:
-            /* The STATUS_TBIMODE bit is reserved or reused for the this
-             * device.
-             */
-            hw->media_type = e1000_media_type_copper;
-            break;
         default:
             status = er32(STATUS);
             if (status & E1000_STATUS_TBIMODE) {
@@ -549,8 +406,6 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
     u32 icr;
     u32 manc;
     u32 led_ctrl;
-    u32 timeout;
-    u32 extcnf_ctrl;
     s32 ret_val;
 
     DEBUGFUNC("e1000_reset_hw");
@@ -561,15 +416,6 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
         e1000_pci_clear_mwi(hw);
     }
 
-    if (hw->bus_type == e1000_bus_type_pci_express) {
-        /* Prevent the PCI-E bus from sticking if there is no TLP connection
-         * on the last TLP read/write transaction when MAC is reset.
-         */
-        if (e1000_disable_pciex_master(hw) != E1000_SUCCESS) {
-            DEBUGOUT("PCI-E Master disable polling has failed.\n");
-        }
-    }
-
     /* Clear interrupt mask to stop board from generating interrupts */
     DEBUGOUT("Masking off all interrupts\n");
     ew32(IMC, 0xffffffff);
@@ -598,36 +444,6 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
         msleep(5);
     }
 
-    /* Must acquire the MDIO ownership before MAC reset.
-     * Ownership defaults to firmware after a reset. */
-    if (hw->mac_type == e1000_82573) {
-        timeout = 10;
-
-        extcnf_ctrl = er32(EXTCNF_CTRL);
-        extcnf_ctrl |= E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
-
-        do {
-            ew32(EXTCNF_CTRL, extcnf_ctrl);
-            extcnf_ctrl = er32(EXTCNF_CTRL);
-
-            if (extcnf_ctrl & E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP)
-                break;
-            else
-                extcnf_ctrl |= E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
-
-            msleep(2);
-            timeout--;
-        } while (timeout);
-    }
-
-    /* Workaround for ICH8 bit corruption issue in FIFO memory */
-    if (hw->mac_type == e1000_ich8lan) {
-        /* Set Tx and Rx buffer allocation to 8k apiece. */
-        ew32(PBA, E1000_PBA_8K);
-        /* Set Packet Buffer Size to 16k. */
-        ew32(PBS, E1000_PBS_16K);
-    }
-
     /* Issue a global reset to the MAC.  This will reset the chip's
      * transmit, receive, DMA, and link units.  It will not effect
      * the current PCI configuration.  The global reset bit is self-
@@ -651,20 +467,6 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
             /* Reset is performed on a shadow of the control register */
             ew32(CTRL_DUP, (ctrl | E1000_CTRL_RST));
             break;
-        case e1000_ich8lan:
-            if (!hw->phy_reset_disable &&
-                e1000_check_phy_reset_block(hw) == E1000_SUCCESS) {
-                /* e1000_ich8lan PHY HW reset requires MAC CORE reset
-                 * at the same time to make sure the interface between
-                 * MAC and the external PHY is reset.
-                 */
-                ctrl |= E1000_CTRL_PHY_RST;
-            }
-
-            e1000_get_software_flag(hw);
-            ew32(CTRL, (ctrl | E1000_CTRL_RST));
-            msleep(5);
-            break;
         default:
             ew32(CTRL, (ctrl | E1000_CTRL_RST));
             break;
@@ -695,15 +497,6 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
             /* Wait for EEPROM reload */
             msleep(20);
             break;
-        case e1000_82573:
-            if (!e1000_is_onboard_nvm_eeprom(hw)) {
-                udelay(10);
-                ctrl_ext = er32(CTRL_EXT);
-                ctrl_ext |= E1000_CTRL_EXT_EE_RST;
-                ew32(CTRL_EXT, ctrl_ext);
-                E1000_WRITE_FLUSH();
-            }
-            /* fall through */
         default:
             /* Auto read done will delay 5ms or poll based on mac type */
             ret_val = e1000_get_auto_rd_done(hw);
@@ -713,7 +506,7 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
     }
 
     /* Disable HW ARPs on ASF enabled adapters */
-    if (hw->mac_type >= e1000_82540 && hw->mac_type <= e1000_82547_rev_2) {
+    if (hw->mac_type >= e1000_82540) {
         manc = er32(MANC);
         manc &= ~(E1000_MANC_ARP_EN);
         ew32(MANC, manc);
@@ -742,132 +535,10 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
             e1000_pci_set_mwi(hw);
     }
 
-    if (hw->mac_type == e1000_ich8lan) {
-        u32 kab = er32(KABGTXD);
-        kab |= E1000_KABGTXD_BGSQLBIAS;
-        ew32(KABGTXD, kab);
-    }
-
     return E1000_SUCCESS;
 }
 
 /******************************************************************************
- *
- * Initialize a number of hardware-dependent bits
- *
- * hw: Struct containing variables accessed by shared code
- *
- * This function contains hardware limitation workarounds for PCI-E adapters
- *
- *****************************************************************************/
-static void e1000_initialize_hardware_bits(struct e1000_hw *hw)
-{
-    if ((hw->mac_type >= e1000_82571) && (!hw->initialize_hw_bits_disable)) {
-        /* Settings common to all PCI-express silicon */
-        u32 reg_ctrl, reg_ctrl_ext;
-        u32 reg_tarc0, reg_tarc1;
-        u32 reg_tctl;
-        u32 reg_txdctl, reg_txdctl1;
-
-        /* link autonegotiation/sync workarounds */
-        reg_tarc0 = er32(TARC0);
-        reg_tarc0 &= ~((1 << 30)|(1 << 29)|(1 << 28)|(1 << 27));
-
-        /* Enable not-done TX descriptor counting */
-        reg_txdctl = er32(TXDCTL);
-        reg_txdctl |= E1000_TXDCTL_COUNT_DESC;
-        ew32(TXDCTL, reg_txdctl);
-        reg_txdctl1 = er32(TXDCTL1);
-        reg_txdctl1 |= E1000_TXDCTL_COUNT_DESC;
-        ew32(TXDCTL1, reg_txdctl1);
-
-        switch (hw->mac_type) {
-            case e1000_82571:
-            case e1000_82572:
-                /* Clear PHY TX compatible mode bits */
-                reg_tarc1 = er32(TARC1);
-                reg_tarc1 &= ~((1 << 30)|(1 << 29));
-
-                /* link autonegotiation/sync workarounds */
-                reg_tarc0 |= ((1 << 26)|(1 << 25)|(1 << 24)|(1 << 23));
-
-                /* TX ring control fixes */
-                reg_tarc1 |= ((1 << 26)|(1 << 25)|(1 << 24));
-
-                /* Multiple read bit is reversed polarity */
-                reg_tctl = er32(TCTL);
-                if (reg_tctl & E1000_TCTL_MULR)
-                    reg_tarc1 &= ~(1 << 28);
-                else
-                    reg_tarc1 |= (1 << 28);
-
-                ew32(TARC1, reg_tarc1);
-                break;
-            case e1000_82573:
-                reg_ctrl_ext = er32(CTRL_EXT);
-                reg_ctrl_ext &= ~(1 << 23);
-                reg_ctrl_ext |= (1 << 22);
-
-                /* TX byte count fix */
-                reg_ctrl = er32(CTRL);
-                reg_ctrl &= ~(1 << 29);
-
-                ew32(CTRL_EXT, reg_ctrl_ext);
-                ew32(CTRL, reg_ctrl);
-                break;
-            case e1000_80003es2lan:
-                /* improve small packet performace for fiber/serdes */
-                if ((hw->media_type == e1000_media_type_fiber) ||
-                    (hw->media_type == e1000_media_type_internal_serdes)) {
-                    reg_tarc0 &= ~(1 << 20);
-                }
-
-                /* Multiple read bit is reversed polarity */
-                reg_tctl = er32(TCTL);
-                reg_tarc1 = er32(TARC1);
-                if (reg_tctl & E1000_TCTL_MULR)
-                    reg_tarc1 &= ~(1 << 28);
-                else
-                    reg_tarc1 |= (1 << 28);
-
-                ew32(TARC1, reg_tarc1);
-                break;
-            case e1000_ich8lan:
-                /* Reduce concurrent DMA requests to 3 from 4 */
-                if ((hw->revision_id < 3) ||
-                    ((hw->device_id != E1000_DEV_ID_ICH8_IGP_M_AMT) &&
-                     (hw->device_id != E1000_DEV_ID_ICH8_IGP_M)))
-                    reg_tarc0 |= ((1 << 29)|(1 << 28));
-
-                reg_ctrl_ext = er32(CTRL_EXT);
-                reg_ctrl_ext |= (1 << 22);
-                ew32(CTRL_EXT, reg_ctrl_ext);
-
-                /* workaround TX hang with TSO=on */
-                reg_tarc0 |= ((1 << 27)|(1 << 26)|(1 << 24)|(1 << 23));
-
-                /* Multiple read bit is reversed polarity */
-                reg_tctl = er32(TCTL);
-                reg_tarc1 = er32(TARC1);
-                if (reg_tctl & E1000_TCTL_MULR)
-                    reg_tarc1 &= ~(1 << 28);
-                else
-                    reg_tarc1 |= (1 << 28);
-
-                /* workaround TX hang with TSO=on */
-                reg_tarc1 |= ((1 << 30)|(1 << 26)|(1 << 24));
-
-                ew32(TARC1, reg_tarc1);
-                break;
-            default:
-                break;
-        }
-
-        ew32(TARC0, reg_tarc0);
-    }
-}
-
-/******************************************************************************
  * Performs basic configuration of the adapter.
  *
  * hw - Struct containing variables accessed by shared code
@@ -884,21 +555,10 @@ s32 e1000_init_hw(struct e1000_hw *hw)
     u32 i;
     s32 ret_val;
     u32 mta_size;
-    u32 reg_data;
     u32 ctrl_ext;
 
     DEBUGFUNC("e1000_init_hw");
 
-    /* force full DMA clock frequency for 10/100 on ICH8 A0-B0 */
-    if ((hw->mac_type == e1000_ich8lan) &&
-        ((hw->revision_id < 3) ||
-         ((hw->device_id != E1000_DEV_ID_ICH8_IGP_M_AMT) &&
-          (hw->device_id != E1000_DEV_ID_ICH8_IGP_M)))) {
-            reg_data = er32(STATUS);
-            reg_data &= ~0x80000000;
-            ew32(STATUS, reg_data);
-    }
-
     /* Initialize Identification LED */
     ret_val = e1000_id_led_init(hw);
     if (ret_val) {
@@ -909,17 +569,11 @@ s32 e1000_init_hw(struct e1000_hw *hw)
     /* Set the media type and TBI compatibility */
     e1000_set_media_type(hw);
 
-    /* Must be called after e1000_set_media_type because media_type is used */
-    e1000_initialize_hardware_bits(hw);
-
     /* Disabling VLAN filtering. */
     DEBUGOUT("Initializing the IEEE VLAN\n");
-    /* VET hardcoded to standard value and VFTA removed in ICH8 LAN */
-    if (hw->mac_type != e1000_ich8lan) {
-        if (hw->mac_type < e1000_82545_rev_3)
-            ew32(VET, 0);
-        e1000_clear_vfta(hw);
-    }
+    if (hw->mac_type < e1000_82545_rev_3)
+        ew32(VET, 0);
+    e1000_clear_vfta(hw);
 
     /* For 82542 (rev 2.0), disable MWI and put the receiver into reset */
     if (hw->mac_type == e1000_82542_rev2_0) {
@@ -947,8 +601,6 @@ s32 e1000_init_hw(struct e1000_hw *hw)
     /* Zero out the Multicast HASH table */
     DEBUGOUT("Zeroing the MTA\n");
     mta_size = E1000_MC_TBL_SIZE;
-    if (hw->mac_type == e1000_ich8lan)
-        mta_size = E1000_MC_TBL_SIZE_ICH8LAN;
     for (i = 0; i < mta_size; i++) {
         E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
         /* use write flush to prevent Memory Write Block (MWB) from
@@ -977,10 +629,6 @@ s32 e1000_init_hw(struct e1000_hw *hw)
 	break;
     }
 
-    /* More time needed for PHY to initialize */
-    if (hw->mac_type == e1000_ich8lan)
-        msleep(15);
-
     /* Call a subroutine to configure the link and setup flow control. */
     ret_val = e1000_setup_link(hw);
 
@@ -991,51 +639,6 @@ s32 e1000_init_hw(struct e1000_hw *hw)
         ew32(TXDCTL, ctrl);
     }
 
-    if (hw->mac_type == e1000_82573) {
-        e1000_enable_tx_pkt_filtering(hw);
-    }
-
-    switch (hw->mac_type) {
-    default:
-        break;
-    case e1000_80003es2lan:
-        /* Enable retransmit on late collisions */
-        reg_data = er32(TCTL);
-        reg_data |= E1000_TCTL_RTLC;
-        ew32(TCTL, reg_data);
-
-        /* Configure Gigabit Carry Extend Padding */
-        reg_data = er32(TCTL_EXT);
-        reg_data &= ~E1000_TCTL_EXT_GCEX_MASK;
-        reg_data |= DEFAULT_80003ES2LAN_TCTL_EXT_GCEX;
-        ew32(TCTL_EXT, reg_data);
-
-        /* Configure Transmit Inter-Packet Gap */
-        reg_data = er32(TIPG);
-        reg_data &= ~E1000_TIPG_IPGT_MASK;
-        reg_data |= DEFAULT_80003ES2LAN_TIPG_IPGT_1000;
-        ew32(TIPG, reg_data);
-
-        reg_data = E1000_READ_REG_ARRAY(hw, FFLT, 0x0001);
-        reg_data &= ~0x00100000;
-        E1000_WRITE_REG_ARRAY(hw, FFLT, 0x0001, reg_data);
-        /* Fall through */
-    case e1000_82571:
-    case e1000_82572:
-    case e1000_ich8lan:
-        ctrl = er32(TXDCTL1);
-        ctrl = (ctrl & ~E1000_TXDCTL_WTHRESH) | E1000_TXDCTL_FULL_TX_DESC_WB;
-        ew32(TXDCTL1, ctrl);
-        break;
-    }
-
-
-    if (hw->mac_type == e1000_82573) {
-        u32 gcr = er32(GCR);
-        gcr |= E1000_GCR_L1_ACT_WITHOUT_L0S_RX;
-        ew32(GCR, gcr);
-    }
-
     /* Clear all of the statistics registers (clear on read).  It is
      * important that we do this after we have tried to establish link
      * because the symbol error count will increment wildly if there
@@ -1043,11 +646,6 @@ s32 e1000_init_hw(struct e1000_hw *hw)
      */
     e1000_clear_hw_cntrs(hw);
 
-    /* ICH8 No-snoop bits are opposite polarity.
-     * Set to snoop by default after reset. */
-    if (hw->mac_type == e1000_ich8lan)
-        e1000_set_pci_ex_no_snoop(hw, PCI_EX_82566_SNOOP_ALL);
-
     if (hw->device_id == E1000_DEV_ID_82546GB_QUAD_COPPER ||
         hw->device_id == E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3) {
         ctrl_ext = er32(CTRL_EXT);
@@ -1118,11 +716,6 @@ s32 e1000_setup_link(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_setup_link");
 
-    /* In the case of the phy reset being blocked, we already have a link.
-     * We do not have to set it up again. */
-    if (e1000_check_phy_reset_block(hw))
-        return E1000_SUCCESS;
-
     /* Read and store word 0x0F of the EEPROM. This word contains bits
      * that determine the hardware's default PAUSE (flow control) mode,
      * a bit that determines whether the HW defaults to enabling or
@@ -1132,27 +725,19 @@ s32 e1000_setup_link(struct e1000_hw *hw)
      * be initialized based on a value in the EEPROM.
      */
     if (hw->fc == E1000_FC_DEFAULT) {
-        switch (hw->mac_type) {
-        case e1000_ich8lan:
-        case e1000_82573:
-            hw->fc = E1000_FC_FULL;
-            break;
-        default:
-            ret_val = e1000_read_eeprom(hw, EEPROM_INIT_CONTROL2_REG,
-                                        1, &eeprom_data);
-            if (ret_val) {
-                DEBUGOUT("EEPROM Read Error\n");
-                return -E1000_ERR_EEPROM;
-            }
-            if ((eeprom_data & EEPROM_WORD0F_PAUSE_MASK) == 0)
-                hw->fc = E1000_FC_NONE;
-            else if ((eeprom_data & EEPROM_WORD0F_PAUSE_MASK) ==
-                    EEPROM_WORD0F_ASM_DIR)
-                hw->fc = E1000_FC_TX_PAUSE;
-            else
-                hw->fc = E1000_FC_FULL;
-            break;
+        ret_val = e1000_read_eeprom(hw, EEPROM_INIT_CONTROL2_REG,
+                                    1, &eeprom_data);
+        if (ret_val) {
+            DEBUGOUT("EEPROM Read Error\n");
+            return -E1000_ERR_EEPROM;
         }
+        if ((eeprom_data & EEPROM_WORD0F_PAUSE_MASK) == 0)
+            hw->fc = E1000_FC_NONE;
+        else if ((eeprom_data & EEPROM_WORD0F_PAUSE_MASK) ==
+                 EEPROM_WORD0F_ASM_DIR)
+            hw->fc = E1000_FC_TX_PAUSE;
+        else
+            hw->fc = E1000_FC_FULL;
     }
 
     /* We want to save off the original Flow Control configuration just
@@ -1200,12 +785,9 @@ s32 e1000_setup_link(struct e1000_hw *hw)
      */
     DEBUGOUT("Initializing the Flow Control address, type and timer regs\n");
 
-    /* FCAL/H and FCT are hardcoded to standard values in e1000_ich8lan. */
-    if (hw->mac_type != e1000_ich8lan) {
-        ew32(FCT, FLOW_CONTROL_TYPE);
-        ew32(FCAH, FLOW_CONTROL_ADDRESS_HIGH);
-        ew32(FCAL, FLOW_CONTROL_ADDRESS_LOW);
-    }
+    ew32(FCT, FLOW_CONTROL_TYPE);
+    ew32(FCAH, FLOW_CONTROL_ADDRESS_HIGH);
+    ew32(FCAL, FLOW_CONTROL_ADDRESS_LOW);
 
     ew32(FCTTV, hw->fc_pause_time);
 
@@ -1253,14 +835,6 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_setup_fiber_serdes_link");
 
-    /* On 82571 and 82572 Fiber connections, SerDes loopback mode persists
-     * until explicitly turned off or a power cycle is performed.  A read to
-     * the register does not indicate its status.  Therefore, we ensure
-     * loopback mode is disabled during initialization.
-     */
-    if (hw->mac_type == e1000_82571 || hw->mac_type == e1000_82572)
-        ew32(SCTL, E1000_DISABLE_SERDES_LOOPBACK);
-
     /* On adapters with a MAC newer than 82544, SWDP 1 will be
      * set when the optics detect a signal. On older adapters, it will be
      * cleared when there is a signal.  This applies to fiber media only.
@@ -1466,13 +1040,11 @@ static s32 e1000_copper_link_igp_setup(struct e1000_hw *hw)
 
     /* Wait 15ms for MAC to configure PHY from eeprom settings */
     msleep(15);
-    if (hw->mac_type != e1000_ich8lan) {
     /* Configure activity LED after PHY reset */
     led_ctrl = er32(LEDCTL);
     led_ctrl &= IGP_ACTIVITY_LED_MASK;
     led_ctrl |= (IGP_ACTIVITY_LED_ENABLE | IGP_LED3_MODE);
     ew32(LEDCTL, led_ctrl);
-    }
 
     /* The NVM settings will configure LPLU in D3 for IGP2 and IGP3 PHYs */
     if (hw->phy_type == e1000_phy_igp) {
@@ -1484,12 +1056,6 @@ static s32 e1000_copper_link_igp_setup(struct e1000_hw *hw)
         }
     }
 
-    /* disable lplu d0 during driver init */
-    ret_val = e1000_set_d0_lplu_state(hw, false);
-    if (ret_val) {
-        DEBUGOUT("Error Disabling LPLU D0\n");
-        return ret_val;
-    }
     /* Configure mdi-mdix settings */
     ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CTRL, &phy_data);
     if (ret_val)
@@ -1589,153 +1155,6 @@ static s32 e1000_copper_link_igp_setup(struct e1000_hw *hw)
 }
 
 /********************************************************************
-* Copper link setup for e1000_phy_gg82563 series.
-*
-* hw - Struct containing variables accessed by shared code
-*********************************************************************/
-static s32 e1000_copper_link_ggp_setup(struct e1000_hw *hw)
-{
-    s32 ret_val;
-    u16 phy_data;
-    u32 reg_data;
-
-    DEBUGFUNC("e1000_copper_link_ggp_setup");
-
-    if (!hw->phy_reset_disable) {
-
-        /* Enable CRS on TX for half-duplex operation. */
-        ret_val = e1000_read_phy_reg(hw, GG82563_PHY_MAC_SPEC_CTRL,
-                                     &phy_data);
-        if (ret_val)
-            return ret_val;
-
-        phy_data |= GG82563_MSCR_ASSERT_CRS_ON_TX;
-        /* Use 25MHz for both link down and 1000BASE-T for Tx clock */
-        phy_data |= GG82563_MSCR_TX_CLK_1000MBPS_25MHZ;
-
-        ret_val = e1000_write_phy_reg(hw, GG82563_PHY_MAC_SPEC_CTRL,
-                                      phy_data);
-        if (ret_val)
-            return ret_val;
-
-        /* Options:
-         *   MDI/MDI-X = 0 (default)
-         *   0 - Auto for all speeds
-         *   1 - MDI mode
-         *   2 - MDI-X mode
-         *   3 - Auto for 1000Base-T only (MDI-X for 10/100Base-T modes)
-         */
-        ret_val = e1000_read_phy_reg(hw, GG82563_PHY_SPEC_CTRL, &phy_data);
-        if (ret_val)
-            return ret_val;
-
-        phy_data &= ~GG82563_PSCR_CROSSOVER_MODE_MASK;
-
-        switch (hw->mdix) {
-        case 1:
-            phy_data |= GG82563_PSCR_CROSSOVER_MODE_MDI;
-            break;
-        case 2:
-            phy_data |= GG82563_PSCR_CROSSOVER_MODE_MDIX;
-            break;
-        case 0:
-        default:
-            phy_data |= GG82563_PSCR_CROSSOVER_MODE_AUTO;
-            break;
-        }
-
-        /* Options:
-         *   disable_polarity_correction = 0 (default)
-         *       Automatic Correction for Reversed Cable Polarity
-         *   0 - Disabled
-         *   1 - Enabled
-         */
-        phy_data &= ~GG82563_PSCR_POLARITY_REVERSAL_DISABLE;
-        if (hw->disable_polarity_correction == 1)
-            phy_data |= GG82563_PSCR_POLARITY_REVERSAL_DISABLE;
-        ret_val = e1000_write_phy_reg(hw, GG82563_PHY_SPEC_CTRL, phy_data);
-
-        if (ret_val)
-            return ret_val;
-
-        /* SW Reset the PHY so all changes take effect */
-        ret_val = e1000_phy_reset(hw);
-        if (ret_val) {
-            DEBUGOUT("Error Resetting the PHY\n");
-            return ret_val;
-        }
-    } /* phy_reset_disable */
-
-    if (hw->mac_type == e1000_80003es2lan) {
-        /* Bypass RX and TX FIFO's */
-        ret_val = e1000_write_kmrn_reg(hw, E1000_KUMCTRLSTA_OFFSET_FIFO_CTRL,
-                                       E1000_KUMCTRLSTA_FIFO_CTRL_RX_BYPASS |
-                                       E1000_KUMCTRLSTA_FIFO_CTRL_TX_BYPASS);
-        if (ret_val)
-            return ret_val;
-
-        ret_val = e1000_read_phy_reg(hw, GG82563_PHY_SPEC_CTRL_2, &phy_data);
-        if (ret_val)
-            return ret_val;
-
-        phy_data &= ~GG82563_PSCR2_REVERSE_AUTO_NEG;
-        ret_val = e1000_write_phy_reg(hw, GG82563_PHY_SPEC_CTRL_2, phy_data);
-
-        if (ret_val)
-            return ret_val;
-
-        reg_data = er32(CTRL_EXT);
-        reg_data &= ~(E1000_CTRL_EXT_LINK_MODE_MASK);
-        ew32(CTRL_EXT, reg_data);
-
-        ret_val = e1000_read_phy_reg(hw, GG82563_PHY_PWR_MGMT_CTRL,
-                                          &phy_data);
-        if (ret_val)
-            return ret_val;
-
-        /* Do not init these registers when the HW is in IAMT mode, since the
-         * firmware will have already initialized them.  We only initialize
-         * them if the HW is not in IAMT mode.
-         */
-        if (!e1000_check_mng_mode(hw)) {
-            /* Enable Electrical Idle on the PHY */
-            phy_data |= GG82563_PMCR_ENABLE_ELECTRICAL_IDLE;
-            ret_val = e1000_write_phy_reg(hw, GG82563_PHY_PWR_MGMT_CTRL,
-                                          phy_data);
-            if (ret_val)
-                return ret_val;
-
-            ret_val = e1000_read_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL,
-                                         &phy_data);
-            if (ret_val)
-                return ret_val;
-
-            phy_data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
-            ret_val = e1000_write_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL,
-                                          phy_data);
-
-            if (ret_val)
-                return ret_val;
-        }
-
-        /* Workaround: Disable padding in Kumeran interface in the MAC
-         * and in the PHY to avoid CRC errors.
-         */
-        ret_val = e1000_read_phy_reg(hw, GG82563_PHY_INBAND_CTRL,
-                                     &phy_data);
-        if (ret_val)
-            return ret_val;
-        phy_data |= GG82563_ICR_DIS_PADDING;
-        ret_val = e1000_write_phy_reg(hw, GG82563_PHY_INBAND_CTRL,
-                                      phy_data);
-        if (ret_val)
-            return ret_val;
-    }
-
-    return E1000_SUCCESS;
-}
-
-/********************************************************************
 * Copper link setup for e1000_phy_m88 series.
 *
 * hw - Struct containing variables accessed by shared code
@@ -1861,10 +1280,6 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
     if (hw->autoneg_advertised == 0)
         hw->autoneg_advertised = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
-    /* IFE phy only supports 10/100 */
-    if (hw->phy_type == e1000_phy_ife)
-        hw->autoneg_advertised &= AUTONEG_ADVERTISE_10_100_ALL;
-
     DEBUGOUT("Reconfiguring auto-neg advertisement params\n");
     ret_val = e1000_phy_setup_autoneg(hw);
     if (ret_val) {
@@ -1955,52 +1370,15 @@ static s32 e1000_setup_copper_link(struct e1000_hw *hw)
     s32 ret_val;
     u16 i;
     u16 phy_data;
-    u16 reg_data = 0;
 
     DEBUGFUNC("e1000_setup_copper_link");
 
-    switch (hw->mac_type) {
-    case e1000_80003es2lan:
-    case e1000_ich8lan:
-        /* Set the mac to wait the maximum time between each
-         * iteration and increase the max iterations when
-         * polling the phy; this fixes erroneous timeouts at 10Mbps. */
-        ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 4), 0xFFFF);
-        if (ret_val)
-            return ret_val;
-        ret_val = e1000_read_kmrn_reg(hw, GG82563_REG(0x34, 9), &reg_data);
-        if (ret_val)
-            return ret_val;
-        reg_data |= 0x3F;
-        ret_val = e1000_write_kmrn_reg(hw, GG82563_REG(0x34, 9), reg_data);
-        if (ret_val)
-            return ret_val;
-    default:
-        break;
-    }
-
     /* Check if it is a valid PHY and set PHY mode if necessary. */
     ret_val = e1000_copper_link_preconfig(hw);
     if (ret_val)
         return ret_val;
 
-    switch (hw->mac_type) {
-    case e1000_80003es2lan:
-        /* Kumeran registers are written-only */
-        reg_data = E1000_KUMCTRLSTA_INB_CTRL_LINK_STATUS_TX_TIMEOUT_DEFAULT;
-        reg_data |= E1000_KUMCTRLSTA_INB_CTRL_DIS_PADDING;
-        ret_val = e1000_write_kmrn_reg(hw, E1000_KUMCTRLSTA_OFFSET_INB_CTRL,
-                                       reg_data);
-        if (ret_val)
-            return ret_val;
-        break;
-    default:
-        break;
-    }
-
-    if (hw->phy_type == e1000_phy_igp ||
-        hw->phy_type == e1000_phy_igp_3 ||
-        hw->phy_type == e1000_phy_igp_2) {
+    if (hw->phy_type == e1000_phy_igp) {
         ret_val = e1000_copper_link_igp_setup(hw);
         if (ret_val)
             return ret_val;
@@ -2008,10 +1386,6 @@ static s32 e1000_setup_copper_link(struct e1000_hw *hw)
         ret_val = e1000_copper_link_mgp_setup(hw);
         if (ret_val)
             return ret_val;
-    } else if (hw->phy_type == e1000_phy_gg82563) {
-        ret_val = e1000_copper_link_ggp_setup(hw);
-        if (ret_val)
-            return ret_val;
     }
 
     if (hw->autoneg) {
@@ -2059,77 +1433,6 @@ static s32 e1000_setup_copper_link(struct e1000_hw *hw)
 }
 
 /******************************************************************************
-* Configure the MAC-to-PHY interface for 10/100Mbps
-*
-* hw - Struct containing variables accessed by shared code
-******************************************************************************/
-static s32 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex)
-{
-    s32 ret_val = E1000_SUCCESS;
-    u32 tipg;
-    u16 reg_data;
-
-    DEBUGFUNC("e1000_configure_kmrn_for_10_100");
-
-    reg_data = E1000_KUMCTRLSTA_HD_CTRL_10_100_DEFAULT;
-    ret_val = e1000_write_kmrn_reg(hw, E1000_KUMCTRLSTA_OFFSET_HD_CTRL,
-                                   reg_data);
-    if (ret_val)
-        return ret_val;
-
-    /* Configure Transmit Inter-Packet Gap */
-    tipg = er32(TIPG);
-    tipg &= ~E1000_TIPG_IPGT_MASK;
-    tipg |= DEFAULT_80003ES2LAN_TIPG_IPGT_10_100;
-    ew32(TIPG, tipg);
-
-    ret_val = e1000_read_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
-
-    if (ret_val)
-        return ret_val;
-
-    if (duplex == HALF_DUPLEX)
-        reg_data |= GG82563_KMCR_PASS_FALSE_CARRIER;
-    else
-        reg_data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
-
-    ret_val = e1000_write_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL, reg_data);
-
-    return ret_val;
-}
-
-static s32 e1000_configure_kmrn_for_1000(struct e1000_hw *hw)
-{
-    s32 ret_val = E1000_SUCCESS;
-    u16 reg_data;
-    u32 tipg;
-
-    DEBUGFUNC("e1000_configure_kmrn_for_1000");
-
-    reg_data = E1000_KUMCTRLSTA_HD_CTRL_1000_DEFAULT;
-    ret_val = e1000_write_kmrn_reg(hw, E1000_KUMCTRLSTA_OFFSET_HD_CTRL,
-                                   reg_data);
-    if (ret_val)
-        return ret_val;
-
-    /* Configure Transmit Inter-Packet Gap */
-    tipg = er32(TIPG);
-    tipg &= ~E1000_TIPG_IPGT_MASK;
-    tipg |= DEFAULT_80003ES2LAN_TIPG_IPGT_1000;
-    ew32(TIPG, tipg);
-
-    ret_val = e1000_read_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
-
-    if (ret_val)
-        return ret_val;
-
-    reg_data &= ~GG82563_KMCR_PASS_FALSE_CARRIER;
-    ret_val = e1000_write_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL, reg_data);
-
-    return ret_val;
-}
-
-/******************************************************************************
 * Configures PHY autoneg and flow control advertisement settings
 *
 * hw - Struct containing variables accessed by shared code
@@ -2147,13 +1450,10 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
     if (ret_val)
         return ret_val;
 
-    if (hw->phy_type != e1000_phy_ife) {
-        /* Read the MII 1000Base-T Control Register (Address 9). */
-        ret_val = e1000_read_phy_reg(hw, PHY_1000T_CTRL, &mii_1000t_ctrl_reg);
-        if (ret_val)
-            return ret_val;
-    } else
-        mii_1000t_ctrl_reg=0;
+    /* Read the MII 1000Base-T Control Register (Address 9). */
+    ret_val = e1000_read_phy_reg(hw, PHY_1000T_CTRL, &mii_1000t_ctrl_reg);
+    if (ret_val)
+        return ret_val;
 
     /* Need to parse both autoneg_advertised and fc and set up
      * the appropriate PHY registers.  First we will parse for
@@ -2204,9 +1504,6 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
     if (hw->autoneg_advertised & ADVERTISE_1000_FULL) {
         DEBUGOUT("Advertise 1000mb Full duplex\n");
         mii_1000t_ctrl_reg |= CR_1000T_FD_CAPS;
-        if (hw->phy_type == e1000_phy_ife) {
-            DEBUGOUT("e1000_phy_ife is a 10/100 PHY. Gigabit speed is not supported.\n");
-        }
     }
 
     /* Check for a software override of the flow control settings, and
@@ -2268,11 +1565,9 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 
     DEBUGOUT1("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
-    if (hw->phy_type != e1000_phy_ife) {
-        ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
-        if (ret_val)
-            return ret_val;
-    }
+    ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
+    if (ret_val)
+        return ret_val;
 
     return E1000_SUCCESS;
 }
@@ -2356,8 +1651,7 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
     /* Write the configured values back to the Device Control Reg. */
     ew32(CTRL, ctrl);
 
-    if ((hw->phy_type == e1000_phy_m88) ||
-        (hw->phy_type == e1000_phy_gg82563)) {
+    if (hw->phy_type == e1000_phy_m88) {
         ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
         if (ret_val)
             return ret_val;
@@ -2375,19 +1669,6 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
         /* Need to reset the PHY or these changes will be ignored */
         mii_ctrl_reg |= MII_CR_RESET;
 
-    /* Disable MDI-X support for 10/100 */
-    } else if (hw->phy_type == e1000_phy_ife) {
-        ret_val = e1000_read_phy_reg(hw, IFE_PHY_MDIX_CONTROL, &phy_data);
-        if (ret_val)
-            return ret_val;
-
-        phy_data &= ~IFE_PMC_AUTO_MDIX;
-        phy_data &= ~IFE_PMC_FORCE_MDIX;
-
-        ret_val = e1000_write_phy_reg(hw, IFE_PHY_MDIX_CONTROL, phy_data);
-        if (ret_val)
-            return ret_val;
-
     } else {
         /* Clear Auto-Crossover to force MDI manually.  IGP requires MDI
          * forced whenever speed or duplex are forced.
@@ -2440,8 +1721,7 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
             msleep(100);
         }
         if ((i == 0) &&
-           ((hw->phy_type == e1000_phy_m88) ||
-            (hw->phy_type == e1000_phy_gg82563))) {
+           (hw->phy_type == e1000_phy_m88)) {
             /* We didn't get link.  Reset the DSP and wait again for link. */
             ret_val = e1000_phy_reset_dsp(hw);
             if (ret_val) {
@@ -2499,27 +1779,6 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
             if (ret_val)
                 return ret_val;
         }
-    } else if (hw->phy_type == e1000_phy_gg82563) {
-        /* The TX_CLK of the Extended PHY Specific Control Register defaults
-         * to 2.5MHz on a reset.  We need to re-force it back to 25MHz, if
-         * we're not in a forced 10/duplex configuration. */
-        ret_val = e1000_read_phy_reg(hw, GG82563_PHY_MAC_SPEC_CTRL, &phy_data);
-        if (ret_val)
-            return ret_val;
-
-        phy_data &= ~GG82563_MSCR_TX_CLK_MASK;
-        if ((hw->forced_speed_duplex == e1000_10_full) ||
-            (hw->forced_speed_duplex == e1000_10_half))
-            phy_data |= GG82563_MSCR_TX_CLK_10MBPS_2_5MHZ;
-        else
-            phy_data |= GG82563_MSCR_TX_CLK_100MBPS_25MHZ;
-
-        /* Also due to the reset, we need to enable CRS on Tx. */
-        phy_data |= GG82563_MSCR_ASSERT_CRS_ON_TX;
-
-        ret_val = e1000_write_phy_reg(hw, GG82563_PHY_MAC_SPEC_CTRL, phy_data);
-        if (ret_val)
-            return ret_val;
     }
     return E1000_SUCCESS;
 }
@@ -3179,22 +2438,6 @@ s32 e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 *duplex)
         }
     }
 
-    if ((hw->mac_type == e1000_80003es2lan) &&
-        (hw->media_type == e1000_media_type_copper)) {
-        if (*speed == SPEED_1000)
-            ret_val = e1000_configure_kmrn_for_1000(hw);
-        else
-            ret_val = e1000_configure_kmrn_for_10_100(hw, *duplex);
-        if (ret_val)
-            return ret_val;
-    }
-
-    if ((hw->phy_type == e1000_phy_igp_3) && (*speed == SPEED_1000)) {
-        ret_val = e1000_kumeran_lock_loss_workaround(hw);
-        if (ret_val)
-            return ret_val;
-    }
-
     return E1000_SUCCESS;
 }
 
@@ -3373,9 +2616,6 @@ static s32 e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
 
     DEBUGFUNC("e1000_swfw_sync_acquire");
 
-    if (hw->swfwhw_semaphore_present)
-        return e1000_get_software_flag(hw);
-
     if (!hw->swfw_sync_present)
         return e1000_get_hw_eeprom_semaphore(hw);
 
@@ -3414,11 +2654,6 @@ static void e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
 
     DEBUGFUNC("e1000_swfw_sync_release");
 
-    if (hw->swfwhw_semaphore_present) {
-        e1000_release_software_flag(hw);
-        return;
-    }
-
     if (!hw->swfw_sync_present) {
         e1000_put_hw_eeprom_semaphore(hw);
         return;
@@ -3449,46 +2684,18 @@ s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data)
 
     DEBUGFUNC("e1000_read_phy_reg");
 
-    if ((hw->mac_type == e1000_80003es2lan) &&
-        (er32(STATUS) & E1000_STATUS_FUNC_1)) {
-        swfw = E1000_SWFW_PHY1_SM;
-    } else {
-        swfw = E1000_SWFW_PHY0_SM;
-    }
+    swfw = E1000_SWFW_PHY0_SM;
     if (e1000_swfw_sync_acquire(hw, swfw))
         return -E1000_ERR_SWFW_SYNC;
 
-    if ((hw->phy_type == e1000_phy_igp ||
-        hw->phy_type == e1000_phy_igp_3 ||
-        hw->phy_type == e1000_phy_igp_2) &&
-       (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
+    if ((hw->phy_type == e1000_phy_igp) &&
+        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
                                          (u16)reg_addr);
         if (ret_val) {
             e1000_swfw_sync_release(hw, swfw);
             return ret_val;
         }
-    } else if (hw->phy_type == e1000_phy_gg82563) {
-        if (((reg_addr & MAX_PHY_REG_ADDRESS) > MAX_PHY_MULTI_PAGE_REG) ||
-            (hw->mac_type == e1000_80003es2lan)) {
-            /* Select Configuration Page */
-            if ((reg_addr & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG) {
-                ret_val = e1000_write_phy_reg_ex(hw, GG82563_PHY_PAGE_SELECT,
-                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
-            } else {
-                /* Use Alternative Page Select register to access
-                 * registers 30 and 31
-                 */
-                ret_val = e1000_write_phy_reg_ex(hw,
-                                                 GG82563_PHY_PAGE_SELECT_ALT,
-                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
-            }
-
-            if (ret_val) {
-                e1000_swfw_sync_release(hw, swfw);
-                return ret_val;
-            }
-        }
     }
 
     ret_val = e1000_read_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
@@ -3584,46 +2791,18 @@ s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 phy_data)
 
     DEBUGFUNC("e1000_write_phy_reg");
 
-    if ((hw->mac_type == e1000_80003es2lan) &&
-        (er32(STATUS) & E1000_STATUS_FUNC_1)) {
-        swfw = E1000_SWFW_PHY1_SM;
-    } else {
-        swfw = E1000_SWFW_PHY0_SM;
-    }
+    swfw = E1000_SWFW_PHY0_SM;
     if (e1000_swfw_sync_acquire(hw, swfw))
         return -E1000_ERR_SWFW_SYNC;
 
-    if ((hw->phy_type == e1000_phy_igp ||
-        hw->phy_type == e1000_phy_igp_3 ||
-        hw->phy_type == e1000_phy_igp_2) &&
-       (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
+    if ((hw->phy_type == e1000_phy_igp) &&
+        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
                                          (u16)reg_addr);
         if (ret_val) {
             e1000_swfw_sync_release(hw, swfw);
             return ret_val;
         }
-    } else if (hw->phy_type == e1000_phy_gg82563) {
-        if (((reg_addr & MAX_PHY_REG_ADDRESS) > MAX_PHY_MULTI_PAGE_REG) ||
-            (hw->mac_type == e1000_80003es2lan)) {
-            /* Select Configuration Page */
-            if ((reg_addr & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG) {
-                ret_val = e1000_write_phy_reg_ex(hw, GG82563_PHY_PAGE_SELECT,
-                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
-            } else {
-                /* Use Alternative Page Select register to access
-                 * registers 30 and 31
-                 */
-                ret_val = e1000_write_phy_reg_ex(hw,
-                                                 GG82563_PHY_PAGE_SELECT_ALT,
-                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
-            }
-
-            if (ret_val) {
-                e1000_swfw_sync_release(hw, swfw);
-                return ret_val;
-            }
-        }
     }
 
     ret_val = e1000_write_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
@@ -3694,60 +2873,6 @@ static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
     return E1000_SUCCESS;
 }
 
-static s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 *data)
-{
-    u32 reg_val;
-    u16 swfw;
-    DEBUGFUNC("e1000_read_kmrn_reg");
-
-    if ((hw->mac_type == e1000_80003es2lan) &&
-        (er32(STATUS) & E1000_STATUS_FUNC_1)) {
-        swfw = E1000_SWFW_PHY1_SM;
-    } else {
-        swfw = E1000_SWFW_PHY0_SM;
-    }
-    if (e1000_swfw_sync_acquire(hw, swfw))
-        return -E1000_ERR_SWFW_SYNC;
-
-    /* Write register address */
-    reg_val = ((reg_addr << E1000_KUMCTRLSTA_OFFSET_SHIFT) &
-              E1000_KUMCTRLSTA_OFFSET) |
-              E1000_KUMCTRLSTA_REN;
-    ew32(KUMCTRLSTA, reg_val);
-    udelay(2);
-
-    /* Read the data returned */
-    reg_val = er32(KUMCTRLSTA);
-    *data = (u16)reg_val;
-
-    e1000_swfw_sync_release(hw, swfw);
-    return E1000_SUCCESS;
-}
-
-static s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 data)
-{
-    u32 reg_val;
-    u16 swfw;
-    DEBUGFUNC("e1000_write_kmrn_reg");
-
-    if ((hw->mac_type == e1000_80003es2lan) &&
-        (er32(STATUS) & E1000_STATUS_FUNC_1)) {
-        swfw = E1000_SWFW_PHY1_SM;
-    } else {
-        swfw = E1000_SWFW_PHY0_SM;
-    }
-    if (e1000_swfw_sync_acquire(hw, swfw))
-        return -E1000_ERR_SWFW_SYNC;
-
-    reg_val = ((reg_addr << E1000_KUMCTRLSTA_OFFSET_SHIFT) &
-              E1000_KUMCTRLSTA_OFFSET) | data;
-    ew32(KUMCTRLSTA, reg_val);
-    udelay(2);
-
-    e1000_swfw_sync_release(hw, swfw);
-    return E1000_SUCCESS;
-}
-
 /******************************************************************************
 * Returns the PHY to the power-on reset state
 *
@@ -3762,46 +2887,28 @@ s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_phy_hw_reset");
 
-    /* In the case of the phy reset being blocked, it's not an error, we
-     * simply return success without performing the reset. */
-    ret_val = e1000_check_phy_reset_block(hw);
-    if (ret_val)
-        return E1000_SUCCESS;
-
     DEBUGOUT("Resetting Phy...\n");
 
     if (hw->mac_type > e1000_82543) {
-        if ((hw->mac_type == e1000_80003es2lan) &&
-            (er32(STATUS) & E1000_STATUS_FUNC_1)) {
-            swfw = E1000_SWFW_PHY1_SM;
-        } else {
-            swfw = E1000_SWFW_PHY0_SM;
-        }
+        swfw = E1000_SWFW_PHY0_SM;
         if (e1000_swfw_sync_acquire(hw, swfw)) {
             DEBUGOUT("Unable to acquire swfw sync\n");
             return -E1000_ERR_SWFW_SYNC;
         }
         /* Read the device control register and assert the E1000_CTRL_PHY_RST
          * bit. Then, take it out of reset.
-         * For pre-e1000_82571 hardware, we delay for 10ms between the assert
-         * and deassert.  For e1000_82571 hardware and later, we instead delay
-         * for 50us between and 10ms after the deassertion.
+         * For e1000 hardware, we delay for 10ms between the assert
+         * and deassert.
          */
         ctrl = er32(CTRL);
         ew32(CTRL, ctrl | E1000_CTRL_PHY_RST);
         E1000_WRITE_FLUSH();
 
-        if (hw->mac_type < e1000_82571)
-            msleep(10);
-        else
-            udelay(100);
+        msleep(10);
 
         ew32(CTRL, ctrl);
         E1000_WRITE_FLUSH();
 
-        if (hw->mac_type >= e1000_82571)
-            mdelay(10);
-
         e1000_swfw_sync_release(hw, swfw);
     } else {
         /* Read the Extended Device Control Register, assert the PHY_RESET_DIR
@@ -3831,10 +2938,6 @@ s32 e1000_phy_hw_reset(struct e1000_hw *hw)
     ret_val = e1000_get_phy_cfg_done(hw);
     if (ret_val != E1000_SUCCESS)
         return ret_val;
-    e1000_release_software_semaphore(hw);
-
-    if ((hw->mac_type == e1000_ich8lan) && (hw->phy_type == e1000_phy_igp_3))
-        ret_val = e1000_init_lcd_from_nvm(hw);
 
     return ret_val;
 }
@@ -3853,17 +2956,8 @@ s32 e1000_phy_reset(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_phy_reset");
 
-    /* In the case of the phy reset being blocked, it's not an error, we
-     * simply return success without performing the reset. */
-    ret_val = e1000_check_phy_reset_block(hw);
-    if (ret_val)
-        return E1000_SUCCESS;
-
     switch (hw->phy_type) {
     case e1000_phy_igp:
-    case e1000_phy_igp_2:
-    case e1000_phy_igp_3:
-    case e1000_phy_ife:
         ret_val = e1000_phy_hw_reset(hw);
         if (ret_val)
             return ret_val;
@@ -3882,121 +2976,13 @@ s32 e1000_phy_reset(struct e1000_hw *hw)
         break;
     }
 
-    if (hw->phy_type == e1000_phy_igp || hw->phy_type == e1000_phy_igp_2)
+    if (hw->phy_type == e1000_phy_igp)
         e1000_phy_init_script(hw);
 
     return E1000_SUCCESS;
 }
 
 /******************************************************************************
-* Work-around for 82566 power-down: on D3 entry-
-* 1) disable gigabit link
-* 2) write VR power-down enable
-* 3) read it back
-* if successful continue, else issue LCD reset and repeat
-*
-* hw - struct containing variables accessed by shared code
-******************************************************************************/
-void e1000_phy_powerdown_workaround(struct e1000_hw *hw)
-{
-    s32 reg;
-    u16 phy_data;
-    s32 retry = 0;
-
-    DEBUGFUNC("e1000_phy_powerdown_workaround");
-
-    if (hw->phy_type != e1000_phy_igp_3)
-        return;
-
-    do {
-        /* Disable link */
-        reg = er32(PHY_CTRL);
-        ew32(PHY_CTRL, reg | E1000_PHY_CTRL_GBE_DISABLE |
-                        E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
-
-        /* Write VR power-down enable - bits 9:8 should be 10b */
-        e1000_read_phy_reg(hw, IGP3_VR_CTRL, &phy_data);
-        phy_data |= (1 << 9);
-        phy_data &= ~(1 << 8);
-        e1000_write_phy_reg(hw, IGP3_VR_CTRL, phy_data);
-
-        /* Read it back and test */
-        e1000_read_phy_reg(hw, IGP3_VR_CTRL, &phy_data);
-        if (((phy_data & IGP3_VR_CTRL_MODE_MASK) == IGP3_VR_CTRL_MODE_SHUT) || retry)
-            break;
-
-        /* Issue PHY reset and repeat at most one more time */
-        reg = er32(CTRL);
-        ew32(CTRL, reg | E1000_CTRL_PHY_RST);
-        retry++;
-    } while (retry);
-
-    return;
-
-}
-
-/******************************************************************************
-* Work-around for 82566 Kumeran PCS lock loss:
-* On link status change (i.e. PCI reset, speed change) and link is up and
-* speed is gigabit-
-* 0) if workaround is optionally disabled do nothing
-* 1) wait 1ms for Kumeran link to come up
-* 2) check Kumeran Diagnostic register PCS lock loss bit
-* 3) if not set the link is locked (all is good), otherwise...
-* 4) reset the PHY
-* 5) repeat up to 10 times
-* Note: this is only called for IGP3 copper when speed is 1gb.
-*
-* hw - struct containing variables accessed by shared code
-******************************************************************************/
-static s32 e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
-{
-    s32 ret_val;
-    s32 reg;
-    s32 cnt;
-    u16 phy_data;
-
-    if (hw->kmrn_lock_loss_workaround_disabled)
-        return E1000_SUCCESS;
-
-    /* Make sure link is up before proceeding.  If not just return.
-     * Attempting this while link is negotiating fouled up link
-     * stability */
-    ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &phy_data);
-    ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &phy_data);
-
-    if (phy_data & MII_SR_LINK_STATUS) {
-        for (cnt = 0; cnt < 10; cnt++) {
-            /* read once to clear */
-            ret_val = e1000_read_phy_reg(hw, IGP3_KMRN_DIAG, &phy_data);
-            if (ret_val)
-                return ret_val;
-            /* and again to get new status */
-            ret_val = e1000_read_phy_reg(hw, IGP3_KMRN_DIAG, &phy_data);
-            if (ret_val)
-                return ret_val;
-
-            /* check for PCS lock */
-            if (!(phy_data & IGP3_KMRN_DIAG_PCS_LOCK_LOSS))
-                return E1000_SUCCESS;
-
-            /* Issue PHY reset */
-            e1000_phy_hw_reset(hw);
-            mdelay(5);
-        }
-        /* Disable GigE link negotiation */
-        reg = er32(PHY_CTRL);
-        ew32(PHY_CTRL, reg | E1000_PHY_CTRL_GBE_DISABLE |
-                        E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
-
-        /* unable to acquire PCS lock */
-        return E1000_ERR_PHY;
-    }
-
-    return E1000_SUCCESS;
-}
-
-/******************************************************************************
 * Probes the expected PHY address for known PHY IDs
 *
 * hw - Struct containing variables accessed by shared code
@@ -4012,25 +2998,6 @@ static s32 e1000_detect_gig_phy(struct e1000_hw *hw)
     if (hw->phy_id != 0)
         return E1000_SUCCESS;
 
-    /* The 82571 firmware may still be configuring the PHY.  In this
-     * case, we cannot access the PHY until the configuration is done.  So
-     * we explicitly set the PHY values. */
-    if (hw->mac_type == e1000_82571 ||
-        hw->mac_type == e1000_82572) {
-        hw->phy_id = IGP01E1000_I_PHY_ID;
-        hw->phy_type = e1000_phy_igp_2;
-        return E1000_SUCCESS;
-    }
-
-    /* ESB-2 PHY reads require e1000_phy_gg82563 to be set because of a work-
-     * around that forces PHY page 0 to be set or the reads fail.  The rest of
-     * the code in this routine uses e1000_read_phy_reg to read the PHY ID.
-     * So for ESB-2 we need to have this set so our reads won't fail.  If the
-     * attached PHY is not a e1000_phy_gg82563, the routines below will figure
-     * this out as well. */
-    if (hw->mac_type == e1000_80003es2lan)
-        hw->phy_type = e1000_phy_gg82563;
-
     /* Read the PHY ID Registers to identify which PHY is onboard. */
     ret_val = e1000_read_phy_reg(hw, PHY_ID1, &phy_id_high);
     if (ret_val)
@@ -4065,18 +3032,6 @@ static s32 e1000_detect_gig_phy(struct e1000_hw *hw)
     case e1000_82547_rev_2:
         if (hw->phy_id == IGP01E1000_I_PHY_ID) match = true;
         break;
-    case e1000_82573:
-        if (hw->phy_id == M88E1111_I_PHY_ID) match = true;
-        break;
-    case e1000_80003es2lan:
-        if (hw->phy_id == GG82563_E_PHY_ID) match = true;
-        break;
-    case e1000_ich8lan:
-        if (hw->phy_id == IGP03E1000_E_PHY_ID) match = true;
-        if (hw->phy_id == IFE_E_PHY_ID) match = true;
-        if (hw->phy_id == IFE_PLUS_E_PHY_ID) match = true;
-        if (hw->phy_id == IFE_C_E_PHY_ID) match = true;
-        break;
     default:
         DEBUGOUT1("Invalid MAC type %d\n", hw->mac_type);
         return -E1000_ERR_CONFIG;
@@ -4102,10 +3057,8 @@ static s32 e1000_phy_reset_dsp(struct e1000_hw *hw)
     DEBUGFUNC("e1000_phy_reset_dsp");
 
     do {
-        if (hw->phy_type != e1000_phy_gg82563) {
-            ret_val = e1000_write_phy_reg(hw, 29, 0x001d);
-            if (ret_val) break;
-        }
+        ret_val = e1000_write_phy_reg(hw, 29, 0x001d);
+        if (ret_val) break;
         ret_val = e1000_write_phy_reg(hw, 30, 0x00c1);
         if (ret_val) break;
         ret_val = e1000_write_phy_reg(hw, 30, 0x0000);
@@ -4192,54 +3145,6 @@ static s32 e1000_phy_igp_get_info(struct e1000_hw *hw,
     return E1000_SUCCESS;
 }
 
-/******************************************************************************
-* Get PHY information from various PHY registers for ife PHY only.
-*
-* hw - Struct containing variables accessed by shared code
-* phy_info - PHY information structure
-******************************************************************************/
-static s32 e1000_phy_ife_get_info(struct e1000_hw *hw,
-				  struct e1000_phy_info *phy_info)
-{
-    s32 ret_val;
-    u16 phy_data;
-    e1000_rev_polarity polarity;
-
-    DEBUGFUNC("e1000_phy_ife_get_info");
-
-    phy_info->downshift = (e1000_downshift)hw->speed_downgraded;
-    phy_info->extended_10bt_distance = e1000_10bt_ext_dist_enable_normal;
-
-    ret_val = e1000_read_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL, &phy_data);
-    if (ret_val)
-        return ret_val;
-    phy_info->polarity_correction =
-                        ((phy_data & IFE_PSC_AUTO_POLARITY_DISABLE) >>
-                        IFE_PSC_AUTO_POLARITY_DISABLE_SHIFT) ?
-                        e1000_polarity_reversal_disabled : e1000_polarity_reversal_enabled;
-
-    if (phy_info->polarity_correction == e1000_polarity_reversal_enabled) {
-        ret_val = e1000_check_polarity(hw, &polarity);
-        if (ret_val)
-            return ret_val;
-    } else {
-        /* Polarity is forced. */
-        polarity = ((phy_data & IFE_PSC_FORCE_POLARITY) >>
-                     IFE_PSC_FORCE_POLARITY_SHIFT) ?
-                     e1000_rev_polarity_reversed : e1000_rev_polarity_normal;
-    }
-    phy_info->cable_polarity = polarity;
-
-    ret_val = e1000_read_phy_reg(hw, IFE_PHY_MDIX_CONTROL, &phy_data);
-    if (ret_val)
-        return ret_val;
-
-    phy_info->mdix_mode = (e1000_auto_x_mode)
-                     ((phy_data & (IFE_PMC_AUTO_MDIX | IFE_PMC_FORCE_MDIX)) >>
-                     IFE_PMC_MDIX_MODE_SHIFT);
-
-    return E1000_SUCCESS;
-}
 
 /******************************************************************************
 * Get PHY information from various PHY registers fot m88 PHY only.
@@ -4291,17 +3196,8 @@ static s32 e1000_phy_m88_get_info(struct e1000_hw *hw,
         /* Cable Length Estimation and Local/Remote Receiver Information
          * are only valid at 1000 Mbps.
          */
-        if (hw->phy_type != e1000_phy_gg82563) {
-            phy_info->cable_length = (e1000_cable_length)((phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
-                                      M88E1000_PSSR_CABLE_LENGTH_SHIFT);
-        } else {
-            ret_val = e1000_read_phy_reg(hw, GG82563_PHY_DSP_DISTANCE,
-                                         &phy_data);
-            if (ret_val)
-                return ret_val;
-
-            phy_info->cable_length = (e1000_cable_length)(phy_data & GG82563_DSPD_CABLE_LENGTH);
-        }
+        phy_info->cable_length = (e1000_cable_length)((phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
+                                  M88E1000_PSSR_CABLE_LENGTH_SHIFT);
 
         ret_val = e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_data);
         if (ret_val)
@@ -4359,12 +3255,8 @@ s32 e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info)
         return -E1000_ERR_CONFIG;
     }
 
-    if (hw->phy_type == e1000_phy_igp ||
-        hw->phy_type == e1000_phy_igp_3 ||
-        hw->phy_type == e1000_phy_igp_2)
+    if (hw->phy_type == e1000_phy_igp)
         return e1000_phy_igp_get_info(hw, phy_info);
-    else if (hw->phy_type == e1000_phy_ife)
-        return e1000_phy_ife_get_info(hw, phy_info);
     else
         return e1000_phy_m88_get_info(hw, phy_info);
 }
@@ -4384,8 +3276,7 @@ s32 e1000_validate_mdi_setting(struct e1000_hw *hw)
 
 /******************************************************************************
  * Sets up eeprom variables in the hw struct.  Must be called after mac_type
- * is configured.  Additionally, if this is ICH8, the flash controller GbE
- * registers must be mapped, or this will crash.
+ * is configured.
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
@@ -4459,89 +3350,6 @@ s32 e1000_init_eeprom_params(struct e1000_hw *hw)
         eeprom->use_eerd = false;
         eeprom->use_eewr = false;
         break;
-    case e1000_82571:
-    case e1000_82572:
-        eeprom->type = e1000_eeprom_spi;
-        eeprom->opcode_bits = 8;
-        eeprom->delay_usec = 1;
-        if (eecd & E1000_EECD_ADDR_BITS) {
-            eeprom->page_size = 32;
-            eeprom->address_bits = 16;
-        } else {
-            eeprom->page_size = 8;
-            eeprom->address_bits = 8;
-        }
-        eeprom->use_eerd = false;
-        eeprom->use_eewr = false;
-        break;
-    case e1000_82573:
-        eeprom->type = e1000_eeprom_spi;
-        eeprom->opcode_bits = 8;
-        eeprom->delay_usec = 1;
-        if (eecd & E1000_EECD_ADDR_BITS) {
-            eeprom->page_size = 32;
-            eeprom->address_bits = 16;
-        } else {
-            eeprom->page_size = 8;
-            eeprom->address_bits = 8;
-        }
-        eeprom->use_eerd = true;
-        eeprom->use_eewr = true;
-        if (!e1000_is_onboard_nvm_eeprom(hw)) {
-            eeprom->type = e1000_eeprom_flash;
-            eeprom->word_size = 2048;
-
-            /* Ensure that the Autonomous FLASH update bit is cleared due to
-             * Flash update issue on parts which use a FLASH for NVM. */
-            eecd &= ~E1000_EECD_AUPDEN;
-            ew32(EECD, eecd);
-        }
-        break;
-    case e1000_80003es2lan:
-        eeprom->type = e1000_eeprom_spi;
-        eeprom->opcode_bits = 8;
-        eeprom->delay_usec = 1;
-        if (eecd & E1000_EECD_ADDR_BITS) {
-            eeprom->page_size = 32;
-            eeprom->address_bits = 16;
-        } else {
-            eeprom->page_size = 8;
-            eeprom->address_bits = 8;
-        }
-        eeprom->use_eerd = true;
-        eeprom->use_eewr = false;
-        break;
-    case e1000_ich8lan:
-        {
-        s32  i = 0;
-        u32 flash_size = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_GFPREG);
-
-        eeprom->type = e1000_eeprom_ich8;
-        eeprom->use_eerd = false;
-        eeprom->use_eewr = false;
-        eeprom->word_size = E1000_SHADOW_RAM_WORDS;
-
-        /* Zero the shadow RAM structure. But don't load it from NVM
-         * so as to save time for driver init */
-        if (hw->eeprom_shadow_ram != NULL) {
-            for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
-                hw->eeprom_shadow_ram[i].modified = false;
-                hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
-            }
-        }
-
-        hw->flash_base_addr = (flash_size & ICH_GFPREG_BASE_MASK) *
-                              ICH_FLASH_SECTOR_SIZE;
-
-        hw->flash_bank_size = ((flash_size >> 16) & ICH_GFPREG_BASE_MASK) + 1;
-        hw->flash_bank_size -= (flash_size & ICH_GFPREG_BASE_MASK);
-
-        hw->flash_bank_size *= ICH_FLASH_SECTOR_SIZE;
-
-        hw->flash_bank_size /= 2 * sizeof(u16);
-
-        break;
-        }
     default:
         break;
     }
@@ -4550,22 +3358,17 @@ s32 e1000_init_eeprom_params(struct e1000_hw *hw)
         /* eeprom_size will be an enum [0..8] that maps to eeprom sizes 128B to
          * 32KB (incremented by powers of 2).
          */
-        if (hw->mac_type <= e1000_82547_rev_2) {
-            /* Set to default value for initial eeprom read. */
-            eeprom->word_size = 64;
-            ret_val = e1000_read_eeprom(hw, EEPROM_CFG, 1, &eeprom_size);
-            if (ret_val)
-                return ret_val;
-            eeprom_size = (eeprom_size & EEPROM_SIZE_MASK) >> EEPROM_SIZE_SHIFT;
-            /* 256B eeprom size was not supported in earlier hardware, so we
-             * bump eeprom_size up one to ensure that "1" (which maps to 256B)
-             * is never the result used in the shifting logic below. */
-            if (eeprom_size)
-                eeprom_size++;
-        } else {
-            eeprom_size = (u16)((eecd & E1000_EECD_SIZE_EX_MASK) >>
-                          E1000_EECD_SIZE_EX_SHIFT);
-        }
+        /* Set to default value for initial eeprom read. */
+        eeprom->word_size = 64;
+        ret_val = e1000_read_eeprom(hw, EEPROM_CFG, 1, &eeprom_size);
+        if (ret_val)
+            return ret_val;
+        eeprom_size = (eeprom_size & EEPROM_SIZE_MASK) >> EEPROM_SIZE_SHIFT;
+        /* 256B eeprom size was not supported in earlier hardware, so we
+         * bump eeprom_size up one to ensure that "1" (which maps to 256B)
+         * is never the result used in the shifting logic below. */
+        if (eeprom_size)
+            eeprom_size++;
 
         eeprom->word_size = 1 << (eeprom_size + EEPROM_WORD_SIZE_SHIFT);
     }
@@ -4716,25 +3519,23 @@ static s32 e1000_acquire_eeprom(struct e1000_hw *hw)
         return -E1000_ERR_SWFW_SYNC;
     eecd = er32(EECD);
 
-    if (hw->mac_type != e1000_82573) {
-        /* Request EEPROM Access */
-        if (hw->mac_type > e1000_82544) {
-            eecd |= E1000_EECD_REQ;
-            ew32(EECD, eecd);
+    /* Request EEPROM Access */
+    if (hw->mac_type > e1000_82544) {
+        eecd |= E1000_EECD_REQ;
+        ew32(EECD, eecd);
+        eecd = er32(EECD);
+        while ((!(eecd & E1000_EECD_GNT)) &&
+               (i < E1000_EEPROM_GRANT_ATTEMPTS)) {
+            i++;
+            udelay(5);
             eecd = er32(EECD);
-            while ((!(eecd & E1000_EECD_GNT)) &&
-                  (i < E1000_EEPROM_GRANT_ATTEMPTS)) {
-                i++;
-                udelay(5);
-                eecd = er32(EECD);
-            }
-            if (!(eecd & E1000_EECD_GNT)) {
-                eecd &= ~E1000_EECD_REQ;
-                ew32(EECD, eecd);
-                DEBUGOUT("Could not acquire EEPROM grant\n");
-                e1000_swfw_sync_release(hw, E1000_SWFW_EEP_SM);
-                return -E1000_ERR_EEPROM;
-            }
+        }
+        if (!(eecd & E1000_EECD_GNT)) {
+            eecd &= ~E1000_EECD_REQ;
+            ew32(EECD, eecd);
+            DEBUGOUT("Could not acquire EEPROM grant\n");
+            e1000_swfw_sync_release(hw, E1000_SWFW_EEP_SM);
+            return -E1000_ERR_EEPROM;
         }
     }
 
@@ -4939,7 +3740,7 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16
      * directly. In this case, we need to acquire the EEPROM so that
      * FW or other port software does not interrupt.
      */
-    if (e1000_is_onboard_nvm_eeprom(hw) && !hw->eeprom.use_eerd) {
+    if (!hw->eeprom.use_eerd) {
         /* Prepare the EEPROM for bit-bang reading */
         if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
             return -E1000_ERR_EEPROM;
@@ -4949,10 +3750,6 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16
     if (eeprom->use_eerd)
         return e1000_read_eeprom_eerd(hw, offset, words, data);
 
-    /* ICH EEPROM access is done via the ICH flash controller */
-    if (eeprom->type == e1000_eeprom_ich8)
-        return e1000_read_eeprom_ich8(hw, offset, words, data);
-
     /* Set up the SPI or Microwire EEPROM for bit-bang reading.  We have
      * acquired the EEPROM at this point, so any returns should relase it */
     if (eeprom->type == e1000_eeprom_spi) {
@@ -5103,34 +3900,6 @@ static s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
     return done;
 }
 
-/***************************************************************************
-* Description:     Determines if the onboard NVM is FLASH or EEPROM.
-*
-* hw - Struct containing variables accessed by shared code
-****************************************************************************/
-static bool e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
-{
-    u32 eecd = 0;
-
-    DEBUGFUNC("e1000_is_onboard_nvm_eeprom");
-
-    if (hw->mac_type == e1000_ich8lan)
-        return false;
-
-    if (hw->mac_type == e1000_82573) {
-        eecd = er32(EECD);
-
-        /* Isolate bits 15 & 16 */
-        eecd = ((eecd >> 15) & 0x03);
-
-        /* If both bits are set, device is Flash type */
-        if (eecd == 0x03) {
-            return false;
-        }
-    }
-    return true;
-}
-
 /******************************************************************************
  * Verifies that the EEPROM has a valid checksum
  *
@@ -5147,38 +3916,6 @@ s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_validate_eeprom_checksum");
 
-    if ((hw->mac_type == e1000_82573) && !e1000_is_onboard_nvm_eeprom(hw)) {
-        /* Check bit 4 of word 10h.  If it is 0, firmware is done updating
-         * 10h-12h.  Checksum may need to be fixed. */
-        e1000_read_eeprom(hw, 0x10, 1, &eeprom_data);
-        if ((eeprom_data & 0x10) == 0) {
-            /* Read 0x23 and check bit 15.  This bit is a 1 when the checksum
-             * has already been fixed.  If the checksum is still wrong and this
-             * bit is a 1, we need to return bad checksum.  Otherwise, we need
-             * to set this bit to a 1 and update the checksum. */
-            e1000_read_eeprom(hw, 0x23, 1, &eeprom_data);
-            if ((eeprom_data & 0x8000) == 0) {
-                eeprom_data |= 0x8000;
-                e1000_write_eeprom(hw, 0x23, 1, &eeprom_data);
-                e1000_update_eeprom_checksum(hw);
-            }
-        }
-    }
-
-    if (hw->mac_type == e1000_ich8lan) {
-        /* Drivers must allocate the shadow ram structure for the
-         * EEPROM checksum to be updated.  Otherwise, this bit as well
-         * as the checksum must both be set correctly for this
-         * validation to pass.
-         */
-        e1000_read_eeprom(hw, 0x19, 1, &eeprom_data);
-        if ((eeprom_data & 0x40) == 0) {
-            eeprom_data |= 0x40;
-            e1000_write_eeprom(hw, 0x19, 1, &eeprom_data);
-            e1000_update_eeprom_checksum(hw);
-        }
-    }
-
     for (i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++) {
         if (e1000_read_eeprom(hw, i, 1, &eeprom_data) < 0) {
             DEBUGOUT("EEPROM Read Error\n");
@@ -5205,7 +3942,6 @@ s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw)
  *****************************************************************************/
 s32 e1000_update_eeprom_checksum(struct e1000_hw *hw)
 {
-    u32 ctrl_ext;
     u16 checksum = 0;
     u16 i, eeprom_data;
 
@@ -5222,16 +3958,6 @@ s32 e1000_update_eeprom_checksum(struct e1000_hw *hw)
     if (e1000_write_eeprom(hw, EEPROM_CHECKSUM_REG, 1, &checksum) < 0) {
         DEBUGOUT("EEPROM Write Error\n");
         return -E1000_ERR_EEPROM;
-    } else if (hw->eeprom.type == e1000_eeprom_flash) {
-        e1000_commit_shadow_ram(hw);
-    } else if (hw->eeprom.type == e1000_eeprom_ich8) {
-        e1000_commit_shadow_ram(hw);
-        /* Reload the EEPROM, or else modifications will not appear
-         * until after next adapter reset. */
-        ctrl_ext = er32(CTRL_EXT);
-        ctrl_ext |= E1000_CTRL_EXT_EE_RST;
-        ew32(CTRL_EXT, ctrl_ext);
-        msleep(10);
     }
     return E1000_SUCCESS;
 }
@@ -5277,13 +4003,9 @@ static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words, u16
         return -E1000_ERR_EEPROM;
     }
 
-    /* 82573 writes only through eewr */
     if (eeprom->use_eewr)
         return e1000_write_eeprom_eewr(hw, offset, words, data);
 
-    if (eeprom->type == e1000_eeprom_ich8)
-        return e1000_write_eeprom_ich8(hw, offset, words, data);
-
     /* Prepare the EEPROM for writing  */
     if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
         return -E1000_ERR_EEPROM;
@@ -5448,173 +4170,6 @@ static s32 e1000_write_eeprom_microwire(struct e1000_hw *hw, u16 offset,
 }
 
 /******************************************************************************
- * Flushes the cached eeprom to NVM. This is done by saving the modified values
- * in the eeprom cache and the non modified values in the currently active bank
- * to the new bank.
- *
- * hw - Struct containing variables accessed by shared code
- * offset - offset of  word in the EEPROM to read
- * data - word read from the EEPROM
- * words - number of words to read
- *****************************************************************************/
-static s32 e1000_commit_shadow_ram(struct e1000_hw *hw)
-{
-    u32 attempts = 100000;
-    u32 eecd = 0;
-    u32 flop = 0;
-    u32 i = 0;
-    s32 error = E1000_SUCCESS;
-    u32 old_bank_offset = 0;
-    u32 new_bank_offset = 0;
-    u8 low_byte = 0;
-    u8 high_byte = 0;
-    bool sector_write_failed = false;
-
-    if (hw->mac_type == e1000_82573) {
-        /* The flop register will be used to determine if flash type is STM */
-        flop = er32(FLOP);
-        for (i=0; i < attempts; i++) {
-            eecd = er32(EECD);
-            if ((eecd & E1000_EECD_FLUPD) == 0) {
-                break;
-            }
-            udelay(5);
-        }
-
-        if (i == attempts) {
-            return -E1000_ERR_EEPROM;
-        }
-
-        /* If STM opcode located in bits 15:8 of flop, reset firmware */
-        if ((flop & 0xFF00) == E1000_STM_OPCODE) {
-            ew32(HICR, E1000_HICR_FW_RESET);
-        }
-
-        /* Perform the flash update */
-        ew32(EECD, eecd | E1000_EECD_FLUPD);
-
-        for (i=0; i < attempts; i++) {
-            eecd = er32(EECD);
-            if ((eecd & E1000_EECD_FLUPD) == 0) {
-                break;
-            }
-            udelay(5);
-        }
-
-        if (i == attempts) {
-            return -E1000_ERR_EEPROM;
-        }
-    }
-
-    if (hw->mac_type == e1000_ich8lan && hw->eeprom_shadow_ram != NULL) {
-        /* We're writing to the opposite bank so if we're on bank 1,
-         * write to bank 0 etc.  We also need to erase the segment that
-         * is going to be written */
-        if (!(er32(EECD) & E1000_EECD_SEC1VAL)) {
-            new_bank_offset = hw->flash_bank_size * 2;
-            old_bank_offset = 0;
-            e1000_erase_ich8_4k_segment(hw, 1);
-        } else {
-            old_bank_offset = hw->flash_bank_size * 2;
-            new_bank_offset = 0;
-            e1000_erase_ich8_4k_segment(hw, 0);
-        }
-
-        sector_write_failed = false;
-        /* Loop for every byte in the shadow RAM,
-         * which is in units of words. */
-        for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
-            /* Determine whether to write the value stored
-             * in the other NVM bank or a modified value stored
-             * in the shadow RAM */
-            if (hw->eeprom_shadow_ram[i].modified) {
-                low_byte = (u8)hw->eeprom_shadow_ram[i].eeprom_word;
-                udelay(100);
-                error = e1000_verify_write_ich8_byte(hw,
-                            (i << 1) + new_bank_offset, low_byte);
-
-                if (error != E1000_SUCCESS)
-                    sector_write_failed = true;
-                else {
-                    high_byte =
-                        (u8)(hw->eeprom_shadow_ram[i].eeprom_word >> 8);
-                    udelay(100);
-                }
-            } else {
-                e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset,
-                                     &low_byte);
-                udelay(100);
-                error = e1000_verify_write_ich8_byte(hw,
-                            (i << 1) + new_bank_offset, low_byte);
-
-                if (error != E1000_SUCCESS)
-                    sector_write_failed = true;
-                else {
-                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset + 1,
-                                         &high_byte);
-                    udelay(100);
-                }
-            }
-
-            /* If the write of the low byte was successful, go ahead and
-             * write the high byte while checking to make sure that if it
-             * is the signature byte, then it is handled properly */
-            if (!sector_write_failed) {
-                /* If the word is 0x13, then make sure the signature bits
-                 * (15:14) are 11b until the commit has completed.
-                 * This will allow us to write 10b which indicates the
-                 * signature is valid.  We want to do this after the write
-                 * has completed so that we don't mark the segment valid
-                 * while the write is still in progress */
-                if (i == E1000_ICH_NVM_SIG_WORD)
-                    high_byte = E1000_ICH_NVM_SIG_MASK | high_byte;
-
-                error = e1000_verify_write_ich8_byte(hw,
-                            (i << 1) + new_bank_offset + 1, high_byte);
-                if (error != E1000_SUCCESS)
-                    sector_write_failed = true;
-
-            } else {
-                /* If the write failed then break from the loop and
-                 * return an error */
-                break;
-            }
-        }
-
-        /* Don't bother writing the segment valid bits if sector
-         * programming failed. */
-        if (!sector_write_failed) {
-            /* Finally validate the new segment by setting bit 15:14
-             * to 10b in word 0x13 , this can be done without an
-             * erase as well since these bits are 11 to start with
-             * and we need to change bit 14 to 0b */
-            e1000_read_ich8_byte(hw,
-                                 E1000_ICH_NVM_SIG_WORD * 2 + 1 + new_bank_offset,
-                                 &high_byte);
-            high_byte &= 0xBF;
-            error = e1000_verify_write_ich8_byte(hw,
-                        E1000_ICH_NVM_SIG_WORD * 2 + 1 + new_bank_offset, high_byte);
-            /* And invalidate the previously valid segment by setting
-             * its signature word (0x13) high_byte to 0b. This can be
-             * done without an erase because flash erase sets all bits
-             * to 1's. We can write 1's to 0's without an erase */
-            if (error == E1000_SUCCESS) {
-                error = e1000_verify_write_ich8_byte(hw,
-                            E1000_ICH_NVM_SIG_WORD * 2 + 1 + old_bank_offset, 0);
-            }
-
-            /* Clear the now not used entry in the cache */
-            for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
-                hw->eeprom_shadow_ram[i].modified = false;
-                hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
-            }
-        }
-    }
-
-    return error;
-}
-
-/******************************************************************************
  * Reads the adapter's MAC address from the EEPROM and inverts the LSB for the
  * second function of dual function devices
  *
@@ -5642,8 +4197,6 @@ s32 e1000_read_mac_addr(struct e1000_hw *hw)
         break;
     case e1000_82546:
     case e1000_82546_rev_3:
-    case e1000_82571:
-    case e1000_80003es2lan:
         if (er32(STATUS) & E1000_STATUS_FUNC_1)
             hw->perm_mac_addr[5] ^= 0x01;
         break;
@@ -5677,14 +4230,6 @@ static void e1000_init_rx_addrs(struct e1000_hw *hw)
 
     rar_num = E1000_RAR_ENTRIES;
 
-    /* Reserve a spot for the Locally Administered Address to work around
-     * an 82571 issue in which a reset on one port will reload the MAC on
-     * the other port. */
-    if ((hw->mac_type == e1000_82571) && (hw->laa_is_present))
-        rar_num -= 1;
-    if (hw->mac_type == e1000_ich8lan)
-        rar_num = E1000_RAR_ENTRIES_ICH8LAN;
-
     /* Zero out the other 15 receive addresses. */
     DEBUGOUT("Clearing RAR[1-15]\n");
     for (i = 1; i < rar_num; i++) {
@@ -5714,47 +4259,24 @@ u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
      * LSB                 MSB
      */
     case 0:
-        if (hw->mac_type == e1000_ich8lan) {
-            /* [47:38] i.e. 0x158 for above example address */
-            hash_value = ((mc_addr[4] >> 6) | (((u16)mc_addr[5]) << 2));
-        } else {
-            /* [47:36] i.e. 0x563 for above example address */
-            hash_value = ((mc_addr[4] >> 4) | (((u16)mc_addr[5]) << 4));
-        }
+        /* [47:36] i.e. 0x563 for above example address */
+        hash_value = ((mc_addr[4] >> 4) | (((u16)mc_addr[5]) << 4));
         break;
     case 1:
-        if (hw->mac_type == e1000_ich8lan) {
-            /* [46:37] i.e. 0x2B1 for above example address */
-            hash_value = ((mc_addr[4] >> 5) | (((u16)mc_addr[5]) << 3));
-        } else {
-            /* [46:35] i.e. 0xAC6 for above example address */
-            hash_value = ((mc_addr[4] >> 3) | (((u16)mc_addr[5]) << 5));
-        }
+        /* [46:35] i.e. 0xAC6 for above example address */
+        hash_value = ((mc_addr[4] >> 3) | (((u16)mc_addr[5]) << 5));
         break;
     case 2:
-        if (hw->mac_type == e1000_ich8lan) {
-            /*[45:36] i.e. 0x163 for above example address */
-            hash_value = ((mc_addr[4] >> 4) | (((u16)mc_addr[5]) << 4));
-        } else {
-            /* [45:34] i.e. 0x5D8 for above example address */
-            hash_value = ((mc_addr[4] >> 2) | (((u16)mc_addr[5]) << 6));
-        }
+        /* [45:34] i.e. 0x5D8 for above example address */
+        hash_value = ((mc_addr[4] >> 2) | (((u16)mc_addr[5]) << 6));
         break;
     case 3:
-        if (hw->mac_type == e1000_ich8lan) {
-            /* [43:34] i.e. 0x18D for above example address */
-            hash_value = ((mc_addr[4] >> 2) | (((u16)mc_addr[5]) << 6));
-        } else {
-            /* [43:32] i.e. 0x634 for above example address */
-            hash_value = ((mc_addr[4]) | (((u16)mc_addr[5]) << 8));
-        }
+        /* [43:32] i.e. 0x634 for above example address */
+        hash_value = ((mc_addr[4]) | (((u16)mc_addr[5]) << 8));
         break;
     }
 
     hash_value &= 0xFFF;
-    if (hw->mac_type == e1000_ich8lan)
-        hash_value &= 0x3FF;
-
     return hash_value;
 }
 
@@ -5795,11 +4317,6 @@ void e1000_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
      * on our merry way.
      */
     switch (hw->mac_type) {
-    case e1000_82571:
-    case e1000_82572:
-    case e1000_80003es2lan:
-        if (hw->leave_av_bit_off)
-            break;
     default:
         /* Indicate to hardware the Address is Valid. */
         rar_high |= E1000_RAH_AV;
@@ -5823,9 +4340,6 @@ void e1000_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
 {
     u32 temp;
 
-    if (hw->mac_type == e1000_ich8lan)
-        return;
-
     if ((hw->mac_type == e1000_82544) && ((offset & 0x1) == 1)) {
         temp = E1000_READ_REG_ARRAY(hw, VFTA, (offset - 1));
         E1000_WRITE_REG_ARRAY(hw, VFTA, offset, value);
@@ -5850,22 +4364,6 @@ static void e1000_clear_vfta(struct e1000_hw *hw)
     u32 vfta_offset = 0;
     u32 vfta_bit_in_reg = 0;
 
-    if (hw->mac_type == e1000_ich8lan)
-        return;
-
-    if (hw->mac_type == e1000_82573) {
-        if (hw->mng_cookie.vlan_id != 0) {
-            /* The VFTA is a 4096b bit-field, each identifying a single VLAN
-             * ID.  The following operations determine which 32b entry
-             * (i.e. offset) into the array we want to set the VLAN ID
-             * (i.e. bit) of the manageability unit. */
-            vfta_offset = (hw->mng_cookie.vlan_id >>
-                           E1000_VFTA_ENTRY_SHIFT) &
-                          E1000_VFTA_ENTRY_MASK;
-            vfta_bit_in_reg = 1 << (hw->mng_cookie.vlan_id &
-                                    E1000_VFTA_ENTRY_BIT_SHIFT_MASK);
-        }
-    }
     for (offset = 0; offset < E1000_VLAN_FILTER_TBL_SIZE; offset++) {
         /* If the offset we want to clear is the same offset of the
          * manageability VLAN ID, then clear all bits except that of the
@@ -5902,14 +4400,8 @@ static s32 e1000_id_led_init(struct e1000_hw *hw)
         return -E1000_ERR_EEPROM;
     }
 
-    if ((hw->mac_type == e1000_82573) &&
-        (eeprom_data == ID_LED_RESERVED_82573))
-        eeprom_data = ID_LED_DEFAULT_82573;
-    else if ((eeprom_data == ID_LED_RESERVED_0000) ||
+    if ((eeprom_data == ID_LED_RESERVED_0000) ||
             (eeprom_data == ID_LED_RESERVED_FFFF)) {
-        if (hw->mac_type == e1000_ich8lan)
-            eeprom_data = ID_LED_DEFAULT_ICH8LAN;
-        else
             eeprom_data = ID_LED_DEFAULT;
     }
 
@@ -6007,44 +4499,6 @@ s32 e1000_setup_led(struct e1000_hw *hw)
     return E1000_SUCCESS;
 }
 
-
-/******************************************************************************
- * Used on 82571 and later Si that has LED blink bits.
- * Callers must use their own timer and should have already called
- * e1000_id_led_init()
- * Call e1000_cleanup led() to stop blinking
- *
- * hw - Struct containing variables accessed by shared code
- *****************************************************************************/
-s32 e1000_blink_led_start(struct e1000_hw *hw)
-{
-    s16  i;
-    u32 ledctl_blink = 0;
-
-    DEBUGFUNC("e1000_id_led_blink_on");
-
-    if (hw->mac_type < e1000_82571) {
-        /* Nothing to do */
-        return E1000_SUCCESS;
-    }
-    if (hw->media_type == e1000_media_type_fiber) {
-        /* always blink LED0 for PCI-E fiber */
-        ledctl_blink = E1000_LEDCTL_LED0_BLINK |
-                     (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
-    } else {
-        /* set the blink bit for each LED that's "on" (0x0E) in ledctl_mode2 */
-        ledctl_blink = hw->ledctl_mode2;
-        for (i=0; i < 4; i++)
-            if (((hw->ledctl_mode2 >> (i * 8)) & 0xFF) ==
-                E1000_LEDCTL_MODE_LED_ON)
-                ledctl_blink |= (E1000_LEDCTL_LED0_BLINK << (i * 8));
-    }
-
-    ew32(LEDCTL, ledctl_blink);
-
-    return E1000_SUCCESS;
-}
-
 /******************************************************************************
  * Restores the saved state of the SW controlable LED.
  *
@@ -6074,10 +4528,6 @@ s32 e1000_cleanup_led(struct e1000_hw *hw)
             return ret_val;
         /* Fall Through */
     default:
-        if (hw->phy_type == e1000_phy_ife) {
-            e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL_LED, 0);
-            break;
-        }
         /* Restore LEDCTL settings */
         ew32(LEDCTL, hw->ledctl_default);
         break;
@@ -6121,9 +4571,6 @@ s32 e1000_led_on(struct e1000_hw *hw)
             /* Clear SW Defineable Pin 0 to turn on the LED */
             ctrl &= ~E1000_CTRL_SWDPIN0;
             ctrl |= E1000_CTRL_SWDPIO0;
-        } else if (hw->phy_type == e1000_phy_ife) {
-            e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL_LED,
-                 (IFE_PSCL_PROBE_MODE | IFE_PSCL_PROBE_LEDS_ON));
         } else if (hw->media_type == e1000_media_type_copper) {
             ew32(LEDCTL, hw->ledctl_mode2);
             return E1000_SUCCESS;
@@ -6171,9 +4618,6 @@ s32 e1000_led_off(struct e1000_hw *hw)
             /* Set SW Defineable Pin 0 to turn off the LED */
             ctrl |= E1000_CTRL_SWDPIN0;
             ctrl |= E1000_CTRL_SWDPIO0;
-        } else if (hw->phy_type == e1000_phy_ife) {
-            e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL_LED,
-                 (IFE_PSCL_PROBE_MODE | IFE_PSCL_PROBE_LEDS_OFF));
         } else if (hw->media_type == e1000_media_type_copper) {
             ew32(LEDCTL, hw->ledctl_mode1);
             return E1000_SUCCESS;
@@ -6212,14 +4656,12 @@ static void e1000_clear_hw_cntrs(struct e1000_hw *hw)
     temp = er32(XOFFTXC);
     temp = er32(FCRUC);
 
-    if (hw->mac_type != e1000_ich8lan) {
     temp = er32(PRC64);
     temp = er32(PRC127);
     temp = er32(PRC255);
     temp = er32(PRC511);
     temp = er32(PRC1023);
     temp = er32(PRC1522);
-    }
 
     temp = er32(GPRC);
     temp = er32(BPRC);
@@ -6241,14 +4683,12 @@ static void e1000_clear_hw_cntrs(struct e1000_hw *hw)
     temp = er32(TPR);
     temp = er32(TPT);
 
-    if (hw->mac_type != e1000_ich8lan) {
     temp = er32(PTC64);
     temp = er32(PTC127);
     temp = er32(PTC255);
     temp = er32(PTC511);
     temp = er32(PTC1023);
     temp = er32(PTC1522);
-    }
 
     temp = er32(MPTC);
     temp = er32(BPTC);
@@ -6267,21 +4707,6 @@ static void e1000_clear_hw_cntrs(struct e1000_hw *hw)
     temp = er32(MGTPRC);
     temp = er32(MGTPDC);
     temp = er32(MGTPTC);
-
-    if (hw->mac_type <= e1000_82547_rev_2) return;
-
-    temp = er32(IAC);
-    temp = er32(ICRXOC);
-
-    if (hw->mac_type == e1000_ich8lan) return;
-
-    temp = er32(ICRXPTC);
-    temp = er32(ICRXATC);
-    temp = er32(ICTXPTC);
-    temp = er32(ICTXATC);
-    temp = er32(ICTXQEC);
-    temp = er32(ICTXQMTC);
-    temp = er32(ICRXDMTC);
 }
 
 /******************************************************************************
@@ -6433,8 +4858,6 @@ void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats,
  *****************************************************************************/
 void e1000_get_bus_info(struct e1000_hw *hw)
 {
-    s32 ret_val;
-    u16 pci_ex_link_status;
     u32 status;
 
     switch (hw->mac_type) {
@@ -6444,26 +4867,6 @@ void e1000_get_bus_info(struct e1000_hw *hw)
         hw->bus_speed = e1000_bus_speed_unknown;
         hw->bus_width = e1000_bus_width_unknown;
         break;
-    case e1000_82571:
-    case e1000_82572:
-    case e1000_82573:
-    case e1000_80003es2lan:
-        hw->bus_type = e1000_bus_type_pci_express;
-        hw->bus_speed = e1000_bus_speed_2500;
-        ret_val = e1000_read_pcie_cap_reg(hw,
-                                      PCI_EX_LINK_STATUS,
-                                      &pci_ex_link_status);
-        if (ret_val)
-            hw->bus_width = e1000_bus_width_unknown;
-        else
-            hw->bus_width = (pci_ex_link_status & PCI_EX_LINK_WIDTH_MASK) >>
-                          PCI_EX_LINK_WIDTH_SHIFT;
-        break;
-    case e1000_ich8lan:
-        hw->bus_type = e1000_bus_type_pci_express;
-        hw->bus_speed = e1000_bus_speed_2500;
-        hw->bus_width = e1000_bus_width_pciex_1;
-        break;
     default:
         status = er32(STATUS);
         hw->bus_type = (status & E1000_STATUS_PCIX_MODE) ?
@@ -6577,34 +4980,6 @@ static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length,
             return -E1000_ERR_PHY;
             break;
         }
-    } else if (hw->phy_type == e1000_phy_gg82563) {
-        ret_val = e1000_read_phy_reg(hw, GG82563_PHY_DSP_DISTANCE,
-                                     &phy_data);
-        if (ret_val)
-            return ret_val;
-        cable_length = phy_data & GG82563_DSPD_CABLE_LENGTH;
-
-        switch (cable_length) {
-        case e1000_gg_cable_length_60:
-            *min_length = 0;
-            *max_length = e1000_igp_cable_length_60;
-            break;
-        case e1000_gg_cable_length_60_115:
-            *min_length = e1000_igp_cable_length_60;
-            *max_length = e1000_igp_cable_length_115;
-            break;
-        case e1000_gg_cable_length_115_150:
-            *min_length = e1000_igp_cable_length_115;
-            *max_length = e1000_igp_cable_length_150;
-            break;
-        case e1000_gg_cable_length_150:
-            *min_length = e1000_igp_cable_length_150;
-            *max_length = e1000_igp_cable_length_180;
-            break;
-        default:
-            return -E1000_ERR_PHY;
-            break;
-        }
     } else if (hw->phy_type == e1000_phy_igp) { /* For IGP PHY */
         u16 cur_agc_value;
         u16 min_agc_value = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
@@ -6652,51 +5027,6 @@ static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length,
                        IGP01E1000_AGC_RANGE) : 0;
         *max_length = e1000_igp_cable_length_table[agc_value] +
                       IGP01E1000_AGC_RANGE;
-    } else if (hw->phy_type == e1000_phy_igp_2 ||
-               hw->phy_type == e1000_phy_igp_3) {
-        u16 cur_agc_index, max_agc_index = 0;
-        u16 min_agc_index = IGP02E1000_AGC_LENGTH_TABLE_SIZE - 1;
-        u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] =
-                                                         {IGP02E1000_PHY_AGC_A,
-                                                          IGP02E1000_PHY_AGC_B,
-                                                          IGP02E1000_PHY_AGC_C,
-                                                          IGP02E1000_PHY_AGC_D};
-        /* Read the AGC registers for all channels */
-        for (i = 0; i < IGP02E1000_PHY_CHANNEL_NUM; i++) {
-            ret_val = e1000_read_phy_reg(hw, agc_reg_array[i], &phy_data);
-            if (ret_val)
-                return ret_val;
-
-            /* Getting bits 15:9, which represent the combination of course and
-             * fine gain values.  The result is a number that can be put into
-             * the lookup table to obtain the approximate cable length. */
-            cur_agc_index = (phy_data >> IGP02E1000_AGC_LENGTH_SHIFT) &
-                            IGP02E1000_AGC_LENGTH_MASK;
-
-            /* Array index bound check. */
-            if ((cur_agc_index >= IGP02E1000_AGC_LENGTH_TABLE_SIZE) ||
-                (cur_agc_index == 0))
-                return -E1000_ERR_PHY;
-
-            /* Remove min & max AGC values from calculation. */
-            if (e1000_igp_2_cable_length_table[min_agc_index] >
-                e1000_igp_2_cable_length_table[cur_agc_index])
-                min_agc_index = cur_agc_index;
-            if (e1000_igp_2_cable_length_table[max_agc_index] <
-                e1000_igp_2_cable_length_table[cur_agc_index])
-                max_agc_index = cur_agc_index;
-
-            agc_value += e1000_igp_2_cable_length_table[cur_agc_index];
-        }
-
-        agc_value -= (e1000_igp_2_cable_length_table[min_agc_index] +
-                      e1000_igp_2_cable_length_table[max_agc_index]);
-        agc_value /= (IGP02E1000_PHY_CHANNEL_NUM - 2);
-
-        /* Calculate cable length with the error range of +/- 10 meters. */
-        *min_length = ((agc_value - IGP02E1000_AGC_RANGE) > 0) ?
-                       (agc_value - IGP02E1000_AGC_RANGE) : 0;
-        *max_length = agc_value + IGP02E1000_AGC_RANGE;
     }
 
     return E1000_SUCCESS;
@@ -6726,8 +5056,7 @@ static s32 e1000_check_polarity(struct e1000_hw *hw,
 
     DEBUGFUNC("e1000_check_polarity");
 
-    if ((hw->phy_type == e1000_phy_m88) ||
-        (hw->phy_type == e1000_phy_gg82563)) {
+    if (hw->phy_type == e1000_phy_m88) {
         /* return the Polarity bit in the Status register. */
         ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
                                      &phy_data);
@@ -6737,9 +5066,7 @@ static s32 e1000_check_polarity(struct e1000_hw *hw,
                      M88E1000_PSSR_REV_POLARITY_SHIFT) ?
                      e1000_rev_polarity_reversed : e1000_rev_polarity_normal;
 
-    } else if (hw->phy_type == e1000_phy_igp ||
-              hw->phy_type == e1000_phy_igp_3 ||
-              hw->phy_type == e1000_phy_igp_2) {
+    } else if (hw->phy_type == e1000_phy_igp) {
         /* Read the Status register to check the speed */
         ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS,
                                      &phy_data);
@@ -6766,14 +5093,6 @@ static s32 e1000_check_polarity(struct e1000_hw *hw,
             *polarity = (phy_data & IGP01E1000_PSSR_POLARITY_REVERSED) ?
                          e1000_rev_polarity_reversed : e1000_rev_polarity_normal;
         }
-    } else if (hw->phy_type == e1000_phy_ife) {
-        ret_val = e1000_read_phy_reg(hw, IFE_PHY_EXTENDED_STATUS_CONTROL,
-                                     &phy_data);
-        if (ret_val)
-            return ret_val;
-        *polarity = ((phy_data & IFE_PESC_POLARITY_REVERSED) >>
-                     IFE_PESC_POLARITY_REVERSED_SHIFT) ?
-                     e1000_rev_polarity_reversed : e1000_rev_polarity_normal;
     }
     return E1000_SUCCESS;
 }
@@ -6800,17 +5119,14 @@ static s32 e1000_check_downshift(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_check_downshift");
 
-    if (hw->phy_type == e1000_phy_igp ||
-        hw->phy_type == e1000_phy_igp_3 ||
-        hw->phy_type == e1000_phy_igp_2) {
+    if (hw->phy_type == e1000_phy_igp) {
         ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_LINK_HEALTH,
                                      &phy_data);
         if (ret_val)
             return ret_val;
 
         hw->speed_downgraded = (phy_data & IGP01E1000_PLHR_SS_DOWNGRADE) ? 1 : 0;
-    } else if ((hw->phy_type == e1000_phy_m88) ||
-               (hw->phy_type == e1000_phy_gg82563)) {
+    } else if (hw->phy_type == e1000_phy_m88) {
         ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
                                      &phy_data);
         if (ret_val)
@@ -6818,9 +5134,6 @@ static s32 e1000_check_downshift(struct e1000_hw *hw)
 
         hw->speed_downgraded = (phy_data & M88E1000_PSSR_DOWNSHIFT) >>
                                M88E1000_PSSR_DOWNSHIFT_SHIFT;
-    } else if (hw->phy_type == e1000_phy_ife) {
-        /* e1000_phy_ife supports 10/100 speed only */
-        hw->speed_downgraded = false;
     }
 
     return E1000_SUCCESS;
@@ -7070,13 +5383,11 @@ static s32 e1000_set_phy_mode(struct e1000_hw *hw)
 
 static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
 {
-    u32 phy_ctrl = 0;
     s32 ret_val;
     u16 phy_data;
     DEBUGFUNC("e1000_set_d3_lplu_state");
 
-    if (hw->phy_type != e1000_phy_igp && hw->phy_type != e1000_phy_igp_2
-        && hw->phy_type != e1000_phy_igp_3)
+    if (hw->phy_type != e1000_phy_igp)
         return E1000_SUCCESS;
 
     /* During driver activity LPLU should not be used or it will attain link
@@ -7086,11 +5397,6 @@ static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
         ret_val = e1000_read_phy_reg(hw, IGP01E1000_GMII_FIFO, &phy_data);
         if (ret_val)
             return ret_val;
-    } else if (hw->mac_type == e1000_ich8lan) {
-        /* MAC writes into PHY register based on the state transition
-         * and start auto-negotiation. SW driver can overwrite the settings
-         * in CSR PHY power control E1000_PHY_CTRL register. */
-        phy_ctrl = er32(PHY_CTRL);
     } else {
         ret_val = e1000_read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, &phy_data);
         if (ret_val)
@@ -7105,16 +5411,11 @@ static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
             if (ret_val)
                 return ret_val;
         } else {
-            if (hw->mac_type == e1000_ich8lan) {
-                phy_ctrl &= ~E1000_PHY_CTRL_NOND0A_LPLU;
-                ew32(PHY_CTRL, phy_ctrl);
-            } else {
-                phy_data &= ~IGP02E1000_PM_D3_LPLU;
-                ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
-                                              phy_data);
-                if (ret_val)
-                    return ret_val;
-            }
+            phy_data &= ~IGP02E1000_PM_D3_LPLU;
+            ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
+                                          phy_data);
+            if (ret_val)
+                return ret_val;
         }
 
         /* LPLU and SmartSpeed are mutually exclusive.  LPLU is used during
@@ -7156,114 +5457,11 @@ static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
             if (ret_val)
                 return ret_val;
         } else {
-            if (hw->mac_type == e1000_ich8lan) {
-                phy_ctrl |= E1000_PHY_CTRL_NOND0A_LPLU;
-                ew32(PHY_CTRL, phy_ctrl);
-            } else {
-                phy_data |= IGP02E1000_PM_D3_LPLU;
-                ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
-                                              phy_data);
-                if (ret_val)
-                    return ret_val;
-            }
-        }
-
-        /* When LPLU is enabled we should disable SmartSpeed */
-        ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG, &phy_data);
-        if (ret_val)
-            return ret_val;
-
-        phy_data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-        ret_val = e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG, phy_data);
-        if (ret_val)
-            return ret_val;
-
-    }
-    return E1000_SUCCESS;
-}
-
-/*****************************************************************************
- *
- * This function sets the lplu d0 state according to the active flag.  When
- * activating lplu this function also disables smart speed and vise versa.
- * lplu will not be activated unless the device autonegotiation advertisment
- * meets standards of either 10 or 10/100 or 10/100/1000 at all duplexes.
- * hw: Struct containing variables accessed by shared code
- * active - true to enable lplu false to disable lplu.
- *
- * returns: - E1000_ERR_PHY if fail to read/write the PHY
- *            E1000_SUCCESS at any other case.
- *
- ****************************************************************************/
-
-static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
-{
-    u32 phy_ctrl = 0;
-    s32 ret_val;
-    u16 phy_data;
-    DEBUGFUNC("e1000_set_d0_lplu_state");
-
-    if (hw->mac_type <= e1000_82547_rev_2)
-        return E1000_SUCCESS;
-
-    if (hw->mac_type == e1000_ich8lan) {
-        phy_ctrl = er32(PHY_CTRL);
-    } else {
-        ret_val = e1000_read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, &phy_data);
-        if (ret_val)
-            return ret_val;
-    }
-
-    if (!active) {
-        if (hw->mac_type == e1000_ich8lan) {
-            phy_ctrl &= ~E1000_PHY_CTRL_D0A_LPLU;
-            ew32(PHY_CTRL, phy_ctrl);
-        } else {
-            phy_data &= ~IGP02E1000_PM_D0_LPLU;
-            ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
-            if (ret_val)
-                return ret_val;
-        }
-
-        /* LPLU and SmartSpeed are mutually exclusive.  LPLU is used during
-         * Dx states where the power conservation is most important.  During
-         * driver activity we should enable SmartSpeed, so performance is
-         * maintained. */
-        if (hw->smart_speed == e1000_smart_speed_on) {
-            ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
-                                         &phy_data);
-            if (ret_val)
-                return ret_val;
-
-            phy_data |= IGP01E1000_PSCFR_SMART_SPEED;
-            ret_val = e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+            phy_data |= IGP02E1000_PM_D3_LPLU;
+            ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
                                           phy_data);
             if (ret_val)
                 return ret_val;
-        } else if (hw->smart_speed == e1000_smart_speed_off) {
-            ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
-                                         &phy_data);
-            if (ret_val)
-                return ret_val;
-
-            phy_data &= ~IGP01E1000_PSCFR_SMART_SPEED;
-            ret_val = e1000_write_phy_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
-                                          phy_data);
-            if (ret_val)
-                return ret_val;
-        }
-
-
-    } else {
-
-        if (hw->mac_type == e1000_ich8lan) {
-            phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU;
-            ew32(PHY_CTRL, phy_ctrl);
-        } else {
-            phy_data |= IGP02E1000_PM_D0_LPLU;
-            ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
-            if (ret_val)
-                return ret_val;
         }
 
         /* When LPLU is enabled we should disable SmartSpeed */
@@ -7343,296 +5541,6 @@ static s32 e1000_set_vco_speed(struct e1000_hw *hw)
 }
 
 
-/*****************************************************************************
- * This function reads the cookie from ARC ram.
- *
- * returns: - E1000_SUCCESS .
- ****************************************************************************/
-static s32 e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer)
-{
-    u8 i;
-    u32 offset = E1000_MNG_DHCP_COOKIE_OFFSET;
-    u8 length = E1000_MNG_DHCP_COOKIE_LENGTH;
-
-    length = (length >> 2);
-    offset = (offset >> 2);
-
-    for (i = 0; i < length; i++) {
-        *((u32 *)buffer + i) =
-            E1000_READ_REG_ARRAY_DWORD(hw, HOST_IF, offset + i);
-    }
-    return E1000_SUCCESS;
-}
-
-
-/*****************************************************************************
- * This function checks whether the HOST IF is enabled for command operaton
- * and also checks whether the previous command is completed.
- * It busy waits in case of previous command is not completed.
- *
- * returns: - E1000_ERR_HOST_INTERFACE_COMMAND in case if is not ready or
- *            timeout
- *          - E1000_SUCCESS for success.
- ****************************************************************************/
-static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
-{
-    u32 hicr;
-    u8 i;
-
-    /* Check that the host interface is enabled. */
-    hicr = er32(HICR);
-    if ((hicr & E1000_HICR_EN) == 0) {
-        DEBUGOUT("E1000_HOST_EN bit disabled.\n");
-        return -E1000_ERR_HOST_INTERFACE_COMMAND;
-    }
-    /* check the previous command is completed */
-    for (i = 0; i < E1000_MNG_DHCP_COMMAND_TIMEOUT; i++) {
-        hicr = er32(HICR);
-        if (!(hicr & E1000_HICR_C))
-            break;
-        mdelay(1);
-    }
-
-    if (i == E1000_MNG_DHCP_COMMAND_TIMEOUT) {
-        DEBUGOUT("Previous command timeout failed .\n");
-        return -E1000_ERR_HOST_INTERFACE_COMMAND;
-    }
-    return E1000_SUCCESS;
-}
-
-/*****************************************************************************
- * This function writes the buffer content at the offset given on the host if.
- * It also does alignment considerations to do the writes in most efficient way.
- * Also fills up the sum of the buffer in *buffer parameter.
- *
- * returns  - E1000_SUCCESS for success.
- ****************************************************************************/
-static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer, u16 length,
-				   u16 offset, u8 *sum)
-{
-    u8 *tmp;
-    u8 *bufptr = buffer;
-    u32 data = 0;
-    u16 remaining, i, j, prev_bytes;
-
-    /* sum = only sum of the data and it is not checksum */
-
-    if (length == 0 || offset + length > E1000_HI_MAX_MNG_DATA_LENGTH) {
-        return -E1000_ERR_PARAM;
-    }
-
-    tmp = (u8 *)&data;
-    prev_bytes = offset & 0x3;
-    offset &= 0xFFFC;
-    offset >>= 2;
-
-    if (prev_bytes) {
-        data = E1000_READ_REG_ARRAY_DWORD(hw, HOST_IF, offset);
-        for (j = prev_bytes; j < sizeof(u32); j++) {
-            *(tmp + j) = *bufptr++;
-            *sum += *(tmp + j);
-        }
-        E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, offset, data);
-        length -= j - prev_bytes;
-        offset++;
-    }
-
-    remaining = length & 0x3;
-    length -= remaining;
-
-    /* Calculate length in DWORDs */
-    length >>= 2;
-
-    /* The device driver writes the relevant command block into the
-     * ram area. */
-    for (i = 0; i < length; i++) {
-        for (j = 0; j < sizeof(u32); j++) {
-            *(tmp + j) = *bufptr++;
-            *sum += *(tmp + j);
-        }
-
-        E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, offset + i, data);
-    }
-    if (remaining) {
-        for (j = 0; j < sizeof(u32); j++) {
-            if (j < remaining)
-                *(tmp + j) = *bufptr++;
-            else
-                *(tmp + j) = 0;
-
-            *sum += *(tmp + j);
-        }
-        E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, offset + i, data);
-    }
-
-    return E1000_SUCCESS;
-}
-
-
-/*****************************************************************************
- * This function writes the command header after does the checksum calculation.
- *
- * returns  - E1000_SUCCESS for success.
- ****************************************************************************/
-static s32 e1000_mng_write_cmd_header(struct e1000_hw *hw,
-				      struct e1000_host_mng_command_header *hdr)
-{
-    u16 i;
-    u8 sum;
-    u8 *buffer;
-
-    /* Write the whole command header structure which includes sum of
-     * the buffer */
-
-    u16 length = sizeof(struct e1000_host_mng_command_header);
-
-    sum = hdr->checksum;
-    hdr->checksum = 0;
-
-    buffer = (u8 *)hdr;
-    i = length;
-    while (i--)
-        sum += buffer[i];
-
-    hdr->checksum = 0 - sum;
-
-    length >>= 2;
-    /* The device driver writes the relevant command block into the ram area. */
-    for (i = 0; i < length; i++) {
-        E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, i, *((u32 *)hdr + i));
-        E1000_WRITE_FLUSH();
-    }
-
-    return E1000_SUCCESS;
-}
-
-
-/*****************************************************************************
- * This function indicates to ARC that a new command is pending which completes
- * one write operation by the driver.
- *
- * returns  - E1000_SUCCESS for success.
- ****************************************************************************/
-static s32 e1000_mng_write_commit(struct e1000_hw *hw)
-{
-    u32 hicr;
-
-    hicr = er32(HICR);
-    /* Setting this bit tells the ARC that a new command is pending. */
-    ew32(HICR, hicr | E1000_HICR_C);
-
-    return E1000_SUCCESS;
-}
-
-
-/*****************************************************************************
- * This function checks the mode of the firmware.
- *
- * returns  - true when the mode is IAMT or false.
- ****************************************************************************/
-bool e1000_check_mng_mode(struct e1000_hw *hw)
-{
-    u32 fwsm;
-
-    fwsm = er32(FWSM);
-
-    if (hw->mac_type == e1000_ich8lan) {
-        if ((fwsm & E1000_FWSM_MODE_MASK) ==
-            (E1000_MNG_ICH_IAMT_MODE << E1000_FWSM_MODE_SHIFT))
-            return true;
-    } else if ((fwsm & E1000_FWSM_MODE_MASK) ==
-               (E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT))
-        return true;
-
-    return false;
-}
-
-
-/*****************************************************************************
- * This function writes the dhcp info .
- ****************************************************************************/
-s32 e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length)
-{
-    s32 ret_val;
-    struct e1000_host_mng_command_header hdr;
-
-    hdr.command_id = E1000_MNG_DHCP_TX_PAYLOAD_CMD;
-    hdr.command_length = length;
-    hdr.reserved1 = 0;
-    hdr.reserved2 = 0;
-    hdr.checksum = 0;
-
-    ret_val = e1000_mng_enable_host_if(hw);
-    if (ret_val == E1000_SUCCESS) {
-        ret_val = e1000_mng_host_if_write(hw, buffer, length, sizeof(hdr),
-                                          &(hdr.checksum));
-        if (ret_val == E1000_SUCCESS) {
-            ret_val = e1000_mng_write_cmd_header(hw, &hdr);
-            if (ret_val == E1000_SUCCESS)
-                ret_val = e1000_mng_write_commit(hw);
-        }
-    }
-    return ret_val;
-}
-
-
-/*****************************************************************************
- * This function calculates the checksum.
- *
- * returns  - checksum of buffer contents.
- ****************************************************************************/
-static u8 e1000_calculate_mng_checksum(char *buffer, u32 length)
-{
-    u8 sum = 0;
-    u32 i;
-
-    if (!buffer)
-        return 0;
-
-    for (i=0; i < length; i++)
-        sum += buffer[i];
-
-    return (u8)(0 - sum);
-}
-
-/*****************************************************************************
- * This function checks whether tx pkt filtering needs to be enabled or not.
- *
- * returns  - true for packet filtering or false.
- ****************************************************************************/
-bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
-{
-    /* called in init as well as watchdog timer functions */
-
-    s32 ret_val, checksum;
-    bool tx_filter = false;
-    struct e1000_host_mng_dhcp_cookie *hdr = &(hw->mng_cookie);
-    u8 *buffer = (u8 *) &(hw->mng_cookie);
-
-    if (e1000_check_mng_mode(hw)) {
-        ret_val = e1000_mng_enable_host_if(hw);
-        if (ret_val == E1000_SUCCESS) {
-            ret_val = e1000_host_if_read_cookie(hw, buffer);
-            if (ret_val == E1000_SUCCESS) {
-                checksum = hdr->checksum;
-                hdr->checksum = 0;
-                if ((hdr->signature == E1000_IAMT_SIGNATURE) &&
-                    checksum == e1000_calculate_mng_checksum((char *)buffer,
-                                               E1000_MNG_DHCP_COOKIE_LENGTH)) {
-                    if (hdr->status &
-                        E1000_MNG_DHCP_COOKIE_STATUS_PARSING_SUPPORT)
-                        tx_filter = true;
-                } else
-                    tx_filter = true;
-            } else
-                tx_filter = true;
-        }
-    }
-
-    hw->tx_pkt_filtering = tx_filter;
-    return tx_filter;
-}
-
 /******************************************************************************
  * Verifies the hardware needs to allow ARPs to be processed by the host
  *
@@ -7644,7 +5552,6 @@ bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
 u32 e1000_enable_mng_pass_thru(struct e1000_hw *hw)
 {
     u32 manc;
-    u32 fwsm, factps;
 
     if (hw->asf_firmware_present) {
         manc = er32(MANC);
@@ -7652,16 +5559,8 @@ u32 e1000_enable_mng_pass_thru(struct e1000_hw *hw)
         if (!(manc & E1000_MANC_RCV_TCO_EN) ||
             !(manc & E1000_MANC_EN_MAC_ADDR_FILTER))
             return false;
-        if (e1000_arc_subsystem_valid(hw)) {
-            fwsm = er32(FWSM);
-            factps = er32(FACTPS);
-
-            if ((((fwsm & E1000_FWSM_MODE_MASK) >> E1000_FWSM_MODE_SHIFT) ==
-                   e1000_mng_mode_pt) && !(factps & E1000_FACTPS_MNGCG))
-                return true;
-        } else
-            if ((manc & E1000_MANC_SMBUS_EN) && !(manc & E1000_MANC_ASF_EN))
-                return true;
+        if ((manc & E1000_MANC_SMBUS_EN) && !(manc & E1000_MANC_ASF_EN))
+            return true;
     }
     return false;
 }
@@ -7750,67 +5649,6 @@ static s32 e1000_polarity_reversal_workaround(struct e1000_hw *hw)
     return E1000_SUCCESS;
 }
 
-/***************************************************************************
- *
- * Disables PCI-Express master access.
- *
- * hw: Struct containing variables accessed by shared code
- *
- * returns: - none.
- *
- ***************************************************************************/
-static void e1000_set_pci_express_master_disable(struct e1000_hw *hw)
-{
-    u32 ctrl;
-
-    DEBUGFUNC("e1000_set_pci_express_master_disable");
-
-    if (hw->bus_type != e1000_bus_type_pci_express)
-        return;
-
-    ctrl = er32(CTRL);
-    ctrl |= E1000_CTRL_GIO_MASTER_DISABLE;
-    ew32(CTRL, ctrl);
-}
-
-/*******************************************************************************
- *
- * Disables PCI-Express master access and verifies there are no pending requests
- *
- * hw: Struct containing variables accessed by shared code
- *
- * returns: - E1000_ERR_MASTER_REQUESTS_PENDING if master disable bit hasn't
- *            caused the master requests to be disabled.
- *            E1000_SUCCESS master requests disabled.
- *
- ******************************************************************************/
-s32 e1000_disable_pciex_master(struct e1000_hw *hw)
-{
-    s32 timeout = MASTER_DISABLE_TIMEOUT;   /* 80ms */
-
-    DEBUGFUNC("e1000_disable_pciex_master");
-
-    if (hw->bus_type != e1000_bus_type_pci_express)
-        return E1000_SUCCESS;
-
-    e1000_set_pci_express_master_disable(hw);
-
-    while (timeout) {
-        if (!(er32(STATUS) & E1000_STATUS_GIO_MASTER_ENABLE))
-            break;
-        else
-            udelay(100);
-        timeout--;
-    }
-
-    if (!timeout) {
-        DEBUGOUT("Master requests are pending.\n");
-        return -E1000_ERR_MASTER_REQUESTS_PENDING;
-    }
-
-    return E1000_SUCCESS;
-}
-
 /*******************************************************************************
  *
  * Check for EEPROM Auto Read bit done.
@@ -7823,39 +5661,8 @@ s32 e1000_disable_pciex_master(struct e1000_hw *hw)
  ******************************************************************************/
 static s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
 {
-    s32 timeout = AUTO_READ_DONE_TIMEOUT;
-
     DEBUGFUNC("e1000_get_auto_rd_done");
-
-    switch (hw->mac_type) {
-    default:
-        msleep(5);
-        break;
-    case e1000_82571:
-    case e1000_82572:
-    case e1000_82573:
-    case e1000_80003es2lan:
-    case e1000_ich8lan:
-        while (timeout) {
-            if (er32(EECD) & E1000_EECD_AUTO_RD)
-                break;
-            else msleep(1);
-            timeout--;
-        }
-
-        if (!timeout) {
-            DEBUGOUT("Auto read by HW from EEPROM has not completed.\n");
-            return -E1000_ERR_RESET;
-        }
-        break;
-    }
-
-    /* PHY configuration from NVM just starts after EECD_AUTO_RD sets to high.
-     * Need to wait for PHY configuration completion before accessing NVM
-     * and PHY. */
-    if (hw->mac_type == e1000_82573)
-        msleep(25);
-
+    msleep(5);
     return E1000_SUCCESS;
 }
 
@@ -7870,36 +5677,8 @@ static s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
  ***************************************************************************/
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw)
 {
-    s32 timeout = PHY_CFG_TIMEOUT;
-    u32 cfg_mask = E1000_EEPROM_CFG_DONE;
-
     DEBUGFUNC("e1000_get_phy_cfg_done");
-
-    switch (hw->mac_type) {
-    default:
-        mdelay(10);
-        break;
-    case e1000_80003es2lan:
-        /* Separate *_CFG_DONE_* bit for each port */
-        if (er32(STATUS) & E1000_STATUS_FUNC_1)
-            cfg_mask = E1000_EEPROM_CFG_DONE_PORT_1;
-        /* Fall Through */
-    case e1000_82571:
-    case e1000_82572:
-        while (timeout) {
-            if (er32(EEMNGCTL) & cfg_mask)
-                break;
-            else
-                msleep(1);
-            timeout--;
-        }
-        if (!timeout) {
-            DEBUGOUT("MNG configuration cycle has not completed.\n");
-            return -E1000_ERR_RESET;
-        }
-        break;
-    }
-
+    mdelay(10);
     return E1000_SUCCESS;
 }
 
@@ -7924,12 +5703,6 @@ static s32 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw)
     if (!hw->eeprom_semaphore_present)
         return E1000_SUCCESS;
 
-    if (hw->mac_type == e1000_80003es2lan) {
-        /* Get the SW semaphore. */
-        if (e1000_get_software_semaphore(hw) != E1000_SUCCESS)
-            return -E1000_ERR_EEPROM;
-    }
-
     /* Get the FW semaphore. */
     timeout = hw->eeprom.word_size + 1;
     while (timeout) {
@@ -7973,860 +5746,6 @@ static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw)
         return;
 
     swsm = er32(SWSM);
-    if (hw->mac_type == e1000_80003es2lan) {
-        /* Release both semaphores. */
-        swsm &= ~(E1000_SWSM_SMBI | E1000_SWSM_SWESMBI);
-    } else
-        swsm &= ~(E1000_SWSM_SWESMBI);
-    ew32(SWSM, swsm);
-}
-
-/***************************************************************************
- *
- * Obtaining software semaphore bit (SMBI) before resetting PHY.
- *
- * hw: Struct containing variables accessed by shared code
- *
- * returns: - E1000_ERR_RESET if fail to obtain semaphore.
- *            E1000_SUCCESS at any other case.
- *
- ***************************************************************************/
-static s32 e1000_get_software_semaphore(struct e1000_hw *hw)
-{
-    s32 timeout = hw->eeprom.word_size + 1;
-    u32 swsm;
-
-    DEBUGFUNC("e1000_get_software_semaphore");
-
-    if (hw->mac_type != e1000_80003es2lan) {
-        return E1000_SUCCESS;
-    }
-
-    while (timeout) {
-        swsm = er32(SWSM);
-        /* If SMBI bit cleared, it is now set and we hold the semaphore */
-        if (!(swsm & E1000_SWSM_SMBI))
-            break;
-        mdelay(1);
-        timeout--;
-    }
-
-    if (!timeout) {
-        DEBUGOUT("Driver can't access device - SMBI bit is set.\n");
-        return -E1000_ERR_RESET;
-    }
-
-    return E1000_SUCCESS;
-}
-
-/***************************************************************************
- *
- * Release semaphore bit (SMBI).
- *
- * hw: Struct containing variables accessed by shared code
- *
- ***************************************************************************/
-static void e1000_release_software_semaphore(struct e1000_hw *hw)
-{
-    u32 swsm;
-
-    DEBUGFUNC("e1000_release_software_semaphore");
-
-    if (hw->mac_type != e1000_80003es2lan) {
-        return;
-    }
-
-    swsm = er32(SWSM);
-    /* Release the SW semaphores.*/
-    swsm &= ~E1000_SWSM_SMBI;
+    swsm &= ~(E1000_SWSM_SWESMBI);
     ew32(SWSM, swsm);
 }
-
-/******************************************************************************
- * Checks if PHY reset is blocked due to SOL/IDER session, for example.
- * Returning E1000_BLK_PHY_RESET isn't necessarily an error.  But it's up to
- * the caller to figure out how to deal with it.
- *
- * hw - Struct containing variables accessed by shared code
- *
- * returns: - E1000_BLK_PHY_RESET
- *            E1000_SUCCESS
- *
- *****************************************************************************/
-s32 e1000_check_phy_reset_block(struct e1000_hw *hw)
-{
-    u32 manc = 0;
-    u32 fwsm = 0;
-
-    if (hw->mac_type == e1000_ich8lan) {
-        fwsm = er32(FWSM);
-        return (fwsm & E1000_FWSM_RSPCIPHY) ? E1000_SUCCESS
-                                            : E1000_BLK_PHY_RESET;
-    }
-
-    if (hw->mac_type > e1000_82547_rev_2)
-        manc = er32(MANC);
-    return (manc & E1000_MANC_BLK_PHY_RST_ON_IDE) ?
-        E1000_BLK_PHY_RESET : E1000_SUCCESS;
-}
-
-static u8 e1000_arc_subsystem_valid(struct e1000_hw *hw)
-{
-    u32 fwsm;
-
-    /* On 8257x silicon, registers in the range of 0x8800 - 0x8FFC
-     * may not be provided a DMA clock when no manageability features are
-     * enabled.  We do not want to perform any reads/writes to these registers
-     * if this is the case.  We read FWSM to determine the manageability mode.
-     */
-    switch (hw->mac_type) {
-    case e1000_82571:
-    case e1000_82572:
-    case e1000_82573:
-    case e1000_80003es2lan:
-        fwsm = er32(FWSM);
-        if ((fwsm & E1000_FWSM_MODE_MASK) != 0)
-            return true;
-        break;
-    case e1000_ich8lan:
-        return true;
-    default:
-        break;
-    }
-    return false;
-}
-
-
-/******************************************************************************
- * Configure PCI-Ex no-snoop
- *
- * hw - Struct containing variables accessed by shared code.
- * no_snoop - Bitmap of no-snoop events.
- *
- * returns: E1000_SUCCESS
- *
- *****************************************************************************/
-static s32 e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop)
-{
-    u32 gcr_reg = 0;
-
-    DEBUGFUNC("e1000_set_pci_ex_no_snoop");
-
-    if (hw->bus_type == e1000_bus_type_unknown)
-        e1000_get_bus_info(hw);
-
-    if (hw->bus_type != e1000_bus_type_pci_express)
-        return E1000_SUCCESS;
-
-    if (no_snoop) {
-        gcr_reg = er32(GCR);
-        gcr_reg &= ~(PCI_EX_NO_SNOOP_ALL);
-        gcr_reg |= no_snoop;
-        ew32(GCR, gcr_reg);
-    }
-    if (hw->mac_type == e1000_ich8lan) {
-        u32 ctrl_ext;
-
-        ew32(GCR, PCI_EX_82566_SNOOP_ALL);
-
-        ctrl_ext = er32(CTRL_EXT);
-        ctrl_ext |= E1000_CTRL_EXT_RO_DIS;
-        ew32(CTRL_EXT, ctrl_ext);
-    }
-
-    return E1000_SUCCESS;
-}
-
-/***************************************************************************
- *
- * Get software semaphore FLAG bit (SWFLAG).
- * SWFLAG is used to synchronize the access to all shared resource between
- * SW, FW and HW.
- *
- * hw: Struct containing variables accessed by shared code
- *
- ***************************************************************************/
-static s32 e1000_get_software_flag(struct e1000_hw *hw)
-{
-    s32 timeout = PHY_CFG_TIMEOUT;
-    u32 extcnf_ctrl;
-
-    DEBUGFUNC("e1000_get_software_flag");
-
-    if (hw->mac_type == e1000_ich8lan) {
-        while (timeout) {
-            extcnf_ctrl = er32(EXTCNF_CTRL);
-            extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
-            ew32(EXTCNF_CTRL, extcnf_ctrl);
-
-            extcnf_ctrl = er32(EXTCNF_CTRL);
-            if (extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG)
-                break;
-            mdelay(1);
-            timeout--;
-        }
-
-        if (!timeout) {
-            DEBUGOUT("FW or HW locks the resource too long.\n");
-            return -E1000_ERR_CONFIG;
-        }
-    }
-
-    return E1000_SUCCESS;
-}
-
-/***************************************************************************
- *
- * Release software semaphore FLAG bit (SWFLAG).
- * SWFLAG is used to synchronize the access to all shared resource between
- * SW, FW and HW.
- *
- * hw: Struct containing variables accessed by shared code
- *
- ***************************************************************************/
-static void e1000_release_software_flag(struct e1000_hw *hw)
-{
-    u32 extcnf_ctrl;
-
-    DEBUGFUNC("e1000_release_software_flag");
-
-    if (hw->mac_type == e1000_ich8lan) {
-        extcnf_ctrl= er32(EXTCNF_CTRL);
-        extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
-        ew32(EXTCNF_CTRL, extcnf_ctrl);
-    }
-
-    return;
-}
-
-/******************************************************************************
- * Reads a 16 bit word or words from the EEPROM using the ICH8's flash access
- * register.
- *
- * hw - Struct containing variables accessed by shared code
- * offset - offset of word in the EEPROM to read
- * data - word read from the EEPROM
- * words - number of words to read
- *****************************************************************************/
-static s32 e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
-				  u16 *data)
-{
-    s32  error = E1000_SUCCESS;
-    u32 flash_bank = 0;
-    u32 act_offset = 0;
-    u32 bank_offset = 0;
-    u16 word = 0;
-    u16 i = 0;
-
-    /* We need to know which is the valid flash bank.  In the event
-     * that we didn't allocate eeprom_shadow_ram, we may not be
-     * managing flash_bank.  So it cannot be trusted and needs
-     * to be updated with each read.
-     */
-    /* Value of bit 22 corresponds to the flash bank we're on. */
-    flash_bank = (er32(EECD) & E1000_EECD_SEC1VAL) ? 1 : 0;
-
-    /* Adjust offset appropriately if we're on bank 1 - adjust for word size */
-    bank_offset = flash_bank * (hw->flash_bank_size * 2);
-
-    error = e1000_get_software_flag(hw);
-    if (error != E1000_SUCCESS)
-        return error;
-
-    for (i = 0; i < words; i++) {
-        if (hw->eeprom_shadow_ram != NULL &&
-            hw->eeprom_shadow_ram[offset+i].modified) {
-            data[i] = hw->eeprom_shadow_ram[offset+i].eeprom_word;
-        } else {
-            /* The NVM part needs a byte offset, hence * 2 */
-            act_offset = bank_offset + ((offset + i) * 2);
-            error = e1000_read_ich8_word(hw, act_offset, &word);
-            if (error != E1000_SUCCESS)
-                break;
-            data[i] = word;
-        }
-    }
-
-    e1000_release_software_flag(hw);
-
-    return error;
-}
-
-/******************************************************************************
- * Writes a 16 bit word or words to the EEPROM using the ICH8's flash access
- * register.  Actually, writes are written to the shadow ram cache in the hw
- * structure hw->e1000_shadow_ram.  e1000_commit_shadow_ram flushes this to
- * the NVM, which occurs when the NVM checksum is updated.
- *
- * hw - Struct containing variables accessed by shared code
- * offset - offset of word in the EEPROM to write
- * words - number of words to write
- * data - words to write to the EEPROM
- *****************************************************************************/
-static s32 e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
-				   u16 *data)
-{
-    u32 i = 0;
-    s32 error = E1000_SUCCESS;
-
-    error = e1000_get_software_flag(hw);
-    if (error != E1000_SUCCESS)
-        return error;
-
-    /* A driver can write to the NVM only if it has eeprom_shadow_ram
-     * allocated.  Subsequent reads to the modified words are read from
-     * this cached structure as well.  Writes will only go into this
-     * cached structure unless it's followed by a call to
-     * e1000_update_eeprom_checksum() where it will commit the changes
-     * and clear the "modified" field.
-     */
-    if (hw->eeprom_shadow_ram != NULL) {
-        for (i = 0; i < words; i++) {
-            if ((offset + i) < E1000_SHADOW_RAM_WORDS) {
-                hw->eeprom_shadow_ram[offset+i].modified = true;
-                hw->eeprom_shadow_ram[offset+i].eeprom_word = data[i];
-            } else {
-                error = -E1000_ERR_EEPROM;
-                break;
-            }
-        }
-    } else {
-        /* Drivers have the option to not allocate eeprom_shadow_ram as long
-         * as they don't perform any NVM writes.  An attempt in doing so
-         * will result in this error.
-         */
-        error = -E1000_ERR_EEPROM;
-    }
-
-    e1000_release_software_flag(hw);
-
-    return error;
-}
-
-/******************************************************************************
- * This function does initial flash setup so that a new read/write/erase cycle
- * can be started.
- *
- * hw - The pointer to the hw structure
- ****************************************************************************/
-static s32 e1000_ich8_cycle_init(struct e1000_hw *hw)
-{
-    union ich8_hws_flash_status hsfsts;
-    s32 error = E1000_ERR_EEPROM;
-    s32 i     = 0;
-
-    DEBUGFUNC("e1000_ich8_cycle_init");
-
-    hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
-
-    /* May be check the Flash Des Valid bit in Hw status */
-    if (hsfsts.hsf_status.fldesvalid == 0) {
-        DEBUGOUT("Flash descriptor invalid.  SW Sequencing must be used.");
-        return error;
-    }
-
-    /* Clear FCERR in Hw status by writing 1 */
-    /* Clear DAEL in Hw status by writing a 1 */
-    hsfsts.hsf_status.flcerr = 1;
-    hsfsts.hsf_status.dael = 1;
-
-    E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS, hsfsts.regval);
-
-    /* Either we should have a hardware SPI cycle in progress bit to check
-     * against, in order to start a new cycle or FDONE bit should be changed
-     * in the hardware so that it is 1 after harware reset, which can then be
-     * used as an indication whether a cycle is in progress or has been
-     * completed .. we should also have some software semaphore mechanism to
-     * guard FDONE or the cycle in progress bit so that two threads access to
-     * those bits can be sequentiallized or a way so that 2 threads dont
-     * start the cycle at the same time */
-
-    if (hsfsts.hsf_status.flcinprog == 0) {
-        /* There is no cycle running at present, so we can start a cycle */
-        /* Begin by setting Flash Cycle Done. */
-        hsfsts.hsf_status.flcdone = 1;
-        E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS, hsfsts.regval);
-        error = E1000_SUCCESS;
-    } else {
-        /* otherwise poll for sometime so the current cycle has a chance
-         * to end before giving up. */
-        for (i = 0; i < ICH_FLASH_COMMAND_TIMEOUT; i++) {
-            hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
-            if (hsfsts.hsf_status.flcinprog == 0) {
-                error = E1000_SUCCESS;
-                break;
-            }
-            udelay(1);
-        }
-        if (error == E1000_SUCCESS) {
-            /* Successful in waiting for previous cycle to timeout,
-             * now set the Flash Cycle Done. */
-            hsfsts.hsf_status.flcdone = 1;
-            E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS, hsfsts.regval);
-        } else {
-            DEBUGOUT("Flash controller busy, cannot get access");
-        }
-    }
-    return error;
-}
-
-/******************************************************************************
- * This function starts a flash cycle and waits for its completion
- *
- * hw - The pointer to the hw structure
- ****************************************************************************/
-static s32 e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout)
-{
-    union ich8_hws_flash_ctrl hsflctl;
-    union ich8_hws_flash_status hsfsts;
-    s32 error = E1000_ERR_EEPROM;
-    u32 i = 0;
-
-    /* Start a cycle by writing 1 in Flash Cycle Go in Hw Flash Control */
-    hsflctl.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL);
-    hsflctl.hsf_ctrl.flcgo = 1;
-    E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL, hsflctl.regval);
-
-    /* wait till FDONE bit is set to 1 */
-    do {
-        hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
-        if (hsfsts.hsf_status.flcdone == 1)
-            break;
-        udelay(1);
-        i++;
-    } while (i < timeout);
-    if (hsfsts.hsf_status.flcdone == 1 && hsfsts.hsf_status.flcerr == 0) {
-        error = E1000_SUCCESS;
-    }
-    return error;
-}
-
-/******************************************************************************
- * Reads a byte or word from the NVM using the ICH8 flash access registers.
- *
- * hw - The pointer to the hw structure
- * index - The index of the byte or word to read.
- * size - Size of data to read, 1=byte 2=word
- * data - Pointer to the word to store the value read.
- *****************************************************************************/
-static s32 e1000_read_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
-				u16 *data)
-{
-    union ich8_hws_flash_status hsfsts;
-    union ich8_hws_flash_ctrl hsflctl;
-    u32 flash_linear_address;
-    u32 flash_data = 0;
-    s32 error = -E1000_ERR_EEPROM;
-    s32 count = 0;
-
-    DEBUGFUNC("e1000_read_ich8_data");
-
-    if (size < 1  || size > 2 || data == NULL ||
-        index > ICH_FLASH_LINEAR_ADDR_MASK)
-        return error;
-
-    flash_linear_address = (ICH_FLASH_LINEAR_ADDR_MASK & index) +
-                           hw->flash_base_addr;
-
-    do {
-        udelay(1);
-        /* Steps */
-        error = e1000_ich8_cycle_init(hw);
-        if (error != E1000_SUCCESS)
-            break;
-
-        hsflctl.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL);
-        /* 0b/1b corresponds to 1 or 2 byte size, respectively. */
-        hsflctl.hsf_ctrl.fldbcount = size - 1;
-        hsflctl.hsf_ctrl.flcycle = ICH_CYCLE_READ;
-        E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL, hsflctl.regval);
-
-        /* Write the last 24 bits of index into Flash Linear address field in
-         * Flash Address */
-        /* TODO: TBD maybe check the index against the size of flash */
-
-        E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FADDR, flash_linear_address);
-
-        error = e1000_ich8_flash_cycle(hw, ICH_FLASH_COMMAND_TIMEOUT);
-
-        /* Check if FCERR is set to 1, if set to 1, clear it and try the whole
-         * sequence a few more times, else read in (shift in) the Flash Data0,
-         * the order is least significant byte first msb to lsb */
-        if (error == E1000_SUCCESS) {
-            flash_data = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_FDATA0);
-            if (size == 1) {
-                *data = (u8)(flash_data & 0x000000FF);
-            } else if (size == 2) {
-                *data = (u16)(flash_data & 0x0000FFFF);
-            }
-            break;
-        } else {
-            /* If we've gotten here, then things are probably completely hosed,
-             * but if the error condition is detected, it won't hurt to give
-             * it another try...ICH_FLASH_CYCLE_REPEAT_COUNT times.
-             */
-            hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
-            if (hsfsts.hsf_status.flcerr == 1) {
-                /* Repeat for some time before giving up. */
-                continue;
-            } else if (hsfsts.hsf_status.flcdone == 0) {
-                DEBUGOUT("Timeout error - flash cycle did not complete.");
-                break;
-            }
-        }
-    } while (count++ < ICH_FLASH_CYCLE_REPEAT_COUNT);
-
-    return error;
-}
-
-/******************************************************************************
- * Writes One /two bytes to the NVM using the ICH8 flash access registers.
- *
- * hw - The pointer to the hw structure
- * index - The index of the byte/word to read.
- * size - Size of data to read, 1=byte 2=word
- * data - The byte(s) to write to the NVM.
- *****************************************************************************/
-static s32 e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
-				 u16 data)
-{
-    union ich8_hws_flash_status hsfsts;
-    union ich8_hws_flash_ctrl hsflctl;
-    u32 flash_linear_address;
-    u32 flash_data = 0;
-    s32 error = -E1000_ERR_EEPROM;
-    s32 count = 0;
-
-    DEBUGFUNC("e1000_write_ich8_data");
-
-    if (size < 1  || size > 2 || data > size * 0xff ||
-        index > ICH_FLASH_LINEAR_ADDR_MASK)
-        return error;
-
-    flash_linear_address = (ICH_FLASH_LINEAR_ADDR_MASK & index) +
-                           hw->flash_base_addr;
-
-    do {
-        udelay(1);
-        /* Steps */
-        error = e1000_ich8_cycle_init(hw);
-        if (error != E1000_SUCCESS)
-            break;
-
-        hsflctl.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL);
-        /* 0b/1b corresponds to 1 or 2 byte size, respectively. */
-        hsflctl.hsf_ctrl.fldbcount = size -1;
-        hsflctl.hsf_ctrl.flcycle = ICH_CYCLE_WRITE;
-        E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL, hsflctl.regval);
-
-        /* Write the last 24 bits of index into Flash Linear address field in
-         * Flash Address */
-        E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FADDR, flash_linear_address);
-
-        if (size == 1)
-            flash_data = (u32)data & 0x00FF;
-        else
-            flash_data = (u32)data;
-
-        E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FDATA0, flash_data);
-
-        /* check if FCERR is set to 1 , if set to 1, clear it and try the whole
-         * sequence a few more times else done */
-        error = e1000_ich8_flash_cycle(hw, ICH_FLASH_COMMAND_TIMEOUT);
-        if (error == E1000_SUCCESS) {
-            break;
-        } else {
-            /* If we're here, then things are most likely completely hosed,
-             * but if the error condition is detected, it won't hurt to give
-             * it another try...ICH_FLASH_CYCLE_REPEAT_COUNT times.
-             */
-            hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
-            if (hsfsts.hsf_status.flcerr == 1) {
-                /* Repeat for some time before giving up. */
-                continue;
-            } else if (hsfsts.hsf_status.flcdone == 0) {
-                DEBUGOUT("Timeout error - flash cycle did not complete.");
-                break;
-            }
-        }
-    } while (count++ < ICH_FLASH_CYCLE_REPEAT_COUNT);
-
-    return error;
-}
-
-/******************************************************************************
- * Reads a single byte from the NVM using the ICH8 flash access registers.
- *
- * hw - pointer to e1000_hw structure
- * index - The index of the byte to read.
- * data - Pointer to a byte to store the value read.
- *****************************************************************************/
-static s32 e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8 *data)
-{
-    s32 status = E1000_SUCCESS;
-    u16 word = 0;
-
-    status = e1000_read_ich8_data(hw, index, 1, &word);
-    if (status == E1000_SUCCESS) {
-        *data = (u8)word;
-    }
-
-    return status;
-}
-
-/******************************************************************************
- * Writes a single byte to the NVM using the ICH8 flash access registers.
- * Performs verification by reading back the value and then going through
- * a retry algorithm before giving up.
- *
- * hw - pointer to e1000_hw structure
- * index - The index of the byte to write.
- * byte - The byte to write to the NVM.
- *****************************************************************************/
-static s32 e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte)
-{
-    s32 error = E1000_SUCCESS;
-    s32 program_retries = 0;
-
-    DEBUGOUT2("Byte := %2.2X Offset := %d\n", byte, index);
-
-    error = e1000_write_ich8_byte(hw, index, byte);
-
-    if (error != E1000_SUCCESS) {
-        for (program_retries = 0; program_retries < 100; program_retries++) {
-            DEBUGOUT2("Retrying \t Byte := %2.2X Offset := %d\n", byte, index);
-            error = e1000_write_ich8_byte(hw, index, byte);
-            udelay(100);
-            if (error == E1000_SUCCESS)
-                break;
-        }
-    }
-
-    if (program_retries == 100)
-        error = E1000_ERR_EEPROM;
-
-    return error;
-}
-
-/******************************************************************************
- * Writes a single byte to the NVM using the ICH8 flash access registers.
- *
- * hw - pointer to e1000_hw structure
- * index - The index of the byte to read.
- * data - The byte to write to the NVM.
- *****************************************************************************/
-static s32 e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 data)
-{
-    s32 status = E1000_SUCCESS;
-    u16 word = (u16)data;
-
-    status = e1000_write_ich8_data(hw, index, 1, word);
-
-    return status;
-}
-
-/******************************************************************************
- * Reads a word from the NVM using the ICH8 flash access registers.
- *
- * hw - pointer to e1000_hw structure
- * index - The starting byte index of the word to read.
- * data - Pointer to a word to store the value read.
- *****************************************************************************/
-static s32 e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data)
-{
-    s32 status = E1000_SUCCESS;
-    status = e1000_read_ich8_data(hw, index, 2, data);
-    return status;
-}
-
-/******************************************************************************
- * Erases the bank specified. Each bank may be a 4, 8 or 64k block. Banks are 0
- * based.
- *
- * hw - pointer to e1000_hw structure
- * bank - 0 for first bank, 1 for second bank
- *
- * Note that this function may actually erase as much as 8 or 64 KBytes.  The
- * amount of NVM used in each bank is a *minimum* of 4 KBytes, but in fact the
- * bank size may be 4, 8 or 64 KBytes
- *****************************************************************************/
-static s32 e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank)
-{
-    union ich8_hws_flash_status hsfsts;
-    union ich8_hws_flash_ctrl hsflctl;
-    u32 flash_linear_address;
-    s32  count = 0;
-    s32  error = E1000_ERR_EEPROM;
-    s32  iteration;
-    s32  sub_sector_size = 0;
-    s32  bank_size;
-    s32  j = 0;
-    s32  error_flag = 0;
-
-    hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
-
-    /* Determine HW Sector size: Read BERASE bits of Hw flash Status register */
-    /* 00: The Hw sector is 256 bytes, hence we need to erase 16
-     *     consecutive sectors.  The start index for the nth Hw sector can be
-     *     calculated as bank * 4096 + n * 256
-     * 01: The Hw sector is 4K bytes, hence we need to erase 1 sector.
-     *     The start index for the nth Hw sector can be calculated
-     *     as bank * 4096
-     * 10: The HW sector is 8K bytes
-     * 11: The Hw sector size is 64K bytes */
-    if (hsfsts.hsf_status.berasesz == 0x0) {
-        /* Hw sector size 256 */
-        sub_sector_size = ICH_FLASH_SEG_SIZE_256;
-        bank_size = ICH_FLASH_SECTOR_SIZE;
-        iteration = ICH_FLASH_SECTOR_SIZE / ICH_FLASH_SEG_SIZE_256;
-    } else if (hsfsts.hsf_status.berasesz == 0x1) {
-        bank_size = ICH_FLASH_SEG_SIZE_4K;
-        iteration = 1;
-    } else if (hsfsts.hsf_status.berasesz == 0x3) {
-        bank_size = ICH_FLASH_SEG_SIZE_64K;
-        iteration = 1;
-    } else {
-        return error;
-    }
-
-    for (j = 0; j < iteration ; j++) {
-        do {
-            count++;
-            /* Steps */
-            error = e1000_ich8_cycle_init(hw);
-            if (error != E1000_SUCCESS) {
-                error_flag = 1;
-                break;
-            }
-
-            /* Write a value 11 (block Erase) in Flash Cycle field in Hw flash
-             * Control */
-            hsflctl.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL);
-            hsflctl.hsf_ctrl.flcycle = ICH_CYCLE_ERASE;
-            E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL, hsflctl.regval);
-
-            /* Write the last 24 bits of an index within the block into Flash
-             * Linear address field in Flash Address.  This probably needs to
-             * be calculated here based off the on-chip erase sector size and
-             * the software bank size (4, 8 or 64 KBytes) */
-            flash_linear_address = bank * bank_size + j * sub_sector_size;
-            flash_linear_address += hw->flash_base_addr;
-            flash_linear_address &= ICH_FLASH_LINEAR_ADDR_MASK;
-
-            E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FADDR, flash_linear_address);
-
-            error = e1000_ich8_flash_cycle(hw, ICH_FLASH_ERASE_TIMEOUT);
-            /* Check if FCERR is set to 1.  If 1, clear it and try the whole
-             * sequence a few more times else Done */
-            if (error == E1000_SUCCESS) {
-                break;
-            } else {
-                hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
-                if (hsfsts.hsf_status.flcerr == 1) {
-                    /* repeat for some time before giving up */
-                    continue;
-                } else if (hsfsts.hsf_status.flcdone == 0) {
-                    error_flag = 1;
-                    break;
-                }
-            }
-        } while ((count < ICH_FLASH_CYCLE_REPEAT_COUNT) && !error_flag);
-        if (error_flag == 1)
-            break;
-    }
-    if (error_flag != 1)
-        error = E1000_SUCCESS;
-    return error;
-}
-
-static s32 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
-						 u32 cnf_base_addr,
-						 u32 cnf_size)
-{
-    u32 ret_val = E1000_SUCCESS;
-    u16 word_addr, reg_data, reg_addr;
-    u16 i;
-
-    /* cnf_base_addr is in DWORD */
-    word_addr = (u16)(cnf_base_addr << 1);
-
-    /* cnf_size is returned in size of dwords */
-    for (i = 0; i < cnf_size; i++) {
-        ret_val = e1000_read_eeprom(hw, (word_addr + i*2), 1, &reg_data);
-        if (ret_val)
-            return ret_val;
-
-        ret_val = e1000_read_eeprom(hw, (word_addr + i*2 + 1), 1, &reg_addr);
-        if (ret_val)
-            return ret_val;
-
-        ret_val = e1000_get_software_flag(hw);
-        if (ret_val != E1000_SUCCESS)
-            return ret_val;
-
-        ret_val = e1000_write_phy_reg_ex(hw, (u32)reg_addr, reg_data);
-
-        e1000_release_software_flag(hw);
-    }
-
-    return ret_val;
-}
-
-
-/******************************************************************************
- * This function initializes the PHY from the NVM on ICH8 platforms. This
- * is needed due to an issue where the NVM configuration is not properly
- * autoloaded after power transitions. Therefore, after each PHY reset, we
- * will load the configuration data out of the NVM manually.
- *
- * hw: Struct containing variables accessed by shared code
- *****************************************************************************/
-static s32 e1000_init_lcd_from_nvm(struct e1000_hw *hw)
-{
-    u32 reg_data, cnf_base_addr, cnf_size, ret_val, loop;
-
-    if (hw->phy_type != e1000_phy_igp_3)
-          return E1000_SUCCESS;
-
-    /* Check if SW needs configure the PHY */
-    reg_data = er32(FEXTNVM);
-    if (!(reg_data & FEXTNVM_SW_CONFIG))
-        return E1000_SUCCESS;
-
-    /* Wait for basic configuration completes before proceeding*/
-    loop = 0;
-    do {
-        reg_data = er32(STATUS) & E1000_STATUS_LAN_INIT_DONE;
-        udelay(100);
-        loop++;
-    } while ((!reg_data) && (loop < 50));
-
-    /* Clear the Init Done bit for the next init event */
-    reg_data = er32(STATUS);
-    reg_data &= ~E1000_STATUS_LAN_INIT_DONE;
-    ew32(STATUS, reg_data);
-
-    /* Make sure HW does not configure LCD from PHY extended configuration
-       before SW configuration */
-    reg_data = er32(EXTCNF_CTRL);
-    if ((reg_data & E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE) == 0x0000) {
-        reg_data = er32(EXTCNF_SIZE);
-        cnf_size = reg_data & E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH;
-        cnf_size >>= 16;
-        if (cnf_size) {
-            reg_data = er32(EXTCNF_CTRL);
-            cnf_base_addr = reg_data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER;
-            /* cnf_base_addr is in DWORD */
-            cnf_base_addr >>= 16;
-
-            /* Configure LCD from extended configuration region. */
-            ret_val = e1000_init_lcd_from_nvm_config_region(hw, cnf_base_addr,
-                                                            cnf_size);
-            if (ret_val)
-                return ret_val;
-        }
-    }
-
-    return E1000_SUCCESS;
-}
-
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index a8866bd..243dad2 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -57,11 +57,6 @@ typedef enum {
     e1000_82541_rev_2,
     e1000_82547,
     e1000_82547_rev_2,
-    e1000_82571,
-    e1000_82572,
-    e1000_82573,
-    e1000_80003es2lan,
-    e1000_ich8lan,
     e1000_num_macs
 } e1000_mac_type;
 
@@ -70,7 +65,6 @@ typedef enum {
     e1000_eeprom_spi,
     e1000_eeprom_microwire,
     e1000_eeprom_flash,
-    e1000_eeprom_ich8,
     e1000_eeprom_none, /* No NVM support */
     e1000_num_eeprom_types
 } e1000_eeprom_type;
@@ -109,7 +103,6 @@ typedef enum {
     e1000_bus_type_unknown = 0,
     e1000_bus_type_pci,
     e1000_bus_type_pcix,
-    e1000_bus_type_pci_express,
     e1000_bus_type_reserved
 } e1000_bus_type;
 
@@ -121,18 +114,12 @@ typedef enum {
     e1000_bus_speed_100,
     e1000_bus_speed_120,
     e1000_bus_speed_133,
-    e1000_bus_speed_2500,
     e1000_bus_speed_reserved
 } e1000_bus_speed;
 
 /* PCI bus widths */
 typedef enum {
     e1000_bus_width_unknown = 0,
-    /* These PCIe values should literally match the possible return values
-     * from config space */
-    e1000_bus_width_pciex_1 = 1,
-    e1000_bus_width_pciex_2 = 2,
-    e1000_bus_width_pciex_4 = 4,
     e1000_bus_width_32,
     e1000_bus_width_64,
     e1000_bus_width_reserved
@@ -224,10 +211,6 @@ typedef enum {
 typedef enum {
     e1000_phy_m88 = 0,
     e1000_phy_igp,
-    e1000_phy_igp_2,
-    e1000_phy_gg82563,
-    e1000_phy_igp_3,
-    e1000_phy_ife,
     e1000_phy_undefined = 0xFF
 } e1000_phy_type;
 
@@ -329,8 +312,6 @@ s32 e1000_phy_reset(struct e1000_hw *hw);
 s32 e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
 s32 e1000_validate_mdi_setting(struct e1000_hw *hw);
 
-void e1000_phy_powerdown_workaround(struct e1000_hw *hw);
-
 /* EEPROM Functions */
 s32 e1000_init_eeprom_params(struct e1000_hw *hw);
 
@@ -389,8 +370,6 @@ struct e1000_host_mng_dhcp_cookie{
 };
 #endif
 
-s32 e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer,
-                                  u16 length);
 bool e1000_check_mng_mode(struct e1000_hw *hw);
 bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
 s32 e1000_read_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
@@ -421,13 +400,10 @@ void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats, u
 void e1000_get_bus_info(struct e1000_hw *hw);
 void e1000_pci_set_mwi(struct e1000_hw *hw);
 void e1000_pci_clear_mwi(struct e1000_hw *hw);
-s32 e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value);
 void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc);
 int e1000_pcix_get_mmrbc(struct e1000_hw *hw);
 /* Port I/O is only supported on 82544 and newer */
 void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value);
-s32 e1000_disable_pciex_master(struct e1000_hw *hw);
-s32 e1000_check_phy_reset_block(struct e1000_hw *hw);
 
 
 #define E1000_READ_REG_IO(a, reg) \
@@ -471,36 +447,7 @@ s32 e1000_check_phy_reset_block(struct e1000_hw *hw);
 #define E1000_DEV_ID_82546GB_QUAD_COPPER 0x1099
 #define E1000_DEV_ID_82547EI             0x1019
 #define E1000_DEV_ID_82547EI_MOBILE      0x101A
-#define E1000_DEV_ID_82571EB_COPPER      0x105E
-#define E1000_DEV_ID_82571EB_FIBER       0x105F
-#define E1000_DEV_ID_82571EB_SERDES      0x1060
-#define E1000_DEV_ID_82571EB_QUAD_COPPER 0x10A4
-#define E1000_DEV_ID_82571PT_QUAD_COPPER 0x10D5
-#define E1000_DEV_ID_82571EB_QUAD_FIBER  0x10A5
-#define E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE  0x10BC
-#define E1000_DEV_ID_82571EB_SERDES_DUAL 0x10D9
-#define E1000_DEV_ID_82571EB_SERDES_QUAD 0x10DA
-#define E1000_DEV_ID_82572EI_COPPER      0x107D
-#define E1000_DEV_ID_82572EI_FIBER       0x107E
-#define E1000_DEV_ID_82572EI_SERDES      0x107F
-#define E1000_DEV_ID_82572EI             0x10B9
-#define E1000_DEV_ID_82573E              0x108B
-#define E1000_DEV_ID_82573E_IAMT         0x108C
-#define E1000_DEV_ID_82573L              0x109A
 #define E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3 0x10B5
-#define E1000_DEV_ID_80003ES2LAN_COPPER_DPT     0x1096
-#define E1000_DEV_ID_80003ES2LAN_SERDES_DPT     0x1098
-#define E1000_DEV_ID_80003ES2LAN_COPPER_SPT     0x10BA
-#define E1000_DEV_ID_80003ES2LAN_SERDES_SPT     0x10BB
-
-#define E1000_DEV_ID_ICH8_IGP_M_AMT      0x1049
-#define E1000_DEV_ID_ICH8_IGP_AMT        0x104A
-#define E1000_DEV_ID_ICH8_IGP_C          0x104B
-#define E1000_DEV_ID_ICH8_IFE            0x104C
-#define E1000_DEV_ID_ICH8_IFE_GT         0x10C4
-#define E1000_DEV_ID_ICH8_IFE_G          0x10C5
-#define E1000_DEV_ID_ICH8_IGP_M          0x104D
-
 
 #define NODE_ADDRESS_SIZE 6
 #define ETH_LENGTH_OF_ADDRESS 6
@@ -567,15 +514,6 @@ s32 e1000_check_phy_reset_block(struct e1000_hw *hw);
     E1000_IMS_RXSEQ  |    \
     E1000_IMS_LSC)
 
-/* Additional interrupts need to be handled for e1000_ich8lan:
-    DSW = The FW changed the status of the DISSW bit in FWSM
-    PHYINT = The LAN connected device generates an interrupt
-    EPRST = Manageability reset event */
-#define IMS_ICH8LAN_ENABLE_MASK (\
-    E1000_IMS_DSW   | \
-    E1000_IMS_PHYINT | \
-    E1000_IMS_EPRST)
-
 /* Number of high/low register pairs in the RAR. The RAR (Receive Address
  * Registers) holds the directed and multicast addresses that we monitor. We
  * reserve one of these spots for our directed address, allowing us room for
@@ -583,8 +521,6 @@ s32 e1000_check_phy_reset_block(struct e1000_hw *hw);
  */
 #define E1000_RAR_ENTRIES 15
 
-#define E1000_RAR_ENTRIES_ICH8LAN  6
-
 #define MIN_NUMBER_OF_DESCRIPTORS  8
 #define MAX_NUMBER_OF_DESCRIPTORS  0xFFF8
 
@@ -806,10 +742,6 @@ struct e1000_data_desc {
 #define E1000_MC_TBL_SIZE          128  /* Multicast Filter Table (4096 bits) */
 #define E1000_VLAN_FILTER_TBL_SIZE 128  /* VLAN Filter Table (4096 bits) */
 
-#define E1000_NUM_UNICAST_ICH8LAN  7
-#define E1000_MC_TBL_SIZE_ICH8LAN  32
-
-
 /* Receive Address Register */
 struct e1000_rar {
     volatile __le32 low;      /* receive address low */
@@ -818,7 +750,6 @@ struct e1000_rar {
 
 /* Number of entries in the Multicast Table Array (MTA). */
 #define E1000_NUM_MTA_REGISTERS 128
-#define E1000_NUM_MTA_REGISTERS_ICH8LAN 32
 
 /* IPv4 Address Table Entry */
 struct e1000_ipv4_at_entry {
@@ -829,7 +760,6 @@ struct e1000_ipv4_at_entry {
 /* Four wakeup IP addresses are supported */
 #define E1000_WAKEUP_IP_ADDRESS_COUNT_MAX 4
 #define E1000_IP4AT_SIZE                  E1000_WAKEUP_IP_ADDRESS_COUNT_MAX
-#define E1000_IP4AT_SIZE_ICH8LAN          3
 #define E1000_IP6AT_SIZE                  1
 
 /* IPv6 Address Table Entry */
@@ -1063,7 +993,6 @@ struct e1000_ffvt_entry {
 
 #define E1000_KUMCTRLSTA 0x00034 /* MAC-PHY interface - RW */
 #define E1000_MDPHYA     0x0003C  /* PHY address - RW */
-#define E1000_MANC2H     0x05860  /* Managment Control To Host - RW */
 #define E1000_SW_FW_SYNC 0x05B5C /* Software-Firmware Synchronization - RW */
 
 #define E1000_GCR       0x05B00 /* PCI-Ex Control */
@@ -1302,7 +1231,6 @@ struct e1000_ffvt_entry {
 #define E1000_82542_RSSIR       E1000_RSSIR
 #define E1000_82542_KUMCTRLSTA E1000_KUMCTRLSTA
 #define E1000_82542_SW_FW_SYNC E1000_SW_FW_SYNC
-#define E1000_82542_MANC2H      E1000_MANC2H
 
 /* Statistics counters collected by the MAC */
 struct e1000_hw_stats {
@@ -1399,8 +1327,7 @@ struct e1000_hw {
 	e1000_ffe_config	ffe_config_state;
 	u32		asf_firmware_present;
 	u32		eeprom_semaphore_present;
-	u32		swfw_sync_present;
-	u32		swfwhw_semaphore_present;
+	u32             swfw_sync_present;
 	unsigned long		io_base;
 	u32		phy_id;
 	u32		phy_revision;
@@ -1461,10 +1388,7 @@ struct e1000_hw {
 	bool			in_ifs_mode;
 	bool			mng_reg_access_disabled;
 	bool			leave_av_bit_off;
-	bool			kmrn_lock_loss_workaround_disabled;
 	bool			bad_tx_carr_stats_fd;
-	bool			has_manc2h;
-	bool			rx_needs_kicking;
 	bool			has_smbus;
 };
 
@@ -2018,8 +1942,6 @@ struct e1000_hw {
 #define E1000_TCTL_EXT_BST_MASK  0x000003FF /* Backoff Slot Time */
 #define E1000_TCTL_EXT_GCEX_MASK 0x000FFC00 /* Gigabit Carry Extend Padding */
 
-#define DEFAULT_80003ES2LAN_TCTL_EXT_GCEX   0x00010000
-
 /* Receive Checksum Control */
 #define E1000_RXCSUM_PCSS_MASK 0x000000FF   /* Packet Checksum Start */
 #define E1000_RXCSUM_IPOFL     0x00000100   /* IPv4 checksum offload */
@@ -2289,16 +2211,10 @@ struct e1000_host_command_info {
 /* Word definitions for ID LED Settings */
 #define ID_LED_RESERVED_0000 0x0000
 #define ID_LED_RESERVED_FFFF 0xFFFF
-#define ID_LED_RESERVED_82573  0xF746
-#define ID_LED_DEFAULT_82573   0x1811
 #define ID_LED_DEFAULT       ((ID_LED_OFF1_ON2 << 12) | \
                               (ID_LED_OFF1_OFF2 << 8) | \
                               (ID_LED_DEF1_DEF2 << 4) | \
                               (ID_LED_DEF1_DEF2))
-#define ID_LED_DEFAULT_ICH8LAN  ((ID_LED_DEF1_DEF2 << 12) | \
-                                 (ID_LED_DEF1_OFF2 <<  8) | \
-                                 (ID_LED_DEF1_ON2  <<  4) | \
-                                 (ID_LED_DEF1_DEF2))
 #define ID_LED_DEF1_DEF2     0x1
 #define ID_LED_DEF1_ON2      0x2
 #define ID_LED_DEF1_OFF2     0x3
@@ -2384,11 +2300,8 @@ struct e1000_host_command_info {
 
 #define DEFAULT_82542_TIPG_IPGR2 10
 #define DEFAULT_82543_TIPG_IPGR2 6
-#define DEFAULT_80003ES2LAN_TIPG_IPGR2 7
 #define E1000_TIPG_IPGR2_SHIFT  20
 
-#define DEFAULT_80003ES2LAN_TIPG_IPGT_10_100 0x00000009
-#define DEFAULT_80003ES2LAN_TIPG_IPGT_1000   0x00000008
 #define E1000_TXDMAC_DPP 0x00000001
 
 /* Adaptive IFS defines */
@@ -2485,8 +2398,6 @@ struct e1000_host_command_info {
 /* Number of milliseconds we wait for auto-negotiation to complete */
 #define LINK_UP_TIMEOUT             500
 
-/* Number of 100 microseconds we wait for PCI Express master disable */
-#define MASTER_DISABLE_TIMEOUT      800
 /* Number of milliseconds we wait for Eeprom auto read bit done after MAC reset */
 #define AUTO_READ_DONE_TIMEOUT      10
 /* Number of milliseconds we wait for PHY configuration done after MAC reset */
@@ -2636,79 +2547,6 @@ struct e1000_host_command_info {
 
 #define IGP01E1000_ANALOG_REGS_PAGE  0x20C0
 
-/* Bits...
- * 15-5: page
- * 4-0: register offset
- */
-#define GG82563_PAGE_SHIFT        5
-#define GG82563_REG(page, reg)    \
-        (((page) << GG82563_PAGE_SHIFT) | ((reg) & MAX_PHY_REG_ADDRESS))
-#define GG82563_MIN_ALT_REG       30
-
-/* GG82563 Specific Registers */
-#define GG82563_PHY_SPEC_CTRL           \
-        GG82563_REG(0, 16) /* PHY Specific Control */
-#define GG82563_PHY_SPEC_STATUS         \
-        GG82563_REG(0, 17) /* PHY Specific Status */
-#define GG82563_PHY_INT_ENABLE          \
-        GG82563_REG(0, 18) /* Interrupt Enable */
-#define GG82563_PHY_SPEC_STATUS_2       \
-        GG82563_REG(0, 19) /* PHY Specific Status 2 */
-#define GG82563_PHY_RX_ERR_CNTR         \
-        GG82563_REG(0, 21) /* Receive Error Counter */
-#define GG82563_PHY_PAGE_SELECT         \
-        GG82563_REG(0, 22) /* Page Select */
-#define GG82563_PHY_SPEC_CTRL_2         \
-        GG82563_REG(0, 26) /* PHY Specific Control 2 */
-#define GG82563_PHY_PAGE_SELECT_ALT     \
-        GG82563_REG(0, 29) /* Alternate Page Select */
-#define GG82563_PHY_TEST_CLK_CTRL       \
-        GG82563_REG(0, 30) /* Test Clock Control (use reg. 29 to select) */
-
-#define GG82563_PHY_MAC_SPEC_CTRL       \
-        GG82563_REG(2, 21) /* MAC Specific Control Register */
-#define GG82563_PHY_MAC_SPEC_CTRL_2     \
-        GG82563_REG(2, 26) /* MAC Specific Control 2 */
-
-#define GG82563_PHY_DSP_DISTANCE    \
-        GG82563_REG(5, 26) /* DSP Distance */
-
-/* Page 193 - Port Control Registers */
-#define GG82563_PHY_KMRN_MODE_CTRL   \
-        GG82563_REG(193, 16) /* Kumeran Mode Control */
-#define GG82563_PHY_PORT_RESET          \
-        GG82563_REG(193, 17) /* Port Reset */
-#define GG82563_PHY_REVISION_ID         \
-        GG82563_REG(193, 18) /* Revision ID */
-#define GG82563_PHY_DEVICE_ID           \
-        GG82563_REG(193, 19) /* Device ID */
-#define GG82563_PHY_PWR_MGMT_CTRL       \
-        GG82563_REG(193, 20) /* Power Management Control */
-#define GG82563_PHY_RATE_ADAPT_CTRL     \
-        GG82563_REG(193, 25) /* Rate Adaptation Control */
-
-/* Page 194 - KMRN Registers */
-#define GG82563_PHY_KMRN_FIFO_CTRL_STAT \
-        GG82563_REG(194, 16) /* FIFO's Control/Status */
-#define GG82563_PHY_KMRN_CTRL           \
-        GG82563_REG(194, 17) /* Control */
-#define GG82563_PHY_INBAND_CTRL         \
-        GG82563_REG(194, 18) /* Inband Control */
-#define GG82563_PHY_KMRN_DIAGNOSTIC     \
-        GG82563_REG(194, 19) /* Diagnostic */
-#define GG82563_PHY_ACK_TIMEOUTS        \
-        GG82563_REG(194, 20) /* Acknowledge Timeouts */
-#define GG82563_PHY_ADV_ABILITY         \
-        GG82563_REG(194, 21) /* Advertised Ability */
-#define GG82563_PHY_LINK_PARTNER_ADV_ABILITY \
-        GG82563_REG(194, 23) /* Link Partner Advertised Ability */
-#define GG82563_PHY_ADV_NEXT_PAGE       \
-        GG82563_REG(194, 24) /* Advertised Next Page */
-#define GG82563_PHY_LINK_PARTNER_ADV_NEXT_PAGE \
-        GG82563_REG(194, 25) /* Link Partner Advertised Next page */
-#define GG82563_PHY_KMRN_MISC           \
-        GG82563_REG(194, 26) /* Misc. */
-
 /* PHY Control Register */
 #define MII_CR_SPEED_SELECT_MSB 0x0040  /* bits 6,13: 10=1000, 01=100, 00=10 */
 #define MII_CR_COLL_TEST_ENABLE 0x0080  /* Collision test enable */
@@ -3032,114 +2870,6 @@ struct e1000_host_command_info {
 #define IGP01E1000_ANALOG_FUSE_FINE_1               0x0080
 #define IGP01E1000_ANALOG_FUSE_FINE_10              0x0500
 
-/* GG82563 PHY Specific Status Register (Page 0, Register 16 */
-#define GG82563_PSCR_DISABLE_JABBER             0x0001 /* 1=Disable Jabber */
-#define GG82563_PSCR_POLARITY_REVERSAL_DISABLE  0x0002 /* 1=Polarity Reversal Disabled */
-#define GG82563_PSCR_POWER_DOWN                 0x0004 /* 1=Power Down */
-#define GG82563_PSCR_COPPER_TRANSMITER_DISABLE  0x0008 /* 1=Transmitter Disabled */
-#define GG82563_PSCR_CROSSOVER_MODE_MASK        0x0060
-#define GG82563_PSCR_CROSSOVER_MODE_MDI         0x0000 /* 00=Manual MDI configuration */
-#define GG82563_PSCR_CROSSOVER_MODE_MDIX        0x0020 /* 01=Manual MDIX configuration */
-#define GG82563_PSCR_CROSSOVER_MODE_AUTO        0x0060 /* 11=Automatic crossover */
-#define GG82563_PSCR_ENALBE_EXTENDED_DISTANCE   0x0080 /* 1=Enable Extended Distance */
-#define GG82563_PSCR_ENERGY_DETECT_MASK         0x0300
-#define GG82563_PSCR_ENERGY_DETECT_OFF          0x0000 /* 00,01=Off */
-#define GG82563_PSCR_ENERGY_DETECT_RX           0x0200 /* 10=Sense on Rx only (Energy Detect) */
-#define GG82563_PSCR_ENERGY_DETECT_RX_TM        0x0300 /* 11=Sense and Tx NLP */
-#define GG82563_PSCR_FORCE_LINK_GOOD            0x0400 /* 1=Force Link Good */
-#define GG82563_PSCR_DOWNSHIFT_ENABLE           0x0800 /* 1=Enable Downshift */
-#define GG82563_PSCR_DOWNSHIFT_COUNTER_MASK     0x7000
-#define GG82563_PSCR_DOWNSHIFT_COUNTER_SHIFT    12
-
-/* PHY Specific Status Register (Page 0, Register 17) */
-#define GG82563_PSSR_JABBER                0x0001 /* 1=Jabber */
-#define GG82563_PSSR_POLARITY              0x0002 /* 1=Polarity Reversed */
-#define GG82563_PSSR_LINK                  0x0008 /* 1=Link is Up */
-#define GG82563_PSSR_ENERGY_DETECT         0x0010 /* 1=Sleep, 0=Active */
-#define GG82563_PSSR_DOWNSHIFT             0x0020 /* 1=Downshift */
-#define GG82563_PSSR_CROSSOVER_STATUS      0x0040 /* 1=MDIX, 0=MDI */
-#define GG82563_PSSR_RX_PAUSE_ENABLED      0x0100 /* 1=Receive Pause Enabled */
-#define GG82563_PSSR_TX_PAUSE_ENABLED      0x0200 /* 1=Transmit Pause Enabled */
-#define GG82563_PSSR_LINK_UP               0x0400 /* 1=Link Up */
-#define GG82563_PSSR_SPEED_DUPLEX_RESOLVED 0x0800 /* 1=Resolved */
-#define GG82563_PSSR_PAGE_RECEIVED         0x1000 /* 1=Page Received */
-#define GG82563_PSSR_DUPLEX                0x2000 /* 1-Full-Duplex */
-#define GG82563_PSSR_SPEED_MASK            0xC000
-#define GG82563_PSSR_SPEED_10MBPS          0x0000 /* 00=10Mbps */
-#define GG82563_PSSR_SPEED_100MBPS         0x4000 /* 01=100Mbps */
-#define GG82563_PSSR_SPEED_1000MBPS        0x8000 /* 10=1000Mbps */
-
-/* PHY Specific Status Register 2 (Page 0, Register 19) */
-#define GG82563_PSSR2_JABBER                0x0001 /* 1=Jabber */
-#define GG82563_PSSR2_POLARITY_CHANGED      0x0002 /* 1=Polarity Changed */
-#define GG82563_PSSR2_ENERGY_DETECT_CHANGED 0x0010 /* 1=Energy Detect Changed */
-#define GG82563_PSSR2_DOWNSHIFT_INTERRUPT   0x0020 /* 1=Downshift Detected */
-#define GG82563_PSSR2_MDI_CROSSOVER_CHANGE  0x0040 /* 1=Crossover Changed */
-#define GG82563_PSSR2_FALSE_CARRIER         0x0100 /* 1=False Carrier */
-#define GG82563_PSSR2_SYMBOL_ERROR          0x0200 /* 1=Symbol Error */
-#define GG82563_PSSR2_LINK_STATUS_CHANGED   0x0400 /* 1=Link Status Changed */
-#define GG82563_PSSR2_AUTO_NEG_COMPLETED    0x0800 /* 1=Auto-Neg Completed */
-#define GG82563_PSSR2_PAGE_RECEIVED         0x1000 /* 1=Page Received */
-#define GG82563_PSSR2_DUPLEX_CHANGED        0x2000 /* 1=Duplex Changed */
-#define GG82563_PSSR2_SPEED_CHANGED         0x4000 /* 1=Speed Changed */
-#define GG82563_PSSR2_AUTO_NEG_ERROR        0x8000 /* 1=Auto-Neg Error */
-
-/* PHY Specific Control Register 2 (Page 0, Register 26) */
-#define GG82563_PSCR2_10BT_POLARITY_FORCE           0x0002 /* 1=Force Negative Polarity */
-#define GG82563_PSCR2_1000MB_TEST_SELECT_MASK       0x000C
-#define GG82563_PSCR2_1000MB_TEST_SELECT_NORMAL     0x0000 /* 00,01=Normal Operation */
-#define GG82563_PSCR2_1000MB_TEST_SELECT_112NS      0x0008 /* 10=Select 112ns Sequence */
-#define GG82563_PSCR2_1000MB_TEST_SELECT_16NS       0x000C /* 11=Select 16ns Sequence */
-#define GG82563_PSCR2_REVERSE_AUTO_NEG              0x2000 /* 1=Reverse Auto-Negotiation */
-#define GG82563_PSCR2_1000BT_DISABLE                0x4000 /* 1=Disable 1000BASE-T */
-#define GG82563_PSCR2_TRANSMITER_TYPE_MASK          0x8000
-#define GG82563_PSCR2_TRANSMITTER_TYPE_CLASS_B      0x0000 /* 0=Class B */
-#define GG82563_PSCR2_TRANSMITTER_TYPE_CLASS_A      0x8000 /* 1=Class A */
-
-/* MAC Specific Control Register (Page 2, Register 21) */
-/* Tx clock speed for Link Down and 1000BASE-T for the following speeds */
-#define GG82563_MSCR_TX_CLK_MASK                    0x0007
-#define GG82563_MSCR_TX_CLK_10MBPS_2_5MHZ           0x0004
-#define GG82563_MSCR_TX_CLK_100MBPS_25MHZ           0x0005
-#define GG82563_MSCR_TX_CLK_1000MBPS_2_5MHZ         0x0006
-#define GG82563_MSCR_TX_CLK_1000MBPS_25MHZ          0x0007
-
-#define GG82563_MSCR_ASSERT_CRS_ON_TX               0x0010 /* 1=Assert */
-
-/* DSP Distance Register (Page 5, Register 26) */
-#define GG82563_DSPD_CABLE_LENGTH               0x0007 /* 0 = <50M;
-                                                          1 = 50-80M;
-                                                          2 = 80-110M;
-                                                          3 = 110-140M;
-                                                          4 = >140M */
-
-/* Kumeran Mode Control Register (Page 193, Register 16) */
-#define GG82563_KMCR_PHY_LEDS_EN                    0x0020 /* 1=PHY LEDs, 0=Kumeran Inband LEDs */
-#define GG82563_KMCR_FORCE_LINK_UP                  0x0040 /* 1=Force Link Up */
-#define GG82563_KMCR_SUPPRESS_SGMII_EPD_EXT         0x0080
-#define GG82563_KMCR_MDIO_BUS_SPEED_SELECT_MASK     0x0400
-#define GG82563_KMCR_MDIO_BUS_SPEED_SELECT          0x0400 /* 1=6.25MHz, 0=0.8MHz */
-#define GG82563_KMCR_PASS_FALSE_CARRIER             0x0800
-
-/* Power Management Control Register (Page 193, Register 20) */
-#define GG82563_PMCR_ENABLE_ELECTRICAL_IDLE         0x0001 /* 1=Enalbe SERDES Electrical Idle */
-#define GG82563_PMCR_DISABLE_PORT                   0x0002 /* 1=Disable Port */
-#define GG82563_PMCR_DISABLE_SERDES                 0x0004 /* 1=Disable SERDES */
-#define GG82563_PMCR_REVERSE_AUTO_NEG               0x0008 /* 1=Enable Reverse Auto-Negotiation */
-#define GG82563_PMCR_DISABLE_1000_NON_D0            0x0010 /* 1=Disable 1000Mbps Auto-Neg in non D0 */
-#define GG82563_PMCR_DISABLE_1000                   0x0020 /* 1=Disable 1000Mbps Auto-Neg Always */
-#define GG82563_PMCR_REVERSE_AUTO_NEG_D0A           0x0040 /* 1=Enable D0a Reverse Auto-Negotiation */
-#define GG82563_PMCR_FORCE_POWER_STATE              0x0080 /* 1=Force Power State */
-#define GG82563_PMCR_PROGRAMMED_POWER_STATE_MASK    0x0300
-#define GG82563_PMCR_PROGRAMMED_POWER_STATE_DR      0x0000 /* 00=Dr */
-#define GG82563_PMCR_PROGRAMMED_POWER_STATE_D0U     0x0100 /* 01=D0u */
-#define GG82563_PMCR_PROGRAMMED_POWER_STATE_D0A     0x0200 /* 10=D0a */
-#define GG82563_PMCR_PROGRAMMED_POWER_STATE_D3      0x0300 /* 11=D3 */
-
-/* In-Band Control Register (Page 194, Register 18) */
-#define GG82563_ICR_DIS_PADDING                     0x0010 /* Disable Padding Use */
-
-
 /* Bit definitions for valid PHY IDs. */
 /* I = Integrated
  * E = External
@@ -3154,7 +2884,6 @@ struct e1000_host_command_info {
 #define M88E1011_I_REV_4   0x04
 #define M88E1111_I_PHY_ID  0x01410CC0
 #define L1LXT971A_PHY_ID   0x001378E0
-#define GG82563_E_PHY_ID   0x01410CA0
 
 
 /* Bits...
@@ -3305,74 +3034,6 @@ struct e1000_host_command_info {
 #define ICH_GFPREG_BASE_MASK       0x1FFF
 #define ICH_FLASH_LINEAR_ADDR_MASK 0x00FFFFFF
 
-/* ICH8 GbE Flash Hardware Sequencing Flash Status Register bit breakdown */
-/* Offset 04h HSFSTS */
-union ich8_hws_flash_status {
-    struct ich8_hsfsts {
-#ifdef __BIG_ENDIAN
-        u16 reserved2      :6;
-        u16 fldesvalid     :1;
-        u16 flockdn        :1;
-        u16 flcdone        :1;
-        u16 flcerr         :1;
-        u16 dael           :1;
-        u16 berasesz       :2;
-        u16 flcinprog      :1;
-        u16 reserved1      :2;
-#else
-        u16 flcdone        :1;   /* bit 0 Flash Cycle Done */
-        u16 flcerr         :1;   /* bit 1 Flash Cycle Error */
-        u16 dael           :1;   /* bit 2 Direct Access error Log */
-        u16 berasesz       :2;   /* bit 4:3 Block/Sector Erase Size */
-        u16 flcinprog      :1;   /* bit 5 flash SPI cycle in Progress */
-        u16 reserved1      :2;   /* bit 13:6 Reserved */
-        u16 reserved2      :6;   /* bit 13:6 Reserved */
-        u16 fldesvalid     :1;   /* bit 14 Flash Descriptor Valid */
-        u16 flockdn        :1;   /* bit 15 Flash Configuration Lock-Down */
-#endif
-    } hsf_status;
-    u16 regval;
-};
-
-/* ICH8 GbE Flash Hardware Sequencing Flash control Register bit breakdown */
-/* Offset 06h FLCTL */
-union ich8_hws_flash_ctrl {
-    struct ich8_hsflctl {
-#ifdef __BIG_ENDIAN
-        u16 fldbcount      :2;
-        u16 flockdn        :6;
-        u16 flcgo          :1;
-        u16 flcycle        :2;
-        u16 reserved       :5;
-#else
-        u16 flcgo          :1;   /* 0 Flash Cycle Go */
-        u16 flcycle        :2;   /* 2:1 Flash Cycle */
-        u16 reserved       :5;   /* 7:3 Reserved  */
-        u16 fldbcount      :2;   /* 9:8 Flash Data Byte Count */
-        u16 flockdn        :6;   /* 15:10 Reserved */
-#endif
-    } hsf_ctrl;
-    u16 regval;
-};
-
-/* ICH8 Flash Region Access Permissions */
-union ich8_hws_flash_regacc {
-    struct ich8_flracc {
-#ifdef __BIG_ENDIAN
-        u32 gmwag          :8;
-        u32 gmrag          :8;
-        u32 grwa           :8;
-        u32 grra           :8;
-#else
-        u32 grra           :8;   /* 0:7 GbE region Read Access */
-        u32 grwa           :8;   /* 8:15 GbE region Write Access */
-        u32 gmrag          :8;   /* 23:16 GbE Master Read Access Grant  */
-        u32 gmwag          :8;   /* 31:24 GbE Master Write Access Grant */
-#endif
-    } hsf_flregacc;
-    u16 regval;
-};
-
 /* Miscellaneous PHY bit definitions. */
 #define PHY_PREAMBLE        0xFFFFFFFF
 #define PHY_SOF             0x01
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index c66dd4f..cad6f65 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -31,7 +31,7 @@
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-#define DRV_VERSION "7.3.21-k3-NAPI"
+#define DRV_VERSION "7.3.21-k5-NAPI"
 const char e1000_driver_version[] = DRV_VERSION;
 static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
@@ -131,7 +131,6 @@ static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t e1000_intr(int irq, void *data);
-static irqreturn_t e1000_intr_msi(int irq, void *data);
 static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			       struct e1000_tx_ring *tx_ring);
 static int e1000_clean(struct napi_struct *napi, int budget);
@@ -258,25 +257,14 @@ module_exit(e1000_exit_module);
 
 static int e1000_request_irq(struct e1000_adapter *adapter)
 {
-	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	irq_handler_t handler = e1000_intr;
 	int irq_flags = IRQF_SHARED;
 	int err;
 
-	if (hw->mac_type >= e1000_82571) {
-		adapter->have_msi = !pci_enable_msi(adapter->pdev);
-		if (adapter->have_msi) {
-			handler = e1000_intr_msi;
-			irq_flags = 0;
-		}
-	}
-
 	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
 	                  netdev);
 	if (err) {
-		if (adapter->have_msi)
-			pci_disable_msi(adapter->pdev);
 		DPRINTK(PROBE, ERR,
 		        "Unable to allocate interrupt Error: %d\n", err);
 	}
@@ -289,9 +277,6 @@ static void e1000_free_irq(struct e1000_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 
 	free_irq(adapter->pdev->irq, netdev);
-
-	if (adapter->have_msi)
-		pci_disable_msi(adapter->pdev);
 }
 
 /**
@@ -345,76 +330,6 @@ static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
 	}
 }
 
-/**
- * e1000_release_hw_control - release control of the h/w to f/w
- * @adapter: address of board private structure
- *
- * e1000_release_hw_control resets {CTRL_EXT|FWSM}:DRV_LOAD bit.
- * For ASF and Pass Through versions of f/w this means that the
- * driver is no longer loaded. For AMT version (only with 82573) i
- * of the f/w this means that the network i/f is closed.
- *
- **/
-
-static void e1000_release_hw_control(struct e1000_adapter *adapter)
-{
-	u32 ctrl_ext;
-	u32 swsm;
-	struct e1000_hw *hw = &adapter->hw;
-
-	/* Let firmware taken over control of h/w */
-	switch (hw->mac_type) {
-	case e1000_82573:
-		swsm = er32(SWSM);
-		ew32(SWSM, swsm & ~E1000_SWSM_DRV_LOAD);
-		break;
-	case e1000_82571:
-	case e1000_82572:
-	case e1000_80003es2lan:
-	case e1000_ich8lan:
-		ctrl_ext = er32(CTRL_EXT);
-		ew32(CTRL_EXT, ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
-		break;
-	default:
-		break;
-	}
-}
-
-/**
- * e1000_get_hw_control - get control of the h/w from f/w
- * @adapter: address of board private structure
- *
- * e1000_get_hw_control sets {CTRL_EXT|FWSM}:DRV_LOAD bit.
- * For ASF and Pass Through versions of f/w this means that
- * the driver is loaded. For AMT version (only with 82573)
- * of the f/w this means that the network i/f is open.
- *
- **/
-
-static void e1000_get_hw_control(struct e1000_adapter *adapter)
-{
-	u32 ctrl_ext;
-	u32 swsm;
-	struct e1000_hw *hw = &adapter->hw;
-
-	/* Let firmware know the driver has taken over */
-	switch (hw->mac_type) {
-	case e1000_82573:
-		swsm = er32(SWSM);
-		ew32(SWSM, swsm | E1000_SWSM_DRV_LOAD);
-		break;
-	case e1000_82571:
-	case e1000_82572:
-	case e1000_80003es2lan:
-	case e1000_ich8lan:
-		ctrl_ext = er32(CTRL_EXT);
-		ew32(CTRL_EXT, ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
-		break;
-	default:
-		break;
-	}
-}
-
 static void e1000_init_manageability(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
@@ -425,20 +340,6 @@ static void e1000_init_manageability(struct e1000_adapter *adapter)
 		/* disable hardware interception of ARP */
 		manc &= ~(E1000_MANC_ARP_EN);
 
-		/* enable receiving management packets to the host */
-		/* this will probably generate destination unreachable messages
-		 * from the host OS, but the packets will be handled on SMBUS */
-		if (hw->has_manc2h) {
-			u32 manc2h = er32(MANC2H);
-
-			manc |= E1000_MANC_EN_MNG2HOST;
-#define E1000_MNG2HOST_PORT_623 (1 << 5)
-#define E1000_MNG2HOST_PORT_664 (1 << 6)
-			manc2h |= E1000_MNG2HOST_PORT_623;
-			manc2h |= E1000_MNG2HOST_PORT_664;
-			ew32(MANC2H, manc2h);
-		}
-
 		ew32(MANC, manc);
 	}
 }
@@ -453,12 +354,6 @@ static void e1000_release_manageability(struct e1000_adapter *adapter)
 		/* re-enable hardware interception of ARP */
 		manc |= E1000_MANC_ARP_EN;
 
-		if (hw->has_manc2h)
-			manc &= ~E1000_MANC_EN_MNG2HOST;
-
-		/* don't explicitly have to mess with MANC2H since
-		 * MANC has an enable disable that gates MANC2H */
-
 		ew32(MANC, manc);
 	}
 }
@@ -563,15 +458,6 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 			if (er32(MANC) & E1000_MANC_SMBUS_EN)
 				goto out;
 			break;
-		case e1000_82571:
-		case e1000_82572:
-		case e1000_82573:
-		case e1000_80003es2lan:
-		case e1000_ich8lan:
-			if (e1000_check_mng_mode(hw) ||
-			    e1000_check_phy_reset_block(hw))
-				goto out;
-			break;
 		default:
 			goto out;
 		}
@@ -671,16 +557,6 @@ void e1000_reset(struct e1000_adapter *adapter)
 		legacy_pba_adjust = true;
 		pba = E1000_PBA_30K;
 		break;
-	case e1000_82571:
-	case e1000_82572:
-	case e1000_80003es2lan:
-		pba = E1000_PBA_38K;
-		break;
-	case e1000_82573:
-		pba = E1000_PBA_20K;
-		break;
-	case e1000_ich8lan:
-		pba = E1000_PBA_8K;
 	case e1000_undefined:
 	case e1000_num_macs:
 		break;
@@ -744,16 +620,8 @@ void e1000_reset(struct e1000_adapter *adapter)
 
 			/* if short on rx space, rx wins and must trump tx
 			 * adjustment or use Early Receive if available */
-			if (pba < min_rx_space) {
-				switch (hw->mac_type) {
-				case e1000_82573:
-					/* ERT enabled in e1000_configure_rx */
-					break;
-				default:
-					pba = min_rx_space;
-					break;
-				}
-			}
+			if (pba < min_rx_space)
+				pba = min_rx_space;
 		}
 	}
 
@@ -789,7 +657,6 @@ void e1000_reset(struct e1000_adapter *adapter)
 
 	/* if (adapter->hwflags & HWFLAGS_PHY_PWR_BIT) { */
 	if (hw->mac_type >= e1000_82544 &&
-	    hw->mac_type <= e1000_82547_rev_2 &&
 	    hw->autoneg == 1 &&
 	    hw->autoneg_advertised == ADVERTISE_1000_FULL) {
 		u32 ctrl = er32(CTRL);
@@ -806,20 +673,6 @@ void e1000_reset(struct e1000_adapter *adapter)
 	e1000_reset_adaptive(hw);
 	e1000_phy_get_info(hw, &adapter->phy_info);
 
-	if (!adapter->smart_power_down &&
-	    (hw->mac_type == e1000_82571 ||
-	     hw->mac_type == e1000_82572)) {
-		u16 phy_data = 0;
-		/* speed up time to link by disabling smart power down, ignore
-		 * the return value of this function because there is nothing
-		 * different we would do if it failed */
-		e1000_read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
-		                   &phy_data);
-		phy_data &= ~IGP02E1000_PM_SPD;
-		e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
-		                    phy_data);
-	}
-
 	e1000_release_manageability(adapter);
 }
 
@@ -1046,17 +899,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		goto err_sw_init;
 
 	err = -EIO;
-	/* Flash BAR mapping must happen after e1000_sw_init
-	 * because it depends on mac_type */
-	if ((hw->mac_type == e1000_ich8lan) &&
-	   (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		hw->flash_address = pci_ioremap_bar(pdev, 1);
-		if (!hw->flash_address)
-			goto err_flashmap;
-	}
-
-	if (e1000_check_phy_reset_block(hw))
-		DPRINTK(PROBE, INFO, "PHY reset is blocked due to SOL/IDER session.\n");
 
 	if (hw->mac_type >= e1000_82543) {
 		netdev->features = NETIF_F_SG |
@@ -1064,21 +906,16 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 				   NETIF_F_HW_VLAN_TX |
 				   NETIF_F_HW_VLAN_RX |
 				   NETIF_F_HW_VLAN_FILTER;
-		if (hw->mac_type == e1000_ich8lan)
-			netdev->features &= ~NETIF_F_HW_VLAN_FILTER;
 	}
 
 	if ((hw->mac_type >= e1000_82544) &&
 	   (hw->mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 
-	if (hw->mac_type > e1000_82547_rev_2)
-		netdev->features |= NETIF_F_TSO6;
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
 	netdev->vlan_features |= NETIF_F_TSO;
-	netdev->vlan_features |= NETIF_F_TSO6;
 	netdev->vlan_features |= NETIF_F_HW_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
@@ -1153,15 +990,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 			EEPROM_INIT_CONTROL2_REG, 1, &eeprom_data);
 		eeprom_apme_mask = E1000_EEPROM_82544_APM;
 		break;
-	case e1000_ich8lan:
-		e1000_read_eeprom(hw,
-			EEPROM_INIT_CONTROL1_REG, 1, &eeprom_data);
-		eeprom_apme_mask = E1000_EEPROM_ICH8_APME;
-		break;
 	case e1000_82546:
 	case e1000_82546_rev_3:
-	case e1000_82571:
-	case e1000_80003es2lan:
 		if (er32(STATUS) & E1000_STATUS_FUNC_1){
 			e1000_read_eeprom(hw,
 				EEPROM_INIT_CONTROL3_PORT_B, 1, &eeprom_data);
@@ -1185,17 +1015,12 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		break;
 	case E1000_DEV_ID_82546EB_FIBER:
 	case E1000_DEV_ID_82546GB_FIBER:
-	case E1000_DEV_ID_82571EB_FIBER:
 		/* Wake events only supported on port A for dual fiber
 		 * regardless of eeprom setting */
 		if (er32(STATUS) & E1000_STATUS_FUNC_1)
 			adapter->eeprom_wol = 0;
 		break;
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
-	case E1000_DEV_ID_82571EB_QUAD_COPPER:
-	case E1000_DEV_ID_82571EB_QUAD_FIBER:
-	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
-	case E1000_DEV_ID_82571PT_QUAD_COPPER:
 		/* if quad port adapter, disable WoL on all but port A */
 		if (global_quad_port_a != 0)
 			adapter->eeprom_wol = 0;
@@ -1213,39 +1038,18 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* print bus type/speed/width info */
 	DPRINTK(PROBE, INFO, "(PCI%s:%s:%s) ",
-		((hw->bus_type == e1000_bus_type_pcix) ? "-X" :
-		 (hw->bus_type == e1000_bus_type_pci_express ? " Express":"")),
-		((hw->bus_speed == e1000_bus_speed_2500) ? "2.5Gb/s" :
-		 (hw->bus_speed == e1000_bus_speed_133) ? "133MHz" :
+		((hw->bus_type == e1000_bus_type_pcix) ? "-X" : ""),
+		((hw->bus_speed == e1000_bus_speed_133) ? "133MHz" :
 		 (hw->bus_speed == e1000_bus_speed_120) ? "120MHz" :
 		 (hw->bus_speed == e1000_bus_speed_100) ? "100MHz" :
 		 (hw->bus_speed == e1000_bus_speed_66) ? "66MHz" : "33MHz"),
-		((hw->bus_width == e1000_bus_width_64) ? "64-bit" :
-		 (hw->bus_width == e1000_bus_width_pciex_4) ? "Width x4" :
-		 (hw->bus_width == e1000_bus_width_pciex_1) ? "Width x1" :
-		 "32-bit"));
+		((hw->bus_width == e1000_bus_width_64) ? "64-bit" : "32-bit"));
 
 	printk("%pM\n", netdev->dev_addr);
 
-	if (hw->bus_type == e1000_bus_type_pci_express) {
-		DPRINTK(PROBE, WARNING, "This device (id %04x:%04x) will no "
-			"longer be supported by this driver in the future.\n",
-			pdev->vendor, pdev->device);
-		DPRINTK(PROBE, WARNING, "please use the \"e1000e\" "
-			"driver instead.\n");
-	}
-
 	/* reset the hardware with the new settings */
 	e1000_reset(adapter);
 
-	/* If the controller is 82573 and f/w is AMT, do not set
-	 * DRV_LOAD until the interface is up.  For all other cases,
-	 * let the f/w know that the h/w is now under the control
-	 * of the driver. */
-	if (hw->mac_type != e1000_82573 ||
-	    !e1000_check_mng_mode(hw))
-		e1000_get_hw_control(adapter);
-
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
@@ -1260,14 +1064,11 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	return 0;
 
 err_register:
-	e1000_release_hw_control(adapter);
 err_eeprom:
-	if (!e1000_check_phy_reset_block(hw))
-		e1000_phy_hw_reset(hw);
+	e1000_phy_hw_reset(hw);
 
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
-err_flashmap:
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 err_sw_init:
@@ -1302,14 +1103,9 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 
 	e1000_release_manageability(adapter);
 
-	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
-	 * would have already happened in close and is redundant. */
-	e1000_release_hw_control(adapter);
-
 	unregister_netdev(netdev);
 
-	if (!e1000_check_phy_reset_block(hw))
-		e1000_phy_hw_reset(hw);
+	e1000_phy_hw_reset(hw);
 
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
@@ -1472,12 +1268,6 @@ static int e1000_open(struct net_device *netdev)
 		e1000_update_mng_vlan(adapter);
 	}
 
-	/* If AMT is enabled, let the firmware know that the network
-	 * interface is now open */
-	if (hw->mac_type == e1000_82573 &&
-	    e1000_check_mng_mode(hw))
-		e1000_get_hw_control(adapter);
-
 	/* before we allocate an interrupt, we must be ready to handle it.
 	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
 	 * as soon as we call pci_request_irq, so we have to setup our
@@ -1503,7 +1293,6 @@ static int e1000_open(struct net_device *netdev)
 	return E1000_SUCCESS;
 
 err_req_irq:
-	e1000_release_hw_control(adapter);
 	e1000_power_down_phy(adapter);
 	e1000_free_all_rx_resources(adapter);
 err_setup_rx:
@@ -1548,12 +1337,6 @@ static int e1000_close(struct net_device *netdev)
 		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 	}
 
-	/* If AMT is enabled, let the firmware know that the network
-	 * interface is now closed */
-	if (hw->mac_type == e1000_82573 &&
-	    e1000_check_mng_mode(hw))
-		e1000_release_hw_control(adapter);
-
 	return 0;
 }
 
@@ -1692,7 +1475,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 {
 	u64 tdba;
 	struct e1000_hw *hw = &adapter->hw;
-	u32 tdlen, tctl, tipg, tarc;
+	u32 tdlen, tctl, tipg;
 	u32 ipgr1, ipgr2;
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
@@ -1714,8 +1497,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	}
 
 	/* Set the default values for the Tx Inter Packet Gap timer */
-	if (hw->mac_type <= e1000_82547_rev_2 &&
-	    (hw->media_type == e1000_media_type_fiber ||
+	if ((hw->media_type == e1000_media_type_fiber ||
 	     hw->media_type == e1000_media_type_internal_serdes))
 		tipg = DEFAULT_82543_TIPG_IPGT_FIBER;
 	else
@@ -1728,10 +1510,6 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 		ipgr1 = DEFAULT_82542_TIPG_IPGR1;
 		ipgr2 = DEFAULT_82542_TIPG_IPGR2;
 		break;
-	case e1000_80003es2lan:
-		ipgr1 = DEFAULT_82543_TIPG_IPGR1;
-		ipgr2 = DEFAULT_80003ES2LAN_TIPG_IPGR2;
-		break;
 	default:
 		ipgr1 = DEFAULT_82543_TIPG_IPGR1;
 		ipgr2 = DEFAULT_82543_TIPG_IPGR2;
@@ -1754,21 +1532,6 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	tctl |= E1000_TCTL_PSP | E1000_TCTL_RTLC |
 		(E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT);
 
-	if (hw->mac_type == e1000_82571 || hw->mac_type == e1000_82572) {
-		tarc = er32(TARC0);
-		/* set the speed mode bit, we'll clear it if we're not at
-		 * gigabit link later */
-		tarc |= (1 << 21);
-		ew32(TARC0, tarc);
-	} else if (hw->mac_type == e1000_80003es2lan) {
-		tarc = er32(TARC0);
-		tarc |= 1;
-		ew32(TARC0, tarc);
-		tarc = er32(TARC1);
-		tarc |= 1;
-		ew32(TARC1, tarc);
-	}
-
 	e1000_config_collision_dist(hw);
 
 	/* Setup Transmit Descriptor Settings for eop descriptor */
@@ -1804,7 +1567,6 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 				    struct e1000_rx_ring *rxdr)
 {
-	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	int size, desc_len;
 
@@ -1817,10 +1579,7 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	}
 	memset(rxdr->buffer_info, 0, size);
 
-	if (hw->mac_type <= e1000_82547_rev_2)
-		desc_len = sizeof(struct e1000_rx_desc);
-	else
-		desc_len = sizeof(union e1000_rx_desc_packet_split);
+	desc_len = sizeof(struct e1000_rx_desc);
 
 	/* Round up to nearest 4K */
 
@@ -1977,7 +1736,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 {
 	u64 rdba;
 	struct e1000_hw *hw = &adapter->hw;
-	u32 rdlen, rctl, rxcsum, ctrl_ext;
+	u32 rdlen, rctl, rxcsum;
 
 	if (adapter->netdev->mtu > ETH_DATA_LEN) {
 		rdlen = adapter->rx_ring[0].count *
@@ -2004,17 +1763,6 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 			ew32(ITR, 1000000000 / (adapter->itr * 256));
 	}
 
-	if (hw->mac_type >= e1000_82571) {
-		ctrl_ext = er32(CTRL_EXT);
-		/* Reset delay timers after every interrupt */
-		ctrl_ext |= E1000_CTRL_EXT_INT_TIMER_CLR;
-		/* Auto-Mask interrupts upon ICR access */
-		ctrl_ext |= E1000_CTRL_EXT_IAME;
-		ew32(IAM, 0xffffffff);
-		ew32(CTRL_EXT, ctrl_ext);
-		E1000_WRITE_FLUSH();
-	}
-
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
 	switch (adapter->num_rx_queues) {
@@ -2329,22 +2077,6 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 
 	e1000_rar_set(hw, hw->mac_addr, 0);
 
-	/* With 82571 controllers, LAA may be overwritten (with the default)
-	 * due to controller reset from the other port. */
-	if (hw->mac_type == e1000_82571) {
-		/* activate the work around */
-		hw->laa_is_present = 1;
-
-		/* Hold a copy of the LAA in RAR[14] This is done so that
-		 * between the time RAR[0] gets clobbered  and the time it
-		 * gets fixed (in e1000_watchdog), the actual LAA is in one
-		 * of the RARs and no incoming packets directed to this port
-		 * are dropped. Eventaully the LAA will be in RAR[0] and
-		 * RAR[14] */
-		e1000_rar_set(hw, hw->mac_addr,
-					E1000_RAR_ENTRIES - 1);
-	}
-
 	if (hw->mac_type == e1000_82542_rev2_0)
 		e1000_leave_82542_rst(adapter);
 
@@ -2371,9 +2103,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 	u32 rctl;
 	u32 hash_value;
 	int i, rar_entries = E1000_RAR_ENTRIES;
-	int mta_reg_count = (hw->mac_type == e1000_ich8lan) ?
-				E1000_NUM_MTA_REGISTERS_ICH8LAN :
-				E1000_NUM_MTA_REGISTERS;
+	int mta_reg_count = E1000_NUM_MTA_REGISTERS;
 	u32 *mcarray = kcalloc(mta_reg_count, sizeof(u32), GFP_ATOMIC);
 
 	if (!mcarray) {
@@ -2381,13 +2111,6 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 		return;
 	}
 
-	if (hw->mac_type == e1000_ich8lan)
-		rar_entries = E1000_RAR_ENTRIES_ICH8LAN;
-
-	/* reserve RAR[14] for LAA over-write work-around */
-	if (hw->mac_type == e1000_82571)
-		rar_entries--;
-
 	/* Check for Promiscuous and All Multicast modes */
 
 	rctl = er32(RCTL);
@@ -2396,15 +2119,13 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
 		rctl &= ~E1000_RCTL_VFE;
 	} else {
-		if (netdev->flags & IFF_ALLMULTI) {
+		if (netdev->flags & IFF_ALLMULTI)
 			rctl |= E1000_RCTL_MPE;
-		} else {
+		else
 			rctl &= ~E1000_RCTL_MPE;
-		}
-		if (adapter->hw.mac_type != e1000_ich8lan)
-			/* Enable VLAN filter if there is a VLAN */
-			if (adapter->vlgrp)
-				rctl |= E1000_RCTL_VFE;
+		/* Enable VLAN filter if there is a VLAN */
+		if (adapter->vlgrp)
+			rctl |= E1000_RCTL_VFE;
 	}
 
 	if (netdev->uc.count > rar_entries - 1) {
@@ -2427,7 +2148,6 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 	 *
 	 * RAR 0 is used for the station MAC adddress
 	 * if there are not 14 addresses, go ahead and clear the filters
-	 * -- with 82571 controllers only 0-13 entries are filled here
 	 */
 	i = 1;
 	if (use_uc)
@@ -2538,22 +2258,8 @@ static void e1000_watchdog(unsigned long data)
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	u32 link, tctl;
-	s32 ret_val;
-
-	ret_val = e1000_check_for_link(hw);
-	if ((ret_val == E1000_ERR_PHY) &&
-	    (hw->phy_type == e1000_phy_igp_3) &&
-	    (er32(CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
-		/* See e1000_kumeran_lock_loss_workaround() */
-		DPRINTK(LINK, INFO,
-			"Gigabit has been disabled, downgrading speed\n");
-	}
 
-	if (hw->mac_type == e1000_82573) {
-		e1000_enable_tx_pkt_filtering(hw);
-		if (adapter->mng_vlan_id != hw->mng_cookie.vlan_id)
-			e1000_update_mng_vlan(adapter);
-	}
+	e1000_check_for_link(hw);
 
 	if ((hw->media_type == e1000_media_type_internal_serdes) &&
 	   !(er32(TXCW) & E1000_TXCW_ANE))
@@ -2598,52 +2304,15 @@ static void e1000_watchdog(unsigned long data)
 				break;
 			}
 
-			if ((hw->mac_type == e1000_82571 ||
-			     hw->mac_type == e1000_82572) &&
-			    !txb2b) {
-				u32 tarc0;
-				tarc0 = er32(TARC0);
-				tarc0 &= ~(1 << 21);
-				ew32(TARC0, tarc0);
-			}
-
-			/* disable TSO for pcie and 10/100 speeds, to avoid
-			 * some hardware issues */
-			if (!adapter->tso_force &&
-			    hw->bus_type == e1000_bus_type_pci_express){
-				switch (adapter->link_speed) {
-				case SPEED_10:
-				case SPEED_100:
-					DPRINTK(PROBE,INFO,
-				        "10/100 speed: disabling TSO\n");
-					netdev->features &= ~NETIF_F_TSO;
-					netdev->features &= ~NETIF_F_TSO6;
-					break;
-				case SPEED_1000:
-					netdev->features |= NETIF_F_TSO;
-					netdev->features |= NETIF_F_TSO6;
-					break;
-				default:
-					/* oops */
-					break;
-				}
-			}
-
-			/* enable transmits in the hardware, need to do this
-			 * after setting TARC0 */
+			/* enable transmits in the hardware */
 			tctl = er32(TCTL);
 			tctl |= E1000_TCTL_EN;
 			ew32(TCTL, tctl);
 
 			netif_carrier_on(netdev);
-			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
+			mod_timer(&adapter->phy_info_timer,
+			          round_jiffies(jiffies + 2 * HZ));
 			adapter->smartspeed = 0;
-		} else {
-			/* make sure the receive unit is started */
-			if (hw->rx_needs_kicking) {
-				u32 rctl = er32(RCTL);
-				ew32(RCTL, rctl | E1000_RCTL_EN);
-			}
 		}
 	} else {
 		if (netif_carrier_ok(netdev)) {
@@ -2652,16 +2321,8 @@ static void e1000_watchdog(unsigned long data)
 			printk(KERN_INFO "e1000: %s NIC Link is Down\n",
 			       netdev->name);
 			netif_carrier_off(netdev);
-			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
-
-			/* 80003ES2LAN workaround--
-			 * For packet buffer work-around on link down event;
-			 * disable receives in the ISR and
-			 * reset device here in the watchdog
-			 */
-			if (hw->mac_type == e1000_80003es2lan)
-				/* reset device */
-				schedule_work(&adapter->reset_task);
+			mod_timer(&adapter->phy_info_timer,
+			          round_jiffies(jiffies + 2 * HZ));
 		}
 
 		e1000_smartspeed(adapter);
@@ -2700,11 +2361,6 @@ static void e1000_watchdog(unsigned long data)
 	/* Force detection of hung controller every watchdog period */
 	adapter->detect_tx_hung = true;
 
-	/* With 82571 controllers, LAA may be overwritten due to controller
-	 * reset from the other port. Set the appropriate LAA in RAR[0] */
-	if (hw->mac_type == e1000_82571 && hw->laa_is_present)
-		e1000_rar_set(hw, hw->mac_addr, 0);
-
 	/* Reset the timer */
 	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
 }
@@ -3186,41 +2842,6 @@ no_fifo_stall_required:
 	return 0;
 }
 
-#define MINIMUM_DHCP_PACKET_SIZE 282
-static int e1000_transfer_dhcp_info(struct e1000_adapter *adapter,
-				    struct sk_buff *skb)
-{
-	struct e1000_hw *hw =  &adapter->hw;
-	u16 length, offset;
-	if (vlan_tx_tag_present(skb)) {
-		if (!((vlan_tx_tag_get(skb) == hw->mng_cookie.vlan_id) &&
-			( hw->mng_cookie.status &
-			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT)) )
-			return 0;
-	}
-	if (skb->len > MINIMUM_DHCP_PACKET_SIZE) {
-		struct ethhdr *eth = (struct ethhdr *)skb->data;
-		if ((htons(ETH_P_IP) == eth->h_proto)) {
-			const struct iphdr *ip =
-				(struct iphdr *)((u8 *)skb->data+14);
-			if (IPPROTO_UDP == ip->protocol) {
-				struct udphdr *udp =
-					(struct udphdr *)((u8 *)ip +
-						(ip->ihl << 2));
-				if (ntohs(udp->dest) == 67) {
-					offset = (u8 *)udp + 8 - skb->data;
-					length = skb->len - offset;
-
-					return e1000_mng_write_dhcp_info(hw,
-							(u8 *)udp + 8,
-							length);
-				}
-			}
-		}
-	}
-	return 0;
-}
-
 static int __e1000_maybe_stop_tx(struct net_device *netdev, int size)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -3279,11 +2900,6 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	/* 82571 and newer doesn't need the workaround that limited descriptor
-	 * length to 4kB */
-	if (hw->mac_type >= e1000_82571)
-		max_per_txd = 8192;
-
 	mss = skb_shinfo(skb)->gso_size;
 	/* The controller does a simple calculation to
 	 * make sure there is enough room in the FIFO before
@@ -3296,9 +2912,6 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		max_per_txd = min(mss << 2, max_per_txd);
 		max_txd_pwr = fls(max_per_txd) - 1;
 
-		/* TSO Workaround for 82571/2/3 Controllers -- if skb->data
-		* points to just header, pull a few bytes of payload from
-		* frags into skb->data */
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		if (skb->data_len && hdr_len == len) {
 			switch (hw->mac_type) {
@@ -3313,10 +2926,6 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				if ((unsigned long)(skb_tail_pointer(skb) - 1) & 4)
 					break;
 				/* fall through */
-			case e1000_82571:
-			case e1000_82572:
-			case e1000_82573:
-			case e1000_ich8lan:
 				pull_size = min((unsigned int)4, skb->data_len);
 				if (!__pskb_pull_tail(skb, pull_size)) {
 					DPRINTK(DRV, ERR,
@@ -3361,11 +2970,6 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	if (adapter->pcix_82544)
 		count += nr_frags;
 
-
-	if (hw->tx_pkt_filtering &&
-	    (hw->mac_type == e1000_82573))
-		e1000_transfer_dhcp_info(adapter, skb);
-
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
 	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2)))
@@ -3398,9 +3002,6 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	} else if (likely(e1000_tx_csum(adapter, tx_ring, skb)))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
 
-	/* Old method was to assume IPv4 packet by default if TSO was enabled.
-	 * 82571 hardware supports TSO capabilities for IPv6 as well...
-	 * no longer assume, we must. */
 	if (likely(skb->protocol == htons(ETH_P_IP)))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
@@ -3472,7 +3073,6 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
-	u16 eeprom_data = 0;
 
 	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
@@ -3483,39 +3083,11 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	/* Adapter-specific max frame size limits. */
 	switch (hw->mac_type) {
 	case e1000_undefined ... e1000_82542_rev2_1:
-	case e1000_ich8lan:
 		if (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)) {
 			DPRINTK(PROBE, ERR, "Jumbo Frames not supported.\n");
 			return -EINVAL;
 		}
 		break;
-	case e1000_82573:
-		/* Jumbo Frames not supported if:
-		 * - this is not an 82573L device
-		 * - ASPM is enabled in any way (0x1A bits 3:2) */
-		e1000_read_eeprom(hw, EEPROM_INIT_3GIO_3, 1,
-		                  &eeprom_data);
-		if ((hw->device_id != E1000_DEV_ID_82573L) ||
-		    (eeprom_data & EEPROM_WORD1A_ASPM_MASK)) {
-			if (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)) {
-				DPRINTK(PROBE, ERR,
-			            	"Jumbo Frames not supported.\n");
-				return -EINVAL;
-			}
-			break;
-		}
-		/* ERT will be enabled later to enable wire speed receives */
-
-		/* fall through to get support */
-	case e1000_82571:
-	case e1000_82572:
-	case e1000_80003es2lan:
-#define MAX_STD_JUMBO_FRAME_SIZE 9234
-		if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
-			DPRINTK(PROBE, ERR, "MTU > 9216 not supported.\n");
-			return -EINVAL;
-		}
-		break;
 	default:
 		/* Capable of supporting up to MAX_JUMBO_FRAME_SIZE limit. */
 		break;
@@ -3596,14 +3168,12 @@ void e1000_update_stats(struct e1000_adapter *adapter)
 	adapter->stats.mprc += er32(MPRC);
 	adapter->stats.roc += er32(ROC);
 
-	if (hw->mac_type != e1000_ich8lan) {
-		adapter->stats.prc64 += er32(PRC64);
-		adapter->stats.prc127 += er32(PRC127);
-		adapter->stats.prc255 += er32(PRC255);
-		adapter->stats.prc511 += er32(PRC511);
-		adapter->stats.prc1023 += er32(PRC1023);
-		adapter->stats.prc1522 += er32(PRC1522);
-	}
+	adapter->stats.prc64 += er32(PRC64);
+	adapter->stats.prc127 += er32(PRC127);
+	adapter->stats.prc255 += er32(PRC255);
+	adapter->stats.prc511 += er32(PRC511);
+	adapter->stats.prc1023 += er32(PRC1023);
+	adapter->stats.prc1522 += er32(PRC1522);
 
 	adapter->stats.symerrs += er32(SYMERRS);
 	adapter->stats.mpc += er32(MPC);
@@ -3632,14 +3202,12 @@ void e1000_update_stats(struct e1000_adapter *adapter)
 	adapter->stats.toth += er32(TOTH);
 	adapter->stats.tpr += er32(TPR);
 
-	if (hw->mac_type != e1000_ich8lan) {
-		adapter->stats.ptc64 += er32(PTC64);
-		adapter->stats.ptc127 += er32(PTC127);
-		adapter->stats.ptc255 += er32(PTC255);
-		adapter->stats.ptc511 += er32(PTC511);
-		adapter->stats.ptc1023 += er32(PTC1023);
-		adapter->stats.ptc1522 += er32(PTC1522);
-	}
+	adapter->stats.ptc64 += er32(PTC64);
+	adapter->stats.ptc127 += er32(PTC127);
+	adapter->stats.ptc255 += er32(PTC255);
+	adapter->stats.ptc511 += er32(PTC511);
+	adapter->stats.ptc1023 += er32(PTC1023);
+	adapter->stats.ptc1522 += er32(PTC1522);
 
 	adapter->stats.mptc += er32(MPTC);
 	adapter->stats.bptc += er32(BPTC);
@@ -3659,20 +3227,6 @@ void e1000_update_stats(struct e1000_adapter *adapter)
 		adapter->stats.tsctc += er32(TSCTC);
 		adapter->stats.tsctfc += er32(TSCTFC);
 	}
-	if (hw->mac_type > e1000_82547_rev_2) {
-		adapter->stats.iac += er32(IAC);
-		adapter->stats.icrxoc += er32(ICRXOC);
-
-		if (hw->mac_type != e1000_ich8lan) {
-			adapter->stats.icrxptc += er32(ICRXPTC);
-			adapter->stats.icrxatc += er32(ICRXATC);
-			adapter->stats.ictxptc += er32(ICTXPTC);
-			adapter->stats.ictxatc += er32(ICTXATC);
-			adapter->stats.ictxqec += er32(ICTXQEC);
-			adapter->stats.ictxqmtc += er32(ICTXQMTC);
-			adapter->stats.icrxdmtc += er32(ICRXDMTC);
-		}
-	}
 
 	/* Fill out the OS statistics structure */
 	adapter->net_stats.multicast = adapter->stats.mprc;
@@ -3731,49 +3285,6 @@ void e1000_update_stats(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000_intr_msi - Interrupt Handler
- * @irq: interrupt number
- * @data: pointer to a network interface device structure
- **/
-
-static irqreturn_t e1000_intr_msi(int irq, void *data)
-{
-	struct net_device *netdev = data;
-	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
-	u32 icr = er32(ICR);
-
-	/* in NAPI mode read ICR disables interrupts using IAM */
-
-	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
-		hw->get_link_status = 1;
-		/* 80003ES2LAN workaround-- For packet buffer work-around on
-		 * link down event; disable receives here in the ISR and reset
-		 * adapter in watchdog */
-		if (netif_carrier_ok(netdev) &&
-		    (hw->mac_type == e1000_80003es2lan)) {
-			/* disable receives */
-			u32 rctl = er32(RCTL);
-			ew32(RCTL, rctl & ~E1000_RCTL_EN);
-		}
-		/* guard against interrupt when we're going down */
-		if (!test_bit(__E1000_DOWN, &adapter->flags))
-			mod_timer(&adapter->watchdog_timer, jiffies + 1);
-	}
-
-	if (likely(napi_schedule_prep(&adapter->napi))) {
-		adapter->total_tx_bytes = 0;
-		adapter->total_tx_packets = 0;
-		adapter->total_rx_bytes = 0;
-		adapter->total_rx_packets = 0;
-		__napi_schedule(&adapter->napi);
-	} else
-		e1000_irq_enable(adapter);
-
-	return IRQ_HANDLED;
-}
-
-/**
  * e1000_intr - Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
@@ -3784,43 +3295,22 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 rctl, icr = er32(ICR);
+	u32 icr = er32(ICR);
 
 	if (unlikely((!icr) || test_bit(__E1000_DOWN, &adapter->flags)))
 		return IRQ_NONE;  /* Not our interrupt */
 
-	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
-	 * not set, then the adapter didn't send an interrupt */
-	if (unlikely(hw->mac_type >= e1000_82571 &&
-	             !(icr & E1000_ICR_INT_ASSERTED)))
-		return IRQ_NONE;
-
-	/* Interrupt Auto-Mask...upon reading ICR, interrupts are masked.  No
-	 * need for the IMC write */
-
 	if (unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
 		hw->get_link_status = 1;
-		/* 80003ES2LAN workaround--
-		 * For packet buffer work-around on link down event;
-		 * disable receives here in the ISR and
-		 * reset adapter in watchdog
-		 */
-		if (netif_carrier_ok(netdev) &&
-		    (hw->mac_type == e1000_80003es2lan)) {
-			/* disable receives */
-			rctl = er32(RCTL);
-			ew32(RCTL, rctl & ~E1000_RCTL_EN);
-		}
 		/* guard against interrupt when we're going down */
 		if (!test_bit(__E1000_DOWN, &adapter->flags))
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (unlikely(hw->mac_type < e1000_82571)) {
-		/* disable interrupts, without the synchronize_irq bit */
-		ew32(IMC, ~0);
-		E1000_WRITE_FLUSH();
-	}
+	/* disable interrupts, without the synchronize_irq bit */
+	ew32(IMC, ~0);
+	E1000_WRITE_FLUSH();
+
 	if (likely(napi_schedule_prep(&adapter->napi))) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
@@ -3999,25 +3489,13 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 		return;
 	}
 	/* TCP/UDP Checksum has not been calculated */
-	if (hw->mac_type <= e1000_82547_rev_2) {
-		if (!(status & E1000_RXD_STAT_TCPCS))
-			return;
-	} else {
-		if (!(status & (E1000_RXD_STAT_TCPCS | E1000_RXD_STAT_UDPCS)))
-			return;
-	}
+	if (!(status & E1000_RXD_STAT_TCPCS))
+		return;
+
 	/* It must be a TCP or UDP packet with a valid checksum */
 	if (likely(status & E1000_RXD_STAT_TCPCS)) {
 		/* TCP checksum is good */
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else if (hw->mac_type > e1000_82547_rev_2) {
-		/* IP fragment with UDP payload */
-		/* Hardware complements the payload checksum, so we undo it
-		 * and then put the value in host order for further stack use.
-		 */
-		__sum16 sum = (__force __sum16)htons(csum);
-		skb->csum = csum_unfold(~sum);
-		skb->ip_summed = CHECKSUM_COMPLETE;
 	}
 	adapter->hw_csum_good++;
 }
@@ -4850,33 +4328,28 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 		ctrl |= E1000_CTRL_VME;
 		ew32(CTRL, ctrl);
 
-		if (adapter->hw.mac_type != e1000_ich8lan) {
-			/* enable VLAN receive filtering */
-			rctl = er32(RCTL);
-			rctl &= ~E1000_RCTL_CFIEN;
-	                if (!(netdev->flags & IFF_PROMISC))
-				rctl |= E1000_RCTL_VFE;
-			ew32(RCTL, rctl);
-			e1000_update_mng_vlan(adapter);
-		}
+		/* enable VLAN receive filtering */
+		rctl = er32(RCTL);
+		rctl &= ~E1000_RCTL_CFIEN;
+		if (!(netdev->flags & IFF_PROMISC))
+			rctl |= E1000_RCTL_VFE;
+		ew32(RCTL, rctl);
+		e1000_update_mng_vlan(adapter);
 	} else {
 		/* disable VLAN tag insert/strip */
 		ctrl = er32(CTRL);
 		ctrl &= ~E1000_CTRL_VME;
 		ew32(CTRL, ctrl);
 
-		if (adapter->hw.mac_type != e1000_ich8lan) {
-			/* disable VLAN receive filtering */
-			rctl = er32(RCTL);
-			rctl &= ~E1000_RCTL_VFE;
-			ew32(RCTL, rctl);
+		/* disable VLAN receive filtering */
+		rctl = er32(RCTL);
+		rctl &= ~E1000_RCTL_VFE;
+		ew32(RCTL, rctl);
 
-			if (adapter->mng_vlan_id !=
-			    (u16)E1000_MNG_VLAN_NONE) {
-				e1000_vlan_rx_kill_vid(netdev,
-				                       adapter->mng_vlan_id);
-				adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
-			}
+		if (adapter->mng_vlan_id != (u16)E1000_MNG_VLAN_NONE) {
+			e1000_vlan_rx_kill_vid(netdev,
+			                       adapter->mng_vlan_id);
+			adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 		}
 	}
 
@@ -4913,14 +4386,6 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_enable(adapter);
 
-	if ((hw->mng_cookie.status &
-	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
-	    (vid == adapter->mng_vlan_id)) {
-		/* release control to f/w */
-		e1000_release_hw_control(adapter);
-		return;
-	}
-
 	/* remove VID from filter table */
 	index = (vid >> 5) & 0x7F;
 	vfta = E1000_READ_REG_ARRAY(hw, VFTA, index);
@@ -5031,16 +4496,13 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		}
 
 		if (hw->media_type == e1000_media_type_fiber ||
-		   hw->media_type == e1000_media_type_internal_serdes) {
+		    hw->media_type == e1000_media_type_internal_serdes) {
 			/* keep the laser running in D3 */
 			ctrl_ext = er32(CTRL_EXT);
 			ctrl_ext |= E1000_CTRL_EXT_SDP7_DATA;
 			ew32(CTRL_EXT, ctrl_ext);
 		}
 
-		/* Allow time for pending master requests to run */
-		e1000_disable_pciex_master(hw);
-
 		ew32(WUC, E1000_WUC_PME_EN);
 		ew32(WUFC, wufc);
 	} else {
@@ -5056,16 +4518,9 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	if (adapter->en_mng_pt)
 		*enable_wake = true;
 
-	if (hw->phy_type == e1000_phy_igp_3)
-		e1000_phy_powerdown_workaround(hw);
-
 	if (netif_running(netdev))
 		e1000_free_irq(adapter);
 
-	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
-	 * would have already happened in close and is redundant. */
-	e1000_release_hw_control(adapter);
-
 	pci_disable_device(pdev);
 
 	return 0;
@@ -5131,14 +4586,6 @@ static int e1000_resume(struct pci_dev *pdev)
 
 	netif_device_attach(netdev);
 
-	/* If the controller is 82573 and f/w is AMT, do not set
-	 * DRV_LOAD until the interface is up.  For all other cases,
-	 * let the f/w know that the h/w is now under the control
-	 * of the driver. */
-	if (hw->mac_type != e1000_82573 ||
-	    !e1000_check_mng_mode(hw))
-		e1000_get_hw_control(adapter);
-
 	return 0;
 }
 #endif
@@ -5243,7 +4690,6 @@ static void e1000_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
 
 	e1000_init_manageability(adapter);
 
@@ -5255,15 +4701,6 @@ static void e1000_io_resume(struct pci_dev *pdev)
 	}
 
 	netif_device_attach(netdev);
-
-	/* If the controller is 82573 and f/w is AMT, do not set
-	 * DRV_LOAD until the interface is up.  For all other cases,
-	 * let the f/w know that the h/w is now under the control
-	 * of the driver. */
-	if (hw->mac_type != e1000_82573 ||
-	    !e1000_check_mng_mode(hw))
-		e1000_get_hw_control(adapter);
-
 }
 
 /* e1000_main.c */
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index 213437d..38d2741 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -518,22 +518,6 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 			adapter->smart_power_down = opt.def;
 		}
 	}
-	{ /* Kumeran Lock Loss Workaround */
-		opt = (struct e1000_option) {
-			.type = enable_option,
-			.name = "Kumeran Lock Loss Workaround",
-			.err  = "defaulting to Enabled",
-			.def  = OPTION_ENABLED
-		};
-
-		if (num_KumeranLockLoss > bd) {
-			unsigned int kmrn_lock_loss = KumeranLockLoss[bd];
-			e1000_validate_option(&kmrn_lock_loss, &opt, adapter);
-			adapter->hw.kmrn_lock_loss_workaround_disabled = !kmrn_lock_loss;
-		} else {
-			adapter->hw.kmrn_lock_loss_workaround_disabled = !opt.def;
-		}
-	}
 
 	switch (adapter->hw.media_type) {
 	case e1000_media_type_fiber:
@@ -626,12 +610,6 @@ static void __devinit e1000_check_copper_options(struct e1000_adapter *adapter)
 					 .p = dplx_list }}
 		};
 
-		if (e1000_check_phy_reset_block(&adapter->hw)) {
-			DPRINTK(PROBE, INFO,
-				"Link active due to SoL/IDER Session. "
-			        "Speed/Duplex/AutoNeg parameter ignored.\n");
-			return;
-		}
 		if (num_Duplex > bd) {
 			dplx = Duplex[bd];
 			e1000_validate_option(&dplx, &opt, adapter);

