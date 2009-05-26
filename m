From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [net-2.6 PATCH V2] mlx4_en: Fix a kernel panic when waking tx queue
Date: Tue, 26 May 2009 09:57:21 +0300
Message-ID: <4A1B92D1.8070907@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il> <4A0AB34A.10100@mellanox.co.il> <4A1948D7.8010504@mellanox.co.il> <4A1A57AA.1080209@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49239 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751347AbZEZG40 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2009 02:56:26 -0400
In-Reply-To: <4A1A57AA.1080209@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the transmit queue gets full we enable interrupts for TX completions
There was a race that we handled the TX queue both from the interrupt context
and from the transmit function. Using "spin_trylock_irq()" ensures this
doesn't happen.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_tx.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index ac6fc49..e5c98a9 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -426,7 +426,7 @@ void mlx4_en_poll_tx_cq(unsigned long data)

 	INC_PERF_COUNTER(priv->pstats.tx_poll);

-	if (!spin_trylock(&ring->comp_lock)) {
+	if (!spin_trylock_irq(&ring->comp_lock)) {
 		mod_timer(&cq->timer, jiffies + MLX4_EN_TX_POLL_TIMEOUT);
 		return;
 	}
@@ -439,7 +439,7 @@ void mlx4_en_poll_tx_cq(unsigned long data)
 	if (inflight && priv->port_up)
 		mod_timer(&cq->timer, jiffies + MLX4_EN_TX_POLL_TIMEOUT);

-	spin_unlock(&ring->comp_lock);
+	spin_unlock_irq(&ring->comp_lock);
 }

 static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
@@ -482,9 +482,9 @@ static inline void mlx4_en_xmit_poll(struct mlx4_en_priv *priv, int tx_ind)

 	/* Poll the CQ every mlx4_en_TX_MODER_POLL packets */
 	if ((++ring->poll_cnt & (MLX4_EN_TX_POLL_MODER - 1)) == 0)
-		if (spin_trylock(&ring->comp_lock)) {
+		if (spin_trylock_irq(&ring->comp_lock)) {
 			mlx4_en_process_tx_cq(priv->dev, cq);
-			spin_unlock(&ring->comp_lock);
+			spin_unlock_irq(&ring->comp_lock);
 		}
 }

-- 
1.6.0


