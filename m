From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_en: mlx4_en_netpoll shouldn't call napi_schedule when port is down
Date: Mon, 29 Sep 2014 14:04:55 +0300
Message-ID: <1411988695-30547-1-git-send-email-amirv@mellanox.com>
Cc: Ido Shamay <idos@mellanox.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51595 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751777AbaI2LFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 07:05:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

mlx4_en_netpoll, which is mlx4_en ndo_poll_controller callback,
might be called when port is down, causing a napi_schedule when
napi->poll callback in NULL. mutex_trylock is needed to acquire
the port_state lock, since other threads may grab it and stop
the port while we are in napi scheduling. Using trylock since in atomic
context.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---

Hi Dave,

Please push this commit to -stable

Thanks,
Amir

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index abddcf8..e243f1c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1272,13 +1272,23 @@ out:
 static void mlx4_en_netpoll(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_cq *cq;
 	int i;
 
+	if (!mutex_trylock(&mdev->state_lock))
+		return;
+
+	if (!priv->port_up)
+		goto out;
+
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		cq = priv->rx_cq[i];
 		napi_schedule(&cq->napi);
 	}
+
+out:
+	mutex_unlock(&mdev->state_lock);
 }
 #endif
 
-- 
1.8.3.4
