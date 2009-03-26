From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: PATCH 4/6] mlx4_en: Shift completion vector index between ports
Date: Thu, 26 Mar 2009 15:57:26 +0200
Message-ID: <49CB89C6.4060507@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:53315 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753037AbZCZN63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 09:58:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For both ports UDP traffic is steered to RX ring 0.
If both the ports attached RX ring 0 to the same completion
vector, all UDP traffic for both ports will be handled by the
same core. Making the shift would prevent this situation.
Dual port UDP Bandwidth was increased by ~70%.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_cq.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_cq.c b/drivers/net/mlx4/en_cq.c
index 91f50de..450cf44 100644
--- a/drivers/net/mlx4/en_cq.c
+++ b/drivers/net/mlx4/en_cq.c
@@ -53,7 +53,8 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 	cq->size = entries;
 	if (mode == RX) {
 		cq->buf_size = cq->size * sizeof(struct mlx4_cqe);
-		cq->vector   = ring % mdev->dev->caps.num_comp_vectors;
+		cq->vector   = (ring + priv->port) %
+				mdev->dev->caps.num_comp_vectors;
 	} else {
 		cq->buf_size = sizeof(struct mlx4_cqe);
 		cq->vector   = 0;
-- 
1.6.1.3

