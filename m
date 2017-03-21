From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 3/8] net/mlx5: E-Switch, Don't allow changing inline mode when flows are configured
Date: Tue, 21 Mar 2017 15:59:14 +0200
Message-ID: <20170321135919.25018-4-saeedm@mellanox.com>
References: <20170321135919.25018-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38156 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757456AbdCUN7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:59:54 -0400
In-Reply-To: <20170321135919.25018-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

Changing the eswitch inline mode can potentially cause already configured
flows not to match the policy. E.g. set policy L4, add some L4 rules,
set policy to L2 --> bad! Hence we disallow it.

Keep track of how many offloaded rules are now set and refuse
inline mode changes if this isn't zero.

Fixes: bffaa916588e ("net/mlx5: E-Switch, Add control for inline mode")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h          | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 9227a83a97e3..ad329b1680b4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -209,6 +209,7 @@ struct mlx5_esw_offload {
 	struct mlx5_eswitch_rep *vport_reps;
 	DECLARE_HASHTABLE(encap_tbl, 8);
 	u8 inline_mode;
+	u64 num_flows;
 };
 
 struct mlx5_eswitch {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index bfabefe20ac0..307ec6c5fd3b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -93,6 +93,8 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				   spec, &flow_act, dest, i);
 	if (IS_ERR(rule))
 		mlx5_fc_destroy(esw->dev, counter);
+	else
+		esw->offloads.num_flows++;
 
 	return rule;
 }
@@ -108,6 +110,7 @@ mlx5_eswitch_del_offloaded_rule(struct mlx5_eswitch *esw,
 		counter = mlx5_flow_rule_counter(rule);
 		mlx5_del_flow_rules(rule);
 		mlx5_fc_destroy(esw->dev, counter);
+		esw->offloads.num_flows--;
 	}
 }
 
@@ -922,6 +925,11 @@ int mlx5_devlink_eswitch_inline_mode_set(struct devlink *devlink, u8 mode)
 	    MLX5_CAP_INLINE_MODE_VPORT_CONTEXT)
 		return -EOPNOTSUPP;
 
+	if (esw->offloads.num_flows > 0) {
+		esw_warn(dev, "Can't set inline mode when flows are configured\n");
+		return -EOPNOTSUPP;
+	}
+
 	err = esw_inline_mode_from_devlink(mode, &mlx5_mode);
 	if (err)
 		goto out;
-- 
2.11.0
