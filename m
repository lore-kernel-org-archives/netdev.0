From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general] [PATCH 2/9] mlx4_en: Removed TX locking when polling
	TX cq
Date: Mon, 22 Dec 2008 12:00:22 +0200
Message-ID: <494F6536.6040107@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org
To: jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

There is no need to synchronize the polling with the transmit
function. The only place to synchronize is when we process
the cq from the transmit function. Also removed spin_lock_irq,
and using spin_trylock, if somebody else is already processing the cq,
no need to wait for it to finish.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_tx.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 8592f8f..1f25821 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -404,14 +404,12 @@ void mlx4_en_tx_irq(struct mlx4_cq *mcq)
 	struct mlx4_en_priv *priv = netdev_priv(cq->dev);
 	struct mlx4_en_tx_ring *ring = &priv->tx_ring[cq->ring];

-	spin_lock_irq(&ring->comp_lock);
 	cq->armed = 0;
+	if (!spin_trylock(&ring->comp_lock))
+		return;
 	mlx4_en_process_tx_cq(cq->dev, cq);
-	if (ring->blocked)
-		mlx4_en_arm_cq(priv, cq);
-	else
-		mod_timer(&cq->timer, jiffies + 1);
-	spin_unlock_irq(&ring->comp_lock);
+	mod_timer(&cq->timer, jiffies + 1);
+	spin_unlock(&ring->comp_lock);
 }


@@ -424,8 +422,10 @@ void mlx4_en_poll_tx_cq(unsigned long data)

 	INC_PERF_COUNTER(priv->pstats.tx_poll);

-	netif_tx_lock(priv->dev);
-	spin_lock_irq(&ring->comp_lock);
+	if (!spin_trylock(&ring->comp_lock)) {
+		mod_timer(&cq->timer, jiffies + MLX4_EN_TX_POLL_TIMEOUT);
+		return;
+	}
 	mlx4_en_process_tx_cq(cq->dev, cq);
 	inflight = (u32) (ring->prod - ring->cons - ring->last_nr_txbb);

@@ -435,8 +435,7 @@ void mlx4_en_poll_tx_cq(unsigned long data)
 	if (inflight && priv->port_up)
 		mod_timer(&cq->timer, jiffies + MLX4_EN_TX_POLL_TIMEOUT);

-	spin_unlock_irq(&ring->comp_lock);
-	netif_tx_unlock(priv->dev);
+	spin_unlock(&ring->comp_lock);
 }

 static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
@@ -479,7 +478,10 @@ static inline void mlx4_en_xmit_poll(struct mlx4_en_priv *priv, int tx_ind)

 	/* Poll the CQ every mlx4_en_TX_MODER_POLL packets */
 	if ((++ring->poll_cnt & (MLX4_EN_TX_POLL_MODER - 1)) == 0)
-		mlx4_en_process_tx_cq(priv->dev, cq);
+		if (spin_trylock(&ring->comp_lock)) {
+			mlx4_en_process_tx_cq(priv->dev, cq);
+			spin_unlock(&ring->comp_lock);
+		}
 }

 static void *get_frag_ptr(struct sk_buff *skb)
-- 
1.5.4
