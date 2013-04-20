From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] ixgbe: add SFP+ LX module support
Date: Sat, 20 Apr 2013 02:49:03 -0700
Message-ID: <1366451353-24714-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11476 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754610Ab3DTJtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Apr 2013 05:49:19 -0400
In-Reply-To: <1366451353-24714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds LX support to 82599 devices. This is an alternate patch to
the one suggested by Stefan Behte <s.behte@babiel.com>

In addition this patch includes some cleanups such as:
- removed parenthesis around "x == y ||" lines inside an if statement for
consistency.
- grouped the sx/lx sfp types along with srlr in ixgbe_get_settings() since
they all have the same supported, advertised and port values.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Reported-by: Stefan Behte <s.behte@babiel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 10 ++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     | 21 +++++++++++++++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  2 ++
 4 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 6dbdd4f..3f79242 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -266,6 +266,8 @@ static s32 ixgbe_get_link_capabilities_82599(struct ixgbe_hw *hw,
 	/* Determine 1G link capabilities off of SFP+ type */
 	if (hw->phy.sfp_type == ixgbe_sfp_type_1g_cu_core0 ||
 	    hw->phy.sfp_type == ixgbe_sfp_type_1g_cu_core1 ||
+	    hw->phy.sfp_type == ixgbe_sfp_type_1g_lx_core0 ||
+	    hw->phy.sfp_type == ixgbe_sfp_type_1g_lx_core1 ||
 	    hw->phy.sfp_type == ixgbe_sfp_type_1g_sx_core0 ||
 	    hw->phy.sfp_type == ixgbe_sfp_type_1g_sx_core1) {
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index c3f1afd..bbe00bc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -231,6 +231,10 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		case ixgbe_sfp_type_lr:
 		case ixgbe_sfp_type_srlr_core0:
 		case ixgbe_sfp_type_srlr_core1:
+		case ixgbe_sfp_type_1g_sx_core0:
+		case ixgbe_sfp_type_1g_sx_core1:
+		case ixgbe_sfp_type_1g_lx_core0:
+		case ixgbe_sfp_type_1g_lx_core1:
 			ecmd->supported |= SUPPORTED_FIBRE;
 			ecmd->advertising |= ADVERTISED_FIBRE;
 			ecmd->port = PORT_FIBRE;
@@ -246,12 +250,6 @@ static int ixgbe_get_settings(struct net_device *netdev,
 			ecmd->advertising |= ADVERTISED_TP;
 			ecmd->port = PORT_TP;
 			break;
-		case ixgbe_sfp_type_1g_sx_core0:
-		case ixgbe_sfp_type_1g_sx_core1:
-			ecmd->supported |= SUPPORTED_FIBRE;
-			ecmd->advertising |= ADVERTISED_FIBRE;
-			ecmd->port = PORT_FIBRE;
-			break;
 		case ixgbe_sfp_type_unknown:
 		default:
 			ecmd->supported |= SUPPORTED_FIBRE;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 060d2ad..e5691cc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -956,6 +956,13 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 				else
 					hw->phy.sfp_type =
 						ixgbe_sfp_type_1g_sx_core1;
+			} else if (comp_codes_1g & IXGBE_SFF_1GBASELX_CAPABLE) {
+				if (hw->bus.lan_id == 0)
+					hw->phy.sfp_type =
+						ixgbe_sfp_type_1g_lx_core0;
+				else
+					hw->phy.sfp_type =
+						ixgbe_sfp_type_1g_lx_core1;
 			} else {
 				hw->phy.sfp_type = ixgbe_sfp_type_unknown;
 			}
@@ -1043,6 +1050,8 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 		if (comp_codes_10g == 0 &&
 		    !(hw->phy.sfp_type == ixgbe_sfp_type_1g_cu_core1 ||
 		      hw->phy.sfp_type == ixgbe_sfp_type_1g_cu_core0 ||
+		      hw->phy.sfp_type == ixgbe_sfp_type_1g_lx_core0 ||
+		      hw->phy.sfp_type == ixgbe_sfp_type_1g_lx_core1 ||
 		      hw->phy.sfp_type == ixgbe_sfp_type_1g_sx_core0 ||
 		      hw->phy.sfp_type == ixgbe_sfp_type_1g_sx_core1)) {
 			hw->phy.type = ixgbe_phy_sfp_unsupported;
@@ -1058,10 +1067,12 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 
 		hw->mac.ops.get_device_caps(hw, &enforce_sfp);
 		if (!(enforce_sfp & IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP) &&
-		    !((hw->phy.sfp_type == ixgbe_sfp_type_1g_cu_core0) ||
-		      (hw->phy.sfp_type == ixgbe_sfp_type_1g_cu_core1) ||
-		      (hw->phy.sfp_type == ixgbe_sfp_type_1g_sx_core0) ||
-		      (hw->phy.sfp_type == ixgbe_sfp_type_1g_sx_core1))) {
+		    !(hw->phy.sfp_type == ixgbe_sfp_type_1g_cu_core0 ||
+		      hw->phy.sfp_type == ixgbe_sfp_type_1g_cu_core1 ||
+		      hw->phy.sfp_type == ixgbe_sfp_type_1g_lx_core0 ||
+		      hw->phy.sfp_type == ixgbe_sfp_type_1g_lx_core1 ||
+		      hw->phy.sfp_type == ixgbe_sfp_type_1g_sx_core0 ||
+		      hw->phy.sfp_type == ixgbe_sfp_type_1g_sx_core1)) {
 			/* Make sure we're a supported PHY type */
 			if (hw->phy.type == ixgbe_phy_sfp_intel) {
 				status = 0;
@@ -1125,10 +1136,12 @@ s32 ixgbe_get_sfp_init_sequence_offsets(struct ixgbe_hw *hw,
 	 * SR modules
 	 */
 	if (sfp_type == ixgbe_sfp_type_da_act_lmt_core0 ||
+	    sfp_type == ixgbe_sfp_type_1g_lx_core0 ||
 	    sfp_type == ixgbe_sfp_type_1g_cu_core0 ||
 	    sfp_type == ixgbe_sfp_type_1g_sx_core0)
 		sfp_type = ixgbe_sfp_type_srlr_core0;
 	else if (sfp_type == ixgbe_sfp_type_da_act_lmt_core1 ||
+		 sfp_type == ixgbe_sfp_type_1g_lx_core1 ||
 		 sfp_type == ixgbe_sfp_type_1g_cu_core1 ||
 		 sfp_type == ixgbe_sfp_type_1g_sx_core1)
 		sfp_type = ixgbe_sfp_type_srlr_core1;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 100dd92..4cbe219 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2611,6 +2611,8 @@ enum ixgbe_sfp_type {
 	ixgbe_sfp_type_1g_cu_core1 = 10,
 	ixgbe_sfp_type_1g_sx_core0 = 11,
 	ixgbe_sfp_type_1g_sx_core1 = 12,
+	ixgbe_sfp_type_1g_lx_core0 = 13,
+	ixgbe_sfp_type_1g_lx_core1 = 14,
 	ixgbe_sfp_type_not_present = 0xFFFE,
 	ixgbe_sfp_type_unknown = 0xFFFF
 };
-- 
1.7.11.7
