From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/13] nfp: prepare metadata handling for xdp_adjust_head()
Date: Fri, 10 Mar 2017 10:38:38 -0800
Message-ID: <20170310183839.39568-13-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35128 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755428AbdCJSje (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:34 -0500
Received: by mail-pf0-f175.google.com with SMTP id j5so44844313pfb.2
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:33 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP may require us to move metadata to make room for pushing
headers.  Track meta data location with a pointer and pass
it explicitly to functions.

While at it validate that meta_len from the descriptor is not
bogus.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 28 +++++++++++++++-------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 0e4fa6802733..fe7c3f6d820d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1385,24 +1385,21 @@ static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
 
 static void
 nfp_net_set_hash_desc(struct net_device *netdev, struct sk_buff *skb,
-		      struct nfp_net_rx_desc *rxd)
+		      void *data, struct nfp_net_rx_desc *rxd)
 {
-	struct nfp_net_rx_hash *rx_hash;
+	struct nfp_net_rx_hash *rx_hash = data;
 
 	if (!(rxd->rxd.flags & PCIE_DESC_RX_RSS))
 		return;
 
-	rx_hash = (struct nfp_net_rx_hash *)(skb->data - sizeof(*rx_hash));
-
 	nfp_net_set_hash(netdev, skb, get_unaligned_be32(&rx_hash->hash_type),
 			 &rx_hash->hash);
 }
 
 static void *
 nfp_net_parse_meta(struct net_device *netdev, struct sk_buff *skb,
-		   int meta_len)
+		   void *data, int meta_len)
 {
-	u8 *data = skb->data - meta_len;
 	u32 meta_info;
 
 	meta_info = get_unaligned_be32(data);
@@ -1546,6 +1543,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		struct nfp_net_rx_desc *rxd;
 		dma_addr_t new_dma_addr;
 		void *new_frag;
+		u8 *meta;
 
 		idx = rx_ring->rd_p & (rx_ring->cnt - 1);
 
@@ -1589,6 +1587,17 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		r_vec->rx_bytes += pkt_len;
 		u64_stats_update_end(&r_vec->rx_sync);
 
+		/* Pointer to start of metadata */
+		meta = rxbuf->frag + data_off - meta_len;
+
+		if (unlikely(meta_len > NFP_NET_MAX_PREPEND ||
+			     (dp->rx_offset && meta_len > dp->rx_offset))) {
+			nn_dp_warn(dp, "oversized RX packet metadata %u\n",
+				   meta_len);
+			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, NULL);
+			continue;
+		}
+
 		if (xdp_prog && !(rxd->rxd.flags & PCIE_DESC_RX_BPF &&
 				  dp->bpf_offload_xdp)) {
 			unsigned int dma_off;
@@ -1641,12 +1650,13 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		skb_put(skb, pkt_len);
 
 		if (!dp->chained_metadata_format) {
-			nfp_net_set_hash_desc(dp->netdev, skb, rxd);
+			nfp_net_set_hash_desc(dp->netdev, skb, meta, rxd);
 		} else if (meta_len) {
 			void *end;
 
-			end = nfp_net_parse_meta(dp->netdev, skb, meta_len);
-			if (unlikely(end != skb->data)) {
+			end = nfp_net_parse_meta(dp->netdev, skb, meta,
+						 meta_len);
+			if (unlikely(end != meta + meta_len)) {
 				nn_dp_warn(dp, "invalid RX packet metadata\n");
 				nfp_net_rx_drop(r_vec, rx_ring, NULL, skb);
 				continue;
-- 
2.11.0
