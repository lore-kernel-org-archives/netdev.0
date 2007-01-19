From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: e1000: update device ID table for register dumps
Date: Fri, 19 Jan 2007 22:53:49 +0000 (UTC)
Message-ID: <20070119225313.297224186C@ahkok-mobl.jf.intel.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6664 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932807AbXASWxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 17:53:25 -0500
To: jgarzik@pobox.com
Date: Fri Jan 19 14:49:57 PST 2007
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

e1000: update device ID table for register dumps with new devices

From: Auke Kok <auke-jan.h.kok@intel.com>

The register dump routine of e1000 was missing several newer chipsets. I
reimported the mac detection code from the linux e1000 driver. This fixes
newer NIC's reporting that their bus type is PCI instead of PCI-e.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 e1000.c |  154 ++++++++++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 103 insertions(+), 51 deletions(-)

diff --git a/e1000.c b/e1000.c
index 6741323..d67947a 100644
--- a/e1000.c
+++ b/e1000.c
@@ -111,42 +111,66 @@
 #define E1000_TCTL_NRTU   0x02000000    /* No Re-transmit on underrun */
 
 /* PCI Device IDs */
-#define E1000_DEV_ID_82542               0x1000
-#define E1000_DEV_ID_82543GC_FIBER       0x1001
-#define E1000_DEV_ID_82543GC_COPPER      0x1004
-#define E1000_DEV_ID_82544EI_COPPER      0x1008
-#define E1000_DEV_ID_82544EI_FIBER       0x1009
-#define E1000_DEV_ID_82544GC_COPPER      0x100C
-#define E1000_DEV_ID_82544GC_LOM         0x100D
-#define E1000_DEV_ID_82540EM             0x100E
-#define E1000_DEV_ID_82540EM_LOM         0x1015
-#define E1000_DEV_ID_82540EP_LOM         0x1016
-#define E1000_DEV_ID_82540EP             0x1017
-#define E1000_DEV_ID_82540EP_LP          0x101E
-#define E1000_DEV_ID_82545EM_COPPER      0x100F
-#define E1000_DEV_ID_82545EM_FIBER       0x1011
-#define E1000_DEV_ID_82545GM_COPPER      0x1026
-#define E1000_DEV_ID_82545GM_FIBER       0x1027
-#define E1000_DEV_ID_82545GM_SERDES      0x1028
-#define E1000_DEV_ID_82546EB_COPPER      0x1010
-#define E1000_DEV_ID_82546EB_FIBER       0x1012
-#define E1000_DEV_ID_82546EB_QUAD_COPPER 0x101D
-#define E1000_DEV_ID_82541EI             0x1013
-#define E1000_DEV_ID_82541EI_MOBILE      0x1018
-#define E1000_DEV_ID_82541ER             0x1078
-#define E1000_DEV_ID_82547GI             0x1075
-#define E1000_DEV_ID_82541GI             0x1076
-#define E1000_DEV_ID_82541GI_MOBILE      0x1077
-#define E1000_DEV_ID_82541GI_LF          0x107C
-#define E1000_DEV_ID_82546GB_COPPER      0x1079
-#define E1000_DEV_ID_82546GB_FIBER       0x107A
-#define E1000_DEV_ID_82546GB_SERDES      0x107B
-#define E1000_DEV_ID_82546GB_PCIE        0x108A
-#define E1000_DEV_ID_82547EI             0x1019
-#define E1000_DEV_ID_82573E              0x108B
-#define E1000_DEV_ID_82573E_IAMT         0x108C
-
-#define E1000_DEV_ID_82546GB_QUAD_COPPER 0x1099
+#define E1000_DEV_ID_82542                    0x1000
+#define E1000_DEV_ID_82543GC_FIBER            0x1001
+#define E1000_DEV_ID_82543GC_COPPER           0x1004
+#define E1000_DEV_ID_82544EI_COPPER           0x1008
+#define E1000_DEV_ID_82544EI_FIBER            0x1009
+#define E1000_DEV_ID_82544GC_COPPER           0x100C
+#define E1000_DEV_ID_82544GC_LOM              0x100D
+#define E1000_DEV_ID_82540EM                  0x100E
+#define E1000_DEV_ID_82540EM_LOM              0x1015
+#define E1000_DEV_ID_82540EP_LOM              0x1016
+#define E1000_DEV_ID_82540EP                  0x1017
+#define E1000_DEV_ID_82540EP_LP               0x101E
+#define E1000_DEV_ID_82545EM_COPPER           0x100F
+#define E1000_DEV_ID_82545EM_FIBER            0x1011
+#define E1000_DEV_ID_82545GM_COPPER           0x1026
+#define E1000_DEV_ID_82545GM_FIBER            0x1027
+#define E1000_DEV_ID_82545GM_SERDES           0x1028
+#define E1000_DEV_ID_82546EB_COPPER           0x1010
+#define E1000_DEV_ID_82546EB_FIBER            0x1012
+#define E1000_DEV_ID_82546EB_QUAD_COPPER      0x101D
+#define E1000_DEV_ID_82546GB_COPPER           0x1079
+#define E1000_DEV_ID_82546GB_FIBER            0x107A
+#define E1000_DEV_ID_82546GB_SERDES           0x107B
+#define E1000_DEV_ID_82546GB_PCIE             0x108A
+#define E1000_DEV_ID_82546GB_QUAD_COPPER      0x1099
+#define E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3 0x10B5
+#define E1000_DEV_ID_82541EI                  0x1013
+#define E1000_DEV_ID_82541EI_MOBILE           0x1018
+#define E1000_DEV_ID_82541ER_LOM              0x1014
+#define E1000_DEV_ID_82541ER                  0x1078
+#define E1000_DEV_ID_82541GI                  0x1076
+#define E1000_DEV_ID_82541GI_LF               0x107C
+#define E1000_DEV_ID_82541GI_MOBILE           0x1077
+#define E1000_DEV_ID_82547EI                  0x1019
+#define E1000_DEV_ID_82547EI_MOBILE           0x101A
+#define E1000_DEV_ID_82547GI                  0x1075
+#define E1000_DEV_ID_82571EB_COPPER           0x105E
+#define E1000_DEV_ID_82571EB_FIBER            0x105F
+#define E1000_DEV_ID_82571EB_SERDES           0x1060
+#define E1000_DEV_ID_82571EB_QUAD_COPPER      0x10A4
+#define E1000_DEV_ID_82571EB_QUAD_FIBER       0x10A5
+#define E1000_DEV_ID_82571EB_QUAD_COPPER_LP   0x10BC
+#define E1000_DEV_ID_82572EI_COPPER           0x107D
+#define E1000_DEV_ID_82572EI_FIBER            0x107E
+#define E1000_DEV_ID_82572EI_SERDES           0x107F
+#define E1000_DEV_ID_82572EI                  0x10B9
+#define E1000_DEV_ID_82573E                   0x108B
+#define E1000_DEV_ID_82573E_IAMT              0x108C
+#define E1000_DEV_ID_82573L                   0x109A
+#define E1000_DEV_ID_80003ES2LAN_COPPER_DPT   0x1096
+#define E1000_DEV_ID_80003ES2LAN_SERDES_DPT   0x1098
+#define E1000_DEV_ID_80003ES2LAN_COPPER_SPT   0x10BA
+#define E1000_DEV_ID_80003ES2LAN_SERDES_SPT   0x10BB
+#define E1000_DEV_ID_ICH8_IGP_M_AMT           0x1049
+#define E1000_DEV_ID_ICH8_IGP_AMT             0x104A
+#define E1000_DEV_ID_ICH8_IGP_C               0x104B
+#define E1000_DEV_ID_ICH8_IFE                 0x104C
+#define E1000_DEV_ID_ICH8_IFE_GT              0x10C4
+#define E1000_DEV_ID_ICH8_IFE_G               0x10C5
+#define E1000_DEV_ID_ICH8_IGP_M               0x104D
 
 #define E1000_82542_2_0_REV_ID 2
 #define E1000_82542_2_1_REV_ID 3
@@ -155,8 +179,7 @@
 /* Media Access Controlers */
 enum e1000_mac_type {
 	e1000_undefined = 0,
-	e1000_82542_rev2_0,
-	e1000_82542_rev2_1,
+	e1000_82542,
 	e1000_82543,
 	e1000_82544,
 	e1000_82540,
@@ -168,7 +191,11 @@ enum e1000_mac_type {
 	e1000_82541_rev_2,
 	e1000_82547,
 	e1000_82547_rev_2,
+	e1000_82571,
+	e1000_82572,
 	e1000_82573,
+	e1000_80003es2lan,
+	e1000_ich8lan,
 	e1000_num_macs
 };
 
@@ -179,16 +206,7 @@ e1000_get_mac_type(u16 device_id, u8 revision_id)
 
 	switch (device_id) {
 	case E1000_DEV_ID_82542:
-		switch (revision_id) {
-		case E1000_82542_2_0_REV_ID:
-			mac_type = e1000_82542_rev2_0;
-			break;
-		case E1000_82542_2_1_REV_ID:
-			mac_type = e1000_82542_rev2_1;
-			break;
-		default:
-			mac_type = e1000_82542_rev2_0;
-		}
+		mac_type = e1000_82542;
 		break;
 	case E1000_DEV_ID_82543GC_FIBER:
 	case E1000_DEV_ID_82543GC_COPPER:
@@ -226,10 +244,12 @@ e1000_get_mac_type(u16 device_id, u8 revision_id)
 	case E1000_DEV_ID_82546GB_SERDES:
 	case E1000_DEV_ID_82546GB_PCIE:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER:
+	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		mac_type = e1000_82546_rev_3;
 		break;
 	case E1000_DEV_ID_82541EI:
 	case E1000_DEV_ID_82541EI_MOBILE:
+	case E1000_DEV_ID_82541ER_LOM:
 		mac_type = e1000_82541;
 		break;
 	case E1000_DEV_ID_82541ER:
@@ -239,17 +259,49 @@ e1000_get_mac_type(u16 device_id, u8 revision_id)
 		mac_type = e1000_82541_rev_2;
 		break;
 	case E1000_DEV_ID_82547EI:
+	case E1000_DEV_ID_82547EI_MOBILE:
 		mac_type = e1000_82547;
 		break;
 	case E1000_DEV_ID_82547GI:
 		mac_type = e1000_82547_rev_2;
 		break;
+	case E1000_DEV_ID_82571EB_COPPER:
+	case E1000_DEV_ID_82571EB_FIBER:
+	case E1000_DEV_ID_82571EB_SERDES:
+	case E1000_DEV_ID_82571EB_QUAD_COPPER:
+	case E1000_DEV_ID_82571EB_QUAD_FIBER:
+	case E1000_DEV_ID_82571EB_QUAD_COPPER_LP:
+		mac_type = e1000_82571;
+		break;
+	case E1000_DEV_ID_82572EI:
+	case E1000_DEV_ID_82572EI_COPPER:
+	case E1000_DEV_ID_82572EI_FIBER:
+	case E1000_DEV_ID_82572EI_SERDES:
+		mac_type = e1000_82572;
+		break;
 	case E1000_DEV_ID_82573E:
 	case E1000_DEV_ID_82573E_IAMT:
+	case E1000_DEV_ID_82573L:
 		mac_type = e1000_82573;
 		break;
+	case E1000_DEV_ID_80003ES2LAN_COPPER_DPT:
+	case E1000_DEV_ID_80003ES2LAN_SERDES_DPT:
+	case E1000_DEV_ID_80003ES2LAN_COPPER_SPT:
+	case E1000_DEV_ID_80003ES2LAN_SERDES_SPT:
+		mac_type = e1000_80003es2lan;
+		break;
+	case E1000_DEV_ID_ICH8_IFE:
+	case E1000_DEV_ID_ICH8_IFE_GT:
+	case E1000_DEV_ID_ICH8_IFE_G:
+	case E1000_DEV_ID_ICH8_IGP_M:
+	case E1000_DEV_ID_ICH8_IGP_M_AMT:
+	case E1000_DEV_ID_ICH8_IGP_AMT:
+	case E1000_DEV_ID_ICH8_IGP_C:
+		mac_type = e1000_ich8lan;
+		break;
 	default:
-		/* list of supported devices probably needs updating */
+		/* assume old nic and attempt so user can get limited
+		 * functionality */
 		mac_type = e1000_82543;
 		break;
 	}
@@ -321,7 +373,7 @@ e1000_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		reg,
 		reg & E1000_STATUS_FD      ? "full"        : "half",
 		reg & E1000_STATUS_LU      ? "link config" : "no link config");
-	if(mac_type >= e1000_82573) {
+	if (mac_type >= e1000_82571) {
 	fprintf(stdout,
 		"      TBI mode:                          %s\n"
 		"      Link speed:                        %s\n"
@@ -337,7 +389,7 @@ e1000_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"PCI Express",
 		(reg & E1000_STATUS_FUNC_MASK) == 0 ? "0" : "1");
 	}
-	else if(mac_type >= e1000_82543) {
+	else if (mac_type >= e1000_82543) {
 	fprintf(stdout,
 		"      TBI mode:                          %s\n"
 		"      Link speed:                        %s\n"
