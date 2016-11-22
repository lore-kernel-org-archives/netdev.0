From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Free netdev resources under state lock
Date: Tue, 22 Nov 2016 16:20:39 +0200
Message-ID: <1479824439-27353-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Sagi Grimberg <sagi@grimberg.me>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52221 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756030AbcKVOVR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 09:21:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure mlx4_en_free_resources is called under the netdev state lock.
This is needed since RCU dereference of XDP prog should be protected.

Fixes: 326fe02d1ed6 ("net/mlx4_en: protect ring->xdp_prog with rcu_read_lock")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reported-by: Sagi Grimberg <sagi@grimberg.me>
CC: Brenden Blanco <bblanco@plumgrid.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 3a47e83d3e07..a60f635da78b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -129,6 +129,9 @@ static enum mlx4_net_trans_rule_id mlx4_ip_proto_to_trans_rule_id(u8 ip_proto)
 	}
 };
 
+/* Must not acquire state_lock, as its corresponding work_sync
+ * is done under it.
+ */
 static void mlx4_en_filter_work(struct work_struct *work)
 {
 	struct mlx4_en_filter *filter = container_of(work,
@@ -2189,13 +2192,13 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	mutex_lock(&mdev->state_lock);
 	mdev->pndev[priv->port] = NULL;
 	mdev->upper[priv->port] = NULL;
-	mutex_unlock(&mdev->state_lock);
 
 #ifdef CONFIG_RFS_ACCEL
 	mlx4_en_cleanup_filters(priv);
 #endif
 
 	mlx4_en_free_resources(priv);
+	mutex_unlock(&mdev->state_lock);
 
 	kfree(priv->tx_ring);
 	kfree(priv->tx_cq);
-- 
1.8.3.1
