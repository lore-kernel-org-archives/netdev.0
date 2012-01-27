From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] e1000e: split lib.c into three more-appropriate files
Date: Thu, 26 Jan 2012 19:08:48 -0800
Message-ID: <1327633729-14086-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35567 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754758Ab2A0DI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 22:08:56 -0500
In-Reply-To: <1327633729-14086-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The generic lib.c file contains code relative to the various MACs, NVM and
Manageability supported by the driver.  This patch splits the file into
three which are specific to those areas similar to how the PHY-specific
code is in phy.c and code specific to the 80003es2lan, 8257x, and ichX
MAC families are in their own files.  The generic code that is applicable
to all MAC/PHY parts supported by the driver remains in netdev.c, param.c
and ethtool.c files.  No change in functionality, just moving code
around for ease of maintenance, with some whitespace and other checkpatch
cleanups.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/Makefile         |    3 +-
 drivers/net/ethernet/intel/e1000e/{lib.c => mac.c} | 1019 +-------------------
 drivers/net/ethernet/intel/e1000e/manage.c         |  377 ++++++++
 drivers/net/ethernet/intel/e1000e/nvm.c            |  647 +++++++++++++
 4 files changed, 1051 insertions(+), 995 deletions(-)
 rename drivers/net/ethernet/intel/e1000e/{lib.c => mac.c} (65%)
 create mode 100644 drivers/net/ethernet/intel/e1000e/manage.c
 create mode 100644 drivers/net/ethernet/intel/e1000e/nvm.c

diff --git a/drivers/net/ethernet/intel/e1000e/Makefile b/drivers/net/ethernet/intel/e1000e/Makefile
index 948c05d..8b888e5 100644
--- a/drivers/net/ethernet/intel/e1000e/Makefile
+++ b/drivers/net/ethernet/intel/e1000e/Makefile
@@ -33,5 +33,6 @@
 obj-$(CONFIG_E1000E) += e1000e.o
 
 e1000e-objs := 82571.o ich8lan.o 80003es2lan.o \
-	       lib.o phy.o param.o ethtool.o netdev.o
+	       mac.o manage.o nvm.o phy.o \
+	       param.o ethtool.o netdev.o
 
diff --git a/drivers/net/ethernet/intel/e1000e/lib.c b/drivers/net/ethernet/intel/e1000e/mac.c
similarity index 65%
rename from drivers/net/ethernet/intel/e1000e/lib.c
rename to drivers/net/ethernet/intel/e1000e/mac.c
index e2678bd..64b6f43 100644
--- a/drivers/net/ethernet/intel/e1000e/lib.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -28,19 +28,6 @@
 
 #include "e1000.h"
 
-enum e1000_mng_mode {
-	e1000_mng_mode_none = 0,
-	e1000_mng_mode_asf,
-	e1000_mng_mode_pt,
-	e1000_mng_mode_ipmi,
-	e1000_mng_mode_host_if_only
-};
-
-#define E1000_FACTPS_MNGCG		0x20000000
-
-/* Intel(R) Active Management Technology signature */
-#define E1000_IAMT_SIGNATURE		0x544D4149
-
 /**
  *  e1000e_get_bus_info_pcie - Get PCIe bus information
  *  @hw: pointer to the HW structure
@@ -151,7 +138,7 @@ void e1000_write_vfta_generic(struct e1000_hw *hw, u32 offset, u32 value)
 void e1000e_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 {
 	u32 i;
-	u8 mac_addr[ETH_ALEN] = {0};
+	u8 mac_addr[ETH_ALEN] = { 0 };
 
 	/* Setup the receive address */
 	e_dbg("Programming MAC Address into RAR[0]\n");
@@ -159,7 +146,7 @@ void e1000e_init_rx_addrs(struct e1000_hw *hw, u16 rar_count)
 	e1000e_rar_set(hw, hw->mac.addr, 0);
 
 	/* Zero out the other (rar_entry_count - 1) receive addresses */
-	e_dbg("Clearing RAR[1-%u]\n", rar_count-1);
+	e_dbg("Clearing RAR[1-%u]\n", rar_count - 1);
 	for (i = 1; i < rar_count; i++)
 		e1000e_rar_set(hw, mac_addr, i);
 }
@@ -192,7 +179,7 @@ s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
 		goto out;
 
 	ret_val = e1000_read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
-	                         &nvm_alt_mac_addr_offset);
+				 &nvm_alt_mac_addr_offset);
 	if (ret_val) {
 		e_dbg("NVM Read Error\n");
 		goto out;
@@ -251,11 +238,10 @@ void e1000e_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 	 * HW expects these in little endian so we reverse the byte order
 	 * from network order (big endian) to little endian
 	 */
-	rar_low = ((u32) addr[0] |
-		   ((u32) addr[1] << 8) |
-		    ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
+	rar_low = ((u32)addr[0] | ((u32)addr[1] << 8) |
+		   ((u32)addr[2] << 16) | ((u32)addr[3] << 24));
 
-	rar_high = ((u32) addr[4] | ((u32) addr[5] << 8));
+	rar_high = ((u32)addr[4] | ((u32)addr[5] << 8));
 
 	/* If MAC address zero, no need to set the AV bit */
 	if (rar_low || rar_high)
@@ -315,7 +301,7 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 	 * values resulting from each mc_filter_type...
 	 * [0] [1] [2] [3] [4] [5]
 	 * 01  AA  00  12  34  56
-	 * LSB		 MSB
+	 * LSB           MSB
 	 *
 	 * case 0: hash_value = ((0x34 >> 4) | (0x56 << 4)) & 0xFFF = 0x563
 	 * case 1: hash_value = ((0x34 >> 3) | (0x56 << 5)) & 0xFFF = 0xAC6
@@ -338,7 +324,7 @@ static u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr)
 	}
 
 	hash_value = hash_mask & (((mc_addr[4] >> (8 - bit_shift)) |
-				  (((u16) mc_addr[5]) << bit_shift)));
+				   (((u16)mc_addr[5]) << bit_shift)));
 
 	return hash_value;
 }
@@ -362,7 +348,7 @@ void e1000e_update_mc_addr_list_generic(struct e1000_hw *hw,
 	memset(&hw->mac.mta_shadow, 0, sizeof(hw->mac.mta_shadow));
 
 	/* update mta_shadow from mc_addr_list */
-	for (i = 0; (u32) i < mc_addr_count; i++) {
+	for (i = 0; (u32)i < mc_addr_count; i++) {
 		hash_value = e1000_hash_mc_addr(hw, mc_addr_list);
 
 		hash_reg = (hash_value >> 5) & (hw->mac.mta_reg_count - 1);
@@ -458,7 +444,7 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 		return ret_val;
 
 	if (!link)
-		return ret_val; /* No link detected */
+		return ret_val;	/* No link detected */
 
 	mac->get_link_status = false;
 
@@ -701,8 +687,7 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 
 	if ((nvm_data & NVM_WORD0F_PAUSE_MASK) == 0)
 		hw->fc.requested_mode = e1000_fc_none;
-	else if ((nvm_data & NVM_WORD0F_PAUSE_MASK) ==
-		 NVM_WORD0F_ASM_DIR)
+	else if ((nvm_data & NVM_WORD0F_PAUSE_MASK) == NVM_WORD0F_ASM_DIR)
 		hw->fc.requested_mode = e1000_fc_tx_pause;
 	else
 		hw->fc.requested_mode = e1000_fc_full;
@@ -748,8 +733,7 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 	 */
 	hw->fc.current_mode = hw->fc.requested_mode;
 
-	e_dbg("After fix-ups FlowControl is now = %x\n",
-		hw->fc.current_mode);
+	e_dbg("After fix-ups FlowControl is now = %x\n", hw->fc.current_mode);
 
 	/* Call the necessary media_type subroutine to configure the link. */
 	ret_val = mac->ops.setup_physical_interface(hw);
@@ -1195,9 +1179,9 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 		 *   0   |    1    |   1   |    1    | e1000_fc_tx_pause
 		 */
 		else if (!(mii_nway_adv_reg & NWAY_AR_PAUSE) &&
-			  (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
-			  (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
-			  (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
+			 (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
+			 (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
+			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.current_mode = e1000_fc_tx_pause;
 			e_dbg("Flow Control = Tx PAUSE frames only.\n");
 		}
@@ -1261,7 +1245,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
  *  Read the status register for the current speed/duplex and store the current
  *  speed and duplex for copper connections.
  **/
-s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *duplex)
+s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed,
+				       u16 *duplex)
 {
 	u32 status;
 
@@ -1294,7 +1279,8 @@ s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed, u16 *dup
  *  Sets the speed and duplex to gigabit full duplex (the only possible option)
  *  for fiber/serdes links.
  **/
-s32 e1000e_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed, u16 *duplex)
+s32 e1000e_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed,
+					     u16 *duplex)
 {
 	*speed = SPEED_1000;
 	*duplex = FULL_DUPLEX;
@@ -1497,11 +1483,10 @@ s32 e1000e_setup_led_generic(struct e1000_hw *hw)
 		ledctl = er32(LEDCTL);
 		hw->mac.ledctl_default = ledctl;
 		/* Turn off LED0 */
-		ledctl &= ~(E1000_LEDCTL_LED0_IVRT |
-		            E1000_LEDCTL_LED0_BLINK |
-		            E1000_LEDCTL_LED0_MODE_MASK);
+		ledctl &= ~(E1000_LEDCTL_LED0_IVRT | E1000_LEDCTL_LED0_BLINK |
+			    E1000_LEDCTL_LED0_MODE_MASK);
 		ledctl |= (E1000_LEDCTL_MODE_LED_OFF <<
-		           E1000_LEDCTL_LED0_MODE_SHIFT);
+			   E1000_LEDCTL_LED0_MODE_SHIFT);
 		ew32(LEDCTL, ledctl);
 	} else if (hw->phy.media_type == e1000_media_type_copper) {
 		ew32(LEDCTL, hw->mac.ledctl_mode1);
@@ -1537,7 +1522,7 @@ s32 e1000e_blink_led_generic(struct e1000_hw *hw)
 	if (hw->phy.media_type == e1000_media_type_fiber) {
 		/* always blink LED0 for PCI-E fiber */
 		ledctl_blink = E1000_LEDCTL_LED0_BLINK |
-		     (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
+		    (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
 	} else {
 		/*
 		 * set the blink bit for each LED that's "on" (0x0E)
@@ -1650,8 +1635,7 @@ s32 e1000e_disable_pcie_master(struct e1000_hw *hw)
 	ew32(CTRL, ctrl);
 
 	while (timeout) {
-		if (!(er32(STATUS) &
-		      E1000_STATUS_GIO_MASTER_ENABLE))
+		if (!(er32(STATUS) & E1000_STATUS_GIO_MASTER_ENABLE))
 			break;
 		udelay(100);
 		timeout--;
@@ -1716,7 +1700,7 @@ void e1000e_update_adaptive(struct e1000_hw *hw)
 					mac->current_ifs_val = mac->ifs_min_val;
 				else
 					mac->current_ifs_val +=
-						mac->ifs_step_size;
+					    mac->ifs_step_size;
 				ew32(AIT, mac->current_ifs_val);
 			}
 		}
@@ -1731,956 +1715,3 @@ void e1000e_update_adaptive(struct e1000_hw *hw)
 out:
 	return;
 }
-
-/**
- *  e1000_raise_eec_clk - Raise EEPROM clock
- *  @hw: pointer to the HW structure
- *  @eecd: pointer to the EEPROM
- *
- *  Enable/Raise the EEPROM clock bit.
- **/
-static void e1000_raise_eec_clk(struct e1000_hw *hw, u32 *eecd)
-{
-	*eecd = *eecd | E1000_EECD_SK;
-	ew32(EECD, *eecd);
-	e1e_flush();
-	udelay(hw->nvm.delay_usec);
-}
-
-/**
- *  e1000_lower_eec_clk - Lower EEPROM clock
- *  @hw: pointer to the HW structure
- *  @eecd: pointer to the EEPROM
- *
- *  Clear/Lower the EEPROM clock bit.
- **/
-static void e1000_lower_eec_clk(struct e1000_hw *hw, u32 *eecd)
-{
-	*eecd = *eecd & ~E1000_EECD_SK;
-	ew32(EECD, *eecd);
-	e1e_flush();
-	udelay(hw->nvm.delay_usec);
-}
-
-/**
- *  e1000_shift_out_eec_bits - Shift data bits our to the EEPROM
- *  @hw: pointer to the HW structure
- *  @data: data to send to the EEPROM
- *  @count: number of bits to shift out
- *
- *  We need to shift 'count' bits out to the EEPROM.  So, the value in the
- *  "data" parameter will be shifted out to the EEPROM one bit at a time.
- *  In order to do this, "data" must be broken down into bits.
- **/
-static void e1000_shift_out_eec_bits(struct e1000_hw *hw, u16 data, u16 count)
-{
-	struct e1000_nvm_info *nvm = &hw->nvm;
-	u32 eecd = er32(EECD);
-	u32 mask;
-
-	mask = 0x01 << (count - 1);
-	if (nvm->type == e1000_nvm_eeprom_spi)
-		eecd |= E1000_EECD_DO;
-
-	do {
-		eecd &= ~E1000_EECD_DI;
-
-		if (data & mask)
-			eecd |= E1000_EECD_DI;
-
-		ew32(EECD, eecd);
-		e1e_flush();
-
-		udelay(nvm->delay_usec);
-
-		e1000_raise_eec_clk(hw, &eecd);
-		e1000_lower_eec_clk(hw, &eecd);
-
-		mask >>= 1;
-	} while (mask);
-
-	eecd &= ~E1000_EECD_DI;
-	ew32(EECD, eecd);
-}
-
-/**
- *  e1000_shift_in_eec_bits - Shift data bits in from the EEPROM
- *  @hw: pointer to the HW structure
- *  @count: number of bits to shift in
- *
- *  In order to read a register from the EEPROM, we need to shift 'count' bits
- *  in from the EEPROM.  Bits are "shifted in" by raising the clock input to
- *  the EEPROM (setting the SK bit), and then reading the value of the data out
- *  "DO" bit.  During this "shifting in" process the data in "DI" bit should
- *  always be clear.
- **/
-static u16 e1000_shift_in_eec_bits(struct e1000_hw *hw, u16 count)
-{
-	u32 eecd;
-	u32 i;
-	u16 data;
-
-	eecd = er32(EECD);
-
-	eecd &= ~(E1000_EECD_DO | E1000_EECD_DI);
-	data = 0;
-
-	for (i = 0; i < count; i++) {
-		data <<= 1;
-		e1000_raise_eec_clk(hw, &eecd);
-
-		eecd = er32(EECD);
-
-		eecd &= ~E1000_EECD_DI;
-		if (eecd & E1000_EECD_DO)
-			data |= 1;
-
-		e1000_lower_eec_clk(hw, &eecd);
-	}
-
-	return data;
-}
-
-/**
- *  e1000e_poll_eerd_eewr_done - Poll for EEPROM read/write completion
- *  @hw: pointer to the HW structure
- *  @ee_reg: EEPROM flag for polling
- *
- *  Polls the EEPROM status bit for either read or write completion based
- *  upon the value of 'ee_reg'.
- **/
-s32 e1000e_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg)
-{
-	u32 attempts = 100000;
-	u32 i, reg = 0;
-
-	for (i = 0; i < attempts; i++) {
-		if (ee_reg == E1000_NVM_POLL_READ)
-			reg = er32(EERD);
-		else
-			reg = er32(EEWR);
-
-		if (reg & E1000_NVM_RW_REG_DONE)
-			return 0;
-
-		udelay(5);
-	}
-
-	return -E1000_ERR_NVM;
-}
-
-/**
- *  e1000e_acquire_nvm - Generic request for access to EEPROM
- *  @hw: pointer to the HW structure
- *
- *  Set the EEPROM access request bit and wait for EEPROM access grant bit.
- *  Return successful if access grant bit set, else clear the request for
- *  EEPROM access and return -E1000_ERR_NVM (-1).
- **/
-s32 e1000e_acquire_nvm(struct e1000_hw *hw)
-{
-	u32 eecd = er32(EECD);
-	s32 timeout = E1000_NVM_GRANT_ATTEMPTS;
-
-	ew32(EECD, eecd | E1000_EECD_REQ);
-	eecd = er32(EECD);
-
-	while (timeout) {
-		if (eecd & E1000_EECD_GNT)
-			break;
-		udelay(5);
-		eecd = er32(EECD);
-		timeout--;
-	}
-
-	if (!timeout) {
-		eecd &= ~E1000_EECD_REQ;
-		ew32(EECD, eecd);
-		e_dbg("Could not acquire NVM grant\n");
-		return -E1000_ERR_NVM;
-	}
-
-	return 0;
-}
-
-/**
- *  e1000_standby_nvm - Return EEPROM to standby state
- *  @hw: pointer to the HW structure
- *
- *  Return the EEPROM to a standby state.
- **/
-static void e1000_standby_nvm(struct e1000_hw *hw)
-{
-	struct e1000_nvm_info *nvm = &hw->nvm;
-	u32 eecd = er32(EECD);
-
-	if (nvm->type == e1000_nvm_eeprom_spi) {
-		/* Toggle CS to flush commands */
-		eecd |= E1000_EECD_CS;
-		ew32(EECD, eecd);
-		e1e_flush();
-		udelay(nvm->delay_usec);
-		eecd &= ~E1000_EECD_CS;
-		ew32(EECD, eecd);
-		e1e_flush();
-		udelay(nvm->delay_usec);
-	}
-}
-
-/**
- *  e1000_stop_nvm - Terminate EEPROM command
- *  @hw: pointer to the HW structure
- *
- *  Terminates the current command by inverting the EEPROM's chip select pin.
- **/
-static void e1000_stop_nvm(struct e1000_hw *hw)
-{
-	u32 eecd;
-
-	eecd = er32(EECD);
-	if (hw->nvm.type == e1000_nvm_eeprom_spi) {
-		/* Pull CS high */
-		eecd |= E1000_EECD_CS;
-		e1000_lower_eec_clk(hw, &eecd);
-	}
-}
-
-/**
- *  e1000e_release_nvm - Release exclusive access to EEPROM
- *  @hw: pointer to the HW structure
- *
- *  Stop any current commands to the EEPROM and clear the EEPROM request bit.
- **/
-void e1000e_release_nvm(struct e1000_hw *hw)
-{
-	u32 eecd;
-
-	e1000_stop_nvm(hw);
-
-	eecd = er32(EECD);
-	eecd &= ~E1000_EECD_REQ;
-	ew32(EECD, eecd);
-}
-
-/**
- *  e1000_ready_nvm_eeprom - Prepares EEPROM for read/write
- *  @hw: pointer to the HW structure
- *
- *  Setups the EEPROM for reading and writing.
- **/
-static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
-{
-	struct e1000_nvm_info *nvm = &hw->nvm;
-	u32 eecd = er32(EECD);
-	u8 spi_stat_reg;
-
-	if (nvm->type == e1000_nvm_eeprom_spi) {
-		u16 timeout = NVM_MAX_RETRY_SPI;
-
-		/* Clear SK and CS */
-		eecd &= ~(E1000_EECD_CS | E1000_EECD_SK);
-		ew32(EECD, eecd);
-		e1e_flush();
-		udelay(1);
-
-		/*
-		 * Read "Status Register" repeatedly until the LSB is cleared.
-		 * The EEPROM will signal that the command has been completed
-		 * by clearing bit 0 of the internal status register.  If it's
-		 * not cleared within 'timeout', then error out.
-		 */
-		while (timeout) {
-			e1000_shift_out_eec_bits(hw, NVM_RDSR_OPCODE_SPI,
-						 hw->nvm.opcode_bits);
-			spi_stat_reg = (u8)e1000_shift_in_eec_bits(hw, 8);
-			if (!(spi_stat_reg & NVM_STATUS_RDY_SPI))
-				break;
-
-			udelay(5);
-			e1000_standby_nvm(hw);
-			timeout--;
-		}
-
-		if (!timeout) {
-			e_dbg("SPI NVM Status error\n");
-			return -E1000_ERR_NVM;
-		}
-	}
-
-	return 0;
-}
-
-/**
- *  e1000e_read_nvm_eerd - Reads EEPROM using EERD register
- *  @hw: pointer to the HW structure
- *  @offset: offset of word in the EEPROM to read
- *  @words: number of words to read
- *  @data: word read from the EEPROM
- *
- *  Reads a 16 bit word from the EEPROM using the EERD register.
- **/
-s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
-{
-	struct e1000_nvm_info *nvm = &hw->nvm;
-	u32 i, eerd = 0;
-	s32 ret_val = 0;
-
-	/*
-	 * A check for invalid values:  offset too large, too many words,
-	 * too many words for the offset, and not enough words.
-	 */
-	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
-	    (words == 0)) {
-		e_dbg("nvm parameter(s) out of bounds\n");
-		return -E1000_ERR_NVM;
-	}
-
-	for (i = 0; i < words; i++) {
-		eerd = ((offset+i) << E1000_NVM_RW_ADDR_SHIFT) +
-		       E1000_NVM_RW_REG_START;
-
-		ew32(EERD, eerd);
-		ret_val = e1000e_poll_eerd_eewr_done(hw, E1000_NVM_POLL_READ);
-		if (ret_val)
-			break;
-
-		data[i] = (er32(EERD) >> E1000_NVM_RW_REG_DATA);
-	}
-
-	return ret_val;
-}
-
-/**
- *  e1000e_write_nvm_spi - Write to EEPROM using SPI
- *  @hw: pointer to the HW structure
- *  @offset: offset within the EEPROM to be written to
- *  @words: number of words to write
- *  @data: 16 bit word(s) to be written to the EEPROM
- *
- *  Writes data to EEPROM at offset using SPI interface.
- *
- *  If e1000e_update_nvm_checksum is not called after this function , the
- *  EEPROM will most likely contain an invalid checksum.
- **/
-s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
-{
-	struct e1000_nvm_info *nvm = &hw->nvm;
-	s32 ret_val;
-	u16 widx = 0;
-
-	/*
-	 * A check for invalid values:  offset too large, too many words,
-	 * and not enough words.
-	 */
-	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
-	    (words == 0)) {
-		e_dbg("nvm parameter(s) out of bounds\n");
-		return -E1000_ERR_NVM;
-	}
-
-	ret_val = nvm->ops.acquire(hw);
-	if (ret_val)
-		return ret_val;
-
-	while (widx < words) {
-		u8 write_opcode = NVM_WRITE_OPCODE_SPI;
-
-		ret_val = e1000_ready_nvm_eeprom(hw);
-		if (ret_val) {
-			nvm->ops.release(hw);
-			return ret_val;
-		}
-
-		e1000_standby_nvm(hw);
-
-		/* Send the WRITE ENABLE command (8 bit opcode) */
-		e1000_shift_out_eec_bits(hw, NVM_WREN_OPCODE_SPI,
-					 nvm->opcode_bits);
-
-		e1000_standby_nvm(hw);
-
-		/*
-		 * Some SPI eeproms use the 8th address bit embedded in the
-		 * opcode
-		 */
-		if ((nvm->address_bits == 8) && (offset >= 128))
-			write_opcode |= NVM_A8_OPCODE_SPI;
-
-		/* Send the Write command (8-bit opcode + addr) */
-		e1000_shift_out_eec_bits(hw, write_opcode, nvm->opcode_bits);
-		e1000_shift_out_eec_bits(hw, (u16)((offset + widx) * 2),
-					 nvm->address_bits);
-
-		/* Loop to allow for up to whole page write of eeprom */
-		while (widx < words) {
-			u16 word_out = data[widx];
-			word_out = (word_out >> 8) | (word_out << 8);
-			e1000_shift_out_eec_bits(hw, word_out, 16);
-			widx++;
-
-			if ((((offset + widx) * 2) % nvm->page_size) == 0) {
-				e1000_standby_nvm(hw);
-				break;
-			}
-		}
-	}
-
-	usleep_range(10000, 20000);
-	nvm->ops.release(hw);
-	return 0;
-}
-
-/**
- *  e1000_read_pba_string_generic - Read device part number
- *  @hw: pointer to the HW structure
- *  @pba_num: pointer to device part number
- *  @pba_num_size: size of part number buffer
- *
- *  Reads the product board assembly (PBA) number from the EEPROM and stores
- *  the value in pba_num.
- **/
-s32 e1000_read_pba_string_generic(struct e1000_hw *hw, u8 *pba_num,
-				  u32 pba_num_size)
-{
-	s32 ret_val;
-	u16 nvm_data;
-	u16 pba_ptr;
-	u16 offset;
-	u16 length;
-
-	if (pba_num == NULL) {
-		e_dbg("PBA string buffer was null\n");
-		ret_val = E1000_ERR_INVALID_ARGUMENT;
-		goto out;
-	}
-
-	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
-	if (ret_val) {
-		e_dbg("NVM Read Error\n");
-		goto out;
-	}
-
-	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_1, 1, &pba_ptr);
-	if (ret_val) {
-		e_dbg("NVM Read Error\n");
-		goto out;
-	}
-
-	/*
-	 * if nvm_data is not ptr guard the PBA must be in legacy format which
-	 * means pba_ptr is actually our second data word for the PBA number
-	 * and we can decode it into an ascii string
-	 */
-	if (nvm_data != NVM_PBA_PTR_GUARD) {
-		e_dbg("NVM PBA number is not stored as string\n");
-
-		/* we will need 11 characters to store the PBA */
-		if (pba_num_size < 11) {
-			e_dbg("PBA string buffer too small\n");
-			return E1000_ERR_NO_SPACE;
-		}
-
-		/* extract hex string from data and pba_ptr */
-		pba_num[0] = (nvm_data >> 12) & 0xF;
-		pba_num[1] = (nvm_data >> 8) & 0xF;
-		pba_num[2] = (nvm_data >> 4) & 0xF;
-		pba_num[3] = nvm_data & 0xF;
-		pba_num[4] = (pba_ptr >> 12) & 0xF;
-		pba_num[5] = (pba_ptr >> 8) & 0xF;
-		pba_num[6] = '-';
-		pba_num[7] = 0;
-		pba_num[8] = (pba_ptr >> 4) & 0xF;
-		pba_num[9] = pba_ptr & 0xF;
-
-		/* put a null character on the end of our string */
-		pba_num[10] = '\0';
-
-		/* switch all the data but the '-' to hex char */
-		for (offset = 0; offset < 10; offset++) {
-			if (pba_num[offset] < 0xA)
-				pba_num[offset] += '0';
-			else if (pba_num[offset] < 0x10)
-				pba_num[offset] += 'A' - 0xA;
-		}
-
-		goto out;
-	}
-
-	ret_val = e1000_read_nvm(hw, pba_ptr, 1, &length);
-	if (ret_val) {
-		e_dbg("NVM Read Error\n");
-		goto out;
-	}
-
-	if (length == 0xFFFF || length == 0) {
-		e_dbg("NVM PBA number section invalid length\n");
-		ret_val = E1000_ERR_NVM_PBA_SECTION;
-		goto out;
-	}
-	/* check if pba_num buffer is big enough */
-	if (pba_num_size < (((u32)length * 2) - 1)) {
-		e_dbg("PBA string buffer too small\n");
-		ret_val = E1000_ERR_NO_SPACE;
-		goto out;
-	}
-
-	/* trim pba length from start of string */
-	pba_ptr++;
-	length--;
-
-	for (offset = 0; offset < length; offset++) {
-		ret_val = e1000_read_nvm(hw, pba_ptr + offset, 1, &nvm_data);
-		if (ret_val) {
-			e_dbg("NVM Read Error\n");
-			goto out;
-		}
-		pba_num[offset * 2] = (u8)(nvm_data >> 8);
-		pba_num[(offset * 2) + 1] = (u8)(nvm_data & 0xFF);
-	}
-	pba_num[offset * 2] = '\0';
-
-out:
-	return ret_val;
-}
-
-/**
- *  e1000_read_mac_addr_generic - Read device MAC address
- *  @hw: pointer to the HW structure
- *
- *  Reads the device MAC address from the EEPROM and stores the value.
- *  Since devices with two ports use the same EEPROM, we increment the
- *  last bit in the MAC address for the second port.
- **/
-s32 e1000_read_mac_addr_generic(struct e1000_hw *hw)
-{
-	u32 rar_high;
-	u32 rar_low;
-	u16 i;
-
-	rar_high = er32(RAH(0));
-	rar_low = er32(RAL(0));
-
-	for (i = 0; i < E1000_RAL_MAC_ADDR_LEN; i++)
-		hw->mac.perm_addr[i] = (u8)(rar_low >> (i*8));
-
-	for (i = 0; i < E1000_RAH_MAC_ADDR_LEN; i++)
-		hw->mac.perm_addr[i+4] = (u8)(rar_high >> (i*8));
-
-	for (i = 0; i < ETH_ALEN; i++)
-		hw->mac.addr[i] = hw->mac.perm_addr[i];
-
-	return 0;
-}
-
-/**
- *  e1000e_validate_nvm_checksum_generic - Validate EEPROM checksum
- *  @hw: pointer to the HW structure
- *
- *  Calculates the EEPROM checksum by reading/adding each word of the EEPROM
- *  and then verifies that the sum of the EEPROM is equal to 0xBABA.
- **/
-s32 e1000e_validate_nvm_checksum_generic(struct e1000_hw *hw)
-{
-	s32 ret_val;
-	u16 checksum = 0;
-	u16 i, nvm_data;
-
-	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
-		ret_val = e1000_read_nvm(hw, i, 1, &nvm_data);
-		if (ret_val) {
-			e_dbg("NVM Read Error\n");
-			return ret_val;
-		}
-		checksum += nvm_data;
-	}
-
-	if (checksum != (u16) NVM_SUM) {
-		e_dbg("NVM Checksum Invalid\n");
-		return -E1000_ERR_NVM;
-	}
-
-	return 0;
-}
-
-/**
- *  e1000e_update_nvm_checksum_generic - Update EEPROM checksum
- *  @hw: pointer to the HW structure
- *
- *  Updates the EEPROM checksum by reading/adding each word of the EEPROM
- *  up to the checksum.  Then calculates the EEPROM checksum and writes the
- *  value to the EEPROM.
- **/
-s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw)
-{
-	s32 ret_val;
-	u16 checksum = 0;
-	u16 i, nvm_data;
-
-	for (i = 0; i < NVM_CHECKSUM_REG; i++) {
-		ret_val = e1000_read_nvm(hw, i, 1, &nvm_data);
-		if (ret_val) {
-			e_dbg("NVM Read Error while updating checksum.\n");
-			return ret_val;
-		}
-		checksum += nvm_data;
-	}
-	checksum = (u16) NVM_SUM - checksum;
-	ret_val = e1000_write_nvm(hw, NVM_CHECKSUM_REG, 1, &checksum);
-	if (ret_val)
-		e_dbg("NVM Write Error while updating checksum.\n");
-
-	return ret_val;
-}
-
-/**
- *  e1000e_reload_nvm - Reloads EEPROM
- *  @hw: pointer to the HW structure
- *
- *  Reloads the EEPROM by setting the "Reinitialize from EEPROM" bit in the
- *  extended control register.
- **/
-void e1000e_reload_nvm(struct e1000_hw *hw)
-{
-	u32 ctrl_ext;
-
-	udelay(10);
-	ctrl_ext = er32(CTRL_EXT);
-	ctrl_ext |= E1000_CTRL_EXT_EE_RST;
-	ew32(CTRL_EXT, ctrl_ext);
-	e1e_flush();
-}
-
-/**
- *  e1000_calculate_checksum - Calculate checksum for buffer
- *  @buffer: pointer to EEPROM
- *  @length: size of EEPROM to calculate a checksum for
- *
- *  Calculates the checksum for some buffer on a specified length.  The
- *  checksum calculated is returned.
- **/
-static u8 e1000_calculate_checksum(u8 *buffer, u32 length)
-{
-	u32 i;
-	u8  sum = 0;
-
-	if (!buffer)
-		return 0;
-
-	for (i = 0; i < length; i++)
-		sum += buffer[i];
-
-	return (u8) (0 - sum);
-}
-
-/**
- *  e1000_mng_enable_host_if - Checks host interface is enabled
- *  @hw: pointer to the HW structure
- *
- *  Returns E1000_success upon success, else E1000_ERR_HOST_INTERFACE_COMMAND
- *
- *  This function checks whether the HOST IF is enabled for command operation
- *  and also checks whether the previous command is completed.  It busy waits
- *  in case of previous command is not completed.
- **/
-static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
-{
-	u32 hicr;
-	u8 i;
-
-	if (!(hw->mac.arc_subsystem_valid)) {
-		e_dbg("ARC subsystem not valid.\n");
-		return -E1000_ERR_HOST_INTERFACE_COMMAND;
-	}
-
-	/* Check that the host interface is enabled. */
-	hicr = er32(HICR);
-	if ((hicr & E1000_HICR_EN) == 0) {
-		e_dbg("E1000_HOST_EN bit disabled.\n");
-		return -E1000_ERR_HOST_INTERFACE_COMMAND;
-	}
-	/* check the previous command is completed */
-	for (i = 0; i < E1000_MNG_DHCP_COMMAND_TIMEOUT; i++) {
-		hicr = er32(HICR);
-		if (!(hicr & E1000_HICR_C))
-			break;
-		mdelay(1);
-	}
-
-	if (i == E1000_MNG_DHCP_COMMAND_TIMEOUT) {
-		e_dbg("Previous command timeout failed .\n");
-		return -E1000_ERR_HOST_INTERFACE_COMMAND;
-	}
-
-	return 0;
-}
-
-/**
- *  e1000e_check_mng_mode_generic - check management mode
- *  @hw: pointer to the HW structure
- *
- *  Reads the firmware semaphore register and returns true (>0) if
- *  manageability is enabled, else false (0).
- **/
-bool e1000e_check_mng_mode_generic(struct e1000_hw *hw)
-{
-	u32 fwsm = er32(FWSM);
-
-	return (fwsm & E1000_FWSM_MODE_MASK) ==
-		(E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT);
-}
-
-/**
- *  e1000e_enable_tx_pkt_filtering - Enable packet filtering on Tx
- *  @hw: pointer to the HW structure
- *
- *  Enables packet filtering on transmit packets if manageability is enabled
- *  and host interface is enabled.
- **/
-bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw)
-{
-	struct e1000_host_mng_dhcp_cookie *hdr = &hw->mng_cookie;
-	u32 *buffer = (u32 *)&hw->mng_cookie;
-	u32 offset;
-	s32 ret_val, hdr_csum, csum;
-	u8 i, len;
-
-	hw->mac.tx_pkt_filtering = true;
-
-	/* No manageability, no filtering */
-	if (!e1000e_check_mng_mode(hw)) {
-		hw->mac.tx_pkt_filtering = false;
-		goto out;
-	}
-
-	/*
-	 * If we can't read from the host interface for whatever
-	 * reason, disable filtering.
-	 */
-	ret_val = e1000_mng_enable_host_if(hw);
-	if (ret_val) {
-		hw->mac.tx_pkt_filtering = false;
-		goto out;
-	}
-
-	/* Read in the header.  Length and offset are in dwords. */
-	len    = E1000_MNG_DHCP_COOKIE_LENGTH >> 2;
-	offset = E1000_MNG_DHCP_COOKIE_OFFSET >> 2;
-	for (i = 0; i < len; i++)
-		*(buffer + i) = E1000_READ_REG_ARRAY(hw, E1000_HOST_IF, offset + i);
-	hdr_csum = hdr->checksum;
-	hdr->checksum = 0;
-	csum = e1000_calculate_checksum((u8 *)hdr,
-					E1000_MNG_DHCP_COOKIE_LENGTH);
-	/*
-	 * If either the checksums or signature don't match, then
-	 * the cookie area isn't considered valid, in which case we
-	 * take the safe route of assuming Tx filtering is enabled.
-	 */
-	if ((hdr_csum != csum) || (hdr->signature != E1000_IAMT_SIGNATURE)) {
-		hw->mac.tx_pkt_filtering = true;
-		goto out;
-	}
-
-	/* Cookie area is valid, make the final check for filtering. */
-	if (!(hdr->status & E1000_MNG_DHCP_COOKIE_STATUS_PARSING)) {
-		hw->mac.tx_pkt_filtering = false;
-		goto out;
-	}
-
-out:
-	return hw->mac.tx_pkt_filtering;
-}
-
-/**
- *  e1000_mng_write_cmd_header - Writes manageability command header
- *  @hw: pointer to the HW structure
- *  @hdr: pointer to the host interface command header
- *
- *  Writes the command header after does the checksum calculation.
- **/
-static s32 e1000_mng_write_cmd_header(struct e1000_hw *hw,
-				  struct e1000_host_mng_command_header *hdr)
-{
-	u16 i, length = sizeof(struct e1000_host_mng_command_header);
-
-	/* Write the whole command header structure with new checksum. */
-
-	hdr->checksum = e1000_calculate_checksum((u8 *)hdr, length);
-
-	length >>= 2;
-	/* Write the relevant command block into the ram area. */
-	for (i = 0; i < length; i++) {
-		E1000_WRITE_REG_ARRAY(hw, E1000_HOST_IF, i,
-					    *((u32 *) hdr + i));
-		e1e_flush();
-	}
-
-	return 0;
-}
-
-/**
- *  e1000_mng_host_if_write - Write to the manageability host interface
- *  @hw: pointer to the HW structure
- *  @buffer: pointer to the host interface buffer
- *  @length: size of the buffer
- *  @offset: location in the buffer to write to
- *  @sum: sum of the data (not checksum)
- *
- *  This function writes the buffer content at the offset given on the host if.
- *  It also does alignment considerations to do the writes in most efficient
- *  way.  Also fills up the sum of the buffer in *buffer parameter.
- **/
-static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer,
-				   u16 length, u16 offset, u8 *sum)
-{
-	u8 *tmp;
-	u8 *bufptr = buffer;
-	u32 data = 0;
-	u16 remaining, i, j, prev_bytes;
-
-	/* sum = only sum of the data and it is not checksum */
-
-	if (length == 0 || offset + length > E1000_HI_MAX_MNG_DATA_LENGTH)
-		return -E1000_ERR_PARAM;
-
-	tmp = (u8 *)&data;
-	prev_bytes = offset & 0x3;
-	offset >>= 2;
-
-	if (prev_bytes) {
-		data = E1000_READ_REG_ARRAY(hw, E1000_HOST_IF, offset);
-		for (j = prev_bytes; j < sizeof(u32); j++) {
-			*(tmp + j) = *bufptr++;
-			*sum += *(tmp + j);
-		}
-		E1000_WRITE_REG_ARRAY(hw, E1000_HOST_IF, offset, data);
-		length -= j - prev_bytes;
-		offset++;
-	}
-
-	remaining = length & 0x3;
-	length -= remaining;
-
-	/* Calculate length in DWORDs */
-	length >>= 2;
-
-	/*
-	 * The device driver writes the relevant command block into the
-	 * ram area.
-	 */
-	for (i = 0; i < length; i++) {
-		for (j = 0; j < sizeof(u32); j++) {
-			*(tmp + j) = *bufptr++;
-			*sum += *(tmp + j);
-		}
-
-		E1000_WRITE_REG_ARRAY(hw, E1000_HOST_IF, offset + i, data);
-	}
-	if (remaining) {
-		for (j = 0; j < sizeof(u32); j++) {
-			if (j < remaining)
-				*(tmp + j) = *bufptr++;
-			else
-				*(tmp + j) = 0;
-
-			*sum += *(tmp + j);
-		}
-		E1000_WRITE_REG_ARRAY(hw, E1000_HOST_IF, offset + i, data);
-	}
-
-	return 0;
-}
-
-/**
- *  e1000e_mng_write_dhcp_info - Writes DHCP info to host interface
- *  @hw: pointer to the HW structure
- *  @buffer: pointer to the host interface
- *  @length: size of the buffer
- *
- *  Writes the DHCP information to the host interface.
- **/
-s32 e1000e_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length)
-{
-	struct e1000_host_mng_command_header hdr;
-	s32 ret_val;
-	u32 hicr;
-
-	hdr.command_id = E1000_MNG_DHCP_TX_PAYLOAD_CMD;
-	hdr.command_length = length;
-	hdr.reserved1 = 0;
-	hdr.reserved2 = 0;
-	hdr.checksum = 0;
-
-	/* Enable the host interface */
-	ret_val = e1000_mng_enable_host_if(hw);
-	if (ret_val)
-		return ret_val;
-
-	/* Populate the host interface with the contents of "buffer". */
-	ret_val = e1000_mng_host_if_write(hw, buffer, length,
-					  sizeof(hdr), &(hdr.checksum));
-	if (ret_val)
-		return ret_val;
-
-	/* Write the manageability command header */
-	ret_val = e1000_mng_write_cmd_header(hw, &hdr);
-	if (ret_val)
-		return ret_val;
-
-	/* Tell the ARC a new command is pending. */
-	hicr = er32(HICR);
-	ew32(HICR, hicr | E1000_HICR_C);
-
-	return 0;
-}
-
-/**
- *  e1000e_enable_mng_pass_thru - Check if management passthrough is needed
- *  @hw: pointer to the HW structure
- *
- *  Verifies the hardware needs to leave interface enabled so that frames can
- *  be directed to and from the management interface.
- **/
-bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw)
-{
-	u32 manc;
-	u32 fwsm, factps;
-	bool ret_val = false;
-
-	manc = er32(MANC);
-
-	if (!(manc & E1000_MANC_RCV_TCO_EN))
-		goto out;
-
-	if (hw->mac.has_fwsm) {
-		fwsm = er32(FWSM);
-		factps = er32(FACTPS);
-
-		if (!(factps & E1000_FACTPS_MNGCG) &&
-		    ((fwsm & E1000_FWSM_MODE_MASK) ==
-		     (e1000_mng_mode_pt << E1000_FWSM_MODE_SHIFT))) {
-			ret_val = true;
-			goto out;
-		}
-	} else if ((hw->mac.type == e1000_82574) ||
-		   (hw->mac.type == e1000_82583)) {
-		u16 data;
-
-		factps = er32(FACTPS);
-		e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &data);
-
-		if (!(factps & E1000_FACTPS_MNGCG) &&
-		    ((data & E1000_NVM_INIT_CTRL2_MNGM) ==
-		     (e1000_mng_mode_pt << 13))) {
-			ret_val = true;
-			goto out;
-		}
-	} else if ((manc & E1000_MANC_SMBUS_EN) &&
-		    !(manc & E1000_MANC_ASF_EN)) {
-			ret_val = true;
-			goto out;
-	}
-
-out:
-	return ret_val;
-}
diff --git a/drivers/net/ethernet/intel/e1000e/manage.c b/drivers/net/ethernet/intel/e1000e/manage.c
new file mode 100644
index 0000000..3dae265
--- /dev/null
+++ b/drivers/net/ethernet/intel/e1000e/manage.c
@@ -0,0 +1,377 @@
+/*******************************************************************************
+
+  Intel PRO/1000 Linux driver
+  Copyright(c) 1999 - 2011 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "e1000.h"
+
+enum e1000_mng_mode {
+	e1000_mng_mode_none = 0,
+	e1000_mng_mode_asf,
+	e1000_mng_mode_pt,
+	e1000_mng_mode_ipmi,
+	e1000_mng_mode_host_if_only
+};
+
+#define E1000_FACTPS_MNGCG		0x20000000
+
+/* Intel(R) Active Management Technology signature */
+#define E1000_IAMT_SIGNATURE		0x544D4149
+
+/**
+ *  e1000_calculate_checksum - Calculate checksum for buffer
+ *  @buffer: pointer to EEPROM
+ *  @length: size of EEPROM to calculate a checksum for
+ *
+ *  Calculates the checksum for some buffer on a specified length.  The
+ *  checksum calculated is returned.
+ **/
+static u8 e1000_calculate_checksum(u8 *buffer, u32 length)
+{
+	u32 i;
+	u8 sum = 0;
+
+	if (!buffer)
+		return 0;
+
+	for (i = 0; i < length; i++)
+		sum += buffer[i];
+
+	return (u8)(0 - sum);
+}
+
+/**
+ *  e1000_mng_enable_host_if - Checks host interface is enabled
+ *  @hw: pointer to the HW structure
+ *
+ *  Returns E1000_success upon success, else E1000_ERR_HOST_INTERFACE_COMMAND
+ *
+ *  This function checks whether the HOST IF is enabled for command operation
+ *  and also checks whether the previous command is completed.  It busy waits
+ *  in case of previous command is not completed.
+ **/
+static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
+{
+	u32 hicr;
+	u8 i;
+
+	if (!(hw->mac.arc_subsystem_valid)) {
+		e_dbg("ARC subsystem not valid.\n");
+		return -E1000_ERR_HOST_INTERFACE_COMMAND;
+	}
+
+	/* Check that the host interface is enabled. */
+	hicr = er32(HICR);
+	if ((hicr & E1000_HICR_EN) == 0) {
+		e_dbg("E1000_HOST_EN bit disabled.\n");
+		return -E1000_ERR_HOST_INTERFACE_COMMAND;
+	}
+	/* check the previous command is completed */
+	for (i = 0; i < E1000_MNG_DHCP_COMMAND_TIMEOUT; i++) {
+		hicr = er32(HICR);
+		if (!(hicr & E1000_HICR_C))
+			break;
+		mdelay(1);
+	}
+
+	if (i == E1000_MNG_DHCP_COMMAND_TIMEOUT) {
+		e_dbg("Previous command timeout failed .\n");
+		return -E1000_ERR_HOST_INTERFACE_COMMAND;
+	}
+
+	return 0;
+}
+
+/**
+ *  e1000e_check_mng_mode_generic - check management mode
+ *  @hw: pointer to the HW structure
+ *
+ *  Reads the firmware semaphore register and returns true (>0) if
+ *  manageability is enabled, else false (0).
+ **/
+bool e1000e_check_mng_mode_generic(struct e1000_hw *hw)
+{
+	u32 fwsm = er32(FWSM);
+
+	return (fwsm & E1000_FWSM_MODE_MASK) ==
+	    (E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT);
+}
+
+/**
+ *  e1000e_enable_tx_pkt_filtering - Enable packet filtering on Tx
+ *  @hw: pointer to the HW structure
+ *
+ *  Enables packet filtering on transmit packets if manageability is enabled
+ *  and host interface is enabled.
+ **/
+bool e1000e_enable_tx_pkt_filtering(struct e1000_hw *hw)
+{
+	struct e1000_host_mng_dhcp_cookie *hdr = &hw->mng_cookie;
+	u32 *buffer = (u32 *)&hw->mng_cookie;
+	u32 offset;
+	s32 ret_val, hdr_csum, csum;
+	u8 i, len;
+
+	hw->mac.tx_pkt_filtering = true;
+
+	/* No manageability, no filtering */
+	if (!e1000e_check_mng_mode(hw)) {
+		hw->mac.tx_pkt_filtering = false;
+		goto out;
+	}
+
+	/*
+	 * If we can't read from the host interface for whatever
+	 * reason, disable filtering.
+	 */
+	ret_val = e1000_mng_enable_host_if(hw);
+	if (ret_val) {
+		hw->mac.tx_pkt_filtering = false;
+		goto out;
+	}
+
+	/* Read in the header.  Length and offset are in dwords. */
+	len = E1000_MNG_DHCP_COOKIE_LENGTH >> 2;
+	offset = E1000_MNG_DHCP_COOKIE_OFFSET >> 2;
+	for (i = 0; i < len; i++)
+		*(buffer + i) = E1000_READ_REG_ARRAY(hw, E1000_HOST_IF,
+						     offset + i);
+	hdr_csum = hdr->checksum;
+	hdr->checksum = 0;
+	csum = e1000_calculate_checksum((u8 *)hdr,
+					E1000_MNG_DHCP_COOKIE_LENGTH);
+	/*
+	 * If either the checksums or signature don't match, then
+	 * the cookie area isn't considered valid, in which case we
+	 * take the safe route of assuming Tx filtering is enabled.
+	 */
+	if ((hdr_csum != csum) || (hdr->signature != E1000_IAMT_SIGNATURE)) {
+		hw->mac.tx_pkt_filtering = true;
+		goto out;
+	}
+
+	/* Cookie area is valid, make the final check for filtering. */
+	if (!(hdr->status & E1000_MNG_DHCP_COOKIE_STATUS_PARSING)) {
+		hw->mac.tx_pkt_filtering = false;
+		goto out;
+	}
+
+out:
+	return hw->mac.tx_pkt_filtering;
+}
+
+/**
+ *  e1000_mng_write_cmd_header - Writes manageability command header
+ *  @hw: pointer to the HW structure
+ *  @hdr: pointer to the host interface command header
+ *
+ *  Writes the command header after does the checksum calculation.
+ **/
+static s32 e1000_mng_write_cmd_header(struct e1000_hw *hw,
+				      struct e1000_host_mng_command_header *hdr)
+{
+	u16 i, length = sizeof(struct e1000_host_mng_command_header);
+
+	/* Write the whole command header structure with new checksum. */
+
+	hdr->checksum = e1000_calculate_checksum((u8 *)hdr, length);
+
+	length >>= 2;
+	/* Write the relevant command block into the ram area. */
+	for (i = 0; i < length; i++) {
+		E1000_WRITE_REG_ARRAY(hw, E1000_HOST_IF, i, *((u32 *)hdr + i));
+		e1e_flush();
+	}
+
+	return 0;
+}
+
+/**
+ *  e1000_mng_host_if_write - Write to the manageability host interface
+ *  @hw: pointer to the HW structure
+ *  @buffer: pointer to the host interface buffer
+ *  @length: size of the buffer
+ *  @offset: location in the buffer to write to
+ *  @sum: sum of the data (not checksum)
+ *
+ *  This function writes the buffer content at the offset given on the host if.
+ *  It also does alignment considerations to do the writes in most efficient
+ *  way.  Also fills up the sum of the buffer in *buffer parameter.
+ **/
+static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer,
+				   u16 length, u16 offset, u8 *sum)
+{
+	u8 *tmp;
+	u8 *bufptr = buffer;
+	u32 data = 0;
+	u16 remaining, i, j, prev_bytes;
+
+	/* sum = only sum of the data and it is not checksum */
+
+	if (length == 0 || offset + length > E1000_HI_MAX_MNG_DATA_LENGTH)
+		return -E1000_ERR_PARAM;
+
+	tmp = (u8 *)&data;
+	prev_bytes = offset & 0x3;
+	offset >>= 2;
+
+	if (prev_bytes) {
+		data = E1000_READ_REG_ARRAY(hw, E1000_HOST_IF, offset);
+		for (j = prev_bytes; j < sizeof(u32); j++) {
+			*(tmp + j) = *bufptr++;
+			*sum += *(tmp + j);
+		}
+		E1000_WRITE_REG_ARRAY(hw, E1000_HOST_IF, offset, data);
+		length -= j - prev_bytes;
+		offset++;
+	}
+
+	remaining = length & 0x3;
+	length -= remaining;
+
+	/* Calculate length in DWORDs */
+	length >>= 2;
+
+	/*
+	 * The device driver writes the relevant command block into the
+	 * ram area.
+	 */
+	for (i = 0; i < length; i++) {
+		for (j = 0; j < sizeof(u32); j++) {
+			*(tmp + j) = *bufptr++;
+			*sum += *(tmp + j);
+		}
+
+		E1000_WRITE_REG_ARRAY(hw, E1000_HOST_IF, offset + i, data);
+	}
+	if (remaining) {
+		for (j = 0; j < sizeof(u32); j++) {
+			if (j < remaining)
+				*(tmp + j) = *bufptr++;
+			else
+				*(tmp + j) = 0;
+
+			*sum += *(tmp + j);
+		}
+		E1000_WRITE_REG_ARRAY(hw, E1000_HOST_IF, offset + i, data);
+	}
+
+	return 0;
+}
+
+/**
+ *  e1000e_mng_write_dhcp_info - Writes DHCP info to host interface
+ *  @hw: pointer to the HW structure
+ *  @buffer: pointer to the host interface
+ *  @length: size of the buffer
+ *
+ *  Writes the DHCP information to the host interface.
+ **/
+s32 e1000e_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer, u16 length)
+{
+	struct e1000_host_mng_command_header hdr;
+	s32 ret_val;
+	u32 hicr;
+
+	hdr.command_id = E1000_MNG_DHCP_TX_PAYLOAD_CMD;
+	hdr.command_length = length;
+	hdr.reserved1 = 0;
+	hdr.reserved2 = 0;
+	hdr.checksum = 0;
+
+	/* Enable the host interface */
+	ret_val = e1000_mng_enable_host_if(hw);
+	if (ret_val)
+		return ret_val;
+
+	/* Populate the host interface with the contents of "buffer". */
+	ret_val = e1000_mng_host_if_write(hw, buffer, length,
+					  sizeof(hdr), &(hdr.checksum));
+	if (ret_val)
+		return ret_val;
+
+	/* Write the manageability command header */
+	ret_val = e1000_mng_write_cmd_header(hw, &hdr);
+	if (ret_val)
+		return ret_val;
+
+	/* Tell the ARC a new command is pending. */
+	hicr = er32(HICR);
+	ew32(HICR, hicr | E1000_HICR_C);
+
+	return 0;
+}
+
+/**
+ *  e1000e_enable_mng_pass_thru - Check if management passthrough is needed
+ *  @hw: pointer to the HW structure
+ *
+ *  Verifies the hardware needs to leave interface enabled so that frames can
+ *  be directed to and from the management interface.
+ **/
+bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw)
+{
+	u32 manc;
+	u32 fwsm, factps;
+	bool ret_val = false;
+
+	manc = er32(MANC);
+
+	if (!(manc & E1000_MANC_RCV_TCO_EN))
+		goto out;
+
+	if (hw->mac.has_fwsm) {
+		fwsm = er32(FWSM);
+		factps = er32(FACTPS);
+
+		if (!(factps & E1000_FACTPS_MNGCG) &&
+		    ((fwsm & E1000_FWSM_MODE_MASK) ==
+		     (e1000_mng_mode_pt << E1000_FWSM_MODE_SHIFT))) {
+			ret_val = true;
+			goto out;
+		}
+	} else if ((hw->mac.type == e1000_82574) ||
+		   (hw->mac.type == e1000_82583)) {
+		u16 data;
+
+		factps = er32(FACTPS);
+		e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &data);
+
+		if (!(factps & E1000_FACTPS_MNGCG) &&
+		    ((data & E1000_NVM_INIT_CTRL2_MNGM) ==
+		     (e1000_mng_mode_pt << 13))) {
+			ret_val = true;
+			goto out;
+		}
+	} else if ((manc & E1000_MANC_SMBUS_EN) &&
+		   !(manc & E1000_MANC_ASF_EN)) {
+		ret_val = true;
+		goto out;
+	}
+
+out:
+	return ret_val;
+}
diff --git a/drivers/net/ethernet/intel/e1000e/nvm.c b/drivers/net/ethernet/intel/e1000e/nvm.c
new file mode 100644
index 0000000..dbdaa00
--- /dev/null
+++ b/drivers/net/ethernet/intel/e1000e/nvm.c
@@ -0,0 +1,647 @@
+/*******************************************************************************
+
+  Intel PRO/1000 Linux driver
+  Copyright(c) 1999 - 2011 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "e1000.h"
+
+/**
+ *  e1000_raise_eec_clk - Raise EEPROM clock
+ *  @hw: pointer to the HW structure
+ *  @eecd: pointer to the EEPROM
+ *
+ *  Enable/Raise the EEPROM clock bit.
+ **/
+static void e1000_raise_eec_clk(struct e1000_hw *hw, u32 *eecd)
+{
+	*eecd = *eecd | E1000_EECD_SK;
+	ew32(EECD, *eecd);
+	e1e_flush();
+	udelay(hw->nvm.delay_usec);
+}
+
+/**
+ *  e1000_lower_eec_clk - Lower EEPROM clock
+ *  @hw: pointer to the HW structure
+ *  @eecd: pointer to the EEPROM
+ *
+ *  Clear/Lower the EEPROM clock bit.
+ **/
+static void e1000_lower_eec_clk(struct e1000_hw *hw, u32 *eecd)
+{
+	*eecd = *eecd & ~E1000_EECD_SK;
+	ew32(EECD, *eecd);
+	e1e_flush();
+	udelay(hw->nvm.delay_usec);
+}
+
+/**
+ *  e1000_shift_out_eec_bits - Shift data bits our to the EEPROM
+ *  @hw: pointer to the HW structure
+ *  @data: data to send to the EEPROM
+ *  @count: number of bits to shift out
+ *
+ *  We need to shift 'count' bits out to the EEPROM.  So, the value in the
+ *  "data" parameter will be shifted out to the EEPROM one bit at a time.
+ *  In order to do this, "data" must be broken down into bits.
+ **/
+static void e1000_shift_out_eec_bits(struct e1000_hw *hw, u16 data, u16 count)
+{
+	struct e1000_nvm_info *nvm = &hw->nvm;
+	u32 eecd = er32(EECD);
+	u32 mask;
+
+	mask = 0x01 << (count - 1);
+	if (nvm->type == e1000_nvm_eeprom_spi)
+		eecd |= E1000_EECD_DO;
+
+	do {
+		eecd &= ~E1000_EECD_DI;
+
+		if (data & mask)
+			eecd |= E1000_EECD_DI;
+
+		ew32(EECD, eecd);
+		e1e_flush();
+
+		udelay(nvm->delay_usec);
+
+		e1000_raise_eec_clk(hw, &eecd);
+		e1000_lower_eec_clk(hw, &eecd);
+
+		mask >>= 1;
+	} while (mask);
+
+	eecd &= ~E1000_EECD_DI;
+	ew32(EECD, eecd);
+}
+
+/**
+ *  e1000_shift_in_eec_bits - Shift data bits in from the EEPROM
+ *  @hw: pointer to the HW structure
+ *  @count: number of bits to shift in
+ *
+ *  In order to read a register from the EEPROM, we need to shift 'count' bits
+ *  in from the EEPROM.  Bits are "shifted in" by raising the clock input to
+ *  the EEPROM (setting the SK bit), and then reading the value of the data out
+ *  "DO" bit.  During this "shifting in" process the data in "DI" bit should
+ *  always be clear.
+ **/
+static u16 e1000_shift_in_eec_bits(struct e1000_hw *hw, u16 count)
+{
+	u32 eecd;
+	u32 i;
+	u16 data;
+
+	eecd = er32(EECD);
+
+	eecd &= ~(E1000_EECD_DO | E1000_EECD_DI);
+	data = 0;
+
+	for (i = 0; i < count; i++) {
+		data <<= 1;
+		e1000_raise_eec_clk(hw, &eecd);
+
+		eecd = er32(EECD);
+
+		eecd &= ~E1000_EECD_DI;
+		if (eecd & E1000_EECD_DO)
+			data |= 1;
+
+		e1000_lower_eec_clk(hw, &eecd);
+	}
+
+	return data;
+}
+
+/**
+ *  e1000e_poll_eerd_eewr_done - Poll for EEPROM read/write completion
+ *  @hw: pointer to the HW structure
+ *  @ee_reg: EEPROM flag for polling
+ *
+ *  Polls the EEPROM status bit for either read or write completion based
+ *  upon the value of 'ee_reg'.
+ **/
+s32 e1000e_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg)
+{
+	u32 attempts = 100000;
+	u32 i, reg = 0;
+
+	for (i = 0; i < attempts; i++) {
+		if (ee_reg == E1000_NVM_POLL_READ)
+			reg = er32(EERD);
+		else
+			reg = er32(EEWR);
+
+		if (reg & E1000_NVM_RW_REG_DONE)
+			return 0;
+
+		udelay(5);
+	}
+
+	return -E1000_ERR_NVM;
+}
+
+/**
+ *  e1000e_acquire_nvm - Generic request for access to EEPROM
+ *  @hw: pointer to the HW structure
+ *
+ *  Set the EEPROM access request bit and wait for EEPROM access grant bit.
+ *  Return successful if access grant bit set, else clear the request for
+ *  EEPROM access and return -E1000_ERR_NVM (-1).
+ **/
+s32 e1000e_acquire_nvm(struct e1000_hw *hw)
+{
+	u32 eecd = er32(EECD);
+	s32 timeout = E1000_NVM_GRANT_ATTEMPTS;
+
+	ew32(EECD, eecd | E1000_EECD_REQ);
+	eecd = er32(EECD);
+
+	while (timeout) {
+		if (eecd & E1000_EECD_GNT)
+			break;
+		udelay(5);
+		eecd = er32(EECD);
+		timeout--;
+	}
+
+	if (!timeout) {
+		eecd &= ~E1000_EECD_REQ;
+		ew32(EECD, eecd);
+		e_dbg("Could not acquire NVM grant\n");
+		return -E1000_ERR_NVM;
+	}
+
+	return 0;
+}
+
+/**
+ *  e1000_standby_nvm - Return EEPROM to standby state
+ *  @hw: pointer to the HW structure
+ *
+ *  Return the EEPROM to a standby state.
+ **/
+static void e1000_standby_nvm(struct e1000_hw *hw)
+{
+	struct e1000_nvm_info *nvm = &hw->nvm;
+	u32 eecd = er32(EECD);
+
+	if (nvm->type == e1000_nvm_eeprom_spi) {
+		/* Toggle CS to flush commands */
+		eecd |= E1000_EECD_CS;
+		ew32(EECD, eecd);
+		e1e_flush();
+		udelay(nvm->delay_usec);
+		eecd &= ~E1000_EECD_CS;
+		ew32(EECD, eecd);
+		e1e_flush();
+		udelay(nvm->delay_usec);
+	}
+}
+
+/**
+ *  e1000_stop_nvm - Terminate EEPROM command
+ *  @hw: pointer to the HW structure
+ *
+ *  Terminates the current command by inverting the EEPROM's chip select pin.
+ **/
+static void e1000_stop_nvm(struct e1000_hw *hw)
+{
+	u32 eecd;
+
+	eecd = er32(EECD);
+	if (hw->nvm.type == e1000_nvm_eeprom_spi) {
+		/* Pull CS high */
+		eecd |= E1000_EECD_CS;
+		e1000_lower_eec_clk(hw, &eecd);
+	}
+}
+
+/**
+ *  e1000e_release_nvm - Release exclusive access to EEPROM
+ *  @hw: pointer to the HW structure
+ *
+ *  Stop any current commands to the EEPROM and clear the EEPROM request bit.
+ **/
+void e1000e_release_nvm(struct e1000_hw *hw)
+{
+	u32 eecd;
+
+	e1000_stop_nvm(hw);
+
+	eecd = er32(EECD);
+	eecd &= ~E1000_EECD_REQ;
+	ew32(EECD, eecd);
+}
+
+/**
+ *  e1000_ready_nvm_eeprom - Prepares EEPROM for read/write
+ *  @hw: pointer to the HW structure
+ *
+ *  Setups the EEPROM for reading and writing.
+ **/
+static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
+{
+	struct e1000_nvm_info *nvm = &hw->nvm;
+	u32 eecd = er32(EECD);
+	u8 spi_stat_reg;
+
+	if (nvm->type == e1000_nvm_eeprom_spi) {
+		u16 timeout = NVM_MAX_RETRY_SPI;
+
+		/* Clear SK and CS */
+		eecd &= ~(E1000_EECD_CS | E1000_EECD_SK);
+		ew32(EECD, eecd);
+		e1e_flush();
+		udelay(1);
+
+		/*
+		 * Read "Status Register" repeatedly until the LSB is cleared.
+		 * The EEPROM will signal that the command has been completed
+		 * by clearing bit 0 of the internal status register.  If it's
+		 * not cleared within 'timeout', then error out.
+		 */
+		while (timeout) {
+			e1000_shift_out_eec_bits(hw, NVM_RDSR_OPCODE_SPI,
+						 hw->nvm.opcode_bits);
+			spi_stat_reg = (u8)e1000_shift_in_eec_bits(hw, 8);
+			if (!(spi_stat_reg & NVM_STATUS_RDY_SPI))
+				break;
+
+			udelay(5);
+			e1000_standby_nvm(hw);
+			timeout--;
+		}
+
+		if (!timeout) {
+			e_dbg("SPI NVM Status error\n");
+			return -E1000_ERR_NVM;
+		}
+	}
+
+	return 0;
+}
+
+/**
+ *  e1000e_read_nvm_eerd - Reads EEPROM using EERD register
+ *  @hw: pointer to the HW structure
+ *  @offset: offset of word in the EEPROM to read
+ *  @words: number of words to read
+ *  @data: word read from the EEPROM
+ *
+ *  Reads a 16 bit word from the EEPROM using the EERD register.
+ **/
+s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+{
+	struct e1000_nvm_info *nvm = &hw->nvm;
+	u32 i, eerd = 0;
+	s32 ret_val = 0;
+
+	/*
+	 * A check for invalid values:  offset too large, too many words,
+	 * too many words for the offset, and not enough words.
+	 */
+	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
+	    (words == 0)) {
+		e_dbg("nvm parameter(s) out of bounds\n");
+		return -E1000_ERR_NVM;
+	}
+
+	for (i = 0; i < words; i++) {
+		eerd = ((offset + i) << E1000_NVM_RW_ADDR_SHIFT) +
+		    E1000_NVM_RW_REG_START;
+
+		ew32(EERD, eerd);
+		ret_val = e1000e_poll_eerd_eewr_done(hw, E1000_NVM_POLL_READ);
+		if (ret_val)
+			break;
+
+		data[i] = (er32(EERD) >> E1000_NVM_RW_REG_DATA);
+	}
+
+	return ret_val;
+}
+
+/**
+ *  e1000e_write_nvm_spi - Write to EEPROM using SPI
+ *  @hw: pointer to the HW structure
+ *  @offset: offset within the EEPROM to be written to
+ *  @words: number of words to write
+ *  @data: 16 bit word(s) to be written to the EEPROM
+ *
+ *  Writes data to EEPROM at offset using SPI interface.
+ *
+ *  If e1000e_update_nvm_checksum is not called after this function , the
+ *  EEPROM will most likely contain an invalid checksum.
+ **/
+s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+{
+	struct e1000_nvm_info *nvm = &hw->nvm;
+	s32 ret_val;
+	u16 widx = 0;
+
+	/*
+	 * A check for invalid values:  offset too large, too many words,
+	 * and not enough words.
+	 */
+	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
+	    (words == 0)) {
+		e_dbg("nvm parameter(s) out of bounds\n");
+		return -E1000_ERR_NVM;
+	}
+
+	ret_val = nvm->ops.acquire(hw);
+	if (ret_val)
+		return ret_val;
+
+	while (widx < words) {
+		u8 write_opcode = NVM_WRITE_OPCODE_SPI;
+
+		ret_val = e1000_ready_nvm_eeprom(hw);
+		if (ret_val) {
+			nvm->ops.release(hw);
+			return ret_val;
+		}
+
+		e1000_standby_nvm(hw);
+
+		/* Send the WRITE ENABLE command (8 bit opcode) */
+		e1000_shift_out_eec_bits(hw, NVM_WREN_OPCODE_SPI,
+					 nvm->opcode_bits);
+
+		e1000_standby_nvm(hw);
+
+		/*
+		 * Some SPI eeproms use the 8th address bit embedded in the
+		 * opcode
+		 */
+		if ((nvm->address_bits == 8) && (offset >= 128))
+			write_opcode |= NVM_A8_OPCODE_SPI;
+
+		/* Send the Write command (8-bit opcode + addr) */
+		e1000_shift_out_eec_bits(hw, write_opcode, nvm->opcode_bits);
+		e1000_shift_out_eec_bits(hw, (u16)((offset + widx) * 2),
+					 nvm->address_bits);
+
+		/* Loop to allow for up to whole page write of eeprom */
+		while (widx < words) {
+			u16 word_out = data[widx];
+			word_out = (word_out >> 8) | (word_out << 8);
+			e1000_shift_out_eec_bits(hw, word_out, 16);
+			widx++;
+
+			if ((((offset + widx) * 2) % nvm->page_size) == 0) {
+				e1000_standby_nvm(hw);
+				break;
+			}
+		}
+	}
+
+	usleep_range(10000, 20000);
+	nvm->ops.release(hw);
+	return 0;
+}
+
+/**
+ *  e1000_read_pba_string_generic - Read device part number
+ *  @hw: pointer to the HW structure
+ *  @pba_num: pointer to device part number
+ *  @pba_num_size: size of part number buffer
+ *
+ *  Reads the product board assembly (PBA) number from the EEPROM and stores
+ *  the value in pba_num.
+ **/
+s32 e1000_read_pba_string_generic(struct e1000_hw *hw, u8 *pba_num,
+				  u32 pba_num_size)
+{
+	s32 ret_val;
+	u16 nvm_data;
+	u16 pba_ptr;
+	u16 offset;
+	u16 length;
+
+	if (pba_num == NULL) {
+		e_dbg("PBA string buffer was null\n");
+		ret_val = E1000_ERR_INVALID_ARGUMENT;
+		goto out;
+	}
+
+	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
+	if (ret_val) {
+		e_dbg("NVM Read Error\n");
+		goto out;
+	}
+
+	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_1, 1, &pba_ptr);
+	if (ret_val) {
+		e_dbg("NVM Read Error\n");
+		goto out;
+	}
+
+	/*
+	 * if nvm_data is not ptr guard the PBA must be in legacy format which
+	 * means pba_ptr is actually our second data word for the PBA number
+	 * and we can decode it into an ascii string
+	 */
+	if (nvm_data != NVM_PBA_PTR_GUARD) {
+		e_dbg("NVM PBA number is not stored as string\n");
+
+		/* we will need 11 characters to store the PBA */
+		if (pba_num_size < 11) {
+			e_dbg("PBA string buffer too small\n");
+			return E1000_ERR_NO_SPACE;
+		}
+
+		/* extract hex string from data and pba_ptr */
+		pba_num[0] = (nvm_data >> 12) & 0xF;
+		pba_num[1] = (nvm_data >> 8) & 0xF;
+		pba_num[2] = (nvm_data >> 4) & 0xF;
+		pba_num[3] = nvm_data & 0xF;
+		pba_num[4] = (pba_ptr >> 12) & 0xF;
+		pba_num[5] = (pba_ptr >> 8) & 0xF;
+		pba_num[6] = '-';
+		pba_num[7] = 0;
+		pba_num[8] = (pba_ptr >> 4) & 0xF;
+		pba_num[9] = pba_ptr & 0xF;
+
+		/* put a null character on the end of our string */
+		pba_num[10] = '\0';
+
+		/* switch all the data but the '-' to hex char */
+		for (offset = 0; offset < 10; offset++) {
+			if (pba_num[offset] < 0xA)
+				pba_num[offset] += '0';
+			else if (pba_num[offset] < 0x10)
+				pba_num[offset] += 'A' - 0xA;
+		}
+
+		goto out;
+	}
+
+	ret_val = e1000_read_nvm(hw, pba_ptr, 1, &length);
+	if (ret_val) {
+		e_dbg("NVM Read Error\n");
+		goto out;
+	}
+
+	if (length == 0xFFFF || length == 0) {
+		e_dbg("NVM PBA number section invalid length\n");
+		ret_val = E1000_ERR_NVM_PBA_SECTION;
+		goto out;
+	}
+	/* check if pba_num buffer is big enough */
+	if (pba_num_size < (((u32)length * 2) - 1)) {
+		e_dbg("PBA string buffer too small\n");
+		ret_val = E1000_ERR_NO_SPACE;
+		goto out;
+	}
+
+	/* trim pba length from start of string */
+	pba_ptr++;
+	length--;
+
+	for (offset = 0; offset < length; offset++) {
+		ret_val = e1000_read_nvm(hw, pba_ptr + offset, 1, &nvm_data);
+		if (ret_val) {
+			e_dbg("NVM Read Error\n");
+			goto out;
+		}
+		pba_num[offset * 2] = (u8)(nvm_data >> 8);
+		pba_num[(offset * 2) + 1] = (u8)(nvm_data & 0xFF);
+	}
+	pba_num[offset * 2] = '\0';
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_read_mac_addr_generic - Read device MAC address
+ *  @hw: pointer to the HW structure
+ *
+ *  Reads the device MAC address from the EEPROM and stores the value.
+ *  Since devices with two ports use the same EEPROM, we increment the
+ *  last bit in the MAC address for the second port.
+ **/
+s32 e1000_read_mac_addr_generic(struct e1000_hw *hw)
+{
+	u32 rar_high;
+	u32 rar_low;
+	u16 i;
+
+	rar_high = er32(RAH(0));
+	rar_low = er32(RAL(0));
+
+	for (i = 0; i < E1000_RAL_MAC_ADDR_LEN; i++)
+		hw->mac.perm_addr[i] = (u8)(rar_low >> (i * 8));
+
+	for (i = 0; i < E1000_RAH_MAC_ADDR_LEN; i++)
+		hw->mac.perm_addr[i + 4] = (u8)(rar_high >> (i * 8));
+
+	for (i = 0; i < ETH_ALEN; i++)
+		hw->mac.addr[i] = hw->mac.perm_addr[i];
+
+	return 0;
+}
+
+/**
+ *  e1000e_validate_nvm_checksum_generic - Validate EEPROM checksum
+ *  @hw: pointer to the HW structure
+ *
+ *  Calculates the EEPROM checksum by reading/adding each word of the EEPROM
+ *  and then verifies that the sum of the EEPROM is equal to 0xBABA.
+ **/
+s32 e1000e_validate_nvm_checksum_generic(struct e1000_hw *hw)
+{
+	s32 ret_val;
+	u16 checksum = 0;
+	u16 i, nvm_data;
+
+	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
+		ret_val = e1000_read_nvm(hw, i, 1, &nvm_data);
+		if (ret_val) {
+			e_dbg("NVM Read Error\n");
+			return ret_val;
+		}
+		checksum += nvm_data;
+	}
+
+	if (checksum != (u16)NVM_SUM) {
+		e_dbg("NVM Checksum Invalid\n");
+		return -E1000_ERR_NVM;
+	}
+
+	return 0;
+}
+
+/**
+ *  e1000e_update_nvm_checksum_generic - Update EEPROM checksum
+ *  @hw: pointer to the HW structure
+ *
+ *  Updates the EEPROM checksum by reading/adding each word of the EEPROM
+ *  up to the checksum.  Then calculates the EEPROM checksum and writes the
+ *  value to the EEPROM.
+ **/
+s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw)
+{
+	s32 ret_val;
+	u16 checksum = 0;
+	u16 i, nvm_data;
+
+	for (i = 0; i < NVM_CHECKSUM_REG; i++) {
+		ret_val = e1000_read_nvm(hw, i, 1, &nvm_data);
+		if (ret_val) {
+			e_dbg("NVM Read Error while updating checksum.\n");
+			return ret_val;
+		}
+		checksum += nvm_data;
+	}
+	checksum = (u16)NVM_SUM - checksum;
+	ret_val = e1000_write_nvm(hw, NVM_CHECKSUM_REG, 1, &checksum);
+	if (ret_val)
+		e_dbg("NVM Write Error while updating checksum.\n");
+
+	return ret_val;
+}
+
+/**
+ *  e1000e_reload_nvm - Reloads EEPROM
+ *  @hw: pointer to the HW structure
+ *
+ *  Reloads the EEPROM by setting the "Reinitialize from EEPROM" bit in the
+ *  extended control register.
+ **/
+void e1000e_reload_nvm(struct e1000_hw *hw)
+{
+	u32 ctrl_ext;
+
+	udelay(10);
+	ctrl_ext = er32(CTRL_EXT);
+	ctrl_ext |= E1000_CTRL_EXT_EE_RST;
+	ew32(CTRL_EXT, ctrl_ext);
+	e1e_flush();
+}
-- 
1.7.7.6
