From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool 2/3] ethtool/ixgbe: Correct offsets and support x550, x550em_x, x550em_a
Date: Wed,  4 May 2016 09:44:52 -0700
Message-ID: <1462380293-4132-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Preethi Banala <preethi.banala@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5935 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541AbcEDQo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:44:57 -0400
In-Reply-To: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Preethi Banala <preethi.banala@intel.com>

Correct hard-coded wrong offset values and add several conditions to
display registers for x550, x550em_x and x550em_a based on datasheet/
EAS document.

Signed-off-by: Preethi Banala <preethi.banala@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ixgbe.c | 74 ++++++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 41 insertions(+), 33 deletions(-)

diff --git a/ixgbe.c b/ixgbe.c
index a375782..4f5af77 100644
--- a/ixgbe.c
+++ b/ixgbe.c
@@ -173,6 +173,7 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	u32 *regs_buff = (u32 *)regs->data;
 	u32 regs_buff_len = regs->len / sizeof(*regs_buff);
 	u32 reg;
+	u32 offset;
 	u16 hw_device_id = (u16) regs->version;
 	u8 version = (u8)(regs->version >> 24);
 	u8 i;
@@ -273,7 +274,7 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 
 	reg = regs_buff[1047];
 	fprintf(stdout,
-	"0x04250: HLREG0 (Highlander Control 0 register)       0x%08X\n"
+	"0x04240: HLREG0 (Highlander Control 0 register)       0x%08X\n"
 	"       Transmit CRC:                                  %s\n"
 	"       Receive CRC Strip:                             %s\n"
 	"       Jumbo Frames:                                  %s\n"
@@ -320,17 +321,19 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		regs_buff[7]);
 
 	/* NVM Register */
+	offset = mac_type == ixgbe_mac_x550em_a ? 0x15FF8 : 0x10010;
 	fprintf(stdout,
-		"0x10010: EEC         (EEPROM/Flash Control)           0x%08X\n",
-		regs_buff[8]);
+		"0x%05X: EEC         (EEPROM/Flash Control)           0x%08X\n",
+		offset, regs_buff[8]);
 
 	fprintf(stdout,
 		"0x10014: EERD        (EEPROM Read)                    0x%08X\n",
 		regs_buff[9]);
 
+	offset = mac_type == ixgbe_mac_x550em_a ? 0x15F6C : 0x1001C;
 	fprintf(stdout,
-		"0x1001C: FLA         (Flash Access)                   0x%08X\n",
-		regs_buff[10]);
+		"0x%05X: FLA         (Flash Access)                   0x%08X\n",
+		offset, regs_buff[10]);
 
 	fprintf(stdout,
 		"0x10110: EEMNGCTL    (Manageability EEPROM Control)   0x%08X\n",
@@ -341,7 +344,7 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		regs_buff[12]);
 
 	fprintf(stdout,
-		"0x10110: FLMNGCTL    (Manageability Flash Control)    0x%08X\n",
+		"0x10118: FLMNGCTL    (Manageability Flash Control)    0x%08X\n",
 		regs_buff[13]);
 
 	fprintf(stdout,
@@ -356,9 +359,10 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x1013C: FLOP        (Flash Opcode)                   0x%08X\n",
 		regs_buff[16]);
 
+	offset = mac_type == ixgbe_mac_x550em_a ? 0x15F64 : 0x10200;
 	fprintf(stdout,
-		"0x10200: GRC         (General Receive Control)        0x%08X\n",
-		regs_buff[17]);
+		"0x%05X: GRC         (General Receive Control)        0x%08X\n",
+		offset, regs_buff[17]);
 
 	/* Interrupt */
 	fprintf(stdout,
@@ -690,7 +694,7 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 			fprintf(stdout,
 			"0x%05X: TDPT2TCSR%d  (Tx Data Plane T2 TC Status %d)   0x%08X\n",
 			0x0CD40 + (4 * i), i, i, regs_buff[873 + i]);
-	} else if (mac_type >= ixgbe_mac_82599EB) {
+	} else if (mac_type >= ixgbe_mac_82599EB && mac_type <= ixgbe_mac_x550) {
 		fprintf(stdout,
 			"0x04900: RTTDCS      (Tx Descr Plane Ctrl&Status)     0x%08X\n",
 			regs_buff[830]);
@@ -718,60 +722,64 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 			"0x%05X: RTTDT2C%d    (Tx Descr Plane T2 Config %d)     0x%08X\n",
 			0x04910 + (4 * i), i, i, regs_buff[849 + i]);
 
-		for (i = 0; i < 8; i++)
-			fprintf(stdout,
-			"0x%05X: RTTDT2S%d    (Tx Descr Plane T2 Status %d)     0x%08X\n",
-			0x04930 + (4 * i), i, i, regs_buff[857 + i]);
+		if (mac_type < ixgbe_mac_x550)
+			for (i = 0; i < 8; i++)
+				fprintf(stdout,
+					"0x%05X: RTTDT2S%d    (Tx Descr Plane T2 Status %d)     0x%08X\n",
+					0x04930 + (4 * i), i, i, regs_buff[857 + i]);
 
 		for (i = 0; i < 8; i++)
 			fprintf(stdout,
 			"0x%05X: RTTPT2C%d    (Tx Packet Plane T2 Config %d)    0x%08X\n",
 			0x0CD20 + (4 * i), i, i, regs_buff[865]);
 
-		for (i = 0; i < 8; i++)
-			fprintf(stdout,
-			"0x%05X: RTTPT2S%d    (Tx Packet Plane T2 Status %d)    0x%08X\n",
-			0x0CD40 + (4 * i), i, i, regs_buff[873 + i]);
+		if (mac_type < ixgbe_mac_x550)
+			for (i = 0; i < 8; i++)
+				fprintf(stdout,
+					"0x%05X: RTTPT2S%d    (Tx Packet Plane T2 Status %d)    0x%08X\n",
+					0x0CD40 + (4 * i), i, i, regs_buff[873 + i]);
+	}
 
-		if (regs_buff_len > 1129) {
-			fprintf(stdout,
+	if (regs_buff_len > 1129 && mac_type != ixgbe_mac_82598EB) {
+		fprintf(stdout,
 			"0x03020: RTRUP2TC    (Rx User Prio to Traffic Classes)0x%08X\n",
 			regs_buff[1129]);
 
-			fprintf(stdout,
+		fprintf(stdout,
 			"0x0C800: RTTUP2TC    (Tx User Prio to Traffic Classes)0x%08X\n",
 			regs_buff[1130]);
 
+		if (mac_type <= ixgbe_mac_x550)
 			for (i = 0; i < 4; i++)
 				fprintf(stdout,
-				"0x%05X: TXLLQ%d      (Strict Low Lat Tx Queues %d)     0x%08X\n",
-				0x082E0 + (4 * i), i, i, regs_buff[1131 + i]);
+					"0x%05X: TXLLQ%d      (Strict Low Lat Tx Queues %d)     0x%08X\n",
+					0x082E0 + (4 * i), i, i, regs_buff[1131 + i]);
 
-			if (mac_type == ixgbe_mac_82599EB) {
-				fprintf(stdout,
+		if (mac_type == ixgbe_mac_82599EB) {
+			fprintf(stdout,
 				"0x04980: RTTBCNRM    (DCB TX Rate Sched MMW)          0x%08X\n",
 				regs_buff[1135]);
 
-				fprintf(stdout,
+			fprintf(stdout,
 				"0x0498C: RTTBCNRD    (DCB TX Rate-Scheduler Drift)    0x%08X\n",
 				regs_buff[1136]);
-			} else if (mac_type == ixgbe_mac_X540) {
-				fprintf(stdout,
+		} else if (mac_type <= ixgbe_mac_x550) {
+			fprintf(stdout,
 				"0x04980: RTTQCNRM    (DCB TX QCN Rate Sched MMW)      0x%08X\n",
 				regs_buff[1135]);
 
-				fprintf(stdout,
+			fprintf(stdout,
 				"0x0498C: RTTQCNRR    (DCB TX QCN Rate Reset)          0x%08X\n",
 				regs_buff[1136]);
 
+			if (mac_type < ixgbe_mac_x550)
 				fprintf(stdout,
-				"0x08B00: RTTQCNCR    (DCB TX QCN Control)             0x%08X\n",
-				regs_buff[1137]);
+					"0x08B00: RTTQCNCR    (DCB TX QCN Control)             0x%08X\n",
+					regs_buff[1137]);
 
-				fprintf(stdout,
+			fprintf(stdout,
 				"0x04A90: RTTQCNTG    (DCB TX QCN Tagging)             0x%08X\n",
 				regs_buff[1138]);
-			}
 		}
 	}
 
@@ -1127,7 +1135,7 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 			regs_buff[1068]);
 
 		fprintf(stdout,
-			"0x042B0: ANLP2       (Auto Neg Lnk Part. Ctrl Word 2) 0x%08X\n",
+			"0x042B4: ANLP2       (Auto Neg Lnk Part. Ctrl Word 2) 0x%08X\n",
 			regs_buff[1069]);
 	}
 
-- 
2.5.5
