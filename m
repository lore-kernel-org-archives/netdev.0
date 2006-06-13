From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.18 1/6] bnx2: Add an rx drop counter
Date: Mon, 12 Jun 2006 17:17:03 -0700
Message-ID: <1150157824.26173.6.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:22033 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932675AbWFMAUA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 20:20:00 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a counter for packets dropped by firmware.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7a1fb52..1a5f7a8 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4034,6 +4034,8 @@ bnx2_timer(unsigned long data)
 	msg = (u32) ++bp->fw_drv_pulse_wr_seq;
 	REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_PULSE_MB, msg);
 
+	bp->stats_blk->stat_FwRxDrop = REG_RD_IND(bp, BNX2_FW_RX_DROP_COUNT);
+
 	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
 	    (CHIP_NUM(bp) == CHIP_NUM_5706)) {
 
@@ -4504,6 +4506,10 @@ bnx2_get_stats(struct net_device *dev)
 		net_stats->tx_aborted_errors +
 		net_stats->tx_carrier_errors;
 
+	net_stats->rx_missed_errors =
+		(unsigned long) (stats_blk->stat_IfInMBUFDiscards +
+		stats_blk->stat_FwRxDrop);
+
 	return net_stats;
 }
 
@@ -4986,7 +4992,7 @@ bnx2_set_rx_csum(struct net_device *dev,
 	return 0;
 }
 
-#define BNX2_NUM_STATS 45
+#define BNX2_NUM_STATS 46
 
 static struct {
 	char string[ETH_GSTRING_LEN];
@@ -5036,6 +5042,7 @@ static struct {
 	{ "rx_mac_ctrl_frames" },
 	{ "rx_filtered_packets" },
 	{ "rx_discards" },
+	{ "rx_fw_discards" },
 };
 
 #define STATS_OFFSET32(offset_name) (offsetof(struct statistics_block, offset_name) / 4)
@@ -5086,6 +5093,7 @@ static const unsigned long bnx2_stats_of
     STATS_OFFSET32(stat_MacControlFramesReceived),                    
     STATS_OFFSET32(stat_IfInFramesL2FilterDiscards),                  
     STATS_OFFSET32(stat_IfInMBUFDiscards),                            
+    STATS_OFFSET32(stat_FwRxDrop),
 };
 
 /* stat_IfHCInBadOctets and stat_Dot3StatsCarrierSenseErrors are
@@ -5096,7 +5104,7 @@ static u8 bnx2_5706_stats_len_arr[BNX2_N
 	4,0,4,4,4,4,4,4,4,4,
 	4,4,4,4,4,4,4,4,4,4,
 	4,4,4,4,4,4,4,4,4,4,
-	4,4,4,4,4,
+	4,4,4,4,4,4,
 };
 
 static u8 bnx2_5708_stats_len_arr[BNX2_NUM_STATS] = {
@@ -5104,7 +5112,7 @@ static u8 bnx2_5708_stats_len_arr[BNX2_N
 	4,4,4,4,4,4,4,4,4,4,
 	4,4,4,4,4,4,4,4,4,4,
 	4,4,4,4,4,4,4,4,4,4,
-	4,4,4,4,4,
+	4,4,4,4,4,4,
 };
 
 #define BNX2_NUM_TESTS 6
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index b87925f..ea1ab06 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -231,6 +231,7 @@ struct statistics_block {
 	u32 stat_GenStat13;
 	u32 stat_GenStat14;
 	u32 stat_GenStat15;
+	u32 stat_FwRxDrop;
 };
 
 
@@ -3481,6 +3482,8 @@ struct l2_fhdr {
 
 #define BNX2_COM_SCRATCH				0x00120000
 
+#define BNX2_FW_RX_DROP_COUNT				 0x00120084
+
 
 /*
  *  cp_reg definition


