From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/8] ixgbe: add support for disabling link at boot time on 82599
Date: Thu, 25 Apr 2013 21:57:10 -0700
Message-ID: <1366952231-16727-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51268 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754381Ab3DZE5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Apr 2013 00:57:20 -0400
In-Reply-To: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch adds support for disabling link during boot time. This
feature was requested by customers and is configurable through the EEPROM.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 21 +++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |  1 +
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index c4c5e87..0b82d38 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1051,6 +1051,14 @@ mac_reset_top:
 	 */
 	hw->mac.cached_autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
 	autoc2 = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
+
+	/* Enable link if disabled in NVM */
+	if (autoc2 & IXGBE_AUTOC2_LINK_DISABLE_MASK) {
+		autoc2 &= ~IXGBE_AUTOC2_LINK_DISABLE_MASK;
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC2, autoc2);
+		IXGBE_WRITE_FLUSH(hw);
+	}
+
 	if (hw->mac.orig_link_settings_stored == false) {
 		hw->mac.orig_autoc = hw->mac.cached_autoc;
 		hw->mac.orig_autoc2 = autoc2;
@@ -2186,8 +2194,17 @@ static s32 ixgbe_read_eeprom_82599(struct ixgbe_hw *hw,
  **/
 s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw)
 {
-	s32 i, autoc_reg, ret_val;
-	s32 anlp1_reg = 0;
+	s32 ret_val;
+	u32 anlp1_reg = 0;
+	u32 i, autoc_reg, autoc2_reg;
+
+	/* Enable link if disabled in NVM */
+	autoc2_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
+	if (autoc2_reg & IXGBE_AUTOC2_LINK_DISABLE_MASK) {
+		autoc2_reg &= ~IXGBE_AUTOC2_LINK_DISABLE_MASK;
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC2, autoc2_reg);
+		IXGBE_WRITE_FLUSH(hw);
+	}
 
 	autoc_reg = hw->mac.cached_autoc;
 	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 7480f7b..70c6aa3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1593,6 +1593,7 @@ enum {
 #define IXGBE_AUTOC2_10G_KR  (0x0 << IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT)
 #define IXGBE_AUTOC2_10G_XFI (0x1 << IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT)
 #define IXGBE_AUTOC2_10G_SFI (0x2 << IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_SHIFT)
+#define IXGBE_AUTOC2_LINK_DISABLE_MASK        0x70000000
 
 #define IXGBE_MACC_FLU       0x00000001
 #define IXGBE_MACC_FSV_10G   0x00030000
-- 
1.7.11.7
