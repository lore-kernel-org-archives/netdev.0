From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 05/12] e1000e: cleanup multiple common exit points
Date: Mon, 10 May 2010 18:00:31 -0700
Message-ID: <20100511010029.30827.82837.stgit@localhost.localdomain>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:33409
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757406Ab0EKBAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 21:00:48 -0400
In-Reply-To: <20100511005801.30827.50808.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

...in e1000_update_nvm_checksum_ich8lan().

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   41 +++++++++++++++++------------------------
 1 files changed, 17 insertions(+), 24 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index b8c4dce..448e123 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1938,18 +1938,14 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		new_bank_offset = nvm->flash_bank_size;
 		old_bank_offset = 0;
 		ret_val = e1000_erase_flash_bank_ich8lan(hw, 1);
-		if (ret_val) {
-			nvm->ops.release(hw);
-			goto out;
-		}
+		if (ret_val)
+			goto release;
 	} else {
 		old_bank_offset = nvm->flash_bank_size;
 		new_bank_offset = 0;
 		ret_val = e1000_erase_flash_bank_ich8lan(hw, 0);
-		if (ret_val) {
-			nvm->ops.release(hw);
-			goto out;
-		}
+		if (ret_val)
+			goto release;
 	}
 
 	for (i = 0; i < E1000_ICH8_SHADOW_RAM_WORDS; i++) {
@@ -2005,8 +2001,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	if (ret_val) {
 		/* Possibly read-only, see e1000e_write_protect_nvm_ich8lan() */
 		e_dbg("Flash commit failed.\n");
-		nvm->ops.release(hw);
-		goto out;
+		goto release;
 	}
 
 	/*
@@ -2017,18 +2012,15 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	 */
 	act_offset = new_bank_offset + E1000_ICH_NVM_SIG_WORD;
 	ret_val = e1000_read_flash_word_ich8lan(hw, act_offset, &data);
-	if (ret_val) {
-		nvm->ops.release(hw);
-		goto out;
-	}
+	if (ret_val)
+		goto release;
+
 	data &= 0xBFFF;
 	ret_val = e1000_retry_write_flash_byte_ich8lan(hw,
 						       act_offset * 2 + 1,
 						       (u8)(data >> 8));
-	if (ret_val) {
-		nvm->ops.release(hw);
-		goto out;
-	}
+	if (ret_val)
+		goto release;
 
 	/*
 	 * And invalidate the previously valid segment by setting
@@ -2038,10 +2030,8 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	 */
 	act_offset = (old_bank_offset + E1000_ICH_NVM_SIG_WORD) * 2 + 1;
 	ret_val = e1000_retry_write_flash_byte_ich8lan(hw, act_offset, 0);
-	if (ret_val) {
-		nvm->ops.release(hw);
-		goto out;
-	}
+	if (ret_val)
+		goto release;
 
 	/* Great!  Everything worked, we can now clear the cached entries. */
 	for (i = 0; i < E1000_ICH8_SHADOW_RAM_WORDS; i++) {
@@ -2049,14 +2039,17 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		dev_spec->shadow_ram[i].value = 0xFFFF;
 	}
 
+release:
 	nvm->ops.release(hw);
 
 	/*
 	 * Reload the EEPROM, or else modifications will not appear
 	 * until after the next adapter reset.
 	 */
-	e1000e_reload_nvm(hw);
-	msleep(10);
+	if (!ret_val) {
+		e1000e_reload_nvm(hw);
+		msleep(10);
+	}
 
 out:
 	if (ret_val)

