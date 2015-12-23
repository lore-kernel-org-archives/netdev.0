From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 7/9] cxgb4: Update mps_tcam output to include T6 fields
Date: Wed, 23 Dec 2015 22:47:17 +0530
Message-ID: <1450891039-17196-8-git-send-email-hariprasad@chelsio.com>
References: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:42965 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933213AbbLWRQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 12:16:11 -0500
In-Reply-To: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In T6, MPS classification has a 512 deep TCAM to do the match lookup.
Each entry has 80x2b sets containing 48 bit MAC address, port number,
VLAN Valid/ID, VNI, lookup type (outer or inner packet header).
[71:48] bit locations are overloaded for outer vs. inner lookup types.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 100 +++++++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  24 +++++
 2 files changed, 105 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 98965a4..1fe2db7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1586,25 +1586,35 @@ static int mps_tcam_show(struct seq_file *seq, void *v)
 {
 	struct adapter *adap = seq->private;
 	unsigned int chip_ver = CHELSIO_CHIP_VERSION(adap->params.chip);
-
 	if (v == SEQ_START_TOKEN) {
-		if (adap->params.arch.mps_rplc_size > 128)
+		if (chip_ver > CHELSIO_T5) {
 			seq_puts(seq, "Idx  Ethernet address     Mask     "
+				 "  VNI   Mask   IVLAN Vld "
+				 "DIP_Hit   Lookup  Port "
 				 "Vld Ports PF  VF                           "
 				 "Replication                                "
 				 "    P0 P1 P2 P3  ML\n");
-		else
-			seq_puts(seq, "Idx  Ethernet address     Mask     "
-				 "Vld Ports PF  VF              Replication"
-				 "	         P0 P1 P2 P3  ML\n");
+		} else {
+			if (adap->params.arch.mps_rplc_size > 128)
+				seq_puts(seq, "Idx  Ethernet address     Mask     "
+					 "Vld Ports PF  VF                           "
+					 "Replication                                "
+					 "    P0 P1 P2 P3  ML\n");
+			else
+				seq_puts(seq, "Idx  Ethernet address     Mask     "
+					 "Vld Ports PF  VF              Replication"
+					 "	         P0 P1 P2 P3  ML\n");
+		}
 	} else {
 		u64 mask;
 		u8 addr[ETH_ALEN];
-		bool replicate;
+		bool replicate, dip_hit = false, vlan_vld = false;
 		unsigned int idx = (uintptr_t)v - 2;
 		u64 tcamy, tcamx, val;
-		u32 cls_lo, cls_hi, ctl;
+		u32 cls_lo, cls_hi, ctl, data2, vnix = 0, vniy = 0;
 		u32 rplc[8] = {0};
+		u8 lookup_type = 0, port_num = 0;
+		u16 ivlan = 0;
 
 		if (chip_ver > CHELSIO_T5) {
 			/* CtlCmdType - 0: Read, 1: Write
@@ -1623,6 +1633,22 @@ static int mps_tcam_show(struct seq_file *seq, void *v)
 			val = t4_read_reg(adap, MPS_CLS_TCAM_DATA1_A);
 			tcamy = DMACH_G(val) << 32;
 			tcamy |= t4_read_reg(adap, MPS_CLS_TCAM_DATA0_A);
+			data2 = t4_read_reg(adap, MPS_CLS_TCAM_DATA2_CTL_A);
+			lookup_type = DATALKPTYPE_G(data2);
+			/* 0 - Outer header, 1 - Inner header
+			 * [71:48] bit locations are overloaded for
+			 * outer vs. inner lookup types.
+			 */
+			if (lookup_type && (lookup_type != DATALKPTYPE_M)) {
+				/* Inner header VNI */
+				vniy = ((data2 & DATAVIDH2_F) << 23) |
+				       (DATAVIDH1_G(data2) << 16) | VIDL_G(val);
+				dip_hit = data2 & DATADIPHIT_F;
+			} else {
+				vlan_vld = data2 & DATAVIDH2_F;
+				ivlan = VIDL_G(val);
+			}
+			port_num = DATAPORTNUM_G(data2);
 
 			/* Read tcamx. Change the control param */
 			ctl |= CTLXYBITSEL_V(1);
@@ -1630,6 +1656,12 @@ static int mps_tcam_show(struct seq_file *seq, void *v)
 			val = t4_read_reg(adap, MPS_CLS_TCAM_DATA1_A);
 			tcamx = DMACH_G(val) << 32;
 			tcamx |= t4_read_reg(adap, MPS_CLS_TCAM_DATA0_A);
+			data2 = t4_read_reg(adap, MPS_CLS_TCAM_DATA2_CTL_A);
+			if (lookup_type && (lookup_type != DATALKPTYPE_M)) {
+				/* Inner header VNI mask */
+				vnix = ((data2 & DATAVIDH2_F) << 23) |
+				       (DATAVIDH1_G(data2) << 16) | VIDL_G(val);
+			}
 		} else {
 			tcamy = t4_read_reg64(adap, MPS_CLS_TCAM_Y_L(idx));
 			tcamx = t4_read_reg64(adap, MPS_CLS_TCAM_X_L(idx));
@@ -1689,17 +1721,47 @@ static int mps_tcam_show(struct seq_file *seq, void *v)
 		}
 
 		tcamxy2valmask(tcamx, tcamy, addr, &mask);
-		if (chip_ver > CHELSIO_T5)
-			seq_printf(seq, "%3u %02x:%02x:%02x:%02x:%02x:%02x "
-				   "%012llx%3c   %#x%4u%4d",
-				   idx, addr[0], addr[1], addr[2], addr[3],
-				   addr[4], addr[5], (unsigned long long)mask,
-				   (cls_lo & T6_SRAM_VLD_F) ? 'Y' : 'N',
-				   PORTMAP_G(cls_hi),
-				   T6_PF_G(cls_lo),
-				   (cls_lo & T6_VF_VALID_F) ?
-				   T6_VF_G(cls_lo) : -1);
-		else
+		if (chip_ver > CHELSIO_T5) {
+			/* Inner header lookup */
+			if (lookup_type && (lookup_type != DATALKPTYPE_M)) {
+				seq_printf(seq,
+					   "%3u %02x:%02x:%02x:%02x:%02x:%02x "
+					   "%012llx %06x %06x    -    -   %3c"
+					   "      %3c  %4x   "
+					   "%3c   %#x%4u%4d", idx, addr[0],
+					   addr[1], addr[2], addr[3],
+					   addr[4], addr[5],
+					   (unsigned long long)mask,
+					   vniy, vnix, dip_hit ? 'Y' : 'N',
+					   lookup_type ? 'I' : 'O', port_num,
+					   (cls_lo & T6_SRAM_VLD_F) ? 'Y' : 'N',
+					   PORTMAP_G(cls_hi),
+					   T6_PF_G(cls_lo),
+					   (cls_lo & T6_VF_VALID_F) ?
+					   T6_VF_G(cls_lo) : -1);
+			} else {
+				seq_printf(seq,
+					   "%3u %02x:%02x:%02x:%02x:%02x:%02x "
+					   "%012llx    -       -   ",
+					   idx, addr[0], addr[1], addr[2],
+					   addr[3], addr[4], addr[5],
+					   (unsigned long long)mask);
+
+				if (vlan_vld)
+					seq_printf(seq, "%4u   Y     ", ivlan);
+				else
+					seq_puts(seq, "  -    N     ");
+
+				seq_printf(seq,
+					   "-      %3c  %4x   %3c   %#x%4u%4d",
+					   lookup_type ? 'I' : 'O', port_num,
+					   (cls_lo & T6_SRAM_VLD_F) ? 'Y' : 'N',
+					   PORTMAP_G(cls_hi),
+					   T6_PF_G(cls_lo),
+					   (cls_lo & T6_VF_VALID_F) ?
+					   T6_VF_G(cls_lo) : -1);
+			}
+		} else
 			seq_printf(seq, "%3u %02x:%02x:%02x:%02x:%02x:%02x "
 				   "%012llx%3c   %#x%4u%4d",
 				   idx, addr[0], addr[1], addr[2], addr[3],
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 0971cc4..9fea255 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2398,6 +2398,30 @@
 #define MPS_CLS_TCAM_DATA0_A 0xf000
 #define MPS_CLS_TCAM_DATA1_A 0xf004
 
+#define VIDL_S    16
+#define VIDL_M    0xffffU
+#define VIDL_G(x) (((x) >> VIDL_S) & VIDL_M)
+
+#define DATALKPTYPE_S    10
+#define DATALKPTYPE_M    0x3U
+#define DATALKPTYPE_G(x) (((x) >> DATALKPTYPE_S) & DATALKPTYPE_M)
+
+#define DATAPORTNUM_S    12
+#define DATAPORTNUM_M    0xfU
+#define DATAPORTNUM_G(x) (((x) >> DATAPORTNUM_S) & DATAPORTNUM_M)
+
+#define DATADIPHIT_S    8
+#define DATADIPHIT_V(x) ((x) << DATADIPHIT_S)
+#define DATADIPHIT_F    DATADIPHIT_V(1U)
+
+#define DATAVIDH2_S    7
+#define DATAVIDH2_V(x) ((x) << DATAVIDH2_S)
+#define DATAVIDH2_F    DATAVIDH2_V(1U)
+
+#define DATAVIDH1_S    0
+#define DATAVIDH1_M    0x7fU
+#define DATAVIDH1_G(x) (((x) >> DATAVIDH1_S) & DATAVIDH1_M)
+
 #define USED_S    16
 #define USED_M    0x7ffU
 #define USED_G(x) (((x) >> USED_S) & USED_M)
-- 
2.3.4
