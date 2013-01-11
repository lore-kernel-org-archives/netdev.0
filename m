From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] e1000e: Invalid Image CSUM bit changed for I217
Date: Fri, 11 Jan 2013 02:23:39 -0800
Message-ID: <1357899831-4168-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35178 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753456Ab3AKKX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 05:23:58 -0500
In-Reply-To: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

On I217, the bit that indicates an invalid EEPROM (NVM) image checksum has
changed from previous ICH/PCH LOMs.  When validating the EEPROM checksum,
check the appropriate bit on different devices.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h |  4 ++++
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 29 +++++++++++++++++++++--------
 2 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index 2073532..7326ea2 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -639,6 +639,10 @@
 /* NVM Word Offsets */
 #define NVM_COMPAT                 0x0003
 #define NVM_ID_LED_SETTINGS        0x0004
+#define NVM_FUTURE_INIT_WORD1      0x0019
+#define NVM_COMPAT_VALID_CSUM      0x0001
+#define NVM_FUTURE_INIT_WORD1_VALID_CSUM	0x0040
+
 #define NVM_INIT_CONTROL2_REG      0x000F
 #define NVM_INIT_CONTROL3_PORT_B   0x0014
 #define NVM_INIT_3GIO_3            0x001A
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 9763365..7d5f6b7 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2949,19 +2949,32 @@ static s32 e1000_validate_nvm_checksum_ich8lan(struct e1000_hw *hw)
 {
 	s32 ret_val;
 	u16 data;
+	u16 word;
+	u16 valid_csum_mask;
 
-	/* Read 0x19 and check bit 6.  If this bit is 0, the checksum
-	 * needs to be fixed.  This bit is an indication that the NVM
-	 * was prepared by OEM software and did not calculate the
-	 * checksum...a likely scenario.
+	/* Read NVM and check Invalid Image CSUM bit.  If this bit is 0,
+	 * the checksum needs to be fixed.  This bit is an indication that
+	 * the NVM was prepared by OEM software and did not calculate
+	 * the checksum...a likely scenario.
 	 */
-	ret_val = e1000_read_nvm(hw, 0x19, 1, &data);
+	switch (hw->mac.type) {
+	case e1000_pch_lpt:
+		word = NVM_COMPAT;
+		valid_csum_mask = NVM_COMPAT_VALID_CSUM;
+		break;
+	default:
+		word = NVM_FUTURE_INIT_WORD1;
+		valid_csum_mask = NVM_FUTURE_INIT_WORD1_VALID_CSUM;
+		break;
+	}
+
+	ret_val = e1000_read_nvm(hw, word, 1, &data);
 	if (ret_val)
 		return ret_val;
 
-	if (!(data & 0x40)) {
-		data |= 0x40;
-		ret_val = e1000_write_nvm(hw, 0x19, 1, &data);
+	if (!(data & valid_csum_mask)) {
+		data |= valid_csum_mask;
+		ret_val = e1000_write_nvm(hw, word, 1, &data);
 		if (ret_val)
 			return ret_val;
 		ret_val = e1000e_update_nvm_checksum(hw);
-- 
1.7.11.7
