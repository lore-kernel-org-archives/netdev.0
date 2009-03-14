From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 01/11] ixgbe: Fix get_supported_physical_layer() due
	to new 82599 PHY types
Date: Sat, 14 Mar 2009 01:12:29 -0700
Message-ID: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:46392
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750963AbZCNIMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 04:12:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

A purely cosmetic change.  Report which physical layer is present, instead
of PHY unknown.  82599 added new PHY types for the SFP+ devices, and this
was missed getting updated.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index cc3bfa1..56efa98 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1130,6 +1130,7 @@ s32 ixgbe_identify_phy_82599(struct ixgbe_hw *hw)
 u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 {
 	u32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+	u8 comp_codes_10g = 0;
 
 	switch (hw->device_id) {
 	case IXGBE_DEV_ID_82599:
@@ -1143,6 +1144,8 @@ u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 
 		switch (hw->phy.sfp_type) {
 		case ixgbe_sfp_type_da_cu:
+		case ixgbe_sfp_type_da_cu_core0:
+		case ixgbe_sfp_type_da_cu_core1:
 			physical_layer = IXGBE_PHYSICAL_LAYER_SFP_PLUS_CU;
 			break;
 		case ixgbe_sfp_type_sr:
@@ -1151,6 +1154,19 @@ u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 		case ixgbe_sfp_type_lr:
 			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_LR;
 			break;
+		case ixgbe_sfp_type_srlr_core0:
+		case ixgbe_sfp_type_srlr_core1:
+			hw->phy.ops.read_i2c_eeprom(hw,
+			                            IXGBE_SFF_10GBE_COMP_CODES,
+			                            &comp_codes_10g);
+			if (comp_codes_10g & IXGBE_SFF_10GBASESR_CAPABLE)
+				physical_layer =
+				                IXGBE_PHYSICAL_LAYER_10GBASE_SR;
+			else if (comp_codes_10g & IXGBE_SFF_10GBASELR_CAPABLE)
+				physical_layer =
+				                IXGBE_PHYSICAL_LAYER_10GBASE_LR;
+			else
+				physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
 		default:
 			physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
 			break;

