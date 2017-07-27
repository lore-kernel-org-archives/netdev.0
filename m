From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 14/14] net/mlx5: Fix mlx5_add_flow_rules call with correct num of dests
Date: Thu, 27 Jul 2017 13:25:32 +0300
Message-ID: <20170727102532.2317-15-saeedm@mellanox.com>
References: <20170727102532.2317-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45005 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751451AbdG0K1O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 06:27:14 -0400
In-Reply-To: <20170727102532.2317-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>

When adding ethtool steering rule with action DISCARD we wrongly
pass a NULL dest with dest_num 1 to mlx5_add_flow_rules().
What this error seems to have caused is sending VPORT 0
(MLX5_FLOW_DESTINATION_TYPE_VPORT) as the fte dest instead of no dests.
We have fte action correctly set to DROP so it might been ignored
anyways.

To reproduce use:
 # sudo ethtool --config-nfc <dev> flow-type ether \
   dst aa:bb:cc:dd:ee:ff action -1

Fixes: 74491de93712 ("net/mlx5: Add multi dest support")
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Mark Bloch <markb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index 22fb993987b4..eafc59280ada 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -320,7 +320,7 @@ add_ethtool_flow_rule(struct mlx5e_priv *priv,
 
 	spec->match_criteria_enable = (!outer_header_zero(spec->match_criteria));
 	flow_act.flow_tag = MLX5_FS_DEFAULT_FLOW_TAG;
-	rule = mlx5_add_flow_rules(ft, spec, &flow_act, dst, 1);
+	rule = mlx5_add_flow_rules(ft, spec, &flow_act, dst, dst ? 1 : 0);
 	if (IS_ERR(rule)) {
 		err = PTR_ERR(rule);
 		netdev_err(priv->netdev, "%s: failed to add ethtool steering rule: %d\n",
-- 
2.13.0
