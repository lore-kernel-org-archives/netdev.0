From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 5/9] net/mlx5e: Fix minimum MTU
Date: Tue, 19 Apr 2016 15:33:38 +0300
Message-ID: <1461069222-27076-6-git-send-email-saeedm@mellanox.com>
References: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48527 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754132AbcDSMfI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 08:35:08 -0400
In-Reply-To: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minimum MTU that can be set in Connectx4 device is 68.

This fixes the case where a user wants to set invalid MTU,
the driver will fail to satisfy this request and the interface
will stay down.

It is better to report an error and continue working with old
mtu.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2fbbc62..93e4ef4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1999,22 +1999,27 @@ static int mlx5e_set_features(struct net_device *netdev,
 	return err;
 }
 
+#define MXL5_HW_MIN_MTU 64
+#define MXL5E_MIN_MTU (MXL5_HW_MIN_MTU + ETH_FCS_LEN)
+
 static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 	bool was_opened;
 	u16 max_mtu;
+	u16 min_mtu;
 	int err = 0;
 
 	mlx5_query_port_max_mtu(mdev, &max_mtu, 1);
 
 	max_mtu = MLX5E_HW2SW_MTU(max_mtu);
+	min_mtu = MLX5E_HW2SW_MTU(MXL5E_MIN_MTU);
 
-	if (new_mtu > max_mtu) {
+	if (new_mtu > max_mtu || new_mtu < min_mtu) {
 		netdev_err(netdev,
-			   "%s: Bad MTU (%d) > (%d) Max\n",
-			   __func__, new_mtu, max_mtu);
+			   "%s: Bad MTU (%d), valid range is: [%d..%d]\n",
+			   __func__, new_mtu, min_mtu, max_mtu);
 		return -EINVAL;
 	}
 
-- 
1.7.1
