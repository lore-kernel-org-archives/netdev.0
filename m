From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 7/9] nfp: complete the XDP TX ring only when it's full
Date: Mon, 15 May 2017 17:55:21 -0700
Message-ID: <20170516005523.26124-8-jakub.kicinski@netronome.com>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34507 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdEPA4X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 20:56:23 -0400
Received: by mail-pf0-f179.google.com with SMTP id 9so31448560pfj.1
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 17:56:23 -0700 (PDT)
In-Reply-To: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since XDP TX ring holds "spare" RX buffers anyway, we don't have to
rush the completion.  We can wait until ring fills up completely
before trying to reclaim buffers.  If RX poll has ended an no
buffer has been queued for XDP TX we have no guarantee we will see
another interrupt, so run the reclaim there as well, to make sure
TX statistics won't become stale.

This should help us reclaim more buffers per single queue controller
register read.

Note that the XDP completion is very trivial, it only adds up
the sizes of transmitted frames for statistics so the latency
spike should be acceptable.  In case user sets the ring sizes
to something crazy, limit the completion to 2k entries.

The check if the ring is empty at the beginning of xdp_complete()
is no longer needed - the callers will perform it.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  1 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 52 ++++++++++++++--------
 2 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index acd9811d08d1..66319a1026bb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -102,6 +102,7 @@
 #define NFP_NET_RX_DESCS_DEFAULT 4096	/* Default # of Rx descs per ring */
 
 #define NFP_NET_FL_BATCH	16	/* Add freelist in this Batch size */
+#define NFP_NET_XDP_MAX_COMPLETE 2048	/* XDP bufs to reclaim in NAPI poll */
 
 /* Offload definitions */
 #define NFP_NET_N_VXLAN_PORTS	(NFP_NET_CFG_VXLAN_SZ / sizeof(__be16))
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index d640b3331741..a4c6878f1df1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1001,27 +1001,30 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
 		  tx_ring->rd_p, tx_ring->wr_p, tx_ring->cnt);
 }
 
-static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
+static bool nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 {
 	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
 	u32 done_pkts = 0, done_bytes = 0;
+	bool done_all;
 	int idx, todo;
 	u32 qcp_rd_p;
 
-	if (tx_ring->wr_p == tx_ring->rd_p)
-		return;
-
 	/* Work out how many descriptors have been transmitted */
 	qcp_rd_p = nfp_qcp_rd_ptr_read(tx_ring->qcp_q);
 
 	if (qcp_rd_p == tx_ring->qcp_rd_p)
-		return;
+		return true;
 
 	if (qcp_rd_p > tx_ring->qcp_rd_p)
 		todo = qcp_rd_p - tx_ring->qcp_rd_p;
 	else
 		todo = qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p;
 
+	done_all = todo <= NFP_NET_XDP_MAX_COMPLETE;
+	todo = min(todo, NFP_NET_XDP_MAX_COMPLETE);
+
+	tx_ring->qcp_rd_p = (tx_ring->qcp_rd_p + todo) & (tx_ring->cnt - 1);
+
 	done_pkts = todo;
 	while (todo--) {
 		idx = tx_ring->rd_p & (tx_ring->cnt - 1);
@@ -1030,16 +1033,16 @@ static void nfp_net_xdp_complete(struct nfp_net_tx_ring *tx_ring)
 		done_bytes += tx_ring->txbufs[idx].real_len;
 	}
 
-	tx_ring->qcp_rd_p = qcp_rd_p;
-
 	u64_stats_update_begin(&r_vec->tx_sync);
 	r_vec->tx_bytes += done_bytes;
 	r_vec->tx_pkts += done_pkts;
 	u64_stats_update_end(&r_vec->tx_sync);
 
 	WARN_ONCE(tx_ring->wr_p - tx_ring->rd_p > tx_ring->cnt,
-		  "TX ring corruption rd_p=%u wr_p=%u cnt=%u\n",
+		  "XDP TX ring corruption rd_p=%u wr_p=%u cnt=%u\n",
 		  tx_ring->rd_p, tx_ring->wr_p, tx_ring->cnt);
+
+	return done_all;
 }
 
 /**
@@ -1500,15 +1503,23 @@ static bool
 nfp_net_tx_xdp_buf(struct nfp_net_dp *dp, struct nfp_net_rx_ring *rx_ring,
 		   struct nfp_net_tx_ring *tx_ring,
 		   struct nfp_net_rx_buf *rxbuf, unsigned int dma_off,
-		   unsigned int pkt_len)
+		   unsigned int pkt_len, bool *completed)
 {
 	struct nfp_net_tx_buf *txbuf;
 	struct nfp_net_tx_desc *txd;
 	int wr_idx;
 
 	if (unlikely(nfp_net_tx_full(tx_ring, 1))) {
-		nfp_net_rx_drop(dp, rx_ring->r_vec, rx_ring, rxbuf, NULL);
-		return false;
+		if (!*completed) {
+			nfp_net_xdp_complete(tx_ring);
+			*completed = true;
+		}
+
+		if (unlikely(nfp_net_tx_full(tx_ring, 1))) {
+			nfp_net_rx_drop(dp, rx_ring->r_vec, rx_ring, rxbuf,
+					NULL);
+			return false;
+		}
 	}
 
 	wr_idx = tx_ring->wr_p & (tx_ring->cnt - 1);
@@ -1580,6 +1591,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 	struct nfp_net_dp *dp = &r_vec->nfp_net->dp;
 	struct nfp_net_tx_ring *tx_ring;
 	struct bpf_prog *xdp_prog;
+	bool xdp_tx_cmpl = false;
 	unsigned int true_bufsz;
 	struct sk_buff *skb;
 	int pkts_polled = 0;
@@ -1690,7 +1702,8 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 				if (unlikely(!nfp_net_tx_xdp_buf(dp, rx_ring,
 								 tx_ring, rxbuf,
 								 dma_off,
-								 pkt_len)))
+								 pkt_len,
+								 &xdp_tx_cmpl)))
 					trace_xdp_exception(dp->netdev,
 							    xdp_prog, act);
 				continue;
@@ -1738,8 +1751,14 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		napi_gro_receive(&rx_ring->r_vec->napi, skb);
 	}
 
-	if (xdp_prog && tx_ring->wr_ptr_add)
-		nfp_net_tx_xmit_more_flush(tx_ring);
+	if (xdp_prog) {
+		if (tx_ring->wr_ptr_add)
+			nfp_net_tx_xmit_more_flush(tx_ring);
+		else if (unlikely(tx_ring->wr_p != tx_ring->rd_p) &&
+			 !xdp_tx_cmpl)
+			if (!nfp_net_xdp_complete(tx_ring))
+				pkts_polled = budget;
+	}
 	rcu_read_unlock();
 
 	return pkts_polled;
@@ -1760,11 +1779,8 @@ static int nfp_net_poll(struct napi_struct *napi, int budget)
 
 	if (r_vec->tx_ring)
 		nfp_net_tx_complete(r_vec->tx_ring);
-	if (r_vec->rx_ring) {
+	if (r_vec->rx_ring)
 		pkts_polled = nfp_net_rx(r_vec->rx_ring, budget);
-		if (r_vec->xdp_ring)
-			nfp_net_xdp_complete(r_vec->xdp_ring);
-	}
 
 	if (pkts_polled < budget)
 		if (napi_complete_done(napi, pkts_polled))
-- 
2.11.0
