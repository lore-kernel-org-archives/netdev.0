From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 1/5] net/mlx5e: Use the correct pause values for ethtool advertising
Date: Sun, 14 May 2017 13:43:07 +0300
Message-ID: <20170514104311.2081-2-saeedm@mellanox.com>
References: <20170514104311.2081-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        kernel-team@fb.com, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48620 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751845AbdENKnZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 06:43:25 -0400
In-Reply-To: <20170514104311.2081-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Query the operational pause from firmware (PFCC register) instead of
always passing zeros.

Fixes: 665bc53969d7 ("net/mlx5e: Use new ethtool get/set link ksettings API")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index ce7b09d72ff6..d60e681b443e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -849,6 +849,8 @@ static int mlx5e_get_link_ksettings(struct net_device *netdev,
 	struct mlx5e_priv *priv    = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 	u32 out[MLX5_ST_SZ_DW(ptys_reg)] = {0};
+	u32 rx_pause = 0;
+	u32 tx_pause = 0;
 	u32 eth_proto_cap;
 	u32 eth_proto_admin;
 	u32 eth_proto_lp;
@@ -871,11 +873,13 @@ static int mlx5e_get_link_ksettings(struct net_device *netdev,
 	an_disable_admin = MLX5_GET(ptys_reg, out, an_disable_admin);
 	an_status        = MLX5_GET(ptys_reg, out, an_status);
 
+	mlx5_query_port_pause(mdev, &rx_pause, &tx_pause);
+
 	ethtool_link_ksettings_zero_link_mode(link_ksettings, supported);
 	ethtool_link_ksettings_zero_link_mode(link_ksettings, advertising);
 
 	get_supported(eth_proto_cap, link_ksettings);
-	get_advertising(eth_proto_admin, 0, 0, link_ksettings);
+	get_advertising(eth_proto_admin, tx_pause, rx_pause, link_ksettings);
 	get_speed_duplex(netdev, eth_proto_oper, link_ksettings);
 
 	eth_proto_oper = eth_proto_oper ? eth_proto_oper : eth_proto_cap;
-- 
2.11.0
