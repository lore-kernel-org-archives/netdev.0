From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/4] net/mlx4_en: Release TX QP when destroying TX ring
Date: Wed, 24 Jun 2015 18:22:00 +0300
Message-ID: <1435159323-10028-2-git-send-email-ogerlitz@mellanox.com>
References: <1435159323-10028-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56550 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752620AbbFXPW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 11:22:28 -0400
In-Reply-To: <1435159323-10028-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

TX ring QP wasn't released at mlx4_en_destroy_tx_ring. Instead, the code
used the deprecated base_tx_qpn field. Move TX QP release to
mlx4_en_destroy_tx_ring and remove the base_tx_qpn field.

Fixes: ddae0349fdb7 ('net/mlx4: Change QP allocation scheme')
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 4 ----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 1 -
 3 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 77179d7..e0de2fd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1977,10 +1977,6 @@ void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 			mlx4_en_destroy_cq(priv, &priv->rx_cq[i]);
 	}
 
-	if (priv->base_tx_qpn) {
-		mlx4_qp_release_range(priv->mdev->dev, priv->base_tx_qpn, priv->tx_ring_num);
-		priv->base_tx_qpn = 0;
-	}
 }
 
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 7bed3a8..0ab298f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -180,6 +180,7 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 		mlx4_bf_free(mdev->dev, &ring->bf);
 	mlx4_qp_remove(mdev->dev, &ring->qp);
 	mlx4_qp_free(mdev->dev, &ring->qp);
+	mlx4_qp_release_range(priv->mdev->dev, ring->qpn, 1);
 	mlx4_en_unmap_buffer(&ring->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 	kfree(ring->bounce_buf);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index d5f9adb..32134bd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -580,7 +580,6 @@ struct mlx4_en_priv {
 	int vids[128];
 	bool wol;
 	struct device *ddev;
-	int base_tx_qpn;
 	struct hlist_head mac_hash[MLX4_EN_MAC_HASH_SIZE];
 	struct hwtstamp_config hwtstamp_config;
 	u32 counter_index;
-- 
2.3.7
