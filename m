From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 06/11] RFC: mlx5: RX bulking or bundling of packets
 before calling network stack
Date: Tue, 02 Feb 2016 22:13:09 +0100
Message-ID: <20160202211228.16315.9691.stgit@firesoul>
References: <20160202211051.16315.51808.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, tom@herbertland.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34919 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932948AbcBBVNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 16:13:11 -0500
In-Reply-To: <20160202211051.16315.51808.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several techniques/concepts combined in this optimization.
It is both a data-cache and instruction-cache optimization.

First of all, this is primarily about delaying touching
packet-data, which happend in eth_type_trans, until the prefetch
have had time to fetch.  Thus, hopefully avoiding a cache-miss on
packet data.

Secondly, the instruction-cache optimization is about, not
calling the network stack for every packet, which is pulled out
of the RX ring.  Calling the full stack likely removes/flushes
the instruction cache every time.

Thus, have two loops, one loop pulling out packet from the RX
ring and starting the prefetching, and the second loop calling
eth_type_trans() and invoking the stack via napi_gro_receive().

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>


Notes:
This is the patch that gave a speed up of 6.2Mpps to 12Mpps, when
trying to measure lowest RX level, by dropping the packets in the
driver itself (marked drop point as comment).

For now, the ring is emptied upto the budget.  I don't know if it
would be better to chunk it up more?

In the future, I imagine the we can call the stack with the full
SKB-list instead of this local loop.  But then it would look a
bit strange, to call eth_type_trans() as the only function...
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |   23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index e923f4adc0f8..5d96d6682db0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -214,8 +214,6 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 
 	mlx5e_handle_csum(netdev, cqe, rq, skb);
 
-	skb->protocol = eth_type_trans(skb, netdev);
-
 	skb_record_rx_queue(skb, rq->ix);
 
 	if (likely(netdev->features & NETIF_F_RXHASH))
@@ -229,8 +227,15 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
+	struct sk_buff_head rx_skb_list;
+	struct sk_buff *rx_skb;
 	int work_done;
 
+	/* Using SKB list infrastructure, even-though some instructions
+	 * could be saved by open-coding it on skb->next directly.
+	 */
+	__skb_queue_head_init(&rx_skb_list);
+
 	/* avoid accessing cq (dma coherent memory) if not needed */
 	if (!test_and_clear_bit(MLX5E_CQ_HAS_CQES, &cq->flags))
 		return 0;
@@ -252,7 +257,6 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 		wqe_counter    = be16_to_cpu(wqe_counter_be);
 		wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
 		skb            = rq->skb[wqe_counter];
-		prefetch(skb->data);
 		rq->skb[wqe_counter] = NULL;
 
 		dma_unmap_single(rq->pdev,
@@ -265,16 +269,27 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 			dev_kfree_skb(skb);
 			goto wq_ll_pop;
 		}
+		prefetch(skb->data);
 
 		mlx5e_build_rx_skb(cqe, rq, skb);
 		rq->stats.packets++;
-		napi_gro_receive(cq->napi, skb);
+		__skb_queue_tail(&rx_skb_list, skb);
 
 wq_ll_pop:
 		mlx5_wq_ll_pop(&rq->wq, wqe_counter_be,
 			       &wqe->next.next_wqe_index);
 	}
 
+	while ((rx_skb = __skb_dequeue(&rx_skb_list)) != NULL) {
+		rx_skb->protocol = eth_type_trans(rx_skb, rq->netdev);
+		napi_gro_receive(cq->napi, rx_skb);
+
+		/* NOT FOR UPSTREAM INCLUSION:
+		 * How I did isolated testing of driver RX, I here called:
+		 *  napi_consume_skb(rx_skb, budget);
+		 */
+	}
+
 	mlx5_cqwq_update_db_record(&cq->wq);
 
 	/* ensure cq space is freed before enabling more cqes */
