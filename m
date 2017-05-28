From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/12] nfp: don't keep count for free buffers delayed kick
Date: Sat, 27 May 2017 17:34:11 -0700
Message-ID: <20170528003411.17603-13-jakub.kicinski@netronome.com>
References: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33975 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750871AbdE1Ae4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 20:34:56 -0400
Received: by mail-pg0-f51.google.com with SMTP id u28so8595744pgn.1
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 17:34:51 -0700 (PDT)
In-Reply-To: <20170528003411.17603-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only kick RX free buffer queue controller every NFP_NET_FL_BATCH
(currently 16) entries.  This means that we will always kick the QC
when write ring index is divisable by NFP_NET_FL_BATCH.  There is
no need to keep counts.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        | 3 ---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 7 ++-----
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 7882d2604835..cb7114309656 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -328,8 +328,6 @@ struct nfp_net_rx_buf {
  * @idx:        Ring index from Linux's perspective
  * @fl_qcidx:   Queue Controller Peripheral (QCP) queue index for the freelist
  * @qcp_fl:     Pointer to base of the QCP freelist queue
- * @wr_ptr_add: Accumulated number of buffers to add to QCP write pointer
- *              (used for free list batching)
  * @rxbufs:     Array of transmitted FL/RX buffers
  * @rxds:       Virtual address of FL/RX ring in host memory
  * @dma:        DMA address of the FL/RX ring
@@ -343,7 +341,6 @@ struct nfp_net_rx_ring {
 	u32 rd_p;
 
 	u32 idx;
-	u32 wr_ptr_add;
 
 	int fl_qcidx;
 	u8 __iomem *qcp_fl;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 68013d048e9d..c9a140376621 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1212,14 +1212,12 @@ static void nfp_net_rx_give_one(const struct nfp_net_dp *dp,
 			      dma_addr + dp->rx_dma_off);
 
 	rx_ring->wr_p++;
-	rx_ring->wr_ptr_add++;
-	if (rx_ring->wr_ptr_add >= NFP_NET_FL_BATCH) {
+	if (!(rx_ring->wr_p % NFP_NET_FL_BATCH)) {
 		/* Update write pointer of the freelist queue. Make
 		 * sure all writes are flushed before telling the hardware.
 		 */
 		wmb();
-		nfp_qcp_wr_ptr_add(rx_ring->qcp_fl, rx_ring->wr_ptr_add);
-		rx_ring->wr_ptr_add = 0;
+		nfp_qcp_wr_ptr_add(rx_ring->qcp_fl, NFP_NET_FL_BATCH);
 	}
 }
 
@@ -1245,7 +1243,6 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
 	memset(rx_ring->rxds, 0, sizeof(*rx_ring->rxds) * rx_ring->cnt);
 	rx_ring->wr_p = 0;
 	rx_ring->rd_p = 0;
-	rx_ring->wr_ptr_add = 0;
 }
 
 /**
-- 
2.11.0
