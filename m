From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 2/2] nfp: correct DMA direction in XDP DMA sync
Date: Thu,  2 Mar 2017 15:26:21 -0800
Message-ID: <20170302232621.39763-3-jakub.kicinski@netronome.com>
References: <20170302232621.39763-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:32866 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdCCAcl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 19:32:41 -0500
Received: by mail-pg0-f54.google.com with SMTP id 25so37579147pgy.0
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 16:31:13 -0800 (PST)
In-Reply-To: <20170302232621.39763-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dma_sync_single_for_*() takes the direction in which the buffer
was mapped, not the direction of the sync.  We should sync XDP
buffers bidirectionally.

Fixes: ecd63a0217d5 ("nfp: add XDP support in the driver")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 00a83218857a..9179a99563af 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1498,7 +1498,7 @@ nfp_net_tx_xdp_buf(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
 	txbuf->real_len = pkt_len;
 
 	dma_sync_single_for_device(&nn->pdev->dev, rxbuf->dma_addr + pkt_off,
-				   pkt_len, DMA_TO_DEVICE);
+				   pkt_len, DMA_BIDIRECTIONAL);
 
 	/* Build TX descriptor */
 	txd = &tx_ring->txds[wr_idx];
@@ -1611,7 +1611,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 			dma_sync_single_for_cpu(&nn->pdev->dev,
 						rxbuf->dma_addr + pkt_off,
-						pkt_len, DMA_FROM_DEVICE);
+						pkt_len, DMA_BIDIRECTIONAL);
 			act = nfp_net_run_xdp(xdp_prog, rxbuf->frag + data_off,
 					      pkt_len);
 			switch (act) {
-- 
2.11.0
