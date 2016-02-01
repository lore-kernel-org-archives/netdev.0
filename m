From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 7/9] net/mlx5_core: Go to next flow table support
Date: Mon,  1 Feb 2016 08:34:43 +0000
Message-ID: <1454315685-32202-8-git-send-email-amir@vadai.me>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:32948 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752454AbcBAIhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 03:37:24 -0500
In-Reply-To: <1454315685-32202-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When destination is NULL, continue processing packet in the following
table.
Will be used by the offloads table, to process the traffic before any
other table (without it knowing who is the next table)

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 6f68dba..fb3717a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -993,9 +993,27 @@ mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 		   u32 flow_tag,
 		   struct mlx5_flow_destination *dest)
 {
+	struct mlx5_flow_destination *my_dest = NULL;
 	struct mlx5_flow_group *g;
 	struct mlx5_flow_rule *rule;
 
+	if (!dest) {
+		struct mlx5_flow_table *next_ft;
+		struct fs_prio *prio;
+
+		fs_get_obj(prio, ft->node.parent);
+		next_ft = find_next_chained_ft(prio);
+		if (!next_ft) {
+			pr_warn("There is no next flow table\n");
+			return ERR_PTR(-EINVAL);
+		}
+		my_dest = kzalloc(sizeof(*my_dest), GFP_KERNEL);
+		if (!my_dest)
+			return ERR_PTR(-ENOMEM);
+		my_dest->type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE;
+		my_dest->ft = next_ft;
+		dest = my_dest;
+	}
 	nested_lock_ref_node(&ft->node, FS_MUTEX_GRANDPARENT);
 	fs_for_each_fg(g, ft)
 		if (compare_match_criteria(g->mask.match_criteria_enable,
@@ -1012,6 +1030,7 @@ mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 				   match_value, action, flow_tag, dest);
 unlock:
 	unlock_ref_node(&ft->node);
+	kfree(my_dest);
 	return rule;
 }
 EXPORT_SYMBOL(mlx5_add_flow_rule);
-- 
2.7.0
