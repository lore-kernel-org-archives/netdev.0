From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 08/11] net/mlx4_en: Use ethtool cmd->autoneg as a hint for ethtool set settings
Date: Tue, 27 Jan 2015 15:58:06 +0200
Message-ID: <1422367089-13419-9-git-send-email-amirv@mellanox.com>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49249 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757611AbbA0N7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 08:59:20 -0500
In-Reply-To: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Use cmd->autoneg as a user hint to decide what to set in ethtool set settings callback.
When cmd->autoneg == AUTONEG_ENABLE set according to ethtool->advertise otherwise,
set according to ethtool->speed.

Usage:
	- ethtool -s eth<x> speed 56000 autoneg off
	- ethtool -s eth<x> advertise 0x800000 autoneg on

While we're here:
	- Move proto_admin masking outcome check to be adjacent to the operation.
	- Move en_warn("port reset..") print to "port reset" block.

Fixes: 312df74 ("net/mlx4_en: mlx4_en_set_settings() always fails when autoneg is set")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 569eda9..a7b58ba 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -770,22 +770,20 @@ static int mlx4_en_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return 0;
 	}
 
-	proto_admin = cpu_to_be32(ptys_adv);
-	if (speed >= 0 && speed != priv->port_state.link_speed)
-		/* If speed was set then speed decides :-) */
-		proto_admin = speed_set_ptys_admin(priv, speed,
-						   ptys_reg.eth_proto_cap);
+	proto_admin = cmd->autoneg == AUTONEG_ENABLE ?
+		cpu_to_be32(ptys_adv) :
+		speed_set_ptys_admin(priv, speed,
+				     ptys_reg.eth_proto_cap);
 
 	proto_admin &= ptys_reg.eth_proto_cap;
-
-	if (proto_admin == ptys_reg.eth_proto_admin)
-		return 0; /* Nothing to change */
-
 	if (!proto_admin) {
 		en_warn(priv, "Not supported link mode(s) requested, check supported link modes.\n");
 		return -EINVAL; /* nothing to change due to bad input */
 	}
 
+	if (proto_admin == ptys_reg.eth_proto_admin)
+		return 0; /* Nothing to change */
+
 	en_dbg(DRV, priv, "mlx4_ACCESS_PTYS_REG SET: ptys_reg.eth_proto_admin = 0x%x\n",
 	       be32_to_cpu(proto_admin));
 
@@ -798,9 +796,9 @@ static int mlx4_en_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return ret;
 	}
 
-	en_warn(priv, "Port link mode changed, restarting port...\n");
 	mutex_lock(&priv->mdev->state_lock);
 	if (priv->port_up) {
+		en_warn(priv, "Port link mode changed, restarting port...\n");
 		mlx4_en_stop_port(dev, 1);
 		if (mlx4_en_start_port(dev))
 			en_err(priv, "Failed restarting port %d\n", priv->port);
-- 
1.9.3
