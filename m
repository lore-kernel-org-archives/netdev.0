From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH for-net] net/mlx4_en: Check device state when setting coalescing
Date: Thu, 12 Sep 2013 18:11:20 +0300
Message-ID: <1378998680-7546-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Gideon Naim <gideonn@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38125 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754281Ab3ILPLj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 11:11:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

When the device is down, CQs are freed. We must check the device state
to avoid issuing firmware commands on non existing CQs.

CC: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index a28cd80..0c75098 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -53,9 +53,11 @@ static int mlx4_en_moderation_update(struct mlx4_en_priv *priv)
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		priv->tx_cq[i].moder_cnt = priv->tx_frames;
 		priv->tx_cq[i].moder_time = priv->tx_usecs;
-		err = mlx4_en_set_cq_moder(priv, &priv->tx_cq[i]);
-		if (err)
-			return err;
+		if (priv->port_up) {
+			err = mlx4_en_set_cq_moder(priv, &priv->tx_cq[i]);
+			if (err)
+				return err;
+		}
 	}
 
 	if (priv->adaptive_rx_coal)
@@ -65,9 +67,11 @@ static int mlx4_en_moderation_update(struct mlx4_en_priv *priv)
 		priv->rx_cq[i].moder_cnt = priv->rx_frames;
 		priv->rx_cq[i].moder_time = priv->rx_usecs;
 		priv->last_moder_time[i] = MLX4_EN_AUTO_CONF;
-		err = mlx4_en_set_cq_moder(priv, &priv->rx_cq[i]);
-		if (err)
-			return err;
+		if (priv->port_up) {
+			err = mlx4_en_set_cq_moder(priv, &priv->rx_cq[i]);
+			if (err)
+				return err;
+		}
 	}
 
 	return err;
-- 
1.8.3.4
