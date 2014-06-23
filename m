From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net 3/3] net/mlx4_en: IRQ affinity hint is not cleared on port down
Date: Mon, 23 Jun 2014 17:41:58 +0300
Message-ID: <1403534518-20898-4-git-send-email-amirv@mellanox.com>
References: <1403534518-20898-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:36866 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754210AbaFWOmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 10:42:11 -0400
In-Reply-To: <1403534518-20898-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to free affinity_mask at mlx4_en_deactivate_cq() and not at
mlx4_en_destroy_cq() - since affinity_mask might be free'd while still
being used by procfs.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 1213cc7..14c0004 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -191,8 +191,6 @@ void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq)
 	mlx4_en_unmap_buffer(&cq->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
 	if (priv->mdev->dev->caps.comp_pool && cq->vector) {
-		if (!cq->is_tx)
-			irq_set_affinity_hint(cq->mcq.irq, NULL);
 		mlx4_release_eq(priv->mdev->dev, cq->vector);
 	}
 	cq->vector = 0;
@@ -208,6 +206,7 @@ void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 	if (!cq->is_tx) {
 		napi_hash_del(&cq->napi);
 		synchronize_rcu();
+		irq_set_affinity_hint(cq->mcq.irq, NULL);
 	}
 	netif_napi_del(&cq->napi);
 
-- 
1.8.3.4
