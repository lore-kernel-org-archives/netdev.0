From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] e1000e: cleanup: use goto for common work needed by multiple exit points
Date: Mon, 13 Feb 2012 13:47:36 -0800
Message-ID: <1329169670-5403-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3407 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754393Ab2BMVrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 16:47:55 -0500
In-Reply-To: <1329169670-5403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

There are two exit points of e1000e_write_nvm_spi() which require the
nvm->ops.release() function pointer called just before exiting.
Consolidate the two duplicate pieces of common work with a goto.  With
this change, the value ret_val will need to be returned instead of 0.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/nvm.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/nvm.c b/drivers/net/ethernet/intel/e1000e/nvm.c
index f6fb7a7..1b50db5 100644
--- a/drivers/net/ethernet/intel/e1000e/nvm.c
+++ b/drivers/net/ethernet/intel/e1000e/nvm.c
@@ -382,10 +382,8 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		u8 write_opcode = NVM_WRITE_OPCODE_SPI;
 
 		ret_val = e1000_ready_nvm_eeprom(hw);
-		if (ret_val) {
-			nvm->ops.release(hw);
-			return ret_val;
-		}
+		if (ret_val)
+			goto release;
 
 		e1000_standby_nvm(hw);
 
@@ -422,8 +420,10 @@ s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 	}
 
 	usleep_range(10000, 20000);
+release:
 	nvm->ops.release(hw);
-	return 0;
+
+	return ret_val;
 }
 
 /**
-- 
1.7.7.6
