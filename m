From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v4 net-next 11/13] mlx4: factorize page_address() calls
Date: Wed,  8 Mar 2017 08:17:16 -0800
Message-ID: <20170308161718.2867-12-edumazet@google.com>
References: <20170308161718.2867-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35235 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753058AbdCHQRy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:17:54 -0500
Received: by mail-pf0-f173.google.com with SMTP id j5so16556111pfb.2
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:17:48 -0800 (PST)
In-Reply-To: <20170308161718.2867-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to compute the frame virtual address at different points.
Do it once.

Following patch will use the new va address for validate_loopback()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b62fa265890edd0eff50256bdc50fc907dbe8aa2..b5aa3f986508f0a5a89a40e18f8db99767068fef 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -734,9 +734,10 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	/* Process all completed CQEs */
 	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
 		    cq->mcq.cons_index & cq->size)) {
+		void *va;
 
 		frags = ring->rx_info + (index << priv->log_rx_info);
-
+		va = page_address(frags[0].page) + frags[0].page_offset;
 		/*
 		 * make sure we read the CQE after we read the ownership bit
 		 */
@@ -759,7 +760,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		 * and not performing the selftest or flb disabled
 		 */
 		if (priv->flags & MLX4_EN_FLAG_RX_FILTER_NEEDED) {
-			struct ethhdr *ethh;
+			const struct ethhdr *ethh = va;
 			dma_addr_t dma;
 			/* Get pointer to first fragment since we haven't
 			 * skb yet and cast it to ethhdr struct
@@ -767,8 +768,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			dma = frags[0].dma + frags[0].page_offset;
 			dma_sync_single_for_cpu(priv->ddev, dma, sizeof(*ethh),
 						DMA_FROM_DEVICE);
-			ethh = (struct ethhdr *)(page_address(frags[0].page) +
-						 frags[0].page_offset);
 
 			if (is_multicast_ether_addr(ethh->h_dest)) {
 				struct mlx4_mac_entry *entry;
@@ -808,8 +807,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 						priv->frag_info[0].frag_size,
 						DMA_FROM_DEVICE);
 
-			xdp.data_hard_start = page_address(frags[0].page);
-			xdp.data = xdp.data_hard_start + frags[0].page_offset;
+			xdp.data_hard_start = va - frags[0].page_offset;
+			xdp.data = va;
 			xdp.data_end = xdp.data + length;
 			orig_data = xdp.data;
 
@@ -819,6 +818,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				length = xdp.data_end - xdp.data;
 				frags[0].page_offset = xdp.data -
 					xdp.data_hard_start;
+				va = xdp.data;
 			}
 
 			switch (act) {
@@ -891,7 +891,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				goto next;
 
 			if (ip_summed == CHECKSUM_COMPLETE) {
-				void *va = skb_frag_address(skb_shinfo(gro_skb)->frags);
 				if (check_csum(cqe, gro_skb, va,
 					       dev->features)) {
 					ip_summed = CHECKSUM_NONE;
@@ -955,7 +954,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		}
 
 		if (ip_summed == CHECKSUM_COMPLETE) {
-			if (check_csum(cqe, skb, skb->data, dev->features)) {
+			if (check_csum(cqe, skb, va, dev->features)) {
 				ip_summed = CHECKSUM_NONE;
 				ring->csum_complete--;
 				ring->csum_none++;
-- 
2.12.0.246.ga2ecc84866-goog
