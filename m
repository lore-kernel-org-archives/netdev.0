From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 02/13] e1000: remove unused functions
Date: Fri, 25 Sep 2009 15:16:39 -0700
Message-ID: <20090925221639.26715.42420.stgit@localhost.localdomain>
References: <20090925221613.26715.66796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:37494
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752654AbZIYWQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:16:56 -0400
In-Reply-To: <20090925221613.26715.66796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

after removal of pcie, need to remove some unnecessary functions

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_hw.c |  174 ------------------------------------------
 drivers/net/e1000/e1000_hw.h |    2 
 2 files changed, 2 insertions(+), 174 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 74aa599..765fd71 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -33,9 +33,6 @@
 
 #include "e1000_hw.h"
 
-static s32 e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask);
-static void e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask);
-
 static s32 e1000_check_downshift(struct e1000_hw *hw);
 static s32 e1000_check_polarity(struct e1000_hw *hw,
 				e1000_rev_polarity *polarity);
@@ -48,7 +45,6 @@ static s32 e1000_detect_gig_phy(struct e1000_hw *hw);
 static s32 e1000_get_auto_rd_done(struct e1000_hw *hw);
 static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length,
 				  u16 *max_length);
-static s32 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw);
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
 static s32 e1000_id_led_init(struct e1000_hw *hw);
 static void e1000_init_rx_addrs(struct e1000_hw *hw);
@@ -61,7 +57,6 @@ static s32 e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words,
 static s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
 static s32 e1000_phy_m88_get_info(struct e1000_hw *hw,
 				  struct e1000_phy_info *phy_info);
-static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw);
 static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
 static s32 e1000_wait_autoneg(struct e1000_hw *hw);
 static void e1000_write_reg_io(struct e1000_hw *hw, u32 offset, u32 value);
@@ -2607,70 +2602,6 @@ static u16 e1000_shift_in_mdi_bits(struct e1000_hw *hw)
     return data;
 }
 
-static s32 e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
-{
-    u32 swfw_sync = 0;
-    u32 swmask = mask;
-    u32 fwmask = mask << 16;
-    s32 timeout = 200;
-
-    DEBUGFUNC("e1000_swfw_sync_acquire");
-
-    if (!hw->swfw_sync_present)
-        return e1000_get_hw_eeprom_semaphore(hw);
-
-    while (timeout) {
-            if (e1000_get_hw_eeprom_semaphore(hw))
-                return -E1000_ERR_SWFW_SYNC;
-
-            swfw_sync = er32(SW_FW_SYNC);
-            if (!(swfw_sync & (fwmask | swmask))) {
-                break;
-            }
-
-            /* firmware currently using resource (fwmask) */
-            /* or other software thread currently using resource (swmask) */
-            e1000_put_hw_eeprom_semaphore(hw);
-            mdelay(5);
-            timeout--;
-    }
-
-    if (!timeout) {
-        DEBUGOUT("Driver can't access resource, SW_FW_SYNC timeout.\n");
-        return -E1000_ERR_SWFW_SYNC;
-    }
-
-    swfw_sync |= swmask;
-    ew32(SW_FW_SYNC, swfw_sync);
-
-    e1000_put_hw_eeprom_semaphore(hw);
-    return E1000_SUCCESS;
-}
-
-static void e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
-{
-    u32 swfw_sync;
-    u32 swmask = mask;
-
-    DEBUGFUNC("e1000_swfw_sync_release");
-
-    if (!hw->swfw_sync_present) {
-        e1000_put_hw_eeprom_semaphore(hw);
-        return;
-    }
-
-    /* if (e1000_get_hw_eeprom_semaphore(hw))
-     *    return -E1000_ERR_SWFW_SYNC; */
-    while (e1000_get_hw_eeprom_semaphore(hw) != E1000_SUCCESS);
-        /* empty */
-
-    swfw_sync = er32(SW_FW_SYNC);
-    swfw_sync &= ~swmask;
-    ew32(SW_FW_SYNC, swfw_sync);
-
-    e1000_put_hw_eeprom_semaphore(hw);
-}
-
 /*****************************************************************************
 * Reads the value from a PHY register, if the value is on a specific non zero
 * page, sets the page first.
@@ -2680,28 +2611,19 @@ static void e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
 s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data)
 {
     u32 ret_val;
-    u16 swfw;
 
     DEBUGFUNC("e1000_read_phy_reg");
 
-    swfw = E1000_SWFW_PHY0_SM;
-    if (e1000_swfw_sync_acquire(hw, swfw))
-        return -E1000_ERR_SWFW_SYNC;
-
     if ((hw->phy_type == e1000_phy_igp) &&
         (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
                                          (u16)reg_addr);
-        if (ret_val) {
-            e1000_swfw_sync_release(hw, swfw);
+        if (ret_val)
             return ret_val;
-        }
     }
 
     ret_val = e1000_read_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
                                     phy_data);
-
-    e1000_swfw_sync_release(hw, swfw);
     return ret_val;
 }
 
@@ -2787,28 +2709,20 @@ static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 phy_data)
 {
     u32 ret_val;
-    u16 swfw;
 
     DEBUGFUNC("e1000_write_phy_reg");
 
-    swfw = E1000_SWFW_PHY0_SM;
-    if (e1000_swfw_sync_acquire(hw, swfw))
-        return -E1000_ERR_SWFW_SYNC;
-
     if ((hw->phy_type == e1000_phy_igp) &&
         (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
                                          (u16)reg_addr);
-        if (ret_val) {
-            e1000_swfw_sync_release(hw, swfw);
+        if (ret_val)
             return ret_val;
-        }
     }
 
     ret_val = e1000_write_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
                                      phy_data);
 
-    e1000_swfw_sync_release(hw, swfw);
     return ret_val;
 }
 
@@ -2883,18 +2797,12 @@ s32 e1000_phy_hw_reset(struct e1000_hw *hw)
     u32 ctrl, ctrl_ext;
     u32 led_ctrl;
     s32 ret_val;
-    u16 swfw;
 
     DEBUGFUNC("e1000_phy_hw_reset");
 
     DEBUGOUT("Resetting Phy...\n");
 
     if (hw->mac_type > e1000_82543) {
-        swfw = E1000_SWFW_PHY0_SM;
-        if (e1000_swfw_sync_acquire(hw, swfw)) {
-            DEBUGOUT("Unable to acquire swfw sync\n");
-            return -E1000_ERR_SWFW_SYNC;
-        }
         /* Read the device control register and assert the E1000_CTRL_PHY_RST
          * bit. Then, take it out of reset.
          * For e1000 hardware, we delay for 10ms between the assert
@@ -2908,8 +2816,6 @@ s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 
         ew32(CTRL, ctrl);
         E1000_WRITE_FLUSH();
-
-        e1000_swfw_sync_release(hw, swfw);
     } else {
         /* Read the Extended Device Control Register, assert the PHY_RESET_DIR
          * bit to put the PHY into reset. Then, take it out of reset.
@@ -3515,8 +3421,6 @@ static s32 e1000_acquire_eeprom(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_acquire_eeprom");
 
-    if (e1000_swfw_sync_acquire(hw, E1000_SWFW_EEP_SM))
-        return -E1000_ERR_SWFW_SYNC;
     eecd = er32(EECD);
 
     /* Request EEPROM Access */
@@ -3534,7 +3438,6 @@ static s32 e1000_acquire_eeprom(struct e1000_hw *hw)
             eecd &= ~E1000_EECD_REQ;
             ew32(EECD, eecd);
             DEBUGOUT("Could not acquire EEPROM grant\n");
-            e1000_swfw_sync_release(hw, E1000_SWFW_EEP_SM);
             return -E1000_ERR_EEPROM;
         }
     }
@@ -3653,8 +3556,6 @@ static void e1000_release_eeprom(struct e1000_hw *hw)
         eecd &= ~E1000_EECD_REQ;
         ew32(EECD, eecd);
     }
-
-    e1000_swfw_sync_release(hw, E1000_SWFW_EEP_SM);
 }
 
 /******************************************************************************
@@ -3847,8 +3748,6 @@ static s32 e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words,
     u32    i              = 0;
     s32     error          = 0;
 
-    if (e1000_swfw_sync_acquire(hw, E1000_SWFW_EEP_SM))
-        return -E1000_ERR_SWFW_SYNC;
 
     for (i = 0; i < words; i++) {
         register_value = (data[i] << E1000_EEPROM_RW_REG_DATA) |
@@ -3869,7 +3768,6 @@ static s32 e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words,
         }
     }
 
-    e1000_swfw_sync_release(hw, E1000_SWFW_EEP_SM);
     return error;
 }
 
@@ -5681,71 +5579,3 @@ static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw)
     mdelay(10);
     return E1000_SUCCESS;
 }
-
-/***************************************************************************
- *
- * Using the combination of SMBI and SWESMBI semaphore bits when resetting
- * adapter or Eeprom access.
- *
- * hw: Struct containing variables accessed by shared code
- *
- * returns: - E1000_ERR_EEPROM if fail to access EEPROM.
- *            E1000_SUCCESS at any other case.
- *
- ***************************************************************************/
-static s32 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw)
-{
-    s32 timeout;
-    u32 swsm;
-
-    DEBUGFUNC("e1000_get_hw_eeprom_semaphore");
-
-    if (!hw->eeprom_semaphore_present)
-        return E1000_SUCCESS;
-
-    /* Get the FW semaphore. */
-    timeout = hw->eeprom.word_size + 1;
-    while (timeout) {
-        swsm = er32(SWSM);
-        swsm |= E1000_SWSM_SWESMBI;
-        ew32(SWSM, swsm);
-        /* if we managed to set the bit we got the semaphore. */
-        swsm = er32(SWSM);
-        if (swsm & E1000_SWSM_SWESMBI)
-            break;
-
-        udelay(50);
-        timeout--;
-    }
-
-    if (!timeout) {
-        /* Release semaphores */
-        e1000_put_hw_eeprom_semaphore(hw);
-        DEBUGOUT("Driver can't access the Eeprom - SWESMBI bit is set.\n");
-        return -E1000_ERR_EEPROM;
-    }
-
-    return E1000_SUCCESS;
-}
-
-/***************************************************************************
- * This function clears HW semaphore bits.
- *
- * hw: Struct containing variables accessed by shared code
- *
- * returns: - None.
- *
- ***************************************************************************/
-static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw)
-{
-    u32 swsm;
-
-    DEBUGFUNC("e1000_put_hw_eeprom_semaphore");
-
-    if (!hw->eeprom_semaphore_present)
-        return;
-
-    swsm = er32(SWSM);
-    swsm &= ~(E1000_SWSM_SWESMBI);
-    ew32(SWSM, swsm);
-}
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 243dad2..1a8a000 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -284,7 +284,6 @@ typedef enum {
 #define E1000_ERR_MASTER_REQUESTS_PENDING 10
 #define E1000_ERR_HOST_INTERFACE_COMMAND 11
 #define E1000_BLK_PHY_RESET   12
-#define E1000_ERR_SWFW_SYNC 13
 
 #define E1000_BYTE_SWAP_WORD(_value) ((((_value) & 0x00ff) << 8) | \
                                      (((_value) & 0xff00) >> 8))
@@ -1327,7 +1326,6 @@ struct e1000_hw {
 	e1000_ffe_config	ffe_config_state;
 	u32		asf_firmware_present;
 	u32		eeprom_semaphore_present;
-	u32             swfw_sync_present;
 	unsigned long		io_base;
 	u32		phy_id;
 	u32		phy_revision;

