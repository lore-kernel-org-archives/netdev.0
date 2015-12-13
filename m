From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/17] e1000e: initial support for i219-LM (3)
Date: Sun, 13 Dec 2015 00:31:30 -0800
Message-ID: <1449995490-17020-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Raanan Avargil <raanan.avargil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4841 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbbLMIbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 03:31:38 -0500
In-Reply-To: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raanan Avargil <raanan.avargil@intel.com>

i219-LM (3) is a LOM that will be available on systems with the
Lewisburg Platform Controller Hub (PCH) chipset from Intel.
This patch provides the initial support for the device.

Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/hw.h      |  1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 43 +++++++++++++++++++++--------
 drivers/net/ethernet/intel/e1000e/netdev.c  |  1 +
 3 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index c9da465..b3949d5 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -91,6 +91,7 @@ struct e1000_hw;
 #define E1000_DEV_ID_PCH_SPT_I219_V		0x1570	/* SPT PCH */
 #define E1000_DEV_ID_PCH_SPT_I219_LM2		0x15B7	/* SPT-H PCH */
 #define E1000_DEV_ID_PCH_SPT_I219_V2		0x15B8	/* SPT-H PCH */
+#define E1000_DEV_ID_PCH_LBG_I219_LM3		0x15B9	/* LBG PCH */
 
 #define E1000_REVISION_4	4
 
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 64c1f36..a049e30 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -3093,24 +3093,45 @@ static s32 e1000_valid_nvm_bank_detect_ich8lan(struct e1000_hw *hw, u32 *bank)
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	u32 bank1_offset = nvm->flash_bank_size * sizeof(u16);
 	u32 act_offset = E1000_ICH_NVM_SIG_WORD * 2 + 1;
+	u32 nvm_dword = 0;
 	u8 sig_byte = 0;
 	s32 ret_val;
 
 	switch (hw->mac.type) {
-		/* In SPT, read from the CTRL_EXT reg instead of
-		 * accessing the sector valid bits from the nvm
-		 */
 	case e1000_pch_spt:
-		*bank = er32(CTRL_EXT)
-		    & E1000_CTRL_EXT_NVMVS;
-		if ((*bank == 0) || (*bank == 1)) {
-			e_dbg("ERROR: No valid NVM bank present\n");
-			return -E1000_ERR_NVM;
-		} else {
-			*bank = *bank - 2;
+		bank1_offset = nvm->flash_bank_size;
+		act_offset = E1000_ICH_NVM_SIG_WORD;
+
+		/* set bank to 0 in case flash read fails */
+		*bank = 0;
+
+		/* Check bank 0 */
+		ret_val = e1000_read_flash_dword_ich8lan(hw, act_offset,
+							 &nvm_dword);
+		if (ret_val)
+			return ret_val;
+		sig_byte = (u8)((nvm_dword & 0xFF00) >> 8);
+		if ((sig_byte & E1000_ICH_NVM_VALID_SIG_MASK) ==
+		    E1000_ICH_NVM_SIG_VALUE) {
+			*bank = 0;
 			return 0;
 		}
-		break;
+
+		/* Check bank 1 */
+		ret_val = e1000_read_flash_dword_ich8lan(hw, act_offset +
+							 bank1_offset,
+							 &nvm_dword);
+		if (ret_val)
+			return ret_val;
+		sig_byte = (u8)((nvm_dword & 0xFF00) >> 8);
+		if ((sig_byte & E1000_ICH_NVM_VALID_SIG_MASK) ==
+		    E1000_ICH_NVM_SIG_VALUE) {
+			*bank = 1;
+			return 0;
+		}
+
+		e_dbg("ERROR: No valid NVM bank present\n");
+		return -E1000_ERR_NVM;
 	case e1000_ich8lan:
 	case e1000_ich9lan:
 		eecd = er32(EECD);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 7724473..775e389 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -7467,6 +7467,7 @@ static const struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_SPT_I219_V), board_pch_spt },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_SPT_I219_LM2), board_pch_spt },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_SPT_I219_V2), board_pch_spt },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_LBG_I219_LM3), board_pch_spt },
 
 	{ 0, 0, 0, 0, 0, 0, 0 }	/* terminate list */
 };
-- 
2.5.0
