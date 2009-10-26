From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 4/5] e1000e: separate mutex usage between NVM and
	PHY/CSR register for ICHx/PCH
Date: Mon, 26 Oct 2009 14:23:43 -0700
Message-ID: <20091026212343.9682.56885.stgit@localhost.localdomain>
References: <20091026212242.9682.25442.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:41640 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753446AbZJZV1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 17:27:18 -0400
In-Reply-To: <20091026212242.9682.25442.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Accesses to NVM and PHY/CSR registers on ICHx/PCH-based parts are protected
from concurrent accesses with a mutex that is acquired when the access is
initiated and released when the access has completed.  However, the two
types of accesses should not be protected by the same mutex because the
driver may have to access the NVM while already holding the mutex over
several consecutive PHY/CSR accesses which would result in livelock.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   89 +++++++++++++++++++++++++++---------------
 1 files changed, 58 insertions(+), 31 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 2451dc8..aaaaf2c 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -578,12 +578,39 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 static DEFINE_MUTEX(nvm_mutex);
 
 /**
+ *  e1000_acquire_nvm_ich8lan - Acquire NVM mutex
+ *  @hw: pointer to the HW structure
+ *
+ *  Acquires the mutex for performing NVM operations.
+ **/
+static s32 e1000_acquire_nvm_ich8lan(struct e1000_hw *hw)
+{
+	mutex_lock(&nvm_mutex);
+
+	return 0;
+}
+
+/**
+ *  e1000_release_nvm_ich8lan - Release NVM mutex
+ *  @hw: pointer to the HW structure
+ *
+ *  Releases the mutex used while performing NVM operations.
+ **/
+static void e1000_release_nvm_ich8lan(struct e1000_hw *hw)
+{
+	mutex_unlock(&nvm_mutex);
+
+	return;
+}
+
+static DEFINE_MUTEX(swflag_mutex);
+
+/**
  *  e1000_acquire_swflag_ich8lan - Acquire software control flag
  *  @hw: pointer to the HW structure
  *
- *  Acquires the software control flag for performing NVM and PHY
- *  operations.  This is a function pointer entry point only called by
- *  read/write routines for the PHY and NVM parts.
+ *  Acquires the software control flag for performing PHY and select
+ *  MAC CSR accesses.
  **/
 static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 {
@@ -592,7 +619,7 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 
 	might_sleep();
 
-	mutex_lock(&nvm_mutex);
+	mutex_lock(&swflag_mutex);
 
 	while (timeout) {
 		extcnf_ctrl = er32(EXTCNF_CTRL);
@@ -633,7 +660,7 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 
 out:
 	if (ret_val)
-		mutex_unlock(&nvm_mutex);
+		mutex_unlock(&swflag_mutex);
 
 	return ret_val;
 }
@@ -642,9 +669,8 @@ out:
  *  e1000_release_swflag_ich8lan - Release software control flag
  *  @hw: pointer to the HW structure
  *
- *  Releases the software control flag for performing NVM and PHY operations.
- *  This is a function pointer entry point only called by read/write
- *  routines for the PHY and NVM parts.
+ *  Releases the software control flag for performing PHY and select
+ *  MAC CSR accesses.
  **/
 static void e1000_release_swflag_ich8lan(struct e1000_hw *hw)
 {
@@ -654,7 +680,9 @@ static void e1000_release_swflag_ich8lan(struct e1000_hw *hw)
 	extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
 	ew32(EXTCNF_CTRL, extcnf_ctrl);
 
-	mutex_unlock(&nvm_mutex);
+	mutex_unlock(&swflag_mutex);
+
+	return;
 }
 
 /**
@@ -1360,12 +1388,11 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 	if ((offset >= nvm->word_size) || (words > nvm->word_size - offset) ||
 	    (words == 0)) {
 		hw_dbg(hw, "nvm parameter(s) out of bounds\n");
-		return -E1000_ERR_NVM;
+		ret_val = -E1000_ERR_NVM;
+		goto out;
 	}
 
-	ret_val = e1000_acquire_swflag_ich8lan(hw);
-	if (ret_val)
-		goto out;
+	nvm->ops.acquire_nvm(hw);
 
 	ret_val = e1000_valid_nvm_bank_detect_ich8lan(hw, &bank);
 	if (ret_val) {
@@ -1391,7 +1418,7 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 		}
 	}
 
-	e1000_release_swflag_ich8lan(hw);
+	nvm->ops.release_nvm(hw);
 
 out:
 	if (ret_val)
@@ -1649,11 +1676,15 @@ static s32 e1000_write_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 		return -E1000_ERR_NVM;
 	}
 
+	nvm->ops.acquire_nvm(hw);
+
 	for (i = 0; i < words; i++) {
 		dev_spec->shadow_ram[offset+i].modified = 1;
 		dev_spec->shadow_ram[offset+i].value = data[i];
 	}
 
+	nvm->ops.release_nvm(hw);
+
 	return 0;
 }
 
@@ -1683,9 +1714,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	if (nvm->type != e1000_nvm_flash_sw)
 		goto out;
 
-	ret_val = e1000_acquire_swflag_ich8lan(hw);
-	if (ret_val)
-		goto out;
+	nvm->ops.acquire_nvm(hw);
 
 	/*
 	 * We're writing to the opposite bank so if we're on bank 1,
@@ -1703,7 +1732,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		old_bank_offset = 0;
 		ret_val = e1000_erase_flash_bank_ich8lan(hw, 1);
 		if (ret_val) {
-			e1000_release_swflag_ich8lan(hw);
+			nvm->ops.release_nvm(hw);
 			goto out;
 		}
 	} else {
@@ -1711,7 +1740,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		new_bank_offset = 0;
 		ret_val = e1000_erase_flash_bank_ich8lan(hw, 0);
 		if (ret_val) {
-			e1000_release_swflag_ich8lan(hw);
+			nvm->ops.release_nvm(hw);
 			goto out;
 		}
 	}
@@ -1769,7 +1798,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	if (ret_val) {
 		/* Possibly read-only, see e1000e_write_protect_nvm_ich8lan() */
 		hw_dbg(hw, "Flash commit failed.\n");
-		e1000_release_swflag_ich8lan(hw);
+		nvm->ops.release_nvm(hw);
 		goto out;
 	}
 
@@ -1782,7 +1811,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	act_offset = new_bank_offset + E1000_ICH_NVM_SIG_WORD;
 	ret_val = e1000_read_flash_word_ich8lan(hw, act_offset, &data);
 	if (ret_val) {
-		e1000_release_swflag_ich8lan(hw);
+		nvm->ops.release_nvm(hw);
 		goto out;
 	}
 	data &= 0xBFFF;
@@ -1790,7 +1819,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 						       act_offset * 2 + 1,
 						       (u8)(data >> 8));
 	if (ret_val) {
-		e1000_release_swflag_ich8lan(hw);
+		nvm->ops.release_nvm(hw);
 		goto out;
 	}
 
@@ -1803,7 +1832,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	act_offset = (old_bank_offset + E1000_ICH_NVM_SIG_WORD) * 2 + 1;
 	ret_val = e1000_retry_write_flash_byte_ich8lan(hw, act_offset, 0);
 	if (ret_val) {
-		e1000_release_swflag_ich8lan(hw);
+		nvm->ops.release_nvm(hw);
 		goto out;
 	}
 
@@ -1813,7 +1842,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		dev_spec->shadow_ram[i].value = 0xFFFF;
 	}
 
-	e1000_release_swflag_ich8lan(hw);
+	nvm->ops.release_nvm(hw);
 
 	/*
 	 * Reload the EEPROM, or else modifications will not appear
@@ -1877,14 +1906,12 @@ static s32 e1000_validate_nvm_checksum_ich8lan(struct e1000_hw *hw)
  **/
 void e1000e_write_protect_nvm_ich8lan(struct e1000_hw *hw)
 {
+	struct e1000_nvm_info *nvm = &hw->nvm;
 	union ich8_flash_protected_range pr0;
 	union ich8_hws_flash_status hsfsts;
 	u32 gfpreg;
-	s32 ret_val;
 
-	ret_val = e1000_acquire_swflag_ich8lan(hw);
-	if (ret_val)
-		return;
+	nvm->ops.acquire_nvm(hw);
 
 	gfpreg = er32flash(ICH_FLASH_GFPREG);
 
@@ -1905,7 +1932,7 @@ void e1000e_write_protect_nvm_ich8lan(struct e1000_hw *hw)
 	hsfsts.hsf_status.flockdn = true;
 	ew32flash(ICH_FLASH_HSFSTS, hsfsts.regval);
 
-	e1000_release_swflag_ich8lan(hw);
+	nvm->ops.release_nvm(hw);
 }
 
 /**
@@ -3162,9 +3189,9 @@ static struct e1000_phy_operations ich8_phy_ops = {
 };
 
 static struct e1000_nvm_operations ich8_nvm_ops = {
-	.acquire_nvm		= e1000_acquire_swflag_ich8lan,
+	.acquire_nvm		= e1000_acquire_nvm_ich8lan,
 	.read_nvm	 	= e1000_read_nvm_ich8lan,
-	.release_nvm		= e1000_release_swflag_ich8lan,
+	.release_nvm		= e1000_release_nvm_ich8lan,
 	.update_nvm		= e1000_update_nvm_checksum_ich8lan,
 	.valid_led_default	= e1000_valid_led_default_ich8lan,
 	.validate_nvm		= e1000_validate_nvm_checksum_ich8lan,

