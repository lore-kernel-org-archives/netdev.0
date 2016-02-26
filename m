From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 03/10] bnxt_en: Store irq coalescing timer values in micro seconds.
Date: Fri, 26 Feb 2016 04:00:01 -0500
Message-ID: <1456477208-30692-4-git-send-email-michael.chan@broadcom.com>
References: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:55798
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751258AbcBZJAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 04:00:47 -0500
In-Reply-To: <1456477208-30692-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't convert these to internal hardware tick values before storing
them.  This avoids the confusion of ethtool -c returning slightly
different values than the ones set using ethtool -C when we convert
hardware tick values back to micro seconds.  Add better comments for
the hardware settings.

Also, rename the current set of coalescing fields with rx_ prefix.
The next patch will add support of tx coalescing values.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 33 ++++++++++++++---------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  9 +++----
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 21 +++++++--------
 3 files changed, 34 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 80c4412..a7103b5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3532,20 +3532,25 @@ int bnxt_hwrm_set_coal(struct bnxt *bp)
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_RING_CMPL_RING_CFG_AGGINT_PARAMS,
 			       -1, -1);
 
-	/* Each rx completion (2 records) should be DMAed immediately */
-	max_buf = min_t(u16, bp->coal_bufs / 4, 2);
+	/* Each rx completion (2 records) should be DMAed immediately.
+	 * DMA 1/4 of the completion buffers at a time.
+	 */
+	max_buf = min_t(u16, bp->rx_coal_bufs / 4, 2);
 	/* max_buf must not be zero */
 	max_buf = clamp_t(u16, max_buf, 1, 63);
-	max_buf_irq = clamp_t(u16, bp->coal_bufs_irq, 1, 63);
-	buf_tmr = max_t(u16, bp->coal_ticks / 4, 1);
-	buf_tmr_irq = max_t(u16, bp->coal_ticks_irq, 1);
+	max_buf_irq = clamp_t(u16, bp->rx_coal_bufs_irq, 1, 63);
+	buf_tmr = BNXT_USEC_TO_COAL_TIMER(bp->rx_coal_ticks);
+	/* buf timer set to 1/4 of interrupt timer */
+	buf_tmr = max_t(u16, buf_tmr / 4, 1);
+	buf_tmr_irq = BNXT_USEC_TO_COAL_TIMER(bp->rx_coal_ticks_irq);
+	buf_tmr_irq = max_t(u16, buf_tmr_irq, 1);
 
 	flags = RING_CMPL_RING_CFG_AGGINT_PARAMS_REQ_FLAGS_TIMER_RESET;
 
 	/* RING_IDLE generates more IRQs for lower latency.  Enable it only
 	 * if coal_ticks is less than 25 us.
 	 */
-	if (BNXT_COAL_TIMER_TO_USEC(bp->coal_ticks) < 25)
+	if (bp->rx_coal_ticks < 25)
 		flags |= RING_CMPL_RING_CFG_AGGINT_PARAMS_REQ_FLAGS_RING_IDLE;
 
 	req.flags = cpu_to_le16(flags);
@@ -3553,9 +3558,10 @@ int bnxt_hwrm_set_coal(struct bnxt *bp)
 	req.num_cmpl_dma_aggr_during_int = cpu_to_le16(max_buf_irq);
 	req.cmpl_aggr_dma_tmr = cpu_to_le16(buf_tmr);
 	req.cmpl_aggr_dma_tmr_during_int = cpu_to_le16(buf_tmr_irq);
-	req.int_lat_tmr_min = cpu_to_le16(buf_tmr);
-	req.int_lat_tmr_max = cpu_to_le16(bp->coal_ticks);
-	req.num_cmpl_aggr_int = cpu_to_le16(bp->coal_bufs);
+	/* Minimum time between 2 interrupts set to buf_tmr x 2 */
+	req.int_lat_tmr_min = cpu_to_le16(buf_tmr * 2);
+	req.int_lat_tmr_max = cpu_to_le16(buf_tmr * 4);
+	req.num_cmpl_aggr_int = cpu_to_le16(max_buf * 4);
 
 	mutex_lock(&bp->hwrm_cmd_lock);
 	for (i = 0; i < bp->cp_nr_rings; i++) {
@@ -5295,10 +5301,11 @@ static int bnxt_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->rx_ring_size = BNXT_DEFAULT_RX_RING_SIZE;
 	bp->tx_ring_size = BNXT_DEFAULT_TX_RING_SIZE;
 
-	bp->coal_ticks = BNXT_USEC_TO_COAL_TIMER(4);
-	bp->coal_bufs = 20;
-	bp->coal_ticks_irq = BNXT_USEC_TO_COAL_TIMER(1);
-	bp->coal_bufs_irq = 2;
+	/* tick values in micro seconds */
+	bp->rx_coal_ticks = 4;
+	bp->rx_coal_bufs = 20;
+	bp->rx_coal_ticks_irq = 1;
+	bp->rx_coal_bufs_irq = 2;
 
 	init_timer(&bp->timer);
 	bp->timer.data = (unsigned long)bp;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index cc798d5..6913307 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -968,13 +968,12 @@ struct bnxt {
 	__le16			vxlan_fw_dst_port_id;
 	u8			nge_port_cnt;
 	__le16			nge_fw_dst_port_id;
-	u16			coal_ticks;
-	u16			coal_ticks_irq;
-	u16			coal_bufs;
-	u16			coal_bufs_irq;
+	u16			rx_coal_ticks;
+	u16			rx_coal_ticks_irq;
+	u16			rx_coal_bufs;
+	u16			rx_coal_bufs_irq;
 
 #define BNXT_USEC_TO_COAL_TIMER(x)	((x) * 25 / 2)
-#define BNXT_COAL_TIMER_TO_USEC(x) ((x) * 2 / 25)
 
 	struct work_struct	sp_task;
 	unsigned long		sp_event;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 3238817..d18a977 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -41,12 +41,11 @@ static int bnxt_get_coalesce(struct net_device *dev,
 
 	memset(coal, 0, sizeof(*coal));
 
-	coal->rx_coalesce_usecs =
-		max_t(u16, BNXT_COAL_TIMER_TO_USEC(bp->coal_ticks), 1);
-	coal->rx_max_coalesced_frames = bp->coal_bufs / 2;
-	coal->rx_coalesce_usecs_irq =
-		max_t(u16, BNXT_COAL_TIMER_TO_USEC(bp->coal_ticks_irq), 1);
-	coal->rx_max_coalesced_frames_irq = bp->coal_bufs_irq / 2;
+	coal->rx_coalesce_usecs = bp->rx_coal_ticks;
+	/* 2 completion records per rx packet */
+	coal->rx_max_coalesced_frames = bp->rx_coal_bufs / 2;
+	coal->rx_coalesce_usecs_irq = bp->rx_coal_ticks_irq;
+	coal->rx_max_coalesced_frames_irq = bp->rx_coal_bufs_irq / 2;
 
 	return 0;
 }
@@ -57,11 +56,11 @@ static int bnxt_set_coalesce(struct net_device *dev,
 	struct bnxt *bp = netdev_priv(dev);
 	int rc = 0;
 
-	bp->coal_ticks = BNXT_USEC_TO_COAL_TIMER(coal->rx_coalesce_usecs);
-	bp->coal_bufs = coal->rx_max_coalesced_frames * 2;
-	bp->coal_ticks_irq =
-		BNXT_USEC_TO_COAL_TIMER(coal->rx_coalesce_usecs_irq);
-	bp->coal_bufs_irq = coal->rx_max_coalesced_frames_irq * 2;
+	bp->rx_coal_ticks = coal->rx_coalesce_usecs;
+	/* 2 completion records per rx packet */
+	bp->rx_coal_bufs = coal->rx_max_coalesced_frames * 2;
+	bp->rx_coal_ticks_irq = coal->rx_coalesce_usecs_irq;
+	bp->rx_coal_bufs_irq = coal->rx_max_coalesced_frames_irq * 2;
 
 	if (netif_running(dev))
 		rc = bnxt_hwrm_set_coal(bp);
-- 
1.8.3.1
