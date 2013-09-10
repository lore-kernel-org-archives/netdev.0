From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] igb: Read flow control for i350 from correct EEPROM section
Date: Tue, 10 Sep 2013 11:57:17 -0700
Message-ID: <1378839437-10965-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1378839437-10965-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Fujinaka, Todd" <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16614 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750974Ab3IJS5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 14:57:20 -0400
In-Reply-To: <1378839437-10965-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Fujinaka, Todd" <todd.fujinaka@intel.com>

Flow control is defined in the four EEPROM sections but the driver only reads
from section 0.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_mac.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index f0dfd41..298f0ed 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -712,6 +712,7 @@ static s32 igb_set_fc_watermarks(struct e1000_hw *hw)
 static s32 igb_set_default_fc(struct e1000_hw *hw)
 {
 	s32 ret_val = 0;
+	u16 lan_offset;
 	u16 nvm_data;
 
 	/* Read and store word 0x0F of the EEPROM. This word contains bits
@@ -722,7 +723,14 @@ static s32 igb_set_default_fc(struct e1000_hw *hw)
 	 * control setting, then the variable hw->fc will
 	 * be initialized based on a value in the EEPROM.
 	 */
-	ret_val = hw->nvm.ops.read(hw, NVM_INIT_CONTROL2_REG, 1, &nvm_data);
+	if (hw->mac.type == e1000_i350) {
+		lan_offset = NVM_82580_LAN_FUNC_OFFSET(hw->bus.func);
+		ret_val = hw->nvm.ops.read(hw, NVM_INIT_CONTROL2_REG
+					   + lan_offset, 1, &nvm_data);
+	 } else {
+		ret_val = hw->nvm.ops.read(hw, NVM_INIT_CONTROL2_REG,
+					   1, &nvm_data);
+	 }
 
 	if (ret_val) {
 		hw_dbg("NVM Read Error\n");
-- 
1.8.3.1
