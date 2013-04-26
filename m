From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool] ethtool: check mac type from ethtool_regs.version
Date: Thu, 25 Apr 2013 22:12:48 -0700
Message-ID: <1366953168-17509-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:43240 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751867Ab3DZFMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Apr 2013 01:12:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch cleans up the mac type checks by using ethtool_regs.version
provided by the driver. This change eliminates the need to add device IDs
every time they are added to the driver.

This patch depends on a driver change that will add the mac_type to the
upper 8 bits of ethtool_regs.version.

Note that when using ethtool with this patch with a version of ixgbe that
does not provide the mac_type in ethtool_regs.version the register dump
may be incomplete. However this issue would've existed previously for
device IDs that were not added to ethtool.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ixgbe.c | 88 ++---------------------------------------------------------------
 1 file changed, 2 insertions(+), 86 deletions(-)

diff --git a/ixgbe.c b/ixgbe.c
index dae11d4..ef87d53 100644
--- a/ixgbe.c
+++ b/ixgbe.c
@@ -31,37 +31,6 @@
 #define IXGBE_MFLCN_RPFCE          0x00000004 /* Receive Priority FC Enable */
 #define IXGBE_MFLCN_RFCE           0x00000008 /* Receive FC Enable */
 
-/* Device IDs */
-#define IXGBE_DEV_ID_82598               0x10B6
-#define IXGBE_DEV_ID_82598_BX            0x1508
-#define IXGBE_DEV_ID_82598AF_DUAL_PORT   0x10C6
-#define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
-#define IXGBE_DEV_ID_82598EB_SFP_LOM     0x10DB
-#define IXGBE_DEV_ID_82598AT             0x10C8
-#define IXGBE_DEV_ID_82598AT2            0x150B
-#define IXGBE_DEV_ID_82598EB_CX4         0x10DD
-#define IXGBE_DEV_ID_82598_CX4_DUAL_PORT 0x10EC
-#define IXGBE_DEV_ID_82598_DA_DUAL_PORT  0x10F1
-#define IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM      0x10E1
-#define IXGBE_DEV_ID_82598EB_XF_LR       0x10F4
-#define IXGBE_DEV_ID_82599_KX4           0x10F7
-#define IXGBE_DEV_ID_82599_KX4_MEZZ      0x1514
-#define IXGBE_DEV_ID_82599_KR            0x1517
-#define IXGBE_DEV_ID_82599_T3_LOM        0x151C
-#define IXGBE_DEV_ID_82599_CX4           0x10F9
-#define IXGBE_DEV_ID_82599_SFP           0x10FB
-#define IXGBE_DEV_ID_82599_BACKPLANE_FCOE       0x152a
-#define IXGBE_DEV_ID_82599_SFP_FCOE      0x1529
-#define IXGBE_SUBDEV_ID_82599_SFP        0x11A9
-#define IXGBE_DEV_ID_82599_SFP_EM        0x1507
-#define IXGBE_DEV_ID_82599_SFP_SF2       0x154D
-#define IXGBE_DEV_ID_82599EN_SFP         0x1557
-#define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC
-#define IXGBE_DEV_ID_82599_COMBO_BACKPLANE 0x10F8
-#define IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ  0x000C
-#define IXGBE_DEV_ID_82599_LS            0x154F
-#define IXGBE_DEV_ID_X540T               0x1528
-
 /*
  * Enumerated types specific to the ixgbe hardware
  * Media Access Controlers
@@ -74,70 +43,17 @@ enum ixgbe_mac_type {
 	ixgbe_num_macs
 };
 
-enum ixgbe_mac_type
-ixgbe_get_mac_type(u16 device_id)
-{
-	enum ixgbe_mac_type mac_type = ixgbe_mac_unknown;
-
-	switch (device_id) {
-	case IXGBE_DEV_ID_82598:
-	case IXGBE_DEV_ID_82598_BX:
-	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
-	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
-	case IXGBE_DEV_ID_82598EB_SFP_LOM:
-	case IXGBE_DEV_ID_82598AT:
-	case IXGBE_DEV_ID_82598AT2:
-	case IXGBE_DEV_ID_82598EB_CX4:
-	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
-	case IXGBE_DEV_ID_82598_DA_DUAL_PORT:
-	case IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM:
-	case IXGBE_DEV_ID_82598EB_XF_LR:
-		mac_type = ixgbe_mac_82598EB;
-		break;
-	case IXGBE_DEV_ID_82599_KX4:
-	case IXGBE_DEV_ID_82599_KX4_MEZZ:
-	case IXGBE_DEV_ID_82599_KR:
-	case IXGBE_DEV_ID_82599_T3_LOM:
-	case IXGBE_DEV_ID_82599_CX4:
-	case IXGBE_DEV_ID_82599_SFP:
-	case IXGBE_DEV_ID_82599_BACKPLANE_FCOE:
-	case IXGBE_DEV_ID_82599_SFP_FCOE:
-	case IXGBE_SUBDEV_ID_82599_SFP:
-	case IXGBE_DEV_ID_82599_SFP_EM:
-	case IXGBE_DEV_ID_82599_SFP_SF2:
-	case IXGBE_DEV_ID_82599EN_SFP:
-	case IXGBE_DEV_ID_82599_XAUI_LOM:
-	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
-	case IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ:
-	case IXGBE_DEV_ID_82599_LS:
-		mac_type = ixgbe_mac_82599EB;
-		break;
-	case IXGBE_DEV_ID_X540T:
-		mac_type = ixgbe_mac_X540;
-		break;
-	default:
-		mac_type = ixgbe_mac_82598EB;
-		break;
-	}
-
-	return mac_type;
-}
-
 int
 ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 {
 	u32 *regs_buff = (u32 *)regs->data;
 	u32 reg;
-	u16 hw_device_id = (u16) regs->version;
-	u8 version = (u8)(regs->version >> 24);
+	u8 mac_type = (u8)(regs->version >> 24);
 	u8 i;
-	enum ixgbe_mac_type mac_type;
 
-	if (version != 1)
+	if (mac_type == ixgbe_mac_unknown)
 		return -1;
 
-	mac_type = ixgbe_get_mac_type(hw_device_id);
-
 	reg = regs_buff[1065];
 	fprintf(stdout,
 	"0x042A4: LINKS (Link Status register)                 0x%08X\n"
-- 
1.7.11.7
