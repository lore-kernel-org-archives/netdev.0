From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] e1000e: Acquire/release semaphore when writing each EEPROM page
Date: Fri, 11 Jan 2013 02:23:38 -0800
Message-ID: <1357899831-4168-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35178 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753137Ab3AKKX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 05:23:57 -0500
In-Reply-To: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When data blocks are written to the EEPROM, the HW/SW/FW semaphore must be
held for the duration.  With large data blocks on 80003es2lan, 82571 and
82572, this can take too long and cause the firmware to take ownership of
the semaphore and consequently ownership of writes to the EEPROM.
Instead, acquire and release the semaphore for each page of the block
written.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/nvm.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/nvm.c b/drivers/net/ethernet/intel/e1000e/nvm.c
index b646880..71938ed 100644
--- a/drivers/net/ethernet/intel/e1000e/nvm.c
+++ b/drivers/net/ethernet/intel/e1000e/nvm.c
@@ -359,7 +359,7 @@ s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
-	s32 ret_val;
+	s32 ret_val = -E1000_ERR_NVM;
 	u16 widx = 0;
 
 	/* A check for invalid values:  offset too large, too many words,
@@ -371,16 +371,18 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		return -E1000_ERR_NVM;
 	}
 
-	ret_val = nvm->ops.acquire(hw);
-	if (ret_val)
-		return ret_val;
-
 	while (widx < words) {
 		u8 write_opcode = NVM_WRITE_OPCODE_SPI;
 
-		ret_val = e1000_ready_nvm_eeprom(hw);
+		ret_val = nvm->ops.acquire(hw);
 		if (ret_val)
-			goto release;
+			return ret_val;
+
+		ret_val = e1000_ready_nvm_eeprom(hw);
+		if (ret_val) {
+			nvm->ops.release(hw);
+			return ret_val;
+		}
 
 		e1000_standby_nvm(hw);
 
@@ -413,12 +415,10 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 				break;
 			}
 		}
+		usleep_range(10000, 20000);
+		nvm->ops.release(hw);
 	}
 
-	usleep_range(10000, 20000);
-release:
-	nvm->ops.release(hw);
-
 	return ret_val;
 }
 
-- 
1.7.11.7
