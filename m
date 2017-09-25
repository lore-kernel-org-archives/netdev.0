From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/6] bpf, nfp: add meta data support
Date: Mon, 25 Sep 2017 02:25:54 +0200
Message-ID: <e88b1cbcb0cbfb20a960c57cee3c873e3cadc4cb.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37235 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933044AbdIYA1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 20:27:07 -0400
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
In-Reply-To: <cover.1506297988.git.daniel@iogearbox.net>
References: <cover.1506297988.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement support for transferring XDP meta data into skb for
nfp driver; before calling into the program, xdp.data_meta points
to xdp.data, where on program return with pass verdict, we call
into skb_metadata_set().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 40 ++++++++--------------
 1 file changed, 15 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index e3a38be..d2f73fe 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1574,27 +1574,6 @@ static void nfp_net_rx_csum(struct nfp_net_dp *dp,
 	return true;
 }
 
-static int nfp_net_run_xdp(struct bpf_prog *prog, void *data, void *hard_start,
-			   unsigned int *off, unsigned int *len)
-{
-	struct xdp_buff xdp;
-	void *orig_data;
-	int ret;
-
-	xdp.data_hard_start = hard_start;
-	xdp.data = data + *off;
-	xdp_set_data_meta_invalid(&xdp);
-	xdp.data_end = data + *off + *len;
-
-	orig_data = xdp.data;
-	ret = bpf_prog_run_xdp(prog, &xdp);
-
-	*len -= xdp.data - orig_data;
-	*off += xdp.data - orig_data;
-
-	return ret;
-}
-
 /**
  * nfp_net_rx() - receive up to @budget packets on @rx_ring
  * @rx_ring:   RX ring to receive from
@@ -1630,6 +1609,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		struct nfp_meta_parsed meta;
 		struct net_device *netdev;
 		dma_addr_t new_dma_addr;
+		u32 meta_len_xdp = 0;
 		void *new_frag;
 
 		idx = D_IDX(rx_ring, rx_ring->rd_p);
@@ -1708,16 +1688,24 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 		if (xdp_prog && !(rxd->rxd.flags & PCIE_DESC_RX_BPF &&
 				  dp->bpf_offload_xdp) && !meta.portid) {
+			void *orig_data = rxbuf->frag + pkt_off;
 			unsigned int dma_off;
-			void *hard_start;
+			struct xdp_buff xdp;
 			int act;
 
-			hard_start = rxbuf->frag + NFP_NET_RX_BUF_HEADROOM;
+			xdp.data_hard_start = rxbuf->frag + NFP_NET_RX_BUF_HEADROOM;
+			xdp.data = orig_data;
+			xdp.data_meta = orig_data;
+			xdp.data_end = orig_data + pkt_len;
+
+			act = bpf_prog_run_xdp(xdp_prog, &xdp);
+
+			pkt_len -= xdp.data - orig_data;
+			pkt_off += xdp.data - orig_data;
 
-			act = nfp_net_run_xdp(xdp_prog, rxbuf->frag, hard_start,
-					      &pkt_off, &pkt_len);
 			switch (act) {
 			case XDP_PASS:
+				meta_len_xdp = xdp.data - xdp.data_meta;
 				break;
 			case XDP_TX:
 				dma_off = pkt_off - NFP_NET_RX_BUF_HEADROOM;
@@ -1785,6 +1773,8 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		if (rxd->rxd.flags & PCIE_DESC_RX_VLAN)
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 					       le16_to_cpu(rxd->rxd.vlan));
+		if (meta_len_xdp)
+			skb_metadata_set(skb, meta_len_xdp);
 
 		napi_gro_receive(&rx_ring->r_vec->napi, skb);
 	}
-- 
1.9.3
