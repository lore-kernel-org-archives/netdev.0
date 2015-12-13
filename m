From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/17] igb: use the correct i210 register for EEMNGCTL
Date: Sun, 13 Dec 2015 00:31:19 -0800
Message-ID: <1449995490-17020-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:41148 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496AbbLMIlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 03:41:03 -0500
In-Reply-To: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

The i210 has two EEPROM access registers that are located in
non-standard offsets: EEARBC and EEMNGCTL. EEARBC was fixed previously
and EEMNGCTL should also be corrected.

Reported-by: Roman Hodek <roman.aud@siemens.com>
Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |  1 +
 drivers/net/ethernet/intel/igb/e1000_i210.c  | 27 +++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/e1000_i210.h  |  1 +
 drivers/net/ethernet/intel/igb/e1000_regs.h  |  1 +
 4 files changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index d9664c4..362911d 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -299,6 +299,7 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
 	case I210_I_PHY_ID:
 		phy->type		= e1000_phy_i210;
 		phy->ops.check_polarity	= igb_check_polarity_m88;
+		phy->ops.get_cfg_done	= igb_get_cfg_done_i210;
 		phy->ops.get_phy_info	= igb_get_phy_info_m88;
 		phy->ops.get_cable_length = igb_get_cable_length_m88_gen2;
 		phy->ops.set_d0_lplu_state = igb_set_d0_lplu_state_82580;
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index 65d9316..29f59c7 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -900,3 +900,30 @@ s32 igb_pll_workaround_i210(struct e1000_hw *hw)
 	wr32(E1000_MDICNFG, mdicnfg);
 	return ret_val;
 }
+
+/**
+ *  igb_get_cfg_done_i210 - Read config done bit
+ *  @hw: pointer to the HW structure
+ *
+ *  Read the management control register for the config done bit for
+ *  completion status.  NOTE: silicon which is EEPROM-less will fail trying
+ *  to read the config done bit, so an error is *ONLY* logged and returns
+ *  0.  If we were to return with error, EEPROM-less silicon
+ *  would not be able to be reset or change link.
+ **/
+s32 igb_get_cfg_done_i210(struct e1000_hw *hw)
+{
+	s32 timeout = PHY_CFG_TIMEOUT;
+	u32 mask = E1000_NVM_CFG_DONE_PORT_0;
+
+	while (timeout) {
+		if (rd32(E1000_EEMNGCTL_I210) & mask)
+			break;
+		usleep_range(1000, 2000);
+		timeout--;
+	}
+	if (!timeout)
+		hw_dbg("MNG configuration cycle has not completed.\n");
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.h b/drivers/net/ethernet/intel/igb/e1000_i210.h
index 3442b63..eaa68a5 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.h
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.h
@@ -34,6 +34,7 @@ s32 igb_write_xmdio_reg(struct e1000_hw *hw, u16 addr, u8 dev_addr, u16 data);
 s32 igb_init_nvm_params_i210(struct e1000_hw *hw);
 bool igb_get_flash_presence_i210(struct e1000_hw *hw);
 s32 igb_pll_workaround_i210(struct e1000_hw *hw);
+s32 igb_get_cfg_done_i210(struct e1000_hw *hw);
 
 #define E1000_STM_OPCODE		0xDB00
 #define E1000_EEPROM_FLASH_SIZE_WORD	0x11
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 4af2870..0fdcd4d 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -66,6 +66,7 @@
 #define E1000_PBA      0x01000  /* Packet Buffer Allocation - RW */
 #define E1000_PBS      0x01008  /* Packet Buffer Size */
 #define E1000_EEMNGCTL 0x01010  /* MNG EEprom Control */
+#define E1000_EEMNGCTL_I210 0x12030  /* MNG EEprom Control */
 #define E1000_EEARBC_I210 0x12024  /* EEPROM Auto Read Bus Control */
 #define E1000_EEWR     0x0102C  /* EEPROM Write Register - RW */
 #define E1000_I2CCMD   0x01028  /* SFPI2C Command Register - RW */
-- 
2.5.0
