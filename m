From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v4 net-next 10/13] mlx4: do not access rx_desc from mlx4_en_process_rx_cq()
Date: Wed,  8 Mar 2017 08:17:15 -0800
Message-ID: <20170308161718.2867-11-edumazet@google.com>
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
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35226 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753835AbdCHQRr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:17:47 -0500
Received: by mail-pf0-f181.google.com with SMTP id j5so16555729pfb.2
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:17:46 -0800 (PST)
In-Reply-To: <20170308161718.2867-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of fetching dma address from rx_desc->data[0].addr,
prefer using frags[0].dma + frags[0].page_offset to avoid
a potential cache line miss.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index d3a425fa46b3924411e42a865b3a57aa063f1635..b62fa265890edd0eff50256bdc50fc907dbe8aa2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -528,7 +528,6 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 
 
 static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
-				      struct mlx4_en_rx_desc *rx_desc,
 				      struct mlx4_en_rx_alloc *frags,
 				      unsigned int length)
 {
@@ -703,7 +702,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_cqe *cqe;
 	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
 	struct mlx4_en_rx_alloc *frags;
-	struct mlx4_en_rx_desc *rx_desc;
 	struct bpf_prog *xdp_prog;
 	int doorbell_pending;
 	struct sk_buff *skb;
@@ -738,7 +736,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		    cq->mcq.cons_index & cq->size)) {
 
 		frags = ring->rx_info + (index << priv->log_rx_info);
-		rx_desc = ring->buf + (index << ring->log_stride);
 
 		/*
 		 * make sure we read the CQE after we read the ownership bit
@@ -767,7 +764,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			/* Get pointer to first fragment since we haven't
 			 * skb yet and cast it to ethhdr struct
 			 */
-			dma = be64_to_cpu(rx_desc->data[0].addr);
+			dma = frags[0].dma + frags[0].page_offset;
 			dma_sync_single_for_cpu(priv->ddev, dma, sizeof(*ethh),
 						DMA_FROM_DEVICE);
 			ethh = (struct ethhdr *)(page_address(frags[0].page) +
@@ -806,7 +803,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			void *orig_data;
 			u32 act;
 
-			dma = be64_to_cpu(rx_desc->data[0].addr);
+			dma = frags[0].dma + frags[0].page_offset;
 			dma_sync_single_for_cpu(priv->ddev, dma,
 						priv->frag_info[0].frag_size,
 						DMA_FROM_DEVICE);
@@ -946,7 +943,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		}
 
 		/* GRO not possible, complete processing here */
-		skb = mlx4_en_rx_skb(priv, rx_desc, frags, length);
+		skb = mlx4_en_rx_skb(priv, frags, length);
 		if (unlikely(!skb)) {
 			ring->dropped++;
 			goto next;
-- 
2.12.0.246.ga2ecc84866-goog
