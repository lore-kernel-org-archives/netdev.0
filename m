From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2 09/12] nfp: add support for tx/rx with metadata portid
Date: Tue, 20 Jun 2017 23:36:17 +0200
Message-ID: <1497994580-6271-10-git-send-email-simon.horman@netronome.com>
References: <1497994580-6271-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:33461 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752515AbdFTVhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 17:37:05 -0400
Received: by mail-qt0-f176.google.com with SMTP id u12so143977247qth.0
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 14:37:05 -0700 (PDT)
In-Reply-To: <1497994580-6271-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow tx/rx with metadata port id. This will be used for tx/rx of
representor netdevs acting as upper-devices while a pf netdev acts
as a lower-device.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  1 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 57 +++++++++++++++++++---
 2 files changed, 52 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 02fd8d4e253c..96c8ea476c05 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -318,6 +318,7 @@ struct nfp_meta_parsed {
 	u8 csum_type;
 	u32 hash;
 	u32 mark;
+	u32 portid;
 	__wsum csum;
 };
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 2bdddd1ae666..49b8bc937ad8 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -755,6 +755,26 @@ static void nfp_net_tx_xmit_more_flush(struct nfp_net_tx_ring *tx_ring)
 	tx_ring->wr_ptr_add = 0;
 }
 
+static int nfp_net_prep_port_id(struct sk_buff *skb)
+{
+	struct metadata_dst *md_dst = skb_metadata_dst(skb);
+	unsigned char *data;
+
+	if (likely(!md_dst))
+		return 0;
+	if (unlikely(md_dst->type != METADATA_HW_PORT_MUX))
+		return 0;
+
+	if (unlikely(skb_cow_head(skb, 8)))
+		return -ENOMEM;
+
+	data = skb_push(skb, 8);
+	put_unaligned_be32(NFP_NET_META_PORTID, data);
+	put_unaligned_be32(md_dst->u.port_info.port_id, data + 4);
+
+	return 8;
+}
+
 /**
  * nfp_net_tx() - Main transmit entry point
  * @skb:    SKB to transmit
@@ -767,6 +787,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	struct nfp_net *nn = netdev_priv(netdev);
 	const struct skb_frag_struct *frag;
 	struct nfp_net_tx_desc *txd, txdg;
+	int f, nr_frags, wr_idx, md_bytes;
 	struct nfp_net_tx_ring *tx_ring;
 	struct nfp_net_r_vector *r_vec;
 	struct nfp_net_tx_buf *txbuf;
@@ -774,8 +795,6 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	struct nfp_net_dp *dp;
 	dma_addr_t dma_addr;
 	unsigned int fsize;
-	int f, nr_frags;
-	int wr_idx;
 	u16 qidx;
 
 	dp = &nn->dp;
@@ -797,6 +816,13 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_BUSY;
 	}
 
+	md_bytes = nfp_net_prep_port_id(skb);
+	if (unlikely(md_bytes < 0)) {
+		nfp_net_tx_xmit_more_flush(tx_ring);
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
 	/* Start with the head skbuf */
 	dma_addr = dma_map_single(dp->dev, skb->data, skb_headlen(skb),
 				  DMA_TO_DEVICE);
@@ -815,7 +841,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 
 	/* Build TX descriptor */
 	txd = &tx_ring->txds[wr_idx];
-	txd->offset_eop = (nr_frags == 0) ? PCIE_DESC_TX_EOP : 0;
+	txd->offset_eop = (nr_frags ? 0 : PCIE_DESC_TX_EOP) | md_bytes;
 	txd->dma_len = cpu_to_le16(skb_headlen(skb));
 	nfp_desc_set_dma_addr(txd, dma_addr);
 	txd->data_len = cpu_to_le16(skb->len);
@@ -855,7 +881,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 			*txd = txdg;
 			txd->dma_len = cpu_to_le16(fsize);
 			nfp_desc_set_dma_addr(txd, dma_addr);
-			txd->offset_eop =
+			txd->offset_eop |=
 				(f == nr_frags - 1) ? PCIE_DESC_TX_EOP : 0;
 		}
 
@@ -1450,6 +1476,10 @@ nfp_net_parse_meta(struct net_device *netdev, struct nfp_meta_parsed *meta,
 			meta->mark = get_unaligned_be32(data);
 			data += 4;
 			break;
+		case NFP_NET_META_PORTID:
+			meta->portid = get_unaligned_be32(data);
+			data += 4;
+			break;
 		case NFP_NET_META_CSUM:
 			meta->csum_type = CHECKSUM_COMPLETE;
 			meta->csum =
@@ -1594,6 +1624,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		struct nfp_net_rx_buf *rxbuf;
 		struct nfp_net_rx_desc *rxd;
 		struct nfp_meta_parsed meta;
+		struct net_device *netdev;
 		dma_addr_t new_dma_addr;
 		void *new_frag;
 
@@ -1672,7 +1703,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		}
 
 		if (xdp_prog && !(rxd->rxd.flags & PCIE_DESC_RX_BPF &&
-				  dp->bpf_offload_xdp)) {
+				  dp->bpf_offload_xdp) && !meta.portid) {
 			unsigned int dma_off;
 			void *hard_start;
 			int act;
@@ -1718,6 +1749,20 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			continue;
 		}
 
+		if (likely(!meta.portid)) {
+			netdev = dp->netdev;
+		} else {
+			struct nfp_net *nn;
+
+			nn = netdev_priv(dp->netdev);
+			netdev = nfp_app_repr_get(nn->app, meta.portid);
+			if (unlikely(!netdev)) {
+				nfp_net_rx_drop(dp, r_vec, rx_ring, rxbuf, skb);
+				continue;
+			}
+			nfp_repr_inc_rx_stats(netdev, pkt_len);
+		}
+
 		nfp_net_dma_unmap_rx(dp, rxbuf->dma_addr);
 
 		nfp_net_rx_give_one(dp, rx_ring, new_frag, new_dma_addr);
@@ -1729,7 +1774,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		skb_set_hash(skb, meta.hash, meta.hash_type);
 
 		skb_record_rx_queue(skb, rx_ring->idx);
-		skb->protocol = eth_type_trans(skb, dp->netdev);
+		skb->protocol = eth_type_trans(skb, netdev);
 
 		nfp_net_rx_csum(dp, r_vec, rxd, &meta, skb);
 
-- 
2.1.4
