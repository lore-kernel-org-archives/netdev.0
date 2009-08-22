From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 4/8] bnx2: Apply BROKEN_STATS workaround to 5706
 and 5708.
Date: Fri, 21 Aug 2009 19:20:46 -0700
Message-ID: <1250907650-24672-4-git-send-email-mchan@broadcom.com>
References: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3672 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933141AbZHVCNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 22:13:46 -0400
In-Reply-To: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add flag to expand the workaround to both chips.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    7 ++++---
 drivers/net/bnx2.h |    1 +
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 1d502e6..085c2dd 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4900,7 +4900,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	REG_WR(bp, BNX2_HC_CMD_TICKS,
 	       (bp->cmd_ticks_int << 16) | bp->cmd_ticks);
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5708)
+	if (bp->flags & BNX2_FLAG_BROKEN_STATS)
 		REG_WR(bp, BNX2_HC_STATS_TICKS, 0);
 	else
 		REG_WR(bp, BNX2_HC_STATS_TICKS, bp->stats_ticks);
@@ -6025,7 +6025,7 @@ bnx2_timer(unsigned long data)
 		bnx2_reg_rd_ind(bp, BNX2_FW_RX_DROP_COUNT);
 
 	/* workaround occasional corrupted counters */
-	if (CHIP_NUM(bp) == CHIP_NUM_5708 && bp->stats_ticks)
+	if ((bp->flags & BNX2_FLAG_BROKEN_STATS) && bp->stats_ticks)
 		REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd |
 					    BNX2_HC_COMMAND_STATS_NOW);
 
@@ -6941,7 +6941,7 @@ bnx2_set_coalesce(struct net_device *dev, struct ethtool_coalesce *coal)
 		0xff;
 
 	bp->stats_ticks = coal->stats_block_coalesce_usecs;
-	if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+	if (bp->flags & BNX2_FLAG_BROKEN_STATS) {
 		if (bp->stats_ticks != 0 && bp->stats_ticks != USEC_PER_SEC)
 			bp->stats_ticks = USEC_PER_SEC;
 	}
@@ -7722,6 +7722,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 			rc = -EIO;
 			goto err_out_unmap;
 		}
+		bp->flags |= BNX2_FLAG_BROKEN_STATS;
 	}
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709 && CHIP_REV(bp) != CHIP_REV_Ax) {
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index f1edfaa..3c004b4 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6718,6 +6718,7 @@ struct bnx2 {
 					 BNX2_FLAG_USING_MSIX)
 #define BNX2_FLAG_JUMBO_BROKEN		0x00000800
 #define BNX2_FLAG_CAN_KEEP_VLAN		0x00001000
+#define BNX2_FLAG_BROKEN_STATS		0x00002000
 
 	struct bnx2_napi	bnx2_napi[BNX2_MAX_MSIX_VEC];
 
-- 
1.5.6.GIT


