From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 02/10] net/mlx5e: Optimization for MTU change
Date: Thu, 18 Aug 2016 21:09:03 +0300
Message-ID: <1471543751-24164-3-git-send-email-saeedm@mellanox.com>
References: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41793 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932411AbcHSBnP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:43:15 -0400
In-Reply-To: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Avoid unnecessary interface down/up operations upon an MTU change
when it does not affect the rings configuration.

Fixes: 461017cb006a ("net/mlx5e: Support RX multi-packet WQE (Striding RQ)")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 0fc3a2b..65258b2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2569,6 +2569,7 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 	u16 max_mtu;
 	u16 min_mtu;
 	int err = 0;
+	bool reset;
 
 	mlx5_query_port_max_mtu(mdev, &max_mtu, 1);
 
@@ -2584,14 +2585,18 @@ static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 
 	mutex_lock(&priv->state_lock);
 
+	reset = !priv->params.lro_en &&
+		(priv->params.rq_wq_type !=
+		 MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ);
+
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
-	if (was_opened)
+	if (was_opened && reset)
 		mlx5e_close_locked(netdev);
 
 	netdev->mtu = new_mtu;
 	mlx5e_set_dev_port_mtu(netdev);
 
-	if (was_opened)
+	if (was_opened && reset)
 		err = mlx5e_open_locked(netdev);
 
 	mutex_unlock(&priv->state_lock);
-- 
2.7.4
