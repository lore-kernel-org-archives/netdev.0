From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 19/23] e1000: rework polarity, NVM, eeprom code and fixes.
Date: Tue, 19 Sep 2006 10:29:16 -0700
Message-ID: <20060919172915.4605.41830.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:29965 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030348AbWISRUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:21 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several minor issues exist in the low-level device handling code of
e1000. The NVM and EEPROM writing/reading code was updated which fixes
unneeded delays, adds proper eeprom aqcuiring steps and handle shadow
ram and flash access. Minor cosmetic adjustments to the polarity code
adding symbols. PHY reset code mistakenly distinguished between MAC
types instead of PHY types, and was fixes.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c |  290 +++++++++++++++++++++---------------------
 drivers/net/e1000/e1000_hw.h |   10 +
 2 files changed, 155 insertions(+), 145 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 9280c27..4d871cd 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -662,19 +662,12 @@ e1000_reset_hw(struct e1000_hw *hw)
                 E1000_WRITE_FLUSH(hw);
             }
             /* fall through */
-        case e1000_82571:
-        case e1000_82572:
-        case e1000_ich8lan:
-        case e1000_80003es2lan:
+        default:
+            /* Auto read done will delay 5ms or poll based on mac type */
             ret_val = e1000_get_auto_rd_done(hw);
             if (ret_val)
-                /* We don't want to continue accessing MAC registers. */
                 return ret_val;
             break;
-        default:
-            /* Wait for EEPROM reload (it happens automatically) */
-            msec_delay(5);
-            break;
     }
 
     /* Disable HW ARPs on ASF enabled adapters */
@@ -3796,7 +3789,7 @@ e1000_phy_hw_reset(struct e1000_hw *hw)
             swfw = E1000_SWFW_PHY0_SM;
         }
         if (e1000_swfw_sync_acquire(hw, swfw)) {
-            e1000_release_software_semaphore(hw);
+            DEBUGOUT("Unable to acquire swfw sync\n");
             return -E1000_ERR_SWFW_SYNC;
         }
         /* Read the device control register and assert the E1000_CTRL_PHY_RST
@@ -3878,11 +3871,11 @@ e1000_phy_reset(struct e1000_hw *hw)
     if (ret_val)
         return E1000_SUCCESS;
 
-    switch (hw->mac_type) {
-    case e1000_82541_rev_2:
-    case e1000_82571:
-    case e1000_82572:
-    case e1000_ich8lan:
+    switch (hw->phy_type) {
+    case e1000_phy_igp:
+    case e1000_phy_igp_2:
+    case e1000_phy_igp_3:
+    case e1000_phy_ife:
         ret_val = e1000_phy_hw_reset(hw);
         if (ret_val)
             return ret_val;
@@ -4030,6 +4023,9 @@ e1000_detect_gig_phy(struct e1000_hw *hw
 
     DEBUGFUNC("e1000_detect_gig_phy");
 
+    if (hw->phy_id != 0)
+        return E1000_SUCCESS;
+
     /* The 82571 firmware may still be configuring the PHY.  In this
      * case, we cannot access the PHY until the configuration is done.  So
      * we explicitly set the PHY values. */
@@ -4951,44 +4947,43 @@ e1000_read_eeprom(struct e1000_hw *hw,
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     uint32_t i = 0;
-    int32_t ret_val;
 
     DEBUGFUNC("e1000_read_eeprom");
 
+    /* If eeprom is not yet detected, do so now */
+    if (eeprom->word_size == 0)
+        e1000_init_eeprom_params(hw);
+
     /* A check for invalid values:  offset too large, too many words, and not
      * enough words.
      */
     if ((offset >= eeprom->word_size) || (words > eeprom->word_size - offset) ||
        (words == 0)) {
-        DEBUGOUT("\"words\" parameter out of bounds\n");
+        DEBUGOUT2("\"words\" parameter out of bounds. Words = %d, size = %d\n", offset, eeprom->word_size);
         return -E1000_ERR_EEPROM;
     }
 
-    /* FLASH reads without acquiring the semaphore are safe */
+    /* EEPROM's that don't use EERD to read require us to bit-bang the SPI
+     * directly. In this case, we need to acquire the EEPROM so that
+     * FW or other port software does not interrupt.
+     */
     if (e1000_is_onboard_nvm_eeprom(hw) == TRUE &&
         hw->eeprom.use_eerd == FALSE) {
-        switch (hw->mac_type) {
-        case e1000_80003es2lan:
-            break;
-        default:
-            /* Prepare the EEPROM for reading  */
-            if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
-                return -E1000_ERR_EEPROM;
-            break;
-        }
+        /* Prepare the EEPROM for bit-bang reading */
+        if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
+            return -E1000_ERR_EEPROM;
     }
 
-    if (eeprom->use_eerd == TRUE) {
-        ret_val = e1000_read_eeprom_eerd(hw, offset, words, data);
-        if ((e1000_is_onboard_nvm_eeprom(hw) == TRUE) ||
-            (hw->mac_type != e1000_82573))
-            e1000_release_eeprom(hw);
-        return ret_val;
-    }
+    /* Eerd register EEPROM access requires no eeprom aquire/release */
+    if (eeprom->use_eerd == TRUE)
+        return e1000_read_eeprom_eerd(hw, offset, words, data);
 
+    /* ICH EEPROM access is done via the ICH flash controller */
     if (eeprom->type == e1000_eeprom_ich8)
         return e1000_read_eeprom_ich8(hw, offset, words, data);
 
+    /* Set up the SPI or Microwire EEPROM for bit-bang reading.  We have
+     * acquired the EEPROM at this point, so any returns should relase it */
     if (eeprom->type == e1000_eeprom_spi) {
         uint16_t word_in;
         uint8_t read_opcode = EEPROM_READ_OPCODE_SPI;
@@ -5303,6 +5298,10 @@ e1000_write_eeprom(struct e1000_hw *hw,
 
     DEBUGFUNC("e1000_write_eeprom");
 
+    /* If eeprom is not yet detected, do so now */
+    if (eeprom->word_size == 0)
+        e1000_init_eeprom_params(hw);
+
     /* A check for invalid values:  offset too large, too many words, and not
      * enough words.
      */
@@ -5508,10 +5507,8 @@ e1000_commit_shadow_ram(struct e1000_hw 
     int32_t error = E1000_SUCCESS;
     uint32_t old_bank_offset = 0;
     uint32_t new_bank_offset = 0;
-    uint32_t sector_retries = 0;
     uint8_t low_byte = 0;
     uint8_t high_byte = 0;
-    uint8_t temp_byte = 0;
     boolean_t sector_write_failed = FALSE;
 
     if (hw->mac_type == e1000_82573) {
@@ -5564,41 +5561,46 @@ e1000_commit_shadow_ram(struct e1000_hw 
             e1000_erase_ich8_4k_segment(hw, 0);
         }
 
-        do {
-            sector_write_failed = FALSE;
-            /* Loop for every byte in the shadow RAM,
-             * which is in units of words. */
-            for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
-                /* Determine whether to write the value stored
-                 * in the other NVM bank or a modified value stored
-                 * in the shadow RAM */
-                if (hw->eeprom_shadow_ram[i].modified == TRUE) {
-                    low_byte = (uint8_t)hw->eeprom_shadow_ram[i].eeprom_word;
-                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset,
-                                         &temp_byte);
-                    udelay(100);
-                    error = e1000_verify_write_ich8_byte(hw,
-                                                 (i << 1) + new_bank_offset,
-                                                 low_byte);
-                    if (error != E1000_SUCCESS)
-                        sector_write_failed = TRUE;
+        sector_write_failed = FALSE;
+        /* Loop for every byte in the shadow RAM,
+         * which is in units of words. */
+        for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
+            /* Determine whether to write the value stored
+             * in the other NVM bank or a modified value stored
+             * in the shadow RAM */
+            if (hw->eeprom_shadow_ram[i].modified == TRUE) {
+                low_byte = (uint8_t)hw->eeprom_shadow_ram[i].eeprom_word;
+                udelay(100);
+                error = e1000_verify_write_ich8_byte(hw,
+                            (i << 1) + new_bank_offset, low_byte);
+
+                if (error != E1000_SUCCESS)
+                    sector_write_failed = TRUE;
+                else {
                     high_byte =
                         (uint8_t)(hw->eeprom_shadow_ram[i].eeprom_word >> 8);
-                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset + 1,
-                                         &temp_byte);
-                    udelay(100);
-                } else {
-                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset,
-                                         &low_byte);
                     udelay(100);
-                    error = e1000_verify_write_ich8_byte(hw,
-                                 (i << 1) + new_bank_offset, low_byte);
-                    if (error != E1000_SUCCESS)
-                        sector_write_failed = TRUE;
+                }
+            } else {
+                e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset,
+                                     &low_byte);
+                udelay(100);
+                error = e1000_verify_write_ich8_byte(hw,
+                            (i << 1) + new_bank_offset, low_byte);
+
+                if (error != E1000_SUCCESS)
+                    sector_write_failed = TRUE;
+                else {
                     e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset + 1,
                                          &high_byte);
+                    udelay(100);
                 }
+            }
 
+            /* If the write of the low byte was successful, go ahread and
+             * write the high byte while checking to make sure that if it
+             * is the signature byte, then it is handled properly */
+            if (sector_write_failed == FALSE) {
                 /* If the word is 0x13, then make sure the signature bits
                  * (15:14) are 11b until the commit has completed.
                  * This will allow us to write 10b which indicates the
@@ -5609,45 +5611,45 @@ e1000_commit_shadow_ram(struct e1000_hw 
                     high_byte = E1000_ICH8_NVM_SIG_MASK | high_byte;
 
                 error = e1000_verify_write_ich8_byte(hw,
-                             (i << 1) + new_bank_offset + 1, high_byte);
+                            (i << 1) + new_bank_offset + 1, high_byte);
                 if (error != E1000_SUCCESS)
                     sector_write_failed = TRUE;
 
-                if (sector_write_failed == FALSE) {
-                    /* Clear the now not used entry in the cache */
-                    hw->eeprom_shadow_ram[i].modified = FALSE;
-                    hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
-                }
+            } else {
+                /* If the write failed then break from the loop and
+                 * return an error */
+                break;
             }
+        }
 
-            /* Don't bother writing the segment valid bits if sector
-             * programming failed. */
-            if (sector_write_failed == FALSE) {
-                /* Finally validate the new segment by setting bit 15:14
-                 * to 10b in word 0x13 , this can be done without an
-                 * erase as well since these bits are 11 to start with
-                 * and we need to change bit 14 to 0b */
-                e1000_read_ich8_byte(hw,
-                    E1000_ICH8_NVM_SIG_WORD * 2 + 1 + new_bank_offset,
-                    &high_byte);
-                high_byte &= 0xBF;
+        /* Don't bother writing the segment valid bits if sector
+         * programming failed. */
+        if (sector_write_failed == FALSE) {
+            /* Finally validate the new segment by setting bit 15:14
+             * to 10b in word 0x13 , this can be done without an
+             * erase as well since these bits are 11 to start with
+             * and we need to change bit 14 to 0b */
+            e1000_read_ich8_byte(hw,
+                                 E1000_ICH8_NVM_SIG_WORD * 2 + 1 + new_bank_offset,
+                                 &high_byte);
+            high_byte &= 0xBF;
+            error = e1000_verify_write_ich8_byte(hw,
+                        E1000_ICH8_NVM_SIG_WORD * 2 + 1 + new_bank_offset, high_byte);
+            /* And invalidate the previously valid segment by setting
+             * its signature word (0x13) high_byte to 0b. This can be
+             * done without an erase because flash erase sets all bits
+             * to 1's. We can write 1's to 0's without an erase */
+            if (error == E1000_SUCCESS) {
                 error = e1000_verify_write_ich8_byte(hw,
-                            E1000_ICH8_NVM_SIG_WORD * 2 + 1 + new_bank_offset,
-                            high_byte);
-                if (error != E1000_SUCCESS)
-                    sector_write_failed = TRUE;
+                            E1000_ICH8_NVM_SIG_WORD * 2 + 1 + old_bank_offset, 0);
+            }
 
-                /* And invalidate the previously valid segment by setting
-                 * its signature word (0x13) high_byte to 0b. This can be
-                 * done without an erase because flash erase sets all bits
-                 * to 1's. We can write 1's to 0's without an erase */
-                error = e1000_verify_write_ich8_byte(hw,
-                            E1000_ICH8_NVM_SIG_WORD * 2 + 1 + old_bank_offset,
-                            0);
-                if (error != E1000_SUCCESS)
-                    sector_write_failed = TRUE;
+            /* Clear the now not used entry in the cache */
+            for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
+                hw->eeprom_shadow_ram[i].modified = FALSE;
+                hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
             }
-        } while (++sector_retries < 10 && sector_write_failed == TRUE);
+        }
     }
 
     return error;
@@ -8745,20 +8747,22 @@ static int32_t
 e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte)
 {
     int32_t error = E1000_SUCCESS;
-    int32_t program_retries;
-    uint8_t temp_byte;
+    int32_t program_retries = 0;
 
-    e1000_write_ich8_byte(hw, index, byte);
-    udelay(100);
+    DEBUGOUT2("Byte := %2.2X Offset := %d\n", byte, index);
 
-    for (program_retries = 0; program_retries < 100; program_retries++) {
-        e1000_read_ich8_byte(hw, index, &temp_byte);
-        if (temp_byte == byte)
-            break;
-        udelay(10);
-        e1000_write_ich8_byte(hw, index, byte);
-        udelay(100);
+    error = e1000_write_ich8_byte(hw, index, byte);
+
+    if (error != E1000_SUCCESS) {
+        for (program_retries = 0; program_retries < 100; program_retries++) {
+            DEBUGOUT2("Retrying \t Byte := %2.2X Offset := %d\n", byte, index);
+            error = e1000_write_ich8_byte(hw, index, byte);
+            udelay(100);
+            if (error == E1000_SUCCESS)
+                break;
+        }
     }
+
     if (program_retries == 100)
         error = E1000_ERR_EEPROM;
 
@@ -8799,39 +8803,27 @@ e1000_read_ich8_word(struct e1000_hw *hw
 }
 
 /******************************************************************************
- * Writes a word to the NVM using the ICH8 flash access registers.
+ * Erases the bank specified. Each bank may be a 4, 8 or 64k block. Banks are 0
+ * based.
  *
  * hw - pointer to e1000_hw structure
- * index - The starting byte index of the word to read.
- * data - The word to write to the NVM.
- *****************************************************************************/
-#if 0
-int32_t
-e1000_write_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t data)
-{
-    int32_t status = E1000_SUCCESS;
-    status = e1000_write_ich8_data(hw, index, 2, data);
-    return status;
-}
-#endif  /*  0  */
-
-/******************************************************************************
- * Erases the bank specified. Each bank is a 4k block. Segments are 0 based.
- * segment N is 4096 * N + flash_reg_addr.
+ * bank - 0 for first bank, 1 for second bank
  *
- * hw - pointer to e1000_hw structure
- * segment - 0 for first segment, 1 for second segment, etc.
+ * Note that this function may actually erase as much as 8 or 64 KBytes.  The
+ * amount of NVM used in each bank is a *minimum* of 4 KBytes, but in fact the
+ * bank size may be 4, 8 or 64 KBytes
  *****************************************************************************/
-static int32_t
-e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t segment)
+int32_t
+e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
     uint32_t flash_linear_address;
     int32_t  count = 0;
     int32_t  error = E1000_ERR_EEPROM;
-    int32_t  iteration, seg_size;
-    int32_t  sector_size;
+    int32_t  iteration;
+    int32_t  sub_sector_size = 0;
+    int32_t  bank_size;
     int32_t  j = 0;
     int32_t  error_flag = 0;
 
@@ -8840,22 +8832,27 @@ e1000_erase_ich8_4k_segment(struct e1000
     /* Determine HW Sector size: Read BERASE bits of Hw flash Status register */
     /* 00: The Hw sector is 256 bytes, hence we need to erase 16
      *     consecutive sectors.  The start index for the nth Hw sector can be
-     *     calculated as = segment * 4096 + n * 256
+     *     calculated as bank * 4096 + n * 256
      * 01: The Hw sector is 4K bytes, hence we need to erase 1 sector.
      *     The start index for the nth Hw sector can be calculated
-     *     as = segment * 4096
-     * 10: Error condition
-     * 11: The Hw sector size is much bigger than the size asked to
-     *     erase...error condition */
+     *     as bank * 4096
+     * 10: The HW sector is 8K bytes
+     * 11: The Hw sector size is 64K bytes */
     if (hsfsts.hsf_status.berasesz == 0x0) {
         /* Hw sector size 256 */
-        sector_size = seg_size = ICH8_FLASH_SEG_SIZE_256;
+        sub_sector_size = ICH8_FLASH_SEG_SIZE_256;
+        bank_size = ICH8_FLASH_SECTOR_SIZE;
         iteration = ICH8_FLASH_SECTOR_SIZE / ICH8_FLASH_SEG_SIZE_256;
     } else if (hsfsts.hsf_status.berasesz == 0x1) {
-        sector_size = seg_size = ICH8_FLASH_SEG_SIZE_4K;
+        bank_size = ICH8_FLASH_SEG_SIZE_4K;
+        iteration = 1;
+    } else if (hw->mac_type != e1000_ich8lan &&
+               hsfsts.hsf_status.berasesz == 0x2) {
+        /* 8K erase size invalid for ICH8 - added in for ICH9 */
+        bank_size = ICH9_FLASH_SEG_SIZE_8K;
         iteration = 1;
     } else if (hsfsts.hsf_status.berasesz == 0x3) {
-        sector_size = seg_size = ICH8_FLASH_SEG_SIZE_64K;
+        bank_size = ICH8_FLASH_SEG_SIZE_64K;
         iteration = 1;
     } else {
         return error;
@@ -8879,16 +8876,15 @@ e1000_erase_ich8_4k_segment(struct e1000
 
             /* Write the last 24 bits of an index within the block into Flash
              * Linear address field in Flash Address.  This probably needs to
-             * be calculated here based off the on-chip segment size and the
-             * software segment size assumed (4K) */
-            /* TBD */
-            flash_linear_address = segment * sector_size + j * seg_size;
-            flash_linear_address &= ICH8_FLASH_LINEAR_ADDR_MASK;
+             * be calculated here based off the on-chip erase sector size and
+             * the software bank size (4, 8 or 64 KBytes) */
+            flash_linear_address = bank * bank_size + j * sub_sector_size;
             flash_linear_address += hw->flash_base_addr;
+            flash_linear_address &= ICH8_FLASH_LINEAR_ADDR_MASK;
 
             E1000_WRITE_ICH8_REG(hw, ICH8_FLASH_FADDR, flash_linear_address);
 
-            error = e1000_ich8_flash_cycle(hw, 1000000);
+            error = e1000_ich8_flash_cycle(hw, ICH8_FLASH_ERASE_TIMEOUT);
             /* Check if FCERR is set to 1.  If 1, clear it and try the whole
              * sequence a few more times else Done */
             if (error == E1000_SUCCESS) {
@@ -8946,6 +8942,14 @@ e1000_init_lcd_from_nvm_config_region(st
 }
 
 
+/******************************************************************************
+ * This function initializes the PHY from the NVM on ICH8 platforms. This
+ * is needed due to an issue where the NVM configuration is not properly
+ * autoloaded after power transitions. Therefore, after each PHY reset, we
+ * will load the configuration data out of the NVM manually.
+ *
+ * hw: Struct containing variables accessed by shared code
+ *****************************************************************************/
 static int32_t
 e1000_init_lcd_from_nvm(struct e1000_hw *hw)
 {
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index a005001..b3dd549 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -292,6 +292,9 @@ typedef enum {
 #define E1000_BLK_PHY_RESET   12
 #define E1000_ERR_SWFW_SYNC 13
 
+#define E1000_BYTE_SWAP_WORD(_value) ((((_value) & 0x00ff) << 8) | \
+                                     (((_value) & 0xff00) >> 8))
+
 /* Function prototypes */
 /* Initialization */
 int32_t e1000_reset_hw(struct e1000_hw *hw);
@@ -3124,6 +3127,7 @@ struct e1000_host_command_info {
 /* I = Integrated
  * E = External
  */
+#define M88_VENDOR         0x0141
 #define M88E1000_E_PHY_ID  0x01410C50
 #define M88E1000_I_PHY_ID  0x01410C30
 #define M88E1011_I_PHY_ID  0x01410C20
@@ -3248,10 +3252,12 @@ struct e1000_host_command_info {
 #define IFE_PSCL_PROBE_LEDS_OFF              0x0006  /* Force LEDs 0 and 2 off */
 #define IFE_PSCL_PROBE_LEDS_ON               0x0007  /* Force LEDs 0 and 2 on */
 
-#define ICH8_FLASH_COMMAND_TIMEOUT           500   /* 500 ms , should be adjusted */
-#define ICH8_FLASH_CYCLE_REPEAT_COUNT        10    /* 10 cycles , should be adjusted */
+#define ICH8_FLASH_COMMAND_TIMEOUT           5000    /* 5000 uSecs - adjusted */
+#define ICH8_FLASH_ERASE_TIMEOUT             3000000 /* Up to 3 seconds - worst case */
+#define ICH8_FLASH_CYCLE_REPEAT_COUNT        10      /* 10 cycles */
 #define ICH8_FLASH_SEG_SIZE_256              256
 #define ICH8_FLASH_SEG_SIZE_4K               4096
+#define ICH9_FLASH_SEG_SIZE_8K               8192
 #define ICH8_FLASH_SEG_SIZE_64K              65536
 
 #define ICH8_CYCLE_READ                      0x0



---
Auke Kok <auke-jan.h.kok@intel.com>
