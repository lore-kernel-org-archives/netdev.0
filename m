From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/15] nfp: remove RX queue pointers
Date: Tue, 21 Mar 2017 17:59:18 -0700
Message-ID: <20170322005921.10965-13-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36604 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757414AbdCVBIL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:08:11 -0400
Received: by mail-pg0-f51.google.com with SMTP id g2so100803695pge.3
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:08:00 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NFP6000 doesn't use queue pointers/doorbells for RX, it uses
'done' bit in descriptors.  Remove the pointers from data structures.
Since we are saving space in rx_ring structure make fields we
previously compressed to 16bits word size again.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h         |  8 ++------
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  |  3 ---
 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c | 15 ++++-----------
 3 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 4d45f4573b57..8e04aa0e6e87 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -307,9 +307,7 @@ struct nfp_net_rx_buf {
  * @rd_p:       FL/RX ring read pointer (free running)
  * @idx:        Ring index from Linux's perspective
  * @fl_qcidx:   Queue Controller Peripheral (QCP) queue index for the freelist
- * @rx_qcidx:   Queue Controller Peripheral (QCP) queue index for the RX queue
  * @qcp_fl:     Pointer to base of the QCP freelist queue
- * @qcp_rx:     Pointer to base of the QCP RX queue
  * @wr_ptr_add: Accumulated number of buffers to add to QCP write pointer
  *              (used for free list batching)
  * @rxbufs:     Array of transmitted FL/RX buffers
@@ -324,13 +322,11 @@ struct nfp_net_rx_ring {
 	u32 wr_p;
 	u32 rd_p;
 
-	u16 idx;
-	u16 wr_ptr_add;
+	u32 idx;
+	u32 wr_ptr_add;
 
 	int fl_qcidx;
-	int rx_qcidx;
 	u8 __iomem *qcp_fl;
-	u8 __iomem *qcp_rx;
 
 	struct nfp_net_rx_buf *rxbufs;
 	struct nfp_net_rx_desc *rxds;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 19f9d95faea4..255294b8bc5f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -479,10 +479,7 @@ nfp_net_rx_ring_init(struct nfp_net_rx_ring *rx_ring,
 	rx_ring->r_vec = r_vec;
 
 	rx_ring->fl_qcidx = rx_ring->idx * nn->stride_rx;
-	rx_ring->rx_qcidx = rx_ring->fl_qcidx + (nn->stride_rx - 1);
-
 	rx_ring->qcp_fl = nn->rx_bar + NFP_QCP_QUEUE_OFF(rx_ring->fl_qcidx);
-	rx_ring->qcp_rx = nn->rx_bar + NFP_QCP_QUEUE_OFF(rx_ring->rx_qcidx);
 }
 
 /**
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index 74125584260b..4077c59bf782 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -40,9 +40,9 @@ static struct dentry *nfp_dir;
 
 static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 {
-	int fl_rd_p, fl_wr_p, rx_rd_p, rx_wr_p, rxd_cnt;
 	struct nfp_net_r_vector *r_vec = file->private;
 	struct nfp_net_rx_ring *rx_ring;
+	int fl_rd_p, fl_wr_p, rxd_cnt;
 	struct nfp_net_rx_desc *rxd;
 	struct nfp_net *nn;
 	void *frag;
@@ -61,14 +61,11 @@ static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 
 	fl_rd_p = nfp_qcp_rd_ptr_read(rx_ring->qcp_fl);
 	fl_wr_p = nfp_qcp_wr_ptr_read(rx_ring->qcp_fl);
-	rx_rd_p = nfp_qcp_rd_ptr_read(rx_ring->qcp_rx);
-	rx_wr_p = nfp_qcp_wr_ptr_read(rx_ring->qcp_rx);
 
-	seq_printf(file, "RX[%02d,%02d,%02d]: cnt=%d dma=%pad host=%p   H_RD=%d H_WR=%d FL_RD=%d FL_WR=%d RX_RD=%d RX_WR=%d\n",
-		   rx_ring->idx, rx_ring->fl_qcidx, rx_ring->rx_qcidx,
+	seq_printf(file, "RX[%02d,%02d]: cnt=%d dma=%pad host=%p   H_RD=%d H_WR=%d FL_RD=%d FL_WR=%d\n",
+		   rx_ring->idx, rx_ring->fl_qcidx,
 		   rx_ring->cnt, &rx_ring->dma, rx_ring->rxds,
-		   rx_ring->rd_p, rx_ring->wr_p,
-		   fl_rd_p, fl_wr_p, rx_rd_p, rx_wr_p);
+		   rx_ring->rd_p, rx_ring->wr_p, fl_rd_p, fl_wr_p);
 
 	for (i = 0; i < rxd_cnt; i++) {
 		rxd = &rx_ring->rxds[i];
@@ -91,10 +88,6 @@ static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 			seq_puts(file, " FL_RD");
 		if (i == fl_wr_p % rxd_cnt)
 			seq_puts(file, " FL_WR");
-		if (i == rx_rd_p % rxd_cnt)
-			seq_puts(file, " RX_RD");
-		if (i == rx_wr_p % rxd_cnt)
-			seq_puts(file, " RX_WR");
 
 		seq_putc(file, '\n');
 	}
-- 
2.11.0
