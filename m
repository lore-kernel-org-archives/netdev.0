From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH] ethtool: add support for latest Intel adapters
Date: Fri, 6 May 2005 19:15:54 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0505061850190.11228-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds register dump and device ID support for the new Intel
PRO/1000 Server Adapters with a PCI-Express bus.  It also took care of a 
little housekeeping of some missing device IDs.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

===== e1000.c 1.5 vs edited =====
--- 1.5/e1000.c	2004-04-09 11:44:55 -07:00
+++ edited/e1000.c	2005-04-15 17:15:55 -07:00
@@ -137,10 +137,16 @@
 #define E1000_DEV_ID_82547GI             0x1075
 #define E1000_DEV_ID_82541GI             0x1076
 #define E1000_DEV_ID_82541GI_MOBILE      0x1077
+#define E1000_DEV_ID_82541GI_LF          0x107C
 #define E1000_DEV_ID_82546GB_COPPER      0x1079
 #define E1000_DEV_ID_82546GB_FIBER       0x107A
 #define E1000_DEV_ID_82546GB_SERDES      0x107B
+#define E1000_DEV_ID_82546GB_PCIE        0x108A
 #define E1000_DEV_ID_82547EI             0x1019
+#define E1000_DEV_ID_82573E              0x108B
+#define E1000_DEV_ID_82573E_IAMT         0x108C
+
+#define E1000_DEV_ID_82546GB_QUAD_COPPER 0x1099
 
 #define E1000_82542_2_0_REV_ID 2
 #define E1000_82542_2_1_REV_ID 3
@@ -162,6 +168,7 @@
 	e1000_82541_rev_2,
 	e1000_82547,
 	e1000_82547_rev_2,
+	e1000_82573,
 	e1000_num_macs
 };
 
@@ -217,6 +224,8 @@
 	case E1000_DEV_ID_82546GB_COPPER:
 	case E1000_DEV_ID_82546GB_FIBER:
 	case E1000_DEV_ID_82546GB_SERDES:
+	case E1000_DEV_ID_82546GB_PCIE:
+	case E1000_DEV_ID_82546GB_QUAD_COPPER:
 		mac_type = e1000_82546_rev_3;
 		break;
 	case E1000_DEV_ID_82541EI:
@@ -225,6 +234,7 @@
 		break;
 	case E1000_DEV_ID_82541ER:
 	case E1000_DEV_ID_82541GI:
+	case E1000_DEV_ID_82541GI_LF:
 	case E1000_DEV_ID_82541GI_MOBILE:
 		mac_type = e1000_82541_rev_2;
 		break;
@@ -234,6 +244,10 @@
 	case E1000_DEV_ID_82547GI:
 		mac_type = e1000_82547_rev_2;
 		break;
+	case E1000_DEV_ID_82573E:
+	case E1000_DEV_ID_82573E_IAMT:
+		mac_type = e1000_82573;
+		break;
 	default:
 		/* list of supported devices probably needs updating */
 		mac_type = e1000_82543;
@@ -309,7 +323,23 @@
 		reg,
 		reg & E1000_STATUS_FD      ? "full"        : "half",
 		reg & E1000_STATUS_LU      ? "link config" : "no link config");
-	if(mac_type >= e1000_82543) {
+	if(mac_type >= e1000_82573) {
+	fprintf(stdout,
+		"      TBI mode:                          %s\n"
+		"      Link speed:                        %s\n"
+		"      Bus type:                          %s\n"
+		"      Port number:                       %s\n",
+		reg & E1000_STATUS_TBIMODE ? "enabled"     : "disabled",
+		(reg & E1000_STATUS_SPEED_MASK) == E1000_STATUS_SPEED_10   ?
+		"10Mb/s" :
+		(reg & E1000_STATUS_SPEED_MASK) == E1000_STATUS_SPEED_100  ?
+		"100Mb/s" :
+		(reg & E1000_STATUS_SPEED_MASK) == E1000_STATUS_SPEED_1000 ?
+		"1000Mb/s" : "not used",
+		"PCI-Express",
+		(reg & E1000_STATUS_FUNC_MASK) == 0 ? "0" : "1");
+	}
+	else if(mac_type >= e1000_82543) {
 	fprintf(stdout,
 		"      TBI mode:                          %s\n"
 		"      Link speed:                        %s\n"
@@ -431,7 +461,9 @@
 	/* PHY type */
 	fprintf(stdout,
 		"PHY type:                                %s\n",
-		regs_buff[12] == 0 ? "M88" : "IGP");
+		regs_buff[12] == 0 ? "M88" :
+		regs_buff[12] == 1 ? "IGP" :
+		regs_buff[12] == 2 ? "IGP2" : "unknown" );
 
 	return 0;
 }
