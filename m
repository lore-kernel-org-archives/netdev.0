From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/mlx5_core: Set flow steering dest only for forward rules
Date: Wed, 27 Jan 2016 17:02:24 +0200
Message-ID: <1453906945-25414-2-git-send-email-ogerlitz@mellanox.com>
References: <1453906945-25414-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Amir Vadai <amir@vadai.me>, Maor Gottlieb <maorg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49139 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932555AbcA0PC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 10:02:56 -0500
In-Reply-To: <1453906945-25414-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>

We need to handle flow table entry destinations only if the action
associated with the rule is
forwarding (MLX5_FLOW_CONTEXT_ACTION_FWD_DEST).

Fixes: 26a8145390b3 ('net/mlx5_core: Introduce flow steering firmware commands')
Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c | 33 +++++++++++++-----------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index a9894d2..0302f44 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -212,25 +212,28 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 	MLX5_SET(flow_context, in_flow_context, group_id, group_id);
 	MLX5_SET(flow_context, in_flow_context, flow_tag, fte->flow_tag);
 	MLX5_SET(flow_context, in_flow_context, action, fte->action);
-	MLX5_SET(flow_context, in_flow_context, destination_list_size,
-		 fte->dests_size);
 	in_match_value = MLX5_ADDR_OF(flow_context, in_flow_context,
 				      match_value);
 	memcpy(in_match_value, &fte->val, MLX5_ST_SZ_BYTES(fte_match_param));
 
-	in_dests = MLX5_ADDR_OF(flow_context, in_flow_context, destination);
-	list_for_each_entry(dst, &fte->node.children, node.list) {
-		unsigned int id;
-
-		MLX5_SET(dest_format_struct, in_dests, destination_type,
-			 dst->dest_attr.type);
-		if (dst->dest_attr.type ==
-		    MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE)
-			id = dst->dest_attr.ft->id;
-		else
-			id = dst->dest_attr.tir_num;
-		MLX5_SET(dest_format_struct, in_dests, destination_id, id);
-		in_dests += MLX5_ST_SZ_BYTES(dest_format_struct);
+	if (fte->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
+		MLX5_SET(flow_context, in_flow_context, destination_list_size,
+			 fte->dests_size);
+		in_dests = MLX5_ADDR_OF(flow_context, in_flow_context, destination);
+		list_for_each_entry(dst, &fte->node.children, node.list) {
+			unsigned int id;
+
+			MLX5_SET(dest_format_struct, in_dests, destination_type,
+				 dst->dest_attr.type);
+			if (dst->dest_attr.type ==
+			    MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE) {
+				id = dst->dest_attr.ft->id;
+			} else {
+				id = dst->dest_attr.tir_num;
+			}
+			MLX5_SET(dest_format_struct, in_dests, destination_id, id);
+			in_dests += MLX5_ST_SZ_BYTES(dest_format_struct);
+		}
 	}
 	memset(out, 0, sizeof(out));
 	err = mlx5_cmd_exec_check_status(dev, in, inlen, out,
-- 
2.3.7
