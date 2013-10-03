From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool] ethtool: ixgbe DCB registers dump for 82599 and x540
Date: Thu,  3 Oct 2013 01:11:27 -0700
Message-ID: <1380787887-6878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Leonardo Potenza <leonardo.potenza@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Maryam Tahhan <maryam.tahhan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1878 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561Ab3JCILb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Oct 2013 04:11:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leonardo Potenza <leonardo.potenza@intel.com>

Added support for DCB registers dump using ethtool -d option both for
82599 and x540 ethernet controllers

Signed-off-by: Leonardo Potenza <leonardo.potenza@intel.com>
Signed-off-by: Maryam Tahhan <maryam.tahhan@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Jack Morgan <jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ixgbe.c | 154 ++++++++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 125 insertions(+), 29 deletions(-)

diff --git a/ixgbe.c b/ixgbe.c
index 854e463..6a663e4 100644
--- a/ixgbe.c
+++ b/ixgbe.c
@@ -26,6 +26,8 @@
 #define IXGBE_HLREG0_LPBK          0x00008000
 #define IXGBE_RMCS_TFCE_802_3X     0x00000008
 #define IXGBE_RMCS_TFCE_PRIORITY   0x00000010
+#define IXGBE_FCCFG_TFCE_802_3X    0x00000008
+#define IXGBE_FCCFG_TFCE_PRIORITY  0x00000010
 #define IXGBE_MFLCN_PMCF           0x00000001 /* Pass MAC Control Frames */
 #define IXGBE_MFLCN_DPF            0x00000002 /* Discard Pause Frame */
 #define IXGBE_MFLCN_RPFCE          0x00000004 /* Receive Priority FC Enable */
@@ -127,6 +129,7 @@ int
 ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 {
 	u32 *regs_buff = (u32 *)regs->data;
+	u32 regs_buff_len = regs->len / sizeof(*regs_buff);
 	u32 reg;
 	u16 hw_device_id = (u16) regs->version;
 	u8 version = (u8)(regs->version >> 24);
@@ -208,13 +211,23 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	(reg & IXGBE_SRRCTL_BSIZEPKT_MASK) <= 0x10 ? (reg & IXGBE_SRRCTL_BSIZEPKT_MASK) : 0x10);
 
 	reg = regs_buff[829];
-	fprintf(stdout,
-	"0x03D00: RMCS (Receive Music Control register)        0x%08X\n"
-	"       Transmit Flow Control:                         %s\n"
-	"       Priority Flow Control:                         %s\n",
-	reg,
-	reg & IXGBE_RMCS_TFCE_802_3X     ? "enabled"  : "disabled",
-	reg & IXGBE_RMCS_TFCE_PRIORITY   ? "enabled"  : "disabled");
+	if (mac_type == ixgbe_mac_82598EB) {
+		fprintf(stdout,
+		"0x03D00: RMCS (Receive Music Control register)        0x%08X\n"
+		"       Transmit Flow Control:                         %s\n"
+		"       Priority Flow Control:                         %s\n",
+		reg,
+		reg & IXGBE_RMCS_TFCE_802_3X     ? "enabled"  : "disabled",
+		reg & IXGBE_RMCS_TFCE_PRIORITY   ? "enabled"  : "disabled");
+	} else if (mac_type >= ixgbe_mac_82599EB) {
+		fprintf(stdout,
+		"0x03D00: FCCFG (Flow Control Configuration)           0x%08X\n"
+		"       Transmit Flow Control:                         %s\n"
+		"       Priority Flow Control:                         %s\n",
+		reg,
+		reg & IXGBE_FCCFG_TFCE_802_3X     ? "enabled"  : "disabled",
+		reg & IXGBE_FCCFG_TFCE_PRIORITY   ? "enabled"  : "disabled");
+	}
 
 	reg = regs_buff[1047];
 	fprintf(stdout,
@@ -428,7 +441,7 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x02F00: RDRXCTL     (Receive DMA Control)            0x%08X\n",
 		regs_buff[469]);
 
-	for (i = 0; i < 8; i++ )
+	for (i = 0; i < 8; i++)
 		fprintf(stdout,
 		"0x%05X: RXPBSIZE%d   (Receive Packet Buffer Size %d)   0x%08X\n",
 		0x3C00 + (4 * i), i, i, regs_buff[470 + i]);
@@ -592,50 +605,133 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x09000: FHFT        (Flexible Host Filter Table)     0x%08X\n",
 		regs_buff[828]);
 
-	/* DCE */
-	fprintf(stdout,
+	/* DCB */
+	if (mac_type == ixgbe_mac_82598EB) {
+		fprintf(stdout,
 		"0x07F40: DPMCS       (Desc. Plan Music Ctrl Status)   0x%08X\n",
 		regs_buff[830]);
 
-	fprintf(stdout,
+		fprintf(stdout,
 		"0x0CD00: PDPMCS      (Pkt Data Plan Music ctrl Stat)  0x%08X\n",
 		regs_buff[831]);
 
-	if (mac_type == ixgbe_mac_82598EB) {
 		fprintf(stdout,
-			"0x050A0: RUPPBMR     (Rx User Prior to Pkt Buff Map)  0x%08X\n",
-			regs_buff[832]);
+		"0x050A0: RUPPBMR     (Rx User Prior to Pkt Buff Map)  0x%08X\n",
+		regs_buff[832]);
 
 		for (i = 0; i < 8; i++)
 			fprintf(stdout,
-				"0x%05X: RT2CR%d      (Receive T2 Configure %d)         0x%08X\n",
-				0x03C20 + (4 * i), i, i, regs_buff[833 + i]);
+			"0x%05X: RT2CR%d      (Receive T2 Configure %d)         0x%08X\n",
+			0x03C20 + (4 * i), i, i, regs_buff[833 + i]);
 
 		for (i = 0; i < 8; i++)
 			fprintf(stdout,
-				"0x%05X: RT2SR%d      (Recieve T2 Status %d)            0x%08X\n",
-				0x03C40 + (4 * i), i, i, regs_buff[841 + i]);
+			"0x%05X: RT2SR%d      (Receive T2 Status %d)            0x%08X\n",
+			0x03C40 + (4 * i), i, i, regs_buff[841 + i]);
 
 		for (i = 0; i < 8; i++)
 			fprintf(stdout,
-				"0x%05X: TDTQ2TCCR%d  (Tx Desc TQ2 TC Config %d)        0x%08X\n",
-				0x0602C + (0x40 * i), i, i, regs_buff[849 + i]);
+			"0x%05X: TDTQ2TCCR%d  (Tx Desc TQ2 TC Config %d)        0x%08X\n",
+			0x0602C + (0x40 * i), i, i, regs_buff[849 + i]);
 
 		for (i = 0; i < 8; i++)
 			fprintf(stdout,
-				"0x%05X: TDTQ2TCSR%d  (Tx Desc TQ2 TC Status %d)        0x%08X\n",
-				0x0622C + (0x40 * i), i, i, regs_buff[857 + i]);
-	}
+			"0x%05X: TDTQ2TCSR%d  (Tx Desc TQ2 TC Status %d)        0x%08X\n",
+			0x0622C + (0x40 * i), i, i, regs_buff[857 + i]);
 
-	for (i = 0; i < 8; i++)
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+			"0x%05X: TDPT2TCCR%d  (Tx Data Plane T2 TC Config %d)   0x%08X\n",
+			0x0CD20 + (4 * i), i, i, regs_buff[865 + i]);
+
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+			"0x%05X: TDPT2TCSR%d  (Tx Data Plane T2 TC Status %d)   0x%08X\n",
+			0x0CD40 + (4 * i), i, i, regs_buff[873 + i]);
+	} else if (mac_type >= ixgbe_mac_82599EB) {
 		fprintf(stdout,
-		"0x%05X: TDPT2TCCR%d  (Tx Data Plane T2 TC Config %d)   0x%08X\n",
-		0x0CD20 + (4 * i), i, i, regs_buff[865 + i]);
+			"0x04900: RTTDCS      (Tx Descr Plane Ctrl&Status)     0x%08X\n",
+			regs_buff[830]);
+
+		fprintf(stdout,
+			"0x0CD00: RTTPCS      (Tx Pkt Plane Ctrl&Status)       0x%08X\n",
+			regs_buff[831]);
 
-	for (i = 0; i < 8; i++)
 		fprintf(stdout,
-		"0x%05X: TDPT2TCSR%d  (Tx Data Plane T2 TC Status %d)   0x%08X\n",
-		0x0CD40 + (4 * i), i, i, regs_buff[873 + i]);
+			"0x02430: RTRPCS      (Rx Packet Plane Ctrl&Status)    0x%08X\n",
+			regs_buff[832]);
+
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+			"0x%05X: RTRPT4C%d    (Rx Packet Plane T4 Config %d)    0x%08X\n",
+			0x02140 + (4 * i), i, i, regs_buff[833 + i]);
+
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+			"0x%05X: RTRPT4S%d    (Rx Packet Plane T4 Status %d)    0x%08X\n",
+			0x02160 + (4 * i), i, i, regs_buff[841 + i]);
+
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+			"0x%05X: RTTDT2C%d    (Tx Descr Plane T2 Config %d)     0x%08X\n",
+			0x04910 + (4 * i), i, i, regs_buff[849 + i]);
+
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+			"0x%05X: RTTDT2S%d    (Tx Descr Plane T2 Status %d)     0x%08X\n",
+			0x04930 + (4 * i), i, i, regs_buff[857 + i]);
+
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+			"0x%05X: RTTPT2C%d    (Tx Packet Plane T2 Config %d)    0x%08X\n",
+			0x0CD20 + (4 * i), i, i, regs_buff[865]);
+
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+			"0x%05X: RTTPT2S%d    (Tx Packet Plane T2 Status %d)    0x%08X\n",
+			0x0CD40 + (4 * i), i, i, regs_buff[873 + i]);
+
+		if (regs_buff_len > 1129) {
+			fprintf(stdout,
+			"0x03020: RTRUP2TC    (Rx User Prio to Traffic Classes)0x%08X\n",
+			regs_buff[1129]);
+
+			fprintf(stdout,
+			"0x0C800: RTTUP2TC    (Tx User Prio to Traffic Classes)0x%08X\n",
+			regs_buff[1130]);
+
+			for (i = 0; i < 4; i++)
+				fprintf(stdout,
+				"0x%05X: TXLLQ%d      (Strict Low Lat Tx Queues %d)     0x%08X\n",
+				0x082E0 + (4 * i), i, i, regs_buff[1131 + i]);
+
+			if (mac_type == ixgbe_mac_82599EB) {
+				fprintf(stdout,
+				"0x04980: RTTBCNRM    (DCB TX Rate Sched MMW)          0x%08X\n",
+				regs_buff[1135]);
+
+				fprintf(stdout,
+				"0x0498C: RTTBCNRD    (DCB TX Rate-Scheduler Drift)    0x%08X\n",
+				regs_buff[1136]);
+			} else if (mac_type == ixgbe_mac_X540) {
+				fprintf(stdout,
+				"0x04980: RTTQCNRM    (DCB TX QCN Rate Sched MMW)      0x%08X\n",
+				regs_buff[1135]);
+
+				fprintf(stdout,
+				"0x0498C: RTTQCNRR    (DCB TX QCN Rate Reset)          0x%08X\n",
+				regs_buff[1136]);
+
+				fprintf(stdout,
+				"0x08B00: RTTQCNCR    (DCB TX QCN Control)             0x%08X\n",
+				regs_buff[1137]);
+
+				fprintf(stdout,
+				"0x04A90: RTTQCNTG    (DCB TX QCN Tagging)             0x%08X\n",
+				regs_buff[1138]);
+			}
+		}
+	}
 
 	/* Statistics */
 	fprintf(stdout,
-- 
1.8.3.1
