From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 09/10] net/mlx4_en: Add NAPI support for transmit side
Date: Thu, 19 Dec 2013 21:20:17 +0200
Message-ID: <1387480818-3932-10-git-send-email-amirv@mellanox.com>
References: <1387480818-3932-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37333 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755598Ab3LSTUj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 14:20:39 -0500
In-Reply-To: <1387480818-3932-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Add NAPI for TX side,
implement its support and provide NAPI callback.


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c   | 12 ++++++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   | 39 +++++++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  1 +
 3 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 3a098cc..70e9532 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -161,12 +161,16 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	cq->mcq.comp  = cq->is_tx ? mlx4_en_tx_irq : mlx4_en_rx_irq;
 	cq->mcq.event = mlx4_en_cq_event;
 
-	if (!cq->is_tx) {
+	if (cq->is_tx) {
+		netif_napi_add(cq->dev, &cq->napi, mlx4_en_poll_tx_cq,
+			       NAPI_POLL_WEIGHT);
+	} else {
 		netif_napi_add(cq->dev, &cq->napi, mlx4_en_poll_rx_cq, 64);
 		napi_hash_add(&cq->napi);
-		napi_enable(&cq->napi);
 	}
 
+	napi_enable(&cq->napi);
+
 	return 0;
 }
 
@@ -188,12 +192,12 @@ void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq)
 
 void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 {
+	napi_disable(&cq->napi);
 	if (!cq->is_tx) {
-		napi_disable(&cq->napi);
 		napi_hash_del(&cq->napi);
 		synchronize_rcu();
-		netif_napi_del(&cq->napi);
 	}
+	netif_napi_del(&cq->napi);
 
 	mlx4_cq_free(priv->mdev->dev, &cq->mcq);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 5e22d7d..e3adceb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -324,7 +324,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 			}
 		}
 	}
-	dev_kfree_skb_any(skb);
+	dev_kfree_skb(skb);
 	return tx_info->nr_txbb;
 }
 
@@ -361,7 +361,9 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 	return cnt;
 }
 
-static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
+static int mlx4_en_process_tx_cq(struct net_device *dev,
+				 struct mlx4_en_cq *cq,
+				 int budget)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_cq *mcq = &cq->mcq;
@@ -379,9 +381,10 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 	u32 bytes = 0;
 	int factor = priv->cqe_factor;
 	u64 timestamp = 0;
+	int done = 0;
 
 	if (!priv->port_up)
-		return;
+		return 0;
 
 	index = cons_index & size_mask;
 	cqe = &buf[(index << factor) + factor];
@@ -390,7 +393,7 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 
 	/* Process all completed CQEs */
 	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
-			cons_index & size)) {
+			cons_index & size) && (done < budget)) {
 		/*
 		 * make sure we read the CQE after we read the
 		 * ownership bit
@@ -428,7 +431,7 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 			txbbs_stamp = txbbs_skipped;
 			packets++;
 			bytes += ring->tx_info[ring_index].nr_bytes;
-		} while (ring_index != new_index);
+		} while ((++done < budget) && (ring_index != new_index));
 
 		++cons_index;
 		index = cons_index & size_mask;
@@ -454,6 +457,7 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 		netif_tx_wake_queue(ring->tx_queue);
 		priv->port_stats.wake_queue++;
 	}
+	return done;
 }
 
 void mlx4_en_tx_irq(struct mlx4_cq *mcq)
@@ -461,10 +465,31 @@ void mlx4_en_tx_irq(struct mlx4_cq *mcq)
 	struct mlx4_en_cq *cq = container_of(mcq, struct mlx4_en_cq, mcq);
 	struct mlx4_en_priv *priv = netdev_priv(cq->dev);
 
-	mlx4_en_process_tx_cq(cq->dev, cq);
-	mlx4_en_arm_cq(priv, cq);
+	if (priv->port_up)
+		napi_schedule(&cq->napi);
+	else
+		mlx4_en_arm_cq(priv, cq);
 }
 
+/* TX CQ polling - called by NAPI */
+int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget)
+{
+	struct mlx4_en_cq *cq = container_of(napi, struct mlx4_en_cq, napi);
+	struct net_device *dev = cq->dev;
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int done;
+
+	done = mlx4_en_process_tx_cq(dev, cq, budget);
+
+	/* If we used up all the quota - we're probably not done yet... */
+	if (done < budget) {
+		/* Done for now */
+		napi_complete(napi);
+		mlx4_en_arm_cq(priv, cq);
+		return done;
+	}
+	return budget;
+}
 
 static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
 						      struct mlx4_en_tx_ring *ring,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 202d8e5..123714c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -744,6 +744,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev,
 			  struct mlx4_en_cq *cq,
 			  int budget);
 int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget);
+int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget);
 void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 		int is_tx, int rss, int qpn, int cqn, int user_prio,
 		struct mlx4_qp_context *context);
-- 
1.8.3.4
