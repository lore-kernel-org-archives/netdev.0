From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  4/9] igb: M88E1543 PHY downshift implementation
Date: Wed,  4 Sep 2013 06:08:51 -0700
Message-ID: <1378300136-26003-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8588 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757142Ab3IDNJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 09:09:01 -0400
In-Reply-To: <1378300136-26003-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

This patch implements downshift mechanism for M88E1543 PHY, so that
downshift is disabled first during link setup process, and later enabled
if we are master and downshift link is negotiated. Also cleaned up
return code implementation.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c | 29 ++++++++++++++++++++---------
 1 file changed, 20 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 5adccbc..e726675 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -731,15 +731,13 @@ s32 igb_copper_link_setup_m88_gen2(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_data;
 
-	if (phy->reset_disable) {
-		ret_val = 0;
-		goto out;
-	}
+	if (phy->reset_disable)
+		return 0;
 
 	/* Enable CRS on Tx. This must be set for half-duplex operation. */
 	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Options:
 	 *   MDI/MDI-X = 0 (default)
@@ -780,23 +778,36 @@ s32 igb_copper_link_setup_m88_gen2(struct e1000_hw *hw)
 		phy_data |= M88E1000_PSCR_POLARITY_REVERSAL;
 
 	/* Enable downshift and setting it to X6 */
+	if (phy->id == M88E1543_E_PHY_ID) {
+		phy_data &= ~I347AT4_PSCR_DOWNSHIFT_ENABLE;
+		ret_val =
+		    phy->ops.write_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
+		if (ret_val)
+			return ret_val;
+
+		ret_val = igb_phy_sw_reset(hw);
+		if (ret_val) {
+			hw_dbg("Error committing the PHY changes\n");
+			return ret_val;
+		}
+	}
+
 	phy_data &= ~I347AT4_PSCR_DOWNSHIFT_MASK;
 	phy_data |= I347AT4_PSCR_DOWNSHIFT_6X;
 	phy_data |= I347AT4_PSCR_DOWNSHIFT_ENABLE;
 
 	ret_val = phy->ops.write_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
 	if (ret_val)
-		goto out;
+		return ret_val;
 
 	/* Commit the changes. */
 	ret_val = igb_phy_sw_reset(hw);
 	if (ret_val) {
 		hw_dbg("Error committing the PHY changes\n");
-		goto out;
+		return ret_val;
 	}
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**
-- 
1.8.3.1
