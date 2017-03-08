From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 4/9] nfp: move more ring debug info to debugfs
Date: Wed,  8 Mar 2017 08:57:03 -0800
Message-ID: <20170308165708.96087-5-jakub.kicinski@netronome.com>
References: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35536 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753476AbdCHQ7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:59:04 -0500
Received: by mail-pg0-f52.google.com with SMTP id b129so15239489pgc.2
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:58:12 -0800 (PST)
In-Reply-To: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already print most of ring configuration including descriptors
in debugfs, add the few missing pieces and remove debug prints.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  |  9 ---------
 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c | 13 +++++++++----
 2 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 5c34f79053f7..0be47188fd36 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1776,11 +1776,6 @@ nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring, u32 cnt, bool is_xdp)
 		netif_set_xps_queue(nn->netdev, &r_vec->affinity_mask,
 				    tx_ring->idx);
 
-	nn_dbg(nn, "TxQ%02d: QCidx=%02d cnt=%d dma=%#llx host=%p %s\n",
-	       tx_ring->idx, tx_ring->qcidx,
-	       tx_ring->cnt, (unsigned long long)tx_ring->dma, tx_ring->txds,
-	       is_xdp ? "XDP" : "");
-
 	return 0;
 
 err_alloc:
@@ -1900,10 +1895,6 @@ nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring, unsigned int fl_bufsz,
 	if (!rx_ring->rxbufs)
 		goto err_alloc;
 
-	nn_dbg(nn, "RxQ%02d: FlQCidx=%02d RxQCidx=%02d cnt=%d dma=%#llx host=%p\n",
-	       rx_ring->idx, rx_ring->fl_qcidx, rx_ring->rx_qcidx,
-	       rx_ring->cnt, (unsigned long long)rx_ring->dma, rx_ring->rxds);
-
 	return 0;
 
 err_alloc:
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index 6e9372a18375..edfa59e51fdd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -64,8 +64,10 @@ static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 	rx_rd_p = nfp_qcp_rd_ptr_read(rx_ring->qcp_rx);
 	rx_wr_p = nfp_qcp_wr_ptr_read(rx_ring->qcp_rx);
 
-	seq_printf(file, "RX[%02d]: H_RD=%d H_WR=%d FL_RD=%d FL_WR=%d RX_RD=%d RX_WR=%d\n",
-		   rx_ring->idx, rx_ring->rd_p, rx_ring->wr_p,
+	seq_printf(file, "RX[%02d,%02d,%02d]: cnt=%d dma=%pad host=%p   H_RD=%d H_WR=%d FL_RD=%d FL_WR=%d RX_RD=%d RX_WR=%d\n",
+		   rx_ring->idx, rx_ring->fl_qcidx, rx_ring->rx_qcidx,
+		   rx_ring->cnt, &rx_ring->dma, rx_ring->rxds,
+		   rx_ring->rd_p, rx_ring->wr_p,
 		   fl_rd_p, fl_wr_p, rx_rd_p, rx_wr_p);
 
 	for (i = 0; i < rxd_cnt; i++) {
@@ -151,8 +153,11 @@ static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
 	d_rd_p = nfp_qcp_rd_ptr_read(tx_ring->qcp_q);
 	d_wr_p = nfp_qcp_wr_ptr_read(tx_ring->qcp_q);
 
-	seq_printf(file, "TX[%02d]: H_RD=%d H_WR=%d D_RD=%d D_WR=%d\n",
-		   tx_ring->idx, tx_ring->rd_p, tx_ring->wr_p, d_rd_p, d_wr_p);
+	seq_printf(file, "TX[%02d,%02d%s]: cnt=%d dma=%pad host=%p   H_RD=%d H_WR=%d D_RD=%d D_WR=%d\n",
+		   tx_ring->idx, tx_ring->qcidx,
+		   tx_ring == r_vec->tx_ring ? "" : "xdp",
+		   tx_ring->cnt, &tx_ring->dma, tx_ring->txds,
+		   tx_ring->rd_p, tx_ring->wr_p, d_rd_p, d_wr_p);
 
 	for (i = 0; i < txd_cnt; i++) {
 		txd = &tx_ring->txds[i];
-- 
2.11.0
