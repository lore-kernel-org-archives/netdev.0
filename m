From: Joe Perches <joe@perches.com>
Subject: [PATCH] ixgbe: Remove pr_cont uses
Date: Tue,  3 Jan 2017 07:28:11 -0800
Message-ID: <7be510fd79f67969fc03be24dea68b9f198e486b.1483457249.git.joe@perches.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As pr_cont output can be interleaved by other processes,
using pr_cont should be avoided where possible.

Miscellanea:

o Use a temporary pointer to hold the next descriptions and
  consolidate the pr_cont uses
o Use the temporary buffer to hold the 8 u32 register values and
  emit those in a single go
o Coalesce formats and logging neatening around those changes
o Fix a defective output for the rx ring entry description when
  also emitting rx_buffer_info data

This reduces overall object size a tiny bit too.

$ size drivers/net/ethernet/intel/ixgbe/*.o*
   text	   data	    bss	    dec	    hex	filename
  62167	    728	     12	  62907	   f5bb	drivers/net/ethernet/intel/ixgbe/ixgbe_main.o.new
  62273	    728	     12	  63013	   f625	drivers/net/ethernet/intel/ixgbe/ixgbe_main.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 84 +++++++++++++++------------
 1 file changed, 47 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1e2f39ebd824..bc1c3819f520 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -504,7 +504,7 @@ static const struct ixgbe_reg_info ixgbe_reg_info_tbl[] = {
  */
 static void ixgbe_regdump(struct ixgbe_hw *hw, struct ixgbe_reg_info *reginfo)
 {
-	int i = 0, j = 0;
+	int i;
 	char rname[16];
 	u32 regs[64];
 
@@ -566,17 +566,21 @@ static void ixgbe_regdump(struct ixgbe_hw *hw, struct ixgbe_reg_info *reginfo)
 			regs[i] = IXGBE_READ_REG(hw, IXGBE_TXDCTL(i));
 		break;
 	default:
-		pr_info("%-15s %08x\n", reginfo->name,
-			IXGBE_READ_REG(hw, reginfo->ofs));
+		pr_info("%-15s %08x\n",
+			reginfo->name, IXGBE_READ_REG(hw, reginfo->ofs));
 		return;
 	}
 
-	for (i = 0; i < 8; i++) {
-		snprintf(rname, 16, "%s[%d-%d]", reginfo->name, i*8, i*8+7);
-		pr_err("%-15s", rname);
+	i = 0;
+	while (i < 64) {
+		int j;
+		char buf[9 * 8 + 1];
+		char *p = buf;
+
+		snprintf(rname, 16, "%s[%d-%d]", reginfo->name, i, i + 7);
 		for (j = 0; j < 8; j++)
-			pr_cont(" %08x", regs[i*8+j]);
-		pr_cont("\n");
+			p += sprintf(p, " %08x", regs[i++]);
+		pr_err("%-15s%s\n", rname, buf);
 	}
 
 }
@@ -698,7 +702,18 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 			tx_buffer = &tx_ring->tx_buffer_info[i];
 			u0 = (struct my_u0 *)tx_desc;
 			if (dma_unmap_len(tx_buffer, len) > 0) {
-				pr_info("T [0x%03X]    %016llX %016llX %016llX %08X %p %016llX %p",
+				const char *ring_desc;
+
+				if (i == tx_ring->next_to_use &&
+				    i == tx_ring->next_to_clean)
+					ring_desc = " NTC/U";
+				else if (i == tx_ring->next_to_use)
+					ring_desc = " NTU";
+				else if (i == tx_ring->next_to_clean)
+					ring_desc = " NTC";
+				else
+					ring_desc = "";
+				pr_info("T [0x%03X]    %016llX %016llX %016llX %08X %p %016llX %p%s",
 					i,
 					le64_to_cpu(u0->a),
 					le64_to_cpu(u0->b),
@@ -706,16 +721,8 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 					dma_unmap_len(tx_buffer, len),
 					tx_buffer->next_to_watch,
 					(u64)tx_buffer->time_stamp,
-					tx_buffer->skb);
-				if (i == tx_ring->next_to_use &&
-					i == tx_ring->next_to_clean)
-					pr_cont(" NTC/U\n");
-				else if (i == tx_ring->next_to_use)
-					pr_cont(" NTU\n");
-				else if (i == tx_ring->next_to_clean)
-					pr_cont(" NTC\n");
-				else
-					pr_cont("\n");
+					tx_buffer->skb,
+					ring_desc);
 
 				if (netif_msg_pktdata(adapter) &&
 				    tx_buffer->skb)
@@ -794,34 +801,45 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 		pr_info("------------------------------------\n");
 		pr_info("RX QUEUE INDEX = %d\n", rx_ring->queue_index);
 		pr_info("------------------------------------\n");
-		pr_info("%s%s%s",
+		pr_info("%s%s%s\n",
 			"R  [desc]      [ PktBuf     A0] ",
 			"[  HeadBuf   DD] [bi->dma       ] [bi->skb       ] ",
-			"<-- Adv Rx Read format\n");
-		pr_info("%s%s%s",
+			"<-- Adv Rx Read format");
+		pr_info("%s%s%s\n",
 			"RWB[desc]      [PcsmIpSHl PtRs] ",
 			"[vl er S cks ln] ---------------- [bi->skb       ] ",
-			"<-- Adv Rx Write-Back format\n");
+			"<-- Adv Rx Write-Back format");
 
 		for (i = 0; i < rx_ring->count; i++) {
+			const char *ring_desc;
+
+			if (i == rx_ring->next_to_use)
+				ring_desc = " NTU";
+			else if (i == rx_ring->next_to_clean)
+				ring_desc = " NTC";
+			else
+				ring_desc = "";
+
 			rx_buffer_info = &rx_ring->rx_buffer_info[i];
 			rx_desc = IXGBE_RX_DESC(rx_ring, i);
 			u0 = (struct my_u0 *)rx_desc;
 			staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 			if (staterr & IXGBE_RXD_STAT_DD) {
 				/* Descriptor Done */
-				pr_info("RWB[0x%03X]     %016llX "
-					"%016llX ---------------- %p", i,
+				pr_info("RWB[0x%03X]     %016llX %016llX ---------------- %p%s\n",
+					i,
 					le64_to_cpu(u0->a),
 					le64_to_cpu(u0->b),
-					rx_buffer_info->skb);
+					rx_buffer_info->skb,
+					ring_desc);
 			} else {
-				pr_info("R  [0x%03X]     %016llX "
-					"%016llX %016llX %p", i,
+				pr_info("R  [0x%03X]     %016llX %016llX %016llX %p%s\n",
+					i,
 					le64_to_cpu(u0->a),
 					le64_to_cpu(u0->b),
 					(u64)rx_buffer_info->dma,
-					rx_buffer_info->skb);
+					rx_buffer_info->skb,
+					ring_desc);
 
 				if (netif_msg_pktdata(adapter) &&
 				    rx_buffer_info->dma) {
@@ -832,14 +850,6 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 					   ixgbe_rx_bufsz(rx_ring), true);
 				}
 			}
-
-			if (i == rx_ring->next_to_use)
-				pr_cont(" NTU\n");
-			else if (i == rx_ring->next_to_clean)
-				pr_cont(" NTC\n");
-			else
-				pr_cont("\n");
-
 		}
 	}
 }
-- 
2.10.0.rc2.1.g053435c
