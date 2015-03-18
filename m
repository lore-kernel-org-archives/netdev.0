From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 3/3] net/mlx4_en: Add tx queue maxrate support
Date: Wed, 18 Mar 2015 14:57:35 +0200
Message-ID: <1426683455-24243-4-git-send-email-ogerlitz@mellanox.com>
References: <1426683455-24243-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38206 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755793AbbCRM5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 08:57:43 -0400
In-Reply-To: <1426683455-24243-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ndo_set_tx_maxrate support.

To support per tx queue maxrate limit, we use the update-qp firmware
command to do run-time rate setting for the qp that serves this tx ring.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Ido Shamay <idos@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   29 ++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index c59ed92..d8dc3f9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2379,6 +2379,33 @@ static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
 }
 #endif
 
+int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 maxrate)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_tx_ring *tx_ring = priv->tx_ring[queue_index];
+	struct mlx4_update_qp_params params;
+	int err;
+
+	if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_QP_RATE_LIMIT))
+		return -EOPNOTSUPP;
+
+	/* rate provided to us in Mbs, check if it fits into 12 bits, if not use Gbs */
+	if (maxrate >> 12) {
+		params.rate_unit = MLX4_QP_RATE_LIMIT_GBS;
+		params.rate_val  = maxrate / 1000;
+	} else if (maxrate) {
+		params.rate_unit = MLX4_QP_RATE_LIMIT_MBS;
+		params.rate_val  = maxrate;
+	} else { /* zero serves to revoke the QP rate-limitation */
+		params.rate_unit = 0;
+		params.rate_val  = 0;
+	}
+
+	err = mlx4_update_qp(priv->mdev->dev, tx_ring->qpn, MLX4_UPDATE_QP_RATE_LIMIT,
+			     &params);
+	return err;
+}
+
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
@@ -2410,6 +2437,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
 #endif
+	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
 };
 
 static const struct net_device_ops mlx4_netdev_ops_master = {
@@ -2444,6 +2472,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
 #endif
+	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
 };
 
 struct mlx4_en_bond {
-- 
1.7.1
