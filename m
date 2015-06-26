From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 07/10] e1000e: i219 - Increase minimum FIFO read/write min gap
Date: Fri, 26 Jun 2015 03:20:37 -0700
Message-ID: <1435314040-3228-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59229 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751904AbbFZKUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 06:20:51 -0400
In-Reply-To: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

Due to clocking changes in the Skylake platform, there was i219
data corruption. To work around this, HW team reported the need
to increase the minimum gap between the PHY FIFO read and write pointers.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 46 +++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 983f5bf..3f5b8cb 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1437,6 +1437,52 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 
 		if (ret_val)
 			return ret_val;
+
+		if (hw->mac.type == e1000_pch_spt) {
+			u16 data;
+			u16 ptr_gap;
+
+			if (speed == SPEED_1000) {
+				ret_val = hw->phy.ops.acquire(hw);
+				if (ret_val)
+					return ret_val;
+
+				ret_val = e1e_rphy_locked(hw,
+							  PHY_REG(776, 20),
+							  &data);
+				if (ret_val) {
+					hw->phy.ops.release(hw);
+					return ret_val;
+				}
+
+				ptr_gap = (data & (0x3FF << 2)) >> 2;
+				if (ptr_gap < 0x18) {
+					data &= ~(0x3FF << 2);
+					data |= (0x18 << 2);
+					ret_val =
+					    e1e_wphy_locked(hw,
+							    PHY_REG(776, 20),
+							    data);
+				}
+				hw->phy.ops.release(hw);
+				if (ret_val)
+					return ret_val;
+			}
+		}
+	}
+
+	/* I217 Packet Loss issue:
+	 * ensure that FEXTNVM4 Beacon Duration is set correctly
+	 * on power up.
+	 * Set the Beacon Duration for I217 to 8 usec
+	 */
+	if ((hw->mac.type == e1000_pch_lpt) || (hw->mac.type == e1000_pch_spt)) {
+		u32 mac_reg;
+
+		mac_reg = er32(FEXTNVM4);
+		mac_reg &= ~E1000_FEXTNVM4_BEACON_DURATION_MASK;
+		mac_reg |= E1000_FEXTNVM4_BEACON_DURATION_8USEC;
+		ew32(FEXTNVM4, mac_reg);
 	}
 
 	/* Work-around I218 hang issue */
-- 
2.4.3
