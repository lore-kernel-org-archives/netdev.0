From: "Michael Chan" <mchan@broadcom.com>
Subject: [4/5][BNX2]: Fix occasional counter corruption on 5708.
Date: Mon, 04 Jun 2007 17:01:08 -0700
Message-ID: <1181001668.5275.15.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org, jd@disjunkt.com,
	cat@zip.com.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1399 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106AbXFDXTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 19:19:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix occasional counter corruption on 5708.

The statistics block DMA on 5708 can be messed up occasionally on the
average of about once per hour.  If the user is reading the counters
within one second after the corruption, the counters will be all
messed up.  One second later, the counters will be ok again until the
next corruption occurs.

The workaround is to disable the periodic statistics DMA.  Instead,
we manually trigger the DMA once a second in bnx2_timer().  This
manual trigger of the DMA avoids the problem.

As a consequence, we can only allow 0 or 1 second settings for
ethtool -C statistics block.

Thanks to Jean-Daniel Pauget <jd@disjunkt.com> and
CaT <cat@zip.com.au> for reporting this rare problem.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index c03282c..5654cc7 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3783,7 +3783,10 @@ bnx2_init_chip(struct bnx2 *bp)
 	REG_WR(bp, BNX2_HC_CMD_TICKS,
 	       (bp->cmd_ticks_int << 16) | bp->cmd_ticks);
 
-	REG_WR(bp, BNX2_HC_STATS_TICKS, bp->stats_ticks & 0xffff00);
+	if (CHIP_NUM(bp) == CHIP_NUM_5708)
+		REG_WR(bp, BNX2_HC_STATS_TICKS, 0);
+	else
+		REG_WR(bp, BNX2_HC_STATS_TICKS, bp->stats_ticks & 0xffff00);
 	REG_WR(bp, BNX2_HC_STAT_COLLECT_TICKS, 0xbb8);  /* 3ms */
 
 	if (CHIP_ID(bp) == CHIP_ID_5706_A1)
@@ -4636,6 +4639,11 @@ bnx2_timer(unsigned long data)
 
 	bp->stats_blk->stat_FwRxDrop = REG_RD_IND(bp, BNX2_FW_RX_DROP_COUNT);
 
+	/* workaround occasional corrupted counters */
+	if (CHIP_NUM(bp) == CHIP_NUM_5708 && bp->stats_ticks)
+		REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd |
+					    BNX2_HC_COMMAND_STATS_NOW);
+
 	if (bp->phy_flags & PHY_SERDES_FLAG) {
 		if (CHIP_NUM(bp) == CHIP_NUM_5706)
 			bnx2_5706_serdes_timer(bp);
@@ -5446,6 +5454,10 @@ bnx2_set_coalesce(struct net_device *dev, struct ethtool_coalesce *coal)
 		0xff;
 
 	bp->stats_ticks = coal->stats_block_coalesce_usecs;
+	if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+		if (bp->stats_ticks != 0 && bp->stats_ticks != USEC_PER_SEC)
+			bp->stats_ticks = USEC_PER_SEC;
+	}
 	if (bp->stats_ticks > 0xffff00) bp->stats_ticks = 0xffff00;
 	bp->stats_ticks &= 0xffff00;
 


