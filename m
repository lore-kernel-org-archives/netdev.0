From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 02/14] mlx4: mlx4_en_low_latency_recv() called with BH disabled
Date: Wed, 18 Nov 2015 06:30:51 -0800
Message-ID: <1447857063-618-3-git-send-email-edumazet@google.com>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35566 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932733AbbKRObS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:31:18 -0500
Received: by pacej9 with SMTP id ej9so46595896pac.2
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 06:31:16 -0800 (PST)
In-Reply-To: <1447857063-618-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx4_en_low_latency_recv() is called with BH disabled,
as other ndo_busy_poll() methods.

No need for spin_lock_bh()/spin_unlock_bh()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index c41f15102ae0..965c8f016ac4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -660,11 +660,12 @@ static inline bool mlx4_en_cq_unlock_napi(struct mlx4_en_cq *cq)
 	return rc;
 }
 
-/* called from mlx4_en_low_latency_poll() */
+/* called from mlx4_en_low_latency_recv(), BH are disabled */
 static inline bool mlx4_en_cq_lock_poll(struct mlx4_en_cq *cq)
 {
 	int rc = true;
-	spin_lock_bh(&cq->poll_lock);
+
+	spin_lock(&cq->poll_lock);
 	if ((cq->state & MLX4_CQ_LOCKED)) {
 		struct net_device *dev = cq->dev;
 		struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -676,7 +677,7 @@ static inline bool mlx4_en_cq_lock_poll(struct mlx4_en_cq *cq)
 	} else
 		/* preserve yield marks */
 		cq->state |= MLX4_EN_CQ_STATE_POLL;
-	spin_unlock_bh(&cq->poll_lock);
+	spin_unlock(&cq->poll_lock);
 	return rc;
 }
 
@@ -684,13 +685,14 @@ static inline bool mlx4_en_cq_lock_poll(struct mlx4_en_cq *cq)
 static inline bool mlx4_en_cq_unlock_poll(struct mlx4_en_cq *cq)
 {
 	int rc = false;
-	spin_lock_bh(&cq->poll_lock);
+
+	spin_lock(&cq->poll_lock);
 	WARN_ON(cq->state & (MLX4_EN_CQ_STATE_NAPI));
 
 	if (cq->state & MLX4_EN_CQ_STATE_POLL_YIELD)
 		rc = true;
 	cq->state = MLX4_EN_CQ_STATE_IDLE;
-	spin_unlock_bh(&cq->poll_lock);
+	spin_unlock(&cq->poll_lock);
 	return rc;
 }
 
-- 
2.6.0.rc2.230.g3dd15c0
