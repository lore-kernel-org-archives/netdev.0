From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH RFC] mlx4: RX prefetch loop
Date: Fri, 08 Jul 2016 18:02:20 +0200
Message-ID: <20160708160135.27507.77711.stgit@firesoul>
References: <20160708172024.4a849b7a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, daniel@iogearbox.net, tom@herbertland.com,
	bblanco@plumgrid.com, Jesper Dangaard Brouer <brouer@redhat.com>,
	john.fastabend@gmail.com, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, rana.shahot@gmail.com, tgraf@suug.ch,
	"David S. Miller" <davem@davemloft.net>, as754m@att.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754881AbcGHQCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 12:02:23 -0400
In-Reply-To: <20160708172024.4a849b7a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is about prefetching without being opportunistic.
The idea is only to start prefetching on packets that are marked as
ready/completed in the RX ring.

This is acheived by splitting the napi_poll call mlx4_en_process_rx_cq()
loop into two.  The first loop extract completed CQEs and start
prefetching on data and RX descriptors. The second loop process the
real packets.

Details: The batching of CQEs are limited to 8 in-order to avoid
stressing the LFB (Line Fill Buffer) and cache usage.

I've left some opportunities for prefetching CQE descriptors.


The performance improvements on my platform are huge, as I tested this
on a CPU without DDIO.  The performance for XDP is the same as with
Brendens prefetch hack.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |   70 +++++++++++++++++++++++++---
 1 file changed, 62 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 41c76fe00a7f..c5efe03e31ce 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -782,7 +782,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	int doorbell_pending;
 	struct sk_buff *skb;
 	int tx_index;
-	int index;
+	int index, saved_index, i;
 	int nr;
 	unsigned int length;
 	int polled = 0;
@@ -790,6 +790,10 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	int factor = priv->cqe_factor;
 	u64 timestamp;
 	bool l2_tunnel;
+#define PREFETCH_BATCH 8
+	struct mlx4_cqe *cqe_array[PREFETCH_BATCH];
+	int cqe_idx;
+	bool cqe_more;
 
 	if (!priv->port_up)
 		return 0;
@@ -801,24 +805,75 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	doorbell_pending = 0;
 	tx_index = (priv->tx_ring_num - priv->rsv_tx_rings) + cq->ring;
 
+next_prefetch_batch:
+	cqe_idx = 0;
+	cqe_more = false;
+
 	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
 	 * descriptor offset can be deduced from the CQE index instead of
 	 * reading 'cqe->index' */
 	index = cq->mcq.cons_index & ring->size_mask;
+	saved_index = index;
 	cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
 
-	/* Process all completed CQEs */
+	/* Extract and prefetch completed CQEs */
 	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
 		    cq->mcq.cons_index & cq->size)) {
+		void *data;
 
 		frags = ring->rx_info + (index << priv->log_rx_info);
 		rx_desc = ring->buf + (index << ring->log_stride);
+		prefetch(rx_desc);
 
 		/*
 		 * make sure we read the CQE after we read the ownership bit
 		 */
 		dma_rmb();
 
+		cqe_array[cqe_idx++] = cqe;
+
+		/* Base error handling here, free handled in next loop */
+		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
+			     MLX4_CQE_OPCODE_ERROR))
+			goto skip;
+
+		data = page_address(frags[0].page) + frags[0].page_offset;
+		prefetch(data);
+	skip:
+		++cq->mcq.cons_index;
+		index = (cq->mcq.cons_index) & ring->size_mask;
+		cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
+		/* likely too slow prefetching CQE here ... do look-a-head ? */
+		//prefetch(cqe + priv->cqe_size * 3);
+
+		if (++polled == budget) {
+			cqe_more = false;
+			break;
+		}
+		if (cqe_idx == PREFETCH_BATCH) {
+			cqe_more = true;
+			// IDEA: Opportunistic prefetch CQEs for next_prefetch_batch?
+			//for (i = 0; i < PREFETCH_BATCH; i++) {
+			//	prefetch(cqe + priv->cqe_size * i);
+			//}
+			break;
+		}
+	}
+	/* Hint: The cqe_idx will be number of packets, it can be used
+	 * for bulk allocating SKBs
+	 */
+
+	/* Now, index function as index for rx_desc */
+	index = saved_index;
+
+	/* Process completed CQEs in cqe_array */
+	for (i = 0; i < cqe_idx; i++) {
+
+		cqe = cqe_array[i];
+
+		frags = ring->rx_info + (index << priv->log_rx_info);
+		rx_desc = ring->buf + (index << ring->log_stride);
+
 		/* Drop packet on bad receive or bad checksum */
 		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
 						MLX4_CQE_OPCODE_ERROR)) {
@@ -1065,14 +1120,13 @@ next:
 			mlx4_en_free_frag(priv, frags, nr);
 
 consumed:
-		++cq->mcq.cons_index;
-		index = (cq->mcq.cons_index) & ring->size_mask;
-		cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
-		if (++polled == budget)
-			goto out;
+		++index;
+		index = index & ring->size_mask;
 	}
+	/* Check for more completed CQEs */
+	if (cqe_more)
+		goto next_prefetch_batch;
 
-out:
 	if (doorbell_pending)
 		mlx4_en_xmit_doorbell(priv->tx_ring[tx_index]);
 
