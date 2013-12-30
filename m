From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] igb: cleanups
Date: Mon, 30 Dec 2013 10:36:48 -0800
Message-ID: <20131230103648.5ac53b4f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36629 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755867Ab3L3Sgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 13:36:52 -0500
Received: by mail-pa0-f45.google.com with SMTP id fb1so11884975pad.18
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 10:36:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is against current version in net-next, some of this may not
apply after other patches you have pending.

Make local functions static.

Delete unused code (igb_get_eee_status_i354, e1000_write_sfp_data_byte)

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org> 


---
 drivers/net/ethernet/intel/igb/e1000_82575.c |   37 --------------
 drivers/net/ethernet/intel/igb/e1000_82575.h |    2 
 drivers/net/ethernet/intel/igb/e1000_i210.c  |   20 ++++---
 drivers/net/ethernet/intel/igb/e1000_i210.h  |    9 ---
 drivers/net/ethernet/intel/igb/e1000_phy.c   |   71 ---------------------------
 drivers/net/ethernet/intel/igb/e1000_phy.h   |    1 
 drivers/net/ethernet/intel/igb/igb.h         |    2 
 drivers/net/ethernet/intel/igb/igb_ptp.c     |    6 +-
 8 files changed, 17 insertions(+), 131 deletions(-)

--- a/drivers/net/ethernet/intel/igb/e1000_82575.c	2013-12-12 12:13:19.742490331 -0800
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c	2013-12-30 10:21:33.445517450 -0800
@@ -2668,39 +2668,6 @@ s32 igb_set_eee_i354(struct e1000_hw *hw
 out:
 	return ret_val;
 }
-
-/**
- *  igb_get_eee_status_i354 - Get EEE status
- *  @hw: pointer to the HW structure
- *  @status: EEE status
- *
- *  Get EEE status by guessing based on whether Tx or Rx LPI indications have
- *  been received.
- **/
-s32 igb_get_eee_status_i354(struct e1000_hw *hw, bool *status)
-{
-	struct e1000_phy_info *phy = &hw->phy;
-	s32 ret_val = 0;
-	u16 phy_data;
-
-	/* Check if EEE is supported on this device. */
-	if ((hw->phy.media_type != e1000_media_type_copper) ||
-	    (phy->id != M88E1543_E_PHY_ID))
-		goto out;
-
-	ret_val = igb_read_xmdio_reg(hw, E1000_PCS_STATUS_ADDR_I354,
-				     E1000_PCS_STATUS_DEV_I354,
-				     &phy_data);
-	if (ret_val)
-		goto out;
-
-	*status = phy_data & (E1000_PCS_STATUS_TX_LPI_RCVD |
-			      E1000_PCS_STATUS_RX_LPI_RCVD) ? true : false;
-
-out:
-	return ret_val;
-}
-
 static const u8 e1000_emc_temp_data[4] = {
 	E1000_EMC_INTERNAL_DATA,
 	E1000_EMC_DIODE1_DATA,
@@ -2720,7 +2687,7 @@ static const u8 e1000_emc_therm_limit[4]
  *
  *  Updates the temperatures in mac.thermal_sensor_data
  **/
-s32 igb_get_thermal_sensor_data_generic(struct e1000_hw *hw)
+static s32 igb_get_thermal_sensor_data_generic(struct e1000_hw *hw)
 {
 	s32 status = E1000_SUCCESS;
 	u16 ets_offset;
@@ -2774,7 +2741,7 @@ s32 igb_get_thermal_sensor_data_generic(
  *  Sets the thermal sensor thresholds according to the NVM map
  *  and save off the threshold and location values into mac.thermal_sensor_data
  **/
-s32 igb_init_thermal_sensor_thresh_generic(struct e1000_hw *hw)
+static s32 igb_init_thermal_sensor_thresh_generic(struct e1000_hw *hw)
 {
 	s32 status = E1000_SUCCESS;
 	u16 ets_offset;
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c	2013-12-12 12:13:19.742490331 -0800
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c	2013-12-30 10:31:22.002682203 -0800
@@ -35,6 +35,8 @@
 #include "e1000_hw.h"
 #include "e1000_i210.h"
 
+static s32 igb_update_flash_i210(struct e1000_hw *hw);
+
 /**
  * igb_get_hw_semaphore_i210 - Acquire hardware semaphore
  *  @hw: pointer to the HW structure
@@ -111,7 +113,7 @@ static s32 igb_get_hw_semaphore_i210(str
  *  Return successful if access grant bit set, else clear the request for
  *  EEPROM access and return -E1000_ERR_NVM (-1).
  **/
-s32 igb_acquire_nvm_i210(struct e1000_hw *hw)
+static s32 igb_acquire_nvm_i210(struct e1000_hw *hw)
 {
 	return igb_acquire_swfw_sync_i210(hw, E1000_SWFW_EEP_SM);
 }
@@ -123,7 +125,7 @@ s32 igb_acquire_nvm_i210(struct e1000_hw
  *  Stop any current commands to the EEPROM and clear the EEPROM request bit,
  *  then release the semaphores acquired.
  **/
-void igb_release_nvm_i210(struct e1000_hw *hw)
+static void igb_release_nvm_i210(struct e1000_hw *hw)
 {
 	igb_release_swfw_sync_i210(hw, E1000_SWFW_EEP_SM);
 }
@@ -206,8 +208,8 @@ void igb_release_swfw_sync_i210(struct e
  *  Reads a 16 bit word from the Shadow Ram using the EERD register.
  *  Uses necessary synchronization semaphores.
  **/
-s32 igb_read_nvm_srrd_i210(struct e1000_hw *hw, u16 offset, u16 words,
-			     u16 *data)
+static s32 igb_read_nvm_srrd_i210(struct e1000_hw *hw, u16 offset, u16 words,
+				  u16 *data)
 {
 	s32 status = E1000_SUCCESS;
 	u16 i, count;
@@ -306,8 +308,8 @@ out:
  *  If error code is returned, data and Shadow RAM may be inconsistent - buffer
  *  partially written.
  **/
-s32 igb_write_nvm_srwr_i210(struct e1000_hw *hw, u16 offset, u16 words,
-			      u16 *data)
+static s32 igb_write_nvm_srwr_i210(struct e1000_hw *hw, u16 offset, u16 words,
+				   u16 *data)
 {
 	s32 status = E1000_SUCCESS;
 	u16 i, count;
@@ -555,7 +557,7 @@ s32 igb_read_invm_version(struct e1000_h
  *  Calculates the EEPROM checksum by reading/adding each word of the EEPROM
  *  and then verifies that the sum of the EEPROM is equal to 0xBABA.
  **/
-s32 igb_validate_nvm_checksum_i210(struct e1000_hw *hw)
+static s32 igb_validate_nvm_checksum_i210(struct e1000_hw *hw)
 {
 	s32 status = E1000_SUCCESS;
 	s32 (*read_op_ptr)(struct e1000_hw *, u16, u16, u16 *);
@@ -590,7 +592,7 @@ s32 igb_validate_nvm_checksum_i210(struc
  *  up to the checksum.  Then calculates the EEPROM checksum and writes the
  *  value to the EEPROM. Next commit EEPROM data onto the Flash.
  **/
-s32 igb_update_nvm_checksum_i210(struct e1000_hw *hw)
+static s32 igb_update_nvm_checksum_i210(struct e1000_hw *hw)
 {
 	s32 ret_val = E1000_SUCCESS;
 	u16 checksum = 0;
@@ -684,7 +686,7 @@ bool igb_get_flash_presence_i210(struct
  *  @hw: pointer to the HW structure
  *
  **/
-s32 igb_update_flash_i210(struct e1000_hw *hw)
+static s32 igb_update_flash_i210(struct e1000_hw *hw)
 {
 	s32 ret_val = E1000_SUCCESS;
 	u32 flup;
--- a/drivers/net/ethernet/intel/igb/e1000_i210.h	2013-12-12 12:13:19.742490331 -0800
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.h	2013-12-30 10:31:24.730650282 -0800
@@ -28,17 +28,8 @@
 #ifndef _E1000_I210_H_
 #define _E1000_I210_H_
 
-s32 igb_update_flash_i210(struct e1000_hw *hw);
-s32 igb_update_nvm_checksum_i210(struct e1000_hw *hw);
-s32 igb_validate_nvm_checksum_i210(struct e1000_hw *hw);
-s32 igb_write_nvm_srwr_i210(struct e1000_hw *hw, u16 offset, u16 words,
-			    u16 *data);
-s32 igb_read_nvm_srrd_i210(struct e1000_hw *hw, u16 offset, u16 words,
-			   u16 *data);
 s32 igb_acquire_swfw_sync_i210(struct e1000_hw *hw, u16 mask);
 void igb_release_swfw_sync_i210(struct e1000_hw *hw, u16 mask);
-s32 igb_acquire_nvm_i210(struct e1000_hw *hw);
-void igb_release_nvm_i210(struct e1000_hw *hw);
 s32 igb_valid_led_default_i210(struct e1000_hw *hw, u16 *data);
 s32 igb_read_invm_version(struct e1000_hw *hw,
 			  struct e1000_fw_version *invm_ver);
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c	2013-12-20 07:59:47.420147779 -0800
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c	2013-12-30 10:26:17.258242143 -0800
@@ -394,77 +394,6 @@ s32 igb_read_sfp_data_byte(struct e1000_
 }
 
 /**
- *  e1000_write_sfp_data_byte - Writes SFP module data.
- *  @hw: pointer to the HW structure
- *  @offset: byte location offset to write to
- *  @data: data to write
- *
- *  Writes one byte to SFP module data stored
- *  in SFP resided EEPROM memory or SFP diagnostic area.
- *  Function should be called with
- *  E1000_I2CCMD_SFP_DATA_ADDR(<byte offset>) for SFP module database access
- *  E1000_I2CCMD_SFP_DIAG_ADDR(<byte offset>) for SFP diagnostics parameters
- *  access
- **/
-s32 e1000_write_sfp_data_byte(struct e1000_hw *hw, u16 offset, u8 data)
-{
-	u32 i = 0;
-	u32 i2ccmd = 0;
-	u32 data_local = 0;
-
-	if (offset > E1000_I2CCMD_SFP_DIAG_ADDR(255)) {
-		hw_dbg("I2CCMD command address exceeds upper limit\n");
-		return -E1000_ERR_PHY;
-	}
-	/* The programming interface is 16 bits wide
-	 * so we need to read the whole word first
-	 * then update appropriate byte lane and write
-	 * the updated word back.
-	 */
-	/* Set up Op-code, EEPROM Address,in the I2CCMD
-	 * register. The MAC will take care of interfacing
-	 * with an EEPROM to write the data given.
-	 */
-	i2ccmd = ((offset << E1000_I2CCMD_REG_ADDR_SHIFT) |
-		  E1000_I2CCMD_OPCODE_READ);
-	/* Set a command to read single word */
-	wr32(E1000_I2CCMD, i2ccmd);
-	for (i = 0; i < E1000_I2CCMD_PHY_TIMEOUT; i++) {
-		udelay(50);
-		/* Poll the ready bit to see if lastly
-		 * launched I2C operation completed
-		 */
-		i2ccmd = rd32(E1000_I2CCMD);
-		if (i2ccmd & E1000_I2CCMD_READY) {
-			/* Check if this is READ or WRITE phase */
-			if ((i2ccmd & E1000_I2CCMD_OPCODE_READ) ==
-			    E1000_I2CCMD_OPCODE_READ) {
-				/* Write the selected byte
-				 * lane and update whole word
-				 */
-				data_local = i2ccmd & 0xFF00;
-				data_local |= data;
-				i2ccmd = ((offset <<
-					E1000_I2CCMD_REG_ADDR_SHIFT) |
-					E1000_I2CCMD_OPCODE_WRITE | data_local);
-				wr32(E1000_I2CCMD, i2ccmd);
-			} else {
-				break;
-			}
-		}
-	}
-	if (!(i2ccmd & E1000_I2CCMD_READY)) {
-		hw_dbg("I2CCMD Write did not complete\n");
-		return -E1000_ERR_PHY;
-	}
-	if (i2ccmd & E1000_I2CCMD_ERROR) {
-		hw_dbg("I2CCMD Error bit set\n");
-		return -E1000_ERR_PHY;
-	}
-	return 0;
-}
-
-/**
  *  igb_read_phy_reg_igp - Read igp PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
--- a/drivers/net/ethernet/intel/igb/e1000_phy.h	2013-12-12 12:13:19.742490331 -0800
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.h	2013-12-30 10:26:08.610342990 -0800
@@ -70,7 +70,6 @@ s32  igb_write_phy_reg_mdic(struct e1000
 s32  igb_read_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 *data);
 s32  igb_write_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 data);
 s32  igb_read_sfp_data_byte(struct e1000_hw *hw, u16 offset, u8 *data);
-s32  e1000_write_sfp_data_byte(struct e1000_hw *hw, u16 offset, u8 data);
 s32  igb_copper_link_setup_82580(struct e1000_hw *hw);
 s32  igb_get_phy_info_82580(struct e1000_hw *hw);
 s32  igb_phy_force_speed_duplex_82580(struct e1000_hw *hw);
--- a/drivers/net/ethernet/intel/igb/igb.h	2013-12-18 13:18:29.633913381 -0800
+++ b/drivers/net/ethernet/intel/igb/igb.h	2013-12-30 10:27:41.289261708 -0800
@@ -525,9 +525,7 @@ void igb_set_fw_version(struct igb_adapt
 void igb_ptp_init(struct igb_adapter *adapter);
 void igb_ptp_stop(struct igb_adapter *adapter);
 void igb_ptp_reset(struct igb_adapter *adapter);
-void igb_ptp_tx_work(struct work_struct *work);
 void igb_ptp_rx_hang(struct igb_adapter *adapter);
-void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter);
 void igb_ptp_rx_rgtstamp(struct igb_q_vector *q_vector, struct sk_buff *skb);
 void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, unsigned char *va,
 			 struct sk_buff *skb);
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c	2013-12-12 12:13:19.742490331 -0800
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c	2013-12-30 10:27:48.809173924 -0800
@@ -23,6 +23,8 @@
 
 #include "igb.h"
 
+static void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter);
+
 #define INCVALUE_MASK		0x7fffffff
 #define ISGN			0x80000000
 
@@ -372,7 +374,7 @@ static int igb_ptp_enable(struct ptp_clo
  * This work function polls the TSYNCTXCTL valid bit to determine when a
  * timestamp has been taken for the current stored skb.
  **/
-void igb_ptp_tx_work(struct work_struct *work)
+static void igb_ptp_tx_work(struct work_struct *work)
 {
 	struct igb_adapter *adapter = container_of(work, struct igb_adapter,
 						   ptp_tx_work);
@@ -466,7 +468,7 @@ void igb_ptp_rx_hang(struct igb_adapter
  * available, then it must have been for this skb here because we only
  * allow only one such packet into the queue.
  **/
-void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter)
+static void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct skb_shared_hwtstamps shhwtstamps;
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h	2013-12-13 10:30:28.005645103 -0800
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h	2013-12-30 10:28:25.388746806 -0800
@@ -266,8 +266,6 @@ u16 igb_rxpbs_adjust_82580(u32 data);
 s32 igb_read_emi_reg(struct e1000_hw *, u16 addr, u16 *data);
 s32 igb_set_eee_i350(struct e1000_hw *);
 s32 igb_set_eee_i354(struct e1000_hw *);
-s32 igb_init_thermal_sensor_thresh_generic(struct e1000_hw *);
-s32 igb_get_thermal_sensor_data_generic(struct e1000_hw *hw);
 
 #define E1000_I2C_THERMAL_SENSOR_ADDR	0xF8
 #define E1000_EMC_INTERNAL_DATA		0x00
