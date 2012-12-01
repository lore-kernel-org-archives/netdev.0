From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] igb: Acquire, release semaphore for writing each EEPROM page
Date: Sat,  1 Dec 2012 03:53:31 -0800
Message-ID: <1354362817-26168-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354362817-26168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21302 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928Ab2LALx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 06:53:57 -0500
In-Reply-To: <1354362817-26168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch allows software acquires and releases NVM resource for
writing each EEPROM page, instead of holding semaphore for the whole
data block which is too long and could trigger write fails on
unpredictable addresses.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_nvm.c | 28 ++++++++++++----------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_nvm.c b/drivers/net/ethernet/intel/igb/e1000_nvm.c
index 7db3f80..fbb7604 100644
--- a/drivers/net/ethernet/intel/igb/e1000_nvm.c
+++ b/drivers/net/ethernet/intel/igb/e1000_nvm.c
@@ -438,7 +438,7 @@ out:
 s32 igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
-	s32 ret_val;
+	s32 ret_val = -E1000_ERR_NVM;
 	u16 widx = 0;
 
 	/*
@@ -448,22 +448,21 @@ s32 igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
 	    (words == 0)) {
 		hw_dbg("nvm parameter(s) out of bounds\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
+		return ret_val;
 	}
 
-	ret_val = hw->nvm.ops.acquire(hw);
-	if (ret_val)
-		goto out;
-
-	msleep(10);
-
 	while (widx < words) {
 		u8 write_opcode = NVM_WRITE_OPCODE_SPI;
 
-		ret_val = igb_ready_nvm_eeprom(hw);
+		ret_val = nvm->ops.acquire(hw);
 		if (ret_val)
-			goto release;
+			return ret_val;
+
+		ret_val = igb_ready_nvm_eeprom(hw);
+		if (ret_val) {
+			nvm->ops.release(hw);
+			return ret_val;
+		}
 
 		igb_standby_nvm(hw);
 
@@ -497,13 +496,10 @@ s32 igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 				break;
 			}
 		}
+		usleep_range(1000, 2000);
+		nvm->ops.release(hw);
 	}
 
-	msleep(10);
-release:
-	hw->nvm.ops.release(hw);
-
-out:
 	return ret_val;
 }
 
-- 
1.7.11.7
