From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool] ethtool: fix flow control register dump for 82599 and newer
Date: Wed,  5 Oct 2011 19:17:31 -0700
Message-ID: <1317867451-23539-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37695 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753405Ab1JFCRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 22:17:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Fix reporting of the flow control settings in the register dump for ixgbe.
Use MFLCN for 82599 and X540 HW instead of FCTRL.

This patch also adds the ability to check for mac type.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ixgbe.c |  138 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 129 insertions(+), 9 deletions(-)

diff --git a/ixgbe.c b/ixgbe.c
index 998c008..e64d34a 100644
--- a/ixgbe.c
+++ b/ixgbe.c
@@ -26,18 +26,118 @@
 #define IXGBE_HLREG0_LPBK          0x00008000
 #define IXGBE_RMCS_TFCE_802_3X     0x00000008
 #define IXGBE_RMCS_TFCE_PRIORITY   0x00000010
+#define IXGBE_MFLCN_PMCF           0x00000001 /* Pass MAC Control Frames */
+#define IXGBE_MFLCN_DPF            0x00000002 /* Discard Pause Frame */
+#define IXGBE_MFLCN_RPFCE          0x00000004 /* Receive Priority FC Enable */
+#define IXGBE_MFLCN_RFCE           0x00000008 /* Receive FC Enable */
+
+/* Device IDs */
+#define IXGBE_DEV_ID_82598               0x10B6
+#define IXGBE_DEV_ID_82598_BX            0x1508
+#define IXGBE_DEV_ID_82598AF_DUAL_PORT   0x10C6
+#define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
+#define IXGBE_DEV_ID_82598EB_SFP_LOM     0x10DB
+#define IXGBE_DEV_ID_82598AT             0x10C8
+#define IXGBE_DEV_ID_82598AT2            0x150B
+#define IXGBE_DEV_ID_82598EB_CX4         0x10DD
+#define IXGBE_DEV_ID_82598_CX4_DUAL_PORT 0x10EC
+#define IXGBE_DEV_ID_82598_DA_DUAL_PORT  0x10F1
+#define IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM      0x10E1
+#define IXGBE_DEV_ID_82598EB_XF_LR       0x10F4
+#define IXGBE_DEV_ID_82599_KX4           0x10F7
+#define IXGBE_DEV_ID_82599_KX4_MEZZ      0x1514
+#define IXGBE_DEV_ID_82599_KR            0x1517
+#define IXGBE_DEV_ID_82599_T3_LOM        0x151C
+#define IXGBE_DEV_ID_82599_CX4           0x10F9
+#define IXGBE_DEV_ID_82599_SFP           0x10FB
+#define IXGBE_DEV_ID_82599_BACKPLANE_FCOE       0x152a
+#define IXGBE_DEV_ID_82599_SFP_FCOE      0x1529
+#define IXGBE_SUBDEV_ID_82599_SFP        0x11A9
+#define IXGBE_DEV_ID_82599_SFP_EM        0x1507
+#define IXGBE_DEV_ID_82599_SFP_SF2       0x154D
+#define IXGBE_DEV_ID_82599EN_SFP         0x1557
+#define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC
+#define IXGBE_DEV_ID_82599_COMBO_BACKPLANE 0x10F8
+#define IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ  0x000C
+#define IXGBE_DEV_ID_82599_LS            0x154F
+#define IXGBE_DEV_ID_X540T               0x1528
+
+/*
+ * Enumerated types specific to the ixgbe hardware
+ * Media Access Controlers
+ */
+enum ixgbe_mac_type {
+	ixgbe_mac_unknown = 0,
+	ixgbe_mac_82598EB,
+	ixgbe_mac_82599EB,
+	ixgbe_mac_X540,
+	ixgbe_num_macs
+};
+
+enum ixgbe_mac_type
+ixgbe_get_mac_type(u16 device_id)
+{
+	enum ixgbe_mac_type mac_type = ixgbe_mac_unknown;
+
+	switch (device_id) {
+	case IXGBE_DEV_ID_82598:
+	case IXGBE_DEV_ID_82598_BX:
+	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
+	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
+	case IXGBE_DEV_ID_82598EB_SFP_LOM:
+	case IXGBE_DEV_ID_82598AT:
+	case IXGBE_DEV_ID_82598AT2:
+	case IXGBE_DEV_ID_82598EB_CX4:
+	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
+	case IXGBE_DEV_ID_82598_DA_DUAL_PORT:
+	case IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM:
+	case IXGBE_DEV_ID_82598EB_XF_LR:
+		mac_type = ixgbe_mac_82598EB;
+		break;
+	case IXGBE_DEV_ID_82599_KX4:
+	case IXGBE_DEV_ID_82599_KX4_MEZZ:
+	case IXGBE_DEV_ID_82599_KR:
+	case IXGBE_DEV_ID_82599_T3_LOM:
+	case IXGBE_DEV_ID_82599_CX4:
+	case IXGBE_DEV_ID_82599_SFP:
+	case IXGBE_DEV_ID_82599_BACKPLANE_FCOE:
+	case IXGBE_DEV_ID_82599_SFP_FCOE:
+	case IXGBE_SUBDEV_ID_82599_SFP:
+	case IXGBE_DEV_ID_82599_SFP_EM:
+	case IXGBE_DEV_ID_82599_SFP_SF2:
+	case IXGBE_DEV_ID_82599EN_SFP:
+	case IXGBE_DEV_ID_82599_XAUI_LOM:
+	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
+	case IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ:
+	case IXGBE_DEV_ID_82599_LS:
+		mac_type = ixgbe_mac_82599EB;
+		break;
+	case IXGBE_DEV_ID_X540T:
+		mac_type = ixgbe_mac_X540;
+		break;
+	default:
+		mac_type = ixgbe_mac_82598EB;
+		break;
+	}
+
+	return mac_type;
+}
 
 int
 ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 {
 	u32 *regs_buff = (u32 *)regs->data;
 	u32 reg;
-	u8 i;
+	u16 hw_device_id = (u16) regs->version;
 	u8 version = (u8)(regs->version >> 24);
+	u8 i;
+	enum ixgbe_mac_type mac_type;
 
 	if (version != 1)
 		return -1;
 
+	mac_type = ixgbe_get_mac_type(hw_device_id);
+
 	reg = regs_buff[1065];
 	fprintf(stdout,
 	"0x042A4: LINKS (Link Status register)                 0x%08X\n"
@@ -50,24 +150,44 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	reg = regs_buff[515];
 	fprintf(stdout,
 	"0x05080: FCTRL (Filter Control register)              0x%08X\n"
-	"       Receive Flow Control Packets:                  %s\n"
-	"       Receive Priority Flow Control Packets:         %s\n"
-	"       Discard Pause Frames:                          %s\n"
-	"       Pass MAC Control Frames:                       %s\n"
 	"       Broadcast Accept:                              %s\n"
 	"       Unicast Promiscuous:                           %s\n"
 	"       Multicast Promiscuous:                         %s\n"
 	"       Store Bad Packets:                             %s\n",
 	reg,
-	reg & IXGBE_FCTRL_RFCE    ? "enabled"  : "disabled",
-	reg & IXGBE_FCTRL_RPFCE   ? "enabled"  : "disabled",
-	reg & IXGBE_FCTRL_DPF     ? "enabled"  : "disabled",
-	reg & IXGBE_FCTRL_PMCF    ? "enabled"  : "disabled",
 	reg & IXGBE_FCTRL_BAM     ? "enabled"  : "disabled",
 	reg & IXGBE_FCTRL_UPE     ? "enabled"  : "disabled",
 	reg & IXGBE_FCTRL_MPE     ? "enabled"  : "disabled",
 	reg & IXGBE_FCTRL_SBP     ? "enabled"  : "disabled");
 
+	/* Some FCTRL bits are valid only on 82598 */
+	if (mac_type == ixgbe_mac_82598EB) {
+		fprintf(stdout,
+		"       Receive Flow Control Packets:                  %s\n"
+		"       Receive Priority Flow Control Packets:         %s\n"
+		"       Discard Pause Frames:                          %s\n"
+		"       Pass MAC Control Frames:                       %s\n",
+		reg & IXGBE_FCTRL_RFCE    ? "enabled"  : "disabled",
+		reg & IXGBE_FCTRL_RPFCE   ? "enabled"  : "disabled",
+		reg & IXGBE_FCTRL_DPF     ? "enabled"  : "disabled",
+		reg & IXGBE_FCTRL_PMCF    ? "enabled"  : "disabled");
+	 }
+
+	reg = regs_buff[1128];
+	if (mac_type >= ixgbe_mac_82599EB) {
+		fprintf(stdout,
+		"0x04294: MFLCN (TabMAC Flow Control register)         0x%08X\n"
+		"       Receive Flow Control Packets:                  %s\n"
+		"       Discard Pause Frames:                          %s\n"
+		"       Pass MAC Control Frames:                       %s\n"
+		"       Receive Priority Flow Control Packets:         %s\n",
+		reg,
+		reg & IXGBE_MFLCN_RFCE    ? "enabled"  : "disabled",
+		reg & IXGBE_FCTRL_DPF     ? "enabled"  : "disabled",
+		reg & IXGBE_FCTRL_PMCF    ? "enabled"  : "disabled",
+		reg & IXGBE_FCTRL_RPFCE   ? "enabled"  : "disabled");
+	}
+
 	reg = regs_buff[516];
 	fprintf(stdout,
 	"0x05088: VLNCTRL (VLAN Control register)              0x%08X\n"
-- 
1.7.6.4
