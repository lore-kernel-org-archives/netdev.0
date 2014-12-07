From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next] net/mlx4_en: ethtool force speed when asking for autoneg=off
Date: Sun,  7 Dec 2014 10:07:14 +0200
Message-ID: <1417939634-26085-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49040 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752411AbaLGIHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Dec 2014 03:07:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Use cmd->autoneg == AUTONEG_DISABLE as a user hint to force specific speed.
We don't want to rely on ethtool to calculate advertised link modes when
forcing specific speed, a user can request a specific speed and specify
"autoneg off" in ethtool command to give a hint for forcing this speed.

Move en_warn("port reset..") inside the "port reset" block.

Fixes: d48b3ab ("net/mlx4_en: Use PTYS register to set ethtool settings (Speed)")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index c45e06a..3045582 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -771,13 +771,13 @@ static int mlx4_en_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	}
 
 	proto_admin = cpu_to_be32(ptys_adv);
-	if (speed >= 0 && speed != priv->port_state.link_speed)
+	if (speed >= 0 && ((speed != priv->port_state.link_speed) ||
+			   (cmd->autoneg == AUTONEG_DISABLE)))
 		/* If speed was set then speed decides :-) */
 		proto_admin = speed_set_ptys_admin(priv, speed,
 						   ptys_reg.eth_proto_cap);
 
 	proto_admin &= ptys_reg.eth_proto_cap;
-
 	if (proto_admin == ptys_reg.eth_proto_admin)
 		return 0; /* Nothing to change */
 
@@ -798,9 +798,9 @@ static int mlx4_en_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
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
