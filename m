From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 3/4] net: qcom/emac: enforce DMA address restrictions
Date: Wed, 11 Oct 2017 14:52:25 -0500
Message-ID: <1507751546-10265-4-git-send-email-timur@codeaurora.org>
References: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
Cc: timur@codeaurora.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37672 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752417AbdJKTwd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 15:52:33 -0400
In-Reply-To: <1507751546-10265-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EMAC has a restriction that the upper 32 bits of the base addresses
for the RFD and RRD rings must be the same.  The ensure that restriction,
we allocate twice the space for the RRD and locate it at an appropriate
address.

We also re-arrange the allocations so that invalid addresses are even
less likely.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 39 ++++++++++++++++-----------
 1 file changed, 24 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index 9cbb27263742..0f5ece5d9507 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -734,6 +734,11 @@ static int emac_rx_descs_alloc(struct emac_adapter *adpt)
 	rx_q->rrd.size = rx_q->rrd.count * (adpt->rrd_size * 4);
 	rx_q->rfd.size = rx_q->rfd.count * (adpt->rfd_size * 4);
 
+	/* Check if the RRD and RFD are aligned properly, and if not, adjust. */
+	if (upper_32_bits(ring_header->dma_addr) !=
+	    upper_32_bits(ring_header->dma_addr + ALIGN(rx_q->rrd.size, 8)))
+		ring_header->used = ALIGN(rx_q->rrd.size, 8);
+
 	rx_q->rrd.dma_addr = ring_header->dma_addr + ring_header->used;
 	rx_q->rrd.v_addr   = ring_header->v_addr + ring_header->used;
 	ring_header->used += ALIGN(rx_q->rrd.size, 8);
@@ -767,11 +772,18 @@ int emac_mac_rx_tx_rings_alloc_all(struct emac_adapter *adpt)
 
 	/* Ring DMA buffer. Each ring may need up to 8 bytes for alignment,
 	 * hence the additional padding bytes are allocated.
+	 *
+	 * Also double the memory allocated for the RRD so that we can
+	 * re-align it if necessary.  The EMAC has a restriction that the
+	 * upper 32 bits of the base addresses for the RFD and RRD rings
+	 * must be the same.  It is extremely unlikely that this is not the
+	 * case, since the rings are only a few KB in size.  However, we
+	 * need to check for this anyway, and if the two rings are not
+	 * compliant, then we re-align.
 	 */
-	ring_header->size = num_tx_descs * (adpt->tpd_size * 4) +
-			    num_rx_descs * (adpt->rfd_size * 4) +
-			    num_rx_descs * (adpt->rrd_size * 4) +
-			    8 + 2 * 8; /* 8 byte per one Tx and two Rx rings */
+	ring_header->size = ALIGN(num_tx_descs * (adpt->tpd_size * 4), 8) +
+			    ALIGN(num_rx_descs * (adpt->rfd_size * 4), 8) +
+			    ALIGN(num_rx_descs * (adpt->rrd_size * 4), 8) * 2;
 
 	ring_header->used = 0;
 	ring_header->v_addr = dma_zalloc_coherent(dev, ring_header->size,
@@ -780,26 +792,23 @@ int emac_mac_rx_tx_rings_alloc_all(struct emac_adapter *adpt)
 	if (!ring_header->v_addr)
 		return -ENOMEM;
 
-	ring_header->used = ALIGN(ring_header->dma_addr, 8) -
-							ring_header->dma_addr;
-
-	ret = emac_tx_q_desc_alloc(adpt, &adpt->tx_q);
-	if (ret) {
-		netdev_err(adpt->netdev, "error: Tx Queue alloc failed\n");
-		goto err_alloc_tx;
-	}
-
 	ret = emac_rx_descs_alloc(adpt);
 	if (ret) {
 		netdev_err(adpt->netdev, "error: Rx Queue alloc failed\n");
 		goto err_alloc_rx;
 	}
 
+	ret = emac_tx_q_desc_alloc(adpt, &adpt->tx_q);
+	if (ret) {
+		netdev_err(adpt->netdev, "transmit queue allocation failed\n");
+		goto err_alloc_tx;
+	}
+
 	return 0;
 
-err_alloc_rx:
-	emac_tx_q_bufs_free(adpt);
 err_alloc_tx:
+	emac_rx_q_bufs_free(adpt);
+err_alloc_rx:
 	dma_free_coherent(dev, ring_header->size,
 			  ring_header->v_addr, ring_header->dma_addr);
 
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
