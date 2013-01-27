From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] e1000e: fix PHY init workarounds for i217/i218
Date: Sun, 27 Jan 2013 02:39:48 -0800
Message-ID: <1359283193-2043-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26342 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756532Ab3A0KkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 05:40:03 -0500
In-Reply-To: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Toggling the LANPHYPC Value bit cycles the power on the PHY and sets it
back to power-on defaults.  This includes setting it's MAC-PHY messaging
mode to use the PCIe-like interconnect, so the MAC must also be set back
from SMBus mode to PCIe mode otherwise the PHY can be inaccessible.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index e0f41f0..3f3477f 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -426,6 +426,15 @@ static s32 e1000_init_phy_workarounds_pchlan(struct e1000_hw *hw)
 		mac_reg |= E1000_FEXTNVM3_PHY_CFG_COUNTER_50MSEC;
 		ew32(FEXTNVM3, mac_reg);
 
+		if (hw->mac.type == e1000_pch_lpt) {
+			/* Toggling LANPHYPC brings the PHY out of SMBus mode
+			 * So ensure that the MAC is also out of SMBus mode
+			 */
+			mac_reg = er32(CTRL_EXT);
+			mac_reg &= ~E1000_CTRL_EXT_FORCE_SMBUS;
+			ew32(CTRL_EXT, mac_reg);
+		}
+
 		/* Toggle LANPHYPC Value bit */
 		mac_reg = er32(CTRL);
 		mac_reg |= E1000_CTRL_LANPHYPC_OVERRIDE;
-- 
1.7.11.7
