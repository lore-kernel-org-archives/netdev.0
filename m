From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 12/18] e1000: rename ICH8 flash macros
Date: Wed, 01 Nov 2006 09:51:56 -0800
Message-ID: <20061101175156.2356.47649.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:20496 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946973AbWKARom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:44:42 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


ICH8 will soon be followed by newer chipsets bearing the same acronym,
thus we remove the '8' and make it independent of the version number in
the platform name.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c    |  119 +++++++++++++++++++--------------------
 drivers/net/e1000/e1000_hw.h    |   73 ++++++++++++------------
 drivers/net/e1000/e1000_osdep.h |    8 +--
 3 files changed, 98 insertions(+), 102 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index fd7d09d..a25a6b1 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -4555,7 +4555,7 @@ e1000_init_eeprom_params(struct e1000_hw
     case e1000_ich8lan:
         {
         int32_t  i = 0;
-        uint32_t flash_size = E1000_READ_ICH8_REG(hw, ICH8_FLASH_GFPREG);
+        uint32_t flash_size = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_GFPREG);
 
         eeprom->type = e1000_eeprom_ich8;
         eeprom->use_eerd = FALSE;
@@ -4571,12 +4571,14 @@ e1000_init_eeprom_params(struct e1000_hw
             }
         }
 
-        hw->flash_base_addr = (flash_size & ICH8_GFPREG_BASE_MASK) *
-                              ICH8_FLASH_SECTOR_SIZE;
+        hw->flash_base_addr = (flash_size & ICH_GFPREG_BASE_MASK) *
+                              ICH_FLASH_SECTOR_SIZE;
+
+        hw->flash_bank_size = ((flash_size >> 16) & ICH_GFPREG_BASE_MASK) + 1;
+        hw->flash_bank_size -= (flash_size & ICH_GFPREG_BASE_MASK);
+
+        hw->flash_bank_size *= ICH_FLASH_SECTOR_SIZE;
 
-        hw->flash_bank_size = ((flash_size >> 16) & ICH8_GFPREG_BASE_MASK) + 1;
-        hw->flash_bank_size -= (flash_size & ICH8_GFPREG_BASE_MASK);
-        hw->flash_bank_size *= ICH8_FLASH_SECTOR_SIZE;
         hw->flash_bank_size /= 2 * sizeof(uint16_t);
 
         break;
@@ -5626,8 +5628,8 @@ e1000_commit_shadow_ram(struct e1000_hw 
                  * signature is valid.  We want to do this after the write
                  * has completed so that we don't mark the segment valid
                  * while the write is still in progress */
-                if (i == E1000_ICH8_NVM_SIG_WORD)
-                    high_byte = E1000_ICH8_NVM_SIG_MASK | high_byte;
+                if (i == E1000_ICH_NVM_SIG_WORD)
+                    high_byte = E1000_ICH_NVM_SIG_MASK | high_byte;
 
                 error = e1000_verify_write_ich8_byte(hw,
                             (i << 1) + new_bank_offset + 1, high_byte);
@@ -5649,18 +5651,18 @@ e1000_commit_shadow_ram(struct e1000_hw 
              * erase as well since these bits are 11 to start with
              * and we need to change bit 14 to 0b */
             e1000_read_ich8_byte(hw,
-                                 E1000_ICH8_NVM_SIG_WORD * 2 + 1 + new_bank_offset,
+                                 E1000_ICH_NVM_SIG_WORD * 2 + 1 + new_bank_offset,
                                  &high_byte);
             high_byte &= 0xBF;
             error = e1000_verify_write_ich8_byte(hw,
-                        E1000_ICH8_NVM_SIG_WORD * 2 + 1 + new_bank_offset, high_byte);
+                        E1000_ICH_NVM_SIG_WORD * 2 + 1 + new_bank_offset, high_byte);
             /* And invalidate the previously valid segment by setting
              * its signature word (0x13) high_byte to 0b. This can be
              * done without an erase because flash erase sets all bits
              * to 1's. We can write 1's to 0's without an erase */
             if (error == E1000_SUCCESS) {
                 error = e1000_verify_write_ich8_byte(hw,
-                            E1000_ICH8_NVM_SIG_WORD * 2 + 1 + old_bank_offset, 0);
+                            E1000_ICH_NVM_SIG_WORD * 2 + 1 + old_bank_offset, 0);
             }
 
             /* Clear the now not used entry in the cache */
@@ -8494,7 +8496,7 @@ e1000_ich8_cycle_init(struct e1000_hw *h
 
     DEBUGFUNC("e1000_ich8_cycle_init");
 
-    hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+    hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
 
     /* May be check the Flash Des Valid bit in Hw status */
     if (hsfsts.hsf_status.fldesvalid == 0) {
@@ -8507,7 +8509,7 @@ e1000_ich8_cycle_init(struct e1000_hw *h
     hsfsts.hsf_status.flcerr = 1;
     hsfsts.hsf_status.dael = 1;
 
-    E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFSTS, hsfsts.regval);
+    E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS, hsfsts.regval);
 
     /* Either we should have a hardware SPI cycle in progress bit to check
      * against, in order to start a new cycle or FDONE bit should be changed
@@ -8522,13 +8524,13 @@ e1000_ich8_cycle_init(struct e1000_hw *h
         /* There is no cycle running at present, so we can start a cycle */
         /* Begin by setting Flash Cycle Done. */
         hsfsts.hsf_status.flcdone = 1;
-        E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFSTS, hsfsts.regval);
+        E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS, hsfsts.regval);
         error = E1000_SUCCESS;
     } else {
         /* otherwise poll for sometime so the current cycle has a chance
          * to end before giving up. */
-        for (i = 0; i < ICH8_FLASH_COMMAND_TIMEOUT; i++) {
-            hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+        for (i = 0; i < ICH_FLASH_COMMAND_TIMEOUT; i++) {
+            hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
             if (hsfsts.hsf_status.flcinprog == 0) {
                 error = E1000_SUCCESS;
                 break;
@@ -8539,7 +8541,7 @@ e1000_ich8_cycle_init(struct e1000_hw *h
             /* Successful in waiting for previous cycle to timeout,
              * now set the Flash Cycle Done. */
             hsfsts.hsf_status.flcdone = 1;
-            E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFSTS, hsfsts.regval);
+            E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS, hsfsts.regval);
         } else {
             DEBUGOUT("Flash controller busy, cannot get access");
         }
@@ -8561,13 +8563,13 @@ e1000_ich8_flash_cycle(struct e1000_hw *
     uint32_t i = 0;
 
     /* Start a cycle by writing 1 in Flash Cycle Go in Hw Flash Control */
-    hsflctl.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFCTL);
+    hsflctl.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL);
     hsflctl.hsf_ctrl.flcgo = 1;
-    E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFCTL, hsflctl.regval);
+    E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL, hsflctl.regval);
 
     /* wait till FDONE bit is set to 1 */
     do {
-        hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+        hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
         if (hsfsts.hsf_status.flcdone == 1)
             break;
         udelay(1);
@@ -8601,10 +8603,10 @@ e1000_read_ich8_data(struct e1000_hw *hw
     DEBUGFUNC("e1000_read_ich8_data");
 
     if (size < 1  || size > 2 || data == 0x0 ||
-        index > ICH8_FLASH_LINEAR_ADDR_MASK)
+        index > ICH_FLASH_LINEAR_ADDR_MASK)
         return error;
 
-    flash_linear_address = (ICH8_FLASH_LINEAR_ADDR_MASK & index) +
+    flash_linear_address = (ICH_FLASH_LINEAR_ADDR_MASK & index) +
                            hw->flash_base_addr;
 
     do {
@@ -8614,25 +8616,25 @@ e1000_read_ich8_data(struct e1000_hw *hw
         if (error != E1000_SUCCESS)
             break;
 
-        hsflctl.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFCTL);
+        hsflctl.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL);
         /* 0b/1b corresponds to 1 or 2 byte size, respectively. */
         hsflctl.hsf_ctrl.fldbcount = size - 1;
-        hsflctl.hsf_ctrl.flcycle = ICH8_CYCLE_READ;
-        E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFCTL, hsflctl.regval);
+        hsflctl.hsf_ctrl.flcycle = ICH_CYCLE_READ;
+        E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL, hsflctl.regval);
 
         /* Write the last 24 bits of index into Flash Linear address field in
          * Flash Address */
         /* TODO: TBD maybe check the index against the size of flash */
 
-        E1000_WRITE_ICH8_REG(hw, ICH8_FLASH_FADDR, flash_linear_address);
+        E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FADDR, flash_linear_address);
 
-        error = e1000_ich8_flash_cycle(hw, ICH8_FLASH_COMMAND_TIMEOUT);
+        error = e1000_ich8_flash_cycle(hw, ICH_FLASH_COMMAND_TIMEOUT);
 
         /* Check if FCERR is set to 1, if set to 1, clear it and try the whole
          * sequence a few more times, else read in (shift in) the Flash Data0,
          * the order is least significant byte first msb to lsb */
         if (error == E1000_SUCCESS) {
-            flash_data = E1000_READ_ICH8_REG(hw, ICH8_FLASH_FDATA0);
+            flash_data = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_FDATA0);
             if (size == 1) {
                 *data = (uint8_t)(flash_data & 0x000000FF);
             } else if (size == 2) {
@@ -8642,9 +8644,9 @@ e1000_read_ich8_data(struct e1000_hw *hw
         } else {
             /* If we've gotten here, then things are probably completely hosed,
              * but if the error condition is detected, it won't hurt to give
-             * it another try...ICH8_FLASH_CYCLE_REPEAT_COUNT times.
+             * it another try...ICH_FLASH_CYCLE_REPEAT_COUNT times.
              */
-            hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+            hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
             if (hsfsts.hsf_status.flcerr == 1) {
                 /* Repeat for some time before giving up. */
                 continue;
@@ -8653,7 +8655,7 @@ e1000_read_ich8_data(struct e1000_hw *hw
                 break;
             }
         }
-    } while (count++ < ICH8_FLASH_CYCLE_REPEAT_COUNT);
+    } while (count++ < ICH_FLASH_CYCLE_REPEAT_COUNT);
 
     return error;
 }
@@ -8680,10 +8682,10 @@ e1000_write_ich8_data(struct e1000_hw *h
     DEBUGFUNC("e1000_write_ich8_data");
 
     if (size < 1  || size > 2 || data > size * 0xff ||
-        index > ICH8_FLASH_LINEAR_ADDR_MASK)
+        index > ICH_FLASH_LINEAR_ADDR_MASK)
         return error;
 
-    flash_linear_address = (ICH8_FLASH_LINEAR_ADDR_MASK & index) +
+    flash_linear_address = (ICH_FLASH_LINEAR_ADDR_MASK & index) +
                            hw->flash_base_addr;
 
     do {
@@ -8693,34 +8695,34 @@ e1000_write_ich8_data(struct e1000_hw *h
         if (error != E1000_SUCCESS)
             break;
 
-        hsflctl.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFCTL);
+        hsflctl.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL);
         /* 0b/1b corresponds to 1 or 2 byte size, respectively. */
         hsflctl.hsf_ctrl.fldbcount = size -1;
-        hsflctl.hsf_ctrl.flcycle = ICH8_CYCLE_WRITE;
-        E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFCTL, hsflctl.regval);
+        hsflctl.hsf_ctrl.flcycle = ICH_CYCLE_WRITE;
+        E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL, hsflctl.regval);
 
         /* Write the last 24 bits of index into Flash Linear address field in
          * Flash Address */
-        E1000_WRITE_ICH8_REG(hw, ICH8_FLASH_FADDR, flash_linear_address);
+        E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FADDR, flash_linear_address);
 
         if (size == 1)
             flash_data = (uint32_t)data & 0x00FF;
         else
             flash_data = (uint32_t)data;
 
-        E1000_WRITE_ICH8_REG(hw, ICH8_FLASH_FDATA0, flash_data);
+        E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FDATA0, flash_data);
 
         /* check if FCERR is set to 1 , if set to 1, clear it and try the whole
          * sequence a few more times else done */
-        error = e1000_ich8_flash_cycle(hw, ICH8_FLASH_COMMAND_TIMEOUT);
+        error = e1000_ich8_flash_cycle(hw, ICH_FLASH_COMMAND_TIMEOUT);
         if (error == E1000_SUCCESS) {
             break;
         } else {
             /* If we're here, then things are most likely completely hosed,
              * but if the error condition is detected, it won't hurt to give
-             * it another try...ICH8_FLASH_CYCLE_REPEAT_COUNT times.
+             * it another try...ICH_FLASH_CYCLE_REPEAT_COUNT times.
              */
-            hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+            hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
             if (hsfsts.hsf_status.flcerr == 1) {
                 /* Repeat for some time before giving up. */
                 continue;
@@ -8729,7 +8731,7 @@ e1000_write_ich8_data(struct e1000_hw *h
                 break;
             }
         }
-    } while (count++ < ICH8_FLASH_CYCLE_REPEAT_COUNT);
+    } while (count++ < ICH_FLASH_CYCLE_REPEAT_COUNT);
 
     return error;
 }
@@ -8848,7 +8850,7 @@ e1000_erase_ich8_4k_segment(struct e1000
     int32_t  j = 0;
     int32_t  error_flag = 0;
 
-    hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+    hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
 
     /* Determine HW Sector size: Read BERASE bits of Hw flash Status register */
     /* 00: The Hw sector is 256 bytes, hence we need to erase 16
@@ -8861,19 +8863,14 @@ e1000_erase_ich8_4k_segment(struct e1000
      * 11: The Hw sector size is 64K bytes */
     if (hsfsts.hsf_status.berasesz == 0x0) {
         /* Hw sector size 256 */
-        sub_sector_size = ICH8_FLASH_SEG_SIZE_256;
-        bank_size = ICH8_FLASH_SECTOR_SIZE;
-        iteration = ICH8_FLASH_SECTOR_SIZE / ICH8_FLASH_SEG_SIZE_256;
+        sub_sector_size = ICH_FLASH_SEG_SIZE_256;
+        bank_size = ICH_FLASH_SECTOR_SIZE;
+        iteration = ICH_FLASH_SECTOR_SIZE / ICH_FLASH_SEG_SIZE_256;
     } else if (hsfsts.hsf_status.berasesz == 0x1) {
-        bank_size = ICH8_FLASH_SEG_SIZE_4K;
-        iteration = 1;
-    } else if (hw->mac_type != e1000_ich8lan &&
-               hsfsts.hsf_status.berasesz == 0x2) {
-        /* 8K erase size invalid for ICH8 - added in for ICH9 */
-        bank_size = ICH9_FLASH_SEG_SIZE_8K;
+        bank_size = ICH_FLASH_SEG_SIZE_4K;
         iteration = 1;
     } else if (hsfsts.hsf_status.berasesz == 0x3) {
-        bank_size = ICH8_FLASH_SEG_SIZE_64K;
+        bank_size = ICH_FLASH_SEG_SIZE_64K;
         iteration = 1;
     } else {
         return error;
@@ -8891,9 +8888,9 @@ e1000_erase_ich8_4k_segment(struct e1000
 
             /* Write a value 11 (block Erase) in Flash Cycle field in Hw flash
              * Control */
-            hsflctl.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFCTL);
-            hsflctl.hsf_ctrl.flcycle = ICH8_CYCLE_ERASE;
-            E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFCTL, hsflctl.regval);
+            hsflctl.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL);
+            hsflctl.hsf_ctrl.flcycle = ICH_CYCLE_ERASE;
+            E1000_WRITE_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL, hsflctl.regval);
 
             /* Write the last 24 bits of an index within the block into Flash
              * Linear address field in Flash Address.  This probably needs to
@@ -8901,17 +8898,17 @@ e1000_erase_ich8_4k_segment(struct e1000
              * the software bank size (4, 8 or 64 KBytes) */
             flash_linear_address = bank * bank_size + j * sub_sector_size;
             flash_linear_address += hw->flash_base_addr;
-            flash_linear_address &= ICH8_FLASH_LINEAR_ADDR_MASK;
+            flash_linear_address &= ICH_FLASH_LINEAR_ADDR_MASK;
 
-            E1000_WRITE_ICH8_REG(hw, ICH8_FLASH_FADDR, flash_linear_address);
+            E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FADDR, flash_linear_address);
 
-            error = e1000_ich8_flash_cycle(hw, ICH8_FLASH_ERASE_TIMEOUT);
+            error = e1000_ich8_flash_cycle(hw, ICH_FLASH_ERASE_TIMEOUT);
             /* Check if FCERR is set to 1.  If 1, clear it and try the whole
              * sequence a few more times else Done */
             if (error == E1000_SUCCESS) {
                 break;
             } else {
-                hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+                hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
                 if (hsfsts.hsf_status.flcerr == 1) {
                     /* repeat for some time before giving up */
                     continue;
@@ -8920,7 +8917,7 @@ e1000_erase_ich8_4k_segment(struct e1000
                     break;
                 }
             }
-        } while ((count < ICH8_FLASH_CYCLE_REPEAT_COUNT) && !error_flag);
+        } while ((count < ICH_FLASH_CYCLE_REPEAT_COUNT) && !error_flag);
         if (error_flag == 1)
             break;
     }
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 93c1e26..3321fb1 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1583,8 +1583,8 @@ struct e1000_hw {
 #define E1000_HICR_FW_RESET  0xC0
 
 #define E1000_SHADOW_RAM_WORDS     2048
-#define E1000_ICH8_NVM_SIG_WORD    0x13
-#define E1000_ICH8_NVM_SIG_MASK    0xC0
+#define E1000_ICH_NVM_SIG_WORD     0x13
+#define E1000_ICH_NVM_SIG_MASK     0xC0
 
 /* EEPROM Read */
 #define E1000_EERD_START      0x00000001 /* Start Read */
@@ -3263,41 +3263,40 @@ struct e1000_host_command_info {
 #define IFE_PSCL_PROBE_LEDS_OFF              0x0006  /* Force LEDs 0 and 2 off */
 #define IFE_PSCL_PROBE_LEDS_ON               0x0007  /* Force LEDs 0 and 2 on */
 
-#define ICH8_FLASH_COMMAND_TIMEOUT           5000    /* 5000 uSecs - adjusted */
-#define ICH8_FLASH_ERASE_TIMEOUT             3000000 /* Up to 3 seconds - worst case */
-#define ICH8_FLASH_CYCLE_REPEAT_COUNT        10      /* 10 cycles */
-#define ICH8_FLASH_SEG_SIZE_256              256
-#define ICH8_FLASH_SEG_SIZE_4K               4096
-#define ICH9_FLASH_SEG_SIZE_8K               8192
-#define ICH8_FLASH_SEG_SIZE_64K              65536
-
-#define ICH8_CYCLE_READ                      0x0
-#define ICH8_CYCLE_RESERVED                  0x1
-#define ICH8_CYCLE_WRITE                     0x2
-#define ICH8_CYCLE_ERASE                     0x3
-
-#define ICH8_FLASH_GFPREG   0x0000
-#define ICH8_FLASH_HSFSTS   0x0004
-#define ICH8_FLASH_HSFCTL   0x0006
-#define ICH8_FLASH_FADDR    0x0008
-#define ICH8_FLASH_FDATA0   0x0010
-#define ICH8_FLASH_FRACC    0x0050
-#define ICH8_FLASH_FREG0    0x0054
-#define ICH8_FLASH_FREG1    0x0058
-#define ICH8_FLASH_FREG2    0x005C
-#define ICH8_FLASH_FREG3    0x0060
-#define ICH8_FLASH_FPR0     0x0074
-#define ICH8_FLASH_FPR1     0x0078
-#define ICH8_FLASH_SSFSTS   0x0090
-#define ICH8_FLASH_SSFCTL   0x0092
-#define ICH8_FLASH_PREOP    0x0094
-#define ICH8_FLASH_OPTYPE   0x0096
-#define ICH8_FLASH_OPMENU   0x0098
-
-#define ICH8_FLASH_REG_MAPSIZE      0x00A0
-#define ICH8_FLASH_SECTOR_SIZE      4096
-#define ICH8_GFPREG_BASE_MASK       0x1FFF
-#define ICH8_FLASH_LINEAR_ADDR_MASK 0x00FFFFFF
+#define ICH_FLASH_COMMAND_TIMEOUT            5000    /* 5000 uSecs - adjusted */
+#define ICH_FLASH_ERASE_TIMEOUT              3000000 /* Up to 3 seconds - worst case */
+#define ICH_FLASH_CYCLE_REPEAT_COUNT         10      /* 10 cycles */
+#define ICH_FLASH_SEG_SIZE_256               256
+#define ICH_FLASH_SEG_SIZE_4K                4096
+#define ICH_FLASH_SEG_SIZE_64K               65536
+
+#define ICH_CYCLE_READ                       0x0
+#define ICH_CYCLE_RESERVED                   0x1
+#define ICH_CYCLE_WRITE                      0x2
+#define ICH_CYCLE_ERASE                      0x3
+
+#define ICH_FLASH_GFPREG   0x0000
+#define ICH_FLASH_HSFSTS   0x0004
+#define ICH_FLASH_HSFCTL   0x0006
+#define ICH_FLASH_FADDR    0x0008
+#define ICH_FLASH_FDATA0   0x0010
+#define ICH_FLASH_FRACC    0x0050
+#define ICH_FLASH_FREG0    0x0054
+#define ICH_FLASH_FREG1    0x0058
+#define ICH_FLASH_FREG2    0x005C
+#define ICH_FLASH_FREG3    0x0060
+#define ICH_FLASH_FPR0     0x0074
+#define ICH_FLASH_FPR1     0x0078
+#define ICH_FLASH_SSFSTS   0x0090
+#define ICH_FLASH_SSFCTL   0x0092
+#define ICH_FLASH_PREOP    0x0094
+#define ICH_FLASH_OPTYPE   0x0096
+#define ICH_FLASH_OPMENU   0x0098
+
+#define ICH_FLASH_REG_MAPSIZE      0x00A0
+#define ICH_FLASH_SECTOR_SIZE      4096
+#define ICH_GFPREG_BASE_MASK       0x1FFF
+#define ICH_FLASH_LINEAR_ADDR_MASK 0x00FFFFFF
 
 /* ICH8 GbE Flash Hardware Sequencing Flash Status Register bit breakdown */
 /* Offset 04h HSFSTS */
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 3b7eb7c..18afc0c 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -107,16 +107,16 @@ typedef enum {
 
 #define E1000_WRITE_FLUSH(a) E1000_READ_REG(a, STATUS)
 
-#define E1000_WRITE_ICH8_REG(a, reg, value) ( \
+#define E1000_WRITE_ICH_FLASH_REG(a, reg, value) ( \
     writel((value), ((a)->flash_address + reg)))
 
-#define E1000_READ_ICH8_REG(a, reg) ( \
+#define E1000_READ_ICH_FLASH_REG(a, reg) ( \
     readl((a)->flash_address + reg))
 
-#define E1000_WRITE_ICH8_REG16(a, reg, value) ( \
+#define E1000_WRITE_ICH_FLASH_REG16(a, reg, value) ( \
     writew((value), ((a)->flash_address + reg)))
 
-#define E1000_READ_ICH8_REG16(a, reg) ( \
+#define E1000_READ_ICH_FLASH_REG16(a, reg) ( \
     readw((a)->flash_address + reg))
 
 #endif /* _E1000_OSDEP_H_ */



---
Auke Kok <auke-jan.h.kok@intel.com>
