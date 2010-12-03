From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] ixgbe: fix for link failure on SFP+ DA cables
Date: Fri, 03 Dec 2010 15:23:30 -0800
Message-ID: <20101203232218.21869.62349.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:47105
	"EHLO qmta04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753873Ab0LCXXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 18:23:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch helps prevent FW/SW semaphore collision from leading
to link establishment failure.  The collision might mess up the
PHY registers so we reset the PHY.  However there are SFI/KR areas
in the PHY that are not reset with a Reset_AN so we need to change
LMS to reset it.  Also wait until AN state machine is AN_GOOD

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |   28 +++++++++++++++++++++++++---
 drivers/net/ixgbe/ixgbe_type.h  |    3 +++
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 385cceb..6827ddd 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -96,6 +96,8 @@ static void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 static s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 {
 	s32 ret_val = 0;
+	u32 reg_anlp1 = 0;
+	u32 i = 0;
 	u16 list_offset, data_offset, data_value;
 
 	if (hw->phy.sfp_type != ixgbe_sfp_type_unknown) {
@@ -122,14 +124,34 @@ static s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 			IXGBE_WRITE_FLUSH(hw);
 			hw->eeprom.ops.read(hw, ++data_offset, &data_value);
 		}
-		/* Now restart DSP by setting Restart_AN */
-		IXGBE_WRITE_REG(hw, IXGBE_AUTOC,
-		    (IXGBE_READ_REG(hw, IXGBE_AUTOC) | IXGBE_AUTOC_AN_RESTART));
 
 		/* Release the semaphore */
 		ixgbe_release_swfw_sync(hw, IXGBE_GSSR_MAC_CSR_SM);
 		/* Delay obtaining semaphore again to allow FW access */
 		msleep(hw->eeprom.semaphore_delay);
+
+		/* Now restart DSP by setting Restart_AN and clearing LMS */
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, ((IXGBE_READ_REG(hw,
+		                IXGBE_AUTOC) & ~IXGBE_AUTOC_LMS_MASK) |
+		                IXGBE_AUTOC_AN_RESTART));
+
+		/* Wait for AN to leave state 0 */
+		for (i = 0; i < 10; i++) {
+			msleep(4);
+			reg_anlp1 = IXGBE_READ_REG(hw, IXGBE_ANLP1);
+			if (reg_anlp1 & IXGBE_ANLP1_AN_STATE_MASK)
+				break;
+		}
+		if (!(reg_anlp1 & IXGBE_ANLP1_AN_STATE_MASK)) {
+			hw_dbg(hw, "sfp module setup not complete\n");
+			ret_val = IXGBE_ERR_SFP_SETUP_NOT_COMPLETE;
+			goto setup_sfp_out;
+		}
+
+		/* Restart DSP by setting Restart_AN and return to SFI mode */
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, (IXGBE_READ_REG(hw,
+		                IXGBE_AUTOC) | IXGBE_AUTOC_LMS_10G_SERIAL |
+		                IXGBE_AUTOC_AN_RESTART));
 	}
 
 setup_sfp_out:
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index ef816dd..0f80893 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1470,6 +1470,8 @@
 #define IXGBE_ANLP1_PAUSE               0x0C00
 #define IXGBE_ANLP1_SYM_PAUSE           0x0400
 #define IXGBE_ANLP1_ASM_PAUSE           0x0800
+#define IXGBE_ANLP1_AN_STATE_MASK       0x000f0000
+
 
 /* SW Semaphore Register bitmasks */
 #define IXGBE_SWSM_SMBI 0x00000001 /* Driver Semaphore bit */
@@ -2641,6 +2643,7 @@ struct ixgbe_info {
 #define IXGBE_ERR_NO_SPACE                      -25
 #define IXGBE_ERR_OVERTEMP                      -26
 #define IXGBE_ERR_RAR_INDEX                     -27
+#define IXGBE_ERR_SFP_SETUP_NOT_COMPLETE        -30
 #define IXGBE_ERR_PBA_SECTION                   -31
 #define IXGBE_ERR_INVALID_ARGUMENT              -32
 #define IXGBE_NOT_IMPLEMENTED                   0x7FFFFFFF

