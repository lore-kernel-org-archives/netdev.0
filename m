From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] igb: Updates to read nvm function for i211 device
Date: Sat,  1 Dec 2012 03:53:30 -0800
Message-ID: <1354362817-26168-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354362817-26168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21302 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751808Ab2LALx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 06:53:58 -0500
In-Reply-To: <1354362817-26168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

The i211 has an integrated secure space to store configuration information that is
usually stored in an EEPROM or flash type device. This patch updates the
read functions to return values or appropriate error codes to prevent
unnecessary init failures on some configuration schemes.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_i210.c | 32 +++++++++++++++++++++++++----
 drivers/net/ethernet/intel/igb/e1000_i210.h |  6 ++++++
 2 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index 4147429..239650e 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -350,16 +350,40 @@ s32 igb_read_nvm_i211(struct e1000_hw *hw, u16 offset, u16 words,
 		if (ret_val != E1000_SUCCESS)
 			hw_dbg("MAC Addr not found in iNVM\n");
 		break;
-	case NVM_ID_LED_SETTINGS:
 	case NVM_INIT_CTRL_2:
+		ret_val = igb_read_invm_i211(hw, (u8)offset, data);
+		if (ret_val != E1000_SUCCESS) {
+			*data = NVM_INIT_CTRL_2_DEFAULT_I211;
+			ret_val = E1000_SUCCESS;
+		}
+		break;
 	case NVM_INIT_CTRL_4:
+		ret_val = igb_read_invm_i211(hw, (u8)offset, data);
+		if (ret_val != E1000_SUCCESS) {
+			*data = NVM_INIT_CTRL_4_DEFAULT_I211;
+			ret_val = E1000_SUCCESS;
+		}
+		break;
 	case NVM_LED_1_CFG:
+		ret_val = igb_read_invm_i211(hw, (u8)offset, data);
+		if (ret_val != E1000_SUCCESS) {
+			*data = NVM_LED_1_CFG_DEFAULT_I211;
+			ret_val = E1000_SUCCESS;
+		}
+		break;
 	case NVM_LED_0_2_CFG:
 		igb_read_invm_i211(hw, offset, data);
+		if (ret_val != E1000_SUCCESS) {
+			*data = NVM_LED_0_2_CFG_DEFAULT_I211;
+			ret_val = E1000_SUCCESS;
+		}
 		break;
-	case NVM_COMPAT:
-		*data = ID_LED_DEFAULT_I210;
-		break;
+	case NVM_ID_LED_SETTINGS:
+		ret_val = igb_read_invm_i211(hw, (u8)offset, data);
+		if (ret_val != E1000_SUCCESS) {
+			*data = ID_LED_RESERVED_FFFF;
+			ret_val = E1000_SUCCESS;
+		}
 	case NVM_SUB_DEV_ID:
 		*data = hw->subsystem_device_id;
 		break;
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.h b/drivers/net/ethernet/intel/igb/e1000_i210.h
index 974d235..1c89358 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.h
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.h
@@ -84,4 +84,10 @@ enum E1000_INVM_STRUCTURE_TYPE {
 					 (ID_LED_DEF1_DEF2 <<  4) | \
 					 (ID_LED_DEF1_DEF2))
 
+/* NVM offset defaults for i211 device */
+#define NVM_INIT_CTRL_2_DEFAULT_I211	0X7243
+#define NVM_INIT_CTRL_4_DEFAULT_I211	0x00C1
+#define NVM_LED_1_CFG_DEFAULT_I211	0x0184
+#define NVM_LED_0_2_CFG_DEFAULT_I211	0x200C
+
 #endif
-- 
1.7.11.7
