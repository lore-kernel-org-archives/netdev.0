From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/8] net/mlx5e: Priv state flag not rolled-back upon netdev open error
Date: Fri, 25 Sep 2015 10:49:09 +0300
Message-ID: <1443167356-32095-2-git-send-email-ogerlitz@mellanox.com>
References: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, eli@labmailer.mlnx,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39313 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755187AbbIYHtx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 03:49:53 -0400
In-Reply-To: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

The private mlx5 state flag that indicates that the netdev is
opened is set at the beginning of the netdev open flow.
In case an error occured later in the mlx5 netdev open flow, this
flag was not cleared, remaining set although the actual set is
closed.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 59874d6..bb801a9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1367,13 +1367,13 @@ int mlx5e_open_locked(struct net_device *netdev)
 
 	err = mlx5e_set_dev_port_mtu(netdev);
 	if (err)
-		return err;
+		goto err_clear_state_opened_flag;
 
 	err = mlx5e_open_channels(priv);
 	if (err) {
 		netdev_err(netdev, "%s: mlx5e_open_channels failed, %d\n",
 			   __func__, err);
-		return err;
+		goto err_clear_state_opened_flag;
 	}
 
 	mlx5e_update_carrier(priv);
@@ -1382,6 +1382,10 @@ int mlx5e_open_locked(struct net_device *netdev)
 	schedule_delayed_work(&priv->update_stats_work, 0);
 
 	return 0;
+
+err_clear_state_opened_flag:
+	clear_bit(MLX5E_STATE_OPENED, &priv->state);
+	return err;
 }
 
 static int mlx5e_open(struct net_device *netdev)
-- 
2.3.7
