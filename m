From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 2/3] mlx4: use napi_consume_skb API to get bulk
 free operations
Date: Thu, 10 Mar 2016 13:15:42 +0100
Message-ID: <20160310121542.3680.84170.stgit@firesoul>
References: <20160310121414.3680.45727.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	gerlitz.or@gmail.com
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59339 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932091AbcCJMPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 07:15:49 -0500
In-Reply-To: <20160310121414.3680.45727.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bulk free of SKBs happen transparently by the API call napi_consume_skb().
The napi budget parameter is usually needed by napi_consume_skb()
to detect if called from netpoll.  In this patch it have an extra meaning.

For mlx4 driver, the mlx4_en_stop_port() call is done outside
NAPI/softirq context, and cleanup the entire TX ring via
mlx4_en_free_tx_buf().  The code mlx4_en_free_tx_desc() for
freeing SKBs are shared with NAPI calls.

To handle this shared use the zero budget indication is reused,
and handled appropiately in napi_consume_skb(). To reflect this,
variable is called napi_mode for the function call that needed
this distinction.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index e0946ab22010..1b41feafce9e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -276,7 +276,8 @@ static void mlx4_en_stamp_wqe(struct mlx4_en_priv *priv,
 
 static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 				struct mlx4_en_tx_ring *ring,
-				int index, u8 owner, u64 timestamp)
+				int index, u8 owner, u64 timestamp,
+				int napi_mode)
 {
 	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
 	struct mlx4_en_tx_desc *tx_desc = ring->buf + index * TXBB_SIZE;
@@ -347,7 +348,8 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 			}
 		}
 	}
-	dev_consume_skb_any(skb);
+	napi_consume_skb(skb, napi_mode);
+
 	return tx_info->nr_txbb;
 }
 
@@ -371,7 +373,9 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 	while (ring->cons != ring->prod) {
 		ring->last_nr_txbb = mlx4_en_free_tx_desc(priv, ring,
 						ring->cons & ring->size_mask,
-						!!(ring->cons & ring->size), 0);
+						!!(ring->cons & ring->size), 0,
+						0 /* none-NAPI caller */
+			);
 		ring->cons += ring->last_nr_txbb;
 		cnt++;
 	}
@@ -385,7 +389,7 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 }
 
 static bool mlx4_en_process_tx_cq(struct net_device *dev,
-				 struct mlx4_en_cq *cq)
+				  struct mlx4_en_cq *cq, int napi_budget)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_cq *mcq = &cq->mcq;
@@ -451,7 +455,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 			last_nr_txbb = mlx4_en_free_tx_desc(
 					priv, ring, ring_index,
 					!!((ring_cons + txbbs_skipped) &
-					ring->size), timestamp);
+					ring->size), timestamp, napi_budget);
 
 			mlx4_en_stamp_wqe(priv, ring, stamp_index,
 					  !!((ring_cons + txbbs_stamp) &
@@ -511,7 +515,7 @@ int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int clean_complete;
 
-	clean_complete = mlx4_en_process_tx_cq(dev, cq);
+	clean_complete = mlx4_en_process_tx_cq(dev, cq, budget);
 	if (!clean_complete)
 		return budget;
 
