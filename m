From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Remove selftest TX queues empty condition
Date: Sun,  1 Dec 2013 14:19:34 +0200
Message-ID: <1385900374-27479-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46797 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751694Ab3LAMTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Dec 2013 07:19:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Remove waiting for TX queues to become empty during selftest.
This check is not necessary for any purpose, and might put
the driver into an infinite loop.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index 4062669..c11d063 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -140,7 +140,6 @@ void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
-	struct mlx4_en_tx_ring *tx_ring;
 	int i, carrier_ok;
 
 	memset(buf, 0, sizeof(u64) * MLX4_EN_NUM_SELF_TEST);
@@ -150,16 +149,10 @@ void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf)
 		carrier_ok = netif_carrier_ok(dev);
 
 		netif_carrier_off(dev);
-retry_tx:
 		/* Wait until all tx queues are empty.
 		 * there should not be any additional incoming traffic
 		 * since we turned the carrier off */
 		msleep(200);
-		for (i = 0; i < priv->tx_ring_num && carrier_ok; i++) {
-			tx_ring = priv->tx_ring[i];
-			if (tx_ring->prod != (tx_ring->cons + tx_ring->last_nr_txbb))
-				goto retry_tx;
-		}
 
 		if (priv->mdev->dev->caps.flags &
 					MLX4_DEV_CAP_FLAG_UC_LOOPBACK) {
-- 
1.8.3.4
