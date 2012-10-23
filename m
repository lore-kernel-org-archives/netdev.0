From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] igb: Update get cable length function for i210/i211
Date: Tue, 23 Oct 2012 03:24:42 -0700
Message-ID: <1350987887-16161-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10577 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754406Ab2JWKYw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 06:24:52 -0400
In-Reply-To: <1350987887-16161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

There was a problem in the initial implementation of the get cable length
function for i210 and it did not work properly.  This patch fixes that
problem for i210/i211 devices.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 3404bc7..c62a4c3 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -1710,6 +1710,26 @@ s32 igb_get_cable_length_m88_gen2(struct e1000_hw *hw)
 
 	switch (hw->phy.id) {
 	case I210_I_PHY_ID:
+		/* Get cable length from PHY Cable Diagnostics Control Reg */
+		ret_val = phy->ops.read_reg(hw, (0x7 << GS40G_PAGE_SHIFT) +
+					    (I347AT4_PCDL + phy->addr),
+					    &phy_data);
+		if (ret_val)
+			return ret_val;
+
+		/* Check if the unit of cable length is meters or cm */
+		ret_val = phy->ops.read_reg(hw, (0x7 << GS40G_PAGE_SHIFT) +
+					    I347AT4_PCDC, &phy_data2);
+		if (ret_val)
+			return ret_val;
+
+		is_cm = !(phy_data2 & I347AT4_PCDC_CABLE_LENGTH_UNIT);
+
+		/* Populate the phy structure with cable length in meters */
+		phy->min_cable_length = phy_data / (is_cm ? 100 : 1);
+		phy->max_cable_length = phy_data / (is_cm ? 100 : 1);
+		phy->cable_length = phy_data / (is_cm ? 100 : 1);
+		break;
 	case I347AT4_E_PHY_ID:
 		/* Remember the original page select and set it to 7 */
 		ret_val = phy->ops.read_reg(hw, I347AT4_PAGE_SELECT,
-- 
1.7.11.7
