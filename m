From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 12/12] net/mlx5e: Disable netdev after close
Date: Wed, 28 Dec 2016 14:58:42 +0200
Message-ID: <1482929922-32626-13-git-send-email-saeedm@mellanox.com>
References: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32814 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751561AbcL1M66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:58:58 -0500
In-Reply-To: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable netdev should come after it was closed, although no harm of doing it
before -hence the MLX5E_STATE_DESTROYING bit- but it is more natural this way.

Fixes: 26e59d8077a3 ("net/mlx5e: Implement mlx5e interface attach/detach callbacks")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Mohamad Haj Yahia <mohamad@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index cf270f6..1236b27 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3947,10 +3947,6 @@ void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 	const struct mlx5e_profile *profile = priv->profile;
 
 	set_bit(MLX5E_STATE_DESTROYING, &priv->state);
-	if (profile->disable)
-		profile->disable(priv);
-
-	flush_workqueue(priv->wq);
 
 	rtnl_lock();
 	if (netif_running(netdev))
@@ -3958,6 +3954,10 @@ void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 	netif_device_detach(netdev);
 	rtnl_unlock();
 
+	if (profile->disable)
+		profile->disable(priv);
+	flush_workqueue(priv->wq);
+
 	mlx5e_destroy_q_counter(priv);
 	profile->cleanup_rx(priv);
 	mlx5e_close_drop_rq(priv);
-- 
2.7.4
