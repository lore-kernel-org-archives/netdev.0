From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/4] ixgbe: Fix copper PHY initialization code
Date: Wed, 31 Oct 2007 15:22:10 -0700
Message-ID: <20071031222210.17411.90118.stgit@localhost.localdomain>
References: <20071031222152.17411.20977.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29287 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754288AbXJaWZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 18:25:11 -0400
In-Reply-To: <20071031222152.17411.20977.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While cleaning up the internal API focussing on Fiber and CX4 code
we found that I had broken the copper PHY initialization code. This
patch restores the PHY-specific code. This is mostly uninteresting
since no copper PHY boards are yet available. The changes have been
tested against Fiber only as I do not even have copper PHY versions
of 82598 macs.

This change actually cleans up the API code a bit more and we
lose some initialization code. A few PHY link detection helper
lines of code have been snuck into this patch, as well as a
read flush where it was suspected that this might cause issues.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe.h        |    8 --
 drivers/net/ixgbe/ixgbe_82598.c  |  156 +++++++++++---------------------------
 drivers/net/ixgbe/ixgbe_common.c |   10 ++
 drivers/net/ixgbe/ixgbe_main.c   |   19 ++---
 drivers/net/ixgbe/ixgbe_phy.h    |    1 
 drivers/net/ixgbe/ixgbe_type.h   |   13 ++-
 6 files changed, 71 insertions(+), 136 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index bc51432..a021a6e 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -234,14 +234,10 @@ enum ixbge_state_t {
 };
 
 enum ixgbe_boards {
-	board_82598AF,
-	board_82598EB,
-	board_82598AT,
+	board_82598,
 };
 
-extern struct ixgbe_info ixgbe_82598AF_info;
-extern struct ixgbe_info ixgbe_82598EB_info;
-extern struct ixgbe_info ixgbe_82598AT_info;
+extern struct ixgbe_info ixgbe_82598_info;
 
 extern char ixgbe_driver_name[];
 extern const char ixgbe_driver_version[];
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 4d64673..6321b05 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -50,8 +50,6 @@ static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
 					    bool autoneg,
 					    bool autoneg_wait_to_complete);
 static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw);
-static s32 ixgbe_check_copper_link_82598(struct ixgbe_hw *hw, u32 *speed,
-					 bool *link_up);
 static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
 					       bool autoneg,
 					       bool autoneg_wait_to_complete);
@@ -64,6 +62,28 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 	hw->mac.num_tx_queues = IXGBE_82598_MAX_RX_QUEUES;
 	hw->mac.num_rx_addrs = IXGBE_82598_RAR_ENTRIES;
 
+	/* PHY ops are filled in by default properly for Fiber only */
+	if (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_copper) {
+		hw->mac.ops.setup_link = &ixgbe_setup_copper_link_82598;
+		hw->mac.ops.setup_link_speed = &ixgbe_setup_copper_link_speed_82598;
+		hw->mac.ops.get_link_settings =
+				&ixgbe_get_copper_link_settings_82598;
+
+		/* Call PHY identify routine to get the phy type */
+		ixgbe_identify_phy(hw);
+
+		switch (hw->phy.type) {
+		case ixgbe_phy_tn:
+			hw->phy.ops.setup_link = &ixgbe_setup_tnx_phy_link;
+			hw->phy.ops.check_link = &ixgbe_check_tnx_phy_link;
+			hw->phy.ops.setup_link_speed =
+					&ixgbe_setup_tnx_phy_link_speed;
+			break;
+		default:
+			break;
+		}
+	}
+
 	return 0;
 }
 
@@ -206,6 +226,7 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
 		autoc_reg |= hw->mac.link_mode_select;
 
 		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
+		IXGBE_WRITE_FLUSH(hw);
 		msleep(50);
 	}
 
@@ -314,7 +335,7 @@ static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
 		 * ixgbe_hw This will write the AUTOC register based on the new
 		 * stored values
 		 */
-		hw->phy.ops.setup(hw);
+		hw->mac.ops.setup_link(hw);
 	}
 
 	return status;
@@ -332,72 +353,18 @@ static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw,
  **/
 static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw)
 {
-	s32 status;
-	u32 speed = 0;
-	bool link_up = false;
-
-	/* Set up MAC */
-	hw->phy.ops.setup(hw);
+	s32 status = 0;
 
 	/* Restart autonegotiation on PHY */
-	status = hw->phy.ops.setup(hw);
-
-	/* Synchronize MAC to PHY speed */
-	if (status == 0)
-		status = hw->phy.ops.check(hw, &speed, &link_up);
-
-	return status;
-}
+	if (hw->phy.ops.setup_link)
+		status = hw->phy.ops.setup_link(hw);
 
-/**
- *  ixgbe_check_copper_link_82598 - Syncs MAC & PHY link settings
- *  @hw: pointer to hardware structure
- *  @speed: pointer to link speed
- *  @link_up: true if link is up, false otherwise
- *
- *  Reads the mac link, phy link, and synchronizes the MAC to PHY.
- **/
-static s32 ixgbe_check_copper_link_82598(struct ixgbe_hw *hw, u32 *speed,
-					 bool *link_up)
-{
-	s32 status;
-	u32 phy_speed = 0;
-	bool phy_link = false;
+	/* Set MAC to KX/KX4 autoneg, which defaultis to Parallel detection */
+	hw->mac.link_attach_type = (IXGBE_AUTOC_10G_KX4 | IXGBE_AUTOC_1G_KX);
+	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_KX4_AN;
 
-	/* This is the speed and link the MAC is set at */
-	hw->phy.ops.check(hw, speed, link_up);
-
-	/*
-	 * Check current speed and link status of the PHY register.
-	 * This is a vendor specific register and may have to
-	 * be changed for other copper PHYs.
-	 */
-	status = hw->phy.ops.check(hw, &phy_speed, &phy_link);
-
-	if ((status == 0) && (phy_link)) {
-		/*
-		 * Check current link status of the MACs link's register
-		 * matches that of the speed in the PHY register
-		 */
-		if (*speed != phy_speed) {
-			/*
-			 * The copper PHY requires 82598 attach type to be XAUI
-			 * for 10G and BX for 1G
-			 */
-			hw->mac.link_attach_type =
-				(IXGBE_AUTOC_10G_XAUI | IXGBE_AUTOC_1G_BX);
-
-			/* Synchronize the MAC speed to the PHY speed */
-			status = hw->phy.ops.setup_speed(hw, phy_speed, false,
-							  false);
-			if (status == 0)
-				hw->phy.ops.check(hw, speed, link_up);
-			else
-				status = IXGBE_ERR_LINK_SETUP;
-		}
-	} else {
-		*link_up = phy_link;
-	}
+	/* Set up MAC */
+	hw->mac.ops.setup_link(hw);
 
 	return status;
 }
@@ -415,16 +382,19 @@ static s32 ixgbe_setup_copper_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
 					       bool autoneg,
 					       bool autoneg_wait_to_complete)
 {
-	s32 status;
-	bool link_up = 0;
+	s32 status = 0;
 
 	/* Setup the PHY according to input speed */
-	status = hw->phy.ops.setup_speed(hw, speed, autoneg,
-					  autoneg_wait_to_complete);
+	if (hw->phy.ops.setup_link_speed)
+		status = hw->phy.ops.setup_link_speed(hw, speed, autoneg,
+						autoneg_wait_to_complete);
+
+	/* Set MAC to KX/KX4 autoneg, which defaults to Parallel detection */
+	hw->mac.link_attach_type = (IXGBE_AUTOC_10G_KX4 | IXGBE_AUTOC_1G_KX);
+	hw->mac.link_mode_select = IXGBE_AUTOC_LMS_KX4_AN;
 
-	/* Synchronize MAC to PHY speed */
-	if (status == 0)
-		status = hw->phy.ops.check(hw, &speed, &link_up);
+	/* Set up MAC */
+	hw->mac.ops.setup_link(hw);
 
 	return status;
 }
@@ -542,47 +512,15 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 static struct ixgbe_mac_operations mac_ops_82598 = {
 	.reset			= &ixgbe_reset_hw_82598,
 	.get_media_type		= &ixgbe_get_media_type_82598,
+	.setup_link		= &ixgbe_setup_mac_link_82598,
+	.check_link		= &ixgbe_check_mac_link_82598,
+	.setup_link_speed	= &ixgbe_setup_mac_link_speed_82598,
+	.get_link_settings	= &ixgbe_get_link_settings_82598,
 };
 
-static struct ixgbe_phy_operations phy_ops_82598EB = {
-	.setup			= &ixgbe_setup_copper_link_82598,
-	.check			= &ixgbe_check_copper_link_82598,
-	.setup_speed		= &ixgbe_setup_copper_link_speed_82598,
-	.get_settings		= &ixgbe_get_copper_link_settings_82598,
-};
-
-struct ixgbe_info ixgbe_82598EB_info = {
-	.mac			= ixgbe_mac_82598EB,
-	.get_invariants		= &ixgbe_get_invariants_82598,
-	.mac_ops		= &mac_ops_82598,
-	.phy_ops		= &phy_ops_82598EB,
-};
-
-static struct ixgbe_phy_operations phy_ops_82598AT = {
-	.setup			= &ixgbe_setup_tnx_phy_link,
-	.check			= &ixgbe_check_tnx_phy_link,
-	.setup_speed		= &ixgbe_setup_tnx_phy_link_speed,
-	.get_settings		= &ixgbe_get_copper_link_settings_82598,
-};
-
-struct ixgbe_info ixgbe_82598AT_info = {
-	.mac			= ixgbe_mac_82598EB,
-	.get_invariants		= &ixgbe_get_invariants_82598,
-	.mac_ops		= &mac_ops_82598,
-	.phy_ops		= &phy_ops_82598AT,
-};
-
-static struct ixgbe_phy_operations phy_ops_82598AF = {
-	.setup			= &ixgbe_setup_mac_link_82598,
-	.check			= &ixgbe_check_mac_link_82598,
-	.setup_speed		= &ixgbe_setup_mac_link_speed_82598,
-	.get_settings		= &ixgbe_get_link_settings_82598,
-};
-
-struct ixgbe_info ixgbe_82598AF_info = {
+struct ixgbe_info ixgbe_82598_info = {
 	.mac			= ixgbe_mac_82598EB,
 	.get_invariants		= &ixgbe_get_invariants_82598,
 	.mac_ops		= &mac_ops_82598,
-	.phy_ops		= &phy_ops_82598AF,
 };
 
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 512e3b2..9c10c05 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -74,7 +74,7 @@ s32 ixgbe_start_hw(struct ixgbe_hw *hw)
 	ixgbe_clear_vfta(hw);
 
 	/* Set up link */
-	hw->phy.ops.setup(hw);
+	hw->mac.ops.setup_link(hw);
 
 	/* Clear statistics registers */
 	ixgbe_clear_hw_cntrs(hw);
@@ -83,6 +83,7 @@ s32 ixgbe_start_hw(struct ixgbe_hw *hw)
 	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
 	ctrl_ext |= IXGBE_CTRL_EXT_NS_DIS;
 	IXGBE_WRITE_REG(hw, IXGBE_CTRL_EXT, ctrl_ext);
+	IXGBE_WRITE_FLUSH(hw);
 
 	/* Clear adapter stopped flag */
 	hw->adapter_stopped = false;
@@ -297,6 +298,7 @@ s32 ixgbe_led_on(struct ixgbe_hw *hw, u32 index)
 	led_reg &= ~IXGBE_LED_MODE_MASK(index);
 	led_reg |= IXGBE_LED_ON << IXGBE_LED_MODE_SHIFT(index);
 	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+	IXGBE_WRITE_FLUSH(hw);
 
 	return 0;
 }
@@ -314,6 +316,7 @@ s32 ixgbe_led_off(struct ixgbe_hw *hw, u32 index)
 	led_reg &= ~IXGBE_LED_MODE_MASK(index);
 	led_reg |= IXGBE_LED_OFF << IXGBE_LED_MODE_SHIFT(index);
 	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+	IXGBE_WRITE_FLUSH(hw);
 
 	return 0;
 }
@@ -496,6 +499,7 @@ static void ixgbe_release_eeprom_semaphore(struct ixgbe_hw *hw)
 	/* Release both semaphores by writing 0 to the bits SWESMBI and SMBI */
 	swsm &= ~(IXGBE_SWSM_SWESMBI | IXGBE_SWSM_SMBI);
 	IXGBE_WRITE_REG(hw, IXGBE_SWSM, swsm);
+	IXGBE_WRITE_FLUSH(hw);
 }
 
 /**
@@ -1132,7 +1136,7 @@ void ixgbe_release_swfw_sync(struct ixgbe_hw *hw, u16 mask)
 }
 
 /**
- *  ixgbe_read_analog_reg8- Reads 8 bit 82598 Atlas analog register
+ *  ixgbe_read_analog_reg8 - Reads 8 bit Atlas analog register
  *  @hw: pointer to hardware structure
  *  @reg: analog register to read
  *  @val: read value
@@ -1154,7 +1158,7 @@ s32 ixgbe_read_analog_reg8(struct ixgbe_hw *hw, u32 reg, u8 *val)
 }
 
 /**
- *  ixgbe_write_analog_reg8- Writes 8 bit Atlas analog register
+ *  ixgbe_write_analog_reg8 - Writes 8 bit Atlas analog register
  *  @hw: pointer to hardware structure
  *  @reg: atlas register to write
  *  @val: value to write
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 00bc525..0e14761 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -54,9 +54,7 @@ static const char ixgbe_copyright[] =
 	 "Copyright (c) 1999-2007 Intel Corporation.";
 
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
-	[board_82598AF]			= &ixgbe_82598AF_info,
-	[board_82598EB]			= &ixgbe_82598EB_info,
-	[board_82598AT]			= &ixgbe_82598AT_info,
+	[board_82598]			= &ixgbe_82598_info,
 };
 
 /* ixgbe_pci_tbl - PCI Device ID Table
@@ -69,13 +67,13 @@ static const struct ixgbe_info *ixgbe_info_tbl[] = {
  */
 static struct pci_device_id ixgbe_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_DUAL_PORT),
-	 board_82598AF },
+	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_SINGLE_PORT),
-	 board_82598AF },
+	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AT_DUAL_PORT),
-	 board_82598AT },
+	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_CX4),
-	 board_82598EB },
+	 board_82598 },
 
 	/* required last entry */
 	{0, }
@@ -1571,8 +1569,8 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		dev_err(&pdev->dev, "HW Init failed\n");
 		return -EIO;
 	}
-	if (hw->phy.ops.setup_speed(hw, IXGBE_LINK_SPEED_10GB_FULL, true,
-				   false)) {
+	if (hw->mac.ops.setup_link_speed(hw, IXGBE_LINK_SPEED_10GB_FULL, true,
+					 false)) {
 		dev_err(&pdev->dev, "Link Speed setup failed\n");
 		return -EIO;
 	}
@@ -2039,7 +2037,7 @@ static void ixgbe_watchdog(unsigned long data)
 	bool link_up;
 	u32 link_speed = 0;
 
-	adapter->hw.phy.ops.check(&adapter->hw, &(link_speed), &link_up);
+	adapter->hw.mac.ops.check_link(&adapter->hw, &(link_speed), &link_up);
 
 	if (link_up) {
 		if (!netif_carrier_ok(netdev)) {
@@ -2607,7 +2605,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	/* Setup hw api */
 	memcpy(&hw->mac.ops, ii->mac_ops, sizeof(hw->mac.ops));
-	memcpy(&hw->phy.ops, ii->phy_ops, sizeof(hw->phy.ops));
 
 	err = ii->get_invariants(hw);
 	if (err)
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index 199e8f6..aa3ea72 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -31,7 +31,6 @@
 
 #include "ixgbe_type.h"
 
-s32 ixgbe_init_shared_code_phy(struct ixgbe_hw *hw);
 s32 ixgbe_setup_phy_link(struct ixgbe_hw *hw);
 s32 ixgbe_check_phy_link(struct ixgbe_hw *hw, u32 *speed, bool *link_up);
 s32 ixgbe_setup_phy_link_speed(struct ixgbe_hw *hw, u32 speed, bool autoneg,
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index fdcde16..e60787a 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1244,13 +1244,16 @@ struct ixgbe_hw;
 struct ixgbe_mac_operations {
 	s32 (*reset)(struct ixgbe_hw *);
 	enum ixgbe_media_type (*get_media_type)(struct ixgbe_hw *);
+	s32 (*setup_link)(struct ixgbe_hw *);
+	s32 (*check_link)(struct ixgbe_hw *, u32 *, bool *);
+	s32 (*setup_link_speed)(struct ixgbe_hw *, u32, bool, bool);
+	s32 (*get_link_settings)(struct ixgbe_hw *, u32 *, bool *);
 };
 
 struct ixgbe_phy_operations {
-	s32 (*setup)(struct ixgbe_hw *);
-	s32 (*check)(struct ixgbe_hw *, u32 *, bool *);
-	s32 (*setup_speed)(struct ixgbe_hw *, u32, bool, bool);
-	s32 (*get_settings)(struct ixgbe_hw *, u32 *, bool *);
+	s32 (*setup_link)(struct ixgbe_hw *);
+	s32 (*check_link)(struct ixgbe_hw *, u32 *, bool *);
+	s32 (*setup_link_speed)(struct ixgbe_hw *, u32, bool, bool);
 };
 
 struct ixgbe_mac_info {
@@ -1267,7 +1270,6 @@ struct ixgbe_mac_info {
 	bool				link_settings_loaded;
 };
 
-
 struct ixgbe_eeprom_info {
 	enum ixgbe_eeprom_type		type;
 	u16				word_size;
@@ -1290,7 +1292,6 @@ struct ixgbe_info {
 	enum ixgbe_mac_type		mac;
 	s32 				(*get_invariants)(struct ixgbe_hw *);
 	struct ixgbe_mac_operations	*mac_ops;
-	struct ixgbe_phy_operations	*phy_ops;
 };
 
 struct ixgbe_hw {
