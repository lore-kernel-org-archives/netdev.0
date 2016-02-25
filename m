From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 05/10] bnxt_en: Add coalescing support for tx rings.
Date: Thu, 25 Feb 2016 03:19:29 -0500
Message-ID: <1456388374-1440-6-git-send-email-michael.chan@broadcom.com>
References: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:11789
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759552AbcBYITg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 03:19:36 -0500
In-Reply-To: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tx and rx rings don't share the same completion ring, tx coalescing
parameters can be set differently from the rx coalescing parameters.
Otherwise, use rx coalescing parameters on shared completion rings.

Adjust rx coalescing default values to lower interrupt rate.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 42 ++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  5 +++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 10 ++++++
 3 files changed, 49 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index b87b367..f38a2d2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3539,13 +3539,16 @@ static void bnxt_hwrm_set_coal_params(
 int bnxt_hwrm_set_coal(struct bnxt *bp)
 {
 	int i, rc = 0;
-	struct hwrm_ring_cmpl_ring_cfg_aggint_params_input req = {0};
+	struct hwrm_ring_cmpl_ring_cfg_aggint_params_input req_rx = {0},
+							   req_tx = {0}, *req;
 	u16 max_buf, max_buf_irq;
 	u16 buf_tmr, buf_tmr_irq;
 	u32 flags;
 
-	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_RING_CMPL_RING_CFG_AGGINT_PARAMS,
-			       -1, -1);
+	bnxt_hwrm_cmd_hdr_init(bp, &req_rx,
+			       HWRM_RING_CMPL_RING_CFG_AGGINT_PARAMS, -1, -1);
+	bnxt_hwrm_cmd_hdr_init(bp, &req_tx,
+			       HWRM_RING_CMPL_RING_CFG_AGGINT_PARAMS, -1, -1);
 
 	/* Each rx completion (2 records) should be DMAed immediately.
 	 * DMA 1/4 of the completion buffers at a time.
@@ -3569,13 +3572,31 @@ int bnxt_hwrm_set_coal(struct bnxt *bp)
 		flags |= RING_CMPL_RING_CFG_AGGINT_PARAMS_REQ_FLAGS_RING_IDLE;
 
 	bnxt_hwrm_set_coal_params(bp, max_buf_irq << 16 | max_buf,
-				  buf_tmr_irq << 16 | buf_tmr, flags, &req);
+				  buf_tmr_irq << 16 | buf_tmr, flags, &req_rx);
+
+	/* max_buf must not be zero */
+	max_buf = clamp_t(u16, bp->tx_coal_bufs, 1, 63);
+	max_buf_irq = clamp_t(u16, bp->tx_coal_bufs_irq, 1, 63);
+	buf_tmr = BNXT_USEC_TO_COAL_TIMER(bp->tx_coal_ticks);
+	/* buf timer set to 1/4 of interrupt timer */
+	buf_tmr = max_t(u16, buf_tmr / 4, 1);
+	buf_tmr_irq = BNXT_USEC_TO_COAL_TIMER(bp->tx_coal_ticks_irq);
+	buf_tmr_irq = max_t(u16, buf_tmr_irq, 1);
+
+	flags = RING_CMPL_RING_CFG_AGGINT_PARAMS_REQ_FLAGS_TIMER_RESET;
+	bnxt_hwrm_set_coal_params(bp, max_buf_irq << 16 | max_buf,
+				  buf_tmr_irq << 16 | buf_tmr, flags, &req_tx);
 
 	mutex_lock(&bp->hwrm_cmd_lock);
 	for (i = 0; i < bp->cp_nr_rings; i++) {
-		req.ring_id = cpu_to_le16(bp->grp_info[i].cp_fw_ring_id);
+		struct bnxt_napi *bnapi = bp->bnapi[i];
 
-		rc = _hwrm_send_message(bp, &req, sizeof(req),
+		req = &req_rx;
+		if (!bnapi->rx_ring)
+			req = &req_tx;
+		req->ring_id = cpu_to_le16(bp->grp_info[i].cp_fw_ring_id);
+
+		rc = _hwrm_send_message(bp, req, sizeof(*req),
 					HWRM_CMD_TIMEOUT);
 		if (rc)
 			break;
@@ -5310,11 +5331,16 @@ static int bnxt_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->tx_ring_size = BNXT_DEFAULT_TX_RING_SIZE;
 
 	/* tick values in micro seconds */
-	bp->rx_coal_ticks = 4;
-	bp->rx_coal_bufs = 20;
+	bp->rx_coal_ticks = 12;
+	bp->rx_coal_bufs = 30;
 	bp->rx_coal_ticks_irq = 1;
 	bp->rx_coal_bufs_irq = 2;
 
+	bp->tx_coal_ticks = 25;
+	bp->tx_coal_bufs = 30;
+	bp->tx_coal_ticks_irq = 2;
+	bp->tx_coal_bufs_irq = 2;
+
 	init_timer(&bp->timer);
 	bp->timer.data = (unsigned long)bp;
 	bp->timer.function = bnxt_timer;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 6913307..ba67c4a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -968,10 +968,15 @@ struct bnxt {
 	__le16			vxlan_fw_dst_port_id;
 	u8			nge_port_cnt;
 	__le16			nge_fw_dst_port_id;
+
 	u16			rx_coal_ticks;
 	u16			rx_coal_ticks_irq;
 	u16			rx_coal_bufs;
 	u16			rx_coal_bufs_irq;
+	u16			tx_coal_ticks;
+	u16			tx_coal_ticks_irq;
+	u16			tx_coal_bufs;
+	u16			tx_coal_bufs_irq;
 
 #define BNXT_USEC_TO_COAL_TIMER(x)	((x) * 25 / 2)
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index d18a977..a2d2549 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -47,6 +47,11 @@ static int bnxt_get_coalesce(struct net_device *dev,
 	coal->rx_coalesce_usecs_irq = bp->rx_coal_ticks_irq;
 	coal->rx_max_coalesced_frames_irq = bp->rx_coal_bufs_irq / 2;
 
+	coal->tx_coalesce_usecs = bp->tx_coal_ticks;
+	coal->tx_max_coalesced_frames = bp->tx_coal_bufs;
+	coal->tx_coalesce_usecs_irq = bp->tx_coal_ticks_irq;
+	coal->tx_max_coalesced_frames_irq = bp->tx_coal_bufs_irq;
+
 	return 0;
 }
 
@@ -62,6 +67,11 @@ static int bnxt_set_coalesce(struct net_device *dev,
 	bp->rx_coal_ticks_irq = coal->rx_coalesce_usecs_irq;
 	bp->rx_coal_bufs_irq = coal->rx_max_coalesced_frames_irq * 2;
 
+	bp->tx_coal_ticks = coal->tx_coalesce_usecs;
+	bp->tx_coal_bufs = coal->tx_max_coalesced_frames;
+	bp->tx_coal_ticks_irq = coal->tx_coalesce_usecs_irq;
+	bp->tx_coal_bufs_irq = coal->tx_max_coalesced_frames_irq;
+
 	if (netif_running(dev))
 		rc = bnxt_hwrm_set_coal(bp);
 
-- 
1.8.3.1
