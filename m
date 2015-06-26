From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 04/10] e1000e: synchronization of MAC-PHY interface only on non- ME systems
Date: Fri, 26 Jun 2015 03:20:34 -0700
Message-ID: <1435314040-3228-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59229 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751817AbbFZKUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 06:20:47 -0400
In-Reply-To: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

On power up, the MAC - PHY interface needs to be set to PCIe, even if
cable is disconnected.  In ME systems, the ME handles this on exit from
Sx state. In non-ME, the driver handles it. Added a check for non-ME
system to the driver code that handles that.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index b074b9a..c742a4f 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -237,17 +237,19 @@ static bool e1000_phy_is_accessible_pchlan(struct e1000_hw *hw)
 	if (ret_val)
 		return false;
 out:
-	if ((hw->mac.type == e1000_pch_lpt) ||
-	    (hw->mac.type == e1000_pch_spt)) {
-		/* Unforce SMBus mode in PHY */
-		e1e_rphy_locked(hw, CV_SMB_CTRL, &phy_reg);
-		phy_reg &= ~CV_SMB_CTRL_FORCE_SMBUS;
-		e1e_wphy_locked(hw, CV_SMB_CTRL, phy_reg);
+	if ((hw->mac.type == e1000_pch_lpt) || (hw->mac.type == e1000_pch_spt)) {
+		/* Only unforce SMBus if ME is not active */
+		if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
+			/* Unforce SMBus mode in PHY */
+			e1e_rphy_locked(hw, CV_SMB_CTRL, &phy_reg);
+			phy_reg &= ~CV_SMB_CTRL_FORCE_SMBUS;
+			e1e_wphy_locked(hw, CV_SMB_CTRL, phy_reg);
 
-		/* Unforce SMBus mode in MAC */
-		mac_reg = er32(CTRL_EXT);
-		mac_reg &= ~E1000_CTRL_EXT_FORCE_SMBUS;
-		ew32(CTRL_EXT, mac_reg);
+			/* Unforce SMBus mode in MAC */
+			mac_reg = er32(CTRL_EXT);
+			mac_reg &= ~E1000_CTRL_EXT_FORCE_SMBUS;
+			ew32(CTRL_EXT, mac_reg);
+		}
 	}
 
 	return true;
-- 
2.4.3
