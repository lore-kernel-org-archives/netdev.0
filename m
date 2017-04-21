From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 2/5] nfp: parse metadata prepend before XDP runs
Date: Fri, 21 Apr 2017 12:23:07 -0700
Message-ID: <20170421192310.193875-3-jakub.kicinski@netronome.com>
References: <20170421192310.193875-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:35607 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424891AbdDUTXX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:23:23 -0400
Received: by mail-oi0-f45.google.com with SMTP id j201so108856850oih.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:23:23 -0700 (PDT)
In-Reply-To: <20170421192310.193875-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling memcpy to shift metadata out of the way for XDP to run
seems like an overkill.  The most common metadata contents are
8 bytes containing type and flow hash.  Simply parse the metadata
before we run XDP.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  6 ++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 67 +++++++++++-----------
 2 files changed, 40 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 052db9208fbb..8302a2d688da 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -284,6 +284,12 @@ struct nfp_net_rx_desc {
 
 #define NFP_NET_META_FIELD_MASK GENMASK(NFP_NET_META_FIELD_SIZE - 1, 0)
 
+struct nfp_meta_parsed {
+	u32 hash_type;
+	u32 hash;
+	u32 mark;
+};
+
 struct nfp_net_rx_hash {
 	__be32 hash_type;
 	__be32 hash;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 71e5568a43ff..7b70944573fa 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1403,8 +1403,9 @@ static void nfp_net_rx_csum(struct nfp_net_dp *dp,
 	}
 }
 
-static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
-			     unsigned int type, __be32 *hash)
+static void
+nfp_net_set_hash(struct net_device *netdev, struct nfp_meta_parsed *meta,
+		 unsigned int type, __be32 *hash)
 {
 	if (!(netdev->features & NETIF_F_RXHASH))
 		return;
@@ -1413,16 +1414,18 @@ static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
 	case NFP_NET_RSS_IPV4:
 	case NFP_NET_RSS_IPV6:
 	case NFP_NET_RSS_IPV6_EX:
-		skb_set_hash(skb, get_unaligned_be32(hash), PKT_HASH_TYPE_L3);
+		meta->hash_type = PKT_HASH_TYPE_L3;
 		break;
 	default:
-		skb_set_hash(skb, get_unaligned_be32(hash), PKT_HASH_TYPE_L4);
+		meta->hash_type = PKT_HASH_TYPE_L4;
 		break;
 	}
+
+	meta->hash = get_unaligned_be32(hash);
 }
 
 static void
-nfp_net_set_hash_desc(struct net_device *netdev, struct sk_buff *skb,
+nfp_net_set_hash_desc(struct net_device *netdev, struct nfp_meta_parsed *meta,
 		      void *data, struct nfp_net_rx_desc *rxd)
 {
 	struct nfp_net_rx_hash *rx_hash = data;
@@ -1430,12 +1433,12 @@ nfp_net_set_hash_desc(struct net_device *netdev, struct sk_buff *skb,
 	if (!(rxd->rxd.flags & PCIE_DESC_RX_RSS))
 		return;
 
-	nfp_net_set_hash(netdev, skb, get_unaligned_be32(&rx_hash->hash_type),
+	nfp_net_set_hash(netdev, meta, get_unaligned_be32(&rx_hash->hash_type),
 			 &rx_hash->hash);
 }
 
 static void *
-nfp_net_parse_meta(struct net_device *netdev, struct sk_buff *skb,
+nfp_net_parse_meta(struct net_device *netdev, struct nfp_meta_parsed *meta,
 		   void *data, int meta_len)
 {
 	u32 meta_info;
@@ -1447,13 +1450,13 @@ nfp_net_parse_meta(struct net_device *netdev, struct sk_buff *skb,
 		switch (meta_info & NFP_NET_META_FIELD_MASK) {
 		case NFP_NET_META_HASH:
 			meta_info >>= NFP_NET_META_FIELD_SIZE;
-			nfp_net_set_hash(netdev, skb,
+			nfp_net_set_hash(netdev, meta,
 					 meta_info & NFP_NET_META_FIELD_MASK,
 					 (__be32 *)data);
 			data += 4;
 			break;
 		case NFP_NET_META_MARK:
-			skb->mark = get_unaligned_be32(data);
+			meta->mark = get_unaligned_be32(data);
 			data += 4;
 			break;
 		default:
@@ -1588,12 +1591,11 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 	while (pkts_polled < budget) {
 		unsigned int meta_len, data_len, meta_off, pkt_len, pkt_off;
-		u8 meta_prepend[NFP_NET_MAX_PREPEND];
 		struct nfp_net_rx_buf *rxbuf;
 		struct nfp_net_rx_desc *rxd;
+		struct nfp_meta_parsed meta;
 		dma_addr_t new_dma_addr;
 		void *new_frag;
-		u8 *meta;
 
 		idx = rx_ring->rd_p & (rx_ring->cnt - 1);
 
@@ -1606,6 +1608,8 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		 */
 		dma_rmb();
 
+		memset(&meta, 0, sizeof(meta));
+
 		rx_ring->rd_p++;
 		pkts_polled++;
 
@@ -1639,9 +1643,6 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		r_vec->rx_bytes += pkt_len;
 		u64_stats_update_end(&r_vec->rx_sync);
 
-		/* Pointer to start of metadata */
-		meta = rxbuf->frag + meta_off;
-
 		if (unlikely(meta_len > NFP_NET_MAX_PREPEND ||
 			     (dp->rx_offset && meta_len > dp->rx_offset))) {
 			nn_dp_warn(dp, "oversized RX packet metadata %u\n",
@@ -1653,6 +1654,23 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		nfp_net_dma_sync_cpu_rx(dp, rxbuf->dma_addr + meta_off,
 					data_len);
 
+		if (!dp->chained_metadata_format) {
+			nfp_net_set_hash_desc(dp->netdev, &meta,
+					      rxbuf->frag + meta_off, rxd);
+		} else if (meta_len) {
+			void *end;
+
+			end = nfp_net_parse_meta(dp->netdev, &meta,
+						 rxbuf->frag + meta_off,
+						 meta_len);
+			if (unlikely(end != rxbuf->frag + pkt_off)) {
+				nn_dp_warn(dp, "invalid RX packet metadata\n");
+				nfp_net_rx_drop(dp, r_vec, rx_ring, rxbuf,
+						NULL);
+				continue;
+			}
+		}
+
 		if (xdp_prog && !(rxd->rxd.flags & PCIE_DESC_RX_BPF &&
 				  dp->bpf_offload_xdp)) {
 			unsigned int dma_off;
@@ -1661,12 +1679,6 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 			hard_start = rxbuf->frag + NFP_NET_RX_BUF_HEADROOM;
 
-			/* Move prepend out of the way */
-			if (xdp_prog->xdp_adjust_head) {
-				memcpy(meta_prepend, meta, meta_len);
-				meta = meta_prepend;
-			}
-
 			act = nfp_net_run_xdp(xdp_prog, rxbuf->frag, hard_start,
 					      &pkt_off, &pkt_len);
 			switch (act) {
@@ -1710,19 +1722,8 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		skb_reserve(skb, pkt_off);
 		skb_put(skb, pkt_len);
 
-		if (!dp->chained_metadata_format) {
-			nfp_net_set_hash_desc(dp->netdev, skb, meta, rxd);
-		} else if (meta_len) {
-			void *end;
-
-			end = nfp_net_parse_meta(dp->netdev, skb, meta,
-						 meta_len);
-			if (unlikely(end != meta + meta_len)) {
-				nn_dp_warn(dp, "invalid RX packet metadata\n");
-				nfp_net_rx_drop(dp, r_vec, rx_ring, NULL, skb);
-				continue;
-			}
-		}
+		skb->mark = meta.mark;
+		skb_set_hash(skb, meta.hash, meta.hash_type);
 
 		skb_record_rx_queue(skb, rx_ring->idx);
 		skb->protocol = eth_type_trans(skb, dp->netdev);
-- 
2.11.0
