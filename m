From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] ixgbe: Add X552 XFI backplane support
Date: Tue, 18 Apr 2017 16:01:55 -0700
Message-ID: <20170418230205.37223-6-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:55358 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755893AbdDRXCM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:12 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch add support for X552 XFI backplane interface.  The XFI
backplane requires a custom tuned link.  HW/FW owns the link config
for XF backplane and SW must not interfere with it.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c    | 14 ++++++++++++++
 4 files changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 0da0752fedef..59730ede4746 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -179,6 +179,7 @@ static u32 ixgbe_get_supported_10gtypes(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82598_BX:
 	case IXGBE_DEV_ID_82599_KR:
 	case IXGBE_DEV_ID_X550EM_X_KR:
+	case IXGBE_DEV_ID_X550EM_X_XFI:
 		return SUPPORTED_10000baseKR_Full;
 	default:
 		return SUPPORTED_10000baseKX4_Full |
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 848dea922b2a..e250c1d54a11 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -131,6 +131,7 @@ static const struct pci_device_id ixgbe_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550T), board_X550},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550T1), board_X550},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_KX4), board_X550EM_x},
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_XFI), board_X550EM_x},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_KR), board_X550EM_x},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_10G_T), board_X550EM_x},
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_SFP), board_X550EM_x},
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index c0f6b9503439..22869aaec3d4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -85,6 +85,7 @@
 #define IXGBE_DEV_ID_X550EM_X_SFP	0x15AC
 #define IXGBE_DEV_ID_X550EM_X_10G_T	0x15AD
 #define IXGBE_DEV_ID_X550EM_X_1G_T	0x15AE
+#define IXGBE_DEV_ID_X550EM_X_XFI	0x15B0
 #define IXGBE_DEV_ID_X550EM_A_KR	0x15C2
 #define IXGBE_DEV_ID_X550EM_A_KR_L	0x15C3
 #define IXGBE_DEV_ID_X550EM_A_SFP_N	0x15C4
@@ -3128,6 +3129,7 @@ enum ixgbe_phy_type {
 	ixgbe_phy_aq,
 	ixgbe_phy_x550em_kr,
 	ixgbe_phy_x550em_kx4,
+	ixgbe_phy_x550em_xfi,
 	ixgbe_phy_x550em_ext_t,
 	ixgbe_phy_cu_unknown,
 	ixgbe_phy_qt,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 633079eaf8fb..5127e5e759f2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -320,6 +320,9 @@ static s32 ixgbe_identify_phy_x550em(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_X550EM_X_KX4:
 		hw->phy.type = ixgbe_phy_x550em_kx4;
 		break;
+	case IXGBE_DEV_ID_X550EM_X_XFI:
+		hw->phy.type = ixgbe_phy_x550em_xfi;
+		break;
 	case IXGBE_DEV_ID_X550EM_X_KR:
 	case IXGBE_DEV_ID_X550EM_A_KR:
 	case IXGBE_DEV_ID_X550EM_A_KR_L:
@@ -2231,6 +2234,10 @@ static s32 ixgbe_get_link_capabilities_X550em(struct ixgbe_hw *hw,
 				 IXGBE_LINK_SPEED_2_5GB_FULL |
 				 IXGBE_LINK_SPEED_10GB_FULL;
 			break;
+		case ixgbe_phy_x550em_xfi:
+			*speed = IXGBE_LINK_SPEED_1GB_FULL |
+				 IXGBE_LINK_SPEED_10GB_FULL;
+			break;
 		case ixgbe_phy_sgmii:
 			*speed = IXGBE_LINK_SPEED_1GB_FULL;
 			break;
@@ -3127,6 +3134,12 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 		phy->ops.read_reg = ixgbe_read_phy_reg_x550em;
 		phy->ops.write_reg = ixgbe_write_phy_reg_x550em;
 		break;
+	case ixgbe_phy_x550em_xfi:
+		/* link is managed by HW */
+		phy->ops.setup_link = NULL;
+		phy->ops.read_reg = ixgbe_read_phy_reg_x550em;
+		phy->ops.write_reg = ixgbe_write_phy_reg_x550em;
+		break;
 	case ixgbe_phy_x550em_ext_t:
 		/* Save NW management interface connected on board. This is used
 		 * to determine internal PHY mode
@@ -3180,6 +3193,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_X550em(struct ixgbe_hw *hw)
 		/* Fallthrough */
 	case IXGBE_DEV_ID_X550EM_X_KR:
 	case IXGBE_DEV_ID_X550EM_X_KX4:
+	case IXGBE_DEV_ID_X550EM_X_XFI:
 	case IXGBE_DEV_ID_X550EM_A_KR:
 	case IXGBE_DEV_ID_X550EM_A_KR_L:
 		media_type = ixgbe_media_type_backplane;
-- 
2.12.2
