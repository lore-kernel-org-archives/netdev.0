From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net/mlx4_en: remove napi_hash_del() call
Date: Wed, 16 Nov 2016 05:49:22 -0800
Message-ID: <1479304162.8455.163.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33938 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752377AbcKPNtZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 08:49:25 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so14430933pgc.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 05:49:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

There is no need calling napi_hash_del()+synchronize_rcu() before
calling netif_napi_del()

netif_napi_del() does this already.

Using napi_hash_del() in a driver is useful only when dealing with
a batch of NAPI structures, so that a single synchronize_rcu() can
be used. mlx4_en_deactivate_cq() is deactivating a single NAPI.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 03f05c4d1f9897d851c4f36d1f0e37ad3398e76c..09dd3776db7632ae8818c9638507705176233ea4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -185,10 +185,6 @@ void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq)
 void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 {
 	napi_disable(&cq->napi);
-	if (cq->type == RX) {
-		napi_hash_del(&cq->napi);
-		synchronize_rcu();
-	}
 	netif_napi_del(&cq->napi);
 
 	mlx4_cq_free(priv->mdev->dev, &cq->mcq);
