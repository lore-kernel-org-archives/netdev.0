From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/9] e1000e: remove no longer used e1000e_read_nvm_spi
Date: Fri, 21 Mar 2008 11:06:47 -0700
Message-ID: <20080321180647.24164.91005.stgit@localhost.localdomain>
References: <20080321180625.24164.46137.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:41394 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760618AbYCUSST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2008 14:18:19 -0400
In-Reply-To: <20080321180625.24164.46137.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is no longer used now that 82573 uses the eerd
read method as well. Thanks to Adrian Bunk for pointing this out.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h |    1 -
 drivers/net/e1000e/lib.c   |   56 --------------------------------------------
 2 files changed, 0 insertions(+), 57 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 327c062..6e0c6ed 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -462,7 +462,6 @@ extern s32 e1000e_acquire_nvm(struct e1000_hw *hw);
 extern s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 extern s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw);
 extern s32 e1000e_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg);
-extern s32 e1000e_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 extern s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 extern s32 e1000e_validate_nvm_checksum_generic(struct e1000_hw *hw);
 extern void e1000e_release_nvm(struct e1000_hw *hw);
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 95f75a4..073934c 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1852,62 +1852,6 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_read_nvm_spi - Reads EEPROM using SPI
- *  @hw: pointer to the HW structure
- *  @offset: offset of word in the EEPROM to read
- *  @words: number of words to read
- *  @data: word read from the EEPROM
- *
- *  Reads a 16 bit word from the EEPROM.
- **/
-s32 e1000e_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
-{
-	struct e1000_nvm_info *nvm = &hw->nvm;
-	u32 i = 0;
-	s32 ret_val;
-	u16 word_in;
-	u8 read_opcode = NVM_READ_OPCODE_SPI;
-
-	/* A check for invalid values:  offset too large, too many words,
-	 * and not enough words. */
-	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
-	    (words == 0)) {
-		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
-		return -E1000_ERR_NVM;
-	}
-
-	ret_val = nvm->ops.acquire_nvm(hw);
-	if (ret_val)
-		return ret_val;
-
-	ret_val = e1000_ready_nvm_eeprom(hw);
-	if (ret_val) {
-		nvm->ops.release_nvm(hw);
-		return ret_val;
-	}
-
-	e1000_standby_nvm(hw);
-
-	if ((nvm->address_bits == 8) && (offset >= 128))
-		read_opcode |= NVM_A8_OPCODE_SPI;
-
-	/* Send the READ command (opcode + addr) */
-	e1000_shift_out_eec_bits(hw, read_opcode, nvm->opcode_bits);
-	e1000_shift_out_eec_bits(hw, (u16)(offset*2), nvm->address_bits);
-
-	/* Read the data.  SPI NVMs increment the address with each byte
-	 * read and will roll over if reading beyond the end.  This allows
-	 * us to read the whole NVM from any offset */
-	for (i = 0; i < words; i++) {
-		word_in = e1000_shift_in_eec_bits(hw, 16);
-		data[i] = (word_in >> 8) | (word_in << 8);
-	}
-
-	nvm->ops.release_nvm(hw);
-	return 0;
-}
-
-/**
  *  e1000e_read_nvm_eerd - Reads EEPROM using EERD register
  *  @hw: pointer to the HW structure
  *  @offset: offset of word in the EEPROM to read

