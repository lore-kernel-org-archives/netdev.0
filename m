From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 4/5] net/mlx5e: Disable VLAN filter in promiscuous mode
Date: Thu,  8 Oct 2015 15:26:18 +0300
Message-ID: <1444307179-16105-5-git-send-email-ogerlitz@mellanox.com>
References: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57475 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756017AbbJHM1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 08:27:01 -0400
In-Reply-To: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

When the device was set to promiscuous mode, we didn't disable
VLAN filtering, which is wrong behaviour, fix that.

Now when the device is set to promiscuous mode RX packets
sent over any VLAN (or no VLAN tag at all) will be accepted.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
index e71563c..22d603f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
@@ -598,6 +598,8 @@ void mlx5e_enable_vlan_filter(struct mlx5e_priv *priv)
 		return;
 
 	priv->vlan.filter_disabled = false;
+	if (priv->netdev->flags & IFF_PROMISC)
+		return;
 	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID, 0);
 }
 
@@ -607,6 +609,8 @@ void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv)
 		return;
 
 	priv->vlan.filter_disabled = true;
+	if (priv->netdev->flags & IFF_PROMISC)
+		return;
 	mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID, 0);
 }
 
@@ -717,8 +721,12 @@ void mlx5e_set_rx_mode_work(struct work_struct *work)
 	bool enable_broadcast  = !ea->broadcast_enabled &&  broadcast_enabled;
 	bool disable_broadcast =  ea->broadcast_enabled && !broadcast_enabled;
 
-	if (enable_promisc)
+	if (enable_promisc) {
 		mlx5e_add_eth_addr_rule(priv, &ea->promisc, MLX5E_PROMISC);
+		if (!priv->vlan.filter_disabled)
+			mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID,
+					    0);
+	}
 	if (enable_allmulti)
 		mlx5e_add_eth_addr_rule(priv, &ea->allmulti, MLX5E_ALLMULTI);
 	if (enable_broadcast)
@@ -730,8 +738,12 @@ void mlx5e_set_rx_mode_work(struct work_struct *work)
 		mlx5e_del_eth_addr_from_flow_table(priv, &ea->broadcast);
 	if (disable_allmulti)
 		mlx5e_del_eth_addr_from_flow_table(priv, &ea->allmulti);
-	if (disable_promisc)
+	if (disable_promisc) {
+		if (!priv->vlan.filter_disabled)
+			mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID,
+					    0);
 		mlx5e_del_eth_addr_from_flow_table(priv, &ea->promisc);
+	}
 
 	ea->promisc_enabled   = promisc_enabled;
 	ea->allmulti_enabled  = allmulti_enabled;
-- 
2.3.7
