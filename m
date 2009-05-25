From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [net-2.6 PATCH] mlx4_en: Fix a kernel panic when waking tx queue
Date: Mon, 25 May 2009 11:32:42 +0300
Message-ID: <4A1A57AA.1080209@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il> <4A0AB34A.10100@mellanox.co.il> <4A1948D7.8010504@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:35814 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751117AbZEYIbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2009 04:31:49 -0400
In-Reply-To: <4A1948D7.8010504@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a kernel panic when waking the TX queue
from irq context.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_tx.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index ac6fc49..bbb082b 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -326,7 +326,8 @@ void mlx4_en_set_prio_map(struct mlx4_en_priv *priv, u16 *prio_map, u32 ring_num
 	}
 }

-static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
+static void mlx4_en_process_tx_cq(struct net_device *dev,
+				  struct mlx4_en_cq *cq, int poll)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_cq *mcq = &cq->mcq;
@@ -383,7 +384,7 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 	ring->cons += txbbs_skipped;

 	/* Wakeup Tx queue if this ring stopped it */
-	if (unlikely(ring->blocked)) {
+	if (unlikely(ring->blocked) && poll) {
 		if ((u32) (ring->prod - ring->cons) <=
 		     ring->size - HEADROOM - MAX_DESC_TXBBS) {

@@ -411,7 +412,7 @@ void mlx4_en_tx_irq(struct mlx4_cq *mcq)

 	if (!spin_trylock(&ring->comp_lock))
 		return;
-	mlx4_en_process_tx_cq(cq->dev, cq);
+	mlx4_en_process_tx_cq(cq->dev, cq, 0);
 	mod_timer(&cq->timer, jiffies + 1);
 	spin_unlock(&ring->comp_lock);
 }
@@ -430,7 +431,7 @@ void mlx4_en_poll_tx_cq(unsigned long data)
 		mod_timer(&cq->timer, jiffies + MLX4_EN_TX_POLL_TIMEOUT);
 		return;
 	}
-	mlx4_en_process_tx_cq(cq->dev, cq);
+	mlx4_en_process_tx_cq(cq->dev, cq, 1);
 	inflight = (u32) (ring->prod - ring->cons - ring->last_nr_txbb);

 	/* If there are still packets in flight and the timer has not already
@@ -483,7 +484,7 @@ static inline void mlx4_en_xmit_poll(struct mlx4_en_priv *priv, int tx_ind)
 	/* Poll the CQ every mlx4_en_TX_MODER_POLL packets */
 	if ((++ring->poll_cnt & (MLX4_EN_TX_POLL_MODER - 1)) == 0)
 		if (spin_trylock(&ring->comp_lock)) {
-			mlx4_en_process_tx_cq(priv->dev, cq);
+			mlx4_en_process_tx_cq(priv->dev, cq, 1);
 			spin_unlock(&ring->comp_lock);
 		}
 }
-- 
1.6.0



