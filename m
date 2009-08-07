From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] e1000e: fix potential NVM corruption on ICH9 with
	8K bank size
Date: Fri, 07 Aug 2009 10:41:56 -0700
Message-ID: <20090807174155.31114.81083.stgit@localhost.localdomain>
References: <20090807174136.31114.96240.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:44339
	"EHLO QMTA12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754680AbZHGRmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 13:42:12 -0400
In-Reply-To: <20090807174136.31114.96240.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The bank offset was being incorrectly calculated on ICH9 parts with a bank
size of 8K (instead of the more common 4K bank) which would cause any NVM
writes to be done on the wrong address after switching from bank 1 to bank
0.  Additionally, assume we are meant to use bank 0 if a valid bank is not
detected, and remove the unnecessary acquisition of the SW/FW/HW semaphore
when writing to the shadow ram version of the NVM image.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   50 ++++++++++--------------------------------
 1 files changed, 12 insertions(+), 38 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index dd61e7e..99df2ab 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -338,10 +338,7 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
-	union ich8_hws_flash_status hsfsts;
-	u32 gfpreg;
-	u32 sector_base_addr;
-	u32 sector_end_addr;
+	u32 gfpreg, sector_base_addr, sector_end_addr;
 	u16 i;
 
 	/* Can't read flash registers if the register set isn't mapped. */
@@ -375,20 +372,6 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 	/* Adjust to word count */
 	nvm->flash_bank_size /= sizeof(u16);
 
-	/*
-	 * Make sure the flash bank size does not overwrite the 4k
-	 * sector ranges. We may have 64k allotted to us but we only care
-	 * about the first 2 4k sectors. Therefore, if we have anything less
-	 * than 64k set in the HSFSTS register, we will reduce the bank size
-	 * down to 4k and let the rest remain unused. If berasesz == 3, then
-	 * we are working in 64k mode. Otherwise we are not.
-	 */
-	if (nvm->flash_bank_size > E1000_ICH8_SHADOW_RAM_WORDS) {
-		hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
-		if (hsfsts.hsf_status.berasesz != 3)
-			nvm->flash_bank_size = E1000_ICH8_SHADOW_RAM_WORDS;
-	}
-
 	nvm->word_size = E1000_ICH8_SHADOW_RAM_WORDS;
 
 	/* Clear shadow ram */
@@ -1324,7 +1307,7 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
 	u32 act_offset;
-	s32 ret_val;
+	s32 ret_val = 0;
 	u32 bank = 0;
 	u16 i, word;
 
@@ -1339,12 +1322,15 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 		goto out;
 
 	ret_val = e1000_valid_nvm_bank_detect_ich8lan(hw, &bank);
-	if (ret_val)
-		goto release;
+	if (ret_val) {
+		hw_dbg(hw, "Could not detect valid bank, assuming bank 0\n");
+		bank = 0;
+	}
 
 	act_offset = (bank) ? nvm->flash_bank_size : 0;
 	act_offset += offset;
 
+	ret_val = 0;
 	for (i = 0; i < words; i++) {
 		if ((dev_spec->shadow_ram) &&
 		    (dev_spec->shadow_ram[offset+i].modified)) {
@@ -1359,7 +1345,6 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 		}
 	}
 
-release:
 	e1000_release_swflag_ich8lan(hw);
 
 out:
@@ -1610,7 +1595,6 @@ static s32 e1000_write_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
-	s32 ret_val;
 	u16 i;
 
 	if ((offset >= nvm->word_size) || (words > nvm->word_size - offset) ||
@@ -1619,17 +1603,11 @@ static s32 e1000_write_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 		return -E1000_ERR_NVM;
 	}
 
-	ret_val = e1000_acquire_swflag_ich8lan(hw);
-	if (ret_val)
-		return ret_val;
-
 	for (i = 0; i < words; i++) {
 		dev_spec->shadow_ram[offset+i].modified = 1;
 		dev_spec->shadow_ram[offset+i].value = data[i];
 	}
 
-	e1000_release_swflag_ich8lan(hw);
-
 	return 0;
 }
 
@@ -1670,8 +1648,8 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	 */
 	ret_val =  e1000_valid_nvm_bank_detect_ich8lan(hw, &bank);
 	if (ret_val) {
-		e1000_release_swflag_ich8lan(hw);
-		goto out;
+		hw_dbg(hw, "Could not detect valid bank, assuming bank 0\n");
+		bank = 0;
 	}
 
 	if (bank == 0) {
@@ -2057,12 +2035,8 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 		iteration = 1;
 		break;
 	case 2:
-		if (hw->mac.type == e1000_ich9lan) {
-			sector_size = ICH_FLASH_SEG_SIZE_8K;
-			iteration = flash_bank_size / ICH_FLASH_SEG_SIZE_8K;
-		} else {
-			return -E1000_ERR_NVM;
-		}
+		sector_size = ICH_FLASH_SEG_SIZE_8K;
+		iteration = 1;
 		break;
 	case 3:
 		sector_size = ICH_FLASH_SEG_SIZE_64K;
@@ -2074,7 +2048,7 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 
 	/* Start with the base address, then add the sector offset. */
 	flash_linear_addr = hw->nvm.flash_base_addr;
-	flash_linear_addr += (bank) ? (sector_size * iteration) : 0;
+	flash_linear_addr += (bank) ? flash_bank_size : 0;
 
 	for (j = 0; j < iteration ; j++) {
 		do {

