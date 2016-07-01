From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 11/11] bnxt_en: Allow statistics DMA to be configurable using ethtool -C.
Date: Fri,  1 Jul 2016 18:46:29 -0400
Message-ID: <1467413189-29566-12-git-send-email-michael.chan@broadcom.com>
References: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34179 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081AbcGAWq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 18:46:58 -0400
Received: by mail-pa0-f46.google.com with SMTP id bz2so42229382pad.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 15:46:58 -0700 (PDT)
In-Reply-To: <1467413189-29566-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The allowable range is 0.25 seconds to 1 second interval.  Default is
1 second.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  4 +++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  5 +++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 25 +++++++++++++++++++++--
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 18be62b..70b148a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3952,7 +3952,7 @@ static int bnxt_hwrm_stat_ctx_alloc(struct bnxt *bp)
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_STAT_CTX_ALLOC, -1, -1);
 
-	req.update_period_ms = cpu_to_le32(1000);
+	req.update_period_ms = cpu_to_le32(bp->stats_coal_ticks / 1000);
 
 	mutex_lock(&bp->hwrm_cmd_lock);
 	for (i = 0; i < bp->cp_nr_rings; i++) {
@@ -5994,6 +5994,8 @@ static int bnxt_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->tx_coal_ticks_irq = 2;
 	bp->tx_coal_bufs_irq = 2;
 
+	bp->stats_coal_ticks = BNXT_DEF_STATS_COAL_TICKS;
+
 	init_timer(&bp->timer);
 	bp->timer.data = (unsigned long)bp;
 	bp->timer.function = bnxt_timer;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 1d5a3cd..2313e37 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1067,6 +1067,11 @@ struct bnxt {
 
 #define BNXT_USEC_TO_COAL_TIMER(x)	((x) * 25 / 2)
 
+	u32			stats_coal_ticks;
+#define BNXT_DEF_STATS_COAL_TICKS	 1000000
+#define BNXT_MIN_STATS_COAL_TICKS	  250000
+#define BNXT_MAX_STATS_COAL_TICKS	 1000000
+
 	struct work_struct	sp_task;
 	unsigned long		sp_event;
 #define BNXT_RX_MASK_SP_EVENT		0
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 33b3135..0f7dd86 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -56,6 +56,8 @@ static int bnxt_get_coalesce(struct net_device *dev,
 	coal->tx_coalesce_usecs_irq = bp->tx_coal_ticks_irq;
 	coal->tx_max_coalesced_frames_irq = bp->tx_coal_bufs_irq;
 
+	coal->stats_block_coalesce_usecs = bp->stats_coal_ticks;
+
 	return 0;
 }
 
@@ -63,6 +65,7 @@ static int bnxt_set_coalesce(struct net_device *dev,
 			     struct ethtool_coalesce *coal)
 {
 	struct bnxt *bp = netdev_priv(dev);
+	bool update_stats = false;
 	int rc = 0;
 
 	bp->rx_coal_ticks = coal->rx_coalesce_usecs;
@@ -76,8 +79,26 @@ static int bnxt_set_coalesce(struct net_device *dev,
 	bp->tx_coal_ticks_irq = coal->tx_coalesce_usecs_irq;
 	bp->tx_coal_bufs_irq = coal->tx_max_coalesced_frames_irq;
 
-	if (netif_running(dev))
-		rc = bnxt_hwrm_set_coal(bp);
+	if (bp->stats_coal_ticks != coal->stats_block_coalesce_usecs) {
+		u32 stats_ticks = coal->stats_block_coalesce_usecs;
+
+		stats_ticks = clamp_t(u32, stats_ticks,
+				      BNXT_MIN_STATS_COAL_TICKS,
+				      BNXT_MAX_STATS_COAL_TICKS);
+		stats_ticks = rounddown(stats_ticks, BNXT_MIN_STATS_COAL_TICKS);
+		bp->stats_coal_ticks = stats_ticks;
+		update_stats = true;
+	}
+
+	if (netif_running(dev)) {
+		if (update_stats) {
+			rc = bnxt_close_nic(bp, true, false);
+			if (!rc)
+				rc = bnxt_open_nic(bp, true, false);
+		} else {
+			rc = bnxt_hwrm_set_coal(bp);
+		}
+	}
 
 	return rc;
 }
-- 
1.8.3.1
