From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/4] e1000e: Spurious interrupts & dropped packets with 82577/8/9 in half-duplex
Date: Sat, 13 Aug 2011 02:23:38 -0700
Message-ID: <1313227420-9974-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313227420-9974-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9400 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751241Ab1HMJXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2011 05:23:43 -0400
In-Reply-To: <1313227420-9974-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

On 82577/8/9 in half-duplex when a received packet is passed from the PHY
to the MAC, if too many preamble octects are stripped from the packet
before arriving at the MAC, it can be misintrepeted as an in-band message
rather than an actual frame.  For example, if the frame contents resembled
an interrupt request in-band message, it would trigger a false interrupt.
In most cases, the packet is just dropped.

By reducing the number of preamble octets stripped from the beginning of
the frame when passing it from the PHY to the MAC, the MAC will interpret
the frame properly.

An additional uses of the magic PHY_REG(770, 16) have been updated with a
define introduced with this patch.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ich8lan.c |   41 +++++++++++++++++++++++++++++++++--------
 1 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 4e36978..7525e37 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -163,6 +163,11 @@
 #define HV_KMRN_MODE_CTRL      PHY_REG(769, 16)
 #define HV_KMRN_MDIO_SLOW      0x0400
 
+/* KMRN FIFO Control and Status */
+#define HV_KMRN_FIFO_CTRLSTA                  PHY_REG(770, 16)
+#define HV_KMRN_FIFO_CTRLSTA_PREAMBLE_MASK    0x7000
+#define HV_KMRN_FIFO_CTRLSTA_PREAMBLE_SHIFT   12
+
 /* ICH GbE Flash Hardware Sequencing Flash Status Register bit breakdown */
 /* Offset 04h HSFSTS */
 union ich8_hws_flash_status {
@@ -657,6 +662,7 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 	s32 ret_val;
 	bool link;
+	u16 phy_reg;
 
 	/*
 	 * We only want to go out to the PHY registers to see if Auto-Neg
@@ -689,16 +695,35 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 
 	mac->get_link_status = false;
 
-	if (hw->phy.type == e1000_phy_82578) {
-		ret_val = e1000_link_stall_workaround_hv(hw);
-		if (ret_val)
-			goto out;
-	}
-
-	if (hw->mac.type == e1000_pch2lan) {
+	switch (hw->mac.type) {
+	case e1000_pch2lan:
 		ret_val = e1000_k1_workaround_lv(hw);
 		if (ret_val)
 			goto out;
+		/* fall-thru */
+	case e1000_pchlan:
+		if (hw->phy.type == e1000_phy_82578) {
+			ret_val = e1000_link_stall_workaround_hv(hw);
+			if (ret_val)
+				goto out;
+		}
+
+		/*
+		 * Workaround for PCHx parts in half-duplex:
+		 * Set the number of preambles removed from the packet
+		 * when it is passed from the PHY to the MAC to prevent
+		 * the MAC from misinterpreting the packet type.
+		 */
+		e1e_rphy(hw, HV_KMRN_FIFO_CTRLSTA, &phy_reg);
+		phy_reg &= ~HV_KMRN_FIFO_CTRLSTA_PREAMBLE_MASK;
+
+		if ((er32(STATUS) & E1000_STATUS_FD) != E1000_STATUS_FD)
+			phy_reg |= (1 << HV_KMRN_FIFO_CTRLSTA_PREAMBLE_SHIFT);
+
+		e1e_wphy(hw, HV_KMRN_FIFO_CTRLSTA, phy_reg);
+		break;
+	default:
+		break;
 	}
 
 	/*
@@ -1355,7 +1380,7 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 			return ret_val;
 
 		/* Preamble tuning for SSC */
-		ret_val = e1e_wphy(hw, PHY_REG(770, 16), 0xA204);
+		ret_val = e1e_wphy(hw, HV_KMRN_FIFO_CTRLSTA, 0xA204);
 		if (ret_val)
 			return ret_val;
 	}
-- 
1.7.6

