From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] e1000e: WoL fails on device ID 0x1501
Date: Thu,  6 Oct 2011 04:02:32 -0700
Message-ID: <1317898959-16550-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30733 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758213Ab1JFLCn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 07:02:43 -0400
In-Reply-To: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

PCI device ID 0x1501 has a hardware bug when the link downshifts for
whatever reason which requires a workaround.  The workaround already exists
for other similar devices but is not called for 0x1501 (it should be called
for any ICH8-based device that uses a GbE PHY).  There is also one other
instance when the workaround should be called - after disabling gigabit
speed when going to Sx.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 4ec5a5a..ad34de0 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -811,7 +811,7 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	}
 
 	if ((adapter->hw.mac.type == e1000_ich8lan) &&
-	    (adapter->hw.phy.type == e1000_phy_igp_3))
+	    (adapter->hw.phy.type != e1000_phy_ife))
 		adapter->flags |= FLAG_LSC_GIG_SPEED_DROP;
 
 	/* Enable workaround for 82579 w/ ME enabled */
@@ -3642,15 +3642,14 @@ void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw)
  *  LPLU, Gig disable, MDIC PHY reset):
  *    1) Set Kumeran Near-end loopback
  *    2) Clear Kumeran Near-end loopback
- *  Should only be called for ICH8[m] devices with IGP_3 Phy.
+ *  Should only be called for ICH8[m] devices with any 1G Phy.
  **/
 void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw)
 {
 	s32 ret_val;
 	u16 reg_data;
 
-	if ((hw->mac.type != e1000_ich8lan) ||
-	    (hw->phy.type != e1000_phy_igp_3))
+	if ((hw->mac.type != e1000_ich8lan) || (hw->phy.type == e1000_phy_ife))
 		return;
 
 	ret_val = e1000e_read_kmrn_reg(hw, E1000_KMRNCTRLSTA_DIAG_OFFSET,
@@ -3686,6 +3685,9 @@ void e1000_suspend_workarounds_ich8lan(struct e1000_hw *hw)
 	phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU | E1000_PHY_CTRL_GBE_DISABLE;
 	ew32(PHY_CTRL, phy_ctrl);
 
+	if (hw->mac.type == e1000_ich8lan)
+		e1000e_gig_downshift_workaround_ich8lan(hw);
+
 	if (hw->mac.type >= e1000_pchlan) {
 		e1000_oem_bits_config_ich8lan(hw, false);
 		e1000_phy_hw_reset_ich8lan(hw);
-- 
1.7.6.4
