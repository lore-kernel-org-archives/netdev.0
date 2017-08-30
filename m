From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 1/3] net/mlx5e: Use IP version matching to classify IP traffic
Date: Thu, 31 Aug 2017 02:04:07 +0300
Message-ID: <20170830230409.15176-2-saeedm@mellanox.com>
References: <20170830230409.15176-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34540 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751237AbdH3XEV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 19:04:21 -0400
In-Reply-To: <20170830230409.15176-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

This change adds the ability for flow steering to classify IPv4/6
packets with MPLS tag (Ethertype 0x8847 and 0x8848) as standard IP
packets and hit IPv4/6 classification steering rules.

Since IP packets with MPLS tag header have MPLS ethertype, they
missed the IPv4/6 ethertype rule and ended up hitting the default
filter forwarding all the packets to the same single RQ (No RSS).

Since our device is able to look past the MPLS tag and identify the
next protocol we introduce this solution which replaces ethertype
matching by the device's capability to perform IP version
identification and matching in order to distinguish between IPv4 and
IPv6.
Therefore, when driver is performing flow steering configuration on the
device it will use IP version matching in IP classified rules instead
of ethertype matching which will cause relevant MPLS tagged packets to
hit this rule as well.

If the device doesn't support IP version matching the driver will fall back
to use legacy ethertype matching in the steering as before.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Ariel Levkovich <lariel@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c | 33 ++++++++++++++++++++++---
 1 file changed, 29 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index eecbc6d4f51f..85e6226dacfb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -660,6 +660,17 @@ static struct {
 	},
 };
 
+static u8 mlx5e_etype_to_ipv(u16 ethertype)
+{
+	if (ethertype == ETH_P_IP)
+		return 4;
+
+	if (ethertype == ETH_P_IPV6)
+		return 6;
+
+	return 0;
+}
+
 static struct mlx5_flow_handle *
 mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
 			struct mlx5_flow_table *ft,
@@ -667,10 +678,12 @@ mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
 			u16 etype,
 			u8 proto)
 {
+	int match_ipv_outer = MLX5_CAP_FLOWTABLE_NIC_RX(priv->mdev, ft_field_support.outer_ip_version);
 	MLX5_DECLARE_FLOW_ACT(flow_act);
 	struct mlx5_flow_handle *rule;
 	struct mlx5_flow_spec *spec;
 	int err = 0;
+	u8 ipv;
 
 	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
 	if (!spec)
@@ -681,7 +694,13 @@ mlx5e_generate_ttc_rule(struct mlx5e_priv *priv,
 		MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.ip_protocol);
 		MLX5_SET(fte_match_param, spec->match_value, outer_headers.ip_protocol, proto);
 	}
-	if (etype) {
+
+	ipv = mlx5e_etype_to_ipv(etype);
+	if (match_ipv_outer && ipv) {
+		spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+		MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.ip_version);
+		MLX5_SET(fte_match_param, spec->match_value, outer_headers.ip_version, ipv);
+	} else if (etype) {
 		spec->match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
 		MLX5_SET_TO_ONES(fte_match_param, spec->match_criteria, outer_headers.ethertype);
 		MLX5_SET(fte_match_param, spec->match_value, outer_headers.ethertype, etype);
@@ -739,7 +758,9 @@ static int mlx5e_generate_ttc_table_rules(struct mlx5e_priv *priv)
 #define MLX5E_TTC_TABLE_SIZE	(MLX5E_TTC_GROUP1_SIZE +\
 				 MLX5E_TTC_GROUP2_SIZE +\
 				 MLX5E_TTC_GROUP3_SIZE)
-static int mlx5e_create_ttc_table_groups(struct mlx5e_ttc_table *ttc)
+
+static int mlx5e_create_ttc_table_groups(struct mlx5e_ttc_table *ttc,
+					 bool use_ipv)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
 	struct mlx5e_flow_table *ft = &ttc->ft;
@@ -761,7 +782,10 @@ static int mlx5e_create_ttc_table_groups(struct mlx5e_ttc_table *ttc)
 	/* L4 Group */
 	mc = MLX5_ADDR_OF(create_flow_group_in, in, match_criteria);
 	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.ip_protocol);
-	MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.ethertype);
+	if (use_ipv)
+		MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.ip_version);
+	else
+		MLX5_SET_TO_ONES(fte_match_param, mc, outer_headers.ethertype);
 	MLX5_SET_CFG(in, match_criteria_enable, MLX5_MATCH_OUTER_HEADERS);
 	MLX5_SET_CFG(in, start_flow_index, ix);
 	ix += MLX5E_TTC_GROUP1_SIZE;
@@ -812,6 +836,7 @@ void mlx5e_destroy_ttc_table(struct mlx5e_priv *priv)
 
 int mlx5e_create_ttc_table(struct mlx5e_priv *priv)
 {
+	bool match_ipv_outer = MLX5_CAP_FLOWTABLE_NIC_RX(priv->mdev, ft_field_support.outer_ip_version);
 	struct mlx5e_ttc_table *ttc = &priv->fs.ttc;
 	struct mlx5_flow_table_attr ft_attr = {};
 	struct mlx5e_flow_table *ft = &ttc->ft;
@@ -828,7 +853,7 @@ int mlx5e_create_ttc_table(struct mlx5e_priv *priv)
 		return err;
 	}
 
-	err = mlx5e_create_ttc_table_groups(ttc);
+	err = mlx5e_create_ttc_table_groups(ttc, match_ipv_outer);
 	if (err)
 		goto err;
 
-- 
2.13.0
