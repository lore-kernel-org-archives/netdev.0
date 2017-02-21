From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC v3 3/8] nfp: Changes to use generic XDP infrastructure
Date: Tue, 21 Feb 2017 11:34:12 -0800
Message-ID: <20170221193417.3641224-4-tom@herbertland.com>
References: <20170221193417.3641224-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47181 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754060AbdBUTe2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 14:34:28 -0500
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1LJS9M8025485
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:27 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28ru5a063x-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 11:34:27 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 c18fa62ef86c11e6bc1f0002c99293a0-e62e9a00 for <netdev@vger.kernel.org>;        Tue,
 21 Feb 2017 11:34:26 -0800
In-Reply-To: <20170221193417.3641224-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change XDP program management functional interface to correspond to new
XDP API.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   5 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 172 ++++++++++-----------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  12 +-
 3 files changed, 87 insertions(+), 102 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index e614a37..732e40b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -503,14 +503,13 @@ struct nfp_net {
 	unsigned is_vf:1;
 	unsigned bpf_offload_skip_sw:1;
 	unsigned bpf_offload_xdp:1;
+	unsigned xdp_enabled:1;
 
 	u32 ctrl;
 	u32 fl_bufsz;
 
 	u32 rx_offset;
 
-	struct bpf_prog *xdp_prog;
-
 	struct nfp_net_tx_ring *tx_rings;
 	struct nfp_net_rx_ring *rx_rings;
 
@@ -788,7 +787,7 @@ void
 nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
 		    unsigned int n);
 int
-nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
+nfp_net_ring_reconfig(struct nfp_net *nn,
 		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx);
 
 #ifdef CONFIG_NFP_DEBUG
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 074259c..6200035 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -65,6 +65,7 @@
 
 #include <net/pkt_cls.h>
 #include <net/vxlan.h>
+#include <net/xdp.h>
 
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
@@ -1169,10 +1170,10 @@ nfp_net_napi_alloc_one(struct nfp_net *nn, int direction, dma_addr_t *dma_addr)
 {
 	void *frag;
 
-	if (!nn->xdp_prog)
-		frag = napi_alloc_frag(nn->fl_bufsz);
-	else
+	if (nn->xdp_enabled)
 		frag = page_address(alloc_page(GFP_ATOMIC | __GFP_COLD));
+	else
+		frag = napi_alloc_frag(nn->fl_bufsz);
 	if (!frag) {
 		nn_warn_ratelimit(nn, "Failed to alloc receive page frag\n");
 		return NULL;
@@ -1180,7 +1181,7 @@ nfp_net_napi_alloc_one(struct nfp_net *nn, int direction, dma_addr_t *dma_addr)
 
 	*dma_addr = nfp_net_dma_map_rx(nn, frag, nn->fl_bufsz, direction);
 	if (dma_mapping_error(&nn->pdev->dev, *dma_addr)) {
-		nfp_net_free_frag(frag, nn->xdp_prog);
+		nfp_net_free_frag(frag, nn->xdp_enabled);
 		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
 		return NULL;
 	}
@@ -1251,17 +1252,15 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
  * nfp_net_rx_ring_bufs_free() - Free any buffers currently on the RX ring
  * @nn:		NFP Net device
  * @rx_ring:	RX ring to remove buffers from
- * @xdp:	Whether XDP is enabled
  *
  * Assumes that the device is stopped and buffers are in [0, ring->cnt - 1)
  * entries.  After device is disabled nfp_net_rx_ring_reset() must be called
  * to restore required ring geometry.
  */
 static void
-nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
-			  bool xdp)
+nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)
 {
-	int direction = xdp ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
+	int direction = nn->xdp_enabled ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
 	unsigned int i;
 
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
@@ -1274,7 +1273,7 @@ nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
 
 		nfp_net_dma_unmap_rx(nn, rx_ring->rxbufs[i].dma_addr,
 				     rx_ring->bufsz, direction);
-		nfp_net_free_frag(rx_ring->rxbufs[i].frag, xdp);
+		nfp_net_free_frag(rx_ring->rxbufs[i].frag, nn->xdp_enabled);
 		rx_ring->rxbufs[i].dma_addr = 0;
 		rx_ring->rxbufs[i].frag = NULL;
 	}
@@ -1287,8 +1286,7 @@ nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
  * @xdp:	Whether XDP is enabled
  */
 static int
-nfp_net_rx_ring_bufs_alloc(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
-			   bool xdp)
+nfp_net_rx_ring_bufs_alloc(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)
 {
 	struct nfp_net_rx_buf *rxbufs;
 	unsigned int i;
@@ -1298,9 +1296,9 @@ nfp_net_rx_ring_bufs_alloc(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
 		rxbufs[i].frag =
 			nfp_net_rx_alloc_one(rx_ring, &rxbufs[i].dma_addr,
-					     rx_ring->bufsz, xdp);
+					     rx_ring->bufsz, nn->xdp_enabled);
 		if (!rxbufs[i].frag) {
-			nfp_net_rx_ring_bufs_free(nn, rx_ring, xdp);
+			nfp_net_rx_ring_bufs_free(nn, rx_ring);
 			return -ENOMEM;
 		}
 	}
@@ -1516,16 +1514,6 @@ nfp_net_tx_xdp_buf(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring,
 	return true;
 }
 
-static int nfp_net_run_xdp(struct bpf_prog *prog, void *data, unsigned int len)
-{
-	struct xdp_buff xdp;
-
-	xdp.data = data;
-	xdp.data_end = data + len;
-
-	return bpf_prog_run_xdp(prog, &xdp);
-}
-
 /**
  * nfp_net_rx() - receive up to @budget packets on @rx_ring
  * @rx_ring:   RX ring to receive from
@@ -1542,19 +1530,20 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
 	struct nfp_net_tx_ring *tx_ring;
-	struct bpf_prog *xdp_prog;
 	unsigned int true_bufsz;
 	struct sk_buff *skb;
+	bool run_xdp;
 	int pkts_polled = 0;
 	int rx_dma_map_dir;
 	int idx;
 
 	rcu_read_lock();
-	xdp_prog = READ_ONCE(nn->xdp_prog);
-	rx_dma_map_dir = xdp_prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
-	true_bufsz = xdp_prog ? PAGE_SIZE : nn->fl_bufsz;
+	rx_dma_map_dir = nn->xdp_enabled ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
+	true_bufsz = nn->xdp_enabled ? PAGE_SIZE : nn->fl_bufsz;
 	tx_ring = r_vec->xdp_ring;
 
+	run_xdp = xdp_hook_run_needed_check(nn->netdev, &r_vec->napi);
+
 	while (pkts_polled < budget) {
 		unsigned int meta_len, data_len, data_off, pkt_len, pkt_off;
 		struct nfp_net_rx_buf *rxbuf;
@@ -1605,15 +1594,21 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		r_vec->rx_bytes += pkt_len;
 		u64_stats_update_end(&r_vec->rx_sync);
 
-		if (xdp_prog && !(rxd->rxd.flags & PCIE_DESC_RX_BPF &&
-				  nn->bpf_offload_xdp)) {
+		if (run_xdp && !(rxd->rxd.flags & PCIE_DESC_RX_BPF &&
+				 nn->bpf_offload_xdp)) {
 			int act;
+			struct xdp_buff xdp;
+			struct xdp_hook *last_hook;
 
 			dma_sync_single_for_cpu(&nn->pdev->dev,
 						rxbuf->dma_addr + pkt_off,
 						pkt_len, DMA_FROM_DEVICE);
-			act = nfp_net_run_xdp(xdp_prog, rxbuf->frag + data_off,
-					      pkt_len);
+
+			xdp.data = rxbuf->frag + data_off;
+			xdp.data_end = xdp.data + pkt_len;
+
+			act = xdp_hook_run_ret_last(&r_vec->napi, &xdp,
+						    &last_hook);
 			switch (act) {
 			case XDP_PASS:
 				break;
@@ -1621,12 +1616,15 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 				if (unlikely(!nfp_net_tx_xdp_buf(nn, rx_ring,
 								 tx_ring, rxbuf,
 								 pkt_off, pkt_len)))
-					trace_xdp_exception(nn->netdev, xdp_prog, act);
+					trace_xdp_hook_exception(nn->netdev,
+								 last_hook,
+								 act);
 				continue;
 			default:
-				bpf_warn_invalid_xdp_action(act);
+				xdp_warn_invalid_action(act);
 			case XDP_ABORTED:
-				trace_xdp_exception(nn->netdev, xdp_prog, act);
+				trace_xdp_hook_exception(nn->netdev, last_hook,
+							 act);
 			case XDP_DROP:
 				nfp_net_rx_give_one(rx_ring, rxbuf->frag,
 						    rxbuf->dma_addr);
@@ -1679,7 +1677,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		napi_gro_receive(&rx_ring->r_vec->napi, skb);
 	}
 
-	if (xdp_prog && tx_ring->wr_ptr_add)
+	if (run_xdp && tx_ring->wr_ptr_add)
 		nfp_net_tx_xmit_more_flush(tx_ring);
 	rcu_read_unlock();
 
@@ -1910,8 +1908,7 @@ nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring, unsigned int fl_bufsz,
 }
 
 static struct nfp_net_rx_ring *
-nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
-			    bool xdp)
+nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
 	unsigned int fl_bufsz =	nfp_net_calc_fl_bufsz(nn, s->mtu);
 	struct nfp_net_rx_ring *rings;
@@ -1927,7 +1924,7 @@ nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
 		if (nfp_net_rx_ring_alloc(&rings[r], fl_bufsz, s->dcnt))
 			goto err_free_prev;
 
-		if (nfp_net_rx_ring_bufs_alloc(nn, &rings[r], xdp))
+		if (nfp_net_rx_ring_bufs_alloc(nn, &rings[r]))
 			goto err_free_ring;
 	}
 
@@ -1935,7 +1932,7 @@ nfp_net_rx_ring_set_prepare(struct nfp_net *nn, struct nfp_net_ring_set *s,
 
 err_free_prev:
 	while (r--) {
-		nfp_net_rx_ring_bufs_free(nn, &rings[r], xdp);
+		nfp_net_rx_ring_bufs_free(nn, &rings[r]);
 err_free_ring:
 		nfp_net_rx_ring_free(&rings[r]);
 	}
@@ -1961,14 +1958,13 @@ nfp_net_rx_ring_set_swap(struct nfp_net *nn, struct nfp_net_ring_set *s)
 }
 
 static void
-nfp_net_rx_ring_set_free(struct nfp_net *nn, struct nfp_net_ring_set *s,
-			 bool xdp)
+nfp_net_rx_ring_set_free(struct nfp_net *nn, struct nfp_net_ring_set *s)
 {
 	struct nfp_net_rx_ring *rings = s->rings;
 	unsigned int r;
 
 	for (r = 0; r < s->n_rings; r++) {
-		nfp_net_rx_ring_bufs_free(nn, &rings[r], xdp);
+		nfp_net_rx_ring_bufs_free(nn, &rings[r]);
 		nfp_net_rx_ring_free(&rings[r]);
 	}
 
@@ -2304,7 +2300,7 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 			goto err_cleanup_vec_p;
 	}
 
-	nn->rx_rings = nfp_net_rx_ring_set_prepare(nn, &rx, nn->xdp_prog);
+	nn->rx_rings = nfp_net_rx_ring_set_prepare(nn, &rx);
 	if (!nn->rx_rings) {
 		err = -ENOMEM;
 		goto err_cleanup_vec;
@@ -2352,7 +2348,7 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 err_free_rings:
 	nfp_net_tx_ring_set_free(nn, &tx);
 err_free_rx_rings:
-	nfp_net_rx_ring_set_free(nn, &rx, nn->xdp_prog);
+	nfp_net_rx_ring_set_free(nn, &rx);
 err_cleanup_vec:
 	r = nn->num_r_vecs;
 err_cleanup_vec_p:
@@ -2393,7 +2389,7 @@ static void nfp_net_close_free_all(struct nfp_net *nn)
 	unsigned int r;
 
 	for (r = 0; r < nn->num_rx_rings; r++) {
-		nfp_net_rx_ring_bufs_free(nn, &nn->rx_rings[r], nn->xdp_prog);
+		nfp_net_rx_ring_bufs_free(nn, &nn->rx_rings[r]);
 		nfp_net_rx_ring_free(&nn->rx_rings[r]);
 	}
 	for (r = 0; r < nn->num_tx_rings; r++)
@@ -2474,7 +2470,6 @@ static void nfp_net_rss_init_itbl(struct nfp_net *nn)
 static int
 nfp_net_ring_swap_enable(struct nfp_net *nn, unsigned int *num_vecs,
 			 unsigned int *stack_tx_rings,
-			 struct bpf_prog **xdp_prog,
 			 struct nfp_net_ring_set *rx,
 			 struct nfp_net_ring_set *tx)
 {
@@ -2488,7 +2483,6 @@ nfp_net_ring_swap_enable(struct nfp_net *nn, unsigned int *num_vecs,
 
 	swap(*num_vecs, nn->num_r_vecs);
 	swap(*stack_tx_rings, nn->num_stack_tx_rings);
-	*xdp_prog = xchg(&nn->xdp_prog, *xdp_prog);
 
 	for (r = 0; r <	nn->max_r_vecs; r++)
 		nfp_net_vector_assign_rings(nn, &nn->r_vecs[r], r);
@@ -2512,11 +2506,11 @@ nfp_net_ring_swap_enable(struct nfp_net *nn, unsigned int *num_vecs,
 }
 
 static int
-nfp_net_check_config(struct nfp_net *nn, struct bpf_prog *xdp_prog,
+nfp_net_check_config(struct nfp_net *nn,
 		     struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx)
 {
 	/* XDP-enabled tests */
-	if (!xdp_prog)
+	if (!nn->xdp_enabled)
 		return 0;
 	if (rx && nfp_net_calc_fl_bufsz(nn, rx->mtu) > PAGE_SIZE) {
 		nn_warn(nn, "MTU too large w/ XDP enabled\n");
@@ -2531,7 +2525,7 @@ nfp_net_check_config(struct nfp_net *nn, struct bpf_prog *xdp_prog,
 }
 
 static void
-nfp_net_ring_reconfig_down(struct nfp_net *nn, struct bpf_prog **xdp_prog,
+nfp_net_ring_reconfig_down(struct nfp_net *nn,
 			   struct nfp_net_ring_set *rx,
 			   struct nfp_net_ring_set *tx,
 			   unsigned int stack_tx_rings, unsigned int num_vecs)
@@ -2544,31 +2538,30 @@ nfp_net_ring_reconfig_down(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 	nn->num_tx_rings = tx ? tx->n_rings : nn->num_tx_rings;
 	nn->num_stack_tx_rings = stack_tx_rings;
 	nn->num_r_vecs = num_vecs;
-	*xdp_prog = xchg(&nn->xdp_prog, *xdp_prog);
 
 	if (!netif_is_rxfh_configured(nn->netdev))
 		nfp_net_rss_init_itbl(nn);
 }
 
 int
-nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
+nfp_net_ring_reconfig(struct nfp_net *nn,
 		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx)
 {
 	unsigned int stack_tx_rings, num_vecs, r;
 	int err;
 
 	stack_tx_rings = tx ? tx->n_rings : nn->num_tx_rings;
-	if (*xdp_prog)
+	if (nn->xdp_enabled)
 		stack_tx_rings -= rx ? rx->n_rings : nn->num_rx_rings;
 
 	num_vecs = max(rx ? rx->n_rings : nn->num_rx_rings, stack_tx_rings);
 
-	err = nfp_net_check_config(nn, *xdp_prog, rx, tx);
+	err = nfp_net_check_config(nn, rx, tx);
 	if (err)
 		return err;
 
 	if (!netif_running(nn->netdev)) {
-		nfp_net_ring_reconfig_down(nn, xdp_prog, rx, tx,
+		nfp_net_ring_reconfig_down(nn, rx, tx,
 					   stack_tx_rings, num_vecs);
 		return 0;
 	}
@@ -2582,7 +2575,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 		}
 	}
 	if (rx) {
-		if (!nfp_net_rx_ring_set_prepare(nn, rx, *xdp_prog)) {
+		if (!nfp_net_rx_ring_set_prepare(nn, rx)) {
 			err = -ENOMEM;
 			goto err_cleanup_vecs;
 		}
@@ -2599,7 +2592,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 	nfp_net_clear_config_and_disable(nn);
 
 	err = nfp_net_ring_swap_enable(nn, &num_vecs, &stack_tx_rings,
-				       xdp_prog, rx, tx);
+				       rx, tx);
 	if (err) {
 		int err2;
 
@@ -2607,7 +2600,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 
 		/* Try with old configuration and old rings */
 		err2 = nfp_net_ring_swap_enable(nn, &num_vecs, &stack_tx_rings,
-						xdp_prog, rx, tx);
+						rx, tx);
 		if (err2)
 			nn_err(nn, "Can't restore ring config - FW communication failed (%d,%d)\n",
 			       err, err2);
@@ -2616,7 +2609,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
 
 	if (rx)
-		nfp_net_rx_ring_set_free(nn, rx, *xdp_prog);
+		nfp_net_rx_ring_set_free(nn, rx);
 	if (tx)
 		nfp_net_tx_ring_set_free(nn, tx);
 
@@ -2626,7 +2619,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 
 err_free_rx:
 	if (rx)
-		nfp_net_rx_ring_set_free(nn, rx, *xdp_prog);
+		nfp_net_rx_ring_set_free(nn, rx);
 err_cleanup_vecs:
 	for (r = num_vecs - 1; r >= nn->num_r_vecs; r--)
 		nfp_net_cleanup_vector(nn, &nn->r_vecs[r]);
@@ -2642,7 +2635,7 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 		.dcnt = nn->rxd_cnt,
 	};
 
-	return nfp_net_ring_reconfig(nn, &nn->xdp_prog, &rx, NULL);
+	return nfp_net_ring_reconfig(nn, &rx, NULL);
 }
 
 static void nfp_net_stat64(struct net_device *netdev,
@@ -2938,7 +2931,17 @@ static int nfp_net_xdp_offload(struct nfp_net *nn, struct bpf_prog *prog)
 	return ret;
 }
 
-static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
+static int nfp_xdp_check_bpf(struct nfp_net *nn, struct bpf_prog *prog)
+{
+	if (prog && prog->xdp_adjust_head) {
+		nn_err(nn, "Does not support bpf_xdp_adjust_head()\n");
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static int nfp_net_xdp_init(struct nfp_net *nn, bool enable)
 {
 	struct nfp_net_ring_set rx = {
 		.n_rings = nn->num_rx_rings,
@@ -2951,33 +2954,17 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 	};
 	int err;
 
-	if (prog && prog->xdp_adjust_head) {
-		nn_err(nn, "Does not support bpf_xdp_adjust_head()\n");
-		return -EOPNOTSUPP;
-	}
-	if (!prog && !nn->xdp_prog)
-		return 0;
-	if (prog && nn->xdp_prog) {
-		prog = xchg(&nn->xdp_prog, prog);
-		bpf_prog_put(prog);
-		nfp_net_xdp_offload(nn, nn->xdp_prog);
+	if (nn->xdp_enabled == enable)
 		return 0;
-	}
-
-	tx.n_rings += prog ? nn->num_rx_rings : -nn->num_rx_rings;
 
-	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
-	err = nfp_net_ring_reconfig(nn, &prog, &rx, &tx);
-	if (err)
-		return err;
+	nn->xdp_enabled = enable;
 
-	/* @prog got swapped and is now the old one */
-	if (prog)
-		bpf_prog_put(prog);
+	tx.n_rings += enable ? nn->num_rx_rings : -nn->num_rx_rings;
 
-	nfp_net_xdp_offload(nn, nn->xdp_prog);
+	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
+	err = nfp_net_ring_reconfig(nn, &rx, &tx);
 
-	return 0;
+	return err;
 }
 
 static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
@@ -2985,11 +2972,14 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 	struct nfp_net *nn = netdev_priv(netdev);
 
 	switch (xdp->command) {
-	case XDP_SETUP_PROG:
-		return nfp_net_xdp_setup(nn, xdp->prog);
-	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!nn->xdp_prog;
-		return 0;
+	case XDP_MODE_ON:
+		return nfp_net_xdp_init(nn, true);
+	case XDP_MODE_OFF:
+		return nfp_net_xdp_init(nn, false);
+	case XDP_CHECK_BPF_PROG:
+		return nfp_xdp_check_bpf(nn, xdp->prog);
+	case XDP_OFFLOAD_BPF:
+		return nfp_net_xdp_offload(nn, xdp->prog);
 	default:
 		return -EINVAL;
 	}
@@ -3175,7 +3165,7 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	 * and netdev->hw_features advertises which features are
 	 * supported.  By default we enable most features.
 	 */
-	netdev->hw_features = NETIF_F_HIGHDMA;
+	netdev->hw_features = NETIF_F_HIGHDMA | NETIF_F_XDP;
 	if (nn->cap & NFP_NET_CFG_CTRL_RXCSUM) {
 		netdev->hw_features |= NETIF_F_RXCSUM;
 		nn->ctrl |= NFP_NET_CFG_CTRL_RXCSUM;
@@ -3274,8 +3264,6 @@ void nfp_net_netdev_clean(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
-	if (nn->xdp_prog)
-		bpf_prog_put(nn->xdp_prog);
 	if (nn->bpf_offload_xdp)
 		nfp_net_xdp_offload(nn, NULL);
 	unregister_netdev(nn->netdev);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 2649f75..1377c7e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -201,8 +201,7 @@ static int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
 	if (nn->txd_cnt != txd_cnt)
 		reconfig_tx = &tx;
 
-	return nfp_net_ring_reconfig(nn, &nn->xdp_prog,
-				     reconfig_rx, reconfig_tx);
+	return nfp_net_ring_reconfig(nn, reconfig_rx, reconfig_tx);
 }
 
 static int nfp_net_set_ringparam(struct net_device *netdev,
@@ -737,7 +736,7 @@ static void nfp_net_get_channels(struct net_device *netdev,
 	unsigned int num_tx_rings;
 
 	num_tx_rings = nn->num_tx_rings;
-	if (nn->xdp_prog)
+	if (nn->xdp_enabled)
 		num_tx_rings -= nn->num_rx_rings;
 
 	channel->max_rx = min(nn->max_rx_rings, nn->max_r_vecs);
@@ -767,15 +766,14 @@ static int nfp_net_set_num_rings(struct nfp_net *nn, unsigned int total_rx,
 	if (nn->num_rx_rings != total_rx)
 		reconfig_rx = &rx;
 	if (nn->num_stack_tx_rings != total_tx ||
-	    (nn->xdp_prog && reconfig_rx))
+	    (nn->xdp_enabled && reconfig_rx))
 		reconfig_tx = &tx;
 
 	/* nfp_net_check_config() will catch tx.n_rings > nn->max_tx_rings */
-	if (nn->xdp_prog)
+	if (nn->xdp_enabled)
 		tx.n_rings += total_rx;
 
-	return nfp_net_ring_reconfig(nn, &nn->xdp_prog,
-				     reconfig_rx, reconfig_tx);
+	return nfp_net_ring_reconfig(nn, reconfig_rx, reconfig_tx);
 }
 
 static int nfp_net_set_channels(struct net_device *netdev,
-- 
2.9.3
