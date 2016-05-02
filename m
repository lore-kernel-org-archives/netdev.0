From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 10/12] net/mlx5: E-Switch, Add promiscuous and allmulti FDB flowtable groups
Date: Mon,  2 May 2016 19:43:42 +0300
Message-ID: <1462207424-4463-11-git-send-email-saeedm@mellanox.com>
References: <1462207424-4463-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:40239 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754538AbcEBQoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2016 12:44:55 -0400
In-Reply-To: <1462207424-4463-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Add promiscuous and allmulti steering groups in FDB table.
Besides the full match L2 steering rules group, we added
two more groups to catch the "miss" rules traffic:
* Allmulti group: One rule that forwards any mcast traffic coming from
either uplink or VFs/PF vports
* Promisc group: One rule that forwards all unmatched traffic coming
from uplink.

Needed for downstream privileged VF promisc and allmulti support.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 91 +++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  2 +
 2 files changed, 79 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 37b4be9..6c72562 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -323,15 +323,17 @@ static void del_l2_table_entry(struct mlx5_core_dev *dev, u32 index)
 
 /* E-Switch FDB */
 static struct mlx5_flow_rule *
-esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u8 mac[ETH_ALEN], u32 vport)
+__esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport,
+			 u8 mac_c[ETH_ALEN], u8 mac_v[ETH_ALEN])
 {
-	int match_header = MLX5_MATCH_OUTER_HEADERS;
-	struct mlx5_flow_destination dest;
+	int match_header = (is_zero_ether_addr(mac_c) ? 0 :
+			    MLX5_MATCH_OUTER_HEADERS);
 	struct mlx5_flow_rule *flow_rule = NULL;
+	struct mlx5_flow_destination dest;
+	u8 *dmac_v = NULL;
+	u8 *dmac_c = NULL;
 	u32 *match_v;
 	u32 *match_c;
-	u8 *dmac_v;
-	u8 *dmac_c;
 
 	match_v = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
 	match_c = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
@@ -339,14 +341,16 @@ esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u8 mac[ETH_ALEN], u32 vport)
 		pr_warn("FDB: Failed to alloc match parameters\n");
 		goto out;
 	}
+
 	dmac_v = MLX5_ADDR_OF(fte_match_param, match_v,
 			      outer_headers.dmac_47_16);
 	dmac_c = MLX5_ADDR_OF(fte_match_param, match_c,
 			      outer_headers.dmac_47_16);
 
-	ether_addr_copy(dmac_v, mac);
-	/* Match criteria mask */
-	memset(dmac_c, 0xff, 6);
+	if (match_header == MLX5_MATCH_OUTER_HEADERS) {
+		ether_addr_copy(dmac_v, mac_v);
+		ether_addr_copy(dmac_c, mac_c);
+	}
 
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
 	dest.vport_num = vport;
@@ -373,6 +377,15 @@ out:
 	return flow_rule;
 }
 
+static struct mlx5_flow_rule *
+esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u8 mac[ETH_ALEN], u32 vport)
+{
+	u8 mac_c[ETH_ALEN];
+
+	eth_broadcast_addr(mac_c);
+	return __esw_fdb_set_vport_rule(esw, vport, mac_c, mac);
+}
+
 static int esw_create_fdb_table(struct mlx5_eswitch *esw, int nvports)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
@@ -407,28 +420,74 @@ static int esw_create_fdb_table(struct mlx5_eswitch *esw, int nvports)
 		esw_warn(dev, "Failed to create FDB Table err %d\n", err);
 		goto out;
 	}
+	esw->fdb_table.fdb = fdb;
 
+	/* Addresses group : Full match unicast/multicast addresses */
 	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable,
 		 MLX5_MATCH_OUTER_HEADERS);
 	match_criteria = MLX5_ADDR_OF(create_flow_group_in, flow_group_in, match_criteria);
 	dmac = MLX5_ADDR_OF(fte_match_param, match_criteria, outer_headers.dmac_47_16);
 	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, 0);
-	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, table_size - 1);
+	/* Preserve 2 entries for allmulti and promisc rules*/
+	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, table_size - 3);
 	eth_broadcast_addr(dmac);
-
 	g = mlx5_create_flow_group(fdb, flow_group_in);
 	if (IS_ERR_OR_NULL(g)) {
 		err = PTR_ERR(g);
 		esw_warn(dev, "Failed to create flow group err(%d)\n", err);
 		goto out;
 	}
-
 	esw->fdb_table.addr_grp = g;
-	esw->fdb_table.fdb = fdb;
+
+	/* Allmulti group : One rule that forwards any mcast traffic */
+	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable,
+		 MLX5_MATCH_OUTER_HEADERS);
+	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, table_size - 2);
+	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, table_size - 2);
+	eth_zero_addr(dmac);
+	dmac[0] = 0x01;
+	g = mlx5_create_flow_group(fdb, flow_group_in);
+	if (IS_ERR_OR_NULL(g)) {
+		err = PTR_ERR(g);
+		esw_warn(dev, "Failed to create allmulti flow group err(%d)\n", err);
+		goto out;
+	}
+	esw->fdb_table.allmulti_grp = g;
+
+	/* Promiscuous group :
+	 * One rule that forward all unmatched traffic from previous groups
+	 */
+	eth_zero_addr(dmac);
+	MLX5_SET(create_flow_group_in, flow_group_in, match_criteria_enable,
+		 MLX5_MATCH_MISC_PARAMETERS);
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria, misc_parameters.source_port);
+	MLX5_SET(create_flow_group_in, flow_group_in, start_flow_index, table_size - 1);
+	MLX5_SET(create_flow_group_in, flow_group_in, end_flow_index, table_size - 1);
+	g = mlx5_create_flow_group(fdb, flow_group_in);
+	if (IS_ERR_OR_NULL(g)) {
+		err = PTR_ERR(g);
+		esw_warn(dev, "Failed to create promisc flow group err(%d)\n", err);
+		goto out;
+	}
+	esw->fdb_table.promisc_grp = g;
+
 out:
+	if (err) {
+		if (!IS_ERR_OR_NULL(esw->fdb_table.allmulti_grp)) {
+			mlx5_destroy_flow_group(esw->fdb_table.allmulti_grp);
+			esw->fdb_table.allmulti_grp = NULL;
+		}
+		if (!IS_ERR_OR_NULL(esw->fdb_table.addr_grp)) {
+			mlx5_destroy_flow_group(esw->fdb_table.addr_grp);
+			esw->fdb_table.addr_grp = NULL;
+		}
+		if (!IS_ERR_OR_NULL(esw->fdb_table.fdb)) {
+			mlx5_destroy_flow_table(esw->fdb_table.fdb);
+			esw->fdb_table.fdb = NULL;
+		}
+	}
+
 	kfree(flow_group_in);
-	if (err && !IS_ERR_OR_NULL(fdb))
-		mlx5_destroy_flow_table(fdb);
 	return err;
 }
 
@@ -438,10 +497,14 @@ static void esw_destroy_fdb_table(struct mlx5_eswitch *esw)
 		return;
 
 	esw_debug(esw->dev, "Destroy FDB Table\n");
+	mlx5_destroy_flow_group(esw->fdb_table.promisc_grp);
+	mlx5_destroy_flow_group(esw->fdb_table.allmulti_grp);
 	mlx5_destroy_flow_group(esw->fdb_table.addr_grp);
 	mlx5_destroy_flow_table(esw->fdb_table.fdb);
 	esw->fdb_table.fdb = NULL;
 	esw->fdb_table.addr_grp = NULL;
+	esw->fdb_table.allmulti_grp = NULL;
+	esw->fdb_table.promisc_grp = NULL;
 }
 
 /* E-Switch vport UC/MC lists management */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 2f979c9..36e87cb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -132,6 +132,8 @@ struct mlx5_l2_table {
 struct mlx5_eswitch_fdb {
 	void *fdb;
 	struct mlx5_flow_group *addr_grp;
+	struct mlx5_flow_group *allmulti_grp;
+	struct mlx5_flow_group *promisc_grp;
 };
 
 struct mlx5_eswitch {
-- 
2.8.0
