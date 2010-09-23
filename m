From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/6] e1000e: 82577/8/9 issues with device in Sx
Date: Wed, 22 Sep 2010 20:15:08 -0700
Message-ID: <20100923031432.10976.81909.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:46092
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751217Ab0IWDPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 23:15:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When going to Sx, disable gigabit in PHY (e1000_oem_bits_config_ich8lan)
in addition to the MAC before configuring PHY wakeup otherwise the PHY
configuration writes might be missed.  Also write the LED configuration
and SMBus address to the PHY registers (e1000_oem_bits_config_ich8lan and
e1000_write_smbus_addr, respectively).  The reset is no longer needed
since re-auto-negotiation is forced in e1000_oem_bits_config_ich8lan and
leaving it in causes issues with auto-negotiating the link.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   47 +++++++++++++++++++++++++++++++++++-------
 1 files changed, 39 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 63930d1..822de48 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -125,6 +125,7 @@
 
 /* SMBus Address Phy Register */
 #define HV_SMB_ADDR            PHY_REG(768, 26)
+#define HV_SMB_ADDR_MASK       0x007F
 #define HV_SMB_ADDR_PEC_EN     0x0200
 #define HV_SMB_ADDR_VALID      0x0080
 
@@ -895,6 +896,34 @@ static s32 e1000_check_reset_block_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_write_smbus_addr - Write SMBus address to PHY needed during Sx states
+ *  @hw: pointer to the HW structure
+ *
+ *  Assumes semaphore already acquired.
+ *
+ **/
+static s32 e1000_write_smbus_addr(struct e1000_hw *hw)
+{
+	u16 phy_data;
+	u32 strap = er32(STRAP);
+	s32 ret_val = 0;
+
+	strap &= E1000_STRAP_SMBUS_ADDRESS_MASK;
+
+	ret_val = e1000_read_phy_reg_hv_locked(hw, HV_SMB_ADDR, &phy_data);
+	if (ret_val)
+		goto out;
+
+	phy_data &= ~HV_SMB_ADDR_MASK;
+	phy_data |= (strap >> E1000_STRAP_SMBUS_ADDRESS_SHIFT);
+	phy_data |= HV_SMB_ADDR_PEC_EN | HV_SMB_ADDR_VALID;
+	ret_val = e1000_write_phy_reg_hv_locked(hw, HV_SMB_ADDR, phy_data);
+
+out:
+	return ret_val;
+}
+
+/**
  *  e1000_sw_lcd_config_ich8lan - SW-based LCD Configuration
  *  @hw:   pointer to the HW structure
  *
@@ -970,12 +999,7 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 		 * When both NVM bits are cleared, SW will configure
 		 * them instead.
 		 */
-		data = er32(STRAP);
-		data &= E1000_STRAP_SMBUS_ADDRESS_MASK;
-		reg_data = data >> E1000_STRAP_SMBUS_ADDRESS_SHIFT;
-		reg_data |= HV_SMB_ADDR_PEC_EN | HV_SMB_ADDR_VALID;
-		ret_val = e1000_write_phy_reg_hv_locked(hw, HV_SMB_ADDR,
-							reg_data);
+		ret_val = e1000_write_smbus_addr(hw);
 		if (ret_val)
 			goto out;
 
@@ -3460,13 +3484,20 @@ void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw)
 void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
 {
 	u32 phy_ctrl;
+	s32 ret_val;
 
 	phy_ctrl = er32(PHY_CTRL);
 	phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU | E1000_PHY_CTRL_GBE_DISABLE;
 	ew32(PHY_CTRL, phy_ctrl);
 
-	if (hw->mac.type >= e1000_pchlan)
-		e1000_phy_hw_reset_ich8lan(hw);
+	if (hw->mac.type >= e1000_pchlan) {
+		e1000_oem_bits_config_ich8lan(hw, true);
+		ret_val = hw->phy.ops.acquire(hw);
+		if (ret_val)
+			return;
+		e1000_write_smbus_addr(hw);
+		hw->phy.ops.release(hw);
+	}
 }
 
 /**

