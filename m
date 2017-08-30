From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 07/11] net/mlx5e: Don't override user RSS upon set channels
Date: Thu, 31 Aug 2017 01:21:06 +0300
Message-ID: <20170830222110.15737-8-saeedm@mellanox.com>
References: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Inbar Karmy <inbark@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53254 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751333AbdH3WVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:33 -0400
In-Reply-To: <20170830222110.15737-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inbar Karmy <inbark@mellanox.com>

Currently, increasing the number of combined channels is changing
the RSS spread to use the new created channels.
Prevent the RSS spread change in case the user explicitly declare it,
to avoid overriding user configuration.

Tested:
when RSS default:

# ethtool -L ens8 combined 4
RSS spread will change and point to 4 channels.

# ethtool -X ens8 equal 4
# ethtool -L ens8 combined 6
RSS will not change after increasing the number of the channels.

Fixes: 8bf368620486 ('ethtool: ensure channel counts are within bounds during SCHANNELS')
Signed-off-by: Inbar Karmy <inbark@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 917fade5f5d5..f5594014715b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -641,8 +641,10 @@ int mlx5e_ethtool_set_channels(struct mlx5e_priv *priv,
 
 	new_channels.params = priv->channels.params;
 	new_channels.params.num_channels = count;
-	mlx5e_build_default_indir_rqt(priv->mdev, new_channels.params.indirection_rqt,
-				      MLX5E_INDIR_RQT_SIZE, count);
+	if (!netif_is_rxfh_configured(priv->netdev))
+		mlx5e_build_default_indir_rqt(priv->mdev,
+					      new_channels.params.indirection_rqt,
+					      MLX5E_INDIR_RQT_SIZE, count);
 
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
 		priv->channels.params = new_channels.params;
-- 
2.13.0
